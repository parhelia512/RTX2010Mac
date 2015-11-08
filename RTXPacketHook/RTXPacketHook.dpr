library RTXPacketHook;

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  HookUtils,
  Winapi.Winsock2,
  uCommon in '..\X\uCommon.pas';

type
  TSend = function(s: TSocket; const buf; len, flags: Integer): Integer; stdcall;
  TRecv = function(s: TSocket; var buf; len, flags: Integer): Integer; stdcall;
  TConnect = function(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;

var
  Oldsend: TSend;
  Oldrecv: TRecv;
  OldConnect: TConnect;
  FHandle: THandle;
  RTX8000PortSocket: TSocket;



// 分析包用
{
  第一个包 0x400 send
  02      // head      0
  00 37   // len       1-2
  01 01   // version   3-2
  04 00   // cmd       5-2
  16 01   // seq       7-2
  00 00 00 00 // uin 第一个包为0  9-4
  0f 16 25 45 88 4f 20 7c 04 1b 81 78 fb 78 71 16 // key  13-16
  18 // tea encrypt data len 29-1
  fa 46 82 73 9f 56 81 d0 de 5b 4b 63 de 03 fa 96 fe a6
  83 1f 78 16 15 15 // data
  03 // tail

}


procedure ToBigEndian(Value: Pointer);
var
 LWord: Word;
begin
  LWord := (Word(PByte(Value)^) shl 8) + Word(PByte(Cardinal(Value) + 1)^);
         PWord(Value)^ := LWord;
end;

function GetPacketTempHead(P: Pointer; len: Integer): TRTXDataHeadRec;
begin
  Result.Version := 0;
  Result.Cmd := 0;
  Result.Uin := 0;
  if Assigned(P) and (len >= 12) then
  begin
    Result.Version := PWord(Cardinal(P)+3)^;
    Result.Cmd := PWord(Cardinal(P)+5)^;
    Result.Uin := PCardinal(Cardinal(P)+9)^;
    ToBigEndian(@Result.Version);
    ToBigEndian(@Result.Cmd);
    ToBigEndian(@Result.Uin);
  end;
end;

function GetPacketCmd(P: Pointer): Word;
begin
  Result := 0;
  if Assigned(P) then
    Result := PWord(Cardinal(P)+5)^;
  ToBigEndian(@result);
end;

procedure DumpCmd(p: Pointer; issend: boolean);
var
  s: string;
begin
  DateTimeToString(s, 'yyyy-mm-dd hh:nn:ss:zzz', now);
  OutputDebugString(PChar(Format('cmd=%s,  issend=%s,  time=%s', [GetPacketCmd(p).ToHexString(4), booltostr(issend, true), s])));
end;

procedure SendPacket(s: TSocket; const buf; len: Integer; IsSend: Boolean);
var
  LName: TSockAddr;
  LNamelen: Integer;
  LHead: TRTXDataHeadRec;
begin
  if Assigned(gSharePtr) and (len < SHARE_MEMORY_SIZE - SizeOf(TShareMemRec)) then
  begin
    gSharePtr^.SAddr := 0;
    gSharePtr^.SPort := 0;
    gSharePtr^.DAddr := 0;
    gSharePtr^.DPort := 0;
    if getsockname(s, LName, LNamelen) = NO_ERROR then
    begin
      if IsSend then
      begin
        gSharePtr^.SAddr := TSockAddrIn(LName).sin_addr.S_addr;
        gSharePtr^.SPort := ntohs(TSockAddrIn(LName).sin_port);
      end
      else
      begin
        gSharePtr^.DAddr := TSockAddrIn(LName).sin_addr.S_addr;
        gSharePtr^.DPort := ntohs(TSockAddrIn(LName).sin_port);
      end;
    end;
    if getpeername(s, LName, LNamelen) = NO_ERROR then
    begin
      if IsSend then
      begin
        gSharePtr^.DAddr := TSockAddrIn(LName).sin_addr.S_addr;
        gSharePtr^.DPort := ntohs(TSockAddrIn(LName).sin_port);
      end
      else
      begin
        gSharePtr^.SAddr := TSockAddrIn(LName).sin_addr.S_addr;
        gSharePtr^.SPort := ntohs(TSockAddrIn(LName).sin_port);
      end;
    end;
    {LHead := GetPacketTempHead(@buf, len);
    // 0则不过滤
    if gSharePtr^.FiterPort <> 0 then
    begin
      // 有时候因为初始的问题会取得端口失败。。。
      if (gSharePtr^.DPort <> gSharePtr^.FiterPort) and
         (gSharePtr^.SPort <> gSharePtr^.FiterPort) and
         (gSharePtr^.SPort <> 0) and (gSharePtr^.DPort <> 0) then
         Exit;
    end;

    if gSharePtr^.FiterVer <> 0 then
    begin
      if gSharePtr^.FiterVer <> LHead.Version then
        Exit;
    end;

    if gSharePtr^.FiterIpAddress <> 0 then
    begin
      if (gSharePtr^.SAddr <> gSharePtr^.FiterIpAddress) and
         (gSharePtr^.DAddr <> gSharePtr^.FiterIpAddress) and
         (gSharePtr^.SAddr <> 0) and (gSharePtr^.DAddr <> 0) then
         Exit;
    end;

    if gSharePtr^.FiterUin <> 0 then
    begin
      if gSharePtr^.FiterUin <> LHead.Uin then
         Exit;
    end;  }

    Move(buf, GetDataPtr^, len);
    SendMessage(gSharePtr^.hWd, FILE_MAP_RECV_MESSAGE, len, Integer(IsSend));
  end;
end;

function new_connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
begin
  if RTX8000PortSocket = 0 then
  begin
    if ntohs(TSockAddrIn(name).sin_port) = gSharePtr^.CapturePort then
      RTX8000PortSocket := s;
  end;
  Result := OldConnect(s, name, namelen);
end;

function new_send(s: TSocket; const buf; len, flags: Integer): Integer; stdcall;
begin
  SendPacket(s, buf, len, True);
  Result := Oldsend(s, buf, len, flags);
end;

function new_recv(s: TSocket; var buf; len, flags: Integer): Integer; stdcall;
begin
  Result := Oldrecv(s, buf, len, flags);
  SendPacket(s, buf, len, False);
end;

/// <summary>
///   远程调用的函数
/// </summary>
procedure SendRTXData(AData: Pointer); stdcall;
var
  LDataLen: Integer;
begin
  if AData <> nil then
  begin
    LDataLen := PInteger(AData)^;
    if (LDataLen > 0) and (RTX8000PortSocket <> 0) then
      new_send(RTX8000PortSocket, PByte(Cardinal(AData) + 4)^, LDataLen, 0);
    OutputDebugString(PChar(Format('调用senddata函数, 数据长度：%d', [LDataLen])));
  end;
end;

procedure RTXHookOn;
begin
  OutputDebugString('RTXHookOn');
  RTX8000PortSocket := 0;
  FHandle := OpenFileMapping(FILE_MAP_EXECUTE or FILE_MAP_READ or FILE_MAP_WRITE, False, 'global/rtxpacket/');
  if FHandle > 0 then
    gSharePtr := MapViewOfFile(FHandle, FILE_MAP_EXECUTE or FILE_MAP_READ or
      FILE_MAP_WRITE, 0, 0, 0);
  if gSharePtr <> nil then
  begin
    gSharePtr^.RemoteSendAddr := @SendRTXData;
    HookProcInModule('ws2_32.dll', 'connect', @new_connect, @OldConnect);
    HookProcInModule('ws2_32.dll', 'send', @new_send, @Oldsend);
    HookProcInModule('ws2_32.dll', 'recv', @new_recv, @Oldrecv);
  end;
end;

procedure RTXHookOff;
begin
  RTX8000PortSocket := 0;
  OutputDebugString('RTXHookOff');
  if FHandle <> 0 then
    Closehandle(FHandle);
  if gSharePtr <> nil then
  begin
    UnHook(@Oldrecv);
    UnHook(@Oldsend);
    UnHook(@OldConnect);
  end;
end;

{$R *.res}

procedure NewDllProc(nReason: DWORD); register;
begin
  case nReason of
    DLL_PROCESS_ATTACH:
      RTXHookOn;
    DLL_PROCESS_DETACH:
      RTXHookOff;
  end;
end;

begin
  DllProc := @NewDllProc;
  NewDllProc(DLL_PROCESS_ATTACH);
end.

