unit ufpFiscDocXml_;

interface

uses
   SysUtils
  ,StrUtils
  ,Types

  ,uCommon
  ,simplexml
  ,uXMLcommon
  ,uUnFiscXml_
  ;

type
  T_CodeName_Tag = class(T_Tag)
  private
    FName: T_Attr;
    FCode: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Code(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Name(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  T_IdCodeName_Tag = class(T_CodeName_Tag)
  private
    FId: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Id(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
  end;

  T_IdCodeNameValue_Tag = class(T_IdCodeName_Tag)
  private
    FValue: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Value(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TOperator_Tag = class(T_IdCodeName_Tag)
  private
    FTaxPayerIdNum: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function TaxPayerIdNum(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
  end;

  T_Number_Tag = class(T_Tag)
  private
    FNumber: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Number(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  T_NumberName_Tag = class(T_Number_Tag)
  private
    FName: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Name(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TInvoice_Tag = class(T_Number_Tag)
  private
    FINN      : T_Attr;  //  "1234567890"           - Поле "ИНН" из формы "Реквизиты организации"
    FName     : T_Attr;  //  "Волков А.Б."          - Поле "Наименование" из формы "Реквизиты организации"
    FAddress  : T_Attr;  //  "Deep Forest, 1"       - Поле "Адрес" из формы "Реквизиты организации"
    FExtraInfo: T_Attr;  //  "Restaurant"           - Поле "Доп. инфо" из формы "Реквизиты организации"
    FComment  : T_Attr;  //  "No"                   - Поле "Комментарий" из формы "Реквизиты организации"
    FTime     : T_Attr;  //  "YYYY-MM-DDThh:nn:ss"  - Значение поля "DateTime" из датасета "DSN_INVOICES"
    FSeller   : T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function INN      (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Name     (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Address  (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function ExtraInfo(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Comment  (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Time     (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Seller   (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;  //  "Зайцев В.Г."/>      - Продавец (Кассир)
  end;

  TCustomProp_Tag = class(T_Tag)
  private
    FName: T_Tag;
    FData: T_Tag;
    FName_def: T_Tag;
    FData_def: T_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Name(AisCanDef: Boolean = False): T_Tag;
    function Data(AisCanDef: Boolean = False): T_Tag;
  end;

  TarCustomProp_Tag = array of TCustomProp_Tag;

  TCustomProperties_Tag = class(T_Tag)
  private
    FarCustomProp_Tag: TarCustomProp_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
    function GetCustomProp(const AusName: UTF8String): UTF8String;
  public
    property arCustomProp_Tag: TarCustomProp_Tag read FarCustomProp_Tag;
    property CustomProp[const AusName: UTF8String]: UTF8String read GetCustomProp; default;
  end;

const
  S_CustomPropName_Phone: AnsiString = '{A598C6FD-E347-414C-8E40-E5B846973ACF}';
  S_CustomPropName_Email: AnsiString = '{44727918-5294-40F8-9FF8-65270A8E2C9C}';
  S_CustomPropName_ElectronicReceipt: AnsiString = '{2A8EF470-821B-43B6-B16E-2517DDD1F768}';

type
  TLinkReceipt_Tag = class(T_Number_Tag)
  private
    FCustomProperties    : TCustomProperties_Tag;
    FCustomProperties_def: TCustomProperties_Tag;
    FFiscalDocNum: T_Attr;
    FGuid: T_Attr;
    FGlobalFiscalId: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function CustomProperties(AisCanDef: Boolean = False): TCustomProperties_Tag;
    function FiscalDocNum(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Guid(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function GlobalFiscalId(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TTax_Tag = class(T_Tag)
  private
    FTaxRateIndex: T_Attr;
    FRateValue   : T_Attr;
    FTaxValue    : T_Attr;
    FTaxName     : T_Attr;
    FRateName    : T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function TaxRateIndex(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function RateValue   (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function TaxValue    (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function TaxName     (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function RateName    (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarTax_Tag = array of TTax_Tag;

  T_DiscBase_Tag = class(T_IdCodeNameValue_Tag)
  private
    FComment: T_Attr;
    FarTax: TarTax_Tag;
    FUnfiscal : TUnfiscal_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Comment(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    property arTax: TarTax_Tag read FarTax;
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
  end;

  TarDiscBase_Tag = array of T_DiscBase_Tag;

  TDiscount_Tag = class(T_DiscBase_Tag);
  TarDiscount_Tag = array of TDiscount_Tag;

  TDiscInfo_Tag = class(T_DiscBase_Tag);
  TarDiscInfo_Tag = array of TDiscInfo_Tag;

  TPayment_Tag = class(T_IdCodeNameValue_Tag)
  private
    FTypeIndex: T_Attr;
    FUnfiscal: TUnfiscal_Tag;
    FISOCode: T_Attr;
    FRate: T_Attr;
    FOriginalValue: T_Attr;
    FCardNum: T_Attr;
    FAuthCode: T_Attr;
    FCardHolder: T_Attr;
    FRRN: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
    function TypeIndex    (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function ISOCode      (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Rate         (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function OriginalValue(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function CardNum      (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function AuthCode     (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function CardHolder   (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function RRN          (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarPayment_Tag = array of TPayment_Tag;

  TBarcode_Tag = class(T_Tag)
  private
    FValue     : T_Attr;
    FMultiplier: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Value     (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Multiplier(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarBarcode_Tag = array of TBarcode_Tag;

  TItemCustomData_Tag = class(T_Tag);

  TarItemCustomData_Tag = array of TItemCustomData_Tag;

  TVoid_Tag = class(T_IdCodeName_Tag)
  private
    FQuantity: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Quantity(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarVoid_Tag = array of TVoid_Tag;

  TItem_Tag = class(T_IdCodeNameValue_Tag)
  private
    FDepartment    : T_Attr;
    FDepartmentName: T_Attr;
    FQuantity      : T_Attr;
    FPricePerOne   : T_Attr;
    FPortionName   : T_Attr;
    FPriceToPay    : T_Attr;
    FForAdvance    : T_Attr;
    FItemKind      : T_Attr;
    FPaymentKind   : T_Attr;
    FarDiscount: TarDiscount_Tag;
    FarDiscInfo: TarDiscInfo_Tag;
    FarTax     : TarTax_Tag;
    FarBarcode : TarBarcode_Tag;
    FarVoid    : TarVoid_Tag;
    FUnfiscal: TUnfiscal_Tag;
    FarItemCustomData: TarItemCustomData_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Department    (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function DepartmentName(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function Quantity      (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function PricePerOne   (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function PortionName   (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function PriceToPay    (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function ForAdvance    (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function ItemKind      (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function PaymentKind   (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    property arDiscount: TarDiscount_Tag read FarDiscount;
    property arDiscInfo: TarDiscInfo_Tag read FarDiscInfo;
    property arTax     : TarTax_Tag      read FarTax;
    property arBarcode : TarBarcode_Tag  read FarBarcode;
    property arVoid    : TarVoid_Tag     read FarVoid;
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
    property arItemCustomData: TarItemCustomData_Tag read FarItemCustomData;
  end;

  TarItem_Tag = array of TItem_Tag;

  TOrder_Tag = class(T_Tag)
  private
    FTable       : T_Attr;
    FGuests      : T_Attr;
    FStartService: T_Attr;
    FGuid        : T_Attr;
    FName        : T_Attr;
    FGlobalId    : T_Attr;
  private
    FOperator    : TOperator_Tag;
    FSeat        : T_NumberName_Tag;
    FOperator_def: TOperator_Tag;
    FSeat_def    : T_NumberName_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Table       (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Guests      (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function StartService(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function Guid        (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function Name        (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
    function GlobalId    (AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
  public
    function Operator(AisCanDef: Boolean = False): T_CodeName_Tag;
    function Seat    (AisCanDef: Boolean = False): T_NumberName_Tag;
  end;

  TDeletion_Tag = class(T_Tag)
  private
    FTime: T_Attr;
    FLinkReceipt    : TLinkReceipt_Tag;
    FOperator       : T_CodeName_Tag;
    FLinkReceipt_def: TLinkReceipt_Tag;
    FOperator_def   : T_CodeName_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Time(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function LinkReceipt(AisCanDef: Boolean = False): TLinkReceipt_Tag;
    function Operator   (AisCanDef: Boolean = False): T_CodeName_Tag;
  end;

  TReceipt_Tag = class(T_Tag)
  private
    FDocNumber: T_Attr;
    FGuid     : T_Attr;
    FLastBill : T_Attr;
    FTaxType  : T_Attr;
    FOrder       : TOrder_Tag;
    FDeletion    : TDeletion_Tag;
    FOrder_def   : TOrder_Tag;
    FDeletion_def: TDeletion_Tag;
    FarItem    : TarItem_Tag;
    FarDiscount: TarDiscount_Tag;
    FarDiscInfo: TarDiscInfo_Tag;
    FarPayment : TarPayment_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function DocNumber(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Guid     (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function LastBill (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr;
    function TaxType  (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
    function Order   (AisCanDef: Boolean = False): TOrder_Tag;
    function Deletion(AisCanDef: Boolean = False): TDeletion_Tag;
    property arItem    : TarItem_Tag     read FarItem;
    property arDiscount: TarDiscount_Tag read FarDiscount;
    property arDiscInfo: TarDiscInfo_Tag read FarDiscInfo;
    property arPayment : TarPayment_Tag  read FarPayment;
  end;

  TReport_Tag = class(T_Tag)
  private
    FReportType: T_Attr;
    FParameters: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function ReportType(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Parameters(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

type
  THeader_Tag = class(T_Tag)
  private
    FRestaurant          : T_CodeName_Tag;
    FOperator            : TOperator_Tag;
    FStation             : T_IdCodeName_Tag;
    FCustomProperties    : TCustomProperties_Tag;
    FRestaurant_def      : T_CodeName_Tag;
    FOperator_def        : TOperator_Tag;
    FStation_def         : T_IdCodeName_Tag;
    FCustomProperties_def: TCustomProperties_Tag;
  private
    FUnfiscal: TUnfiscal_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Restaurant      (AisCanDef: Boolean = False): T_CodeName_Tag;
    function Operator        (AisCanDef: Boolean = False): TOperator_Tag;
    function Station         (AisCanDef: Boolean = False): T_IdCodeName_Tag;
    function CustomProperties(AisCanDef: Boolean = False): TCustomProperties_Tag;
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
  end;

  TFooter_Tag = class(T_Tag)
  private
    FUnfiscal: TUnfiscal_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
  end;

  TReason_Tag = class(T_IdCodeName_Tag);

type // correction documents specificity
  TTLV_Tag = class(T_Tag)
  private
    FTag  : T_Attr;
    FValue: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Tag  (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Value(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarTLV_Tag = array of TTLV_Tag;

  TSTLV_Tag = class(T_Tag)
  private
    FTag  : T_Attr;
    FarTLV: TarTLV_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Tag  (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    property arTLV: TarTLV_Tag read FarTLV;
  end;

  TarSTLV_Tag = array of TSTLV_Tag;

  TFFD_Tag = class(T_Tag)
  private
    FCode: T_Attr;
    FarTLV : TarTLV_Tag;
    FarSTLV: TarSTLV_Tag;
    FDefVal: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Code (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    property arTLV : TarTLV_Tag  read FarTLV ;
    property arSTLV: TarSTLV_Tag read FarSTLV;
    function Value(AwTag: Word; AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TFiscalDocument_Tag = class(T_Tag)
  private
    FDocType: T_Attr;
    FOptions: T_Attr;
    FHeader         : THeader_Tag;
    FFooter         : TFooter_Tag;
    FInvoice        : TInvoice_Tag;
    FLinkReceipt    : TLinkReceipt_Tag;
    FReceipt        : TReceipt_Tag;
    FarPayment      : TarPayment_Tag;
    FReport         : TReport_Tag;
    FFFD            : TFFD_Tag;
    FReason         : TReason_Tag;
    FHeader_def     : THeader_Tag;
    FFooter_def     : TFooter_Tag;
    FInvoice_def    : TInvoice_Tag;
    FLinkReceipt_def: TLinkReceipt_Tag;
    FReceipt_def    : TReceipt_Tag;
    FPayment_def    : TPayment_Tag;
    FReport_def     : TReport_Tag;
    FFFD_def        : TFFD_Tag;
    FReason_def     : TReason_Tag;
    FsCustom        : UTF8String;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function DocType(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Options(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Header     (AisCanDef: Boolean = False): THeader_Tag;
    function Footer     (AisCanDef: Boolean =  True): TFooter_Tag;
    function Invoice    (AisCanDef: Boolean = False): TInvoice_Tag;
    function LinkReceipt(AisCanDef: Boolean = False): TLinkReceipt_Tag;
    function Receipt    (AisCanDef: Boolean = False): TReceipt_Tag;
    function Payment    (AisCanDef: Boolean = False): TPayment_Tag;
    property arPayment : TarPayment_Tag  read FarPayment;
    function Report     (AisCanDef: Boolean = False): TReport_Tag;
    function FFD        (AisCanDef: Boolean = False): TFFD_Tag;
    function Reason     (AisCanDef: Boolean = False): TReason_Tag;
    property sCustom: UTF8String read FsCustom;
  end;

  TFiscalDocument = class
  private
   FFiscalDocument: TFiscalDocument_Tag;
  public
    constructor Create(ApcXMLDoc: PAnsiChar; out AusError: UTF8String);
    destructor Destroy; override;
  public
    property FiscalDocument: TFiscalDocument_Tag read FFiscalDocument;
  end;

  TZReportData = class
  private
    FXmlDocument: IXmlDocument;
  private
    FndDepartmentValues: IXmlNode;
    FndCounterValues: IXmlNode;
  public
    constructor Create(const 
       AusPOS_ID                      //  Fiscal register ID
      ,AusZReportNumber               //  Z-report number
      ,AusCashInValue                 //  Cash in amount (money for change), in cents
      ,AusPayCashValue                //  The amount of the payment in cash for a shift, in cents
      ,AusPayNonCashValue             //  The amount of non-cash payments (including credit cards) for a shift, in cents
      ,AusDayValue                    //  Revenue: Daily sales totals (possibly after deduction of returns) for a shift, in cents
      ,AusReturnValue                 //  The amount of returns on sales for a shift, in cents
      ,AusTaxValue                    //  Day total of taxes for a shift, in cents
      ,AusTotal         : UTF8String  //  Grand total sales for all shifts, in cents
    );
    procedure AddDepartmentValue(const AusNumber, AusName, AusValue: UTF8String);
    procedure AddCounterValue(const AusSourceID, AusValueKeyID, AusValue: UTF8String);
    function  usToXML: UTF8String;
  end;

  TFiscalDocumentReturn = class
  private
    FXmlDocument: IXmlDocument;
  public
    constructor Create;
    procedure SetDocumentInfo(const AusGlobalId: UTF8String);
    function  usToXML: UTF8String;
  end;

implementation

{ T_Body_Tag }
{
constructor T_Body_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  FusBody := AndTag.Text;
end;

constructor T_Body_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FusBody := '';
end;

function T_Body_Tag.usBody(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): UTF8String;
begin
  Result := FusBody;
  if (Result = '') and AisCanDef then Result := AusDefVal;
end;
{}
{ T_CodeName_Tag }

constructor T_CodeName_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FCode, 'Code');
  ParseAttr(AndTag, FName, 'Name');
end;

constructor T_CodeName_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FCode := nil;
  FName := nil;
end;

destructor T_CodeName_Tag.Destroy;
begin
  FCode.Free;
  FName.Free;

  inherited;
end;

function T_CodeName_Tag.Code(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FCode, 'Code', AisCanDef, AusDefVal);
end;

function T_CodeName_Tag.Name(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

{ T_IdCodeName_Tag }

constructor T_IdCodeName_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FId, 'Id');
end;

constructor T_IdCodeName_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FId := nil;
end;

destructor T_IdCodeName_Tag.Destroy;
begin
  FId.Free;

  inherited;
end;

function T_IdCodeName_Tag.Id(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FId, 'Id', AisCanDef, AusDefVal);
end;

{ T_IdCodeNameValue_Tag }

constructor T_IdCodeNameValue_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;
  ParseAttr(AndTag, FValue, 'Value');
end;

constructor T_IdCodeNameValue_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FValue := nil;
end;

destructor T_IdCodeNameValue_Tag.Destroy;
begin
  FValue.Free;

  inherited;
end;

function T_IdCodeNameValue_Tag.Value(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FValue, 'Value', AisCanDef, AusDefVal);
end;

{ TOperator_Tag }

constructor TOperator_Tag.Create(AndTag: IXmlNode;  AParentTag: T_Tag);
begin
  inherited;
  ParseAttr(AndTag, FTaxPayerIdNum, 'TaxPayerIdNum');
end;

constructor TOperator_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);
  FTaxPayerIdNum := nil;
end;

destructor TOperator_Tag.Destroy;
begin
  FTaxPayerIdNum.Free;
  inherited;
end;

function TOperator_Tag.TaxPayerIdNum(AisCanDef: Boolean =  True;  AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTaxPayerIdNum, 'TaxPayerIdNum', AisCanDef, AusDefVal);
end;

{ T_Number_Tag }

constructor T_Number_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FNumber, 'Number');
end;

constructor T_Number_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FNumber := nil;
end;

destructor T_Number_Tag.Destroy;
begin
  FNumber.Free;

  inherited;
end;

function T_Number_Tag.Number(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FNumber, 'Number', AisCanDef, AusDefVal);
end;

{ T_NumberName_Tag }

constructor T_NumberName_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FName, 'Name');
end;

constructor T_NumberName_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FName := nil;
end;

destructor T_NumberName_Tag.Destroy;
begin
  FName.Free;

  inherited;
end;

function T_NumberName_Tag.Name(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

{ TInvoice_Tag }

constructor TInvoice_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FINN      , 'INN');
  ParseAttr(AndTag, FName     , 'Name');
  ParseAttr(AndTag, FAddress  , 'Address');
  ParseAttr(AndTag, FExtraInfo, 'ExtraInfo');
  ParseAttr(AndTag, FComment  , 'Comment');
  ParseAttr(AndTag, FTime     , 'Time');
  ParseAttr(AndTag, FNumber   , 'Number');
  ParseAttr(AndTag, FSeller   , 'Seller');
end;

constructor TInvoice_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FINN      := nil;
  FName     := nil;
  FAddress  := nil;
  FExtraInfo:= nil;
  FComment  := nil;
  FTime     := nil;
  FSeller   := nil;
end;

destructor TInvoice_Tag.Destroy;
begin
  FINN.Free;
  FName.Free;
  FAddress.Free;
  FExtraInfo.Free;
  FComment.Free;
  FTime.Free;
  FSeller.Free;

  inherited;
end;

function TInvoice_Tag.Address(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FAddress, 'Address', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.Comment(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FComment, 'Comment', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.ExtraInfo(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FExtraInfo, 'ExtraInfo', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.INN(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FINN, 'INN', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.Name(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.Seller(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FSeller, 'Seller', AisCanDef, AusDefVal);
end;

function TInvoice_Tag.Time(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTime, 'Time', AisCanDef, AusDefVal);
end;

{ TCustomProp_Tag }

constructor TCustomProp_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  nd := AndTag.SelectSingleNode('Name');
  if Assigned(nd) then FName := T_Tag.Create(nd, Self) else FName := nil;
  nd := AndTag.SelectSingleNode('Data');
  if Assigned(nd) then FData := T_Tag.Create(nd, Self) else FData := nil;
  FName_def := T_Tag.Create('Name', Self);
  FData_def := T_Tag.Create('Data', Self);
end;

constructor TCustomProp_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FName := nil;
  FData := nil;
  FName_def := T_Tag.Create('Name', Self);
  FData_def := T_Tag.Create('Data', Self);
end;

destructor TCustomProp_Tag.Destroy;
begin
  FName.Free;
  FData.Free;
  FName_def.Free;
  FData_def.Free;

  inherited;
end;

function TCustomProp_Tag.Name(AisCanDef: Boolean = False): T_Tag;
begin
  Result := T_Tag(GetChildTag(FName, 'Name', AisCanDef, FName_def));
end;

function TCustomProp_Tag.Data(AisCanDef: Boolean = False): T_Tag;
begin
  Result := T_Tag(GetChildTag(FData, 'Data', AisCanDef, FData_def));
end;

{ TCustomProperties_Tag }

constructor TCustomProperties_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  ndlt: IXmlNodeList;
  i: Integer;
begin
  inherited;

  ndlt := AndTag.SelectNodes('CustomProp');
  SetLength(FarCustomProp_Tag, ndlt.Count);
  for i := Low(FarCustomProp_Tag) to High(FarCustomProp_Tag) do FarCustomProp_Tag[i] := TCustomProp_Tag.Create(ndlt[i], Self);
end;

constructor TCustomProperties_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);
end;

destructor TCustomProperties_Tag.Destroy;
var
  i: Integer;
begin
  for i := Low(FarCustomProp_Tag) to High(FarCustomProp_Tag) do FreeAndNil(FarCustomProp_Tag[i]);
  SetLength(FarCustomProp_Tag, 0);

  inherited;
end;

function TCustomProperties_Tag.GetCustomProp(const AusName: UTF8String): UTF8String;
var
  i: Integer;
begin
  Result := '';

  for i := Low(FarCustomProp_Tag) to High(FarCustomProp_Tag) do begin
    if SameText(Trim(FarCustomProp_Tag[i].Name(True).usValue), AusName) then begin
      Result := FarCustomProp_Tag[i].Data(True).usValue;
      Exit;
    end;
  end;
end;

{ TLinkReceipt_Tag }

constructor TLinkReceipt_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  nd := AndTag.SelectSingleNode('CustomProperties');
  if Assigned(nd) then FCustomProperties := TCustomProperties_Tag.Create(nd, Self) else FCustomProperties := nil;
  FCustomProperties_def := TCustomProperties_Tag.Create('CustomProperties', Self);

  ParseAttr(AndTag, FFiscalDocNum, 'FiscalDocNum');
  ParseAttr(AndTag, FGuid, 'Guid');
  ParseAttr(AndTag, FGlobalFiscalId, 'GlobalFiscalId');
end;

constructor TLinkReceipt_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FCustomProperties := nil;
  FCustomProperties_def := TCustomProperties_Tag.Create('CustomProperties', Self);

  FFiscalDocNum := nil;
  FGuid := nil;
  FGlobalFiscalId := nil;
end;

destructor TLinkReceipt_Tag.Destroy;
begin
  FCustomProperties.Free;
  FCustomProperties_def.Free;

  FFiscalDocNum.Free;
  FGuid.Free;
  FGlobalFiscalId.Free;

  inherited;
end;

function TLinkReceipt_Tag.CustomProperties(AisCanDef: Boolean): TCustomProperties_Tag;
begin
  Result := TCustomProperties_Tag(GetChildTag(FCustomProperties, 'CustomProperties', AisCanDef, FCustomProperties_def));
end;

function TLinkReceipt_Tag.FiscalDocNum(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FFiscalDocNum, 'FiscalDocNum', AisCanDef, AusDefVal);
end;

function TLinkReceipt_Tag.Guid(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FGuid, 'Guid', AisCanDef, AusDefVal);
end;

function TLinkReceipt_Tag.GlobalFiscalId(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FGlobalFiscalId, 'GlobalFiscalId', AisCanDef, AusDefVal);
end;

{ TTax_Tag }

constructor TTax_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FRateValue, 'RateValue');
  ParseAttr(AndTag, FTaxRateIndex, 'TaxRateIndex');
  ParseAttr(AndTag, FTaxValue, 'TaxValue');
  ParseAttr(AndTag, FTaxName, 'TaxName');
  ParseAttr(AndTag, FRateName, 'RateName');
end;

constructor TTax_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FTaxRateIndex := nil;
  FRateValue    := nil;
  FTaxValue     := nil;
  FTaxName      := nil;
  FRateName     := nil;
end;

destructor TTax_Tag.Destroy;
begin
  FRateValue.Free;
  FTaxRateIndex.Free;
  FTaxValue.Free;

  inherited;
end;

function TTax_Tag.RateName(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FRateName, 'RateName', AisCanDef, AusDefVal);
end;

function TTax_Tag.RateValue(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FRateValue, 'RateValue', AisCanDef, AusDefVal);
end;

function TTax_Tag.TaxName(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTaxName, 'TaxName', AisCanDef, AusDefVal);
end;

function TTax_Tag.TaxRateIndex(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTaxRateIndex, 'TaxRateIndex', AisCanDef, AusDefVal);
end;

function TTax_Tag.TaxValue(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTaxValue, 'TaxValue', AisCanDef, AusDefVal);
end;

{ TDiscount_Tag }

constructor T_DiscBase_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
  i: Integer;
  ndlt: IXmlNodeList;
begin
  inherited;

  ParseAttr(AndTag, FComment, 'Comment');

  nd := AndTag.SelectSingleNode('Taxes');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Tax');
    SetLength(FarTax, ndlt.Count);
    for i := Low(FarTax) to High(FarTax) do FarTax[i] := TTax_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Unfiscal');
  if Assigned(nd) then FUnfiscal := TUnfiscal_Tag.Create(nd, Self) else FUnfiscal := nil;
end;

constructor T_DiscBase_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FComment := nil;

  FUnfiscal := nil;
end;

destructor T_DiscBase_Tag.Destroy;
var
  i: Integer;
begin
  FComment.Free;

  for i := Low(FarTax) to High(FarTax) do FarTax[i].Free;

  FUnfiscal.Free;

  inherited;
end;

function T_DiscBase_Tag.Comment(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FComment, 'Comment', AisCanDef, AusDefVal);
end;

{ TPayment_Tag }

constructor TPayment_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  ParseAttr(AndTag, FTypeIndex    , 'TypeIndex'    );
  ParseAttr(AndTag, FISOCode      , 'ISOCode'      );
  ParseAttr(AndTag, FRate         , 'Rate'         );
  ParseAttr(AndTag, FOriginalValue, 'OriginalValue');
  ParseAttr(AndTag, FCardNum      , 'CardNum'      );
  ParseAttr(AndTag, FAuthCode     , 'AuthCode'     );
  ParseAttr(AndTag, FCardHolder   , 'CardHolder'   );
  ParseAttr(AndTag, FRRN          , 'RRN'          );

  nd := AndTag.SelectSingleNode('Unfiscal');
  if Assigned(nd) then FUnfiscal := TUnfiscal_Tag.Create(nd, Self) else FUnfiscal := nil;
end;

constructor TPayment_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FTypeIndex := nil;

  FUnfiscal      := nil;
  FISOCode       := nil;
  FRate          := nil;
  FOriginalValue := nil;
  FCardNum       := nil;
  FAuthCode      := nil;
  FCardHolder    := nil;
  FRRN           := nil;
end;

destructor TPayment_Tag.Destroy;
begin
  FTypeIndex.Free;

  FUnfiscal.Free;

  FISOCode.Free;
  FRate.Free;
  FOriginalValue.Free;
  FCardNum.Free;
  FAuthCode.Free;
  FCardHolder.Free;
  FRRN.Free;
  inherited;
end;

function TPayment_Tag.TypeIndex(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTypeIndex, 'TypeIndex', AisCanDef, AusDefVal);
end;

function TPayment_Tag.ISOCode(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FISOCode, 'ISOCode', AisCanDef, AusDefVal);
end;

function TPayment_Tag.Rate(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FRate, 'Rate', AisCanDef, AusDefVal);
end;

function TPayment_Tag.OriginalValue(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FOriginalValue, 'OriginalValue', AisCanDef, AusDefVal);
end;

function TPayment_Tag.RRN(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FRRN, 'RRN', AisCanDef, AusDefVal);
end;

function TPayment_Tag.AuthCode(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FAuthCode, 'AuthCode', AisCanDef, AusDefVal);
end;

function TPayment_Tag.CardHolder(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FCardHolder, 'CardHolder', AisCanDef, AusDefVal);
end;

function TPayment_Tag.CardNum(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FCardNum, 'CardNum', AisCanDef, AusDefVal);
end;

{ TBarcode_Tag }

constructor TBarcode_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FValue     , 'Value');
  ParseAttr(AndTag, FMultiplier, 'Multiplier');
end;

constructor TBarcode_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FValue      := nil;
  FMultiplier := nil;
end;

destructor TBarcode_Tag.Destroy;
begin
  FValue.Free;
  FMultiplier.Free;

  inherited;
end;

function TBarcode_Tag.Multiplier(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FMultiplier, 'Multiplier', AisCanDef, AusDefVal);
end;

function TBarcode_Tag.Value(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FValue, 'Value', AisCanDef, AusDefVal);
end;

{ TVoid_Tag }

constructor TVoid_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;
  ParseAttr(AndTag, FQuantity, 'Quantity');
end;

constructor TVoid_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FQuantity := nil;
end;

function TVoid_Tag.Quantity(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FQuantity, 'Quantity', AisCanDef, AusDefVal);
end;

destructor TVoid_Tag.Destroy;
begin
  FQuantity.Free;

  inherited;
end;

{ TItem_Tag }

constructor TItem_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
  i: Integer;
  ndlt: IXmlNodeList;
begin
  inherited;

  ParseAttr(AndTag, FDepartment , 'Department' );
  ParseAttr(AndTag, FDepartmentName, 'DepartmentName' );
  ParseAttr(AndTag, FQuantity, 'Quantity');
  ParseAttr(AndTag, FPricePerOne, 'PricePerOne');
  ParseAttr(AndTag, FPortionName, 'PortionName');
  ParseAttr(AndTag, FPriceToPay, 'PriceToPay');
  ParseAttr(AndTag, FForAdvance, 'ForAdvance');
  ParseAttr(AndTag, FItemKind, 'ItemKind');
  ParseAttr(AndTag, FPaymentKind, 'PaymentKind');

  nd := AndTag.SelectSingleNode('Discounts');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Discount');
    SetLength(FarDiscount, ndlt.Count);
    for i := Low(FarDiscount) to High(FarDiscount) do FarDiscount[i] := TDiscount_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('DiscInfos');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('DiscInfo');
    SetLength(FarDiscInfo, ndlt.Count);
    for i := Low(FarDiscInfo) to High(FarDiscInfo) do FarDiscInfo[i] := TDiscInfo_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Taxes');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Tax');
    SetLength(FarTax, ndlt.Count);
    for i := Low(FarTax) to High(FarTax) do FarTax[i] := TTax_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Barcodes');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Barcode');
    SetLength(FarBarcode, ndlt.Count);
    for i := Low(FarBarcode) to High(FarBarcode) do FarBarcode[i] := TBarcode_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Voids');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Void');
    SetLength(FarVoid, ndlt.Count);
    for i := Low(FarVoid) to High(FarVoid) do FarVoid[i] := TVoid_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Unfiscal');
  if Assigned(nd) then FUnfiscal := TUnfiscal_Tag.Create(nd, Self) else FUnfiscal := nil;

  nd := AndTag.SelectSingleNode('CustomData');
  if Assigned(nd) then begin
    ndlt := nd.ChildNodes;
    SetLength(FarItemCustomData, ndlt.Count);
    for i := Low(FarItemCustomData) to High(FarItemCustomData) do FarItemCustomData[i] := TItemCustomData_Tag.Create(ndlt[i], Self);
  end;
end;

constructor TItem_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FDepartment     := nil;
  FDepartmentName := nil;
  FQuantity       := nil;
  FPricePerOne    := nil;
  FPortionName    := nil;
  FPriceToPay     := nil;
  FForAdvance     := nil;
  FItemKind       := nil;
  FPaymentKind    := nil;

  FUnfiscal := nil;
end;

destructor TItem_Tag.Destroy;
var
  i: Integer;
begin
  FDepartment.Free;
  FDepartmentName.Free;
  FQuantity.Free;
  FPricePerOne.Free;
  FPortionName.Free;
  FPriceToPay.Free;
  FForAdvance.Free;
  FItemKind.Free;
  FPaymentKind.Free;

  for i := Low(FarDiscount) to High(FarDiscount) do FreeAndNil(FarDiscount[i]);
  for i := Low(FarDiscInfo) to High(FarDiscInfo) do FreeAndNil(FarDiscInfo[i]);
  for i := Low(FarTax     ) to High(FarTax     ) do FreeAndNil(FarTax     [i]);
  for i := Low(FarBarcode ) to High(FarBarcode ) do FreeAndNil(FarBarcode [i]);
  for i := Low(FarVoid    ) to High(FarVoid    ) do FreeAndNil(FarVoid    [i]);

  FUnfiscal.Free;

  inherited;
end;

function TItem_Tag.Department(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FDepartment, 'Department', AisCanDef, AusDefVal);
end;

function TItem_Tag.DepartmentName(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FDepartmentName, 'DepartmentName', AisCanDef, AusDefVal);
end;

function TItem_Tag.PricePerOne(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FPricePerOne, 'PricePerOne', AisCanDef, AusDefVal);
end;

function TItem_Tag.PortionName(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FPortionName, 'PortionName', AisCanDef, AusDefVal);
end;

function TItem_Tag.Quantity(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FQuantity, 'Quantity', AisCanDef, AusDefVal);
end;

function TItem_Tag.PriceToPay(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FPriceToPay, 'PriceToPay', AisCanDef, AusDefVal);
end;

function TItem_Tag.ForAdvance(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FForAdvance, 'ForAdvance', AisCanDef, AusDefVal);
end;

function TItem_Tag.ItemKind(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FItemKind, 'ItemKind', AisCanDef, AusDefVal);
end;

function TItem_Tag.PaymentKind(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FPaymentKind, 'PaymentKind', AisCanDef, AusDefVal);
end;

{ TOrder_Tag }

constructor TOrder_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  ParseAttr(AndTag, FGuests, 'Guests');
  ParseAttr(AndTag, FStartService, 'StartService');
  ParseAttr(AndTag, FTable, 'Table');
  ParseAttr(AndTag, FGuid, 'Guid');
  ParseAttr(AndTag, FName, 'Name');
  ParseAttr(AndTag, FGlobalId, 'GlobalId');

  nd := AndTag.SelectSingleNode('Operator');
  if Assigned(nd) then FOperator := TOperator_Tag.Create(nd, Self) else FOperator := nil;
  nd := AndTag.SelectSingleNode('Seat');
  if Assigned(nd) then FSeat := T_NumberName_Tag.Create(nd, Self) else FSeat := nil;
  FOperator_def := TOperator_Tag.Create('Operator', Self);
  FSeat_def := T_NumberName_Tag.Create('Seat', Self);
end;

constructor TOrder_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FGuests      := nil;
  FStartService:= nil;
  FTable       := nil;
  FGuid        := nil;
  FName        := nil;
  FGlobalId    := nil;

  FOperator := nil;
  FSeat     := nil;
  FOperator_def := TOperator_Tag.Create('Operator', Self);
  FSeat_def := T_NumberName_Tag.Create('Seat', Self);
end;

destructor TOrder_Tag.Destroy;
begin
  FGuests.Free;
  FStartService.Free;
  FTable.Free;
  FGuid.Free;
  FName.Free;
  FGlobalId.Free;

  FOperator.Free;
  FSeat.Free;
  FOperator_def.Free;
  FSeat_def.Free;

  inherited;
end;

function TOrder_Tag.GlobalId(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FGlobalId, 'GlobalId', AisCanDef, AusDefVal);
end;

function TOrder_Tag.Guests(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FGuests, 'Guests', AisCanDef, AusDefVal);
end;

function TOrder_Tag.Guid(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FGuid, 'Guid', AisCanDef, AusDefVal);
end;

function TOrder_Tag.Name(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

function TOrder_Tag.Operator(AisCanDef: Boolean = False): T_CodeName_Tag;
begin
  Result := T_CodeName_Tag(GetChildTag(FOperator, 'Operator', AisCanDef, FOperator_def));
end;

function TOrder_Tag.Seat(AisCanDef: Boolean = False): T_NumberName_Tag;
begin
  Result := T_NumberName_Tag(GetChildTag(FSeat, 'Seat', AisCanDef, FSeat_def));
end;

function TOrder_Tag.StartService(AisCanDef: Boolean =  True; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FStartService, 'StartService', AisCanDef, AusDefVal);
end;

function TOrder_Tag.Table(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTable, 'Table', AisCanDef, AusDefVal);
end;

{ TDeletion_Tag }

constructor TDeletion_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  ParseAttr(AndTag, FTime, 'Time');

  nd := AndTag.SelectSingleNode('LinkReceipt');
  if Assigned(nd) then FLinkReceipt := TLinkReceipt_Tag.Create(nd, Self) else FLinkReceipt := nil;
  nd := AndTag.SelectSingleNode('Operator');
  if Assigned(nd) then FOperator := T_CodeName_Tag.Create(nd, Self) else FOperator := nil;
  FLinkReceipt_def := TLinkReceipt_Tag.Create('LinkReceipt', Self);
  FOperator_def := T_CodeName_Tag.Create('Operator', Self);
end;

constructor TDeletion_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FTime := nil;

  FLinkReceipt := nil;
  FOperator    := nil;
  FLinkReceipt_def := TLinkReceipt_Tag.Create('LinkReceipt', Self);
  FOperator_def := T_CodeName_Tag.Create('Operator', Self);
end;

destructor TDeletion_Tag.Destroy;
begin
  FTime.Free;

  FLinkReceipt.Free;
  FOperator.Free;
  FLinkReceipt_def.Free;
  FOperator_def.Free;

  inherited;
end;

function TDeletion_Tag.LinkReceipt(AisCanDef: Boolean = False): TLinkReceipt_Tag;
begin
  Result := TLinkReceipt_Tag(GetChildTag(FLinkReceipt, 'LinkReceipt', AisCanDef, FLinkReceipt_def));
end;

function TDeletion_Tag.Operator(AisCanDef: Boolean = False): T_CodeName_Tag;
begin
  Result := T_CodeName_Tag(GetChildTag(FOperator, 'Operator', AisCanDef, FOperator_def));
end;

function TDeletion_Tag.Time(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FTime, 'Time', AisCanDef, AusDefVal);
end;

{ TReceipt_Tag }

constructor TReceipt_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
  i: Integer;
  ndlt: IXmlNodeList;
begin
  inherited;

  ParseAttr(AndTag, FDocNumber, 'DocNumber');
  ParseAttr(AndTag, FGuid     , 'Guid'     );
  ParseAttr(AndTag, FLastBill , 'LastBill' );
  ParseAttr(AndTag, FTaxType  , 'TaxType' );

  nd := AndTag.SelectSingleNode('Order');
  if Assigned(nd) then FOrder := TOrder_Tag.Create(nd, Self) else FOrder := nil;
  nd := AndTag.SelectSingleNode('Deletion');
  if Assigned(nd) then FDeletion := TDeletion_Tag.Create(nd, Self) else FDeletion := nil;
  FOrder_def    := TOrder_Tag.Create   ('Order', Self);
  FDeletion_def := TDeletion_Tag.Create('Deletion', Self);

  nd := AndTag.SelectSingleNode('Items');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Item');
    SetLength(FarItem, ndlt.Count);
    for i := Low(FarItem) to High(FarItem) do FarItem[i] := TItem_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Discounts');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Discount');
    SetLength(FarDiscount, ndlt.Count);
    for i := Low(FarDiscount) to High(FarDiscount) do FarDiscount[i] := TDiscount_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('DiscInfos');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('DiscInfo');
    SetLength(FarDiscInfo, ndlt.Count);
    for i := Low(FarDiscInfo) to High(FarDiscInfo) do FarDiscInfo[i] := TDiscInfo_Tag.Create(ndlt[i], Self);
  end;

  nd := AndTag.SelectSingleNode('Payments');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Payment');
    SetLength(FarPayment, ndlt.Count);
    for i := Low(FarPayment) to High(FarPayment) do FarPayment[i] := TPayment_Tag.Create(ndlt[i], Self);
  end;
end;

constructor TReceipt_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FDocNumber := nil;
  FGuid      := nil;
  FLastBill  := nil;
  FTaxType   := nil;

  FOrder    := nil;
  FDeletion := nil;
  FOrder_def    := TOrder_Tag.Create   ('Order'   , Self);
  FDeletion_def := TDeletion_Tag.Create('Deletion', Self);
end;

destructor TReceipt_Tag.Destroy;
var
  i: Integer;
begin
  FDocNumber.Free;
  FGuid     .Free;
  FLastBill .Free;
  FTaxType  .Free;

  FOrder.Free;
  FDeletion.Free;
  FOrder_def.Free;
  FDeletion_def.Free;

  for i := Low(FarItem)     to High(FarItem)     do FreeAndNil(FarItem    [i]);
  for i := Low(FarDiscount) to High(FarDiscount) do FreeAndNil(FarDiscount[i]);
  for i := Low(FarDiscInfo) to High(FarDiscInfo) do FreeAndNil(FarDiscInfo[i]);
  for i := Low(FarPayment)  to High(FarPayment)  do FreeAndNil(FarPayment [i]);

  inherited;
end;

function TReceipt_Tag.DocNumber(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FDocNumber, 'DocNumber', AisCanDef, AusDefVal);
end;

function TReceipt_Tag.Guid(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FGuid, 'Guid', AisCanDef, AusDefVal);
end;

function TReceipt_Tag.LastBill(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr;
begin
  Result := Self.GetAttr(FLastBill, 'LastBill', AisCanDef, AusDefVal);
end;

function TReceipt_Tag.TaxType(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FTaxType, 'TaxType', AisCanDef, AusDefVal);
end;

function TReceipt_Tag.Order(AisCanDef: Boolean = False): TOrder_Tag;
begin
  Result := TOrder_Tag(GetChildTag(FOrder, 'Order', AisCanDef, FOrder_def));
end;

function TReceipt_Tag.Deletion(AisCanDef: Boolean = False): TDeletion_Tag;
begin
  Result := TDeletion_Tag(GetChildTag(FDeletion, 'Deletion', AisCanDef, FDeletion_def));
end;

{ TReport_Tag }

constructor TReport_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FParameters, 'Parameters');
  ParseAttr(AndTag, FReportType, 'ReportType');
end;

constructor TReport_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FParameters := nil;
  FReportType := nil;
end;

destructor TReport_Tag.Destroy;
begin
  FParameters.Free;
  FReportType.Free;

  inherited;
end;

function TReport_Tag.Parameters(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FParameters, 'Parameters', AisCanDef, AusDefVal);
end;

function TReport_Tag.ReportType(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FReportType, 'ReportType', AisCanDef, AusDefVal);
end;

{ THeader_Tag }

constructor THeader_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  nd := AndTag.SelectSingleNode('Operator');
  if Assigned(nd) then FOperator := TOperator_Tag.Create(nd, Self) else FOperator := nil;
  nd := AndTag.SelectSingleNode('Restaurant');
  if Assigned(nd) then FRestaurant := T_CodeName_Tag.Create(nd, Self) else FRestaurant := nil;
  nd := AndTag.SelectSingleNode('Station');
  if Assigned(nd) then FStation := T_IdCodeName_Tag.Create(nd, Self) else FStation := nil;
  nd := AndTag.SelectSingleNode('CustomProperties');
  if Assigned(nd) then FCustomProperties := TCustomProperties_Tag.Create(nd, Self) else FCustomProperties := nil;
  FOperator_def         := TOperator_Tag.Create('Operator', Self);
  FRestaurant_def       := T_CodeName_Tag.Create('Restaurant', Self);
  FStation_def          := T_IdCodeName_Tag.Create('Station', Self);
  FCustomProperties_def := TCustomProperties_Tag.Create('CustomProperties', Self);

  nd := AndTag.SelectSingleNode('Unfiscal');
  if Assigned(nd) then FUnfiscal := TUnfiscal_Tag.Create(nd, Self) else FUnfiscal := nil;
end;

constructor THeader_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FOperator         := nil;
  FRestaurant       := nil;
  FStation          := nil;
  FCustomProperties := nil;
  FOperator_def         := TOperator_Tag.Create('Operator', Self);
  FRestaurant_def       := T_CodeName_Tag.Create('Restaurant', Self);
  FStation_def          := T_IdCodeName_Tag.Create('Station', Self);
  FCustomProperties_def := TCustomProperties_Tag.Create('CustomProperties', Self);

  FUnfiscal := nil;
end;

destructor THeader_Tag.Destroy;
begin
  FOperator.Free;
  FRestaurant.Free;
  FStation.Free;
  FCustomProperties.Free;
  FOperator_def.Free;
  FRestaurant_def.Free;
  FStation_def.Free;
  FCustomProperties_def.Free;

  FUnfiscal.Free;

  inherited;
end;

function THeader_Tag.Operator(AisCanDef: Boolean = False): TOperator_Tag;
begin
  Result := TOperator_Tag(GetChildTag(FOperator, 'Operator', AisCanDef, FOperator_def));
end;

function THeader_Tag.Restaurant(AisCanDef: Boolean = False): T_CodeName_Tag;
begin
  Result := T_CodeName_Tag(GetChildTag(FRestaurant, 'Restaurant', AisCanDef, FRestaurant_def));
end;

function THeader_Tag.Station(AisCanDef: Boolean = False): T_IdCodeName_Tag;
begin
  Result := T_IdCodeName_Tag(GetChildTag(FStation, 'Station', AisCanDef, FStation_def));
end;

function THeader_Tag.CustomProperties(AisCanDef: Boolean): TCustomProperties_Tag;
begin
  Result := TCustomProperties_Tag(GetChildTag(FCustomProperties, 'CustomProperties', AisCanDef, FCustomProperties_def));
end;

{ TFooter_Tag }

constructor TFooter_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
begin
  inherited;

  nd := AndTag.SelectSingleNode('Unfiscal');
  if Assigned(nd) then FUnfiscal := TUnfiscal_Tag.Create(nd, Self) else FUnfiscal := nil;
end;

constructor TFooter_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FUnfiscal := nil;
end;

destructor TFooter_Tag.Destroy;
begin
  FUnfiscal.Free;

  inherited;
end;

{ TTLV_Tag }

constructor TTLV_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FTag  , 'Tag'  );
  ParseAttr(AndTag, FValue, 'Value');
end;

constructor TTLV_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited;

  FTag   := nil;
  FValue := nil;
end;

destructor TTLV_Tag.Destroy;
begin
  FTag.Free;
  FValue.Free;

  inherited;
end;

function TTLV_Tag.Tag(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FTag, 'Tag', AisCanDef, AusDefVal);
end;

function TTLV_Tag.Value(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FValue, 'Value', AisCanDef, AusDefVal);
end;

{ TSTLV_Tag }

constructor TSTLV_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  ndlt: IXmlNodeList;
  i: Integer;
begin
  inherited;

  ParseAttr(AndTag, FTag, 'Tag');

  ndlt := AndTag.SelectNodes('TLV');
  SetLength(FarTLV, ndlt.Count);
  for i := Low(FarTLV) to High(FarTLV) do FarTLV[i] := TTLV_Tag.Create(ndlt[i], Self);
end;

constructor TSTLV_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited;

  FTag := nil;
end;

destructor TSTLV_Tag.Destroy;
var
  i: Integer;
begin
  FTag.Free;

  for i := Low(FarTLV) to High(FarTLV) do FarTLV[i].Free;

  inherited;
end;

function TSTLV_Tag.Tag(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FTag, 'Tag', AisCanDef, AusDefVal);
end;

{ TFFD_Tag }

function TFFD_Tag.Code(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FCode, 'Code', AisCanDef, AusDefVal);
end;

constructor TFFD_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  ndlt: IXmlNodeList;
  i: Integer;
begin
  inherited;

  ParseAttr(AndTag, FCode, 'Code');

  ndlt := AndTag.SelectNodes('TLV');
  SetLength(FarTLV, ndlt.Count);
  for i := Low(FarTLV) to High(FarTLV) do FarTLV[i] := TTLV_Tag.Create(ndlt[i], Self);

  ndlt := AndTag.SelectNodes('STLV');
  SetLength(FarSTLV, ndlt.Count);
  for i := Low(FarSTLV) to High(FarSTLV) do FarSTLV[i] := TSTLV_Tag.Create(ndlt[i], Self);

  FDefVal := nil;
end;

constructor TFFD_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited;

  FCode := nil;

  FDefVal := nil;
end;

destructor TFFD_Tag.Destroy;
var
  i: Integer;
begin
  FCode.Free;

  for i := Low(FarTLV)  to High(FarTLV)  do FarTLV[i] .Free;
  for i := Low(FarSTLV) to High(FarSTLV) do FarSTLV[i].Free;

  FDefVal.Free;

  inherited;
end;

function TFFD_Tag.Value(AwTag: Word; AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
var
  i, j: Integer;
begin
  for i := Low(FarTLV)  to High(FarTLV)  do if FarTLV[i].FTag.i = AwTag then begin
    Result := FarTLV[i].FValue;
    Exit;
  end;
  for j := Low(FarSTLV) to High(FarSTLV) do begin
    for i := Low(FarSTLV[j].FarTLV)  to High(FarSTLV[j].FarTLV)  do if FarSTLV[j].FarTLV[i].FTag.i = AwTag then begin
      Result := FarSTLV[j].FarTLV[i].FValue;
      Exit;
    end;
  end;

  if AisCanDef then begin
    FDefVal.Free;

    FDefVal := T_Attr.Create('TLV_Tag_' + IntToStr(AwTag), Self, AusDefVal);
    Result := FDefVal;
  end else begin
    raise Exception.CreateFmt('Required TLV Tag="%d" is missed', [AwTag]);
  end;
end;

{ TFiscalDocument_Tag }

constructor TFiscalDocument_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
  i: Integer;
  ndlt: IXmlNodeList;
begin
  inherited;

  ParseAttr(AndTag, FDocType, 'DocType');
  ParseAttr(AndTag, FOptions, 'Options');

  nd := AndTag.SelectSingleNode('Header');
  if Assigned(nd) then FHeader      := THeader_Tag.Create (nd, Self) else FHeader := nil;
  nd := AndTag.SelectSingleNode('Footer');
  if Assigned(nd) then FFooter      := TFooter_Tag.Create (nd, Self) else FFooter := nil;
  nd := AndTag.SelectSingleNode('Invoice');
  if Assigned(nd) then FInvoice     := TInvoice_Tag.Create(nd, Self) else FInvoice := nil;
  nd := AndTag.SelectSingleNode('LinkReceipt');
  if Assigned(nd) then FLinkReceipt := TLinkReceipt_Tag.Create(nd, Self) else FLinkReceipt := nil;
  nd := AndTag.SelectSingleNode('Receipt');
  if Assigned(nd) then FReceipt     := TReceipt_Tag.Create(nd, Self) else FReceipt := nil;
  nd := AndTag.SelectSingleNode('Report');
  if Assigned(nd) then FReport      := TReport_Tag.Create (nd, Self) else FReport := nil;
  nd := AndTag.SelectSingleNode('FFD');
  if Assigned(nd) then FFFD         := TFFD_Tag.Create(nd, Self) else FFFD := nil;
  nd := AndTag.SelectSingleNode('Reason');
  if Assigned(nd) then FReason      := TReason_Tag.Create(nd, Self) else FReason := nil;

  FHeader_def      := THeader_Tag     .Create('Header'     , Self);
  FFooter_def      := TFooter_Tag     .Create('Footer'     , Self);
  FInvoice_def     := TInvoice_Tag    .Create('Invoice'    , Self);
  FLinkReceipt_def := TLinkReceipt_Tag.Create('LinkReceipt', Self);
  FReceipt_def     := TReceipt_Tag    .Create('Receipt'    , Self);
  FPayment_def     := TPayment_Tag    .Create('Payment'    , Self);
  FReport_def      := TReport_Tag     .Create('Report'     , Self);
  FFFD_def         := TFFD_Tag        .Create('FFD'        , Self);
  FReason_def      := TReason_Tag     .Create('Reason'     , Self);

  ndlt := AndTag.SelectNodes('Payment');
  SetLength(FarPayment, ndlt.Count);
  for i := Low(FarPayment) to High(FarPayment) do FarPayment[i] := TPayment_Tag.Create(ndlt[i], Self);
end;

constructor TFiscalDocument_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FDocType := nil;
  FOptions := nil;

  FHeader      := nil;
  FFooter      := nil;
  FInvoice     := nil;
  FLinkReceipt := nil;
  FReceipt     := nil;
  FReport      := nil;
  FFFD         := nil;
  FReason      := nil;
  FHeader_def      := nil;
  FFooter_def      := nil;
  FInvoice_def     := nil;
  FLinkReceipt_def := nil;
  FReceipt_def     := nil;
  FPayment_def     := nil;
  FReport_def      := nil;
  FFFD_def         := nil;
  FReason_def      := nil;
end;

destructor TFiscalDocument_Tag.Destroy;
var
  i: Integer;
begin
  FDocType.Free;
  FOptions.Free;

  FHeader     .Free;
  FFooter     .Free;
  FInvoice    .Free;
  FLinkReceipt.Free;
  FReceipt    .Free;
  FReport     .Free;
  FFFD        .Free;
  FReason     .Free;
  FHeader_def     .Free;
  FFooter_def     .Free;
  FInvoice_def    .Free;
  FLinkReceipt_def.Free;
  FReceipt_def    .Free;
  FPayment_def    .Free;
  FReport_def     .Free;
  FFFD_def        .Free;
  FReason_def     .Free;
  for i := Low(FarPayment) to High(FarPayment) do FarPayment[i].Free;
  inherited;
end;

function TFiscalDocument_Tag.DocType(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FDocType, 'DocType', AisCanDef, AusDefVal);
end;

function TFiscalDocument_Tag.FFD(AisCanDef: Boolean = False): TFFD_Tag;
begin
  Result := TFFD_Tag(GetChildTag(FFFD, 'FFD', AisCanDef, FFFD_def));
end;

function TFiscalDocument_Tag.Reason(AisCanDef: Boolean = False): TReason_Tag;
begin
  Result := TReason_Tag(GetChildTag(FReason, 'Reason', AisCanDef, FReason_def));
end;

function TFiscalDocument_Tag.Footer(AisCanDef: Boolean =  True): TFooter_Tag;
begin
  Result := TFooter_Tag(GetChildTag(FFooter, 'Footer', AisCanDef, FFooter_def));
end;

function TFiscalDocument_Tag.Header(AisCanDef: Boolean = False): THeader_Tag;
begin
  Result := THeader_Tag(GetChildTag(FHeader, 'Header', AisCanDef, FHeader_def));
end;

function TFiscalDocument_Tag.Invoice(AisCanDef: Boolean = False): TInvoice_Tag;
begin
  Result := TInvoice_Tag(GetChildTag(FInvoice, 'Invoice', AisCanDef, FInvoice_def));
end;

function TFiscalDocument_Tag.LinkReceipt(AisCanDef: Boolean = False): TLinkReceipt_Tag;
begin
  Result := TLinkReceipt_Tag(GetChildTag(FLinkReceipt, 'LinkReceipt', AisCanDef, FLinkReceipt_def));
end;

function TFiscalDocument_Tag.Options(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FOptions, 'Options', AisCanDef, AusDefVal);
end;

function TFiscalDocument_Tag.Payment(AisCanDef: Boolean = False): TPayment_Tag;
var
  Payment: TPayment_Tag;
begin
  if Length(FarPayment) > 0 then Payment := FarPayment[0] else Payment := nil;
  Result := TPayment_Tag(GetChildTag(Payment, 'Payment', AisCanDef, FPayment_def));
end;

function TFiscalDocument_Tag.Receipt(AisCanDef: Boolean = False): TReceipt_Tag;
begin
  Result := TReceipt_Tag(GetChildTag(FReceipt, 'Receipt', AisCanDef, FReceipt_def));
end;

function TFiscalDocument_Tag.Report(AisCanDef: Boolean = False): TReport_Tag;
begin
  Result := TReport_Tag(GetChildTag(FReport, 'Report', AisCanDef, FReport_def));
end;

{ TFiscalDocument }

constructor TFiscalDocument.Create(ApcXMLDoc: PAnsiChar; out AusError: UTF8String);
const
  S_ROOT_NAME = 'FiscalDocument';
var
  XmlDocument: IXmlDocument;
begin
  try
    XmlDocument := LoadXmlDocumentFromXML(ApcXMLDoc);
  except
    on E: Exception do begin
      AusError := S_ROOT_NAME + ' xml loading syntax error: ' + E.Message;
      Exit;
    end;
  end;

  if not Assigned(XmlDocument) or not Assigned(XmlDocument.DocumentElement) then begin
    AusError := S_ROOT_NAME + ' xml root element is absent';
    Exit;
  end;

  if XmlDocument.DocumentElement.NodeName <> S_ROOT_NAME then begin
    AusError := S_ROOT_NAME + ' xml root element is not ' + S_ROOT_NAME;
    Exit;
  end;

  FFiscalDocument := TFiscalDocument_Tag.Create(XmlDocument.DocumentElement, nil);

  AusError := '';
end;

destructor TFiscalDocument.Destroy;
begin
  FFiscalDocument.Free;

  inherited;
end;

{ TZReportData }

procedure TZReportData.AddCounterValue(const AusSourceID, AusValueKeyID, AusValue: UTF8String);
var
  nd: IXmlNode;
begin
  if not Assigned(FndCounterValues) then FndCounterValues := FXmlDocument.DocumentElement.AppendElement('CounterValues');

  nd := CreateXmlElement('CounterValue');
  nd.SetAttr('SourceID'  , AusSourceID  );
  nd.SetAttr('ValueKeyID', AusValueKeyID);
  nd.SetAttr('Value'     , AusValue     );

  FndCounterValues.AppendChild(nd);
end;

procedure TZReportData.AddDepartmentValue(const AusNumber, AusName, AusValue: UTF8String);
var
  nd: IXmlNode;
begin
  if not Assigned(FndDepartmentValues) then FndDepartmentValues := FXmlDocument.DocumentElement.AppendElement('DepartmentValues');

  nd := CreateXmlElement('DepartmentValue');
  nd.SetAttr('Number', AusNumber);
  nd.SetAttr('Name'  , AusName  );
  nd.SetAttr('Value' , AusValue );

  FndDepartmentValues.AppendChild(nd);
end;

constructor TZReportData.Create(const AusPOS_ID, AusZReportNumber, AusCashInValue, AusPayCashValue, AusPayNonCashValue, AusDayValue, AusReturnValue, AusTaxValue, AusTotal: UTF8String);
var
  nd: IXmlNode;
begin
  FXmlDocument := CreateXmlDocument('ZReportData', '1.0', 'utf-8');
  nd := FXmlDocument.DocumentElement;

  if AusPOS_ID          <> '' then nd.SetAttr('POS_ID'         , AusPOS_ID         );
  if AusZReportNumber   <> '' then nd.SetAttr('ZReportNumber'  , AusZReportNumber  );
  if AusCashInValue     <> '' then nd.SetAttr('CashInValue'    , AusCashInValue    );
  if AusPayCashValue    <> '' then nd.SetAttr('PayCashValue'   , AusPayCashValue   );
  if AusPayNonCashValue <> '' then nd.SetAttr('PayNonCashValue', AusPayNonCashValue);
  if AusDayValue        <> '' then nd.SetAttr('DayValue'       , AusDayValue       );
  if AusReturnValue     <> '' then nd.SetAttr('ReturnValue'    , AusReturnValue    );
  if AusTaxValue        <> '' then nd.SetAttr('TaxValue'       , AusTaxValue       );
  if AusTotal           <> '' then nd.SetAttr('Total'          , AusTotal          );

  FndDepartmentValues := nil;
  FndCounterValues := nil;
end;

function TZReportData.usToXML: UTF8String;
begin
  Result := FXmlDocument.XML;
end;

{ TFiscalDocumentReturn }

constructor TFiscalDocumentReturn.Create;
begin
  FXmlDocument := CreateXmlDocument('FiscalDocumentReturn', '1.0', 'utf-8');
end;

procedure TFiscalDocumentReturn.SetDocumentInfo(const AusGlobalId: UTF8String);
var
  nd: IXmlNode;
begin
  nd := FXmlDocument.DocumentElement.EnsureChild('DocumentInfo');
  nd.SetAttr('GlobalId', AusGlobalId);
end;

function TFiscalDocumentReturn.usToXML: UTF8String;
begin
  Result := FXmlDocument.XML;
end;

end.


