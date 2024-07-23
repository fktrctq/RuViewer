program RuViewerServerSrvc;



uses
  Vcl.SvcMgr,
  MainModule in 'MainModule.pas' {RuViewerSrvService: TService},
  DataBase in 'DataBase.pas' {DataModule2: TDataModule},
  RunOutConnect in 'RunOutConnect.pas',
  RunInConnect in 'RunInConnect.pas',
  FunctionPrefixServer in 'FunctionPrefixServer.pas',
  UIDgen in 'UIDgen.pas',
  SocketCrypt in 'SocketCrypt.pas';

{$R *.res}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TRuViewerSrvService, RuViewerSrvService);
  Application.CreateForm(TDataModule2, DataModule2);
  Application.Run;
end.
