unit uInterfaceHelper;

interface

uses
  uServer, IdCustomHTTPServer, superObject;

const
  c_settings = '/api/settings';

procedure interfaceCmd(ARequestDocument: string;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

function isInterfaceApi(document: string): boolean;
function settingsGet(): string;
function settingsPost(): string;

var
  reqParams, reqData, reqId: string;

implementation

uses
  SysUtils, StrUtils, Classes, uEkasaPrinters, uSettings, Math, uScannerHelper;

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

function isInterfaceApi(document: string): boolean;
begin
  result := (pos(UpperCase(c_settings), UpperCase(document)) > 0);
end;

function settingsGet(): string;
var
  res: ISuperObject;
begin
  res := SO();
  res.O['ekasa'] := fSettings.O['ekasa'];
  res.O['scanner'] := fSettings.O['scanner'];
  res.S['bearerToken'] := fSettings.S['web.bearerToken'];
  result := res.AsString;
end;

function CompareValueBoolean(left, right: boolean): integer;
begin
  if left < right then
    result := -1
  else if left > right then
    result := 1
  else
    result := 0;
end;

function CompareValueString(left, right: string): integer;
begin
  result := CompareStr(left, right);
end;

function CompareValueInteger(left, right: integer): integer;
begin
  result := CompareValue(left, right);
end;

function settingsPost(): string;
var
  postObj: ISuperObject;
  onChangeObj: boolean;
begin
  postObj := SO(reqData);
  onChangeObj := false;

  if (postObj.O['ekasa.typ'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.typ'], postObj.i['ekasa.typ'])
      <> 0) then
    begin
      fSettings.i['ekasa.typ'] := postObj.i['ekasa.typ'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.typStr'] <> nil) then
    if (CompareValueString(fSettings.S['ekasa.typStr'],
      postObj.S['ekasa.typStr']) <> 0) then
    begin
      fSettings.S['ekasa.typStr'] := postObj.S['ekasa.typStr'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.connectionTyp'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.connectionTyp'],
      postObj.i['ekasa.connectionTyp']) <> 0) then
    begin
      fSettings.i['ekasa.connectionTyp'] := postObj.i['ekasa.connectionTyp'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.hostAddress'] <> nil) then
    if (CompareValueString(fSettings.S['ekasa.hostAddress'],
      postObj.S['ekasa.hostAddress']) <> 0) then
    begin
      fSettings.S['ekasa.hostAddress'] := postObj.S['ekasa.hostAddress'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.comPort'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.comPort'],
      postObj.i['ekasa.comPort']) <> 0) then
    begin
      fSettings.i['ekasa.comPort'] := postObj.i['ekasa.comPort'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.withLog'] <> nil) then
    if (CompareValueBoolean(fSettings.B['ekasa.withLog'],
      postObj.B['ekasa.withLog']) <> 0) then
    begin
      fSettings.B['ekasa.withLog'] := postObj.B['ekasa.withLog'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.header'] <> nil) then
    if (CompareValueString(fSettings.S['ekasa.header'],
      postObj.S['ekasa.header']) <> 0) then
    begin
      fSettings.S['ekasa.header'] := postObj.S['ekasa.header'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.footer'] <> nil) then
    if (CompareValueString(fSettings.S['ekasa.footer'],
      postObj.S['ekasa.footer']) <> 0) then
    begin
      fSettings.S['ekasa.footer'] := postObj.S['ekasa.footer'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.drawer'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.drawer'],
      postObj.i['ekasa.drawer']) <> 0) then
    begin
      fSettings.i['ekasa.drawer'] := postObj.i['ekasa.drawer'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.vatPayer'] <> nil) then
    if (CompareValueBoolean(fSettings.B['ekasa.vatPayer'],
      postObj.B['ekasa.vatPayer']) <> 0) then
    begin
      fSettings.B['ekasa.vatPayer'] := postObj.B['ekasa.vatPayer'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.headerBitmap'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.headerBitmap'],
      postObj.i['ekasa.headerBitmap']) <> 0) then
    begin
      fSettings.i['ekasa.headerBitmap'] := postObj.i['ekasa.headerBitmap'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.footerBitmap'] <> nil) then
    if (CompareValueInteger(fSettings.i['ekasa.footerBitmap'],
      postObj.i['ekasa.footerBitmap']) <> 0) then
    begin
      fSettings.i['ekasa.footerBitmap'] := postObj.i['ekasa.footerBitmap'];
      onChangeObj := true;
    end;

  if (postObj.O['ekasa.printFullName'] <> nil) then
    if (CompareValueBoolean(fSettings.B['ekasa.printFullName'],
      postObj.B['ekasa.printFullName']) <> 0) then
    begin
      fSettings.B['ekasa.printFullName'] := postObj.B['ekasa.printFullName'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.use'] <> nil) then
    if (CompareValueBoolean(fSettings.B['scanner.use'], postObj.B['scanner.use']
      ) <> 0) then
    begin
      fSettings.B['scanner.use'] := postObj.B['scanner.use'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.comPort'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.comPort'],
      postObj.i['scanner.comPort']) <> 0) then
    begin
      fSettings.i['scanner.comPort'] := postObj.i['scanner.comPort'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.baudRate'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.baudRate'],
      postObj.i['scanner.baudRate']) <> 0) then
    begin
      fSettings.i['scanner.baudRate'] := postObj.i['scanner.baudRate'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.dataBits'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.dataBits'],
      postObj.i['scanner.dataBits']) <> 0) then
    begin
      fSettings.i['scanner.dataBits'] := postObj.i['scanner.dataBits'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.parity'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.parity'],
      postObj.i['scanner.parity']) <> 0) then
    begin
      fSettings.i['scanner.parity'] := postObj.i['scanner.parity'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.stopBits'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.stopBits'],
      postObj.i['scanner.stopBits']) <> 0) then
    begin
      fSettings.i['scanner.stopBits'] := postObj.i['scanner.stopBits'];
      onChangeObj := true;
    end;

  if (postObj.O['scanner.flowControl'] <> nil) then
    if (CompareValueInteger(fSettings.i['scanner.flowControl'],
      postObj.i['scanner.flowControl']) <> 0) then
    begin
      fSettings.i['scanner.flowControl'] := postObj.i['scanner.flowControl'];
      onChangeObj := true;
    end;

  if onChangeObj then
  begin
    saveSettings();
    uEkasaPrinters.isEkasaInit := false;
    uServer.Scanner.restartScanner;
  end;
  result := '{"message":"OK"}';
end;

procedure interfaceCmd(ARequestDocument: string;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
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

  if isMatchUrl(ARequestInfo.document, c_settings) then
  begin
    if (ARequestInfo.Command = C_GET) then
      response := settingsGet();
    if (ARequestInfo.Command = C_POST) then
      response := settingsPost();
  end
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
