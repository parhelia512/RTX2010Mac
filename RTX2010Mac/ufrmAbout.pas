//***************************************************************************
//
//       名称：ufrmAbout.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:44:33
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit ufrmAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  Tfrm_About = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_About: Tfrm_About;

implementation

{$R *.fmx}

end.
