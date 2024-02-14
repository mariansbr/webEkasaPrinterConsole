unit uCommon;

interface

uses
  SysUtils, Math, DecRound, Types, Windows;

type
  TFileVersion = record
    case byte of
      1:
        (FullVersion: Int64);
      2:
        (Build: Word;
          Release: Word;
          Minor: Word;
          Major: Word);
  end;

const
  c_Sp_Zaok_prirozene = 0;
  c_Sp_Zaok_nadol = 1;
  c_Sp_Zaok_nahor = 2;
  c_Sp_Zaok_BankRound = 3;

function TrimLeadZero(vValue: string): string;
function EncodeDateStrDef(Year, Month, Day: string; Default: TDate): TDate;
function EncodeTimeStrDef(Hour, Minute, Second: string; Default: TTime): TTime;
function Zaok(dCiastka: double; DesM: byte; Smer: byte): double;
function Curr2Int(fVal: double; decPos: byte): integer;
function Empty(const S: String): boolean;
function DelNotNumChar(vValue: string; ExceptChars: TSysCharSet)
  : string; overload;
function DelNotNumChar(vValue: string): string; overload;
function DecStrToCurr(const S: string): currency;
function CmpFileVersion(Ver1, Ver2: TFileVersion): integer;
function CheckDLLVersion(PotrebnaVerzia, AktualniVerzia: TFileVersion): boolean;
function GetFileVersion(const FilePath: string): TFileVersion;

function ifThenEx(aValue: boolean; const aTrue: string; aFalse: string)
  : string; overload;
function ifThenEx(aValue: boolean; const aTrue: integer; aFalse: integer)
  : integer; overload;
function ifThenEx(aValue: boolean; const aTrue: Int64; aFalse: Int64)
  : Int64; overload;
function ifThenEx(aValue: boolean; const aTrue: currency; aFalse: currency)
  : currency; overload;
function ifThenEx(aValue: boolean; const aTrue: double; aFalse: double)
  : double; overload;
function intInSet(int: integer; intSet: array of integer): boolean;

procedure IntDecStrToCurr(var R: string; var Z: currency);
function DecStrToCurrDef(S: string; const Default: currency): currency;
function TxtToBin(txt: string; out bin: string): boolean;

implementation

function TrimLeadZero(vValue: string): string;
begin
  Result := Trim(vValue);
  while (Length(Result) > 0) and (Result[1] = '0') do
    Delete(Result, 1, 1);
end;

function EncodeDateStrDef(Year, Month, Day: string; Default: TDate): TDate;
var
  Y, M, D: Word;
  DT: TDateTime;
begin
  Y := StrToInt(Year);
  if Y < 100 then
  begin
    if Y > 30 then
      Y := Y + 1900
    else
      Y := Y + 2000;
  end;
  M := StrToInt(Month);
  D := StrToInt(Day);
  if TryEncodeDate(Y, M, D, DT) then
    Result := DT
  else
    Result := Default;
end;

function EncodeTimeStrDef(Hour, Minute, Second: string; Default: TTime): TTime;
var
  H, M, S: Word;
  DT: TDateTime;
begin
  H := StrToInt(Hour);
  M := StrToInt(Minute);
  S := StrToInt(Second);
  if TryEncodeTime(H, M, S, 0, DT) then
    Result := DT
  else
    Result := Default;
end;

function Zaok(dCiastka: double; DesM: byte; Smer: byte): double;
var
  iZapor: integer;
  ZaokJedn: double;
  dTempCst: double;
begin
  if dCiastka = 0 then
  begin
    Result := 0;
    exit;
  end
  else if dCiastka < 0 then
  begin
    iZapor := -1;
  end
  else
    iZapor := 1;

  if DesM = 9 then
  begin // na 0,5
    dTempCst := dCiastka * iZapor * 2;
    dTempCst := Zaok(dTempCst, 0, Smer);
    dTempCst := dTempCst / 2;
  end // na 0,5
  else
  begin
    if DesM = 0 then
    begin
      ZaokJedn := 0.00;
      dTempCst := dCiastka * iZapor;
    end
    else
    begin
      dTempCst := Power(10, DesM);
      ZaokJedn := 1 / dTempCst;
      dTempCst := dCiastka / ZaokJedn * iZapor;
    end;

    case Smer of
      c_Sp_Zaok_nadol: // 1 - nadol
        dTempCst := DecimalRoundDbl(dTempCst, 0, drRndDown);
      c_Sp_Zaok_nahor: // 2 - nahor
        dTempCst := DecimalRoundDbl(dTempCst, 0, drRndUp);
      c_Sp_Zaok_BankRound: // 3 - bank
        dTempCst := DecimalRoundDbl(dTempCst, 0, drHalfEven);
    else // 0 - prirozene
      dTempCst := DecimalRoundDbl(dTempCst, 0, drHalfUp);
    end;

    if ZaokJedn <> 0 then
      dTempCst := dTempCst * ZaokJedn;
  end;

  dTempCst := dTempCst * iZapor;
  Result := dTempCst;
end;

function Curr2Int(fVal: double; decPos: byte): integer;
var
  cVal: double;
begin
  cVal := fVal;
  case decPos of
    1:
      cVal := Zaok(cVal, 1, 0) * 10;
    2:
      cVal := Zaok(cVal, 2, 0) * 100;
    3:
      cVal := Zaok(cVal, 3, 0) * 1000;
    4:
      cVal := Zaok(cVal, 4, 0) * 10000;
  end;
  Result := Trunc(cVal);
  if Frac(cVal) >= 0.5 then
    Result := Result + 1;
end;

function Empty(const S: String): boolean;
begin
  Result := (Length(Trim(S)) = 0);
end;

function DelNotNumChar(vValue: string; ExceptChars: TSysCharSet): string;
var
  I: integer;
begin
  Result := Trim(vValue);
  for I := Length(Result) downto 1 do
    if not CharInSet(Result[I], ['0' .. '9']) then
      if not CharInSet(Result[I], ExceptChars) then
        Delete(Result, I, 1);
end;

function DelNotNumChar(vValue: string): string;
begin
  Result := DelNotNumChar(vValue, []);
end;

function DecStrToCurr(const S: string): currency;
var
  R, RR: string;
  I: integer;
begin
  R := S;
  RR := '';
  // odstranenie nepotrebnych znakov + zmena des. ciarky
  for I := 1 to Length(R) do
    if CharInSet(R[I], ['0' .. '9', 'e', 'E', '+', '-']) then
      RR := RR + R[I]
    else if CharInSet(R[I], [',', '.']) then
      RR := RR + FormatSettings.DecimalSeparator;
  Result := StrToCurr(RR);
end;

function CmpFileVersion(Ver1, Ver2: TFileVersion): integer;
begin
  if Ver1.FullVersion > Ver2.FullVersion then
    Result := 1
  else if Ver1.FullVersion < Ver2.FullVersion then
    Result := -1
  else
    Result := 0;
end;

function CheckDLLVersion(PotrebnaVerzia, AktualniVerzia: TFileVersion): boolean;
begin
  Result := (CmpFileVersion(PotrebnaVerzia, AktualniVerzia) <= 0);
end;

function GetFileVersion(const FilePath: string): TFileVersion;
var
  VerInfoSize: Cardinal;
  VerQuerySize: Cardinal;
  VersionInfo: Pointer;
  GetInfoSizeJunk: DWORD;
  pVS_FIXEDFILEINFO: Pointer;
begin
  Result.FullVersion := 0;

  VerInfoSize := GetFileVersionInfoSize(PChar(FilePath), GetInfoSizeJunk);
  { if there was a version information resource available... }
  if VerInfoSize > 0 then
  begin
    { retrieve enough memory to hold the version resource }
    GetMem(VersionInfo, VerInfoSize);
    try
      { retrieve the version resource for the selected file }
      GetFileVersionInfo(PChar(FilePath), 0, VerInfoSize, VersionInfo);
      { retrieve a pointer to the translation table }
      VerQueryValue(VersionInfo, '\', pVS_FIXEDFILEINFO, VerQuerySize);

      Result.FullVersion := VS_FIXEDFILEINFO(pVS_FIXEDFILEINFO^)
        .dwFileVersionMS;
      Result.FullVersion := Result.FullVersion * $100000000;
      Result.FullVersion := Result.FullVersion +
        VS_FIXEDFILEINFO(pVS_FIXEDFILEINFO^).dwFileVersionLS;

    finally
      FreeMem(VersionInfo, VerInfoSize);
    end;
  end;
end;

function ifThenEx(aValue: boolean; const aTrue: string; aFalse: string): string;
begin
  if aValue then
    Result := aTrue
  else
    Result := aFalse;
end;

function ifThenEx(aValue: boolean; const aTrue: integer;
  aFalse: integer): integer;
begin
  if aValue then
    Result := aTrue
  else
    Result := aFalse;
end;

function ifThenEx(aValue: boolean; const aTrue: Int64; aFalse: Int64): Int64;
begin
  if aValue then
    Result := aTrue
  else
    Result := aFalse;
end;

function ifThenEx(aValue: boolean; const aTrue: currency; aFalse: currency)
  : currency;
begin
  if aValue then
    Result := aTrue
  else
    Result := aFalse;
end;

function ifThenEx(aValue: boolean; const aTrue: double; aFalse: double): double;
begin
  if aValue then
    Result := aTrue
  else
    Result := aFalse;
end;

function intInSet(int: integer; intSet: array of integer): boolean;
var
  I: integer;
begin
  Result := false;
  for I := Low(intSet) to High(intSet) do
  begin
    if intSet[I] = int then
    begin
      Result := true;
      break;
    end;
  end;
end;

procedure IntDecStrToCurr(var R: string; var Z: currency);
const
  C_TD_SEP: set of AnsiChar = [',', '.'];
var
  S: string;
  I: integer;
begin
  S := R;
  R := '';
  // Zbavime se nepotrebnych znaku a zkonvertujeme des. tecku
  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0' .. '9', 'e', 'E', '+', '-']) then
      R := R + S[I]
    else if CharInSet(S[I], C_TD_SEP) then
      R := R + FormatSettings.DecimalSeparator;
  // Pro jistotu to zbavime znamenka
  // Implicitne to bude kladne
  Z := 1;
  if Length(R) > 0 then
  begin
    if CharInSet(R[1], ['+', '-']) then
    begin
      if R[1] = '+' then
        Z := 1
      else
        Z := -1;
      System.Delete(R, 1, 1);
    end;
  end;
  // (kdyby bylo na konci, taky bude delat paseku)
  if Length(R) > 0 then
  begin
    if CharInSet(R[Length(R)], ['+', '-']) then
    begin
      if R[Length(R)] = '+' then
        Z := 1
      else
        Z := -1;
      System.Delete(R, Length(R), 1);
    end;
  end;
end;

function DecStrToCurrDef(S: string; const Default: currency): currency;
var
  Z: currency;
begin
  IntDecStrToCurr(S, Z);
  Result := Z * StrToCurrDef(S, Default);
end;

function TxtToBin(txt: string; out bin: string): boolean;
const
  separators = [',', ' ', ';', '.', '/'];
var
  I, n: integer;
  zacal, hexprefix: boolean;
  c: char;
begin
  bin := '';
  Result := true;
  n := 0;
  zacal := false;
  hexprefix := false;
  for I := 1 to Length(txt) + 1 do
  begin
    c := (txt + ' ')[I];
    if c >= 'a' then
      c := Chr(Ord(c) - 32); // namisto stringoveho UpperCase
    if zacal and CharInSet(c, separators) then
    begin // konec cisla
      if n > 255 then
      begin
        Result := false; // chyba: prilis velke cislo
        break;
      end;
      bin := bin + Chr(n);
      n := 0;
      zacal := false;
      hexprefix := false;
    end
    else if c = ' ' then
      continue // nadbytecne mezery ignorujeme
    else if (not zacal) and (not hexprefix) and (c = '$') then
      hexprefix := true
    else if (n = 0) and (not hexprefix) and (c = 'X') then
      hexprefix := true // aby bral i C-notaci : 0xE5
    else if hexprefix and CharInSet(c, ['0' .. '9', 'A' .. 'F']) then
    begin
      if CharInSet(c, ['0' .. '9']) then
        n := n * 16 + (Ord(c) - Ord('0'))
      else
        n := n * 16 + (Ord(c) - Ord('A') + 10);
      zacal := true;
    end
    else if CharInSet(c, ['0' .. '9']) then
    begin
      n := n * 10 + (Ord(c) - Ord('0'));
      zacal := true;
    end
    else
    begin
      Result := false; // chyba: nepovoleny znak
      break;
    end;
  end;
end;

end.
