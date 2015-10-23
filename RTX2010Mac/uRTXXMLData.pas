//***************************************************************************
//
//       名称：uRTXXMLData.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:44:58
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uRTXXMLData;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  Xml.xmldom,
  Xml.XMLIntf,
{$IFDEF MSWINDOWS}
  Xml.Win.msxmldom,
{$ENDIF}
  Xml.XMLDoc;

type
  TRTXMsgFontAttr = record
    Name: string;
    CharSet: Integer;
    PAF: Integer;
    Size: Integer;
    YOffset: Integer;
    Effects: Integer;
    Color: Integer;
  end;

  TRTXXML = class(TObject)
  private
    FXML: TXMLDocument;
    function GetXML: string;
    procedure SetXML(const Value: string);
    function CheckString(AOle: OleVariant): string;
    function CheckLong(AOle: OleVariant): LongWord;
  public
    constructor Create; overload;
    constructor Create(AOwner: TComponent; const AXMLData: string); overload;
    destructor Destroy; override;
  public
    property XML: string read GetXML write SetXML;
  end;

  TRTXCData = class(TRTXXML)
  private
    function FindNodeByKey(const AKey: string; ACanCreate: Boolean = False): IXMLNode;
  public
    constructor Create; overload;
    procedure SetString(const AKey, AString: string);
    function GetString(const AKey: string): string;
    procedure SetLong(const AKey: string; ALong: LongWord);
    function GetLong(const AKey: string): LongWord;
    procedure SetBuffer(const AKey, ABuffer: string);
    function GetBuffer(const AKey: string): string;
  end;

  TRTXMsg = class(TRTXXML)
  private
    function GetText: string;
    procedure SetText(const Value: string);
    function GetFonts: TRTXMsgFontAttr;
    procedure SetFonts(const Value: TRTXMsgFontAttr);
    procedure SetFontNodeProperty(ANode: IXMLNode; Value: TRTXMsgFontAttr);
    procedure SetTxtNodeText(ANode: IXMLNode; const AText: string);
  public
    constructor Create(const AText: string; AFont: TRTXMsgFontAttr); overload;
    constructor Create(const AText: string); overload;
  public
    property Text: string read GetText write SetText;
    property Fonts: TRTXMsgFontAttr read GetFonts write SetFonts;
  end;

implementation

{ TRTXCData }

uses
  uDebug;



{ TRTXXML }

constructor TRTXXML.Create;
begin
  inherited Create;
  FXML := TXMLDocument.Create(nil);
  FXML.Active := True;
end;

constructor TRTXXML.Create(AOwner: TComponent; const AXMLData: string);
begin
  inherited Create;
  if AXMLData = '' then
    Exit;
  FXML := TXMLDocument.Create(AOwner);
  FXML.LoadFromXML(AXMLData);
end;

destructor TRTXXML.Destroy;
begin
  FXML.Active := False;
  FreeAndNil(FXML);
  inherited;
end;

procedure TRTXXML.SetXML(const Value: string);
begin
  if FXML.Active then
    FXML.XML.Text := Value;
end;

function TRTXXML.GetXML: string;
begin
  Result := '';
  if FXML.Active then
    Result := FXML.XML.Text;
end;

function TRTXXML.CheckLong(AOle: OleVariant): LongWord;
begin
  Result := 0;
  if AOle <> null then
    Result := LongWord(AOle);
end;

function TRTXXML.CheckString(AOle: OleVariant): string;
begin
  Result := '';
  if AOle <> null then
    Result := string(AOle);
end;


{ TRTXCData }

constructor TRTXCData.Create;
begin
  inherited Create;
  FXML.DocumentElement := FXML.CreateNode('RTXCData');
end;

function TRTXCData.FindNodeByKey(const AKey: string; ACanCreate: Boolean): IXMLNode;
var
  LRoot, LItem: IXMLNode;
begin
  Result := nil;
  LRoot := FXML.DocumentElement;
  if Assigned(LRoot) then
  begin
    LItem := LRoot.ChildNodes.First;
    while LItem <> nil do
    begin
      if SameText(CheckString(LItem.Attributes['Key']), AKey) then
        Exit(LItem);
      LItem := LItem.NextSibling;
    end;
    if ACanCreate then
    begin
      Result := LRoot.AddChild('Item');
      Result.Attributes['Key'] := AKey;
    end;
  end;
end;

procedure TRTXCData.SetString(const AKey, AString: string);
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, True);
  if Assigned(LNode) then
  begin
    LNode.Attributes['Type'] := 'String';
    LNode.NodeValue := AString;
  end;
end;

function TRTXCData.GetString(const AKey: string): string;
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, False);
  if Assigned(LNode) then
    Result := CheckString(LNode.NodeValue)
  else
    Result := '';
end;

procedure TRTXCData.SetBuffer(const AKey, ABuffer: string);
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, True);
  if Assigned(LNode) then
  begin
    LNode.Attributes['Type'] := 'Buffer';
    LNode.NodeValue := ABuffer;
  end;
end;

procedure TRTXCData.SetLong(const AKey: string; ALong: LongWord);
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, True);
  if Assigned(LNode) then
  begin
    LNode.Attributes['Type'] := 'Long';
    LNode.NodeValue := ALong;
  end;
end;

function TRTXCData.GetBuffer(const AKey: string): string;
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, False);
  if Assigned(LNode) then
    Result := CheckString(LNode.NodeValue)
  else
    Result := '';
end;

function TRTXCData.GetLong(const AKey: string): LongWord;
var
  LNode: IXMLNode;
begin
  LNode := FindNodeByKey(AKey, False);
  if Assigned(LNode) then
    Result := CheckLong(LNode.NodeValue)
  else
    Result := 0;
end;



{ TRTXMsg }

constructor TRTXMsg.Create(const AText: string; AFont: TRTXMsgFontAttr);
var
  LNode: IXMLNode;
begin
  inherited Create;
  FXML.DocumentElement := FXML.CreateNode('RTXMsg');
  LNode := FXML.ChildNodes.First;
  if Assigned(LNode) then
  begin
    LNode.Attributes['Ver'] := '1.0';
    LNode := LNode.AddChild('Content');
    if Assigned(LNode) then
    begin
      SetTxtNodeText(LNode.AddChild('Txt'), AText);
      SetFontNodeProperty(LNode.AddChild('Font'), AFont);
    end;
  end;
end;

constructor TRTXMsg.Create(const AText: string);
var
  LFonts: TRTXMsgFontAttr;
begin
  LFonts.Name := '宋体';
  LFonts.CharSet := 134;
  LFonts.PAF := 0;
  LFonts.Size := 9;
  LFonts.YOffset := 0;
  LFonts.Effects := 1073741824;
  LFonts.Color := 0;
  Create(AText, LFonts);
end;

function TRTXMsg.GetFonts: TRTXMsgFontAttr;
var
  LNode: IXMLNode;
begin
  FillChar(Result, SizeOf(TRTXMsgFontAttr), #0);
  LNode := FXML.ChildNodes.FindNode('Content');
  if Assigned(LNode) then
  begin
    LNode := LNode.ChildNodes.FindNode('Font');
    if Assigned(LNode) then
    begin
      Result.Name := CheckString(LNode.Attributes['Name']);
      Result.CharSet := CheckLong(LNode.Attributes['CharSet']);
      Result.PAF := CheckLong(LNode.Attributes['PAF']);
      Result.Size := CheckLong(LNode.Attributes['Size']);
      Result.YOffset := CheckLong(LNode.Attributes['YOffset']);
      Result.Effects := CheckLong(LNode.Attributes['Effects']);
      Result.Color := CheckLong(LNode.Attributes['Color']);
    end;
  end;
end;

function TRTXMsg.GetText: string;
var
  LNode: IXMLNode;
begin
  Result := '';
  if not Assigned(FXML.DocumentElement) then Exit;
  LNode := FXML.DocumentElement.ChildNodes.FindNode('Content');
  if Assigned(LNode) then
  begin
    LNode := LNode.ChildNodes.FindNode('Txt');
    if Assigned(LNode) then
      Result := CheckString(LNode.NodeValue);
  end;
end;

procedure TRTXMsg.SetFontNodeProperty(ANode: IXMLNode;
  Value: TRTXMsgFontAttr);
begin
  if Assigned(ANode) then
  begin
    ANode.Attributes['Name'] := Value.Name;
    ANode.Attributes['CharSet'] := Value.CharSet;
    ANode.Attributes['PAF'] := Value.PAF;
    ANode.Attributes['Size'] := Value.Size;
    ANode.Attributes['YOffset'] := Value.YOffset;
    ANode.Attributes['Effects'] := Value.Effects;
    ANode.Attributes['Color'] := Value.Color;
  end;
end;

procedure TRTXMsg.SetFonts(const Value: TRTXMsgFontAttr);
var
  LNode: IXMLNode;
begin
  if not Assigned(FXML.DocumentElement) then Exit;
  LNode := FXML.DocumentElement.ChildNodes.FindNode('Content');
  if not Assigned(LNode) then
    SetFontNodeProperty(LNode.ChildNodes.FindNode('Font'), Value);
end;

procedure TRTXMsg.SetText(const Value: string);
var
  LNode: IXMLNode;
begin
  if not Assigned(FXML.DocumentElement) then Exit;
  LNode := FXML.DocumentElement.ChildNodes.FindNode('Content');
  if Assigned(LNode) then
    SetTxtNodeText(LNode.ChildNodes.FindNode('Txt'), Value);
end;

procedure TRTXMsg.SetTxtNodeText(ANode: IXMLNode; const AText: string);
begin
  if Assigned(ANode) then
    ANode.NodeValue := AText;
end;

end.

