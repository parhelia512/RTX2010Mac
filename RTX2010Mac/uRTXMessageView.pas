//***************************************************************************
//
//       名称：uRTXMessageView.pas
//       工具：RAD Studio XE8
//       日期：2015/10/18 12:45:53
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uRTXMessageView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TreeView, FMX.Layouts, FMX.Edit, FMX.Objects;

type
  TRTXMessageItem = class(TControl)
  private

  end;

  TRTXMessageItems = class(TPersistent)
  private

  end;


  TRTXMessageView = class(TVertScrollBox)
  private
    constructor Create(AOwner: TComponent); override;
  end;

implementation




{ TRTXMessageView }

constructor TRTXMessageView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

end.
