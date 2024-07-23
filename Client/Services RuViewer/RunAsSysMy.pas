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
function GetCurrentDesktop:string; // ��� �������� �������� �����

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
        if OpenProcessToken(ProcessHandle, MAXIMUM_ALLOWED, TokenHandle) then  //������� OpenProcessToken ��������� ������ ������� , ��������� � ���������.
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
  except
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
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then // ���� ������� ���������� �� �������
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 ��������� ������ �� ������ ���������, ����������� � ��������� �������� ������������ �� ������ �������� ������������� ������.
        //ProcessEntry32.dwSize ������ ��������� � ������. ����� ������� ������� Process32First ���������� ��� ����� ����� �������� sizeof(PROCESSENTRY32). ���� �� �� ��������������� dwSize , Process32First ���������� �������.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //�������� ���������� � ��������� ��������, ���������� � ������������ ������ �������. ToolHelp32SnapShot-������, ProcessEntry32 -��������� �� ���������
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then // ���� ������������� ������� � ������ ��������� = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then // ������ ����� ������ ������������ ��� ������� ��������
          if IdProcSession=SessionID then // ���� �� ����� �� ������ ������� ������� � ������ ��� �����, ����� ���������� ������ � ������ ������ �������
               GetProcessIntegrityLevel(ProcessEntry32.th32ProcessID, IntegrityLevel); // ProcessEntry32.th32ProcessID-ID ��������
              if IntegrityLevel = SystemIntegrityLevel then //���� ������� ���������� ������������� SystemIntegrityLevel �� ���������� � ��������� ID ��������
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


function GetCurrentDesktop:string; // ��� �������� �������� �����
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
except on E: Exception do Log_Write('service','������ GetCurrentDesktop: '+e.ClassName +': '+ e.Message);
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
  if (@CreateProcessWithTokenW = nil) then //������� ����� ������� � ��� �������� �����. ����� ������� ����������� � ��������� ������������ ���������� ������. ��� ������� �� ����� ��������� ������� ������������ ��� ���������� ������������.
    Exit;
  step:=0;
  try    //��������� ������������ ��������� ������ ��������. MAXIMUM_ALLOWED-����� �������. false-�� ����������� ���������� ����� ��������
    ProcessHandle := OpenProcess(MAXIMUM_ALLOWED, False, GetWinlogonProcessId(IdSession,'winlogon.exe')); //GetWinlogonProcessId-ID �������� � ���������� ������������, ������������� ���������� ��������, ������� ���������� �������.
    if ProcessHandle = 0 then Log_Write('service','CreateProcessAsSystemThread: ProcessHandle = 0');//���� ��������� ���������� ������������ ���������� �������� �������
    step:=1;
      try  //��������� ������ ������� , ��������� � ���������. ProcessHandle-���������� ��������, ��� ����� ������� ������. MAXIMUM_ALLOWED-����������� ���� ������� � ������� �������
        if OpenProcessToken(ProcessHandle,TOKEN_DUPLICATE {MAXIMUM_ALLOWED}, TokenHandle) then  //TokenHandle-��������� �� ����������, ������� �������������� ����� �������� ������ ������� ��� �������� �������. ��� ������� �������� ��� ��������� �������
        begin
        step:=2;
          try  //������� DuplicateTokenEx ������� ����� ������ ������� ImpersonateToken, ����������� ������������ ������ TokenHandle, � ������� � ������������ MAXIMUM_ALLOWED � ������� ������������� SecurityImpersonation. ��� ������� ����� ������� ���� ��������� ����� , ���� ����� ������������� .
            sa.nLength:= sizeof(sa);
            if DuplicateTokenEx(TokenHandle, MAXIMUM_ALLOWED, @sa, SecurityIdentification, TokenPrimary, ImpersonateToken) then //ImpersonateToken- ��������� �� ���������� HANDLE , ������� �������� ����� �����
            begin
            step:=3;
              try // ������� ���������� ���������
                New(Sid); //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� �����������
                if (not GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, 0, ReturnLength)) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
                begin
                step:=4;
                  MandatoryLabel := nil;
                  GetMem(MandatoryLabel, ReturnLength);
                  if MandatoryLabel <> nil then
                  begin
                  step:=5;
                    try //GetTokenInformation-��������� ���������� ������������� ���� � ������� ������� . MandatoryLabel-��������� �� �����, ������� ������� ��������� ����������� ����������� � ��������� ������ ������ ReturnLength
                      if GetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, ReturnLength, ReturnLength) then
                      begin // ���� �������� ���������� � ��������� MandatoryLabel
                        step:=6;
                        if IntegrityLevel = SystemIntegrityLevel then // � ����������� � ������� �������
                          PIntegrityLevel := SYSTEM_INTEGRITY_SID    // ��������� ������� �������
                        else if IntegrityLevel = HighIntegrityLevel then
                          PIntegrityLevel := HIGH_INTEGRITY_SID
                        else if IntegrityLevel = MediumIntegrityLevel then
                          PIntegrityLevel := MEDIUM_INTEGRITY_SID
                        else if IntegrityLevel = LowIntegrityLevel then
                          PIntegrityLevel := LOW_INTEGRITY_SID;
                        if ConvertStringSidToSidW(PIntegrityLevel, Sid) then // ������������ SID
                        begin
                        step:=7;
                          MandatoryLabel.Label_.Sid := Sid; //� ��������� ����������� SID
                          MandatoryLabel.Label_.Attributes := SE_GROUP_INTEGRITY; //SE_GROUP_INTEGRITY-SID �������� ������������ SID �����������
                          //������������� ��������� ���� ���������� ��� ImpersonateToken ������ �������
                          if SetTokenInformation(ImpersonateToken, TTokenInformationClass(TokenIntegrityLevel), MandatoryLabel, SizeOf(TOKEN_MANDATORY_LABEL) + GetLengthSid(Sid)) then
                          begin //������� ����� ������� � ��� �������� �����. ����� ������� ����������� � ��������� ������������ ���������� ������. ��� ������� �� ����� ��������� ������� ������������ ��� ���������� ������������.
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
  Log_Write('service','������ CreateProcessAsSystemThread: ��� '+inttostr(step)+': '+e.ClassName +': '+ e.Message);
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
  ZeroMemory(@StartupInfo, SizeOf(TStartupInfoW));//��������� ������� ������ @StartupInfo ������. ������ �������  SizeOf(TStartupInfoW)
  FillChar(StartupInfo, SizeOf(TStartupInfoW), 0);// ��������� ������ ������ StartupInfo ��� �� ����� ������ ��� �������� SizeOf(TStartupInfoW) 0 ���.
  StartupInfo.cb := SizeOf(TStartupInfoW); // ������ ��������� � ������
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
  Log_Write('service','������ CreateProcessAsSystemThread: '+e.ClassName +': '+ e.Message);
  end;
end;


/////////////////////////////////////////////////////////////////////////////////////////////////////////

end.

