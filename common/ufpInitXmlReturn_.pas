unit ufpInitXmlReturn_;

interface

uses
   SysUtils
  ,Simplexml
  ,uUnFiscXml_
  ,uCommon
  ;

type  //  константам значения НЕ назначать!
  TeOption = (
     optText                  // ФР поддерживает отдельную нефискальную печать (не в чеке)
    ,optZeroReceipt           // ФР поддерживает печать нулевого чека (с нулевой стоимостью)
    ,optDeleteReceipt         // ФР поддерживает удаление чека
    ,optZReport               // ФР поддерживает Z отчёт
    ,optMoneyInOut            // ФР поддерживает внесения-выдачи
    ,optXReport               // ФР поддерживает X отчёт
    ,optSpecialReport         // ФР поддерживает специальные отчёты: - итоговый/детализированный отчет по датам; - итоговый отчет по сменам.
    ,optZeroSale              // ФР поддерживает печать продажи с "нулевой" суммой
    ,optProgram               // ФР поддерживает программирование принтера [при закрытой смене]
    ,optFullLastShift         // ФР поддерживает распечатку последней смены
    ,optAllMoneyOut           // ФР поддерживает изъятие всех денег
    ,optTextInReceipt         // ФР поддерживает нефискальную печать внутри чека (внутри <Header>)
    ,optBarCodeInNotFisc      // ФР поддерживает печать штрих-кода в нефискальной части чека
    ,optZClearMoney           // Z отчёт автоматически очищает остаток денег в кассе
    ,optCheckCopy             // Фискальный документ - копия чека (пока только в Латвии)
    ,optTextInLine            // ФР поддерживает нефискальную печать внутри линии чека (внутри <Item> или <Payment> или <Discount>)
    ,optItemDepartments       // ФР поддерживает отделы по товарам/услугам
    ,optOnlyFixed             // Работа только с заранее запрограммированными блюдами (RK7 в этом случае использует блюда "итого" по отделам с кодами отделов и распечатывает "суммарные" чеки с такими блюдами)
    ,optTextOpenShift         // Признак, что нефискальная печать открывает фискальную смену
    ,optDrawerOpen            // Может открывать ящик
    ,optDrawerState           // Может возвращать состояние ящика
    ,optCustomerDisplay       // Поддерживает вывод на дисплей покупателя
    ,optSlip                  // Поддерживает печать на бланке
    ,optCalcChange            // ФР поддерживает вычисление сдачи
    ,optZWhenClosedShift      // ФР поддерживает печать Z-отчёта при закрытой смене
    ,optAbsDiscountSum        // ФР поддерживает абсолютные суммовые скидки(до версии 11 включение этого флага означает включение и foAbsItemDiscount, foAbsItemMarkup, foAbsMarkupSum)
    ,optFiscInvoice           // ФР поддерживает печать фискального чека как счет-фактуру
    ,optCashRegValue          // ФР поддерживает возврат значения регистра кассовой наличности
    ,optFixedNames            // ФР требует неизменности имён позиций в течении дня
    ,optDeleteReturn          // (версия 1.1+) ФР поддерживает операцию удаление возврата
    ,optDiscWithTaxes         // (версия 9+) ФР принимает скидки на чек вместе с налоговыми ставками, соответственно, скидки должны разбиваться по ставкам,   в скидках на чек надо указывать налоги, иначе для правильного расчёта налогов скидки надо разбивать по блюдам (блюдным скидкам налоги не нужны)
    ,optCanIgnoreTaxes        // ФР имеет режим "без налогов", можно не передавать тэг Taxes
    ,optAbsItemDiscount       // (версия 11+) ФР может печатать скидки на позиции, для более старых версий такие скидки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemDiscount и выключено foAbsDiscountSum, то суммовые скидки разбиваются по позициям.
    ,optAbsItemMarkup         // (версия 11+) ФР может печатать наценки на позиции, для более старых версий такие наценки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemMarkup и выключено foAbsDiscountSum, то суммовые наценки приходят в драйвер разбитые по блюдам.
    ,optAbsMarkupSum          // (версия 11+) ФР поддерживает абсолютные (не процентные) наценки на чек
    ,optMaxOneMarkupDiscount  // (версия 16+) Не больше одной наценки/скидки
    ,optBill                  // (версия 18+) ФР печатает фискальные документы "Счёт"
    ,optCreateCloseOrder      // (версия 18+) ФР печатает фискальные документы "Открытие заказа", "Закрытие заказа"
    ,optCorrection            // (версия 18+) ФР печатает фискальные документы "Коррекция заказа"
    ,optReturnReceipt         // (версия 20+) ФР печатает фискальные документы "Возврат по чеку"
    ,optPayUngrouped          // (версия 24+) Не группировать платежи по индексу платежа, добавлять в тэг Payment атрибуты ISOCode, Rate и OriginalValue
    ,optLogger                // (версия 25+) Устройство используется ля логирования печати других устройств
    ,optWorkWithoutPaper      // (версия 27+) Устройство может выполнять фискальные операции без бумаги. Если это не устраивает, хост должен анализировать PaperStatus
    ,optCorrectPriceToPay     // (версия 32+) Если хост поддерживает протокол 32 и драйвер выставил эту опцию, хост должен передавать атрибут PriceToPay и так, чтобы PriceToPay * Quantity равна сумме к оплате по позиции, если опции нет, то может передавать, может не передавать, а драйвер может вычислить.
    ,optRoundDiscountOnly     // (версия 32+) Если выставлена эта опция, то корректировка округления добавляется отдельной суммарной скидкой без налогов на маленькую сумму. При foAbsDiscountSum без foAbsItemDiscount поведение аналогичное, но скидка с налогами если foDiscWithTaxes.
    ,optCorrectionReceipt     // (версия 35+) ФР печатает фискальные документы "Чек коррекции" (Россия)
    ,optManyCashInOutPayments // (версия 40+) ФР умеет принимать несколько типов платежей в одном документе CashInOut. Если не указана, то тэг Payment должен быть только один.
    ,optOpenShiftReport       // (версия 48+) ФР умеет делать отчёт OpenShiftReport - отчёт открытия смены.
    ,optCancelOrder           // (версия 57+) ФР умеет печатать фискальный документ CancelOrder
    ,optCancelBill            // (версия 58+) ФР умеет печатать фискальный документ CancelBill - документ отмены счёта/пречека
  );
  TsetOptions = set of TeOption;
const
  S_OPTION: array[TeOption] of UTF8String = (
     'Text'
    ,'ZeroReceipt'
    ,'DeleteReceipt'
    ,'ZReport'
    ,'MoneyInOut'
    ,'XReport'
    ,'SpecialReport'
    ,'ZeroSale'
    ,'Program'
    ,'FullLastShift'
    ,'AllMoneyOut'
    ,'TextInReceipt'
    ,'BarCodeInNotFisc'
    ,'ZClearMoney'
    ,'CheckCopy'
    ,'TextInLine'
    ,'ItemDepartments'
    ,'OnlyFixed'
    ,'TextOpenShift'
    ,'DrawerOpen'
    ,'DrawerState'
    ,'CustomerDisplay'
    ,'Slip'
    ,'CalcChange'
    ,'ZWhenClosedShift'
    ,'AbsDiscountSum'
    ,'FiscInvoice'
    ,'CashRegValue'
    ,'FixedNames'
    ,'DeleteReturn'
    ,'DiscWithTaxes'
    ,'CanIgnoreTaxes'
    ,'AbsItemDiscount'
    ,'AbsItemMarkup'
    ,'AbsMarkupSum'
    ,'MaxOneMarkupDiscount' //  с версии 16
    ,'Bill'              // (версия 18+)
    ,'CreateCloseOrder'  // (версия 18+)
    ,'Correction'        // (версия 18+)
    ,'ReturnReceipt'     // (версия 20+) ФР печатает фискальные документы "Возврат по чеку"
    ,'PayUngrouped'      // (версия 24+) Не группировать платежи по индексу платежа, добавлять в тэг Payment атрибуты ISOCode, Rate и OriginalValue
    ,'Logger'            // (версия 25+) Устройство используется ля логирования печати других устройств
    ,'WorkWithoutPaper'  // (версия 27+) Устройство может выполнять фискальные операции без бумаги. Если это не устраивает, хост должен анализировать PaperStatus
    ,'CorrectPriceToPay' // (версия 32+) Если хост поддерживает протокол 32 и драйвер выставил эту опцию, хост должен передавать атрибут PriceToPay и так, чтобы PriceToPay * Quantity равна сумме к оплате по позиции, если опции нет, то может передавать, может не передавать, а драйвер может вычислить.
    ,'RoundDiscountOnly' // (версия 32+) Если выставлена эта опция, то корректировка округления добавляется отдельной суммарной скидкой без налогов на маленькую сумму. При foAbsDiscountSum без foAbsItemDiscount поведение аналогичное, но скидка с налогами если foDiscWithTaxes.
    ,'CorrectionReceipt' // (версия 35+) ФР печатает фискальные документы "Чек коррекции" (Россия)
    ,'ManyCashInOutPayments' // (версия 40+) ФР умеет принимать несколько типов платежей в одном документе CashInOut. Если не указана, то тэг Payment должен быть только один.
    ,'OpenShiftReport'       // (версия 48+) ФР умеет делать отчёт OpenShiftReport - отчёт открытия смены.
    ,'CancelOrder'           // (версия 57+) ФР умеет печатать фискальный документ CancelOrder
    ,'CancelBill'            // (версия 58+) ФР умеет печатать фискальный документ CancelBill - документ отмены счёта/пречека
  );
const
  I6_OPTION: array[TeOption] of Int64 = (
     $00000000000001 // Text                  ФР поддерживает отдельную нефискальную печать (не в чеке)
    ,$00000000000002 // ZeroReceipt           ФР поддерживает печать нулевого чека (с нулевой стоимостью)
    ,$00000000000004 // DeleteReceipt         ФР поддерживает удаление чека
    ,$00000000000008 // ZReport               ФР поддерживает Z отчёт
    ,$00000000000010 // MoneyInOut            ФР поддерживает внесения-выдачи
    ,$00000000000020 // XReport               ФР поддерживает X отчёт
    ,$00000000000040 // SpecialReport         ФР поддерживает специальные отчёты: - итоговый/детализированный отчет по датам; - итоговый отчет по сменам.
    ,$00000000000080 // ZeroSale              ФР поддерживает печать продажи с "нулевой" суммой
    ,$00000000000100 // Program               ФР поддерживает программирование принтера [при закрытой смене]
    ,$00000000000200 // FullLastShift         ФР поддерживает распечатку последней смены
    ,$00000000000400 // AllMoneyOut           ФР поддерживает изъятие всех денег
    ,$00000000000800 // TextInReceipt         ФР поддерживает нефискальную печать внутри чека (внутри <Header>)
    ,$00000000001000 // BarCodeInNotFisc      ФР поддерживает печать штрих-кода в нефискальной части чека
    ,$00000000002000 // ZClearMoney           Z отчёт автоматически очищает остаток денег в кассе
    ,$00000000004000 // CheckCopy             Фискальный документ - копия чека (пока только в Латвии)
    ,$00000000008000 // TextInLine            ФР поддерживает нефискальную печать внутри линии чека (внутри <Item> или <Payment> или <Discount>)
    ,$00000000010000 // ItemDepartments       ФР поддерживает отделы по товарам/услугам
    ,$00000000020000 // OnlyFixed             Работа только с заранее запрограммированными блюдами (RK7 в этом случае использует блюда "итого" по отделам с кодами отделов и распечатывает "суммарные" чеки с такими блюдами)
    ,$00000000040000 // TextOpenShift         Признак, что нефискальная печать открывает фискальную смену
    ,$00000000080000 // DrawerOpen            Может открывать ящик
    ,$00000000100000 // DrawerState           Может возвращать состояние ящика
    ,$00000000200000 // CustomerDisplay       Поддерживает вывод на дисплей покупателя
    ,$00000000400000 // Slip                  Поддерживает печать на бланке
    ,$00000000800000 // CalcChange            ФР поддерживает вычисление сдачи
    ,$00000001000000 // ZWhenClosedShift      ФР поддерживает печать Z-отчёта при закрытой смене
    ,$00000002000000 // AbsDiscountSum        ФР поддерживает абсолютные суммовые скидки(до версии 11 включение этого флага означает включение и foAbsItemDiscount, foAbsItemMarkup, foAbsMarkupSum)
    ,$00000004000000 // FiscInvoice           ФР поддерживает печать фискального чека как счет-фактуру
    ,$00000008000000 // CashRegValue          ФР поддерживает возврат значения регистра кассовой наличности
    ,$00000010000000 // FixedNames            ФР требует неизменности имён позиций в течении дня
    ,$00000020000000 // DeleteReturn          (версия 1.1+) ФР поддерживает операцию удаление возврата
    ,$00000040000000 // DiscWithTaxes         (версия 9+) ФР принимает скидки на чек вместе с налоговыми ставками, соответственно, скидки должны разбиваться по ставкам, в скидках на чек надо указывать налоги, иначе для правильного расчёта налогов скидки надо разбивать по блюдам (блюдным скидкам налоги не нужны)
    ,$00000080000000 // CanIgnoreTaxes        ФР имеет режим "без налогов", можно не передавать тэг Taxes
    ,$00000100000000 // AbsItemDiscount       (версия 11+) ФР может печатать скидки на позиции, для более старых версий такие скидки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemDiscount и выключено foAbsDiscountSum, то суммовые скидки разбиваются по позициям.
    ,$00000200000000 // AbsItemMarkup         (версия 11+) ФР может печатать наценки на позиции, для более старых версий такие наценки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemMarkup и выключено foAbsDiscountSum, то суммовые наценки приходят в драйвер разбитые по блюдам.
    ,$00000400000000 // AbsMarkupSum          (версия 11+) ФР поддерживает абсолютные (не процентные) наценки на чек
    ,$00000800000000 // MaxOneMarkupDiscount  (версия 16+) Не больше одной наценки/скидки
    ,$00001000000000 // Bill                  (версия 18+) ФР печатает фискальные документы "Счёт"
    ,$00002000000000 // CreateCloseOrder      (версия 18+) ФР печатает фискальные документы "Открытие заказа", "Закрытие заказа"
    ,$00004000000000 // Correction            (версия 18+) ФР печатает фискальные документы "Коррекция заказа"
    ,$00008000000000 // ReturnReceipt         (версия 20+) ФР печатает фискальные документы "Возврат по чеку"
    ,$00010000000000 // PayUngrouped          (версия 24+) Не группировать платежи по индексу платежа, добавлять в тэг Payment атрибуты ISOCode, Rate и OriginalValue
    ,$00020000000000 // Logger                (версия 25+) Устройство используется ля логирования печати других устройств
    ,$00040000000000 // WorkWithoutPaper      (версия 27+) Устройство может выполнять фискальные операции без бумаги. Если это не устраивает, хост должен анализировать PaperStatus
    ,$00080000000000 // CorrectPriceToPay     (версия 32+) Если хост поддерживает протокол 32 и драйвер выставил эту опцию, хост должен передавать атрибут PriceToPay и так, чтобы PriceToPay * Quantity равна сумме к оплате по позиции, если опции нет, то может передавать, может не передавать, а драйвер может вычислить.
    ,$00100000000000 // RoundDiscountOnly     (версия 32+) Если выставлена эта опция, то корректировка округления добавляется отдельной суммарной скидкой без налогов на маленькую сумму. При foAbsDiscountSum без foAbsItemDiscount поведение аналогичное, но скидка с налогами если foDiscWithTaxes.
    ,$00200000000000 // CorrectionReceipt     (версия 35+) ФР печатает фискальные документы "Чек коррекции" (Россия)
    ,$00400000000000 // ManyCashInOutPayments (версия 40+) ФР умеет принимать несколько типов платежей в одном документе CashInOut. Если не указана, то тэг Payment должен быть только один.
    ,$00800000000000 // OpenShiftReport       (версия 48+) ФР умеет делать отчёт OpenShiftReport - отчёт открытия смены.
    ,$01000000000000 // CancelOrder           (версия 57+) ФР умеет печатать фискальный документ CancelOrder
    ,$02000000000000 // CancelBill            (версия 58+) ФР умеет печатать фискальный документ CancelBill - документ отмены счёта/пречека
  );

type // константам значения НЕ назначать!
  TeDialogType = (
     dlgtDateInterval
    ,dlgtNumberInterval
    ,dlgtOneDate
    ,dlgtOneNumber
  );
const
  S_DIALOG_TYPE: array[TeDialogType] of UTF8String = (
     'DateInterval'
    ,'NumberInterval'
    ,'OneDate'
    ,'OneNumber'
  );

type
  TDialogInfo_tag = class
  private
    FeDialogType: TeDialogType;
    FusCaption: UTF8String; //  не обязательный
  public
    constructor Create(AeDialogType: TeDialogType; const AusCaption: UTF8String = '');
    function ToXML: IXmlNode;
  end;

  TMenuItem_tag = class
  private
    FusCaption: UTF8String; //  обязательный
  public
    function ToXML: IXmlNode; virtual; abstract;
  end;

  TMenuItem_end_tag = class(TMenuItem_tag)
  private
    FusOperationId: UTF8String; //  {123E720F-BAFC-453F-9948-50662663F75C} - обязательный для исполняемого пункта меню
    FusParameter: UTF8String; //  "12345" - число, не обязательный, если есть будет скопирован при вызове в parameter
    FusPurposeToLock: UTF8String; //  {7DA9C7F9-7DAE-462F-9FC5-113E2E3810B2} - назначение печати, перед выполнением принтер с этого назначения будет заблокирован, не обязательный, ({7DA9C7F9-7DAE-462F-9FC5-113E2E3810B2} - в RK7 "для пречеков")
    FusUserRight: UTF8String; //  {A4C4606D-F7C4-4FBF-83D7-00AD12DD7E55} - пользовательское право, которое будет проверяться перед выполнением, не обязательный
  private
    FDialogInfo: TDialogInfo_tag;
  public
    constructor Create(const AusCaption: UTF8String;
                       const AusOperationId: UTF8String;
                       const AusParameter: UTF8String = '';
                       const AusPurposeToLock: UTF8String = '';
                       const AusUserRight: UTF8String = '';
                       ADialogInfo: TDialogInfo_tag = nil);
    function ToXML: IXmlNode; override;
    destructor Destroy; override;
  end;

  TMenuItem_node_tag = class(TMenuItem_tag)
  private
    FarMenuItem: array of TMenuItem_tag;
  public
    constructor Create(const AusCaption: UTF8String);
    function ToXML: IXmlNode; override;
    procedure AddItem(AMenuItem: TMenuItem_tag);
    destructor Destroy; override;
  end;

  TMenu = class
  private
    FarMenuItem: array of TMenuItem_tag;
  public
    function ToXML: IXmlNode;
    procedure AddItem(AMenuItem: TMenuItem_tag);
    destructor Destroy; override;
  end;

type
  TDialogInfo_oper_tag = class
  private
    FusFrom: UTF8String;
    FusTo: UTF8String;
    function fGeti6(const AsCaption, AsValue: AnsiString): Int64;
    function fGetdt(const AsCaption, AsValue: AnsiString): TDateTime;
    function GetdtFrom: TDateTime;
    function GetdtTo: TDateTime;
    function Geti6From: Int64;
    function Geti6To: Int64;
  public
    constructor Create(AndDialogInfo: IXmlNode);
  public
    property usFrom: UTF8String read FusFrom;
    property usTo  : UTF8String read FusTo  ;
    property dtFrom: TDateTime read GetdtFrom;
    property dtTo  : TDateTime read GetdtTo  ;
    property i6From: Int64 read Geti6From;
    property i6To  : Int64 read Geti6To  ;
  end;

  TMenuOperation = class
  private
    FusOperationId: UTF8String; //  "5B3F851D-1C75-41C1-B3B3-B0927E49D3ED"
    FusParameter: UTF8String; //  "12345"
    FDialogInfo_oper: TDialogInfo_oper_tag;
  public
    constructor Create(ApcXMLData: PAnsiChar; out AusError: UTF8String);
    destructor Destroy; override;
  public
    property usOperationId: UTF8String read FusOperationId;
    property usParameter  : UTF8String read FusParameter  ;
    property DialogInfo_oper: TDialogInfo_oper_tag read FDialogInfo_oper;
  end;

type
  TFiscal_tag = class
  private
    FusEndDate: UTF8String; // "2020-12-23" дата окончания работы (первый день, когда не будет работать) фискального накопителя (и его аналогов), при невозможности заполнить - не добавлять атрибут
  public
    constructor Create;
  public
    function  ToXML: IXmlNode;
    procedure SetEndDate(AdtEndDate: TDateTime);
    property  usEndDate: UTF8String read FusEndDate;
  end;

type
  THardware_tag = class
  private
    FFiscal: TFiscal_tag;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function ToXML: IXmlNode;
    property Fiscal: TFiscal_tag read FFiscal;
  end;

type
  TRounding_tag = class
  private
    Fi6Multiplier: Int64;
  public
    constructor Create;
    function ToXML: IXmlNode;
    property Multiplier: Int64 read Fi6Multiplier write Fi6Multiplier;
  end;

  TDataFormat_tag = class
  private
    FRounding: TRounding_tag;
  public
    constructor Create;
    destructor Destroy; override;
    function ToXML: IXmlNode;
    property Rounding: TRounding_tag  read FRounding;
  end;

type
  TChangeFromTypeIndexes_tag = class
  private
    FarIndexes: array of Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function ToXML: IXmlNode;
    procedure Clear;
    procedure Add(AiIndex: Integer);
  end;

type
  TUFRInitXMLReturn = class
  private
    FiProtocolVersion: Integer;
    FsVersionInfo: AnsiString;
    FsName: AnsiString;
    FsetOptions: TsetOptions;
    FMenu: TMenu;
    FHardware: THardware_tag;
    FDataFormat: TDataFormat_tag;
    FChangeFromTypeIndexes: TChangeFromTypeIndexes_tag;
  public
    constructor Create(AsetOptions: TsetOptions; AiProtocolVersion: Integer; AsName: AnsiString = ''; AsVersionInfo: AnsiString = ''); overload;
    constructor Create(ADriverOptionsMask: Int64; AiProtocolVersion: Integer; AsName: AnsiString = ''; AsVersionInfo: AnsiString = ''); overload;
    destructor Destroy; override;
    function  ToXML: UTF8String;
  public
    property Menu: TMenu read FMenu;
    property Hardware: THardware_tag read FHardware;
    property DataFormat:TDataFormat_tag read FDataFormat;
    property ChangeFromTypeIndexes:TChangeFromTypeIndexes_tag read FChangeFromTypeIndexes;
  end;

type
  TMenuOperationResult = class
  private
    FusOperationId: UTF8String;
//    FPrintUnfiscal: TPrintUnfiscal;
  public
    constructor Create(const AusOperationId: UTF8String);
    destructor Destroy; override;
    function  ToXML: UTF8String;
//  public
//    property PrintUnfiscal: TPrintUnfiscal read FPrintUnfiscal;
  end;

implementation

{ TDialogInfo }

constructor TDialogInfo_tag.Create(AeDialogType: TeDialogType; const AusCaption: UTF8String);
begin
  FeDialogType := AeDialogType;
  FusCaption := AusCaption;
end;

function TDialogInfo_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('DIALOGINFO');

  Result.SetAttr('dialogType', S_DIALOG_TYPE[FeDialogType]);
  if FusCaption <> '' then Result.SetAttr('caption', FusCaption);
end;

{ TMenuItem_end }

constructor TMenuItem_end_tag.Create(const AusCaption, AusOperationId, AusParameter, AusPurposeToLock, AusUserRight: UTF8String; ADialogInfo: TDialogInfo_tag);
begin
  FusCaption := AusCaption;
  FusOperationId   := AusOperationId;
  FusParameter     := AusParameter;
  FusPurposeToLock := AusPurposeToLock;
  FusUserRight     := AusUserRight;

  FDialogInfo := ADialogInfo;
end;

destructor TMenuItem_end_tag.Destroy;
begin
  FDialogInfo.Free;
  
  inherited;
end;

function TMenuItem_end_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('MENUITEM');

  Result.SetAttr('caption', FusCaption);
  if FusOperationId   <> '' then Result.SetAttr('operationId', FusOperationId);
  if FusParameter     <> '' then Result.SetAttr('parameter', FusParameter);
  if FusPurposeToLock <> '' then Result.SetAttr('purposeToLock', FusPurposeToLock);
  if FusUserRight     <> '' then Result.SetAttr('userRight', FusUserRight);

  if Assigned(FDialogInfo) then Result.AppendChild(FDialogInfo.ToXML);
end;

{ TMenuItem_node }

procedure TMenuItem_node_tag.AddItem(AMenuItem: TMenuItem_tag);
begin
  SetLength(FarMenuItem, Length(FarMenuItem) + 1);
  FarMenuItem[High(FarMenuItem)] := AMenuItem;
end;

constructor TMenuItem_node_tag.Create(const AusCaption: UTF8String);
begin
  FusCaption := AusCaption;
end;

destructor TMenuItem_node_tag.Destroy;
var
  i: Integer;
begin
  for i := Low(FarMenuItem) to High(FarMenuItem) do FarMenuItem[i].Free;

  inherited;
end;

function TMenuItem_node_tag.ToXML: IXmlNode;
var
  i: Integer;
begin
  Result := CreateXmlElement('MENUITEM');

  Result.SetAttr('caption', FusCaption);

  for i := Low(FarMenuItem) to High(FarMenuItem) do Result.AppendChild(FarMenuItem[i].ToXML);
end;

{ TMenu }

procedure TMenu.AddItem(AMenuItem: TMenuItem_tag);
begin
  SetLength(FarMenuItem, Length(FarMenuItem) + 1);
  FarMenuItem[High(FarMenuItem)] := AMenuItem;
end;

destructor TMenu.Destroy;
var
  i: Integer;
begin
  for i := Low(FarMenuItem) to High(FarMenuItem) do FarMenuItem[i].Free;

  inherited;
end;

function TMenu.ToXML: IXmlNode;
var
  i: Integer;
begin
  Result := CreateXmlElement('MENU');

  for i := Low(FarMenuItem) to High(FarMenuItem) do Result.AppendChild(FarMenuItem[i].ToXML);
end;

{ TDialogInfo_oper }

constructor TDialogInfo_oper_tag.Create(AndDialogInfo: IXmlNode);
begin
  FusFrom := AndDialogInfo.GetAttr('from');
  FusTo := AndDialogInfo.GetAttr('to');
end;

function TDialogInfo_oper_tag.fGeti6(const AsCaption, AsValue: AnsiString): Int64;
begin
  if not TryStrToInt64(AsValue, Result) then raise Exception.CreateFmt('Wrong "%s" integer value %s', [AsCaption, AsValue]);
end;

function TDialogInfo_oper_tag.fGetdt(const AsCaption, AsValue: AnsiString): TDateTime;
var
  sError: AnsiString;
begin
  sError := ParseDate(AsValue, 'yyyy-mm-dd', Result);
  if sError <> '' then raise Exception.CreateFmt('Wrong "%s" date value %s: %s', [AsCaption, AsValue, sError]);
end;

function TDialogInfo_oper_tag.GetdtFrom: TDateTime;
begin
  Result := fGetdt('from', FusFrom);
end;

function TDialogInfo_oper_tag.GetdtTo: TDateTime;
begin
  Result := fGetdt('to', FusTo);
end;

function TDialogInfo_oper_tag.Geti6From: Int64;
begin
  Result := fGeti6('from', FusFrom);
end;

function TDialogInfo_oper_tag.Geti6To: Int64;
begin
  Result := fGeti6('to', FusTo);
end;

{ TMenuOperation }

constructor TMenuOperation.Create(ApcXMLData: PAnsiChar; out AusError: UTF8String);
var
  XmlDocument: IXmlDocument;
  ndMenuOperation: IXmlNode;
  ndDIALOGINFO: IXmlNode;
begin
  XmlDocument := CreateXmlDocument('', '1.0', 'utf-8');
  try
    XmlDocument.LoadXML(ApcXMLData);
  except
    on E: Exception do begin
      AusError := 'MenuOperation xml loading syntax error: ' + E.Message;
      Exit;
    end;
  end;
  ndMenuOperation := XmlDocument.DocumentElement;

  FusOperationId := ndMenuOperation.GetAttr('operationId');
  FusParameter   := ndMenuOperation.GetAttr('parameter');

  ndDIALOGINFO := ndMenuOperation.SelectSingleNode('DIALOGINFO');
  if Assigned(ndDIALOGINFO) then FDialogInfo_oper := TDialogInfo_oper_tag.Create(ndDIALOGINFO) else FDialogInfo_oper := nil;

  AusError := '';
end;

destructor TMenuOperation.Destroy;
begin
  FDialogInfo_oper.Free;
  
  inherited;
end;

{ TUFRInitXMLReturn }

constructor TUFRInitXMLReturn.Create(AsetOptions: TsetOptions; AiProtocolVersion: Integer; AsName: AnsiString = ''; AsVersionInfo: AnsiString = '');
begin
  FiProtocolVersion := AiProtocolVersion;

  FsetOptions       := AsetOptions;

  FMenu             := TMenu.Create;
  FHardware         := THardware_tag.Create;
  FDataFormat       := TDataFormat_tag.Create;
  FChangeFromTypeIndexes := TChangeFromTypeIndexes_tag.Create;
  FsName            := AsName;
  FsVersionInfo     := AsVersionInfo;
end;

constructor TUFRInitXMLReturn.Create(ADriverOptionsMask: int64; AiProtocolVersion: Integer; AsName: AnsiString = ''; AsVersionInfo: AnsiString = '');
var
  eOption: TeOption;
  setOptions: TsetOptions;
begin
  setOptions       := [];
  for eOption := Low(TeOption) to High(TeOption) do begin
    if (ADriverOptionsMask and  I6_OPTION[eOption]) <> 0 then begin
      Include(setOptions, eOption);
    end;
  end;
  Create(setOptions, AiProtocolVersion, AsName, AsVersionInfo);
end;

destructor TUFRInitXMLReturn.Destroy;
begin
  FMenu.Free;

  FHardware.Free;
  FDataFormat.Free;
  FChangeFromTypeIndexes.Free;
  inherited;
end;

function TUFRInitXMLReturn.ToXML: UTF8String;
var
  docXML: IXmlDocument;
  ndUFRInitXMLReturn: IXmlNode;
  ndOptions: IXmlNode;
  eOption: TeOption;
begin
  docXML := CreateXmlDocument('UFRInitXMLReturn', '1.0', 'utf-8');
  ndUFRInitXMLReturn := docXML.documentElement;

  ndUFRInitXMLReturn.SetIntAttr('MaxProtocolSupported', FiProtocolVersion);
  ndUFRInitXMLReturn.SetAttr('DriverName', fsName);
  ndUFRInitXMLReturn.SetAttr('VersionInfo', FsVersionInfo);

  ndOptions := ndUFRInitXMLReturn.AppendElement('Options');

  for eOption := Low(TeOption) to High(TeOption) do if eOption in FsetOptions then ndOptions.AppendElement('Option').SetAttr('Name', S_OPTION[eOption]);

  ndUFRInitXMLReturn.AppendChild(FMenu.toXML);

  ndUFRInitXMLReturn.AppendChild(FHardware.toXML);
  ndUFRInitXMLReturn.AppendChild(FDataFormat.ToXML);
  ndUFRInitXMLReturn.AppendChild(FChangeFromTypeIndexes.ToXML);

  Result := docXML.XML;
end;

{ TMenuOperationResult }

constructor TMenuOperationResult.Create(const AusOperationId: UTF8String);
begin
  FusOperationId := AusOperationId;

//  FPrintUnfiscal := TPrintUnfiscal.Create;
end;

destructor TMenuOperationResult.Destroy;
begin
//  FPrintUnfiscal.Free;

  inherited;
end;

function TMenuOperationResult.ToXML: UTF8String;
var
  docXML: IXmlDocument;
  ndMENUOPERATIONRESULT: IXmlNode;
begin
  docXML := CreateXmlDocument('MENUOPERATIONRESULT', '1.0', 'utf-8');
  ndMENUOPERATIONRESULT := docXML.documentElement;

  ndMENUOPERATIONRESULT.SetAttr('operationId', FusOperationId);

//  if FPrintUnfiscal.isFilled then ndMENUOPERATIONRESULT.AppendChild(FPrintUnfiscal.ToXML);

  Result := docXML.XML;
end;

{ TFiscal_tag }

constructor TFiscal_tag.Create;
begin
  FusEndDate := '';
end;

procedure TFiscal_tag.SetEndDate(AdtEndDate: TDateTime);
begin
  FusEndDate := FormatDateTime('yyyy-mm-dd', AdtEndDate)
end;

function TFiscal_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('Fiscal');

  if FusEndDate <> '' then Result.SetAttr('EndDate', FusEndDate);
end;

{ THardware_tag }

constructor THardware_tag.Create;
begin
  inherited;
  
  FFiscal := TFiscal_tag.Create;
end;

destructor THardware_tag.Destroy;
begin
  FFiscal.Free;

  inherited;
end;

function THardware_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('Fiscal');

  Result.AppendChild(FFiscal.ToXML);
end;

{ TRounding_tag }

constructor TRounding_tag.Create;
begin
  inherited;
  Fi6Multiplier := 1; //По умолчанию 0.01
end;

function TRounding_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('Rounding');
  Result.SetFloatAttr('Multiplier', Fi6Multiplier / 100);
end;

{ TDataFormat_tag }

constructor TDataFormat_tag.Create;
begin
  inherited;
  FRounding := TRounding_tag.Create;
end;

destructor TDataFormat_tag.Destroy;
begin
  FRounding.Free;
  inherited;
end;

function TDataFormat_tag.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('DataFormat');
  if Assigned(FRounding) then begin
    Result.AppendChild(FRounding.ToXML);
  end;
end;

{ TChangeFromTypeIndexes_tag }

procedure TChangeFromTypeIndexes_tag.Add(AiIndex: Integer);
begin
  SetLength(FarIndexes, Length(FarIndexes) + 1);
  FarIndexes[High(FarIndexes)] := AiIndex;
end;

procedure TChangeFromTypeIndexes_tag.Clear;
begin
  SetLength(FarIndexes, 0);
end;

constructor TChangeFromTypeIndexes_tag.Create;
begin
  inherited;
  Clear;
end;

destructor TChangeFromTypeIndexes_tag.Destroy;
begin
  Clear;
  inherited;
end;

function TChangeFromTypeIndexes_tag.ToXML: IXmlNode;
var
  i: Integer;
  s: string;
begin
  Result := CreateXmlElement('ChangeFromTypeIndexes');

  s := '';
  for i := 0 to High(FarIndexes) do begin
    if i <> 0 then begin
      s := s + ' ';
    end;
     s := s + IntToStr(FarIndexes[i]);
  end;

  Result.Text := s;
end;

end.

