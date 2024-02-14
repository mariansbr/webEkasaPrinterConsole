program webEkasaPrinter;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Windows,
  superdate in 'components\superObject\superdate.pas',
  superobject in 'components\superObject\superobject.pas',
  supertimezone in 'components\superObject\supertimezone.pas',
  supertypes in 'components\superObject\supertypes.pas',
  eKasaBowa in 'ekasa\eKasaBowa.pas',
  eKasaElcomm in 'ekasa\eKasaElcomm.pas',
  eKasaFiskalPro in 'ekasa\eKasaFiskalPro.pas',
  eKasaMrp in 'ekasa\eKasaMrp.pas',
  eKasaVarosNative in 'ekasa\eKasaVarosNative.pas',
  ekMrp in 'ekasa\ekMrp.pas',
  Elcomm_TLB_3_0 in 'ekasa\Elcomm_TLB_3_0.pas',
  FiskalPro in 'ekasa\FiskalPro.pas',
  uEkasa in 'ekasa\uEkasa.pas',
  Varos in 'ekasa\Varos.pas',
  DecRound in 'DecRound.pas',
  DelUp in 'DelUp.pas',
  uServer in 'uServer.pas',
  uCommon in 'uCommon.pas',
  uSettings in 'uSettings.pas',
  uEkasaPrinters in 'uEkasaPrinters.pas',
  uScannerHelper in 'uScannerHelper.pas',
  uInterfaceHelper in 'uInterfaceHelper.pas',
  uEkasaHelper in 'uEkasaHelper.pas',
  payPackageUtils in 'payPackageUtils.pas';

var
  Event: TInputrecord;
  EventsRead: DWORD;
  Done: boolean;

begin
  ReportMemoryLeaksOnShutdown := true;

  writeln('MRP web eKasa printer');
  writeln(#10'started on ip addres: '+getLocalIPAddress+' and port: 80'
    + #10);
  writeln('Press [Enter] to close the server.'#10);
  uServer.MrpServer.StartServer;
  try
    Done := False;
    repeat
      ReadConsoleInput(GetStdhandle(STD_INPUT_HANDLE), Event, 1, EventsRead);
      if Event.Eventtype = key_Event then
      begin
        if Event.Event.KeyEvent.bKeyDown then
        begin
          Done := Event.Event.KeyEvent.wVirtualKeyCode = VK_RETURN;
        end;
      end;
    until Done;
  finally
    uServer.MrpServer.StopServer;
  end;

end.
