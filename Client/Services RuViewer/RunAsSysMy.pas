unit RunAsSysMy;

interface

uses
  System.Classes,Winapi.Windows,System.SysUtils,ShellApi,VCL.Forms,TLHelp32;
  //https://www.delphipraxis.net/198884-setthreaddesktop-function-how-show-form-any-active-desktop.html
type
  TIntegrityLevel = (UnknownIntegrityLevel, LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel);

type
  _TOKEN_MANDATORY_LABEL = record
    Label_: SID_AND_ATTRIBUTES;
  end;
  PStartupInfoW = ^TStartupInfoW;
  _STARTUPINFOW = record
    cb: DWORD;
    lpReserved: PWideChar;
    lpDesktop: PWideChar;
    lpTitle: PWideChar;
    dwX: DWORD;
    dwY: DWORD;
    dwXSize: DWORD;
    dwYSize: DWORD;
    dwXCountChars: DWORD;
    dwYCountChars: DWORD;
    dwFillAttribute: DWORD;
    dwFlags: DWORD;
    wShowWindow: Word;
    cbReserved2: Word;
    lpReserved2: PByte;
    hStdInput: THandle;
    hStdOutput: THandle;
    hStdError: THandle;
  end;
  _STARTUPINFO = _STARTUPINFOW;
  TStartupInfoW = _STARTUPINFOW;

  TTokenInformationClass = (
    TokenUser = 1,
    TokenGroups,
    TokenPrivileges,
    TokenOwner,
    TokenPrimaryGroup,
    TokenDefaultDacl,
    TokenSource,
    TokenType,
    TokenImpersonationLevel,
    TokenStatistics,
    TokenRestrictedSids,
    TokenSessionId,
    TokenGroupsAndPrivileges,
    TokenSessionReference,
    TokenSandBoxInert,
    TokenAuditPolicy,
    TokenOrigin,
    TokenElevationType,
    TokenLinkedToken,
    TokenElevation,
    TokenHasRestrictions,
    TokenAccessInformation,
    TokenVirtualizationAllowed,
    TokenVirtualizationEnabled,
    TokenIntegrityLevel,
    TokenUIAccess,
    TokenMandatoryPolicy,
    TokenLogonSid,
    vMaxTokenInfoClass);
    WTS_INFO_CLASS = (
    WTSInitialProgram,
    WTSApplicationName,
    WTSWorkingDirectory,
    WTSOEMId,
    WTSSessionId,
    WTSUserName,
    WTSWinStationName,
    WTSDomainName,
    WTSConnectState,
    WTSClientBuildNumber,
    WTSClientName,
    WTSClientDirectory,
    WTSClientProductId,
    WTSClientHardwareId,
    WTSClientAddress,
    WTSClientDisplay,
    WTSClientProtocolType,
    WTSIdleTime,
    WTSLogonTime,
    WTSIncomingBytes,
    WTSOutgoingBytes,
    WTSIncomingFrames,
    WTSOutgoingFrames,
    WTSClientInfo,
    WTSSessionInfo,
    WTSSessionInfoEx,
    WTSConfigInfo,
    WTSValidationInfo,
    WTSSessionAddressV4,
    WTSIsRemoteSession
  );

  TOKEN_MANDATORY_LABEL = _TOKEN_MANDATORY_LABEL;
  PTOKEN_MANDATORY_LABEL = ^TOKEN_MANDATORY_LABEL;

  TTokenMandatoryLabel = _TOKEN_MANDATORY_LABEL;
  PTokenMandatoryLabel = ^TTokenMandatoryLabel;

  TConvertStringSidToSidW = function(StringSid: PWideChar; var Sid: PSID): BOOL; stdcall;
  TCreateProcessWithTokenW = function(hToken: THandle;
    dwLogonFlags: DWORD;
    lpApplicationName: PWideChar;
    lpCommandLine: PWideChar;
    dwCreationFlags: DWORD;
    lpEnvironment: Pointer;
    lpCurrentDirectory: PWideChar;
    lpStartupInfo: PStartupInfoW;
    lpProcessInformation: PProcessInformation): BOOL; stdcall;

  TConvertStringSidToSidA = function(StringSid: PAnsiChar; var Sid: PSID): BOOL; stdcall;

  TGetTokenInformation = function(TokenHandle: THandle;
    TokenInformationClass: TTokenInformationClass; TokenInformation: Pointer;
    TokenInformationLength: DWORD; var ReturnLength: DWORD): BOOL; stdcall;

  TSetTokenInformation = function(TokenHandle: THandle;
    TokenInformationClass: TTokenInformationClass; TokenInformation: Pointer;
    TokenInformationLength: DWORD): BOOL; stdcall;

  TCreateProcessAsUserW = function(hToken: THandle; lpApplicationName: PWideChar;
    lpCommandLine: PWideChar; lpProcessAttributes: PSecurityAttributes;
    lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
    dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PWideChar;
    const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;

    function WTSQueryUserToken(SessionId: ULONG; var phToken: THandle): BOOL; stdcall; external 'Wtsapi32.dll';
    function CreateEnvironmentBlock(var lpEnvironment: Pointer; hToken: THandle;bInherit: BOOL): BOOL;  stdcall; external 'Userenv.dll';

var
  ConvertStringSidToSidW: TConvertStringSidToSidW;
  CreateProcessWithTokenW: TCreateProcessWithTokenW;
  ConvertStringSidToSidA: TConvertStringSidToSidA;
  GetTokenInformation: TGetTokenInformation;
  SetTokenInformation: TSetTokenInformation;
  CreateProcessAsUserW: TCreateProcessAsUserW;

const
  LOW_INTEGRITY_SID: PWideChar = 'S-1-16-4096';
  MEDIUM_INTEGRITY_SID: PWideChar = 'S-1-16-8192';
  HIGH_INTEGRITY_SID: PWideChar = 'S-1-16-12288';
  SYSTEM_INTEGRITY_SID: PWideChar = 'S-1-16-16384';

  SECURITY_MANDATORY_UNTRUSTED_RID = $00000000;
  SECURITY_MANDATORY_LOW_RID = $00001000;
  SECURITY_MANDATORY_MEDIUM_RID = $00002000;
  SECURITY_MANDATORY_HIGH_RID = $00003000;
  SECURITY_MANDATORY_SYSTEM_RID = $00004000;
  SECURITY_MANDATORY_PROTECTED_PROCESS_RID = $00005000;

  SE_GROUP_INTEGRITY = $00000020;
  WTS_CURRENT_SERVER_HANDLE: THANDLE = 0;


function RunProcAsSystemThread( FileName, Param,IpDes: string;  IdSession:DWORD;
 IntegrityLevel: TIntegrityLevel = LowIntegrityLevel): Boolean;
function GetCurrentDesktop:string; // имя текущего рабочего стола

implementation

uses RunAsSystem;

function Log_write(fname, text:string):string;
var f:TStringList;
begin
  if not DirectoryExists('log') then CreateDir('log');
  f:=TStringList.Create;
  try
    if FileExists(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log') then
      f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
    f.Insert(0,DateTimeToStr(Now)+chr(9)+text);
    while f.Count>1000 do f.Delete(1000);
    f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
  finally
    f.Destroy;
  end;
end;


function GetProcessIntegrityLevel(ProcessId: DWORD; var IntegrityLevel: TIntegrityLevel): Boolean;
var  //возвращает указатель IntegrityLevel (уровень привелегий) на указанный дочерний орган в идентификаторе безопасности (SID)
     //(SID из процесса с ID ProcessId ). Значение субавторитета является относительным идентификатором (RID).
  SIDAndAttributes: PSIDAndAttributes;
  ReturnLength: DWORD;
  SidSubAuthorityCount: PUCHAR;
  SidSubAuthority: DWORD;
  ProcessHandle, TokenHandle: THandle;
begin
  IntegrityLevel := UnknownIntegrityLevel;
  Result := False;
  try
    ProcessHandle := 0;
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, ProcessId); //Открывает существующий локальный объект процесса. Возвращает открытый дескриптор указанного процесса
    if ProcessHandle <> 0 then     // если дескриптор процесса не равен 0
    begin
      try  //получаем маркер доступа TokenHandle связянный с этим процессом. MAXIMUM_ALLOWED маска доступа, указывает запрошеные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //Функция OpenProcessToken открывает маркер доступа , связанный с процессом.
        begin  // если успешно открыли маркер доступа TokenHandle
          try  // ReturnLength Указатель на переменную, которая получает количество байтов, необходимых для буфера
            GetTokenInformation(TokenHandle, TokenIntegrityLevel, nil, 0, ReturnLength);   //Функция GetTokenInformation извлекает информацию определенного типа о маркере доступа .
            SIDAndAttributes := nil;
            GetMem(SIDAndAttributes, ReturnLength); //Процедура GetMem пытается получить указанные в ReturnLength байт памяти, сохраняя указатель на память в SIDAndAttributes.
            if SIDAndAttributes <> nil then
            begin
              try  //извлекает информацию определенного типа о маркере доступа . TokenIntegrityLevel-определяет тип информации которую извлекаем. SIDAndAttributes-заполняем буфер памяти получаемой информацией
                if GetTokenInformation(TokenHandle, TokenIntegrityLevel, SIDAndAttributes, ReturnLength, ReturnLength) then   // ReturnLength-длинна буфера
                begin  // если получили информацию в SIDAndAttributes
                  SidSubAuthorityCount := GetSidSubAuthorityCount(SIDAndAttributes.Sid); //Функция GetSidSubAuthorityCount возвращает указатель на элемент в структуре идентификатора безопасности
                  //  возвращаемое значение является указателем на количество дочерних органов для указанной структуры SID .
                  SidSubAuthority := SidSubAuthorityCount^;
                  SidSubAuthority := SidSubAuthority - 1;
                  if IsValidSid(SIDAndAttributes.Sid) then // убедиться, что структура SID действительна
                  begin
                  //GetSidSubAuthority возвращает указатель на указанный дочерний орган в идентификаторе безопасности (SID). Значение субавторитета является относительным идентификатором (RID).
                    case DWORD(GetSidSubAuthority(SIDAndAttributes.Sid, SidSubAuthority)^) of //
                      SECURITY_MANDATORY_LOW_RID:    IntegrityLevel := LowIntegrityLevel;
                      SECURITY_MANDATORY_MEDIUM_RID: IntegrityLevel := MediumIntegrityLevel;
                      SECURITY_MANDATORY_HIGH_RID:   IntegrityLevel := HighIntegrityLevel;
                      SECURITY_MANDATORY_SYSTEM_RID: IntegrityLevel := SystemIntegrityLevel;
                    end;
                    Result := True;
                  end;
                end;
              finally
                FreeMem(SIDAndAttributes, ReturnLength);
              end;
            end;
          finally
            CloseHandle(TokenHandle);
          end;
        end;
      finally
        CloseHandle(ProcessHandle);
      end;
    end;
  except
  end;
end;


function GetWinlogonProcessId(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // Получаем ID процесса winlogon указанного сеанса SessionID пользователя с системными привилегиями SystemIntegrityLevel для Vista и выше или ID процесса пользователя system для XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  IntegrityLevel: TIntegrityLevel;
  UserName: WideString;
  DomainName: WideString;
  IdProcSession:DWORD;
begin
  Result := 0;
  try //Делает снимок указанных процессов, а также кучу, модулей и потоков, используемых этими процессами.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-ключает в снимок все процессы в системе. Чтобы перечислить процессы, см. Process32First . 0-идентификатор процесса, если 0 то текущий процесс, в данном лучае он игногируется и в снимок включаются все процессы
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then // если функция завршилась не ошибкой
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 Описывает запись из списка процессов, находящихся в системном адресном пространстве на момент создания моментального снимка.
        //ProcessEntry32.dwSize Размер структуры в байтах. Перед вызовом функции Process32First установите для этого члена значение sizeof(PROCESSENTRY32). Если вы не инициализируете dwSize , Process32First завершится ошибкой.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //звлекает информацию о следующем процессе, записанном в моментальный снимок системы. ToolHelp32SnapShot-снимок, ProcessEntry32 -Указатель на структуру
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then // если перичисленный процесс в снимке процессов = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then // узнаем номер сеанса пользователя для данного процесса
          if IdProcSession=SessionID then // если он равен то данный процесс запущен в нужном нам сенсе, иначе продолжаем искать в снимке другой процесс
               GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID процесса
              if IntegrityLevel = SystemIntegrityLevel then //если уровень привелегий соответствует SystemIntegrityLevel то возвращаем в результат ID процесса
              begin
                Result := ProcessEntry32.th32ProcessID;
                Break;
              end;
        end;
      finally
        CloseHandle(ToolHelp32SnapShot);
      end;
    end;
  except
  end;
end;


function GetCurrentDesktop:string; // имя текущего рабочего стола
var
inputDesktop:HDESK;
deskBytes: array [0 .. 255] of Char;
needed: Cardinal;
buf: PChar;
procInfo:STARTUPINFO;
begin
try
buf := AllocMem(256);
inputDesktop := OpenInputDesktop(0,false,MAXIMUM_ALLOWED);
if inputDesktop=0 then Log_Write('service','GetCurrentDesktop - OpenInputDesktop: '+SysErrorMessage(GetLastError()));
if not GetUserObjectInformation(inputDesktop,UOI_NAME,@deskBytes[0],256,needed) then
Log_Write('service','GetCurrentDesktop - GetUserObjectInformation: '+SysErrorMessage(GetLastError()));
buf:=allocMem(needed);
if not CloseDesktop(inputDesktop) then Log_Write('service','GetCurrentDesktop - CloseDesktop: '+SysErrorMessage(GetLastError()));
Log_Write('service','GetCurrentDesktop - : '+buf);
result:=buf;
FreeMem(buf);
except on E: Exception do Log_Write('service','Ошибка GetCurrentDesktop: '+e.ClassName +': '+ e.Message);
end;
end;

function CreateProcessAsSystemThread(
  ApplicationName: PWideChar;
  CommandLine: PWideChar;
  CreationFlags: DWORD;
  Environment: Pointer;
  CurrentDirectory: PWideChar;
  StartupInfo: TStartupInfoW;IdSession: DWORD;
  var ProcessInformation: TProcessInformation;
  IntegrityLevel: TIntegrityLevel): Boolean;
var
  ProcessHandle, TokenHandle, ImpersonateToken: THandle;
  Sid: PSID;
  MandatoryLabel: PTOKEN_MANDATORY_LABEL;
  ReturnLength: DWORD;
  PIntegrityLevel: PWideChar;
  TokenCurrentUser:THandle;
  P : Pointer;
  dwCreationFlags:dword;
   step:integer;
  TokenHandle1: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength1: DWORD;
  sa:SECURITY_ATTRIBUTES;
begin
  Log_Write('service','CreateProcessAsSystemThread: Start');
    Result := False;
  if (@CreateProcessWithTokenW = nil) then //Создает новый процесс и его основной поток. Новый процесс запускается в контексте безопасности указанного токена. При желании он может загрузить профиль пользователя для указанного пользователя.
    Exit;
  step:=0;
  try    //Открывает существующий локальный объект процесса. MAXIMUM_ALLOWED-права доступа. false-не наследовать дескриптор этого процесса
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, GetWinlogonProcessId(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID процесса с системными привелегиями, Идентификатор локального процесса, который необходимо открыть.
    if ProcessHandle = 0 then Log_Write('service','CreateProcessAsSystemThread: ProcessHandle = 0');//Если полученый дескриптор безопасности указанного процесаа получен
    step:=1;
      try  //открывает маркер доступа , связанный с процессом. ProcessHandle-Дескриптор процесса, чей токен доступа открыт. MAXIMUM_ALLOWED-запрошенные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle,TOKEN_DUPLICATE {MAXIMUM_ALLOWED}, TokenHandle) then  //TokenHandle-Указатель на дескриптор, который идентифицирует вновь открытый маркер доступа при возврате функции. для запуска процесса под системной учеткой
        begin
        step:=2;
          try  //Функция DuplicateTokenEx создает новый маркер доступа ImpersonateToken, дублирующий существующий маркер TokenHandle, с правами и привилегиями MAXIMUM_ALLOWED и уровнем олицетворения SecurityImpersonation. Эта функция может создать либо первичный токен , либо токен олицетворения .
            sa.nLength:= sizeof(sa);
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, @sa, SecurityIdentification, TokenPrimary, ImpersonateToken) then //ImpersonateToken- Указатель на переменную HANDLE , которая получает новый токен
            begin
            step:=3;
              try // создаем переменную указатель
                New(Sid); //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                step:=4;
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                  step:=5;
                    try //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией с указанием длинны буфера ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // если получили информацию в структуру MandatoryLabel
                        step:=6;
                        if IntegrityLevel = SystemIntegrityLevel then // в соответсвии с уровнем доступа
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // назначаем уровень доступа
                        else if IntegrityLevel = HighIntegrityLevel then
                          PIntegrityLevel := HIGH_INTEGRITY_SID
                        else if IntegrityLevel = MediumIntegrityLevel then
                          PIntegrityLevel := MEDIUM_INTEGRITY_SID
                        else if IntegrityLevel = LowIntegrityLevel then
                          PIntegrityLevel := LOW_INTEGRITY_SID;
                        if ConvertStringSidToSidW(PIntegrityLevel, Sid) then // конвертируем SID
                        begin
                        step:=7;
                          MandatoryLabel.Label_.Sid := Sid; //в структуре присваеваем SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID является обязательным SID целостности
                          //устанавливает различные типы информации для ImpersonateToken токена доступа
                          if SetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, SizeOf(TOKEN_MANDATORY_LABEL) + GetLengthSid(Sid)) then
                          begin //Создает новый процесс и его основной поток. Новый процесс запускается в контексте безопасности указанного токена. При желании он может загрузить профиль пользователя для указанного пользователя.
                           step:=8;
                            //Result := CreateProcessWithTokenW(ImpersonateToken, 0, ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, @StartupInfo, @ProcessInformation);
                            result:=CreateProcessAsUserW(ImpersonateToken, ApplicationName, CommandLine, @sa,  @sa, False,NORMAL_PRIORITY_CLASS+CREATE_NEW_CONSOLE,  Environment,CurrentDirectory, StartupInfo,ProcessInformation);
                              SetLastError(0);
                          end;
                        end;
                      end;
                    finally
                      FreeMem(MandatoryLabel);
                    end;
                  end;
                end;
              finally
                CloseHandle(ImpersonateToken);
              end;
            end;
          finally
            CloseHandle(TokenHandle);
          end;
        end;
      finally
        CloseHandle(ProcessHandle);
      end;
  Log_Write('service','CreateProcessAsSystemThread: End');
  except on E: Exception do
  Log_Write('service','Ошибка CreateProcessAsSystemThread: шаг '+inttostr(step)+': '+e.ClassName +': '+ e.Message);
  end;
end;

function RunProcAsSystemThread( FileName, Param,IpDes: string;  IdSession:DWORD;
  IntegrityLevel: TIntegrityLevel = LowIntegrityLevel): Boolean;
var
  StartupInfo: TStartupInfoW;
  ProcessInformation: TProcessInformation;
  ////////////////////////
  hToken, hUserToken: THandle;
  ProcessInfo : TProcessInformation;
  P : Pointer;
  CurrentDirectory: PWideChar;
begin
try
 Log_Write('service','RunProcAsSystemThread: Start ');
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//Заполняет область памяти @StartupInfo нулями. размер области  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// заполняет раздел памяти StartupInfo тем же самым байтом или символом SizeOf(TStartupInfoW) 0 раз.
  StartupInfo.cb := SizeOf(TStartupInfoW); // Размер структуры в байтах
  StartupInfo.lpDesktop := PwideChar('WinSta0\'+IpDes);
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  Result := CreateProcessAsSystemThread(
    PWideChar(WideString(FileName)), //
    PWideChar(WideString(Param)),
    NORMAL_PRIORITY_CLASS,
    nil,
    nil,
    StartupInfo,
    IdSession,
    ProcessInformation,
    IntegrityLevel);
  if Result then
  begin
    CloseHandle(ProcessInformation.hThread);
    CloseHandle(ProcessInformation.hProcess);
  end;
  Log_Write('service','RunProcAsSystemThread: End ');
except on E: Exception do
  Log_Write('service','Ошибка CreateProcessAsSystemThread: '+e.ClassName +': '+ e.Message);
  end;
end;


/////////////////////////////////////////////////////////////////////////////////////////////////////////

end.

