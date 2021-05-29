unit ufpDrivParamsXml;

interface

uses
  SysUtils
  ,StrUtils
  ,Simplexml
  ;

type
  TParameter = class
  private
    FsName : UTF8String;
    FsIntegerValue: UTF8String;
    FsStringValue: UTF8String;
    Fi: Int64;
    FisIntValid: Boolean;
    FisDefault: Boolean;
    function GetiDef(AiDef: Int64): Int64;
  public
    constructor CreateNewXML(AndParameter: IXmlNode);
    constructor CreateOldXML(AndParameter: IXmlNode);
    constructor Create(const AsName, AsIntegerValue, AsStringValue: UTF8String);
    function ToXML: IXmlNode;
  public
    property sName: UTF8String read FsName;
    property sIntegerValue: UTF8String read FsIntegerValue;
    property sStringValue: UTF8String read FsStringValue;
  public
    property isIntValid: Boolean read FisIntValid;
    property i: Int64 read Fi;
    property iDef[AiDef: Int64]: Int64 read GetiDef;
    property isDefault: Boolean read FisDefault;
end;

type
  TParameters = class
  private
    FarParameter: array of TParameter;
    function GetParameter(AiParameter: Integer): TParameter;
    procedure SetParameter(AiParameter: Integer; AParameter: TParameter);
    procedure FillParametersFromOldXML(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
    procedure FillParametersFromNewXML(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
  private
    FsError: AnsiString;
  public
    constructor Create(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString); overload;
    constructor Create(ApcXMLParams: PChar; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString); overload;
    destructor Destroy; override;
    function ToXML: IXmlNode;
    function ParamByName(AName:String): TParameter;
  public
    property Parameter[AiParameter: Integer]: TParameter read GetParameter write SetParameter; default;
    property sError: AnsiString read FsError;
  private
    FProtocolVersion: Integer;
  public
    property ProtocolVersion: Integer read FProtocolVersion;
  end;

function ValueInArray(const AiValue: Integer; const ConstArray: array of const): Boolean;

implementation

uses
   uCommon
  ;

function ValueInArray(const AiValue: Integer; const ConstArray: array of const): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := Low(ConstArray) to High(ConstArray) do if AiValue = ConstArray[i].VInteger then Exit;
  Result := False;
end;

{ TParameter }

constructor TParameter.Create(const AsName, AsIntegerValue, AsStringValue: UTF8String);
begin
  FisDefault := True; //Этот конструктор используется только для создания дефолтных Parameter
  FsName         := AsName        ;
  FsIntegerValue := AsIntegerValue;
  FsStringValue  := AsStringValue ;

  FisIntValid := TryStrToInt64(FsIntegerValue, Fi);
  if not FisIntValid then Fi := 0;
end;

constructor TParameter.CreateOldXML(AndParameter: IXmlNode);
begin
  FisDefault := False; //Этот конструктор используется только при парсинге XML
  FsName         := AndParameter.GetAttr('Name');
  FsIntegerValue := AndParameter.GetAttr('IntegerValue');
  FsStringValue  := AndParameter.GetAttr('StringValue');

  FisIntValid := TryStrToInt64(FsIntegerValue, Fi);
  if not FisIntValid then Fi := 0;
end;

constructor TParameter.CreateNewXML(AndParameter: IXmlNode);
begin
  FisDefault := False; //Этот конструктор используется только при парсинге XML
  FsName         := AndParameter.NodeName;
  FsIntegerValue := AndParameter.Text;
  if copy(FsIntegerValue,length(FsIntegerValue)-3,4)=#13#10#9#9 then {#91443, #89700}
    SetLength(FsIntegerValue, length(FsIntegerValue)-2);
  FsStringValue  := FsIntegerValue;

  FisIntValid := TryStrToInt64(FsIntegerValue, Fi);
  if not FisIntValid then Fi := 0;
end;

function TParameter.GetiDef(AiDef: Int64): Int64;
begin
  if FisIntValid then Result := Fi else Result := AiDef;
end;

function TParameter.ToXML: IXmlNode;
begin
  Result := CreateXmlElement('Parameter');

  if FsName <> '' then Result.SetAttr('Name', FsName);
  if FsIntegerValue <> '' then Result.SetAttr('IntegerValue', FsIntegerValue);
  if FsStringValue <> '' then Result.SetAttr('StringValue' , FsStringValue);
end;

{ TParameters }

constructor TParameters.Create(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
begin
  AsError := 'DriverParameters.Create unknown error';
  FProtocolVersion := 0;
  if AndParameters.AttrExists('ProtocolVersion') then begin
    if not TryStrToInt(AndParameters.GetAttr('ProtocolVersion'),FProtocolVersion) then begin
      FProtocolVersion := 0;
    end;
  end;

  SetLength(FarParameter, Length(AarsNames));
  if SameText(AndParameters.NodeName,'DriverParameters') then
    FillParametersFromOldXML(AndParameters, AarsNames, AarsDefVals, AarblIsInt, AsError)
  else
    FillParametersFromNewXML(AndParameters, AarsNames, AarsDefVals, AarblIsInt, AsError)
end;

constructor TParameters.Create(ApcXMLParams: PChar; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
var
  XmlDocument: IXmlDocument;
  ndDriverParameters : IXmlNode;
begin
  AsError := 'DriverParameters.Create unknown error';
  try
    XmlDocument := CreateXmlDocument;
    XmlDocument.LoadXML(ApcXMLParams);
    ndDriverParameters  := XmlDocument.DocumentElement;

    Create(ndDriverParameters, AarsNames, AarsDefVals, AarblIsInt, AsError);
  except
    on E: Exception do AsError := E.Message;  //  конструктор не должен давать исключений
  end;
end;

destructor TParameters.Destroy;
var
  i: Integer;
begin
  for i := Low(FarParameter) to High(FarParameter) do FarParameter[i].Free;

  inherited;
end;

procedure TParameters.FillParametersFromNewXML(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
var
  l1, nd: IXmlNode;
  i: Integer;
  n1,n2: integer;
begin
  for n1:=0 to AndParameters.ChildNodes.Count-1 do begin
    l1:=AndParameters.ChildNodes[n1];
    for n2:=0 to l1.ChildNodes.Count-1 do begin
      nd:=l1.ChildNodes[n2];
      for i := Low(FarParameter) to High(FarParameter) do begin
        if SameText(AarsNames[i],nd.NodeName) then begin
          SetParameter(i, TParameter.CreateNewXML(nd));
          if (i >= Low(AarblIsInt)) and (i <= High(AarblIsInt)) and AarblIsInt[i] and not FarParameter[i].isIntValid then begin
            AsError := Format('Parameter %s value %s is not integer value', [AarsNames[i], FarParameter[i].sIntegerValue]);
            Exit;
          end;
        end;
      end;
    end;
  end;
  for i := Low(FarParameter) to High(FarParameter) do begin
    if not Assigned(FarParameter[i]) then begin
      if AarblIsInt[i] then begin
        SetParameter(i, TParameter.Create(AarsNames[i], StrConstToUTF8(AarsDefVals[i]), ''));
        if not FarParameter[i].isIntValid then begin
          AsError := Format('Parameter %s default value %s is not integer value', [AarsNames[i], StrConstToUTF8(AarsDefVals[i])]);
          Exit;
        end;
      end else begin
        SetParameter(i, TParameter.Create(AarsNames[i], '', StrConstToUTF8(AarsDefVals[i])));
      end;
    end;
  end;
  AsError := '';
end;

procedure TParameters.FillParametersFromOldXML(AndParameters: IXmlNode; const AarsNames, AarsDefVals: array of AnsiString; AarblIsInt: array of Boolean; out AsError: AnsiString);
var
  nd: IXmlNode;
  i: Integer;
begin
  for i := Low(FarParameter) to High(FarParameter) do begin
    nd := IXmlNode(AndParameters.FindElement('Parameter', 'Name', AarsNames[i]));
    if Assigned(nd) then begin
      SetParameter(i, TParameter.CreateOldXML(nd));
      if (i >= Low(AarblIsInt)) and (i <= High(AarblIsInt)) and AarblIsInt[i] and not FarParameter[i].isIntValid then begin
        AsError := Format('Parameter %s value %s is not integer value', [AarsNames[i], FarParameter[i].sIntegerValue]);
        Exit;
      end;
    end else begin
      if AarblIsInt[i] then begin
        SetParameter(i, TParameter.Create(AarsNames[i], StrConstToUTF8(AarsDefVals[i]), ''));
        if not FarParameter[i].isIntValid then begin
          AsError := Format('Parameter %s default value %s is not integer value', [AarsNames[i], StrConstToUTF8(AarsDefVals[i])]);
          Exit;
        end;
      end else begin
        SetParameter(i, TParameter.Create(AarsNames[i], '', StrConstToUTF8(AarsDefVals[i])));
      end;
    end;
  end;

  AsError := '';
end;

function TParameters.GetParameter(AiParameter: Integer): TParameter;
begin
  Result := FarParameter[AiParameter];
end;

function TParameters.ParamByName(AName: String): TParameter;
var
  i: Integer;
begin
  for i := Low(FarParameter) to High(FarParameter) do
    if SameText(AName,FarParameter[i].FsName) then begin
      Result:=FarParameter[i];
      exit;
    end;
  raise exception.Create('No parameter '+AName);
end;

procedure TParameters.SetParameter(AiParameter: Integer; AParameter: TParameter);
begin
  FarParameter[AiParameter].Free;
  FarParameter[AiParameter] := AParameter;
end;

function TParameters.ToXML: IXmlNode;
var
  i: Integer;
begin
  Result := CreateXmlElement('DriverParameters');

  for i := Low(FarParameter) to High(FarParameter) do Result.AppendChild(FarParameter[i].ToXML);
end;

end.
