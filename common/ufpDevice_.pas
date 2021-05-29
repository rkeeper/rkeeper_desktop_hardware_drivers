unit ufpDevice_;

interface

uses
   Windows
  ,SysUtils
  ,Classes
  ,SyncObjs

  ,uLog
  ,uLoclz
  ,uCommon
  ,uCallbacks
  ,uStack32
  ,uXMLcommon
  ,uUnFiscXml_

  ,ufpInitXmlReturn_
  ,ufpDrivParamsXml
  ,ufpFiscDocXml_
  ,ufpProgramXml_
  ,ufpBaseProto_
  ,ufpResult_
  ,ufpStatus

  ,uProto
  ,uDeviceCnst
  ;

type
  TUFRdevice = class
  public
    constructor Create(AiNumber: Integer; ApcXMLParams : PAnsiChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc; ApcXMLreturnBuf: PAnsiChar); virtual;
    destructor  Destroy; override;
    procedure BeforeLastInstanceDestroy;
  public
    procedure CustomerDisplay(ApcXMLBuffer: PAnsiChar; Flags: Integer); virtual;
    procedure GetStatus(var AUFRStatus: TUFRStatus; AdwFieldsNeeded: DWord); virtual;
    procedure UnfiscalPrint(ApcXMLBuffer: PAnsiChar; Flags: Integer); virtual;
    procedure FiscalDocument(ApcXMLDoc: PAnsiChar; var AUFRStatus: TUFRStatus; var AdwFieldsFilled: Cardinal); virtual;
    procedure Programming(ApcXMLDoc: PAnsiChar); virtual;
    procedure OpenDrawer(DrawerNum: Integer); virtual;
    procedure GetZReportData(ApcXMLData: PAnsiChar; var  XMLDataSize: Integer); virtual;
    procedure GetOptions(var Ai6Options: Int64; Var  DriverName, VersionInfo, DriverState: OpenString); virtual;
    procedure Started; virtual;
    procedure MenuOperation(ApcXMLData: PAnsiChar; ApcXMLReturn: PAnsiChar); virtual;
    class function MaxProtocolSupported: Integer; virtual;
    class function MinProtocolSupported: Integer; virtual;
  protected
    FiNumber: Integer;
    FParameters: TParameters;
    FCallBacks: TCallBacks;
    FLog: TLog;
    FResult: TUFRresult;
    FfpStatus: TfpStatus;
    FProto: TBaseProto;
    FCriticalSection: TCriticalSection;
  private
    function  fCommonParamsProc(AiNumber: Integer; ApcXMLParams : PAnsiChar): AnsiString;
    function  fXMLreturnProc(ApcXMLreturnBuf: PAnsiChar) : Boolean;
    procedure ResultSaveToLog(const AusSelfFuncName: UTF8String; ApcXMLreturn: PAnsiChar = nil);
  public
    property iNumber: Integer read FiNumber;
    property Result: TUFRresult read FResult;
    property Proto: TBaseProto read FProto;
  end;
  TUFRdeviceClass = class of TUFRdevice;

implementation

type  //  параметры LowDriverParams
  TeCommonParam = (  //  константам значения НЕ назначать!
     comparLogLevel     //  0...6 (ErrorOnly...OsFunc), def = 0
    ,comparLogRotateSize  // 0 - no rotate on size
    ,comparLogRotateCount // 0 - no rotate
    ,comparMsgLanguage //  Language of messages, the string matches with the extension of the localisation file, for example: ENG, RUS etc
  );
const
  S_COMMON_PARAM_NAME: array[TeCommonParam] of AnsiString = ( //  названия параметров в XML-файле конфигурации
     'LogLevel'     //  parLOG_LEVEL
    ,'LogRotateSize'  //  comparLogRotateSize
    ,'LogRotateCount' //  comparLogRotateCount
    ,'MsgLanguage'  //  parMsgLanguage
  );
  S_COMMON_PARAM_DEF_VAL: array[TeCommonParam] of AnsiString = (
      '5'    //  parLOG_LEVEL
     ,'10'  //  comparLogRotateSize
     ,'1'    //  comparLogRotateCount
    ,'ENG'  //  parMsgLanguage
  );
  IS_COMMON_PARAM_INT: array[TeCommonParam] of Boolean = (
      True   //  parLOG_LEVEL
     ,True  //  comparLogRotateSize
     ,True  //  comparLogRotateCount
    ,False  //  parMsgLanguage
  );

{ TUFRdevice }

constructor TUFRdevice.Create(AiNumber: Integer; ApcXMLParams: PChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc; ApcXMLreturnBuf: PAnsiChar);
var
  sError: AnsiString;
  ExcEBP: Pointer;
begin
  FCriticalSection := TCriticalSection.Create;
  FiNumber := AiNumber;
  FResult      := nil;
  FfpStatus    := nil;
  FCallBacks   := nil;
  FParameters  := nil;
  FProto       := nil;

  if Assigned(ApcXMLreturnBuf) then ApcXMLreturnBuf^ := #0;

  try
    try
      FResult := TUFRresult.Create(errLowInternalError);

      sError := fCommonParamsProc(AiNumber, ApcXMLParams);

      FLog.Log(llALWAYS, Format('======================== Start %s Version %s ===============================', [sDescription(S_DEFAULT_DESCRIPTION), sVersion]), True);
      if Assigned(ApcXMLParams) then FLog.Log(llALWAYS, ApcXMLParams);

      if FResult.SetIfStrError(errAssertInvalidXMLInitializationParams, sError, 'CommonParams create') then Exit;

      FfpStatus := TfpStatus.Create;

      FCallBacks := TCallBacks.Create(FLog);
      FCallBacks.SetCallBacks(AInterfaceCallbackProc, APropCallbackProc);

      FResult.SetValue(errAssertInvalidXMLInitializationParams, '', 'DriverParameters');  //  считывание xml-параметров, заданных в менеджерской станции
      FParameters := TParameters.Create(ApcXMLParams, S_PARAM_NAME, S_PARAM_DEF_VAL, IS_PARAM_INT, sError);
      if FResult.SetIfStrError(errAssertInvalidXMLInitializationParams, sError, 'Parameters create') then Exit;

      if (TProto.MinProtocolSupported > 0) and (FParameters.ProtocolVersion < TProto.MinProtocolSupported) then begin
        FResult.SetValue(errInternalException, Format('Driver %s require at least %d ProtocolVersion', [ExtractFileName(GetSelfModuleFileName), TProto.MinProtocolSupported]), 'TUFRdevice.Create');
        Exit;
      end;

      FResult.SetValue(errLowInternalError, '', 'Device protocol');
      FProto := TProto.Create(FParameters, FCallBacks, FLog, FResult);
      if FResult.iError <> errOk then Exit;

      if not fXMLreturnProc(ApcXMLreturnBuf) then Exit;

      FResult.SetValue(errOk, '');
    except
      {$I uStack32.inc}
      if ExceptObject <> nil then begin
        StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Initialization exception');
        FResult.SetValue(errInternalException, 'Initialization exception: ' + Exception(ExceptObject).Message)
      end else begin
        StackDump(ExcEBP, nil, nil, 'Initialization exception');
        FResult.SetValue(errInternalException, 'Initialization exception');
      end;
    end;
  finally
    ResultSaveToLog('Create', ApcXMLreturnBuf);
    FLog.EndInitBlock;
  end;
end;

destructor TUFRdevice.Destroy;
begin
  FreeAndNil(FProto     );
  FreeAndNil(FfpStatus  );
  FreeAndNil(FResult    );
  FreeAndNil(FParameters);
  FreeAndNil(FCallBacks );

  FLog.Log(llEXP_FUNC_CALL, 'UFRDone() Stop driver', True);
  FreeAndNil(FLog);

  FreeAndNil(FCriticalSection);
end;

procedure TUFRdevice.BeforeLastInstanceDestroy;
begin
  if Assigned(FProto) then FProto.BeforeLastInstanceDestroy;
end;

procedure TUFRdevice.CustomerDisplay(ApcXMLBuffer: PAnsiChar; Flags: Integer);
var
  Unfiscal: TUnfiscal;
  usErrors: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.CustomerDisplay');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    if (ApcXMLBuffer <> nil) then FLog.Log(llEXP_FUNC_CALL, ApcXMLBuffer);
    try
      try
        Unfiscal := TUnfiscal.Create(ApcXMLBuffer, usErrors);
        try
          if FResult.SetIfStrError(errAssertInvalidXMLParams, usErrors, 'CustomerDisplay') then Exit;

          FResult.SetValue(errLowInternalError, '', 'Display');
          FProto.Display(Unfiscal.Unfiscal, FResult);
        finally
          Unfiscal.Free;
        end;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog('CustomerDisplay(..., ' + IntToHex(Flags, 8) + ')');
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.FiscalDocument(ApcXMLDoc: PChar; var AUFRStatus: TUFRStatus; var AdwFieldsFilled: Cardinal);
var
  FiscalDocument: TFiscalDocument;
  usError: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.FiscalDocument');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    if (ApcXMLDoc <> nil) then FLog.Log(llEXP_FUNC_CALL, ApcXMLDoc);
    try
      try
        FfpStatus.EnterProc(0);
        FiscalDocument := TFiscalDocument.Create(ApcXMLDoc, usError);
        try
          if FResult.SetIfStrError(errAssertInvalidXMLParams, usError, 'FiscalDocument.Create') then Exit;

          FResult.SetValue(errLowInternalError, 'Result is not filled', S_DOC_TYPE[FiscalDocument.FiscalDocument.DocType.doct]);
          case FiscalDocument.FiscalDocument.DocType.doct of
            doctNOTHING: ;
            doctRECEIPT,
            doctINVOICE,
            doctDELETION,
            doctRETURNRECEIPT,
            doctRETURN,
            doctRETURNDELETION,
            doctBILL,
            doctCREATEORDER,
            doctCORRECTION,
            doctCLOSEORDER,
            doctCANCELORDER,
            doctCANCELSEAT,
            doctCancelBill       : if not FProto.PrintReceipt          (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctRECEIPTCOPY      : if not FProto.PrintReceiptCopy      (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctCASHINOUT        : if not FProto.PrintCashInOut        (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctCOLLECTALL       : if not FProto.PrintCollectAll       (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctREPORT           : if not FProto.PrintReport           (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctCUSTOM           : if not FProto.Custom                (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctPrintLog         : if not FProto.PrintLog              (FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
            doctCORRECTIONRECEIPT: if not FProto.PrintCorrectionReceipt(FiscalDocument.FiscalDocument, FfpStatus, FResult) then Exit;
          else
            FResult.SetValue(errLowInternalError, 'Unsupported Fiscal document type');
            Exit;
          end;
          if not FfpStatus.LeaveProc(AUFRStatus, AdwFieldsFilled, FResult) then Exit;
        finally
          FiscalDocument.Free;
        end;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog(Format('FiscalDocument(Status[%s])', [FfpStatus.ToLogStr]));
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.GetStatus(var AUFRStatus: TUFRStatus; AdwFieldsNeeded: DWord);
var
  usLog: UTF8String;
  dwFieldsFilled: DWord;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.GetStatus');
    FfpStatus.EnterProc(AdwFieldsNeeded);
    FLog.ClearDetailBlock;
    usLog := Format('%s start, needs 0x%.16x (%s) requested size: %d',
      [FResult.usFuncName, AdwFieldsNeeded, FfpStatus.NeedsToLogStr, AUFRStatus.Size]);
    FLog.Log(llEXP_FUNC_CALL, usLog, FLog.iLevel >= llTALKATIVE);
    try
      try
        FResult.SetValue(errLowInternalError, '', 'GetStatus');
        if not FProto.GetStatus(FfpStatus, FResult) then Exit;

        if not FfpStatus.LeaveProc(AUFRStatus, dwFieldsFilled, FResult) then Exit;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog(Format('GetStatus(%s) internal size %d', [FfpStatus.ToLogStr, SizeOf(AUFRStatus)]));
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.GetZReportData(ApcXMLData: PChar; var XMLDataSize: Integer);
var
  iBegXMLDataSize: Integer;
  ZReportData: TZReportData;
  usXmlRes: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.GetZReportData');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    ZReportData := nil;
    usXmlRes := #0;
    iBegXMLDataSize := XMLDataSize;
    XMLDataSize := 0;
    try
      try
        FResult.SetValue(errLowInternalError, '', 'GetZReportData');
        if not FProto.GetZReportData(ZReportData, FResult) or not Assigned(ZReportData) then Exit;

        usXmlRes := ZReportData.usToXML;
        if (usXmlRes <> '') then FLog.Log(llEXP_FUNC_CALL, usXmlRes);
        usXmlRes := usXmlRes + #0;

        XMLDataSize := Length(usXmlRes);
        if (ApcXMLData = nil) or (iBegXMLDataSize < Length(usXmlRes)) then begin
          FResult.SetValue(errAssertInsufficientBufferSize, '');
        end else begin
          Move(usXmlRes[1], ApcXMLData^, Length(usXmlRes));
        end;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ZReportData.Free;
      ResultSaveToLog(Format('GetZReportData(..., %d -> %d)', [iBegXMLDataSize, XMLDataSize]), PAnsiChar(usXmlRes));
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.GetOptions(var Ai6Options: Int64; var DriverName, VersionInfo, DriverState: OpenString);
const
  S_SEPARATOR = ', ';
var
  setOptions: TsetOptions;
  eOption: TeOption;
  sOptions: AnsiString;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.GetOptions');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    try
      try
        FResult.SetValue(errLowInternalError, '', 'DriverOptions');
        FProto.DriverOptions(setOptions);

        sOptions := '';
        Ai6Options := 0;
        for eOption := Low(TeOption) to High(TeOption) do if eOption in setOptions then begin
          sOptions := sOptions + S_OPTION[eOption] + S_SEPARATOR;
          Ai6Options := Ai6Options or I6_OPTION[eOption];
        end;
        if Length(sOptions) >= Length(S_SEPARATOR) then SetLength(sOptions, Length(sOptions) - Length(S_SEPARATOR));

        DriverName := sDescription(S_DEFAULT_DESCRIPTION);
        VersionInfo := sVersion;
        DriverState := '';

        FResult.SetValue(errOk, '');
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog(Format('GetOptions(0x%s: [%s], %s, %s, %s)', [IntToHex(Ai6Options, 16), sOptions, DriverName, VersionInfo, DriverState]));
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.OpenDrawer(DrawerNum: Integer);
var
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.OpenDrawer');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    try
      try
        FResult.SetValue(errLowInternalError, '', 'OpenDrawer');
        FProto.OpenDrawer(DrawerNum, FResult);
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog('OpenDrawer(' + IntToStr(DrawerNum) + ')');
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.Programming(ApcXMLDoc: PAnsiChar);
var
  ProgramFR: TProgramFR;
  usError: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.Programming');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    if (ApcXMLDoc <> nil) then FLog.Log(llEXP_FUNC_CALL, ApcXMLDoc);
    try
      try
        ProgramFR := TProgramFR.Create(ApcXMLDoc, usError);
        try
          if FResult.SetIfStrError(errAssertInvalidXMLParams, usError) then Exit;

          FResult.SetValue(errLowInternalError, '', 'Programming');
          FProto.Programming(ProgramFR.ProgramFR, FResult);
        finally
          ProgramFR.Free;
        end;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog('Program_');
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.UnfiscalPrint(ApcXMLBuffer: Pchar; Flags: Integer);
var
  Unfiscal: TUnfiscal;
  usError: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.UnfiscalPrint');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    if (ApcXMLBuffer <> nil) then FLog.Log(llEXP_FUNC_CALL, ApcXMLBuffer);
    try
      try
        Unfiscal := TUnfiscal.Create(ApcXMLBuffer, usError);
        try
          if FResult.SetIfStrError(errAssertInvalidXMLParams, usError) then Exit;

          FResult.SetValue(errLowInternalError, '', 'PrintUnfiscal');
          FProto.PrintUnfiscal(Unfiscal.Unfiscal, FResult);
        finally
          Unfiscal.Free;
        end;
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog('UnfiscalPrint(..., ' + IntToHex(Flags, 8) + ')');
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.Started;
var
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.Started');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    try
      try

        FResult.SetValue(errLowInternalError, '', 'Started');
        FProto.Started(FResult);
      except
        {$I uStack32.inc}
        if ExceptObject <> nil then begin
          StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
        end else begin
          StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
          FResult.SetValue(errInternalException, 'Unprocessed exception');
        end;
      end;
    finally
      ResultSaveToLog('UFRStarted');
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TUFRdevice.ResultSaveToLog(const AusSelfFuncName: UTF8String; ApcXMLreturn: pChar = nil);
const
  I_LOG_LEVEL: array[Boolean] of Integer = (llERROR, llEXP_FUNC_CALL);
var
  usToLog: UTF8String;
begin
  try
    if Assigned(ApcXMLreturn) then FLog.Log(llEXP_FUNC_CALL, ApcXMLreturn);

    if Assigned(FResult) then begin
      usToLog := AusSelfFuncName + ' = ' + FResult.usLogText;

      FLog.Log(I_LOG_LEVEL[FResult.iError = errOk], usToLog);
    end else begin
      FLog.Log(llERROR, 'Result class is not created');
    end;
  finally
    FLog.Log(llTALKATIVE, ' ', True); // повышение читаемости лога - пустая строка после экспортируемой функцией
  end;
end;

procedure TUFRdevice.MenuOperation(ApcXMLData: PAnsiChar; ApcXMLReturn: PAnsiChar);
var
  MenuOperation: TMenuOperation;
  usError: UTF8String;
  MenuOperationResult: TMenuOperationResult;
  usXMLreturn: UTF8String;
  ExcEBP: Pointer;
begin
  FCriticalSection.Enter;
  try
    FResult.SetValue(errLowInternalError, '', 'TUFRdevice.MenuOperation');
    FLog.Log(llEXP_FUNC_CALL, FResult.usFuncName + ' start', FLog.iLevel >= llTALKATIVE);
    if (ApcXMLData <> nil) then FLog.Log(llEXP_FUNC_CALL, ApcXMLData);
    try
      FResult.SetValue(errLowInternalError, '', 'MenuOperation.Create');
      MenuOperation := TMenuOperation.Create(ApcXMLData, usError);
      try
        if FResult.SetIfStrError(errAssertInvalidXMLParams, usError) then Exit;

        MenuOperationResult := TMenuOperationResult.Create(MenuOperation.usOperationId);
        try
          FResult.SetValue(errLowInternalError, '', 'MenuOperation');
          FProto.MenuOperation(MenuOperation, MenuOperationResult, FResult);

          if Assigned(ApcXMLReturn) then begin
            ApcXMLReturn^ := #0;

            usXMLreturn := MenuOperationResult.ToXML + #0;
            if Length(usXMLreturn) > 524288 then SetLength(usXMLreturn, 524288);
            Move(usXMLreturn[1], ApcXMLReturn^, Length(usXMLreturn));
          end;
        finally
          MenuOperationResult.Free;
        end;
      finally
        MenuOperation.Free;
      end;
    except
      {$I uStack32.inc}
      if ExceptObject <> nil then begin
        StackDump(ExcEBP, ExceptAddr, ExceptObject, 'Unprocessed exception');
        FResult.SetValue(errInternalException, 'Unprocessed exception: ' + Exception(ExceptObject).Message)
      end else begin
        StackDump(ExcEBP, nil, nil, 'Unprocessed exception');
        FResult.SetValue(errInternalException, 'Unprocessed exception');
      end;
    end;
  finally
    ResultSaveToLog('MenuOperation', ApcXMLReturn);
    FCriticalSection.Leave;
  end;
end;

class function TUFRdevice.MaxProtocolSupported: Integer;
begin
  Result := TProto.MaxProtocolSupported;
end;

class function TUFRdevice.MinProtocolSupported: Integer;
begin
  Result := TProto.MinProtocolSupported;
end;

function TUFRdevice.fCommonParamsProc(AiNumber: Integer; ApcXMLParams: PAnsiChar): AnsiString;
var
  CommonParams: TParameters;
  iLogRotateSize : Integer;
  iLogRotateCount: Integer;
  ExcEBP: Pointer;
begin
  CommonParams := nil;
  FLog := nil;

  try
    CommonParams := TParameters.Create(ApcXMLParams, S_COMMON_PARAM_NAME, S_COMMON_PARAM_DEF_VAL, IS_COMMON_PARAM_INT, Result);
    try
      if Result <> '' then Exit;

      iLogRotateSize := CommonParams[Integer(comparLogRotateSize)].i;
      if iLogRotateSize < 8192 then iLogRotateSize := iLogRotateSize * 1024 * 1024;

      iLogRotateCount := CommonParams[Integer(comparLogRotateCount)].i;

      FLog := TLog.Create(AiNumber, Format('ModuleVersion: %s, %s', [ExtractFileName(GetSelfModuleFileName), sVersion]), CommonParams[Integer(comparLogLevel)].i, iLogRotateSize, iLogRotateCount);

      uLoclz.LoadLanguage(CommonParams[Integer(comparMsgLanguage)].sStringValue);

    finally
      if not Assigned(FLog) then FLog := TLog.Create(AiNumber, Format('ModuleVersion: %s, %s', [ExtractFileName(GetSelfModuleFileName), sVersion])); //  если лог с правильными параметрами не создался, создадим с параметрами по умолчанию

      FreeAndNil(CommonParams);
    end;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'fCommonParamsProc');
      Result := 'Exception ' + Exception(ExceptObject).Message
    end else begin
      StackDump(ExcEBP, nil, nil, 'fCommonParamsProc');
      Result := 'Exception';
    end;
  end;
end;

function TUFRdevice.fXMLreturnProc(ApcXMLreturnBuf: PAnsiChar): Boolean;
var
  setOptions: TsetOptions;
  UFRInitXMLReturn: TUFRInitXMLReturn;
  usXMLreturnBuf: UTF8String;
begin
  Result := False;

  FResult.SetValue(errLowInternalError, '', 'XML return buffer processing');

  if Assigned(ApcXMLreturnBuf) then begin
    ApcXMLreturnBuf^ := #0;
    FProto.DriverOptions(setOptions);
    UFRInitXMLReturn := TUFRInitXMLReturn.Create(setOptions, FProto.MaxProtocolSupported, sDescription(S_DEFAULT_DESCRIPTION), sVersion);
    try
      FProto.DriverMenu(UFRInitXMLReturn.Menu);
      if not FProto.DriverHardware(UFRInitXMLReturn.Hardware, FResult) then Exit;
      if not FProto.DriverDataFormat(UFRInitXMLReturn.DataFormat, FResult) then Exit;
      if not FProto.DriverChangeFromTypeIndexes(UFRInitXMLReturn.ChangeFromTypeIndexes, FResult) then Exit;

      usXMLreturnBuf := UFRInitXMLReturn.ToXML + #0;
      if Length(usXMLreturnBuf) > 524288 then SetLength(usXMLreturnBuf, 524288);
      Move(usXMLreturnBuf[1], ApcXMLreturnBuf^, Length(usXMLreturnBuf));
    finally
      FreeAndNil(UFRInitXMLReturn);
    end;
  end;

  FResult.SetValue(errOk, '');
  Result := True;
end;

end.
