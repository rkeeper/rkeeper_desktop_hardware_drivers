unit uCommon;

interface

uses
   SysUtils
  ,StrUtils
  ,Windows
  ,FMTBcd
  ,DateUtils
  ;

type BinaryString = AnsiString;

function iSelfVersion(AiPart: Integer =3): Integer;
function sVersion: AnsiString;
function sDescription(const AsDefaultDescription: AnsiString): AnsiString;

function GetSelfModuleFileName: AnsiString;

function DataToDataStr(const AData; AiLength: Integer): AnsiString;
function DataStrToData(const AsDataStr: AnsiString; var AData): Boolean;
function DataStrToShowStr(const AsData: AnsiString; AisInvisibleAsHex: Boolean = False): AnsiString;
function DataStrToHexStr(const AsDataStr: AnsiString; AsSeparator: AnsiString = ' '): AnsiString;
function HexStrToBin(const s:string):string;
function HexStrToDataStr(const AsHEX: AnsiString; out AsData: AnsiString; AsSeparator: AnsiString = ''): Boolean;

procedure IncWrap(var v: byte); overload;
procedure IncWrap(var v: word); overload;
procedure IncWrap(var v: integer); overload;
procedure IncWrap(var v: cardinal); overload;

procedure DecWrap(var v: byte); overload;
procedure DecWrap(var v: word); overload;
procedure DecWrap(var v: integer); overload;
procedure DecWrap(var v: cardinal); overload;

const
  STRING_CONST_CODEPAGE = 1251;

const
  cNUL = #$00;
  cSOH = #$01;
  cSTX = #$02;
  cETX = #$03;
  cEOT = #$04;
  cENQ = #$05;
  cACK = #$06;
  cBEL = #$07;
  cBS  = #$08;
  cTAB = #$09;
  cLF  = #$0A;
  cVT  = #$0B;
  cFF  = #$0C;
  cCR  = #$0D;
  cSO  = #$0E;
  cSI  = #$0F;
  cDLE = #$10;
  cDC1 = #$11;
  cDC2 = #$12;
  cDC3 = #$13;
  cDC4 = #$14;
  cNAK = #$15;
  cSYN = #$16;
  cETB = #$17;
  cCAN = #$18;
  cEM  = #$19;
  cSUB = #$1A;
  cESC = #$1B;
  cFS  = #$1C;
  cGS  = #$1D;
  cRS  = #$1E;
  cUS  = #$1F;

  cDEL = #$7F;

  CRLF = #$0D#$0A;

function CodePageToWideString(AlwCodePage: LongWord; const AsText: AnsiString): WideString;
function CodePageToUTF8(AlwCodePage: LongWord; const AsText: AnsiString): UTF8String;
function StrConstToWideString(const AsText: AnsiString): WideString;
function StrConstToUTF8(const AsText: AnsiString): UTF8String;

function WideStringToCodePage(const AwsText: WideString; AlwCodePage: LongWord): AnsiString;
function UTF8toCodePage(const AusText: UTF8String; AlwCodePage: LongWord): AnsiString;
function UTF8toStrConst(const AusText: UTF8String): AnsiString;

function FixedLenStr(const AsIn: AnsiString; AiNeedLen: Integer; Ac: AnsiChar = ' '; AisAddToEnd: Boolean = True): AnsiString;
function FixedLenStrUTF8(const AsIn: UTF8String; AiNeedLen: Integer; Ac: AnsiChar = ' '; AisAddToEnd: Boolean = True): UTF8String;
function FixLenStr(const AsIn: AnsiString; AiNeedLen: Integer; AcFill: AnsiChar = ' '; AisAddToCutFromEnd: Boolean = True): AnsiString;

function AddDataToFile(const AsFileName, AsData: AnsiString): Boolean;

function sErrInterval(Ai6Value, Ai6Min, Ai6Max: Int64; const AusName: UTF8String = ''): UTF8String;
function sErrNotInEnum(Ai6Value: Int64; const AarcstEnums: array of Int64; const AusName: UTF8String = ''): UTF8String;
function sErrNonIntStr(const AsValue: AnsiString; out AiValue: Integer; const AusName: UTF8String = ''): UTF8String;
function sErrNonInt64Str(const AsValue: AnsiString; out Ai6Value: Int64; const AusName: UTF8String = ''): UTF8String;
function sErrNonDecStr(const AsValue: AnsiString; AiDecimDigitQntty: Integer; out Ai6Value: Int64; AcNeedDecimSepar: AnsiChar = '.'; const AusName: UTF8String = ''): UTF8String;

function SetValInLims(Ai6Val, Ai6Min, Ai6Max: Int64): Int64;

function LoadLibraryCustom(const AsLibraryFilePathName: AnsiString; out AhLib: Cardinal): UTF8String;
function GetProcAddrCustom(AhLib: Cardinal; AsProcName: AnsiString; out ApProc: Pointer): UTF8String;

function GetLastErrorCustom: UTF8String;
function SysErrorMessageUTF8(ErrorCode: Integer): UTF8String;

function IsBitSet(const AData; AiBitNum: Integer): Boolean;
function IsBitSetInt(Ai6Data: Int64; AiBitNum: Integer): Boolean;

function IntToDecStr(Ai6Value: Int64; AiDecimDigitQntty: Integer; AcNeedDecimSepar: AnsiChar = '.'; AisShowDecimZeros: Boolean = False): AnsiString;
function DecStrToInt(AsValue: AnsiString; AiDecimDigitQntty: Integer; out Ai6Value: Int64; AcNeedDecimSepar: AnsiChar = '.'): Boolean;

function ByteToBCD(AbDec: Byte; out AbBCD: Byte): Boolean;
function BCDtoByte(AbBCD: Byte; out AbDec: Byte): Boolean;

function ExtractFieldByNumber(const AsText, AsSeparator: AnsiString; AiNumber: Integer): AnsiString; // numbering from 1, in AsText several fields divided by AsSeparator string
function ExtractFieldByPrefix(const AsText, AsSeparator, AsPrefix: AnsiString): AnsiString; // in AsText several fields like PrefixValue divided by AsSeparator string

function HexCharToInt(AcHex: AnsiChar; const AsFieldName: AnsiString; out AsError: AnsiString): Byte;
function HexToInt(const AsHex, AsFieldName: AnsiString; out Ai6Result: Int64): AnsiString;

function CRC16_CCITT(const AsData: AnsiString; AwInitValue: Word = $FFFF): Word;
function CRC16(const AsData: AnsiString; AwPolinom, AwInitValue: Word): Word;

function FlipW(AwValue: Word): Word;

function ExtractValueByName(const AsData, AsName, AsValuNameDlmt, AsPairPairDlmt: AnsiString): AnsiString;

function WtoLE(AwData: Word): AnsiString;
function DWtoLE(AdwData: DWORD): AnsiString;
function I6toLE(Ai6Data: Int64): AnsiString;
function WtoBE(AwData: Word): AnsiString;
function DWtoBE(AdwData: DWORD): AnsiString;
function LEtoW(const AsData: AnsiString): Word;
function LEtoDW(const AsData: AnsiString): DWORD;
function LEtoI6(const AsData: AnsiString): Int64;
function BEtoW(const AsData: AnsiString): Word;
function BEtoDW(const AsData: AnsiString): DWORD;
function BEtoI6(const AsData: AnsiString): Int64;
function LEtoVLN(const AsData: AnsiString): Int64;
function BEtoVLN(const AsData: AnsiString): Int64;

function XORbyte(const AsData: AnsiString): Byte;

function GetTickDiff(AdwTickBegin, AdwTickEnd: DWORD): DWORD;

function StrToIntLim(const AsVal: AnsiString; AiMin, AiMax: Integer; out AiVal: Integer): Boolean;
function ParseDateTime(const AsDateTime, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;
function ParseDate(const AsDate, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;
function ParseTime(const AsTime, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;

implementation

function HexDigitToByte(AcHEXdigit: AnsiChar; out AbData: Byte): Boolean;
begin
  Result := False;

  if AcHEXdigit in ['0'..'9'] then begin
    AbData := Ord(AcHEXdigit) - Ord('0');
  end else if AcHEXdigit in ['A'..'F'] then begin
    AbData := 10 + Ord(AcHEXdigit) - Ord('A');
  end else if AcHEXdigit in ['a'..'f'] then begin
    AbData := 10 + Ord(AcHEXdigit) - Ord('a');
  end else begin
    Exit;
  end;

  Result := True;
end;

function HexStrToDataStr(const AsHEX: AnsiString; out AsData: AnsiString; AsSeparator: AnsiString = ''): Boolean;
var
  i: Integer;
  bl, bh: Byte;
  sCurSep: AnsiString;
begin
  Result := False;

  AsData := '';
  i := 1;
  while True do begin
    if i > Length(AsHEX) then Break;
    if not HexDigitToByte(AsHEX[i], bh) then Exit;
    Inc(i);

    if i > Length(AsHEX) then Break;
    if not HexDigitToByte(AsHEX[i], bl) then Exit;
    Inc(i);

    AsData := AsData + Chr((bh shl 4) + bl);

    if AsSeparator = '' then Continue;
    if i + Length(AsSeparator) > Length(AsHEX) then Break;
    sCurSep := Copy(AsHEX, i, Length(AsSeparator));
    if sCurSep <> AsSeparator then Exit;
    Inc(i, Length(AsSeparator));
  end;

  Result := True;
end;

function ExtractFieldByNumber(const AsText, AsSeparator: AnsiString; AiNumber: Integer): AnsiString;
var
  iBegPos, iEndPos: Integer;
  iCurNum: Integer;
begin //  извлекает поле по номеру (нумераци€ от 1) из строки AsText, в которой несколько полей разделены AsSeparator
  Result := '';
  iBegPos := 1;
  iEndPos := iBegPos - Length(AsSeparator); //  чтобы начинать с 1
  for iCurNum := 1 to AiNumber do begin
    iBegPos := iEndPos + Length(AsSeparator);
    iEndPos := PosEx(AsSeparator, AsText + AsSeparator, iBegPos);
    if iEndPos = 0 then Exit;
  end;
  Result := Copy(AsText, iBegPos, iEndPos - iBegPos);
end;

function ExtractFieldByPrefix(const AsText, AsSeparator, AsPrefix: AnsiString): AnsiString;
var
  iPos: Integer;
begin
  Result := '';

  iPos := Pos(AsPrefix, AsText);
  if iPos <= 0 then Exit;
  Result := Copy(AsText, iPos + Length(AsPrefix), Length(AsText));
  iPos := Pos(AsSeparator, Result);
  if iPos > 0 then Result := Copy(Result, 1, iPos - 1);
end;

function ByteToBCD(AbDec: Byte; out AbBCD: Byte): Boolean;
var
  Bcd: TBcd;
begin
  Result := False;

  if not AbDec in [0..99] then Exit;

  Bcd := IntegerToBcd(AbDec);
  case Bcd.Precision of
    0: AbBCD := 0;
    1: AbBCD := Bcd.Fraction[0] shr 4;
  else
    AbBCD := Bcd.Fraction[0];
  end;

  Result := True;
end;

function BCDtoByte(AbBCD: Byte; out AbDec: Byte): Boolean;
var
  Bcd: TBcd;
begin
  Result := False;

  Bcd.Precision := 2;
  Bcd.SignSpecialPlaces := 0;
  Bcd.Fraction[0] := AbBCD;
  try
    AbDec := BcdToInteger(Bcd);
  except
    on Exception do Exit;
  end;

  Result := True;
end;

function GetSelfModuleFileName: AnsiString;
const
  I_APRIORI_SIZE = $FF;
begin
  SetLength(Result, I_APRIORI_SIZE);
  SetLength(Result, GetModuleFileName(hInstance, @Result[1], I_APRIORI_SIZE));
end;

function CodePageToWideString(AlwCodePage: LongWord; const AsText: AnsiString): WideString;
var
  ws: WideString;
begin
  Result := '';
  if Length(AsText) = 0 then Exit;
  SetLength(ws, MultiByteToWideChar(AlwCodePage, 0, @AsText[1], Length(AsText), nil, 0));
  if Length(ws) = 0 then Exit;
  MultiByteToWideChar(AlwCodePage, 0, @AsText[1], Length(AsText), @ws[1], Length(ws));
  Result := ws;
end;

function CodePageToUTF8(AlwCodePage: LongWord; const AsText: AnsiString): UTF8String;
begin
  Result := UTF8Encode(CodePageToWideString(AlwCodePage, AsText));
end;

function StrConstToWideString(const AsText: AnsiString): WideString;
begin
  Result := CodePageToWideString(STRING_CONST_CODEPAGE, AsText);
end;

function StrConstToUTF8(const AsText: AnsiString): UTF8String;
begin
  Result := CodePageToUTF8(STRING_CONST_CODEPAGE, AsText);
end;

function UTF8toCodePage(const AusText: UTF8String; AlwCodePage: LongWord): AnsiString;
var
  ws: WideString;
begin
  Result := '';
  ws := UTF8Decode(AusText);
  if Length(ws) = 0 then Exit;

  SetLength(Result, WideCharToMultiByte(AlwCodePage, 0, @ws[1], Length(ws), nil, 0, nil, nil));
  if Length(Result) = 0 then Exit;
  WideCharToMultiByte(AlwCodePage, 0, @ws[1], Length(ws), @Result[1], Length(Result), nil, nil)
end;

function UTF8toStrConst(const AusText: UTF8String): AnsiString;
begin
  Result := UTF8toCodePage(AusText, STRING_CONST_CODEPAGE);
end;

function WideStringToCodePage(const AwsText: WideString; AlwCodePage: LongWord): AnsiString;
begin
  Result := '';
  if Length(AwsText) = 0 then Exit;
  SetLength(Result, WideCharToMultiByte(AlwCodePage, 0, @AwsText[1], Length(AwsText), nil, 0, nil, nil));
  if Length(Result) = 0 then Exit;
  WideCharToMultiByte(AlwCodePage, 0, @AwsText[1], Length(AwsText), @Result[1], Length(Result), nil, nil)
end;

function FixedLenStr(const AsIn: AnsiString; AiNeedLen: Integer; Ac: AnsiChar = ' '; AisAddToEnd: Boolean = True): AnsiString;
begin
  Result := '';
  if AiNeedLen <= 0 then Exit;
  Result := AsIn;
  if Length(AsIn) > AiNeedLen then Result := Copy(AsIn, 1, AiNeedLen);
  if Length(AsIn) < AiNeedLen then begin
    if AisAddToEnd then
      Result := AsIn + StringOfChar(Ac, AiNeedLen - Length(AsIn))
    else
      Result := StringOfChar(Ac, AiNeedLen - Length(AsIn)) + AsIn;
  end;
end;

function FixedLenStrUTF8(const AsIn: UTF8String; AiNeedLen: Integer; Ac: AnsiChar = ' '; AisAddToEnd: Boolean = True): UTF8String;
var AsInLen: integer;
begin
  Result := '';
  if AiNeedLen <= 0 then Exit;
  AsInLen:=length(UTF8Decode(AsIn));
  Result := AsIn;
  if AsInLen > AiNeedLen then Result := UTF8Encode(Copy(UTF8Decode(AsIn), 1, AiNeedLen));
  if AsInLen < AiNeedLen then begin
    if AisAddToEnd then
      Result := AsIn + StringOfChar(Ac, AiNeedLen - AsInLen)
    else
      Result := StringOfChar(Ac, AiNeedLen - AsInLen) + AsIn;
  end;
end;

function FixLenStr(const AsIn: AnsiString; AiNeedLen: Integer; AcFill: AnsiChar = ' '; AisAddToCutFromEnd: Boolean = True): AnsiString;
begin
  Result := '';
  if AiNeedLen <= 0 then Exit;
  Result := AsIn;
  if Length(AsIn) > AiNeedLen then begin
    if AisAddToCutFromEnd then begin
      Result := Copy(AsIn, 1, AiNeedLen);
    end else begin
      Result := Copy(AsIn, Length(AsIn) - AiNeedLen + 1, AiNeedLen);
    end;
  end;
  if Length(AsIn) < AiNeedLen then begin
    if AisAddToCutFromEnd then begin
      Result := AsIn + StringOfChar(AcFill, AiNeedLen - Length(AsIn))
    end else begin
      Result := StringOfChar(AcFill, AiNeedLen - Length(AsIn)) + AsIn;
    end;
  end;
end;

function GetLastErrorCustom: UTF8String;
var
  lwWinError: LongWord;
begin
  lwWinError := GetLastError;
  if lwWinError = 0 then Result := '' else Result := Format('Windows error: 0x%s - %s', [IntToHex(lwWinError, 8), SysErrorMessageUTF8(lwWinError)]);
end;

function LoadLibraryCustom(const AsLibraryFilePathName: AnsiString; out AhLib: Cardinal): UTF8String;
begin
  Result := 'Unknown error';

  AhLib := LoadLibrary(PAnsiChar(AsLibraryFilePathName));
  if AhLib > 32 then Result := '' else Result := Format('Unable to load library %s. %s', [AsLibraryFilePathName, GetLastErrorCustom]);
end;

function GetProcAddrCustom(AhLib: Cardinal; AsProcName: AnsiString; out ApProc: Pointer): UTF8String;
begin
  Result := 'Unknown error';

  ApProc := GetProcAddress(AhLib, PAnsiChar(AsProcName));
  if Assigned(ApProc) then Result := '' else Result := Format('Unable to find procedure %s. %s', [AsProcName, GetLastErrorCustom]);
end;

function DataToDataStr(const AData; AiLength: Integer): AnsiString;
begin
  SetLength(Result, AiLength);
  try
    Move(AData, Result[1], Length(Result));
  except
    Result := '';
  end;
end;

function DataStrToData(const AsDataStr: AnsiString; var AData): Boolean;
begin
  Result := False;
  if Length(AsDataStr) = 0 then Exit;
  try
    Move(AsDataStr[1], AData, Length(AsDataStr));
  except
    Exit;
  end;
  Result := True
end;

function DataStrToShowStr(const AsData: AnsiString; AisInvisibleAsHex: Boolean = False): AnsiString;
var
  c: Char;
  i: Integer;
begin
  Result := '';

  for i := 1 to Length(AsData) do begin
    c := AsData[i];
    if AisInvisibleAsHex then begin
      if c in [#$00..#$1F, #$7F, '<', '>'] then begin
        Result := Result + '<' + IntToHex(Ord(c), 2) + '>';
      end else begin //  видимый символ
        Result := Result + c;
      end;
    end else begin
      case c of
        cNUL: Result := Result + '<NUL>';
        cSOH: Result := Result + '<SOH>';
        cSTX: Result := Result + '<STX>';
        cETX: Result := Result + '<ETX>';
        cEOT: Result := Result + '<EOT>';
        cENQ: Result := Result + '<ENQ>';
        cACK: Result := Result + '<ACK>';
        cBEL: Result := Result + '<BEL>';
        cBS : Result := Result + '<BS>';
        cTAB: Result := Result + '<TAB>';
        cLF : Result := Result + '<LF>';
        cVT : Result := Result + '<VT>';
        cFF : Result := Result + '<FF>';
        cCR : Result := Result + '<CR>';
        cSO : Result := Result + '<SO>';
        cSI : Result := Result + '<SI>';
        cDLE: Result := Result + '<DLE>';
        cDC1: Result := Result + '<DC1>';
        cDC2: Result := Result + '<DC2>';
        cDC3: Result := Result + '<DC3>';
        cDC4: Result := Result + '<DC4>';
        cNAK: Result := Result + '<NAK>';
        cSYN: Result := Result + '<SYN>';
        cETB: Result := Result + '<ETB>';
        cCAN: Result := Result + '<CAN>';
        cEM : Result := Result + '<EM>';
        cSUB: Result := Result + '<SUB>';
        cESC: Result := Result + '<ESC>';
        cFS : Result := Result + '<FS>';
        cGS : Result := Result + '<GS>';
        cRS : Result := Result + '<RS>';
        cUS : Result := Result + '<US>';

        cDEL: Result := Result + '<DEL>';
      else //  видимый символ
        Result := Result + c;
      end;
    end;
  end;
end;

function DataStrToHexStr(const AsDataStr: AnsiString; AsSeparator: AnsiString = ' '): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AsDataStr) do Result := Result + IntToHex(Ord(AsDataStr[i]), 2) + AsSeparator;
  if Length(Result) >= Length(AsSeparator) then SetLength(Result, Length(Result) - Length(AsSeparator));
end;

function AddDataToFile(const AsFileName, AsData: AnsiString): Boolean;
var
  hFile : THandle;
begin
  Result := False;
  if AsData = '' then begin
    Result := True;
    Exit;
  end;

  hFile := CreateFile(PChar(AsFileName), GENERIC_WRITE, FILE_SHARE_READ, Nil, OPEN_ALWAYS, 0, 0);
  try
    if hFile = INVALID_HANDLE_VALUE then Exit;

    FileSeek(hFile, 0, FILE_END);
    FileWrite(hFile, AsData[1], Length(AsData));
    FlushFileBuffers(hFile);

    Result := True;
  finally
    CloseHandle(hFile);
  end;
end;

function sErrInterval(Ai6Value, Ai6Min, Ai6Max: Int64; const AusName: UTF8String = ''): UTF8String;
begin
  Result := '';
  if (Ai6Value < Ai6Min) or (Ai6Value > Ai6Max) then begin
    Result := Format('Invalid %s value %d, must be in limits [%d...%d]', [AusName, Ai6Value, Ai6Min, Ai6Max]);
  end;
end;

function sErrNotInEnum(Ai6Value: Int64; const AarcstEnums: array of Int64; const AusName: UTF8String = ''): UTF8String;
const
  S_SEPARATOR = ', ';
var
  i: Integer;
  sVariants: AnsiString;
begin
  Result := '';
  for i := Low(AarcstEnums) to High(AarcstEnums) do if Ai6Value = AarcstEnums[i] then Exit;

  sVariants := '';
  for i := Low(AarcstEnums) to High(AarcstEnums) do sVariants := sVariants + IntToStr(AarcstEnums[i]) + S_SEPARATOR;
  if Length(sVariants) >= Length(S_SEPARATOR) then SetLength(sVariants, Length(sVariants) - Length(S_SEPARATOR));

  Result := Format('Invalid %s value %d, must be from variants [%s]', [AusName, Ai6Value, sVariants]);
end;

function sErrNonIntStr(const AsValue: AnsiString; out AiValue: Integer; const AusName: UTF8String = ''): UTF8String;
begin
  Result := '';
  if TryStrToInt(AsValue, AiValue) then Exit;

  Result := Format('Invalid %s integer value %s', [AusName, AsValue]);
end;

function sErrNonInt64Str(const AsValue: AnsiString; out Ai6Value: Int64; const AusName: UTF8String = ''): UTF8String;
begin
  Result := '';
  if TryStrToInt64(AsValue, Ai6Value) then Exit;

  Result := Format('Invalid %s integer value %s', [AusName, AsValue]);
end;

function sErrNonDecStr(const AsValue: AnsiString; AiDecimDigitQntty: Integer; out Ai6Value: Int64; AcNeedDecimSepar: AnsiChar = '.'; const AusName: UTF8String = ''): UTF8String;
begin
  Result := '';
  if DecStrToInt(AsValue, AiDecimDigitQntty, Ai6Value, AcNeedDecimSepar) then Exit;

  Result := Format('Invalid %s decimal string value %s', [AusName, AsValue]);
end;

function SetValInLims(Ai6Val, Ai6Min, Ai6Max: Int64): Int64;
begin
  Result := Ai6Val;
  if Result < Ai6Min then Result := Ai6Min;
  if Result > Ai6Max then Result := Ai6Max;
end;

function iSelfVersion(AiPart: Integer = 3): Integer;
var
  sModuleName: AnsiString;
  pBuf: Pointer;
  lwBufSize: LongWord;
  pFixedFileInfo: PVSFixedFileInfo;
  lwValueLen: LongWord;
begin
  Result := 0;
  sModuleName := GetSelfModuleFileName;
  lwBufSize := GetFileVersionInfoSize(PAnsiChar(sModuleName), lwBufSize);
  if lwBufSize > 0 then begin
    pBuf := AllocMem(lwBufSize);
    try
      if not GetFileVersionInfo(PAnsiChar(sModuleName), 0, lwBufSize, pBuf) then Exit;
      if not VerQueryValue(pBuf, '\', Pointer(pFixedFileInfo), lwValueLen) then Exit;
      case AiPart of
        1: Result := pFixedFileInfo.dwFileVersionMS shr 16;
        2: Result := pFixedFileInfo.dwFileVersionMS and $FFFF;
        3: Result := pFixedFileInfo.dwFileVersionLS shr 16;
        4: Result := pFixedFileInfo.dwFileVersionLS and $FFFF;
      end;
    finally
      FreeMem(pBuf, lwBufSize);
    end;
  end;
end;

function sVersion: AnsiString;
var
  sModuleName: AnsiString;
  pBuf: Pointer;
  lwBufSize: LongWord;
  pFixedFileInfo: PVSFixedFileInfo;
  lwValueLen: LongWord;
begin
  Result := 'Unknown version';

  sModuleName := GetSelfModuleFileName;
  lwBufSize := GetFileVersionInfoSize(PAnsiChar(sModuleName), lwBufSize);
  if lwBufSize > 0 then begin
    pBuf := AllocMem(lwBufSize);
    try
      if not GetFileVersionInfo(PAnsiChar(sModuleName), 0, lwBufSize, pBuf) then Exit;

      if not VerQueryValue(pBuf, '\', Pointer(pFixedFileInfo), lwValueLen) then Exit;

      Result := IntToStr(pFixedFileInfo.dwFileVersionMS shr 16) + '.' + IntToStr(pFixedFileInfo.dwFileVersionMS and $FFFF) + '.' + 
                IntToStr(pFixedFileInfo.dwFileVersionLS shr 16) + '.' + IntToStr(pFixedFileInfo.dwFileVersionLS and $FFFF);
    finally
      FreeMem(pBuf, lwBufSize);
    end;
  end;
end;

function sDescription(const AsDefaultDescription: AnsiString): AnsiString;
const
  LangIds   : array [0..1] of cardinal = ($0419, $0409);
  Encodings : array [0..1] of cardinal = ($04E3, $04E4);
var
  sModuleName: AnsiString;
  pBuf: Pointer;
  lwBufSize: LongWord;
  pcValue: PAnsiChar;
  lwValueLen: LongWord;
  iLang, iEncoding: Integer;
  sResId: string;
begin
  Result := AsDefaultDescription;

  sModuleName := GetSelfModuleFileName;
  lwBufSize := GetFileVersionInfoSize(PAnsiChar(sModuleName), lwBufSize);
  if lwBufSize > 0 then begin
    pBuf := AllocMem(lwBufSize);
    try
      if not GetFileVersionInfo(PAnsiChar(sModuleName), 0, lwBufSize, pBuf) then Exit;

      for iLang := Low(LangIds) to High(LangIds) do begin
        for iEncoding := Low(Encodings) to High(Encodings) do begin
          sResId := Format('StringFileInfo\%.4X%.4X\FileDescription', [LangIds[iLang], Encodings[iEncoding]]);
          if VerQueryValue(pBuf, PAnsiChar(sResId), Pointer(pcValue), lwValueLen) then begin
            Result := CodePageToUTF8(Encodings[iEncoding], pcValue);
            Exit;
          end;
        end;
      end;

    finally
      FreeMem(pBuf, lwBufSize);
    end;
  end;
end;

function IsBitSet(const AData; AiBitNum: Integer): Boolean;
var
  b: Byte;
begin
  Move(AData, b, 1);
  Result := (b and (1 shl AiBitNum)) > 0;
end;

function IsBitSetInt(Ai6Data: Int64; AiBitNum: Integer): Boolean;
begin
  Result := (Ai6Data and (1 shl AiBitNum)) > 0;
end;

function IntToDecStr(Ai6Value: Int64; AiDecimDigitQntty: Integer; AcNeedDecimSepar: AnsiChar = '.'; AisShowDecimZeros: Boolean = False): AnsiString;
var
  isMinus: Boolean;
begin
  isMinus := (Ai6Value < 0);
  Result := IntToStr(Abs(Ai6Value));

  while Length(Result) < AiDecimDigitQntty + 1 do Result := '0' + Result;

  Insert(AcNeedDecimSepar, Result, Length(Result) - AiDecimDigitQntty + 1);
  if isMinus then Result := '-' + Result;

  if AisShowDecimZeros then Exit;

  while (Pos(AcNeedDecimSepar, Result) > 0) and ((Result[Length(Result)] = '0') or (Result[Length(Result)] = AcNeedDecimSepar)) do begin
    SetLength(Result, Length(Result) - 1);
  end;
end;

function DecStrToInt(AsValue: AnsiString; AiDecimDigitQntty: Integer; out Ai6Value: Int64; AcNeedDecimSepar: AnsiChar = '.'): Boolean;
var
  iPos, iFrag: Integer;
begin
  Result := False;

  iPos := Pos(AcNeedDecimSepar, AsValue);
  if iPos > 0 then begin
    iFrag := Length(AsValue) - iPos;
    if iFrag > AiDecimDigitQntty then SetLength(AsValue, Length(AsValue) - iFrag + AiDecimDigitQntty);
    if iFrag < AiDecimDigitQntty then AsValue := AsValue + StringOfChar('0', AiDecimDigitQntty - iFrag);
    Delete(AsValue, iPos, 1);
  end else begin
    AsValue := AsValue + StringOfChar('0', AiDecimDigitQntty);
  end;

  if not TryStrToInt64(AsValue, Ai6Value) then Exit;

  Result := True;
end;

function SysErrorMessageUTF8(ErrorCode: Integer): UTF8String;
var
  Buffer: array[0..255] of WChar;
  BufferUTF8: array[0..512] of Char;
var
  Len,UTF8Len: Integer;
begin
  Len := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or
    FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, Buffer,
    256, nil);
  while (Len > 0) and ((ord(Buffer[Len - 1])<=32) or (ord(Buffer[Len - 1])=ord('.'))) do Dec(Len);

  UTF8Len:=UnicodeToUtf8(BufferUTF8, sizeof(Buffer), Buffer, Len);

  SetString(Result,BufferUTF8,UTF8Len);
end;

function HexStrToBin(const s:string):string;
var i,n,err:integer;
begin
  Result:='';
  i:=1;
  while i<=length(s) do
    if s[i] in ['$',' ','h','H',',',';'] then
      inc(i)
    else begin
      if copy(s,i,2)<>'0x' then begin
        if (i=length(s)) or (s[i+1] in [' ','h','H',',',';']) then
          Val('$'+s[i],n,err)
        else
          Val('$'+copy(s,i,2),n,err);
        if err<>0 then
          break;
        Result:=Result+chr(n);
      end;
      inc(i,2);
    end;
end;

procedure IncWrap(var v: byte); overload;
begin
  if v = High(v) then v := Low(v) else Inc(v);
end;

procedure IncWrap(var v: word); overload;
begin
  if v = High(v) then v := Low(v) else Inc(v);
end;

procedure IncWrap(var v: integer); overload;
begin
  if v = High(v) then v := Low(v) else Inc(v);
end;

procedure IncWrap(var v: cardinal); overload;
begin
  if v = High(v) then v := Low(v) else Inc(v);
end;

procedure DecWrap(var v: byte); overload;
begin
  if v = Low(v) then v := High(v) else Dec(v);
end;

procedure DecWrap(var v: word); overload;
begin
  if v = Low(v) then v := High(v) else Dec(v);
end;

procedure DecWrap(var v: integer); overload;
begin
  if v = Low(v) then v := High(v) else Dec(v);
end;

procedure DecWrap(var v: cardinal); overload;
begin
  if v = Low(v) then v := High(v) else Dec(v);
end;

function HexCharToInt(AcHex: AnsiChar; const AsFieldName: AnsiString; out AsError: AnsiString): Byte;
begin
  Result := 0;
  AsError := '';
  case AcHex of
    '0'..'9': Result := Ord(AcHex) - Ord('0');
    'A'..'F': Result := Ord(AcHex) - Ord('A') + $A;
    'a'..'f': Result := Ord(AcHex) - Ord('a') + $A;
  else
    AsError := Format('Invalid %s HEX symbol: %s', [AsFieldName, DataStrToShowStr(AcHex)]);
  end;
end;

function HexToInt(const AsHex, AsFieldName: AnsiString; out Ai6Result: Int64): AnsiString;
var
  i: Integer;
  sFieldValue: AnsiString;
begin
  Ai6Result := 0;
  Result := 'Unexpected exit';

  sFieldValue := Format('HEX value %s = "%s"', [AsFieldName, AsHex]);
  if Length(AsHex) > SizeOf(Int64) * 2 then begin
    Result := sFieldValue + ' is too long for correct Hex value';
    Exit;
  end;

  if Length(AsHex) < 1 then begin
    Result := sFieldValue + ' is too short for correct Hex value';
    Exit;
  end;

  for i := 1 to Length(AsHex) do begin
    Ai6Result := (Ai6Result shl 4) + HexCharToInt(AsHex[i], sFieldValue, Result);
    if Result <> '' then Exit;
  end;  

  Result := '';
end;

function CRC16_CCITT(const AsData: AnsiString; AwInitValue: Word = $FFFF): Word;
const
  CRC_TAB: array[0..$FF] of word = (
    $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
    $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
    $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
    $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
    $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
    $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
    $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
    $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
    $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
    $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
    $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
    $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
    $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
    $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
    $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
    $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
    $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
    $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
    $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
    $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
    $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
    $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
    $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
    $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0
  );
var
  i: Integer;
begin
  Result := AwInitValue;
  for i := 1 to Length(AsData) do begin
    Result := Word(Result shl 8) xor CRC_TAB[(Result shr 8) xor Ord(AsData[i])];
  end;
end;

function CRC16(const AsData: AnsiString; AwPolinom, AwInitValue: Word): Word;
var
  i: Integer;
  j: Integer;
begin
  Result := AwInitValue;

  {$R-} // ¬ременно отключаем контроль переполнени€

  for i := 1 to Length(AsData) do begin
    Result := Result xor Byte(AsData[i]);

    for j := 1 to 8 do if (Result and $0001) <> 0 then begin
      Result := Result shr 1;
      Result := Result xor AwPolinom;
    end else begin
      Result := Result shr 1;
    end;
  end;

  {$R+} // ¬осстанавливаем контроль переполнени€
end;

function FlipW(AwValue: Word): Word;
begin
  Result := (AwValue shr 8) or Word(LongWord(AwValue) shl 8);
end;

function ExtractValueByName(const AsData, AsName, AsValuNameDlmt, AsPairPairDlmt: AnsiString): AnsiString;
var
  iPos: Integer;
begin
  Result := '';

  iPos := Pos(AsName + AsValuNameDlmt, AsData);
  if iPos = 0 then Exit;

  Result := Copy(AsData, iPos + Length(AsName + AsValuNameDlmt), Length(AsData));

  iPos := Pos(AsPairPairDlmt, Result);

  if iPos <> 0 then Result := Copy(Result, 1, iPos - 1);
end;

function WtoLE(AwData: Word): AnsiString;
begin
  Result := Chr(Byte(AwData)) + Chr(Byte(AwData shr 8));
end;

function DWtoLE(AdwData: DWORD): AnsiString;
begin
  Result := WtoLE(Word(AdwData)) + WtoLE(Word(AdwData shr 16));
end;

function I6toLE(Ai6Data: Int64): AnsiString;
begin
  Result := DWtoLE(DWORD(Ai6Data)) + DWtoLE(DWORD(Ai6Data shr 32));
end;

function WtoBE(AwData: Word): AnsiString;
begin
  Result := Chr(Byte(AwData shr 8)) + Chr(Byte(AwData));
end;

function DWtoBE(AdwData: DWORD): AnsiString;
begin
  Result := WtoBE(Word(AdwData shr 16)) + WtoBE(Word(AdwData));
end;

function LEtoW(const AsData: AnsiString): Word;
begin
  Result := 0;
  if Length(AsData) >= 1 then Result := Result + (Word(Ord(AsData[1])) shl (8 * (1 - 1)));
  if Length(AsData) >= 2 then Result := Result + (Word(Ord(AsData[2])) shl (8 * (2 - 1)));
end;

function LEtoDW(const AsData: AnsiString): DWORD;
begin
  Result := LEtoW(AsData) + (DWORD(LEtoW(Copy(AsData, 2 + 1, 2))) shl (8 * 2));
end;

function LEtoI6(const AsData: AnsiString): Int64;
begin
  Result := Int64(LEtoDW(AsData)) + (Int64(LEtoDW(Copy(AsData, 4 + 1, 4))) shl (8 * 4));
end;

function BEtoW(const AsData: AnsiString): Word;
begin
  Result := 0;
  if Length(AsData) >= 1 then Result := (Result shl 8) + Ord(AsData[1]);
  if Length(AsData) >= 2 then Result := (Result shl 8) + Ord(AsData[2]);
end;

function BEtoDW(const AsData: AnsiString): DWORD;
begin
  Result := 0;
  if Length(AsData) >= 1 then Result := (Result shl 8) + Ord(AsData[1]);
  if Length(AsData) >= 2 then Result := (Result shl 8) + Ord(AsData[2]);
  if Length(AsData) >= 3 then Result := (Result shl 8) + Ord(AsData[3]);
  if Length(AsData) >= 4 then Result := (Result shl 8) + Ord(AsData[4]);
end;

function BEtoI6(const AsData: AnsiString): Int64;
begin
  Result := 0;
  if Length(AsData) >= 1 then Result := (Result shl 8) + Ord(AsData[1]);
  if Length(AsData) >= 2 then Result := (Result shl 8) + Ord(AsData[2]);
  if Length(AsData) >= 3 then Result := (Result shl 8) + Ord(AsData[3]);
  if Length(AsData) >= 4 then Result := (Result shl 8) + Ord(AsData[4]);
  if Length(AsData) >= 5 then Result := (Result shl 8) + Ord(AsData[5]);
  if Length(AsData) >= 6 then Result := (Result shl 8) + Ord(AsData[6]);
  if Length(AsData) >= 7 then Result := (Result shl 8) + Ord(AsData[7]);
  if Length(AsData) >= 8 then Result := (Result shl 8) + Ord(AsData[8]);
end;

function LEtoVLN(const AsData: AnsiString): Int64;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AsData) do begin
    Result := Result + (Int64(Ord(AsData[i])) shl (8 * (i - 1)));
  end;
end;

function BEtoVLN(const AsData: AnsiString): Int64;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AsData) do begin
    Result := (Result shl 8) + Ord(AsData[i]);
  end;
end;

function XORbyte(const AsData: AnsiString): Byte;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AsData) do Result := Result xor Byte(Ord(AsData[i]));
end;

function GetTickDiff(AdwTickBegin, AdwTickEnd: DWORD): DWORD;
begin
  if AdwTickEnd >= AdwTickBegin then Result := AdwTickEnd - AdwTickBegin else Result := High(DWORD) - AdwTickBegin + AdwTickEnd + 1;
end;

function StrToIntLim(const AsVal: AnsiString; AiMin, AiMax: Integer; out AiVal: Integer): Boolean;
var
  iVal: Integer;
begin
  Result := False;

  if not TryStrToInt(AsVal, iVal) then Exit;

  if iVal < AiMin then Exit;
  if iVal > AiMax then Exit;

  AiVal := iVal;
  Result := True;
end;

function ParseDateTime(const AsDateTime, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;
type
  TeFld =                             (_yyyy_, _yy_, _mm_, _dd_, _hh_, _nn_, _ss_);
const
  S_FLD: array[TeFld] of AnsiString = ('yyyy', 'yy', 'mm', 'dd', 'hh', 'nn', 'ss');
var
  iPos, iLen: Integer;
  eFld: TeFld;
  sFrm, sVal: AnsiString;
  isFound: Boolean;
  iYYYY, iMM, iDD, iHH, iNN, iSS: Integer;
begin
  iYYYY := 0;
  iMM   := 1;
  iDD   := 1;
  iHH   := 0;
  iNN   := 0;
  iSS   := 0;
  iPos := 1;
  while (iPos <= Length(AsDateTime)) and (iPos <= Length(AsFormat)) do begin
    Result := 'Wrong format on pos ' + IntToStr(iPos);
    isFound := False;
    for eFld := Low(TeFld) to High(TeFld) do begin
      sFrm := S_FLD[eFld];
      iLen := Length(sFrm);
      if SameText(Copy(AsFormat, iPos, iLen), sFrm) then begin
        isFound := True;
        sVal := Copy(AsDateTime, iPos, iLen);
        case eFld of
          _yyyy_: if not StrToIntLim(sVal, 0, 9999, iYYYY) then Exit;
          _yy_: begin
            if not StrToIntLim(sVal, 0, 99, iYYYY) then Exit;
            iYYYY := iYYYY + 2000;
          end;
          _mm_: if not StrToIntLim(sVal, 1, 12, iMM) then Exit;
          _dd_: if not StrToIntLim(sVal, 1, 31, iDD) then Exit;
          _hh_: if not StrToIntLim(sVal, 0, 23, iHH) then Exit;
          _nn_: if not StrToIntLim(sVal, 0, 59, iNN) then Exit;
          _ss_: if not StrToIntLim(sVal, 0, 59, iSS) then Exit;
        else
          Assert(False);
        end;
        Inc(iPos, iLen);
        Break;
      end;     
    end;
    if isFound then Continue;
    if AsDateTime[iPos] <> AsFormat[iPos] then Exit;
    Inc(iPos);
  end;
  Result := 'Wrong field values';
  if not TryEncodeDateTime(iYYYY, iMM, iDD, iHH, iNN, iSS, 0, AdtResult) then Exit;
  Result := '';
end;

function ParseDate(const AsDate, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;
type
  TeFld =                             (_yyyy_, _yy_, _mm_, _dd_, ___);
const
  S_FLD: array[TeFld] of AnsiString = ('yyyy', 'yy', 'mm', 'dd', '*');
var
  iPos, iLen: Integer;
  eFld: TeFld;
  sFrm, sVal: AnsiString;
  isFound: Boolean;
  iYYYY, iYY, iMM, iDD: Integer;
begin
  iYYYY := 0;
  iMM   := 1;
  iDD   := 1;
  iPos := 1;
  while (iPos <= Length(AsDate)) and (iPos <= Length(AsFormat)) do begin
    Result := 'Wrong format on pos ' + IntToStr(iPos);
    isFound := False;
    for eFld := Low(TeFld) to High(TeFld) do begin
      sFrm := S_FLD[eFld];
      iLen := Length(sFrm);
      if Copy(AsFormat, iPos, iLen) = sFrm then begin
        isFound := True;
        sVal := Copy(AsDate, iPos, iLen);
        case eFld of
          _yyyy_: if not StrToIntLim(sVal, 0, 9999, iYYYY) then Exit;
          _yy_: begin
            if not StrToIntLim(sVal, 0, 99, iYY) then Exit;
            iYYYY := iYY + 2000;
          end;
          _mm_: if not StrToIntLim(sVal, 1, 12, iMM) then Exit;
          _dd_: if not StrToIntLim(sVal, 1, 31, iDD) then Exit;
          ___: ; // any symbol -> skip
        else
          Assert(False);
        end;
        Inc(iPos, iLen);
        Break;
      end;     
    end;
    if isFound then Continue;
    if AsDate[iPos] <> AsFormat[iPos] then Exit;
    Inc(iPos);
  end;
  Result := 'Wrong field values';
  if not TryEncodeDate(iYYYY, iMM, iDD, AdtResult) then Exit;
  Result := '';
end;

function ParseTime(const AsTime, AsFormat: AnsiString; out AdtResult: TDateTime): AnsiString;
type
  TeFld =                             (_hh_, _nn_, _ss_, _zzz_, ___);
const
  S_FLD: array[TeFld] of AnsiString = ('hh', 'nn', 'ss', 'zzz', '*');
var
  iPos, iLen: Integer;
  eFld: TeFld;
  sFrm, sVal: AnsiString;
  isFound: Boolean;
  iHH, iNN, iSS, iZZZ: Integer;
begin
  iHH   := 0;
  iNN   := 0;
  iSS   := 0;
  iZZZ  := 0;
  iPos := 1;
  while (iPos <= Length(AsTime)) and (iPos <= Length(AsFormat)) do begin
    Result := 'Wrong format on pos ' + IntToStr(iPos);
    isFound := False;
    for eFld := Low(TeFld) to High(TeFld) do begin
      sFrm := S_FLD[eFld];
      iLen := Length(sFrm);
      if Copy(AsFormat, iPos, iLen) = sFrm then begin
        isFound := True;
        sVal := Copy(AsTime, iPos, iLen);
        case eFld of
          _hh_: if not StrToIntLim(sVal, 0, 23, iHH) then Exit;
          _nn_: if not StrToIntLim(sVal, 0, 59, iNN) then Exit;
          _ss_: if not StrToIntLim(sVal, 0, 59, iSS) then Exit;
          _zzz_: if not StrToIntLim(sVal, 0, 999, iZZZ) then Exit;
          ___: ; // any symbol -> skip
        else
          Assert(False);
        end;
        Inc(iPos, iLen);
        Break;
      end;     
    end;
    if isFound then Continue;
    if AsTime[iPos] <> AsFormat[iPos] then Exit;
    Inc(iPos);
  end;
  Result := 'Wrong field values';
  if not TryEncodeTime(iHH, iNN, iSS, iZZZ, AdtResult) then Exit;
  Result := '';
end;

end.
