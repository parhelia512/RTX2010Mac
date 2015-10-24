unit uBufferFile;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  uCommon;

type
  TBufferFile = class
  private const
    FILE_HEAD: array[0..8] of byte = ($52, $54, $58, $42, $55, $46, $46, $45, $52);
    FILE_VERSION: Word = 1;
  private
    FStream: TMemoryStream;
    FList: TList<TRTXDataRec>;
//    FTouchKey: TBytes;
//    FPassKey2: TBytes;
//    FNameKey: TBytes;
    FSessionKey: TBytes;
    procedure SetSessionKey(const Value: TBytes);
  public
    constructor Create(const AList: TList<TRTXDataRec>);
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    property SessionKey: TBytes read FSessionKey write SetSessionKey;
  end;

implementation

{ TBufferFile }

uses uBytesHelper;

constructor TBufferFile.Create(const AList: TList<TRTXDataRec>);
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FList := AList;
  SetLength(FSessionKey, $10);
end;

destructor TBufferFile.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TBufferFile.LoadFromFile(const AFileName: string);
var
  LItem: TRTXDataRec;
  LHead: array[0..8] of Byte;
  LVer: Word;
  LSize, LSize2: Integer;
  I: Integer;
begin
  if Assigned(FList) then
  begin
    FList.Clear;
    FStream.LoadFromFile(AFileName);
    FStream.Position := 0;
    FStream.Read(LHead, Length(FILE_HEAD));
    if CompareMem(@LHead, @FILE_HEAD, SizeOf(FILE_HEAD)) then
    begin
      FStream.Read(LVer, 2);
      FStream.Read(LSize, 4);
      FStream.Read(FSessionKey, 0, FSessionKey.Length);
      for I := 1 to LSize do
      begin
        FStream.Read(LItem.DataSize, 4);
        FStream.Read(LItem.IsSend, SizeOf(Boolean));
        FStream.Read(LSize2, 4);
        SetLength(LItem.TestBytes, LSize2);
        FStream.Read(LItem.TestBytes, 0, LSize2);

        FStream.Read(LItem.SAddr, 4);
        FStream.Read(LItem.SPort, 2);
        FStream.Read(LItem.DAddr, 4);
        FStream.Read(LItem.DPort, 2);

        FStream.Read(LItem.Head, 1);
        FStream.Read(LItem.Len, 2);
        FStream.Read(LItem.Version, 2);
        FStream.Read(LItem.Cmd, 2);
        FStream.Read(LItem.Seq, 2);
        FStream.Read(LItem.Uin, 4);
        FStream.Read(LSize2, 4);
        SetLength(LItem.Data, LSize2);
        FStream.Read(Litem.Data, 0, LSize2);
        FStream.Read(LItem.Tail, 1);
        FList.Add(LItem);
      end;
    end;
  end;
end;

procedure TBufferFile.SaveToFile(const AFileName: string);
var
  LItem: TRTXDataRec;
  LInt: Integer;
begin
  FStream.Clear;
  FStream.Write(FILE_HEAD, Length(FILE_HEAD));
  FStream.Write(FILE_VERSION, 2);
  FStream.Write(FList.Count, 4);

  FStream.Write(FSessionKey, 0, FSessionKey.Length);

  for LItem in FList do
  begin
    FStream.Write(LItem.DataSize, 4);
    FStream.Write(LItem.IsSend, SizeOf(Boolean));
    LInt := Litem.TestBytes.Length;
    FStream.Write(LInt, 4);
    FStream.Write(LItem.TestBytes, 0, LItem.TestBytes.Length);

    FStream.Write(LItem.SAddr, 4);
    FStream.Write(LItem.SPort, 2);
    FStream.Write(LItem.DAddr, 4);
    FStream.Write(LItem.DPort, 2);

    FStream.Write(LItem.Head, 1);
    FStream.Write(LItem.Len, 2);
    FStream.Write(LItem.Version, 2);
    FStream.Write(LItem.Cmd, 2);
    FStream.Write(LItem.Seq, 2);
    FStream.Write(LItem.Uin, 4);
    LInt := LItem.Data.Length;
    FStream.Write(LInt, 4);
    FStream.Write(Litem.Data, 0, LItem.Data.Length);
    FStream.Write(LItem.Tail, 1);
  end;
  FStream.SaveToFile(AFileName);
end;

procedure TBufferFile.SetSessionKey(const Value: TBytes);
begin
  if Assigned(Value) and (Value.Length = $10) then
    Move(Value[0], FSessionKey[0], Value.Length);
end;

end.
