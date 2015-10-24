//***************************************************************************
//
//       名称：uBytesHelper.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:44:07
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uBytesHelper;

interface

uses
  System.SysUtils;

type
  TBytesHelper = record helper for TBytes
  private
    function GetLength: Integer;
    function GetHigh: Integer;
  public
    function ToHexString: string; overload;
    class function ToHexString(ABytes: TBytes): string; overload; static;
    property Length: Integer read GetLength;
    property High: Integer read GetHigh;
  end;

implementation

{ TBytesHelper }

function TBytesHelper.GetHigh: Integer;
begin
  Result := High(Self);
end;

function TBytesHelper.GetLength: Integer;
begin
  Result := Length(Self);
end;

class function TBytesHelper.ToHexString(ABytes: TBytes): string;
begin
  Result := ABytes.ToHexString;
end;

function TBytesHelper.ToHexString: string;
var
  B: Byte;
begin
  Result := '';
  for B in Self do
    Result := Result + B.ToHexString(2) + ' ';
  Result := Result.Trim;
end;

end.
