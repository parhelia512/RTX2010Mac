
=======
#RTX2010 for Mac
***
##Delphi开发RTX2010 Mac OS x客户端
***
#### **这个东西就是我随便玩玩的！**
#### **暂时还在继续开发中，还有很多没有弄，反正有空就整下吧**
***
***
##### 原协议参考[solosky](http://git.oschina.net/solosky/rtx)分析的协议，不过他的不全完，而且跟rtx2010的有些协议有点不一样，于是自己着手写了工具分析
***
### 目录结构及祥细情况
1. RTX2010Mac  ***-----------客户端主工程 DelphiXE8***
2. RTXPacketHook  ***-----------RTX Hook库 DelphiXE6***
3. X ***-----------分析工具  DelphiXE6***

*** 

###第三方库使用情况：
1. RTX2010中使用了RYYD编写的QQTEA.pas单元，由我增加支持Mac平台
2. RTXPacketHook 中使用了[wr960204武稀松](http://www.raysoftware.cn)的HookUtils.pas
3. X中使用了来自[CnPack团队](http://www.cnpack.org)的Cnvcl控件CnHexEditor.pas及CnMD5.pas单元 

![数据包分析工具](http://git.oschina.net/ying32/RTX2010Mac/xxx.png)
***
## 作者信息
***
ying32