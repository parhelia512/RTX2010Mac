//***************************************************************************
//
//       名称：uMain.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:43:53
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TreeView, FMX.Layouts, FMX.Edit, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation, FMX.Menus, System.Actions, FMX.ActnList,
  FMX.ScrollBox, FMX.Memo;

type
  Tfrm_Main = class(TForm)
    mm_Main: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem3: TMenuItem;
    actlst1: TActionList;
    act_About: TAction;
    act_ExitApp: TAction;
    act_Setting: TAction;
    lyt_ControlBar: TLayout;
    lyt_Session: TLayout;
    lyt3: TLayout;
    mmo1: TMemo;
    tlb1: TToolBar;
    mmo2: TMemo;
    pnl1: TPanel;
    pnl2: TPanel;
    btn_Send: TButton;
    procedure act_ExitAppExecute(Sender: TObject);
    procedure act_AboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure act_SettingExecute(Sender: TObject);
  private
    procedure OnRTXIMMessage(Sender: TObject; const AFrom, ATo, ABody: string);
    procedure OnRTXLoginResult(Sender: TObject; AStatus: Integer);
  public
    { Public declarations }
  end;

var
  frm_Main: Tfrm_Main;

implementation

{$R *.fmx}
{$R *.Macintosh.fmx MACOS}

uses uUDPModule, ufrmAbout, uDebug, ufrmSetting, uGlobalDef;

procedure Tfrm_Main.act_AboutExecute(Sender: TObject);
begin
  frm_About.ShowModal;
end;

procedure Tfrm_Main.act_ExitAppExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tfrm_Main.act_SettingExecute(Sender: TObject);
begin
  frm_Setting.ShowModal;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DBG('Tfrm_Main.FormClose');
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  DBG('Tfrm_Main.FormCreate');
  if Assigned(dm_UDP) then
  begin
    dm_UDP.RTXOnMainFormIMMessage := OnRTXIMMessage;
    dm_UDP.RTXOnMainFormLoginResult := OnRTXLoginResult;
  end;
end;

procedure Tfrm_Main.OnRTXIMMessage(Sender: TObject; const AFrom, ATo,
  ABody: string);
begin

end;

procedure Tfrm_Main.OnRTXLoginResult(Sender: TObject; AStatus: Integer);
begin
  if gIsLogin then
    Show;
end;

end.
