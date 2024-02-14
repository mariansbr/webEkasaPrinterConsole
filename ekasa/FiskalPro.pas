// --------------------------------------------------------------------------
// FiskalPro ver 1.0 for Delphi XE modified 24-Januar-2019
// Author: M.Snek
// --------------------------------------------------------------------------

unit FiskalPro;

interface

uses
  Classes, SysUtils, AfComPort, IdTCPClient, Windows, IdGlobal, uEkasaPrinters,
  StrUtils, uSettings;

resourcestring
  // Navratova kody
  rs_e_01 = 'Paper out';
  rs_e_02 = 'Paper error';
  rs_e_03 = 'FM error alebo funkciu nie je mo�no previes�';
  rs_e_04 = 'Chyba komunikacie';
  rs_e_05 = 'Zru�en� posledn� doklad';
  rs_e_06 = 'OK';
  rs_e_07 = 'Je potrebn� urobi� Z report';
  rs_e_08 = 'Je potreba otvorie� de�';
  rs_e_10 = 'Chyba pri nastaven� �asu';
  rs_e_11 = '�as u� bol nastaven�';
  rs_e_12 = 'Pr�kaz nie je povolen�';
  rs_e_13 = 'Chyba pr�kazu master reset';
  rs_e_14 = 'Len jeden Z report za de�';
  rs_e_15 = 'Chyba platby';
  rs_e_16 = 'Probieha platba kartou';
  rs_e_17 = 'Platba kartou akceptovan�';
  rs_e_18 = 'Platba kartou zamietnut�';
  rs_e_20 = 'Chyba fiskalizacie';
  rs_e_27 = 'Neplatn� index DPH';
  rs_e_28 = 'Neexistuj� d�ta pre zadan� interval alebo konflikt DPH za vybran� obdobie';
  rs_e_29 = 'Nie je mo�n� vytvori� Z report v testovacom m�de';
  rs_e_36 = 'Neplatn� alebo ch�baj�ca suma dokladu';
  rs_e_37 = 'Ekasa je zablokov�na chybn�m dokladom';
  rs_e_42 = 'Ekasa je zablokov�na in�m chybn�m dokladom';
  rs_e_43 = 'Ekasa : Neplatn� ��slo z�kazn�ka';
  rs_e_44 = 'Ekasa : Neplatn� ID n�vratu';
  rs_e_45 = 'Ekasa : Neplatn� text artiklu';
  rs_e_46 = 'Ekasa : Neplatn� referen�n� ��slo';
  rs_e_47 = 'Ekasa : Neplatn� parameter paragonu';
  rs_e_176 = 'Ekasa : FiskalPro je zanepr�zdnen�, opakujte pr�kaz';
  // Nej�ast�ji m��e nastat na p��kazy po FTCLOSE po online dokladu, kdy FiskalPro pos�l� offline doklady.';
  rs_e_177 = 'Ekasa : neo�ek�van� chyba' + #13#10 + 'Skontrolujte chdu' + #13#10
    + 'Skontroluj platnos� certifik�tu ekasy' + #13#10 +
    'Kontaktujte servis FiskalPro';
  rs_e_178 = 'Ekasa : zastavujem posielanie offline fronty';
  // Pokud se pos�l� offline fronta doklad�, tak obsluha m��e toto pos�l�n� p�eru�it  pomoc� p��kazu FTEKASASTOPSEND. Odpov�� na tento p��kaz je pak 0xB2. K p�eru�en� nedojde okam�it�, ale po dokon�en� komunikace pro aktu�ln� pos�lan� doklad.
  rs_e_179 = 'Ekasa : doklad m� ve�a polo�iek';
  // Pokud velikost dokladu p�es�hne nastavenou velikost zpr�vy, FiskalPro vr�t� tuto chybu. Pozor za polo�ku sa po��ta aj polo�kov� z�ava
  rs_e_180 = 'Ekasa : nie je mo�n� uplatni� v�menn� poukaz';
  // D�vody:
  // -Hodnota v�m�nn�ho poukazu je vy��� ne� hodnota zbo��. Po��t� se samostatn� pro ka�dou hladinu DPH.
  // -Poukaz s 20% DPH nem��e b�t uplatn�n pro zbo�� v 10% DPH. Kontrola prikazu FITEMV
  // -Hodnota poukazu mus� ma� z�porn� hodnotu.
  rs_e_181 = 'Chyba d�t pre pr�kaz FTGETPRN';
  rs_e_182 = 'Ekasa : nen� nastavena poloha';
  // Pro m�d PORTABLE mus� b�t v�dy nastavena poloha. Popis t�to chyby se z�rove� vytiskne.
  rs_e_183 = 'Neplatn� PIN pre n�vrat na kartu' + #13#10 +
    'Jedn� sa o PIN obsluhy (ne PIN karty)';
  rs_e_184 = 'Neplatn� doklad nesmie obsahova+t ID z�kazn�ka';
  rs_e_185 = 'Nie je mo�n� uzavrie� predajn� doklad bez polo�iek';
  rs_e_186 = 'Chyba z�avy na polo�ku' + #13#10 +
    'Nie je v rovnakej DPH ako polo�ka alebo m� vy��iu �iastku ako polo�ka,' +
    #13#10 + 'alebo nie je mo�n� zada� z�avu na polo�ku na doklad bez polo�iek';
  rs_e_187 = 'Reklama (reklamn� sekvencia) nen�jden�';
  // (jak�koliv operace nad reklamn� sekvenc�, kter� nebyla p�edem definov�na, nebo v�bec neexistuje)
  rs_e_188 = 'Neexistuje �iadna reklama'; // (my�leno reklamn� kampa�)
  rs_e_189 = 'Reklamn� sekvencia je pr�zdna';
  // (pokus o spu�t�n� reklamn� sekvence, kter� je�t� neobsahuje ��dn� sn�mky)
  rs_e_190 =
    'Chyba vstupn�ch parametrov pre dan� pr�kaz vz�ahuj�ci sa k reklam�m';
  // (nap�. vstupy pro definici text�, sn�mk� apod.)
  rs_e_191 = 'Default chyba ma�arsk�ho fisk�lu, default chyba rumunsk�ho UPOSu';
  rs_e_192 = 'Chyba licencie zaokr�hlenia';
  // "Od verzie fw: 64.384 (VX) od 72.114(TX) podpora aj pre Android"
  rs_e_x = '��slo chyby %d nezadokumentovan� chyba';

  rs_e_except = 'Chyba pri vykon�van� pr�kazu.'#13;
  rs_e_paramsin = 'Nespr�vne vstupn� parametre.';
  rs_e_paramsout = 'Nespr�vne v�stupn� parametre.';
  rs_e_noactive = 'Komunika�n� port nie je akt�vny.';
  rs_e_timeout = 'V pr�slu�nom �ase nedo�la odpove� z FM.';
  rs_e_checksum = 'Chyba kontroln�ho s��tu paketu.';
  rs_e_packetno = 'Chyba v ��sle paketu.';
  rs_e_identif = 'Chybn� identifik�tor paketu.';
  rs_e_errcode = 'Chyba pri dek�dovan� indikovanej chyby FM.';
  rs_e_testlink = 'Prenosov� linka nie je pripravena na komunik�ciu s FM';

  rs_errormsg = 'Chyba: %d' + #13#10 + '%s';
  rs_chybakomunikaciefm = 'Chyba komunik�cie s fisk�lnym modulom!';

const
  { error code ecr }
  ec_000 = 0;
  // chyby v samotne dll
  C_ERR_EXCEPT = -1; // vyjimka pri vykonavani prikazu
  C_ERR_PARAMSIN = -2; // nespravne vstupni parametry
  C_ERR_PARAMSOUT = -3; // nespravne vystupni parametry
  C_ERR_NOACTIVE = -4; // port neni aktivni
  C_ERR_TIMEOUT = -5; // v nastavenem case nedosla odpoved
  C_ERR_CHECKSUM = -6; // chyba kontrolniho souctu
  C_ERR_PACKETNO = -7; // chyba v cisle paketu
  C_ERR_IDENTIF = -8; // chybny identifikator
  C_ERR_ERRCODE = -9; // chyba pri dekodovani chyby
  C_ERR_TESTLINK = -10; // chyba pri testovani klidu na lincee

  C_LEN_BUFF = 1024;
  C_DATA_IDX = 2;

  C_SALES = '0'; // predajn� doklad
  C_REFUND = '1'; // storno predajn�ho dokladu
  C_RETURN = '2'; // n�vrat
  C_INVOICE = '10'; // �hrada fakt�ry
  C_INVOICE_CANCEL = '11'; // storno �hrady fakt�ry
  C_CASH_IN = '20'; // vlo�enie pe�az�
  C_CASH_OUT = '21'; // v�ber pe�az�
  C_NOFISCAL = '30'; // nefisk�lny doklad

  C_PAY_INVOICE = '�hrada fakt�ry';
  C_PAY_CASH = 'Hotovos�';
  C_PAY_CARD = 'Platobn� karty';
  C_PAY_CHECK = 'Pouk�ka';
  C_PAY_EXPENSE = 'Vr�ti�';

  C_PAY_CASH_IDX = '1';
  C_PAY_CARD_IDX = '2';
  C_PAY_CHECK_IDX = '3';

  C_RCODE_3 = 3; // FM error nebo funkci nelze prov�st
  C_RCODE_6 = 6; // OK
  C_RCODE_17 = 17; // Platba kartou akceptov�na
  C_RCODE_18 = 18; // Platba kartou zam�tnuta
  C_RCODE_192 = 192; // Nepovolena hodnota zaokruhlenia dokladu
  C_IMP_NR = '3719'; // ID implementace

type
  TInternalBuffer = array [0 .. C_LEN_BUFF - 1] of byte;

  TConnectType = (ctNone, ctCom, ctTcp);

  TFiskalPro = class
  private
    fCom: TAfComPort;
    fTcp: TIdTCPClient;
    fIntBuf: TInternalBuffer;
    fRecvCount: integer;
    fUid: string;
    fConnectType: TConnectType;
    function getReady(): boolean;
    function LRC(var basePacket: TInternalBuffer; Count: integer): byte;
  public
    constructor Create();
    destructor Destroy; override;
    function execCommand(cmd: string; buf: PAnsiChar; Count: integer;
      timeOutTime: cardinal): integer;
    function beginReceipt(receiptType: string): integer; overload;
    function beginReceipt(receiptType, guid: string): integer; overload;
    function beginReceipt(receiptType, guid, impNr: string): integer; overload;
    function endReceipt(): integer;
    function getUid: string;
    procedure ReadRecvData(buf: PAnsiChar);
    property RecvCount: integer read fRecvCount;
    property Ready: boolean read getReady;

    // COM/USB interface
    function _OpenCom(comNumber: integer): integer;
    function _CloseCom(): integer;
    // TCP interface
    function _ConnectTcp(host: string; const port: word = 6090): integer;
    function _DisconnectTcp(): integer;

    function _Receiptcopy(): integer;
    function _ZReport(): integer;
    function _XReport(): integer;
    function _Report(reporttype, startpoint, endpoint: string): integer;

    function _Cashin(value_2, text: string): integer;
    function _Cashout(value_2, text: string): integer;
    function _Invoice(value_2, text: string): integer;
    function _InvoiceCancel(value_2, text: string): integer;

    function _Sale(quantity_3, price_2, deptno, name, unit_name: string)
      : integer; overload;
    function _Sale(quantity_3, price_2, deptno, name, unit_name, ref, s_reg,
      item_t, unit_price: string): integer; overload;

    function _Discount(value_2, text, vat_idx: string): integer;
    function _Surcharge(value_2, text, vat_idx: string): integer;

    function _Total(value_2: string): integer;
    function _Payment(paymentType, value_2: string; rounding_2: string)
      : integer;
    function _CashExpense(value_2: string): integer;

    function _Header(text: string): integer;
    function _Footer(footer_idx, text: string): integer;
    function _Display(display_idx, text: string): integer;

    function _Settings(settings: PAnsiChar): integer;
    function _Status(status: PAnsiChar): integer;

    function _Errortext(errcode: integer; errtext: PAnsiChar): integer;

    // Nativny protokol FiskalPro
    // 1.Prikazova sada
    // 1.1 Nastavenie fiskalnej aplikacie
    function FSMODE(data: PAnsiChar): integer;
    // zmena fisk�lneho m�du fisk�lnej aplik�cie
    function FSVAT(data: PAnsiChar): integer; // zmena nastavenia hlad�n DPH
    function FSPAY(data: PAnsiChar): integer; // zmena nastavenia typov platieb
    function FSDPK(data: PAnsiChar): integer; // nastavenie DKP ��sla
    function FRDPK(data: PAnsiChar): integer; // ��tanie DKP ��sla
    function FSBON(data: PAnsiChar): integer; // zmena nastavenia hlavi�ky bonu
    function FRBON(line: byte; data: PAnsiChar): integer;
    // ��tanie nastavenia hlavi�ky bonu
    function FSRTC(data: PAnsiChar): integer; // zmena nastavenia d�tumu a �asu
    function FRRTC(data: PAnsiChar): integer; // ��tanie d�tumu a �asu
    function FRSTAT(data: PAnsiChar): integer; // stav fisk�lnej aplik�cie
    function FRZDATA(number: integer; data: PAnsiChar): integer;
    // ��tanie d�t uz�vierky
    function FRSER(event: byte; data: PAnsiChar): integer;
    // ��tanie servisn�ch eventov
    function FSRES(data: PAnsiChar): integer; // reset �dr�by
    function FSSCRIPTSTART(): integer; // spustenie skriptu pre fiskaliz�ciu
    function FSSCRIPTEND(): integer; // ukon�enie skriptu pre fiskaliz�ciu
    function FRINFO(data: PAnsiChar): integer;
    // inform�cie o nastaven� fisk�lnej aplik�cie
    function FTFISSTATE(data: PAnsiChar): integer; // status fisk�lna aplik�cia
    function FRDEVINFO(data: PAnsiChar): integer;
    // status termin�lu a fisk�lnej pam�te
    function FTERRUID(data: PAnsiChar): integer; // UID chybneho dokladu
    function FTEKASASTATE(data: PAnsiChar): integer; // informacie statusu
    // 1.2 Doklady
    function FTUID(data: PAnsiChar): integer; // identifik�tor dokladu/platby
    function FTCLUID(data: PAnsiChar): integer;
    // identifik�tor origin�lneho dokladu
    function FTOPEN(data: PAnsiChar): integer; // otvorenie transakcie
    function FTHEAD(data: PAnsiChar): integer; // tla� vo�n�ho textu hlavi�ky
    function FTDOCNR(data: PAnsiChar): integer; // extern� ��slo dokladu
    function FTDOCBR(data: PAnsiChar): integer; // ��slo fili�lky pro dokladu
    function FTDOCPO(data: PAnsiChar): integer; // ��slo pokladne pro dokladu
    function FTDOCCA(data: PAnsiChar): integer;
    // ��slo pokladni�n�ho pro dokladu
    function FTEXT(data: PAnsiChar): integer; // tla� vo�n�ho textu
    function FITEM(data: PAnsiChar): integer; // tla� polo�ky dokladu
    function FIDIS(data: PAnsiChar): integer; // z�ava polo�ky
    function FSUBA(data: PAnsiChar): integer; // medzis��et dokladu
    function FDDIS(data: PAnsiChar): integer; // z�ava na doklad
    function FTOTA(data: PAnsiChar): integer; // suma dokladu
    function FPAY(data: PAnsiChar): integer; // platba
    function FTFOOTER(data: PAnsiChar): integer; // p�ti�ka dokladu
    function FTCLOSE(data: PAnsiChar): integer; // uzavretie transakcie
    function FTPAYINFO(data: PAnsiChar): integer;
    // pr�kaz na pre��tanie inform�ci� o platbe kartou
    function FTDOCFISINFO(data: PAnsiChar): integer; // fisk�lne ��slo dokladu
    function FTDOCINFO(data: PAnsiChar): integer;
    // inform�cia o aktu�lnom doklade
    function FTVATINFO(data: PAnsiChar): integer;
    // hodnoty DPH aktu�lneho dokladu
    function FDCOPY(): integer; // opakovan� tla� dokladu
    function FTCARDPAY(uid: string; data: PAnsiChar): integer;
    // status platby kartou pre doklad
    function FITEMO(data: PAnsiChar): integer;
    // identifikator povodneho dokladu pre strono/navrat polozky "ReferenceReceiptId"
    function FITEMG(data: PAnsiChar): integer;
    // priznak specifikuje dovod priradenia DPH0 "SpecialRegulation"
    function FITEMH(data: PAnsiChar): integer; // typ polozky dokladu "ItemType"
    function FTCUSTOMER(data: PAnsiChar): integer;
    // identifikacia zakaznika "CustomerId"
    function FTCUSTID(data: PAnsiChar): integer;
    // typ identifikacie zakaznika "CustomerIdType"
    function FTEKASADICVALUE(data: PAnsiChar): integer;
    // identifikacia pre predaj v zastupeni "SellerId" !!! PRIKAZ AKTUALNE NIE JE IMPLEMENTOVANY !!!
    function FTEKASADICID(data: PAnsiChar): integer;
    // typ identifikacie pre predaj v zastupeni "SellerIdType" !!! PRIKAZ AKTUALNE NIE JE IMPLEMENTOVANY !!!
    function FTEKASADOCNR(data: PAnsiChar): integer;
    // cislo paragonu, pre dodatocne zadane doklady "ParagonNumber"
    function FTEKASADOCDT(data: PAnsiChar): integer;
    // datum paragonu "IssueDate"
    function FTREFNR(data: PAnsiChar): integer; // referencne cislo dokladu
    function FTEKASAEMAIL(data: PAnsiChar): integer;
    // emailov� adresa pre odoslanie dokladu emailom
    function FTEKASASENDCMD(data: PAnsiChar): integer;
    // nastav� p��kaz pro odesl�n� offline fronty po online dokladu
    // 1.3 Reporty
    function FXREP(data: PAnsiChar): integer; // XReport
    function FZREP(): integer; // ZReport
    function FTREPVATINFO(data: PAnsiChar): integer; // hodnoty DPH pre report
    // 1.4 Ostatn�
    function FDISP(data: PAnsiChar): integer; // odosielanie textu na displej
    function FTSIGNAL(data: PAnsiChar): integer;
    // pr�kaz na otvorenie pokladni�nej z�suvky
    function FSGPS(data: PAnsiChar): integer;
    // nastavenie GPS/Adresy/SPZ "Location"
    function FXEKASAPRNERR(data: PAnsiChar): integer;
    // tlac neodoslanych datovych sprav
    function FSEKASASEND(): integer; // odoslanie neodoslanych sprav na SFS
    // 1.5 Platba kartou
    function FTCARDSTART(data: PAnsiChar): integer;
    // spust� vlastn� platbu kartou
    function FTCARDINFO(data: PAnsiChar): integer; // status platby kartou
    function FXBAREP(): integer; // mezisou�et banky
    function FZBAREP(): integer; // uzavierka banky
    function FRCARDRETINFO(): integer; // status pre n�vrat
    function FTCARDCANCELLAST(data: PAnsiChar): integer;
    // storno posledn� transakce
    // 1.6 Zaokruhlovanie
    function FTDOCROUND(data: PAnsiChar): integer;
    function FPAYD(data: PAnsiChar): integer;
    function FSIMPNR(data: PAnsiChar): integer;
  end;

function bufToHexaStr(buffer: TInternalBuffer; bufferLength: integer): string;

var
  fFiskalPro: TFiskalPro = nil;
  fExceptStr: string = '';

implementation

{ TFiskalPro }

constructor TFiskalPro.Create();
begin
  inherited;
  fConnectType := ctNone;
end;

destructor TFiskalPro.Destroy;
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

function TFiskalPro.getUid: string;
var
  uid: TGuid;
begin
  result := '';
  if CreateGuid(uid) = S_OK then
  begin
    result := GuidToString(uid);
    result := StringReplace(result, '{', '', [rfReplaceAll]);
    result := StringReplace(result, '}', '', [rfReplaceAll]);
  end;
end;

function TFiskalPro.getReady(): boolean;
begin
  case fConnectType of
    ctCom:
      result := (Assigned(fCom) and fCom.Active);
    ctTcp:
      result := (Assigned(fTcp) and fTcp.Connected);
  else
    result := false;
  end;
end;

function TFiskalPro.LRC(var basePacket: TInternalBuffer; Count: integer): byte;
var
  i: integer;
begin
  // LRC sa pocita len z <data> basePacket uz obsahuje <Startovaci znak1>, <Startovaci znak2>,
  // <Dlzka 1>, <Dlzka 2>
  result := 0;
  for i := 4 to Count - 1 do
    result := result xor basePacket[i];
end;

function TFiskalPro.beginReceipt(receiptType: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      fUid := getUid();

      result := fFiskalPro.execCommand('FTUID', PAnsiChar(AnsiString(fUid)),
        Length(fUid), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOPEN',
        PAnsiChar(AnsiString(receiptType)), Length(receiptType), 3500);

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

function TFiskalPro.beginReceipt(receiptType, guid: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := fFiskalPro.execCommand('FTUID', PAnsiChar(AnsiString(guid)),
        Length(guid), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOPEN',
        PAnsiChar(AnsiString(receiptType)), Length(receiptType), 3500);

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

function TFiskalPro.beginReceipt(receiptType, guid, impNr: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := fFiskalPro.execCommand('FTUID', PAnsiChar(AnsiString(guid)),
        Length(guid), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOPEN',
        PAnsiChar(AnsiString(receiptType)), Length(receiptType), 3500);

      fFiskalPro.execCommand('FSIMPNR', PAnsiChar(AnsiString(impNr)),
        Length(impNr), 3500);

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

function TFiskalPro.endReceipt(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCLOSE', PAnsiChar(AnsiString('')
        ), 0, 20000)
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

function TFiskalPro.execCommand(cmd: string; buf: PAnsiChar; Count: integer;
  timeOutTime: cardinal): integer;
var
  fPacket: TInternalBuffer;
  iPos, iCnt: integer;
  pocetCteni: integer;
  stopTime: cardinal;
  recvWait: integer;
  // ^ -1 cekame, 0 prijem ok, 1 TimeOut (ale muze to byt v poradku)
  i: integer;
  p: pointer;
  cSum: byte;
  dataLength: integer;
  fBBuffer: TBytes;
  str: string;
begin
  FillChar(fPacket, SizeOf(fPacket), 0);

  iPos := 0;
  // <Startovaci znak 1> = 1
  fPacket[iPos] := 1;
  Inc(iPos);
  // <Startovaci znak 2> = 1
  fPacket[iPos] := 1;
  Inc(iPos);

  dataLength := Length(cmd) + Count;
  // <Dlzka 1> = Data.length / 256
  fPacket[iPos] := (dataLength div 256);
  Inc(iPos);
  // <Dlzka 2> = Data.length % 256
  fPacket[iPos] := dataLength - (256 * fPacket[iPos - 1]);
  Inc(iPos);

  // <Data.cmd>
  if Length(cmd) > 0 then
  begin
    for i := 0 to Length(cmd) - 1 do
    begin
      fPacket[iPos] := ord(cmd[i + 1]);
      Inc(iPos);
    end;
  end;

  // <Data.buf>
  if Count > 0 then
  begin
    Move(buf^, fPacket[iPos], Count);
    Inc(iPos, Count);
  end;

  // <LRC> = LRC pre Data
  fPacket[iPos] := LRC(fPacket, iPos);
  Inc(iPos);
  // log - request
  if fSettings.B['ekasa.withLog'] then
  begin
    SetString(str, PAnsiChar(@buf[0]), Count);
    addLog('Out : ''' + cmd + str + '''');
    addLog('Out Hexa : ' + bufToHexaStr(fPacket, iPos));
  end;

  iCnt := 0;
  recvWait := -1;
  if (fConnectType = ctCom) then
  begin
    // Vyprazdnime
    // Teoreticky by se mohlo stat, ze to muzeme cist do nekonecna,
    // ale pokud je na lince takovy chaos, pak nema smysl se pokouset
    // o nejake rizene spojeni...
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

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    fRecvCount := 0;
    FillChar(fIntBuf, SizeOf(fIntBuf), 0);
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // Odesleme
    Sleep(100);
    fCom.WriteData(fPacket[0], iPos + 1);

    // Pripravime prijem
    recvWait := -1;
    iPos := 0;
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
            // Odpoved je vo formate
            // <Dlzka 1><Dlzka 2><Kod><LRC> - odpoved bez dat
            // alebo
            // <Dlzka 1><Dlzka 2><Data><Kod><LRC> - odpoved iba z navratovym kodom
            // 256 * <Dlzka 1> + <Dlzka 2> = <Data.Length>
            dataLength := 256 * fPacket[0] + fPacket[1];
            if (iCnt = (dataLength + 2 + 1)) then
            begin // 2= dlzka1 + dlzka2; 1=LRC
              recvWait := 0;
              Break;
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
          Break;
      end
      else
        Break;
      Dec(pocetCteni);
    until (pocetCteni <= 0);
  end;

  if (fConnectType = ctTcp) then
  begin

    // Pripravime buffer na odoslanie
    SetLength(fBBuffer, iPos);
    for i := 0 to iPos - 1 do
      fBBuffer[i] := fPacket[i];

    // Odosleme buffer
    fTcp.IOHandler.Write(TIdBytes(fBBuffer));

    // Pripravime buffer na prijem
    recvWait := -1;
    fRecvCount := 0;
    stopTime := GetTickCount;
    if (timeOutTime > 0) then
      stopTime := stopTime + timeOutTime;
    SetLength(fBBuffer, 0);
    fTcp.ReadTimeout := timeOutTime;

    repeat
      // Citanie odpovede do buffra
      fTcp.IOHandler.ReadBytes(TIdBytes(fBBuffer), -1);

      FillChar(fPacket, SizeOf(fPacket), 0);
      for i := 0 to Length(fBBuffer) - 1 do
        fPacket[i] := fBBuffer[i];

      fRecvCount := Length(fBBuffer);
      iCnt := fRecvCount;

      // kontrola na prijem celeho paketu
      cSum := 0;
      for i := 2 to iCnt - 2 do
        cSum := cSum xor fPacket[i];
      if (cSum = fPacket[iCnt - 1]) then
        recvWait := 0;

      if (recvWait < 0) and (stopTime < GetTickCount) then
        recvWait := 1; // timeOut odchod z tadeto

    until (recvWait >= 0);

  end;

  if (recvWait = 0) then
  begin
    // Kontroly
    cSum := 0;
    for i := 2 to iCnt - 2 do
      cSum := cSum xor fPacket[i];
    // na LRC
    if cSum <> fPacket[iCnt - 1] then
      result := C_ERR_CHECKSUM
    else
    begin
      fRecvCount := iCnt - C_DATA_IDX - 1; // 1= LRC
      Move(fPacket[C_DATA_IDX], fIntBuf[0], fRecvCount);
      if fSettings.B['ekasa.withLog'] then
        addLog('In Hexa : ' + bufToHexaStr(fPacket, fRecvCount + 3));
      if (iCnt = 4) then
      begin // odpoved bez dat - <Dlzka 1><Dlzka 2><Kod><LRC>
        result := fIntBuf[0];
        if fSettings.B['ekasa.withLog'] then
          addLog('In : --');
      end
      else
      begin // odpoved s datami - <Dlzka 1><Dlzka 2><Kod><LRC>
        result := C_RCODE_6;
        SetString(str, PAnsiChar(@fPacket[0]), fRecvCount + C_DATA_IDX + 1);
        if fSettings.B['ekasa.withLog'] then
          addLog('In : ' + Copy(str, 3, Length(str) - 3));
      end;
    end;
  end
  else
  begin
    result := C_ERR_TIMEOUT;
    if fSettings.B['ekasa.withLog'] then
      addLog('TimeOut - ERROR');
  end;
end;

procedure TFiskalPro.ReadRecvData(buf: PAnsiChar);
begin
  if Assigned(buf) and (fRecvCount > 0) then
    Move(fIntBuf[0], buf^, fRecvCount);
end;

function TFiskalPro._OpenCom(comNumber: integer): integer;
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
      result := C_RCODE_6;
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

function TFiskalPro._CloseCom(): integer;
begin
  result := C_RCODE_6;
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

function TFiskalPro._ConnectTcp(host: string; const port: word): integer;

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
    portIp := StrToIntDef(hostIp, 6090);
  end;

  if (isWrongIP(host)) then
  begin
    fTcp := TIdTCPClient.Create(nil);
    fTcp.host := host;
    fTcp.port := portIp;
    fTcp.ConnectTimeout := 10000;
    try
      fTcp.Connect();
      fConnectType := ctTcp;
      result := C_RCODE_6;
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

function TFiskalPro._DisconnectTcp(): integer;
begin
  result := C_RCODE_6;
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

function TFiskalPro._Receiptcopy(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FDCOPY', PAnsiChar(AnsiString('')
        ), 0, 20000)
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

function TFiskalPro._ZReport(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FZREP', PAnsiChar(AnsiString('')
        ), 0, 12500)
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

function TFiskalPro._XReport(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FXREPF', PAnsiChar(AnsiString('')
        ), 0, 12500)
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

function TFiskalPro._Report(reporttype, startpoint, endpoint: string): integer;
begin
  result := C_RCODE_6;
  try
    if fFiskalPro.Ready then
    begin
      if (reporttype = 'I') then
      begin
        result := fFiskalPro.execCommand('FXREPF',
          PAnsiChar(AnsiString(startpoint)), Length(startpoint), 12500);
        if result <> C_RCODE_6 then
          exit;
        result := fFiskalPro.execCommand('FXREPT',
          PAnsiChar(AnsiString(endpoint)), Length(endpoint), 12500);
      end;
      if (reporttype = 'D') then
      begin
        result := fFiskalPro.execCommand('FXREPDF',
          PAnsiChar(AnsiString(startpoint)), Length(startpoint), 12500);
        if result <> C_RCODE_6 then
          exit;
        result := fFiskalPro.execCommand('FXREPDT',
          PAnsiChar(AnsiString(endpoint)), Length(endpoint), 12500);
      end;
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

var
  err_str: string;

function TFiskalPro._Cashin(value_2, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := beginReceipt(C_CASH_IN);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTEXT', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYR', PAnsiChar(AnsiString(C_PAY_CASH)
        ), Length(C_PAY_CASH), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYI', PAnsiChar(AnsiString('1')),
        Length('1'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := endReceipt();

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

function TFiskalPro._Cashout(value_2, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := beginReceipt(C_CASH_OUT);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTEXT', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYR', PAnsiChar(AnsiString(C_PAY_CASH)
        ), Length(C_PAY_CASH), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYI', PAnsiChar(AnsiString('1')),
        Length('1'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := endReceipt();

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

function TFiskalPro._Invoice(value_2, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := beginReceipt(C_INVOICE);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMT',
        PAnsiChar(AnsiString(C_PAY_INVOICE)), Length(C_PAY_INVOICE), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMV', PAnsiChar(AnsiString('5')),
        Length('5'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTEXT', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYR', PAnsiChar(AnsiString(C_PAY_CASH)
        ), Length(C_PAY_CASH), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYI', PAnsiChar(AnsiString('1')),
        Length('1'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := endReceipt();

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

function TFiskalPro._InvoiceCancel(value_2, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      result := beginReceipt(C_INVOICE_CANCEL);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMT',
        PAnsiChar(AnsiString(C_PAY_INVOICE)), Length(C_PAY_INVOICE), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FITEMV', PAnsiChar(AnsiString('5')),
        Length('5'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTEXT', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYR', PAnsiChar(AnsiString(C_PAY_CASH)
        ), Length(C_PAY_CASH), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYI', PAnsiChar(AnsiString('1')),
        Length('1'), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := fFiskalPro.execCommand('FPAYA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;

      result := endReceipt();

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

function TFiskalPro._Sale(quantity_3, price_2, deptno, name,
  unit_name: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      // Celkov� cena polo�ky s DPH [%10.2f]
      result := fFiskalPro.execCommand('FITEMA', PAnsiChar(AnsiString(price_2)),
        Length(price_2), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // 0-Predaj, 1-Storno [0-1]
        result := fFiskalPro.execCommand('FITEMC', PAnsiChar(AnsiString()), Length(), 3500);
      *)
      // Text artiklu [%60s]
      result := fFiskalPro.execCommand('FITEMT', PAnsiChar(AnsiString(name)),
        Length(name), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Mno�stvo artiklu [%19.3f]
      result := fFiskalPro.execCommand('FITEMQ',
        PAnsiChar(AnsiString(quantity_3)), Length(quantity_3), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // Jednotkov� cena s DPH [%10.2f]
        result := fFiskalPro.execCommand('FITEMP', PAnsiChar(AnsiString(C_PAY_INVOICE)), Length(C_PAY_INVOICE), 3500);
        if result <> C_RCODE_6 then exit;
      *)
      // Mern� jednotky [%9s]
      result := fFiskalPro.execCommand('FITEMU', PAnsiChar(AnsiString(unit_name)
        ), Length(unit_name), 3500);
      if result <> C_RCODE_6 then
        exit;

      // TODO - toto musi poslednym volanym prikazom FITEM
      // Index DPH [1-5]
      result := fFiskalPro.execCommand('FITEMV', PAnsiChar(AnsiString(deptno)),
        Length(deptno), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // 1=NETTO, teda polo�ka na ktor� nem��e by� poskytnut� alebo dokladov� z�ava (napr�klad obaly) [0-1]
        result := fFiskalPro.execCommand('FITEMN', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // ��slo tovaru [%24s]
        result := fFiskalPro.execCommand('FITEMI', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // �iarov� k�d artiklu [%50s]
        result := fFiskalPro.execCommand('FITEMB', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // S�riov� ��slo artiklu [%40s]
        result := fFiskalPro.execCommand('FITEMS', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;
      *)
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

function TFiskalPro._Sale(quantity_3, price_2, deptno, name, unit_name, ref,
  s_reg, item_t, unit_price: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin

      // Celkov� cena polo�ky s DPH [%10.2f]
      result := fFiskalPro.execCommand('FITEMA', PAnsiChar(AnsiString(price_2)),
        Length(price_2), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // 0-Predaj, 1-Storno [0-1]
        result := fFiskalPro.execCommand('FITEMC', PAnsiChar(AnsiString()), Length(), 3500);
      *)
      // Text artiklu [%60s]
      result := fFiskalPro.execCommand('FITEMT', PAnsiChar(AnsiString(name)),
        Length(name), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Mno�stvo artiklu [%19.3f]
      result := fFiskalPro.execCommand('FITEMQ',
        PAnsiChar(AnsiString(quantity_3)), Length(quantity_3), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Jednotkov� cena s DPH [%10.3f] od verzie 64.300 podpora tisku jednotkov� ceny na 3 desetinn� m�sta
      result := fFiskalPro.execCommand('FITEMP',
        PAnsiChar(AnsiString(unit_price)), Length(unit_price), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Mern� jednotky [%9s]
      result := fFiskalPro.execCommand('FITEMU', PAnsiChar(AnsiString(unit_name)
        ), Length(unit_name), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Typ polo�ky [%8s]
      result := fFiskalPro.execCommand('FITEMH', PAnsiChar(AnsiString(item_t)),
        Length(item_t), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Identifik�tor p�vodn�ho dokladu pre storno/n�vrat polo�ky [%44s]
      if ((item_t = 'V') or (item_t = 'O')) then
      begin
        result := fFiskalPro.execCommand('FITEMO', PAnsiChar(AnsiString(ref)),
          Length(ref), 3500);
        if result <> C_RCODE_6 then
          exit;
      end;

      // Special regulation - priznak �pecifikuje d�vod priradenia 0% sadzby dane  [%8s]
      if (s_reg <> '') then
      begin
        result := fFiskalPro.execCommand('FITEMG', PAnsiChar(AnsiString(s_reg)),
          Length(s_reg), 3500);
        if result <> C_RCODE_6 then
          exit;
      end;

      // TODO - toto musi poslednym volanym prikazom FITEM
      // Index DPH [1-5]
      result := fFiskalPro.execCommand('FITEMV', PAnsiChar(AnsiString(deptno)),
        Length(deptno), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // 1=NETTO, teda polo�ka na ktor� nem��e by� poskytnut� alebo dokladov� z�ava (napr�klad obaly) [0-1]
        result := fFiskalPro.execCommand('FITEMN', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // ��slo tovaru [%24s]
        result := fFiskalPro.execCommand('FITEMI', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // �iarov� k�d artiklu [%50s]
        result := fFiskalPro.execCommand('FITEMB', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;

        // S�riov� ��slo artiklu [%40s]
        result := fFiskalPro.execCommand('FITEMS', PAnsiChar(AnsiString()), Length(), 3500);
        if result <> C_RCODE_6 then exit;
      *)
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

function TFiskalPro._Discount(value_2, text, vat_idx: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      // Hodnota z�avy
      result := fFiskalPro.execCommand('FIDISA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;
      // Text
      result := fFiskalPro.execCommand('FIDIST', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;
      // V�zba na DPH
      result := fFiskalPro.execCommand('FIDISV', PAnsiChar(AnsiString(vat_idx)),
        Length(vat_idx), 3500);
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

function TFiskalPro._Surcharge(value_2, text, vat_idx: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      // Hodnota prir�ky
      result := fFiskalPro.execCommand('FIDISA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);
      if result <> C_RCODE_6 then
        exit;
      // Text
      result := fFiskalPro.execCommand('FIDIST', PAnsiChar(AnsiString(text)),
        Length(text), 3500);
      if result <> C_RCODE_6 then
        exit;
      // V�zba na DPH
      result := fFiskalPro.execCommand('FIDISV', PAnsiChar(AnsiString(vat_idx)),
        Length(vat_idx), 3500);
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

function TFiskalPro._Total(value_2: string): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      // Suma dokladu [%10.2f] (len pre typy dokladov 0,1,2,10,11,20,21)
      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(value_2)),
        Length(value_2), 3500);

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

function TFiskalPro._Payment(paymentType, value_2: string;
  rounding_2: string): integer;
var
  data: string;
begin
  try
    if fFiskalPro.Ready then
    begin

      // Referencie [%40s]
      if paymentType = C_PAY_CASH_IDX then
        data := C_PAY_CASH;
      if paymentType = C_PAY_CARD_IDX then
        data := C_PAY_CARD;
      if paymentType = C_PAY_CHECK_IDX then
        data := C_PAY_CHECK;

      data := 'R' + data;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Index typu platby [%2d]
      data := 'I' + paymentType;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Hodnota zaokruhlenia platby hotovostou
      if (paymentType = C_PAY_CASH_IDX) and (rounding_2 <> '') then
      begin
        data := 'D' + rounding_2;
        result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
          Length(data), 3500);
        if result <> C_RCODE_6 then
          exit;
      end;

      // 0 � �hrada, 1 � vr�tenie pe�az� (preplatok) [0-1]
      data := 'B0';
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Hodnota dokladu napo��tan� riadiacou aplik�ciou [%10.2f]
      data := 'A' + value_2;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      (*
        // Referencie pre platbu kartou [%19s]
        result := fFiskalPro.execCommand('FPAYC', PAnsiChar(AnsiString('VS123')), Length('VS123'), 3500);
        if result <> C_RCODE_6 then exit;

        // Koniec platieb dokladu
        result := fFiskalPro.execCommand('FPAYE', PAnsiChar(AnsiString('')), Length(''), 3500);
      *)
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

function TFiskalPro._CashExpense(value_2: string): integer;
var
  data: string;
begin
  try
    if fFiskalPro.Ready then
    begin

      // Referencie [%40s]
      data := 'R' + C_PAY_EXPENSE;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Index typu platby [%2d]
      data := 'I' + C_PAY_CASH_IDX;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;
      (*
        // Hodnota zaokruhlenia platby hotovostou
        if (paymentType = C_PAY_CASH_IDX) and (rounding_2 <> '') then begin
        data := 'D' + rounding_2;
        result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)), Length(data), 3500);
        if result <> C_RCODE_6 then exit;
        end;
      *)
      // 0 � �hrada, 1 � vr�tenie pe�az� (preplatok) [0-1]
      data := 'B1';
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      // Hodnota dokladu napo��tan� riadiacou aplik�ciou [%10.2f]
      data := 'A' + value_2;
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result <> C_RCODE_6 then
        exit;

      (*
        // Referencie pre platbu kartou [%19s]
        result := fFiskalPro.execCommand('FPAYC', PAnsiChar(AnsiString('VS123')), Length('VS123'), 3500);
        if result <> C_RCODE_6 then exit;

        // Koniec platieb dokladu
        result := fFiskalPro.execCommand('FPAYE', PAnsiChar(AnsiString('')), Length(''), 3500);
      *)
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

function TFiskalPro._Header(text: string): integer;
begin
  try
    if fFiskalPro.Ready then
      // Text hlavi�ky dokladu
      result := fFiskalPro.execCommand('FTHEAD', PAnsiChar(AnsiString(text)),
        Length(text), 3500)
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

function TFiskalPro._Footer(footer_idx, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
      // Text p�ti�ky dokladu
      result := fFiskalPro.execCommand('FTFOOTER' + footer_idx,
        PAnsiChar(AnsiString(text)), Length(text), 3500)
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

function TFiskalPro._Display(display_idx, text: string): integer;
begin
  try
    if fFiskalPro.Ready then
      // Text p�ti�ky dokladu
      result := fFiskalPro.execCommand('FDISP' + display_idx,
        PAnsiChar(AnsiString(text)), Length(text), 3500)
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

function TFiskalPro._Settings(settings: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      // Status fiskalna aplikacia
      result := fFiskalPro.execCommand('FRINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = ec_000 then
        fFiskalPro.ReadRecvData(PAnsiChar(settings));

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

function TFiskalPro._Status(status: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      // Status fiskalna aplikacia
      result := fFiskalPro.execCommand('FRINFO', PAnsiChar(AnsiString('')), 0,
        3500); { FTFISSTATE }
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(status));
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

function TFiskalPro._Errortext(errcode: integer; errtext: PAnsiChar): integer;
var
  msg: string;
begin
  result := C_RCODE_6;
  if errcode > 0 then
    case errcode of
      1:
        msg := rs_e_01;
      2:
        msg := rs_e_02;
      3:
        msg := rs_e_03;
      4:
        msg := rs_e_04;
      5:
        msg := rs_e_05;
      6:
        msg := rs_e_06;
      7:
        msg := rs_e_07;
      8:
        msg := rs_e_08;
      10:
        msg := rs_e_10;
      11:
        msg := rs_e_11;
      12:
        msg := rs_e_12;
      13:
        msg := rs_e_13;
      14:
        msg := rs_e_14;
      15:
        msg := rs_e_15;
      16:
        msg := rs_e_16;
      17:
        msg := rs_e_17;
      18:
        msg := rs_e_18;
      20:
        msg := rs_e_20;
      27:
        msg := rs_e_27;
      28:
        msg := rs_e_28;
      29:
        msg := rs_e_29;
      36:
        msg := rs_e_36;
      37:
        msg := rs_e_37;
      42:
        msg := rs_e_42;
      43:
        msg := rs_e_43;
      44:
        msg := rs_e_44;
      45:
        msg := rs_e_45;
      46:
        msg := rs_e_46;
      47:
        msg := rs_e_47;
      176:
        msg := rs_e_176;
      177:
        msg := rs_e_177;
      178:
        msg := rs_e_178;
      179:
        msg := rs_e_179;
      180:
        msg := rs_e_180;
      181:
        msg := rs_e_181;
      182:
        msg := rs_e_182;
      183:
        msg := rs_e_183;
      184:
        msg := rs_e_184;
      185:
        msg := rs_e_185;
      186:
        msg := rs_e_186;
      187:
        msg := rs_e_187;
      188:
        msg := rs_e_188;
      189:
        msg := rs_e_189;
      190:
        msg := rs_e_190;
      191:
        msg := rs_e_191;
      192:
        msg := rs_e_192;
    else
      msg := Format(rs_e_x, [errcode]);
    end
  else if errcode < 0 then
    case errcode of
      C_ERR_EXCEPT:
        msg := rs_e_except;
      C_ERR_PARAMSIN:
        msg := rs_e_paramsin;
      C_ERR_PARAMSOUT:
        msg := rs_e_paramsout;
      C_ERR_NOACTIVE:
        msg := rs_e_noactive;
      C_ERR_TIMEOUT:
        msg := rs_e_timeout;
      C_ERR_CHECKSUM:
        msg := rs_e_checksum;
      C_ERR_PACKETNO:
        msg := rs_e_packetno;
      C_ERR_IDENTIF:
        msg := rs_e_identif;
      C_ERR_ERRCODE:
        msg := rs_e_errcode;
      C_ERR_TESTLINK:
        msg := rs_e_testlink;
    else
      msg := Format(rs_e_x, [errcode]);
    end
  else
    msg := '';

  StrCopy(errtext, PAnsiChar(AnsiString(msg)));
end;

function TFiskalPro.FSMODE(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSMODE', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    0 Prechod serializovan�ho m�du
    1 HW master reset
    2 Fiskalizovan�
    4 Stiahnutie aktu�lneho �urn�lu
    6 Zapnutie tr�ningov�ho m�du
    7 Vypnutie tr�ningov�ho m�du
    8 Zapnutie neplatcu DPH
    9 Vypnutie neplatcu DPH
  *)
end;

function TFiskalPro.FSVAT(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSVAT', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    x[%4.2f] x = (1,2,3,4,5)
  *)
end;

function TFiskalPro.FSPAY(data: PAnsiChar): integer;
begin
  result := C_RCODE_6;
end;

function TFiskalPro.FSDPK(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSDKP', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%20s]
  *)
end;

function TFiskalPro.FRDPK(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FRDKP', PAnsiChar(AnsiString(data)),
        Length(data), 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FSBON(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSBON', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    xT [%42s] x = (1..10)
    xF [%1d]  x = (1..10) 0-normalny text, 1-tucne, 2-dvojita sirka
  *)
end;

function TFiskalPro.FRBON(line: byte; data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand(Format('FRBON%dT', [line]),
        PAnsiChar(AnsiString(data)), Length(data), 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FSRTC(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSRTC', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    D,M,Y,H,M,S [%2d] D-den,M-mesiac,Y-rok,H-hodina,M-minuta,S-sekunda
  *)
end;

function TFiskalPro.FRRTC(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FRRTC', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    yyyyMMddhhmmss
  *)
end;

function TFiskalPro.FRSTAT(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FRSTAT', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FRZDATA(number: integer; data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand(Format('FRZDATA%d', [number]),
        PAnsiChar(AnsiString('')), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FRSER(event: byte; data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand(Format('FRSER%d', [event]),
        PAnsiChar(AnsiString('')), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FSRES(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSRES', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
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

function TFiskalPro.FSSCRIPTSTART(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSSCRIPTSTART', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

(*
  FSSCRIPTSTART -> FSVAT -> FSPAY -> FSDPK -> FSBON -> FSSCRIPTEND
*)

function TFiskalPro.FSSCRIPTEND(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSSCRIPTEND', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

function TFiskalPro.FRINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FRINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FTFISSTATE(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTFISSTATE', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FRDEVINFO(data: PAnsiChar): integer;
// status termin�lu a fisk�lnej pam�te
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FRDEVINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FTERRUID(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTERRUID', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data>: %s\%d
    %s	UID chybn�ho dokladu
    %d	��slo chyby EKASA
  *)
end;

function TFiskalPro.FTEKASASTATE(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTEKASASTATE', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data>: %d\%d\%s\%s\%s
    %d  Status ekasy
    0..OK
    2..certifik�t nenalezen
    3..identifika�n� �daje nenalezeny
    4..chyba inicializace (worm pam� je odpojena)
    5..neplatn� certifik�t
    6..blokace z d�vodu chybn�ho dokladu
    7...OK, ale certifik�tu bude kon�it platnost
    8..certifik�tu vypr�ela platnost
    %d	Po�et dn� do konce platnosti certifik�tu
    %s	Datum a �as konce platnosti certifik�tu ve form�tu DD.MM.YYYY HH:mm
    %s	DI� ulo�en� v certifik�tu
    %s	Nastaven� typ (PORTABLE/STANDARD)
  *)
end;

function TFiskalPro.FTUID(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTUID', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%39s]
  *)
end;

function TFiskalPro.FTCLUID(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCLUID', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%39s]
  *)
end;

function TFiskalPro.FTOPEN(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTOPEN', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%2d] 0-predajny doklad,1-storno predajneho dokladu,2-navrat,10-uhrada faktury
    11-storno uhrady faktury,20-vklad,21-vyber,30-nefiskalny doklad
  *)
end;

function TFiskalPro.FTHEAD(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTHEAD', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%40s]
  *)
end;

function TFiskalPro.FTDOCNR(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTDOCNR', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%32s]
  *)
end;

function TFiskalPro.FTDOCBR(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTDOCBR', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%d]
  *)
end;

function TFiskalPro.FTDOCPO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTDOCPO', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%d]
  *)
end;

function TFiskalPro.FTDOCCA(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTDOCCA', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%d]
  *)
end;

function TFiskalPro.FTEXT(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEXT', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%41s]
  *)
end;

function TFiskalPro.FITEM(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FITEM', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    C [0-predaj,1-storno]
    T [%60s] - text
    Q [%19.3f] - mnozstvo
    P [%10.2f] - jednotkova cena s DPH
    A [%10.2f] - celkova cena polozky s DPH
    V [1..5] - index DPH
    N [0,1] - 1=NETTO,teda polo6ka na ktoru nemoze byt poskytnuta alebo dokladova zlava (naprikald obaly)
    I [%24s] - cislo tovaru
    B [%50s] - ciarovy kod
    S [%40s] - seriova cislo
    U [%9s] - merne jednotky
  *)
end;

function TFiskalPro.FIDIS(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FIDIS', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    T [%60s] - text
    A [%10.2f] - hodnota zlavy
    V [1..5] - index DPH
  *)
end;

function TFiskalPro.FSUBA(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSUBA', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%10.2f] - hodnota dokladu napocitana riadiacou aplikacie
  *)
end;

function TFiskalPro.FDDIS(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FDDIS', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    T [%60s] - text
    A [%10.2f] - hodnota zlavy
  *)
end;

function TFiskalPro.FTOTA(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTOTA', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%10.2f] - hodnota dokladu napocitana riadiacou aplikaciou
  *)
end;

function TFiskalPro.FPAY(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FPAY', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    I [%2d] - index typu platby
    A [%10.2f] - hodnota dokladu napocitana riadiacou aplikaciou
    B [%1d] - 0=uhrada,1=vratenie penazi (preplatok)
    R [%40s] - referencia (napr. VS)
    C [%19s] - referencie pre platbu kartou
    E - koniec platieb
  *)
end;

function TFiskalPro.FTFOOTER(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTFOOTER', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X   yyyy
    1-4 [%s]
  *)
end;

function TFiskalPro.FTCLOSE(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCLOSE', PAnsiChar(AnsiString(data)),
        Length(data), 12500)
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

function TFiskalPro.FTPAYINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTPAYINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri kominikacny protokol
  *)
end;

function TFiskalPro.FTDOCFISINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTDOCFISINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri komunikacny protokol
  *)
end;

function TFiskalPro.FTDOCINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTDOCINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri komunikacny protokol
  *)
end;

function TFiskalPro.FTVATINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTVATINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri kominikacny protokol
  *)
end;

function TFiskalPro.FDCOPY(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FDCOPY', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

function TFiskalPro.FTCARDPAY(uid: string; data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTVATINFO' + uid,
        PAnsiChar(AnsiString('')), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri kominikacny protokol
  *)
end;

function TFiskalPro.FITEMO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FITEMO', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%44s]
  *)
end;

function TFiskalPro.FITEMG(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FITEMG', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%8s] - povolene hodnoty {PDP, OOD, CK, PT, UD, ZPS}
  *)
end;

function TFiskalPro.FITEMH(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FITEMH', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%8s] - povolene hodnoty {K, VO, V, O, Z, OZ, VP}
  *)
end;

function TFiskalPro.FTCUSTOMER(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCUSTOMER', PAnsiChar(AnsiString(data)
        ), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%40s]
  *)
end;

function TFiskalPro.FTCUSTID(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCUSTID', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%10s] - povolene hodnoty {ICO, DIC, IC_DPH, INE}
  *)
end;

function TFiskalPro.FTEKASADICVALUE(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASADICVALUE',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%32s]
  *)
end;

function TFiskalPro.FTEKASADICID(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASADICID',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%d] povolene hodnoty {1 - DI�, 2 - I�DPH}
  *)
end;

function TFiskalPro.FTEKASADOCNR(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASADOCNR',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%16s]
  *)
end;

function TFiskalPro.FTREFNR(data: PAnsiChar): integer;
// Povinn� pre �hradu faktury/storno �hrady faktury pre syst�m EKASA
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTREFNR', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%10s]
  *)
end;

function TFiskalPro.FTEKASADOCDT(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASADOCDT',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%20s] datum vo formate YYYYMMDDHHmm
  *)
end;

function TFiskalPro.FTEKASAEMAIL(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASAEMAIL',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%64s]
  *)
end;

function TFiskalPro.FTEKASASENDCMD(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTEKASASENDCMD',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%32s] podporovane prikazy: FTEKASAGETOKPF, FTEKASAGETOKPC, FTDOCFISINFO, FTDOCINFO, FTGETPRN
    priklad FTEKASASENDCMDFTDOCINFO
  *)
end;

function TFiskalPro.FXREP(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FXREP', PAnsiChar(AnsiString(data)),
        Length(data), 25000)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    F [%8s] - datum/cislo od pre intervalovy XReport
    T [%8s] - datum/cislo do pre intervalovy XReport
    DF [%8s] - datum/cislo od pre detailny XReport
    DT [%8s] - datum/cislo d0 pre detailny XReport
    C [%19s] - referencie pre platbu kartou
    F [bez parametra] - priebehovy XReport
  *)
end;

function TFiskalPro.FZREP(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FZREP', PAnsiChar(AnsiString('')
        ), 0, 25000)
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

function TFiskalPro.FTREPVATINFO(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTREPVATINFO', PAnsiChar(AnsiString('')
        ), 0, 25000);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    <Data> - strukturu pozri kominikacny protokol
  *)
end;

function TFiskalPro.FDISP(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FDISP', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    X  yyyyy..
    R [1,2] - riadok
    T [%20s] - text
  *)
end;

function TFiskalPro.FTSIGNAL(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTSIGNAL', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [0..3] - 0=signal 0x07,1=signal 0x01,2=signal 0x02(doporucene nastavenie), 3=signal 0x04
  *)
end;

function TFiskalPro.FSGPS(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSGPS', PAnsiChar(AnsiString(data)),
        Length(data), 12500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%64s]
    1: GPSAXIS
    2: STREETNAME\REGNR\ZIP\CITY\BULDINGNR
    3: OTHER
    P��klady p��kazu podle typ�:
    FSGPS1\17.165377\48.148962
    FSGPS2\Mierova\202\82105\Bratislava\23
    FSGPS3\Taxi ABC SPZ=BA 123 AA
  *)
end;

function TFiskalPro.FXEKASAPRNERR(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FXEKASAPRNERR',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%64s]
    DATEFROM\DATETO\NRFROM\NRTO
    DATEFROM � datum od vo formate YYYYMMDDHHmm
    DATERTO � datum do vo formate YYYYMMDDHHmm
    NRFROM� cislo dokladu od
    NRTO� cislo dokladu do
  *)
end;

function TFiskalPro.FSEKASASEND(): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSEKASASEND', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

function TFiskalPro.FTCARDSTART(data: PAnsiChar): integer;
// spust� vlastn� platbu kartou
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCARDSTART', PAnsiChar(AnsiString(data)
        ), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%0.2f] - ��stka k platb�. Minim�ln� a maxim�ln� hodnota je kontrolov�na na stran� platebn� aplikace.
    N�vratov� hodnoty
    0x10 (16) � platba zah�jena.
    0x12 (18) � platba zam�tnuta. Funkce vrac� tuto hodnotu, pokud je pou�it identifik�tor platby, pro kter� ji� platba prob�hla ne�sp�n�.
    0x06  (6) � platba akceptov�na. Funkce vrac� tuto hodnotu, pokud je pou�it identifik�tor platby, pro kter� ji� platba prob�hla usp�n�.
    0x0C (12) � platba kartou nen� povolena. Pou��v� se pro n�vraty na kartu, kter� nemus� b�t na termin�lu povoleny.
  *)
end;

function TFiskalPro.FTCARDINFO(data: PAnsiChar): integer;
// status platby kartou
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTCARDINFO', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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

function TFiskalPro.FXBAREP(): integer;
// P��kaz prov�d� a tiskne mezisou�et banky
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FXBAREP', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

function TFiskalPro.FZBAREP(): integer;
// P��kaz prov�d� a tiskne uz�v�rky banky. Uz�v�rka banky nuluje po��tadla banky. Uz�v�rku banky, na rozd�l od ZReportu, lze prov�st opakovan� b�hem jednoho dne
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FZBAREP', PAnsiChar(AnsiString('')
        ), 0, 3500)
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

function TFiskalPro.FRCARDRETINFO(): integer;
// P��kaz vrac� nastaven� pro n�vrat na kartu.
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FRCARDRETINFO', PAnsiChar(AnsiString('')
        ), 0, 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin
      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    N�vratov� hodnoty
    0x06  (6) � n�vrat na kartu je povolen.
    0x0C (12)� n�vrat na kartu nen� povolen.
  *)
end;

function TFiskalPro.FTCARDCANCELLAST(data: PAnsiChar): integer;
// P��kaz spust� storno posledn� platby kartou
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FTCARDCANCELLAST',
        PAnsiChar(AnsiString(data)), Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin

      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    N�vratov� hodnoty
    0x10 (16) � storno zah�jeno.
    0x12 (18) � storno zam�tnuto. Funkce vrac� tuto hodnotu, pokud je pou�it identifik�tor platby, pro kter� ji� platba prob�hla ne�sp�n�.
    0x06  (6) � platba nebo storno akceptov�no. Funkce vrac� tuto hodnotu, pokud je pou�it identifik�tor platby, pro kter� ji� platba prob�hla usp�n�.
    0x0C (12) � storno kartou nen� povoleno.
  *)
end;

function TFiskalPro.FTDOCROUND(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
    begin
      result := fFiskalPro.execCommand('FTDOCROUND', PAnsiChar(AnsiString('')
        ), 0, 3500);
      if result = C_RCODE_6 then
        fFiskalPro.ReadRecvData(PAnsiChar(data));
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
  (*
    Hodnota zaokr�hlenia posledn�ho dokladu. Pou�ije a� za pr�kazom FTCLOSE.
  *)
end;

function TFiskalPro.FPAYD(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FPAYD', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin

      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    Zaokr�hlenie platby hotovos� (index 1)
    Hodnota zaokr�hlenia pre dokladu. Pou�ije medzi pr�kazom FPAYI a FPAYA.
    Pr�kaz sa pou�ije ak nadraden� SW chce posiela� vlastn� zaokr�hlenie.
  *)
end;

function TFiskalPro.FSIMPNR(data: PAnsiChar): integer;
begin
  try
    if fFiskalPro.Ready then
      result := fFiskalPro.execCommand('FSIMPNR', PAnsiChar(AnsiString(data)),
        Length(data), 3500)
    else
      result := C_ERR_NOACTIVE;
  except
    on E: Exception do
    begin

      fExceptStr := E.Message;
      result := C_ERR_EXCEPT;
    end;
  end;
  (*
    [%10s] - ID implementace - Pou�ite ��seln�ho k�du priraden�ho od FiskalPRO
    P��kaz nastavuje ID implementace. Slou�� k identifikaci implementace dokladu na port�lu. P��kaz pou�ijte za FTOPEN.
  *)
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

fFiskalPro := TFiskalPro.Create();

finalization

if Assigned(fFiskalPro) then
  FreeAndNil(fFiskalPro);

end.
