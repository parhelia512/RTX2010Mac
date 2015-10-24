//***************************************************************************
//
//       名称：uRTXPacket.pas
//       工具：RAD Studio XE6, XE8
//       日期：2015/10/16 20:44:42
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uRTXPacket;

{$I 'RTX.inc'}

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
 {$IFNDEF USEIDTCP}
    System.Win.ScktComp,
 {$ENDIF}
{$ENDIF}
{$IFDEF USEIDTCP}
  IdTCPClient,
  IdGlobal,
{$ENDIF}
  System.DateUtils,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  uBytesHelper,
  uRTXPacketRWriter,
  QQTEA,
  StreamRWriter,
  uRTXXMLData;

type
  /// <summary>
  ///   RTX封包数据头
  /// </summary>
  TRTXDataHead = packed record
    Head: Byte;
    Len: Word;
    Version: Word;
    Cmd: Word;
    Seq: Word;
    Uin: Cardinal;
  public
    constructor Create(ALen, AVersion, ACmd, ASeq: Word; AUin: Cardinal);
  end;

  /// <summary>
  ///   一个会话记录
  /// </summary>
  TRTXSession = record
    Key: string;
    Receiver: string;
    Title: string;
    Sender: string;
    Initiator: string;
    Identifier: string;
    // 额外的, 理论上不属于会话
    Cmd : string;
    im_message_id : string;
  public
    constructor Create(const AKey, AReceiver, ATitle, ASender, AInitiator, AIdentifier: string);
  end;


  /// <summary>
  ///   0离线了, 1在线, 2离开状态
  /// </summary>
  TRTXStatusType = (rstOffline, rstOnline, rstAway);

  /// <summary>
  ///   状态改变
  /// </summary>
  TRTXStatusRec = record
    Id: Integer;
    Status: TRTXStatusType;
  public
    constructor Create(AId: Integer; AStatus: TRTXStatusType);
  end;

  TRTXStatusList = class(TList<TRTXStatusRec>);

  TRTXErrorEvent = procedure(Sender: TObject; const AError: string; ACode: Integer) of object;
  TRTXIMMessageEvent = procedure(Sender: TObject; const AFrom, ATo, ABody: string) of object;
  TRTXLoginResultEvent = procedure(Sender: TObject; AStatus: Integer) of object;
  TRTXStatusChangedEvent = procedure(Sender: TObject; AList: TRTXStatusList) of object;
  TRTXIMMsgStatusEvent = procedure(Sender: TObject; AStatus: Integer) of object;

  TRTXPacket = class(TComponent)
  public
    const
      PACKET_HEAD = $02;
      PACKET_TAIL = $03;
      PACKET_VERSION = $0101;
      /// <summary>
      ///   登录第一个包 $0400
      /// </summary>
      CMD_0400 = $0400;  
      /// <summary>
      ///   发送验证 $0401
      /// </summary>
      CMD_0401 = $0401;  
      /// <summary>
      ///   处理IM消息 $0C01
      /// </summary>
      CMD_0C01 = $0C01;  
      /// <summary>
      ///   回复收到IM消息 $0C02
      /// </summary>
      CMD_0C02 = $0C02;   
      /// <summary>
      ///   发送消息出去 $0C00
      /// </summary>
      CMD_0C00 = $0C00;   
      /// <summary>
      ///   keeplive $0805
      /// </summary>
      CMD_0805 = $0805;
      /// <summary>
      ///   貌似是状态改变的通知包
      /// </summary>
      CMD_080E = $080E;
  private
    FOnError: TRTXErrorEvent;
    FOnIMMessage: TRTXIMMessageEvent;
    FOnLoginResult: TRTXLoginResultEvent;
    FOnStatusChanged: TRTXStatusChangedEvent;
   {$IFDEF USEIDTCP}
    FSocket: TIdTCPClient;
   {$ELSE}
    FSocket: TClientSocket;
   {$ENDIF}
    /// <summary>
    ///   聊天会话, Key=Key, Value=Session GUID
    /// </summary>
    FSessions: TDictionary<string, TRTXSession>;
    /// <summary>
    ///   保存发送者对应的KEY
    /// </summary>
    FSessionSenders: TDictionary<string, string>;
    
    FTouchKey: TBytes;
    FSessionKey: TBytes;
    FPassKey1: TBytes;
    FPassKey2: TBytes;
    FNameKey3: TBytes;
    FIsLogin: Boolean;
    FUID: Cardinal;
    FUserName: string;
    FAuthType: Integer;
    FNextSeq: Word;
    FPassword : string;
    FOnIMMsgStatus: TRTXIMMsgStatusEvent;

    function RandKey: TBytes;
    function GetTimestamp: Cardinal;
    procedure SendIMMessageToMainForm(const AFrom, ATo, ABody: string);
    procedure SendLoginResult(AStatus: Integer);
    procedure SendError(const AErr: string; ACode: Integer);
    procedure WritePacket(ACmd: Word; AData, AKey: TBytes; ASendKey: Boolean);
    function Passkey1(APassword: string): TBytes;
    function Passkey2(APassword: string): TBytes;
    function NameKey3(AName: string): TBytes;

    procedure ProcessIMMessage(const AMsgBody: string);

    procedure SetSocket(const Value: {$IFDEF USEIDTCP}TIdTCPClient{$ELSE}TClientSocket{$ENDIF});
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ProcessData: Boolean;
    procedure Process_0400(Data: TBytes);
    procedure Process_0401(Data: TBytes; ALen: Integer);
    procedure Process_0C01(Data: TBytes);
    procedure Process_0C00(Data: TBytes);
    procedure Process_0C02(Data: TBytes);
    procedure Process_0805(Data: TBytes); // keeplive
    procedure Process_080E(Data: TBytes); // status
    procedure Keeplive;
    procedure Process_Unknow(Data: TBytes; ACmd: Integer);
    procedure InitUserInfo(const AUserName, APassword: string);
    procedure Login;
    procedure SendIMMessage(const ATo, AMsg: string; AFont: TRTXMsgFontAttr);
    procedure DeleteSession(const AKey: string);
  published
    property Socket: {$IFDEF USEIDTCP}TIdTCPClient{$ELSE}TClientSocket{$ENDIF} read FSocket write SetSocket;
    property OnIMMsgStatus: TRTXIMMsgStatusEvent read FOnIMMsgStatus write FOnIMMsgStatus;
    property OnStatusChanged: TRTXStatusChangedEvent read FOnStatusChanged write FOnStatusChanged;
    property OnError: TRTXErrorEvent read FOnError write FOnError;
    property OnIMMessage: TRTXIMMessageEvent read FOnIMMessage write FOnIMMessage;
    property OnLogResult: TRTXLoginResultEvent read FOnLoginResult write FOnLoginResult;
  end;

implementation

uses
  System.Math,
{$IFDEF DelphiXE8}
  System.Hash, // XE8之后，还是XE7之后有的
{$ELSE}
  {$IFDEF MSWINDOWS}
    CnMD5,
  {$ENDIF}
{$ENDIF}
  uDebug;




{ TRTXDataHead }

constructor TRTXDataHead.Create(ALen, AVersion, ACmd, ASeq: Word;
  AUin: Cardinal);
begin
  Self.Head := $02;
  Self.Len := ALen;
  Self.Version := AVersion;
  Self.Cmd := ACmd;
  Self.Seq := ASeq;
  Self.Uin := AUin;
end;


{ TRTXPacket }

constructor TRTXPacket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNextSeq := $0E55;
  FUID := 0;
  FSessions := TDictionary<string, TRTXSession>.Create;
  FSessionSenders := TDictionary<string, string>.Create;
end;

procedure TRTXPacket.DeleteSession(const AKey: string);
begin
  FSessions.Remove(AKey);
//  if FSessionSenders.ContainsValue(AKey)
end;

destructor TRTXPacket.Destroy;
begin
  FSessionSenders.Free;
  FSessions.Free;
  inherited;
end;

function TRTXPacket.GetTimestamp: Cardinal;
begin
  Result := System.DateUtils.DateTimeToUnix(Now) - 28800;
end;

procedure TRTXPacket.InitUserInfo(const AUserName, APassword: string);
begin
  FUserName := AUserName;
  FPassword := APassword;
  FPassKey1 := Passkey1(FPassword);
  FPassKey2 := Passkey2(FPassword);
  FNameKey3 := NameKey3(FUserName);
end;

procedure TRTXPacket.Keeplive;
begin
  if FIsLogin then
    WritePacket(CMD_0805, nil, FSessionKey, False);
end;

procedure TRTXPacket.Login;
var
  LRTXData: TRTXStream;
begin
  FTouchKey := RandKey;
  LRTXData := TRTXStream.Create(True);
  try
    LRTXData.WriteByte(PACKET_HEAD);
    LRTXData.WriteUnicode(FUserName);
    WritePacket(CMD_0400, LRTXData.GetBytes, FTouchKey, True);
  finally
    LRTXData.Free;
  end;
end;

function TRTXPacket.NameKey3(AName: string): TBytes;
{$IF Defined(MSWINDOWS) and not Defined(DelphiXE8)}
var
  M: TMD5Digest;
  LBytes: TBytes;
begin
  SetLength(Result, $10);
  LBytes := TEncoding.Unicode.GetBytes(AName);
  M := MD5Buffer(LBytes, Length(LBytes));
  Move(M, Result[0], SizeOf(TMD5Digest));
end;
{$ELSE}
var
  M: THashMD5;
  LBytes: TBytes;
begin
  SetLength(Result, $10);
  LBytes := TEncoding.Unicode.GetBytes(AName);
  M := THashMD5.Create;
  M.Update(LBytes);
  Move(M.HashAsBytes[0], Result[0], $10);
end;
{$ENDIF}

procedure TRTXPacket.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if AComponent = FSocket then
      FSocket := nil;
  end;
end;

procedure TRTXPacket.ProcessIMMessage(const AMsgBody: string);
var
  LRTXCData: TRTXCData;
  LSession: TRTXSession;
//  LRTXMsg: TRTXMsg;
begin
  LRTXCData := TRTXCData.Create(Self, AMsgBody);
  try
    LSession.Key := LRTXCData.GetString('Key');
    LSession.Receiver := LRTXCData.GetString('Receiver');
    LSession.Title := LRTXCData.GetString('Title');
    LSession.Sender := LRTXCData.GetString('Sender');
    LSession.Initiator := LRTXCData.GetString('Initiator');
    LSession.Identifier := LRTXCData.GetString('Identifier');
    LSession.Cmd := LRTXCData.GetString('Cmd');
    LSession.im_message_id := LRTXCData.GetString('im_message_id');
    // 保存session
    FSessions.AddOrSetValue(LSession.Key, LSession);
    if not LSession.Sender.IsEmpty then
      FSessionSenders.AddOrSetValue(LSession.Sender, LSession.Key);
    
    // 对方打开会话窗口，要求会话目标初始窗口
    {if LSession.Cmd.Equals('QueryLoginMode') then
    begin
      FSessions.AddOrSetValue(LSession.Key, LSession);
      if not LSession.Sender.IsEmpty then
        FSessionSenders.AddOrSetValue(LSession.Sender, LSession.Key);
    end
    else
    begin
      // 更新key项目
      if FSessions.ContainsKey(LSession.Key) then
        FSessions.Items[LSession.Key] := LSession;
      // 更新对应KEY
      if not LSession.Sender.IsEmpty then
      begin
        if FSessionSenders.ContainsKey(LSession.Sender) then
          FSessionSenders.Items[LSession.Sender] := LSession.Key;
      end;
    end;   }
  finally
    LRTXCData.Free;
  end;
end;

function TRTXPacket.Passkey1(APassword: string): TBytes;
{$IF Defined(MSWINDOWS) and not Defined(DelphiXE8)}
var
  M: TMD5Digest;
begin
  SetLength(Result, SizeOf(TMD5Digest));
  M := MD5String(APassword);
  Move(M, Result[0], SizeOf(TMD5Digest));
end;
{$ELSE}
begin
  SetLength(Result, $10);
  Move(THashMD5.GetHashBytes(APassword)[0], Result[0], $10);
end;
{$ENDIF}


function TRTXPacket.Passkey2(APassword: string): TBytes;
{$IF Defined(MSWINDOWS) and not Defined(DelphiXE8)}
var
  pp, dd: TBytes;
  M: TMD5Digest;
begin
  pp := BytesOf(APassword);
  SetLength(dd, $10);
  Move(pp[0], dd[0], Min(Length(pp), $10));
  SetLength(Result, $10);
  M := MD5Buffer(dd, Length(dd));
  Move(M, Result[0], SizeOf(TMD5Digest));
end;
{$ELSE}
var
  pp, dd: TBytes;
  M: THashMD5;
begin
  pp := BytesOf(APassword);
  SetLength(dd, $10);
  Move(pp[0], dd[0], Min(Length(pp), $10));
  SetLength(Result, $10);
  M := THashMD5.Create;
  M.Update(dd);
  Move(M.HashAsBytes[0], Result[0], $10);
end;
{$ENDIF}


function TRTXPacket.ProcessData: Boolean;
var
  LRTXHead: TRTXDataHead;
  LDataLen: Integer;
  LData: TBytes;
  LTail: Byte;
begin
  Result := False;
  try
    if Assigned(FSocket) then
    begin
    {$IFDEF USEIDTCP}
      LRTXHead.Head := FSocket.IOHandler.ReadByte;
      LRTXHead.Len  := FSocket.IOHandler.ReadUInt16(True);
      LRTXHead.Version  := FSocket.IOHandler.ReadUInt16(True);
      LRTXHead.Cmd  := FSocket.IOHandler.ReadUInt16(True);
      LRTXHead.Seq  := FSocket.IOHandler.ReadUInt16(True);
      LRTXHead.Uin  := FSocket.IOHandler.ReadUInt32(True);
    {$ELSE}
      FSocket.Socket.ReceiveBuf(LRTXHead, SizeOf(TRTXDataHead));
      TStreamRWriter.ToBigEndian(@LRTXHead.Len, 2);
      TStreamRWriter.ToBigEndian(@LRTXHead.Cmd, 2);
      TStreamRWriter.ToBigEndian(@LRTXHead.Seq, 2);
      TStreamRWriter.ToBigEndian(@LRTXHead.Uin, 4);
    {$ENDIF}
      LDataLen := LRTXHead.Len - $E;
      if LRTXHead.Cmd <> 0 then
      begin
        if LDataLen > 0 then
        begin
          {$IFDEF USEIDTCP}
            FSocket.IOHandler.ReadBytes(TIdBytes(LData), LDataLen);
          {$ELSE}
            SetLength(LData, LDataLen);
            FSocket.Socket.ReceiveBuf(LData[0], LDataLen);
          {$ENDIF}
        end;
      end;
      {$IFDEF USEIDTCP}
        LTail := FSocket.IOHandler.ReadByte;
      {$ELSE}
        FSocket.Socket.ReceiveBuf(LTail, 1);
      {$ENDIF}

      if (LRTXHead.Head = PACKET_HEAD) and (LTail = PACKET_TAIL) then
      begin

        DBG('------------------Recv begin CMD=%s, Length=%d', [IntToHex(LRTXHead.Cmd, 4), LRTXHead.Len]);
        PrintBytes(LData, 'RECV');

        case LRTXHead.Cmd of
          CMD_0400 :
            Process_0400(LData);
          CMD_0401 :
            Process_0401(LData, LRTXHead.Len);
          CMD_0C01 :
            Process_0C01(LData);
          CMD_0C00 :
            Process_0C00(LData);
          CMD_0C02 : 
            Process_0C02(LData);
          CMD_0805 :
            Process_0805(LData);
          CMD_080E :
            Process_080E(LData);
        else
          Process_Unknow(LData, LRTXHead.Cmd);
        end;
        DBG('------------------Recv end--------------------');
        DBG('       ');
      end;
    end;
    Result := True;
  except
    on E: Exception do
      SendError(E.Message, -3);
  end;
end;

procedure TRTXPacket.Process_0400(Data: TBytes);
var
  LRTXStream, LRTXTemp: TRTXStream;
  LStatus: Byte;
  LName: string;
  LSalt: array[0..3] of Byte;
  LPassBytes: TBytes;
begin
  LRTXStream := TRTXStream.Create(QQTEADeCrypt(Data, FTouchKey));
  try
    LStatus := LRTXStream.ReadByte;
    if LStatus = $FE then
      SendError('用户不存在！', LStatus)
    else if LStatus in [$02, $00] then //status == 0x02 || status == 0x0
    begin
      FUID := LRTXStream.ReadCardinal;
      LName := LRTXStream.ReadUnicode;
      LRTXStream.ReadBytes(LSalt, 4);
      FAuthType := LRTXStream.ReadByte; // 认证类型
      //DBG('----------Name=%s, UIN=%d', [LName, FUID]);
      LRTXStream.Clear;
      if FAuthType = 0 then
      begin
        LRTXStream.WriteUnicode(LName);
        LRTXStream.WriteByte(1);
        LRTXStream.WriteToken(QQTEAEcCrypt(Lsalt, FPassKey2));
        LRTXStream.WriteToken(QQTEAEcCrypt(Lsalt, FPassKey1));
        LRTXStream.WriteBytes(RandKey);
        LRTXStream.WriteByte(0);
      end else if FAuthType = 1 then
      begin
        LRTXStream.WriteUnicode(LName);
        LRTXStream.WriteByte($02); // authtype
        LRTXTemp := TRTXStream.Create(True);
        try
          LPassBytes := BytesOf(FPassword);
          LRTXTemp.WriteByte(LPassBytes.Length);
          LRTXTemp.WriteBytes(LPassBytes);
          LRTXTemp.WriteBytes(TBytes(LSalt));
          LRTXStream.WriteToken(QQTEAEcCrypt(LRTXStream.GetBytes, FNameKey3));
        finally
          LRTXTemp.Free;
        end;
        LRTXStream.WriteByte(0);
        LRTXStream.WriteBytes(RandKey); //???
        LRTXStream.WriteByte(0);
      end;
      //PrintBytes(LRTXStream.GetBytes, 'LRTXStream.Bytes');
      WritePacket(CMD_0401, LRTXStream.GetBytes, RandKey, True);
    end;
  finally
    LRTXStream.Free;
  end;
end;

procedure TRTXPacket.Process_0401(Data: TBytes; ALen: Integer);
var
  LStatus: Byte;
  LRaw, LTEADeData: TBytes;
  LRTXData: TRTXStream;
  LMessage: string;
begin
  //PrintBytes(Data, 'Process_0401');
  LStatus := Data[0];
  if LStatus = 0 then
  begin
    SetLength(LRaw, ALen - $E - 1);
    Move(Data[1], LRaw[0], LRaw.Length);
    if FAuthType = 0 then
      LTEADeData := QQTEADeCrypt(LRaw, FPassKey2)
    else
      LTEADeData := QQTEADeCrypt(LRaw, FNameKey3);
    if LTEADeData <> nil then
    begin
      LRTXData := TRTXStream.Create(LTEADeData);
      try
        FUID := LRTXData.ReadCardinal;
        FSessionKey := LRTXData.ReadBytes($10);
        //PrintBytes(FSessionKey, 'LoginOK: sessionKey');
        FIsLogin := True;
        SendLoginResult(1);
        Keeplive;
      finally
        LRTXData.Free;
      end;
    end else
      DBG('解密数据错误！');
  end else
  begin
    case LStatus of
      253 : LMessage := '密码错误！';
    else
      LMessage := '登录失败，错误代码:' + IntToStr(LStatus);
    end;
    SendError(LMessage, LStatus);
  end;
end;

procedure TRTXPacket.Process_0805(Data: TBytes);
var
  LDe: TBytes;
begin
  LDe := QQTEADeCrypt(Data, FSessionKey);
  PrintBytes(LDe, 'TEADeCrypt Process_0805');
  DBG('Process_0805 Text=' + StringOf(LDe));
end;

procedure TRTXPacket.Process_080E(Data: TBytes);
var
  LDe: TBytes;
  LStatus: TRTXStatusList;
  LCount, I: Integer;
  LRTXData: TRTXStream;
begin
  LDe := QQTEADeCrypt(Data, FSessionKey);
  // 00 01 改变的人数
  // 00 00 03 E9 UIN
  // 01 00 状态，0离线了, 1在线, 2离开状态
  // 两个人时
  // 00 02         2个人
  // 00 00 03 E9   1001
  // 02 00         2
  // 00 00 03 EB   1003
  // 02 00         2
  // 00 01 00 00 03 E9 01 00
  // 00 01 00 00 03 E9 00 00
  if Assigned(FOnStatusChanged) then
  begin
    LRTXData := TRTXStream.Create(LDe);
    try
      LCount := LRTXData.ReadWord;
      if LCount > 0 then
      begin
        LStatus := TRTXStatusList.Create;
        try
          for I := 1 to LCount do
            LStatus.Add(TRTXStatusRec.Create(LRTXData.ReadCardinal, TRTXStatusType(LRTXData.ReadWord)));
          FOnStatusChanged(Self, LStatus);
        finally
          LStatus.Free;
        end;
      end;
    finally
      LRTXData.Free;
    end;
  end;
//  PrintBytes(LDe, 'TEADeCrypt Process_080E');
//  DBG('Process_080E Text=' + StringOf(LDe));
end;

procedure TRTXPacket.Process_0C00(Data: TBytes);
var
  LTEADeData: TBytes;
begin
  LTEADeData := QQTEADeCrypt(Data, FSessionKey);
  if LTEADeData <> nil then
  begin
    // 第一字节为状态，2为在线消息成功，5貌似是离线消息成功
    if Assigned(FOnIMMsgStatus) then
      FOnIMMsgStatus(Self, LTEADeData[0]);
    DBG('send msg reply: ' + LTEADeData[0].ToString)
  end
  else DBG('send msg reply decrypt data error.');
end;

procedure TRTXPacket.Process_0C01(Data: TBytes);
var
  LimId: Cardinal;
  LTEADeData: TBytes;
  LRTXData: TRTXStream;
  LFrom, LTo, LBody, LImType, LImType2: string;
begin
  LTEADeData := QQTEADeCrypt(Data, FSessionKey);
  if LTEADeData <> nil then
  begin
    LRTXData := TRTXStream.Create(LTEADeData);
    try
      LimId := LRTXData.ReadWord;
      LRTXData.Seek(2, soCurrent);
      LRTXData.Seek(8, soCurrent); // 8 bit 0
      LRTXData.Seek(4, soCurrent); // unknown1
      LImType := LRTXData.ReadUnicode; // imType
      LRTXData.Seek(1, soCurrent); // 0
      LImType2 := LRTXData.ReadUnicode(); // imType2
      LFrom := LRTXData.ReadUnicode;
      LRTXData.Seek(1, soCurrent); // 0
      LTo := LRTXData.ReadUnicode;
      LRTXData.Seek(2, soCurrent); // unknown2
      LBody := LRTXData.ReadUnicode2;

      DBG('---------------------------------------Body Begin------------------------');
      DBG(LBody);
      DBG('---------------------------------------Body End--------------------------');

      LRTXData.Clear;
      //LRTXData.WriteHexBytes('00 00 00 00 00 00 01');
      LRTXData.WriteCardinal(0);
      LRTXData.WriteWord(0);
      LRTXData.WriteByte(1);
      LRTXData.WriteWord(LimId);
      LRTXData.WriteUnicode(LImType);
      LRTXData.WriteByte(0);
      LRTXData.WriteUnicode(LImType2);
      LRTXData.WriteUnicode(LTo);
      LRTXData.WriteUnicode(LFrom);
      LRTXData.WriteByte(0);
      LRTXData.WriteUnicode('OK');
      //LRTXData.WriteHexBytes('00 06 4F 00 4B 00 00 00');
      WritePacket(CMD_0C02, LRTXData.GetBytes, FSessionKey, False);

      // 处理数据，早晚我要换掉这自带的xml
      TThread.Synchronize(nil,
        procedure
        begin
          ProcessIMMessage(LBody);
        end);
      SendIMMessageToMainForm(LFrom, LTo, LBody);
//      TThread.Synchronize(nil,
//        procedure
//        begin
//          //Self.SendIMMessage(LFrom, '收到啦 ~ ' + DateTimeToStr(Now));
//        end);

    finally
      LRTXData.Free;
    end;
  end;
end;

procedure TRTXPacket.Process_0C02(Data: TBytes);
var
  LDe: TBytes;
begin
  LDe := QQTEADeCrypt(Data, FSessionKey);
  PrintBytes(LDe, 'TEADeCrypt Process_0C02');
  DBG('Process_0C02 Text=' + StringOf(LDe));
end;

procedure TRTXPacket.Process_Unknow(Data: TBytes; ACmd: Integer);
var
  LDe: TBytes;
begin
  LDe := QQTEADeCrypt(Data, FSessionKey);
  PrintBytes(LDe, Format('TEADeCrypt Process_Unknow(%.x4)', [ACmd]));
  DBG('Process_Unknow Text=' + StringOf(LDe));
end;

function TRTXPacket.RandKey: TBytes;
var
  I: Integer;
begin
  Randomize;
  SetLength(Result, $10);
  for I := 0 to High(Result) do
    Result[I] := Random(255);
end;

procedure TRTXPacket.SendLoginResult(AStatus: Integer);
begin
  if Assigned(FOnLoginResult) then
    FOnLoginResult(Self, AStatus);
end;

procedure TRTXPacket.SendError(const AErr: string; ACode: Integer);
begin
  if Assigned(FOnError) then
    FOnError(Self, AErr, ACode);
end;

procedure TRTXPacket.SendIMMessage(const ATo, AMsg: string; AFont: TRTXMsgFontAttr);
var
  LRTXStream: TRTXStream;
  LRTXCData: TRTXCData;
  LRTXMsg: TRTXMsg;
  LSession: TRTXSession;
  LKey: string;
begin
  // 查询发送人是否存在,　不存在会话列表是不是应该新添加一个，有待观察数据
  
  if FSessionSenders.TryGetValue(ATo, LKey) then
  begin
    if FSessions.TryGetValue(LKey, LSession) then
    begin
      LRTXStream := TRTXStream.Create(True);
      try
        LRTXCData := TRTXCData.Create;
        try
          LRTXCData.SetLong('Mode', 0);
          LRTXMsg := TRTXMsg.Create(AMsg, AFont);
          try
            LRTXCData.SetString('Content', LRTXMsg.XML);
          finally
            LRTXMsg.Free;
          end;
          LRTXCData.SetString('Initiator', FUserName);
          LRTXCData.SetString('Key', LSession.Key);//'{589E22CE-91E2-4FB5-97C6-2D1DE253C539}');//TGuidHelper.NewGuid.ToString);
          LRTXCData.SetBuffer('im_message_id', LSession.im_message_id);//'EAAAANSTcL/D4jxDhS9VIr0khiV='); // 这里的buff估计要解

          DBG(LRTXCData.XML);

          LRTXStream.WriteCardinal(0);
          LRTXStream.WriteCardinal(GetTimestamp);
          LRTXStream.WriteUnicode('Tencent.RTX.IM');
          LRTXStream.WriteByte(0);
          LRTXStream.WriteUnicode('Tencent.RTX.IM');
          LRTXStream.WriteUnicode(FUserName);
          LRTXStream.WriteByte(0);
          LRTXStream.WriteUnicode(ATo);
          LRTXStream.WriteWord(Random(65565)); //未知，分析像个随机数
          LRTXStream.WriteUnicode2(LRTXCData.XML);
          WritePacket(CMD_0C00, LRTXStream.GetBytes, FSessionKey, False);
        finally
          LRTXCData.Free;
        end;
      finally
        LRTXStream.Free;
      end;
    end;
  end;  
end;

procedure TRTXPacket.SendIMMessageToMainForm(const AFrom, ATo, ABody: string);
begin
  if Assigned(FOnIMMessage) then
    FOnIMMessage(Self, AFrom, ATo, ABody);
end;

procedure TRTXPacket.SetSocket(const Value: {$IFDEF USEIDTCP}TIdTCPClient{$ELSE}TClientSocket{$ENDIF});
begin
 if FSocket <> Value then
    FSocket := Value;
end;

procedure TRTXPacket.WritePacket(ACmd: Word; AData, AKey: TBytes; ASendKey: Boolean);
var
  LRaw: TBytes;
  LRTXData: TRTXStream;
begin
  //PrintBytes(AData, 'data');
  //PrintBytes(AKey, 'key');
  LRaw := QQTEAEcCrypt(AData, AKey);
  LRTXData := TRTXStream.Create(True);
  try
    if ASendKey then
    begin
      LRTXData.WriteBytes(AKey);
      LRTXData.WriteByte(LRaw.Length);
      LRTXData.WriteBytes(LRaw);
      LRaw := LRTXData.GetBytes;
      //PrintBytes(LRaw, 'LRaw');
    end;
    LRTXData.Clear;
    Inc(FNextSeq);
    LRTXData.WriteByte(PACKET_HEAD);
    LRTXData.WriteWord(LRaw.Length + $E);
    LRTXData.WriteWord(PACKET_VERSION);
    LRTXData.WriteWord(ACmd);
    LRTXData.WriteWord(FNextSeq);
    LRTXData.WriteCardinal(FUID);
    LRTXData.WriteBytes(LRaw);
    LRTXData.WriteByte(PACKET_TAIL);
    //PrintBytes(LRTXData.GetBytes, 'LWrite.Write');
    if Assigned(FSocket) then
    begin
     {$IFDEF USEIDTCP}
       if FSocket.Connected then
          FSocket.IOHandler.Write(TIdBytes(LRTXData.GetBytes))
     {$ELSE}
        if FSocket.Socket.Connected then
          FSocket.Socket.SendBuf(LRTXData.Memory^, LRTXData.Size)
     {$ENDIF}
      else SendError('未连接服务器！', -1);
    end;
  finally
    LRTXData.Free;
  end;

end;

{ TRTXSession }

constructor TRTXSession.Create(const AKey, AReceiver, ATitle, ASender,
  AInitiator, AIdentifier: string);
begin
  Self.Key := AKey;
  Self.Receiver := AReceiver;
  Self.Title := ATitle;
  Self.Sender := ASender;
  Self.Initiator := AInitiator;
  Self.Identifier := AIdentifier;
  Self.Cmd := '';
  Self.im_message_id := '';
end;

{ TStatusRec }

constructor TRTXStatusRec.Create(AId: Integer; AStatus: TRTXStatusType);
begin
  Id := AId;
  Status := AStatus;
end;

end.

