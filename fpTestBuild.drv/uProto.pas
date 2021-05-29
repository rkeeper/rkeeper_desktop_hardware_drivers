unit uProto;

interface

uses
  ufpBaseProto_
  ,ufpDrivParamsXml
  ,uCommon
  ,uCallbacks
  ,uLog
  ,uUnFiscXml_
  ,ufpResult_
  ,ufpInitXmlReturn_
  ,ufpStatus
  ,ufpFiscDocXml_
  ,ufpProgramXml_
  ,uDeviceCnst
;


const DEBUG_FAKE_ERROR = False;
const DEBUG_FAKE_ShiftEx24h = False;

type
  TProto = class(TBaseProto)
  public
    constructor Create(AParameters: TParameters; ACallBacks: TCallBacks; ALog: TLog; AResult: TUFRresult); override;
  public
    class function  MaxProtocolSupported: Integer; override;
    procedure DriverOptions(out AsetOptions: TsetOptions); override;
    procedure DriverMenu(AMenu: TMenu); override;
    function  DriverChangeFromTypeIndexes(AChangeFromTypeIndexes: TChangeFromTypeIndexes_tag; AResult: TUFRresult): Boolean; override;
    function  GetStatus(AfpStatus: TfpStatus; AResult: TUFRresult): Boolean; override;
    function  PrintReceipt(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean; override;
    function  PrintUnfiscal(AUnfiscal: TUnfiscal_Tag;AResult: TUFRresult): Boolean; override;
    function  PrintReport(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean; override;
    function  Programming(AProgramFR: TProgramFR_Tag; AResult: TUFRResult): Boolean; override;
    function  GetZReportData(out AZReportData: TZReportData; AResult: TUFRresult): Boolean; override;
  private
    FsetOptions: TsetOptions;
    FarMenu: array of TMenuItem_tag;
    FusDriverName: UTF8String;
    FarChangeFromTypeIndexes: array of Integer;
  private
    function fPrepareOptions(AResult: TUFRresult): Boolean;
    function fCalcReceipt(AFiscalDocument: TFiscalDocument_Tag; AResult: TUFRresult): Boolean;
    procedure fPrintLine(Aus: UTF8String);
    procedure fPrintUnfiscalLine(Aus: UTF8String);
    function fUnfiscal(AUnfiscal: TUnfiscal_Tag;AResult: TUFRresult): Boolean;
    function fReadFileInt(name: string; default: Integer=0):Integer;
    procedure fWriteFileInt(name: string; value: Integer);
    function fGetShiftState: TUFRShiftState;
    procedure fSetShiftState(value: TUFRShiftState);
    function fGetShiftNum: Integer;
    procedure fSetShiftNum(value: Integer);
    function fGetLastReceiptNum: Integer;
    procedure fSetLastReceiptNum(value: Integer);
  end;

implementation
uses
  SysUtils
  ,StrUtils
  ,Classes
  ,SimpleXML
  ,uXMLcommon
;

var
  giMaxProtocolSupported: Integer = 35;

function FindXMLend(const AsSource: AnsiString; AiPosBegXML: Integer): Integer;
const
  S_TAG_BEG = '<';
  S_TAG_END = '>';
var
  iPosBegRoot, iPosEndRoot: Integer;
  sRootTagName: AnsiString;
begin
  Result := -1;

  iPosBegRoot := PosEx(S_TAG_BEG, AsSource, AiPosBegXML + Length(S_TAG_BEG));
  if iPosBegRoot <= 0 then Exit;

  iPosBegRoot := iPosBegRoot + Length(S_TAG_BEG);

  iPosEndRoot := PosEx(' ', AsSource, iPosBegRoot);
  if iPosEndRoot <= 0 then iPosEndRoot := PosEx(S_TAG_END, AsSource, iPosBegRoot);
  if iPosEndRoot <= 0 then Exit;

  sRootTagName := Copy(AsSource, iPosBegRoot, iPosEndRoot - iPosBegRoot);

  iPosBegRoot := PosEx(sRootTagName, AsSource, iPosEndRoot);
  if iPosBegRoot <= 0 then Exit;

  iPosEndRoot := iPosBegRoot + Length(sRootTagName);

  iPosEndRoot := PosEx(S_TAG_END, AsSource, iPosEndRoot);
  if iPosEndRoot <= 0 then Exit;

  Result := iPosEndRoot + Length(S_TAG_END);
end;

function FindLatestXml(const AsSource: AnsiString; const AsXmlTag: AnsiString=''): IXMLDocument;
const
  S_BEG_XML = '<?xml';
var
  iPosBegXML, iPosEndXML: Integer;
  XML: IXMLDocument;
begin
  Result := nil;
  iPosEndXML := 1;

  while True do begin
    iPosBegXML := PosEx(S_BEG_XML, AsSource, iPosEndXML);
    if iPosBegXML <= 0 then
      Break;

    iPosEndXML := FindXMLend(AsSource, iPosBegXML);
    if iPosEndXML <= 0 then begin
      iPosEndXML := iPosBegXML + Length(S_BEG_XML);
      Continue;
    end;

    try
      XML := Simplexml.LoadXmlDocumentFromXML(Copy(AsSource, iPosBegXML, iPosEndXML - iPosBegXML));
      if (AsXmlTag = '') or Assigned(XML.SelectSingleNode(AsXmlTag)) then
        Result := XML;
    except
    end;
  end;
end;

function ReadFile(const AsFileName: AnsiString): AnsiString;
var
  fs: TFileStream;
begin
  Result := '';
  fs := TFileStream.Create(AsFileName, fmOpenRead);
  try
    SetLength(Result, fs.Size);
    if Length(Result) > 0 then
      fs.Read(Result[1], Length(Result));
  finally
    FreeAndNil(fs);
  end;
end;

function m2s(v: Int64; wf: Integer=5; wi: Integer=5): string;
var
  ii: Integer;
  isNeg: Boolean;
  i, f: Int64;
begin
  isNeg := v < 0;
  if isNeg then v := -v;

  f := 1;

  for ii := 0 to wf-1 do
    f:=f*10;

  i := v div f;
  f := v mod f;

  if isNeg then begin
    Result := Format('-%d.%.*d', [i,wf,f]);
     while Length(Result) <= wi + wf do Result := ' ' + Result;
  end else begin
    Result := Format('%*d.%.*d', [wi,i,wf,f]);
  end;
end;

function TProto.fPrepareOptions(AResult: TUFRresult): Boolean;
  function FillChangeFromTypeIndexes(AsChangeFromTypeIndexes: AnsiString; AResult: TUFRresult): Boolean;
  var
    sl: TStringList;
    i: Integer;
  begin
    Result := False;
    sl := TStringList.Create;
    try
      sl.Delimiter := ' ';
      sl.DelimitedText := AsChangeFromTypeIndexes;
      try
        SetLength(FarChangeFromTypeIndexes, sl.Count);
        for i := 0 to sl.Count-1 do
          FarChangeFromTypeIndexes[i] := StrToInt(sl.Strings[i]);
      except
        on E: EConvertError do begin
          AResult.SetValue(errAssertInvalidXMLInitializationParams, Format('Exception on ChangeFromTypeIndexes: %s', [E.Message]));
          Exit;
        end;
      end;
    finally
      FreeAndNil(sl);
    end;
    Result := True;
  end;

var
  xmlIn: IXMLDocument;
  xmlList: IXmlNodeList;
  Root: IXmlNode;
  i: Integer;
  sLogFileName: AnsiString;
  sLogFile: AnsiString;
  str: UTF8String;
  iTeOption: TeOption;
  sOptions: AnsiString;
  sl: TStringList;
begin
  Result := False;
  FsetOptions := [];
  SetLength(FarChangeFromTypeIndexes, 0);

  sLogFileName := FParameters[Integer(par_FileNameLogWithUFRInitXMLReturn)].sStringValue;
  if sLogFileName <> '' then begin
    try
      sLogFile := ReadFile(sLogFileName);
    except
      on E: Exception do begin
        AResult.SetValue(errAssertInvalidXMLInitializationParams, AnsiToUtf8(E.Message));
        Exit;
      end;
    end;

    xmlIn := FindLatestXml(sLogFile, 'UFRInitXMLReturn');
    if not Assigned(xmlIn) then begin
      AResult.SetValue(errAssertInvalidXMLInitializationParams, Format('UFRInitXMLReturn not found in file:"%s"', [sLogFileName]));
      Exit;
    end;

    Root := xmlIn.EnsureChild('UFRInitXMLReturn');
    giMaxProtocolSupported := Root.GetIntAttr('MaxProtocolSupported', giMaxProtocolSupported);
    FusDriverName := Root.GetAttr('DriverName', '');
    //Конвертируем опции
    xmlList := Root.EnsureChild('Options').SelectNodes('Option');
    for i:=0 to xmlList.Count-1 do begin
      str := xmlList[i].GetAttr('Name');
      str := LowerCase(str);
      for iTeOption := Low(TeOption) to High(TeOption) do begin
        if SameText(S_OPTION[iTeOption], str) then begin
          Include(FsetOptions, iTeOption);
          Break;
        end;
      end;
    end;

    //конвертируем меню. //TODO вложенные меню не поддержаны. только элементы первого уровня
    xmlList := Root.EnsureChild('MENU').SelectNodes('MENUITEM');
    SetLength(FarMenu, xmlList.Count);
    for i:=0 to xmlList.Count-1 do begin
      FarMenu[i] := TMenuItem_end_tag.Create(
          xmlList[i].GetAttr('caption', '')
          ,xmlList[i].GetAttr('operationId', '')
          ,xmlList[i].GetAttr('parameter', '')
          ,xmlList[i].GetAttr('purposeToLock', '')
          ,xmlList[i].GetAttr('userRight', '')
        );
    end;

    if not FillChangeFromTypeIndexes(Root.EnsureChild('ChangeFromTypeIndexes').Text, AResult) then Exit;

    Result := True;
    Exit; //если задан файл, то остальные опции игнорируются.
  end;

  sOptions := Trim(FParameters[Integer(par_Options)].sStringValue);
  if sOptions <> '' then begin
    sl := TStringList.Create;
    try
      sl.DelimitedText := sOptions;
      for i:=0 to sl.Count-1 do begin
        str := sl.Strings[i];
        if str = '' then
          Continue;
        if Pos('fo', str) = 1 then begin
          str := Copy(str, 3, MaxInt);
        end else if Pos('opt', str) = 1 then begin
          str := Copy(str, 4, MaxInt);
        end;
        for iTeOption := Low(TeOption) to High(TeOption) do begin
          if SameText(S_OPTION[iTeOption], str) then begin
            Include(FsetOptions, iTeOption);
            Break;
          end;
        end;
      end;
    finally
      sl.Free;
    end;
  end;

  if not FillChangeFromTypeIndexes(FParameters[Integer(par_ChangeFromTypeIndexes)].sStringValue, AResult) then Exit;

  Result := True;
end;

{ TProto }

constructor TProto.Create(AParameters: TParameters; ACallBacks: TCallBacks; ALog: TLog; AResult: TUFRresult);
begin
  ALog.Rotate;
  inherited Create(AParameters, ACallBacks, ALog, AResult);
  if AResult.iError <> errOk then Exit;
  AResult.SetValue(errAssertInvalidXMLInitializationParams, 'bad init');
  if not fPrepareOptions(AResult) then Exit;
  AResult.SetValue(errOk, '');
end;

procedure TProto.DriverOptions(out AsetOptions: TsetOptions);
begin
  AsetOptions := FsetOptions;
end;

procedure TProto.DriverMenu(AMenu: TMenu);
var
  i: Integer;
begin
  inherited;
  for i:=0 to High(FarMenu) do
    AMenu.AddItem(FarMenu[i]);
end;

class function TProto.MaxProtocolSupported: Integer;
begin
  Result := giMaxProtocolSupported;
end;

function TProto.GetStatus(AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  Result := False;
  if not inherited GetStatus(AfpStatus, AResult) then Exit;

  if AfpStatus.SerialNum.isNeeded then AfpStatus.SerialNum.Value := '12345';
  if AfpStatus.CashRegValue.isNeeded then AfpStatus.CashRegValue.Value := 200000000; //чтобы хватало денег для CashInOut по закрытию смены
  if AfpStatus.ShiftState.isNeeded then AfpStatus.ShiftState.Value := fGetShiftState;
  if AfpStatus.LastReceiptNum.isNeeded then AfpStatus.LastReceiptNum.Value := fGetLastReceiptNum;
  if AfpStatus.InternalDateTime.isNeeded then AfpStatus.InternalDateTime.Value := Now() + 0/SecsPerDay;

  Result := True;
end;

function TProto.PrintReceipt(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
var
  ShiftState: TUFRShiftState;
  LastReceiptNum: Integer;
  i: Integer;
  Item: TItem_Tag;
begin
  Result := False;

  ShiftState := fGetShiftState;

  if ShiftState = ssShiftOpened24hoursExceeded then begin
    AResult.SetValue(errLogic24hour, 'Shift over 24h');
    Exit;
  end else if ShiftState = ssShiftClosed then begin
    fSetShiftState(ssShiftOpened);
    fSetLastReceiptNum(0);
  end;

  LastReceiptNum := fGetLastReceiptNum;

  if not inherited  PrintReceipt(AFiscalDocument, AfpStatus, AResult) then Exit;

  fPrintLine('Receipt {');
  if Assigned(AFiscalDocument.Header.Unfiscal) then
    if not fUnfiscal(AFiscalDocument.Header.Unfiscal, AResult) then Exit;

  for i := 0 to High(AFiscalDocument.Receipt.arItem) do begin
    Item := AFiscalDocument.Receipt.arItem[i];
    if Assigned(Item.Unfiscal) then begin
      if (not Item.Unfiscal.Position.isDefault) and (Item.Unfiscal.Position.us = 'Before') then
        if not fUnfiscal(Item.Unfiscal, AResult) then Exit;
    end;

    fPrintLine(Format('f: %s: %s x %s = %s', [Item.Name.us, m2s(Item.Quantity.i,3,0), m2s(Item.PricePerOne.i,2,0), m2s(Item.Value.i,2,0)]));

    if Assigned(Item.Unfiscal) then begin
      if (Item.Unfiscal.Position.isDefault) or (Item.Unfiscal.Position.us = 'After') then
        if not fUnfiscal(Item.Unfiscal, AResult) then Exit;
    end;
  end;

  fPrintLine('} //Receipt');

  if not fCalcReceipt(AFiscalDocument, AResult) then Exit;

  if DEBUG_FAKE_ShiftEx24h then //Смена кончилась после первого чека
    fSetShiftState(ssShiftOpened24hoursExceeded);

  if DEBUG_FAKE_ERROR then begin
    AResult.SetValue(errLogicPaperOut, 'Fake Error');
    Exit;
  end;

  Inc(LastReceiptNum);
  fSetLastReceiptNum(LastReceiptNum);

  Result := True;
end;

function TProto.PrintUnfiscal(AUnfiscal: TUnfiscal_Tag; AResult: TUFRresult): Boolean;
begin
  Result := False;
  if not inherited PrintUnfiscal(AUnfiscal, AResult) then Exit;
  if not fUnfiscal(Aunfiscal, AResult) then Exit;
  Result := True;
end;

function TProto.PrintReport(AFiscalDocument: TFiscalDocument_Tag; AfpStatus: TfpStatus; AResult: TUFRresult): Boolean;
begin
  Result := False;
  if not inherited PrintReport(AFiscalDocument, AfpStatus, AResult) then Exit;
  //AResult.SetValue(errLogicPaperOut,StrConstToUTF8('Кончилась бумага')); Exit;
  if AFiscalDocument.Report.ReportType.us = 'Z' then begin
    fSetShiftState(ssShiftClosed);
    fSetShiftNum(fGetShiftNum + 1);
  end;
  Result := True;
end;

function TProto.Programming(AProgramFR: TProgramFR_Tag; AResult: TUFRResult): Boolean;
begin
  Result := False;
  if not inherited Programming(AProgramFR, AResult) then Exit;
  Result := True;
end;

function TProto.GetZReportData(out AZReportData: TZReportData; AResult: TUFRresult): Boolean;
begin
  Result := False;
  if not inherited GetZReportData(AZReportData, AResult) then Exit;
  AZReportData := TZReportData.Create('posid1', '3', '30000', '20000', '10000', '60000', '5000', '1760', '700000');
  Result := True;
end;

function TProto.DriverChangeFromTypeIndexes(AChangeFromTypeIndexes: TChangeFromTypeIndexes_tag; AResult: TUFRresult): Boolean;
var
  i: Integer;
begin
  Result := False;
  if not inherited DriverChangeFromTypeIndexes(AChangeFromTypeIndexes, AResult) then Exit;
  for i:=0 to Length(FarChangeFromTypeIndexes)-1 do
    AChangeFromTypeIndexes.Add(FarChangeFromTypeIndexes[i]);
  Result := True;
end;

//Считает различные суммы по чеку в лог
function TProto.fCalcReceipt(AFiscalDocument: TFiscalDocument_Tag; AResult: TUFRresult): Boolean;
var
  i,k: Integer;
  ItemsByValue, ItemsByPriceToPay, ItemsByPricePerOne: Int64;
  NoChange, Change: Int64;
  ItemDiscounts, ReceiptDiscounts: Int64;
  ItemDiscInfos, ReceiptDiscInfos: Int64;
  q,v,ppo,ptp, d: Int64;
begin
  Result := False;
  AResult.SetValue(errLogicError, 'unknown', 'fCalcReceipt');
  try
    ItemsByValue := 0;
    ItemsByPriceToPay :=0;
    ItemsByPricePerOne := 0;
    ItemDiscounts := 0;
    ItemDiscInfos := 0;

    for i := 0 to Length(AFiscalDocument.Receipt.arItem)-1 do begin
      ItemsByPriceToPay := ItemsByPriceToPay + AFiscalDocument.Receipt.arItem[i].Quantity.i * AFiscalDocument.Receipt.arItem[i].PriceToPay(True, '0').i;
      ItemsByPricePerOne := ItemsByPricePerOne + AFiscalDocument.Receipt.arItem[i].Quantity.i * AFiscalDocument.Receipt.arItem[i].PricePerOne(True, '0').i;
      ItemsByValue := ItemsByValue + AFiscalDocument.Receipt.arItem[i].Value.i;
      for k := 0 to Length(AFiscalDocument.Receipt.arItem[i].arDiscount)-1 do begin
        ItemDiscounts := ItemDiscounts + AFiscalDocument.Receipt.arItem[i].arDiscount[k].Value.i;
      end;
      for k := 0 to Length(AFiscalDocument.Receipt.arItem[i].arDiscInfo)-1 do begin
        ItemDiscInfos := ItemDiscInfos + AFiscalDocument.Receipt.arItem[i].arDiscInfo[k].Value.i;
      end;
    end;

    ReceiptDiscounts := 0;
    for i := 0 to Length(AFiscalDocument.Receipt.arDiscount)-1 do begin
      ReceiptDiscounts := ReceiptDiscounts + AFiscalDocument.Receipt.arDiscount[i].Value.i;
    end;

    ReceiptDiscInfos := 0;
    for i := 0 to Length(AFiscalDocument.Receipt.arDiscInfo)-1 do begin
      ReceiptDiscInfos := ReceiptDiscInfos + AFiscalDocument.Receipt.arDiscInfo[i].Value.i;
    end;

    Change := 0;
    NoChange := 0;

    for i := 0 to Length(AFiscalDocument.Receipt.arPayment)-1 do begin
      v := AFiscalDocument.Receipt.arPayment[i].Value.i;
      if v < 0 then begin
        Change := Change + v;
      end else begin
        NoChange := NoChange + v;
      end;
    end;

    FLog.Log(llALWAYS, Format('ItemsByValue             : %s', [m2s(ItemsByValue,2)]));
    FLog.Log(llALWAYS, Format('ItemsByPriceToPay        : %s', [m2s(ItemsByPriceToPay)]));
    FLog.Log(llALWAYS, Format('ItemsByPricePerOne       : %s', [m2s(ItemsByPricePerOne)]));
    FLog.Log(llALWAYS, Format('ItemsByValue(+Disc)      : %s', [m2s(ItemsByValue + ItemDiscounts + ReceiptDiscounts,2)]));
    FLog.Log(llALWAYS, Format('ItemsByPriceToPay(+Disc) : %s', [m2s(ItemsByPriceToPay + ReceiptDiscounts*1000)]));
    FLog.Log(llALWAYS, Format('ItemsByPricePerOne(+Disc): %s', [m2s(ItemsByPricePerOne + ItemDiscounts*1000 + ReceiptDiscounts*1000)]));
    FLog.Log(llALWAYS, Format('Payments                 : %s', [m2s(NoChange+Change,2)]));
    FLog.Log(llALWAYS, Format('NoChange                 : %s', [m2s(NoChange,2)]));
    FLog.Log(llALWAYS, Format('Change                   : %s', [m2s(Change,2)]));
    FLog.Log(llALWAYS, Format('Discounts                : %s', [m2s(ItemDiscounts + ReceiptDiscounts,2)]));
    FLog.Log(llALWAYS, Format('ItemDiscounts            : %s', [m2s(ItemDiscounts,2)]));
    FLog.Log(llALWAYS, Format('ReceiptDiscounts         : %s', [m2s(ReceiptDiscounts,2)]));
    FLog.Log(llALWAYS, Format('DiscInfos                : %s', [m2s(ItemDiscInfos + ReceiptDiscInfos,2)]));
    FLog.Log(llALWAYS, Format('ItemDiscInfos            : %s', [m2s(ItemDiscInfos,2)]));
    FLog.Log(llALWAYS, Format('ReceiptDiscInfos         : %s', [m2s(ReceiptDiscInfos,2)]));


    for i := 0 to Length(AFiscalDocument.Receipt.arItem)-1 do begin
      v := AFiscalDocument.Receipt.arItem[i].Value.i;
      q := AFiscalDocument.Receipt.arItem[i].Quantity.i;
      ppo := AFiscalDocument.Receipt.arItem[i].PricePerOne(True, '0').i;
      ptp := AFiscalDocument.Receipt.arItem[i].PriceToPay(True, '0').i;
      d := 0;
      for k := 0 to Length(AFiscalDocument.Receipt.arItem[i].arDiscount)-1 do begin
        d := d + AFiscalDocument.Receipt.arItem[i].arDiscount[k].Value.i;
      end;

      FLog.Log(llALWAYS, Format('Item %2d V: %s D: %s Q: %s PpO: %s PtP: %s Q*PpO: %s Q*PtP: %s V+D: %s dPpO: %s dPtp: %s N: %s', [
        i+1, m2s(v,2), m2s(d,2)
        ,m2s(q,3, 4), m2s(ppo,2), m2s(ptp,2), m2s(q * ppo), m2s(q * ptp), m2s((v+d),2), m2s(v*1000 - q * ppo), m2s((v+d)*1000 - q * ptp)
        ,AFiscalDocument.Receipt.arItem[i].Name.us
      ]));
    end;

  except
    on E: Exception do begin
      AResult.SetValue(errInternalException, E.Message);
      Exit;
    end;
  end;

  AResult.SetValue(errOk, '');
  Result := True;
end;

procedure TProto.fPrintLine(Aus: UTF8String);
begin
  FLog.Log(llALWAYS, Aus);
end;

procedure TProto.fPrintUnfiscalLine(Aus: UTF8String);
begin
  fPrintLine(Format('u: %s', [Aus]));
end;

function TProto.fUnfiscal(AUnfiscal: TUnfiscal_Tag;AResult: TUFRresult): Boolean;
var
  i: Integer;
  UnfChild: TUnfChild_Tag;
  usAcc: UTF8String;
begin
  //Result := False;
  usAcc := '';
  for i:=0 to High(AUnfiscal.arUnfChild) do begin
    UnfChild :=AUnfiscal.arUnfChild[i];
    case UnfChild.eUnfiscalTag of
      unfTextBlock: begin usAcc := usAcc + (UnfChild as TunfTextBlock_Tag).usValue; fPrintUnfiscalLine(usAcc); usAcc:=''; end;
      unfTextLine : begin usAcc := usAcc + (UnfChild as TunfTextLine_Tag).Text.us; fPrintUnfiscalLine(usAcc); usAcc:=''; end;
      unfTextPart : usAcc := usAcc + (UnfChild as TunfTextPart_Tag).Text.us;
      unfRawBlock : usAcc := usAcc + CodePageToUTF8(866,  (UnfChild as TunfRawBlock_Tag).sData);
      unfAddInfo  : usAcc := usAcc + (UnfChild as TunfAddInfo_Tag).Name(True, '').us + '=' + (UnfChild as TunfAddInfo_Tag).Data(True, '').us;
    end;
  end;
  if usAcc <> '' then fPrintUnfiscalLine(usAcc);
  Result := True;
end;

function TProto.fReadFileInt(name: string; default: Integer): Integer;
var
  sl: TStringList;
begin
  Result := default;
  sl := TStringList.Create;
  try
    try
      sl.LoadFromFile(name);
    except
      Exit;
    end;
    if sl.Count > 0 then
      Result := StrToIntDef(sl[0], Result);
  finally
    sl.Free;
  end;
end;

procedure TProto.fWriteFileInt(name: string; value: Integer);
var
  sl: TStringList;
begin
  sl:=TStringList.Create;
  try
    sl.Add(IntToStr(value));
    sl.SaveToFile(name);
  finally
    sl.Free;
  end;
end;


const ShiftStateFileName     = 'fpTestBuildSS.txt';
const ShiftNumFileName       = 'fpTestBuildSN.txt';
const LastReceiptNumFileName = 'fpTestBuildLR.txt';

function TProto.fGetShiftState: TUFRShiftState;
begin
  Result := TUFRShiftState(fReadFileInt(ShiftStateFileName, Integer(ssShiftOpened))); //открытая смена блокирует программирование
end;

procedure TProto.fSetShiftState(value: TUFRShiftState);
begin
  fWriteFileInt(ShiftStateFileName, Integer(value));
end;

function TProto.fGetLastReceiptNum: Integer;
begin
  Result := 0;
  if fGetShiftState <> ssShiftOpened then Exit;
  Result := fReadFileInt(LastReceiptNumFileName, 0);
end;

procedure TProto.fSetLastReceiptNum(value: Integer);
begin
  fWriteFileInt(LastReceiptNumFileName, value);
end;

function TProto.fGetShiftNum: Integer;
begin
  Result := fReadFileInt(ShiftNumFileName, 1);
end;

procedure TProto.fSetShiftNum(value: Integer);
begin
  fWriteFileInt(ShiftNumFileName, value)
end;

end.
