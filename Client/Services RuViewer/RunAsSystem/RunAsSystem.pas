unit RunAsSystem;

interface

uses
  Windows, SysUtils, TLHelp32, AccCtrl, AclAPI,Vcl.Controls,Vcl.Forms, System.Classes;

type
  ArraySession=array of Integer;
  TIntegrityLevel = (UnknownIntegrityLevel, LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel);
                    //уровни целостности и обязательную политику для оценки доступа.  Windows определяет четыре уровня целостности (доступа): низкий, средний, высокий и системный.
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

  WTS_CONNECTSTATE_CLASS = (
    WTSActive,
    WTSConnected,
    WTSConnectQuery,
    WTSShadow,
    WTSDisconnected,
    WTSIdle,
    WTSListen,
    WTSReset,
    WTSDown,
    WTSInit
  );

  PWTS_SESSION_INFO = ^WTS_SESSION_INFO;
  WTS_SESSION_INFO = record
    SessionId: DWORD;
    pWinStationName: LPTSTR;
    State: WTS_CONNECTSTATE_CLASS;
   end;

   function GetCurentSession:ArraySession; // функция перечисления всех консольных сеансов пользователей
   function GetCurentRDPSession:ArraySession; // функция перечисления всех RDP сеансов пользователей
   function GetCurentSessionConsole:integer; // функция поиска активного консольного сеанса пользователя
   function GetTypeSession(GetNumSession:dword):string; // функция возвращает тип сессии Console или RDP для указаного сеанса

   function RunProcAsSystem( FileName, Param: string; IdSession:DWORD;RDPSession:boolean; Var ReadPID:integer;
    IntegrityLevel: TIntegrityLevel): Boolean;
   function RunProcAsSystemRunUser( FileName, Param: string;  IdSession:DWORD;RDPSession:boolean; Var ReadPID:integer;
  IntegrityLevel: TIntegrityLevel): Boolean; {LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel}

  function CreateProcessAsSystemW( ApplicationName: PWideChar; CommandLine: PWideChar;
    CreationFlags: DWORD; Environment: Pointer; CurrentDirectory: PWideChar;
    StartupInfo: TStartupInfoW;IdSession:DWORD;RDPSession:boolean; var ProcessInformation: TProcessInformation;
    IntegrityLevel: TIntegrityLevel): Boolean; overload;

  function WTSEnumerateSessions(hServer: THandle; Reserved: DWORD; Version: DWORD;
  var ppSessionInfo: PWTS_SESSION_INFO; var pCount: DWORD): BOOL; stdcall; external
   'Wtsapi32.dll' name {$IFDEF UNICODE}'WTSEnumerateSessionsW'{$ELSE}'WTSEnumerateSessionsA'{$ENDIF};

  function WTSQuerySessionInformation(hServer: THandle; SessionId: DWORD; WTSInfoClass:
   WTS_INFO_CLASS; var ppBuffer: LPTSTR; var pBytesReturned: DWORD): BOOL; stdcall; external
    'Wtsapi32.dll' name {$IFDEF UNICODE}'WTSQuerySessionInformationW'{$ELSE}'WTSQuerySessionInformationA'{$ENDIF};

    procedure WTSFreeMemory(pMemory: Pointer); stdcall; external 'Wtsapi32.dll';

  var
  LevelLogErrorRun:integer;
   
implementation


type
  _TOKEN_MANDATORY_LABEL = record
    Label_: SID_AND_ATTRIBUTES;
  end;

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


const
  LOW_INTEGRITY_SID: PWideChar = 'S-1-16-4096'; // Низкий обязательный уровень   S-1-16-$00001000
  MEDIUM_INTEGRITY_SID: PWideChar = 'S-1-16-8192'; //Средний обязательный уровень S-1-16-$00002000
  MEDIUM_INTEGRITY_PLUS_SID: PWideChar = 'S-1-16-8448'; //Уровень целостности от среднего до высокого.
  HIGH_INTEGRITY_SID: PWideChar = 'S-1-16-12288';  //Высокий обязательный уровень S-1-16-$00003000
  SYSTEM_INTEGRITY_SID: PWideChar = 'S-1-16-16384'; //Обязательный уровень системы S-1-16-$00004000
  PROTECTED_PROCESS_SID: PWideChar = 'S-1-16-20480'; //SID, представляющий уровень целостности защищенного процесса.
  SECURITY_PROCESS_RID: PWideChar = 'S-1-16-28672'; //SID, который представляет безопасный уровень целостности процесса.
  TMP_SECURITY_RID: PWideChar = 'S-1-16-13568';

  //https://katochcisco.blogspot.com/2016/09/windows-integrity-mechanism-design.html
  SECURITY_MANDATORY_UNTRUSTED_RID = $00000000;  //Ненадежный уровень -0
  SECURITY_MANDATORY_LOW_RID = $00001000;       //Низкий уровень целостности -4096
  SECURITY_MANDATORY_MEDIUM_RID = $00002000;    //Средний уровень целостности -8192
  //SECURITY_MANDATORY_UIACCESS_RID = SECURITY_MANDATORY_MEDIUM_RID + $0x10
  SECURITY_MANDATORY_MEDIUM_PLUS_RID =$00002100;//сточник: https://windowso.ru/articles/eventid-sozdaniya-protsessa-windows.html
  SECURITY_MANDATORY_HIGH_RID = $00003000;      // Высокий уровень целостности -12288
  SECURITY_MANDATORY_SYSTEM_RID = $00004000;    //Уровень целостности системы - 16384
  SECURITY_MANDATORY_PROTECTED_PROCESS_RID = $00005000; //уровень целостности защищенного процесса 20480.
  SECURITY_MANDATORY_PROCESS_RID=$00007000; //представляет безопасный уровень целостности процесса. 28672


  SECURITY_NT_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0,0,0,0,0,5));
  SE_GROUP_INTEGRITY = $00000020;   //32
  SECURITY_INTERACTIVE_RID ='S-1-5-4';// $00000004;  // -4
  WTS_CURRENT_SERVER_HANDLE: THANDLE = 0;

var
  ConvertStringSidToSidW: TConvertStringSidToSidW;
  CreateProcessWithTokenW: TCreateProcessWithTokenW;
  ConvertStringSidToSidA: TConvertStringSidToSidA;
  GetTokenInformation: TGetTokenInformation;
  SetTokenInformation: TSetTokenInformation;
  CreateProcessAsUserW: TCreateProcessAsUserW;

  WindowsVersion: Cardinal;

function Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
 try
 if NumError<=LevelLogErrorRun then // если уровень ошибки выше чем указаный в настройках
      Begin
        if not DirectoryExists('log') then CreateDir('log');
        f:=TStringList.Create;
        try
          if FileExists(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log') then
            f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
            f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
          while f.Count>1000 do f.Delete(1);
          f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
        finally
          f.Destroy;
        end;
      End;
 except on E: Exception do
  begin
  exit;
  end;
 end
end;


//Winsta0\Winlogon - при передаче приложению в сеансе пользователя приложение не отображается на рабочем столе т.к. ХЗ, возможно на другом отображается....
 { inputDesktop := OpenWindowStation('Winsta0',true,GENERIC_ALL
  или  OpenWindowStation - открывает имеющуюся рабочую станцию Winlogon CreateWindowStation Создает объект оконной станции, связывает его с вызывающим процессом и назначает текущему сеансу.
   inputDesktop := CreateWindowStation('Winsta0', 0, GENERIC_ALL, nil);  //GENERIC_READ or GENERIC_WRITE

  if inputDesktop=0 then Log_Write('service','GetDeskName - CreateWindowStation: '+SysErrorMessage(GetLastError()));
  if not SetProcessWindowStation(inputDesktop) then Log_Write('service','GetDeskName - SetProcessWindowStation: '+SysErrorMessage(GetLastError()));
  myDesk := OpenInputDesktop(0,true,MAXIMUM_ALLOWED);}

function GetDeskNameWinlogon: string;
var
  buf: PChar;
  needed: Cardinal;
  inputDesktop:HDESK;
  myWinStat,myDesk:HDESK;
begin
try
  inputDesktop := OpenWindowStation('Winsta0',true,GENERIC_ALL);
  if inputDesktop=0 then Log_Write('service',2,'GetDeskName - OpenWindowStation: '+SysErrorMessage(GetLastError()));
  //inputDesktop := CreateWindowStation('Winsta0', 0, GENERIC_ALL, nil);  //GENERIC_READ or GENERIC_WRITE
 // if inputDesktop=0 then Log_Write('service','GetDeskName - CreateWindowStation: '+SysErrorMessage(GetLastError()));

 // inputDesktop := GetProcessWindowStation();
 // if inputDesktop=0 then Log_Write('service','GetDeskName - GetProcessWindowStation: '+SysErrorMessage(GetLastError()));

  if not SetProcessWindowStation(inputDesktop) then Log_Write('service',2,'GetDeskName - SetProcessWindowStation: '+SysErrorMessage(GetLastError()));

  //inputDesktop := CreateDesktop('', nil, nil, 0, GENERIC_ALL, nil); // GENERIC_READ or GENERIC_WRITE
  //if inputDesktop=0 then Log_Write('service','GetDeskName - CreateDesktop: '+SysErrorMessage(GetLastError()));

  //myDesk := OpenDesktop('',0,false,MAXIMUM_ALLOWED);
  //if myDesk=0 then Log_Write('service','GetDeskName - OpenDesktop: '+SysErrorMessage(GetLastError()));

  myDesk := OpenInputDesktop(0,true,MAXIMUM_ALLOWED);
  if myDesk=0 then
    begin
   // Log_Write('service','GetDeskName - OpenInputDesktop: '+SysErrorMessage(GetLastError()));
   end;
  buf := AllocMem(1024);
  if not GetUserObjectInformation(myDesk, UOI_NAME, buf, 1024, needed) then
  begin
   // Log_Write('service','GetDeskName - GetUserObjectInformation: '+SysErrorMessage(GetLastError())+' - '+buf);
    FreeMem(buf);
    buf := AllocMem(needed);
    if not GetUserObjectInformation(myDesk, UOI_NAME, buf, needed, needed) then
    begin
   // Log_Write('service','GetDeskName - GetUserObjectInformation2: '+SysErrorMessage(GetLastError())+' - '+buf);
    result:='Default';
    end
    else Result := buf;
  end
  else   Result := buf;
  if not CloseDesktop(myDesk) then Log_Write('service',2,'GetDeskName - CloseDesktop: '+SysErrorMessage(GetLastError()));
  FreeMem(buf);
   except on E: Exception do
  Log_Write('service',3,'Ошибка GetDeskName: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetDeskName: string;
var
  buf: PChar;
  needed: Cardinal;
  inputDesktop:HDESK;
  myWinStat,myDesk:HDESK;
begin
try
  inputDesktop := CreateWindowStation('Winsta0', 0, GENERIC_ALL, nil);  //GENERIC_READ or GENERIC_WRITE
  if inputDesktop=0 then Log_Write('service',2,'GetDeskName - CreateWindowStation: '+SysErrorMessage(GetLastError()));
  if not SetProcessWindowStation(inputDesktop) then Log_Write('service',2,'GetDeskName - SetProcessWindowStation: '+SysErrorMessage(GetLastError()));
  myDesk := OpenInputDesktop(0,true,MAXIMUM_ALLOWED);
  if myDesk=0 then
    begin
   // Log_Write('service','GetDeskName - OpenInputDesktop: '+SysErrorMessage(GetLastError()));
   end;
  buf := AllocMem(1024);
  if not GetUserObjectInformation(myDesk, UOI_NAME, buf, 1024, needed) then
  begin
    //Log_Write('service','GetDeskName - GetUserObjectInformation: '+SysErrorMessage(GetLastError())+' - '+buf);
    FreeMem(buf);
    buf := AllocMem(needed);
    if not GetUserObjectInformation(myDesk, UOI_NAME, buf, needed, needed) then
    begin
    //Log_Write('service','GetDeskName - GetUserObjectInformation2: '+SysErrorMessage(GetLastError())+' - '+buf);
    result:='Default';
    end
    else Result := buf;
  end
  else   Result := buf;
  if not CloseDesktop(myDesk) then Log_Write('service',2,'GetDeskName - CloseDesktop: '+SysErrorMessage(GetLastError()));
  FreeMem(buf);
   except on E: Exception do
  Log_Write('service',3,'Ошибка GetDeskName: '+e.ClassName +': '+ e.Message);
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////////

function GetWindowsVersion: Cardinal;
var
  OSVersionInfo: TOSVersionInfo;
begin
  Result := 0;
  FillChar(OSVersionInfo, SizeOf(TOSVersionInfo), 0);
  OSVersionInfo.DwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
  begin
    if OSVersionInfo.dwMajorVersion = 5 then
    begin
      if OSVersionInfo.dwMinorVersion = 0 then
        Result := 50 // 2000
      else if OSVersionInfo.dwMinorVersion = 2 then
        Result := 52 // 2003
      else if OSVersionInfo.dwMinorVersion = 1 then
        Result := 51 // XP
    end;
    if OSVersionInfo.dwMajorVersion = 6 then
    begin
      if OSVersionInfo.dwMinorVersion = 0 then
        Result := 60 // Vista
      else if OSVersionInfo.dwMinorVersion = 1 then
        Result := 61 // 7
      else if OSVersionInfo.dwMinorVersion = 2 then
        Result := 62 // 8
      else if OSVersionInfo.dwMinorVersion = 3 then
        Result := 63; // 8.1
    end;
  end;
end;

function AdjustCurrentProcessPrivilege(PrivilegeName: WideString; Enabled: Boolean): Boolean;
var       // Включаем или выключааем указанные в PrivilegeName привелегии в текущем процессе
  TokenHandle: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength: DWORD;
begin
  Result := False;
  try                   //GetCurrentProcess Извлекает псевдодескриптор текущего процесса.
    if OpenProcessToken(GetCurrentProcess, TOKEN_DUPLICATE, TokenHandle) then   //TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY Функция OpenProcessToken открывает маркер доступа , связанный с процессом.
    begin
      try
        LookupPrivilegeValueW(nil, PWideChar(PrivilegeName), TokenPrivileges.Privileges[0].Luid);   //Функция LookupPrivilegeValue извлекает локальный уникальный идентификатор (LUID), используемый в указанной системе для локального представления указанного имени привилегии.
        TokenPrivileges.PrivilegeCount := 1;
        if Enabled then
          TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
        else
          TokenPrivileges.Privileges[0].Attributes := 0;
        if AdjustTokenPrivileges(TokenHandle, False, TokenPrivileges, 0, nil, ReturnLength) then   //Функция AdjustTokenPrivileges включает или отключает привилегии в указанном токене доступа .
          Result := True;
      finally
        CloseHandle(TokenHandle);
      end;
    end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка AdjustCurrentProcessPrivilege: '+e.ClassName +': '+ e.Message);
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
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //MAXIMUM_ALLOWED Функция OpenProcessToken открывает маркер доступа , связанный с процессом.
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
 except on E: Exception do
 Log_Write('service',3,'Ошибка GetProcessIntegrityLevel: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetTokenUserName(ProcessId: DWORD; var UserName: WideString; var DomainName: WideString): Boolean;
var      // получаем имя пользователя UserName и домен DomainName пользователя указанного ProcessId процесса
  ReturnLength: DWORD;
  peUse: SID_NAME_USE;
  SIDAndAttributes: PSIDAndAttributes;
  Name: PWideChar;
  Domain: PWideChar;
  ProcessHandle, TokenHandle: THandle;
begin
  Result := False;
  try ////Открывает существующий локальный объект процесса. Возвращает открытый дескриптор указанного процесса
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, ProcessId);
    if ProcessHandle <> 0 then
    begin
      try ////получаем маркер доступа TokenHandle связянный с ProcessHandle процесса. MAXIMUM_ALLOWED маска доступа, указывает запрошеные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then
        begin
          try //// ReturnLength Указатель на переменную, которая получает количество байтов, необходимых для буфера
            GetTokenInformation(TokenHandle, TokenUser, nil, 0, ReturnLength); //Функция GetTokenInformation извлекает информацию определенного типа о маркере доступа .
            GetMem(SIDAndAttributes, ReturnLength);//Процедура GetMem пытается получить указанные в ReturnLength байт памяти, сохраняя указатель на память в SIDAndAttributes.
            if SIDAndAttributes <> nil then
            begin
              try ////извлекает информацию определенного типа о маркере доступа . TokenUser-определяет тип информации которую извлекаем. SIDAndAttributes-заполняем буфер памяти получаемой информацией
                if GetTokenInformation(TokenHandle, TokenUser, SIDAndAttributes, ReturnLength, ReturnLength) then
                begin
                  GetMem(Name, MAX_PATH); //Процедура GetMem пытается получить указанные в MAX_PATH байт памяти
                  GetMem(Domain, MAX_PATH);
                  if (Name <> nil) and (Domain <> nil) then
                  begin
                    try  //принимает идентификатор безопасности (SIDAndAttributes.SID) в качестве входных данных. Он извлекает имя учетной записи для этого SID и имя первого домена, в котором этот SID найден.
                      if LookupAccountSidW(nil, SIDAndAttributes.SID, Name, ReturnLength, Domain, ReturnLength, peUse) then
                      begin           //Имя ПК, указатель на SID, получем Имя пользоватлея, размер буфера для имени, Получаем домен, резмер буфера домена, peUse-получаем значение SID_NAME_USE указывающее тип учетной записи
                        UserName := WideString(Name);
                        DomainName := WideString(Domain);
                        Result := True;
                      end;
                    finally
                      FreeMem(Name);
                      FreeMem(Domain);
                    end;
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
 except on E: Exception do
 Log_Write('service',3,'Ошибка GetTokenUserName: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetWinlogonProcessIdRDP(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // Получаем ID процесса winlogon указанного сеанса SessionID пользователя с системными привилегиями SystemIntegrityLevel для Vista и выше или ID процесса пользователя system для XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  IntegrityLevel: TIntegrityLevel;
  IdProcSession:DWORD;
begin
  Result := 0;
  //IdProcSession:=0;
  try //Делает снимок указанных процессов, а также кучу, модулей и потоков, используемых этими процессами.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-ключает в снимок все процессы в системе. Чтобы перечислить процессы, см. Process32First . 0-идентификатор процесса, если 0 то текущий процесс, в данном лучае он игногируется и в снимок включаются все процессы
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// если функция завршилась не ошибкой
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 Описывает запись из списка процессов, находящихся в системном адресном пространстве на момент создания моментального снимка.
        //ProcessEntry32.dwSize Размер структуры в байтах. Перед вызовом функции Process32First установите для этого члена значение sizeof(PROCESSENTRY32). Если вы не инициализируете dwSize , Process32First завершится ошибкой.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //звлекает информацию о следующем процессе, записанном в моментальный снимок системы. ToolHelp32SnapShot-снимок, ProcessEntry32 -Указатель на структуру
        begin
         if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// если перичисленный процесс в снимке процессов = winlogon.exe
         if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // узнаем номер сеанса пользователя для данного процесса
         if IdProcSession=SessionID then // Log_Write('service','GetWinlogonProcessId - IdProcSession=SessionID')// если он равен то данный процесс запущен в нужном нам сенсе, иначе продолжаем искать в снимке другой процесс
          begin
          GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID процесса
            if IntegrityLevel = SystemIntegrityLevel then //если уровень привелегий соответствует SystemIntegrityLevel то возвращаем в результат ID процесса
             begin
             Result := ProcessEntry32.th32ProcessID;
             //Log_Write('service','GetWinlogonProcessIdRDP - ID = '+inttostr(Result));
             Break;
             end;
          end
        end;
      finally
        CloseHandle(ToolHelp32SnapShot);
      end;
    end;
 except on E: Exception do
 Log_Write('service',3,'Ошибка GetWinlogonProcessIdRDP: '+e.ClassName +': '+ e.Message);
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
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// если функция завршилась не ошибкой
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 Описывает запись из списка процессов, находящихся в системном адресном пространстве на момент создания моментального снимка. //ProcessEntry32.dwSize Размер структуры в байтах. Перед вызовом функции Process32First установите для этого члена значение sizeof(PROCESSENTRY32). Если вы не инициализируете dwSize , Process32First завершится ошибкой.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //звлекает информацию о следующем процессе, записанном в моментальный снимок системы. ToolHelp32SnapShot-снимок, ProcessEntry32 -Указатель на структуру
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// если перичисленный процесс в снимке процессов = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // узнаем номер сеанса пользователя для данного процесса
          if not IdProcSession=SessionID then Log_Write('service',3,'GetWinlogonProcessId - IdProcSession '+inttostr(IdProcSession)+ ' = SessionID '+inttostr(SessionID))// если он равен то данный процесс запущен в нужном нам сенсе, иначе продолжаем искать в снимке другой процесс
          else
            begin // получаем уровень привелегий IntegrityLevel в заданном процессе ProcessEntry32.th32ProcessID
              GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID процесса
              if IntegrityLevel = SystemIntegrityLevel then //если уровень привелегий соответствует SystemIntegrityLevel то возвращаем в результат ID процесса
              begin
                Result := ProcessEntry32.th32ProcessID;
                //Log_Write('service','GetWinlogonProcessId - ID = '+inttostr(Result));
                Break;
              end;
            end
       end;
      finally
      CloseHandle(ToolHelp32SnapShot);
      end;
    end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка GetWinlogonProcessId: '+e.ClassName +': '+ e.Message);
 end;
end;

///////////////////////////////////////////////////////////////////////////////



function GetTypeSession(GetNumSession:dword):string; // функция возвращает тип сессии Console или RDP
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
  restmp:string;
begin                        //дескриптр сервера, 0-резерв,1-Версия запроса перечисления,Sessions-Указатель на массив структур WTS_SESSION_INFO
try
    if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //Извлекает список сеансов на сервере узла сеансов удаленных рабочих столов
     begin
     //Log_Write('service','not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
     RaiseLastOSError;
     end;

     try
      if CountSessions > 0 then
       begin
       Session := Sessions;
        for I := 0 to CountSessions-1 do //в цикле проверяем сессии
         begin
          if Session.SessionId=GetNumSession then  // если сеанс равен запрошеному
           begin
            if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes)) then
             begin
             // Log_Write('service','Console UserName='+UserName+' WWinStationName='+WWinStationName );
             if ((pos('RDP', WWinStationName)>0)) then result:='Rdp';
             if  ((pos(UpperCase('Console'), UpperCase(WWinStationName))>0)) then result:='Console';
             WTSFreeMemory(WWinStationName);
             end
             else Log_Write('service',2,'RDP WTSQuerySessionInformation Error : '+SysErrorMessage(GetLastError()));
           end;
           Inc(Session);
         end;
       end;
       finally
        WTSFreeMemory(Sessions);
       end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка GetTypeSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function GetCurentSession:ArraySession; // функция перечисления всех консольных сеансов пользователей в том числе не активных
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
  restmp:string;
begin                        //дескриптр сервера, 0-резерв,1-Версия запроса перечисления,Sessions-Указатель на массив структур WTS_SESSION_INFO
  try
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //Извлекает список сеансов на сервере узла сеансов удаленных рабочих столов
   begin
    //Log_Write('service','not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
    RaiseLastOSError;
   end;
     try
        if CountSessions > 0 then
        begin
          Session := Sessions;
          for I := 0 to CountSessions-1 do //в цикле проверяем сессии
          begin
           if (Session.State = WTSActive) or (Session.SessionId=0) then  // если сеанс активен. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
            begin
            //Log_Write('service','Console Session.State = WTSActive SessionId='+inttostr(Session.SessionId));
              // извлекаем сведения о сеансе.
              //WTS_CURRENT_SERVER_HANDLE-дескриптор сервера,Session.SessionId-сеанс,
               //WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSDomainName, WDomainName, NumBytes);
              //WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSClientName, WClientName, NumBytes);
              //WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSClientProtocolType, WClientProtocolType, NumBytes);
              if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes))
              and (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes))
               then
              begin
              // Log_Write('service','Console UserName='+UserName+' WWinStationName='+WWinStationName );
                try
                 if ((UserName<>'') or (Session.SessionId=0)) and ((pos('RDP', WWinStationName)=0)) then
                  begin
                  Setlength(result,length(result)+1); // увеличение длинны массива для номеров сессий
                  result[length(result)-1]:=integer(Session.SessionId); //добавляем в массив номер сессии
                  //Log_Write('service','GetCurentSession - Console Session Id = '+inttostr(Session.SessionId));
                  end;
                 finally
                  WTSFreeMemory(UserName);
                  WTSFreeMemory(WWinStationName);
                end;
              end;
            end;
            Inc(Session);
          end;
        end;
     finally
      WTSFreeMemory(Sessions);
      { if length(result)>0 then
        begin
        restmp:='';
        for I :=0  to length(result)-1 do restmp:=inttostr(result[i])+',';
        Log_Write('service','Консольные сессии GetCurentSession: '+restmp);
        end;}
     end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка GetCurentSession: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetCurentRDPSession:ArraySession; // функция перечисления RDP сеансов пользователей в том числе не активных
var
  Sessions,Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName: LPTSTR;
  restmp:string;
begin
try                        //дескриптр сервера, 0-резерв,1-Версия запроса перечисления,Sessions-Указатель на массив структур WTS_SESSION_INFO
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //Извлекает список сеансов на сервере узла сеансов удаленных рабочих столов
    begin
    //Log_Write('service','RDP not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
    end;
      try
        if CountSessions > 0 then
        begin
        Session := Sessions;
          for I := 0 to CountSessions-1 do //в цикле проверяем сессии
          begin
           if Session.State = WTSActive then  // если сеанс активен. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
            begin
           // Log_Write('service','RDP Session.State = WTSActive SessionId='+inttostr(Session.SessionId));
             if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes))
               and (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes))
               then
                begin
                 //Log_Write('service','RDP UserName='+UserName+' WWinStationName='+WWinStationName );
                   if (UserName<>'') and (pos('RDP', WWinStationName)>0) then
                    begin
                    Setlength(result,length(result)+1); // увеличение длинны массива для номеров сессий
                    result[length(result)-1]:=integer(Session.SessionId); //добавляем в массив номер сессии
                   // Log_Write('service','GetCurentSession - RDP Session Id = '+inttostr(Sessions.SessionId));
                    end;
                  WTSFreeMemory(UserName);
                  WTSFreeMemory(WWinStationName);
                end
              else Log_Write('service',2,'RDP WTSQuerySessionInformation Error : '+SysErrorMessage(GetLastError()));
            end;
            Inc(Session);
          end;
        end;
      finally
        WTSFreeMemory(Sessions);
        if length(result)>0 then
        begin
        restmp:='';
        for I :=0  to length(result)-1 do restmp:=inttostr(result[i])+',';
        //Log_Write('service','RDP сессии GetCurentRDPSession: '+restmp);
        end;
      end;
 except on E: Exception do
 Log_Write('service',3,'Ошибка GetCurentRDPSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function GetCurentSessionConsole:integer; // функция поиска активного консольного сеанса пользователя. Активный консольный сеанс может быть только один
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
begin                        //дескриптр сервера, 0-резерв,1-Версия запроса перечисления,Sessions-Указатель на массив структур WTS_SESSION_INFO
  try
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //Извлекает список сеансов на сервере узла сеансов удаленных рабочих столов
    RaiseLastOSError;
  try
    if CountSessions > 0 then
    begin
      Session := Sessions;
      for I := 0 to CountSessions-1 do //в цикле проверяем сессии
      begin
       if Session.State = WTSActive then  // если сеанс активен. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
        begin
        if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes))
          and (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes))
           then
          begin
            try
             if (UserName<>'')  and ((pos(UpperCase('Console'), UpperCase(WWinStationName))>0)) then
              begin
              result:=integer(Session.SessionId); //добавляем номер сессии
              //Log_Write('service','GetCurentSessionConsole - Active Console Session Id = '+inttostr(Session.SessionId));
              end;
            finally
              WTSFreeMemory(UserName);
              WTSFreeMemory(WWinStationName);
            end;
          end;
        end;
        Inc(Session);
      end;
    end;
  finally
    WTSFreeMemory(Sessions);
  end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка GetCurentSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function CreateProcessAsSystemConsole(   // запуск процесса в консольном сеансе
  ApplicationName: PWideChar;
  CommandLine: PWideChar;
  CreationFlags: DWORD;
  Environment: Pointer;
  CurrentDirectory: PWideChar;
  StartupInfo: TStartupInfoW;IdSession:Dword;
  var ProcessInformation: TProcessInformation;
  IntegrityLevel: TIntegrityLevel): Boolean;
var
  ProcessHandle, TokenHandle, ImpersonateToken: THandle;
  Sid: PSID;
  MandatoryLabel: PTOKEN_MANDATORY_LABEL;
  ReturnLength: DWORD;
  PIntegrityLevel: PWideChar;
  TokenCurrentUser:THandle;
  lpTokenAttributes: PSecurityAttributes;  //lpTokenAttributes.nLength:=SizeOf(lpTokenAttributes);  Log_Write('service','CreateProcessAsSystem_Service - start');
begin
try
 Result := False;
 //Log_Write('service','CreateProcessAsSystem_Service - start');
  if (@CreateProcessWithTokenW = nil) then //Создает новый процесс и его основной поток. Новый процесс запускается в контексте безопасности указанного токена. При желании он может загрузить профиль пользователя для указанного пользователя.
    Exit;
   //Открывает существующий локальный объект процесса. MAXIMUM_ALLOWED-права доступа. false-не наследовать дескриптор этого процесса
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, false, GetWinlogonProcessId(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID процесса с системными привелегиями, Идентификатор локального процесса, который необходимо открыть.
    //Log_Write('service','CreateProcessAsSystem_Service - OpenProcess');
    if ProcessHandle = 0 then Log_Write('service',2,'CreateProcessAsUserW - ProcessHandle = 0: '+SysErrorMessage(GetLastError()))//Если полученый дескриптор безопасности указанного процесаа получен
    else
    begin
      try  //открывает маркер доступа , связанный с процессом. ProcessHandle-Дескриптор процесса, чей токен доступа открыт. MAXIMUM_ALLOWED-запрошенные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //TokenHandle-Указатель на дескриптор, который идентифицирует вновь открытый маркер доступа при возврате функции. для запуска процесса под системной учеткой
        begin
        //Log_Write('service','CreateProcessAsSystem_Service - OpenProcessToken');
          try  //Функция DuplicateTokenEx создает новый маркер доступа ImpersonateToken, дублирующий существующий маркер TokenHandle, с правами и привилегиями MAXIMUM_ALLOWED и уровнем олицетворения SecurityImpersonation. Эта функция может создать либо первичный токен , либо токен олицетворения .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, {SecurityIdentification}SecurityImpersonation, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- Указатель на переменную HANDLE , которая получает новый токен
            begin
              try // создаем переменную указатель
                begin // если получили информацию в структуру MandatoryLabel
                  begin
                  result:=CreateProcessAsUserW(ImpersonateToken, ApplicationName, CommandLine, nil,  nil, False,CREATE_UNICODE_ENVIRONMENT,  Environment,CurrentDirectory, StartupInfo,ProcessInformation);
                  SetLastError(0);
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
    end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка CreateProcessAsSystem_Service: '+e.ClassName +': '+ e.Message);
 end;
end;

function CreateProcessAsSystemRDP(   // запуск процесса в RDP сеансе
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
  Sid,NewSid: PSID;
  SidStr:PChar;
  MandatoryLabel: PTOKEN_MANDATORY_LABEL;
  ReturnLength: DWORD;
  PIntegrityLevel: PWideChar;
  TokenCurrentUser:THandle;
  P : Pointer;
  dwCreationFlags:dword;

  TokenHandle1: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength1: DWORD;
begin
try
    Result := False;
  if (@CreateProcessWithTokenW = nil) then //Создает новый процесс и его основной поток. Новый процесс запускается в контексте безопасности указанного токена. При желании он может загрузить профиль пользователя для указанного пользователя.
    Exit;
   //Открывает существующий локальный объект процесса. MAXIMUM_ALLOWED-права доступа. false-не наследовать дескриптор этого процесса
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, GetWinlogonProcessIdRDP(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID процесса с системными привелегиями, Идентификатор локального процесса, который необходимо открыть.
    if ProcessHandle <> 0 then //Если полученый дескриптор безопасности указанного процесаа получен
    begin
      try  //открывает маркер доступа , связанный с процессом. ProcessHandle-Дескриптор процесса, чей токен доступа открыт. MAXIMUM_ALLOWED-запрошенные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //TokenHandle-Указатель на дескриптор, который идентифицирует вновь открытый маркер доступа при возврате функции. для запуска процесса под системной учеткой
        begin
          try  //Функция DuplicateTokenEx создает новый маркер доступа ImpersonateToken, дублирующий существующий маркер TokenHandle, с правами и привилегиями MAXIMUM_ALLOWED и уровнем олицетворения SecurityImpersonation. Эта функция может создать либо первичный токен , либо токен олицетворения .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, SecurityIdentification, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- Указатель на переменную HANDLE , которая получает новый токен
            begin
              try // создаем переменную указатель
                New(Sid); //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                    try //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией с указанием длинны буфера ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // если получили информацию в структуру MandatoryLabel
                        if IntegrityLevel = SystemIntegrityLevel then // в соответсвии с уровнем доступа
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // назначаем уровень доступа
                        else if IntegrityLevel = HighIntegrityLevel then
                          PIntegrityLevel := HIGH_INTEGRITY_SID  //'S-1-16-12288';
                        else if IntegrityLevel = MediumIntegrityLevel then
                          PIntegrityLevel := MEDIUM_INTEGRITY_SID
                        else if IntegrityLevel = LowIntegrityLevel then
                          PIntegrityLevel := LOW_INTEGRITY_SID;
                          //SECURITY_INTERACTIVE_RID = 0x00000004
                        // AllocateAndInitializeSid(SECURITY_NT_AUTHORITY,1,12288,0,0,0,0,0,0,0,NewSid);
                        // ConvertSidToStringSid(NewSid,SidStr);
                        // Log_Write('service','CreateProcessAsUserW - SidStr='+SidStr);
                        if ConvertStringSidToSidW(PIntegrityLevel{SYSTEM_INTEGRITY_SID}, Sid) then // конвертируем SID
                        begin
                          MandatoryLabel.Label_.Sid := Sid; //в структуре присваеваем SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID является обязательным SID целостности
                          //устанавливает различные типы информации для ImpersonateToken токена доступа
                          if SetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, SizeOf(TOKEN_MANDATORY_LABEL) + GetLengthSid(Sid)) then
                          begin
                            result:=CreateProcessAsUserW(ImpersonateToken, ApplicationName, CommandLine, nil,  nil, False,CREATE_UNICODE_ENVIRONMENT,  Environment,CurrentDirectory, StartupInfo,ProcessInformation);
                            if not result then Log_Write('service',3,'CreateProcessAsUserW - CreateProcessAsUserW: '+SysErrorMessage(GetLastError()));
                            SetLastError(0);
                            Log_Write('service',2,'Запущен процесс ProcessId: '+inttostr(ProcessInformation.dwProcessId));
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
    end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка CreateProcessAsSystemNew: '+e.ClassName +': '+ e.Message);
 end;
end;




function CreateProcessAsSystemW(
  ApplicationName: PWideChar;
  CommandLine: PWideChar;
  CreationFlags: DWORD;
  Environment: Pointer;
  CurrentDirectory: PWideChar;
  StartupInfo: TStartupInfoW;IdSession:DWORD;RDPSession:boolean;
  var ProcessInformation: TProcessInformation;
  IntegrityLevel: TIntegrityLevel): Boolean;
begin
  Result := False;
  try
    if RDPSession then     //если необходимо запустить процесс в  RDP сеансе
    begin
    Result := CreateProcessAsSystemRDP(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
   // if not Result then   Log_Write('service',' CreateProcessAsSystemW не выполнено CreateProcessAsSystemNew');
    end
    else  // иначе запускаем в консоли
     begin
     Result :=CreateProcessAsSystemConsole(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
     //if not Result then   Log_Write('service',' CreateProcessAsSystemW не выполнено CreateProcessAsSystem_Service');
     end;
  except on E: Exception do
  Log_Write('service',3,'Ошибка CreateProcessAsSystemW: '+e.ClassName +': '+ e.Message);
 end;
end;

Function ProcessIDFromAppname32( szExeFileName: String ): DWORD;
var
    Snapshot: THandle;
    ProcessEntry: TProcessEntry32;
Begin
       Result := 0;
       szExeFileName := UpperCase( szExeFileName );
       Snapshot := CreateToolhelp32Snapshot(
                  TH32CS_SNAPPROCESS,
                  0 );
     If Snapshot <> 0 Then
       try
          ProcessEntry.dwSize := Sizeof( ProcessEntry );
          If Process32First( Snapshot, ProcessEntry ) Then
          Repeat
                  If Pos( szExeFileName,
                      UpperCase(ExtractFilename(
                      StrPas(ProcessEntry.szExeFile)))
                      ) > 0
                  then Begin
                       Result:= ProcessEntry.th32ProcessID;
                   Break;
                  end;
        until not Process32Next( Snapshot, ProcessEntry );
     finally
              CloseHandle( Snapshot );
     end;
  End;




//---
function RunProcAsSystem( FileName, Param: string;  IdSession:DWORD;RDPSession:boolean; Var ReadPID:integer;
  IntegrityLevel: TIntegrityLevel): Boolean; {LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel}
var
  StartupInfo: TStartupInfoW;
  ProcessInformation: TProcessInformation;
  ////////////////////////
  hToken, hUserToken: THandle;
  ProcessInfo : TProcessInformation;
  P : Pointer;
  CurrentDirectory: PWideChar;
  DesktopDef:PwideChar;
begin
try
  //if ( WindowsVersion < 60 ) and ( IntegrityLevel <> UnknownIntegrityLevel ) then  IntegrityLevel := UnknownIntegrityLevel;
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//Заполняет область памяти @StartupInfo нулями. размер области  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// заполняет раздел памяти StartupInfo тем же самым байтом или символом SizeOf(TStartupInfoW) 0 раз.
  StartupInfo.cb := SizeOf(TStartupInfoW); // Размер структуры в байтах
  //if not RDPSession then DesktopDef:= PWidechar('WinSta0\'+GetDeskNameWinlogon) else // или просто 'WinSta0\Winlogon'   //GetDeskNameWinlogon // если GetDeskName выдает Winlogon то приложение отображается на системном рабочем столе а не на столе пользователя+соответственно отображается при загрузке на столе входа
  DesktopDef:= PWidechar('WinSta0\Default');
  //Log_Write('service','NameDesktop - '+DesktopDef);
  StartupInfo.lpDesktop := DesktopDef;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  Result := CreateProcessAsSystemW(
    PWideChar(WideString(FileName)), //
    PWideChar(WideString(Param)),
    NORMAL_PRIORITY_CLASS and CREATE_NEW_CONSOLE,     //NORMAL_PRIORITY_CLASS+CREATE_NEW_CONSOLE
    nil,
    nil,
    StartupInfo,
    IdSession,
    RDPSession,
    ProcessInformation,
    IntegrityLevel);
  if Result then
  begin
    readPid:=ProcessInformation.dwProcessId;
    CloseHandle(ProcessInformation.hThread);
    CloseHandle(ProcessInformation.hProcess);
  end
  else
  begin
  //Log_Write('service','RunProcAsSystem не выполнена операция CreateProcessAsSystemW');
  end;
  except on E: Exception do
  Log_Write('service',3,'Ошибка RunProcAsSystem: '+e.ClassName +': '+ e.Message);
 end;
end;

function Initialize: Boolean;
var
  LibraryHandle: HMODULE;
begin
  Result := False;
  try
    AdjustCurrentProcessPrivilege('SeDebugPrivilege', True);
    WindowsVersion := GetWindowsVersion;
    LibraryHandle := LoadLibrary('Advapi32.dll');
    if LibraryHandle <> 0 then
    begin
      @ConvertStringSidToSidW := GetProcAddress(LibraryHandle, 'ConvertStringSidToSidW');
      @CreateProcessWithTokenW := GetProcAddress(LibraryHandle, 'CreateProcessWithTokenW');
      @ConvertStringSidToSidA := GetProcAddress(LibraryHandle, 'ConvertStringSidToSidA');
      @GetTokenInformation := GetProcAddress(LibraryHandle, 'GetTokenInformation');
      @SetTokenInformation := GetProcAddress(LibraryHandle, 'SetTokenInformation');
      @CreateProcessAsUserW := GetProcAddress(LibraryHandle, 'CreateProcessAsUserW');
      FreeLibrary(LibraryHandle);
      LibraryHandle := 0;
      Result := True;
    end;
  except
  end;
end;


//--------------------------------------------------------------------------
// функции относятся к запуску процесса по запросу пользователя
//----------------------------------------------------------------------------
Function SetPrivilege(aPrivilegeName: String; aEnabled: Boolean; var Token: THandle): Boolean;
Var TPPrev,
TP: TTokenPrivileges;
dwRetLen: DWord;
Begin
Result:=False;
TP.PrivilegeCount:=1;
IF LookupPrivilegeValue(nil,PChar(aPrivilegeName),TP.Privileges[0].LUID ) then
  Begin
  IF aEnabled then TP.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED
  else TP.Privileges[0].Attributes:=0;
  dwRetLen:= 0;
  Result:=AdjustTokenPrivileges(Token ,False,TP,SizeOf(TPPrev),TPPrev,dwRetLen);
  if not result then Log_Write('service',2,'SetPrivilege - AdjustTokenPrivileges: '+SysErrorMessage(GetLastError()));

  End
 else Log_Write('service',3,'SetPrivilege - LookupPrivilegeValue: '+SysErrorMessage(GetLastError()));
End;



function CreateProcessAsSystemRunUser(   // запуск процесса при запросе пользователя из запущенного сеанса
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
  Sid,NewSid: PSID;
  SidStr:PChar;
  MandatoryLabel: PTOKEN_MANDATORY_LABEL;
  ReturnLength: DWORD;
  PIntegrityLevel: PWideChar;
  TokenCurrentUser:THandle;
  P : Pointer;
  dwCreationFlags:dword;

  TokenHandle1: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength1: DWORD;
begin
try
    Result := False;
  if (@CreateProcessWithTokenW = nil) then //Создает новый процесс и его основной поток. Новый процесс запускается в контексте безопасности указанного токена. При желании он может загрузить профиль пользователя для указанного пользователя.
    Exit;
   //Открывает существующий локальный объект процесса. MAXIMUM_ALLOWED-права доступа. false-не наследовать дескриптор этого процесса
    ProcessHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetWinlogonProcessIdRDP(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID процесса с системными привелегиями, Идентификатор локального процесса, который необходимо открыть.
    if ProcessHandle <> 0 then //Если полученый дескриптор безопасности указанного процесаа получен
    begin
      try  //открывает маркер доступа , связанный с процессом. ProcessHandle-Дескриптор процесса, чей токен доступа открыт. MAXIMUM_ALLOWED-запрошенные типы доступа к маркеру доступа
        if OpenProcessToken(ProcessHandle, TOKEN_ALL_ACCESS, TokenHandle) then  //TokenHandle-Указатель на дескриптор, который идентифицирует вновь открытый маркер доступа при возврате функции. для запуска процесса под системной учеткой
        begin
          try  //Функция DuplicateTokenEx создает новый маркер доступа ImpersonateToken, дублирующий существующий маркер TokenHandle, с правами и привилегиями MAXIMUM_ALLOWED и уровнем олицетворения SecurityImpersonation. Эта функция может создать либо первичный токен , либо токен олицетворения .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, SecurityIdentification, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- Указатель на переменную HANDLE , которая получает новый токен
            begin
              try // создаем переменную указатель
                New(Sid); //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                    try //GetTokenInformation-извлекает информацию определенного типа о маркере доступа . MandatoryLabel-Указатель на буфер, который функция заполняет запрошенной информацией с указанием длинны буфера ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // если получили информацию в структуру MandatoryLabel
                        if IntegrityLevel = SystemIntegrityLevel then // в соответсвии с уровнем доступа
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // уровень системы (не доступны файлы в буфере обмена)
                        else if IntegrityLevel = HighIntegrityLevel then
                          PIntegrityLevel := HIGH_INTEGRITY_SID  //'S-1-16-12288'; Высокий (sendinput не работает в окнах UAC, но доступны файлы из буфера)
                        else if IntegrityLevel = MediumIntegrityLevel then
                          PIntegrityLevel := MEDIUM_INTEGRITY_SID    // средний
                        else if IntegrityLevel = LowIntegrityLevel then
                          PIntegrityLevel := LOW_INTEGRITY_SID;     // низкий
                          //SECURITY_INTERACTIVE_RID = 0x00000004
                        // AllocateAndInitializeSid(SECURITY_NT_AUTHORITY,1,12288,0,0,0,0,0,0,0,NewSid);
                        // ConvertSidToStringSid(NewSid,SidStr);
                        // Log_Write('service','CreateProcessAsUserW - SidStr='+SidStr);
                        if ConvertStringSidToSidW(PIntegrityLevel{SYSTEM_INTEGRITY_SID}, Sid) then // конвертируем SID
                        begin
                          MandatoryLabel.Label_.Sid := Sid; //в структуре присваеваем SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID является обязательным SID целостности
                          //устанавливает различные типы информации для ImpersonateToken токена доступа
                          if SetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, SizeOf(TOKEN_MANDATORY_LABEL) + GetLengthSid(Sid)) then
                          begin
                            result:=CreateProcessAsUserW(ImpersonateToken, ApplicationName, CommandLine, nil,  nil, False,CREATE_UNICODE_ENVIRONMENT,  Environment,CurrentDirectory, StartupInfo,ProcessInformation);
                           // if not result then Log_Write('service','CreateProcessAsUserW - CreateProcessAsUserW: '+SysErrorMessage(GetLastError()));
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
    end;
 except on E: Exception do
  Log_Write('service',3,'Ошибка CreateProcessAsSystemNew: '+e.ClassName +': '+ e.Message);
 end;
end;

function CreateProcessAsSystemWRunUser(
  ApplicationName: PWideChar;
  CommandLine: PWideChar;
  CreationFlags: DWORD;
  Environment: Pointer;
  CurrentDirectory: PWideChar;
  StartupInfo: TStartupInfoW;IdSession:DWORD;RDPSession:boolean;
  var ProcessInformation: TProcessInformation;
  IntegrityLevel: TIntegrityLevel): Boolean;
begin
  Result := False;
  try
    if RDPSession then     //если необходимо запустить процесс в  RDP сеансе
    begin
    Result := CreateProcessAsSystemRunUser(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
   // if not Result then   Log_Write('service',' CreateProcessAsSystemW не выполнено CreateProcessAsSystemNew');
    end
    else  // иначе запускаем в консоли
     begin
     Result := CreateProcessAsSystemRunUser(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
    // if not Result then   Log_Write('service',' CreateProcessAsSystemW не выполнено CreateProcessAsSystem_Service');
     end;
  except on E: Exception do
  Log_Write('service',3,'Ошибка CreateProcessAsSystemW: '+e.ClassName +': '+ e.Message);
 end;
end;

function RunProcAsSystemRunUser( FileName, Param: string;  IdSession:DWORD;RDPSession:boolean; Var ReadPID:integer;
  IntegrityLevel: TIntegrityLevel): Boolean; {LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel}
 var
  StartupInfo: TStartupInfoW;
  ProcessInformation: TProcessInformation;
  hToken, hUserToken: THandle;
  ProcessInfo : TProcessInformation;
  P : Pointer;
  CurrentDirectory: PWideChar;
  DesktopDef:PwideChar;
begin
try
  //if ( WindowsVersion < 60 ) and ( IntegrityLevel <> UnknownIntegrityLevel ) then  IntegrityLevel := UnknownIntegrityLevel;
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//Заполняет область памяти @StartupInfo нулями. размер области  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// заполняет раздел памяти StartupInfo тем же самым байтом или символом SizeOf(TStartupInfoW) 0 раз.
  StartupInfo.cb := SizeOf(TStartupInfoW); // Размер структуры в байтах
  //if not RDPSession then DesktopDef:= PWidechar('WinSta0\'+GetDeskNameWinlogon) else // или просто 'WinSta0\Winlogon'   //GetDeskNameWinlogon // если GetDeskName выдает Winlogon то приложение отображается на системном рабочем столе а не на столе пользователя+соответственно отображается при загрузке на столе входа
  DesktopDef:= PWidechar('WinSta0\Default');
  //Log_Write('service','NameDesktop - '+DesktopDef);
  StartupInfo.lpDesktop := DesktopDef;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  Result := CreateProcessAsSystemWRunUser(
    PWideChar(WideString(FileName)), //
    PWideChar(WideString(Param)),
    NORMAL_PRIORITY_CLASS and CREATE_NEW_CONSOLE,     //NORMAL_PRIORITY_CLASS+CREATE_NEW_CONSOLE
    nil,
    nil,
    StartupInfo,
    IdSession,
    RDPSession,
    ProcessInformation,
    IntegrityLevel);
  if Result then
  begin
    readPid:=ProcessInformation.dwProcessId;
    CloseHandle(ProcessInformation.hThread);
    CloseHandle(ProcessInformation.hProcess);
  end
  else
  begin
  //Log_Write('service','RunProcAsSystemRunUser не выполнена операция CreateProcessAsSystemW');
  end;
  except on E: Exception do
  Log_Write('service',3,'Ошибка RunProcAsSystemRunUser: '+e.ClassName +': '+ e.Message);
 end;
end;





function DeInitialize: LongBool;
begin

end;

initialization

Initialize;

finalization

DeInitialize;

end.
