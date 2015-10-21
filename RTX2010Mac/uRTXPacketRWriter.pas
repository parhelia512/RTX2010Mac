//***************************************************************************
//
//       名称：uRTXPacketRWriter.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:44:54
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uRTXPacketRWriter;

interface

uses
  System.Classes,
  System.SysUtils,
  StreamRWriter;

type
  TRTXStream = class(TStreamRWriter)
  public
    function ReadUnicode: string;
    procedure WriteUnicode(const AStr: string);
    procedure SeekUnicode;
    function ReadUnicode2: string;
    procedure WriteUnicode2(const AStr: string);
    procedure SeekUnicode2;
    procedure WriteToken(AToken: TBytes);
    procedure WriteHexBytes(AHex: string);
  end;


implementation


{ TRTXStream }

uses uBytesHelper;

function TRTXStream.ReadUnicode: string;
var
  Len: Integer;
begin
  Result := '';
  Len := ReadByte;
  if Len > 0 then
    Result := TEncoding.Unicode.GetString(ReadBytes(Len - 2));
  ReadWord;
end;

function TRTXStream.ReadUnicode2: string;
var
  Len: Integer;
begin
  Result := '';
  Len := ReadWord;
  if Len > 0 then
    Result := TEncoding.Unicode.GetString(ReadBytes(Len - 2));
  ReadWord;
end;

procedure TRTXStream.SeekUnicode;
var
  Len: Integer;
begin
  Len := ReadByte;
  if Len > 0 then
    Seek(Len, soCurrent);
end;

procedure TRTXStream.SeekUnicode2;
var
  Len: Integer;
begin
  Len := ReadWord;
  if Len > 0 then
    Seek(Len, soCurrent);
end;

procedure TRTXStream.WriteHexBytes(AHex: string);
var
  I: Integer;
  LBytes: TBytes;
begin
  AHex := AHex.Replace(' ', '', [rfReplaceAll]);
  SetLength(LBytes, AHex.Length div 2);
  for I := 0 to LBytes.High do
   LBytes[I] := StrToIntDef('$' + Copy(AHex, I * 2 + 1, 2), 0);
  WriteBytes(LBytes);
end;

procedure TRTXStream.WriteToken(AToken: TBytes);
begin
  WriteByte(AToken.Length);
  WriteBytes(AToken);
end;

procedure TRTXStream.WriteUnicode(const AStr: string);
var
  Bs: TBytes;
begin
  Bs := TEncoding.Unicode.GetBytes(AStr + #0);
  WriteByte(Bs.Length);
  WriteBytes(Bs);
end;

procedure TRTXStream.WriteUnicode2(const AStr: string);
var
  Bs: TBytes;
begin
  Bs := TEncoding.Unicode.GetBytes(AStr + #0);
  WriteWord(Bs.Length);
  WriteBytes(Bs);
end;

end.
