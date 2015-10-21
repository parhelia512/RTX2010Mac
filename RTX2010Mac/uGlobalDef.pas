//***************************************************************************
//
//       名称：uGlobalDef.pas
//       工具：RAD Studio XE8
//       日期：2015/10/16 20:44:38
//       作者：ying32
//       QQ  ：1444386932
//       E-mail：yuanfen3287@vip.qq.com
//       版权所有 (C) 2015-2015 ying32.com All Rights Reserved
//
//
//***************************************************************************
unit uGlobalDef;

interface

const
  /// <summary>
  ///   默认RTX端口，8000
  /// </summary>
  DEFAULT_RTX_PORT = 8000;

  /// <summary>
  ///   默认RTX主机地址
  /// </summary>
  DEFAULT_RTX_HOST = '192.168.0.2';
//  DEFAULT_RTX_HOST = '127.0.0.1';

var
  /// <summary>
  ///  全局标识，是否已经登录
  /// </summary>
  gIsLogin: Boolean;

implementation

end.
