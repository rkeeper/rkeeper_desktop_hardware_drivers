unit uCallbacks;

interface

uses
   Windows
  ,uCommon
  ,uLog
  ;

const // список функций Callback процедуры
  cpfDialog           = 1; // Вызов диалога, структура tDialogInfo, см. Вызов диалога на станции
  cpfProgress         = 2; // Индикация прогресса, структура tProgressInfo
  cpfGetStringDialog  = 3; // Диалог запроса строки, структура tGetStringInfo
  cpfRegisterSpecMenu = 4; // Зарегистрировать специальное меню, структура tDriverMenuInfo
  cpfLog              = 5; // Логирование
  cpfTranslate        = 6; // Перевод, структура tTranslateInfo
  cpfPrintTextOther   = 7; // Печать текста на другой принтер, структура tPrintTextOtherInfo (Версия 2+)
  cpfDeviceSignal     = 8; // Послать сигнал с идентификатором как от внешнего устройства, структура tDeviceSignalInfo (версия 39+)
  cpfPerformMessage   = 9; // Синхронно обработать сообщение с возвратом результата, структура tPerformMessageInfo (версия 39+)
  cpfExecXML          = 10;// Выполнение XML команды, структура tExecXMLInfo (версия 39+)

type
  TeMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom, mtZRepConfirm);
const
  S_MSG_DLG_TYPE: array[TeMsgDlgType] of AnsiString = ('Warning', 'Error', 'Information', 'Confirmation', 'Custom', 'ZRepConfirm');

type
  TeMsgDlgBtn = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore, mbAll, mbNoToAll, mbYesToAll, mbHelp);
const
  S_MSG_DLG_BTN: array[TeMsgDlgBtn] of AnsiString = ('Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll', 'YesToAll', 'Help');

type
  TseMsgDlgButtons = set of TeMsgDlgBtn;

function MsgDlgButtonsToStr(AseMsgDlgButtons: TseMsgDlgButtons): AnsiString;

type
  PDialogInfo = ^TDialogInfo;
  TDialogInfo = packed record
    Size:     Integer;     //SizeOf(TDialogInfo)

    Message:  ShortString;
    Header:   ShortString; //Если пусто, то выводится заголовок с указанием имени драйвера и номера
    DlgType:  TeMsgDlgType;
    ShowHere: Boolean;     //true – показать на компьютере драйвера, иначе – на заблокировавшем
    Buttons:  TseMsgDlgButtons;
    Result:   Integer;    //mrOk, mrCancel,

    //Начиная с версии 4
    Timeout:  DWord;       //Таймаут в миллисекундах, 0 и INFINITE обрабатываются одинаково - без ограничений
  end;

const
  mrNone     = 0;
  mrOk       = 1;
  mrCancel   = 2;
  mrAbort    = 3;
  mrRetry    = 4;
  mrIgnore   = 5;
  mrYes      = 6;
  mrNo       = 7;
  mrAll      = mrNo + 1;
  mrNoToAll  = mrAll + 1;
  mrYesToAll = mrNoToAll + 1;
  mrTimeout = 254;
  mrInternalError = 255;

function mrToStr(Aimr: Integer): AnsiString;

type
  PProgressInfo = ^TProgressInfo;
  TProgressInfo = packed record
    Size:        Integer;     //SizeOf(TProgressInfo)

    Message:     ShortString;
    Position:    Integer;     //0..MaxPosition
    MaxPosition: Integer;
  end;

type
  PGetStringInfo = ^TGetStringInfo;
  TGetStringInfo = packed record
    Size:      Integer;     //SizeOf(TGetStringInfo)

    Message:   ShortString;
    Header:    ShortString; //Если пусто, выведется заголовок с указанием имени драйвера и номера
    Default:   ShortString; //Строка по умолчанию
    Mask:      ShortString; //Маска ввода
    ShowHere:  Boolean;     //true - показать на компьютере драйвера, иначе - на заблокировавшем
    Result:    Boolean;     //Результат выполнения: false возможен при разрыве связи, закрытии формы и т.п.
    ResString: ShortString;

    //Начиная с версии 4
    Timeout:   DWord;        //Таймаут в миллисекундах, 0 и INFINITE обрабатываются одинаково - без ограничений
  end;

type
  PFRLog = ^TFRLog;
  TFRLog = packed record
    Size: Integer; //SizeOf(TFRLog) [заполнить до регистрации]

    LogEventType: Integer; //одна из констант letXXX
    TextData:     PAnsiChar;   //строка в кодировке UTF8, заканчивающаяся 0
    BinData:      Pointer;
    BinDataSize:  Integer;
  end;

const // for log
  letUndefined           = 0; // Неопределйнный тип
  letError               = 1; // Ошибка. В поле TextData - строка в кодировке UTF8
  letInitializing        = 2; // В начале инициализации. В поле TextData - строка в кодировке UTF8
  letInitialized         = 3; // При успешной инициализации. В поле TextData - строка в кодировке UTF8
  letFiscCommand         = 4; // Текстовое и бинарное представление фискальной команды. В поле TextData: номер | описание | параметр. В поле BinData: пакет данных для отправки в ФР).
  letFiscCommandComplete = 5; // Текстовое и бинарное представление ответа фискальника.
                              // В поле TextData: код ошибки | время выполнения фискальной команды | расшифровка содержательного ответа ФР (например, на запрос статуса).
                              // В поле BinData: пакет данных, полученный от ФР.
  letTextCommand         = 6; // Текстовое и бинарное представление команды вывода текста (нефискальная печать, вывод на дисплей покупателя). В поле BinData: пакет данных для отправки в ФР.
  letTextCommandComplete = 7; // Текстовое и бинарное представление ответа от ФР.
                              // В поле TextData: код ошибки | время выполнения фискальной команды | расшифровка содержательного ответа ФР (например, статус печатающего стройства).
                              // В поле BinData: пакет данных, полученный от ФР.
  letBinInput            = 8; // Бинарный системный вход, не описанный в letFiscCommandComplete, letTextCommandComplete. Например, подтверждение от ФР о получении пакета данных.
  letBinOut              = 9; // Бинарный системный вывод, не описанный в letFiscCommand, letTextCommand. Например, подтверждение о получении пакета данных или подготовка ФР к отправке команды.

type
  pTranslateInfo = ^tTranslateInfo;
  tTranslateInfo = packed record
    Size:         Integer;      // SizeOf(tTranslateInfo)
    TranslateFrom: ShortString; // ANSI,Заполнить
    LocaleID:      Integer;     // Заполнить
    TranslateTo  : ShortString; // ANSI, Возврат
  end;

type
  PPrintTextOtherInfo = ^TPrintTextOtherInfo;
  TPrintTextOtherInfo = packed record
    Size:        Integer;     //SizeOf(TPrintTextOtherInfo)

    DeviceIdent: ShortString; //Код или GUID или ещё какой-либо идентификатор
    PrintBuffer: PAnsiChar;   //Строка, заканчивающаяся 0 - XML в UTF-8 с корневым тэгом Unfiscal, см. выше
    Res:         Boolean;     //Успешность: true - без ошибки, иначе заполнено ErrorText
    ErrorText:   ShortString; //Текст ошибки: не пусто, если была ошибка
    ToWait:      Boolean;     //Ждать окончания печати

    Timeout:     DWord;       //Таймаут печати в милисекундах, если ждать, иначе таймаут блокировки (ожидания готовности)
  end;

type
  TeSignalDeviceType = (
     sigdevtypMagCard
    ,sigdevtypBarCode
    ,sigdevtypDallas
    ,sigdevtypInpKBD
    ,sigdevtypNoTouch
  );
const
  I_SIGNAL_DEVICE_TYPE: array[TeSignalDeviceType] of Integer = (
     0 // sigdevtypMagCard
    ,1 // sigdevtypBarCode
    ,2 // sigdevtypDallas
    ,3 // sigdevtypInpKBD
    ,4 // sigdevtypNoTouch
  );
  S_SIGNAL_DEVICE_TYPE: array[TeSignalDeviceType] of UTF8String = (
     'MagCard' // sigdevtypMagCard
    ,'BarCode' // sigdevtypBarCode
    ,'Dallas'  // sigdevtypDallas
    ,'InpKBD'  // sigdevtypInpKBD
    ,'NoTouch' // sigdevtypNoTouch
  );

type
  pDeviceSignalInfo = ^tDeviceSignalInfo;
  tDeviceSignalInfo = packed record
    Size:       Integer;     // Заполнить SizeOf(tDeviceSignalInfo)
    DeviceType: Integer;     // тип устройства dstXXXX: 0 - магнитная карта, 1 - штрих-код, 2 - Dallas, 3 - ввод с клавиатуры, 4 - бесконтактная карта
    DeviceID:   Integer;     // Идентификатор устройства
    Data:       ShortString; // Данные сигнала
  end;

type
  pPerformMessageInfo = ^tPerformMessageInfo;
  tPerformMessageInfo = packed record
    Size:        Integer; // SizeOf(tPerformMessageInfo)
    Msg:         Integer; // идентификатор сообщения (WM_... или аналог)
    WParam:      Integer;
    LParam:      Integer;
    Res:         Integer; // результат синхронной обработки сообщения
  end;

type
  PExecXMLInfo = ^TExecXMLInfo;
  TExecXMLInfo = packed record
    Size:          Integer; // SizeOf(tExecXMLInfo)
    InXML:         PChar;   // XML команда для выполнения, если касса не умеет выполнить, должна перекинуть на сервер
    OutXMLBuf:     PChar;   // Буфер для ответа, выделяется в драйвере перед вызовом callback, размер выделенного буфера указан в OutXMLBufSize
    OutXMLBufSize: Integer; // размер выделенного буфера для ответа
    Res:           Integer; // результат выполнения
  end;

type
  TInterfaceCallbackProc = procedure
  (
   //Хэндл модуля, который вызывает процедуру
   AModuleHandle: tHandle;
   //Номер, который передали при регистрации
   ANumber: Integer;
   AFuncID: Integer;
   AProtocolVersion: Integer;
   //Указатель на параметр (возможно структура, часть полей которой могут меняться) [возврат]
   AFuncParams: Pointer
  ); stdcall;

type
  TPropCallbackProc = procedure
  (
   //Тип элемента, совпадает с тэгом
   //Для "Receipt"/"Receipt.Order"/"Receipt.Deletion"/"Receipt.Operator" идентификаторы не нужны;
   //Для "Item""/"Discount"/"Pay" нужны (атрибут Id).
   AXMLTag: PAnsiChar;
   //Идентификатор элемента
   AIdentifier: PAnsiChar;
   //Имя свойства
   APropName: PAnsiChar;
   var APropValue: OpenString
  ); stdcall;

type
  TCallBacks = class
  public
    constructor Create(ALog: TLog);
    procedure SetCallBacks(AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc);
  public
    function ShowCashDialog(const AusHeader, AusMessage: UTF8String; ADlgType: TeMsgDlgType; AButtons: TseMsgDlgButtons; AisShowHere: Boolean = False; AlwTimeOut: LongWord = INFINITE): Integer;
    function CashGetString(const AusHeader, AusMessage, AusDefault, AusMask: UTF8String; out AusResult: UTF8String; AisShowHere: Boolean = False; AlwTimeOut: LongWord = INFINITE): Boolean;
    function CallPrintTextOtherCallbackWait(const AusXmlStr: UTF8String; const AsPrinterDeviceIdent: AnsiString; AlwPrintingTimeout: LongWord; ProtocolSupported: Integer; var AusErrorStr: UTF8String): Boolean;
    function SendDeviceSignal(AeSignalDeviceType: TeSignalDeviceType; AiDeviceID: Integer; AssData: ShortString; AiProtoVers: Integer): Boolean;
    function GetProperty(const AsXMLtag, AsIdentifier, AsPropName: AnsiString): AnsiString;
    function ExecXML(const AusInXML: UTF8String; out AusOutXML: UTF8String; AiProtoVers: Integer = 1): Integer;
    function Progress(AiMaxPosition: Integer; AiPosition: Integer; AusMessage: UTF8String): Boolean;
  private
    FLog: TLog;
    FInterfaceCallbackProc: TInterfaceCallbackProc;
    FPropCallbackProc: TPropCallbackProc;
    FiInInterfaceCallbackLevel: Integer;
  public
    property PropCallbackProc: TPropCallbackProc read FPropCallbackProc;
    property InterfaceCallbackProc: TInterfaceCallbackProc read FInterfaceCallbackProc;
  end;


implementation

uses
  SysUtils
  ,uLoclz
;

function MsgDlgButtonsToStr(AseMsgDlgButtons: TseMsgDlgButtons): AnsiString;
const
  S_SEPARATOR = ', ';
var
  eMsgDlgBtn: TeMsgDlgBtn;
begin
  Result := '';
  for eMsgDlgBtn := Low(TeMsgDlgBtn) to High(TeMsgDlgBtn) do if eMsgDlgBtn in AseMsgDlgButtons then begin
    Result := Result + S_MSG_DLG_BTN[eMsgDlgBtn] + S_SEPARATOR;
  end;
  if Length(Result) >= Length(S_SEPARATOR) then SetLength(Result, Length(Result) - Length(S_SEPARATOR));
end;

function mrToStr(Aimr: Integer): AnsiString;
begin
  case Aimr of
    mrNone         : Result := 'None';
    mrOk           : Result := 'Ok';
    mrCancel       : Result := 'Cancel';
    mrAbort        : Result := 'Abort';
    mrRetry        : Result := 'Retry';
    mrIgnore       : Result := 'Ignore';
    mrYes          : Result := 'Yes';
    mrNo           : Result := 'No';
    mrAll          : Result := 'All';
    mrNoToAll      : Result := 'NoToAll';
    mrYesToAll     : Result := 'YesToAll';
    mrTimeout      : Result := 'Timeout ';
    mrInternalError: Result := 'InternalError';
  else
    Result := 'mr_' + IntToStr(Aimr);
  end;
end;

{ TCallBacks }

constructor TCallBacks.Create(ALog: TLog);
begin
  FLog := ALog;

  FInterfaceCallbackProc := nil;
  FPropCallbackProc := nil;
end;

procedure TCallBacks.SetCallBacks(AInterfaceCallbackProc: TInterfaceCallbackProc; APropCallbackProc: TPropCallbackProc);
  function GetAddrModuleName(addr: Pointer): string;
  begin
    SetLength(Result, MAX_PATH + 1);
    SetLength(Result, GetModuleFileNameA(System.FindHInstance(Addr), @Result[1], Length(Result)-1));
  end;

  function GetAddrModuleOffset(addr: Pointer): LongWord;
  begin
    Result := System.FindHInstance(Addr);
    if Result <> 0 then Result := LongWord(Addr) - Result;
  end;
begin
  FLog.Log(llALWAYS, Format('SetCallBacks(InterfaceCallback=0x%p, PropCallback=0x%p)', [@AInterfaceCallbackProc, @APropCallbackProc]));
  FLog.Log(llALWAYS, Format('InterfaceCallback: at 0x%x in %s', [GetAddrModuleOffset(@AInterfaceCallbackProc), GetAddrModuleName(@AInterfaceCallbackProc)]));
  FLog.Log(llALWAYS, Format('PropCallback     : at 0x%x in %s', [GetAddrModuleOffset(@APropCallbackProc), GetAddrModuleName(@APropCallbackProc)]));
  FInterfaceCallbackProc := AInterfaceCallbackProc;
  FPropCallbackProc := APropCallbackProc;
end;

const
  S_SHOW_HERE: array[Boolean] of AnsiString = ('', 'Show here');

function TCallBacks.ShowCashDialog(const AusHeader, AusMessage: UTF8String; ADlgType: TeMsgDlgType; AButtons: TseMsgDlgButtons; AisShowHere: Boolean = False; AlwTimeOut: LongWord = INFINITE): Integer;
var
  DialogInfo: TDialogInfo;
  sError: AnsiString;
begin
  Result := mrCancel;
  sError := 'Unknown error';

  try
    try
      FLog.Log(llEXP_FUNC_CALL, Format('Enter ShowCashDialog(%s, %s, %s, [%s], %s, %u)', [AusHeader, AusMessage, S_MSG_DLG_TYPE[ADlgType], MsgDlgButtonsToStr(AButtons), S_SHOW_HERE[AisShowHere], AlwTimeOut]));

      if not Assigned(FInterfaceCallbackProc) then begin
        sError := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;

      DialogInfo.Size := SizeOf(TDialogInfo);
      DialogInfo.Message  := UTF8ToMain(tr(AusMessage));
      DialogInfo.Header   := UTF8ToMain(tr(AusHeader));
      DialogInfo.DlgType  := ADlgType;
      DialogInfo.ShowHere := AisShowHere;
      DialogInfo.Buttons  := AButtons;
      DialogInfo.Result   := 0;
      DialogInfo.Timeout  := AlwTimeOut;

      FInterfaceCallbackProc(hInstance, FLog.iNumber, cpfDialog, 1, @DialogInfo);

      Result := DialogInfo.Result;
      sError := '';
    except
      on E: Exception do sError := 'External exception on InterfaceCallbackProc: ' + E.Message;
      else sError := 'External exception on InterfaceCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('Leave ShowCashDialog(...) -> %d (%s) %s', [Result, mrToStr(Result), sError]), True);
  end;
end;

function TCallBacks.CashGetString(const AusHeader, AusMessage, AusDefault, AusMask: UTF8String; out AusResult: UTF8String; AisShowHere: Boolean = False; AlwTimeOut: LongWord = INFINITE): Boolean;
var
  GetStringInfo: TGetStringInfo;
  sError: AnsiString;
begin
  Result := False;
  sError := 'Unknown error';
  AusResult := '';

  try
    try
      FLog.Log(llEXP_FUNC_CALL, Format('Enter CashGetString(%s, %s, %s, %s, ..., %s, %u)', [AusHeader, AusMessage, AusDefault, AusMask, S_SHOW_HERE[AisShowHere], AlwTimeOut]));

      if not Assigned(FInterfaceCallbackProc) then begin
        sError := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;

      GetStringInfo.Size      := SizeOf(GetStringInfo);
      GetStringInfo.Message   := UTF8ToMain(tr(AusMessage));
      GetStringInfo.Header    := UTF8ToMain(tr(AusHeader));
      GetStringInfo.Default   := UTF8ToMain(AusDefault);
      GetStringInfo.Mask      := UTF8ToMain(AusMask);
      GetStringInfo.ShowHere  := AisShowHere;
      GetStringInfo.Result    := False;
      GetStringInfo.ResString := '';
      GetStringInfo.Timeout   := AlwTimeOut;

      FInterfaceCallbackProc(hInstance, FLog.iNumber, cpfGetStringDialog, 1, @GetStringInfo);

      if GetStringInfo.Result <> False then AusResult := MainToUTF8(GetStringInfo.ResString);

      Result := GetStringInfo.Result;
      sError := '';
    except
      on E: Exception do sError := 'External exception on InterfaceCallbackProc: ' + E.Message;
      else sError := 'External exception on InterfaceCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('Leave CashGetString(..., %s, ...) -> %s %s', [AusResult, BoolToStr(Result, True), sError]), True);
  end;
end;

function TCallBacks.CallPrintTextOtherCallbackWait(const AusXmlStr: UTF8String; const AsPrinterDeviceIdent: AnsiString; AlwPrintingTimeout: LongWord; ProtocolSupported: Integer; var AusErrorStr: UTF8String): Boolean;
var
  PrintTextOtherInfo: TPrintTextOtherInfo;
begin
  Result := False;
  Inc(FiInInterfaceCallbackLevel);
  try
    try
      if not Assigned(FInterfaceCallbackProc) then begin
        AusErrorStr := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;

      FillChar(PrintTextOtherInfo, sizeof(PrintTextOtherInfo), 0);

      PrintTextOtherInfo.Size := sizeof(PrintTextOtherInfo);
      PrintTextOtherInfo.DeviceIdent := AsPrinterDeviceIdent;
      PrintTextOtherInfo.PrintBuffer := PAnsiChar(AusXmlStr);
      PrintTextOtherInfo.ToWait := True;
      PrintTextOtherInfo.Timeout := AlwPrintingTimeout;

      FInterfaceCallbackProc(HInstance, FLog.iNumber, cpfPrintTextOther, ProtocolSupported, @PrintTextOtherInfo);

      if not PrintTextOtherInfo.Res then begin
        AusErrorStr := MainToUTF8(PrintTextOtherInfo.ErrorText);
        Exit;
      end;

      AusErrorStr := '';
      Result := True;
    except
      on E: Exception do AusErrorStr := 'External exception on InterfaceCallbackProc: ' + Utf8Encode(E.Message);
      else AusErrorStr := 'External exception on InterfaceCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('PrintTextOther(%s, %s, %d) -> %s %s', [AusXmlStr, AsPrinterDeviceIdent, AlwPrintingTimeout, BoolToStr(Result, True), AusErrorStr]), True);
    Dec(FiInInterfaceCallbackLevel);
  end;
end;

function TCallBacks.SendDeviceSignal(AeSignalDeviceType: TeSignalDeviceType; AiDeviceID: Integer; AssData: ShortString; AiProtoVers: Integer): Boolean;
var
  DeviceSignalInfo: TDeviceSignalInfo;
  usError: UTF8String;
begin
  Result := False;
  usError := 'Unknown error';

  try
    try
      if not Assigned(FInterfaceCallbackProc) then begin
        usError := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;

      FillChar(DeviceSignalInfo, sizeof(DeviceSignalInfo), 0);
      DeviceSignalInfo.Size := sizeof(DeviceSignalInfo);
      DeviceSignalInfo.DeviceType := I_SIGNAL_DEVICE_TYPE[AeSignalDeviceType];
      DeviceSignalInfo.DeviceID := AiDeviceID;
      DeviceSignalInfo.Data := AssData;

      FInterfaceCallbackProc(HInstance, FLog.iNumber, cpfDeviceSignal, AiProtoVers, @DeviceSignalInfo);

      Result := True;
  	  usError := '';
    except
      on E: Exception do usError := 'External exception on InterfaceCallbackProc: ' + E.Message;
      else usError := 'External exception on InterfaceCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('SendDeviceSignal(%s, %d, %s) -> %s %s', [S_SIGNAL_DEVICE_TYPE[AeSignalDeviceType], AiDeviceID, AssData, BoolToStr(Result, True), usError]));
  end;
end;

function TCallBacks.GetProperty(const AsXMLtag, AsIdentifier, AsPropName: AnsiString): AnsiString;
var
  usError: UTF8String;
  ssPropValue: ShortString;
begin
  Result := '';
  usError := 'Unknown error';

  try
    try
      if not Assigned(FPropCallbackProc) then begin
        usError := 'PropCallbackProc is not assigned';
        Exit;
      end;

      FPropCallbackProc(PAnsiChar(AsXMLtag), PAnsiChar(AsIdentifier), PAnsiChar(AsPropName), ssPropValue);

      Result := ssPropValue;
  	  usError := '';
    except
      on E: Exception do usError := 'External exception on PropCallbackProc: ' + E.Message;
      else usError := 'External exception on PropCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('PropCallbackProc(%s, %s, %s) -> "%s" %s', [AsXMLtag, AsIdentifier, AsPropName, Result, usError]));
  end;
end;

function TCallBacks.ExecXML(const AusInXML: UTF8String; out AusOutXML: UTF8String; AiProtoVers: Integer = 1): Integer;
var
  usError: UTF8String;
  ExecXMLInfo: TExecXMLInfo;
  usOutXML: UTF8String;
begin
  Result := -1;
  usError := 'Unknown error';

  try
    try
      if not Assigned(FInterfaceCallbackProc) then begin
        usError := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;
      if Length(AusInXML) < 1 then begin
        usError := 'InXML is empty';
        Exit;
      end;

      SetLength(usOutXML, 512 * 1024);

      FillChar(ExecXMLInfo, sizeof(ExecXMLInfo), 0);
      ExecXMLInfo.Size := sizeof(ExecXMLInfo);
      ExecXMLInfo.InXML := PAnsiChar(AusInXML);
      ExecXMLInfo.OutXMLBuf := @usOutXML[1];
      ExecXMLInfo.OutXMLBufSize := Length(usOutXML);

      FInterfaceCallbackProc(HInstance, FLog.iNumber, cpfExecXML, AiProtoVers, @ExecXMLInfo);
      Result := ExecXMLInfo.Res;
      if Result <> 0 then begin
        usError := Format('Result = %d', [Result]);
        Exit;
      end;

      AusOutXML := PAnsiChar(@usOutXML[1]);
  	  usError := '';
    except
      on E: Exception do usError := 'External exception on InterfaceCallbackProc: ' + E.Message;
      else usError := 'External exception on InterfaceCallbackProc';
    end;
  finally
    if Length(AusInXML) > 0 then FLog.Log(llSERIAL_TRANS, 'InXML:' + cCR + cLF + AusInXML);
    if usError = '' then FLog.Log(llEXP_FUNC_CALL, 'ExecXML() -> Ok', True) else FLog.Log(llERROR, Format('ExecXML() -> Error: %s', [usError]), True);
    if usError = '' then FLog.Log(llSERIAL_TRANS, 'OutXML:' + cCR + cLF + AusOutXML, True);
  end;
end;

function TCallBacks.Progress(AiMaxPosition: Integer; AiPosition: Integer; AusMessage: UTF8String): Boolean;
var
  ProgressInfo: TProgressInfo;
  sError: AnsiString;
begin
  Result := False;
  sError := 'Unknown error';
  try
    try
      if not Assigned(FInterfaceCallbackProc) then begin
        sError := 'InterfaceCallbackProc is not assigned';
        Exit;
      end;

      if AiMaxPosition < 0 then begin
        AiMaxPosition := 0;
      end;

      if AiPosition > AiMaxPosition then begin
        AiPosition := AiMaxPosition;
      end;

      if AiPosition < 0 then begin
        AiPosition := 0;
      end;

      ProgressInfo.Size       := SizeOf(ProgressInfo);
      ProgressInfo.Message    := UTF8ToMain(tr(AusMessage));
      ProgressInfo.Position   := AiPosition; //0..MaxPosition
      ProgressInfo.MaxPosition:= AiMaxPosition;

      FInterfaceCallbackProc(hInstance, FLog.iNumber, cpfProgress, 1, @ProgressInfo);
      Result := True;
      sError := '';
    except
      on E: Exception do sError := 'External exception on InterfaceCallbackProc: ' + E.Message;
      else sError := 'External exception on InterfaceCallbackProc';
    end;
  finally
    FLog.Log(llEXP_FUNC_CALL, Format('Progress(%d, %d, %s) -> %s %s', [AiMaxPosition, AiPosition, AusMessage, BoolToStr(Result, True), sError]));
  end;
end;

end.
