unit uRTXPacketType;

interface

uses
  System.Generics.Collections;

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

  TRTXSesions = class(TDictionary<string, TRTXSession>);

  /// <summary>
  ///   成员信息, 暂时就解析出了以下信息
  /// </summary>
  TRTXMemberInfo = record
    UserName: string;
    UID: Cardinal;
    UserName2: string;
    NickName: string;
    PhoneNum1: string;
    PhoneNum2: string;
    Email: string;
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

implementation

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
