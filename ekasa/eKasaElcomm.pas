unit eKasaElcomm;

interface

uses
  uEkasaPrinters, Elcomm_TLB_3_0, DelUp;

const
  C_PAR_SEP = #9;
  C_DP_SEP = '.';
  C_BOOL_TRUE = '1';

  C_ReceiptMode_Registration = 'registration';
  C_ReceiptMode_Training = 'training';

  C_ReceiptType_Sale = 'sale';
  C_ReceiptType_Refund = 'refund';
  C_ReceiptType_Corection = 'corection';
  C_ReceiptType_Invoice = 'invoice';
  C_ReceiptType_Inout = 'inout';

  C_TenderType_Cash = 'cash';
  C_TenderType_Card = 'card'; // alebo 'credit'
  C_TenderType_Check = 'check'; // alebo 'cheque' alebo 'chegue'

  C_Command_BR = 'BR';
  // Begin Receipt - otvorenie uctenky - Tento príkaz sa používa len v SK eKasa (on-line) pokladniciach. Je povinný na zaèiatku každej úètenky predaja položiek (nepoužíva sa pre úhradu faktúry).
  C_Command_SI = 'SI';
  // Sell Item - predaj tovarovej polozky z databazi pocitaca
  C_Command_SC = 'SC';
  // Sell Container - predaj vratneho obalu z databazi pocitaca
  C_Command_RI = 'RI';
  // Return Item - vratenie tovarovej polozky z databazi pocitaca
  C_Command_RC = 'RC';
  // Return Container - vykup/vratenie vratneho obalu z databazi pocitaca
  C_Command_DB = 'DB';
  // DataBase - predaj tovarovej polozky/vratneho obalu y databazi pocitaca
  C_Command_RD = 'RD';
  // Return Database Item - vrátenie tovarovej polozky/vratneho obalu z databázy pokladnice
  C_Command_INV = 'INV'; // Invoice - uhrada faktury
  C_Command_RIN = 'RIN'; // ReturnInvoice - vratenie faktury
  C_Command_PAR = 'PAR';
  // Paragon - Tento príkaz nastaví režim úètovania paragonov. Príkaz je potrebné zada po príkaze BR, INV, RIN, ale zároveò pred príkazom PV. Tento príkaz je podporovaný len v SK eKasa (on-line) pokladniciach.
  C_Command_CUST = 'CUST';
  // Customer - identifikator kupujuceho - Týmto príkazom je možné nastavi kupujúceho (pre identifikáciu colnou správou; hodnota nemá slúži ako náhrada zákazníckych kariet). Príkaz je potrebné zada po príkaze BR, INV, RIN, ale zároveò pred príkazom PV. Tento príkaz je podporovaný len v SK eKasa (on-line) pokladniciach.
  C_Command_PV = 'PV'; // Payment Value - platba/ukoncenie nakupu
  C_Command_DV = 'DV';
  // Direct Void - okamzita oprava poslednej operacie predaja
  C_Command_VI = 'VI'; // Void Item - oprava (storno) polozky z uctenky
  C_Command_VR = 'VR'; // Void Receipt - storno/anulacia neukoncenej uctenky
  C_Command_OD = 'OD'; // Open Drawer - otvorit zasuvku
  C_Command_RN = 'RN'; // Reference Number - referencne cislo
  C_Command_PA = 'PA'; // Price Adjust - uprava ceny
  C_Command_PSur = '+%'; // percentualna (%) prirazka (+)
  C_Command_PDis = '-%'; // percentualna (%) zlava (-)
  C_Command_VSur = '+V'; // hodnotova (Value) prirazka (+)
  C_Command_VDis = '-V'; // hodnotova (Value) zlava (-)
  C_Command_PD = 'PD'; // Print Duplicate - vytlacenie duplikatu uctenky
  C_Command_RA = 'RA';
  // Receive on Account - vklad finacnej hotovosti na zaciatku dna
  C_Command_PO = 'PO'; // Pay Out - vyber (nie len) hotovosti zo zasuvky

resourcestring
  rs_connection_error =
    '{"errorCode":500,"error":"Nepodarilo sa spojenie s Elcomm. Skontrolujte ju!"}';

type
  TVatRec = record
    vatID: integer;
    vatFlag: string;
    vatRate: currency;
  end;

  TVats = array of TVatRec;

procedure internalInit();
procedure internalClose();

function eKasaElcommInit: boolean;
function eKasaElcommWork(action: TEkasaActions): string;

var
  Elcomm: CCommLib;
  Vats: TVats;
  elcommOpen: boolean = false;
  cashRoundSupport: integer = -1;
  // -1 nebolo zistene, 0 nepodporovane, 1 podporovane

implementation

uses
  payPackageUtils, uSettings, SysUtils, Classes, superObject, StrUtils,
  ActiveX, uEkasaHelper;

function getPluCount(): integer;
var
  retVal: eGRetVal;
begin
  result := 0;
  try
    retVal := Elcomm.OpenTable('PLU');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.OpenTable(PLU) => %d;', [retVal]));
    if retVal <> eGRetVal_TableOpenReadOneWriteOne then
      exit;
    result := Elcomm.GetRecordCount; // nacitame pocet PLU
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.GetRecordCount => %d;', [result]));
  finally
    retVal := Elcomm.CloseTable();
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.CloseTable() => %d;', [retVal]));
  end;
end;

procedure internalReadVats();

  function decodeVat(id: integer; data: string): TVatRec;
  var
    s: string;
    sl: TStringList;
  begin
    result.vatID := id;
    result.vatFlag := 'TAXFREE'; // 'VAT','TAXFREE','INVOICE'
    result.vatRate := 0;
    sl := TStringList.Create;
    try
      sl.Clear;
      sl.LineBreak := C_PAR_SEP;
      sl.Text := data;
      s := StringReplace(sl.Strings[0], '.', FormatSettings.DecimalSeparator,
        [rfReplaceAll]);
      result.vatRate := StrToCurr(s);
      result.vatFlag := sl.Strings[1];
    finally
      sl.Free;
    end;
  end;

var
  retVal: eGRetVal;
  i, rec_count: integer;
  data: WideString;
begin
  try
    retVal := Elcomm.OpenTable('TAXGROUP');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.OpenTable(TAXGROUP) => %d;', [retVal]));
    if retVal <> eGRetVal_TableOpenReadOneWriteNone then
      exit;

    retVal := Elcomm.SetHeader('TAXGROUP_RATE' + C_PAR_SEP + 'TAXGROUP_TYPE');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetHeader(TAXGROUP_RATE' + C_PAR_SEP +
        'TAXGROUP_TYPE) => %d;', [retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    rec_count := Elcomm.GetRecordCount; // nacitame pocet sadzieb
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.GetRecordCount => %d;', [retVal]));

    if rec_count > 0 then
    begin
      if Assigned(Vats) then
        Vats := nil;
      SetLength(Vats, rec_count);
      for i := 1 to rec_count do
      begin
        retVal := Elcomm.GetRecord(IntToStr(i), data);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.GetRecord(%d,%s) => %d;', [i, data, retVal]));
        if retVal <> eGRetVal_AllOk then
          exit;
        Vats[i - 1] := decodeVat(i, data);
      end;
    end;

  finally
    retVal := Elcomm.CloseTable();
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.CloseTable() => %d;', [retVal]));
  end;
end;

procedure internalPriceConfig();
var
  retVal: eGRetVal;
  f_RecordData: WideString;
  unitPriceScale: string;
  sl: TStringList;
begin
  try
    retVal := Elcomm.OpenTable('PRICECONFIG');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.OpenTable(PRICECONFIG) => %d;', [retVal]));
    if (retVal <> eGRetVal_TableOpenReadOneWriteOne) then
      exit;

    retVal := Elcomm.SetHeader('unitprice_scale' + C_PAR_SEP + 'price_roundtype'
      + C_PAR_SEP + 'price_roundplace');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetHeader(unitprice_scale' + C_PAR_SEP +
        'price_roundtype' + C_PAR_SEP + 'price_roundplace) => %d;', [retVal]));
    if (retVal <> eGRetVal_AllOk) then
      exit;

    f_RecordData := '';
    retVal := Elcomm.GetRecord('1', f_RecordData);
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.GetRecord(1,%s) => %d;', [f_RecordData, retVal]));
    if (retVal <> eGRetVal_AllOk) then
      exit;

    sl := TStringList.Create;
    try
      sl.Clear;
      sl.LineBreak := C_PAR_SEP;
      sl.Text := f_RecordData;
      unitPriceScale := sl.Strings[0];
    finally
      sl.Free;
    end;

    if not(unitPriceScale = '3') then
    begin
      f_RecordData := '3' + C_PAR_SEP + 'UPFROM5' + C_PAR_SEP + '2';
      retVal := Elcomm.SetRecord('1', f_RecordData);
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.SetRecord(1,%s) => %d;', [f_RecordData, retVal]));
    end;

  finally
    retVal := Elcomm.CloseTable();
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.CloseTable() => %d;', [retVal]));
  end;
end;

function strReplaceNonChars(Text: string): string;
begin
  result := StringReplace(Text, #1, '', [rfReplaceAll]);
  result := StringReplace(result, #2, '', [rfReplaceAll]);
  result := StringReplace(result, #3, '', [rfReplaceAll]);
  result := StringReplace(result, #4, '', [rfReplaceAll]);
  result := StringReplace(result, #5, '', [rfReplaceAll]);
  result := StringReplace(result, #6, '', [rfReplaceAll]);
  result := StringReplace(result, #7, '', [rfReplaceAll]);
  result := StringReplace(result, #8, '', [rfReplaceAll]);
  result := StringReplace(result, #9, '', [rfReplaceAll]);
  result := StringReplace(result, #10, '', [rfReplaceAll]);
  result := StringReplace(result, #11, '', [rfReplaceAll]);
  result := StringReplace(result, #12, '', [rfReplaceAll]);
  result := StringReplace(result, #13, '', [rfReplaceAll]);
  result := StringReplace(result, #14, '', [rfReplaceAll]);
  result := StringReplace(result, #15, '', [rfReplaceAll]);
  result := StringReplace(result, #16, '', [rfReplaceAll]);
  result := StringReplace(result, #17, '', [rfReplaceAll]);
  result := StringReplace(result, #18, '', [rfReplaceAll]);
  result := StringReplace(result, #19, '', [rfReplaceAll]);
  result := StringReplace(result, #20, '', [rfReplaceAll]);
  result := StringReplace(result, #21, '', [rfReplaceAll]);
  result := StringReplace(result, #22, '', [rfReplaceAll]);
  result := StringReplace(result, #23, '', [rfReplaceAll]);
  result := StringReplace(result, #24, '', [rfReplaceAll]);
  result := StringReplace(result, #25, '', [rfReplaceAll]);
  result := StringReplace(result, #26, '', [rfReplaceAll]);
  result := StringReplace(result, #27, '', [rfReplaceAll]);
  result := StringReplace(result, #28, '', [rfReplaceAll]);
  result := StringReplace(result, #29, '', [rfReplaceAll]);
  result := StringReplace(result, #30, '', [rfReplaceAll]);
  result := StringReplace(result, #31, '', [rfReplaceAll]);
end;

function getReference(): string;
var
  ref: WideString;
begin
  ref := '';
  Elcomm.GetDeviceInfo('fiscalinfo\reference_id', ref);
  result := ref;
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('Elcomm.GetDeviceInfo(%s,%s);',
      ['fiscalinfo\reference_id', ref]));
end;

function getElcommDate(sDateTime: string): string;
begin
  result := Copy(sDateTime, 9, 2) + Copy(sDateTime, 6, 2) +
    Copy(sDateTime, 1, 4); // DDMMYYYY
end;

function getElcommTime(sDateTime: string): string;
begin
  result := Copy(sDateTime, 12, 2) + Copy(sDateTime, 15, 2) +
    Copy(sDateTime, 18, 2); // hhnnss
end;

function get_vatID(vatRate: string): string;
var
  i: integer;
  vatFlag: string;
  vatRateCurr: currency;
begin
  vatRate := ReplaceStr(vatRate, '%', '');
  vatRate := ReplaceStr(vatRate, 'OOD', '');
  vatRate := ReplaceStr(vatRate, 'PDP', '');
  vatRate := ReplaceStr(vatRate, 'CK', '');
  vatRate := ReplaceStr(vatRate, 'PT', '');
  vatRate := ReplaceStr(vatRate, 'UD', '');
  vatRate := ReplaceStr(vatRate, 'ZPS', '');
  vatRate := ReplaceStr(vatRate, 'INE', '');
  vatRateCurr := StrToCurrDef(vatRate, 0);
  result := '1';
  vatFlag := IfThen(vatRateCurr = 0, 'TAXFREE', 'VAT');
  if Assigned(Vats) then
  begin
    for i := 0 to High(Vats) do
      if (Vats[i].vatFlag = vatFlag) and (Vats[i].vatRate = vatRateCurr) then
      begin
        result := IntToStr(Vats[i].vatID);
        break;
      end;
  end;
end;

function errorStr(errCode: eGRetVal): string;
var
  retVal: eGRetVal;
  f_ErrorText: WideString;
begin
  result := Format('Code: %d ', [errCode]);
  retVal := Elcomm.GetErrorText(errCode, f_ErrorText);
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('Elcomm.GetErrorText(%d,%s) => %d;', [errCode, f_ErrorText,
      retVal]));
  if retVal = eGRetVal_AllOk then
    result := result + Format('Text: %s ', [f_ErrorText]);
{$IFDEF DEBUG}
  result := result + Format('Level: %d ', [Elcomm.GetErrorLevel(errCode)]);
  result := result + Format('Type: %d', [Elcomm.GetErrorType(errCode)]);
{$ENDIF}
end;

procedure internalInit();
var
  retVal: eGRetVal;
begin
  if not elcommOpen then
  begin
    retVal := Elcomm.Connect('', '');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.Connect() => %d;', [retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;
    elcommOpen := true;
  end;
end;

procedure internalClose();
var
  retVal: eGRetVal;
begin
  if (elcommOpen = false) then
    exit;

  retVal := Elcomm.Disconnect();
  if fSettings.B['ekasa.withLog'] then
    addLog(Format('Elcomm.Disconnect() => %d;', [retVal]));
  if retVal <> eGRetVal_AllOk then
    exit;
  elcommOpen := false;
end;

function init_eKasaElcomm(): integer;
var
  retVal: eGRetVal;
  data: WideString;
  ver: integer;
  f_UniqueID: eCashRegisterUID;

  function getUniqueID(eKasaTyp: integer): eCashRegisterUID;
  begin
    result := 0;
    case eKasaTyp of
      ord(ftEEuro50T):
        result := 329; // Euro-50T Mini
      ord(ftEEuro50TE):
        result := 330; // Euro-50TE Mini
      ord(ftEEuro50TECash):
        result := 332; // Euro-50TE Cash
      ord(ftEEuro50TEMedi):
        result := 333; // Euro-50TE Medi
      ord(ftEEuro50TESmart):
        result := 334; // Euro-50TE Smart
      ord(ftEEuro50iTE):
        result := 338; // Euro-50iTE Mini
      ord(ftEEuro50iTECash):
        result := 340; // Euro-50iTE Cash
      ord(ftEEuro150TEF):
        result := 362; // Euro-150TE Flexy
      ord(ftEEuro150iTEF):
        result := 366; // Euro-150iTE Flexy
      ord(ftEEuro150TEFP):
        result := 378; // Euro-150TE Flexy Plus
      ord(ftEEuro150iTEFP):
        result := 382; // Euro-150iTE Flexy Plus
      ord(ftEEuro80B):
        result := 394; // Euro-80B
      ord(frEEuro2100i):
        result := 425; // Euro-2100i
    end;
  end;

begin
  result := -1;
  isEkasaInit := false;
  retVal := eGRetVal_AllOk;

  if not CheckInstalledPackage(pckgElcomEuro, true) then
    exit;
  try
    Elcomm := nil;
    try
      CoInitialize(nil);
      Elcomm := CoCCommLib.Create;
    except
      exit;
    end;

    retVal := Elcomm.Initialize('SK');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.Initialize(%s) => %d;', ['SK', retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    f_UniqueID := getUniqueID(fSettings.i['ekasa.typ']);
    retVal := Elcomm.SetActiveCashRegister(f_UniqueID);
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetActiveCashRegister(%d) => %d;',
        [f_UniqueID, retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    // Odde¾ovaè jednotlivých položiek v rámci jedného záznamu.
    retVal := Elcomm.SetConfigValue('item_sep', C_PAR_SEP);
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;',
        ['item_sep', C_PAR_SEP, retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    // Odde¾ovaè desatinnej èasti èísel.
    retVal := Elcomm.SetConfigValue('dec_sep', C_DP_SEP);
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;', ['dec_sep', C_DP_SEP,
        retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    // Prida text chyby (dôvod zamietnutia) zaslaný serverom.
    retVal := Elcomm.SetConfigValue('include_server_message_in_error_text',
      C_BOOL_TRUE);
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;',
        ['include_server_message_in_error_text', C_BOOL_TRUE, retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    case fSettings.i['ekasa.connectionTyp'] of
      ord(connectionRS232), ord(connectionUSB):
        begin // USB "COM3:38400,n,8,1"
          retVal := Elcomm.SetConfigValue('port', Format('COM%d:38400,n,8,1',
            [fSettings.i['ekasa.comPort']]));
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;',
              ['port', Format('COM%d:38400,n,8,1',
              [fSettings.i['ekasa.comPort']]), retVal]));
          if retVal <> eGRetVal_AllOk then
            exit;
        end;
      ord(connectionTCP):
        begin // ethernet "tcp://192.168.1.25:49999"
          retVal := Elcomm.SetConfigValue('port',
            Format('tcp://%s', [fSettings.s['ekasa.hostAddress']]));
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;',
              ['port', Format('tcp://%s', [fSettings.s['ekasa.hostAddress']]),
              retVal]));
          if retVal <> eGRetVal_AllOk then
            exit;
          retVal := Elcomm.SetConfigValue('link_delay', '5000');
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.SetConfigValue(%s,%s) => %d;',
              ['link_delay', '5000', retVal]));
          if retVal <> eGRetVal_AllOk then
            exit;
        end;
    end;

    retVal := Elcomm.Connect('', '');
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.Connect() => %d;', [retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    if (cashRoundSupport = -1) then
    begin
      cashRoundSupport := 0;

      retVal := Elcomm.GetDeviceInfo('sw_version', data);
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.GetDeviceInfo(%s,%s) => %d;', ['sw_version', data,
          retVal]));
      if retVal <> eGRetVal_AllOk then
        exit;

      data := StringReplace(data, '.', '', [rfReplaceAll]); // 3.017.01
      ver := StrToInt(data);
      if (ver >= 301701) then
        cashRoundSupport := 1
      else
        cashRoundSupport := 0;
    end;

    retVal := Elcomm.Disconnect();
    if fSettings.B['ekasa.withLog'] then
      addLog(Format('Elcomm.Disconnect() => %d;', [retVal]));
    if retVal <> eGRetVal_AllOk then
      exit;

    isEkasaInit := (cashRoundSupport = 0) or (cashRoundSupport = 1);
  finally
    result := retVal;
  end;
end;

function eKasaElcommInit: boolean;
var
  initResult: integer;
begin
  if not isEkasaInit then
  begin
    initResult := init_eKasaElcomm;
    if (initResult <> 0) then
      lastError := errorStr(initResult);
  end;
  result := isEkasaInit;
end;

function elcommState(): string;
var
  retVal: eGRetVal;
  data: WideString;
  sl: TStringList;
  i: integer;
  o: ISuperObject;

  function Flag(vatFlag: string; vatRate: currency): string;
  begin
    result := 'zakázaná';
    if vatRate < 100 then
    begin
      if vatFlag = 'VAT' then
        result := 'zdanite¾ná'
      else if vatFlag = 'TAXFREE' then
        result := 'nezdanite¾ná'
      else if vatFlag = 'INVOICE' then
        result := 'faktúry'
      else
        result := 'neznáma';
    end;
  end;

begin
  result := '';
  retVal := eGRetVal_AllOk;
  sl := TStringList.Create;
  internalInit();
  try
    if (elcommOpen) then
    begin
      retVal := Elcomm.GetDeviceInfo('ecr_name' + C_PAR_SEP + 'sw_version' +
        C_PAR_SEP + 'protocol_version' + C_PAR_SEP + 'serial_num', data);
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.GetDeviceInfo(%s,%s) => %d;',
          ['ecr_name' + C_PAR_SEP + 'sw_version' + C_PAR_SEP +
          'protocol_version' + C_PAR_SEP + 'serial_num', data, retVal]));
      if (retVal <> eGRetVal_AllOk) then
        exit;

      o := SO();
      sl.Clear;
      sl.LineBreak := C_PAR_SEP;
      sl.Text := data;

      o.s['arr[]'] := 'Status ekasy';
      o.s['arr[]'] := '=======================';
      o.s['arr[]'] := Format('Názov pokladnice: %s', [sl.Strings[0]]);
      o.s['arr[]'] := Format('Verzia firmvéru: %s', [sl.Strings[1]]);
      o.s['arr[]'] := Format('Ver. kom. protokolu: %s', [sl.Strings[2]]);
      o.s['arr[]'] := Format('Unikátne èíslo: %s', [sl.Strings[3]]);
      o.s['arr[]'] := Format('Poèet PLU: %d', [getPluCount()]);
      o.s['arr[]'] := '';
      o.s['arr[]'] := 'Nastavenie daní';
      o.s['arr[]'] := '=======================';
      o.s['arr[]'] := 'Daò Typ dane         Sadzba';
      if not Assigned(Vats) then
        internalReadVats();
      for i := Low(Vats) to High(Vats) do
      begin

        o.s['arr[]'] := LeftStr(IntToStr(Vats[i].vatID) + StringOfChar(' ', 8),
          8) + LeftStr(Flag(Vats[i].vatFlag, Vats[i].vatRate) +
          StringOfChar(' ', 20), 20) + CurrToStr(Vats[i].vatRate) + ' %';
      end;

      result := o['arr'].AsString;
    end
    else
      result := rs_connection_error;
  finally
    if Assigned(sl) then
      sl.Free;
    if (retVal <> eGRetVal_AllOk) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [retVal, errorStr(retVal)]);
    internalClose();
  end;
end;

function elcommCopyLast(): string;
var
  retVal: eGRetVal;
begin
  result := '';
  retVal := eGRetVal_AllOk;
  internalInit();
  try
    if (elcommOpen) then
    begin
      retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration,
        C_ReceiptType_Sale);
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
          [C_ReceiptMode_Registration, C_ReceiptType_Sale, retVal]));
      if (retVal <> eGRetVal_AllOk) then
        exit;

      retVal := Elcomm.ReceiptCommand(C_Command_PD, '');
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
          [C_Command_PD, '', retVal]));
      if (retVal <> eGRetVal_AllOk) then
        exit;

      result := '{"message":"OK"}';
    end
    else
      result := rs_connection_error;
  finally
    if (retVal <> eGRetVal_AllOk) then
    begin
      Elcomm.ReceiptCommand(C_Command_VR, '');
      // storno/anulacia neukoncenej uctenky
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [retVal, errorStr(retVal)]);
    end;
    internalClose();
  end;
end;

function elcommReceipt(): string;
var
  retVal: eGRetVal;
  f_Command, f_Parameters, f_ReferenceID, f_ReceiptType, uidOkp: string;
  reqObj, item: ISuperObject;
  totalSum, roundSum, unit_price: currency;
  special_regulation: string;

  function checkReferenceID(): string;
  var
    item: ISuperObject;
  begin
    result := '';
    for item in reqObj['ReceiptData.Items'] do
    begin
      if (item.C['Quantity'] < 0) then
      begin
        if not(isReturnType(item.s['Custom.Unit'])) then
        begin
          result := reqObj.s['ReferenceReceiptId'];
          break;
        end;
      end;
    end;
  end;

  function specialRegulation(taxType: string): string;
  begin
    result := '2';
    if (taxType = 'OOD') then
      result := '2'
    else if (taxType = 'PDP') then
      result := '1'
    else if (taxType = 'CK') then
      result := '3'
    else if (taxType = 'PT') then
      result := '4'
    else if (taxType = 'UD') then
      result := '5'
    else if (taxType = 'ZPS') then
      result := '6';
  end;

begin
  result := '';
  retVal := eGRetVal_AllOk;
  internalInit();
  try
    if (elcommOpen) then
    begin
      reqObj := SO(reqData);

      if (reqObj.s['ReceiptData.ReceiptType'] = 'PD') then
      begin
        if not Assigned(Vats) then
          internalReadVats();

        // TODO = check ci je vratenie/storno a naplnenie
        f_ReferenceID := checkReferenceID();
        f_ReceiptType := IfThen(f_ReferenceID = '', C_ReceiptType_Sale,
          C_ReceiptType_Refund);
        retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration, f_ReceiptType);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
            [C_ReceiptMode_Registration, f_ReceiptType, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        // otvorenie uctenky
        retVal := Elcomm.ReceiptCommand(C_Command_BR, f_ReferenceID);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
            [C_Command_BR, f_ReferenceID, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        for item in reqObj['ReceiptData.Items'] do
        begin

          if (item.s['ItemType'] = 'Z') then
          begin
            f_Command := C_Command_VDis;
            f_Parameters := value_x(Abs((item.C['Amount'])), 3);
            retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
            if fSettings.B['ekasa.withLog'] then
              addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
                [f_Command, f_Parameters, retVal]));
            if retVal <> eGRetVal_AllOk then
              exit;
          end
          else
          begin
            if (item.C['Quantity'] > 0) then // predaj
              f_Command := IfThen(isReturnType(item.s['Custom.Unit']),
                C_Command_SC, C_Command_SI)
            else // vratenie/storno
              f_Command := IfThen(isReturnType(item.s['Custom.Unit']),
                C_Command_RC, C_Command_RI);

            special_regulation := '';
            if not(item.s['SpecialRegulation'] = '') then
              special_regulation :=
                specialRegulation(item.s['SpecialRegulation']);

            unit_price := item.C['Custom.PriceUnit'];

            f_Parameters := strReplaceNonChars(item.s['Name']) + C_PAR_SEP +
            // description - dåžka reazca je závislá na type pokladnice => pokladnica si oreze text sama
              value_x(Abs(unit_price), 3) + C_PAR_SEP + // unit_price
              get_vatID(item.s['VatRate']) + C_PAR_SEP +
            // ID záznamu daòovej hladiny (1 ÷ n)
              special_regulation + C_PAR_SEP + value_x(Abs(item.C['Quantity']),
              3) + C_PAR_SEP + // quantity1
              '*' + C_PAR_SEP + // qoperator
              '1' + C_PAR_SEP + // quantity2
              strReplaceNonChars(item.s['Custom.Unit']);
            // unit_name - 3 znaky na názov mernej jednotky

            retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
            if fSettings.B['ekasa.withLog'] then
              addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
                [f_Command, f_Parameters, retVal]));
            if (retVal <> eGRetVal_AllOk) then
              exit;
          end;
        end;

        // identifikacia dokladu ako paragonu
        if (reqObj.B['ReceiptData.Paragon']) then
        begin
          f_Parameters := strReplaceNonChars
            (reqObj.s['ReceiptData.ParagonNumber']) + C_PAR_SEP + // number
            getElcommDate(reqObj.s['ReceiptData.IssueDate']) + C_PAR_SEP +
          // date DDMMRRRR
            getElcommTime(reqObj.s['ReceiptData.IssueDate']);
          // time HHMM, alebo HHMMSS
          retVal := Elcomm.ReceiptCommand('PAR', f_Parameters);
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
              ['PAR', f_Parameters, retVal]));
          if (retVal <> eGRetVal_AllOk) then
            exit;
        end;

        // PLATBY
        // Hotovost
        if ((reqObj.C['ReceiptData.Custom.PaymentCash'] <> 0) or
          (reqObj.C['ReceiptData.Amount'] = 0)) then
        begin
          f_Command := C_Command_PV;
          f_Parameters := IfThen(reqObj.C['ReceiptData.Custom.PaymentCash'] > 0,
            value_x(reqObj.C['ReceiptData.Custom.PaymentCash'], 2), '') +
            C_PAR_SEP +
          // hodnota platby (volite¾né – default hodnota je rovná hodnote nákupu)
            C_TenderType_Cash + C_PAR_SEP +
          // typ platby (volite¾né – default 'cash')
            '' + C_PAR_SEP + // mena (volite¾né – default 'national')
            ''; // èíslo platobnej karty (volite¾né)

          retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
              [f_Command, f_Parameters, retVal]));
          if (retVal <> eGRetVal_AllOk) then
            exit;
        end;
        // Platobna karta
        if (reqObj.C['ReceiptData.Custom.PaymentCard'] <> 0) then
        begin
          f_Command := C_Command_PV;
          f_Parameters := IfThen(reqObj.C['ReceiptData.Custom.PaymentCard'] > 0,
            value_x(reqObj.C['ReceiptData.Custom.PaymentCard'], 2), '') +
            C_PAR_SEP +
          // hodnota platby (volite¾né – default hodnota je rovná hodnote nákupu)
            C_TenderType_Card + C_PAR_SEP +
          // typ platby (volite¾né – default 'cash')
            '' + C_PAR_SEP + // mena (volite¾né – default 'national')
            ''; // èíslo platobnej karty (volite¾né)

          retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
              [f_Command, f_Parameters, retVal]));
          if (retVal <> eGRetVal_AllOk) then
            exit;
        end;
        // Sek
        if (reqObj.C['ReceiptData.Custom.PaymentCheck'] <> 0) then
        begin
          f_Command := C_Command_PV;
          f_Parameters := IfThen(reqObj.C['ReceiptData.Custom.PaymentCheck'] >
            0, value_x(reqObj.C['ReceiptData.Custom.PaymentCheck'], 2), '') +
            C_PAR_SEP +
          // hodnota platby (volite¾né – default hodnota je rovná hodnote nákupu)
            C_TenderType_Check + C_PAR_SEP +
          // typ platby (volite¾né – default 'cash')
            '' + C_PAR_SEP + // mena (volite¾né – default 'national')
            ''; // èíslo platobnej karty (volite¾né)

          retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
              [f_Command, f_Parameters, retVal]));
          if (retVal <> eGRetVal_AllOk) then
            exit;
        end;

        retVal := Elcomm.CloseReceipt();
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.CloseReceipt() => %d;', [retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s úspešne zaevidovaný a odoslaný do tlaèiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);
      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'UF') then
      begin
        retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration,
          C_ReceiptType_Invoice);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
            [C_ReceiptMode_Registration, C_ReceiptType_Invoice, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        // typ dokladu uhrada faktury / strono uhrady faktury
        f_Command := IfThen(reqObj.C['ReceiptData.Amount'] > 0, C_Command_INV,
          C_Command_RIN);
        f_Parameters := strReplaceNonChars(reqObj.s['ReceiptData.InvoiceNumber']
          ) + C_PAR_SEP +
        // invoice number - length of the string depends on the type of cash register
          value_x(Abs(reqObj.C['ReceiptData.Amount']), 2);
        // invoice price - from 0.00 to 999999.999

        retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
            [f_Command, f_Parameters, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        // identifikacia dokladu ako paragonu
        if (reqObj.B['ReceiptData.Paragon']) then
        begin
          f_Parameters := strReplaceNonChars
            (reqObj.s['ReceiptData.ParagonNumber']) + C_PAR_SEP + // number
            getElcommDate(reqObj.s['ReceiptData.IssueDate']) + C_PAR_SEP +
          // date DDMMRRRR
            getElcommTime(reqObj.s['ReceiptData.IssueDate']);
          // time HHMM, alebo HHMMSS
          retVal := Elcomm.ReceiptCommand('PAR', f_Parameters);
          if fSettings.B['ekasa.withLog'] then
            addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
              ['PAR', f_Parameters, retVal]));
          if (retVal <> eGRetVal_AllOk) then
            exit;
        end;

        totalSum := reqObj.C['ReceiptData.Amount'];
        roundSum := reqObj.C['ReceiptData.Custom.PaymentCard'] +
          reqObj.C['ReceiptData.Custom.PaymentCash'] - reqObj.C
          ['ReceiptData.Amount'];
        if (cashRoundSupport = 1) then
          totalSum := totalSum + roundSum;
        // platby
        f_Command := C_Command_PV;
        f_Parameters := IfThen(totalSum > 0, value_x(totalSum, 2), '') +
          C_PAR_SEP +
        // hodnota platby (volite¾né – default hodnota je rovná hodnote nákupu)
          C_TenderType_Cash + C_PAR_SEP +
        // typ platby (volite¾né – default 'cash')
          '' + C_PAR_SEP + // mena (volite¾né – default 'national')
          ''; // èíslo platobnej karty (volite¾né)

        retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
            [f_Command, f_Parameters, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        retVal := Elcomm.CloseReceipt();
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.CloseReceipt() => %d;', [retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s úspešne zaevidovaný a odoslaný do tlaèiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp])
      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'VK') then
      begin
        retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration,
          C_ReceiptType_Inout);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
            [C_ReceiptMode_Registration, C_ReceiptType_Inout, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        // typ dokladu vklad
        f_Command := C_Command_RA;

        f_Parameters := value_x(Abs(reqObj.C['ReceiptData.Amount']), 2) +
          C_PAR_SEP + // hodnota vkladu
          strReplaceNonChars(reqObj.s['ReceiptData.Custom.Cashier']) + C_PAR_SEP
          + // meno pokladnika
          strReplaceNonChars(reqObj.s['ReceiptData.Custom.Purpose']);
        // dôvod vkladu

        retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
            [f_Command, f_Parameters, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        retVal := Elcomm.CloseReceipt();
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.CloseReceipt() => %d;', [retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s úspešne zaevidovaný a odoslaný do tlaèiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp]);
      end;

      if (reqObj.s['ReceiptData.ReceiptType'] = 'VY') then
      begin
        retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration,
          C_ReceiptType_Inout);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
            [C_ReceiptMode_Registration, C_ReceiptType_Inout, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        // typ dokladu vyber
        f_Command := C_Command_PO;

        f_Parameters := 'cash' + C_PAR_SEP +
        // typ platby (volite¾né – default 'cash')
          '' + C_PAR_SEP + // mena (volite¾né – default 'national')
          value_x(Abs(reqObj.C['ReceiptData.Amount']), 2) + C_PAR_SEP +
        // hodnota vyberu
          strReplaceNonChars(reqObj.s['ReceiptData.Custom.Cashier']) + C_PAR_SEP
          + // meno pokladnika
          strReplaceNonChars(reqObj.s['ReceiptData.Custom.Purpose']);
        // dôvod vyberu

        retVal := Elcomm.ReceiptCommand(f_Command, f_Parameters);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
            [f_Command, f_Parameters, retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        retVal := Elcomm.CloseReceipt();
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.CloseReceipt() => %d;', [retVal]));
        if (retVal <> eGRetVal_AllOk) then
          exit;

        uidOkp := getReference();
        result := Format
          ('{"message":"Doklad UID:%s úspešne zaevidovaný a odoslaný do tlaèiarne.",'
          + '"uid":"%s"}', [uidOkp, uidOkp])
      end;
    end
    else
      result := rs_connection_error;
  finally
    if (retVal <> eGRetVal_AllOk) then
    begin
      Elcomm.ReceiptCommand(C_Command_VR, '');
      // storno/anulacia neukoncenej uctenky
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [retVal, errorStr(retVal)]);
    end;
    internalClose();
  end;
end;

function elcommReport(): string;
var
  retVal: eGRetVal;
  f_ReportName, f_Mode, f_RangeMin, f_RangeMax: WideString;
  report: string;
begin
  result := '';
  retVal := eGRetVal_AllOk;
  internalInit();
  try
    if (elcommOpen) then
    begin
      report := paramByName('type', reqParams);
      if (Lowercase(report) = 'zreport') then
      begin
        f_ReportName := 'FINREPORT';
        f_Mode := 'day' + C_PAR_SEP + 'Z_Report' + C_PAR_SEP + 'print' +
          C_PAR_SEP + 'Mode_R';
        f_RangeMin := '';
        f_RangeMax := '';

        retVal := Elcomm.MakeReport(f_ReportName, f_Mode, f_RangeMin,
          f_RangeMax);
        if fSettings.B['ekasa.withLog'] then
          addLog(Format('Elcomm.MakeReport(%s,%s,%s,%s) => %d;',
            [f_ReportName, f_Mode, f_RangeMin, f_RangeMax, retVal]));
        if retVal <> eGRetVal_AllOk then
          exit;

        internalPriceConfig();
        result := '{"message":"OK"}'
      end
      else
      begin
        result := '{"errorCode":500,"error":"unsupported request"}';
        exit;
      end;
    end
    else
      result := rs_connection_error;
  finally
    if (retVal <> eGRetVal_AllOk) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [retVal, errorStr(retVal)]);
    internalClose();
  end;
end;

function elcommPrncdkick(): string;
var
  retVal: eGRetVal;
begin
  result := '';
  retVal := eGRetVal_AllOk;
  internalInit();
  try
    if (elcommOpen) then
    begin
      retVal := Elcomm.OpenReceipt(C_ReceiptMode_Registration,
        C_ReceiptType_Sale);
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.OpenReceipt(%s,%s) => %d;',
          [C_ReceiptMode_Registration, C_ReceiptType_Sale, retVal]));
      if (retVal <> eGRetVal_AllOk) then
        exit;

      retVal := Elcomm.ReceiptCommand(C_Command_OD, '');
      if fSettings.B['ekasa.withLog'] then
        addLog(Format('Elcomm.ReceiptCommand(%s,%s) => %d;',
          [C_Command_OD, '', retVal]));
      if (retVal <> eGRetVal_AllOk) then
        exit;

      result := '{"message":"OK"}';
    end
    else
      result := rs_connection_error;
  finally
    if (retVal <> eGRetVal_AllOk) then
      result := Format('{"errorCode":500,"errorEkasa":%d,"error":"%s"}',
        [retVal, errorStr(retVal)]);
    internalClose();
  end;
end;

function eKasaElcommWork(action: TEkasaActions): string;
begin
  result := '';
  case action of
    actState:
      result := elcommState;
    actSettingsGet:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSettingsPost:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actCopyLast:
      result := elcommCopyLast;
    actCopyByUuid:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actCopyById:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actReceipt:
      result := elcommReceipt;
    actReceiptStateId:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actLocationGps:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actLocationAddress:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actLocationOther:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actReport:
      result := elcommReport;
    actUnsent:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSendunsent:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actPrncdkick:
      result := elcommPrncdkick;
    actPrnfreeprint:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSenderror:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actExamplereceipt:
      result := '{"errorCode":500,"error":"unsupported request"}';
    actSelectpayments:
      result := '{"errorCode":500,"error":"unsupported request"}';
  end;
end;

initialization

Vats := nil;

finalization

if Assigned(Vats) then
  Vats := nil;
if Assigned(Elcomm) then
begin
  Elcomm.Disconnect();
  Elcomm := nil;
end;

end.
