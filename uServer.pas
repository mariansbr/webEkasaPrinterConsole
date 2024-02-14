unit uServer;

interface

uses
  IdHTTPServer, IdContext, IdCustomHTTPServer, IdSocketHandle, IdTCPClient,
  IdGlobal, superObject, uScannerHelper, IdThreadSafe, IdComponent;

const
  C_GET = 'GET';
  C_OPTIONS = 'OPTIONS';
  C_POST = 'POST';
  C_WEB = 'WEB\';
  C_RESULT_OK = '{"errorCode":200}';
  C_RESULT_ER = '{"errorCode":%d,"error":"%s"}';

resourcestring
  SERROR_START = 'Nastala chyba pri sp˙öùanÌ servera';
  SERROR_STOP = 'Nastala chyba pri vypÌnanÌ servera';
  SERROR_BAD_REQUEST = '{"errorCode":400,"error":"Bad request %s"}';
  SBUSYPORT = 'Vybrat˝ port je pravdepodobne obsaden˝ inou aplik·ciou';

type
  TMrpServer = class(TIdHTTPServer)
  private
    fScannerRequest: boolean;
    function PortIsOpen(dwPort: Word; ipAddressStr: string): boolean;
  public
    property scannerRequest: boolean read fScannerRequest write fScannerRequest;
    procedure InitComponent; override;
    procedure DoCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo); override;
    procedure DoCommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo); override;
    procedure DoParseAuthentication(AContext: TIdContext;
      const AAuthType, AAuthData: string; var VUsername, VPassword: string;
      var VHandled: boolean);

    procedure StartServer;
    procedure StopServer;
    function CloseAllConnections: boolean;
    function PridajIpPort(ip: string; port: integer): string;
  end;

  function getLocalIPAddress(): string;

var
  MrpServer: TMrpServer;
  Scanner: TScanner;
  scancode: string = '';

implementation

uses
  SysUtils, IniFiles, Classes, uInterfaceHelper,
  uEkasaHelper, uEkasaPrinters, uSettings, WinSock;

function getLocalIPAddress(): string;
type
  pu_long = ^u_long;
var
  varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf : Array[0..255] of ansichar;
begin
  if WSAStartup($101,varTWSAData) <> 0 then
  result := ''
  else begin
    gethostname(namebuf,sizeof(namebuf));
    varPHostEnt := gethostbyname(namebuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    result := string(inet_ntoa(varTInAddr))+' localhost 127.0.0.1';
  end;
  WSACleanup;
end;

{ TMrpServer }
function TMrpServer.PortIsOpen(dwPort: Word; ipAddressStr: string): boolean;
var
  LTcpClient: TIdTCPClient;
begin
  LTcpClient := TIdTCPClient.Create(nil);
  try
    try
      LTcpClient.Host := ipAddressStr;
      LTcpClient.port := dwPort;
      LTcpClient.ConnectTimeout := 200;
      LTcpClient.Connect;
      result := true;
    except
      result := false;
    end;
  finally
    FreeAndNil(LTcpClient);
  end;
end;

procedure TMrpServer.DoCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  requestDocument: string;
  fileDocument: string;
  logText: string;

  function RetContextType(fileDocument: string): string;
  var
    sExt: string;
  begin
    result := 'text/html';
    sExt := ExtractFileExt(fileDocument);
    if sExt = '.css' then
      result := 'text/css'
    else if sExt = '.js' then
      result := 'text/javascript'
    else if sExt = '.json' then
      result := 'text/javascript'
    else if sExt = '.wav' then
      result := 'audio/x-wav'
    else if sExt = '.mp3' then
      result := 'audio/mpeg'
    else if sExt = '.ogg' then
      result := 'audio/ogg';
  end;

  function isAuthorization(headers: string): boolean;
  var
    i: integer;
    sl: TSTringList;
  begin
    result := false;
    sl := TSTringList.Create;
    try
      sl.LineBreak := '';
      sl.Text := headers;
      for i := 0 to sl.Count - 1 do
      begin
        if (Pos('authorization', LowerCase(sl.Strings[i])) > 0) then
        begin
          result := true;
          break;
        end;
      end;
    finally
      sl.Free
    end;
  end;

  function isNoApi(document: string): boolean;
  begin
    result := (Pos('/api', LowerCase(document)) = 0);
  end;

begin
  inherited;
  // CORS
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Methods: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Headers: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Credentials: true');

  requestDocument := ARequestInfo.document;

  // addLog(ARequestInfo.RemoteIp+' - '+ARequestInfo.Command+' - '+ARequestInfo.Document+' - '+DateTimeToStr(ARequestInfo.Date));
  logText := ARequestInfo.RemoteIp + ' - ' + ARequestInfo.Command + ' - ' +  ARequestInfo.document;

  if ARequestInfo.Command = C_GET then
  begin
    if isNoApi(requestDocument) then
    begin // administracia
      if (requestDocument = '/') then
        requestDocument := 'index.html';
      fileDocument := ExtractFilePath(ParamStr(0)) + C_WEB + requestDocument;
      if FileExists(fileDocument) then
      begin
        AResponseInfo.ContentType := RetContextType(fileDocument);
        AResponseInfo.CharSet := 'UTF-8';
        AResponseInfo.ContentStream := TFileStream.Create(fileDocument,
          fmOpenRead + fmShareDenyWrite);
      end
    end
    else if uInterfaceHelper.isInterfaceApi(requestDocument) then begin
      interfaceCmd(requestDocument, ARequestInfo, AResponseInfo);
      logText := logText + ' => ' + AResponseInfo.ContentText;
    end
    else if uScannerHelper.isScannerApi(requestDocument) then begin
      if (fSettings.B['scanner.use']) then begin
        scannerRequest := true;
        while (scancode = '') do begin
          // nekonecny cyklus pre nacitanie scannerom
        end;
        AResponseInfo.ContentText := scancode;
        scannerRequest := false;
        logText := logText + ' => ' + scancode;
        scancode := '';
      end
      else begin
        AResponseInfo.ContentType := 'text/html';
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText := 'The scanner is not use or is not configured';
        logText := logText + ' => The scanner is not use or is not configured';
      end;
    end
    else if uEkasaHelper.isEkasaApi(requestDocument) then begin
      if not isAuthorization(ARequestInfo.RawHeaders.Text) then begin
        AResponseInfo.ContentType := 'text/html; charset=utf-8';
        AResponseInfo.ResponseNo := 401;
        AResponseInfo.ContentText := 'Unsupported authorization scheme.';
        logText := logText + ' => Unsupported authorization scheme';
        exit;
      end;
      eKasaCmd(requestDocument, ARequestInfo, AResponseInfo);
    end
    else begin
      AResponseInfo.ContentType := 'text/html';
      AResponseInfo.ResponseNo := 400;
      AResponseInfo.ContentText := Format(SERROR_BAD_REQUEST,
        [requestDocument]);
      logText := logText + ' => ' + SERROR_BAD_REQUEST;
    end;
  end;

  if ARequestInfo.Command = C_POST then begin
    if uInterfaceHelper.isInterfaceApi(requestDocument) then begin
      interfaceCmd(requestDocument, ARequestInfo, AResponseInfo);
      logText := logText + ' => ' + AResponseInfo.ContentText;
    end
    else if uEkasaHelper.isEkasaApi(requestDocument) then begin
      eKasaCmd(requestDocument, ARequestInfo, AResponseInfo);
      logText := logText + ' => ' + AResponseInfo.ContentText;
    end
    else begin
      AResponseInfo.ContentType := 'text/html';
      AResponseInfo.ResponseNo := 400;
      AResponseInfo.ContentText := Format(SERROR_BAD_REQUEST,
        [requestDocument]);
      logText := logText + ' => ' + SERROR_BAD_REQUEST;
    end;
  end;

  addLog(logText);

end;

procedure TMrpServer.DoCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Methods: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Headers: *');
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Credentials: true');

  if ARequestInfo.Command = C_OPTIONS then begin
    AResponseInfo.ContentType := 'text/html';
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentText := 'OK';
  end;
end;

procedure TMrpServer.DoParseAuthentication(AContext: TIdContext;
  const AAuthType, AAuthData: string; var VUsername, VPassword: string;
  var VHandled: boolean);
begin
  if AAuthType = 'Bearer' then
    if (AAuthData = fSettings.S['web.bearerToken']) then
      VHandled := true;
end;

procedure TMrpServer.InitComponent;
var
  Binding: TIdSocketHandle;
begin
  inherited;
  Bindings.Clear;
  Binding := Bindings.Add;
  Binding.SetBinding(fSettings.S['web.hostAddress'], 80, Id_IPv4);
  KeepAlive := false;
end;

procedure TMrpServer.StartServer;
var
  serverIsRunning: boolean;
begin
  if PortIsOpen(80, fSettings.S['web.hostAddress']) then begin
    serverIsRunning := fSettings.B['web.running'];
    if (serverIsRunning = false) then
      writeln('[ERROR] ' + SBUSYPORT);
  end
  else begin

    if not Assigned(MrpServer) then  begin
      MrpServer := TMrpServer.Create(nil);
      MrpServer.OnParseAuthentication := DoParseAuthentication;
    end;

    try
      if not MrpServer.Active then begin
        MrpServer.Active := true;
        fSettings.B['web.running'] := true;
        saveSettings();
        writeln('[ INFO] Server status running');
      end;
    except
      on E: Exception do begin
        writeln('[ERROR] ' + SERROR_START);
        writeln('[ERROR] ' + E.Message);
      end;
    end;

    if not Assigned(Scanner) then
    begin
      Scanner := TScanner.Create(nil);
    end;

    if (fSettings.B['scanner.use']) then
    begin
      try
        Scanner.StartScanner;
      except
        on E: Exception do
        begin
          writeln('[ERROR] ' + SERROR_START);
          writeln('[ERROR] ' + E.Message);
        end;
      end;
    end;

  end;
end;

procedure TMrpServer.StopServer;
begin
  // STOP SERVER doplnit kontrolu na active session -> konci to except
  if Assigned(MrpServer) then
  begin
    try
//      CloseAllConnections;
      uServer.scancode := 'Server is shutting down';
      if MrpServer.Active then begin
        MrpServer.Active := false;
        FreeAndNil(MrpServer);
        fSettings.B['web.running'] := false;
        saveSettings();
        writeln('[ INFO] Server status exited');
      end;
    except
      on E: Exception do begin
        writeln('[ERROR] ' + SERROR_STOP);
        writeln('[ERROR] ' + E.Message);
      end;
    end;
  end;

  if Assigned(Scanner) then
  begin
    try
      Scanner.StopScanner;
      FreeAndNil(Scanner);
    except
      on E: Exception do
      begin
        writeln('[ERROR] ' + SERROR_STOP);
        writeln('[ERROR] ' + E.Message);
      end;
    end;

  end;
end;

function TMrpServer.CloseAllConnections: boolean;
var
  i: integer;
  l: TList;
  c: TIdThreadSafeObjectList;
begin
  result := false;
  c := MrpServer.Contexts;
  if c = nil then exit;

  l := c.LockList();
  try
    for i := 0 to l.Count - 1 do
      TIdContext(l.Items[i]).Connection.Disconnect;
    result := true;
    writeln('[ INFO] CloseAllConnections')
  finally
    c.UnlockList;
  end;
end;

function TMrpServer.PridajIpPort(ip: string; port: integer): string;
var
  Binding: TIdSocketHandle;
begin
  if not PortIsOpen(port, ip) then
  begin
    MrpServer.StopListening;
    case MrpServer.Bindings.Count of
      1:
        begin
          Binding := MrpServer.Bindings.Add;
          Binding.SetBinding(ip, port, Id_IPv4);
        end;
      2:
        begin
          MrpServer.Bindings.Delete(1);
          Binding := MrpServer.Bindings.Add;
          Binding.SetBinding(ip, port, Id_IPv4);
        end;
    end;
    MrpServer.StartListening;
    result := C_RESULT_OK;
  end
  else
    result := Format(C_RESULT_ER, [500, SBUSYPORT]);
end;

initialization

loadSettings();

finalization

saveSettings();

end.
