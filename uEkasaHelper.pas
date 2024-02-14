unit uEkasaHelper;

interface

uses
  uServer, IdCustomHTTPServer, superObject;

const
  c_api_state = '/api/ekasa/state';
  c_api_settings = '/api/ekasa/settings';
  c_api_receipt = '/api/ekasa/receipt';
  c_api_receipt_copy = '/api/ekasa/receipt/copy';
  c_api_receipt_copy_id = '/api/ekasa/receipt/copy/{id}';
  c_api_receipt_state_id = '/api/ekasa/receipt/state/{id}';
  c_api_receipt_last_copy = '/api/ekasa/receipt/last/copy';
  c_api_location_gps = '/api/ekasa/location/gps';
  c_api_location_address = '/api/ekasa/location/physicaladdress';
  c_api_location_other = '/api/ekasa/location/other';
  c_api_report = '/api/ekasa/report';
  c_api_unsent = '/api/ekasa/unsent';
  c_api_sendunsent = '/api/ekasa/sendunsent';
  c_api_prn_cdkick = '/api/ekasa/prn/cdkick';
  c_api_prn_freeprint = '/api/ekasa/prn/freeprint';
  c_api_senderror = '/api/ekasa/senderror';
  c_api_examplereceipt = '/api/ekasa/examplereceipt';
  c_api_selectpayments = '/api/ekasa/selectpayments';

function isMatchUrl(aUrl, aMaskUrl: string): boolean;
function isEkasaApi(document: string): boolean;
function paramByName(paramName, paramSource: string): string;

procedure eKasaCmd(ARequestDocument: string; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);

var
  reqParams, reqData, reqId: string;

implementation

uses
  SysUtils, StrUtils, DelUp, uEkasaPrinters, classes;

function isMatchUrl(aUrl, aMaskUrl: string): boolean;
var
  i: integer;
  slUrl, slMask: TstringList;
begin
  slUrl := TstringList.Create;
  slMask := TstringList.Create;
  result := false;
  try
    slUrl.LineBreak := '/';
    slUrl.Text := SysUtils.UpperCase(aUrl);
    slMask.LineBreak := '/';
    slMask.Text := SysUtils.UpperCase(aMaskUrl);

    if slUrl.Count <> slMask.Count then
      exit;

    for i := 0 to slUrl.Count - 1 do
    begin
      if pos('{', slMask[i]) > 0 then
      begin
        reqId := SysUtils.LowerCase(slUrl[i]);
        continue;
      end;
      result := slUrl[i] = slMask[i];

      if not result then
        exit;
    end;
  finally
    slMask.Free;
    slUrl.Free;
  end;
end;

function isEkasaApi(document: string): boolean;
begin
  result := (pos('/API/EKASA/', UpperCase(document)) > 0);
end;

function paramByName(paramName, paramSource: string): string;
var
  i: integer;
  sl: TstringList;
begin
  result := '';
  sl := TstringList.Create;
  try
    sl.Clear;
    sl.LineBreak := #$D#$A;
    sl.Text := paramSource;
    for i := 0 to sl.Count - 1 do
    begin
      if (pos(paramName, sl.Strings[i]) > 0) then
      begin
        result := Copy(sl.Strings[i], Length(paramName) + 2,
          Length(sl.Strings[i]) - 1);
        break;
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure eKasaCmd(ARequestDocument: string; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  response: string;
  dataStream: TStringStream;
  errorCode: integer;

begin
  AResponseInfo.ContentType := 'application/json';
  AResponseInfo.CharSet := 'UTF-8';

  reqParams := ARequestInfo.Params.Text;
  if ((ARequestInfo.Command = C_POST) and (ARequestInfo.PostStream <> nil)) then
  begin
    dataStream := TStringStream.Create('', TEncoding.UTF8);
    try
      dataStream.LoadFromStream(ARequestInfo.PostStream);
      reqData := dataStream.DataString;
    finally
      dataStream.Free;
    end;
  end;

  if isMatchUrl(ARequestInfo.document, c_api_state) then
    response := EKasaPrinter(actState)
  else if isMatchUrl(ARequestInfo.document, c_api_settings) then
  begin
    if (ARequestInfo.Command = C_GET) then
      response := EKasaPrinter(actSettingsGet);
    if (ARequestInfo.Command = C_POST) then
      response := EKasaPrinter(actSettingsPost);
  end
  else if isMatchUrl(ARequestInfo.document, c_api_receipt) then
    response := EKasaPrinter(actReceipt)
  else if isMatchUrl(ARequestInfo.document, c_api_receipt_copy) then
    response := EKasaPrinter(actCopyByUuid)
  else if isMatchUrl(ARequestInfo.document, c_api_receipt_copy_id) then
    response := EKasaPrinter(actCopyById)
  else if isMatchUrl(ARequestInfo.document, c_api_receipt_state_id) then
    response := EKasaPrinter(actReceiptStateId)
  else if isMatchUrl(ARequestInfo.document, c_api_receipt_last_copy) then
    response := EKasaPrinter(actCopyLast)
  else if isMatchUrl(ARequestInfo.document, c_api_location_gps) then
    response := EKasaPrinter(actLocationGps)
  else if isMatchUrl(ARequestInfo.document, c_api_location_address) then
    response := EKasaPrinter(actLocationAddress)
  else if isMatchUrl(ARequestInfo.document, c_api_location_other) then
    response := EKasaPrinter(actLocationOther)
  else if isMatchUrl(ARequestInfo.document, c_api_report) then
    response := EKasaPrinter(actReport)
  else if isMatchUrl(ARequestInfo.document, c_api_unsent) then
    response := EKasaPrinter(actUnsent)
  else if isMatchUrl(ARequestInfo.document, c_api_sendunsent) then
    response := EKasaPrinter(actSendunsent)
  else if isMatchUrl(ARequestInfo.document, c_api_prn_cdkick) then
    response := EKasaPrinter(actPrncdkick)
  else if isMatchUrl(ARequestInfo.document, c_api_prn_freeprint) then
    response := EKasaPrinter(actPrnfreeprint)
  else if isMatchUrl(ARequestInfo.document, c_api_senderror) then
    response := EKasaPrinter(actSenderror)
  else if isMatchUrl(ARequestInfo.document, c_api_examplereceipt) then
    response := EKasaPrinter(actExamplereceipt)
  else if isMatchUrl(ARequestInfo.document, c_api_selectpayments) then
    response := EKasaPrinter(actSelectpayments)
  else
  begin
    response := Format(uServer.SERROR_BAD_REQUEST, [ARequestInfo.document]);
    AResponseInfo.ContentType := 'text/html';
    AResponseInfo.ResponseNo := 400;
  end;

  reqId := '';
  reqData := '';
  reqParams := '';

  AResponseInfo.ContentText := response;
  errorCode := SO(response).i['errorCode'];
  if (errorCode > 0) then
    AResponseInfo.ResponseNo := errorCode;
end;

end.
