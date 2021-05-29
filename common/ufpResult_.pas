unit ufpResult_;

interface

uses
  SysUtils
  ;

const //  коды ошибок
  errOk = 0; //без ошибок

  //  Универсальные ОШИБКИ ИНИЦИАЛИЗАЦИИ: 1..99
  errPortAlreadyUsed                      = 1; // Порт уже используется.
  errIllegalOS                            = 2; // Не та OS.
  errProtocolNotSupported                 = 3; // Запрашиваемый протокол не поддерживается.
  errFunctionNotSupported                 = 4; // Функция драйвера не поддерживается данным ФР.
  errInvalidHandle                        = 5; // Недействительный дескриптор (handle).
  errPortOpenError                        = 6; // Ошибка открытия порта.
  errPortBadBaud                          = 7; // Недопустимая скорость для порта.
  errInternalException                    = 8; // Неожиданное прерывание (внутренняя ошибка)
  errExtPrintError                        = 9; // Ошибка печати через внешнюю систему, можно запрашивать текст ошибки
                                                    
  //  Универсальные ОШИБКИ НИЗКОГО УРОВНЯ: 100..199 
  errLowNotReady                          = 101; // Устройство не готово принять команду. Таймаут ожидания.
  errLowSendError                         = 102; // Устройство отвечает ошибкой приёма команды.
  errLowAnswerTimeout                     = 103; // Устройство не отвечает на команду.
  errLowInactiveOnExec                    = 104; // Устройство не отвечает на проверку работоспособности после отправки команды.
  errLowBadAnswer                         = 105; // Устройство отвечает мусором (и невозможно повторить или повтор не помог).
  errLowInternalError                     = 106; // внутренний exception и т.п.
                                                    
  //  ЛОГИЧЕСКИЕ ОШИБКИ, ВЫЗВАННЫЕ РАБОТОЙ ФР: 200..299.
  //  ПРИМЕЧАНИЕ. По ошибкам данного назначения есть возможность получения более подробной информации через дополнительный вызов "UFRGetLastLogicError"
  errLogicError                           = 200; // Логическая ошибка неизвестного типа.
  errLogic24hour                          = 201; // Смена превысила максимальную продолжительность.
  errLogicPrinterNotReady                 = 202; // Печать была прервана по неготовности принтера. При запросе статуса не надо возвращать эту ошибку.
  errLogicPaperOut                        = 203; // Закончилась бумага во время печати. При запросе статуса не надо возвращать эту ошибку.
  errLogicBadAnswerFormat                 = 204; // В ответе вроде бы не мусор и нет ошибки, но что то принципиально не то
  errLogicShiftAlreadyOpened              = 205; // В ответ на OpenShiftReport если смена уже открыта

  //  Ошибки ВО ВХОДНЫХ ДАННЫХ, обнаруженные ДО ОТПРАВКИ ДАННЫХ в ФР: 300..399
  errAssertItemsPaysDifferent             = 301; // В чеке не совпадают суммы по товарам и платежам.
  errAssertInvalidXMLInitializationParams = 302; // Ошибка конфигурации XMLParams, обнаруженная во время инициализации UFRInit. Для получения более подробной информации вызвать "UFRGetLastLogicError".
  errAssertInvalidXMLParams               = 303; // Ошибка XML, переданного в: UFRFiscalDocument, UFRUnfiscalPrint, UFRCustomerDisplay. Для получения более подробной информации вызвать "UFRGetLastLogicError".
  errAssertInsufficientBufferSize         = 304; // Недостаточный размер буфера для получения данных.

type
  TUFRLogicError = packed record
    Size              : Integer;     // SizeOf(TUFRLogicError)

    LogicError        : Integer;     // Внутренний код логической ошибки ФР
    LogicErrorTextANSI: ShortString; // Описание логической ошибки ФР ANSI, для протокола 6 устаревшее
    LogicErrorTextUTF8: ShortString; // Описание логической ошибки ФР UTF8
  end;

type
  TUFRresult = class
  public
    constructor Create(AiError: Integer = errOk; const AusMessage: UTF8String = '');
    procedure SetValue(AiError: Integer; const AusMessage: UTF8String; const AusFuncName: UTF8String = '');  //  если параметр AsFuncName не указывается, он не изменяется
    function SetIfStrError(AiError: Integer; const AusMessage: UTF8String; const AusFuncName: UTF8String = ''): Boolean;
    function SetIfWinError(AiError: Integer; AiWinErrCode: Integer = 0; const AusMessagePrefix: UTF8String = ''; const AusFuncName: UTF8String = ''): Boolean;
  private
    FiError: Integer;  //  одна из констант errXX..XX
    FusMessage: UTF8String;  //  описание ошибки
    FusFuncName: UTF8String;
    function GetusError: UTF8String;
    function GetusLogText: UTF8String;
  public
    property iError: Integer read FiError;
    property usMessage: UTF8String read FusMessage;
    property usFuncName: UTF8String read FusFuncName write FusFuncName;
  public
    property usLogText: UTF8String read GetusLogText; //  текст, который логируется (краткий)
  end;

implementation

{ TResult }

constructor TUFRresult.Create(AiError: Integer; const AusMessage: UTF8String);
begin
  SetValue(AiError, AusMessage);
end;

function TUFRresult.GetusError: UTF8String;
begin
  case iError of
    errOk                                   : Result := 'Ok'; //без ошибок
     // Универсальные ОШИБКИ ИНИЦИАЛИЗАЦИИ: 1..99
    errPortAlreadyUsed                      : Result := 'PortAlreadyUsed'; //Порт уже используется.
    errIllegalOS                            : Result := 'IllegalOS'; //Не та OS.
    errProtocolNotSupported                 : Result := 'ProtocolNotSupported'; //Запрашиваемый протокол не поддерживается.
    errFunctionNotSupported                 : Result := 'FunctionNotSupported'; //Функция драйвера не поддерживается данным ФР.
    errInvalidHandle                        : Result := 'InvalidHandle'; //Недействительный дескриптор (handle).
    errPortOpenError                        : Result := 'PortOpenError'; //Ошибка открытия порта.
    errPortBadBaud                          : Result := 'PortBadBaud'; //Недопустимая скорость для порта.
    errInternalException                    : Result := 'InternalException'; //Неожиданное прерывание (внутренняя ошибка)
     // Универсальные ОШИБКИ НИЗКОГО УРОВНЯ: 100..199
    errLowNotReady                          : Result := 'LowNotReady'; //Устройство не готово принять команду. Таймаут ожидания.
    errLowSendError                         : Result := 'LowSendError'; //Устройство отвечает ошибкой приёма команды.
    errLowAnswerTimeout                     : Result := 'LowAnswerTimeout'; //Устройство не отвечает на команду.
    errLowInactiveOnExec                    : Result := 'LowInactiveOnExec'; //Устройство не отвечает на проверку работоспособности после отправки команды.
    errLowBadAnswer                         : Result := 'LowBadAnswer'; //Устройство отвечает мусором (и невозможно повторить или повтор не помог).
    errLowInternalError                     : Result := 'LowInternalError'; //внутренний exception и т.п.
     // ЛОГИЧЕСКИЕ ОШИБКИ, ВЫЗВАННЫЕ РАБОТОЙ ФР: 200..299. ПРИМЕЧАНИЕ. По ошибкам данного назначения есть возможность получения более подробной информации через дополнительный вызов "UFRGetLastLogicError"
    errLogicError                           : Result := 'LogicError'; //Логическая ошибка неизвестного типа.
    errLogic24hour                          : Result := 'Logic24hour'; //Смена превысила максимальную продолжительность.
    errLogicPrinterNotReady                 : Result := 'LogicPrinterNotReady'; //Печать была прервана по неготовности принтера. При запросе статуса не надо возвращать эту ошибку.
    errLogicPaperOut                        : Result := 'LogicPaperOut'; //Закончилась бумага во время печати. При запросе статуса не надо возвращать эту ошибку.
    errLogicBadAnswerFormat                 : Result := 'LogicBadAnswerFormat'; //В ответе вроде бы не мусор и нет ошибки, но что то принципиально не то
    errLogicShiftAlreadyOpened              : Result := 'LogicShiftAlreadyOpened'; // В ответ на OpenShiftReport если смена уже открыта
     // Ошибки ВО ВХОДНЫХ ДАННЫХ, обнаруженные ДО ОТПРАВКИ ДАННЫХ в ФР: 300..399
    errAssertItemsPaysDifferent             : Result := 'AssertItemsPaysDifferent'; //В чеке не совпадают суммы по товарам и платежам.
    errAssertInvalidXMLInitializationParams : Result := 'AssertInvalidXMLInitializationParams'; //Ошибка конфигурации XMLParams, обнаруженная во время инициализации UFRInit. Для получения более подробной информации вызвать "UFRGetLastLogicError".
    errAssertInvalidXMLParams               : Result := 'AssertInvalidXMLParams'; //Ошибка XML, переданного в: UFRFiscalDocument, UFRUnfiscalPrint, UFRCustomerDisplay. Для получения более подробной информации вызвать "UFRGetLastLogicError".
    errAssertInsufficientBufferSize         : Result := 'AssertInsufficientBufferSize'; //Недостаточный размер буфера для получения данных.
  else
    Result := 'Unknown error: ' + IntToStr(iError);
  end;
end;

function TUFRresult.GetusLogText: UTF8String;
var
  usMessage: UTF8String;
begin
  usMessage := '';
  if FusMessage <> '' then usMessage := usMessage + ' - ' + FusMessage;
  if FusFuncName <> '' then usMessage := usMessage + ' in ' + FusFuncName + '()';
  Result := GetusError + usMessage;
end;

function TUFRresult.SetIfStrError(AiError: Integer; const AusMessage, AusFuncName: UTF8String): Boolean;
begin
  Result := False;

  if AusMessage = '' then Exit;
  SetValue(AiError, AusMessage, AusFuncName);

  Result := True;
end;

function TUFRresult.SetIfWinError(AiError, AiWinErrCode: Integer; const AusMessagePrefix, AusFuncName: UTF8String): Boolean;
var
  sSeparator: AnsiString;
begin
  Result := False;

  if AiWinErrCode = 0 then AiWinErrCode := 0;//GetLastError;
  if AiWinErrCode = 0 then Exit;
  if AusMessagePrefix = '' then sSeparator := '' else sSeparator := '. ';
  SetValue(AiError, Format('%s%sWindows error 0x%s - %s', [AusMessagePrefix, sSeparator, IntToHex(AiWinErrCode, 8), SysErrorMessage(AiWinErrCode)]), AusFuncName);

  Result := True;
end;

procedure TUFRresult.SetValue(AiError: Integer; const AusMessage: UTF8String; const AusFuncName: UTF8String = '');
begin
  FiError := AiError;
  FusMessage := AusMessage;
  if AusFuncName <> '' then FusFuncName := AusFuncName;
end;

end.
