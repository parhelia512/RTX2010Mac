object frm_RTXPacket: Tfrm_RTXPacket
  Left = 327
  Top = 168
  Caption = 'RTX'#25968#25454#21253#25318#25130#24037#20855' BY:ying32'
  ClientHeight = 636
  ClientWidth = 1027
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 0
    Top = 413
    Width = 1027
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = 8
    ExplicitTop = 317
    ExplicitWidth = 824
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1027
    Height = 145
    Align = alTop
    TabOrder = 0
    object lbl1: TLabel
      Left = 16
      Top = 16
      Width = 60
      Height = 13
      Caption = #36827#31243#21015#34920#65306
    end
    object lbl3: TLabel
      Left = 17
      Top = 83
      Width = 59
      Height = 13
      Caption = 'TouchKey'#65306
    end
    object lbl4: TLabel
      Left = 121
      Top = 56
      Width = 36
      Height = 13
      Caption = #23494#30721#65306
    end
    object lbl5: TLabel
      Left = 17
      Top = 110
      Width = 66
      Height = 13
      Caption = 'SessionKey'#65306
    end
    object lbl6: TLabel
      Left = 376
      Top = 56
      Width = 114
      Height = 39
      Caption = '*'#27492#21151#33021#38656#35201#33719#21462#20102#25910#21040#30340'0401'#21253#25968#25454#21253#25165#21487#20351#29992
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lbl8: TLabel
      Left = 247
      Top = 56
      Width = 101
      Height = 13
      Caption = #29992#20110#35299#23494'Sessionkey'
    end
    object lbl9: TLabel
      Left = 17
      Top = 56
      Width = 36
      Height = 13
      Caption = #24080#21495#65306
    end
    object lbl10: TLabel
      Left = 508
      Top = 55
      Width = 60
      Height = 13
      Caption = #36807#28388#35774#32622#65306
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbl11: TLabel
      Left = 508
      Top = 102
      Width = 378
      Height = 13
      Caption = #36807#28388#35774#32622'('#27599#20010#21442#25968#29992#31354#26684#38548#24320')'#65306'p:'#31471#21475#65292'i=ip'#65292'u='#29992#25143'uin'#65292'v='#21327#35758#29256#26412
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object cbb_ProcessList: TComboBox
      Left = 82
      Top = 13
      Width = 145
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      TabOrder = 4
    end
    object btn_refprocess: TButton
      Left = 233
      Top = 11
      Width = 56
      Height = 25
      Caption = #21047#26032
      TabOrder = 0
      OnClick = btn_refprocessClick
    end
    object btn_Start: TButton
      Left = 705
      Top = 12
      Width = 75
      Height = 25
      Caption = #24320#22987
      TabOrder = 1
      OnClick = btn_StartClick
    end
    object btn_Stop: TButton
      Left = 786
      Top = 11
      Width = 75
      Height = 25
      Caption = #20572#27490
      TabOrder = 2
      OnClick = btn_StopClick
    end
    object btn_Clear: TButton
      Left = 866
      Top = 12
      Width = 75
      Height = 25
      Action = act_clearpackets
      TabOrder = 3
    end
    object btn_GetAllKeys: TButton
      Left = 373
      Top = 105
      Width = 124
      Height = 25
      Caption = #19968#38190#33719#21462#25152#38656'KEY'
      TabOrder = 11
      OnClick = btn_GetAllKeysClick
    end
    object edt_TouchKey: TEdit
      Left = 96
      Top = 80
      Width = 271
      Height = 21
      TabOrder = 10
    end
    object edt_Passkey2: TEdit
      Left = 163
      Top = 53
      Width = 78
      Height = 21
      TabOrder = 8
      Text = '123'
    end
    object edt_SessionKey: TEdit
      Left = 96
      Top = 107
      Width = 271
      Height = 21
      TabOrder = 12
    end
    object edt_usr: TEdit
      Left = 48
      Top = 53
      Width = 67
      Height = 21
      TabOrder = 7
      Text = 'test1'
    end
    object edt_filter: TEdit
      Left = 508
      Top = 74
      Width = 501
      Height = 21
      TabOrder = 9
      Text = 'p:8000 i:192.168.0.2  v:$0101'
    end
    object btnMakeCommetFile: TButton
      Left = 922
      Top = 115
      Width = 87
      Height = 25
      Action = act_MakeCommetFile
      TabOrder = 13
      Visible = False
    end
    object btnLoadBuffer: TButton
      Left = 737
      Top = 42
      Width = 99
      Height = 25
      Action = act_LoadBuffer
      TabOrder = 5
    end
    object btnSaveBuffer: TButton
      Left = 842
      Top = 43
      Width = 99
      Height = 25
      Action = act_SaveBuffer
      TabOrder = 6
    end
    object btn1: TButton
      Left = 624
      Top = 43
      Width = 107
      Height = 25
      Caption = #27979#35797#36828#31243#35843#29992
      TabOrder = 14
      OnClick = btn1Click
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 145
    Width = 1027
    Height = 268
    Align = alClient
    TabOrder = 1
    object lv1: TListView
      Left = 1
      Top = 1
      Width = 1025
      Height = 266
      Align = alClient
      Columns = <
        item
          Caption = '-'
        end
        item
          Caption = #26102#38388
          Width = 110
        end
        item
          Caption = #26631#35782
          Width = 55
        end
        item
          Caption = #28304#22320#22336
          Width = 110
        end
        item
          Caption = #28304#31471#21475
          Width = 60
        end
        item
          Caption = #30446#26631#22320#22336
          Width = 110
        end
        item
          Caption = #30446#26631#31471#21475
          Width = 65
        end
        item
          Caption = #25968#25454#38271#24230
          Width = 100
        end
        item
          Caption = #29256#26412
          Width = 60
        end
        item
          Caption = #21629#20196
          Width = 60
        end
        item
          Caption = #21253#24207
          Width = 60
        end
        item
          Caption = 'UIN'
          Width = 65
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      PopupMenu = pm1
      TabOrder = 0
      ViewStyle = vsReport
      OnAdvancedCustomDrawItem = lv1AdvancedCustomDrawItem
      OnDblClick = lv1DblClick
    end
  end
  object stat1: TStatusBar
    Left = 0
    Top = 617
    Width = 1027
    Height = 19
    Panels = <
      item
        Width = 300
      end>
  end
  object pnl3: TPanel
    Left = 0
    Top = 416
    Width = 1027
    Height = 201
    Align = alBottom
    TabOrder = 2
    object spl2: TSplitter
      Left = 629
      Top = 1
      Height = 199
      Align = alRight
      ExplicitLeft = 584
      ExplicitTop = 112
      ExplicitHeight = 100
    end
    object mmo1: TMemo
      Left = 632
      Top = 1
      Width = 394
      Height = 199
      Align = alRight
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object pm1: TPopupMenu
    Left = 392
    Top = 272
    object SessionKey1: TMenuItem
      Action = act_UseSessionKeyDecrypt
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object HEX1: TMenuItem
      Action = act_CopyPacketBodyData
    end
    object HEX2: TMenuItem
      Action = act_CopyPacketData
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N0C001: TMenuItem
      Action = act_msg_0C00
    end
    object N0C011: TMenuItem
      Action = act_msg_0C01
    end
    object N0C021: TMenuItem
      Action = act_msg_0C02
    end
    object N0C022: TMenuItem
      Action = act_msg_0C02_recv
    end
    object N04051: TMenuItem
      Action = act_msg_0405_recv
    end
  end
  object actlst1: TActionList
    Left = 464
    Top = 276
    object act_UseTouchKeyDecrypt: TAction
      Category = 'ListViewPopup'
      Caption = #20351#29992'TouchKey'#35299#23494
    end
    object act_UseSessionKeyDecrypt: TAction
      Category = 'ListViewPopup'
      Caption = #20351#29992'SessionKey'#35299#23494
      OnExecute = act_UseSessionKeyDecryptExecute
    end
    object act_clearpackets: TAction
      Caption = #28165#31354#25968#25454
      OnExecute = act_clearpacketsExecute
      OnUpdate = act_clearpacketsUpdate
    end
    object act_UsePasskey2Decrypt: TAction
      Category = 'ListViewPopup'
      Caption = #20351#29992'PassKey2'#35299#23494
    end
    object act_hex_copysel: TAction
      Category = 'HexEditor'
      Caption = #22797#21046#36873#25321'(HEX)'
      OnExecute = act_hex_copyselExecute
      OnUpdate = act_hex_copyselUpdate
    end
    object act_converttotext: TAction
      Category = 'HexEditor'
      Caption = #36716#25442#36873#25321#33267'Unicode'#23383#31526#20018
      OnExecute = act_converttotextExecute
    end
    object act_MakeCommetFile: TAction
      Caption = #29983#25104#27880#35299#25991#20214
      OnExecute = act_MakeCommetFileExecute
      OnUpdate = act_MakeCommetFileUpdate
    end
    object act_SaveBuffer: TAction
      Caption = #20445#23384'Buffer'#33267#25991#20214
      OnExecute = act_SaveBufferExecute
    end
    object act_LoadBuffer: TAction
      Caption = #36733#20837'Buffer'#25991#20214
      OnExecute = act_LoadBufferExecute
    end
    object act_msg_0C00: TAction
      Caption = #22788#29702#21457#36865#30340'0C00'#28040#24687
      OnExecute = act_msg_0C00Execute
      OnUpdate = act_msg_0C00Update
    end
    object act_msg_0C01: TAction
      Caption = #22788#29702#25910#21040#30340'0C01'#28040#24687
      OnExecute = act_msg_0C01Execute
      OnUpdate = act_msg_0C01Update
    end
    object act_msg_0C02: TAction
      Caption = #22788#29702#21457#36865#30340'0C02'#28040#24687
      OnExecute = act_msg_0C02Execute
      OnUpdate = act_msg_0C02Update
    end
    object act_CopyPacketData: TAction
      Caption = #22797#21046#23436#25972#25968#25454#21253'(HEX)'
      OnExecute = act_CopyPacketDataExecute
      OnUpdate = act_CopyPacketDataUpdate
    end
    object act_CopyPacketBodyData: TAction
      Caption = #22797#21046#20027#20307#25968#25454#21253'(HEX)'
      OnExecute = act_CopyPacketBodyDataExecute
      OnUpdate = act_CopyPacketDataUpdate
    end
    object act_msg_0C02_recv: TAction
      Caption = #22788#29702#25910#21040#30340'0C02'#28040#24687
      OnExecute = act_msg_0C02_recvExecute
      OnUpdate = act_msg_0C02_recvUpdate
    end
    object act_msg_0405_recv: TAction
      Caption = #22788#29702#25910#21040#30340'0405'#28040#24687
      OnExecute = act_msg_0405_recvExecute
      OnUpdate = act_msg_0405_recvUpdate
    end
  end
  object pm_HexEditor: TPopupMenu
    Left = 616
    Top = 216
    object N1: TMenuItem
      Action = act_converttotext
    end
    object HEX3: TMenuItem
      Action = act_hex_copysel
    end
  end
  object dlgOpen1: TOpenDialog
    DefaultExt = 'rtxbuf'
    Filter = 'RTX'#25968#25454#21253#32531#23384#25991#20214'(*.rtxbuf)|*.rtxbuf'
    Left = 520
    Top = 280
  end
end
