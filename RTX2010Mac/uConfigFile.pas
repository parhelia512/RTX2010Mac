//***************************************************************************
//
//       名称：uConfigFile.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:41:46
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//***************************************************************************
unit uConfigFile;

{$I 'RTX.inc'}

interface

uses
  System.IniFiles,
  System.SysUtils;

type
  TRTXConfig = class
  private const
    LOGIN_SECTION = 'Login';
    SERVER_SECTION = 'Server';
  private
    FIniFile: TIniFile;
    FFileName: string;
    function GetAutoLogin: Boolean;
    procedure SetAutoLogin(const Value: Boolean);
    function GetRemember: Boolean;
    procedure SetRemember(const Value: Boolean);
    function GetPassword: string;
    function GetUserName: string;
    procedure SetPassword(const Value: string);
    procedure SetUserName(const Value: string);
    function GetPort: Word;
    function GetHost: string;
    procedure SetPort(const Value: Word);
    procedure SetHost(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
  public
    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
    property AutoLogin: Boolean read GetAutoLogin write SetAutoLogin;
    property Remember: Boolean read GetRemember write SetRemember;

    property Port: Word read GetPort write SetPort;
    property Host: string read GetHost write SetHost;

    property FileName: string read FFileName;
  end;

implementation

{ TRTXConfig }

uses uGlobalDef;

constructor TRTXConfig.Create;
begin
  inherited Create;
{$IFDEF MSWINDOWS}
  FFileName := ExtractFilePath(ParamStr(0)) + 'RTXConfig.ini';
{$ELSE}
  FFileName := ExtractFilePath(ExtractFileDir(ParamStr(0))) + '/Resources/RTXConfig';
{$ENDIF}
  FIniFile := TIniFile.Create(FFileName{$IFNDEF MSWINDOWS}, TEncoding.UTF8{$ENDIF});
end;

destructor TRTXConfig.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TRTXConfig.GetAutoLogin: Boolean;
begin
  Result := FIniFile.ReadBool(LOGIN_SECTION, 'AutoLogin', False);
end;

function TRTXConfig.GetPassword: string;
begin
  Result := FIniFile.ReadString(LOGIN_SECTION, 'Password', '');
end;

function TRTXConfig.GetPort: Word;
begin
  Result := FIniFile.ReadInteger(SERVER_SECTION, 'Port', DEFAULT_RTX_PORT);
end;

function TRTXConfig.GetRemember: Boolean;
begin
  Result := FIniFile.ReadBool(LOGIN_SECTION, 'Remember', False);
end;

function TRTXConfig.GetHost: string;
begin
  Result := FIniFile.ReadString(SERVER_SECTION, 'Host', DEFAULT_RTX_HOST);
end;

function TRTXConfig.GetUserName: string;
begin
  Result := FIniFile.ReadString(LOGIN_SECTION, 'UserName', '');
end;

procedure TRTXConfig.SetAutoLogin(const Value: Boolean);
begin
  FIniFile.WriteBool(LOGIN_SECTION, 'AutoLogin', Value);
end;

procedure TRTXConfig.SetPassword(const Value: string);
begin
  FIniFile.WriteString(LOGIN_SECTION, 'Password', Value);
end;

procedure TRTXConfig.SetPort(const Value: Word);
begin
  FIniFile.WriteInteger(SERVER_SECTION, 'Port', Value);
end;

procedure TRTXConfig.SetRemember(const Value: Boolean);
begin
  FIniFile.WriteBool(LOGIN_SECTION, 'Remember', Value);
end;

procedure TRTXConfig.SetHost(const Value: string);
begin
  FIniFile.WriteString(SERVER_SECTION, 'Host', Value);
end;

procedure TRTXConfig.SetUserName(const Value: string);
begin
  FIniFile.WriteString(LOGIN_SECTION, 'UserName', Value);
end;

end.
