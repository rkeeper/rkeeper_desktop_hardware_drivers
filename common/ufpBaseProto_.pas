unit ufpBaseProto_;

interface

uses
   Windows
  ,SysUtils
  ,Classes
  ,SimpleXML
  ,ufpDrivParamsXml
  ,uXMLcommon
  ,ufpFiscDocXml_
  ,ufpInitXmlReturn_
  ,ufpStatus
  ,uCommon
  ,uCallbacks
  ,uLog
  ,ufpResult_
  ,uUnFiscXml_
  ,ufpProgramXml_
  ,DateUtils
  ;

type
  TBaseProto = class
  public
    class function  MaxProtocolSupported: Integer;                                                                                     virtual;
    class function  MinProtocolSupported: Integer;                                                                                     virtual;
    procedure DriverOptions(out AsetOptions: TsetOptions);                                                                             virtual;
    procedure DriverMenu(AMenu: TMenu);                                                                                                virtual;
    function  DriverHardware(AHardware: THardware_tag; AResult: TUFRresult): Boolean;                                                  virtual;
    function  DriverDataFormat(ADataFormat: TDataFormat_tag; AResult: TUFRresult): Boolean;                                            virtual;
    function  DriverChangeFromTypeIndexes(AChangeFromTypeIndexes: TChangeFromTypeIndexes_tag; AResult: TUFRresult): Boolean;           virtual;
  public
    constructor Create(AParameters: TParameters; ACallBacks: TCallBacks; ALog: TLog; AResult: TUFRresult);                             virtual;
    destructor Destroy;                                                                                                                override;
    procedure BeforeLastInstanceDestroy;                                                                                               virtual; 
  protected
    FParameters: TParameters; //  объект не создается, хранится только ссылка
    FCallBacks: TCallBacks; //  объект не создается, хранится только ссылка
    FLog: TLog;             //  объект не создается, хранится только ссылка
    FSkipResult: TUFRresult;
  public  //  открытые функции печати и прочих действий
    function  PrintReceipt          (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintCorrectionReceipt(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintReceiptCopy      (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintReport           (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintCashInOut        (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintCollectAll       (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  Custom                (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRResult): Boolean;        virtual;
    function  PrintLog              (AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;        virtual;
    function  PrintUnfiscal         (AUnfiscal      : TUnfiscal_Tag      ;                       AResult: TUFRresult): Boolean;        virtual;
    function  Display               (AUnfiscal      : TUnfiscal_Tag      ;                       AResult: TUFRresult): Boolean;        virtual;
    function  OpenDrawer            (AiDrawerNum    : Integer            ;                       AResult: TUFRresult): Boolean;        virtual;
    function  Programming           (AProgramFR     : TProgramFR_Tag     ;                       AResult: TUFRResult): Boolean;        virtual;
    function  Started               (                                                            AResult: TUFRResult): Boolean;        virtual;
    function  MenuOperation(AMenuOperation: TMenuOperation; AMenuOperationResult: TMenuOperationResult; AResult: TUFRresult): Boolean; virtual;
    function  GetZReportData(out AZReportData: TZReportData; AResult: TUFRresult): Boolean;                                            virtual;
  public // получение информации от ФР
    function  GetStatus(AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;                                                           virtual;
  end;

implementation

{ TBaseProto }

constructor TBaseProto.Create(AParameters: TParameters; ACallBacks: TCallBacks; ALog: TLog; AResult: TUFRresult);
begin
  AResult.SetValue(errOk, '');
  FParameters := AParameters;
  FCallBacks := ACallBacks;
  FLog := ALog;

  FSkipResult := TUFRresult.Create;
end;

destructor TBaseProto.Destroy;
begin
  FreeAndNil(FSkipResult);

  inherited;
end;

procedure TBaseProto.BeforeLastInstanceDestroy;
begin

end;

class function TBaseProto.MaxProtocolSupported: Integer;
begin
  Result := iSelfVersion(2); // Максимальный протокол во 2-й цифре версии cм. #76697
end;

class function TBaseProto.MinProtocolSupported: Integer;
begin
  Result := 0;
end;

procedure TBaseProto.DriverOptions(out AsetOptions: TsetOptions);
begin
  AsetOptions := [];
  //Include(AsetOptions, optText                ); // ФР поддерживает отдельную нефискальную печать (нефискальный документ)
  //Include(AsetOptions, optZeroReceipt         ); // ФР поддерживает печать нулевого чека (с нулевой стоимостью)
  //Include(AsetOptions, optDeleteReceipt       ); // ФР поддерживает удаление чека или возврат
  //Include(AsetOptions, optZReport             ); // ФР поддерживает Z отчёт
  //Include(AsetOptions, optMoneyInOut          ); // ФР поддерживает внесения-выдачи
  //Include(AsetOptions, optXReport             ); // ФР поддерживает X отчёт
  //Include(AsetOptions, optSpecialReport       ); // ФР поддерживает специальные отчёты: итоговый/детализированный отчет по датам, итоговый отчет по сменам.
  //Include(AsetOptions, optZeroSale            ); // ФР поддерживает печать продажи с "нулевой" суммой
  //Include(AsetOptions, optProgram             ); // ФР поддерживает программирование принтера [при закрытой смене]
  //Include(AsetOptions, optFullLastShift       ); // ФР поддерживает распечатку последней смены
  //Include(AsetOptions, optAllMoneyOut         ); // ФР поддерживает изъятие всех денег
  //Include(AsetOptions, optTextInReceipt       ); // ФР поддерживает нефискальную печать внутри чека (внутри <Header>)
  //Include(AsetOptions, optBarCodeInNotFisc    ); // ФР поддерживает печать штрих-кода в нефискальной части чека
  //Include(AsetOptions, optZClearMoney         ); // Z-отчёт автоматически очищает остаток денег в кассе
  //Include(AsetOptions, optCheckCopy           ); // Фискальный документ - копия чека (пока только в Латвии)
  //Include(AsetOptions, optTextInLine          ); // ФР поддерживает нефискальную печать внутри линии чека (внутри <Item> или <Payment> или <Discount>)
  //Include(AsetOptions, optItemDepartments     ); // ФР поддерживает отделы по товарам/услугам
  //Include(AsetOptions, optOnlyFixed           ); // Работа только с заранее запрограммированными блюдами (RK7 в этом случае использует блюда "итого" по отделам с кодами отделов и распечатывает "суммарные" чеки с такими блюдами), пример - prim08 в режиме отделов
  //Include(AsetOptions, optTextOpenShift       ); // Признак, что нефискальная печать открывает фискальную смену
  //Include(AsetOptions, optDrawerOpen          ); // ФР может открывать ящик
  //Include(AsetOptions, optDrawerState         ); // ФР может возвращать состояние ящика
  //Include(AsetOptions, optCustomerDisplay     ); // ФР поддерживает вывод на дисплей покупателя
  //Include(AsetOptions, optSlip                ); // ФР поддерживает печать на бланке
  //Include(AsetOptions, optCalcChange          ); // ФР поддерживает вычисление сдачи
  //Include(AsetOptions, optZWhenClosedShift    ); // ФР поддерживает печать Z-отчёта при закрытой смене
  //Include(AsetOptions, optAbsDiscountSum      ); // ФР поддерживает абсолютные (не процентные) скидки/наценки
  //Include(AsetOptions, optFiscInvoice         ); // ФР поддерживает печать фискального чека как счет-фактуру
  //Include(AsetOptions, optCashRegValue        ); // ФР поддерживает возврат значения регистра кассовой наличности
  //Include(AsetOptions, optFixedNames          ); // ФР требует неизменности имён позиций в течении дня
  //Include(AsetOptions, optDeleteReturn        ); // (версия 1.1+) ФР поддерживает операцию удаление возврата
  //Include(AsetOptions, optDiscWithTaxes       ); // (версия 9+) ФР принимает скидки на чек вместе с налоговыми ставками, соответственно, скидки должны разбиваться по ставкам, в скидках на чек надо указывать налоги, иначе для правильного расчёта налогов скидки надо разбивать по блюдам (блюдным скидкам налоги не нужны)
  //Include(AsetOptions, optCanIgnoreTaxes      ); // ФР имеет режим "без налогов", можно не передавать тэг Taxes
  //Include(AsetOptions, optAbsItemDiscount     ); // (версия 11+) ФР может печатать скидки на позиции, для более старых версий такие скидки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemDiscount и выключено foAbsDiscountSum, то суммовые скидки разбиваются по позициям.
  //Include(AsetOptions, optAbsItemMarkup       ); // (версия 11+) ФР может печатать наценки на позиции, для более старых версий такие наценки считаются возможными, если включено foAbsDiscountSum. Если включено foAbsItemMarkup и выключено foAbsDiscountSum, то суммовые наценки приходят в драйвер разбитые по блюдам.
  //Include(AsetOptions, optAbsMarkupSum        ); // (версия 11+) ФР поддерживает абсолютные (не процентные)  наценки на чек
  //Include(AsetOptions, optMaxOneMarkupDiscount); // (версия 16+) Не больше одной наценки/скидки
  //Include(AsetOptions, optBill                ); // (версия 18+) ФР печатает фискальные документы "Счёт"
  //Include(AsetOptions, optCreateCloseOrder    ); // (версия 18+) ФР печатает фискальные документы "Открытие заказа", "Закрытие заказа"
  //Include(AsetOptions, optCorrection          ); // (версия 18+) ФР печатает фискальные документы "Коррекция заказа"
  //Include(AsetOptions, optReturnReceipt       ); // (версия 20+) ФР печатает фискальные документы "Возврат по чеку"
  //Include(AsetOptions, optPayUngrouped        ); // (версия 24+) Не группировать платежи по индексу платежа, добавлять в тэг Payment атрибуты ISOCode, Rate и OriginalValue
  //Include(AsetOptions, optLogger              ); // (версия 25+) Устройство используется ля логирования печати других устройств
  //Include(AsetOptions, optWorkWithoutPaper    ); // (версия 27+) Устройство может выполнять фискальные операции без бумаги. Если это не устраивает, хост должен анализировать PaperStatus
  //Include(AsetOptions, optCorrectPriceToPay   ); // (версия 32+) Если хост поддерживает протокол 32 и драйвер выставил эту опцию, хост должен передавать атрибут PriceToPay и так, чтобы PriceToPay * Quantity равна сумме к оплате по позиции, если опции нет, то может передавать, может не передавать, а драйвер может вычислить.
  //Include(AsetOptions, optRoundDiscountOnly   ); // (версия 32+) Если выставлена эта опция, то корректировка округления добавляется отдельной суммарной скидкой без налогов на маленькую сумму. При foAbsDiscountSum без foAbsItemDiscount поведение аналогичное, но скидка с налогами если foDiscWithTaxes.
  //Include(AsetOptions, optCorrectionReceipt   ); // (версия 35+) ФР печатает фискальные документы "Чек коррекции" (Россия)
  //Include(AsetOptions, optOpenShiftReport     ); // (версия 48+) ФР умеет делать отчёт OpenShiftReport - отчёт открытия смены.
  //Include(AsetOptions, optCancelOrder         ); // (версия 57+) ФР умеет печатать фискальный документ CancelOrder
  //Include(AsetOptions, optCancelBill          ); // (версия 58+) фискальный документ CancelBill - документ отмены счёта/пречека
end;

procedure TBaseProto.DriverMenu(AMenu: TMenu);
{var
  eMenu: TeMenu;{}
begin
{  for eMenu := Low(TeMenu) to High(TeMenu) do AMenu.AddItem(TMenuItem_end_tag.Create(
    CodePageToUTF8(1251, sMenuCaption[eMenu]),
    sMenuGUID[eMenu],
    IntToStr(Integer(eMenu))
  ));{}
end;

function TBaseProto.DriverHardware(AHardware: THardware_tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function TBaseProto.DriverDataFormat(ADataFormat: TDataFormat_tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function TBaseProto.DriverChangeFromTypeIndexes(AChangeFromTypeIndexes: TChangeFromTypeIndexes_tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

//======= открытые функции получения информации от ФР ==========================

function TBaseProto.GetStatus(AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

//======= открытые функции печати и прочих действий ============================

function  TBaseProto.GetZReportData(out AZReportData: TZReportData; AResult: TUFRresult): Boolean;
begin
  AZReportData := nil;
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.MenuOperation(AMenuOperation: TMenuOperation; AMenuOperationResult: TMenuOperationResult; AResult: TUFRResult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.Programming(AProgramFR: TProgramFR_Tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.Started(AResult: TUFRResult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintReceipt(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintCorrectionReceipt(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintReceiptCopy(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintReport(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintUnfiscal(AUnfiscal: TUnfiscal_Tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.PrintCashInOut(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function TBaseProto.PrintCollectAll(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.Custom(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRResult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.Display(AUnfiscal: TUnfiscal_Tag; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function TBaseProto.PrintLog(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

function  TBaseProto.OpenDrawer(AiDrawerNum: Integer; AResult: TUFRresult): Boolean;
begin
  AResult.SetValue(errOk, '');
  Result := True;
end;

end.
