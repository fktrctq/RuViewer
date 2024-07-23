unit RunAsSystem;

interface

uses
  Windows, SysUtils, TLHelp32, AccCtrl, AclAPI,Vcl.Controls,Vcl.Forms, System.Classes;

type
  ArraySession=array of Integer;
  TIntegrityLevel = (UnknownIntegrityLevel, LowIntegrityLevel, MediumIntegrityLevel, HighIntegrityLevel, SystemIntegrityLevel);
                    //������ ����������� � ������������ �������� ��� ������ �������.  Windows ���������� ������ ������ ����������� (�������): ������, �������, ������� � ���������.
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

   function GetCurentSession:ArraySession; // ������� ������������ ���� ���������� ������� �������������
   function GetCurentRDPSession:ArraySession; // ������� ������������ ���� RDP ������� �������������
   function GetCurentSessionConsole:integer; // ������� ������ ��������� ����������� ������ ������������
   function GetTypeSession(GetNumSession:dword):string; // ������� ���������� ��� ������ Console ��� RDP ��� ��������� ������

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
  LOW_INTEGRITY_SID: PWideChar = 'S-1-16-4096'; // ������ ������������ �������   S-1-16-$00001000
  MEDIUM_INTEGRITY_SID: PWideChar = 'S-1-16-8192'; //������� ������������ ������� S-1-16-$00002000
  MEDIUM_INTEGRITY_PLUS_SID: PWideChar = 'S-1-16-8448'; //������� ����������� �� �������� �� ��������.
  HIGH_INTEGRITY_SID: PWideChar = 'S-1-16-12288';  //������� ������������ ������� S-1-16-$00003000
  SYSTEM_INTEGRITY_SID: PWideChar = 'S-1-16-16384'; //������������ ������� ������� S-1-16-$00004000
  PROTECTED_PROCESS_SID: PWideChar = 'S-1-16-20480'; //SID, �������������� ������� ����������� ����������� ��������.
  SECURITY_PROCESS_RID: PWideChar = 'S-1-16-28672'; //SID, ������� ������������ ���������� ������� ����������� ��������.
  TMP_SECURITY_RID: PWideChar = 'S-1-16-13568';

  //https://katochcisco.blogspot.com/2016/09/windows-integrity-mechanism-design.html
  SECURITY_MANDATORY_UNTRUSTED_RID = $00000000;  //���������� ������� -0
  SECURITY_MANDATORY_LOW_RID = $00001000;       //������ ������� ����������� -4096
  SECURITY_MANDATORY_MEDIUM_RID = $00002000;    //������� ������� ����������� -8192
  //SECURITY_MANDATORY_UIACCESS_RID = SECURITY_MANDATORY_MEDIUM_RID + $0x10
  SECURITY_MANDATORY_MEDIUM_PLUS_RID =$00002100;//�������: https://windowso.ru/articles/eventid-sozdaniya-protsessa-windows.html
  SECURITY_MANDATORY_HIGH_RID = $00003000;      // ������� ������� ����������� -12288
  SECURITY_MANDATORY_SYSTEM_RID = $00004000;    //������� ����������� ������� - 16384
  SECURITY_MANDATORY_PROTECTED_PROCESS_RID = $00005000; //������� ����������� ����������� �������� 20480.
  SECURITY_MANDATORY_PROCESS_RID=$00007000; //������������ ���������� ������� ����������� ��������. 28672


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
 if NumError<=LevelLogErrorRun then // ���� ������� ������ ���� ��� �������� � ����������
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


//Winsta0\Winlogon - ��� �������� ���������� � ������ ������������ ���������� �� ������������ �� ������� ����� �.�. ��, �������� �� ������ ������������....
 { inputDesktop := OpenWindowStation('Winsta0',true,GENERIC_ALL
  ���  OpenWindowStation - ��������� ��������� ������� ������� Winlogon CreateWindowStation ������� ������ ������� �������, ��������� ��� � ���������� ��������� � ��������� �������� ������.
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
  Log_Write('service',3,'������ GetDeskName: '+e.ClassName +': '+ e.Message);
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
  Log_Write('service',3,'������ GetDeskName: '+e.ClassName +': '+ e.Message);
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
var       // �������� ��� ���������� ��������� � PrivilegeName ���������� � ������� ��������
  TokenHandle: THandle;
  TokenPrivileges: TTokenPrivileges;
  ReturnLength: DWORD;
begin
  Result := False;
  try                   //GetCurrentProcess ��������� ���������������� �������� ��������.
    if OpenProcessToken(GetCurrentProcess, TOKEN_DUPLICATE, TokenHandle) then   //TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY ������� OpenProcessToken ��������� ������ ������� , ��������� � ���������.
    begin
      try
        LookupPrivilegeValueW(nil, PWideChar(PrivilegeName), TokenPrivileges.Privileges[0].Luid);   //������� LookupPrivilegeValue ��������� ��������� ���������� ������������� (LUID), ������������ � ��������� ������� ��� ���������� ������������� ���������� ����� ����������.
        TokenPrivileges.PrivilegeCount := 1;
        if Enabled then
          TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
        else
          TokenPrivileges.Privileges[0].Attributes := 0;
        if AdjustTokenPrivileges(TokenHandle, False, TokenPrivileges, 0, nil, ReturnLength) then   //������� AdjustTokenPrivileges �������� ��� ��������� ���������� � ��������� ������ ������� .
          Result := True;
      finally
        CloseHandle(TokenHandle);
      end;
    end;
 except on E: Exception do
  Log_Write('service',3,'������ AdjustCurrentProcessPrivilege: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetProcessIntegrityLevel(ProcessId: DWORD; var IntegrityLevel: TIntegrityLevel): Boolean;
var  //���������� ��������� IntegrityLevel (������� ����������) �� ��������� �������� ����� � �������������� ������������ (SID)
     //(SID �� �������� � ID ProcessId ). �������� ������������� �������� ������������� ��������������� (RID).
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
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, ProcessId); //��������� ������������ ��������� ������ ��������. ���������� �������� ���������� ���������� ��������
    if ProcessHandle <> 0 then     // ���� ���������� �������� �� ����� 0
    begin
      try  //�������� ������ ������� TokenHandle ��������� � ���� ���������. MAXIMUM_ALLOWED ����� �������, ��������� ���������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //MAXIMUM_ALLOWED ������� OpenProcessToken ��������� ������ ������� , ��������� � ���������.
        begin  // ���� ������� ������� ������ ������� TokenHandle
          try  // ReturnLength ��������� �� ����������, ������� �������� ���������� ������, ����������� ��� ������
            GetTokenInformation(TokenHandle, TokenIntegrityLevel, nil, 0, ReturnLength);   //������� GetTokenInformation ��������� ���������� ������������� ���� � ������� ������� .
            SIDAndAttributes := nil;
            GetMem(SIDAndAttributes, ReturnLength); //��������� GetMem �������� �������� ��������� � ReturnLength ���� ������, �������� ��������� �� ������ � SIDAndAttributes.
            if SIDAndAttributes <> nil then
            begin
              try  //��������� ���������� ������������� ���� � ������� ������� . TokenIntegrityLevel-���������� ��� ���������� ������� ���������. SIDAndAttributes-��������� ����� ������ ���������� �����������
                if GetTokenInformation(TokenHandle, TokenIntegrityLevel, SIDAndAttributes, ReturnLength, ReturnLength) then   // ReturnLength-������ ������
                begin  // ���� �������� ���������� � SIDAndAttributes
                  SidSubAuthorityCount := GetSidSubAuthorityCount(SIDAndAttributes.Sid); //������� GetSidSubAuthorityCount ���������� ��������� �� ������� � ��������� �������������� ������������
                  //  ������������ �������� �������� ���������� �� ���������� �������� ������� ��� ��������� ��������� SID .
                  SidSubAuthority := SidSubAuthorityCount^;
                  SidSubAuthority := SidSubAuthority - 1;
                  if IsValidSid(SIDAndAttributes.Sid) then // ���������, ��� ��������� SID �������������
                  begin
                  //GetSidSubAuthority ���������� ��������� �� ��������� �������� ����� � �������������� ������������ (SID). �������� ������������� �������� ������������� ��������������� (RID).
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
 Log_Write('service',3,'������ GetProcessIntegrityLevel: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetTokenUserName(ProcessId: DWORD; var UserName: WideString; var DomainName: WideString): Boolean;
var      // �������� ��� ������������ UserName � ����� DomainName ������������ ���������� ProcessId ��������
  ReturnLength: DWORD;
  peUse: SID_NAME_USE;
  SIDAndAttributes: PSIDAndAttributes;
  Name: PWideChar;
  Domain: PWideChar;
  ProcessHandle, TokenHandle: THandle;
begin
  Result := False;
  try ////��������� ������������ ��������� ������ ��������. ���������� �������� ���������� ���������� ��������
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, ProcessId);
    if ProcessHandle <> 0 then
    begin
      try ////�������� ������ ������� TokenHandle ��������� � ProcessHandle ��������. MAXIMUM_ALLOWED ����� �������, ��������� ���������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then
        begin
          try //// ReturnLength ��������� �� ����������, ������� �������� ���������� ������, ����������� ��� ������
            GetTokenInformation(TokenHandle, TokenUser, nil, 0, ReturnLength); //������� GetTokenInformation ��������� ���������� ������������� ���� � ������� ������� .
            GetMem(SIDAndAttributes, ReturnLength);//��������� GetMem �������� �������� ��������� � ReturnLength ���� ������, �������� ��������� �� ������ � SIDAndAttributes.
            if SIDAndAttributes <> nil then
            begin
              try ////��������� ���������� ������������� ���� � ������� ������� . TokenUser-���������� ��� ���������� ������� ���������. SIDAndAttributes-��������� ����� ������ ���������� �����������
                if GetTokenInformation(TokenHandle, TokenUser, SIDAndAttributes, ReturnLength, ReturnLength) then
                begin
                  GetMem(Name, MAX_PATH); //��������� GetMem �������� �������� ��������� � MAX_PATH ���� ������
                  GetMem(Domain, MAX_PATH);
                  if (Name <> nil) and (Domain <> nil) then
                  begin
                    try  //��������� ������������� ������������ (SIDAndAttributes.SID) � �������� ������� ������. �� ��������� ��� ������� ������ ��� ����� SID � ��� ������� ������, � ������� ���� SID ������.
                      if LookupAccountSidW(nil, SIDAndAttributes.SID, Name, ReturnLength, Domain, ReturnLength, peUse) then
                      begin           //��� ��, ��������� �� SID, ������� ��� ������������, ������ ������ ��� �����, �������� �����, ������ ������ ������, peUse-�������� �������� SID_NAME_USE ����������� ��� ������� ������
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
 Log_Write('service',3,'������ GetTokenUserName: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetWinlogonProcessIdRDP(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // �������� ID �������� winlogon ���������� ������ SessionID ������������ � ���������� ������������ SystemIntegrityLevel ��� Vista � ���� ��� ID �������� ������������ system ��� XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  IntegrityLevel: TIntegrityLevel;
  IdProcSession:DWORD;
begin
  Result := 0;
  //IdProcSession:=0;
  try //������ ������ ��������� ���������, � ����� ����, ������� � �������, ������������ ����� ����������.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-������� � ������ ��� �������� � �������. ����� ����������� ��������, ��. Process32First . 0-������������� ��������, ���� 0 �� ������� �������, � ������ ����� �� ������������ � � ������ ���������� ��� ��������
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// ���� ������� ���������� �� �������
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 ��������� ������ �� ������ ���������, ����������� � ��������� �������� ������������ �� ������ �������� ������������� ������.
        //ProcessEntry32.dwSize ������ ��������� � ������. ����� ������� ������� Process32First ���������� ��� ����� ����� �������� sizeof(PROCESSENTRY32). ���� �� �� ��������������� dwSize , Process32First ���������� �������.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //�������� ���������� � ��������� ��������, ���������� � ������������ ������ �������. ToolHelp32SnapShot-������, ProcessEntry32 -��������� �� ���������
        begin
         if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// ���� ������������� ������� � ������ ��������� = winlogon.exe
         if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // ������ ����� ������ ������������ ��� ������� ��������
         if IdProcSession=SessionID then // Log_Write('service','GetWinlogonProcessId - IdProcSession=SessionID')// ���� �� ����� �� ������ ������� ������� � ������ ��� �����, ����� ���������� ������ � ������ ������ �������
          begin
          GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID ��������
            if IntegrityLevel = SystemIntegrityLevel then //���� ������� ���������� ������������� SystemIntegrityLevel �� ���������� � ��������� ID ��������
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
 Log_Write('service',3,'������ GetWinlogonProcessIdRDP: '+e.ClassName +': '+ e.Message);
 end;
end;


function GetWinlogonProcessId(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // �������� ID �������� winlogon ���������� ������ SessionID ������������ � ���������� ������������ SystemIntegrityLevel ��� Vista � ���� ��� ID �������� ������������ system ��� XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  IntegrityLevel: TIntegrityLevel;
  UserName: WideString;
  DomainName: WideString;
  IdProcSession:DWORD;
begin
  Result := 0;
  try //������ ������ ��������� ���������, � ����� ����, ������� � �������, ������������ ����� ����������.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-������� � ������ ��� �������� � �������. ����� ����������� ��������, ��. Process32First . 0-������������� ��������, ���� 0 �� ������� �������, � ������ ����� �� ������������ � � ������ ���������� ��� ��������
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// ���� ������� ���������� �� �������
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 ��������� ������ �� ������ ���������, ����������� � ��������� �������� ������������ �� ������ �������� ������������� ������. //ProcessEntry32.dwSize ������ ��������� � ������. ����� ������� ������� Process32First ���������� ��� ����� ����� �������� sizeof(PROCESSENTRY32). ���� �� �� ��������������� dwSize , Process32First ���������� �������.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //�������� ���������� � ��������� ��������, ���������� � ������������ ������ �������. ToolHelp32SnapShot-������, ProcessEntry32 -��������� �� ���������
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// ���� ������������� ������� � ������ ��������� = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // ������ ����� ������ ������������ ��� ������� ��������
          if not IdProcSession=SessionID then Log_Write('service',3,'GetWinlogonProcessId - IdProcSession '+inttostr(IdProcSession)+ ' = SessionID '+inttostr(SessionID))// ���� �� ����� �� ������ ������� ������� � ������ ��� �����, ����� ���������� ������ � ������ ������ �������
          else
            begin // �������� ������� ���������� IntegrityLevel � �������� �������� ProcessEntry32.th32ProcessID
              GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID ��������
              if IntegrityLevel = SystemIntegrityLevel then //���� ������� ���������� ������������� SystemIntegrityLevel �� ���������� � ��������� ID ��������
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
  Log_Write('service',3,'������ GetWinlogonProcessId: '+e.ClassName +': '+ e.Message);
 end;
end;

///////////////////////////////////////////////////////////////////////////////



function GetTypeSession(GetNumSession:dword):string; // ������� ���������� ��� ������ Console ��� RDP
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
  restmp:string;
begin                        //��������� �������, 0-������,1-������ ������� ������������,Sessions-��������� �� ������ �������� WTS_SESSION_INFO
try
    if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //��������� ������ ������� �� ������� ���� ������� ��������� ������� ������
     begin
     //Log_Write('service','not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
     RaiseLastOSError;
     end;

     try
      if CountSessions > 0 then
       begin
       Session := Sessions;
        for I := 0 to CountSessions-1 do //� ����� ��������� ������
         begin
          if Session.SessionId=GetNumSession then  // ���� ����� ����� �����������
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
  Log_Write('service',3,'������ GetTypeSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function GetCurentSession:ArraySession; // ������� ������������ ���� ���������� ������� ������������� � ��� ����� �� ��������
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
  restmp:string;
begin                        //��������� �������, 0-������,1-������ ������� ������������,Sessions-��������� �� ������ �������� WTS_SESSION_INFO
  try
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //��������� ������ ������� �� ������� ���� ������� ��������� ������� ������
   begin
    //Log_Write('service','not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
    RaiseLastOSError;
   end;
     try
        if CountSessions > 0 then
        begin
          Session := Sessions;
          for I := 0 to CountSessions-1 do //� ����� ��������� ������
          begin
           if (Session.State = WTSActive) or (Session.SessionId=0) then  // ���� ����� �������. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
            begin
            //Log_Write('service','Console Session.State = WTSActive SessionId='+inttostr(Session.SessionId));
              // ��������� �������� � ������.
              //WTS_CURRENT_SERVER_HANDLE-���������� �������,Session.SessionId-�����,
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
                  Setlength(result,length(result)+1); // ���������� ������ ������� ��� ������� ������
                  result[length(result)-1]:=integer(Session.SessionId); //��������� � ������ ����� ������
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
        Log_Write('service','���������� ������ GetCurentSession: '+restmp);
        end;}
     end;
 except on E: Exception do
  Log_Write('service',3,'������ GetCurentSession: '+e.ClassName +': '+ e.Message);
 end;
end;

function GetCurentRDPSession:ArraySession; // ������� ������������ RDP ������� ������������� � ��� ����� �� ��������
var
  Sessions,Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName: LPTSTR;
  restmp:string;
begin
try                        //��������� �������, 0-������,1-������ ������� ������������,Sessions-��������� �� ������ �������� WTS_SESSION_INFO
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //��������� ������ ������� �� ������� ���� ������� ��������� ������� ������
    begin
    //Log_Write('service','RDP not WTSEnumerateSessions: '+SysErrorMessage(GetLastError));
    end;
      try
        if CountSessions > 0 then
        begin
        Session := Sessions;
          for I := 0 to CountSessions-1 do //� ����� ��������� ������
          begin
           if Session.State = WTSActive then  // ���� ����� �������. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
            begin
           // Log_Write('service','RDP Session.State = WTSActive SessionId='+inttostr(Session.SessionId));
             if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes))
               and (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes))
               then
                begin
                 //Log_Write('service','RDP UserName='+UserName+' WWinStationName='+WWinStationName );
                   if (UserName<>'') and (pos('RDP', WWinStationName)>0) then
                    begin
                    Setlength(result,length(result)+1); // ���������� ������ ������� ��� ������� ������
                    result[length(result)-1]:=integer(Session.SessionId); //��������� � ������ ����� ������
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
        //Log_Write('service','RDP ������ GetCurentRDPSession: '+restmp);
        end;
      end;
 except on E: Exception do
 Log_Write('service',3,'������ GetCurentRDPSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function GetCurentSessionConsole:integer; // ������� ������ ��������� ����������� ������ ������������. �������� ���������� ����� ����� ���� ������ ����
var
  Sessions, Session: PWTS_SESSION_INFO;
  CountSessions, I, NumBytes: DWORD;
  UserName,WWinStationName,WDomainName,WClientName,WClientProtocolType: LPTSTR;
begin                        //��������� �������, 0-������,1-������ ������� ������������,Sessions-��������� �� ������ �������� WTS_SESSION_INFO
  try
  if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, CountSessions) then //��������� ������ ������� �� ������� ���� ������� ��������� ������� ������
    RaiseLastOSError;
  try
    if CountSessions > 0 then
    begin
      Session := Sessions;
      for I := 0 to CountSessions-1 do //� ����� ��������� ������
      begin
       if Session.State = WTSActive then  // ���� ����� �������. WTSActive,WTSConnected,WTSConnectQuery,WTSShadow, WTSDisconnected, WTSIdle,WTSListen,WTSReset,WTSDown,WTSInit
        begin
        if (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes))
          and (WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSWinStationName, WWinStationName, NumBytes))
           then
          begin
            try
             if (UserName<>'')  and ((pos(UpperCase('Console'), UpperCase(WWinStationName))>0)) then
              begin
              result:=integer(Session.SessionId); //��������� ����� ������
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
  Log_Write('service',3,'������ GetCurentSession: '+e.ClassName +': '+ e.Message);
 end;
end;


function CreateProcessAsSystemConsole(   // ������ �������� � ���������� ������
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
  if (@CreateProcessWithTokenW = nil) then //������� ����� ������� � ��� �������� �����. ����� ������� ����������� � ��������� ������������ ���������� ������. ��� ������� �� ����� ��������� ������� ������������ ��� ���������� ������������.
    Exit;
   //��������� ������������ ��������� ������ ��������. MAXIMUM_ALLOWED-����� �������. false-�� ����������� ���������� ����� ��������
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, false, GetWinlogonProcessId(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID �������� � ���������� ������������, ������������� ���������� ��������, ������� ���������� �������.
    //Log_Write('service','CreateProcessAsSystem_Service - OpenProcess');
    if ProcessHandle = 0 then Log_Write('service',2,'CreateProcessAsUserW - ProcessHandle = 0: '+SysErrorMessage(GetLastError()))//���� ��������� ���������� ������������ ���������� �������� �������
    else
    begin
      try  //��������� ������ ������� , ��������� � ���������. ProcessHandle-���������� ��������, ��� ����� ������� ������. MAXIMUM_ALLOWED-����������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //TokenHandle-��������� �� ����������, ������� �������������� ����� �������� ������ ������� ��� �������� �������. ��� ������� �������� ��� ��������� �������
        begin
        //Log_Write('service','CreateProcessAsSystem_Service - OpenProcessToken');
          try  //������� DuplicateTokenEx ������� ����� ������ ������� ImpersonateToken, ����������� ������������ ������ TokenHandle, � ������� � ������������ MAXIMUM_ALLOWED � ������� ������������� SecurityImpersonation. ��� ������� ����� ������� ���� ��������� ����� , ���� ����� ������������� .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, {SecurityIdentification}SecurityImpersonation, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- ��������� �� ���������� HANDLE , ������� �������� ����� �����
            begin
              try // ������� ���������� ���������
                begin // ���� �������� ���������� � ��������� MandatoryLabel
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
  Log_Write('service',3,'������ CreateProcessAsSystem_Service: '+e.ClassName +': '+ e.Message);
 end;
end;

function CreateProcessAsSystemRDP(   // ������ �������� � RDP ������
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
  if (@CreateProcessWithTokenW = nil) then //������� ����� ������� � ��� �������� �����. ����� ������� ����������� � ��������� ������������ ���������� ������. ��� ������� �� ����� ��������� ������� ������������ ��� ���������� ������������.
    Exit;
   //��������� ������������ ��������� ������ ��������. MAXIMUM_ALLOWED-����� �������. false-�� ����������� ���������� ����� ��������
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, GetWinlogonProcessIdRDP(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID �������� � ���������� ������������, ������������� ���������� ��������, ������� ���������� �������.
    if ProcessHandle <> 0 then //���� ��������� ���������� ������������ ���������� �������� �������
    begin
      try  //��������� ������ ������� , ��������� � ���������. ProcessHandle-���������� ��������, ��� ����� ������� ������. MAXIMUM_ALLOWED-����������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //TokenHandle-��������� �� ����������, ������� �������������� ����� �������� ������ ������� ��� �������� �������. ��� ������� �������� ��� ��������� �������
        begin
          try  //������� DuplicateTokenEx ������� ����� ������ ������� ImpersonateToken, ����������� ������������ ������ TokenHandle, � ������� � ������������ MAXIMUM_ALLOWED � ������� ������������� SecurityImpersonation. ��� ������� ����� ������� ���� ��������� ����� , ���� ����� ������������� .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, SecurityIdentification, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- ��������� �� ���������� HANDLE , ������� �������� ����� �����
            begin
              try // ������� ���������� ���������
                New(Sid); //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� �����������
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                    try //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� ����������� � ��������� ������ ������ ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // ���� �������� ���������� � ��������� MandatoryLabel
                        if IntegrityLevel = SystemIntegrityLevel then // � ����������� � ������� �������
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // ��������� ������� �������
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
                        if ConvertStringSidToSidW(PIntegrityLevel{SYSTEM_INTEGRITY_SID}, Sid) then // ������������ SID
                        begin
                          MandatoryLabel.Label_.Sid := Sid; //� ��������� ����������� SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID �������� ������������ SID �����������
                          //������������� ��������� ���� ���������� ��� ImpersonateToken ������ �������
                          if SetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, SizeOf(TOKEN_MANDATORY_LABEL) + GetLengthSid(Sid)) then
                          begin
                            result:=CreateProcessAsUserW(ImpersonateToken, ApplicationName, CommandLine, nil,  nil, False,CREATE_UNICODE_ENVIRONMENT,  Environment,CurrentDirectory, StartupInfo,ProcessInformation);
                            if not result then Log_Write('service',3,'CreateProcessAsUserW - CreateProcessAsUserW: '+SysErrorMessage(GetLastError()));
                            SetLastError(0);
                            Log_Write('service',2,'������� ������� ProcessId: '+inttostr(ProcessInformation.dwProcessId));
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
  Log_Write('service',3,'������ CreateProcessAsSystemNew: '+e.ClassName +': '+ e.Message);
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
    if RDPSession then     //���� ���������� ��������� ������� �  RDP ������
    begin
    Result := CreateProcessAsSystemRDP(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
   // if not Result then   Log_Write('service',' CreateProcessAsSystemW �� ��������� CreateProcessAsSystemNew');
    end
    else  // ����� ��������� � �������
     begin
     Result :=CreateProcessAsSystemConsole(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
     //if not Result then   Log_Write('service',' CreateProcessAsSystemW �� ��������� CreateProcessAsSystem_Service');
     end;
  except on E: Exception do
  Log_Write('service',3,'������ CreateProcessAsSystemW: '+e.ClassName +': '+ e.Message);
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
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//��������� ������� ������ @StartupInfo ������. ������ �������  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// ��������� ������ ������ StartupInfo ��� �� ����� ������ ��� �������� SizeOf(TStartupInfoW) 0 ���.
  StartupInfo.cb := SizeOf(TStartupInfoW); // ������ ��������� � ������
  //if not RDPSession then DesktopDef:= PWidechar('WinSta0\'+GetDeskNameWinlogon) else // ��� ������ 'WinSta0\Winlogon'   //GetDeskNameWinlogon // ���� GetDeskName ������ Winlogon �� ���������� ������������ �� ��������� ������� ����� � �� �� ����� ������������+�������������� ������������ ��� �������� �� ����� �����
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
  //Log_Write('service','RunProcAsSystem �� ��������� �������� CreateProcessAsSystemW');
  end;
  except on E: Exception do
  Log_Write('service',3,'������ RunProcAsSystem: '+e.ClassName +': '+ e.Message);
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
// ������� ��������� � ������� �������� �� ������� ������������
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



function CreateProcessAsSystemRunUser(   // ������ �������� ��� ������� ������������ �� ����������� ������
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
  if (@CreateProcessWithTokenW = nil) then //������� ����� ������� � ��� �������� �����. ����� ������� ����������� � ��������� ������������ ���������� ������. ��� ������� �� ����� ��������� ������� ������������ ��� ���������� ������������.
    Exit;
   //��������� ������������ ��������� ������ ��������. MAXIMUM_ALLOWED-����� �������. false-�� ����������� ���������� ����� ��������
    ProcessHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetWinlogonProcessIdRDP(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID �������� � ���������� ������������, ������������� ���������� ��������, ������� ���������� �������.
    if ProcessHandle <> 0 then //���� ��������� ���������� ������������ ���������� �������� �������
    begin
      try  //��������� ������ ������� , ��������� � ���������. ProcessHandle-���������� ��������, ��� ����� ������� ������. MAXIMUM_ALLOWED-����������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle, TOKEN_ALL_ACCESS, TokenHandle) then  //TokenHandle-��������� �� ����������, ������� �������������� ����� �������� ������ ������� ��� �������� �������. ��� ������� �������� ��� ��������� �������
        begin
          try  //������� DuplicateTokenEx ������� ����� ������ ������� ImpersonateToken, ����������� ������������ ������ TokenHandle, � ������� � ������������ MAXIMUM_ALLOWED � ������� ������������� SecurityImpersonation. ��� ������� ����� ������� ���� ��������� ����� , ���� ����� ������������� .
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, nil, SecurityIdentification, TokenPrimary, ImpersonateToken) then //SecurityImpersonation //ImpersonateToken- ��������� �� ���������� HANDLE , ������� �������� ����� �����
            begin
              try // ������� ���������� ���������
                New(Sid); //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� �����������
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                    try //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� ����������� � ��������� ������ ������ ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // ���� �������� ���������� � ��������� MandatoryLabel
                        if IntegrityLevel = SystemIntegrityLevel then // � ����������� � ������� �������
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // ������� ������� (�� �������� ����� � ������ ������)
                        else if IntegrityLevel = HighIntegrityLevel then
                          PIntegrityLevel := HIGH_INTEGRITY_SID  //'S-1-16-12288'; ������� (sendinput �� �������� � ����� UAC, �� �������� ����� �� ������)
                        else if IntegrityLevel = MediumIntegrityLevel then
                          PIntegrityLevel := MEDIUM_INTEGRITY_SID    // �������
                        else if IntegrityLevel = LowIntegrityLevel then
                          PIntegrityLevel := LOW_INTEGRITY_SID;     // ������
                          //SECURITY_INTERACTIVE_RID = 0x00000004
                        // AllocateAndInitializeSid(SECURITY_NT_AUTHORITY,1,12288,0,0,0,0,0,0,0,NewSid);
                        // ConvertSidToStringSid(NewSid,SidStr);
                        // Log_Write('service','CreateProcessAsUserW - SidStr='+SidStr);
                        if ConvertStringSidToSidW(PIntegrityLevel{SYSTEM_INTEGRITY_SID}, Sid) then // ������������ SID
                        begin
                          MandatoryLabel.Label_.Sid := Sid; //� ��������� ����������� SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID �������� ������������ SID �����������
                          //������������� ��������� ���� ���������� ��� ImpersonateToken ������ �������
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
  Log_Write('service',3,'������ CreateProcessAsSystemNew: '+e.ClassName +': '+ e.Message);
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
    if RDPSession then     //���� ���������� ��������� ������� �  RDP ������
    begin
    Result := CreateProcessAsSystemRunUser(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
   // if not Result then   Log_Write('service',' CreateProcessAsSystemW �� ��������� CreateProcessAsSystemNew');
    end
    else  // ����� ��������� � �������
     begin
     Result := CreateProcessAsSystemRunUser(ApplicationName, CommandLine, CreationFlags, Environment, CurrentDirectory, StartupInfo,IdSession, ProcessInformation, IntegrityLevel);
    // if not Result then   Log_Write('service',' CreateProcessAsSystemW �� ��������� CreateProcessAsSystem_Service');
     end;
  except on E: Exception do
  Log_Write('service',3,'������ CreateProcessAsSystemW: '+e.ClassName +': '+ e.Message);
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
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//��������� ������� ������ @StartupInfo ������. ������ �������  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// ��������� ������ ������ StartupInfo ��� �� ����� ������ ��� �������� SizeOf(TStartupInfoW) 0 ���.
  StartupInfo.cb := SizeOf(TStartupInfoW); // ������ ��������� � ������
  //if not RDPSession then DesktopDef:= PWidechar('WinSta0\'+GetDeskNameWinlogon) else // ��� ������ 'WinSta0\Winlogon'   //GetDeskNameWinlogon // ���� GetDeskName ������ Winlogon �� ���������� ������������ �� ��������� ������� ����� � �� �� ����� ������������+�������������� ������������ ��� �������� �� ����� �����
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
  //Log_Write('service','RunProcAsSystemRunUser �� ��������� �������� CreateProcessAsSystemW');
  end;
  except on E: Exception do
  Log_Write('service',3,'������ RunProcAsSystemRunUser: '+e.ClassName +': '+ e.Message);
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
