unit uEkasaPrinters;

interface

const
  C_ERR_INIT = 'Chyba pri inicializácií fiskálnej tlaèiarne';
  C_ERR_NFNC = 'Nepodporovaná funkcia'; // 888
  C_ERR_FDPH =
    'Vo fiskálnej tlaèiarni nie je definovaná daòová hladina pre úhradu faktúr!';
  // 889

resourcestring
  rs_filenotfound = 'súbor "%s" nebol nájdený.';
  rs_loaddllerror = 'nie je možné zavies potrebnú komunikaènú knižnicu! ';
  rs_nezadane = 'nezadané';
  rs_noname = 'bez názvu';
  rs_chybakomunikaciefm = 'Chyba komunikácie s fiskálnym modulom!';

  rs_Nepouzivat = 'Nepoužíva';
  rs_EKasa = 'MRP eKasa 8000';
  rs_EFiskalPro = 'Fiskal PRO - eKasa';
  rs_EEfox = 'Elcom Efox - eKasa';
  rs_EEuro50T = 'Euro-50T Mini - eKasa';
  rs_EEuro50TE = 'Euro-50TE Mini - eKasa';
  rs_EEuro50TECash = 'Euro-50TE Cash (iba úhrada faktúry) - eKasa';
  rs_EEuro50TEMedi = 'Euro-50TE Medi - eKasa';
  rs_EEuro50TESmart = 'Euro-50TE Smart (iba úhrada faktúry) - eKasa';
  rs_EEuro150TEF = 'Euro-150TE Flexy - eKasa';
  rs_EEuro150TEFP = 'Euro-150TE Flexy Plus - eKasa';
  rs_EEuro80B = 'Euro-80B - eKasa';
  rs_EEuro50iTE = 'Euro-50iTE Mini - eKasa';
  rs_EEuro50iTECash = 'Euro-50iTE Cash - eKasa';
  rs_EEuro150iTE = 'Euro-150iTE Flexy - eKasa';
  rs_EEuro150iTEFP = 'Euro-150iTE Flexy Plus - eKasa';
  rs_EEuro2100i = 'Euro-2100i - eKasa';
  rs_EBowa = 'Bowa - eKasa';
  rs_EVaros = 'Varos - eFT4000B/eFT5000B';
  rs_EVarosNative = 'Varos - eFT4000/FT5000';
  rs_EUpos = 'Upos - eKasa';

type
  TEkasaTyps = (ftNepouzit, // 0
    ftEkasa, // 1
    ftEFiskalPro, // 2
    ftEEfox, // 3
    ftEEuro50T, // 4
    ftEEuro50TE, // 5
    ftEEuro50TECash, // 6
    ftEEuro50TEMedi, // 7
    ftEEuro50TESmart, // 8
    ftEEuro150TEF, // 9
    ftEEuro150TEFP, // 10
    ftEEuro80B, // 11
    ftEEuro50iTE, // 12
    ftEEuro50iTECash, // 13
    ftEEuro150iTEF, // 14
    ftEEuro150iTEFP, // 15
    frEEuro2100i, // 16
    ftEBowa, // 17
    ftEVaros, // 18
    ftEVarosNative, // 19
    ftEUpos // 20
    );

  TConnectionTyp = (connectionRS232, // 0
    connectionUSB, // 1
    connectionTCP // 2
    );

  TLastError = record
    errCode: integer;
    errMess: string;
  end;

  TEkasaActions = (actState, actSettingsGet, actSettingsPost, actCopyLast,
    actCopyByUuid, actCopyById, actReceipt, actReceiptStateId, actLocationGps,
    actLocationAddress, actLocationOther, actReport, actUnsent, actSendunsent,
    actPrncdkick, actPrnfreeprint, actSenderror, actExamplereceipt,
    actSelectpayments);

const
  c_ekasatyps_array: array [TEkasaTyps] of string = (rs_Nepouzivat, rs_EKasa,
    rs_EFiskalPro, rs_EEfox, rs_EEuro50T, rs_EEuro50TE, rs_EEuro50TECash,
    rs_EEuro50TEMedi, rs_EEuro50TESmart, rs_EEuro150TEF, rs_EEuro150TEFP,
    rs_EEuro80B, rs_EEuro50iTE, rs_EEuro50iTECash, rs_EEuro150iTE,
    rs_EEuro150iTEFP, rs_EEuro2100i, rs_EBowa, rs_EVaros, rs_EVarosNative,
    rs_EUpos);

function eKasaPrinter(ekAction: TEkasaActions): string;
function getEkasaTyp(fTyp: string): TEkasaTyps; overload;
function getEkasaTyp(fTyp: TEkasaTyps): string; overload;
function getEkasaConnection(fConn: string): TConnectionTyp; overload;
function getEkasaConnection(fConn: TConnectionTyp): string; overload;
function isReturnType(s: string): boolean;
function value_x(value: currency; dp: byte): string;
function decPlCount(c: currency): integer;
function addSpacesR(s: string; l: byte): string;
function addSpacesL(s: string; l: byte): string;
procedure addLog(s: string);

var
  isEkasaInit: boolean = false;
  lastError: string;

implementation

uses
  SysUtils, IniFiles, uCommon, uServer, uSettings,
  eKasaMrp, eKasaFiskalPro, eKasaVarosNative, eKasaBowa, eKasaElcomm,
  StrUtils;

function eKasaPrinter(ekAction: TEkasaActions): string;
var
  sErr: string;
begin
  case fSettings.I['ekasa.typ'] of
    ord(ftNepouzit):
      begin
        result := Format(C_RESULT_ER, [500, 'eKasa is not set'])
      end;

    ord(ftEkasa):
      begin
        if eKasaMrpInit then
        begin
          result := eKasaMrpWork(ekAction);
        end
        else
        begin
          sErr := C_ERR_INIT;
          if not Empty(lastError) then
          begin
            sErr := sErr + ' - ' + lastError;
            lastError := '';
          end;
          result := Format(C_RESULT_ER, [500, sErr]);
        end;
      end;

    ord(ftEFiskalPro):
      begin
        if eKasaFiskalProInit then
        begin
          result := eKasaFiskalProWork(ekAction);
        end
        else
        begin
          sErr := C_ERR_INIT;
          if not Empty(lastError) then
          begin
            sErr := sErr + ' - ' + lastError;
            lastError := '';
          end;
          result := Format(C_RESULT_ER, [500, sErr]);
        end;
      end;

    ord(ftEBowa):
      begin
        if eKasaBowaInit then
        begin
          result := eKasaBowaWork(ekAction);
        end
        else
        begin
          sErr := C_ERR_INIT;
          if not Empty(lastError) then
          begin
            sErr := sErr + ' - ' + lastError;
            lastError := '';
          end;
          result := Format(C_RESULT_ER, [500, sErr]);
        end;
      end;

    ord(ftEVarosNative):
      begin
        if eKasaVarosNativeInit then
        begin
          result := eKasaVarosNativeWork(ekAction);
        end
        else
        begin
          sErr := C_ERR_INIT;
          if not Empty(lastError) then
          begin
            sErr := sErr + ' - ' + lastError;
            lastError := '';
          end;
          result := Format(C_RESULT_ER, [500, sErr]);
        end;
      end;

    ord(ftEEuro50T), ord(ftEEuro50TE), ord(ftEEuro50TECash),
      ord(ftEEuro50TEMedi), ord(ftEEuro50TESmart), ord(ftEEuro150TEF),
      ord(ftEEuro150TEFP), ord(ftEEuro80B), ord(ftEEuro50iTE),
      ord(ftEEuro50iTECash), ord(ftEEuro150iTEF), ord(ftEEuro150iTEFP),
      ord(frEEuro2100i):
      begin
        if eKasaElcommInit then
        begin
          result := eKasaElcommWork(ekAction);
        end
        else
        begin
          sErr := C_ERR_INIT;
          if not Empty(lastError) then
          begin
            sErr := sErr + ' - ' + lastError;
            lastError := '';
          end;
          result := Format(C_RESULT_ER, [500, sErr]);
        end;
      end;

  end;
end;

function getEkasaTyp(fTyp: string): TEkasaTyps;
begin
  for result := Low(TEkasaTyps) to High(TEkasaTyps) do
    if SameText(fTyp, c_ekasatyps_array[result]) then
      break;
end;

function getEkasaTyp(fTyp: TEkasaTyps): string;
begin
  result := c_ekasatyps_array[fTyp];
end;

function getEkasaConnection(fConn: string): TConnectionTyp;
begin
  result := connectionRS232;
  if (fConn = '1') then
    result := connectionUSB
  else if (fConn = '2') then
    result := connectionTCP;
end;

function getEkasaConnection(fConn: TConnectionTyp): string;
begin
  case fConn of
    connectionRS232:
      result := '0';
    connectionUSB:
      result := '1';
    connectionTCP:
      result := '2';
  end;
end;

function isReturnType(s: string): boolean;
begin
  result := MatchStr(UpperCase(s), ['_VF', '_VO']);
end;

function value_x(value: currency; dp: byte): string;
var
  ds: char;
begin
  ds := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    result := CurrToStrF(value, ffFixed, dp);
  finally
    FormatSettings.DecimalSeparator := ds;
  end;
end;

function decPlCount(c: currency): integer;
var
  s: string;
  ods: char;
begin
  result := 0;
  ods := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    s := CurrToStr(c);
    if (Pos('.', s) > 0) then
      result := Length(s) - Pos('.', s);
  finally
    FormatSettings.DecimalSeparator := ods;
  end;
end;

function addSpacesR(s: string; l: byte): string;
begin
  while Length(s) < l do
    s := s + ' ';
  result := s;
end;

function addSpacesL(s: string; l: byte): string;
begin
  while Length(s) < l do
    s := ' ' + s;
  result := s;
end;

procedure addLog(s: string);
begin
  Writeln('[DEBUG] ' + s);
end;

end.
