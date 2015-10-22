object dm_RTXNetModule: Tdm_RTXNetModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object idtcpclnt_RTX: TIdTCPClient
    OnConnected = idtcpclnt_RTXConnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 16
    Top = 16
  end
  object tmr_RTXKeeplive: TTimer
    Enabled = False
    OnTimer = tmr_RTXKeepliveTimer
    Left = 48
    Top = 16
  end
end
