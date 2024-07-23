unit Unit1;

interface

uses
  Winapi.Windows,Winapi.Messages, System.SysUtils, System.Classes,
   Vcl.SvcMgr, Vcl.Dialogs, Vcl.ExtCtrls,VCL.Forms,TlHelp32,RunAsSystem,Inifiles,Registry,ShellApi,
  Pipes,System.Hash;

type
  TRuViewerSrvc = class(TService) // ���������� ������ ���������� ������� ��������
    function RunProcInSession(numSession:integer; RunAs:string):boolean;// ������ �������� � �������� ������
    Function RunNowProcess(RunAs:string):boolean; // ������ �������� �� ����������, � ��� ����� ��� ������ ������
    function IDSessionRunProcessConsole(exeFileName: string; var IDProcess:integer): boolean; // ID ������ �������� ����������� � ���������� ������
    function processExists(exeFileName: string;IDSession:cardinal): Boolean;
    function KillprocessSession(exeFileName: string;IDSession:cardinal): Boolean;//����� � ��������� ������� ���������� � ������ IDSession
    function KillAllprocess(exeFileName: string): Boolean; ////����� � ��������� ������� ����������
    function FindprocessPID(exeFileName: string; PID:integer; ReadPID:boolean; var PIDProc:integer): Boolean; // ����� �������� �� ��� ����� � PID


    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    Procedure ShutDownAndStopSrevice(tmpStr:string);

    procedure timerFW;
    procedure TimeFWstart(Sender: TObject);
    function GetNamePC:string; // ������ ����� ��
    function ReadParamsRun(var LevelRunSrvc,LevelRunUser,LevelLog,port:integer; var Host,NamePC,AutoRun:string):boolean;
    function WriteRegSet(port:Integer;srv,NamePC,Autorun:string):boolean; // ������ �������� � ������
    Procedure ReadFileSet(var LevelRunSrvc,LevelRunUser:integer ;var srv,NamePC:string; var Port:integer; var AutoRun:String; var result:boolean);// ������ �������� �� �����
    function WriteFileSet(srv,port,NamePC,AutoRun:string):boolean; // ������ �������� � ����
    Procedure ReadRegSet(var LevelRunSrvc,LevelRunUser,levelLog,port:Integer; var srv,NamePC,Autorun:string; var result:boolean); // ������ �������� �� �������
    function WriteRegSendSAS(meaning:integer; DelValue:boolean; var OldMeaning:integer):boolean; // ������ �������� Disable or enable software Secure Attention Sequence � ������
    function EqualArraySessionID(var AddSession:ArraySession; Var DelSession:ArraySession; AllSession:ArraySession; CurSession:ArraySession):boolean;
    function HashRunFile(pachFile:string):boolean;
    procedure ServiceShutdown(Sender: TService);
    // ������� ������ ��������� � �������. ��������� �������� ������� � ���������� ������� �������������
     //// ���������� ��������� ��� ������������ ��� ����������� Windows
     private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    procedure pipesCreate;
    procedure pipesDelete;
    procedure PipeDataReceived(AData: string);
    Function ControlRunProcess(NameProcessRun:string):boolean;
    function Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
    { Public declarations }
  end;

  type
  TThread_Run_Process= class(TThread)
    TimeOutRun:integer;
    NameProcess:string;
    constructor Create(aNameProcess:string;aTimeOutRun:integer); overload;
    procedure Execute; override;
  end;


var
  RuViewerSrvc: TRuViewerSrvc;
  CurrentConsoleSessionID:cardinal; //������� �������� ���������� �����
  SessionIDConsoleRunProc:integer; //���������� ����� � ������� ������� ������� (� RDP ������� �������� ����������� �� ��������)
  TimeFW:Ttimer;
  AllSessionID:ArraySession;// ������ � �������� ���������� ������ ������������� + 0 �����
  AllRDPSessionID:ArraySession; // ������ � �������� RDP �������. � ������ ������� �������� ����������� ���������� �� ����������� ������
  PidConsoleProc:integer;
  ForceRunApp:boolean;
  ApplicationExit:boolean;
  PipeServer:TPBPipeServer; // ���������� �����
  MyStreamCipherId:string; //TCodec.StreamCipherId ��� ����������
  MyBlockCipherId:string; // TCodec.BlockCipherId ��� ����������
  MyChainModeId:string; // TCodec.ChainModeId ��� ����������
  EncodingCrypt:TEncoding; // ��������� ������ ��� ���������� � ����������
  PCUID:string;
  ServiceUID:string[255]; // ��� ����������� ��������� ���������� �� ���������
  ThreadRunPause:boolean; //������������/����� ������
  ThreadRunBreak:boolean; // ������� ���������� ������
  ThRunStart:TThread_Run_Process;
  ShutDownPC:boolean;
  LogOffUser:boolean;
  LevelLogError:integer; // ������� �����������
  LevelAutoRun:integer; // � ������ ������� ��������� ��� ����������� ��������� (ruviewer)
  //0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
  LevelRunManual:integer; // � ������ ������� ��������� ��� ������ ������� ��������� (ruviewer)
  ////0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID

  const
  TimeOutThread=3000; //����� ����������� ������
  TimeOutShutDown=15000;  // ����� �������� ������ �� ������� �������� ���� �� ����������� � ��������, ��������� � �������� ������
  TimeOutLogOff=10000;  // ����� �������� ������ �� ������� �������� ��� ������ ������������ �� �������


implementation
 uses FWW,RunasSysMy,SocketCrypt,UID;
{$R *.dfm}
function WTSQueryUserToken(SessionId: ULONG; var phToken: THandle): BOOL; stdcall;
external 'Wtsapi32.dll';
function WTSGetActiveConsoleSessionId: DWORD; stdcall;
external 'Kernel32.dll';
function CreateEnvironmentBlock(var lpEnvironment: Pointer; hToken: THandle;
                                    bInherit: BOOL): BOOL;
                                    stdcall; external 'Userenv.dll';
function DestroyEnvironmentBlock(pEnvironment: Pointer): BOOL; stdcall; external 'Userenv.dll';
Procedure SendSAS(AsUser:boolean); stdcall; external 'SAS.dll';


//////////////////////////////////////////////////////
constructor TThread_Run_Process.Create(aNameProcess:string;aTimeOutRun:integer);
begin
  inherited Create(False);
  TimeOutRun:=aTimeOutRun;
  NameProcess:=aNameProcess;
  FreeOnTerminate := true;
end;
//////////////////////////////////////////////////////
procedure TThread_Run_Process.Execute;
var
TimeShutdown:integer;
TimeLogOff:integer;
TimeWait:integer;
OutMainWhile:boolean;
 begin
   try
   RuViewerSrvc.Log_Write('Thservice',1,'�������� ����� �������');
   TimeShutdown:=TimeOutShutDown; //16 ������
   TimeLogOff:=TimeOutLogOff;  //10 ���
   TimeWait:=0;
   while (not terminated) do
     Begin
      // RuViewerSrvc.Log_Write('Thservice',0,'�������� ����� ��������');
      TimeWait:=0;
       while TimeWait<TimeOutThread do //����
       begin
       TimeWait:=TimeWait+14;
       sleep(2);
       if ThreadRunBreak then break; // ������� ������ �� �����
       end;
       if ThreadRunBreak then break; // ������� ������ �� �����

       while ThreadRunPause do
       begin
       sleep(10);
       if ThreadRunBreak then break; // ������� ������ �� �����
       end;
       if ThreadRunBreak then break; // ������� ������ �� �����

      if ShutDownPC then // ���� ������� ���������� �� �� ���� ��� ���������� ��� ��� ����� ���, �� ������ �� ����������� � ������, � ��� ��� ���������� ������ ���� ����� ��������� ����� ��� ������������� ������
      begin
      TimeShutdown:=TimeShutdown-TimeOutThread;
      ApplicationExit:=false; // �� ������ ���� ����� � ���������� ��� ��� � ����� ���� ������� ������� ���������
       if TimeShutdown<=0 then
        begin
        ShutDownPC:=false;
        TimeShutdown:=TimeOutShutDown;
        end;
      //RuViewerSrvc.Log_Write('Thservice',0,'ShutDownPC='+booltostr(ShutDownPC)+' TimeShutdown='+inttostr(TimeShutdown));
      end; //

      if LogOffUser then // ���� ������� ���������� ������ ������������
      begin
      TimeLogOff:=TimeLogOff-TimeOutThread;
       if TimeLogOff<=0 then
        begin
        LogOffUser:=false;
        TimeLogOff:=TimeOutLogOff;
        end;
      end;

      if (not ShutDownPC) and (not LogOffUser) then
      begin
      RuViewerSrvc.ControlRunProcess(NameProcess);
      end;

     End;
     RuViewerSrvc.Log_Write('Thservice',1,'�������� ����� ����������');
    except on E: Exception do
      begin
      RuViewerSrvc.Log_Write('Thservice',3,'������ ��������� ������ : '+e.ClassName +': '+ e.Message);
      end;
    end
 end;
////////////////////////////////////////////////////////////
function TRuViewerSrvc.Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
try
 if NumError<=LevelLogError then // ���� ������� ������ ���� ��� �������� � ����������
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
//////////////////////�������� hash ����� �����
function TRuViewerSrvc.HashRunFile(pachFile:string):boolean;
var
read: integer;
buffer: array[0..16383] of byte;
fs:TMemoryStream;
begin
 try
 fs:=TMemoryStream.Create;
 fs.LoadFromFile(pachFile);
 try
  with THashSHA1.Create do
  begin
    repeat
      read := FS.Read(buffer,Sizeof(buffer));
      Update(buffer,read);
    until read<>Sizeof(buffer);
  if ('d7586f727ad7290de53871e78dc346199035b1cd'=HashAsString) or //x64
  ('fcef1681027017a75f894e5d59628373798dcd61'=HashAsString)  then //x32
   result:=true
  else result:=false;
  Log_Write('service',0,'hash - '+HashAsString); //��������������� ����� �������
  result:=true; //��������������� ����� �������
  end;
 finally
 fs.Free;
 end;
  except on E: Exception do
  begin
  Log_Write('service',3,'Hash ������ : '+e.ClassName +': '+ e.Message);
  result:=true;
  end;
  end
end;
//////////////////////////////////////////////////////
////////////////////////////////////////////////////// ������� ������� ������� � ����������� �� ������������ �����
procedure TRuViewerSrvc.pipesCreate;
begin
try
PipeServer := TPBPipeServer.Create('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5');
PipeServer.OnReceivedData := PipeDataReceived;
except on E: Exception do
  begin
  Log_Write('service',3,'PipeCreate: '+e.ClassName +': '+ e.Message);
  end;
  end
end;

procedure TRuViewerSrvc.pipesDelete;
begin
try
PipeServer.Free;
except on E: Exception do
  begin
  Log_Write('service',3,'PipeDelete : '+e.ClassName +': '+ e.Message);
  end;
  end
end;

procedure TRuViewerSrvc.PipeDataReceived(AData: string);
var
tmpData,oldData:integer;
NumSes:integer;
DecryptText:string;
Btmp:boolean;
begin
try
oldData:=5;
 // Log_Write('service','MessagePipe AData - '+AData);
  Decryptstrs(AData,ServiceUID,DecryptText);
  //Log_Write('service','MessagePipe ServiceUID - '+ServiceUID);
 // Log_Write('service','MessagePipe DecryptText - '+DecryptText);
  if Pos('<|FORCERUN|>', Adata)>0 then
  begin
  Delete(Adata, 1, Pos('<|FORCERUN|>', Adata)+11);
  NumSes:= strtoint(Copy(Adata, 1, pos('<|END|>', Adata) - 1)); // ����� ������ �� �������� ��������� ��������� ���������
  ForceRunApp:=true; // ������� ������� �������� � ������
  ApplicationExit:=false; // ���� ��������� ��������� ������� (�.�.�� ������ ������ �����), ������ �� ��������� �������, ������ ����������� �� ������� � �������
  RunProcInSession(NumSes,'RunUser'); // ��������� ��������� � ������ ���������� �� ����������
  end;

 if Pos('<|ALT+CTR+DELETE|>', DecryptText)>0 then
 Begin
   if WriteRegSendSAS(1,false,oldData) then // �������� 1 ��� ���������� SendSAS ��� �����. False �.�. ������ �� �������. OldData ��������� ���������� ��������
   begin
    SendSAS(false);
    keybd_event(18, 0, 0, 0); //ALT
    keybd_event(17, 0, 0, 0); // CTRL
    keybd_event(46, 0, 0, 0); //DELETE
    sleep(200);
    keybd_event(18, 0, KEYEVENTF_KEYUP, 0); //ALT
    keybd_event(17, 0, KEYEVENTF_KEYUP, 0); // CTRL
    keybd_event(46, 0, KEYEVENTF_KEYUP, 0); //DELETE
    //Log_Write('service','�������� AltCtrlDelete.');
   end
   else Log_Write('service',2,'AltCtrlDelete. ������ �������� ���������');
   if oldData<>5 then // ���� ������ � ������ ������ �������
   begin
   if oldData=4 then WriteRegSendSAS(0,true,tmpData) // ���� ������� ���������� �������� 4 �� ����� �� ����, ������� ���.
   else WriteRegSendSAS(oldData,false,tmpData); // ����� ���� oldData=0,1,2,3 �� �������� ���� ��������, ���������� �������� ������� � ������
   end;
 End;



  if Pos('<|FORCEEXIT|>', DecryptText)>0 then
  begin
  ApplicationExit:=true; // ������� ���� ��� ��������� ������� ������� (�.�. ������ ������ �����), ������ ��������� �� �� ����
  Log_Write('service',1,'FORCEEXIT');
  end;

  if Pos('<|SHUTDOWN|>', DecryptText)>0 then  // ��������� ��  RuViewer � ��� ��� OC ��������� ������
  begin
  Delete(DecryptText, 1, Pos('<|SHUTDOWN|>', DecryptText)+11);
  if not trystrtoint(Copy(DecryptText, 1, pos('<|END|>', DecryptText) - 1),NumSes) then NumSes:=-1;
  ShutDownPC:=true;
  Log_Write('service',0,'SHUTDOWN '+inttostr(NumSes));
  end;

  if Pos('<|LOGOFF|>', DecryptText)>0 then   // ��������� ��  RuViewer � ��� ��� ������������ �������� �����
  begin
  Delete(DecryptText, 1, Pos('<|LOGOFF|>', DecryptText)+9);
  if not trystrtoint(Copy(DecryptText, 1, pos('<|END|>', DecryptText) - 1),NumSes) then NumSes:=-1; // ����� ������ �� �������� ��������� ���������� ��
  LogOffUser:=true;
  Log_Write('service',1,'LOGOFF '+inttostr(NumSes));
  end;


 except on E: Exception do
  Log_Write('service',3,'PipeMessage. ������ : '+e.ClassName +': '+ e.Message);
  end
end;

//////////////////////////////////////////////////////// ID ������ �������� ����������� � ���������� ������
function TRuViewerSrvc.IDSessionRunProcessConsole(exeFileName: string; var IDProcess:integer): boolean;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //����� ������ �������� ����������� �������
  i:integer;
  IDtemp:cardinal;
  IDBool:Boolean;
begin
try
  IDProcess := 0;
  IDtemp:=0;
  IDBool:=false;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  while Process32Next(FSnapshotHandle, FProcessEntry32) do
  Begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile))=UpperCase(ExeFileName))or(UpperCase(FProcessEntry32.szExeFile)=UpperCase(ExeFileName))) then
    begin
     //Log_Write('service','����� �������� IDSessionRunProcessConsole: '+ (UpperCase(FProcessEntry32.szExeFile))+' = '+UpperCase(ExeFileName));
     if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession � ����� ������ ������� �������
     if Length(AllRDPSessionID)=0 then // ���� ������ RDP ������ ������
       begin
       IDProcess:=IdProcSession;
       result:=true;
       end
     else
       begin
       for I := 0 to Length(AllRDPSessionID)-1 do //��������� RDP ������
        begin
        if (AllRDPSessionID[i]=IdProcSession)and (AllRDPSessionID[i]<>CurrentConsoleSessionID) then
           begin
           IDBool:=false;
           break;
           end
          else
           begin
           IDtemp:=IdProcSession;
           IDBool:=true;
           end;
        end;
        if IDBool then
        begin
        IDProcess:=IDtemp;
        //Log_Write('service','IDSessionRunProcessConsole ������� ������� � : IdProcSession = '+ inttostr(IDProcess));
        result:=true;
        break;
        end;
       if not IDBool then
         begin
         IDProcess:=0;
         result:=false;
         end;
       end;
   end;
  End;
  CloseHandle(FSnapshotHandle);
  except on E: Exception do
  begin
  result:=false;
  Log_Write('service',3,'������. IDSessionRunProcessConsole : '+e.ClassName +': '+ e.Message);
  end;
  end
end;

function TRuViewerSrvc.FindprocessPID(exeFileName: string; PID:integer; ReadPID:boolean; var PIDProc:integer): Boolean; // ����� �������� �� ��� ����� � PID
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //����� ������ �������� ����������� �������
begin
try
  Result := False;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  while Process32Next(FSnapshotHandle, FProcessEntry32) do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName)))
      then
      begin
      if readPID then // ���� ���� ������ PID ��������
        begin
        PIDProc:=FProcessEntry32.th32ProcessID;
        result:=true;
        end
      else  /// ����� ���� ��������� ����� �� ������� � ������ PID
      if PID=FProcessEntry32.th32ProcessID then
        begin
         Result := True; // ���� ������� � ������ ������
         PIDProc:=FProcessEntry32.th32ProcessID;
        end;
      end;
  end;
  CloseHandle(FSnapshotHandle);
  except on E: Exception do
  Log_Write('service',3,'������ ������ �������� �� PID: '+e.ClassName +': '+ e.Message);
  end
end;

function TRuViewerSrvc.processExists(exeFileName: string; IDSession:cardinal): Boolean; // ����� �������� � ������ ������
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //����� ������ �������� ����������� �������
begin
try
  Result := False;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  while Process32Next(FSnapshotHandle, FProcessEntry32) do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
    begin
   // Log_Write('service',1,'����� �������� ������: '+ (UpperCase(FProcessEntry32.szExeFile))+' = '+UpperCase(ExeFileName)+' ProcessID='+inttostr(FProcessEntry32.th32ProcessID));
    if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession � ����� ������ ������� �������
    begin
    if IDSession=IdProcSession then
      begin
       Result := True; // ���� ������� � ������ ������
      // Log_Write('service',1,'������� ��� ������� � : IdProcSession='+ inttostr(IdProcSession)+' IDSession='+inttostr(IDSession)+' PID = '+inttostr(FProcessEntry32.th32ProcessID));
       break; // ������� �� ����� �.�. �����
      end;
      //else Log_Write('service','����� ��������: IDSession = '+ inttostr(IDSession)+' <> IdProcSession = '+inttostr(IdProcSession));
    end;
    //else Log_Write('service','����� ��������: ProcessIdToSessionId False - IdProcSession: '+inttostr (IdProcSession));
  end;
  end;
  CloseHandle(FSnapshotHandle);
  except on E: Exception do
  Log_Write('service',3,'������ ������ ��������: '+e.ClassName +': '+ e.Message);
  end
end;
///////////////////////////////////////////////
function TRuViewerSrvc.KillprocessSession(exeFileName: string;IDSession:cardinal): Boolean;
////����� � ��������� ������� ���������� � ������ IDSession
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ErrorCode: Cardinal;
  IdProcSession:cardinal;
begin
 try
      FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
      Result := False;
      while Process32Next(FSnapshotHandle, FProcessEntry32) do
      begin
        if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
          UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
          UpperCase(ExeFileName))) then
          begin
          //Log_Write('service','����� � ���������� �������� ��������: ������ ');
          if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession � ����� ������ ������� �������
            begin
           // Log_Write('service','����� � ���������� �������� ��������: ProcessIdToSessionId: IDSession='+inttostr(IDSession)+' - IdProcSession='+inttostr(IdProcSession));
            if IDSession=IdProcSession then // ���� ������� � ������ ������
              begin
             // Log_Write('service','����� � ���������� �������� ��������: IDSession='+inttostr(IDSession)+'==IdProcSession='+inttostr(IdProcSession));
             TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),FProcessEntry32.th32ProcessID),0);
              //Log_Write('service','����� � ���������� �������� ��������: ���������� �������� '+ UpperCase(FProcessEntry32.szExeFile)+': PID'+inttostr(FProcessEntry32.th32ProcessID)+': IdProcSession'+inttostr(IdProcSession));
              Result := True;
              end;
            end;
          end;
      end;
      CloseHandle(FSnapshotHandle);
    except on E: Exception do
    Log_Write('service',3,'������ ���������� �������� '+exeFileName+': '+e.ClassName +': '+ e.Message);
    end;
end;

function TRuViewerSrvc.KillAllprocess(exeFileName: string): Boolean; ////����� � ��������� ������� ���������� �� ���� �������
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  ErrorCode: Cardinal;
  IdProcSession:cardinal;
begin
 try
      FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
      Result := False;
      while Process32Next(FSnapshotHandle, FProcessEntry32) do
      begin
        if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
          UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
          UpperCase(ExeFileName))) then
          begin
          //Log_Write('service','����� � ���������� �������� ��������: ������: '+UpperCase(FProcessEntry32.szExeFile)+': PID = '+inttostr(FProcessEntry32.th32ProcessID));
          if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession � ����� ������ ������� �������
            begin
             TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),FProcessEntry32.th32ProcessID),0);
            ///Log_Write('service','����� � ���������� �������� ��������: ���������� ��������: '+ UpperCase(FProcessEntry32.szExeFile)+': PID = '+inttostr(FProcessEntry32.th32ProcessID)+' : IdProcSession = '+inttostr(IdProcSession))
            //else Log_Write('service','������ ��� ���������� ��������: '+SysErrorMessage(GetLastError()));
            Result := True;
            end;
          end;
      end;
      CloseHandle(FSnapshotHandle);
    except on E: Exception do
    Log_Write('service',3,'������ ���������� �������� '+exeFileName+': '+e.ClassName +': '+ e.Message);
    end;
end;



procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RuViewerSrvc.Controller(CtrlCode);
end;

function TRuViewerSrvc.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;




procedure TRuViewerSrvc.TimeFWstart(Sender: TObject);
begin
FWW.startFW;
end;

procedure TRuViewerSrvc.timerFW;
begin
timeFW:=Ttimer.Create(self);
timeFW.Name:='TFW';
timeFW.interval:=12000;
timeFW.OnTimer:=TimeFWstart;
end;

function TRuViewerSrvc.GetNamePC:string;  // ������ ����� ��
var
i: DWORD;
p: PChar;
begin
  try  // ��� ��
  i:=255;
  GetMem(p, i);
  GetComputerName(p, i);
  result:=String(p);
  finally
  FreeMem(p);
  end;
end;

Procedure TRuViewerSrvc.ReadFileSet(var LevelRunSrvc,LevelRunUser:integer ;var srv,NamePC:string; var Port:integer; var AutoRun:String; var result:boolean);// ������ �������� �� �����
var
Fileset: TMemInifile;
begin
if FileExists(ExtractFilePath(Application.ExeName) + '\data.dat') then // ������ ����� ���������� ���� �� ����������
    begin
      Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName) +
        '\data.dat', TEncoding.Unicode);
      try
      Port:=Fileset.ReadInteger('Net','Port',0); //3898
      srv:=Fileset.ReadString('Net','IP','');   //������
      NamePC:=fileset.ReadString('Other','PCn','Unknw');
      AutoRun:= fileset.ReadString('Other','AutoRun','Auto');
      LevelRunSrvc:=Fileset.ReadInteger('Privileges','LevelAutoRun',0);
      LevelRunUser:=Fileset.ReadInteger('Privileges','LevelManualRun',0);
      Fileset.Free;
      result:=true;
     // Log_Write('service','������ ����� �������� :'+inttostr(port)+': '+srv+': '+NamePC);
       except on  E : Exception do
       begin
        Log_Write('service',3,'������ ������ ����� �������� :'+E.Message);
        result:=false;
       end;
       end;
     end
   else result:=false; // ���� ��� ����� ��������
end;

function TRuViewerSrvc.WriteFileSet(srv,port,NamePC,AutoRun:string):boolean; // ������ �������� � ����
var
Fileset: TMemInifile;
begin
 Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName)+'\data.dat', TEncoding.Unicode);
 try
if port<>'' then Fileset.writestring('Net','Port',port); //3898
if srv<>'' then Fileset.writestring('Net','IP',srv);   //������
if NamePC<>'' then fileset.WriteString('Other','PCn',NamePC);
if AutoRun<>'' then fileset.WriteString('Other','AutoRun',AutoRun);
fileset.UpdateFile;
Fileset.Free;
 except on  E : Exception do Log_Write('service',3,'������ ������ ����� �������� :'+E.Message);
 end;
end;

Procedure TRuViewerSrvc.ReadRegSet(var LevelRunSrvc,LevelRunUser,levelLog,port:Integer; var srv,NamePC:string; var Autorun:String; var result:boolean); // ������ �������� �� �������
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    result:=false;
    Reg := TRegistry.Create(KEY_WOW64_64KEY); //� 64� ������ �������� ������ ������ ��� 64 ���. �.�. ������ 32� �� ���� ���� ��������� ��� ������ ������� �������
    Reg.RootKey := HKEY_LOCAL_MACHINE;        //HKEY_LOCAL_MACHINE\SOFTWARE\RuViewer � �� HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\RuViewer ������� ����� �������� ������� ��� ��������� 32� ������ ���������� � �������� 64�
    if Reg.OpenKeyReadOnly('SOFTWARE\RuViewer') then  // ���� ������ ������
      begin
      port:=Reg.ReadInteger('Port');
      srv:=Reg.ReadString('IP');
      NamePC:=Reg.ReadString('PCn');
      Autorun:=Reg.ReadString('Autorun');
      levelLog:=Reg.ReadInteger('LogLevel');
      LevelRunSrvc:=Reg.ReadInteger('LevelAutoRun');
      LevelRunUser:=Reg.ReadInteger('LevelManualRun');
      result:=true;
      end;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Log_Write('service',3,'������ ������ �������� � ������� :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.WriteRegSet(port:Integer; srv,NamePC,Autorun:String):boolean; // ������ �������� � ������
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // ���� ������� ������� ����
      begin
      if port<>0 then Reg.WriteInteger('Port',Port);
      if srv<>'' then Reg.WriteString('IP',srv);
      if NamePC<>'' then Reg.WriteString('PCn',NamePC);
      if Autorun<>'' then  Reg.WriteString('Autorun',Autorun);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Log_Write('service',3,'������ ������ �������� � ������ :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.WriteRegSendSAS(meaning:Integer; DelValue:boolean; {������� ����} var OldMeaning:integer):boolean; // ������ �������� Disable or enable software Secure Attention Sequence � ������
var  //HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system - SoftwareSASGeneration - ���������� �����- �������� ���������. 0- ��������.��� �������� ��� �������� � ����� ���. 1 - ��������� ������� 2- ��������� ����������� 3-������� � �����������
  Reg: TRegistry; //https://gpsearch.azurewebsites.net/#2810
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system',false) then // ���� ������� ������� ����
      begin       //Log_Write('service','������� ���� �������');
       if not delValue then // ���� ���������� �������� ������
        begin
        if Reg.ValueExists('SoftwareSASGeneration') then // ���� ���� ���������� �� ������ ��� ��������
        OldMeaning:=Reg.ReadInteger('SoftwareSASGeneration')
        else OldMeaning:=4; // ����� ������� ����� �� ���������� � �������� �� ��������. �������� �������� ��� ������������ ����������.
        // � ����� ������ ����� ���������� �������� �����
        //Log_Write('service','������� ���� �������: ���������� ��������: '+inttostr(OldMeaning));
        Reg.WriteInteger('SoftwareSASGeneration',meaning);
        //Log_Write('service','������� ���� �������: �������� ��������: '+inttostr(meaning));
        result:=true;
        end;
       if DelValue then result:=Reg.DeleteValue('SoftwareSASGeneration'); // ���� ���������� ������� ��������;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Log_Write('service',3,'������ ������ �������� SendSAS � ������ :'+E.Message);
    result:=false;
  end;
end;
end;


function TRuViewerSrvc.ReadParamsRun(var LevelRunSrvc,LevelRunUser, LevelLog,port:integer; var Host,NamePC,AutoRun:string ):boolean; /// ������ ���������� �������
var
readSettings:boolean;
portstr:string;
begin
try
 readSettings:=false;
  {if (ParamStr(1)<>'') then // ������ ���������� ������ ������� ���������� ���� ��������� ���������� � �� ������
    Begin
      Host := ParamStr(1);  // ������ �������� ��� ip ����� ������� ��� �����������
      if (ParamStr(2)<>'') then
      if not trystrtoint(ParamStr(2),port) then port:=0;// ���� ������ �������� �� integer  �� 0
      if (ParamStr(3)='Auto') then AutoRun:='Auto' else AutoRun:='No';
      if (ParamStr(4)<>'') then NamePC:=ParamStr(4) else NamePC:=GetNamePC; // �������� ��� ����������
      if not WriteRegSet(Port,host,NamePC,AutoRun) then //�������� � ������ ����� ���� �� ���������� �� � ����
      writefileSet(host,inttostr(Port),NamePC,AutoRun); // ������ � ���� ��������
      readSettings:=true;
    End
   else } // ����� ��������� ������ � ����� ��� �������
    begin
     //Log_Write('service','������ ���������� ������� � �������');
     ReadRegSet(LevelRunSrvc,LevelRunUser,LevelLog,port,Host,NamePC,AutoRun,readSettings);// ������ ������
     if not readSettings then // ���� � ������� ��� ������ �� ������ ����
     begin
     ReadFileSet(LevelRunSrvc,LevelRunUser,Host,NamePC,port,AutoRun,readSettings); //  ������ ��������� �� �����
     end;
    end;
result:=readSettings;
except on E:Exception do
  begin
    Log_Write('service',3,'������ ������ ���������� ������� :'+E.Message);
    result:=false;
  end;
end;
end;


function TRuViewerSrvc.RunProcInSession(numSession:integer; RunAs:string):boolean; // ������ �������� ������������ �� ����������
var
typeSession,Host,NamePC,AutoRunStr:string; // Console ��� Rdp
PidTmp,port:integer;
RdpSession:boolean;
PlevelManual:RunAsSystem.TIntegrityLevel;
begin
try
 ThreadRunPause:=true; // �������� ����� ��� ������
 ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// ������ ���������� ������� ��������
 LevelLogErrorRun:=LevelLogError; // ������� ����������� � ����� AsRunSystem
 //log_Write('service',2,'RunNowProcess port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr+' LevelManual='+inttostr(LevelRunManual));
  case LevelRunManual of
   0:PlevelManual:=RunAsSystem.SystemIntegrityLevel;
   1:PlevelManual:=RunAsSystem.HighIntegrityLevel;
   2:PlevelManual:=RunAsSystem.MediumIntegrityLevel;
   else PlevelManual:=RunAsSystem.SystemIntegrityLevel;
  end;
  typeSession:=GetTypeSession(numSession); // ���������� ���� ������ RDP ��� console
 // log_Write('service',2,RunAs+' Session='+inttostr(numSession)+' Type='+typeSession);

  if typeSession='Console' then RdpSession:=false
  else if typeSession='Rdp' then RdpSession:=true;
   if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // ���� hash ����� �������������
   begin
    if RunProcAsSystemRunUser(ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' '+inttostr(LevelRunManual),numSession,RdpSession,PidConsoleProc, PlevelManual) then
     begin
     //if not RdpSession then log_Write('service', 'RunSession ������� RuViewer.exe �������� � ������ '+inttostr(numSession)+'  PID ��������  = '+inttostr(PidConsoleProc) )
     //else log_Write('service', 'RDP ������� RuViewer.exe �������� � ������ '+inttostr(numSession)+' PID �������� = '+inttostr(PidTmp));
     end
     else log_Write('service',2, 'ManualRun �� ������� ��������� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe � ������ '+inttostr(numSession) );
   end
    else log_Write('service', 2,'ManualRun ���� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
 ThreadRunPause:=false; // ��������� ����� ��� ������
except on E:Exception do
  begin
    Log_Write('service',3,'������ ������� ������� :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.RunNowProcess(RunAs:string):boolean; // ������ �������� ��� ������ ������
var
NamePC,Host:string;
Port,i:integer;
PidTmp:integer;
AutoRunStr:string;
PLevelAuto:RunAsSystem.TIntegrityLevel;
RunConsole:boolean;
begin
try
RunConsole:=false;
PidConsoleProc:=0; // ��� ������ ������� ������ PID �������� ����������� ��� ����������� ������
ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// ������ ���������� ������� ��������
 case LevelAutoRun of
   0:PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
   1:PLevelAuto:=RunAsSystem.HighIntegrityLevel;
   2:PLevelAuto:=RunAsSystem.MediumIntegrityLevel;
   else PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
  end;
log_Write('service',1,'RunNowProcess port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr+' LevelAutoRun='+inttostr(LevelAutoRun));
AllSessionID:=GetCurentSession; // �������� ������ �������� ���������� ������� �������������
AllRDPSessionID:=GetCurentRDPSession; // �������� ������ �������� RDP ������� �������������
CurrentConsoleSessionID:=0;
CurrentConsoleSessionID:=GetCurentSessionConsole; // ��������� ������ ��������� ������������
//log_Write('service','AllSessionID length='+inttostr(length(AllSessionID))+' AllRDPSessionID length='+inttostr(length(AllRDPSessionID))+' CurrentConsoleSessionID='+inttostr(CurrentConsoleSessionID));
if (AutoRunStr<>'No') then // ���� ���������� �� ��������
  Begin
    for I := 0 to Length(AllSessionID)-1 do // ���������� ������
    begin
      if not ProcessExists('RuViewer.exe',AllSessionID[i]) then    //// ������� �� ������� � ���������� ������ ���� ��� � �������� ��� PID ���� �� ������� �� ��������� �����
       begin
       if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // ���� hash ����� �������������
        begin // � ���������� ������ ������� ������ ����������� � ���������� ������� RunAsSystem.SystemIntegrityLevel, ������� �������
         if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' 0',AllSessionID[i],false,PidConsoleProc,PLevelAuto ) then
          begin
          RunConsole:=true;
          log_Write('service',1, 'RunNowProcess Console ������� RuViewer.exe �������� � ������ '+inttostr(AllSessionID[i])+'  PID ��������  = '+inttostr(PidConsoleProc) );
          end
           else log_Write('service', 2,'RunNowProcess Console �� ������� ��������� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe � ������ '+inttostr(AllSessionID[i]) );
        end
        else log_Write('service', 2,'RunNowProcess Console ���� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');

       end;
    end;

     for I := 0 to Length(AllRDPSessionID)-1 do  // ������������ (RDP) ������
     if not ProcessExists('RuViewer.exe',AllRDPSessionID[i]) then    //// ������� �� ������� ���� ��� �� ��������� �����
      begin
       if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // ���� hash ����� �������������
       begin
        if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' '+inttostr(LevelAutoRun),AllRDPSessionID[i],true,PidTmp,PLevelAuto) then
         begin
         log_Write('service',1, 'RunNowProcess RDP ������� RuViewer.exe �������� � ������ '+inttostr(AllRDPSessionID[i])+' PID �������� = '+inttostr(PidTmp));
         end
          else log_Write('service',2, 'RunNowProcess RDP �� ������� ��������� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe � ������ '+inttostr(AllRDPSessionID[i]) );
       end
       else log_Write('service', 2,'RunNowProcess RDP ���� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');

      end;
   ForceRunApp:=false; // �������  ������� �������� �������
  End;
if not RunConsole then // ���� �� ��������� ������� � �������
PidConsoleProc:= PidTmp; // ����������� ��� �������� � RDP

except on E: Exception do
Log_Write('service',3,'������ RunNowProcess: '+e.ClassName +': '+ e.Message);
end;
end;






Function TRuViewerSrvc.ControlRunProcess(NameProcessRun:string):boolean; // ������ �������� �� ������������ ������
var
port,i:integer;
Host,NamePC:string;
DSession,ASession,CurentSession:ArraySession;
pidtmp:integer;
AutoRunstr:String;
PLevelAuto:RunAsSystem.TIntegrityLevel;
begin
///////////////////////////////////////////////////////////////////// ���������� � Winlogon ������
  try
  DSession:=nil;
  ASession:=nil;
  CurentSession:=nil;
  ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// ������ ���������� ������� ��������
  LevelLogErrorRun:=LevelLogError; // ������� ����������� � ����� AsRunSystem
  case LevelAutoRun of
   0:PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
   1:PLevelAuto:=RunAsSystem.HighIntegrityLevel;
   2:PLevelAuto:=RunAsSystem.MediumIntegrityLevel;
   else PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
  end;
  //log_Write('service', 'Timer port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr);
  //AllSessionID - ������ ������� ���������� ��������
  CurentSession:=GetCurentSession; // �������� ������ ���� ���������� ������� ������������� � ������� ������
  CurrentConsoleSessionID:=GetCurentSessionConsole; // �������� ����� �������� ������ ����������� ������������
  if  ((AutoRunStr<>'No') and (not ApplicationExit)) then // ���� ���������� � ��������� ������������� �� ��������� ��� ��������� ������ �� ����������
     Begin
        if not IDSessionRunProcessConsole('RuViewer.exe',SessionIDConsoleRunProc) then  //��������� ������� ������� � ���������� ������ ��� ��� � �������� ID ������ ��������(� RDP ������� �������� ����������� �� ��������)
        begin
        // Log_Write('service',0,'���������� ������� ������� � ������ SessionIDConsoleRunProc='+ inttostr(SessionIDConsoleRunProc));
        if SessionIDConsoleRunProc=0 then
          begin
         // Log_Write('service','���������� ������� �� ������� SessionIDConsoleRunProc='+ inttostr(SessionIDConsoleRunProc));
          for I := 0 to Length(CurentSession)-1 do // ������ ��������� � ����� �������
            begin
            // Log_Write('service',2,'����� � ������ �������� � ���������� ������='+inttostr(CurentSession[i]));
              if not FindProcessPID('RuViewer.exe',PidConsoleProc,false,PidTmp) then // ��������� ������� �� ������� � PID=PidConsoleProc- ��� ������� ���������� � �������, ���� ��� �� ������ ��� ��� ���������
              begin // ���� ��������� �� ��������� � �������� ��� PID
               if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // ���� hash ����� �������������
               begin
                if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe RunService 0',CurentSession[i],false,PidConsoleProc,PLevelAuto ) then // � ���������� ������ ������� ������ ����������� � ���������� ������� RunAsSystem.SystemIntegrityLevel, ������� �������
                 begin
                 Log_Write('service',1,'ControlRunProcess Console ������� ������� RuViewer.exe � ������: '+inttostr(CurentSession[i]));
                 //log_Write('service', 'Console PID �������� '+inttostr(PidConsoleProc));
                 end
                 else Log_Write('service',2,'ControlRunProcess Console �� ������� ��������� ������� RuViewer.exe � ������: '+inttostr(CurentSession[i]));
               end
                else log_Write('service', 2,'ControlRunProcess Console ���� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
              end;
            end;
          end;
        end;
     End;

    {if EqualArraySessionID(ASession,DSession,AllSessionID,CurentSession) then //�������� ������ ��������� � ����� �������
      begin
        //for I := 0 to Length(DSession)-1 do // ���������� ��������� ����������� �������???
       // begin
         //if ProcessExists('RuViewer.exe',DSession[i])then
        // if KillprocessSession('RuViewer.exe',DSession[i]) then
        // Log_Write('service', '����������� ���������� �������� � ������: '+inttostr(DSession[i]) );
       // end;

        for I := 0 to Length(ASession)-1 do // ������ ��������� � ����� �������
        begin
          if not ProcessExists('RuViewer.exe',ASession[i]) then
          if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe '+Host+' '+inttostr(Port)+' '+NamePC,ASession[i],false,pidtmp,RunAsSystem.SystemIntegrityLevel ) then
          begin
           Log_Write('service', '������� ������� RuViewer.exe � ������: '+inttostr(ASession[i]));
           log_Write('service', 'PID �������� '+inttostr(PidTmp));
          end
          else Log_Write('service', '�� ������� ��������� ������� RuViewer.exe � ������: '+inttostr(ASession[i]));
        end;
      end;}

   // Log_Write('service', '������� �������� ���������� ����� WTSGetActiveConsoleSessionId: '+inttostr(WTSGetActiveConsoleSessionId));
   // Log_Write('service', '������� �������� ���������� �����: '+inttostr(CurrentConsoleSessionID));
   // Log_Write('service', '���������� ������� ������� � ������: '+inttostr(SessionIDConsoleRunProc));

    AllSessionID:=nil;
    AllSessionID:=GetCurentSession; // �������� ������ ���� ���������� ������� ������������� � ������� ������
    DSession:=nil;
    ASession:=nil;
    CurentSession:=nil;
     except on E: Exception do
      Log_Write('service',3,'������ ��������� �������� ���������� � ���������� �������: '+e.ClassName +': '+ e.Message);
     end;
/////////////////////////////////////////////////////////////////////////////////////////////// RDP ������
  try
  DSession:=nil;
  ASession:=nil;
  CurentSession:=nil;
  //AllRDPSessionID - ������ RDP ������� ���������� ��������
  CurentSession:=GetCurentRDPSession; // �������� ������ �������� RDP ������� ������������� � ������� ������
  if ((AutoRunStr<>'No')and (not ApplicationExit)) then /// ���� ���������� � ��������� ������������� �� ��������� ��� ��������� ������ �� ����������
    Begin                  //�����, ���������, ����������, ������� ������
    if EqualArraySessionID(ASession,DSession,AllRDPSessionID,CurentSession) then //�������� ������ ��������� � ����� �������
      begin
        for I := 0 to Length(DSession)-1 do // ���������� ��������� ����������� �������???
        begin
         if CurrentConsoleSessionID<>DSession[i] then   // ���� RDP ����� �� ��� ���������� �� �����
           begin
           if ProcessExists('RuViewer.exe',DSession[i])then // ���� �������
           KillprocessSession('RuViewer.exe',DSession[i]); // ������� ���� �� ����
          // Log_Write('service', '����������� ���������� �������� � ������: '+inttostr(DSession[i]) );
           end;
        end;

        for I := 0 to Length(ASession)-1 do // ������ ��������� � ����� �������
        begin
          if not ProcessExists('RuViewer.exe',ASession[i]) then // ���� ������� �� ������
            begin
            //Log_Write('service',2,'RDP �����, ������� �� ������� � ������ ='+ inttostr(ASession[i]));
              if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // ���� hash ����� �������������
              begin
               if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe RunService '+inttostr(LevelAutoRun),ASession[i],true,PidTmp,PLevelAuto ) then
               begin
               Log_Write('service',1, 'ControlRunProcess RDP ������� ������� RuViewer.exe � ������: '+inttostr(ASession[i]));
               //log_Write('service', 'RPD PID �������� '+inttostr(PidTmp));
               end
                else Log_Write('service', 2,'ControlRunProcess RDP �� ������� ��������� ������� RuViewer.exe � ������: '+inttostr(ASession[i]));
              end
              else log_Write('service', 2,'ControlRunProcess RDP ���� �������: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
            end;
        end;
      end;
    End;
    AllRDPSessionID:=nil;
    AllRDPSessionID:=GetCurentRDPSession; // �������� ������ �������� RDP ������� ������������� � ������� ������
    DSession:=nil;
    ASession:=nil;
    CurentSession:=nil;
   except on E: Exception do
    Log_Write('service',3,'������ ��������� �������� ���������� � RDP �������: '+e.ClassName +': '+ e.Message);
   end;
end;







Function TRuViewerSrvc.EqualArraySessionID(var AddSession:ArraySession; Var DelSession:ArraySession; AllSession:ArraySession; CurSession:ArraySession):boolean;
var
i,j:integer;
function DelElArray(r:integer; var Delmas:ArraySession):boolean; // ������� ������ � �������� �������� �� �������
var
Y,Z:integer;
begin
try
for Y := 0 to Length(delmas)-1 do
begin
 if delmas[Y]=r then  // ���� ����� ���� �������
  begin
   for Z := Y to Length(delmas)-2 do // ���������� �������� � ���������� �� ��������������, ������ ��� Z+1
    begin
    delmas[Z]:=delmas[Z+1]; // ����������� ��� �������� ����������
    end;
  Setlength(delmas,length(delmas)-1); // �������� ������ �������
  //break;
  end;
end;
except on E: Exception do Log_Write('service',3,'������� ��������� �������: '+e.ClassName +': '+ e.Message);
end;
end;

BEGIN
try
result:=false;
AddSession:=nil;
DelSession:=nil;
SetLength(AddSession,Length(CurSession));
SetLength(DelSession,Length(AllSession));
for I := 0 to Length(AllSession)-1 do DelSession[i]:=AllSession[i];
for I := 0 to Length(CurSession)-1 do AddSession[i]:=CurSession[i];
for i := 0 to Length(AllSession)-1 do
 begin
    for j := 0 to Length(CurSession)-1 do
     begin
      //Log_Write('service','��������� AllSession['+inttostr(i)+']: '+inttostr(AllSession[i])+' = CurSession['+inttostr(j)+']: '+inttostr(CurSession[j]));
      if AllSession[i]=CurSession[j] then  // ���� �������� �������� �����
       begin
       //Log_Write('service','����� AllSession['+inttostr(i)+']: '+inttostr(AllSession[i])+' = CurSession['+inttostr(j)+']: '+inttostr(CurSession[j]));
       DelElArray(AllSession[i],DelSession);       //���������� ��� �������� � ������� DelSession. � ����� ��������� ������ ��������� ������
       DelElArray(CurSession[j],AddSession);    // ���������� ��� �������� � ������� AddSession. � ����� ��������� ������ ������ ����� ���������
      // break;
       end
     end;
 end;
result:=true;
except on E: Exception do
begin
Log_Write('service',3,'������ EqualArraySessionID ��������� �������: '+e.ClassName +': '+ e.Message);
result:=false;
end;
end;
END;



procedure TRuViewerSrvc.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create(KEY_ALL_ACCESS);
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('SYSTEM\CurrentControlSet\Services\RuViewerSrvc', True);
      // ����������� ���� ��������
      Reg.WriteString('Description', '������ RuViewer');
    finally
      FreeAndNil(Reg);
    end;
   except on E: Exception do
    begin
    Log_Write('service',3,'������ Add Description RuViewerSrvc: '+e.ClassName +': '+ e.Message);
    end;
  end;
end;



procedure TRuViewerSrvc.ServiceStart(Sender: TService; var Started: Boolean);
begin
try
LevelLogErrorRun:=0; // ������� ����������� � ����� AsRunSystem
LevelLogError:=0; // ������� �����������
LevelAutoRun:=0; //0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
LevelRunManual:=0;//0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID

Log_Write('service',1,'������ ������');
PCUID:=generateUID; // ��������� ��������� UID
if length(PCUID)>=11 then ServiceUID:=copy(PCUID,1,10) //������ 10 �������� ����������� ID
 else ServiceUID:='ServiceUID';
MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId ��� ����������
MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId ��� ����������
MyChainModeId:='native.ECB'; // TCodec.ChainModeId ��� ����������
EncodingCrypt:=Tencoding.Create;
EncodingCrypt:=Tencoding.UTF8; // ��������� ��� ����������
ForceRunApp:=false; // �������  ������� �������� �������
ApplicationExit:=false; // ������� ���� ��� ��������� �� ������� ������� (�.�.�� ������ ������ �����)
RunNowProcess('FirstRun'); // ��������� �������
pipesCreate; // ������� ����������� ����� ��� ����� ������ � �����������
ShutDownPC:=false; // ����� ��� ������� ���������� �� ���� �������� =true
LogOffUser:=false; // ����� ��� ������� ���������� ������ ������������ ���� �������� =true
ThreadRunBreak:=false; //������� ���������� ������
ThreadRunPause:=false; // ������� �����
ThRunStart:=TThread_Run_Process.Create('RuViewer.exe',TimeOutThread); // ������ ������
Log_Write('service',1,'������ ��������');
Started:=true;
except on E: Exception do
    begin
    Log_Write('service',3,'������ ������� ������ : '+e.ClassName +': '+ e.Message);
    end;
  end;
end;


procedure TRuViewerSrvc.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
ShutDownAndStopSrevice('Stop.');
Stopped:=true;
end;

procedure TRuViewerSrvc.ServiceShutdown(Sender: TService);
begin
ShutDownAndStopSrevice('ShutDown.');
end;


Procedure TRuViewerSrvc.ShutDownAndStopSrevice(tmpStr:string);
begin
try
Log_Write('service',1,tmpStr+' ��������� ������');
ThreadRunBreak:=true; // ������� ������ �� ����� � ������
ThreadRunPause:=false; //��������� �����
ThRunStart.Terminate; // ������� ���������� ������
FreeAndNil(ThRunStart);
pipesDelete; // �������� ������� ����������� ������
if KillAllprocess('RuViewer.exe') then  Log_Write('service',0,'�������� �����������');
Log_Write('service',1,tmpStr+' ������ �����������');
except on E: Exception do
Log_Write('service',0,tmpStr+' ������ : '+e.ClassName +': '+ e.Message);
end;
end;


end.

