unit DelUp;
// unita s prechodovymi funkcemi na Delphi XE

interface

uses
  Classes, Db, SysUtils;

function CharToAnsiChar(Ch: Char): AnsiChar;
function AnsiCharToChar(Ch: AnsiChar): Char;
function StrToAStr(const S: string): AnsiString;
function AStrToStr(const S: AnsiString): string;
function Utf8ToStr(const S: AnsiString): string;
function StrToPAChar(const S: string): PAnsiChar;

{$IFNDEF UNICODE}

const
  varUString = $0102; { Unicode string 258 } { not OLE compatible }

  { type
    TSysCharSet = set of Char; }

function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;

type
  TFormatSettings = class(TObject)
  private
    class function GetDateSeparator: Char;
    class procedure SetDateSeparator(Value: Char);
    class function GetTimeSeparator: Char;
    class procedure SetTimeSeparator(Value: Char);
    class function GetListSeparator: Char;
    class procedure SetListSeparator(Value: Char);
    class function GetShortDateFormat: string;
    class procedure SetShortDateFormat(Value: string);
    class function GetLongDateFormat: string;
    class procedure SetLongDateFormat(Value: string);
    class function GetShortTimeFormat: string;
    class procedure SetShortTimeFormat(Value: string);
    class function GetLongTimeFormat: string;
    class procedure SetLongTimeFormat(Value: string);
    class function GetLongMonthNames(Index: Integer): string;
    class procedure SetLongMonthNames(Index: Integer; Value: string);
    class function GetShortDayNames(Index: Integer): string;
    class procedure SetShortDayNames(Index: Integer; Value: string);
    class function GetThousandSeparator: Char;
    class procedure SetThousandSeparator(Value: Char);
    class function GetDecimalSeparator: Char;
    class procedure SetDecimalSeparator(Value: Char);
    class function GetTwoDigitYearCenturyWindow: Word;
    class procedure SetTwoDigitYearCenturyWindow(Value: Word);
  public
    property DateSeparator: Char read GetDateSeparator write SetDateSeparator;
    property TimeSeparator: Char read GetTimeSeparator write SetTimeSeparator;
    property ListSeparator: Char read GetListSeparator write SetListSeparator;
    property ShortDateFormat: string read GetShortDateFormat
      write SetShortDateFormat;
    property LongDateFormat: string read GetLongDateFormat
      write SetLongDateFormat;
    property ShortTimeFormat: string read GetShortTimeFormat
      write SetShortTimeFormat;
    property LongTimeFormat: string read GetLongTimeFormat
      write SetLongTimeFormat;
    property LongMonthNames[Index: Integer]: string read GetLongMonthNames
      write SetLongMonthNames;
    property ShortDayNames[Index: Integer]: string read GetShortDayNames
      write SetShortDayNames;
    property ThousandSeparator: Char read GetThousandSeparator
      write SetThousandSeparator;
    property DecimalSeparator: Char read GetDecimalSeparator
      write SetDecimalSeparator;
    property TwoDigitYearCenturyWindow: Word read GetTwoDigitYearCenturyWindow
      write SetTwoDigitYearCenturyWindow;
  end;
{$ENDIF}

type
{$IFDEF UNICODE}
  TBookmarkType = TBookmark;
  TGetTableNameString = WideString;
{$ELSE}
  TBookmarkType = TBookmarkStr;
  TGetTableNameString = string;
{$ENDIF}
{$IFNDEF UNICODE}

var
  FormatSettings: TFormatSettings;
{$ENDIF}

implementation

{ uses
  SysUtils; }

function CharToAnsiChar(Ch: Char): AnsiChar;
var
  AString: AnsiString;
begin
  AString := StrToAStr(Ch);
  Result := AString[1];
end;

function AnsiCharToChar(Ch: AnsiChar): Char;
var
  WString: String;
begin
  WString := AStrToStr(Ch);
  Result := WString[1];
end;

function StrToAStr(const S: string): AnsiString;
begin
{$IFDEF UNICODE}
  Result := AnsiString(S);
{$ELSE}
  Result := S;
{$ENDIF}
end;

function AStrToStr(const S: AnsiString): string;
begin
{$IFDEF UNICODE}
  Result := string(S);
{$ELSE}
  Result := S;
{$ENDIF}
end;

function Utf8ToStr(const S: AnsiString): string;
begin
{$IFDEF UNICODE}
  Result := string(S);
{$ELSE}
  Result := S;
{$ENDIF}
end;

function StrToPAChar(const S: string): PAnsiChar;
var
  AnsString: AnsiString;
begin
  Result := '';
  try
    if S <> '' then
    begin
      AnsString := AnsiString(S);
      Result := PAnsiChar(PAnsiString(AnsString));
    end;
  except { } end;
end;

{$IFNDEF UNICODE}

function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;

{ TFormatSettings }
class function TFormatSettings.GetDateSeparator: Char;
begin
  Result := SysUtils.DateSeparator;
end;

class procedure TFormatSettings.SetDateSeparator(Value: Char);
begin
  SysUtils.DateSeparator := Value;
end;

class function TFormatSettings.GetTimeSeparator: Char;
begin
  Result := SysUtils.TimeSeparator;
end;

class procedure TFormatSettings.SetTimeSeparator(Value: Char);
begin
  SysUtils.TimeSeparator := Value;
end;

class function TFormatSettings.GetListSeparator: Char;
begin
  Result := SysUtils.ListSeparator;
end;

class procedure TFormatSettings.SetListSeparator(Value: Char);
begin
  SysUtils.ListSeparator := Value;
end;

class function TFormatSettings.GetShortDateFormat: string;
begin
  Result := SysUtils.ShortDateFormat;
end;

class procedure TFormatSettings.SetShortDateFormat(Value: string);
begin
  SysUtils.ShortDateFormat := Value;
end;

class function TFormatSettings.GetLongDateFormat: string;
begin
  Result := SysUtils.LongDateFormat;
end;

class procedure TFormatSettings.SetLongDateFormat(Value: string);
begin
  SysUtils.LongDateFormat := Value;
end;

class function TFormatSettings.GetShortTimeFormat: string;
begin
  Result := SysUtils.ShortTimeFormat;
end;

class procedure TFormatSettings.SetShortTimeFormat(Value: string);
begin
  SysUtils.ShortTimeFormat := Value;
end;

class function TFormatSettings.GetLongTimeFormat: string;
begin
  Result := SysUtils.LongTimeFormat;
end;

class procedure TFormatSettings.SetLongTimeFormat(Value: string);
begin
  SysUtils.LongTimeFormat := Value;
end;

class function TFormatSettings.GetLongMonthNames(Index: Integer): string;
begin
  Result := SysUtils.LongMonthNames[Index];
end;

class procedure TFormatSettings.SetLongMonthNames(Index: Integer;
  Value: string);
begin
  SysUtils.LongMonthNames[Index] := Value;
end;

class function TFormatSettings.GetShortDayNames(Index: Integer): string;
begin
  Result := SysUtils.ShortDayNames[Index];
end;

class procedure TFormatSettings.SetShortDayNames(Index: Integer; Value: string);
begin
  SysUtils.ShortDayNames[Index] := Value;
end;

class function TFormatSettings.GetThousandSeparator: Char;
begin
  Result := SysUtils.ThousandSeparator;
end;

class procedure TFormatSettings.SetThousandSeparator(Value: Char);
begin
  SysUtils.ThousandSeparator := Value;
end;

class function TFormatSettings.GetDecimalSeparator: Char;
begin
  Result := FormatSettings.DecimalSeparator;
end;

class procedure TFormatSettings.SetDecimalSeparator(Value: Char);
begin
  FormatSettings.DecimalSeparator := Value;
end;

class function TFormatSettings.GetTwoDigitYearCenturyWindow: Word;
begin
  Result := SysUtils.TwoDigitYearCenturyWindow;
end;

class procedure TFormatSettings.SetTwoDigitYearCenturyWindow(Value: Word);
begin
  SysUtils.TwoDigitYearCenturyWindow := Value;
end;
{$ENDIF}

end.
