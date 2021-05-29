unit uLog;

interface

uses
   Windows
  ,SysUtils
  ;

const //  уровни логирования
  llWARNING       = -2; // логируется всегда, не задаётся в параметрах, предупреждения
  llALWAYS        = -1; // логируется всегда, не задаётся в параметрах
  llERROR         =  0; // логируются только ошибки
  llEXP_FUNC_CALL =  1; // логируется выполение только экспортируемых функций
  llDEV_FUNC_CALL =  2; // логируется выполнение функций устройства
  llSERIAL_TRANS  =  3; // логируется низкий уровень транзакций (данные COM-порта, сетевого сокета и т.п.)
  llPHYSIC_TRAFIC =  4; // логируется трафик физического уровня
  llTALKATIVE     =  5; // логируется все
  llOSFUNC        =  6; // логируется вызов некоторых функций операционной системы

const
  I_LOG_ROTATE_SIZE_DEF  = 1024 * 1024;
  I_LOG_ROTATE_COUNT_DEF = 1;

type
  TLog = class
  public //  при уровне 0 пишется только информация с Level = 0 - самый молчаливый режим, при максимальном уровне пишется все, но этот уровень может быть разный в разных проектах
    constructor Create(AiNumber: Integer; const AusHeader: UTF8String; AiLevel: Integer = 0; AiRotateSize: Integer = I_LOG_ROTATE_SIZE_DEF; AiRotateCount: Integer = I_LOG_ROTATE_COUNT_DEF);
    destructor Destroy; override;
    procedure Log(AiLevel: Integer; const AusText: UTF8String; AisFlushBuf: Boolean = False);
    procedure EndInitBlock;
    procedure ClearDetailBlock;
    procedure Rotate;
  private
    procedure fLogWrite(const AusText: UTF8String);
    procedure fFlushBuf;
    procedure fRotate;
  private
    FiNumber: Integer;
    FsFileName: AnsiString;
    FiLevel: Integer;
    FarbLogBuf: array of Byte;
    FiLogPos: Integer;
    FiRotateSize: Integer;
    FiRotateCount: Integer;
    FRTLCriticalSection: TRTLCriticalSection;
    FusHeader: UTF8String;
  private
    FisInitBlock: Boolean;
    FusInitBlock: UTF8String;
    FisDetailBlock: Boolean;
    FusDetailBlock: UTF8String;
  public
    property iLevel: Integer read FiLevel;
    property iNumber: Integer read FiNumber;
  end;

implementation

const
  S_UTF8_BOM = #$EF#$BB#$BF;
  S_CRLF = #$0D#$0A;
  S_BLOCK_ENTER_FORMAT = S_CRLF + '++++++++++++ %s block enter { ++++++++++++++++++++++++++++++++++++++++++' + S_CRLF + S_CRLF;
  S_BLOCK_LEAVE_FORMAT = S_CRLF + '------------ %s block leave } ----------------------------------------' + S_CRLF + S_CRLF;
  I_INIT_BLOCK_MAX_SIZE = 128 * 1024;
  I_DETAIL_BLOCK_MAX_SIZE = 128 * 1024;

{ TLog }

constructor TLog.Create(AiNumber: Integer; const AusHeader: UTF8String; AiLevel: Integer = 0; AiRotateSize: Integer = I_LOG_ROTATE_SIZE_DEF; AiRotateCount: Integer = I_LOG_ROTATE_COUNT_DEF);
const
  I_APRIORI_SIZE = $FF;
begin
  Inherited Create;
  FiNumber := AiNumber;
  FiLevel := AiLevel;

  FiRotateSize := AiRotateSize;
  FiRotateCount := AiRotateCount;

  FusHeader := AusHeader;

  SetLength(FsFileName, I_APRIORI_SIZE);
  SetLength(FsFileName, GetModuleFileName(hInstance, @FsFileName[1], Length(FsFileName)));

  if AiNumber >= 0 then begin
    FsFileName := Format('%s_%d.LOG', [ChangeFileExt(FsFileName, ''), AiNumber]);
  end else begin
    FsFileName := Format('%s.LOG', [ChangeFileExt(FsFileName, '')]);
  end;

  InitializeCriticalSection(FRTLCriticalSection);

  FisInitBlock := True;
  FusInitBlock := Format(S_BLOCK_ENTER_FORMAT, ['copy of init']);

  FisDetailBlock := FiLevel <= llERROR;
end;

destructor TLog.Destroy;
begin
  fFlushBuf;
  inherited;
end;

procedure Tlog.fRotate;
var
  sFileName: AnsiString;
  sFileExt : AnsiString;
  sOldFileName: AnsiString;
  sNewFileName: AnsiString;
  i: Integer;
begin
  if FiRotateCount < 1 then Exit;

  sFileName := ChangeFileExt(FsFileName, '');
  sFileExt  := ExtractFileExt(FsFileName);

  for i := FiRotateCount downto 1 do begin
    sNewFileName := Format('%s.%d%s', [sFileName, i, sFileExt]);
    if i <> 1 then begin
      sOldFileName := Format('%s.%d%s', [sFileName, i - 1, sFileExt]);
    end else begin
      sOldFileName := Format('%s%s', [sFileName, sFileExt]);
    end;
    DeleteFile(sNewFileName);
    RenameFile(sOldFileName, sNewFileName);
  end;
end;

procedure TLog.fFlushBuf;
var
  Handle: THandle;
  lwRes: Cardinal;
  i6Size: Int64;
  dwFilePos: DWORD;
  iDistanceToMove: Integer;
  usFileHeader: UTF8String;
begin
  try
    try
      if FiLogPos = 0 then Exit;
      if (FsFileName <> '') then begin
        Handle := CreateFile(PChar(FsFileName), GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
        if Handle <> INVALID_HANDLE_VALUE then begin
          iDistanceToMove := 0;
          dwFilePos := SetFilePointer(Handle, iDistanceToMove, nil, FILE_END);
          if (dwFilePos < 10) and (iDistanceToMove = 0) then begin
            usFileHeader := S_UTF8_BOM;
            if FusHeader <> '' then usFileHeader := usFileHeader + FusHeader + S_CRLF;
            if not FisInitBlock and (FusInitBlock <> '') then usFileHeader := usFileHeader + FusInitBlock;
            WriteFile(Handle, usFileHeader[1], Length(usFileHeader), lwRes, nil);
          end;
          WriteFile(Handle, FarbLogBuf[0], FiLogPos, lwRes, nil);
          i6Size := SetFilePointer(Handle, 0, nil, FILE_END);
          CloseHandle(Handle);
          if (FiRotateSize > 0) and (i6Size > FiRotateSize) then fRotate;
        end;
      end;
    except
      on E: Exception do begin // Логгер не имеет права выбрасывать исключения т.к. все необработанные исключения записываются в лог
        MessageBox(0, PAnsiChar('Exception in TLog.FlushBuffer ' + E.Message), 'Error', MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
        OutputDebugString(PAnsiChar('Exception in TLog.FlushBuffer ' + E.Message));
      end;
    end;
  finally
    FiLogPos := 0;
  end;
end;

procedure TLog.fLogWrite(const AusText: UTF8String);
const
  I_BUF_SIZE = 1024 * 128;
var
  iChunkLen: Integer;
  iDataPos: Integer;
  iDataLen: Integer;
begin
  if Length(FarbLogBuf) = 0 then SetLength(FarbLogBuf, I_BUF_SIZE);
  iDataPos := 1;
  iDataLen := 1 + Length(AusText);
  while iDataPos < iDataLen  do begin
    iChunkLen := iDataLen - iDataPos;
    if iChunkLen > Length(FarbLogBuf) - FiLogPos then iChunkLen := Length(FarbLogBuf) - FiLogPos;
    if iChunkLen < 1 then Break;

    Move(AusText[iDataPos], FarbLogBuf[FiLogPos], iChunkLen);

    Inc(iDataPos, iChunkLen);
    Inc(FiLogPos, iChunkLen);

    if FiLogPos = Length(FarbLogBuf) then fFlushBuf;
  end;
end;

procedure TLog.Log(AiLevel: Integer; const AusText: UTF8String; AisFlushBuf: Boolean = False);
const
  S_OFFSET_STEP = '  ';
var
  usDateTime, usTag, usOffset, usLine: UTF8String;
  i: Integer;
begin
  EnterCriticalSection(FRTLCriticalSection);
  try
    usDateTime := FormatDateTime('dd.mm.yy hh:nn:ss.zzz', Now);

    case AiLevel of
      llWARNING       : usTag := 'WRN';
      llALWAYS        : usTag := 'ALW';
      llERROR         : usTag := 'ERR';
      llEXP_FUNC_CALL : usTag := 'EXP';
      llDEV_FUNC_CALL : usTag := 'DEV';
      llSERIAL_TRANS  : usTag := 'SER';
      llPHYSIC_TRAFIC : usTag := 'PHY';
      llTALKATIVE     : usTag := 'TLK';
      llOSFUNC        : usTag := 'OSF';
    else
      usTag := 'UNK';
    end;

    usOffset := ' ';
    for i := 1 to AiLevel do usOffset := usOffset + S_OFFSET_STEP;

    usLine := Format('[%s] [%s] %s%s%s', [usDateTime, usTag, usOffset, AusText, S_CRLF]);

    if AiLevel <= FiLevel then fLogWrite(usLine);

    if FisInitBlock and (Length(FusInitBlock) <= I_INIT_BLOCK_MAX_SIZE) then FusInitBlock := FusInitBlock + usLine;

    if FisDetailBlock and (Length(FusDetailBlock) <= I_DETAIL_BLOCK_MAX_SIZE) then FusDetailBlock := FusDetailBlock + usLine;
    if FisDetailBlock and (AiLevel = llERROR) then begin
      FusDetailBlock := FusDetailBlock + Format(S_BLOCK_LEAVE_FORMAT, ['detail log']);
      fLogWrite(FusDetailBlock);
      ClearDetailBlock;
    end;

    if (AiLevel <= llERROR) or AisFlushBuf then fFlushBuf;
  finally
    LeaveCriticalSection(FRTLCriticalSection);
  end;
end;

procedure TLog.EndInitBlock;
begin
  FusInitBlock := FusInitBlock + Format(S_BLOCK_LEAVE_FORMAT, ['copy of init']);
  FisInitBlock := False;
end;

procedure TLog.ClearDetailBlock;
begin
  if FisDetailBlock then FusDetailBlock := Format(S_BLOCK_ENTER_FORMAT, ['detail log']);
end;

procedure TLog.Rotate;
begin
  fFlushBuf();
  fRotate();
end;

end.
