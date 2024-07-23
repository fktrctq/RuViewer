object RuViewerSrvc: TRuViewerSrvc
  AllowPause = False
  DisplayName = 'ServiceRuViewer'
  Interactive = True
  AfterInstall = ServiceAfterInstall
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
  PixelsPerInch = 96
end
