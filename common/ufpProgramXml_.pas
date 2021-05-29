unit ufpProgramXml_;

interface

uses
  SysUtils
  ,Simplexml
  ,ufpResult_
  ,uXMLcommon
  ,ufpFiscDocXml_
  ;

type
  TProgramDateTime_Tag = class(T_Tag)
  private
    FSource: T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Source(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TDepartment_Tag = class(T_Tag)
  private
    FNumber: T_Attr;
    FName  : T_Attr;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function Number(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    function Name  (AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
  end;

  TarDepartment_Tag = array of TDepartment_Tag;

  TProgramDepartments_Tag = class(T_Tag)
  private
    FDefaultDepartmentName: T_Attr;
    FarDepartment: TarDepartment_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function DefaultDepartmentName(AisCanDef: Boolean = False; AusDefVal: UTF8String = ''): T_Attr;
    property arDepartment: TarDepartment_Tag read FarDepartment;
  end;

  TProgramFR_Tag = class(T_Tag)
  private
    FProgramDateTime   : TProgramDateTime_Tag;
    FProgramDepartments: TProgramDepartments_Tag;
    FProgramDateTime_def: TProgramDateTime_Tag;
    FProgramDepartments_def: TProgramDepartments_Tag;
  private
    FarProgramTaxes    : TarTax_Tag;
  public
    constructor Create(AndTag: IXmlNode; AParentTag: T_Tag); overload;
    constructor Create(AusNodeName: UTF8String; AParentTag: T_Tag); overload;
    destructor Destroy; override;
  public
    function ProgramDateTime(AisCanDef: Boolean = False): TProgramDateTime_Tag;
    function ProgramDepartments(AisCanDef: Boolean = False): TProgramDepartments_Tag;
  public
    property arProgramTaxes: TarTax_Tag read FarProgramTaxes;
  end;

  TProgramFR = class
  private
   FProgramFR: TProgramFR_Tag;
   FndProgramFR: IXmlNode;
  public
    XmlDocument: IXmlDocument;
    constructor Create(ApcXMLDoc: PChar; out AusError: UTF8String);
    destructor Destroy; override;
  public
    property ProgramFR  : TProgramFR_Tag read FProgramFR;
    property ndProgramFR: IXmlNode       read FndProgramFR;
  end;

implementation

{ TProgramDateTime_Tag }

constructor TProgramDateTime_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FSource, 'Source');
end;

constructor TProgramDateTime_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FSource := nil;
end;

destructor TProgramDateTime_Tag.Destroy;
begin
  FSource.Free;

  inherited;
end;

function TProgramDateTime_Tag.Source(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FSource, 'Source', AisCanDef, AusDefVal);
end;

{ TDepartment_Tag }

constructor TDepartment_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
begin
  inherited;

  ParseAttr(AndTag, FNumber, 'Number');
  ParseAttr(AndTag, FName  , 'Name');
end;

constructor TDepartment_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FNumber := nil;
  FName := nil;
end;

destructor TDepartment_Tag.Destroy;
begin
  FNumber.Free;
  FName.Free;

  inherited;
end;

function TDepartment_Tag.Name(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FName, 'Name', AisCanDef, AusDefVal);
end;

function TDepartment_Tag.Number(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FNumber, 'Number', AisCanDef, AusDefVal);
end;

{ TProgramDepartments_Tag }

constructor TProgramDepartments_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  ndlt: IXmlNodeList;
  i: Integer;
begin
  inherited;

  ParseAttr(AndTag, FDefaultDepartmentName, 'DefaultDepartmentName');

  ndlt := AndTag.SelectNodes('Department');
  SetLength(FarDepartment, ndlt.Count);
  for i := Low(FarDepartment) to High(FarDepartment) do FarDepartment[i] := TDepartment_Tag.Create(ndlt[i], Self);
end;

constructor TProgramDepartments_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FDefaultDepartmentName := nil;
end;

function TProgramDepartments_Tag.DefaultDepartmentName(AisCanDef: Boolean; AusDefVal: UTF8String): T_Attr;
begin
  Result := Self.GetAttr(FDefaultDepartmentName, 'DefaultDepartmentName', AisCanDef, AusDefVal);
end;

destructor TProgramDepartments_Tag.Destroy;
var
  i: Integer;
begin
  FDefaultDepartmentName.Free;

  for i := Low(FarDepartment) to High(FarDepartment) do FarDepartment[i].Free;

  inherited;
end;

{ TProgramFR_Tag }

constructor TProgramFR_Tag.Create(AndTag: IXmlNode; AParentTag: T_Tag);
var
  nd: IXmlNode;
  ndlt: IXmlNodeList;
  i: Integer;
begin
  inherited;

  nd := AndTag.SelectSingleNode('ProgramDateTime');
  if Assigned(nd) then FProgramDateTime := TProgramDateTime_Tag.Create(nd, Self) else FProgramDateTime := nil;
  nd := AndTag.SelectSingleNode('ProgramDepartments');
  if Assigned(nd) then FProgramDepartments := TProgramDepartments_Tag.Create(nd, Self) else FProgramDepartments := nil;
  FProgramDateTime_def := TProgramDateTime_Tag.Create('ProgramDateTime', Self);
  FProgramDepartments_def := TProgramDepartments_Tag.Create('ProgramDepartments', Self);

  nd := AndTag.SelectSingleNode('ProgramTaxes');
  if Assigned(nd) then begin
    ndlt := nd.SelectNodes('Tax');
    SetLength(FarProgramTaxes, ndlt.Count);
    for i := Low(FarProgramTaxes) to High(FarProgramTaxes) do FarProgramTaxes[i] := TTax_Tag.Create(ndlt[i], Self);
  end;
end;

constructor TProgramFR_Tag.Create(AusNodeName: UTF8String; AParentTag: T_Tag);
begin
  inherited Create(AusNodeName, AParentTag);

  FProgramDateTime    := nil;
  FProgramDepartments := nil;
  FProgramDateTime_def    := TProgramDateTime_Tag.Create('ProgramDateTime', Self);
  FProgramDepartments_def := TProgramDepartments_Tag.Create('ProgramDepartments', Self);
end;

destructor TProgramFR_Tag.Destroy;
var
  i: Integer;
begin
  FProgramDateTime.Free;
  FProgramDepartments.Free;
  FProgramDateTime_def.Free;
  FProgramDepartments_def.Free;

  for i := Low(FarProgramTaxes) to High(FarProgramTaxes) do FarProgramTaxes[i].Free;
  
  inherited;
end;

function TProgramFR_Tag.ProgramDateTime(AisCanDef: Boolean): TProgramDateTime_Tag;
begin
  Result := TProgramDateTime_Tag(GetChildTag(FProgramDateTime, 'ProgramDateTime', AisCanDef, FProgramDateTime_def));
end;

function TProgramFR_Tag.ProgramDepartments(AisCanDef: Boolean): TProgramDepartments_Tag;
begin
  Result := TProgramDepartments_Tag(GetChildTag(FProgramDepartments, 'ProgramDepartments', AisCanDef, FProgramDepartments_def));
end;

{ TProgramFR }

constructor TProgramFR.Create(ApcXMLDoc: PChar; out AusError: UTF8String);
var
  nd: IXmlNode;
begin
  XmlDocument := CreateXmlDocument('', '1.0', 'utf-8');
  try
    XmlDocument.LoadXML(ApcXMLDoc);
  except
    on E: Exception do begin
      AusError := 'ProgramFR xml loading syntax error: ' + E.Message;
      Exit;
    end;
  end;
  nd := XmlDocument.DocumentElement;
  FndProgramFR := nd;

  FProgramFR := nil;
  if Assigned(nd) then begin
    FProgramFR := TProgramFR_Tag.Create(nd, nil)
  end else begin
    AusError := 'ProgramFR xml root element is absent';
    Exit;
  end;

  if not AnsiSameStr(FProgramFR.usName, 'ProgramFR') then begin
    AusError := 'ProgramFR xml root element is not ProgramFR';
    Exit;
  end;

  AusError := '';
end;

destructor TProgramFR.Destroy;
begin
  FProgramFR.Free;

  inherited;
end;

end.
