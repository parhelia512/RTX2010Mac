unit ufrmSetting;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls;

type
  Tfrm_Setting = class(TForm)
    tbc1: TTabControl;
    TabItem1: TTabItem;
    lbl1: TLabel;
    lbl2: TLabel;
    edt_Host: TEdit;
    edt_Port: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Setting: Tfrm_Setting;


implementation

{$R *.fmx}

uses uConfigFile, uGlobalDef;

procedure Tfrm_Setting.FormClose(Sender: TObject; var Action: TCloseAction);
var
  LConf: TRTXConfig;
begin
  LConf := TRTXConfig.Create;
  try
    LConf.Host := edt_Host.Text;
    LConf.Port := StrToIntDef(edt_Port.Text, DEFAULT_RTX_PORT);
  finally
    LConf.Free;
  end;
end;

procedure Tfrm_Setting.FormShow(Sender: TObject);
var
  LConf: TRTXConfig;
begin
  LConf := TRTXConfig.Create;
  try
    edt_Host.Text := LConf.Host;
    edt_Port.Text := LConf.Port.ToString;
  finally
    LConf.Free;
  end;
end;

end.
