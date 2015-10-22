unit uSessionFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.ListBox,
  FMX.Colors, FMX.Edit, FMX.ComboEdit, FMX.ComboTrackBar, uRTXMessageView,
  FMX.Objects;

type
  Tfra_Session = class(TFrame)
    lyt1: TLayout;
    lyt2: TLayout;
    lyt3: TLayout;
    btn_Send: TButton;
    mmo_Msg: TMemo;
    tlb1: TToolBar;
    spl1: TSplitter;
    lyt4: TLayout;
    lyt_MessageView: TLayout;
    cbb_Fonts: TComboBox;
    cbb_FontColor: TComboColorBox;
    btn_Style_B: TSpeedButton;
    btn_Style_I: TSpeedButton;
    btn_Style_U: TSpeedButton;
    cbb_FontSize: TComboTrackBar;
    Rectangle1: TRectangle;
    procedure cbb_FontColorChange(Sender: TObject);
    procedure btn_Style_BClick(Sender: TObject);
    procedure btn_Style_IClick(Sender: TObject);
    procedure btn_Style_UClick(Sender: TObject);
    procedure cbb_FontSizeChangeTracking(Sender: TObject);
    procedure btn_SendClick(Sender: TObject);
    procedure FrameKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    FMsgView: TRTXMessageView;
    procedure Test;
    procedure TestAddItem;
    procedure InitFrame;
  public
    { Public declarations }
  end;

  /// <summary>
  ///   新建一个session
  /// </summary>
  function CreateSessionFrame(AOwner: TComponent; AParent: TFmxObject): Tfra_Session;
implementation

{$R *.fmx}

function CreateSessionFrame(AOwner: TComponent; AParent: TFmxObject): Tfra_Session;
begin
  Result := Tfra_Session.Create(AOwner);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.Client;
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

procedure Tfra_Session.FrameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    btn_Send.OnClick(btn_Send);
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure Tfra_Session.InitFrame;
begin
  FMsgView := TRTXMessageView.Create(Self);
  FMsgView.Parent := lyt_MessageView;
  FMsgView.Align := TAlignLayout.Client;
  Test;
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
