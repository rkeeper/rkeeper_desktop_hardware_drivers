unit uStack32;
interface

procedure StackDump(AExcEBP: Pointer; AExcAddr: Pointer; AExcObject: TObject; Amessage: string);

implementation

uses
  Windows
, SysUtils
, Classes
, SyncObjs
;

type
  pStackFrame=^tStackFrame;
  tStackFrame=packed record
    NextEBP:pStackFrame;
    RetIP:pointer;
  end;

const CRLF:array[0..1] of char=(#13,#10);

procedure WriteLine(s:tStream; const str:string);
begin
  if s=nil then exit;
  if str<>'' then
    s.writebuffer(str[1],length(str));
  s.writebuffer(CRLF,sizeof(CRLF));
end;

function WriteIP(stream: tStream; addr:pointer):boolean;
var AllocBase:LongWord;
    ModuleName:ShortString;
begin
   Result := false;
   if stream = nil then exit;
   ModuleName := '';
   AllocBase := FindHInstance(Addr);
   if AllocBase <> 0 then
     ModuleName[0] := chr(GetModuleFileName(AllocBase, @ModuleName[1], sizeof(ModuleName)-1));
   if (ModuleName='') and (LongWord(Addr)=AllocBase) then
     Exit;
   WriteLine(stream, Format('%.8X.%s', [LongWord(Addr) - AllocBase, ModuleName]));
   Result:=true;
end;

function GoodAnyAddr(Addr:pointer):boolean;
begin
  Result:=(DWORD(Addr) and $ffff0000 <> 0) and (DWORD(Addr) and $ffff0000 <> $ffff0000);
end;

//test readability
function GoodAddr(dwEBP:pStackFrame):boolean;
var
  testframe:tStackFrame;
begin
  Result:=GoodAnyAddr(dwEBP);
  if not Result then exit;
  try
    testframe:=dwEBP^;
    asm
      jmp @1
      mov eax,$AAAAAAAA
      mov eax,$AAAAAAAA
      mov eax,$AAAAAAAA
      mov eax,$AAAAAAAA
      @1:
    end;
  except
    Result:=False;
    exit;
  end;
end;

procedure StackWrite(stream: TStream; AExcAddr: Pointer; AExcEBP: Pointer; AExcObject: TObject; AMessage: string);
var dwEBP: pStackFrame;
begin
  if stream = nil then Exit;
  dwEBP := aExcEBP;
  if dwEBP = nil then begin
    asm
      mov dwEBP,EBP
    end;
  end;
  try
    if AExcObject <> nil then
      WriteLine(stream, Format('[%s] [EXC:%s:%s] %s', [FormatDateTime('dd.mm.yy hh:nn:ss.zzz', Now), Exception(ExceptObject).ClassName, Exception(ExceptObject).Message, AMessage]))
    else
      WriteLine(stream, Format('[%s] %s', [FormatDateTime('dd.mm.yy hh:nn:ss.zzz', Now), AMessage]));
  except
  end;
  if AExcAddr<>Nil then begin
    try
      WriteIP(stream, AExcAddr);
    except
    end;
  end;
  if not GoodAddr(dwEBP) then Exit;
  try
    WriteLine(stream, '-------------------Start STACK------------------');
    while true do begin
      if (( LongInt(dwEBP) and  3) > 0) then   // Frame pointer must be aligned on a DWORD boundary.  Fail if not so.
        break;
      if not WriteIP(stream, dwEBP^.RetIP) then
        break;
      if cardinal(dwEBP) >= cardinal(dwEBP^.NextEBP) then break;
      dwEBP := dwEBP^.NextEBP;
      if not GoodAddr(dwEBP) then break;
    end;
    WriteLine(stream, '-------------------END STACK------------------');
  except
  end;
end;

var
  stackFileLock: TCriticalSection;
  stackFileName: String;
  stackName: String;
  eventLogger: THandle;

procedure LastResortLog(Ex: Exception; AMessage: String);
var
  msg: String;
  P: PChar;
begin
  try
    if Assigned(Ex) then
      msg := Format('StackDump [%s] [%s] [EXC:%s:%s] %s', [stackName, FormatDateTime('dd.mm.yy hh:nn:ss.zzz', Now), Ex.ClassName, Ex.Message, AMessage])
    else
      msg := Format('StackDump [%s] [%s] [EXC] %s', [stackName, FormatDateTime('dd.mm.yy hh:nn:ss.zzz', Now), AMessage]);

    P := PChar(msg);
    OutputDebugString(P);
    if eventLogger = 0 then eventLogger := RegisterEventSource(nil, PChar(stackName));
    ReportEvent(eventLogger, EVENTLOG_ERROR_TYPE, 1, 1, nil, 1, 0, @P, nil);
  except
   ;//гасим все исключения.
  end;
end;

procedure StackDump(AExcEBP: Pointer; AExcAddr: Pointer; AExcObject: TObject; Amessage: string);
var
  stream: TStream;
  backupFileName: String;
begin
  stackFileLock.Enter;
  try
    try
      if FileExists(stackFileName) then
        stream := TFileStream.Create(stackFileName, fmOpenReadWrite)
      else
        stream := TFileStream.Create(stackFileName, fmCreate);

      if stream.Size >= 20 * 1024 * 1024 then begin
        stream.Free;
        backupFileName := ChangeFileExt(stackFileName , '.tx1');
        SysUtils.DeleteFile(backupFileName);
        SysUtils.RenameFile(stackFileName, backupFileName);
        stream := TFileStream.Create(stackFileName, fmCreate);
      end;

      try
        stream.Seek(0, soEnd);
        StackWrite(stream, AExcAddr, AExcEBP, AExcObject, Amessage);
      finally
        stream.Free;
      end;
    except
      on Ex: Exception do LastResortLog(Ex, AMessage);
      else LastResortLog(nil, AMessage);
    end;
  finally
    stackFileLock.Leave;
  end;
end;

initialization
  stackFileLock:=TCriticalSection.Create;
  SetLength(stackFileName, 8192);
  SetLength(stackFileName, GetModuleFileName(hInstance, @stackFileName[1], Length(stackFileName)));
  stackName := ExtractFileName(stackFileName);
  stackFileName:=ChangeFileExt(stackFileName, '.stk');
finalization
  stackFileLock.Free;
end.

