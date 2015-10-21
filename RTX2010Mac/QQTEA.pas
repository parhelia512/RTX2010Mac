///----------------------------------------------------------\
//|               QQ TEA加密解密单元 Delphi版                |
//|                    Repacked by RYYD                      |
//|                      QQ:133880123                        |
//|                    Mail:Ryyd@163.com                     |
//|                                                          |
//|   调用接口:                                              |
//|       1.加密:EnCrypt(预加密串,加密Key),返回加密结果      |
//|       2.解密:DeCrypt(预解密串,解密Key),返回解密结果      |
//\----------------------------------------------------------/

unit QQTEA;

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils;

type
{$IFDEF MACOS}
  DWORD = Cardinal;
{$ENDIF}


  ByteType = TBytes;//array of Byte;

  TMYByte = array[0..50000] of byte;

  TQQTEA = class
  private
    M_LOnBits: array[0..30] of integer;
    M_L2Power: array[0..30] of integer;
    Plain: TMYByte;
    PrePlain: TMYByte;
    OutKey: TMYByte;
    Crypt, PreCrypt: Integer;
    Pos: Integer;
    Padding: Integer;
    Key: array of Byte;
    Header: Boolean;
    ContextStart: Integer;
    function Rand: Integer;
    procedure Initialize;
    procedure EnCrypt8Bytes;
    procedure ClearArray(var Arr: array of Byte);
    function UnsignedDel(Data1, Data2: Integer): Integer;
    function LShift(lValue: Longint; iShiftBits: Integer): DWORD;
    function RShift(lValue: Longint; iShiftBits: Integer): Integer;
    function UnsignedAdd(Data1: Integer; Data2: Integer): Integer;
    function DeCrypt8Bytes(InArray: array of byte; Offset: Integer): Boolean;
    function Decipher(InArray, KeyArray: array of Byte; Offset: Integer = 0): TMYByte;
    function Encipher(InArray, KeyArray: array of Byte; Offset: Integer = 0): TMYByte;
    function DeCrypt(InArray, KeyArray: array of byte; Offset: Integer): ByteType; overload;
    function EnCrypt(InArray, KeyArray: array of byte; Offset: Integer): ByteType; overload;
  public
    constructor Create;
    function DeCrypt(InArray, KeyArray: array of byte): ByteType; overload;
    function EnCrypt(InArray, KeyArray: array of byte): ByteType; overload;
  end;

function QQTEAEcCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;

function QQTEADeCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;

implementation

var
  QQTEAEnDe: TQQTEA;

{$IFDEF MACOS}
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
begin
  Move(Source^, Destination^, Length);
end;
{$ENDIF}

function QQTEAEcCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;
begin
  Result := QQTEAEnDe.EnCrypt(InArray, KeyArray);
end;

function QQTEADeCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;
begin
  Result := QQTEAEnDe.DeCrypt(InArray, KeyArray);
end;
//////////////////////////////////////////////////////////////////////

function TQQTEA.EnCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;
begin
  Result := EnCrypt(InArray, KeyArray, 0);
end;

function TQQTEA.DeCrypt(InArray: array of Byte; KeyArray: array of Byte): ByteType;
begin
  Result := DeCrypt(InArray, KeyArray, 0);
end;

function TQQTEA.EnCrypt(InArray, KeyArray: array of byte; Offset: Integer): ByteType;
var
  i: Integer;
  nLen: Integer;
  //  nMyLen:Integer;
  nSendLen: Integer;
begin
  Pos := 1;
  Crypt := 0;
  PreCrypt := 0;
  nLen := High(InArray) + 1;
  SetLength(Key, High(KeyArray) + 1);
  ClearArray(Key);
  CopyMemory(@Key[0], @KeyArray[0], High(KeyArray) + 1);
  Header := True;
  Pos := (nLen + 10) mod 8;
  if Pos <> 0 then
    Pos := 8 - Pos;
  nSendLen := nLen + Pos + 10;
  for i := 0 to 50000 do
  begin
    OutKey[i] := 0;
    PrePlain[i] := 0;
    Plain[i] := 0;
  end;
  Plain[0] := (Rand and $F8) or Pos;
  for i := 1 to Pos do
    Plain[I] := Rand and $FF;
  for i := 0 to 7 do
    PrePlain[i] := $0;
  Pos := Pos + 1;
  Padding := 1;
  while Padding < 3 do
  begin
    if Pos < 8 then
    begin
      Plain[Pos] := Rand and $FF;
      Padding := Padding + 1;
      Pos := Pos + 1;
    end
    else if Pos = 8 then
      EnCrypt8Bytes;
  end;
  i := Offset;
  while nLen > 0 do
  begin
    if Pos < 8 then
    begin
      Plain[Pos] := InArray[I];
      i := i + 1;
      Pos := Pos + 1;
      nLen := nLen - 1;
    end
    else if Pos = 8 then
      EnCrypt8Bytes;
  end;
  Padding := 1;
  while Padding < 9 do
  begin
    if Pos < 8 then
    begin
      Plain[Pos] := $0;
      Pos := Pos + 1;
      Padding := Padding + 1
    end
    else if Pos = 8 then
      EnCrypt8Bytes;
  end;
  SetLength(Result, nSendLen);
  CopyMemory(@Result[0], @OutKey[0], nSendLen);
end;

function TQQTEA.DeCrypt(InArray, KeyArray: array of byte; Offset: Integer): ByteType;
var
  m: array of byte;
  i: Integer;
  Count: Integer;
  nLen: Integer;
begin
  if (High(InArray) < 15) or (((High(InArray) + 1) mod 8) <> 0) then
    Exit;
  SetLength(m, Offset + 8);
  SetLength(Key, 16);
  CopyMemory(@Key[0], @KeyArray[0], 16);
  Crypt := 0;
  PreCrypt := 0;
  PrePlain := Decipher(InArray, KeyArray, Offset);
  Pos := PrePlain[0] and $7;
  Count := High(InArray) - Pos - 9;
  nLen := High(InArray) - Pos - 9;
  if Count < 0 then
    Exit;
  PreCrypt := 0;
  Crypt := 8;
  ContextStart := 8;
  Pos := Pos + 1;
  Padding := 1;
  while Padding < 3 do
  begin
    if Pos < 8 then
    begin
      Pos := Pos + 1;
      Padding := Padding + 1;
    end
    else if Pos = 8 then
    begin
      SetLength(m, high(InArray) + 1);
      CopyMemory(@m[0], @InArray[0], High(m) + 1);
      if not DeCrypt8Bytes(InArray, Offset) then
        Exit;
    end;
  end;
  i := 0;
  while Count <> 0 do
  begin
    if Pos < 8 then
    begin
      OutKey[I] := m[Offset + PreCrypt + Pos] xor PrePlain[Pos];
      i := i + 1;
      Count := Count - 1;
      Pos := Pos + 1;
    end
    else if Pos = 8 then
    begin
      SetLength(m, High(InArray) + 1);
      CopyMemory(@m[0], @InArray[0], High(InArray) + 1);
      PreCrypt := Crypt - 8;
      if not DeCrypt8Bytes(InArray, Offset) then
        Exit;
    end;
  end;
  for i := 1 to 7 do
  begin
    if Pos < 8 then
    begin
      if (m[Offset + PreCrypt + Pos] xor PrePlain[Pos]) <> 0 then
        Exit;
      Pos := Pos + 1;
    end
    else if Pos = 8 then
    begin
      CopyMemory(@m[0], @InArray[0], High(m) + 1);
      PreCrypt := Crypt;
      if not DeCrypt8Bytes(InArray, Offset) then
        Exit;
    end;
  end;
  SetLength(Result, nLen);
  CopyMemory(@Result[0], @OutKey[0], nLen);
end;

procedure TQQTEA.EnCrypt8Bytes;
var
  Crypted: TMYByte;
  i: Integer;
begin
  for i := 0 to 7 do
  begin
    if Header then
      Plain[i] := Plain[i] xor PrePlain[i]
    else
      Plain[i] := Plain[i] xor OutKey[PreCrypt + i];
  end;
  Crypted := Encipher(Plain, Key);
  for i := 0 to 7 do
    OutKey[Crypt + I] := Crypted[I];
  for i := 0 to 7 do
    OutKey[Crypt + i] := OutKey[Crypt + i] xor PrePlain[i];
  CopyMemory(@PrePlain[0], @Plain[0], 8);
  PreCrypt := Crypt;
  Crypt := Crypt + 8;
  Pos := 0;
  Header := False
end;

function TQQTEA.DeCrypt8Bytes(InArray: array of byte; Offset: Integer): Boolean;
var
  i: Integer;
begin
  for i := 0 to 7 do
  begin
    if (ContextStart + i) > (High(InArray)) then
    begin
      Result := True;
      Exit;
    end;
    PrePlain[i] := PrePlain[i] xor InArray[Offset + Crypt + i];
  end;
  try
    PrePlain := Decipher(PrePlain, Key);
  except
    Result := False;
    Exit;
  end;
  ContextStart := ContextStart + 8;
  Crypt := Crypt + 8;
  Pos := 0;
  Result := True;
end;

function TQQTEA.Encipher(InArray, KeyArray: array of Byte; Offset: Integer): TMYByte;
var
  i, y, z, a, b, c, d: Longword;
  sum, delta: Longword;
  TempArray: array[0..23] of Byte;
  //  TempOut:TMYByte;
begin
  if High(InArray) < 7 then
    Exit;
  if High(KeyArray) < 15 then
    Exit;
  sum := 0;
  delta := $9E3779B9;
  delta := delta and $FFFFFFFF;
  TempArray[3] := InArray[Offset];
  TempArray[2] := InArray[Offset + 1];
  TempArray[1] := InArray[Offset + 2];
  TempArray[0] := InArray[Offset + 3];
  TempArray[7] := InArray[Offset + 4];
  TempArray[6] := InArray[Offset + 5];
  TempArray[5] := InArray[Offset + 6];
  TempArray[4] := InArray[Offset + 7];
  TempArray[11] := KeyArray[0];
  TempArray[10] := KeyArray[1];
  TempArray[9] := KeyArray[2];
  TempArray[8] := KeyArray[3];
  TempArray[15] := KeyArray[4];
  TempArray[14] := KeyArray[5];
  TempArray[13] := KeyArray[6];
  TempArray[12] := KeyArray[7];
  TempArray[19] := KeyArray[8];
  TempArray[18] := KeyArray[9];
  TempArray[17] := KeyArray[10];
  TempArray[16] := KeyArray[11];
  TempArray[23] := KeyArray[12];
  TempArray[22] := KeyArray[13];
  TempArray[21] := KeyArray[14];
  TempArray[20] := KeyArray[15];
  CopyMemory(@y, @TempArray[0], 4);
  CopyMemory(@z, @TempArray[4], 4);
  CopyMemory(@a, @TempArray[8], 4);
  CopyMemory(@b, @TempArray[12], 4);
  CopyMemory(@c, @TempArray[16], 4);
  CopyMemory(@d, @TempArray[20], 4);
  for i := 1 to 16 do
  begin
    sum := UnsignedAdd(sum, delta);
    sum := sum and $FFFFFFFF;
    y := UnsignedAdd(y, UnsignedAdd(LShift(z, 4), a) xor UnsignedAdd(z, sum) xor UnsignedAdd(RShift
(z, 5), b));
    Y := Y and $FFFFFFFF;
    z := UnsignedAdd(z, UnsignedAdd(LShift(y, 4), c) xor UnsignedAdd(y, sum) xor UnsignedAdd(RShift
(y, 5), d));
    z := z and $FFFFFFFF;
  end;
  CopyMemory(@TempArray[0], @Y, 4);
  CopyMemory(@TempArray[4], @z, 4);
  Result[0] := TempArray[3];
  Result[1] := TempArray[2];
  Result[2] := TempArray[1];
  Result[3] := TempArray[0];
  Result[4] := TempArray[7];
  Result[5] := TempArray[6];
  Result[6] := TempArray[5];
  Result[7] := TempArray[4];
end;

function TQQTEA.Decipher(InArray, KeyArray: array of Byte; Offset: Integer = 0): TMYByte;
var
  i, y, z, a, b, c, d: Longint;
  sum, delta: DWORD;
  TempArray: array[0..23] of Byte;
  TempOut: array[0..7] of Byte;
begin
  if High(InArray) < 7 then
    Exit;
  if High(KeyArray) < 15 then
    Exit;
  sum := $E3779B90;
  sum := sum and $FFFFFFFF;
  delta := $9E3779B9;
  delta := delta and $FFFFFFFF;
  TempArray[3] := InArray[Offset];
  TempArray[2] := InArray[Offset + 1];
  TempArray[1] := InArray[Offset + 2];
  TempArray[0] := InArray[Offset + 3];
  TempArray[7] := InArray[Offset + 4];
  TempArray[6] := InArray[Offset + 5];
  TempArray[5] := InArray[Offset + 6];
  TempArray[4] := InArray[Offset + 7];
  TempArray[11] := KeyArray[0];
  TempArray[10] := KeyArray[1];
  TempArray[9] := KeyArray[2];
  TempArray[8] := KeyArray[3];
  TempArray[15] := KeyArray[4];
  TempArray[14] := KeyArray[5];
  TempArray[13] := KeyArray[6];
  TempArray[12] := KeyArray[7];
  TempArray[19] := KeyArray[8];
  TempArray[18] := KeyArray[9];
  TempArray[17] := KeyArray[10];
  TempArray[16] := KeyArray[11];
  TempArray[23] := KeyArray[12];
  TempArray[22] := KeyArray[13];
  TempArray[21] := KeyArray[14];
  TempArray[20] := KeyArray[15];
  CopyMemory(@y, @TempArray[0], 4);
  CopyMemory(@z, @TempArray[4], 4);
  CopyMemory(@a, @TempArray[8], 4);
  CopyMemory(@b, @TempArray[12], 4);
  CopyMemory(@c, @TempArray[16], 4);
  CopyMemory(@d, @TempArray[20], 4);
  for i := 1 to 16 do
  begin
    z := UnsignedDel(z, (UnsignedAdd(LShift(y, 4), c) xor UnsignedAdd(y, sum) xor UnsignedAdd(RShift
(y, 5), d)));
    z := z and $FFFFFFFF;
    y := UnsignedDel(y, (UnsignedAdd(LShift(z, 4), a) xor UnsignedAdd(z, sum) xor UnsignedAdd(RShift
(z, 5), b)));
    y := y and $FFFFFFFF;
    sum := UnsignedDel(sum, delta);
    sum := sum and $FFFFFFFF;
  end;
  CopyMemory(@TempArray[0], @Y, 4);
  CopyMemory(@TempArray[4], @z, 4);
  TempOut[0] := TempArray[3];
  TempOut[1] := TempArray[2];
  TempOut[2] := TempArray[1];
  TempOut[3] := TempArray[0];
  TempOut[4] := TempArray[7];
  TempOut[5] := TempArray[6];
  TempOut[6] := TempArray[5];
  TempOut[7] := TempArray[4];
  CopyMemory(@Result[0], @TempOut[0], 8);
end;

function TQQTEA.LShift(lValue: Longint; iShiftBits: Integer): DWORD;
begin
//  Result := 0;
  if iShiftBits = 0 then
  begin
    Result := lValue;
    Exit;
  end
  else if iShiftBits = 31 then
  begin
    if (lValue and 1) <> 0 then
      Result := $80000000
    else
      result := 0;
    Exit;
  end
  else if (iShiftBits < 0) or (iShiftBits > 31) then
    raise Exception.Create('数据转换错误');
  if (lValue and M_L2Power[31 - iShiftBits]) <> 0 then
    Result := ((lValue and M_LOnBits[31 -
(iShiftBits + 1)]) * M_L2Power[iShiftBits]) or $80000000
  else
    Result := ((lValue and M_LOnBits[31 - iShiftBits]) * M_L2Power[iShiftBits]);
end;

function TQQTEA.RShift(lValue: Longint; iShiftBits: Integer): Integer;
begin
  if iShiftBits = 0 then
  begin
    RShift := lValue;
    Exit;
  end
  else if iShiftBits = 31 then
  begin
    if (lValue and $80000000) <> 0 then
      RShift := 1
    else
      RShift := 0;
    Exit;
  end
  else if (iShiftBits < 0) or (iShiftBits > 31) then
    raise Exception.Create('数据转换错误');
  Result := (lValue and $7FFFFFFE) div M_L2Power[iShiftBits];
  if (lValue and $80000000) <> 0 then
    Result := (Result or ($40000000 div M_L2Power[iShiftBits - 1]))
end;

function TQQTEA.UnsignedAdd(Data1: Integer; Data2: Integer): Integer;
var
  x1: array[0..3] of byte;
  x2: array[0..3] of byte;
  xx: array[0..3] of byte;
  Rest, value, a: Integer;
begin
  CopyMemory(@x1[0], @Data1, 4);
  CopyMemory(@x2[0], @Data2, 4);
  Rest := 0;
  for a := 0 to 3 do
  begin
    value := Round(x1[a]) + Round(x2[a]) + Rest;
    xx[a] := value and 255;
    Rest := value div 256;
  end;
  CopyMemory(@Result, @xx[0], 4);
end;

function TQQTEA.UnsignedDel(Data1, Data2: Integer): Integer;
var
  x1: array[0..3] of byte;
  x2: array[0..3] of byte;
  xx: array[0..3] of byte;
  Rest, value, a: Integer;
begin
  CopyMemory(@x1[0], @Data1, 4);
  CopyMemory(@x2[0], @Data2, 4);
  CopyMemory(@xx[0], @Result, 4);
  Rest := 0;
  for a := 0 to 3 do
  begin
    value := Round(x1[a]) - Round(x2[a]) - Rest;
    if (value < 0) then
    begin
      value := value + 256;
      Rest := 1;
    end
    else
      Rest := 0;
    xx[a] := value;
  end;
  CopyMemory(@Result, @xx[0], 4);
end;

procedure TQQTEA.Initialize();
begin
  Randomize;

  M_LOnBits[0] := 1;
  M_LOnBits[1] := 3;
  M_LOnBits[2] := 7;
  M_LOnBits[3] := 15;
  M_LOnBits[4] := 31;
  M_LOnBits[5] := 63;
  M_LOnBits[6] := 127;
  M_LOnBits[7] := 255;
  M_LOnBits[8] := 511;
  M_LOnBits[9] := 1023;
  M_LOnBits[10] := 2047;
  M_LOnBits[11] := 4095;
  M_LOnBits[12] := 8191;
  M_LOnBits[13] := 16383;
  M_LOnBits[14] := 32767;
  M_LOnBits[15] := 65535;
  M_LOnBits[16] := 131071;
  M_LOnBits[17] := 262143;
  M_LOnBits[18] := 524287;
  M_LOnBits[19] := 1048575;
  M_LOnBits[20] := 2097151;
  M_LOnBits[21] := 4194303;
  M_LOnBits[22] := 8388607;
  M_LOnBits[23] := 16777215;
  M_LOnBits[24] := 33554431;
  M_LOnBits[25] := 67108863;
  M_LOnBits[26] := 134217727;
  M_LOnBits[27] := 268435455;
  M_LOnBits[28] := 536870911;
  M_LOnBits[29] := 1073741823;
  M_LOnBits[30] := 2147483647;

  M_L2Power[0] := 1;
  M_L2Power[1] := 2;
  M_L2Power[2] := 4;
  M_L2Power[3] := 8;
  M_L2Power[4] := 16;
  M_L2Power[5] := 32;
  M_L2Power[6] := 64;
  M_L2Power[7] := 128;
  M_L2Power[8] := 256;
  M_L2Power[9] := 512;
  M_L2Power[10] := 1024;
  M_L2Power[11] := 2048;
  M_L2Power[12] := 4096;
  M_L2Power[13] := 8192;
  M_L2Power[14] := 16384;
  M_L2Power[15] := 32768;
  M_L2Power[16] := 65536;
  M_L2Power[17] := 131072;
  M_L2Power[18] := 262144;
  M_L2Power[19] := 524288;
  M_L2Power[20] := 1048576;
  M_L2Power[21] := 2097152;
  M_L2Power[22] := 4194304;
  M_L2Power[23] := 8388608;
  M_L2Power[24] := 16777216;
  M_L2Power[25] := 33554432;
  M_L2Power[26] := 67108864;
  M_L2Power[27] := 134217728;
  M_L2Power[28] := 268435456;
  M_L2Power[29] := 536870912;
  M_L2Power[30] := 1073741824;
end;

function TQQTEA.Rand: Integer;
begin
  Result := Random(256);
end;

constructor TQQTEA.Create;
begin
  Initialize;
end;

procedure TQQTEA.ClearArray(var Arr: array of Byte);
var
  i: Integer;
begin
  for i := 0 to High(Arr) do
    Arr[i] := 0;
end;

initialization
  QQTEAEnDe := TQQTEA.Create;

finalization
  QQTEAEnDe.Free;

end.

