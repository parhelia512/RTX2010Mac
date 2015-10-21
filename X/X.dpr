program X;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frm_RTXPacket},
  uRTXPacketRWriter in '..\RTX2010Mac\uRTXPacketRWriter.pas',
  StreamRWriter in '..\RTX2010Mac\StreamRWriter.pas',
  uBytesHelper in '..\RTX2010Mac\uBytesHelper.pas',
  QQTEA in '..\RTX2010Mac\QQTEA.pas',
  uCommon in 'uCommon.pas',
  uBufferFile in 'uBufferFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfrm_RTXPacket, frm_RTXPacket);
  Application.Run;
end.
