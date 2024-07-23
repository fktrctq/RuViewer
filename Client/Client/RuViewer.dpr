program RuViewer;
uses
  Vcl.Forms,
  Winapi.Windows,
  SysUtils,
  ShellAPI,
  Classes,
  WinSvc,
  ActiveX,
  Form_Main in 'Form_Main.pas' {frm_Main},
  Form_Password in 'Form_Password.pas' {frm_Password},
  Form_RemoteScreen in 'Form_RemoteScreen.pas' {frm_RemoteScreen},
  Vcl.Themes,
  Vcl.Styles,
  Form_Chat in 'Form_Chat.pas' {frm_Chat},
  Form_ShareFiles in 'Form_ShareFiles.pas' {frm_ShareFiles},
  Form_Settings in 'Form_Settings.pas' {Form_set},
  PipeS in 'PipeS.pas',
  Osher in 'Osher.pas' {FormOsher},
  MyClpbrd in 'MyClpbrd.pas',
  FfmProgress in 'FfmProgress.pas' {FrmMyProgress},
  ThReadMainTargetID in 'ThReadMainTargetID.pas',
  ThReadMyClipboard in 'ThReadMyClipboard.pas',
  ThReadMainID in 'ThReadMainID.pas',
  FormReconnect in 'FormReconnect.pas' {FReconnect},
  SocketCrypt in 'SocketCrypt.pas',
  UID in 'UID.pas',
  FileTransfer in 'FileTransfer.pas' {FormFileTransfer},
  ThReadCopyFileFolder in 'ThReadCopyFileFolder.pas',
  ThReadDelete in 'ThReadDelete.pas',
  FormSetLevelPrivelage in 'FormSetLevelPrivelage.pas' {FormPrivilage},
  ScanKey in 'ScanKey.pas',
  StreamManager in 'StreamManager.pas';

function CreateEnvironmentBlock(var lpEnvironment: Pointer; hToken: THandle; bInherit: BOOL): BOOL;
                                    stdcall; external 'Userenv.dll';
function DestroyEnvironmentBlock(pEnvironment: Pointer): BOOL; stdcall; external 'Userenv.dll';
{$R *.res}


function IsAccountSystem: Boolean;
var
  hToken: THandle;
  pTokenUser: ^TTokenUser;
  dwInfoBufferSize: DWORD;
  pSystemSid: PSID;
const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_LOCAL_SYSTEM_RID = $00000012;
begin
  if not OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hToken) then
  begin
    Result := False;
    Exit;
  end;
  GetMem(pTokenUser, 1024);
  if not GetTokenInformation(hToken, TokenUser, pTokenUser, 1024, dwInfoBufferSize) then
  begin
    CloseHandle(hToken);
    Result := False;
    Exit;
  end;
  CloseHandle(hToken);
  if not AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 1, SECURITY_LOCAL_SYSTEM_RID, 0, 0, 0, 0, 0, 0, 0, pSystemSid) then
  begin
    Result := False;
    Exit;
  end;
  Result := EqualSid(pTokenUser.User.Sid, pSystemSid);
  FreeSid(pSystemSid);
end;
//---------------------------------------------
function ServiceGetStatus(sMachine, sService: PChar): DWORD; // проверка состояния службы
{******************************************}
  {*** Parameters: ***}
  {*** sService: specifies the name of the service to open
  {*** sMachine: specifies    the name of the target computer
  {*** ***}
  {*** Return Values: ***}
  {*** -1 = Error opening service ***}
  {*** 1 = SERVICE_STOPPED ***}
  {*** 2 = SERVICE_START_PENDING ***}
  {*** 3 = SERVICE_STOP_PENDING ***}
  {*** 4 = SERVICE_RUNNING ***}
  {*** 5 = SERVICE_CONTINUE_PENDING ***}
  {*** 6 = SERVICE_PAUSE_PENDING ***}
  {*** 7 = SERVICE_PAUSED ***}
  {******************************************}

var
  SCManHandle, SvcHandle: SC_Handle;
  SS: TServiceStatus;
  dwStat: DWORD;
begin
  dwStat := 0;
  // Open service manager handle.
  SCManHandle := OpenSCManager(sMachine, SERVICES_ACTIVE_DATABASE, SC_MANAGER_CONNECT);
  if (SCManHandle > 0) then
  begin
    SvcHandle := OpenService(SCManHandle, sService, SERVICE_QUERY_STATUS);
    // if Service installed
    if (SvcHandle > 0) then
    begin
      // SS structure holds the service status (TServiceStatus);
      if (QueryServiceStatus(SvcHandle, SS)) then
        dwStat := ss.dwCurrentState;
      CloseServiceHandle(SvcHandle);
    end;
    CloseServiceHandle(SCManHandle);
  end;
  Result := dwStat;
end;

function ServiceRunning(sMachine, sService: PChar): DWORD;
begin
  Result :=ServiceGetStatus(sMachine, sService);
end;
//---------------------------------------------   //запушен ли от имениадминистратора
function EnablePrivilege(const Value: Boolean; privilegename: string): Boolean;
var
  hToken: THandle;
  tp: TOKEN_PRIVILEGES;
  d: dword;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken) then
  begin
    tp.PrivilegeCount := 1;
    LookupPrivilegeValue(nil, pchar(privilegename), tp.Privileges[0].Luid);
    if Value then
      tp.Privileges[0].Attributes := $00000002
    else
      tp.Privileges[0].Attributes := $80000000;
    AdjustTokenPrivileges(hToken, False, tp, SizeOf(TOKEN_PRIVILEGES), nil, d);
    if GetLastError = ERROR_SUCCESS then
    begin
      Result := true;
    end;
    CloseHandle(hToken);
  end;
end;
//----------------------------------------------
function RunProcessAsCurrentUser(FileName,CommandLine: PwideChar): Boolean; // RunAsSystem
var
  ProcessId: Integer;
  hWindow, hProcess, TokenHandle: THandle;
  si: Tstartupinfo;
  p: Tprocessinformation;
  lpEnvironment: Pointer;
begin
  Result := False;

  hWindow := FindWindow('Progman', 'Program Manager');
  if hWindow = 0 then
  begin
  SysErrorMessage(GetLastError);
   //Exit;
  end;

  if GetWindowThreadProcessID(hWindow, @ProcessID)=0 then
  SysErrorMessage(GetLastError);
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, ProcessID); //GetCurrentProcess();
  if hProcess = 0 then
  begin
  SysErrorMessage(GetLastError);
   //Exit;
  end;

  try
    if not OpenProcessToken(hProcess, TOKEN_ALL_ACCESS, TokenHandle) then
    begin
    SysErrorMessage(GetLastError);
    //Exit;
    end;

    FillChar(si,SizeOf(si),0);
    with Si do begin
      cb := SizeOf( Si);
      dwFlags := startf_UseShowWindow;
      wShowWindow := SW_NORMAL;
      lpDesktop := PChar('winsta0\default');
    end;

    lpEnvironment := nil;
    if not CreateEnvironmentBlock(lpEnvironment, TokenHandle, FALSE)then
    SysErrorMessage(GetLastError);
    try
      Result := CreateProcessAsUser(TokenHandle,FileName,CommandLine,
        nil, nil, FALSE, CREATE_UNICODE_ENVIRONMENT, //CREATE_DEFAULT_ERROR_MODE
        lpEnvironment, nil, si, p);
    finally
      DestroyEnvironmentBlock(lpEnvironment);
    end;
  finally
    CloseHandle(hProcess);
  end;
end;

function currentsession:DWORD; // текущий сеанс пользователя
 var
SessionId: DWORD;
begin
if ProcessIdToSessionId(GetCurrentProcessId, SessionId) then
result:=SessionId;
end;
//--------------------------------------------------
var
 hDesktop: HDESK;
 mesg:String;
 StatusServices:cardinal;
 RunAsSys:boolean;
 i:integer;
 isRunSys:boolean;
begin

Application.Initialize;
 RunAsSys:=EnablePrivilege(true,'SeDebugPrivilege'); // есть ли права администратора
 StatusServices:=ServiceRunning('','RuViewerSrvc'); // проверяем статус службы на локальной машине по системному имени службы

{ isRunSys:=false;
 if RunAsSys and (StatusServices<>4) then // если запустили от имени админа и служба не установлена
  begin
    for I := 0 to ParamCount-1 do
     begin
       if ParamStr(i)='/systemrun/' then // Проверяем, не произошол ли уже запуск от имени системы
        begin
        isRunSys:=true;
        break;
        end;
     end;
     if not isRunSys then //если перезапуск уже не был осуществлен
     begin
       RunProcessAsCurrentUser(PwideChar(paramStr(0)),PwideChar(paramStr(1)+' '+paramStr(2)+' '+paramStr(3)+' '+'/systemrun/'));
       Application.Terminate;
     end;
   end;}

    // проверить и раскоментированть после того как все будет работать
     if StatusServices=4 then // если служба запушена то просим нас запустить не зависимо от наличия прав админитсртаора
      if ParamStr(1)='' then // если первый параметр пустой то приложение запущено вручную
       begin
        mesg:='<|FORCERUN|>'+inttostr(currentsession)+'<|END|>';
        TPBPipeClient.SendData('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5',mesg ); // отправляем сообщение службе
        mesg:='';
        Application.Terminate;
        exit;
       end;

    if not RunAsSys then // если прав админа нет
       begin
       if (StatusServices=-1) or (StatusServices=0)  then // -1 не можем получить доступ. 0 - если такой службы нет, и программа запущена не от имени администратора
       begin                                                  // отображаемое имя службы
       MessageBox(Application.handle, PChar('Установите службу ServiceRuViewer'+#10#13+'и повторите попытку запуска.'), PChar('Ошибка запуска программы'), MB_OK+MB_ICONERROR);
       Application.Terminate;
       end;
       if (StatusServices=1) then
       begin
       MessageBox(Application.handle, PChar('Запустите службу ServiceRuViewer'+#10#13+'и повторите попытку запуска.'), PChar('Ошибка запуска программы'), MB_OK+MB_ICONERROR);
       Application.Terminate;
       end;
       if (StatusServices=2) or (StatusServices=3) or (StatusServices=5) or (StatusServices=6) or (StatusServices=7)  then
       begin
       MessageBox(Application.handle, PChar('Проверьте службу ServiceRuViewer'+#10#13+'и повторите попытку запуска.'), PChar('Ошибка запуска программы'), MB_OK+MB_ICONERROR);
       Application.Terminate;
       end;
     end;

  Application.MainFormOnTaskbar := True;
  Application.Title := 'RuViewer';
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.CreateForm(TFormOsher, FormOsher);
  Application.CreateForm(Tfrm_Password, frm_Password);
  Application.CreateForm(Tfrm_RemoteScreen, frm_RemoteScreen);
  Application.CreateForm(Tfrm_Chat, frm_Chat);
  Application.CreateForm(Tfrm_ShareFiles, frm_ShareFiles);
  Application.CreateForm(TForm_set, Form_set);
  Application.CreateForm(TFrmMyProgress, FrmMyProgress);
  Application.CreateForm(TFReconnect, FReconnect);
  Application.CreateForm(TFormFileTransfer, FormFileTransfer);
  Application.CreateForm(TFormPrivilage, FormPrivilage);
  Application.Run;
end.
