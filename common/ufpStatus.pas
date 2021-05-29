unit ufpStatus;

interface

uses
   Windows
  ,SysUtils
  ,DateUtils
  ,ufpResult_
  ;

type
  TString35 = String[35];
  TUFRShiftState = (ssShiftClosed, ssShiftOpened, ssShiftOpened24hoursExceeded);
  PUFRShiftState = ^TUFRShiftState;

  PUFRStatus = ^TUFRStatus;
  TUFRStatus = packed record // В структуре должно быть заполнено первое поле - Size, а вся остальная структура должна быть проинициализирована (заполнена 0).
    Size               : Integer;
    // Если драйвер не поддерживает какое то поле, оно остаётся заполнено нулём (драйвер неизвестную ему часть структуры не трогает).
    NotReady           : Boolean;        // Не готов
    Busy               : Boolean;        // Работает [занят]
    CannotPrintUnfiscal: Boolean;        // Невозможно выполнить нефискальную печать
    QueueSize          : Integer;        // Размер очереди на печать для нефискальной печати. NOTE по возможности, надо возвращать сумму длин очередей драйвера и устройства
    DrawerOpened       : Boolean;        // Ящик открыт
    ShiftState         : TUFRShiftState; // Статус фискальной смены
    SerialNum          : TString35;      // Уникальный идентификатор фискального регистратора (с моделью)
    LastShiftNum       : Word;           // Последний номер Z отчёта (номер закрытой смены)
    LastDocNum         : Integer;        // Последний номер документа (в том числе инкассации и т.п.)
    LastReceiptNum     : Integer;        // Последний номер чека
    SaledValue         : Int64;          // Сумма продаж за смену, в копейках
    CashRegValue       : Int64;          // Сумма в кассе, в копейках
    PaperStatus        : Integer;        //15+ paperOk=0 - ок, paperOut=1 - бумага закончилась,  paperLow=2 - бумага близка к завершению
    XMLBuffer          : PAnsiChar;      //17+ указатель на буфер для возврата XML в виде строки, завершающейся 0 в кодировке utf-8, заполняется до вызова UFRGetStatus или UFRFiscalDocument, перед вызовом надо в первый байт буфера прописать 0
    XMLBufferSize      : Integer;        //17+ размер буфера, заполняется до вызова UFRGetStatus или UFRFiscalDocument, в случае недостаточного размера и XMLBuffer<>nil возвращается ошибка errAssertInsufficientBufferSize, а в этом поле содержится требуемый размер (включая концевой 0)
    EKLZNearEnd        : Boolean;        //22+ Warning о скором заполнении ЭКЛЗ или его аналогов  end;
    OFDUnsentCount     : Integer;        //35+ Количество неотправленных в ОФД документов, соотвтетствующий флаг fnOFDStatus
    OFDOldestUnsent    : Integer;        //35+ Дата старейшего неотправленного документа - число дней от 30.12.1899, соотвтетствующий флаг fnOFDStatus
    OFDOldestUnsentTime: Integer;        //37+ Время в миллисекундах от начала дня старейшего неотправленного документа, соотвтетствующий флаг fnOFDStatus
    InternalDate       : Integer;        //39+ Внутренняя дата в ФР - число дней от 30.12.1899, соотвтетствующий флаг fnInternalDateTime
    InternalTime       : Integer;        //39+ Внутреннее время в ФР в миллисекундах от начала дня, соотвтетствующий флаг fnInternalDateTime
    ProgramDateMin     : Integer;        //53+ Минимально допустимая для программирования дата. 0 - если не ограничено. флаг fnProgramDateTimeMin.
    ProgramTimeMin     : Integer;        //53+ Минимально допустимое для программирования время. Значимо, если ProgramDateMin > 0. флаг fnProgramDateTimeMin.
  end;

type
  TfpStatusField = class
  public
    constructor Create;
    procedure SetDefault; virtual; abstract;
    function ToLogStr: UTF8String; virtual; abstract;
    function Name: UTF8String;virtual;
  protected
    FisNeeded: Boolean;
    FisFilled: Boolean;
    procedure SetValue;
  public
    property isNeeded: Boolean read FisNeeded;
    property isFilled: Boolean read FisFilled;
  end;

type
  TfpStatusField_Ready = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
  end;

  TfpStatusField_Busy = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
  end;

  TfpStatusField_CanPrintUnfiscal = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
  end;

  TfpStatusField_QueueSize = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    property Value: Integer read FValue write SetValue;
  end;

  TfpStatusField_DrawerOpened = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
  end;

  TfpStatusField_ShiftState = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: TUFRShiftState;
    procedure SetValue(const Value: TUFRShiftState);
  public
    property Value: TUFRShiftState read FValue write SetValue;
  end;

  TfpStatusField_SerialNum = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: UTF8String;
    procedure SetValue(const Value: UTF8String);
  public
    property Value: UTF8String read FValue write SetValue;
  end;

  TfpStatusField_LastShiftNum = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Word;
    procedure SetValue(const Value: Word);
  public
    property Value: Word read FValue write SetValue;
  end;

  TfpStatusField_LastDocNum = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    property Value: Integer read FValue write SetValue;
  end;

  TfpStatusField_LastReceiptNum = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    property Value: Integer read FValue write SetValue;
  end;

  TfpStatusField_SaledValue = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Int64;
    procedure SetValue(const Value: Int64);
  public
    property Value: Int64 read FValue write SetValue;
  end;

  TfpStatusField_CashRegValue = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Int64;
    procedure SetValue(const Value: Int64);
  public
    property Value: Int64 read FValue write SetValue;
  end;

  TePaperStatus = (paperOk, paperOut, paperLow);

  TfpStatusField_PaperStatus = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: TePaperStatus;
    procedure SetValue(const Value: TePaperStatus);
  public
    property Value: TePaperStatus read FValue write SetValue;
  end;

  TfpStatusField_XMLbuffer = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: UTF8String;
    procedure SetValue(const Value: UTF8String);
  public
    property Value: UTF8String read FValue write SetValue;
  end;

  TfpStatusField_EKLZnearEnd = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Boolean;
    procedure SetValue(const Value: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
  end;

  TfpStatusField_OFDunSentCount = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    property Value: Integer read FValue write SetValue;
  end;

  TfpStatusField_OFDoldestUnSent = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: TDateTime;
    procedure SetValue(const Value: TDateTime);
  public
    property Value: TDateTime read FValue write SetValue;
  end;

  TfpStatusField_InternalDateTime = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: TDateTime;
    procedure SetValue(const Value: TDateTime);
  public
    property Value: TDateTime read FValue write SetValue;
  end;

  TfpStatusField_ProgramDateTimeMin = class(TfpStatusField)
  public
    procedure SetDefault; override;
    function ToLogStr: UTF8String; override;
  protected
    FValue: TDateTime;
    procedure SetValue(const Value: TDateTime);
  public
    property Value: TDateTime read FValue write SetValue;
  end;

type
  TfpeStatusFields = (
     fpReady
    ,fpBusy
    ,fpCanPrintUnfiscal
    ,fpQueueSize
    ,fpDrawerOpened
    ,fpShiftState
    ,fpSerialNum
    ,fpLastShiftNum
    ,fpLastDocNum
    ,fpLastReceiptNum
    ,fpSaledValue
    ,fpCashRegValue
    ,fpPaperStatus
    ,fpXMLBuffer
    ,fpEKLZNearEnd
    ,fpOFDUnsentCount
    ,fpOFDoldestUnsent
    ,fpInternalDateTime
    ,fpProgramDateTimeMin
  );

type
  TfpStatus = class
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnterProc(AdwFieldsNeeded: Cardinal);
    function  LeaveProc(var AUFRStatus: TUFRStatus; var AdwFieldsFilled: Cardinal; AResult: TUFRresult): Boolean;
    function ToLogStr: UTF8String;
    function NeedsToLogStr: UTF8String;
  private
    FFields: array[TfpeStatusFields] of TfpStatusField               ;
    function GetReady             : TfpStatusField_Ready             ;
    function GetBusy              : TfpStatusField_Busy              ;
    function GetCanPrintUnfiscal  : TfpStatusField_CanPrintUnfiscal  ;
    function GetQueueSize         : TfpStatusField_QueueSize         ;
    function GetDrawerOpened      : TfpStatusField_DrawerOpened      ;
    function GetShiftState        : TfpStatusField_ShiftState        ;
    function GetSerialNum         : TfpStatusField_SerialNum         ;
    function GetLastShiftNum      : TfpStatusField_LastShiftNum      ;
    function GetLastDocNum        : TfpStatusField_LastDocNum        ;
    function GetLastReceiptNum    : TfpStatusField_LastReceiptNum    ;
    function GetSaledValue        : TfpStatusField_SaledValue        ;
    function GetCashRegValue      : TfpStatusField_CashRegValue      ;
    function GetPaperStatus       : TfpStatusField_PaperStatus       ;
    function GetXMLBuffer         : TfpStatusField_XMLBuffer         ;
    function GetEKLZNearEnd       : TfpStatusField_EKLZNearEnd       ;
    function GetOFDUnsentCount    : TfpStatusField_OFDUnsentCount    ;
    function GetOFDoldestUnsent   : TfpStatusField_OFDoldestUnsent   ;
    function GetInternalDateTime  : TfpStatusField_InternalDateTime  ;
    function GetProgramDateTimeMin: TfpStatusField_ProgramDateTimeMin;
  public
    property Ready             : TfpStatusField_Ready              read GetReady             ; // Не готов
    property Busy              : TfpStatusField_Busy               read GetBusy              ; // Работает [занят]
    property CanPrintUnfiscal  : TfpStatusField_CanPrintUnfiscal   read GetCanPrintUnfiscal  ; // Невозможно выполнить нефискальную печать
    property QueueSize         : TfpStatusField_QueueSize          read GetQueueSize         ; // Размер очереди на печать для нефискальной печати. NOTE по возможности, надо возвращать сумму длин очередей драйвера и устройства
    property DrawerOpened      : TfpStatusField_DrawerOpened       read GetDrawerOpened      ; // Ящик открыт
    property ShiftState        : TfpStatusField_ShiftState         read GetShiftState        ; // Статус фискальной смены
    property SerialNum         : TfpStatusField_SerialNum          read GetSerialNum         ; // Уникальный идентификатор фискального регистратора (с моделью)
    property LastShiftNum      : TfpStatusField_LastShiftNum       read GetLastShiftNum      ; // Последний номер Z отчёта (номер закрытой смены)
    property LastDocNum        : TfpStatusField_LastDocNum         read GetLastDocNum        ; // Последний номер документа (в том числе инкассации и т.п.)
    property LastReceiptNum    : TfpStatusField_LastReceiptNum     read GetLastReceiptNum    ; // Последний номер чека
    property SaledValue        : TfpStatusField_SaledValue         read GetSaledValue        ; // Сумма продаж за смену, в копейках
    property CashRegValue      : TfpStatusField_CashRegValue       read GetCashRegValue      ; // Сумма в кассе, в копейках
    property PaperStatus       : TfpStatusField_PaperStatus        read GetPaperStatus       ; //15+ paperOk=0 - ок, paperOut=1 - бумага закончилась,  paperLow=2 - бумага близка к завершению
    property XMLBuffer         : TfpStatusField_XMLBuffer          read GetXMLBuffer         ; //17+ буфер для возврата XML в виде строки в кодировке utf-8, заполняется до вызова UFRGetStatus или UFRFiscalDocument, перед вызовом надо в первый байт буфера прописать 0
    property EKLZNearEnd       : TfpStatusField_EKLZNearEnd        read GetEKLZNearEnd       ; //22+ Warning о скором заполнении ЭКЛЗ или его аналогов
    property OFDUnsentCount    : TfpStatusField_OFDUnsentCount     read GetOFDUnsentCount    ; //35+ Количество неотправленных в ОФД документов, соотвтетствующий флаг fnOFDStatus
    property OFDoldestUnsent   : TfpStatusField_OFDoldestUnsent    read GetOFDoldestUnsent   ; //35+ Дата/время старейшего неотправленного документа, соотвтетствующий флаг fnOFDStatus
    property InternalDateTime  : TfpStatusField_InternalDateTime   read GetInternalDateTime  ; //39+ Внутренняя дата/время в ФР, соотвтетствующий флаг fnInternalDateTime
    property ProgramDateTimeMin: TfpStatusField_ProgramDateTimeMin read GetProgramDateTimeMin;
  end;

implementation

{ TfpStatus }

const
  fnNotCancelReceipt = $00001; // Не отменять открытый чек.
  fnBusy             = $00002; // Требуется заполнить Busy и NotReady.
  fnUnfiscalPrint    = $00004; // Требуется заполнить CanNotPrintUnfiscal.
  fnPrintQueue       = $00008; // Длина очереди печати (для нефискальной печати).
  fnDrawerOpened     = $00010; // Признак открытого ящика.
  fnPaperStatus      = $00020; // Надо вернуть информацию о конце бумаги
  fnShiftState       = $00100; // Статус фискальной смены.
  fnSerialNumber     = $00200; // Строка-идентификатор ФР, кроме серийного номера можно прописать закодированную модель ФР.
  fnLastShiftNum     = $00400; // Номер последней закрытой[!] фискальной смены, если первая смена, то 0.
  fnLastDocNum       = $00800; // Последний номер напечатанного документа (включая внесения-выдачи).
  fnLastReceiptNum   = $01000; // Последний номер фискального чека может совпадать с номером документа.
  fnSaledValue       = $02000; // Сумма продаж или за смену или глобально. Использовать только для проверки изменилась/не изменилась (прошёл или нет последний чек).
  fnOFDStatus        = $04000; // информация о неотправленных документах и признак скорого переполнения EKLZNearEnd
  fnCashRegValue     = $08000; // Запрос значения регистра кассовой наличности в ФР.
  fnInternalDateTime = $10000; // Запрос полей InternalDate и InternalTime.
  fnProgramDateTimeMin  = $20000; //53+ Запрос полей ProgramDateMin, ProgramTimeMin

  DW_FIELDS_NEEDED: array[TfpeStatusFields] of DWORD = (
     fnBusy             // fpReady
    ,fnBusy             // fpBusy
    ,fnUnfiscalPrint    // fpCanPrintUnfiscal
    ,fnPrintQueue       // fpQueueSize
    ,fnDrawerOpened     // fpDrawerOpened
    ,fnShiftState       // fpUFRShiftState
    ,fnSerialNumber     // fpSerialNum
    ,fnLastShiftNum     // fpLastShiftNum
    ,fnLastDocNum       // fpLastDocNum
    ,fnLastReceiptNum   // fpLastReceiptNum
    ,fnSaledValue       // fpSaledValue
    ,fnCashRegValue     // fpCashRegValue
    ,fnPaperStatus      // fpPaperStatus
    ,0                  // fpXMLBuffer
    ,fnOFDStatus        // fpEKLZNearEnd
    ,fnOFDStatus        // fpOFDUnsentCount
    ,fnOFDStatus        // fpOFDoldestUnsent
    ,fnInternalDateTime // fpInternalDateTime
    ,fnProgramDateTimeMin  // fpProgramDateTimeMin
  );

constructor TfpStatus.Create;
var
  fpeStatusFields: TfpeStatusFields;
begin
  inherited;

  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do FFields[fpeStatusFields] := nil;

  FFields[fpReady           ] := TfpStatusField_Ready           .Create;
  FFields[fpBusy            ] := TfpStatusField_Busy            .Create;
  FFields[fpCanPrintUnfiscal] := TfpStatusField_CanPrintUnfiscal.Create;
  FFields[fpQueueSize       ] := TfpStatusField_QueueSize       .Create;
  FFields[fpDrawerOpened    ] := TfpStatusField_DrawerOpened    .Create;
  FFields[fpShiftState      ] := TfpStatusField_ShiftState      .Create;
  FFields[fpSerialNum       ] := TfpStatusField_SerialNum       .Create;
  FFields[fpLastShiftNum    ] := TfpStatusField_LastShiftNum    .Create;
  FFields[fpLastDocNum      ] := TfpStatusField_LastDocNum      .Create;
  FFields[fpLastReceiptNum  ] := TfpStatusField_LastReceiptNum  .Create;
  FFields[fpSaledValue      ] := TfpStatusField_SaledValue      .Create;
  FFields[fpCashRegValue    ] := TfpStatusField_CashRegValue    .Create;
  FFields[fpPaperStatus     ] := TfpStatusField_PaperStatus     .Create;
  FFields[fpXMLBuffer       ] := TfpStatusField_XMLBuffer       .Create;
  FFields[fpEKLZNearEnd     ] := TfpStatusField_EKLZNearEnd     .Create;
  FFields[fpOFDUnsentCount  ] := TfpStatusField_OFDUnsentCount  .Create;
  FFields[fpOFDoldestUnsent ] := TfpStatusField_OFDoldestUnsent .Create;
  FFields[fpInternalDateTime] := TfpStatusField_InternalDateTime.Create;
  FFields[fpProgramDateTimeMin] := TfpStatusField_ProgramDateTimeMin.Create;

  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do Assert(Assigned(FFields[fpeStatusFields]));
end;

destructor TfpStatus.Destroy;
var
  fpeStatusFields: TfpeStatusFields;
begin
  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do FFields[fpeStatusFields].Free;

  inherited;
end;

procedure TfpStatus.EnterProc(AdwFieldsNeeded: Cardinal);
var
  fpeStatusFields: TfpeStatusFields;
begin
  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do begin
    FFields[fpeStatusFields].FisNeeded := ((DW_FIELDS_NEEDED[fpeStatusFields] and AdwFieldsNeeded) <> 0);
    FFields[fpeStatusFields].FisFilled := False;
  end;
end;

function TfpStatus.GetReady           : TfpStatusField_Ready           ;
begin
  Result := FFields[fpReady           ] as TfpStatusField_Ready           ;
end;

function TfpStatus.GetBusy            : TfpStatusField_Busy            ;
begin
  Result := FFields[fpBusy            ] as TfpStatusField_Busy            ;
end;

function TfpStatus.GetCanPrintUnfiscal: TfpStatusField_CanPrintUnfiscal;
begin
  Result := FFields[fpCanPrintUnfiscal] as TfpStatusField_CanPrintUnfiscal;
end;

function TfpStatus.GetQueueSize       : TfpStatusField_QueueSize       ;
begin
  Result := FFields[fpQueueSize       ] as TfpStatusField_QueueSize       ;
end;

function TfpStatus.GetDrawerOpened    : TfpStatusField_DrawerOpened    ;
begin
  Result := FFields[fpDrawerOpened    ] as TfpStatusField_DrawerOpened    ;
end;

function TfpStatus.GetShiftState      : TfpStatusField_ShiftState      ;
begin
  Result := FFields[fpShiftState      ] as TfpStatusField_ShiftState      ;
end;

function TfpStatus.GetSerialNum       : TfpStatusField_SerialNum       ;
begin
  Result := FFields[fpSerialNum       ] as TfpStatusField_SerialNum       ;
end;

function TfpStatus.GetLastShiftNum    : TfpStatusField_LastShiftNum    ;
begin
  Result := FFields[fpLastShiftNum    ] as TfpStatusField_LastShiftNum    ;
end;

function TfpStatus.GetLastDocNum      : TfpStatusField_LastDocNum      ;
begin
  Result := FFields[fpLastDocNum      ] as TfpStatusField_LastDocNum      ;
end;

function TfpStatus.GetLastReceiptNum  : TfpStatusField_LastReceiptNum  ;
begin
  Result := FFields[fpLastReceiptNum  ] as TfpStatusField_LastReceiptNum  ;
end;

function TfpStatus.GetSaledValue      : TfpStatusField_SaledValue      ;
begin
  Result := FFields[fpSaledValue      ] as TfpStatusField_SaledValue      ;
end;

function TfpStatus.GetCashRegValue    : TfpStatusField_CashRegValue    ;
begin
  Result := FFields[fpCashRegValue    ] as TfpStatusField_CashRegValue    ;
end;

function TfpStatus.GetPaperStatus     : TfpStatusField_PaperStatus     ;
begin
  Result := FFields[fpPaperStatus     ] as TfpStatusField_PaperStatus     ;
end;

function TfpStatus.GetXMLBuffer       : TfpStatusField_XMLBuffer       ;
begin
  Result := FFields[fpXMLBuffer       ] as TfpStatusField_XMLBuffer       ;
end;

function TfpStatus.GetEKLZNearEnd     : TfpStatusField_EKLZNearEnd     ;
begin
  Result := FFields[fpEKLZNearEnd     ] as TfpStatusField_EKLZNearEnd     ;
end;

function TfpStatus.GetOFDUnsentCount  : TfpStatusField_OFDUnsentCount  ;
begin
  Result := FFields[fpOFDUnsentCount  ] as TfpStatusField_OFDUnsentCount  ;
end;

function TfpStatus.GetOFDoldestUnsent : TfpStatusField_OFDoldestUnsent ;
begin
  Result := FFields[fpOFDoldestUnsent ] as TfpStatusField_OFDoldestUnsent ;
end;

function TfpStatus.GetInternalDateTime: TfpStatusField_InternalDateTime;
begin
  Result := FFields[fpInternalDateTime] as TfpStatusField_InternalDateTime;
end;

function TfpStatus.GetProgramDateTimeMin: TfpStatusField_ProgramDateTimeMin;
begin
  Result := FFields[fpProgramDateTimeMin] as TfpStatusField_ProgramDateTimeMin;
end;

procedure FillDateTime(Adt: TDateTime; out AiDate, AiTime: Integer);
begin
  AiDate := DaysBetween(EncodeDate(1899, 12, 30), Adt);
  AiTime := MilliSecondOfTheDay(Adt);
end;

function FillBuffer(const AusData: UTF8String; ApcBuffer: PAnsiChar; var AiBufferSize: Integer; AResult: TUFRresult): Boolean;
var
  us: UTF8String;
begin
  Result := False;

  if Assigned(ApcBuffer) then begin
    us := AusData + #0;

    if Length(us) <= AiBufferSize then begin
      StrPCopy(ApcBuffer, us);
    end else begin
      AiBufferSize := Length(us);
      AResult.SetValue(errAssertInsufficientBufferSize, '');
      Exit;
    end;
  end;

  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TfpStatus.LeaveProc(var AUFRStatus: TUFRStatus; var AdwFieldsFilled: Cardinal; AResult: TUFRresult): Boolean;
const
  I_PAPER_STATUS: array[TePaperStatus] of Integer = (0, 1, 2);
var
  UFRStatus: TUFRStatus;
  iSize: Integer;
  fpeStatusFields: TfpeStatusFields;
begin
  Result := False;

  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do if FFields[fpeStatusFields].isNeeded and not FFields[fpeStatusFields].isFilled then FFields[fpeStatusFields].SetDefault;

  FillChar(UFRStatus, SizeOf(UFRStatus), 0); // Если драйвер не поддерживает какое то поле, оно остаётся заполнено нулём (драйвер неизвестную ему часть структуры не трогает).
  iSize :=  AUFRStatus.Size;
  if iSize > SizeOf(UFRStatus) then iSize := SizeOf(UFRStatus);
  Move(AUFRStatus, UFRStatus, iSize);

  if FFields[fpReady             ].isFilled then UFRStatus.NotReady            := not (FFields[fpReady           ] as TfpStatusField_Ready           ).Value;
  if FFields[fpBusy              ].isFilled then UFRStatus.Busy                :=     (FFields[fpBusy            ] as TfpStatusField_Busy            ).Value;
  if FFields[fpCanPrintUnfiscal  ].isFilled then UFRStatus.CannotPrintUnfiscal := not (FFields[fpCanPrintUnfiscal] as TfpStatusField_CanPrintUnfiscal).Value;
  if FFields[fpQueueSize         ].isFilled then UFRStatus.QueueSize           :=     (FFields[fpQueueSize       ] as TfpStatusField_QueueSize       ).Value;
  if FFields[fpDrawerOpened      ].isFilled then UFRStatus.DrawerOpened        :=     (FFields[fpDrawerOpened    ] as TfpStatusField_DrawerOpened    ).Value;
  if FFields[fpShiftState        ].isFilled then UFRStatus.ShiftState          :=     (FFields[fpShiftState      ] as TfpStatusField_ShiftState      ).Value;
  if FFields[fpSerialNum         ].isFilled then UFRStatus.SerialNum           :=     (FFields[fpSerialNum       ] as TfpStatusField_SerialNum       ).Value;
  if FFields[fpLastShiftNum      ].isFilled then UFRStatus.LastShiftNum        :=     (FFields[fpLastShiftNum    ] as TfpStatusField_LastShiftNum    ).Value;
  if FFields[fpLastDocNum        ].isFilled then UFRStatus.LastDocNum          :=     (FFields[fpLastDocNum      ] as TfpStatusField_LastDocNum      ).Value;
  if FFields[fpLastReceiptNum    ].isFilled then UFRStatus.LastReceiptNum      :=     (FFields[fpLastReceiptNum  ] as TfpStatusField_LastReceiptNum  ).Value;
  if FFields[fpSaledValue        ].isFilled then UFRStatus.SaledValue          :=     (FFields[fpSaledValue      ] as TfpStatusField_SaledValue      ).Value;
  if FFields[fpCashRegValue      ].isFilled then UFRStatus.CashRegValue        :=     (FFields[fpCashRegValue    ] as TfpStatusField_CashRegValue    ).Value;
  if FFields[fpPaperStatus       ].isFilled then UFRStatus.PaperStatus         := I_PAPER_STATUS[(FFields[fpPaperStatus] as TfpStatusField_PaperStatus).Value];
  if FFields[fpXMLBuffer         ].isFilled then begin
    if not FillBuffer((FFields[fpXMLBuffer] as TfpStatusField_XMLBuffer).Value, UFRStatus.XMLBuffer, UFRStatus.XMLBufferSize, AResult) then Exit;
  end;
  if FFields[fpEKLZNearEnd       ].isFilled then UFRStatus.EKLZNearEnd         :=     (FFields[fpEKLZNearEnd     ] as TfpStatusField_EKLZNearEnd   ).Value;
  if FFields[fpOFDUnsentCount    ].isFilled then UFRStatus.OFDUnsentCount      :=     (FFields[fpOFDUnsentCount  ] as TfpStatusField_OFDUnsentCount).Value;
  if FFields[fpOFDoldestUnsent   ].isFilled then FillDateTime((FFields[fpOFDoldestUnsent   ] as TfpStatusField_OFDoldestUnsent   ).Value, UFRStatus.OFDOldestUnsent, UFRStatus.OFDOldestUnsentTime);
  if FFields[fpInternalDateTime  ].isFilled then FillDateTime((FFields[fpInternalDateTime  ] as TfpStatusField_InternalDateTime  ).Value, UFRStatus.InternalDate   , UFRStatus.InternalTime       );
  if FFields[fpProgramDateTimeMin].isFilled then FillDateTime((FFields[fpProgramDateTimeMin] as TfpStatusField_ProgramDateTimeMin).Value, UFRStatus.ProgramDateMin , UFRStatus.ProgramTimeMin     );

  Move(UFRStatus, AUFRStatus, iSize);
  AdwFieldsFilled := 0;
  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do if FFields[fpeStatusFields].isFilled then AdwFieldsFilled := AdwFieldsFilled or DW_FIELDS_NEEDED[fpeStatusFields];

  AResult.SetValue(errOk, '');
  Result := True;
end;

function TfpStatus.ToLogStr: UTF8String;
const
  S_SEPARATOR = ', ';
var
  fpeStatusFields: TfpeStatusFields;
begin
  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do if FFields[fpeStatusFields].isFilled then Result := Result + FFields[fpeStatusFields].ToLogStr + S_SEPARATOR;
  if Length(Result) >= Length(S_SEPARATOR) then SetLength(Result, Length(Result) - Length(S_SEPARATOR))
end;

function TfpStatus.NeedsToLogStr: UTF8String;
const
  S_SEPARATOR = ', ';
var
  fpeStatusFields: TfpeStatusFields;
begin
  for fpeStatusFields := Low(TfpeStatusFields) to High(TfpeStatusFields) do begin
    if FFields[fpeStatusFields].isNeeded then Result := Result + FFields[fpeStatusFields].Name + S_SEPARATOR;
  end;
  if Length(Result) >= Length(S_SEPARATOR) then SetLength(Result, Length(Result) - Length(S_SEPARATOR))
end;

{ TfpStatusField }

constructor TfpStatusField.Create;
begin
  FisNeeded := False;
  FisFilled := False;
end;

function TfpStatusField.Name: UTF8String;
begin
  Result := Self.ClassName;
  if Pos('_', Result) > 0 then Result := Copy(Result, Pos('_', Result)+1, MaxInt);
end;

procedure TfpStatusField.SetValue;
begin
  FisFilled := True;
end;

{ TfpStatusField_Ready }

procedure TfpStatusField_Ready.SetDefault;
begin
  SetValue(True);
end;

procedure TfpStatusField_Ready.SetValue(const Value: Boolean);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_Ready.ToLogStr: UTF8String;
const
  S_READY: array[Boolean] of UTF8String = ('NotReady', 'Ready');
begin
  Result := S_READY[FValue];
end;

{ TfpStatusField_Busy }

procedure TfpStatusField_Busy.SetDefault;
begin
  SetValue(False);
end;

procedure TfpStatusField_Busy.SetValue(const Value: Boolean);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_Busy.ToLogStr: UTF8String;
const
  S_BUSY: array[Boolean] of UTF8String = ('NotBusy', 'Busy');
begin
  Result := S_BUSY[FValue];
end;

{ TfpStatusField_CanPrintUnfiscal }

procedure TfpStatusField_CanPrintUnfiscal.SetDefault;
begin
  SetValue(True);
end;

procedure TfpStatusField_CanPrintUnfiscal.SetValue(const Value: Boolean);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_CanPrintUnfiscal.ToLogStr: UTF8String;
const
  S_CAN_PRINT_UNFISC: array[Boolean] of UTF8String = ('CannotPrintUnfiscal', 'CanPrintUnfiscal');
begin
  Result := S_CAN_PRINT_UNFISC[FValue];
end;

{ TfpStatusField_QueueSize }

procedure TfpStatusField_QueueSize.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_QueueSize.SetValue(const Value: Integer);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_QueueSize.ToLogStr: UTF8String;
begin
  Result := Format('QueueSize: %d', [FValue])
end;

{ TfpStatusField_DrawerOpened }

procedure TfpStatusField_DrawerOpened.SetDefault;
begin
  SetValue(False);
end;

procedure TfpStatusField_DrawerOpened.SetValue(const Value: Boolean);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_DrawerOpened.ToLogStr: UTF8String;
const
  S_DRAWER_OPENED: array[Boolean] of UTF8String = ('DrawerClosed', 'DrawerOpened');
begin
  Result := S_DRAWER_OPENED[FValue];
end;

{ TfpStatusField_ShiftState }

procedure TfpStatusField_ShiftState.SetDefault;
begin
  SetValue(ssShiftClosed);
end;

procedure TfpStatusField_ShiftState.SetValue(const Value: TUFRShiftState);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_ShiftState.ToLogStr: UTF8String;
const
  S_SHIFT_STATE: array[TUFRShiftState] of UTF8String = ('ShiftClosed', 'ShiftOpened', 'ShiftOpened24hExceeded'); // ssShiftClosed, ssShiftOpened, ssShiftOpened24hoursExceeded
begin
  Result := S_SHIFT_STATE[FValue];
end;

{ TfpStatusField_SerialNum }

procedure TfpStatusField_SerialNum.SetDefault;
begin
  SetValue('');
end;

procedure TfpStatusField_SerialNum.SetValue(const Value: UTF8String);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_SerialNum.ToLogStr: UTF8String;
begin
  Result := Format('SerialNum: %s', [FValue])
end;

{ TfpStatusField_LastShiftNum }

procedure TfpStatusField_LastShiftNum.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_LastShiftNum.SetValue(const Value: Word);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_LastShiftNum.ToLogStr: UTF8String;
begin
  Result := Format('LastShiftNum: %d', [FValue])
end;

{ TfpStatusField_LastDocNum }

procedure TfpStatusField_LastDocNum.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_LastDocNum.SetValue(const Value: Integer);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_LastDocNum.ToLogStr: UTF8String;
begin
  Result := Format('LastDocNum: %d', [FValue])
end;

{ TfpStatusField_LastReceiptNum }

procedure TfpStatusField_LastReceiptNum.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_LastReceiptNum.SetValue(const Value: Integer);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_LastReceiptNum.ToLogStr: UTF8String;
begin
  Result := Format('LastReceiptNum: %d', [FValue])
end;

{ TfpStatusField_SaledValue }

procedure TfpStatusField_SaledValue.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_SaledValue.SetValue(const Value: Int64);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_SaledValue.ToLogStr: UTF8String;
begin
  Result := Format('SaledValue: %d', [FValue]);
end;

{ TfpStatusField_CashRegValue }

procedure TfpStatusField_CashRegValue.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_CashRegValue.SetValue(const Value: Int64);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_CashRegValue.ToLogStr: UTF8String;
begin
  Result := Format('CashRegValue: %d', [FValue]);
end;

{ TfpStatusField_PaperStatus }

procedure TfpStatusField_PaperStatus.SetDefault;
begin
  SetValue(paperOk);
end;

procedure TfpStatusField_PaperStatus.SetValue(const Value: TePaperStatus);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_PaperStatus.ToLogStr: UTF8String;
const
  S_PAPER_STATUS: array[TePaperStatus] of UTF8String = ('Paper OK', 'Paper Out', 'Paper Low');
begin
  Result := S_PAPER_STATUS[FValue];
end;

{ TfpStatusField_XMLBuffer }

procedure TfpStatusField_XMLbuffer.SetDefault;
begin
  SetValue('');
end;

procedure TfpStatusField_XMLbuffer.SetValue(const Value: UTF8String);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_XMLbuffer.ToLogStr: UTF8String;
begin
  Result := Format('XMLBuffer: %s', [FValue]);
end;

{ TfpStatusField_EKLZNearEnd }

procedure TfpStatusField_EKLZnearEnd.SetDefault;
begin
  SetValue(False);
end;

procedure TfpStatusField_EKLZnearEnd.SetValue(const Value: Boolean);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_EKLZnearEnd.ToLogStr: UTF8String;
const
  S_EKLZ_NEAR_END: array[Boolean] of UTF8String = ('EKLZenoughSpace', 'EKLZnearEnd');
begin
  Result := S_EKLZ_NEAR_END[FValue];
end;

{ TfpStatusField_OFDUnsentCount }

procedure TfpStatusField_OFDunSentCount.SetDefault;
begin
  SetValue(0);
end;

procedure TfpStatusField_OFDunSentCount.SetValue(const Value: Integer);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_OFDunSentCount.ToLogStr: UTF8String;
begin
  Result := Format('OFDUnsentCount: %d', [FValue]);
end;

{ TfpStatusField_OFDoldestUnsent }

procedure TfpStatusField_OFDoldestUnSent.SetDefault;
begin
  SetValue(Now);
end;

procedure TfpStatusField_OFDoldestUnSent.SetValue(const Value: TDateTime);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_OFDoldestUnSent.ToLogStr: UTF8String;
begin
  Result := 'OFDoldestUnsent: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', FValue);
end;

{ TfpStatusField_InternalDateTime }

procedure TfpStatusField_InternalDateTime.SetDefault;
begin
  SetValue(Now);
end;

procedure TfpStatusField_InternalDateTime.SetValue(const Value: TDateTime);
begin
  FValue := Value;
  inherited SetValue;
end;

function TfpStatusField_InternalDateTime.ToLogStr: UTF8String;
begin
  Result := 'InternalDateTime: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', FValue);
end;

{ TfpStatusField_ProgramDateTimeMin }

procedure TfpStatusField_ProgramDateTimeMin.SetDefault;
begin
  FValue := 0;
end;

procedure TfpStatusField_ProgramDateTimeMin.SetValue(const Value: TDateTime);
begin
  inherited SetValue;
  FValue := Value;
end;

function TfpStatusField_ProgramDateTimeMin.ToLogStr: UTF8String;
begin
  Result := 'ProgramDateTimeMin: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', FValue);
end;

end.
