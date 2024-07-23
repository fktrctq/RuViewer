program ConsoleRVS;

uses
  Vcl.Forms,
  ConsoleSrv in 'ConsoleSrv.pas' {MainF},
  SocketCrypt in 'SocketCrypt.pas',
  UIDGen in 'UIDGen.pas',
  FormAct in 'FormAct.pas' {FormActivation},
  GenPassword in 'GenPassword.pas' {GenNewPswd},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TMainF, MainF);
  Application.CreateForm(TFormActivation, FormActivation);
  Application.CreateForm(TGenNewPswd, GenNewPswd);
  Application.Run;
end.
