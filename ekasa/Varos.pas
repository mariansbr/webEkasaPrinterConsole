// --------------------------------------------------------------------------
// Varos ver 1.0 for Delphi XE created 11-March-2021
// Author: M.Snek
//
// podklady prg_manual 2.01.pdf
// --------------------------------------------------------------------------

unit Varos;

interface

uses
  SysUtils, Windows, AfComPort, IdTCPClient, superObject, IdGlobal, StrUtils,
  uSettings, uEkasaPrinters;

resourcestring
  rs_errormsg = 'Chyba: %d' + #13#10 + '%s';

const
  C_LEN_BUFF = 2 * 8192; // 2048;
  C_OK = 0;
  // ERRORS mrp
  C_ERR_EXCEPT = 1; // Chyba pri vykon�van� pr�kazu
  C_ERR_PARAMSIN = 2; // Nespr�vne parametre komunika�n�ho portu
  C_ERR_NOACTIVE = 3; // Komunika�n� port nie je akt�vny
  C_ERR_TESTLINK = 4; // Prenosov� linka nie je pripravena na komunik�ciu
  C_ERR_PRINTER = 5; // Chyba s tla�iar�ou, skontrolujte paprier
  C_ERR_TIMEOUT = 6; // V nastavenem �ase nedo�la odpove�
  // ERRORS varos
  // Pozn�mka: Chyby ��slo -2 a� -132 s� chyby priamo vracan� serverom eKasa
  C_ERR_2 = -2; // Zl� vstupn� hodnoty.
  C_ERR_8 = -8;
  // T�to verzia integra�n�ho rozhrania u� nie je na�alej podporovan�.
  C_ERR_10 = -10; // Chyba v podpise d�tovej spr�vy.
  C_ERR_12 = -12; // Nespr�vny form�t certifik�tu.
  C_ERR_13 = -13; // Pou�it� certifik�t nie je platn�.
  C_ERR_100 = -100; // Nespr�vna hodnota PKP.
  C_ERR_101 = -101; // DI� v d�tovej spr�ve sa nezhoduje s DI� z certifik�tu.
  C_ERR_102 = -102;
  // K�d ORP v d�tovej spr�ve sa nezhoduje s k�dom ORP z certifik�tu.
  C_ERR_103 = -103;
  // D�tum a �as vyhotovenia dokladu je neskor�� ako d�tum a �as spracovania.
  C_ERR_104 = -104;
  // D�tum a �as vytvorenia dokladu je neskor�� ako d�tum a �as spracovania.
  C_ERR_105 = -105;
  // D�tum a �as vytvorenia dokladu je skor�� ako d�tum a �as spracovania.
  C_ERR_106 = -106;
  // D�tum a �as vyhotovenia dokladu je skor�� ako d�tum a �as spustenia syst�mu.
  C_ERR_107 = -107;
  // D�tum a �as vytvorenia dokladu je skor�� ako d�tum a �as spustenia syst�mu.
  C_ERR_108 = -108;
  // D�tum a �as vytvorenia �dajov o polohe je neskor�� ako d�tum a �as spracovania.
  C_ERR_109 = -109;
  // D�tum a �as vytvorenia �dajov o polohe je skor�� ako d�tum a �as spracovania.
  C_ERR_110 = -110;
  // D�tum a �as vytvorenia �dajov o polohe je skor�� ako d�tum a �as spustenia syst�mu.
  C_ERR_111 = -111; // Nespr�vna hodnota OKP.
  C_ERR_112 = -112;
  // ��slo fakt�ry mus� by� vyplnen� pre typ dokladu: �hrada fakt�ry.
  C_ERR_113 = -113;
  // Rozpis DPH nesmie byt vyplnen� pre typ dokladu: �hrada fakt�ry, Vklad, V�ber.
  C_ERR_114 = -114;
  // Typ dokladu: �hrada fakt�ry, Vklad, V�ber nesmie obsahova� polo�ky.
  C_ERR_115 = -115;
  // ��slo fakt�ry nesmie by� vyplnen� pre typ dokladu: Pokladni�n� doklad, Neplatn� doklad, Vklad, V�ber.
  C_ERR_116 = -116;
  // Typ dokladu: Pokladni�n� doklad, Neplatn� doklad mus� obsahova� polo�ky.
  C_ERR_117 = -117;
  // Pre typ polo�ky: Vr�ten�, Opravn� mus� by� vyplnen� Referen�n� ��slo dokladu, ku ktor�mu sa vr�tenie, oprava vz�ahuje.
  C_ERR_118 = -118;
  // Pre typ polo�ky: Kladn�, Vr�ten� obaly, Z�ava, Odpo��tan� z�loha, V�mena poukazu nesmie by� vyplnen� Referen�n� ��slo dokladu.
  C_ERR_119 = -119;
  // Rozpis DPH mus� by� vyplnen� pre typ dokladu: Pokladni�n� doklad, Neplatn� doklad.
  C_ERR_120 = -120;
  // Suma dane z�kladnej sadzby a Z�klad z�kladnej sadzby dane musia by� vyplnen� obe, alebo ani jedno.
  C_ERR_121 = -121;
  // Suma dane zn�enej sadzby a Z�klad zn�enej sadzby dane musia by� vyplnen� obe, alebo ani jedno.
  C_ERR_122 = -122;
  // ID kupuj�ceho a Typ ID kupuj�ceho musia by� vyplnen� obe, alebo ani jedno.
  C_ERR_123 = -123;
  // ID kupuj�ceho a Typ ID kupuj�ceho nesm� by� vyplnen� pre typ dokladu: Neplatn� doklad, Vklad, V�ber.
  C_ERR_124 = -124; // ��slo parag�nu je povinn� v pr�pade evidovania parag�nu.
  C_ERR_125 = -125;
  // ��slo parag�nu m��e by� vyplnen� iba v pr�pade evidovania parag�nu.
  C_ERR_126 = -126;
  // Parag�n nie je mo�n� zaevidova� pre typ dokladu: Neplatn� doklad, Vklad, V�ber.
  C_ERR_127 = -127; // Typ polo�ky: Kladn� nesmie ma� z�porn� cenu.
  C_ERR_128 = -128;
  // Typ polo�ky: Vr�ten� obaly, Vr�ten�, Z�ava, Odpo��tan� z�loha, V�mena poukazu nesmie ma� kladn� cenu.
  C_ERR_129 = -129;
  // ID pred�vaj�ceho a Typ ID pred�vaj�ceho musia by� vyplnen� obe, alebo ani jedno.
  C_ERR_130 = -130;
  // Pre priradenie dane: 20, 10 nesmie by� vyplnen� Slovn� inform�cia.
  C_ERR_131 = -131;
  // Pre typ polo�ky: Kladn�, Vr�ten� obaly, Vr�ten�, Z�ava, Odpo��tan� z�loha nesmie by� vyplnen� ��slo jedno��elov�ho poukazu.
  C_ERR_132 = -132; // Nespr�vna �asov� z�na.
  C_ERR_499 = -499;
  // Odmietnutie z bezpe�nostn�ch d�vodov, je potrebn� kontaktova� podporu
  C_ERR_500 = -500; // Nesed� kone�n� suma. (Po <ESC>k ).
  C_ERR_501 = -501; // Nespr�vna hodnota v mno�stve.
  C_ERR_502 = -502; // Nespr�vna hodnota v jednotkovej cene.
  C_ERR_503 = -503; // Nespr�vne znamienko ceny v riadku.
  C_ERR_504 = -504; // Nepovolen� doklad v TEST m�de
  C_ERR_505 = -505;
  // Nekorektn� storno typ dokladu. (A -vr�tenie, B -z�ava, C -odpo��tan� z�loha, D -v�mena poukazu).
  C_ERR_507 = -507; // Chyba valid�cie podla wsdl sch�my
  C_ERR_508 = -508; // Duplicitn� polo�ka
  C_ERR_509 = -509; // Odberate� viac ako 1 kr�t uveden�
  C_ERR_510 = -510; // chyba tla�iarne
  C_ERR_511 = -511;
  // V�mena poukazu mus� by� vyplnen� ��slo jedno��elov�ho poukazu.
  C_ERR_512 = -512;
  // Pre doklad obsahuj�ci V�menn� poukazu mus� by� suma dokladu O Eur.
  C_ERR_550 = -550; // Ch�ba ESCK v blo�ku Neukonceny riadok
  C_ERR_551 = -551; // Neukon�en� riadok
  C_ERR_552 = -552; // Prekro�en� po�et dovolen�ch voln�ch tla�ov�ch znakov
  C_ERR_553 = -553; // Nepovolen� riadiace znaky
  C_ERR_554 = -554; // CHDU error
  C_ERR_555 = -555; // Chyba v syst�movom �ase
  C_ERR_556 = -556; // Preru�en� u��vate�om po upozornen� na skok v d�tume
  C_ERR_557 = -557; // Nepovolen� SwId.
  C_ERR_999 = -999; // Nezn�ma chyba.

  // Specialne ASCII znaky
  CR = #13; // carriage return
  ESC = #27; // escape

type
  TInternalBuffer = array [0 .. C_LEN_BUFF - 1] of byte;
  TConnectType = (ctNone, ctCom, ctTcp);

  TVaros = class
  private
    fCom: TAfComPort;
    fTcp: TIdTCPClient;
    fIntBuf: TInternalBuffer;
    fRecvCount: integer;
    fConnectType: TConnectType;
    fExceptStr: string;
    function getReady(): boolean;
    function getReadyPrinter(): boolean;
  public
    constructor Create();
    destructor Destroy; override;

    function execCommand(buffer: PAnsiChar; count: integer;
      timeOutTime: cardinal): integer;
    function errorStr(err: integer): string;
    procedure readRecvData(buffer: PAnsiChar);
    property recvCount: integer read fRecvCount;
    property ready: boolean read getReady;
    property readyPrinter: boolean read getReadyPrinter;

    // COM interface
    function _ConnectCom(comNumber: integer): integer;
    function _DisconectCom(): integer;
    // TCP interface
    function _ConnectTcp(host: string; const port: word = 20543): integer;
    function _DisconnectTcp(): integer;

    function _Receipt(data: string): integer;
    function _Receiptcopy(): integer;
    function _DrawerOpen(): integer;
    function _Report(data: string): integer;
    function _Location(data: string): integer;
    function _OfflineSend(): integer;

    function STATE_h_x68(data: PAnsiChar): integer; // vycitanie hlavicky
    function STATE_D_x44(data: PAnsiChar): integer; // vycitanie kodu pokladne
    function STATE_d_x64(data: PAnsiChar): integer; // vycitanie danovych hladin
    function STATE_v_x76(data: PAnsiChar): integer;
    // vycitanie verzie programu PPEKK
    function STATE_T_x54(data: PAnsiChar): integer;
    // vycitanie priznaku testovacieho modu 1, ostry mod 0
    function STATE_c_x63(data: PAnsiChar): integer;
    // vycitanie platnosti certifikatu (YYYYMMDD)
    function STATE_O_x4F(data: PAnsiChar): integer;
    // vycitanie poctu OFF-LINE dokladov (00001)
    function STATE_p_x70(data: PAnsiChar): integer;
    // vycitanie stavovych informacii tlaciarne (JSON format)
    function STATE_s_x73(data: PAnsiChar): integer;
    // vycitanie informacii o CHDU (JSON format)
    function STATE_I_x49(data: PAnsiChar): integer;
    // vycitanie informacii o poslednom doklade (JSON format)
    function STATE_R_x52(data: PAnsiChar): integer;
    // vycitanie reportu obratov (JSON format)
  end;

function bufToHexaStr(buffer: TInternalBuffer; bufferLength: integer): string;

var
  fVaros: TVaros = nil;

implementation

{ TVaros }

constructor TVaros.Create;
begin
  inherited;
  fExceptStr := '';
  fConnectType := ctNone;
end;

destructor TVaros.Destroy;
begin
  inherited;
  case fConnectType of
    ctCom:
      begin
        if Assigned(fCom) then
        begin
          if fCom.Active then
            fCom.Active := false;
          FreeAndNil(fCom)
        end;
      end;
    ctTcp:
      begin
        if Assigned(fTcp) then
        begin
          if fTcp.Connected then
            fTcp.Disconnect();
          FreeAndNil(fTcp);
        end;
      end;
  end;
end;

function TVaros.execCommand(buffer: PAnsiChar; count: integer;
  timeOutTime: cardinal): integer;
var
  fPacket: TInternalBuffer;
  i: integer;
  fBBuffer: TBytes;
  stopTime: cardinal;
  respLength: integer;
  iCnt, iPos, recvWait, pocetCteni: integer;
  p: pointer;
  str: string;
begin
  result := C_OK;
  FillChar(fPacket, SizeOf(fPacket), 0);
  if count > 0 then
    Move(buffer^, fPacket[0], count);

  iPos := count;
  recvWait := -1;
  fRecvCount := 0;
  FillChar(fIntBuf, SizeOf(fIntBuf), 0);

  // log - request
  if fSettings.B['ekasa.withLog'] then
  begin
    SetString(str, PAnsiChar(@buffer[0]), count);
    addLog('Out : ''' + str + '''');
    addLog('Out Hexa : ' + bufToHexaStr(fPacket, count));
  end;

  // Priama komunikacia pomocou COM/USB
  if (fConnectType = ctCom) then
  begin
    // kontrola moznosti komunikacie
    stopTime := GetTickCount + (3 * timeOutTime);
    repeat
      i := fCom.InBufUsed;
      if i > 0 then
      begin
        GetMem(p, i);
        try
          fCom.ReadData(p^, i);
        finally
          FreeMem(p);
        end;

        if (stopTime < GetTickCount) then
          recvWait := 1;
      end
      else
        recvWait := 0;
    until recvWait >= 0;

    if recvWait > 0 then
    begin
      result := C_ERR_TESTLINK;
      exit;
    end;

    Sleep(100);
    fCom.WriteData(fPacket[0], iPos);

    fRecvCount := 0;
    if (timeOutTime > 0) then
    begin // timeOutTime = 0 => necakam odpoved, beriem ze je vsetko OK
      // Pripravime prijem
      recvWait := -1;
      iCnt := 0;
      // cekame
      pocetCteni := 3;
      FillChar(fPacket, SizeOf(fPacket), 0);
      repeat
        stopTime := GetTickCount + (3 * timeOutTime);
        // Ted cekame bud na cely packet, nebo na timeout
        repeat
          i := fCom.InBufUsed;
          if i > 0 then
          begin
            GetMem(p, i);
            try
              fCom.ReadData(p^, i);
              Move(p^, fPacket[iCnt], i);
              Inc(iCnt, i);
            finally
              FreeMem(p);
            end;

            if iCnt > 0 then
            begin
              // odpoved moze byt:
              // 1. <kod><dlzkaH><dlzkaL><prijate data danej dlzky>
              // 2. <kod> - odpoved bez dat
              if (fPacket[0] = 6 { ACK } ) then
              begin
                respLength := 256 * fPacket[1] + fPacket[2];
                if (respLength > 0) then
                begin
                  if (iCnt = (respLength + 2 + 1)) then
                  begin // 2=<dlzkaH><dlzkaL> 1=<kod>
                    recvWait := 0;
                    fRecvCount := (respLength + 2 + 1);
                    break;
                  end;
                end
                else
                begin
                  recvWait := 0;
                  break;
                end;
              end
              else if (fPacket[0] = 21 { NAK } ) then
              begin
                fExceptStr := 'NAK response from eKasa';
                result := C_ERR_EXCEPT;
                recvWait := 0;
                break;
              end;
            end;

            // Pokud jeste neni packet cely a prijimame znaky, tak posuneme timeout
            stopTime := GetTickCount + (3 * timeOutTime);
          end;
          if (recvWait < 0) and (stopTime < GetTickCount) then
            recvWait := 1;
        until (recvWait >= 0);

        if (recvWait > 0) then
        begin
          // Precetli jsme alespon zacatek? ma smysl zkouset znovu?
          if (iCnt > 0) and (pocetCteni > 1) then
          begin
            recvWait := -1;
          end
          else
            break;
        end
        else
          break;
        Dec(pocetCteni);
      until (pocetCteni <= 0);
    end;
  end;

  // Priama komunikacia pomocou TCP socket
  if (fConnectType = ctTcp) then
  begin

    // Pripravime buffer na odoslanie
    SetLength(fBBuffer, count);
    for i := 0 to count - 1 do
      fBBuffer[i] := fPacket[i];

    // Odosleme buffer
    fTcp.IOHandler.Write(TIdBytes(fBBuffer));

    // Pripravime buffer na prijem
    recvWait := -1;
    fRecvCount := 0;
    stopTime := GetTickCount;
    if (timeOutTime > 0) then
    begin
      fTcp.ReadTimeout := timeOutTime;
      stopTime := stopTime + timeOutTime;
    end;
    SetLength(fBBuffer, 0);

    if (timeOutTime > 0) then
    begin // timeOutTime = 0 => necakam odpoved, beriem ze je vsetko OK
      repeat
        // Citanie odpovede do buffra
        fTcp.IOHandler.ReadBytes(TIdBytes(fBBuffer), -1);

        if fSettings.B['ekasa.withLog'] then
        begin
          FillChar(fPacket, SizeOf(fPacket), 0);
          for i := 0 to Length(fBBuffer) - 1 do
            fPacket[i] := fBBuffer[i];
          addLog('In Hexa : ' + bufToHexaStr(fPacket, Length(fBBuffer) - 1));
        end;

        FillChar(fPacket, SizeOf(fPacket), 0);
        // odpoved moze byt:
        // 1. <kod><dlzkaH><dlzkaL><prijate data danej dlzky>
        // 2. <kod> - odpoved bez dat
        if (fBBuffer[0] = 6 { ACK } ) then
        begin
          respLength := 256 * fBBuffer[1] + fBBuffer[2];
          if (respLength > 0) then
          begin
            for i := 0 to Length(fBBuffer) - 1 do
              fPacket[i] := fBBuffer[i];
            fRecvCount := (respLength + 2 + 1); // 2=<dlzkaH><dlzkaL> 1=<kod>
          end;
          recvWait := 0;
        end
        else if (fBBuffer[0] = 21 { NAK } ) then
        begin
          fExceptStr := 'NAK response from eKasa';
          result := C_ERR_EXCEPT;
          recvWait := 0;
        end;

        if (recvWait < 0) and (stopTime < GetTickCount) then
          recvWait := C_ERR_TIMEOUT; // timeOut odchod z tadeto

      until (recvWait >= 0);
    end;
  end;

  if (recvWait = C_ERR_TIMEOUT) then
  begin
    result := recvWait;
    if fSettings.B['ekasa.withLog'] then
      addLog('TimeOut - ERROR');
  end;

  if (fRecvCount > 0) then
  begin
    Move(fPacket[3], fIntBuf[0], fRecvCount - 3);
    if fSettings.B['ekasa.withLog'] then
    begin
      SetString(str, PAnsiChar(@fPacket[3]), fRecvCount - 3);
      addLog('In : ' + str);
    end;
  end
  else if fSettings.B['ekasa.withLog'] then
    addLog('In : --');
end;

function TVaros.errorStr(err: integer): string;
begin
  case err of
    // ERRORS varos
    // Pozn�mka: Chyby ��slo -2 a� -132 s� chyby priamo vracan� serverom eKasa
    C_ERR_2:
      result := 'Zl� vstupn� hodnoty';
    C_ERR_8:
      result := 'T�to verzia integra�n�ho rozhrania u� nie je na�alej podporovan�';
    C_ERR_10:
      result := 'Chyba v podpise d�tovej spr�vy';
    C_ERR_12:
      result := 'Nespr�vny form�t certifik�tu';
    C_ERR_13:
      result := 'Pou�it� certifik�t nie je platn�';
    C_ERR_100:
      result := 'Nespr�vna hodnota PKP';
    C_ERR_101:
      result := 'DI� v d�tovej spr�ve sa nezhoduje s DI� z certifik�tu';
    C_ERR_102:
      result := 'K�d ORP v d�tovej spr�ve sa nezhoduje s k�dom ORP z certifik�tu';
    C_ERR_103:
      result := 'D�tum a �as vyhotovenia dokladu je neskor�� ako d�tum a �as spracovania';
    C_ERR_104:
      result := 'D�tum a �as vytvorenia dokladu je neskor�� ako d�tum a �as spracovania';
    C_ERR_105:
      result := 'D�tum a �as vytvorenia dokladu je skor�� ako d�tum a �as spracovania';
    C_ERR_106:
      result := 'D�tum a �as vyhotovenia dokladu je skor�� ako d�tum a �as spustenia syst�mu';
    C_ERR_107:
      result := 'D�tum a �as vytvorenia dokladu je skor�� ako d�tum a �as spustenia syst�mu';
    C_ERR_108:
      result := 'D�tum a �as vytvorenia �dajov o polohe je neskor�� ako d�tum a �as spracovania';
    C_ERR_109:
      result := 'D�tum a �as vytvorenia �dajov o polohe je skor�� ako d�tum a �as spracovania';
    C_ERR_110:
      result := 'D�tum a �as vytvorenia �dajov o polohe je skor�� ako d�tum a �as spustenia syst�mu';
    C_ERR_111:
      result := 'Nespr�vna hodnota OKP';
    C_ERR_112:
      result := '��slo fakt�ry mus� by� vyplnen� pre typ dokladu: �hrada fakt�ry';
    C_ERR_113:
      result := 'Rozpis DPH nesmie byt vyplnen� pre typ dokladu: �hrada fakt�ry, Vklad, V�ber';
    C_ERR_114:
      result := 'Typ dokladu: �hrada fakt�ry, Vklad, V�ber nesmie obsahova� polo�ky';
    C_ERR_115:
      result := '��slo fakt�ry nesmie by� vyplnen� pre typ dokladu: Pokladni�n� doklad, Neplatn� doklad, Vklad, V�ber';
    C_ERR_116:
      result := 'Typ dokladu: Pokladni�n� doklad, Neplatn� doklad mus� obsahova� polo�ky';
    C_ERR_117:
      result := 'Pre typ polo�ky: Vr�ten�, Opravn� mus� by� vyplnen� Referen�n� ��slo dokladu, ku ktor�mu sa vr�tenie, oprava vz�ahuje';
    C_ERR_118:
      result := 'Pre typ polo�ky: Kladn�, Vr�ten� obaly, Z�ava, Odpo��tan� z�loha, V�mena poukazu nesmie by� vyplnen� Referen�n� ��slo dokladu';
    C_ERR_119:
      result := 'Rozpis DPH mus� by� vyplnen� pre typ dokladu: Pokladni�n� doklad, Neplatn� doklad';
    C_ERR_120:
      result := 'Suma dane z�kladnej sadzby a Z�klad z�kladnej sadzby dane musia by� vyplnen� obe, alebo ani jedno';
    C_ERR_121:
      result := 'Suma dane zn�enej sadzby a Z�klad zn�enej sadzby dane musia by� vyplnen� obe, alebo ani jedno';
    C_ERR_122:
      result := 'ID kupuj�ceho a Typ ID kupuj�ceho musia by� vyplnen� obe, alebo ani jedno';
    C_ERR_123:
      result := 'ID kupuj�ceho a Typ ID kupuj�ceho nesm� by� vyplnen� pre typ dokladu: Neplatn� doklad, Vklad, V�ber';
    C_ERR_124:
      result := '��slo parag�nu je povinn� v pr�pade evidovania parag�nu';
    C_ERR_125:
      result := '��slo parag�nu m��e by� vyplnen� iba v pr�pade evidovania parag�nu';
    C_ERR_126:
      result := 'Parag�n nie je mo�n� zaevidova� pre typ dokladu: Neplatn� doklad, Vklad, V�ber';
    C_ERR_127:
      result := 'Typ polo�ky: Kladn� nesmie ma� z�porn� cenu';
    C_ERR_128:
      result := 'Typ polo�ky: Vr�ten� obaly, Vr�ten�, Z�ava, Odpo��tan� z�loha, V�mena poukazu nesmie ma� kladn� cenu';
    C_ERR_129:
      result := 'ID pred�vaj�ceho a Typ ID pred�vaj�ceho musia by� vyplnen� obe, alebo ani jedno';
    C_ERR_130:
      result := 'Pre priradenie dane: 20, 10 nesmie by� vyplnen� Slovn� inform�cia';
    C_ERR_131:
      result := 'Pre typ polo�ky: Kladn�, Vr�ten� obaly, Vr�ten�, Z�ava, Odpo��tan� z�loha nesmie by� vyplnen� ��slo jedno��elov�ho poukazu';
    C_ERR_132:
      result := 'Nespr�vna �asov� z�na';
    C_ERR_499:
      result := 'Odmietnutie z bezpe�nostn�ch d�vodov, je potrebn� kontaktova� podporu';
    C_ERR_500:
      result := 'Nesed� kone�n� suma. (Po <ESC>k )';
    C_ERR_501:
      result := 'Nespr�vna hodnota v mno�stve';
    C_ERR_502:
      result := 'Nespr�vna hodnota v jednotkovej cene';
    C_ERR_503:
      result := 'Nespr�vne znamienko ceny v riadku';
    C_ERR_504:
      result := 'Nepovolen� doklad v TEST m�de';
    C_ERR_505:
      result := 'Nekorektn� storno typ dokladu. (A -vr�tenie, B -z�ava, C -odpo��tan� z�loha, D -v�mena poukazu)';
    C_ERR_507:
      result := 'Chyba valid�cie podla wsdl sch�my';
    C_ERR_508:
      result := 'Duplicitn� polo�ka';
    C_ERR_509:
      result := 'Odberate� viac ako 1 kr�t uveden�';
    C_ERR_510:
      result := 'chyba tla�iarne';
    C_ERR_511:
      result := 'V�mena poukazu mus� by� vyplnen� ��slo jedno��elov�ho poukazu';
    C_ERR_512:
      result := 'Pre doklad obsahuj�ci V�menn� poukazu mus� by� suma dokladu O Eur';
    C_ERR_550:
      result := 'Ch�ba ESCK v blo�ku Neukonceny riadok';
    C_ERR_551:
      result := 'Neukon�en� riadok';
    C_ERR_552:
      result := 'Prekro�en� po�et dovolen�ch voln�ch tla�ov�ch znakov';
    C_ERR_553:
      result := 'Nepovolen� riadiace znaky';
    C_ERR_554:
      result := 'CHDU error';
    C_ERR_555:
      result := 'Chyba v syst�movom �ase';
    C_ERR_556:
      result := 'Preru�en� u��vate�om po upozornen� na skok v d�tume';
    C_ERR_557:
      result := 'Nepovolen� SwId';
    C_ERR_999:
      result := 'Nezn�ma chyba';

    C_ERR_EXCEPT:
      result := 'Chyba pri vykon�van� pr�kazu'#13 + fExceptStr;
    C_ERR_PARAMSIN:
      result := 'Nespr�vne parametre komunika�n�ho portu';
    C_ERR_NOACTIVE:
      result := 'Komunika�n� port nie je akt�vny';
    C_ERR_TESTLINK:
      result := 'Prenosov� linka nie je pripravena na komunik�ciu';
    C_ERR_PRINTER:
      result := 'Chyba s tla�iar�ou, skontrolujte paprier';
    C_ERR_TIMEOUT:
      result := 'V pr�slu�nom �ase nedo�la odpove� z FM.';

  else
    result := 'Nezn�ma chyba';

  end;
end;

procedure TVaros.readRecvData(buffer: PAnsiChar);
begin
  if Assigned(buffer) and (fRecvCount > 0) then
    Move(fIntBuf[0], buffer^, fRecvCount);
end;

function TVaros.getReady: boolean;
begin
  result := false;
  case fConnectType of
    ctCom:
      result := (Assigned(fCom) and fCom.Active);
    ctTcp:
      result := (Assigned(fTcp) and fTcp.Connected);
  end;
end;

function TVaros.getReadyPrinter(): boolean;
var
  str: string;
  res: integer;
  o: ISuperObject;
begin
  result := false;
  if ready then
  begin
    str := ESC + '!p' + ESC + 'e';
    res := execCommand(PAnsiChar(AnsiString(str)), Length(str), 2500);
    if (res = C_OK) then
    begin
      SetString(str, PAnsiChar(@fIntBuf[0]), fRecvCount);
      o := SO(str);
      result := o.B['printerStatus.online'];
    end;
  end;
end;

function TVaros._ConnectCom(comNumber: integer): integer;
begin
  if (comNumber >= 1) and (comNumber <= 256) then
  begin
    fCom := TAfComPort.Create(nil);
    fCom.comNumber := comNumber;
    fCom.UserBaudRate := 115200;
    fCom.Databits := db8;
    fCom.Parity := paNone;
    fCom.Stopbits := sbOne;
    fCom.DTR := true;
    try
      fCom.Active := true;
      fConnectType := ctCom;
      result := C_OK;
    except
      on E: Exception do
      begin
        fExceptStr := E.Message;
        result := C_ERR_EXCEPT;
      end;
    end;
  end
  else
    result := C_ERR_PARAMSIN;
end;

function TVaros._DisconectCom(): integer;
begin
  result := C_OK;
  if Assigned(fCom) then
  begin
    try
      if fCom.Active then
        fCom.Close;
      FreeAndNil(fCom);
      fConnectType := ctNone;
    except
      on E: Exception do
      begin
        fExceptStr := E.Message;
        result := C_ERR_EXCEPT;
      end;
    end;
  end;
end;

function TVaros._ConnectTcp(host: string; const port: word): integer;

  function isWrongIP(ip: string): boolean;
  const
    z = ['0' .. '9', '.'];
  var
    i, j, p: integer;
    w: string;
  begin
    result := false;
    if (Length(ip) > 15) or (ip[1] = '.') then
      exit;
    i := 1;
    j := 0;
    p := 0;
    w := '';
    repeat
      if CharInSet(ip[i], ['0' .. '9', '.']) and (j < 4) then
      begin

        if ip[i] = '.' then
        begin
          Inc(p);
          j := 0;
          try
            StrToInt(ip[i + 1]);
          except
            exit;
          end;
          w := '';
        end
        else
        begin
          w := w + ip[i];
          if (StrToInt(w) > 255) or (Length(w) > 3) then
            exit;
          Inc(j);
        end;
      end
      else
        exit;
      Inc(i);
    until i > Length(ip);
    if p < 3 then
      exit;
    result := true;
  end;

var
  hostIp: string;
  portIp: word;

begin
  hostIp := host;
  portIp := port;
  if Pos(':', hostIp) > 0 then
  begin
    host := Copy(hostIp, 1, Pos(':', hostIp) - 1);
    System.Delete(hostIp, 1, Pos(':', hostIp));
    portIp := StrToIntDef(hostIp, 20543);
  end;

  if (isWrongIP(host)) then
  begin
    fTcp := TIdTCPClient.Create(nil);
    fTcp.host := host;
    fTcp.port := portIp;
    fTcp.ConnectTimeout := 20000;
    try
      fTcp.Connect();
      fConnectType := ctTcp;
      result := C_OK;
    except
      on E: Exception do
      begin
        fExceptStr := E.Message;
        result := C_ERR_EXCEPT;
      end;
    end;
  end
  else
    result := C_ERR_PARAMSIN;
end;

function TVaros._DisconnectTcp: integer;
begin
  result := C_OK;
  if Assigned(fTcp) then
  begin
    try
      if fTcp.Connected then
        fTcp.Disconnect;
      FreeAndNil(fTcp);
      fConnectType := ctNone;
    except
      on E: Exception do
      begin
        fExceptStr := E.Message;
        result := C_ERR_EXCEPT;
      end;
    end;
  end;
end;

function TVaros.STATE_h_x68(data: PAnsiChar): integer; // vycitanie hlavicky
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!h' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_D_x44(data: PAnsiChar): integer;
// vycitanie kodu pokladne
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!D' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_d_x64(data: PAnsiChar): integer;
// vycitanie danovych hladin
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!d' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_v_x76(data: PAnsiChar): integer;
// vycitanie verzie programu PPEKK
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!v' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_T_x54(data: PAnsiChar): integer;
// vycitanie priznaku testovacieho modu 1, ostry mod 0
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!T' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_c_x63(data: PAnsiChar): integer;
// vycitanie platnosti certifikatu (YYYYMMDD)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!c' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_O_x4F(data: PAnsiChar): integer;
// vycitanie poctu OFF-LINE dokladov (00001)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!O' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_p_x70(data: PAnsiChar): integer;
// vycitanie stavovych informacii tlaciarne (JSON format)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!p' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_s_x73(data: PAnsiChar): integer;
// vycitanie informacii o CHDU (JSON format)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!s' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_I_x49(data: PAnsiChar): integer;
// vycitanie informacii o poslednom doklade (JSON format)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!I' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 3300);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros.STATE_R_x52(data: PAnsiChar): integer;
// vycitanie reportu obratov (JSON format)
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + '!R' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      if (result = C_OK) then
        readRecvData(PAnsiChar(data));
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
end;

function TVaros._Receipt(data: string): integer;
begin
  try
    if ready then
    begin
      if readyPrinter then
        result := execCommand(PAnsiChar(AnsiString(data)), Length(data), 0)
      else
        result := C_ERR_PRINTER;
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function TVaros._Receiptcopy(): integer;
var
  s: string;
begin
  try
    if ready then
    begin
      if readyPrinter then
      begin
        s := ESC + 'c' + ESC + 'e';
        result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
      end
      else
        result := C_ERR_PRINTER;
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function TVaros._DrawerOpen(): integer;
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + 'o' + ESC + 'e';
      execCommand(PAnsiChar(AnsiString(s)), Length(s), 0);
      result := C_OK;
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function TVaros._Report(data: string): integer;
begin
  try
    if ready then
    begin
      if readyPrinter then
        result := execCommand(PAnsiChar(AnsiString(data)), Length(data), 2500)
      else
        result := C_ERR_PRINTER;
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function TVaros._Location(data: string): integer;
begin
  try
    if ready then
      result := execCommand(PAnsiChar(AnsiString(data)), Length(data), 0)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function TVaros._OfflineSend(): integer;
var
  s: string;
begin
  try
    if ready then
    begin
      s := ESC + 'S' + ESC + 'e';
      result := execCommand(PAnsiChar(AnsiString(s)), Length(s), 2500);
    end
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end
end;

function ByteToHexa(B: byte): string;
const
  hc = '0123456789abcdef';
begin
  result := hc[((B and $F0) shr 4) + 1] + hc[(B and $F0) + 1];
end;

function bufToHexaStr(buffer: TInternalBuffer; bufferLength: integer): string;
var
  i: integer;
begin
  for i := 0 to bufferLength - 1 do
    result := result + '0x' + RightStr('00' + ByteToHexa(buffer[i]), 2) + ' ';
end;

initialization

fVaros := TVaros.Create();

finalization

if Assigned(fVaros) then
  FreeAndNil(fVaros);

end.
