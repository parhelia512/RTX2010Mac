//***************************************************************************
//
//       名称：ufrmLogin.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:43:42
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit ufrmLogin;

{$I 'RTX.inc'}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  uConfigFile;

type
  Tfrm_Login = class(TForm)
    lyt_Login: TLayout;
    edt_User: TEdit;
    ClearEditButton1: TClearEditButton;
    edt_Pwd: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    btn_Login: TButton;
    chk_Remember: TCheckBox;
    chk_AutoLogin: TCheckBox;
    img1: TImage;
    lyt_Logging: TLayout;
    btn_Cancel: TButton;
    AniIndicator1: TAniIndicator;
    lbl3: TLabel;
    btn_Setting: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_LoginClick(Sender: TObject);
    procedure chk_AutoLoginChange(Sender: TObject);
    procedure chk_RememberChange(Sender: TObject);
    procedure btn_CancelClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn_SettingClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    FConf: TRTXConfig;
    procedure ShowLogging;
    procedure HideLogging;
    procedure SetRTXEvent(ASetNil: Boolean = False);
    procedure OnRTXError(Sender: TObject; const AError: string; ACode: Integer);
    procedure OnRTXLoginResult(Sender: TObject; AStatus: Integer);
  public
    { Public declarations }
  end;

var
  frm_Login: Tfrm_Login;

implementation

{$R *.fmx}

uses uGlobalDef, uUDPModule, uDebug, ufrmSetting;

//procedure Waiting(ms: Cardinal);
//begin
//  while ms > 0 do
//  begin
//    TThread.Sleep(1);
//    Dec(ms);
//  end;
//end;

procedure Tfrm_Login.btn_CancelClick(Sender: TObject);
begin
  HideLogging;
  SetRTXEvent(True);
  dm_UDP.CancelLogin;
end;

procedure Tfrm_Login.btn_LoginClick(Sender: TObject);
begin
  if edt_User.Text = '' then
  begin
    ShowMessage('帐号都不输入的么！');
    edt_User.SetFocus;
    Exit;
  end;  
  if edt_Pwd.Text = '' then
  begin
    ShowMessage('密码呢，密码都没有叫我怎么登录啊！');
    edt_Pwd.SetFocus;
    Exit;
  end;  
  ShowLogging;
  SetRTXEvent;
  dm_UDP.LoginRTX(edt_User.Text, edt_Pwd.Text);
end;

procedure Tfrm_Login.btn_SettingClick(Sender: TObject);
begin
  frm_Setting.ShowModal;
end;

procedure Tfrm_Login.chk_AutoLoginChange(Sender: TObject);
begin
  if chk_AutoLogin.IsChecked then
    chk_Remember.IsChecked := True;
end;

procedure Tfrm_Login.chk_RememberChange(Sender: TObject);
begin
  if not chk_Remember.IsChecked then
    chk_AutoLogin.IsChecked := False;
end;

procedure Tfrm_Login.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DBG('Tfrm_Login执行关闭！');
{$IFNDEF LoginFormAMain}
  if not gIsLogin then
    Application.Terminate;
{$ENDIF}
end;

procedure Tfrm_Login.FormCreate(Sender: TObject);
begin
  DBG('Tfrm_Login.FormCreate');
  lyt_Logging.Visible := False;

  FConf := TRTXConfig.Create;
  edt_User.Text := FConf.UserName;
  edt_Pwd.Text := FConf.Password;
  chk_AutoLogin.IsChecked := FConf.AutoLogin;
  chk_Remember.IsChecked := FConf.Remember;
  if chk_AutoLogin.IsChecked then
  begin
    ShowLogging;
    dm_UDP.LoginRTX(FConf.UserName, FConf.Password);
  end;
{$IFDEF ShowLoginForm}
  ShowModal;
{$ENDIF}
end;

procedure Tfrm_Login.FormDestroy(Sender: TObject);
begin
  FConf.Free;
end;

procedure Tfrm_Login.FormHide(Sender: TObject);
begin
  SetRTXEvent(True);
end;

procedure Tfrm_Login.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    if lyt_Login.Visible then
      btn_Login.OnClick(btn_Login)
    else if lyt_Logging.Visible then
      btn_Cancel.OnClick(btn_Cancel);
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure Tfrm_Login.HideLogging;
begin
  AniIndicator1.Enabled := False;
  lyt_Logging.Visible := False;
  lyt_Login.Visible := True;
end;

procedure Tfrm_Login.OnRTXError(Sender: TObject; const AError: string;
  ACode: Integer);
begin
  HideLogging;
  ShowMessage(AError);
end;

procedure Tfrm_Login.OnRTXLoginResult(Sender: TObject; AStatus: Integer);
begin
  if gIsLogin then
  begin
    DBG('Tfrm_Login.OnRTXLoginResult gIsLogin=OK');
    FConf.AutoLogin := chk_AutoLogin.IsChecked;
    FConf.Remember := chk_Remember.IsChecked;
    if not FConf.Remember then
    begin
      FConf.UserName := '';
      FConf.Password := '';
    end else
    begin
      FConf.UserName := edt_User.Text;
      FConf.Password := edt_Pwd.Text;
    end;    
  {$IFNDEF LoginFormAMain}
    DBG('执行关闭！');
    Close;
  {$ELSE}
    Hide;
  {$ENDIF}
  end;
end;

procedure Tfrm_Login.SetRTXEvent(ASetNil: Boolean);
begin
  if Assigned(dm_UDP) then
  begin
    if ASetNil then
    begin
      dm_UDP.RTXOnLoginFormError := nil;
      dm_UDP.RTXOnLoginFormResult := nil;
    end else
    begin
      dm_UDP.RTXOnLoginFormError := OnRTXError;
      dm_UDP.RTXOnLoginFormResult := OnRTXLoginResult;
    end;
  end;
end;

procedure Tfrm_Login.ShowLogging;
begin
  lyt_Login.Visible := False;
  AniIndicator1.Enabled := True;
  lyt_Logging.Visible := True;
end;

end.
