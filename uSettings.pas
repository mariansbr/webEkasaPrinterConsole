unit uSettings;

interface

uses
  superObject, Classes, SysUtils;

procedure loadSettings();
procedure saveSettings();

var
  fSettings: ISuperObject;
  (*
    {"web":{"hostAddress":"0.0.0.0",
    "running":false,
    "bearerToken":""},
    "ekasa":{"typ":2,
    "typStr":"Fiskal PRO - eKasa",
    "hostAddress":"127.0.0.1",
    "connectionTyp":2,
    "copyInvoice":true,
    "withLog":true,
    "comPort":1,
    "header":"",
    "footer":"",
    "drawer":1,           //only bowa
    "vatPayer":true,      //only bowa
    "headerBitmap":0,     //only bowa
    "footerBitmap":0,     //only bowa
    "printFullName":true},//only bowa
    "scanner":{"use":false,
    "comPort:1,
    "baudRate": C_BaudRate
    "dataBits": C_DataBits
    "parity": C_Parity
    "stopBits": fStopbits
    "flowControl": = C_FlowControl}
    }
    }
  *)

implementation

uses
  uEkasaPrinters, AfComPort;

function getToken(const aLength: integer;
  const aCharSequence
  : string =
  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'): string;
var
  i, minRandomValue, sequenceLength: integer;
begin
  result := '';
  minRandomValue := 1;
  sequenceLength := Length(aCharSequence);
  Randomize;
  for i := 0 to aLength - 1 do
    result := result + aCharSequence[Random(sequenceLength - minRandomValue) +
      minRandomValue];
end;

procedure loadSettings();
var
  firstRun, onChangeObj: boolean;
begin
  onChangeObj := false;
  firstRun := not FileExists(ChangeFileExt(ParamStr(0), '.json'));

  if firstRun then
    fSettings := SO()
  else
    fSettings := TSuperObject.ParseFile(ChangeFileExt(ParamStr(0), '.json'));

  // check new or default value
  if (fSettings.O['web.hostAddress'] = nil) then
  begin
    fSettings.S['web.hostAddress'] := '0.0.0.0';
    onChangeObj := true;
  end;

  if (fSettings.O['web.running'] = nil) then
  begin
    fSettings.B['web.running'] := false;
    onChangeObj := true;
  end;

  if (fSettings.O['web.bearerToken'] = nil) then
  begin
    fSettings.S['web.bearerToken'] := getToken(64);
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.typ'] = nil) then
  begin
    fSettings.i['ekasa.typ'] := 0;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.typStr'] = nil) then
  begin
    fSettings.S['ekasa.typStr'] := rs_Nepouzivat;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.connectionTyp'] = nil) then
  begin
    fSettings.i['ekasa.connectionTyp'] := 0;
    onChangeObj := true;
  end;


  if (fSettings.O['ekasa.hostAddress'] = nil) then
  begin
    fSettings.S['ekasa.hostAddress'] := '127.0.0.1';
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.comPort'] = nil) then
  begin
    fSettings.i['ekasa.comPort'] := 1;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.withLog'] = nil) then
  begin
    fSettings.B['ekasa.withLog'] := false;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.header'] = nil) then
  begin
    fSettings.S['ekasa.header'] := '';
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.footer'] = nil) then
  begin
    fSettings.S['ekasa.footer'] := '';
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.drawer'] = nil) then
  begin
    fSettings.i['ekasa.drawer'] := 0;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.vatPayer'] = nil) then
  begin
    fSettings.B['ekasa.vatPayer'] := true;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.headerBitmap'] = nil) then
  begin
    fSettings.i['ekasa.headerBitmap'] := 0;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.footerBitmap'] = nil) then
  begin
    fSettings.i['ekasa.footerBitmap'] := 0;
    onChangeObj := true;
  end;

  if (fSettings.O['ekasa.printFullName'] = nil) then
  begin
    fSettings.B['ekasa.printFullName'] := true;
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.use'] = nil) then
  begin
    fSettings.B['scanner.use'] := false;
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.comPort'] = nil) then
  begin
    fSettings.i['scanner.comPort'] := 1;
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.baudRate'] = nil) then
  begin
    fSettings.i['scanner.baudRate'] := Ord(br9600);
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.dataBits'] = nil) then
  begin
    fSettings.i['scanner.dataBits'] := Ord(db8);
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.parity'] = nil) then
  begin
    fSettings.i['scanner.parity'] := Ord(paNone);
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.stopBits'] = nil) then
  begin
    fSettings.i['scanner.stopBits'] := Ord(sbOne);
    onChangeObj := true;
  end;

  if (fSettings.O['scanner.flowControl'] = nil) then
  begin
    fSettings.i['scanner.flowControl'] := Ord(fwNone);
    onChangeObj := true;
  end;

  if onChangeObj then
    saveSettings();
end;

procedure saveSettings();
begin
  fSettings.SaveTo(ChangeFileExt(ParamStr(0), '.json'));
end;

end.
