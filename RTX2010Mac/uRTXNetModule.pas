//***************************************************************************
//
//       名称：uUDPModule.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:45:03
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uRTXNetModule;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdException, uBytesHelper, uGlobalDef,
  uRTXPacket, uRTXPacketRWriter, uRTXXMLData, FMX.Types;

type
  TRTXReadDataThread = class;

  Tdm_RTXNetModule = class(TDataModule)
    idtcpclnt_RTX: TIdTCPClient;
    tmr_RTXKeeplive: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure idtcpclnt_RTXConnected(Sender: TObject);
    procedure tmr_RTXKeepliveTimer(Sender: TObject);
  private
    FRTXPacket: TRTXPacket;
    FRTXReadThread: TRTXReadDataThread;
    FRTXOnLoginFormError: TRTXErrorEvent;
    FRTXOnLoginFormResult: TRTXLoginResultEvent;
    FRTXOnMainFormLoginResult: TRTXLoginResultEvent;
    FRTXOnMainFormIMMessage: TRTXIMMessageEvent;
    procedure StartLoginThread;
  private
    // 事件私有化
    procedure OnRTXError(Sender: TObject; const AError: string; ACode: Integer);
    procedure OnRTXIMMessage(Sender: TObject; const AFrom, ATo, ABody: string);
    procedure OnRTXLoginResult(Sender: TObject; AStatus: Integer);
  public
    /// <summary>
    ///   登录
    /// </summary>
    procedure LoginRTX(const AUser, APwd: string);
    /// <summary>
    ///   取消登录
    /// </summary>
    procedure CancelLogin;
  public
    property RTX: TRTXPacket read FRTXPacket;
    // 主窗口事件指向
    property RTXOnMainFormLoginResult: TRTXLoginResultEvent read FRTXOnMainFormLoginResult write FRTXOnMainFormLoginResult;
    property RTXOnMainFormIMMessage: TRTXIMMessageEvent read FRTXOnMainFormIMMessage write FRTXOnMainFormIMMessage;
    // 登录窗口事件
    property RTXOnLoginFormError: TRTXErrorEvent read FRTXOnLoginFormError write FRTXOnLoginFormError;
    property RTXOnLoginFormResult: TRTXLoginResultEvent read FRTXOnLoginFormResult write FRTXOnLoginFormResult;
  end;

  TRTXReadDataThread = class(TThread)
  private
    FRTXPacket: TRTXPacket;
  protected
    procedure Execute; override;
  public
    constructor Create(ARTXPacket: TRTXPacket);
  end;

var
  dm_RTXNetModule: Tdm_RTXNetModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uConfigFile, uDebug;

{$R *.dfm}

procedure Tdm_RTXNetModule.CancelLogin;
begin
  if idtcpclnt_RTX.Connected then
    idtcpclnt_RTX.Disconnect;
  if Assigned(FRTXReadThread) then
  begin
    FRTXReadThread.Terminate;
    FRTXReadThread := nil;
  end;
end;

procedure Tdm_RTXNetModule.DataModuleCreate(Sender: TObject);
begin
  DBG('DataModuleCreate');
  tmr_RTXKeeplive.Interval := 1000 * 20;
  FRTXPacket := TRTXPacket.Create(Self);
  FRTXPacket.Socket := idtcpclnt_RTX;
  FRTXPacket.OnError := OnRTXError;
  FRTXPacket.OnLogResult := OnRTXLoginResult;
  FRTXPacket.OnIMMessage := OnRTXIMMessage;
end;

procedure Tdm_RTXNetModule.DataModuleDestroy(Sender: TObject);
begin
  CancelLogin;
  FRTXPacket.Free;
end;

procedure Tdm_RTXNetModule.idtcpclnt_RTXConnected(Sender: TObject);
begin
  // 成功连接之后登录
  FRTXPacket.Login;
  StartLoginThread;
end;

procedure Tdm_RTXNetModule.LoginRTX(const AUser, APwd: string);
var
  LConf: TRTXConfig;
begin
  LConf := TRTXConfig.Create;
  try
    idtcpclnt_RTX.Port := LConf.Port;
    idtcpclnt_RTX.Host := LConf.Host;
  finally
    LConf.Free;
  end;
  FRTXPacket.InitUserInfo(AUser, APwd);
  if not idtcpclnt_RTX.Connected then
  begin
    // 不阻塞主线程
    TThread.CreateAnonymousThread(
      procedure
      begin
        try
          idtcpclnt_RTX.Connect;
        except
          on E: EIdException do
          begin
            Self.OnRTXError(Self, E.Message, -2);
          end;
        end;
      end).Start;
  end
  else
  begin
    FRTXPacket.Login;
    StartLoginThread;
  end;
end;

procedure Tdm_RTXNetModule.OnRTXError(Sender: TObject; const AError: string;
  ACode: Integer);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      gIsLogin := False;
      if Self.tmr_RTXKeeplive.Enabled then
        Self.tmr_RTXKeeplive.Enabled := False;
      if Assigned(FRTXOnLoginFormError) then
        FRTXOnLoginFormError(Sender, AError, ACode);
    end);
end;

procedure Tdm_RTXNetModule.OnRTXIMMessage(Sender: TObject; const AFrom, ATo,
  ABody: string);
begin
  if Assigned(FRTXOnMainFormIMMessage) then
  begin
    TThread.Synchronize(nil,
      procedure
      begin
        FRTXOnMainFormIMMessage(Sender, AFrom, ATo, ABody);
      end);
  end;
end;

procedure Tdm_RTXNetModule.OnRTXLoginResult(Sender: TObject; AStatus: Integer);
begin
  gIsLogin := AStatus = 1;
  {$IFDEF MACOS}
    if Assigned(FRTXOnLoginFormResult) then
      FRTXOnLoginFormResult(Sender, AStatus);
  {$ENDIF}
  TThread.Synchronize(nil,
    procedure
    begin
      DBG('Tdm_UDP.OnRTXLoginResult');
    {$IFNDEF MACOS}
      if Assigned(FRTXOnLoginFormResult) then
        FRTXOnLoginFormResult(Sender, AStatus);
    {$ENDIF}
      if AStatus = 1 then
        tmr_RTXKeeplive.Enabled := True;
      if Assigned(FRTXOnMainFormLoginResult) then
        FRTXOnMainFormLoginResult(Sender, AStatus);
    end);
end;

procedure Tdm_RTXNetModule.StartLoginThread;
begin
  if FRTXReadThread = nil then
  begin
    FRTXReadThread := TRTXReadDataThread.Create(FRTXPacket);
    FRTXReadThread.Start;
  end;
end;

procedure Tdm_RTXNetModule.tmr_RTXKeepliveTimer(Sender: TObject);
begin
  if gIsLogin then
    FRTXPacket.Keeplive;
end;

{ TRTXReadDataThread }

constructor TRTXReadDataThread.Create(ARTXPacket: TRTXPacket);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FRTXPacket := ARTXPacket;
end;

procedure TRTXReadDataThread.Execute;
begin
  inherited;
  if Assigned(FRTXPacket) and Assigned(FRTXPacket.Socket) then
  begin
    while (not Terminated) and (FRTXPacket.Socket.Connected) do
    begin
     if not FRTXPacket.ProcessData then Break;
    end;
  end;
  DBG('TRTXReadDataThread Terminate.');
end;

end.
