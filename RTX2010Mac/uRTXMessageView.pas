unit uRTXMessageView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, System.Math, System.Generics.Collections;

type
  TRTXMessageItem = class(TLayout)
  private const
    MLEN = 12;
  private
    FLayoutContent: TLayout;
    FCRectangle: TCalloutRectangle;
    FUsrText: TText;
    FContent: TLayout;
    FTime: TText;
    FContentText: TText;
    FIsMe: Boolean;
    FText: string;
    FUserName: string;

    // 这里先用这个蛋疼的方式代替下，以后再弄吧
    FXX: TText;

    FCTime: TDateTime;
    FNickName: string;
    FFontSize: Integer;
    FFontName: string;
    FFontColor: TAlphaColor;
    FFontStyles: TFontStyles;
    procedure SetIsMe(const Value: Boolean);
    procedure SetText(const Value: string);
    procedure AdjustSize;

    function GetTextSize2(AControl: TText): TSizeF;

    procedure SetUserName(const Value: string);
    procedure SetCTime(const Value: TDateTime);
    procedure SetNickName(const Value: string);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetFontName(const Value: string);
    procedure SetFontSize(const Value: Integer);
    procedure SetFontStyles(const Value: TFontStyles);
  protected
    procedure Resize;override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property UserName: string read FUserName write SetUserName;
    property NickName: string read FNickName write SetNickName;
    property CTime: TDateTime read FCTime write SetCTime;
    property IsMe: Boolean read FIsMe write SetIsMe;
    property Text: string read FText write SetText;
    property FontColor: TAlphaColor read FFontColor write SetFontColor;
    property FontSize: Integer read FFontSize write SetFontSize;
    property FontName: string read FFontName write SetFontName;
    property FontStyle: TFontStyles read FFontStyles write SetFontStyles;
  end;

//  TRTXMessageItems = class(TPersistent)
//  public type
//    TRTXItemsList = TObjectList<TRTXMessageItem>;
//  private
//    FItems: TRTXItemsList;
//  public
//    constructor Create(AOwner: TComponent); override;
//  end;

   TRTXMessageView = class(TVertScrollBox)
   private
     FItems: TObjectList<TRTXMessageItem>;
     function GetMsgCount: Integer;
     procedure RealignMsgItems;
   protected
     procedure Resize; override;
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;
     procedure Clear;
     function Add: TRTXMessageItem;
   public
     property MsgCount: Integer read GetMsgCount;
   end;

implementation


{ TRTXMessageItem }

constructor TRTXMessageItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FXX := TText.Create(Self);
  FXX.Parent := Self;
  FXX.Visible := False;

  FLayoutContent := TLayout.Create(Self);
  FLayoutContent.Parent := Self;
  FLayoutContent.Align := TAlignLayout.Right;

  FUsrText := TText.Create(FLayoutContent);
  FUsrText.Parent := FLayoutContent;
  FUsrText.Align := TAlignLayout.Top;
  FUsrText.Height := 20;
  FUsrText.TextSettings.FontColor := $FF646363;
  FUsrText.Margins.Right := MLEN;
  FUsrText.TextSettings.WordWrap := False;

  FTime := TText.Create(FLayoutContent);
  FTime.Parent := FLayoutContent;
  FTime.Align := TAlignLayout.Top;
  FTime.HitTest := False;
  FTime.Height := 18;
  FTime.TextSettings.FontColor := $FF646363;
  FTime.TextSettings.WordWrap := False;
  FTime.TextSettings.Font.Size := 10;


  FCRectangle := TCalloutRectangle.Create(FLayoutContent);
  FCRectangle.Parent := FLayoutContent;
  FCRectangle.Stroke.Kind := TBrushKind.None;
  FCRectangle.HitTest := False;
  FCRectangle.XRadius := 5;
  FCRectangle.YRadius := 5;

  FContent := TLayout.Create(FCRectangle);
  FContent.Parent := FCRectangle;
  FContent.Align := TAlignLayout.Client;

  FContentText := TText.Create(FContent);
  FContentText.HitTest := False;
  FContentText.Parent := FContent;
  FContentText.AutoSize := False;
  FContentText.Align := TAlignLayout.Client;
  FContentText.TextSettings.WordWrap := True;
  FContentText.TextSettings.Trimming := TTextTrimming.Character;
  FContentText.TextSettings.HorzAlign := TTextAlign.Leading;
  FContentText.Margins.Left := 4;
  Width := 150;
  IsMe := True;
end;

destructor TRTXMessageItem.Destroy;
begin
  inherited;
end;

function TRTXMessageItem.GetTextSize2(AControl: TText): TSizeF;
begin
  Result.cx := 0;
  Result.cy := 0;
  if Assigned(FXX) then
  begin
    FXX.Font.Assign(AControl.Font);
    FXX.TextSettings.Assign(AControl.TextSettings);
    FXX.AutoSize := True;
    FXX.Text := AControl.Text;
    FXX.Width := Self.Width - MLEN;
    Result.cx := FXX.Width;
    Result.cy := FXX.Height;
  end;
end;

procedure TRTXMessageItem.AdjustSize;
var
  S, S2: TSizeF;
  LW, LW2: Single;
begin
  if Assigned(FLayoutContent) and
     Assigned(FContentText) and
     Assigned(FTime) and
     Assigned(FUsrText) then
  begin
    S := GetTextSize2(FContentText); //GetTextSize;
    S2 := GetTextSize2(FUsrText); // GetUserNameSize;

    LW := S.cx + MLEN;
    LW2 := S2.cx + MLEN;

    Self.Height := S.cy + IfThen(FIsMe, 0, FTime.Height + FUsrText.Height) + 20;
    if LW2 > LW then
    begin
      FCRectangle.Width := LW2 + 15;
      FLayoutContent.Width := LW2;
    end else
    begin
      FCRectangle.Width := LW + 15;
      if LW >= Self.Width - MLEN then
        FCRectangle.Width := LW - 20;
      FLayoutContent.Width := LW;
    end;
  end;
end;

procedure TRTXMessageItem.Resize;
begin
  inherited;
  AdjustSize;
end;

procedure TRTXMessageItem.SetCTime(const Value: TDateTime);
begin
  if FCTime <> Value then
  begin
    FCTime := Value;
    FTime.Text := FormatDateTime('hh:mm:ss', Value);
  end;
end;

procedure TRTXMessageItem.SetFontColor(const Value: TAlphaColor);
begin
  if FFontColor <> Value then
  begin
    FFontColor := Value;
    FContentText.TextSettings.FontColor := FFontColor;
  end;
end;

procedure TRTXMessageItem.SetFontName(const Value: string);
begin
  if FFontName <> Value then
  begin
    FFontName := Value;
    FContentText.TextSettings.Font.Family := Value;
    AdjustSize;
  end;
end;

procedure TRTXMessageItem.SetFontSize(const Value: Integer);
begin
  if FFontSize <> Value then
  begin
    FFontSize := Value;
    FContentText.TextSettings.Font.Size := Value;
    AdjustSize;
  end;
end;

procedure TRTXMessageItem.SetFontStyles(const Value: TFontStyles);
begin
  if FFontStyles <> Value then
  begin
    FFontStyles := Value;
    FContentText.TextSettings.Font.Style := FFontStyles;
  end;
end;

procedure TRTXMessageItem.SetIsMe(const Value: Boolean);
begin
  if FIsMe <> Value then
  begin
    FIsMe := Value;
    FCRectangle.CalloutLength := MLEN;
    FCRectangle.CalloutOffset := MLEN;
    FCRectangle.CalloutWidth := MLEN;
    if FIsMe then
    begin
      FTime.Visible := False;
      FUsrText.Visible := False;

      FLayoutContent.Align := TAlignLayout.Right;
      FUsrText.Margins.Right := MLEN + 15;
      FUsrText.Margins.Left := 0;
      FUsrText.TextSettings.HorzAlign := TTextAlign.Trailing;
      FTime.Margins.Right := MLEN + 15;
      FTime.Margins.Left := 0;
      FTime.TextSettings.HorzAlign := TTextAlign.Trailing;

      FCRectangle.Fill.Color := $FFB5DDF7;
      FCRectangle.CalloutPosition := TCalloutPosition.Right;
      FContent.Margins.Left := 0;
      FContent.Margins.Right := MLEN;
      FCRectangle.Align := TAlignLayout.Right;
      FCRectangle.Margins.Left := 5;
      FCRectangle.Margins.Right := 15;
    end else
    begin
      FTime.Visible := True;
      FUsrText.Visible := True;

      FLayoutContent.Align := TAlignLayout.Left;
      FUsrText.Margins.Right := 0;
      FUsrText.Margins.Left := MLEN;
      FUsrText.TextSettings.HorzAlign := TTextAlign.Leading;

      FTime.Margins.Right := 0;
      FTime.Margins.Left := MLEN;
      FTime.TextSettings.HorzAlign := TTextAlign.Leading;

      FCRectangle.Fill.Color := $FFE3E7EE;
      FCRectangle.CalloutPosition := TCalloutPosition.Left;
      FContent.Margins.Left := MLEN;
      FContent.Margins.Right := 0;
      FCRectangle.Align := TAlignLayout.Left;
      FCRectangle.Margins.Left := 5;
      FCRectangle.Margins.Right := 15;
    end;
  end;
end;

procedure TRTXMessageItem.SetNickName(const Value: string);
begin
  if FNickName <> Value then
  begin
    FNickName := Value;
    if FNickName = '' then
      FUsrText.Text := FUserName
    else
      FUsrText.Text := Format('%s(%s)', [FUserName, FNickName]);
  end;
end;

procedure TRTXMessageItem.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    FContentText.Text := FText;
    AdjustSize;
  end;
end;

procedure TRTXMessageItem.SetUserName(const Value: string);
begin
  if FUserName <> Value then
  begin
    FUserName := Value;
    if FNickName = '' then
      FUsrText.Text := FUserName
    else
      FUsrText.Text := Format('%s(%s)', [FUserName, FNickName]);
  end;
end;

{ TRTXMessageView }


function TRTXMessageView.Add: TRTXMessageItem;
begin
  Result := TRTXMessageItem.Create(Self);
  Result.Parent := Self;
  FItems.Add(Result);
  RealignMsgItems;
end;

procedure TRTXMessageView.Clear;
begin
  FItems.Clear;
  RealignMsgItems;
end;

constructor TRTXMessageView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TObjectList<TRTXMessageItem>.Create;
end;

destructor TRTXMessageView.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TRTXMessageView.GetMsgCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TRTXMessageView.RealignMsgItems;
var
  LTop: Single;
  I: Integer;
begin
  LTop := 0;
  Self.BeginUpdate;
  try
    for I := 0 to FItems.Count - 1 do
    begin
      FItems[I].Width := Self.Width;
      FItems[I].Position.X := 0;
      FItems[I].Position.Y := LTop;
      LTop := LTop + FItems[I].Height + 3;
    end;
  finally
    Self.EndUpdate;
  end;
  ViewportPosition := PointF(0, LTop);
  Self.Repaint;
end;

procedure TRTXMessageView.Resize;
begin
  inherited;
  RealignMsgItems;
end;

end.
