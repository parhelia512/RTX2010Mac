program RTX2010;

uses
  FMX.Forms,
  uMain in 'uMain.pas' {frm_Main},
  ufrmLogin in 'ufrmLogin.pas' {frm_Login},
  uGlobalDef in 'uGlobalDef.pas',
  uRTXNetModule in 'uRTXNetModule.pas' {dm_RTXNetModule: TDataModule},
  QQTEA in 'QQTEA.pas',
  StreamRWriter in 'StreamRWriter.pas',
  uBytesHelper in 'uBytesHelper.pas',
  uRTXPacket in 'uRTXPacket.pas',
  uRTXPacketRWriter in 'uRTXPacketRWriter.pas',
  uRTXXMLData in 'uRTXXMLData.pas',
  uDebug in 'uDebug.pas',
  ufrmAbout in 'ufrmAbout.pas' {frm_About},
  uConfigFile in 'uConfigFile.pas',
  ufrmSetting in 'ufrmSetting.pas' {frm_Setting},
  uRTXMessageView in 'uRTXMessageView.pas',
  uSessionFrame in 'uSessionFrame.pas' {fra_Session: TFrame};

{$R *.res}

begin

  Application.Initialize;
  Application.CreateForm(Tdm_RTXNetModule, dm_RTXNetModule);
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(Tfrm_Setting, frm_Setting);
  Application.CreateForm(Tfrm_Login, frm_Login);
  Application.Run;
end.
