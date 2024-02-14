unit FMEkasa;

interface

uses
  FMUtils, uEkasa, DMEKASAFile;

resourcestring
  rs_prebiehatlacvkladuvyberu = 'Prebieha tlaË vkladu/v˝beru ...';
  rs_connecterror = 'Nepodarilo sa vytvoriù spojenie s fisk·lnou tlaËiarÚou!';
  rs_errormsg = 'Chyba: %d'+#13#10+'%s';
  rs_status = 'N·zov pokladnice: %s %s'#13+
              'Inicialzovan·: %s'#13+
              'PoËet neodoslan˝ch spr·v: %d'#13+
              'Obsahuje chybn˙ d·tov˙ spr·vu: %s'#13+
              'Zaplnenosù CHDU: %s'#13+
              'PPEKK verzia: %s'#13+
              'CHDU verzia: %s'#13+
              'Internet: %s'#13+
              'RTC: %s'#13#13+
              'IdentifikaËnÈ ˙daje:'#13#13+
              '%s'#13+
              '%s %s/%s'#13+
              '%s %s';
  rs_nepodpor = 'T·to funkcia nie je v tejto verzii PPEKK podporovan· !';
  rs_certificate_expires = '!!! PLATNOSç CERTIFIK¡TU AUTENTIFIKA»N›CH ⁄DAJOV EKASY UPLYNIE ZA %d DNÕ !!!'#13+
                           'DoporuËujeme ich obnovu';
  rs_certificate_out = '!!! PLATNOSç CERTIFIK¡TU AUTENTIFIKA»N›CH ⁄DAJOV EKASY UPLYNULA !!!'#13+
                       'DoporuËujeme ich obnovu';

  function FMEkasa_Init: boolean;
  function SpracujFMEkasa(Akcia: TAKC): boolean;
  function baseUrl(): string;
  function cashRounding(): boolean;

  procedure Blocek();
  procedure Faktura();
  procedure FakturaKarta();
  procedure VkladVyber();
  procedure StavFM();
  procedure Poloha();
  procedure UzavierkaPrint();
  procedure UzavierkaShow();
  procedure NeodoslaneTlac();
  procedure KopiaUuid();
  procedure KopiaPosledny();
  procedure NeodoslanePosli();
  procedure Zasuvka();
  procedure Update();
  procedure setTimeout();
  procedure OpravChybu();
  procedure VyberNulovanie();
  procedure VzorOfflineDoklad();
  function getInitialization(): boolean;

var
  EKASA: TEKASA;
  whiteCrlx: boolean = false;
  ppekkVersion: integer = 0;

implementation

uses
  Dialogs, Controls, superObject, uIni, dmAgend, FormUtils, locationData,
  Forms, EKasaUtils, SysUtils, TechUtils, eKasaSelect, Windows, InPrev, Classes,
  GlobUtils, dmMainFi, IdURI, Subory, ShellApi, DateUtils, exDateUtils,
  invoicePaymentCard;

function inicializacia_FMEkasa: integer;
begin
  result := -1;
  jeInitFiskal := false;

  if EKASA = nil then begin
    EKASA := TEKASA.Create();
    setTimeout();
  end;

  if (ppekkVersion = 0) then
    jeInitFiskal := getInitialization()
  else
    jeInitFiskal := true;

  if jeInitFiskal then result := 0;
end;

function FMEkasa_Init: boolean;
begin
  while not JeInitFiskal do begin
    StatusInfoForm(rs_prebiehainicializacia);
    if inicializacia_FMEkasa <> 0 then begin
      StatusInfoForm('', true);
      if MessageDlg(SChybaInitFM + SOpakovatInit, mtError,[mbYes, mbNo], 0) = mrNo then begin
        Break;
      end;
    end
    else
      StatusInfoForm('', true);
  end;
  result := JeInitFiskal;
end;

function baseUrl(): string;
begin
  result := 'http://'+uIni.cfgEKasaIp.Value+':80/api';
end;

function cashRounding(): boolean;
begin
  result := (ppekkVersion >= 1011);
end;

procedure processError(err: ISuperObject);
var
  errorCode: integer;
begin
  errorCode := err.I['errorCode'];

  case errorCode of
    8: begin // eKasa s chybovou spravou

    end;
    10: begin //eKasa je zaneprazdnena

    end;
    else
      MessageDlg(err.S['error'], mtError, [mbOK], 0);
  end;
end;

procedure Blocek();
var
  url: string;
  data,response: ISuperObject;
begin
  StatusInfoForm(rs_prebiehatlacdokladu);

  ChybaPriTlacivFM := true;
  try
    // tlac potvrdenia z POS pre obchodnika
    if printPosReceipt(data) then begin
      url := baseUrl() + '/prn/freeprint';
      EKASA.post(url, data.AsString);
    end;

    url := baseUrl() + '/receipt';
    data := prepareReceiptData('PD');

    response := SO(EKASA.post(url, data.AsString));

    if (EKASA.statusCode in [200,201]) then begin
      ChybaPriTlacivFM := false;
      case EKASA.statusCode of
        200: DMEKASA.EKASAOBJ.S['UID'] := response.S['uid'];
        201: DMEKASA.EKASAOBJ.S['UID'] := response.S['okp'];
      end;
      DMEKASA.saveEKASAOBJ();
    end
    else begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      //server FS vratil error (napr. 499)
      if (response.S['errorCode'] <> '') and
         ((response.I['errorCode'] < 0) or(response.I['errorCode'] = 499)) then begin
        ChybaPriTlacivFM := false;
        DMEKASA.saveEKASAOBJ();
      end;
    end;

  finally
    StatusInfoForm('');
  end;
end;

procedure Faktura();
var
  url: string;
  data,response: ISuperObject;
begin
  StatusInfoForm(rs_prebiehatlacuhradyfaktury);
  try
    url := baseUrl() + '/receipt';
    data := prepareReceiptData('UF');

    response := SO(EKASA.post(url, data.AsString));

    if (EKASA.statusCode in [200,201]) then begin
      ChybaPriTlaciVkladu:= false;
      case EKASA.statusCode of
        200: DMEKASA.EKASAOBJ.S['UID'] := response.S['uid'];
        201: DMEKASA.EKASAOBJ.S['UID'] := response.S['okp'];
      end;
      DMEKASA.saveEKASAOBJ();
    end
    else begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      //server FS vratil error (napr. 499)
      if (response.S['errorCode'] <> '') and
         ((response.I['errorCode'] < 0) or(response.I['errorCode'] = 499)) then begin
        ChybaPriTlaciVkladu := false;
        DMEKASA.saveEKASAOBJ();
      end;
    end;

  finally
    StatusInfoForm('');
  end;
end;

procedure FakturaKarta();
var
  url: string;
  data,response: ISuperObject;
  F: TinvoicePaymentCardForm;
begin
  F := nil;
  UrobForm(TForm(F),TinvoicePaymentCardForm);
  try
    if (F.ShowModal <> mrOK) then exit;

    StatusInfoForm(rs_prebiehatlacuhradyfaktury);
    try
      url := baseUrl() + '/receipt';

      DMEKASA.EKASAOBJ := SO();
      DMEKASA.EKASAOBJ.S['GUID'] := guidGenerator;
      DMEKASA.EKASAOBJ.S['RECEIPTTYPE'] := 'F';
      DMEKASA.EKASAOBJ.S['EMAIL'] := strReplaceNonChars(F.frEKasaSettings.edtMail.Text);
      if ((F.frEKasaSettings.edtNumber.Value >=1) and (F.frEKasaSettings.edtNumber.Value <= 99999))then
        DMEKASA.EKASAOBJ.S['PARAGON'] := FormatDateTime('YYYYMMDD',F.frEKasaSettings.datePicker.DateTime) +
                                 FormatDateTime('HHNNSS',F.frEKasaSettings.timePicker.DateTime) +
                                 IntToStr(Round(F.frEKasaSettings.edtNumber.Value));
      DMEKASA.EKASAOBJ.I['CUSTOMERID'] := F.frEKasaSettings.cbCustomer.ItemIndex + 1;
      DMEKASA.EKASAOBJ.S['CUSTOMER'] := strReplaceNonChars(F.frEKasaSettings.edtCustomer.Text);

      data := SO();
      data.S['ReceiptData.ReceiptType'] := 'UF';
      data.S['Uuid'] := DMEKASA.EKASAOBJ.S['GUID'];
      data.B['receiptCopy'] := uIni.cfgFTCopyInvoice.Value;

      data.C['ReceiptData.Amount'] := F.edtnAmount.Value;
      data.S['ReceiptData.InvoiceNumber'] := IfThen(F.edtInvoiceNumber.Text='',
                                                      rs_nezadane,
                                                      F.edtInvoiceNumber.Text);
      //identifikacia odberatela
      if not Empty(DMEKASA.EKASAOBJ.S['CUSTOMER']) then begin
        data.S['ReceiptData.CustomerId'] := DMEKASA.EKASAOBJ.S['CUSTOMER'];
        data.S['ReceiptData.CustomerIdType'] := EKasaUtils.customerIdType(DMEKASA.EKASAOBJ.I['CUSTOMERID']);
      end;
      //identifikacia dokladu ako paragonu
      if not Empty(DMEKASA.EKASAOBJ.S['PARAGON']) then begin
        data.B['ReceiptData.Paragon'] := true;
        data.S['ReceiptData.IssueDate'] := Copy(DMEKASA.EKASAOBJ.S['PARAGON'],1,4)+'-'+
                                             Copy(DMEKASA.EKASAOBJ.S['PARAGON'],5,2)+'-'+
                                             Copy(DMEKASA.EKASAOBJ.S['PARAGON'],7,2)+'T'+
                                             Copy(DMEKASA.EKASAOBJ.S['PARAGON'],9,2)+':'+
                                             Copy(DMEKASA.EKASAOBJ.S['PARAGON'],11,2)+':'+
                                             Copy(DMEKASA.EKASAOBJ.S['PARAGON'],13,2);
        data.S['ReceiptData.ParagonNumber'] := Copy(DMEKASA.EKASAOBJ.S['PARAGON'],15,Length(DMEKASA.EKASAOBJ.S['PARAGON']));
      end
      else
        data.B['ReceiptData.Paragon'] := false;

      //Polozky naviac potrebne k tlaci dokladu
      data.S['ReceiptData.Custom.Cashier'] := cfgProgram.PrihlasenyUzivatel;
      data.C['ReceiptData.Custom.PaymentCard'] := F.edtnAmount.Value;
      //odoslanie dokladu na email
      if not empty(DMEKASA.EKASAOBJ.S['EMAIL']) then
        data.S['ReceiptData.Custom.Email'] := DMEKASA.EKASAOBJ.S['EMAIL'];

      response := SO(EKASA.post(url, data.AsString));

      if (EKASA.statusCode in [200,201]) then begin
        ChybaPriTlaciVkladu:= false;
        case EKASA.statusCode of
          200: DMEKASA.EKASAOBJ.S['UID'] := response.S['uid'];
          201: DMEKASA.EKASAOBJ.S['UID'] := response.S['okp'];
        end;
        DMEKASA.saveEKASAOBJ();
      end
      else begin
        MessageDlg(response.S['error'],mtError,[mbOK],0);
        //server FS vratil error (napr. 499)
        if (response.S['errorCode'] <> '') and
           ((response.I['errorCode'] < 0) or(response.I['errorCode'] = 499)) then begin
          ChybaPriTlaciVkladu := false;
          DMEKASA.saveEKASAOBJ();
        end;
      end;

    finally
      StatusInfoForm('');
    end;

  finally
    ZrusForm(TForm(F));
  end;
end;

procedure VkladVyber;
var
  url: string;
  data,response: ISuperObject;
begin
  StatusInfoForm(rs_prebiehatlacvkladuvyberu);
  try
    url := baseUrl + '/receipt';
    data := prepareReceiptData('VK');

    response := SO(EKASA.post(url, data.AsString));

    if (EKASA.statusCode in [200,201]) then begin
      ChybaPriTlaciVkladu := false;
      case EKASA.statusCode of
        200: DMEKASA.EKASAOBJ.S['UID'] := response.S['uid'];
        201: DMEKASA.EKASAOBJ.S['UID'] := response.S['okp'];
      end;
      DMEKASA.saveEKASAOBJ();
    end
    else begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      //server FS vratil error (napr. 499)
      if (response.S['errorCode'] <> '') and
         ((response.I['errorCode'] < 0) or(response.I['errorCode'] = 499)) then begin
        ChybaPriTlaciVkladu := false;
        DMEKASA.saveEKASAOBJ();
      end;
    end;

  finally
    StatusInfoForm('');
  end;
end;

procedure StavFM;
var
  url,status: string;
  response: ISuperObject;
begin
  url := baseUrl + '/state';
  response := SO(EKASA.get(url));
  if (EKASA.statusCode = 200) then begin
    status := Format(rs_status,[response.S['globals.PPEKKName'],
                                response.S['globals.CHDUName'],
                                ifThen(response.B['initialized'],'¡no','Nie'),
                                response.I['unsendMessages'],
                                ifThen(response.B['errorDataMessage'],'¡no','Nie'),
                                IntToStr(100 - StrToIntDef(StringReplace(response.S['chdu'], '%','',[rfReplaceAll]),1))+'%',
                                response.S['globals.PPEKKVer'],
                                response.S['globals.CHDUVer'],
                                response.S['internet'],
                                response.S['RTC'],
                                response.S['ident.CorporateBodyFullName'],
                                response.S['ident.PhysicalAddress.StreetName'],
                                response.S['ident.PhysicalAddress.BuildingNumber'],
                                response.S['ident.PhysicalAddress.PropertyRegistrationNumber'],
                                response.S['ident.PhysicalAddress.PostalCode'],
                                response.S['ident.PhysicalAddress.Municipality']]);
    MessageDlg(status, mtInformation,[mbOk], 0);
  end
  else
    MessageDlg(response.S['error'],mtError,[mbOK],0);
end;

procedure Poloha;
var
  url,ident: string;
  data,response: ISuperObject;
  F: TformLocationData;
begin
  F:= nil;
  UrobForm(TForm(F),TformLocationData);
  try
    F.ShowModal;
    if (F.ModalResult = mrCancel) then
      exit;

    case F.pcLocation.ActivePageIndex of
      0: ident := 'Gps';
      1: ident := 'PhysicalAddress';
      2: ident := 'Other';
    end;

    url := baseUrl + '/location/' + LowerCase(ident);
    data := F.Data;
    data.S['Uuid'] := guidGenerator;

    response := SO(EKASA.post(url, data.AsString));

    if (EKASA.statusCode = 200) then
      MessageDlg(response.S['message'],mtInformation,[mbOK],0)
    else
      MessageDlg(response.S['error'],mtError,[mbOK],0)

  finally
    ZrusForm(TForm(F));
  end;
end;

//http://192.168.128.202/api/report?datetimefrom=2019-10-10T00:00:00&datetimeto=2019-10-22T23:59:59
procedure UzavierkaPrint();
var
  url: string;
  response: ISuperObject;
  F: TeKasaSelectForm;
  show: boolean;
  report: TStringList;
begin
  show := false;
  F := nil;
  UrobForm(TForm(F),TeKasaSelectForm);
  try
    F.setMode(mReport);
    F.ShowModal;
    if (F.ModalResult = mrCancel) then
      exit;

//cfgEKasaNull1 : 0=nenulovaù, 1=poloûiù ot·zku, 2=nulovaù automaticky
//cfgEKasaNull2 : 0=pred vytlaËenÌm uz·vierky, 1=po vytlaËenÌ uz·vierky

    if (uIni.cfgEKasaNull1.Value > 0) and (uIni.cfgEKasaNull2.Value = 0) then begin
      if (uIni.cfgEKasaNull1.Value = 1) then begin
        if MessageDlg('Prajete si spustiù: Nulovanie platidiel ?',mtInformation,[mbYes,mbNo],0) = mrYes then
          VyberNulovanie();
      end
      else
        VyberNulovanie();
    end;

    url := baseUrl() + '/report';
    url := url + '?datetimefrom='+FormatDateTime('yyyy-mm-dd',F.dtpDateF.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeF.Time)+
                 '&datetimeto='+FormatDateTime('yyyy-mm-dd',F.dtpDateT.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeT.Time);
    if show then url := url + '&show=true';

    response := SO(EKASA.get(url));

    if (EKASA.statusCode <> 200) then begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      exit;
    end;

    if (uIni.cfgEKasaNull1.Value > 0) and (uIni.cfgEKasaNull2.Value = 1) then begin
      if (uIni.cfgEKasaNull1.Value = 1) then begin
        if MessageDlg('Prajete si spustiù: Nulovanie platidiel ?',mtInformation,[mbYes,mbNo],0) = mrYes then
          VyberNulovanie();
      end
      else
        VyberNulovanie();
    end;

    if show then begin
      report := TStringList.Create;
      report.Clear;
      report.LineBreak := #$A;
      report.Text := response.S['reportText'];
      ViewReport('Prehæadov· uz·vierka - NAHºAD', '', report);
    end;

  finally
    ZrusForm(TForm(F));
  end;
end;

//http://192.168.128.202/api/report?datetimefrom=2019-10-10T00:00:00&datetimeto=2019-10-22T23:59:59&show=true
procedure UzavierkaShow();
var
  url: string;
  response: ISuperObject;
  F: TeKasaSelectForm;
  report: TStringList;
begin
  if (ppekkVersion < 105) then begin
    MessageDlg(rs_nepodpor, mtWarning, [mbOk], 0);
    exit;
  end;

  F := nil;
  UrobForm(TForm(F),TeKasaSelectForm);
  try
    F.setMode(mReport);
    F.ShowModal;
    if (F.ModalResult = mrCancel) then
      exit;

    url := baseUrl() + '/report';
    url := url + '?datetimefrom='+FormatDateTime('yyyy-mm-dd',F.dtpDateF.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeF.Time)+
                 '&datetimeto='+FormatDateTime('yyyy-mm-dd',F.dtpDateT.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeT.Time);
    url := url + '&show=true';

    response := SO(EKASA.get(url));

    if (EKASA.statusCode <> 200) then begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      exit;
    end;

    report := TStringList.Create;
    report.Clear;
    report.LineBreak := #$A;
    report.Text := response.S['reportText'];
    ViewReport('Prehæadov· uz·vierka - NAHºAD', '', report);

  finally
    ZrusForm(TForm(F));
  end;
end;

procedure VzorOfflineDoklad();
var
  url: string;
  response: ISuperObject;
begin
  url := baseUrl() + '/examplereceipt';

  response := SO(EKASA.get(url));

  if (EKASA.statusCode <> 201) then
    MessageDlg(response.S['error'],mtError,[mbOK],0)
  else begin
    if (response['message'] <> nil) then
      MessageDlg(response.S['message'],mtInformation,[mbOK],0)
  end;
end;

procedure NeodoslaneTlac();
var
  url: string;
  response: ISuperObject;
  F: TeKasaSelectForm;
begin
  F:= nil;
  UrobForm(TForm(F),TeKasaSelectForm);
  try
    F.setMode(mUnsend);
    F.ShowModal;
    if (F.ModalResult = mrCancel) then
      exit;

    url := baseUrl + '/unsent';
    if F.rbtnFilterUnsent.Checked then begin
      url := url + '?datetimefrom='+FormatDateTime('yyyy-mm-dd',F.dtpDateF.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeF.Time)+
        '&datetimeto='+FormatDateTime('yyyy-mm-dd',F.dtpDateT.Date)+'T'+FormatDateTime('hh:nn:ss',F.dtpTimeT.Time)+
        '&numberfrom='+F.edtNumberF.Text+'&numberto='+F.edtNumberT.Text;
    end;

    response := SO(EKASA.get(url));
    if (EKASA.statusCode <> 200) then begin
      MessageDlg(response.S['error'],mtError,[mbOK],0);
      exit;
    end;

    if response.I['messageCount'] > 0 then begin
       if MessageDlg(response.S['messageCount'] + ' pripraven˝ch na tlaË', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
         if F.rbtnFilterUnsent.Checked then
           url := url+'&print=true'
         else
           url := url+'?print=true';

         response := SO(EKASA.get(url));

         if (EKASA.statusCode <> 200) then
           MessageDlg(response.S['error'],mtError,[mbOK],0);
      end;
    end
    else
      MessageDlg('Nenaöiel sa ûiadny neodoslan˝ doklad', mtInformation, [mbOk], 0);

  finally
    ZrusForm(TForm(F));
  end;
end;

procedure KopiaUuid();
var
  url,uuid: string;
  response: ISuperObject;
  F: TeKasaSelectForm;
begin
  uuid := uuidCopy;

  if uuid = '' then begin
    F:= nil;
    UrobForm(TForm(F),TeKasaSelectForm);
    try
      F.setMode(mCopy);
      F.ShowModal;
      if (F.ModalResult = mrCancel) then
        exit;

      uuid := strReplaceNonChars(F.edtUuid.Text);
    finally
      ZrusForm(TForm(F));
    end;
  end;

  url := baseUrl() + '/receipt/copy?uuid=' + uuid;

  response := SO(EKASA.get(url));

  if (EKASA.statusCode <> 200) then
    MessageDlg(response.S['error'],mtError,[mbOK],0);

  uuidCopy := '';
end;

procedure KopiaPosledny();
var
  url: string;
  response: ISuperObject;
begin
  url := baseUrl() + '/receipt/last/copy';

  response := SO(EKASA.get(url));

  if (EKASA.statusCode <> 200) then
    MessageDlg(response.S['error'],mtError,[mbOK],0);
end;

procedure NeodoslanePosli();
var
  url: string;
  response: ISuperObject;
begin
  url := baseUrl() + '/sendunsent';

  response := SO(EKASA.get(url));

  if (EKASA.statusCode <> 200) then
    MessageDlg(response.S['error'],mtError,[mbOK],0)
  else begin
    if (response['message'] <> nil) then
      MessageDlg(response.S['message'],mtInformation,[mbOK],0)
  end;
end;

procedure Zasuvka();
var
  url: string;
  response: ISuperObject;
begin
  url := baseUrl() + '/prn/cdkick';

  response := SO(EKASA.get(url));

  if (EKASA.statusCode <> 200) then
    MessageDlg(response.S['error'],mtError,[mbOK],0);
end;

procedure Update();
var
  updppPath: string;
begin
  if (ppekkVersion < 104) then begin
    updppPath := cfgProgram.CestaKProgramu + strExtras + 'updpp.exe';
    if FileExists(updppPath) then
      ShellExecute(Application.Handle, 'open', PChar(updppPath), PChar(uIni.cfgEKasaIp.Value), nil, 0);
  end;
end;

procedure setTimeout();
var
  url: string;
  response: ISuperObject;
  timeOut: integer;
begin
  url := baseUrl() + '/settings';
  response := SO(EKASA.get(url));
  if (EKASA.statusCode = 200) then begin
    timeOut := response.I['timeout'];
    whiteCrlx := (response.I['ORP.PRN.type'] = 1);

    if (uIni.cfgEKasaTimeOut.Value < timeOut) and (uIni.cfgEKasaTimeOut.Value < 2000) then
      uIni.cfgEKasaTimeOut.Value := timeOut;

    if (uIni.cfgEKasaTimeOut.Value <> timeOut) then begin
      response.I['timeout'] := uIni.cfgEKasaTimeOut.Value;
      response := SO(EKASA.post(url,response.AsString));
      if (EKASA.statusCode <> 200) then
        MessageDlg(response.S['error'],mtError,[mbOK],0);
    end;
  end
  else
    MessageDlg(response.S['error'],mtError,[mbOK],0);
end;

procedure OpravChybu();
var
  url: string;
  response: ISuperObject;
begin
  url := baseUrl() + '/senderror';
  response := SO(EKASA.get(url));

  if EKASA.statusCode = 200 then begin
    MessageDlg(response.S['message'], mtInformation, [mbOK], 0);
    if ((response.S['Uuid'] <> '') and (response.S['uid'] <> '')) then
      DMEKASA.updateEKASAOBJ(response.S['Uuid'],response.S['uid']);
  end
  else
    MessageDlg(response.S['error'], mtError, [mbOK], 0);
end;

procedure VyberNulovanie();
var
  url: string;
  response: ISuperObject;
  eKasaUid: string;
  payCash: currency;
  receiptId: integer;
begin
  StatusInfoForm(rs_prebiehatlacvkladuvyberu);
  try
    url := baseUrl + '/selectpayments?purpose=NULOVANIE PLATIDIEL';
    url := TIdURI.URLEncode(url);
    response := SO(EKASA.get(url));

    if (EKASA.statusCode in [200,201]) or (EKASA.statusCode = 499) then begin
      receiptId := response.I['receiptId'];

      if (receiptId > 0) then begin //response={"message":"Doklad UID:O-454F0BC2142C407B8F0BC2142CA-TEST ˙speöne zaevidovan˝ a odoslan˝ do tlaËiarne.","uid":"O-454F0BC2142C407B8F0BC2142CA-TEST","receiptNumber":145,"receiptId":725}
        eKasaUid := '';
        case EKASA.statusCode of
          200: eKasaUid := response.S['uid'];
          201: eKasaUid := response.S['okp'];
        end;
        //vycitanie dokladu => zistenie stavu hotovosti vo vybere
        url := baseUrl + '/receipt/state/' + IntToStr(receiptId);
        response := SO(EKASA.get(url));

        if (EKASA.statusCode = 200) then begin
          payCash := Abs(response.C['payCash']);

          if (payCash > 0) then begin
            dmAgendy.tblKasaIO.Append;
            dmAgendy.tblKasaIOTYP.Value := 'V';
            dmAgendy.tblKasaIOSUMA.AsCurrency := payCash;
            dmAgendy.tblKasaIOIDR_US_EDT.AsInteger := cfgProgram.PrihlasenyUzivatel_IDR;
            dmAgendy.tblKasaIODATUM.AsDateTime := Now;
            dmAgendy.tblKasaIOCas.asString := FormatDateTime('hh:nn:ss',Now);
            dmAgendy.tblKasaIOFISKAL.AsInteger := 1;
            DMMain.Validacia := false; dmAgendy.tblKasaIO.Post; DMMain.Validacia := true;

            DMEKASA.EKASAOBJ := SO();
            DMEKASA.EKASAOBJ.S['GUID'] := dmAgendy.tblKasaIOGUID.AsString;
            DMEKASA.EKASAOBJ.S['RECEIPTTYPE'] := 'V';
            DMEKASA.EKASAOBJ.I['CUSTOMERID'] := 1;
            DMEKASA.EKASAOBJ.S['UID'] := eKasaUid;
            DMEKASA.saveEKASAOBJ();
          end
          else begin
            DMEKASA.EKASAOBJ := SO();
            DMEKASA.EKASAOBJ.S['GUID'] := IntToStr(receiptId);
            DMEKASA.EKASAOBJ.S['RECEIPTTYPE'] := 'V';
            DMEKASA.EKASAOBJ.I['CUSTOMERID'] := 1;
            DMEKASA.EKASAOBJ.S['UID'] := eKasaUid;
            DMEKASA.saveEKASAOBJ();
          end;
        end;
        ChybaPriTlaciVkladu := false;
      end
      else begin //response = {"message":"V ORP nieje ûiadne platidlo z ktorÈho by bolo potrebnÈ urobiù v˝ber."}
        ChybaPriTlaciVkladu := false;
      end;
    end;

  finally
    StatusInfoForm('');
  end;
end;

function getInitialization(): boolean;
var
  url,ppekkVersionStr: string;
  response: ISuperObject;
  daysDiff: integer;
begin
  url := baseUrl + '/state';
  response := SO(EKASA.get(url));
  if (EKASA.statusCode = 200) then begin
    daysDiff := DaysBetween(exDateUtils.StrToDateFmt('d.m.yyyy',response.S['auth.validity.do']), Date());
    if (Date() > exDateUtils.StrToDateFmt('d.m.yyyy',response.S['auth.validity.do'])) then
      daysDiff := - daysDiff;
    if (daysDiff < 0) then
      MessageDlg(rs_certificate_out, mtWarning, [mbOk], 0)
    else if (daysDiff <= 30) then
      MessageDlg(Format(rs_certificate_expires,[daysDiff]), mtWarning,[mbOk], 0);

    ppekkVersionStr := response.S['globals.PPEKKVer'];
    ppekkVersionStr := StringReplace(ppekkVersionStr,'v','',[rfReplaceAll]);
    ppekkVersionStr := StringReplace(ppekkVersionStr,'.','',[rfReplaceAll]);
    ppekkVersion := StrToInt(ppekkVersionStr);
  end;
  result := (ppekkVersion > 0);
end;

function SpracujFMEkasa(Akcia: TAKC): boolean;
begin
  result := false;
  if not FMEkasa_Init then
    exit;

  case Akcia of
    akcTlacBlocek:      Blocek();
    akcUhradaFaktury:   Faktura();
    akcUhradaFakturyKartou: FakturaKarta();
    akcVkladVyber:      VkladVyber();
    akcStavFM:          StavFM();
    akcPoloha:          Poloha();
    akcUzavPrehladova:  UzavierkaPrint();
    akcNeodoslaneTlac:  NeodoslaneTlac();
    akcKopiaBlocku:     KopiaPosledny();
    akcKopiaBlockuUuid: KopiaUuid();
    akcNeodoslanePosli: NeodoslanePosli();
    akcOtvorZasuvku:    Zasuvka();
    akcUpdate:          Update();
    akcOpravChybu:      OpravChybu();
    akcVyberNulovanie:  VyberNulovanie();
    akcUzavPrehladovaShow : UzavierkaShow();
    akcVzorOfflineDoklad: VzorOfflineDoklad();
  end;
  result := true;
end;

initialization

finalization
  if Assigned(EKASA) then EKASA.Free;

end.
