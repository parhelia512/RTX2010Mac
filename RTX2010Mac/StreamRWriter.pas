//***************************************************************************
//
//       名称：StreamRWriter.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:45:11
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit StreamRWriter;

interface

uses
  System.Sysutils,
  System.Classes;

type
  TStreamRWriter = class
  private
    function GetStreamMemory: Pointer;
    function GetStreamPosition: Int64;
    function GetStreamSize: Int64;
    procedure SetStreamPosition(const Value: Int64);

   protected
    FStreamCreated: Boolean;
    FStream: TStream;
    FBigEndian: Boolean;
    FBytes: TBytes;
   public
    constructor Create(ABigEndian: Boolean); overload;
    constructor Create(inStream: TStream; ABigEndian: Boolean = True); overload;
    constructor Create(inBytes: TBytes; ABigEndian: Boolean = True); overload;
    constructor Create(APointer: Pointer; ALen: Integer; ABigEndian: Boolean = True); overload;
    destructor Destroy; override;
    class procedure ToBigEndian(Value: Pointer; nLen: Integer);
    function ReadByte: Byte;
    function ReadWord: Word;
    function ReadCardinal: Cardinal;
    function ReadUInt64: UInt64;
    function ReadShortInt: ShortInt;
    function ReadSmallInt: SmallInt;
    function ReadInteger: Integer;
    function ReadInt64: Int64;
    function ReadSingle: Single;
    function ReadDouble: Double;
    function ReadBytes(nLen: Word): TBytes; overload;
    procedure ReadBytes(var Buffer; Count: Longint); overload;

    procedure WriteByte(AValue: Byte);
    procedure WriteWord(AValue: Word);
    procedure WriteCardinal(AValue: Cardinal);
    procedure WriteUInt64(AValue: UInt64);
    procedure WriteShortInt(AValue: ShortInt);
    procedure WriteSmallInt(AValue: SmallInt);
    procedure WriteInteger(AValue: Integer);
    procedure WriteInt64(AValue: Int64);
    procedure WriteSingle(AValue: Single);
    procedure WriteDouble(AValue: Double);
    procedure WriteBytes(ABytes: TBytes; nLen: Integer); overload;
    procedure WriteBytes(ABytes: TBytes); overload;

    procedure LoadBytes(const ABytes: TBytes);
    procedure Seek(Offset: Longint; Origin: TSeekOrigin);
    procedure Clear;
    function GetBytes: TBytes;
   public
    property Size: Int64 read GetStreamSize;
    property Stream: TStream read FStream;
    property Position: Int64 read GetStreamPosition write SetStreamPosition;
    property Memory: Pointer read GetStreamMemory;
   end;


implementation


{ TReadConvert }


constructor TStreamRWriter.Create(inStream: TStream; ABigEndian: Boolean);
begin
  inherited Create;
  FStream := inStream;
  FStream.Position := 0;
  FBigEndian := ABigEndian;
  FStreamCreated := False;
end;

constructor TStreamRWriter.Create(APointer: Pointer; ALen: Integer; ABigEndian: Boolean);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FStream.Write(APointer^, ALen);
  FStream.Position := 0;
  FBigEndian := ABigEndian;
  FStreamCreated := True;
end;

constructor TStreamRWriter.Create(inBytes: TBytes; ABigEndian: Boolean);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FStream.Write(inBytes, 0, Length(inBytes));
  FStream.Position := 0;
  FBigEndian := ABigEndian;
  FStreamCreated := True;
end;

constructor TStreamRWriter.Create(ABigEndian: Boolean);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FBigEndian := ABigEndian;
  FStreamCreated := True;
end;

destructor TStreamRWriter.Destroy;
begin
  if FStreamCreated then
    FStream.Free;
  inherited;
end;

procedure TStreamRWriter.Clear;
begin
  if FStream is TMemoryStream then
    TMemoryStream(FStream).Clear;
end;

function TStreamRWriter.GetBytes: TBytes;
begin
  Result := nil;
  if FStream is TMemoryStream then
    if (FStream <> nil) and (FStream.Size > 0) then
    begin
      SetLength(Result, FStream.Size);
      Move(TMemoryStream(FStream).Memory^, Result[0], FStream.Size);
    end;
end;

function TStreamRWriter.GetStreamMemory: Pointer;
begin
  if FStream is TMemoryStream then
    Result := TMemoryStream(FStream).Memory
  else Result := nil;
end;

function TStreamRWriter.GetStreamPosition: Int64;
begin
  Result := FStream.Position;
end;

function TStreamRWriter.GetStreamSize: Int64;
begin
  Result := FStream.Size;
end;

procedure TStreamRWriter.LoadBytes(const ABytes: TBytes);
begin
  if Assigned(FStream) then
  begin
    Self.Clear;
    FStream.Write(ABytes[0], Length(ABytes));
    FStream.Position := 0;
  end;
end;

function TStreamRWriter.ReadByte: Byte;
begin
  FStream.Read(Result, SizeOf(Byte));
end;


procedure TStreamRWriter.ReadBytes(var Buffer; Count: Longint);
begin
  FStream.Read(Buffer, Count);
end;


function TStreamRWriter.ReadBytes(nLen: Word): TBytes;
begin
  SetLength(Result, nLen);
  FStream.Read(Result[0], nLen);
end;


function TStreamRWriter.ReadCardinal: Cardinal;
begin
  FStream.Read(Result, SizeOf(Cardinal));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Cardinal));
end;


function TStreamRWriter.ReadDouble: Double;
begin
  FStream.Read(Result, SizeOf(Double));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Double));
end;


function TStreamRWriter.ReadInt64: Int64;
begin
  FStream.Read(Result, SizeOf(Int64));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Int64));
end;


function TStreamRWriter.ReadInteger: Integer;
begin
  FStream.Read(Result, SizeOf(Integer));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Integer));
end;


function TStreamRWriter.ReadShortInt: ShortInt;
begin
  FStream.Read(Result, SizeOf(ShortInt));
end;


function TStreamRWriter.ReadSingle: Single;
begin
  FStream.Read(Result, SizeOf(Single));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Single));
end;


function TStreamRWriter.ReadSmallInt: SmallInt;
begin
  FStream.Read(Result, SizeOf(SmallInt));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(SmallInt));
end;


function TStreamRWriter.ReadUInt64: UInt64;
begin
  FStream.Read(Result, SizeOf(Uint64));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Uint64));
end;


function TStreamRWriter.ReadWord: Word;
begin
  FStream.Read(Result, SizeOf(Word));
  if FBigEndian then
    ToBigEndian(@Result, SizeOf(Word));
end;


procedure TStreamRWriter.Seek(Offset: Longint; Origin: TSeekOrigin);
begin
  FStream.Seek(Offset, Origin);
end;


procedure TStreamRWriter.SetStreamPosition(const Value: Int64);
begin
  FStream.Position := Value;
end;

class procedure TStreamRWriter.ToBigEndian(Value: Pointer; nLen: Integer);
var
 LWord: Word;
 LCardinal: Cardinal;
 LUInt64: UInt64;
begin
   case nLen of
     2 :
       begin
         LWord := (Word(PByte(Value)^) shl 8) + Word(PByte(Cardinal(Value) + 1)^);
         PWord(Value)^ := LWord;
       end;
     4 :
       begin
         LCardinal :=
            (Cardinal(PByte(Value)^) shl 24) +
            (Cardinal(PByte(Cardinal(Value) + 1)^) shl 16) +
            (Cardinal(PByte(Cardinal(Value) + 2)^) shl 8)  +
             Cardinal(PByte(Cardinal(Value) + 3)^);
         PCardinal(Value)^ := LCardinal;
       end;
     8 :
       begin
         LUInt64 :=
           (UInt64(PByte(Cardinal(Value) + 1)^) shl 56) +
           (UInt64(PByte(Value)^) shl 48) +
           (UInt64(PByte(Cardinal(Value) + 1)^) shl 40) +
           (UInt64(PByte(Cardinal(Value) + 2)^) shl 32) +
           (UInt64(PByte(Value)^) shl 24) +
           (UInt64(PByte(Cardinal(Value) + 1)^) shl 16) +
           (UInt64(PByte(Cardinal(Value) + 2)^) shl 8)  +
            UInt64(PByte(Cardinal(Value) + 3)^);
         PUInt64(Value)^ := LUInt64;
       end;
   end;
end;


procedure TStreamRWriter.WriteByte(AValue: Byte);
begin
  FStream.Write(AValue, SizeOf(Byte));
end;

procedure TStreamRWriter.WriteBytes(ABytes: TBytes);
begin
  WriteBytes(ABytes, Length(ABytes));
end;

procedure TStreamRWriter.WriteBytes(ABytes: TBytes; nLen: Integer);
begin
  FStream.Write(ABytes, 0, nLen);
end;

procedure TStreamRWriter.WriteCardinal(AValue: Cardinal);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Cardinal));
  FStream.Write(AValue, SizeOf(Cardinal));
end;

procedure TStreamRWriter.WriteDouble(AValue: Double);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Double));
  FStream.Write(AValue, SizeOf(Double));
end;

procedure TStreamRWriter.WriteInt64(AValue: Int64);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Int64));
  FStream.Write(AValue, SizeOf(Int64));
end;

procedure TStreamRWriter.WriteInteger(AValue: Integer);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Integer));
  FStream.Write(AValue, SizeOf(Integer));
end;

procedure TStreamRWriter.WriteShortInt(AValue: ShortInt);
begin
  FStream.Write(AValue, SizeOf(ShortInt));
end;

procedure TStreamRWriter.WriteSingle(AValue: Single);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Single));
  FStream.Write(AValue, SizeOf(Single));
end;

procedure TStreamRWriter.WriteSmallInt(AValue: SmallInt);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(SmallInt));
  FStream.Write(AValue, SizeOf(SmallInt));
end;

procedure TStreamRWriter.WriteUInt64(AValue: UInt64);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Uint64));
  FStream.Write(AValue, SizeOf(Uint64));
end;

procedure TStreamRWriter.WriteWord(AValue: Word);
begin
  if FBigEndian then
    ToBigEndian(@AValue, SizeOf(Word));
  FStream.Write(AValue, SizeOf(Word));
end;



end.
