object RuViewerSrvService: TRuViewerSrvService
  DisplayName = 'RuViewerSrvService'
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 187
  Width = 426
  PixelsPerInch = 96
  object TimerStartServerRuViewer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = TimerStartServerRuViewerTimer
    Left = 328
    Top = 96
  end
  object TimerStartServerClaster: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = TimerStartServerClasterTimer
    Left = 176
    Top = 96
  end
end
