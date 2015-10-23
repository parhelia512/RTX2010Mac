unit udm_Common;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList;

type
  Tdm_Common = class(TDataModule)
    il_common: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm_Common: Tdm_Common;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
