unit uScannerHelper;

interface

uses
  Classes, AfComPort, AfComPortCore;

const
  c_api_scanner = '/api/scanner';

type
  TInternalBuffer = array [0 .. 4095] of byte;

type
  TComPortActions = class
  public
    class procedure OnPortOpen(Sender: TObject);
    class procedure OnPortClose(Sender: TObject);
    class procedure OnNonSyncEvent(Sender: TObject; EventKind: TAfCoreEvent;
      Data: Cardinal);
  end;

type
  TScanner = class(TAfComPort)
  private
    function _Baudrate(value: integer): TAfBaudrate; overload;
    function _Baudrate(value: TAfBaudrate): integer; overload;
    function _Parity(value: integer): TAfParity; overload;
    function _Parity(value: TAfParity): integer; overload;
    function _Databits(value: TAfDatabits): integer; overload;
    function _Databits(value: integer): TAfDatabits; overload;
    function _Stopbits(value: TAfStopbits): integer; overload;
    function _Stopbits(value: integer): TAfStopbits; overload;
    function _Flowcontrol(value: TAfFlowControl): integer; overload;
    function _Flowcontrol(value: integer): TAfFlowControl; overload;
  protected
    fAfComPort: TAfComPort;
    fComport: integer;
    fBaudrate: TAfBaudrate;
    fDatabits: TAfDatabits;
    fParity: TAfParity;
    fStopbits: TAfStopbits;
    fFlowcontrol: TAfFlowControl;
    function getBaudrate: integer;
    procedure setBaudrate(value: integer);
    function getFlowcontrol: integer;
    procedure setFlowcontrol(value: integer);
    function getDatabits: integer;
    procedure setDatabits(value: integer);
    function getStopbits: integer;
    procedure setStopbits(value: integer);
    function getParity: integer;
    procedure setParity(value: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property AfComPort: TAfComPort read fAfComPort;
    property Comport: integer read fComport write fComport;
    property Baudrate: integer read getBaudrate write setBaudrate;
    property Databits: integer read getDatabits write setDatabits;
    property Parity: integer read getParity write setParity;
    property Stopbits: integer read getStopbits write setStopbits;
    property Flowcontrol: integer read getFlowcontrol write setFlowcontrol;

    procedure settingsScanner;
    procedure startScanner;
    procedure stopScanner;
    procedure restartScanner;
  end;

function isScannerApi(document: string): boolean;

implementation

uses
  uSettings, Windows, SysUtils, uServer, DelUp;

function isScannerApi(document: string): boolean;
begin
  result := (Pos(UpperCase(c_api_scanner), UpperCase(document)) > 0);
end;

{ TScanner }

function TScanner._Baudrate(value: integer): TAfBaudrate;
begin
  for result := Low(TAfBaudrate) to High(TAfBaudrate) do
    if Ord(result) = value then
      exit;
  result := br9600;
end;

function TScanner._Baudrate(value: TAfBaudrate): integer;
begin
  result := Ord(value);
end;

function TScanner._Databits(value: integer): TAfDatabits;
begin
  for result := Low(TAfDatabits) to High(TAfDatabits) do
    if Ord(result) = value then
      exit;
  result := db8;
end;

function TScanner._Databits(value: TAfDatabits): integer;
begin
  result := Ord(value);
end;

function TScanner._Flowcontrol(value: integer): TAfFlowControl;
begin
  for result := Low(TAfFlowControl) to High(TAfFlowControl) do
    if Ord(result) = value then
      exit;
  result := fwNone;
end;

function TScanner._Flowcontrol(value: TAfFlowControl): integer;
begin
  result := Ord(value);
end;

function TScanner._Parity(value: integer): TAfParity;
begin
  for result := Low(TAfParity) to High(TAfParity) do
    if Ord(result) = value then
      exit;
  result := paNone;
end;

function TScanner._Parity(value: TAfParity): integer;
begin
  result := Ord(value);
end;

function TScanner._Stopbits(value: integer): TAfStopbits;
begin
  for result := Low(TAfStopbits) to High(TAfStopbits) do
    if Ord(result) = value then
      exit;
  result := sbOne;
end;

function TScanner._Stopbits(value: TAfStopbits): integer;
begin
  result := Ord(value);
end;

function TScanner.getBaudrate: integer;
begin
  result := _Baudrate(fBaudrate);
end;

procedure TScanner.setBaudrate(value: integer);
begin
  fBaudrate := _Baudrate(value);
end;

function TScanner.getFlowcontrol: integer;
begin
  result := _Flowcontrol(fFlowcontrol);
end;

procedure TScanner.setFlowcontrol(value: integer);
begin
  fFlowcontrol := _Flowcontrol(value);
end;

function TScanner.getDatabits: integer;
begin
  result := _Databits(fDatabits);
end;

procedure TScanner.setDatabits(value: integer);
begin
  fDatabits := _Databits(value);
end;

function TScanner.getStopbits: integer;
begin
  result := _Stopbits(fStopbits);
end;

procedure TScanner.setStopbits(value: integer);
begin
  fStopbits := _Stopbits(value);
end;

function TScanner.getParity: integer;
begin
  result := _Parity(fParity);
end;

procedure TScanner.setParity(value: integer);
begin
  fParity := _Parity(value);
end;

constructor TScanner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fAfComPort := TAfComPort.Create(nil);
end;

destructor TScanner.Destroy;
begin
  fAfComPort.Free;
  inherited;
end;

procedure TScanner.settingsScanner;
begin
  fComport := fSettings.I['scanner.comPort'];
  fBaudrate := _Baudrate(fSettings.I['scanner.baudRate']);
  fDatabits := _Databits(fSettings.I['scanner.dataBits']);
  fParity := _Parity(fSettings.I['scanner.parity']);
  fStopbits := _Stopbits(fSettings.I['scanner.stopBits']);
  fFlowcontrol := _Flowcontrol(fSettings.I['scanner.flowControl']);
end;

procedure TScanner.startScanner;
begin
  settingsScanner;
  fAfComPort.ComNumber := fComport;
  fAfComPort.Baudrate := fBaudrate;
  fAfComPort.Databits := fDatabits;
  fAfComPort.Parity := fParity;
  fAfComPort.Stopbits := fStopbits;
  fAfComPort.Flowcontrol := fFlowcontrol;
  fAfComPort.OnPortOpen := TComPortActions.OnPortOpen;
  fAfComPort.OnPortClose := TComPortActions.OnPortClose;
  fAfComPort.OnNonSyncEvent := TComPortActions.OnNonSyncEvent;
  try
    fAfComPort.Active := true;
  except
    on E: Exception do
    begin
      writeln('[ERROR] Scanner connect error');
      writeln('[ERROR] ' + E.Message);
    end;
  end;
end;

procedure TScanner.stopScanner;
begin
  try
    if fAfComPort.Active then
      fAfComPort.Active := false;
  except
    on E: Exception do
    begin
      writeln('[ERROR] Scanner disconnect error');
      writeln('[ERROR] ' + E.Message);
    end;
  end;
end;

procedure TScanner.restartScanner;
begin
  try
    if (fAfComPort.Active) then
      fAfComPort.Active := false;

    if (fSettings.B['scanner.use']) then
    begin
      // Medzi vypnutim a zapnutim com je doporucena pauza
      Sleep(250);
      settingsScanner;
      fAfComPort.ComNumber := fComport;
      fAfComPort.Baudrate := fBaudrate;
      fAfComPort.Databits := fDatabits;
      fAfComPort.Parity := fParity;
      fAfComPort.Stopbits := fStopbits;
      fAfComPort.Flowcontrol := fFlowcontrol;
      fAfComPort.OnPortOpen := TComPortActions.OnPortOpen;
      fAfComPort.OnPortClose := TComPortActions.OnPortClose;
      fAfComPort.OnNonSyncEvent := TComPortActions.OnNonSyncEvent;
      fAfComPort.Active := true;
    end;
  except
    on E: Exception do
    begin
      writeln('[ERROR] Scanner restart error');
      writeln('[ERROR]' + E.Message);
    end;
  end;
end;

{ TComPortActions }

class procedure TComPortActions.OnNonSyncEvent(Sender: TObject;
  EventKind: TAfCoreEvent; Data: Cardinal);
var
  readString: string;
begin
  readString := AStrToStr(Scanner.AfComPort.readString);
  readString := StringReplace(StringReplace(readString, #10, '', [rfReplaceAll]
    ), #13, '', [rfReplaceAll]);
  writeln(Format('[ INFO] Scanner read data %s', [readString]));
  uServer.scancode := readString;
end;

class procedure TComPortActions.OnPortClose(Sender: TObject);
begin
  writeln('[ INFO] Scanner disconnect');
end;

class procedure TComPortActions.OnPortOpen(Sender: TObject);
begin
  writeln('[ INFO] Scanner connect');
end;

end.
