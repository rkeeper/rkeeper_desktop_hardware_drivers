unit uUnFiscXml_;

interface
 
uses
   SysUtils
  ,Types
  ,Classes
  ,Simplexml
  ,uXMLcommon
  ;

type
  TeUnfiscalTag = (
     unfTextBlock
    ,unfTextLine
    ,unfTextPart
    ,unfRawBlock
    ,unfBarCode
    ,unfBeep
    ,unfDrawer
    ,unfLogo
    ,unfPass
    ,unfWait
    ,unfAddInfo
  );
const
  S_UNFISCAL_TAG: array[TeUnfiscalTag] of UTF8String = (
     'TextBlock'
    ,'TextLine'
    ,'TextPart'
    ,'RawBlock'
    ,'BarCode'
    ,'Beep'
    ,'Drawer'
    ,'Logo'
    ,'Pass'
    ,'Wait'
    ,'AddInfo'
  );

type
  TUnfChild_Tag = class(T_Tag)
  public
    constructor Create(AeUnfiscalTag: TeUnfiscalTag; AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
  protected
    FeUnfiscalTag: TeUnfiscalTag;
  public
    property eUnfiscalTag: TeUnfiscalTag read FeUnfiscalTag;
  public
    constructor Create(AeUnfiscalTag: TeUnfiscalTag); overload;
  end;

  TunfTextCommon_Tag = class(TUnfChild_Tag)
  private
    FBold     : T_Attr;
    FBigWidth : T_Attr;
    FInverted : T_Attr;
    FBigHeight: T_Attr;
    FFontNum  : T_Attr;
    FTapes    : T_Attr;
  public
    constructor Create(AeUnfiscalTag: TeUnfiscalTag; AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Bold     (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr; // "0"|"1" 0 - обычная яркость шрифта | 1 - повышенная яркость шрифта
    function BigWidth (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr; // "0"|"1" 0 - обычная ширина символов | 1 - двойная ширина символов
    function Inverted (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr; // "0"|"1" 0 - сбросить выделение цветом | 1 - установить выделение цветом
    function BigHeight(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr; // "0"|"1" 0 - обычная высота символов | 1 - двойная высота символов
    function FontNum  (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr; // "1"     номер шрифта (в настоящее время не поддерживается)
    function Tapes    (AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr; // "1"|"2"|"3"  Выбор лент для печати: 1 - основная, 2 - контрольная, 3 - обе
  public
    constructor Create(AeUnfiscalTag: TeUnfiscalTag); overload;
    procedure SetBold     (const AusValue: UTF8String); // "0"|"1" 0 - обычная яркость шрифта | 1 - повышенная яркость шрифта
    procedure SetBigWidth (const AusValue: UTF8String); // "0"|"1" 0 - обычная ширина символов | 1 - двойная ширина символов
    procedure SetInverted (const AusValue: UTF8String); // "0"|"1" 0 - сбросить выделение цветом | 1 - установить выделение цветом
    procedure SetBigHeight(const AusValue: UTF8String); // "0"|"1" 0 - обычная высота символов | 1 - двойная высота символов
    procedure SetFontNum  (const AusValue: UTF8String); // "1"     номер шрифта (в настоящее время не поддерживается)
    procedure SetTapes    (const AusValue: UTF8String); // "1"|"2"|"3"  Выбор лент для печати: 1 - основная, 2 - контрольная, 3 - обе
  end;

  TunfTextBlock_Tag = class(TunfTextCommon_Tag)
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    constructor Create(const AusValue: UTF8String); overload;
  end;

  TunfTextLine_Tag = class(TunfTextCommon_Tag)
  private
    FText: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Text(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  public
    constructor Create(const AusText: UTF8String); overload;
    procedure SetText(const AusValue: UTF8String);
  end;

  TunfTextPart_Tag = class(TunfTextCommon_Tag)
  private
    FText: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Text(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  public
    constructor Create(const AusText: UTF8String); overload;
    procedure SetText(const AusValue: UTF8String);
  end;

type
  TunfRawBlock_Tag = class(TUnfChild_Tag)
  private
    FEncoding: T_Attr;
  private
    function GetsData: AnsiString;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Encoding(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  public
    property sData: AnsiString read GetsData;
  public
    constructor Create(AeRawEncoding: TeRawEncoding); overload;
    procedure SetEncoding(const AusValue: UTF8String);
  end;

type
  TunfBarCode_Tag = class(TUnfChild_Tag)
  private
    FWidth          : T_Attr; // это ширина эдементарной линии в точках, а не всего кода
    FHeight         : T_Attr;
    FType           : T_Attr;
    FTextPosition   : T_Attr;
    FCorrectionLevel: T_Attr;
    FAlign          : T_Attr;
    FFlowTextLines  : T_Attr;
    FValue          : T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Width          (AisCanDef: Boolean =  True; AusDefVal: UTF8String =      '2'): T_Attr; // ширина минимального элемента в точках
    function Height         (AisCanDef: Boolean =  True; AusDefVal: UTF8String =    '100'): T_Attr; // высота в точках
    function _Type          (AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'EAN-13'): T_Attr; // "EAN-13"|"Code-39"|"Code-128"|"QRCode"
    function TextPosition   (AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'Bottom'): T_Attr; // "No"|"Top"|"Bottom"|"Top&Bottom" (для Type <> QRCode)
    function CorrectionLevel(AisCanDef: Boolean =  True; AusDefVal: UTF8String =    '30%'): T_Attr; // "7%"|"15%"|"25%"|"30%", начиная с 12 версии, только для Type = QRCode
    function Align          (AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'Center'): T_Attr; // "Center"|"Left"|"Right", только для Type = QRCode
    function FlowTextLines  (AisCanDef: Boolean =  True; AusDefVal: UTF8String =      '0'): T_Attr; // сколько следующих строк текста распечатать рядом с кодом, только для Align="Left" или Align="Right", только для Type = QRCode
    function Value          (AisCanDef: Boolean = False; AusDefVal: UTF8String =       ''): T_Attr;
  public
    constructor Create(const AusValue: UTF8String); overload;
    procedure SetWidth          (const AusValue: UTF8String); // ширина минимального элемента в точках
    procedure SetHeight         (const AusValue: UTF8String); // высота в точках
    procedure SetType           (const AusValue: UTF8String); // "EAN-13"|"Code-39"|"Code-128"|"QRCode"
    procedure SetTextPosition   (const AusValue: UTF8String); // "No"|"Top"|"Bottom"|"Top&Bottom" (для Type <> QRCode)
    procedure SetCorrectionLevel(const AusValue: UTF8String); // "7%"|"15%"|"25%"|"30%", начиная с 12 версии, только для Type = QRCode
    procedure SetAlign          (const AusValue: UTF8String); // "Center"|"Left"|"Right", только для Type = QRCode
    procedure SetFlowTextLines  (const AusValue: UTF8String); // сколько следующих строк текста распечатать рядом с кодом, только для Align="Left" или Align="Right", только для Type = QRCode
    procedure SetValue          (const AusValue: UTF8String);
  end;

  TunfBeep_Tag = class(TUnfChild_Tag)
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create; overload;
    destructor Destroy; override;
  end;

  TunfDrawer_Tag = class(TUnfChild_Tag)
  private
    FNumber: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Number(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr; // "0"|"1" импульс на разъем ящика с номером = Number
  public
    constructor Create(Ai6Number: Int64); overload;
    procedure SetNumber(const AusValue: UTF8String); // "0"|"1" импульс на разъем ящика с номером = Number
  end;

  TunfLogo_Tag = class(TUnfChild_Tag)
  private
    FNumber: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Number(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr; // печать картинки из памяти принтера, номер = Number
  public
    constructor Create(Ai6Number: Int64); overload;
    procedure SetNumber(const AusValue: UTF8String); // печать картинки из памяти принтера, номер = Number
  end;

  TunfPass_Tag = class(TUnfChild_Tag)
  private
    FLines: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Lines(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr; // "0".."99" прогон нескольких строк, количество строк = Lines
  public
    constructor Create(Ai6Lines: Int64); overload;
    procedure SetLines(const AusValue: UTF8String); // "0".."99" прогон нескольких строк, количество строк = Lines
  end;

  TunfWait_Tag = class(TUnfChild_Tag)
  private
    FMSecs: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function MSecs(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr; // "0".."100000" подождать, милисекунд = MSecs
  public
    constructor Create(Ai6MSecs: Int64); overload;
    procedure SetMSecs(const AusValue: UTF8String); // "0".."100000" подождать, милисекунд = MSecs
  end;

  TunfAddInfo_Tag = class(TUnfChild_Tag) // Дополнительная информация специфичная для применения
  private
    FName: T_Attr;
    FData: T_Attr;
  public
    constructor Create(AXMLnode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Name(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
    function Data(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
  public
    constructor Create(const AusName, AusData: UTF8String); overload;
    procedure SetName(const AusValue: UTF8String);
    procedure SetData(const AusValue: UTF8String);
  end;

  TarUnfChild_Tag = array of TUnfChild_Tag;

  TUnfiscal_Tag = class(T_Tag)
  private
    FCutAfter: T_Attr;
    FSlip    : T_Attr;
    FPosition: T_Attr;
  private
    FarUnfChild: TarUnfChild_Tag;
  public
    constructor Create(AXmlNode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function CutAfter(AisCanDef: Boolean =  True; AusDefVal: UTF8String =      '1'): T_Attr;
    function Slip    (AisCanDef: Boolean =  True; AusDefVal: UTF8String =      '0'): T_Attr;
    function Position(AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'Before'): T_Attr;
  public
    property arUnfChild: TarUnfChild_Tag read FarUnfChild;
  public
    constructor Create; overload;
    procedure SetCutAfter(const AusValue: UTF8String);
    procedure SetSlip    (const AusValue: UTF8String);
    procedure SetPosition(const AusValue: UTF8String);
    procedure AddUnfChild(AUnfChild: TUnfChild_Tag);
    procedure CloneUnfChild(AUnfChild: TUnfChild_Tag);
  end;

  TarUnfiscal_Tag = array of TUnfiscal_Tag;

  TUnfiscal = class
  private
   FUnfiscal: TUnfiscal_Tag;
  public
    constructor Create(ApcXMLBuffer: PAnsiChar; out AusError: UTF8String);
    destructor Destroy; override;
  public
    property Unfiscal: TUnfiscal_Tag read FUnfiscal;
  end;

  TPRINTUNFISCAL_Tag = class(T_Tag)
  private
    Fxml_lang: T_Attr;
  private
    FarUnfiscal: TarUnfiscal_Tag;
  public
    constructor Create(AXmlNode: IXmlNode; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function xml_lang(AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'ru'): T_Attr;
  public
    property arUnfiscal: TarUnfiscal_Tag read FarUnfiscal;
  public
    constructor Create; overload;
    procedure Setxml_lang(const AusValue: UTF8String);
    procedure AddUnfiscal(AUnfiscal: TUnfiscal_Tag);
  end;

implementation

{ TUnfChild_Tag }

constructor TUnfChild_Tag.Create(AeUnfiscalTag: TeUnfiscalTag; AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(AXMLnode, AParentTag);

  FeUnfiscalTag := AeUnfiscalTag;
end;

constructor TUnfChild_Tag.Create(AeUnfiscalTag: TeUnfiscalTag);
begin
  inherited Create(S_UNFISCAL_TAG[AeUnfiscalTag]);

  FeUnfiscalTag := AeUnfiscalTag;
end;

{ TunfTextCommon_Tag }

constructor TunfTextCommon_Tag.Create(AeUnfiscalTag: TeUnfiscalTag; AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(AeUnfiscalTag, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FFontNum  , 'FontNum'  );
  ParseAttr(AXmlNode, FBold     , 'Bold'     );
  ParseAttr(AXmlNode, FBigHeight, 'BigHeight');
  ParseAttr(AXmlNode, FBigWidth , 'BigWidth' );
  ParseAttr(AXmlNode, FInverted , 'Inverted' );
  ParseAttr(AXmlNode, FTapes    , 'Tapes'    );
end;

constructor TunfTextCommon_Tag.Create(AeUnfiscalTag: TeUnfiscalTag);
begin
  inherited Create(AeUnfiscalTag);

  FFontNum   := nil;
  FBold      := nil;
  FBigHeight := nil;
  FBigWidth  := nil;
  FInverted  := nil;
  FTapes     := nil;
end;

function TunfTextCommon_Tag.BigHeight(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FBigHeight, 'BigHeight', AisCanDef, AusDefVal);
end;

function TunfTextCommon_Tag.BigWidth(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FBigWidth, 'BigWidth', AisCanDef, AusDefVal);
end;

function TunfTextCommon_Tag.Bold(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FBold, 'Bold', AisCanDef, AusDefVal);
end;

function TunfTextCommon_Tag.FontNum(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr;
begin
  Result := Self.GetAttr(FFontNum, 'FontNum', AisCanDef, AusDefVal);
end;

function TunfTextCommon_Tag.Inverted(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FInverted, 'Inverted', AisCanDef, AusDefVal);
end;

function TunfTextCommon_Tag.Tapes(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '1'): T_Attr;
begin
  Result := Self.GetAttr(FTapes, 'Tapes', AisCanDef, AusDefVal);
end;

destructor TunfTextCommon_Tag.Destroy;
begin
  FreeAndNil(FBold     );
  FreeAndNil(FBigWidth );
  FreeAndNil(FInverted );
  FreeAndNil(FBigHeight);
  FreeAndNil(FFontNum  );
  FreeAndNil(FTapes    );

  inherited;
end;

procedure TunfTextCommon_Tag.SetBigHeight(const AusValue: UTF8String);
begin
  SetAttr(FBigHeight, 'BigHeight', AusValue);
end;

procedure TunfTextCommon_Tag.SetBigWidth(const AusValue: UTF8String);
begin
  SetAttr(FBigWidth, 'BigWidth', AusValue);
end;

procedure TunfTextCommon_Tag.SetBold(const AusValue: UTF8String);
begin
  SetAttr(FBold, 'Bold', AusValue);
end;

procedure TunfTextCommon_Tag.SetFontNum(const AusValue: UTF8String);
begin
  SetAttr(FFontNum, 'FontNum', AusValue);
end;

procedure TunfTextCommon_Tag.SetInverted(const AusValue: UTF8String);
begin
  SetAttr(FInverted, 'Inverted', AusValue);
end;

procedure TunfTextCommon_Tag.SetTapes(const AusValue: UTF8String);
begin
  SetAttr(FTapes, 'Tapes', AusValue);
end;

{ TunfTextBlock_Tag }

constructor TunfTextBlock_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfTextBlock, AXMLnode, AParentTag);
end;

constructor TunfTextBlock_Tag.Create(const AusValue: UTF8String);
begin
  inherited Create(unfTextBlock);

  SetTagValue(AusValue);
end;

destructor TunfTextBlock_Tag.Destroy;
begin
  inherited;
end;

{ TunfTextLine_Tag }

constructor TunfTextLine_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfTextLine, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FText, 'Text');
end;

constructor TunfTextLine_Tag.Create(const AusText: UTF8String);
begin
  inherited Create(unfTextLine);

  FText := nil;

  SetText(AusText);
end;

destructor TunfTextLine_Tag.Destroy;
begin
  FreeAndNil(FText);

  inherited;
end;

procedure TunfTextLine_Tag.SetText(const AusValue: UTF8String);
begin
  SetAttr(FText, 'Text', AusValue);
end;

function TunfTextLine_Tag.Text(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FText, 'Text', AisCanDef, AusDefVal);
end;

{ TunfTextPart_Tag }

constructor TunfTextPart_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfTextPart, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FText, 'Text');
end;

constructor TunfTextPart_Tag.Create(const AusText: UTF8String);
begin
  inherited Create(unfTextPart);

  FText := nil;

  SetText(AusText);
end;

destructor TunfTextPart_Tag.Destroy;
begin
  FreeAndNil(FText);

  inherited;
end;

procedure TunfTextPart_Tag.SetText(const AusValue: UTF8String);
begin
  SetAttr(FText, 'Text', AusValue);
end;

function TunfTextPart_Tag.Text(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FText, 'Text', AisCanDef, AusDefVal);
end;

{ TunfRawBlock_Tag }

constructor TunfRawBlock_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfRawBlock, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FEncoding, 'Encoding');
end;

constructor TunfRawBlock_Tag.Create(AeRawEncoding: TeRawEncoding);
begin
  inherited Create(unfRawBlock);

  FEncoding := nil;

  SetEncoding(S_RAW_ENCODING[AeRawEncoding]);
end;

destructor TunfRawBlock_Tag.Destroy;
begin
  FreeAndNil(FEncoding);

  inherited;
end;

function TunfRawBlock_Tag.Encoding(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FEncoding, 'Encoding', AisCanDef, AusDefVal);
end;

function TunfRawBlock_Tag.GetsData: AnsiString;
begin
  if not Encoding(True).isDefault and (Encoding.rawenc = reBase64) then begin
    Result := SimpleXML.Base64ToBin(FusValue);
  end else begin
    Result := FusValue;
  end;
end;

procedure TunfRawBlock_Tag.SetEncoding(const AusValue: UTF8String);
begin
  SetAttr(FEncoding, 'Encoding', AusValue);
end;

{ TunfBarCode_Tag }

constructor TunfBarCode_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfBarCode, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FWidth          , 'Width'          );
  ParseAttr(AXmlNode, FHeight         , 'Height'         );
  ParseAttr(AXmlNode, FType           , 'Type'           );
  ParseAttr(AXmlNode, FTextPosition   , 'TextPosition'   );
  ParseAttr(AXmlNode, FCorrectionLevel, 'CorrectionLevel');
  ParseAttr(AXmlNode, FAlign          , 'Align'          );
  ParseAttr(AXmlNode, FFlowTextLines  , 'FlowTextLines'  );
  ParseAttr(AXmlNode, FValue          , 'Value'          );
end;

constructor TunfBarCode_Tag.Create(const AusValue: UTF8String);
begin
  inherited Create(unfBarCode);

  FWidth           := nil;
  FHeight          := nil;
  FType            := nil;
  FTextPosition    := nil;
  FCorrectionLevel := nil;
  FAlign           := nil;
  FFlowTextLines   := nil;
  FValue           := nil;

  SetValue(AusValue);
end;

function TunfBarCode_Tag.Width(AisCanDef: Boolean =  True; AusDefVal: UTF8String =      '2'): T_Attr;
begin
  Result := Self.GetAttr(FWidth, 'Width', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.Height(AisCanDef: Boolean =  True; AusDefVal: UTF8String =    '100'): T_Attr;
begin
  Result := Self.GetAttr(FHeight, 'Height', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag._Type(AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'EAN-13'): T_Attr;
begin
  Result := Self.GetAttr(FType, 'Type', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.TextPosition(AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'Bottom'): T_Attr;
begin
  Result := Self.GetAttr(FTextPosition, 'TextPosition', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.CorrectionLevel(AisCanDef: Boolean =  True; AusDefVal: UTF8String =    '30%'): T_Attr;
begin
  Result := Self.GetAttr(FCorrectionLevel, 'CorrectionLevel', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.Align(AisCanDef: Boolean =  True; AusDefVal: UTF8String = 'Center'): T_Attr;
begin
  Result := Self.GetAttr(FAlign, 'Align', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.FlowTextLines(AisCanDef: Boolean =  True; AusDefVal: UTF8String = '0'): T_Attr;
begin
  Result := Self.GetAttr(FFlowTextLines, 'FlowTextLines', AisCanDef, AusDefVal);
end;

function TunfBarCode_Tag.Value(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
begin
  Result := Self.GetAttr(FValue, 'Value', AisCanDef, AusDefVal);
end;

destructor TunfBarCode_Tag.Destroy;
begin
  FreeAndNil(FWidth          );
  FreeAndNil(FHeight         );
  FreeAndNil(FType           );
  FreeAndNil(FTextPosition   );
  FreeAndNil(FCorrectionLevel);
  FreeAndNil(FAlign          );
  FreeAndNil(FFlowTextLines  );
  FreeAndNil(FValue          );

  inherited;
end;

procedure TunfBarCode_Tag.SetWidth(const AusValue: UTF8String);
begin
  SetAttr(FWidth, 'Width', AusValue);
end;

procedure TunfBarCode_Tag.SetHeight(const AusValue: UTF8String);
begin
  SetAttr(FHeight, 'Height', AusValue);
end;

procedure TunfBarCode_Tag.SetType(const AusValue: UTF8String);
begin
  SetAttr(FType, 'Type', AusValue);
end;

procedure TunfBarCode_Tag.SetTextPosition(const AusValue: UTF8String);
begin
  SetAttr(FTextPosition, 'TextPosition', AusValue);
end;

procedure TunfBarCode_Tag.SetCorrectionLevel(const AusValue: UTF8String);
begin
  SetAttr(FCorrectionLevel, 'CorrectionLevel', AusValue);
end;

procedure TunfBarCode_Tag.SetAlign(const AusValue: UTF8String);
begin
  SetAttr(FAlign, 'Align', AusValue);
end;

procedure TunfBarCode_Tag.SetFlowTextLines(const AusValue: UTF8String);
begin
  SetAttr(FFlowTextLines, 'FlowTextLines', AusValue);
end;

procedure TunfBarCode_Tag.SetValue(const AusValue: UTF8String);
begin
  SetAttr(FValue, 'Value', AusValue);
end;

{ TunfBeep_Tag }

constructor TunfBeep_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfBeep, AXMLnode, AParentTag);
end;

constructor TunfBeep_Tag.Create;
begin
  inherited Create(unfBeep);
end;

destructor TunfBeep_Tag.Destroy;
begin
  inherited;
end;

{ TunfDrawer_Tag }

constructor TunfDrawer_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfDrawer, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FNumber, 'Number');
end;

constructor TunfDrawer_Tag.Create(Ai6Number: Int64);
begin
  inherited Create(unfDrawer);

  FNumber := nil;

  SetNumber(IntToStr(Ai6Number));
end;

destructor TunfDrawer_Tag.Destroy;
begin
  FreeAndNil(FNumber);

  inherited;
end;

function TunfDrawer_Tag.Number(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FNumber, 'Number', AisCanDef, AusDefVal);
end;

procedure TunfDrawer_Tag.SetNumber(const AusValue: UTF8String);
begin
  SetAttr(FNumber, 'Number', AusValue);
end;

{ TunfLogo_Tag }

constructor TunfLogo_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfLogo, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FNumber, 'Number');
end;

constructor TunfLogo_Tag.Create(Ai6Number: Int64);
begin
  inherited Create(unfLogo);

  FNumber := nil;

  SetNumber(IntToStr(Ai6Number));
end;

destructor TunfLogo_Tag.Destroy;
begin
  FreeAndNil(FNumber);

  inherited;
end;

function TunfLogo_Tag.Number(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FNumber, 'Number', AisCanDef, AusDefVal);
end;

procedure TunfLogo_Tag.SetNumber(const AusValue: UTF8String);
begin
  SetAttr(FNumber, 'Number', AusValue);
end;

{ TunfPass_Tag }

constructor TunfPass_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfPass, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FLines, 'Lines');
end;

constructor TunfPass_Tag.Create(Ai6Lines: Int64);
begin
  inherited Create(unfPass);

  FLines := nil;

  SetLines(IntToStr(Ai6Lines));
end;

destructor TunfPass_Tag.Destroy;
begin
  FreeAndNil(FLines);

  inherited;
end;

function TunfPass_Tag.Lines(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FLines, 'Lines', AisCanDef, AusDefVal);
end;

procedure TunfPass_Tag.SetLines(const AusValue: UTF8String);
begin
  SetAttr(FLines, 'Lines', AusValue);
end;

{ TunfWait_Tag }

constructor TunfWait_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfWait, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FMSecs, 'MSecs');
end;

constructor TunfWait_Tag.Create(Ai6MSecs: Int64);
begin
  inherited Create(unfWait);

  FMSecs := nil;

  SetMSecs(IntToStr(Ai6MSecs));
end;

destructor TunfWait_Tag.Destroy;
begin
  FreeAndNil(FMSecs);

  inherited;
end;

function TunfWait_Tag.MSecs(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FMSecs, 'MSecs', AisCanDef, AusDefVal);
end;

procedure TunfWait_Tag.SetMSecs(const AusValue: UTF8String);
begin
  SetAttr(FMSecs, 'MSecs', AusValue);
end;

{ TunfAddInfo_Tag }

constructor TunfAddInfo_Tag.Create(AXMLnode: IXmlNode; AParentTag: T_Tag);
begin
  inherited Create(unfAddInfo, AXMLnode, AParentTag);

  ParseAttr(AXmlNode, FName, 'Name');
  ParseAttr(AXmlNode, FData, 'Data');
end;

constructor TunfAddInfo_Tag.Create(const AusName, AusData: UTF8String);
begin
  inherited Create(unfWait);

  FName := nil;
  FData := nil;

  SetName(AusName);
  SetData(AusData);
end;

destructor TunfAddInfo_Tag.Destroy;
begin
  FreeAndNil(FName);
  FreeAndNil(FData);

  inherited;
end;

function TunfAddInfo_Tag.Name(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

function TunfAddInfo_Tag.Data(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FData, 'Data', AisCanDef, AusDefVal);
end;

procedure TunfAddInfo_Tag.SetName(const AusValue: UTF8String);
begin
  SetAttr(FName, 'Name', AusValue);
end;

procedure TunfAddInfo_Tag.SetData(const AusValue: UTF8String);
begin
  SetAttr(FData, 'Data', AusValue);
end;

{ TUnfiscal_Tag }

constructor TUnfiscal_Tag.Create(AXmlNode: IXmlNode; AParentTag: T_Tag);
var
  XmlNodeList: IXmlNodeList;
  i          : Integer;
  XmlNode    : IXmlNode;
  sNodeName  : AnsiString;
  UnfChild   : TUnfChild_Tag;
begin
  inherited;

  ParseAttr(AXmlNode, FCutAfter, 'CutAfter');
  ParseAttr(AXmlNode, FSlip    , 'Slip'    );
  ParseAttr(AXmlNode, FPosition, 'Position');

  XmlNodeList := AXmlNode.ChildNodes;
  for i := 0 to XmlNodeList.Count - 1 do begin
    XmlNode := XmlNodeList[i];
    sNodeName := XmlNode.NodeName;
         if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfTextBlock]) then UnfChild := TunfTextBlock_Tag.Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfTextLine ]) then UnfChild := TunfTextLine_Tag .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfTextPart ]) then UnfChild := TunfTextPart_Tag .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfRawBlock ]) then UnfChild := TunfRawBlock_Tag .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfBarCode  ]) then UnfChild := TunfBarCode_Tag  .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfBeep     ]) then UnfChild := TunfBeep_Tag     .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfDrawer   ]) then UnfChild := TunfDrawer_Tag   .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfLogo     ]) then UnfChild := TunfLogo_Tag     .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfPass     ]) then UnfChild := TunfPass_Tag     .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfWait     ]) then UnfChild := TunfWait_Tag     .Create(XmlNode, Self)
    else if AnsiSameStr(sNodeName, S_UNFISCAL_TAG[unfAddInfo  ]) then UnfChild := TunfAddInfo_Tag  .Create(XmlNode, Self)
    else begin
      UnfChild := nil; // skip unknown tags
    end;
    if Assigned(UnfChild) then begin
      SetLength(FarUnfChild, Length(FarUnfChild) + 1);
      FarUnfChild[High(FarUnfChild)] := UnfChild;
    end;
  end;
end;

destructor TUnfiscal_Tag.Destroy;
var
  i: Integer;
begin
  for i := Low(FarUnfChild) to High(FarUnfChild) do FreeAndNil(FarUnfChild[i]);

  FreeAndNil(FCutAfter);
  FreeAndNil(FSlip);
  FreeAndNil(FPosition);

  inherited;
end;

function TUnfiscal_Tag.CutAfter(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FCutAfter, 'CutAfter', AisCanDef, AusDefVal);
end;

function TUnfiscal_Tag.Position(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FPosition, 'Position', AisCanDef, AusDefVal);
end;

function TUnfiscal_Tag.Slip(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FSlip, 'Slip', AisCanDef, AusDefVal);
end;

constructor TUnfiscal_Tag.Create;
begin
  inherited Create('Unfiscal');

  FCutAfter := nil;
  FSlip     := nil;
  FPosition := nil;
end;

procedure TUnfiscal_Tag.SetCutAfter(const AusValue: UTF8String);
begin
  SetAttr(FCutAfter, 'CutAfter', AusValue);
end;

procedure TUnfiscal_Tag.SetPosition(const AusValue: UTF8String);
begin
  SetAttr(FPosition, 'Position', AusValue);
end;

procedure TUnfiscal_Tag.SetSlip(const AusValue: UTF8String);
begin
  SetAttr(FSlip, 'Slip', AusValue);
end;

procedure TUnfiscal_Tag.AddUnfChild(AUnfChild: TUnfChild_Tag);
begin
  AddChildTag(AUnfChild);

  SetLength(FarUnfChild, Length(FarUnfChild) + 1);
  FarUnfChild[High(FarUnfChild)] := AUnfChild;
end;

procedure TUnfiscal_Tag.CloneUnfChild(AUnfChild: TUnfChild_Tag);
var
  eUnfiscalTag: TeUnfiscalTag;
  XmlNode: IXmlNode;
  UnfChild_Tag: TUnfChild_Tag;
begin
  eUnfiscalTag := AUnfChild.eUnfiscalTag;
  XmlNode := AUnfChild.XmlNode.CloneNode;

  case eUnfiscalTag of
    unfTextBlock: UnfChild_Tag := TUnfTextBlock_Tag.Create(XmlNode, Self);
    unfTextLine : UnfChild_Tag := TUnfTextLine_Tag .Create(XmlNode, Self);
    unfTextPart : UnfChild_Tag := TUnfTextPart_Tag .Create(XmlNode, Self);
    unfRawBlock : UnfChild_Tag := TUnfRawBlock_Tag .Create(XmlNode, Self);
    unfBarCode  : UnfChild_Tag := TUnfBarCode_Tag  .Create(XmlNode, Self);
    unfBeep     : UnfChild_Tag := TUnfBeep_Tag     .Create(XmlNode, Self);
    unfDrawer   : UnfChild_Tag := TUnfDrawer_Tag   .Create(XmlNode, Self);
    unfLogo     : UnfChild_Tag := TUnfLogo_Tag     .Create(XmlNode, Self);
    unfPass     : UnfChild_Tag := TUnfPass_Tag     .Create(XmlNode, Self);
    unfWait     : UnfChild_Tag := TUnfWait_Tag     .Create(XmlNode, Self);
    unfAddInfo  : UnfChild_Tag := TUnfAddInfo_Tag  .Create(XmlNode, Self);
  else
    UnfChild_Tag := TUnfChild_Tag.Create(eUnfiscalTag, XmlNode, Self);
  end;

  AddUnfChild(UnfChild_Tag);
end;

{ TUnfiscal }

constructor TUnfiscal.Create(ApcXMLBuffer: PAnsiChar; out AusError: UTF8String);
const
  S_ROOT_NAME = 'Unfiscal';
var
  XmlDocument: IXmlDocument;
begin
  try
    XmlDocument := LoadXmlDocumentFromXML(ApcXMLBuffer);
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

  FUnfiscal := TUnfiscal_Tag.Create(XmlDocument.DocumentElement, nil);

  AusError := '';
end;

destructor TUnfiscal.Destroy;
begin
  FUnfiscal.Free;

  inherited;
end;

{ TPRINTUNFISCAL_Tag }

constructor TPRINTUNFISCAL_Tag.Create(AXmlNode: IXmlNode; AParentTag: T_Tag);
var
  XmlNodeList: IXmlNodeList;
  i          : Integer;
begin
  inherited;

  ParseAttr(AXmlNode, Fxml_lang, 'xml:lang');

  XmlNodeList := AXmlNode.ChildNodes;
  for i := 0 to XmlNodeList.Count - 1 do begin
    SetLength(FarUnfiscal, Length(FarUnfiscal) + 1);
    FarUnfiscal[High(FarUnfiscal)] := TUnfiscal_Tag.Create(XmlNodeList[i], Self);
  end;
end;

destructor TPRINTUNFISCAL_Tag.Destroy;
var
  i: Integer;
begin
  for i := Low(FarUnfiscal) to High(FarUnfiscal) do FreeAndNil(FarUnfiscal[i]);

  FreeAndNil(Fxml_lang);

  inherited;
end;

function TPRINTUNFISCAL_Tag.xml_lang(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(Fxml_lang, 'xml:lang', AisCanDef, AusDefVal);
end;

constructor TPRINTUNFISCAL_Tag.Create;
begin
  inherited Create('PRINTUNFISCAL');

  Fxml_lang := nil;
end;

procedure TPRINTUNFISCAL_Tag.Setxml_lang(const AusValue: UTF8String);
begin
  SetAttr(Fxml_lang, 'xml:lang', AusValue);
end;

procedure TPRINTUNFISCAL_Tag.AddUnfiscal(AUnfiscal: TUnfiscal_Tag);
begin
  AddChildTag(AUnfiscal);

  SetLength(FarUnfiscal, Length(FarUnfiscal) + 1);
  FarUnfiscal[High(FarUnfiscal)] := AUnfiscal;
end;

end.

