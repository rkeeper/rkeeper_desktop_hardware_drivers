unit uXMLcommon;

interface

uses
   SysUtils
  ,Simplexml
  ,uCommon
  ;

type
  TeDocType = (
     doctNOTHING
    ,doctRECEIPT           // Фискальный чек продажи
    ,doctINVOICE           // Фискальный чек как счет-фактура
    ,doctDELETION          // Удаление чека
    ,doctRETURNRECEIPT     // Возврат по чеку
    ,doctRECEIPTCOPY       // Копия чека
    ,doctRETURN            // Чек возврата
    ,doctRETURNDELETION    // Чек возврата по чеку
    ,doctCASHINOUT         // Внесение/инкассация денег
    ,doctCOLLECTALL        // Изъятие всех денег за смену
    ,doctREPORT            // Отчёты (X, Z, специальные)
    ,doctCUSTOM            // документ транслируется без изменений, формат зависит от конкретного драйвера
    //  restaurant mode documents
    ,doctBILL              // Счёт
    ,doctCREATEORDER       // Открытие заказа
    ,doctCORRECTION        // Изменение количества товара в созданном заказе
    ,doctCLOSEORDER        // Закрытие пустого заказа
    ,doctCANCELSEAT        // Превращение заказа на место в общий заказ
    ,doctPRINTLOG          // Логгирование
    ,doctCORRECTIONRECEIPT // Чек коррекции
    ,doctCANCELORDER       // Отмена заказа
    ,doctCancelBill        // Отмена счета/пречека
  );
const
  S_DOC_TYPE: array[TeDocType] of AnsiString = (
     'Nothing'
    ,'Receipt'
    ,'Invoice'
    ,'Deletion'
    ,'ReturnReceipt'
    ,'ReceiptCopy'
    ,'Return'
    ,'ReturnDeletion'
    ,'CashInOut'
    ,'CollectAll'
    ,'Report'
    ,'Custom'
    ,'Bill'
    ,'CreateOrder'
    ,'Correction'
    ,'CloseOrder'
    ,'CancelSeat'
    ,'PrintLog'
    ,'CorrectionReceipt'
    ,'CancelOrder'
    ,'CancelBill'
  );
  SH_DOC_TYPE_RU: array[TeDocType] of AnsiString = (
     '' // doctNOTHING
    ,'Фискальный чек продажи'          // doctRECEIPT
    ,'Фискальный чек как счет-фактура' // doctINVOICE
    ,'Удаление чека'                   // doctDELETION
    ,'Возврат по чеку'                 // doctRETURNRECEIPT
    ,'Копия чека'                      // doctRECEIPTCOPY
    ,'Чек возврата'                    // doctRETURN
    ,'Чек возврата по чеку'            // doctRETURNDELETION
    ,'Внесение/инкассация денег'       // doctCASHINOUT
    ,'Изъятие всех денег за смену'     // doctCOLLECTALL
    ,'Отчёты (X, Z, специальные)'      // doctREPORT
    ,'Custom'                          // doctCUSTOM
    //  restaurant mode documents
    ,'Счёт'                                           // doctBILL
    ,'Открытие заказа'                                // doctCREATEORDER
    ,'Изменение количества товара в созданном заказе' // doctCORRECTION
    ,'Закрытие пустого заказа'                        // doctCLOSEORDER
    ,'Превращение заказа на место в общий заказ'      // doctCANCELSEAT
    ,'Логгирование' // doctPRINTLOG
    ,'Чек коррекции' // doctCORRECTIONRECEIPT
    ,'Отмена заказа'
    ,'Отмена счета/пречека'
  );

type
  TeReportType = (
    reptNOTHING
    ,reptX
    ,reptZ
    ,reptBRIEFBYDATE
    ,reptDETAILBYDATE
    ,reptBRIEFBYNUMBER
    ,reptLASTSHIFT
    ,reptARTICULES      // Фискальный отчёт по артикулам
    ,reptZEROCHECK      // Фискальный нулевой чек - тест работоспособности
    ,reptOFDSTATUS
    ,reptOpenShiftReport
  );
const
  S_REPORT_TYPE: array[TeReportType] of AnsiString = (
     'Nothing'
    ,'X'
    ,'Z'
    ,'BriefByDate'
    ,'DetailByDate'
    ,'BriefByNumber'
    ,'LastShift'
    ,'ByArticul'      // Фискальный отчёт по артикулам
    ,'ZeroCheck'
    ,'OFDStatus'
    ,'OpenShiftReport'
  );

type
  TeRawEncoding = (reNo, reBase64); // значения константам не назначать!
const
  S_RAW_ENCODING: array[TeRawEncoding] of UTF8String = ('No', 'Base64');

type
  TeBarCodeTextPos = (tpNo, tpTop, tpBottom, tpTopAndBottom); // значения константам не назначать!
const
  S_BAR_CODE_TEXT_POS: array[TeBarCodeTextPos] of UTF8String = ('No', 'Top', 'Bottom', 'Top&Bottom');

type
  TeBarCodeType = (bctEAN13, bctCode128, bctCode39, bctQRCode); // значения константам не назначать!
const
  S_BAR_CODE_TYPE: array[TeBarCodeType] of UTF8String = ('EAN-13', 'Code-128', 'Code-39', 'QRCode');

type
  TeQRcodeCorrLvl = (qccl7, qccl15, qccl25, qccl30); // значения константам не назначать!
const
  S_QR_CODE_CORR_LVL: array[TeQRcodeCorrLvl] of UTF8String = ('7%', '15%', '25%', '30%');

type
  TeBarCodeAlign = (bcaCenter, bcaLeft, bcaRight); // значения константам не назначать!
const
  S_BAR_CODE_ALIGN: array[TeBarCodeAlign] of UTF8String = ('Center', 'Left', 'Right');

type
  TeUnfPosition = (unfposBefore, unfposAfter);
const
  S_UNF_POSITION: array[TeUnfPosition] of UTF8String = ('Before', 'After');

type
  TeTaxType = (taxtOSN, taxtUSNincome, taxtUSNincomeOutcome, taxtENVD, taxtESN, taxtPATENT);
const
  S_TAX_TYPE: array[TeTaxType] of AnsiString = ('0', '1', '2', '3', '4', '5');
  I_TAX_TYPE_BIT: array[TeTaxType] of Integer = (0, 1, 2, 3, 4, 5);
  S_TAX_TYPE_NAME: array[TeTaxType] of AnsiString = (
     'Общая'                             // 0 taxtOSN
    ,'Упрощенная Доход'                  // 1 taxtUSNincome
    ,'Упрощенная Доход минус Расход'     // 2 taxtUSNincomeOutcome
    ,'Единый налог на вмененный доход'   // 3 taxtENVD
    ,'Единый сельскохозяйственный налог' // 4 taxtESN
    ,'Патентная система налогообложения' // 5 taxtPATENT
  );

type
  T_Tag = class; //  для предварительного объявления класса необходимо присутствие этого объявления с полным объявлением в одной секции type

  T_Attr = class
  private
    function Getrawenc: TeRawEncoding;
    function GeteBarCodeTextPos: TeBarCodeTextPos;
    function GeteBarCodeType: TeBarCodeType;
    function GeteQRcodeCorrLvl: TeQRcodeCorrLvl;
    function GeteBarCodeAlign: TeBarCodeAlign;
    function GeteUnfPosition: TeUnfPosition;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag; const AusName: UTF8String); overload; // Этот конструктор используется только при парсинге XML
    constructor Create(const AusName: UTF8String; AParentTag: T_Tag; const AusValue: UTF8String = ''); overload; // Этот конструктор используется только для создания дефолтных T_Attr
    constructor Create(const AusName: UTF8String; const AusValue: UTF8String = ''); overload; // Этот конструктор используется только при создании XML
  protected
    FParentTag: T_Tag;
    FusName: UTF8String;
    FusValue: UTF8String;
    FisDefault: Boolean;
    function Geti: Int64;
    function Getws: WideString;
    function Getus: UTF8String;
    function Getdoct: TeDocType;
    function Getdt: TDateTime;
    function Getrept: TeReportType;
    function GetdtFrom: TDateTime;
    function GetdtTo: TDateTime;
    function GetiFrom: Int64;
    function GetiTo: Int64;
    function GeteTaxType: TeTaxType;
  public
    property isDefault: Boolean read FisDefault;
  public
    function s(AlwCodePage: LongWord = 1251): AnsiString;
    property us: UTF8String read Getus;
    property ws: WideString read Getws;
    property i: Int64 read Geti;
    property dt: TDateTime read Getdt;
    property doct: TeDocType read Getdoct;
    property rept: TeReportType read Getrept;
    property rawenc: TeRawEncoding read Getrawenc;
    property eBarCodeTextPos: TeBarCodeTextPos read GeteBarCodeTextPos;
    property eBarCodeType: TeBarCodeType read GeteBarCodeType;
    property eQRcodeCorrLvl: TeQRcodeCorrLvl read GeteQRcodeCorrLvl;
    property eBarCodeAlign: TeBarCodeAlign read GeteBarCodeAlign;
    property eUnfPosition: TeUnfPosition read GeteUnfPosition;
    property eTaxType: TeTaxType read GeteTaxType;
  public // для отчетов - параметры разделены ';': <sFrom>;<sTo>
    property dtFrom: TDateTime read GetdtFrom;
    property dtTo: TDateTime read GetdtTo;
    property iFrom: Int64 read GetiFrom;
    property iTo: Int64 read GetiTo;
  end;

  T_Tag = class
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload; // Этот конструктор используется только при парсинге XML
    constructor Create(AusName: UTF8String; AParentTag: T_Tag); overload; // Этот конструктор используется только для создания дефолтных T_Tag
    constructor Create(AusName: UTF8String); overload; // Этот конструктор используется только для создания XML
    procedure SetTagValue(AusValue: UTF8String);
  protected
    function  GetHierarchy: UTF8String;
  protected
    procedure ParseAttr(AXMLnode: IXmlNode; var A_Attr: T_Attr; const AusName: UTF8String);
    function  GetAttr(A_Attr: T_Attr; const AusName: UTF8String; AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
    procedure SetAttr(var A_Attr: T_Attr; const AusName, AusValue: UTF8String);
    function  GetChildTag(A_Tag: T_Tag; const AusName: UTF8String; AisCanDef: Boolean; A_defTag: T_Tag): T_Tag;
    procedure AddChildTag(AChild_Tag: T_Tag);
  protected
    FXmlNode: IXmlNode;
    FParentTag: T_Tag;
    FusName: UTF8String;
    FusValue: UTF8String;
    Fdef_Attr: T_Attr;
    FisDefault: Boolean;
  public
    property isDefault: Boolean read FisDefault;
    property usName: UTF8String read FusName;
    property usValue: UTF8String read FusValue;
    property XmlNode: IXMLNode read FXmlNode;
  end;

implementation

const
  S_TAG_SEPARATOR = ' ~ ';
  S_ATTR_SEPARATOR = ' - ';

{ T_Tag }

constructor T_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  FXmlNode := AXMLnode;
  FusName := FXmlNode.NodeName;
  FusValue := FXmlNode.Text;
  FParentTag := AParentTag;
  Fdef_Attr := nil;
  FisDefault := False; // Этот конструктор используется только при парсинге XML
end;

constructor T_Tag.Create(AusName: UTF8String; AParentTag: T_Tag);
begin
  FXmlNode := nil;
  FusName := AusName;
  FusValue := '';
  FParentTag := AParentTag;
  Fdef_Attr := nil;
  FisDefault := True; // Этот конструктор используется только для создания дефолтных T_Tag
end;

constructor T_Tag.Create(AusName: UTF8String);
begin
  FXmlNode := CreateXmlElement(AusName);
  FusName := FXmlNode.NodeName;
  FusValue := FXmlNode.Text;
  FParentTag := nil;
  Fdef_Attr := nil;
  FisDefault := False; // Этот конструктор используется только для создания XML
end;

function T_Tag.GetHierarchy: UTF8String;
var
  ParentTag: T_Tag;
begin
  Result := FusName;
  ParentTag := Self.FParentTag;
  while Assigned(ParentTag) do begin
    Result := ParentTag.FusName + s_TAG_SEPARATOR + Result;
    ParentTag := ParentTag.FParentTag
  end;
end;

procedure T_Tag.SetTagValue(AusValue: UTF8String);
begin
  FusValue := AusValue;

  FXMLNode.Text := FusValue
end;

procedure T_Tag.ParseAttr(AXMLnode: IXmlNode; var A_Attr: T_Attr; const AusName: UTF8String);
begin
  if AXMLnode.AttrExists(AusName) then A_Attr := T_Attr.Create(AXMLnode, Self, AusName) else A_Attr := nil;
end;

function  T_Tag.GetAttr(A_Attr: T_Attr; const AusName: UTF8String; AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  if Assigned(A_Attr) then begin
    Result := A_Attr;
  end else begin
    if AisCanDef then begin
      FreeAndNil(Fdef_Attr);
      Fdef_Attr := T_Attr.Create(AusName, Self, AusDefVal);
      Result := Fdef_Attr;
    end else begin
      raise Exception.CreateFmt('%s%s%s attribute is absent', [Self.GetHierarchy, s_ATTR_SEPARATOR, AusName]);
    end;
  end;
end;

procedure T_Tag.SetAttr(var A_Attr: T_Attr; const AusName, AusValue: UTF8String);
begin
  FreeAndNil(A_Attr);

  A_Attr := T_Attr.Create(AusName, AusValue);

  A_Attr.FParentTag := Self;

  FXMLNode.SetAttr(A_Attr.FusName, A_Attr.FusValue);
end;

function T_Tag.GetChildTag(A_Tag: T_Tag; const AusName: UTF8String; AisCanDef: Boolean; A_defTag: T_Tag): T_Tag;
begin
  if Assigned(A_Tag) then begin
    Result := A_Tag;
  end else begin
    if AisCanDef then begin
      Result := A_defTag;
    end else begin
      raise Exception.CreateFmt('%s%s%s tag is absent', [Self.GetHierarchy, s_TAG_SEPARATOR, AusName]);
    end;
  end;
end;

procedure T_Tag.AddChildTag(AChild_Tag: T_Tag);
begin
  AChild_Tag.FParentTag := Self;

  FXMLNode.AppendChild(AChild_Tag.FXMLNode);
end;

{ T_Attr }

constructor T_Attr.Create(AXMLnode: IXmlNode; AParentTag: T_Tag; const AusName: UTF8String);
begin
  FParentTag := AParentTag;
  FusName := AusName;
  FusValue := AXMLnode.GetAttr(AusName);
  FisDefault := False; // Этот конструктор используется только при парсинге XML
end;

constructor T_Attr.Create(const AusName: UTF8String; AParentTag: T_Tag; const AusValue: UTF8String = '');
begin
  FParentTag := AParentTag;
  FusName := AusName;
  FusValue := AusValue;
  FisDefault := True; // Этот конструктор используется только для создания дефолтных T_Attr
end;

constructor T_Attr.Create(const AusName, AusValue: UTF8String);
begin
  FParentTag := nil;
  FusName := AusName;
  FusValue := AusValue;
  FisDefault := False; // Этот конструктор используется только при создании XML
end;

function T_Attr.Getdoct: TeDocType;
begin
  for Result := Low(TeDocType) to High(TeDocType) do if AnsiSameStr(FusValue, s_DOC_TYPE[Result]) then Exit;
  Result := doctNOTHING;
end;

function T_Attr.Getdt: TDateTime;
begin
  try
    Result := XSTRToDateTime(FusValue);
  except
    on E: Exception do raise Exception.CreateFmt('%s%s%s value "%s" is not DateTime: %s', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName, FusValue, E.Message]);
  end;
end;

function T_Attr.GetdtFrom: TDateTime;
begin
  try
    Result := XSTRToDateTime(ExtractFieldByNumber(FusValue, ';', 1));
  except
    on E: Exception do raise Exception.CreateFmt('%s%s%s value "%s" is not DateTime: %s', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName + ' from', FusValue, E.Message]);
  end;
end;

function T_Attr.GetdtTo: TDateTime;
begin
  try
    Result := XSTRToDateTime(ExtractFieldByNumber(FusValue, ';', 2));
  except
    on E: Exception do raise Exception.CreateFmt('%s%s%s value "%s" is not DateTime: %s', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName + ' to', FusValue, E.Message]);
  end;
end;

function T_Attr.Geti: Int64;
begin
  if not TryStrToInt64(FusValue, Result) then raise Exception.CreateFmt('%s%s%s value "%s" is not integer', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName, FusValue]);
end;

function T_Attr.GetiFrom: Int64;
begin
  if not TryStrToInt64(ExtractFieldByNumber(FusValue, ';', 1), Result) then raise Exception.CreateFmt('%s%s%s value "%s" is not integer', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName + ' from', FusValue]);
end;

function T_Attr.GetiTo: Int64;
begin
  if not TryStrToInt64(ExtractFieldByNumber(FusValue, ';', 2), Result) then raise Exception.CreateFmt('%s%s%s value "%s" is not integer', [FParentTag.GetHierarchy, s_ATTR_SEPARATOR, FusName + ' to', FusValue]);
end;

function T_Attr.Getrept: TeReportType;
begin
  for Result := Low(TeReportType) to High(TeReportType) do if AnsiSameStr(FusValue, s_REPORT_TYPE[Result]) then Exit;
  Result := reptNOTHING;
end;

function T_Attr.s(AlwCodePage: LongWord = 1251): AnsiString;
begin
  Result := UTF8toCodePage(FusValue, AlwCodePage);
end;

function T_Attr.Getus: UTF8String;
begin
  Result := FusValue;
end;

function T_Attr.Getws: WideString;
begin
  Result := UTF8Decode(FusValue);
end;

function T_Attr.Getrawenc: TeRawEncoding;
var
  eRawEncoding: TeRawEncoding;
begin
  for eRawEncoding := Low(TeRawEncoding) to High(TeRawEncoding) do if S_RAW_ENCODING[eRawEncoding] = FusValue then begin
    Result := eRawEncoding;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'RawEncoding']);
end;

function T_Attr.GeteBarCodeTextPos: TeBarCodeTextPos;
var
  eBarCodeTextPos: TeBarCodeTextPos;
begin                                          
  for eBarCodeTextPos := Low(TeBarCodeTextPos) to High(TeBarCodeTextPos) do if S_BAR_CODE_TEXT_POS[eBarCodeTextPos] = FusValue then begin
    Result := eBarCodeTextPos;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'BarCodeTextPos']);
end;

function T_Attr.GeteBarCodeType: TeBarCodeType;
var
  eBarCodeType: TeBarCodeType;
begin
  for eBarCodeType := Low(TeBarCodeType) to High(TeBarCodeType) do if S_BAR_CODE_TYPE[eBarCodeType] = FusValue then begin
    Result := eBarCodeType;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'BarCodeType']);
end;

function T_Attr.GeteQRcodeCorrLvl: TeQRcodeCorrLvl;
var
  eQRcodeCorrLvl: TeQRcodeCorrLvl;
begin
  for eQRcodeCorrLvl := Low(TeQRcodeCorrLvl) to High(TeQRcodeCorrLvl) do if S_QR_CODE_CORR_LVL[eQRcodeCorrLvl] = FusValue then begin
    Result := eQRcodeCorrLvl;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'QRcodeCorrLvl']);
end;

function T_Attr.GeteBarCodeAlign: TeBarCodeAlign;
var
  eBarCodeAlign: TeBarCodeAlign;
begin
  for eBarCodeAlign := Low(TeBarCodeAlign) to High(TeBarCodeAlign) do if S_BAR_CODE_ALIGN[eBarCodeAlign] = FusValue then begin
    Result := eBarCodeAlign;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'QRcodeAlign']);
end;

function T_Attr.GeteUnfPosition: TeUnfPosition;
var
  eUnfPosition: TeUnfPosition;
begin
  for eUnfPosition := Low(TeUnfPosition) to High(TeUnfPosition) do if S_UNF_POSITION[eUnfPosition] = FusValue then begin
    Result := eUnfPosition;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'UnfPosition']);
end;

function T_Attr.GeteTaxType: TeTaxType;
var
  eTaxType: TeTaxType;
begin
  for eTaxType := Low(TeTaxType) to High(TeTaxType) do if SameText(S_TAX_TYPE[eTaxType], FusValue) then begin
    Result := eTaxType;
    Exit;
  end;

  raise Exception.CreateFmt('%s%s%s value "%s" is wrong %s value', [FParentTag.GetHierarchy, S_ATTR_SEPARATOR, FusName, FusValue, 'TaxType']);
end;

end.
