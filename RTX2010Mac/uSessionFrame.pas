unit uSessionFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.ListBox,
  FMX.Colors, FMX.Edit, FMX.ComboEdit, FMX.ComboTrackBar, uRTXMessageView,
  FMX.Objects, uRTXNetModule, uRTXXMLData, System.Math.Vectors, FMX.Controls3D,
  FMX.Layers3D, FMX.ListView.Types, FMX.ListView;

type
  Tfra_Session = class(TFrame)
    lyt_SendContent: TLayout;
    lyt_Top: TLayout;
    lyt6: TLayout;
    btn_Send: TButton;
    mmo_Msg: TMemo;
    tlb1: TToolBar;
    lyt4: TLayout;
    lyt_MessageView: TLayout;
    cbb_Fonts: TComboBox;
    cbb_FontColor: TComboColorBox;
    btn_Style_B: TSpeedButton;
    btn_Style_I: TSpeedButton;
    btn_Style_U: TSpeedButton;
    cbb_FontSize: TComboTrackBar;
    Rectangle1: TRectangle;
    btn_Expression: TSpeedButton;
    btn_AddImage: TSpeedButton;
    btn_AddFile: TSpeedButton;
    lyt_MsgContent: TLayout;
    lyt_Content: TLayout;
    lyt_GroupsContent: TLayout;
    spl_Group: TSplitter;
    lyt1: TLayout;
    lv_Group: TListView;
    lyt2: TLayout;
    spl1: TSplitter;
    Line1: TLine;
    procedure cbb_FontColorChange(Sender: TObject);
    procedure btn_Style_BClick(Sender: TObject);
    procedure btn_Style_IClick(Sender: TObject);
    procedure btn_Style_UClick(Sender: TObject);
    procedure cbb_FontSizeChangeTracking(Sender: TObject);
    procedure btn_SendClick(Sender: TObject);
    procedure mmo_MsgKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    FMsgView: TRTXMessageView;
    procedure Test;
    procedure TestAddItem;
    procedure InitFrame;
    procedure ShowGroupContext(AShow: Boolean);
    function GetFontAttr: TRTXMsgFontAttr;
  public
    procedure SendMsg;
  end;

  /// <summary>
  ///   新建一个session
  /// </summary>
  function CreateSessionFrame(AOwner: TComponent; AParent: TFmxObject; AIsGroup: Boolean = False): Tfra_Session;
implementation

{$R *.fmx}

uses udm_Common;

function CreateSessionFrame(AOwner: TComponent; AParent: TFmxObject; AIsGroup: Boolean): Tfra_Session;
begin
  Result := Tfra_Session.Create(AOwner);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.Client;
  Result.ShowGroupContext(AIsGroup);
  Result.InitFrame;
end;

procedure Tfra_Session.btn_SendClick(Sender: TObject);
begin
  if mmo_Msg.Text.IsEmpty then
  begin
    ShowMessage('消息都没有，发毛线啊发！');
    Exit;
  end;
  TestAddItem;
  dm_RTXNetModule.RTX.SendIMMessage('', mmo_Msg.Text, GetFontAttr);
  mmo_Msg.Text := '';
end;

procedure Tfra_Session.btn_Style_BClick(Sender: TObject);
begin
  if not btn_Style_B.IsPressed then
    mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style - [TFontStyle.fsBold]
  else mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style + [TFontStyle.fsBold];
end;

procedure Tfra_Session.btn_Style_IClick(Sender: TObject);
begin
  if not btn_Style_I.IsPressed then
    mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style - [TFontStyle.fsItalic]
  else mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style + [TFontStyle.fsItalic];
end;

procedure Tfra_Session.btn_Style_UClick(Sender: TObject);
begin
  if not btn_Style_U.IsPressed then
    mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style - [TFontStyle.fsUnderline]
  else mmo_Msg.TextSettings.Font.Style := mmo_Msg.TextSettings.Font.Style + [TFontStyle.fsUnderline];
end;

procedure Tfra_Session.cbb_FontColorChange(Sender: TObject);
begin
  mmo_Msg.TextSettings.FontColor := cbb_FontColor.Color;
end;

procedure Tfra_Session.cbb_FontSizeChangeTracking(Sender: TObject);
begin
  mmo_Msg.TextSettings.Font.Size := cbb_FontSize.Value;
end;

function Tfra_Session.GetFontAttr: TRTXMsgFontAttr;
begin
  Result.Name := mmo_Msg.Font.Family;
  Result.CharSet := 134;
  Result.PAF := 0;
  Result.Size := Trunc(mmo_Msg.Font.Size);
  Result.YOffset := 0;
  Result.Effects := 1073741824;
  Result.Color := TAlphaColorRec.ColorToRGB(mmo_Msg.FontColor);
end;

procedure Tfra_Session.InitFrame;
begin
  FMsgView := TRTXMessageView.Create(Self);
  FMsgView.Parent := lyt_MessageView;
  FMsgView.Align := TAlignLayout.Client;
  Test;
end;


procedure Tfra_Session.mmo_MsgKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
//  if Key = vkReturn then
//  begin
//    SendMsg;
//    Key := 0;
//    KeyChar := #0;
//  end;
end;

procedure Tfra_Session.SendMsg;
begin
  btn_Send.OnClick(btn_Send);
end;

procedure Tfra_Session.ShowGroupContext(AShow: Boolean);
begin
  lyt_GroupsContent.Visible := AShow;
  spl_Group.Visible := AShow;
end;

procedure Tfra_Session.Test;
var
  Litem :TRTXMessageItem;
begin
  Litem := FMsgView.Add;
  Litem.UserName := 'ying32';
  Litem.CTime := Now;
  Litem.Text := '哈哈哈哈哈test';

  Litem := FMsgView.Add;
  Litem.UserName := 'ying33';
  Litem.CTime := Now;
  LItem.IsMe := False;
  Litem.Text := '我去了';
end;

procedure Tfra_Session.TestAddItem;
var
  Litem :TRTXMessageItem;
begin
  Litem := FMsgView.Add;
  Litem.UserName := 'ying32';
  Litem.CTime := Now;
  Litem.Text := mmo_Msg.Text;
  Litem.FontColor := mmo_Msg.FontColor;
  Litem.FontSize := Trunc(mmo_Msg.Font.Size);
  Litem.FontName := mmo_Msg.Font.Family;
  Litem.FontStyle := mmo_Msg.Font.Style;
end;

end.
