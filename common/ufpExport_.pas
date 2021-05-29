unit ufpExport_;

interface

uses
   Windows
  ,Classes
  ,SysUtils
  ,StrUtils
  ,SyncObjs

  ,uCallbacks
  ,uStack32

  ,ufpStatus
  ,ufpResult_
  ,ufpDevice_
  ;

  procedure UFRDone(Number: Integer); stdcall;
  function  UFRMaxProtocolSupported: integer; stdcall;
  function  UFRCustomerDisplay(Number: Integer; XMLBuffer: PAnsiChar; Flags: Integer): Integer; stdcall;
  function  UFRInit(Number: Integer; XMLParams: PAnsiChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc): Integer; stdcall;
  function  UFRInitXML(Number: Integer; XMLParams: PAnsiChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc; InitXMLReturnBuffer: PAnsiChar): Integer; stdcall;
  function  UFRGetStatus(Number: Integer; var  Status: TUFRStatus; FieldsNeeded: DWord): Integer; stdcall;
  function  UFRUnfiscalPrint(Number: Integer; XMLBuffer: PAnsiChar; Flags: Integer): Integer; stdcall;
  function  UFRFiscalDocument(Number: Integer; XMLDoc: PAnsiChar; var  Status: TUFRStatus; var FieldsFilled: Cardinal): Integer; stdcall;
  function  UFRProgram(Number: Integer; XMLDoc: PAnsiChar): Integer; stdcall;
  function  UFRGetOptions(Number: Integer; var Options: Int64; var  DriverName, VersionInfo, DriverState: OpenString): Integer; stdcall;
  function  UFROpenDrawer(Number: Integer; DrawerNum: Integer): Integer; stdcall;
  function  UFRGetZReportData(Number: Integer; XMLData: PAnsiChar; var  XMLDataSize: Integer): Integer; stdcall;
  procedure UFRGetLastLogicError(Number: Integer; var LogicError: TUFRLogicError); stdcall;
  procedure UFRStarted(Number: Integer);stdcall;
  function  UFRMenuOperation(Number: Integer; XMLData: PAnsiChar; var XMLReturn: PAnsiChar): Integer; stdcall;

  //при желании переписать TUFRdevice класс наследника надо занести сюда
  procedure OverloadUFRdeviceClass(const AUFRdeviceClass: TUFRdeviceClass);

implementation

var
  //при желании переписать TUFRdevice класс наследника надо занести сюда
  UFRdeviceClass: TUFRdeviceClass = TUFRdevice;

procedure OverloadUFRdeviceClass(const AUFRdeviceClass: TUFRdeviceClass);
begin
  UFRdeviceClass := AUFRdeviceClass;
end;

var
  GCriticalSection: TCriticalSection;
  arUFRdevice: array of TUFRdevice;

function GetDevice(const AiDeviceNumber: Integer): TUFRdevice;
var
  i: Integer;
begin
  Result := nil;
  GCriticalSection.Enter;
  try
    for i := Low(arUFRdevice) to High(arUFRdevice) do begin
      if Assigned(arUFRdevice[i]) and (arUFRdevice[i].iNumber = AiDeviceNumber) then begin
        Result := arUFRdevice[i];
        Exit;
      end;
    end;
  finally
    GCriticalSection.Leave;
  end;
end;

procedure AppendDevice(AUFRdevice: TUFRdevice);
var
  i: Integer;
  isFindEmpty: Boolean;
begin
  GCriticalSection.Enter;
  try
    isFindEmpty := False;
    for i := Low(arUFRdevice) to High(arUFRdevice) do begin
      if not Assigned(arUFRdevice[i]) then begin
        isFindEmpty := True;
        Break;
      end;
    end;

    if not isFindEmpty then begin
      i := Length(arUFRdevice);
      SetLength(arUFRdevice, i + 1);
      arUFRdevice[i] := nil;
    end;

    arUFRdevice[i] :=  AUFRdevice;

  finally
    GCriticalSection.Leave;
  end;
end;

procedure FreeDevice(const AiDeviceNumber: Integer);
var
  i: Integer;
  iAliveCount: Integer;
begin
  GCriticalSection.Enter;
  try
    iAliveCount := 0;
    for i := Low(arUFRdevice) to High(arUFRdevice) do if Assigned(arUFRdevice[i]) then Inc(iAliveCount);

    for i := Low(arUFRdevice) to High(arUFRdevice) do begin
      if Assigned(arUFRdevice[i]) and (arUFRdevice[i].iNumber = AiDeviceNumber) then begin
        if iAliveCount = 1 then arUFRdevice[i].BeforeLastInstanceDestroy;

        FreeAndNil(arUFRdevice[i]);
        Exit;
      end;
    end;
  finally
    GCriticalSection.Leave;
  end;
end;

function MayBeXMLfromFile(pcXMLdata_or_FilePathTo: PChar): AnsiString;
var
  sl: TStringList;
begin
  Result := pcXMLdata_or_FilePathTo;

  if FileExists(Result) then begin  //  такая порнография сложилась исторически
    sl := TStringList.Create;
    try
      sl.LoadFromFile(Result);

      Result := sl.Text;
    finally
      sl.Free;
    end;
  end;
end;

//======================= Экспортируемые функции ===============================

function UFRInit(Number: Integer; XMLParams: PChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc): Integer; stdcall;
var ExcEBP: Pointer;
begin
  try
    Result := UFRInitXML(Number, XMLParams, AInterfaceCallbackProc, APropCallbackProc, nil);
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRInit');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRInit');
      raise;
    end;
  end;
end;

function UFRInitXML(Number: Integer; XMLParams: PAnsiChar; AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc; InitXMLReturnBuffer: PAnsiChar): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    if Assigned(GetDevice(Number)) then Exit; //  с таким номером уже есть, низзя создавать новый

    sData := MayBeXMLfromFile(XMLParams);

    UFRdevice := UFRdeviceClass.Create(Number, PAnsiChar(sData), AInterfaceCallbackProc, APropCallbackProc, InitXMLReturnBuffer);

    AppendDevice(UFRdevice);

    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRInitXML');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRInitXML');
      raise;
    end;
  end;
end;

function  UFRMenuOperation(Number: Integer; XMLData: PAnsiChar; var XMLReturn: PAnsiChar): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    sData := MayBeXMLfromFile(XMLData);

    UFRdevice.MenuOperation(PAnsiChar(sData), XMLReturn);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRMenuOperation');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRMenuOperation');
      raise;
    end;
  end;
end;

function UFRCustomerDisplay(Number: Integer; XMLBuffer: PChar; Flags: Integer): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    sData := MayBeXMLfromFile(XMLBuffer);

    UFRdevice.CustomerDisplay(PAnsiChar(sData), Flags);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRCustomerDisplay');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRCustomerDisplay');
      raise;
    end;
  end;
end;

function UFRGetStatus(Number: Integer; var Status: TUFRStatus; FieldsNeeded: DWord): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    UFRdevice.GetStatus(Status, FieldsNeeded);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRGetStatus');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRGetStatus');
      raise;
    end;
  end;
end;

function UFRUnfiscalPrint(Number: Integer; XMLBuffer: Pchar; Flags: Integer): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    sData := MayBeXMLfromFile(XMLBuffer);

    UFRdevice.UnfiscalPrint(PAnsiChar(sData), Flags);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRUnfiscalPrint');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRUnfiscalPrint');
      raise;
    end;
  end;
end;

function UFRFiscalDocument(Number: Integer; XMLDoc: PChar; var Status: TUFRStatus; Var FieldsFilled: Cardinal): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    sData := MayBeXMLfromFile(XMLDoc);

    UFRdevice.FiscalDocument(PAnsiChar(sData), Status, FieldsFilled);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRFiscalDocument');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRFiscalDocument');
      raise;
    end;
  end;
end;

function UFRProgram(Number: Integer; XMLDoc: PChar): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  sData: AnsiString;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    sData := MayBeXMLfromFile(XMLDoc);

    UFRdevice.Programming(PAnsiChar(sData));
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRProgram');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRProgram');
      raise;
    end;
  end;
end;

function UFRGetOptions(Number: Integer; var Options: Int64; var DriverName, VersionInfo, DriverState: OpenString): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then begin
      DriverState := 'No device initialized';
      Exit;  //  Номером ошиблись
    end else begin
      Options := 0;
      DriverName := 'UFR some driver';
      DriverState := '';
      UFRdevice.GetOptions(Options,  DriverName, VersionInfo, DriverState);
      Result := UFRdevice.Result.iError;
    end;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRGetOptions');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRGetOptions');
      raise;
    end;
  end;
end;

function UFROpenDrawer(Number: Integer; DrawerNum: Integer): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    UFRdevice.OpenDrawer(DrawerNum);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFROpenDrawer');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFROpenDrawer');
      raise;
    end;
  end;
end;

function UFRGetZReportData(Number: Integer; XMLData: PChar; Var XMLDataSize: Integer): Integer; stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    Result := errInvalidHandle;
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    UFRdevice.GetZReportData(XMLData, XMLDataSize);
    Result := UFRdevice.Result.iError;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRGetZReportData');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRGetZReportData');
      raise;
    end;
  end;
end;

procedure UFRGetLastLogicError(Number: Integer; var LogicError: TUFRLogicError); stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись

    LogicError.Size := SizeOf(TUFRLogicError);
    LogicError.LogicError := UFRdevice.Result.iError;
    LogicError.LogicErrorTextANSI := Utf8ToAnsi(UFRdevice.Result.usMessage);
    LogicError.LogicErrorTextUTF8 := UFRdevice.Result.usMessage;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRGetLastLogicError');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRGetLastLogicError');
      raise;
    end;
  end;
end;

procedure UFRDone(Number: Integer); stdcall;
var ExcEBP: Pointer;
begin
  try
    FreeDevice(Number);
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRDone');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRDone');
      raise;
    end;
  end;
end;

function UFRMaxProtocolSupported: integer; stdcall;
var ExcEBP: Pointer;
begin
  try
    Result := TUFRdevice.MaxProtocolSupported;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRMaxProtocolSupported');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRMaxProtocolSupported');
      raise;
    end;
  end;
end;

procedure UFRStarted(Number: Integer);stdcall;
var
  UFRdevice: TUFRdevice;
  ExcEBP: Pointer;
begin
  try
    UFRdevice := GetDevice(Number);
    if not Assigned(UFRdevice) then Exit;  //  Номером ошиблись
    UFRdevice.Started;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'UFRStarted');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'UFRStarted');
      raise;
    end;
  end;
end;

procedure FreeOnFinal;
var
  i: Integer;
  ExcEBP: Pointer;
begin
  try
    GCriticalSection.Enter;
    try
      for i := Low(arUFRdevice) to High(arUFRdevice) do if Assigned(arUFRdevice[i]) then FreeAndNil(arUFRdevice[i]);
    finally
      GCriticalSection.Leave;
    end;
  except
    {$I uStack32.inc}
    if ExceptObject <> nil then begin
      StackDump(ExcEBP, ExceptAddr, ExceptObject, 'FreeOnFinal');
      raise;
    end else begin
      StackDump(ExcEBP, nil, nil, 'FreeOnFinal');
      raise;
    end;
  end;
end;

initialization
  System.isMultiThread := True;
  GCriticalSection := TCriticalSection.Create;
finalization
  FreeOnFinal;
  GCriticalSection.Free;
end.
