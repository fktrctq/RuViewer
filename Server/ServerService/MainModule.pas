unit MainModule;

interface

uses
  Winapi.Windows,Winapi.WinSock,ShellAPI, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr,
   Vcl.Dialogs,VCL.Forms,Registry,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,inifiles,
    uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants,
    uTPLb_Signatory, uTPLb_SimpleBlockCipher;
type    // ��������� ��� ����������� �������� RuViewer
  TClientMRSD = record
    ConnectBusy:Boolean;
    ItemBusy:byte;
    MainSocket: TCustomWinSocket;
    targetMainSocket: TCustomWinSocket;
    DesktopSocket: TCustomWinSocket;
    targetDesktopSocket: TCustomWinSocket;
    FilesSocket: TCustomWinSocket;
    targetFilesSocket: TCustomWinSocket;
    //MyID: string[255];
    ID: string[255];
    PCUID:String[255]; //UID ����������
    Password: string[255];
    TargetID: string[255];
    TargetPassword: string[255];
    PingStart: Int64;
    PingEnd: Int64;
    PingAnswer:boolean;
    PaswdAdmin:string[255];
    NamePC:String[255];
    dateTimeConnect:Tdatetime;
    mainSocketHandle:string[255];
    //ClientAddress:string[255];
    ServerAddress:string[255];
    ServerPort:integer;
  end;


type    // ��������� ��� ��������/��������� ���������� ��������
 TserverClst = record
   SocketHandle:UIntPtr;
   ServerAddress:string[255];
   ServerPort:integer;
   ServerPassword:string[255];
   PingStart: Int64;
   PingEnd: Int64;
   MyPing:int64;
   PingAnswer:boolean;
   InOutput:byte; // ������� ���������� ��� ��������� ���������� 1- �������� 2-��������� 0-���������� �� �����������
   IDConnect:byte;  //������ ������ �������
   PrefixUpdate:byte; // 1 - ��������� ������ �� ��������
   StatusConnect:byte; // ������ ����������
   DateTimeStatus:TdateTime; // ���� � ����� ��������� StatusConnect
   CloseThread:boolean; // ������� ������������� ��������� ����� � ������� �����
 end;

Type    // ��������� ��� �������� �������� ������� � ��������
 TPrefixSrv = record
   SrvPrefix:string[10];
   SrvPort:integer;
   SrvIp:string[100];
   SrvPswd:string[50];
   DateCreate:string[20];
 end;

//----------------------------------------------------------------------
type
  TThreadConnection_Main = class(TThread)
  private
    ID: string;
    TargetID: string;
    TargetPassword: string;
    PaswdAdmin:string;
    IDConnect:integer;
    PswdCryptMain:string[255];
    PswdCryptTarget:string[255];
  public
    constructor Create(aSocket: TCustomWinSocket;NmPC:String; aIDConnect:integer; aUID:string;aPswd:String;aID:string); overload;
    procedure Execute; override; // ��������� ���������� ������
    function SendMainSock(s:string):boolean;
    function SendTargetSock(s:string):boolean;
    Procedure AddConnect;
    procedure InsertPing;
    function NewCheckIDExists(ID: string): Boolean;  // ���������� �� ������ ID � �������� �� ��� ���������� ��������
    function FindIDinClaster(ID: string; var ServerIP:string; var ServerPort:integer; var SrvPswd:string):boolean; //����� �������� ���������� ID � ��������
    function CorrectID( ID:string):boolean;  // ������� �������� ������������ ID
    function CorrectPrefixID(ID:string):boolean; // �������� ID �� ��� �������
    function GenerateID: string; // ��������� ID
    function NewCheckIDPassword(ID, Password: string): Boolean; //������������ ������ � ID � ������
    function NewFindListItemID(ID: string):TClientMRSD; // �������� TClientMRSD  � ��������� ID
    function CleanMyConnect(IndexID:integer):boolean; // ������� �������� ������� ����� �����������
    function CleanTargetConnect(IndexID:integer):boolean; // ������� �������� ������� ��������(target) �����������
    function FindConnectID(ID: string):integer; // �������� ����������� ������ �������� ������� ����������  � ��������� ID
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
  end;

  //��� ���������� Thread to Define � Desktop.
type
  TThreadConnection_Desktop = class(TThread)
  private
    MyID: string;
    IDConnect:integer;
  public
    constructor Create(aSocket: TCustomWinSocket; ID: string; aIDConnect:integer); overload;
    procedure Execute; override;
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
  end;


  // Thread to Define type connection are Files.
type
  TThreadConnection_Files = class(TThread)
  private
    MyID: string;
    IDConnect:integer;
  public
    constructor Create(aSocket: TCustomWinSocket; ID: string; aIDConnect:integer); overload;
    procedure Execute; override;
    function Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
  end;



//  ����� ��� ����������� ���� �����������, ���� ��������, ��������� ������� ����, �������� ��� �������� ������.
type
  TThreadConnection_One = class(TThread)
  private
    defineSocket: TCustomWinSocket;
    IDTemp:string;
  public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override; // ��������� ���������� ������ // ����� ������������ ������� �������� �� �������� �������(�����������)
    function CorrectPrefixID(ID:string):boolean; // �������� ID �� ��� �������
    function NewCheckIDExists(ID: string): Boolean;  // ���������� �� ������ ID � �������� �� ��� ���������� ��������
    function AddRecordClient(var NextClient:integer):boolean;  //������ ������ ������������� ������� ������ ������ � ������� �����������
    function CorrectID( ID:string):boolean;  // ������� �������� ������������ ID
    function GenerateID(): string; // ��������� ID
    function FindConnectID(ID: string; var OutIndex:integer):boolean; // �������� ����������� ������ �������� ������� ����������  � ��������� ID
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  //����� ��� - TThreadConnection_Main, TThreadConnection_Desktop, TThreadConnection_Keyboard, TThreadConnection_Files
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
  end;

  // Thread to Define type connection are Main.
  //��� ���������� Thread to Define � ��� Main.  �������� ����� ��������� �����������
  // �������� ����� � ��������� RuViewer
  type
  ThreadPingClient = class(TThread) // ����� ��� �������� �����������  ������� RuViewer
  private
    TimeoutConnect:cardinal;
    IDConnect:integer;
    TmpID:string;
  public
    constructor Create(aIDConnect:integer); overload;
    procedure Execute; override;
    function Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function SendMainSock(s:string):boolean; // ������� �������� ����� �������� �����
  end;

  //-----����� ��� ���������� ������� �� �������
  type
  ThReadConsoleManager = class(TThread)
    private
    AdmSocket: TCustomWinSocket;
    public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override; // ��������� ���������� ������ // ����� ������������ ������� �������� �� �������� �������(�����������)
    function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
    function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
    function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
    function SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
    function ListServerClasterToList:string; // ��������� ������ �� ������� �������� ��������
    function ListClientRuViewerToList:string; //������ �� ������� �������� RuViewer
    function StatusRuViewerServer:boolean;  // ����������� ������� ������ ������� RuViewer
    Procedure StopInConnectClaster;  // ��������� ������ �������� ���������� ��������
    function RebootServices:boolean;
    Function StopOutConnectClaster:boolean;  // ��������� ������ ��������� ���������� ��������
    Function StopConnectClaster(ConnectID:integer):boolean;  // ��������� ��������� ���������� � ��������
    procedure StopServerRuViewerSocket; // ��������� ������� RuViewer
    procedure CleanArrayPrefix; // ������� ��������� ������� ��������� ��������
    procedure CleanArrayClaster; // ������� ��������� ������� ��� ����������� �������� � ��������
    procedure CleanArrayRuViewer; // ������� ��������� ������� ����������� �������� Ruviewer
    function FindPrefixSrv(ipSrv:string):string; // ����� �������� ��� ������� � ��������
    function ListPrefixSrv:string; // ������ � ������ ������� ��������� � ��������
    Function ReadFileToString(FileName:string):string; // ��������� ���� � ��������� ������ ��� �������� � �����
    Function WriteStringToFile(FileName,WriteStr:String):boolean; // ������ ������ � ��������� ����
    function ReadFileSettings:boolean;  // ������� �������� �� �����
    function ReadRegK(var res:String):boolean; // ������ �������� �� �������
    function WriteRegK(KeyAct:string):boolean; // ������  � ������
    function Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
  end;

type
  TRuViewerSrvService = class(TService)
    TimerStartServerRuViewer: TTimer;
    TimerStartServerClaster: TTimer;

    procedure Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Main_ServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);

    procedure SrvSocketConcoleClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketConcoleClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketConcoleClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure SrvSocketConcoleClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketConcoleClientWrite(Sender: TObject; Socket: TCustomWinSocket);

    procedure SrvSocketConcoleListen(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketConcoleGetSocket(Sender: TObject; Socket: NativeInt;
      var ClientSocket: TServerClientWinSocket);
    procedure SrvSocketConcoleAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketConcoleGetThread(Sender: TObject;
      ClientSocket: TServerClientWinSocket;
      var SocketThread: TServerClientThread);
    function AllDataTostream():TMemorystream;
    Function  AvailabilityIPInList(ip,handle:string;WBList:TstringList):boolean;
    Function  DeleteIPInList(ip,handle:string;WBList:TstringList):boolean;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStopAndSave;
    procedure StopServerRuViewerSocket; // ��������� ������� RuViewer
    procedure StopServerConsoleSocket; // ��������� ������� ������� ����������
    Procedure StopInConnectClaster;  // ��������� ������ �������� ���������� ��������
    Procedure StopOutConnectClaster;  // ��������� ������ ��������� ���������� ��������
    Procedure StartOutConnectClaster;  // ������ ������ ��������� ���������� ��������
    Procedure StartInConnectClaster;  // ������ ������ �������� ���������� ��������
    procedure StartServerConsoleSocket; // ������ ������� ������� �����������
    procedure StartServerRuViewerSocket; //������ ������� RuViewer
    procedure CleanArrayClaster; // ������� ��������� ������� ��� ����������� �������� � ��������
    procedure CleanArrayPrefix; // ������� ��������� ������� ��������� ��������
    procedure CleanArrayRuViewer; // ������� ��������� ������� ����������� �������� Ruviewer
    function  ReadListServerClaster(ListServer:TstringList; FileName:string):boolean; // ������ ���� �� ��������
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure RegisterErrorLog(nameFile:string;  NumError:integer;  MessageText: string);
    procedure TimerStartServerRuViewerTimer(Sender: TObject);
    procedure TimerStartServerClasterTimer(Sender: TObject); // ������ �����
   private
    SrvSocketConcole: TServerSocket;
    Main_ServerSocket: TServerSocket;

  public

   function GetServiceController: TServiceController; override;

  end;


var
  RuViewerSrvService: TRuViewerSrvService;
  PortServerViewer,PortServerClaster,MaxNumInConnect:integer; // Port for Socket;
  PrefixLifeTime:integer;
  BlackList,ConnectList:TstringList;
  PswdServerViewer:string;
  PswdServerClaster:String;

  LoginConsole:string; // ����� ��� ����������� � ������� �� ������� ����������
  PswdConsole:string[255]; // ������ ��� ����������� � ������� �� ������� ����������
  PortConsole:integer; // ���� ��� �����������������

  ArrayClientClaster: array of TserverClst;// ������ ������� ��� ������������ �������� � ��������
  ArrayPrefixSrv: array of TPrefixSrv; // ������ ������� ��� �������� ��������� �������� � ��������, �� �������� �������� �� � �������� ��� ���
  ArrayClientData: array of TClientMRSD; // ������ ������� ��� ������������ �������� RuViewer
  CurentIndexPrefix:integer; // ������� ������ ������� ���������
  CurrentSrvClaster:integer; //������ �������� ��������� ������������� ������� � �������
  ListServerClaster:TstringList; // ������ �������� ��� �������������
  ReciveListServerClaster:TstringList; // ������ �������� ��� ������������� ���������� �� ������ ��������
  BlackListServerClaster:TstringList; // ������ ������ �������� ��������
  AddIpBlackListClaster:boolean; // �������� ������ ������ ������� ����������� � ��������
  SendListServers:boolean; // ������� ������� ������� �������� �������������, ������ �� ������� ��������� ����������
  GetListServers:boolean; // �������� ����� ������� �������� �������������, ������ �� ������� ��������� ����������
  LiveTimeBlackList:integer;    // ����� ����� ������ � ������ ������
  TimeOutReconnect:integer; //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������(������)
  NumOccurentc:integer; // ���������� �������� ���������� ��� ��������� � ������ ������
  PrefixServer:String; // ������� �������
  SrvIpExternal:String; // ��� ������� ������� ���������
  AutoRunSrvClaster:boolean; // ����� ������� �������� ��� ������� ������
  AutoRunSrvRuViewer:Boolean; // ����� ������� RuViewer ��� ������� ������


  LocalUID:string; // ��������� ID �� ��� ��������� ������
  KeyAct:string; // ���� ���������
  CountConnect:integer;// ���-�� ���������
  DateL:TdateTime; // ���� ��������� ��������� � ����������
  ActualKey:boolean;  // ������� ��������� ��������

  MyStreamCipherId:string; //TCodec.StreamCipherId ��� ����������
  MyBlockCipherId:string; // TCodec.BlockCipherId ��� ����������
  MyChainModeId:string; // TCodec.ChainModeId ��� ����������
  EncodingCrypt:TEncoding; // ��������� ������ ��� ���������� � ����������
  CurrentClient:integer;  //������ �������� ������������� �������
  IndexSrvConnect:integer; //������ ����������� ������� ����������
  CurrentClientClaster:integer; ////������ �������� ���������� ����������� � ������� � ��������
  SendLogToConsole:Boolean;
  SingRunOutConnectClaster:boolean; // ������� ���������� ������ ��������� ���������� ��������
  SingRunInConnectionClaster:boolean; // ������� ���������� ������ �������� ���������� ��������
  SingRunRuViewerServer:boolean;     // ������� ����������� ������� RuViewer
  LevelLogError:integer; // ������� ����������� ������
  TimeWaitPackage:integer; //������������ ����� �������� ����� ������ �������
  const
  ProcessingSlack = 2; // Processing slack for Sleep Commands   ��������� ������� ��� ������ ���
  MaxTimeTimeout = 3000;  // ����� �������� �� �������� �������   PingEnd
  MAX_BUF_SIZE = $4095;


implementation
uses DataBase,RunInConnect,RunOutConnect,FunctionPrefixServer,UIDgen,SocketCrypt;
{$R *.dfm}
var
ClasterOutTHread:TThread_FindAndRunConnection;
ClasterInTHread:RunInConnect.TThread_RunInConnect;

//------------------ ����� ��� ���������� �������� �� �������
constructor ThReadConsoleManager.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  AdmSocket := aSocket;
  FreeOnTerminate := true;
end;

// �������� ����� ��� ��������� �������� ����������� RuViewer. ������� ������ M, D, K, F.
constructor TThreadConnection_One.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  defineSocket := aSocket;
  IDTemp:='Unknown';
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Main.Create(aSocket: TCustomWinSocket; NmPC:string; aIDConnect:integer; aUID:string;aPswd:String;aID:string);
begin
  inherited Create(False);
  try
  IDConnect:=aIDConnect;
  ArrayClientData[IDConnect].ConnectBusy:=true;
  ArrayClientData[IDConnect].MainSocket:=aSocket;
  ArrayClientData[IDConnect].mainSocketHandle:=inttostr(aSocket.Handle);
  ArrayClientData[IDConnect].ServerAddress:=aSocket.LocalAddress; // ��������� ����� ������� ��� �������������
  ArrayClientData[IDConnect].ServerPort:=aSocket.LocalPort;     // ��������� ���� ������� ��� �������������
  ArrayClientData[IDConnect].PingStart := 0;
  ArrayClientData[IDConnect].PingEnd:= 64;
  ArrayClientData[IDConnect].PingAnswer:=false;
  ArrayClientData[IDConnect].PCUID:=aUID;   // ���������� ������������� ��
  ArrayClientData[IDConnect].Password:=aPswd; // ������ ���� ���������� ���� ���������������
  ArrayClientData[IDConnect].ID:=aID;         // ID  ��� ��������, ���� ������� ���� ������������
  ID:=aID; // ID ��� �����������
  ArrayClientData[IDConnect].NamePC:=NmPC;     // ��� ��, ��� ����� ���
  FreeOnTerminate := true;
 except  On E: Exception do
  //Write_Log(ArrayClientData[IDConnect].ClientAddress,'������ �������� M ������ '+ E.ClassName+' / '+ E.Message);
 end;
end;

constructor TThreadConnection_Desktop.Create(aSocket: TCustomWinSocket; ID: string; aIDConnect:integer);
begin
  inherited Create(False);
  try
  MyID := ID;
  IDConnect:=aIDConnect; // ������ ������� ����������� �������� �� ����� ������� ������� ����������� TThreadConnection_Main
  ArrayClientData[IDConnect].DesktopSocket:=aSocket;
  FreeOnTerminate := true;
  except  On E: Exception do
  //Write_Log(ArrayClientData[IDConnect].ClientAddress,'������ �������� D ������ '+ E.ClassName+' / '+ E.Message);
  end;
end;



constructor TThreadConnection_Files.Create(aSocket: TCustomWinSocket; ID: string; aIDConnect:integer);
begin
  inherited Create(False);
  try
  MyID := ID;
  IDConnect:=aIDConnect;
  ArrayClientData[IDConnect].FilesSocket:=aSocket;
  FreeOnTerminate := true;
  except  On E: Exception do
 // Write_Log(ArrayClientData[IDConnect].ClientAddress,'������ �������� F ������ '+ E.ClassName+' / '+ E.Message);
  end;
end;

constructor ThreadPingClient.Create(aIDConnect:integer);
begin
  inherited Create(False);
  IDConnect:=aIDConnect;
  FreeOnTerminate := true;
end;






// Get current Version       �������� ������� ������ ���������
function GetAppVersionStr: string;
type
  TBytes = array of Byte;
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Exe := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);

  if Size = 0 then
    RaiseLastOSError;

  SetLength(Buffer, Size);

  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;

  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;

  Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
    LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
    LongRec(FixedPtr.dwFileVersionLS).Hi, // release
    LongRec(FixedPtr.dwFileVersionLS).Lo]) // build
end;




//------------------------------------------------------------------------------------------------------

procedure TRuViewerSrvService.RegisterErrorLog(nameFile:string; NumError:integer; MessageText: string); // ������ �����
var f:TStringList;
i:integer;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
try
if NumError<=LevelLogError then // ���� ������� ������ ���� ��� �������� � ����������
 Begin
  try
  if not DirectoryExists(ExtractFilePath(Application.ExeName)+'log') then CreateDir(ExtractFilePath(Application.ExeName)+'log');
      f:=TStringList.Create;
      try
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+MessageText);
          while f.Count>3000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');

      finally
        f.Destroy;
      end;

  except
    exit;
  end;
 end;
except
    On E: Exception do
    begin
    exit;
    end;
  end;
end;



procedure TRuViewerSrvService.Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
NextClient:integer;
begin
 TThreadConnection_One.Create(Socket);
 RegisterErrorLog('RuViewerClientConnect',0,'������������ ������� - ' +Socket.RemoteAddress);
end;

procedure TRuViewerSrvService.Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent:
TErrorEvent; var ErrorCode: Integer);   // ������ � ��� ������
begin
 RegisterErrorLog('RuViewerClientConnect',0,'������ ����������� ' + Socket.RemoteAddress+' : '+SysErrorMessage(ErrorCode));
 ErrorCode := 0;
end;

procedure TRuViewerSrvService.Main_ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
 try
 RegisterErrorLog('RuViewerClientConnect',0,'���������� ������� '+ Socket.RemoteAddress+' �� �������');
 except On E: Exception do
  begin
  RegisterErrorLog('RuViewerClientConnect',2,'���������� ������� '+E.ClassName+' / '+ E.Message);
  end;
end;
 end;

//----------------------------------------------------------------------------------------------------
{TThreadConnection_Define}
function TThreadConnection_One.FindConnectID(ID: string; var OutIndex:integer):boolean; // �������� ����������� ������ �������� ������� ����������  � ��������� ID
var
  i: Integer;
  exist:boolean;
begin
try
 exist:=false;
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if ArrayClientData[i].ID = ID then
    begin
     OutIndex:=i;
     exist:=true;
     break;
    end;
  end;
  Result :=exist;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One FindConnectID ');
  result:=false;
  end;
end;
end;
//--------------------------------------------------------------------------------------------
function TThreadConnection_One.GenerateID(): string; // ��������� ID
var
  i: Integer;
  ID: string;
  Exists: Boolean;
begin
try
  Exists := False;
  while true do
  begin
    Randomize;  //
    ID := PrefixServer + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
     for I := 0 to length(ArrayClientData)-1 do
    begin
      if ArrayClientData[i].ID = ID then
      begin
        Exists := true;//ID ����������
        break;
      end
      else
        Exists := False;
    end;
   if not(Exists) then // ����� �� ����� ���� ID ����������
      break;
  end;
  Result := ID;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One GenerateID');
  end;
end;
end;

function GeneratePassword(): string;
begin
  Randomize;
  Result := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
end;

//--------------------------------------------------------------------------
function TThreadConnection_One.CorrectID( ID:string):boolean;  // ������� �������� ������������ ID
var           //286-215-706
i,z:integer;
strTmp:string;
correct:boolean;
begin
try
correct:=true;
strTmp:=StringReplace(ID, ' ', '',[rfReplaceAll, rfIgnoreCase]);
if length(strTmp)<>11 then
  begin
  correct:=false;
  end
else
  for I := 1 to length(strTmp) do
  Begin
  if (i=4)or(i=8)then
    begin
    if strTmp[i]<>'-' then
     begin
      correct:=false;
      break;
     end;
    end
    else
   begin
   if not trystrtoint(strTmp[i],z) then
     begin
     correct:=false;
     break;
     end;
   end;
  End;
result:=correct;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One CorrectID ');
  result:=false;
  end;
end;
end;

//------------------------������ ������ ������������� ������� ������ ������ � ������� �����������
function TThreadConnection_One.AddRecordClient(var NextClient:integer):boolean;  //������ ������ ������������� ������� ������ ������ � ������� �����������
var
i:integer;
exist:boolean;
begin
try
exist:=false;
begin
 for I := 0 to Length(ArrayClientData)-1 do
  begin
    if (not ArrayClientData[i].ConnectBusy) and (ArrayClientData[i].ItemBusy<>1) then
     begin
      exist:=true;
      ArrayClientData[i].ItemBusy:=1; //������� ��������� �������� �������, ������ ��� ������ �������, ����� ������ ������ �� ������ ������ ID ���� �� ����������� ���������� � ��������
      CurrentClient:=i;
      NextClient:=CurrentClient;
      break;
     end;
  end;
end;
if not exist then //���� ��������� ��� �� ����������� ������ �������
begin
  if Length(ArrayClientData)>(CountConnect+(CountConnect div 10)) then // ���� ������ ������� ����������� ������ �����������
  begin
  exist:=false;
  end
  else
  begin
  SetLength(ArrayClientData,Length(ArrayClientData)+1);
  CurrentClient:=Length(ArrayClientData)-1;
  ArrayClientData[CurrentClient].ItemBusy:=1; //������� ��������� �������� �������, ������ ��� ������ �������, ����� ������ ������ �� ������ ������ ID ���� �� ����������� ���������� � ��������
  NextClient:=CurrentClient;
  exist:=true
  end;
end;
result:= exist;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One AddRecordClient '{+ E.ClassName+' / '+ E.Message});
  result:=false;
  end;
end;
end;
//-------------------------------------------------------------------------------------
function TThreadConnection_One.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;
//--------------------------------------------------------------------
function TThreadConnection_One.NewCheckIDExists(ID: string): Boolean;  // ���������� �� ������ ID � �������� �� ��� ���������� ��������
var
  i: Integer;
  Exists: Boolean;
begin
try
  Exists := False;
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if (ArrayClientData[i].ID = ID) and (ArrayClientData[i].ConnectBusy) then
    begin
      Exists := true;
      break;
    end;
  end;
  Result := Exists;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One NewCheckIDExists '{+ E.ClassName+' / '+ E.Message});
  result:=false;
  end;
end;
end;


//-----------------------------------------------------------
function TThreadConnection_One.CorrectPrefixID(ID:string):boolean; // �������� ID �� ��� �������
begin  //PrefixServer   122-402-808    IDTemp
try
if copy(ID,1,6)=PrefixServer  then result:=true
 else result:=false;
except On E: Exception do
  begin
  Write_Log('RuViewerClientConnect',2,IDTemp+' One CorrectPrefixID '+ E.ClassName+' / '+ E.Message);
  result:=false;
  end;
end;
end;

function TThreadConnection_One.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:= false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.DecryptString(OutStr, inStr, EncodingCrypt);
    Result := true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;

except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

function TThreadConnection_One.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

//------------------------------------------------

function TThreadConnection_One.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
var
posStart,posEnd:integer;
bufTmp,BufS:string;
CryptTmp,DecryptTmp:string;
step:integer;
begin
  try
  bufTmp:='';
  BufS:=s;
  step:=0;
   while BufS<>'' do // � ����� ������
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// ������ ������������� �������
      posEnd:=pos('<!!>',BufS); // ����� ������������� �������
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// �������� ����������� ������ ������� � ������� posStart+3 ����� posEnd-4 ��������
      step:=4;
      Decryptstrs(CryptTmp,PswdServerViewer,DecryptTmp); //���������� ������������� ������
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// ����������� �������������� ������
      step:=6;
      if (posStart=0)or (posEnd=0)  then
        begin
        step:=7;
        BufS:='';
        break;
        end
        else
        begin
        step:=8;
        delete(BufS,posStart,posEnd+3);
        end;
        step:=9;
     end;
     step:=10;
   result:=bufTmp;
  except On E: Exception do
    begin
    Write_Log('RuViewerClientConnect',2,'('+inttostr(step)+') ���������� ������ ');
     s:='';
    end;
  end;
end;

// ����� ������������ ������� �������� �� �������� �������(�����������)
procedure TThreadConnection_One.Execute;
var
  Buffer,DecryptBuf,CryptBufTemp: string;
  CryptBuf:string;
  BufferTemp: string;
  ID: string; //��� ��������������� ������� RuViewer
  position: Integer;
  PCName:String;//��� ��������������� ������� RuViewer
  PCUID:String; //��� ��������������� ������� RuViewer
  ManualPswd :string; //��� ��������������� ������� RuViewer
  ThreadMain: TThreadConnection_Main;
  ThreadDesktop: TThreadConnection_Desktop;
  ThreadFiles: TThreadConnection_Files;
  NextClient:integer;
  RecivePswd:string;
  TimeOutTemp:integer;

function SendNoCryptText(s:string):boolean; // �������� �� �������������� ������
begin
defineSocket.SendText(s); //----------------------->
end;

function SendCryptText(s:string):boolean; // �������� �������������� ������
begin
if Encryptstrs(s,PswdServerViewer, CryptBuf) then //������� ����� ���������
 begin
 while defineSocket.SendText('<!>'+CryptBuf+'<!!>')<0 do
 sleep(ProcessingSlack); //----------------------->
 result:=true;
 end
 else result:=false;
end;

begin
  inherited;
  try
  TimeOutTemp:=0;
  RecivePswd:='';
  WHILE true DO
    BEGIN
      Sleep(ProcessingSlack);
      TimeOutTemp:=TimeOutTemp+ProcessingSlack;
     if TimeOutTemp>1050 then // �������� 10 ���
      begin
      Write_Log('RuViewerClientConnect',1,'�������� ����������� ������� RuViewer '+ defineSocket.RemoteAddress+' ������������ ��-�� ������������');
      defineSocket.Close; // ��������� ���������� � �������� ��� �������� ����� 10 ���
      exit;
      end;
      if (defineSocket = nil) or not(defineSocket.Connected) then break;
      if defineSocket.ReceiveLength < 1 then Continue;
     //PswdServerViewer -- ��� ���������� ������������ ������ ������� ��� ���������� � �����������
      DecryptBuf := defineSocket.ReceiveText;  // ���������� ���������� ������

      while not DecryptBuf.Contains('<!!>') do // �������� ����� ������
       begin
        TimeOutTemp:=TimeOutTemp+ProcessingSlack;
        if TimeOutTemp>300 then
         begin
         TimeOutTemp:=0;
         break;
         end;
       Sleep(2);
       if not defineSocket.Connected then break;
       if defineSocket.ReceiveLength < 1 then Continue;
       CryptBufTemp := defineSocket.ReceiveText;
       DecryptBuf:=DecryptBuf+CryptBufTemp;
       end;
       Buffer:=DecryptReciveText(DecryptBuf);
       RecivePswd:='';
   //-------------------------------------------------
      position := Pos('<|SRVPSWD|>', Buffer);
      if position > 0 then // ���� ���� ������
       begin
        BufferTemp:=Buffer;
        if Pos('<|MID|>', BufferTemp)>0 then // ���� ���� ID
          begin
            Delete(BufferTemp, 1, Pos('<|MID|>', BufferTemp)+ 6);
            RecivePswd:= copy(BufferTemp,1,Pos('<|SRVPSWD|>', BufferTemp)-1);
            BufferTemp:='';
          end;
         if Pos('<|END|>', BufferTemp)>0 then  // ���� ����� ������ ���������
          begin
            Delete(BufferTemp, 1, Pos('<|END|>', BufferTemp)+ 6);
            RecivePswd:= copy(BufferTemp,1,Pos('<|SRVPSWD|>', BufferTemp)-1);
            BufferTemp:='';
          end;
        position:=0;
       // Write_Log('RuViewerClientConnect','�������� ����������� ������� RuViewer '+ defineSocket.RemoteAddress+' ������ ������ -'+RecivePswd+' ������ �������-'+PswdServerViewer);
       end;
   //---------------------------------------------------------
      if RecivePswd<>PswdServerViewer then
       begin
       Write_Log('RuViewerClientConnect',1,'�������� ����������� ������� RuViewer '+ defineSocket.RemoteAddress+' ������������, ������ �� ������ ������');
       SendCryptText('<|NOCORRECTPSWD|>');//----------------------->
       defineSocket.Close; // ��������� ���������� � ��������
       exit;
       end
      else // ����� ���������� ������ ������
      BEGIN
        SendCryptText('<|ACCESSALLOWED|>'); //----------------------->
        position := Pos('<|MAINSOCKET|>', Buffer); // ��������� ������ ������ . Storing the position in an integer variable will prevent it from having to perform two searches, gaining more performance   ���������� ������� � ������������� ���������� ������� �� ������������� ��������� ��� ������, ��� �������� ������������������
         if position > 0 then
         begin  //'<|MAINSOCKET|>'+PCn+'<|NPC|>'+leftstr(PCUID,255)+'<|UID|>'+MyPassword+'<|MPSWD|>'+MyID+'<|MID|>'+TmpPswdServer+'<|SRVPSWD|>'
          PCName:='Unknown';
          ManualPswd:='';
          PCUID:='';
          ID:='';
          BufferTemp:=Buffer;
            try
            if Pos('<|NPC|>', BufferTemp)> 0 then  //��� ��
                begin
                Delete(BufferTemp, 1, position + 13); // ������� <|MAINSOCKET|>
                PCName:=copy(BufferTemp,1,Pos('<|NPC|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|NPC|>', BufferTemp)+ 6); // ������� <|NPC|>
                end;
            if Pos('<|UID|>', BufferTemp)> 0 then    // ���������� ������������� ��
                begin
                PCUID:=copy(BufferTemp,1,Pos('<|UID|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|UID|>', BufferTemp )+ 6); //������� <|UID|>
                end;
            if Pos('<|MPSWD|>', BufferTemp)> 0 then //Manual ������, ��������� ���������� ���������������� ������
                begin
                ManualPswd:=copy(BufferTemp,1,Pos('<|MPSWD|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|MPSWD|>', BufferTemp )+ 8); //������� <|MPSWD|>
                if ManualPswd='' then ManualPswd:=GeneratePassword; // ���� ������ ������ �� ���������� ���
                end;
            if Pos('<|MID|>', BufferTemp)> 0 then  // Manual ID, ��������� ���������� ���������������� ������
                begin
                ID:=copy(BufferTemp,1,Pos('<|MID|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|MID|>', BufferTemp )+ 6); //������� <|MID|>
                //Write_Log('RuViewerClientConnect',2,'�� �������� ID='+ID+' / Pswd='+ManualPswd);
                if not CorrectID(ID) then
                begin
                ID:=''; // ���� �������� ����������� ID �� ������� ���
               // Write_Log('RuViewerClientConnect',2,'NotCorrectID ID='+ID+' / Pswd='+ManualPswd);
                end;
                if ID<>'' then
                    begin
                    if not CorrectPrefixID(ID) then
                     begin
                     ID:=GenerateID; // ���� �� ��� ������� �� ���������� ����� ID
                    // Write_Log('RuViewerClientConnect',2,'�� ���������� ������� ID='+ID+' / Pswd='+ManualPswd);
                     end
                    else
                     begin
                      if NewCheckIDExists(ID) then // ��������� ���� �� ����� ID � ������ ����������,
                      begin
                       ID:=GenerateID;// ���� ���� �� ���������� �����
                      // Write_Log('RuViewerClientConnect',2,'ID ���������� ID='+ID+' / Pswd='+ManualPswd);
                      end;
                     end;
                    end
                   else ID:=GenerateID; // ���� �� �������� ID �� ���������� ���������
                end;
               IDTemp:=ID; //IDTemp ��� ������ �����
              // Write_Log('RuViewerClientConnect',2,'����� �������� ID='+ID+' / Pswd='+ManualPswd);
              if AddRecordClient(NextClient) then // �������� ID �������� �������
                begin
                ThreadMain := TThreadConnection_Main.Create(defineSocket,PCName,NextClient,PCUID,ManualPswd,ID) // ������� ����� ��� ��������� ���������� � ��������
                end
               else // ����� ���������� ��������� ��������� ����������
                begin
                SendCryptText('<|NOFREECONNECT|>');
                Write_Log('RuViewerClientConnect',1,IDTemp+' ����������� ��������� ����������� ��� �������� RuViewer');
                defineSocket.Close; // ��������� ���������� � ��������
                break;
                end;
            except On E: Exception do Write_Log('RuViewerClientConnect',2,IDTemp+' ERROR One Create socket (M) '{+ E.ClassName+' / '+ E.Message});  end;
          break; // Break the while
         end;
      //--------------------------------------------------------
        position := Pos('<|DESKTOPSOCKET|>', Buffer);
        if position > 0 then   //'<|DESKTOPSOCKET|>' + MyID + '<|END|>'+TmpPswdServer+'<|SRVPSWD|>'
         begin
          try
          ID:='';
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, position + 16);
          ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
          IDTemp:=ID; //IDTemp ��� ������ �����
          if FindConnectID(ID,NextClient) then
          ThreadDesktop := TThreadConnection_Desktop.Create(defineSocket, ID,NextClient)
          else
            begin
            SendCryptText('<|NOFINDCONNECT|>');
            Write_Log('RuViewerClientConnect',1,IDTemp+'����� (D) �� ������ ID ��� �����������');
            end;
          except On E: Exception do Write_Log('RuViewerClientConnect',2,IDTemp+' One Create socket (D) '{+ E.ClassName+' / '+ E.Message});  end;
          break; // Break the while
         end;
      //-------------------------------------------------------
        position := Pos('<|FILESSOCKET|>', Buffer);
        if Pos('<|FILESSOCKET|>', Buffer) > 0 then  //'<|FILESSOCKET|>' + MyID + '<|END|>'+TmpPswdServer+'<|SRVPSWD|>'
        begin
          try
          ID:='';
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, position + 14);
          ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
          IDTemp:=ID; //IDTemp ��� ������ �����
           if FindConnectID(ID,NextClient) then
          ThreadFiles := TThreadConnection_Files.Create(defineSocket, ID,NextClient)
           else
          begin
          SendCryptText('<|NOFINDCONNECT|>');
          Write_Log('RuViewerClientConnect',1,IDTemp+'����� (F) �� ������ ID ��� �����������');
          end;
          except On E: Exception do Write_Log('RuViewerClientConnect',2,IDTemp+' One Create socket (F) '{+ E.ClassName+' / '+ E.Message});  end;
          break; // Break the while
        end;
      //----------------------------------------------------------------
      END;// ����� �������� ������
      TimeOutTemp:=TimeOutTemp+ProcessingSlack;
     END;// ���� while do
except
    On E: Exception do
    begin
      Write_Log('RuViewerClientConnect',2,IDTemp+' Connection_One '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;
//-------------------------------------------------------------------------
//-------------PING FOR TThreadConnection_Main-------------------------------------------------------
function ThreadPingClient.Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
           f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;

function ThreadPingClient.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

function ThreadPingClient.SendMainSock(s:string):boolean; // ������� �������� ����� �������� �����
 begin
 if (ArrayClientData[IDConnect].mainSocket <> nil) and (ArrayClientData[IDConnect].mainSocket.Connected) then
   begin
     try
       begin
       ArrayClientData[IDConnect].mainSocket.SendText(s);
       result:=true;
       end;
       except On E: Exception do
        begin
        result:=false;
        Write_Log(TmpID,2,'����� P ������� ������� �������� MainS');
        end;
     end;
   end
      else result:=false;
 end;

procedure ThreadPingClient.Execute;
var
CryptBuf:string;
function SendMainCryptText(s:string):String; // �������� �������������� ������ � main �����
  begin
  if Encryptstrs(s,PswdServerViewer, CryptBuf) then //������� ����� ���������
  SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
  result:=CryptBuf;
  end;
begin
  try
  TmpID:=ArrayClientData[IDConnect].ID;
  while {(ArrayClientData[IDConnect].MainSocket.Connected) or} not terminated do
   BEGIN
     try
     sleep(MaxTimeTimeout);
      if (ArrayClientData[IDConnect].MainSocket= nil) or (not ArrayClientData[IDConnect].MainSocket.Connected) then
        begin
        ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
        break;
        end
       else
        begin
        ArrayClientData[IDConnect].PingStart := GetTickCount;
        if not ArrayClientData[IDConnect].PingAnswer then
          begin
          SendMainCryptText('<|SETPING|>' + IntToStr(ArrayClientData[IDConnect].PingEnd) + '<|END|>');
          ArrayClientData[IDConnect].PingAnswer:=true;
          end
          else
          begin
           SendMainCryptText('<|PING|>');
          end;
        end;
     except
     On E: Exception do
       begin
       ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
       Write_Log(TmpID,2,' (1) ����� �');
       break;
       end;
     end;
   END;
ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
//Write_Log(TmpID,ipAdrs+' PING ���������� ������');
except
 On E: Exception do
  begin
  ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
  Write_Log(TmpID,2,' (2) ����� �');
  end;
end;
 end;
//---------------------------------------------------------------------------------------------
 { TThreadConnection_Main }
//--------------------------------------------------------------------------------------------

function TThreadConnection_Main.NewFindListItemID(ID: string):TClientMRSD; // �������� TClientMRSD  � ��������� ID
var
  i: Integer;
begin
try
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if ArrayClientData[i].ID = ID then break;
  end;
  Result := ArrayClientData[i];
except
    On E: Exception do
    begin
      Write_Log(ID,2,' ����� � NewFindListItemID ');
    end;
  end;
end;

//---------------------------------------------------
function TThreadConnection_Main.FindConnectID(ID: string):integer; // �������� ����������� ������ �������� ������� ����������  � ��������� ID
var
  i: Integer;
begin
try
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if ArrayClientData[i].ID = ID then
      break;
  end;
  Result :=i;
except
    On E: Exception do
    begin
      Write_Log(ID,2,' ����� � FindConnectID '{ E.ClassName+' / '+ E.Message});
    end;
  end;
end;

//----------------------------------------------------------
function TThreadConnection_Main.NewCheckIDPassword(ID, Password: string): Boolean; //������������ ������ � ID � ������
var
  i: Integer;
  Correct: Boolean;
begin
try
  Correct := False;
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if (ArrayClientData[i].id = ID) and
    (ArrayClientData[i].Password = Password) and
    (ArrayClientData[i].ConnectBusy) then
    begin
      Correct := true;
      break;
    end;
  end;
  Result := Correct;
except
    On E: Exception do
    begin
     result:=false;
      Write_Log(ID,2,'����� � NewCheckIDPassword ');
    end;
  end;
end;
//-------------------------------------------------
function TThreadConnection_Main.CorrectID( ID:string):boolean;  // ������� �������� ������������ ID
var           //286-215-706
i,z:integer;
strTmp:string;
correct:boolean;
begin
try
correct:=true;
strTmp:=StringReplace(ID, ' ', '',[rfReplaceAll, rfIgnoreCase]);
if length(strTmp)<>11 then
  begin
  correct:=false;
  end
else
  for I := 1 to length(strTmp) do
  Begin
  if (i=4)or(i=8)then
    begin
    if strTmp[i]<>'-' then
     begin
      correct:=false;
      break;
     end;
    end
    else
   begin
   if not trystrtoint(strTmp[i],z) then
     begin
     correct:=false;
     break;
     end;
   end;
  End;
result:=correct;
except
    On E: Exception do
    begin
     result:=false;
      Write_Log(ID,2,'����� � CorrectID ');
    end;
  end;
end;
//--------------------------------------------------
function TThreadConnection_Main.FindIDinClaster(ID: string; var ServerIP:string; var ServerPort:integer; var SrvPswd:string):boolean; //����� �������� ���������� ID � ��������
var
  i: Integer;
  targetPrefix:string;
  exist:boolean;
begin
try
exist:=false;
 if CorrectID(ID) then // ���� ID ����������
  begin
  targetPrefix:=copy(ID,1,6);
  for I := 0 to length( ArrayPrefixSrv)-1 do
    begin
    if ArrayPrefixSrv[i].SrvPrefix=targetPrefix then
      begin
       exist:=true;
       ServerIP:=ArrayPrefixSrv[i].SrvIp;
       ServerPort:=ArrayPrefixSrv[i].SrvPort;
       SrvPswd:=ArrayPrefixSrv[i].SrvPswd;
       break;
      end;
    end;
  end;
result:=exist;
except
    On E: Exception do
    begin
      Write_Log(ID,2,'����� � FindIDinClaster');
    end;
  end;
end;
//--------------------------------------------------------------------------------------------
function TThreadConnection_Main.Write_Log(nameFile:string; NumError:integer;  TextMessage:string):boolean;
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
        while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;


//---------------------------------------------------------------
function TThreadConnection_Main.NewCheckIDExists(ID: string): Boolean;  // ���������� �� ������ ID � �������� �� ��� ���������� ��������
var
  i: Integer;
  Exists: Boolean;
begin
try
  Exists := False;
  for I := 0 to length(ArrayClientData)-1 do
  begin
    if (ArrayClientData[i].ID = ID) and (ArrayClientData[i].ConnectBusy) then
    begin
      Exists := true;
      break;
    end;
  end;
  Result := Exists;
except
    On E: Exception do
    begin
      Write_Log(ID,2,'����� � NewCheckIDExists');
    end;
  end;
end;

//-----------------------------------------------------
// ������ ��������� ��������� � �������� ������ TThreadConnection_Main
Procedure TThreadConnection_Main.AddConnect;
begin
try
  ArrayClientData[IDConnect].ConnectBusy:=true; // ������� ������� ������ � �������  ArrayClientData
  ArrayClientData[IDConnect].ItemBusy:=0; //
  ArrayClientData[IDConnect].dateTimeConnect:=now;
  ArrayClientData[IDConnect].TargetID:='';
  ArrayClientData[IDConnect].TargetPassword:='';
  ArrayClientData[IDConnect].targetMainSocket:=nil;
  ArrayClientData[IDConnect].targetDesktopSocket:=nil;
  ArrayClientData[IDConnect].targetFilesSocket:=nil;
  ArrayClientData[IDConnect].DesktopSocket:=nil;
  ArrayClientData[IDConnect].FilesSocket:=nil;
except
    On E: Exception do
    begin
      Write_Log(ID,2,'����� � AddConnect');
    end;
  end;

end;
//------------------------------------------------------------
function TThreadConnection_Main.CleanMyConnect(IndexID:integer):boolean;
begin
try
ArrayClientData[IndexID].ConnectBusy:=false;
 ArrayClientData[IndexID].ItemBusy:=0; //
 ArrayClientData[IndexID].TargetID:='';
 ArrayClientData[IndexID].TargetPassword:='';
 ArrayClientData[IndexID].ID:='';
 ArrayClientData[IndexID].PCUID:='';
 ArrayClientData[IndexID].Password:='';
 ArrayClientData[IndexID].PaswdAdmin:='';
 ArrayClientData[IndexID].NamePC:='';
 if ArrayClientData[IndexID].mainSocket<>nil then
 if ArrayClientData[IndexID].mainSocket.Connected then ArrayClientData[IndexID].mainSocket.Close;
 if ArrayClientData[IndexID].DesktopSocket<>nil then
 if ArrayClientData[IndexID].DesktopSocket.Connected then ArrayClientData[IndexID].DesktopSocket.Close;
 if ArrayClientData[IndexID].FilesSocket<>nil then
 if ArrayClientData[IndexID].FilesSocket.Connected then ArrayClientData[IndexID].FilesSocket.Close;
except
    On E: Exception do
    begin
      Write_Log(ID,2,'����� � CleanMyConnect ');
    end;
  end;
end;
//-------------------------------------------------------------
function TThreadConnection_Main.GenerateID: string; // ��������� ID
var
  i: Integer;
  ID: string;
  Exists: Boolean;
begin
try
  Exists := False;
  while true do
  begin
    Randomize;  //
    ID := PrefixServer + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
     for I := 0 to length(ArrayClientData)-1 do
    begin
      if ArrayClientData[i].ID = ID then
      begin
        Exists := true;//ID ����������
        break;
      end
      else
        Exists := False;
    end;
   if not(Exists) then // ����� �� ����� ���� ID ����������
      break;
  end;
  Result := ID;
except On E: Exception do
  begin
  Write_Log(ID,2,'����� � GenerateID ');
  end;
end;
end;
//-------------------------------------------------
function TThreadConnection_Main.CorrectPrefixID(ID:string):boolean; // �������� ID �� ��� �������
begin  //PrefixServer   122-402-808    IDTemp
try
if copy(ID,1,6)=PrefixServer  then result:=true
 else result:=false;
except On E: Exception do
  begin
  Write_Log(ID,2,'����� � CorrectPrefixID ');
  result:=false;
  end;
end;
end;
//--------------------------------------------------

function TThreadConnection_Main.CleanTargetConnect(IndexID:integer):boolean;
begin
try
 ArrayClientData[IndexID].TargetID:='';
  ArrayClientData[IndexID].targetMainSocket:=nil;
  ArrayClientData[IndexID].targetDesktopSocket:=nil;
  ArrayClientData[IndexID].targetFilesSocket:=nil;
except
    On E: Exception do
    begin
      Write_Log(ID,2,'����� � CleanTargetConnect ');
    end;
  end;
end;

function TThreadConnection_Main.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
  try
    Result:= false;
    FLibrary := TCryptographicLibrary.Create(nil);
    FCodec := TCodec.Create(nil);
    try
      FCodec.CryptoLibrary := FLibrary;
      FCodec.StreamCipherId := MyStreamCipherId;
      FCodec.BlockCipherId := MyBlockCipherId;
      FCodec.ChainModeId := MyChainModeId;
      FCodec.Password := pswd;
      FCodec.DecryptString(OutStr, inStr, EncodingCrypt);
      Result := true;
    finally
    FreeAndNil(FCodec);
    FreeAndNil(FLibrary);
    end;

  except on E : Exception do
    begin
    Write_Log(ID,2,'����� � ������ Decryptstrs');
    result:=false;
    OutStr:='';
    end;
  end;
end;

function TThreadConnection_Main.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  Write_Log(ID,2,'����� � ������ Encryptstrs');
  result:=false;
  OutStr:='';
  end;
end;
end;

function TThreadConnection_Main.SendMainSock(s:string):boolean; // ������� �������� ����� �������� �����
 begin
 if (ArrayClientData[IDConnect].mainSocket <> nil) and (ArrayClientData[IDConnect].mainSocket.Connected) then
   begin
     try
       begin
       while ArrayClientData[IDConnect].mainSocket.SendText(s) < 0 do Sleep(ProcessingSlack);
            result:=true;
       end;
       except On E: Exception do
        begin
        result:=false;
        Write_Log(ID,2,'����� � ������� ������� �������� MainS');
        end;
     end;
   end
      else result:=false;
 end;

 function TThreadConnection_Main.SendTargetSock(s:string):boolean; // ������� �������� ����� target �����
 begin
 if (ArrayClientData[IDConnect].targetMainSocket <> nil) and (ArrayClientData[IDConnect].targetMainSocket.Connected) then
   begin
     try
       begin
       while ArrayClientData[IDConnect].targetMainSocket.SendText(s) < 0 do Sleep(ProcessingSlack);
            result:=true;
       end;
       except On E: Exception do
        begin
        result:=false;
        Write_Log(ID,2,'����� � ������� ������� ��������  TargetS  ');
        end;
     end;
   end
      else result:=false;
 end;



//------------------------- �������� �����
procedure TThreadConnection_Main.Execute;
var
  Buffer,CryptBuf,DeCryptBuf,DeCryptRedirect: string;
  BufferTemp,DeCryptBufTemp: string;
  StrTmp:string;
  position: Integer;
  ConnectSRV:Integer; // ID �������� ������� � �������� ������������
  step:integer;
  TargetServerAddress:string;
  TargetServerPort:integer;
  TargetServerPSWD:string;
  pingTh:ThreadPingClient;


function SendMainCryptText(s:string):String; // �������� �������������� ������ � main �����
begin
try
if Encryptstrs(s,PswdCryptMain, CryptBuf) then  //������� ����� ���������
begin
SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=CryptBuf;
end
else  Write_Log(ID,1,'No Encryptstrs before main send');
  except On E: Exception do
    begin
    s:='';
    Write_Log(ID,2,'����� � ������ ���������� � �������� ������ ');
    end;
  end;
end;

function SendTargetCryptText(s:string):String; // �������� �������������� ������ � TargetMain �����
begin
try
if Encryptstrs(s,PswdCryptTarget, CryptBuf) then //������� ����� ���������
begin
SendTargetSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=CryptBuf;
end
 else Write_Log(ID,1,' No Encryptstrs before target send');
  except On E: Exception do
    begin
    s:='';
    Write_Log(ID,2,'����� � ������ ���������� � �������� ������');
    end;
  end;
end;

function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
var
posStart,posEnd:integer;
bufTmp,BufS:string;
CryptTmp,DecryptTmp:string;
step:integer;
begin
  try
  bufTmp:='';
  BufS:=s;
  step:=0;
   while BufS<>'' do // � ����� ������
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// ������ ������������� �������
      posEnd:=pos('<!!>',BufS); // ����� ������������� �������
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// �������� ����������� ������
      step:=4;
      Decryptstrs(CryptTmp,PswdCryptMain,DecryptTmp); //���������� ������������� ������
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// ����������� �������������� ������
      step:=6;
      if (posStart=0)or(posEnd=0) then
        begin
        step:=7;
        BufS:='';
        break;
        end
      else
      begin
      step:=8;
      delete(BufS,posStart,posEnd+3);
      end;
      step:=9;
     end;
   step:=10;
   result:=bufTmp;
  except On E: Exception do
    begin
    Write_Log(ID,2,'����� � ������ ���������� ������ ');
    //Write_Log(ID,'ERROR  - ('+inttostr(step)+') ����� � ������ ���������� ������ BufS='+BufS+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp );
    BufS:='';
    end;
  end;
end;

  BEGIN
    inherited;
    try
      AddConnect; // ��������� ������ �  ������ �����������
      step:=1;
      ConnectSRV:=-1; //������ �������� ��� ������ ����������� � ������ ���� �������
      TargetID:='';
      PswdCryptMain:=PswdServerViewer; // ����������� ������ ��� ���������� � ������
      PswdCryptTarget:=PswdServerViewer; // ����������� ������ ��� ���������� � ������
     //SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');// ���������� ������� ��� ID � Password
    step:=2;
     // Write_Log(ID,'������� ����� ������� ');

      while ArrayClientData[IDConnect].mainSocket.Connected do
        BEGIN
          try
        step:=3;
            Sleep(ProcessingSlack);
            if (ArrayClientData[IDConnect].mainSocket = nil) or (not(ArrayClientData[IDConnect].mainSocket.Connected)) then
              begin
              try
                if (ArrayClientData[IDConnect].targetMainSocket <> nil) and (ArrayClientData[IDConnect].targetMainSocket.Connected) then
                begin
                  SendTargetCryptText('<|DISCONNECTED|>');
                end;
              break; // ����� �� ����� �.� ��� ����� ������
                except On E: Exception do
                  begin
                  Write_Log(ID,2,' ����� � ('+inttostr(step)+') DISCONNECTED ');
                  end;
                end;
              end;
        step:=7;

            if ArrayClientData[IDConnect].mainSocket.ReceiveLength < 1 then Continue; // ������� � ������ �����  ���� ������ ���


            DeCryptBuf := ArrayClientData[IDConnect].mainSocket.ReceiveText;   //����������� ������ ��������� � ������� �����
            if DeCryptBuf.Contains('<!>') then
            begin
              while not DeCryptBuf.Contains('<!!>') do // �������� ����� ������
              begin
              if not ArrayClientData[IDConnect].mainSocket.Connected then break;
              Sleep(ProcessingSlack);
              if ArrayClientData[IDConnect].mainSocket.ReceiveLength < 1 then Continue;
              DeCryptBufTemp := ArrayClientData[IDConnect].mainSocket.ReceiveText;
              DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
              end;
            end;
            Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
          //------------------------------------------------------------------------------
             position := Pos('<|RUNPING|>', Buffer); //������ �������� ������ PING
             if position > 0 then
             begin
             pingTh:=ThreadPingClient.Create(IDConnect); // ������� ����� ��� �������� ����� � ��������
             end;
          //-----------------------------------------------------------------------------
            position := Pos('<|GETMYID|>', Buffer); //������ �������� ��� ID � ������
             if position > 0 then
              begin // ���������� ������� ��� ID
              SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');// ���������� ������� ��� ID � Password
              end;
          //-------------------------------------------------------------------
           position := Pos('<|SETMYID|>', Buffer); //������ �������� ����� ID <|SETMYID|>...<|ENDID|>
             if position > 0 then
              begin
               BufferTemp := Buffer;
               Delete(BufferTemp, 1, position + 10);
               StrTmp := Copy(BufferTemp, 1, Pos('<|ENDID|>', BufferTemp)-1);
               if StrTmp<>'' then
                 begin
                 if not CorrectPrefixID(StrTmp) then StrTmp:=GenerateID // ���� �� ��� ������� �� ���������� ����� ID
                 else
                 if NewCheckIDExists(StrTmp) then StrTmp:=GenerateID;// ��������� ���� �� ����� ID � ������ ����������, ���� ���� �� ���������� �����
                 end
               else StrTmp:=GenerateID; // ���� �� �������� ID �� ���������� ���������
               ArrayClientData[IDConnect].ID:=StrTmp;
               SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>'); // ���������� ������� ��� ID � Password
               BufferTemp:='';
              end;
          //------------------------------------------------------------------------
            position := Pos('<|SETMYPSWD|>', Buffer); //������ �������� ����� ������ <|SETMYPSWD|>...<|ENDPSWD|>
             if position > 0 then
              begin
               BufferTemp := Buffer;
                Delete(BufferTemp, 1, position + 12);
                StrTmp := Copy(BufferTemp, 1, Pos('<|ENDPSWD|>', BufferTemp)-1);
                ArrayClientData[IDConnect].Password:=StrTmp;
                SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');  // ���������� ������� ��� ID � Password
                BufferTemp:='';
              end;
          //----------------------------------------------------------------------------
        step:=8;
            position := Pos('<|FINDID|>', Buffer); //������� ������ ID
            if position > 0 then
            if Pos('<|END|>', Buffer)>0then
            begin
             try
              BufferTemp := Buffer;
              TargetServerAddress:='';
              TargetServerPort:=0;
              TargetServerPSWD:='';
              Delete(BufferTemp, 1, position + 9);
              TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        step:=9;
                if CorrectPrefixID(TargetID) then // ���� � ID ��� �������
                 Begin
                 if (NewCheckIDExists(TargetID))  then  //���� ������ TargetID ���� � ���� ������
                   Begin
                     if (NewFindListItemID(TargetID).TargetID = '') then   //���� ������ TargetIDID �� ��������� ��� � ���� ���� ��� ��� ���� � ���� �� ���������.... �������� IP ������� ���� �� ���������
                      begin
                      SendMainCryptText('<|MYIDEXISTS!REQUESTPASSWORD|>'); // ���������� ID ����������,
                      end
                     else
                      begin
                      SendMainCryptText('<|ACCESSBUSY|>');  //���������� �� �����
                      end
                   End
                  else //����� ���� �� ����� ID, ���������� ��� ��� �����
                    begin
                      SendMainCryptText('<|IDNOTEXISTS|>'); //���������� ID �� ����������
                      TargetID:='';
                    end;
                 End
                else  // ����� ������� �� ����� �������, ���� � ��������
                 if ActualKey then //���� �������� �������� �� ���������� ������ �� �������� ������� � ��������
                  Begin
                  if FindIdinClaster(TargetID,TargetServerAddress,TargetServerPort,TargetServerPSWD) then    // ���� �� �������� ID � ��������
                    begin  // ���� ����� �� �������� ID ������� �������� �������
                     //Write_Log(ID,'MESSAGE - ����� �  FIND ID  '+ '<|SRVIDEXISTS!REQUESTPASSWORD|>'+TargetServerAddress+'<|TSA|>'+inttostr(TargetServerPort)+'<|TSP|>'+TargetServerPSWD+'<TSPSWD>');
                     SendMainCryptText('<|SRVIDEXISTS!REQUESTPASSWORD|>'+TargetServerAddress+'<|TSA|>'+inttostr(TargetServerPort)+'<|TSP|>'+TargetServerPSWD+'<TSPSWD>'); // ���������� ID ����������, � ��������� � ������ ������� ��������� ������
                     TargetID:='';
                     // ��� ������ ������ ����������� � ������� �������
                     end
                    else //����� ���� �� ����� � ��������, ���������� ��� ��� �����
                    begin
                      SendMainCryptText('<|IDNOTEXISTS|>'); //���������� ID �� ����������
                      TargetID:='';
                    end;
                  End
                  else //����� �������� �� �����������, ������� ��� ��� ������ ID
                  begin
                   SendMainCryptText('<|IDNOTEXISTS|>'); //���������� ID �� ����������
                   TargetID:='';
                  end;

             except On E: Exception do
                  begin
                  Write_Log(ID,2,'����� � ('+inttostr(step)+') ����� �������� ');
                  end;
                end;
            end;
         ////////////////////////////////////////////////////////////////////////////
        step:=10;
            if Buffer.Contains('<|PONG|>') then //�������� ����� �� ping
            begin
              ArrayClientData[IDConnect].PingEnd :=( GetTickCount - ArrayClientData[IDConnect].PingStart) div 2; //GetTickCount ��������� �p���, �p������� � ������� ������� �������.
              ArrayClientData[IDConnect].PingAnswer:=false;
              //Synchronize(InsertPing); // ������� timeout � listView
            end;
         ////////////////////////////////////////////////////////////////////////////
        step:=11;
            position := Pos('<|CHECKIDPASSWORD|>', Buffer); //�������� ������
            if position > 0 then
            begin
            try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, position + 18);
              position := Pos('<|>', BufferTemp);
              TargetID := Copy(BufferTemp, 1, position - 1);  // �������� ID ��� ����������� � ���������� ��
              Delete(BufferTemp, 1, position + 2);
              TargetPassword := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  // �������� I������ ��� ����������� � ���������� ��
              if (NewCheckIDPassword(TargetID, TargetPassword)) then  // ��������� ������������� �� ID � ������
              begin
                 ConnectSRV:=FindConnectID(TargetID); // ������� � ������ ���������� ��� ���� �����������
                   // ��������� �������� ������
                ArrayClientData[IDConnect].targetMainSocket := ArrayClientData[ConnectSRV].mainSocket;
                ArrayClientData[ConnectSRV].targetMainSocket := ArrayClientData[IDConnect].mainSocket;
                ArrayClientData[IDConnect].TargetID:=TargetID;
                ArrayClientData[IDConnect].TargetPassword:=TargetPassword;
                ArrayClientData[ConnectSRV].TargetID:=ID;
                SendMainCryptText('<|ACCESSGRANTEDMAIN|>');   //���������� ������ �������� �������� ������ �������
              end
              else
              begin
                SendMainCryptText('<|ACCESSDENIED|>');   //���������� ������ ��������
                ArrayClientData[IDConnect].TargetID:='';
                ArrayClientData[IDConnect].TargetPassword:='';
                TargetID:='';
                TargetPassword :='';
              end;
                except On E: Exception do
                  begin
                  //while ArrayClientData[IDConnect].mainSocket.SendText('<|ACCESSDENIED|>') < 0 do   //���������� ������ ��������
                  //Sleep(ProcessingSlack);
                  //ArrayClientData[IDConnect].TargetID:='';
                  //ArrayClientData[IDConnect].TargetPassword:='';
                 // TargetID:='';
                 // TargetPassword :='';
                  Write_Log(ID,2,'����� � ('+inttostr(step)+') ������������� ');
                  end;
                end;
            end;
         step:=12;
         //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if Buffer.Contains('<|BINDDSKTPSOCK|>') then  // ������ ������� � ������������� ������� ������ �������� �����
            begin
             try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, pos('<|BINDDSKTPSOCK|>',BufferTemp) + 16);
              position := Pos('<|>', BufferTemp);
              ID := Copy(BufferTemp, 1, position - 1); // ������� ID c �������� ������������
              Delete(BufferTemp, 1, position + 2);
              TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  //������� ID , ���� ������������
             if (ArrayClientData[IDConnect].TargetID=TargetID) and (ConnectSRV<>-1) then // ���� �� ����� ������� ������ ������ �� TargetID � TargetPassword �� ������, ������ � ���������� � �������
               begin
               // ��������� ���������� ������� �����  ConnectSRV �������� ��� ����������� ��������� ������
               // ConnectSRV:=FindConnectID(TargetID); // ������� � ������ ���������� ��� ���� �����������
               //-----------------------------------------------------------------------------------------
               // ��������� ������� ���� ���������� ��� ��������� ��������� �������� ������ �� ����� �������
                if ArrayClientData[IDConnect].targetDesktopSocket<>nil then ArrayClientData[IDConnect].targetDesktopSocket:=nil;
                if ArrayClientData[ConnectSRV].targetDesktopSocket<>nil then ArrayClientData[ConnectSRV].targetDesktopSocket:=nil;
               //------------------------------------------------------------------------------------------
                ArrayClientData[IDConnect].targetDesktopSocket := ArrayClientData[ConnectSRV].desktopSocket;
                ArrayClientData[ConnectSRV].targetDesktopSocket := ArrayClientData[IDConnect].desktopSocket;
                SendMainCryptText('<|VIEWACCESSINGDESKTOP|>'); // ���������� ������ ������� ���� � ���������� ������� �������� �����
                SendTargetCryptText('<|SRVACCESSINGDESKTOP|>'); // ���������� � ����� �������� ���� � ���������� ������� �������� �����
               end
                else
               begin
                 SendMainCryptText('<|ACCESSDENIEDDESKTOP|>');   //���������� ������ ��������
                 ArrayClientData[ConnectSRV].TargetID:='';
                 ArrayClientData[IDConnect].TargetID:='';
                 ArrayClientData[IDConnect].TargetPassword:='';
                 ArrayClientData[IDConnect].DesktopSocket.Close; // ��������� ���� ����� �������� �����
                 TargetID :='';
               end;
               except On E: Exception do
                  begin
                  // while ArrayClientData[IDConnect].mainSocket.SendText('<|ACCESSDENIEDDESKTOP|>') < 0 do   //���������� ������ ��������
                 // Sleep(ProcessingSlack);
                  Write_Log(ID,2,'����� � ('+inttostr(step)+') ���������� ������� (D)');
                  end;
                end;
            end;
            step:=13;
         ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         ///  ----------------------------------------------------------------------------
            if Buffer.Contains('<|BINDFILESSOCK|>') then  // ������ ������� � ������������� ������� ������ ��� ������
            begin
             try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, pos('<|BINDFILESSOCK|>',BufferTemp) + 16);
              position := Pos('<|>', BufferTemp);
              ID := Copy(BufferTemp, 1, position - 1); // ������� ID c �������� ������������
              Delete(BufferTemp, 1, position + 2);
              TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  //������� ID , ���� ������������
              if (ArrayClientData[IDConnect].TargetID=TargetID) and (ConnectSRV<>-1) then // ���� �� ����� ������� ������ ������ �� TargetID � TargetPassword �� ������, ������ � ���������� � �������
               begin
               // ��������� �������� ������  ConnectSRV �������� ��� ����������� ��������� ������
              // ConnectSRV:=FindConnectID(TargetID); // ������� � ������ ���������� ��� ���� �����������
                 ArrayClientData[IDConnect].targetFilesSocket := ArrayClientData[ConnectSRV].filesSocket;
                 ArrayClientData[ConnectSRV].targetFilesSocket := ArrayClientData[IDConnect].filesSocket;
                 SendMainCryptText('<|VIEWACCESSINGFILES|>');  // ���������� ���� � ���������� ������� ��� ������ ������ �������
                 SendTargetCryptText('<|SRVACCESSINGFILES|>');   // ���������� ���� � ���������� ������� ��� ������ � ��������
               end
                else
               begin
                 SendMainCryptText('<|ACCESSDENIEDFILES|>');   //���������� ������ ��������
                 ArrayClientData[ConnectSRV].TargetID:='';
                 ArrayClientData[IDConnect].TargetID:='';
                 ArrayClientData[IDConnect].TargetPassword:='';
                 ArrayClientData[IDConnect].FilesSocket.Close; // ��������� ���� �������� �����
                 TargetID :='';
               end;
             except On E: Exception do
                  begin
                  Write_Log(ID,2,'����� � ('+inttostr(step)+') ���������� ������� (F)');
                  end;
                end;
            end;
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Stop relations
        step:=14;
            if Buffer.Contains('<|STOPACCESS|>') then  // ���������/������ ����� ������������ ��� �������� ����� ����������
            begin
            try
              SendMainCryptText('<|DISCONNECTED|>');  // ������ �����������
              SendTargetCryptText('<|DISCONNECTED|>'); // ������� �����������
              ArrayClientData[IDConnect].targetMainSocket := nil;
              ArrayClientData[IDConnect].targetDesktopSocket:=nil;
              ArrayClientData[IDConnect].targetFilesSocket:=nil;
              ArrayClientData[IDConnect].TargetPassword:='';
               if ArrayClientData[IDConnect].TargetID<>'' then // ���� ���������� ���� ����������� �� TargetID �� ������, �������
                begin
                ArrayClientData[IDConnect].TargetID:='';
                ArrayClientData[ConnectSRV].TargetID:='';
                ArrayClientData[ConnectSRV].targetMainSocket := nil;
                ArrayClientData[ConnectSRV].targetDesktopSocket:=nil;
                ArrayClientData[ConnectSRV].targetFilesSocket:=nil;
                end;
              ConnectSRV:=-1; //������ �������� ��� ������ ����������� � ������ ���� �������
              TargetID :='';
            except On E: Exception do
                  begin
                  Write_Log(ID,2,'����� � ('+inttostr(step)+') STOP ACCESS');
                  end;
                end;
            end;
         /////////////////////////////////////////////////////////////////////////////////

        step:=15;
            position := Pos('<|REDIRECT|>', Buffer);
            if position > 0 then
            begin
        step:=16;
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, position + 11);
        //------------------------------------------------------------ �������� ����� ��������. � ����� ����� ��� ����� �� �������
        step:=17;
              if (Pos('<|FOLDERLIST|>', BufferTemp) > 0) then // ������ ���������  // ��������� ������ ������ ��������� ����� � ������� �� ������
              begin
        step:=18;
                 try
                  if ArrayClientData[IDConnect].mainSocket<>nil then
                  if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
                  while (ArrayClientData[IDConnect].mainSocket.Connected) do
                   Begin
                    if ArrayClientData[IDConnect].PingEnd>=MaxTimeTimeout then break;
        step:=19;
                    Sleep(ProcessingSlack); // Avoids using 100% CPU

                    DeCryptBuf:= ArrayClientData[IDConnect].mainSocket.ReceiveText;   //����������� ������ ��������� � ������� �����
                    DeCryptRedirect:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
                    BufferTemp := BufferTemp + DeCryptRedirect;  // ��������������� ������
                    if (Pos('<|ENDFOLDERLIST|>', BufferTemp) > 0) then  // ����� ������ ���������
                      break;
                   End;
                  except On E: Exception do
                    begin
                    Write_Log(ID,2,'����� � ('+inttostr(step)+') REDIRECT (1) ');
                    break;
                    end;
                  end;
              end;
        step:=21;
        //---------------------------------------------------------------------
              if (Pos('<|FILESLIST|>', BufferTemp) > 0) then   //������ ������
              begin
        step:=22;
                 try
                  if ArrayClientData[IDConnect].mainSocket<>nil then
                  if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
                  while (ArrayClientData[IDConnect].mainSocket.Connected) do
                   Begin
                   if ArrayClientData[IDConnect].PingEnd>=MaxTimeTimeout then break;
                    Sleep(ProcessingSlack); // Avoids using 100% CPU

                    DeCryptBuf:= ArrayClientData[IDConnect].mainSocket.ReceiveText;   //����������� ������ ��������� � ������� �����
                    DeCryptRedirect:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
                    BufferTemp := BufferTemp + DeCryptRedirect;  // ��������������� ������
                    if (Pos('<|ENDFILESLIST|>', BufferTemp) > 0) then   // ����� ������ ������
                      break;
                   End;
                  except On E: Exception do
                    begin
                    Write_Log(ID,2,'����� � ('+inttostr(step)+') REDIRECT (2)');
                    break;
                    end;
                  end;
              end;
        step:=25;

              try
              if (ArrayClientData[IDConnect].targetMainSocket <> nil)then
              if (ArrayClientData[IDConnect].targetMainSocket.Connected) then
              if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
              begin
        step:=26;
                SendTargetCryptText(BufferTemp); // �������� � target ����� �� ��� ������ ������� ��������
              end;
              except On E: Exception do
                begin
                Write_Log(ID,2,'����� � ('+inttostr(step)+') REDIRECT (3) ');
                break;
                end;
              end;
        //------------------------------------------------------------------------------------
            end; // end redirect

           except On E: Exception do
            begin
            Write_Log(ID,2,'����� � ('+inttostr(step)+') ������ ��������� ����� ');
            break;
            end;
           end;
        END; //while
       ////////////////////////////////////////////////////////////////////////////////////////
      step:=27; // ����� �� �����, ���������� �����������. ������� ���� ������� ���������� ���������� ���� ��� �������
        if (ArrayClientData[IDConnect].targetMainSocket <> nil) then
        if  (ArrayClientData[IDConnect].targetMainSocket.Connected) then
        if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
        begin
          SendTargetCryptText('<|DISCONNECTED|>');
        end;

      step:=28;
        if (ArrayClientData[IDConnect].mainSocket<>nil)then
        if (ArrayClientData[IDConnect].mainSocket.Connected)  then
        if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
        begin
         SendTargetCryptText('<|DISCONNECTED|>');
        end;
       //Write_Log(ID,'MESSAGE - ����� � ���������� ������');
       CleanMyConnect(IDConnect); // ������� �������� ������� ����� �����������
       if ConnectSRV <>-1 then  //����� �� ����� -1 ������ ���� ����������� � ������ ���� ������� � ��������� ������� �� ���������
        begin
        CleanTargetConnect(ConnectSRV); // ������� �������� ������� �������� �����������
        ConnectSRV:=-1;
        end;
       /////////////////////////////////////////////////////////////////////////////////
      step:=29;
      //Write_Log(ID,'������� ����� �������� ');
      pingTh.Terminate; // ������� ���������� ������ PING
       except
          On E: Exception do
          begin
          CleanMyConnect(IDConnect); // ������� �������� ������� ����� �����������
           if ConnectSRV <>-1 then  //����� �� ����� -1 ������ ���� ����������� � ������ ���� ������� � ��������� ������� �� ���������
            begin
            CleanTargetConnect(ConnectSRV);
            ConnectSRV:=-1;
            end;
          pingTh.Terminate; // ������� ���������� ������ PING
          Write_Log(ID,2,'����� � '+inttostr(step)+') ������ ��������� ������');
          end;
        end;
    END;






procedure TThreadConnection_Main.InsertPing;
var
  L: TListItem;
begin

end;

//----------------------------------------------------------------------------
//--------------------------------------------------------------------------------




{ TThreadConnection_Desktop }
// The connection type is the Desktop Screens
function TThreadConnection_Desktop.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;    //
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;

procedure TThreadConnection_Desktop.Execute;
var
  Buffer: string;
begin
  inherited;
  try
  while ArrayClientData[IDConnect].desktopSocket.Connected do
  begin
    Sleep(ProcessingSlack);

    if (ArrayClientData[IDConnect].desktopSocket = nil) or not(ArrayClientData[IDConnect].desktopSocket.Connected) then
      break;

    if ArrayClientData[IDConnect].desktopSocket.ReceiveLength < 1 then
      Continue;

    Buffer := ArrayClientData[IDConnect].desktopSocket.ReceiveText;

    if (ArrayClientData[IDConnect].targetDesktopSocket <> nil) and (ArrayClientData[IDConnect].targetDesktopSocket.Connected) then
    if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
    begin
      while ArrayClientData[IDConnect].targetDesktopSocket.SendText(Buffer) < 0 do
      begin
        if ArrayClientData[IDConnect].PingEnd>=MaxTimeTimeout then break;
        Sleep(ProcessingSlack);
      end;
    end;
    Buffer:='';// ������� ����������. ���� � ������� ���������� �����, �� ������ �������� ������,
                   //��� ����� ��������� � ������, ��� ��������������� ��� �������� �������, � �� ��� ��� �� �����.
  end;
  //Write_Log(ConnectData.ClientAddress+' Desktop','MESSAGE - '+ConnectData.ClientAddress+' ���������� ������ DESKTOP');
   if ArrayClientData[IDConnect].desktopSocket.Connected then ArrayClientData[IDConnect].desktopSocket.Close;
 except
    On E: Exception do
    begin
    Write_Log(MyID,2, 'ERROR - ����� D ');
    ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
    end;
  end;
end;




{ TThreadConnection_Files }
function TThreadConnection_Files.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  //
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;
// The connection type is to Share Files
procedure TThreadConnection_Files.Execute;
var
  Buffer: string;
  nSend : Int64;
  sBuf : Pointer;
  ReadBuf:int64;
  tmpReadBuf:int64;
  FullWriteBuf:int64;
  CurrentWriteBuf:int64;
  SizeBuf:int64;
  TemPstringlist:Tstringlist;
  i:integer;
  Sbuffer: Array [0..MAX_BUF_SIZE] of Char;
begin
  inherited;
 try
 TemPstringlist:=TstringList.Create;

  while ArrayClientData[IDConnect].filesSocket.Connected do
    begin
      //SizeBuf:=1024;
      //CurrentWriteBuf:=0;
      //FullWriteBuf:=0;
      Sleep(ProcessingSlack);

      if (ArrayClientData[IDConnect].filesSocket = nil) or not(ArrayClientData[IDConnect].filesSocket.Connected) then
        begin
          if WSAGetLastError() <> 0 then
          begin
          //TemPstringlist.Add(timetostr(now)+' Nil and Connected '+' WSAGetLastError='+inttostr(WSAGetLastError()));
          //if WSAGetLastError() = WSAEWOULDBLOCK then sleep(100);
          end;
        break;
        end;

      if ArrayClientData[IDConnect].filesSocket.ReceiveLength < 1 then
      begin
        if WSAGetLastError() <> 0 then
          begin
          //TemPstringlist.Add(timetostr(now)+' ReceiveLength WSAGetLastError='+inttostr(WSAGetLastError()));
          //if WSAGetLastError() = WSAEWOULDBLOCK then sleep(100);
          end;
        Continue;
      end;


     // if SizeBuf>ArrayClientData[IDConnect].filesSocket.ReceiveLength then SizeBuf:=ArrayClientData[IDConnect].filesSocket.ReceiveLength
    //  else SizeBuf:=1024;
    // ���������� ����� �����
    {try
      CurrentWriteBuf:=0;
      ReadBuf:=0;
      //SizeBuf:=ArrayClientData[IDConnect].filesSocket.ReceiveLength;
      //GetMem(sBuf, SizeBuf);
      ReadBuf:=ArrayClientData[IDConnect].filesSocket.ReceiveBuf(Sbuffer,SizeOf(Sbuffer));
      if ReadBuf>0 then
        begin
        if (ArrayClientData[IDConnect].targetFilesSocket <> nil) and (ArrayClientData[IDConnect].targetFilesSocket.Connected) then
          if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
            begin


                while CurrentWriteBuf<1 do
                begin
                  CurrentWriteBuf:=ArrayClientData[IDConnect].targetFilesSocket.SendBuf(Sbuffer,ReadBuf);
                  Sleep(ProcessingSlack);

                   while  (WSAGetLastError() = WSAEWOULDBLOCK) and (ArrayClientData[IDConnect].filesSocket.Connected) do
                    begin
                    Sleep(10);
                    TemPstringlist.Add(timetostr(now)+' - WSAGetLastError() = WSAEWOULDBLOCK')
                    end;

                  if CurrentWriteBuf<1 then
                  begin
                  TemPstringlist.Add(timetostr(now)+' WSAGetLastError()='+inttostr(WSAGetLastError())+' - ������ ������ SizeBuf='+inttostr(sizeOf(Sbuffer))+': ��������� �� ������ ReadBuf='+inttostr(ReadBuf)+' ��������� CurrentWriteBuf='+inttostr(CurrentWriteBuf)+' ');
                  sleep(10);
                  end;
                if not ArrayClientData[IDConnect].filesSocket.Connected then break;

                end;
            //TemPstringlist.Add(timetostr(now)+' - ������ ������ SizeBuf='+inttostr(SizeBuf)+': ��������� �� ������ ReadBuf='+inttostr(ReadBuf)+' ��������� CurrentWriteBuf='+inttostr(CurrentWriteBuf)+' ')
            end;

        end;
     // FreeMem(sBuf);
    except
      On E: Exception do
      begin
      Write_Log (ArrayClientData[IDConnect].ClientAddress,SysErrorMessage(WSAGetLastError));
      Write_Log(ArrayClientData[IDConnect].ClientAddress,'������ � F ������ '+ E.ClassName+' / '+ E.Message);
       for I := 0 to TemPstringlist.Count-1 do Write_Log(ArrayClientData[IDConnect].ClientAddress,TemPstringlist[i]);
      end;
    end;}
     // for I := 0 to TemPstringlist.Count-1 do
   // Write_Log(ArrayClientData[IDConnect].ClientAddress,TemPstringlist[i]);
   // TemPstringlist.Free;

      Buffer := ArrayClientData[IDConnect].filesSocket.ReceiveText;

      if (ArrayClientData[IDConnect].targetFilesSocket <> nil) and (ArrayClientData[IDConnect].targetFilesSocket.Connected) then
      if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
      begin
        while ArrayClientData[IDConnect].targetFilesSocket.SendText(Buffer) < 0 do
         begin
          if WSAGetLastError() <> 0 then
          begin
         // TemPstringlist.Add(timetostr(now)+' WSAGetLastError='+inttostr(WSAGetLastError()));
          if WSAGetLastError() = WSAEWOULDBLOCK then sleep(100);
          end;
          if ArrayClientData[IDConnect].PingEnd>=MaxTimeTimeout then break;
          Sleep(ProcessingSlack);
         end;
      end;

    end;
 //Write_Log(ConnectData.ClientAddress+' File','MESSAGE - '+ConnectData.ClientAddress+' ���������� ������ FILES');

 // for I := 0 to TemPstringlist.Count-1 do
 // Write_Log(ArrayClientData[IDConnect].ID,TemPstringlist[i]);
  TemPstringlist.Free;

 if ArrayClientData[IDConnect].filesSocket.Connected then ArrayClientData[IDConnect].filesSocket.Close;

 except
    On E: Exception do
    begin
    if not assigned(TemPstringlist) then
     begin
     //for I := 0 to TemPstringlist.Count-1 do
     //Write_Log(ArrayClientData[IDConnect].ID,TemPstringlist[i]);
     TemPstringlist.Free;
     end;
    Write_Log(MyID,2,' ����� F ');
    ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
    end;
  end;
 end;

 //////////////////////////////////////////////////////////////////////////////////////////////////////
 {ArrayClientClaster: array of TserverClst;// ������ ������� ��� ������������ �������� � ��������
  ArrayPrefixSrv: array of TPrefixSrv; // ������ ������� ��� �������� ��������� �������� � ��������, �� �������� �������� �� � �������� ��� ���
  ArrayClientData: array of TClientMRSD; // ������ ������� ��� ������������ �������� RuViewer
  }
procedure TRuViewerSrvService.CleanArrayClaster; // ������� ��������� ������� ��� ����������� �������� � ��������
var
i:integer;
begin
try
for I := 0 to Length(ArrayClientClaster)-1 do
begin
ArrayClientClaster[i].ServerAddress:='';
ArrayClientClaster[i].InOutput:=0;
ArrayClientClaster[i].SocketHandle:=0;
ArrayClientClaster[i].ServerPort:=0;
ArrayClientClaster[i].PrefixUpdate:=0;
ArrayClientClaster[i].ServerPassword:='';
ArrayClientClaster[i].CloseThread:=false;
end;
SetLength(ArrayClientClaster,0);
except on E : Exception do RegisterErrorLog('Service',2,'CleanArrayClaster ');end;
end;
//------------------------------------------------------------------
procedure TRuViewerSrvService.CleanArrayPrefix; // ������� ��������� ������� ��������� ��������
var
i:integer;
begin
try
for I := 0 to Length(ArrayPrefixSrv)-1 do
begin
 ArrayPrefixSrv[i].DateCreate:='';
 ArrayPrefixSrv[i].SrvPrefix:='';
 ArrayPrefixSrv[i].SrvPort:=0;
 ArrayPrefixSrv[i].SrvIp:='';
 ArrayPrefixSrv[i].SrvPswd:='';
end;
SetLength(ArrayPrefixSrv,0);
except on E : Exception do RegisterErrorLog('Service',2,'CleanArrayPrefix ');end;
end;
//-------------------------------------------------------------------------------------
procedure TRuViewerSrvService.CleanArrayRuViewer; // ������� ��������� ������� ����������� �������� Ruviewer
var
i:integer;
begin
try
for I := 0 to Length(ArrayClientData)-1 do
begin
 ArrayClientData[i].ConnectBusy:=false;
 ArrayClientData[i].ItemBusy:=0; //
 ArrayClientData[i].TargetID:='';
 ArrayClientData[i].TargetPassword:='';
 ArrayClientData[i].ID:='';
 ArrayClientData[i].PCUID:='';
 ArrayClientData[i].Password:='';
 ArrayClientData[i].PaswdAdmin:='';
 ArrayClientData[i].NamePC:='';
end;
SetLength(ArrayClientData,0);
except on E : Exception do RegisterErrorLog('Service',2,'CleanArrayRuViewer');end;
end;

 //////////////////////////////////////////////////////////////////////////////////////////////////////
Procedure TRuViewerSrvService.StopInConnectClaster;  // ��������� ������ �������� ���������� ��������
begin
try
ClasterInTHread.CloseServer;
ClasterInTHread.Terminate;
except on E : Exception do RegisterErrorLog('Service',2,'StopInConnectClaster ');end;
end;
//----------------------------------------------------------------
Procedure TRuViewerSrvService.StopOutConnectClaster;  // ��������� ������ ��������� ���������� ��������
var
i:integer;
begin
  try
    ClasterOutTHread.Terminate; // ���������� ������ ��������������� � ���������� ��������� �����������
     for I := 0 to length(ArrayClientClaster)-1 do
       begin
        ArrayClientClaster[i].CloseThread:=true; // ��������� �������� ���������� ������� ��������� ���������� � ��������
       end;
      try // ��������� � ���� ������ ��� �������������
      if ListServerClaster.Count>0 then // ���� ������ �������� �������� ������ �� � ��������� ������
      ListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'SrvClaster.dat');
      ListServerClaster.Free;
      ReciveListServerClaster.Free;// ������� ���������� ������ �������� ��������
      except on E : Exception do RegisterErrorLog('Service',2,'StopOutConnectClaster  Save SrvClaster.dat '); end;
  except on E : Exception do RegisterErrorLog('Service',2,'StopOutConnectClaster ');end;
end;
//------------------------------------------------------------------------------
Procedure TRuViewerSrvService.StartOutConnectClaster;  // ������ ������ ��������� ���������� ��������
begin
try
  CurrentSrvClaster:=0; // ������� ������ ������������� ������� ��������
  CurentIndexPrefix:=0; // ������� ������ ������� ��������� ��������
  ReciveListServerClaster:=Tstringlist.Create; //������ �������� � �������� ���������� �� ������ ��������
  ListServerClaster:=Tstringlist.Create; //������ �������� � �������� � ������� ������������
  if not ReadListServerClaster(ListServerClaster,'SrvClaster.dat') then   // ������ ���� � ��������� ��� �������������
    begin
     RegisterErrorLog('Service',1,'�� ������� ��������� ���� SrvClaster.dat');
    end
  else
    begin
    if ListServerClaster.Count>0 then // ���� ����� ��� ����������� �� ���� �� ��������� ����� ��� ����������� � �������� ��������
    ClasterOutTHread:=RunOutConnect.TThread_FindAndRunConnection.Create(ListServerClaster);  // ��������� �����������  ��������
    end;
except on E : Exception do RegisterErrorLog('Service',2,'StartOutConnectClaster ' );end;
end;
//-----------------------------------------------------------------------------
Procedure TRuViewerSrvService.StartInConnectClaster;  // ������ ������ �������� ���������� ��������
begin
try
  ClasterInTHread:=RunInConnect.TThread_RunInConnect.Create(ListServerClaster);       // �������� ����������� ��������
except on E : Exception do RegisterErrorLog('Service',2,'StartInConnectClaster ' );end;
end;
//--------------------------------------------------------------------------------------
 ////////////////////////////////////////////////////
procedure TRuViewerSrvService.StopServerRuViewerSocket;
begin
try
  if assigned(Main_ServerSocket) then
   begin
     Main_ServerSocket.Close;
     Main_ServerSocket.Free;
   end;
except on E : Exception do RegisterErrorLog('Service',2,'Stop Server RuViewer ' );end;
end;


procedure TRuViewerSrvService.TimerStartServerClasterTimer(Sender: TObject); // ������ ������� �������������
var
setIni:TMemIniFile;
begin
try
 if PrefixServer<>'' then
   begin // �������� �������� �� ������������
    if not CorrectPrefix(PrefixServer,SrvIpExternal,PrefixServer) then
    begin
    RegisterErrorLog('Service',1,'�� ������� ��������� ������������� ��-�� ������������� �������� �������');
    exit;
    end;
   end
   else  // ����� �� ������, �������� �����
   begin
   PrefixServer:=GeneratePrefixServr('',SrvIpExternal); // ��������� �������� �������
     setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
     try
     setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer ������� �������
     finally
     setIni.UpdateFile;
     setIni.Free;
     end;
   end;

  if SrvIpExternal<>'' then // ��������� � ������ ��������� ���� ������ ���� ������ ������� IP � ����������
  begin                     // ���� ������ ��� �� � ������ ��������� ��� ������ ����������� � ��������
  AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);
  end;
StartOutConnectClaster;
StartInConnectClaster;
TimerStartServerClaster.Enabled:=false;
except on E : Exception do RegisterErrorLog('Service',2,'Timer Start Server Claster ' );end;
end;

procedure TRuViewerSrvService.TimerStartServerRuViewerTimer(Sender: TObject);
begin
try
  CurrentClient:=0; // ������� ������ �������
  Main_ServerSocket := TServerSocket.Create(self);
  Main_ServerSocket.Active := False;
  Main_ServerSocket.ServerType := stNonBlocking;
  Main_ServerSocket.OnClientConnect := Main_ServerSocketClientConnect;
  Main_ServerSocket.OnClientError := Main_ServerSocketClientError;
  Main_ServerSocket.OnClientDisconnect:=Main_ServerSocketClientDisconnect;
  Main_ServerSocket.Port := PortServerViewer;
  Main_ServerSocket.Active := true;
  TimerStartServerRuViewer.Enabled:=false;
 except on E : Exception do RegisterErrorLog('Service',2,'Timer Start Server RuViewer');end;
end;

//-------------------------------------------------------
procedure TRuViewerSrvService.StopServerConsoleSocket;
begin
try
  if assigned(SrvSocketConcole) then
   begin
    SrvSocketConcole.Close;
    SrvSocketConcole.Free;
   end;
except on E : Exception do RegisterErrorLog('Service',2,'Stop Server Console');end;
end;
//--------------------------------------------------------

//------------------------------------------------------
procedure TRuViewerSrvService.StartServerConsoleSocket;
begin
try
  SrvSocketConcole:=TServerSocket.Create(self);
  SrvSocketConcole.Active:=false;
  SrvSocketConcole.ServerType := stNonBlocking;
  SrvSocketConcole.Port :=PortConsole;
  SrvSocketConcole.OnClientConnect:=SrvSocketConcoleClientConnect;
  SrvSocketConcole.OnClientError:=SrvSocketConcoleClientError;
  SrvSocketConcole.OnClientDisconnect:=SrvSocketConcoleClientDisconnect;
  SrvSocketConcole.Active:=true;
  SrvSocketConcole.Open;
 except on E : Exception do RegisterErrorLog('Service',2,'Start Server Console ' );end;
 end;
//-------------------------------------------------------
procedure TRuViewerSrvService.StartServerRuViewerSocket;
begin
try
  CurrentClient:=0; // ������� ������ �������
  Main_ServerSocket := TServerSocket.Create(self);
  Main_ServerSocket.Active := False;
  Main_ServerSocket.ServerType := stNonBlocking;
  Main_ServerSocket.OnClientConnect := Main_ServerSocketClientConnect;
  Main_ServerSocket.OnClientError := Main_ServerSocketClientError;
  Main_ServerSocket.OnClientDisconnect:=Main_ServerSocketClientDisconnect;
  Main_ServerSocket.Port := PortServerViewer;
  Main_ServerSocket.Active := true;
 except on E : Exception do RegisterErrorLog('Service',2,'Start Server RuViewer ');end;
 end;


//////////////////////////////////////////////////////////////////////
procedure TRuViewerSrvService.ServiceStopAndSave;
var
i:integer;
SetIni:TMeminifile;
begin
try

try // ��������� � ���� ������ ������� ������ BlackListServerClaster,'BlackList.dat'
if BlackListServerClaster.Count>0 then // ���� ������ ������ �� � ��������� ������
BlackListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'BlackList.dat');
BlackListServerClaster.Free;
except on E : Exception do RegisterErrorLog('Service',2,'Shutdown service Save BlackList.dat '); end;


setIni:=TMeminifile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
try
setIni.WriteInteger('Console','port',PortConsole);  // ���� ��� �����������������
setIni.WriteString('Console','pswd',PswdConsole);// ������ ��� ����������� �������
setIni.WriteString('Console','Login',LoginConsole); // ������������, ��� ����������� �������
setIni.WriteInteger('Viewer','port',PortServerViewer);// ���� ������� ��� ����������� ��������
setIni.WriteString('Viewer','pswd',PswdServerViewer); // ������
setIni.WriteString('Viewer','interface',SrvIpExternal); // ������� �� ��� �������� RuViewer//
setIni.WriteString('Viewer','prefix',PrefixServer);   // ������ �������
setIni.WriteInteger('claster','port',PortServerClaster);  // ���� ��� �������������
setIni.WriteString('claster','pswd',PswdServerClaster);   // ������ ��� �������������
setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // ������������ ���������� ����������� �������� ����������� � ��������
setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime);   // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //�������� ��� ��� ������ ������
setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); // ����� ����� ������ � ������ ������
setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // ���������� �������� ���������� �� ��������� � ������ ������
setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
setIni.WriteBool('claster','SendListServers',SendListServers); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
setIni.WriteBool('claster','GetListServers',GetListServers);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster);  // ����� ������� �������� ��� ������� ������
setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // ����� ������� RuViewer ��� ������� ������
setIni.UpdateFile;
finally
setIni.Free;
end;

StopServerConsoleSocket; // ��������� ������� ������� ����������
StopServerRuViewerSocket; // ��������� ������� RuViewer

except on E : Exception do RegisterErrorLog('Service',2,'Shutdown service Error ' );end;
end;


function TRuViewerSrvService.ReadListServerClaster(ListServer:TstringList; FileName:string):boolean; // ������ ���� �� ��������
var                                                 //172.16.1.2=3897<|1234|>
i:integer;
f:TFileStream;
Encoding:TEncoding;
begin
try
Encoding := TUTF8Encoding.Create;
if FileExists(ExtractFilePath(Application.ExeName)+ FileName) then
 begin
 ListServer.LoadFromFile(ExtractFilePath(Application.ExeName)+FileName,Encoding);
 //RegisterErrorLog('ClasterError',FileName+' '+ListServer.CommaText);
 result:=true;
 end
 else result:=false;

except on E : Exception do
   RegisterErrorLog('Service',2,'ReadListServerClaster');
end;
end;


procedure TRuViewerSrvService.ServiceShutdown(Sender: TService);
begin
ServiceStopAndSave;
end;

procedure TRuViewerSrvService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
ServiceStopAndSave;
end;

Procedure TRuViewerSrvService.ServiceStart(Sender: TService; var Started: Boolean);
var
i:byte;
SetIni:TMemIniFile;
ActualDate:boolean;
begin
try

  if not FileExists(ExtractFilePath(Application.ExeName)+ 'set.dat') then
   begin
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
      try
      setIni.WriteInteger('Log','level',0);
      setIni.WriteInteger('Console','port',3899);
      setIni.WriteString('Console','pswd','9999');
      setIni.WriteString('Console','Login','ConsoleAdmin');
      setIni.WriteInteger('Viewer','port',3898);
      setIni.WriteString('Viewer','pswd','8888');
      setIni.WriteString('Viewer','interface','');  // ������� ip ����� ��� ����������� �������� RuViewer
      setIni.WriteString('Viewer','prefix','');    // RuViewer ������� �������
      setIni.WriteInteger('claster','port',3897);
      setIni.WriteString('claster','pswd','7777');
      setIni.WriteInteger('claster','MaxNumInConnect',10); // ������������ ���-�� �������� ����������� ��� ������������
      setIni.WriteInteger('claster','PrefixLifeTime',10); // ������������ ����� ����� �������� ���� �� �� ���������� ����������� ��������
      setIni.WriteBool('claster','BlackList',false); //�������� ��� ��� ������ ������
      setIni.WriteInteger('claster','NumberOfLockRetries',3); // ���������� �������� ���������� �� ��������� � ������ ������
      setIni.WriteInteger('claster','BlackListLifeTime',10); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',5); //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      setIni.WriteBool('claster','SendListServers',true); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','GetListServers',true);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','StartSrv',true);  // ����� ������� �������� ��� ������� ������
      setIni.WriteBool('Viewer','StartSrv',true); // ����� ������� RuViewer ��� ������� ������
      setIni.WriteInteger('Other','TimeWaitPackage',600); // //������������ ����� �������� ����� ������ �����������

      TimeWaitPackage:=600; //������������ ����� �������� ����� ������ �����������
      LevelLogError:=0;
      PswdConsole:='9999';
      LoginConsole:='ConsoleAdmin';
      PortConsole := 3899; // ���� ��� �����������������
      PswdServerViewer:='8888';
      PswdServerClaster:='7777';
      PortServerViewer:=3898; // ���� ������� ��� ����������� ��������
      PortServerClaster:=3897; // ���� ��� �������������
      MaxNumInConnect:=10; // ������������ ���-�� �������� ����������� ��� ������������
      PrefixLifeTime:=10;  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
      NumOccurentc:=3;   // ���������� �������� ���������� �� ��������� � ������ ������
      PrefixServer:='';
      SrvIpExternal:='';
      AddIpBlackListClaster:=false; // ��������� ������ ������
      NumOccurentc:=3; // ���������� �������� ��� ���������� �� �������� � ������ ������  ������ ������
      LiveTimeBlackList:=10; // ��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      TimeOutReconnect:=5; //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      SendListServers:=true; // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      GetListServers:=true; // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      AutoRunSrvRuViewer:=true;
      AutoRunSrvClaster:=true;

      finally
      setIni.UpdateFile;
      setIni.Free;
      end;
   end
   else
   begin
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
      try
      LevelLogError:=setIni.ReadInteger('Log','level',0);
      PortConsole:=setIni.ReadInteger('Console','port',3899);  // ���� ��� �����������������
      PswdConsole:=setIni.ReadString('Console','pswd','9999');// ������ ��� ����������� �������
      LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // ������������, ��� ����������� �������
      PswdServerViewer:=setIni.ReadString('Viewer','pswd','8888');
      PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
      SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // ������� ip ����� ��� ����������� �������� RuViewer
      PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer ������� �������
      PortServerClaster:=setIni.ReadInteger('claster','port',3897);
      PswdServerClaster:=setIni.ReadString('claster','pswd','7777');
      MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // ������������ ���������� ����������� �������� ����������� � ��������
      PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
      AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // ���������/��������� ������ ������
      LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // ���������� �������� ���������� �� ��������� � ������ ������
      TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      SendListServers:=setIni.ReadBool('claster','SendListServers',true); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',true); // ����� ������� �������� ��� ������� ������
      AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',true); // ����� ������� RuViewer ��� ������� ������
      TimeWaitPackage:=setIni.ReadInteger('Other','TimeWaitPackage',600); //������������ ����� �������� ����� ������ �����������
      finally
      setIni.Free;
      end;
   end;

  if PrefixServer<>'' then
   begin // �������� �������� �� ������������
    if not CorrectPrefix(PrefixServer,SrvIpExternal,PrefixServer) then
    begin
    RegisterErrorLog('Service',1,'�� ������� ��������� ������ ��-�� ������������� �������� �������');
    exit;
    end;
   end
   else  // ����� �� ������, �������� �����
   begin
   PrefixServer:=GeneratePrefixServr('',SrvIpExternal); // ��������� �������� �������
     setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
     try
     setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer ������� �������
     finally
     setIni.UpdateFile;
     setIni.Free;
     end;
   end;


  if SrvIpExternal<>'' then // ��������� � ������ ��������� ���� ������ ���� ������ ������� IP � ����������
  begin                     // ���� ������ ��� �� � ������ ��������� ��� ������ ����������� � ��������
  AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);
  end;

  IndexSrvConnect:=0;  // ������ ����������� ������� ����������
  CurrentClient:=0; // ������� ������ �������
  CurrentSrvClaster:=0; // ������� ������ ������������� ������� ��������
  SendLogToConsole:=false; // �� ���������� ���� �� ������������ �������
  CurentIndexPrefix:=0; // ������� ������ ������� ��������� ��������

  SingRunOutConnectClaster:=false; // ������� ���������� ������ ��������� ���������� ��������
  SingRunInConnectionClaster:=false; // ������� ���������� ������ �������� ���������� ��������
  SingRunRuViewerServer:=false;     // ������� ����������� ������� RuViewer

  MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId ��� ����������
  MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId ��� ����������
  MyChainModeId:='native.ECB'; // TCodec.ChainModeId ��� ����������
  EncodingCrypt:=Tencoding.Create;
  EncodingCrypt:=Tencoding.UTF8; // ��������� ��� ����������
  //---------------------------------------------------------- // ������ RuViewer

   if AutoRunSrvRuViewer then StartServerRuViewerSocket; // ������ ������� RuViewer
//---------------------------------- socket ��� �������
   StartServerConsoleSocket; /// ������ ������� ������� ����������
//---------------------------------------
  LocalUID:=generateUID; // ��������� ���������� UID ��
  KeyAct:='';
  CountConnect:=10;
  DateL:=strtodate(DateLicDefault);
  if ReadRegK(KeyAct) then // ������ ���� ���������
   begin
    ActualKey:=ReadParemS(LocalUID,KeyAct,CountConnect,DateL,ActualDate);
   end
   else ActualKey:=false;



  BlackList:=Tstringlist.Create;
  ConnectList:=TstringList.Create;

  BlackListServerClaster:=Tstringlist.Create;
  if not ReadListServerClaster(BlackListServerClaster,'BlackList.dat') then   // ������ ���� ������ �������
    begin
     RegisterErrorLog('Service',1,'�� ������� ��������� ���� BlackList.dat');
    end;


   StartOutConnectClaster;  // ������ ������ ��������� ���������� ��������, ������� ����������, �.�. ��� ��������� ���������� ��� ������ �������� ��������
   if AutoRunSrvClaster then StartInConnectClaster;   // ������ ������ �������� ���������� ��������

    RegisterErrorLog('Service',1,'��������������� ������ : ���-�� ��������� :'+inttostr(CountConnect)+' ���� ��������� ���������� :'+datetimetostr(DateL));
  except on E : Exception do
   RegisterErrorLog('Service',2,'������ ������� ������ RuViewerSrvc: ' );
end;
 end;



procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RuViewerSrvService.Controller(CtrlCode);
end;

function TRuViewerSrvService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;
//---------------------------------------------------


//------------------------------ end ���������� �������� -----------------------------------------
//------------------------------------����� ����� ��� ����������������� ---------------------------------------
function TRuViewerSrvService.AllDataTostream():TMemorystream; // ��������� ������ ����������� � �����
var
i,z:integer;
strtmp:string;
lst:Tstringlist;
begin
try
lst:=Tstringlist.Create;
result:=TMemorystream.Create;
  try
  for I := 0  to  Length(ArrayClientData)-1  do
   if ArrayClientData[i].ConnectBusy then
     begin
     strtmp:='';
     strtmp:=ArrayClientData[i].NamePC+'<|>';
     strtmp:=strtmp+datetimetostr(ArrayClientData[i].dateTimeConnect)+'<|>';
     //strtmp:=strtmp+ArrayClientData[i].ClientAddress+'<|>';
     strtmp:=strtmp+ArrayClientData[i].ID+'<|>';
     strtmp:=strtmp+ArrayClientData[i].Password+'<|>';
     strtmp:=strtmp+ArrayClientData[i].TargetID+'<|>';
     strtmp:=strtmp+inttostr(ArrayClientData[i].PingEnd)+'<|>';
     lst.Add(strtmp);
     end;
  result.Position:=0;
  lst.SaveToStream(result);
  result.Position:=0;
  finally
  lst.Free;
  end;
except
on E : Exception do RegisterErrorLog('SRVConsole',2,'AllDataTostream Error ');
end;

end;

Function  TRuViewerSrvService.AvailabilityIPInList(ip,handle:string;WBList:TstringList):boolean; // ��������� ������ IP ������ � ������ �������
var
i:integer;
found:boolean;
begin
try
found:=false;
for I := 0 to WBList.Count-1 do
begin
if (WBList.names[i]=ip)and (WBList.ValueFromIndex[i]=handle) then
  begin
  found:=true;
  break;
  end;
end;
//if found then RegisterErrorLog('SRVConnect','AvailabilityIPInList Ip :'+Ip+ ' ������')
//else RegisterErrorLog('SRVConnect','AvailabilityIPInList Ip :'+Ip+ '�� ������');
except
on E : Exception do RegisterErrorLog('SRVConsole',2,'AvailabilityIPInList');
end;
result:=found;
end;
//////////////////////////////////////////////////////////////////////////////////////////////////
Function  TRuViewerSrvService.DeleteIPInList(ip,handle:string;WBList:TstringList):boolean; // ������� ip ������ �� ������ �������
var
i:integer;
found:boolean;
begin
try
found:=false;
for I := WBList.Count-1 downto 0  do
begin
if (WBList.names[i]=ip)and (WBList.ValueFromIndex[i]=handle) then
  begin
  WBList.Delete(i);
  found:=true;
  break;
  end;
end;
//if found then RegisterErrorLog('SRVConnect','WBList Ip :'+Ip+ ' ������ � ������ �� ������')
//else RegisterErrorLog('SRVConnect','WBList Ip :'+Ip+ '�� ������');
except
on E : Exception do RegisterErrorLog('SRVConsole',2,'DeleteIPInLis ');
end;
result:=found;
end;
///////////////////////////////////////////////////////////////////////////////////////






procedure TRuViewerSrvService.SrvSocketConcoleAccept(Sender: TObject; Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',1,'���������/����� � ����������� ������� :'+socket.RemoteAddress);
end;

procedure TRuViewerSrvService.SrvSocketConcoleClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
  var
  Buffer,BufferTmp,pswdIN,LoginIN:string;
  cryptText:string;
  TimeOutExit:integer;
  begin
  TimeOutExit:=0;
  while Socket.Connected do
  begin
    sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
    if TimeOutExit>1050 then // �������� 10 ���
      begin
      RegisterErrorLog('SRVConsole',0,'�������� ����������� ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������');
      Socket.Close; // ��������� ���������� � �������� ��� �������� ����� 10 ���
      exit;
      end;
    if socket.ReceiveLength<1 then continue;
    CryptText:=Socket.ReceiveText;
    Decryptstrs(CryptText,PswdConsole,Buffer);

    if Buffer.Contains('<|ADMSOCKET|>') then  //<|ADMSOCKET|>1234<|>LgnAdmin<|END|>
      begin                                                                     //  PswdAdm='1234';  LgnAdm='LgnAdmin';
        BufferTmp := Buffer;
        Delete(BufferTmp, 1, Pos('<|ADMSOCKET|>', BufferTmp) + 12);                //1234/LgnAdmin
        pswdIN := Copy(BufferTmp, 1, Pos('<|>', BufferTmp) - 1);
        Delete(BufferTmp, 1, Pos('<|>', BufferTmp) + 2);
        LoginIN := Copy(BufferTmp, 1, Pos('<|END|>', BufferTmp) - 1);
        Delete(BufferTmp, 1, Pos('<|END|>', BufferTmp) + 6);
        //RegisterErrorLog('SRVConnect','pswdIN : '+pswdIN+'/'+LoginIN);
        if (pswdIN=PswdConsole) and (LoginIN=LoginConsole) then
        begin
        ThReadConsoleManager.Create(socket);
        ConnectList.Add(Socket.RemoteAddress+'='+inttostr(Socket.Handle));
        RegisterErrorLog('SRVConsole',0,'���������� ������� ���������� IP :'+Socket.RemoteAddress);
        break;
        end
        else
        begin
         BlackList.Add(Socket.RemoteAddress+'='+inttostr(Socket.Handle));
         RegisterErrorLog('SRVConsole',0,'����������� ������� ����������� ������� ���������� IP :'+Socket.RemoteAddress+ ' ������ �� ������ ������ ��� ������������');
         Socket.Close;
         Break;
        end;
      end;
      TimeOutExit:=TimeOutExit+ProcessingSlack;
  end;
//RegisterErrorLog('SRVConnect','����������� ������� '+ Socket.RemoteAddress+' � ������� �����������������');
end;

procedure TRuViewerSrvService.SrvSocketConcoleClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',0,'���������� ������� '+ Socket.RemoteAddress+' �� ������� �����������������');
DeleteIPInList(Socket.RemoteAddress,inttostr(Socket.Handle),ConnectList);
end;

procedure TRuViewerSrvService.SrvSocketConcoleClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
RegisterErrorLog('SRVConsole',0,'������ ���������� "'+syserrormessage(ErrorCode)+'" � �������� '+ Socket.RemoteAddress);
ErrorCode:=0;
end;



procedure TRuViewerSrvService.SrvSocketConcoleClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
Buffer,BufferTmp,pswdIN,LoginIN:string;
i,z:integer;
 begin


 end;

procedure TRuViewerSrvService.SrvSocketConcoleClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',0,'�������� ������ ������� '+ Socket.RemoteAddress);
end;


procedure TRuViewerSrvService.SrvSocketConcoleGetSocket(Sender: TObject; Socket: NativeInt;
  var ClientSocket: TServerClientWinSocket);
begin
//� ����������� ����� ������� �� ������ ��������������� �������� ClientSocket;
RegisterErrorLog('SRVConsole',1,'SrvSocketGetSocket');
end;

procedure TRuViewerSrvService.SrvSocketConcoleGetThread(Sender: TObject;
  ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
begin
RegisterErrorLog('SRVConsole',1,'GetThread :'+ClientSocket.RemoteHost);
end;

procedure TRuViewerSrvService.SrvSocketConcoleListen(Sender: TObject; Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',1,'����� �������� ����������� ��������');
end;



function ThreadConsoleManager.Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
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
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;


function ThreadConsoleManager.SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
 begin
 if (AdmSocket <> nil) and (AdmSocket.Connected) then
   begin
     try
       begin
       while AdmSocket.SendText(s) < 0 do Sleep(ProcessingSlack);
       result:=true;
       end;
       except On E: Exception do
        begin
        result:=false;
        Write_Log('SRVConsole',2,'����� Manager ������� ������� ��������');
        end;
     end;
   end
      else result:=false;
 end;


function ThreadConsoleManager.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:= false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.DecryptString(OutStr, inStr, EncodingCrypt);
    Result := true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;

except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

function ThreadConsoleManager.Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;




function ThreadConsoleManager.ReadRegK(var res:String):boolean; // ������ �������� �� �������
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_READ); //KEY_READ ������ ������, ��� ������� ������������� ��� ���� ��������������
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewerServer',false) then
      begin
      res:=Reg.ReadString('Key');
      result:=true;
      end
     else result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Write_Log('SRVConsole',2,'������ ������ ������� ');
    result:=false;
  end;
end;
end;

function ThreadConsoleManager.WriteRegK(KeyAct:string):boolean; // ������  � ������
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewerServer',true) then // ���� ������� ������� ����
      begin
      if KeyAct<>'' then reg.WriteString('Key',KeyAct);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Write_Log('SRVConsole',2,'������ ������ � ������ ');
    result:=false;
  end;
end;
end;

procedure ThreadConsoleManager.CleanArrayClaster; // ������� ��������� ������� ��� ����������� �������� � ��������
var
i:integer;
begin
try
for I := 0 to Length(ArrayClientClaster)-1 do
begin
ArrayClientClaster[i].ServerAddress:='';
ArrayClientClaster[i].InOutput:=0;
ArrayClientClaster[i].SocketHandle:=0;
ArrayClientClaster[i].ServerPort:=0;
ArrayClientClaster[i].PrefixUpdate:=0;
ArrayClientClaster[i].ServerPassword:='';
ArrayClientClaster[i].CloseThread:=false;
end;
SetLength(ArrayClientClaster,0);
except on E : Exception do Write_Log('SRVConsole',2,'CleanArrayClaster ');end;
end;
//------------------------------------------------------------------
procedure ThreadConsoleManager.CleanArrayPrefix; // ������� ��������� ������� ��������� ��������
var
i:integer;
begin
try
for I := 0 to Length(ArrayPrefixSrv)-1 do
 begin
 ArrayPrefixSrv[i].DateCreate:='';
 ArrayPrefixSrv[i].SrvPrefix:='';
 ArrayPrefixSrv[i].SrvPort:=0;
 ArrayPrefixSrv[i].SrvIp:='';
 ArrayPrefixSrv[i].SrvPswd:='';
 end;
SetLength(ArrayPrefixSrv,0);
except on E : Exception do Write_Log('SRVConsole',2,'CleanArrayPrefix ');end;
end;
//-------------------------------------------------
procedure ThreadConsoleManager.CleanArrayRuViewer; // ������� ��������� ������� ����������� �������� Ruviewer
var
i:integer;
begin
try
for I := 0 to Length(ArrayClientData)-1 do
 begin
 ArrayClientData[i].ConnectBusy:=false;
 ArrayClientData[i].ItemBusy:=0; //
 ArrayClientData[i].TargetID:='';
 ArrayClientData[i].TargetPassword:='';
 ArrayClientData[i].ID:='';
 ArrayClientData[i].PCUID:='';
 ArrayClientData[i].Password:='';
 ArrayClientData[i].PaswdAdmin:='';
 ArrayClientData[i].NamePC:='';
 end;
SetLength(ArrayClientData,0);
except on E : Exception do Write_Log('SRVConsole',2,'CleanArrayRuViewer');end;
end;
//------------------------------------------------------------
function ThreadConsoleManager.StatusRuViewerServer:boolean; // ����������� ������� ������ ������� RuViewer
begin
  try
   if assigned(RuViewerSrvService.Main_ServerSocket) then
   begin
    result:=RuViewerSrvService.Main_ServerSocket.Active;
   end
   else result:=false;
  except on E : Exception do
    begin
     Write_Log('SRVConsole',2,'StatusRuViewerServer ');
    end;
   end;
end;
//---------------------------------------------------------------------


//-----------------------------------------------------------------------
Procedure ThreadConsoleManager.StopInConnectClaster;  // ��������� ������ �������� ���������� ��������
begin
try
ClasterInTHread.CloseServer;
ClasterInTHread.Terminate;
except on E : Exception do Write_Log('SRVConsole',2,'StopInConnectClaster ');end;
end;
//--------------------------------------------------------------
function ThreadConsoleManager.RebootServices:boolean;
var
SPar : String;
begin
try
SPar := '/K sc stop RuViewerSrvService & TIMEOUT /T 10 /NOBREAK & TASKKILL /F /IM RuViewerServerSrvc.exe & TIMEOUT /T 5 /NOBREAK & sc start RuViewerSrvService & exit'; // /K - ��� ������ �� cmd.exe ����� ���������� �������.
  ShellExecute(0, nil, 'cmd.exe', PChar(SPar), nil, SW_SHOW);
  result:=true;
except on E : Exception do
 begin
 result:=false;
 Write_Log('SRVConsole',2,'RebootService :'+E.ClassName+' / '+E.Message);end;
 end;
end;

{REM Stop Sevices
sc stop RuViewerSrvService

REM Wait
TIMEOUT /T 10 /NOBREAK

REM Find process
TASKLIST /FI "IMAGENAME eq RuViewerServerSrvc.exe"

REM Kil process
TASKKILL /F /IM RuViewerServerSrvc.exe

REM Wait
TIMEOUT /T 5 /NOBREAK

REM Run Services
sc start RuViewerSrvService}
//----------------------------------------------------------------
Function ThreadConsoleManager.StopOutConnectClaster:boolean;  // ��������� ������ ��������� ���������� ��������
var
i:integer;
timeOut:integer;
begin
  try
  result:=false;
  timeOut:=0;
  if ClasterOutTHread<>nil then ClasterOutTHread.Terminate; // ���������� ������ ��������������� � ���������� ��������� �����������
   for I := 0 to length(ArrayClientClaster)-1 do
     begin
      ArrayClientClaster[i].CloseThread:=true; // ��������� �������� ���������� ������� ��������� ���������� � ��������
      while ArrayClientClaster[i].InOutput=2 do //��� ��������� �����������
        begin
          sleep(10);
          timeOut:=timeOut+10;
          if timeOut>=500 then break;
        end;
     timeOut:=0;
     end;
   result:=true;
    try // ��������� � ���� ������ ��� �������������
      if ListServerClaster.Count>0 then // ���� ������ �������� �������� ������ �� � ��������� ������
      ListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'SrvClaster.dat');
      ListServerClaster.Free;
      ReciveListServerClaster.Free;// ������� ���������� ������ �������� ��������
    except on E : Exception do Write_Log('SRVConsole',2,'StopOutConnectClaster  Save SrvClaster.dat'); end;
  except on E : Exception do
   begin
   Write_Log('SRVConsole',2,'StopOutConnectClaster');
   result:=false;
   end;
  end;
end;


//---------------------------------------------------------
Function ThreadConsoleManager.StopConnectClaster(ConnectID:integer):boolean;  // ��������� ��������� ���������� � ��������
var
i:integer;
timeOut:integer;
exist:boolean;
begin
  try
    result:=false;
    exist:=false;
    timeOut:=0;
    for I := 0 to length(ArrayClientClaster)-1 do
     begin
       if ArrayClientClaster[i].SocketHandle=ConnectID then
        begin
         ArrayClientClaster[i].CloseThread:=true;  // ������� ������������� ���������� ������
          while ArrayClientClaster[i].InOutput<>0 do
          begin
            sleep(10);
            timeOut:=timeOut+10;
            if timeOut>=500 then break;
          end;
        exist:=true;
        end;
     if exist then break;
     timeOut:=0;
     end;
   result:=true;
  except on E : Exception do Write_Log('SRVConsole',2,'StopConnectClaster ');end;
end;
//--------------------------------------
procedure ThreadConsoleManager.StopServerRuViewerSocket; // ��������� ������� RuViewer
var
i:integer;
begin
try
  if assigned(RuViewerSrvService.Main_ServerSocket) then
   begin
    for I := 0 to RuViewerSrvService.Main_ServerSocket.Socket.ActiveConnections-1 do
     RuViewerSrvService.Main_ServerSocket.Socket.Connections[i].Close;
     RuViewerSrvService.Main_ServerSocket.Socket.Close;
     //RuViewerSrvService.Main_ServerSocket.Close;
     RuViewerSrvService.Main_ServerSocket.Free;
   end;
except on E : Exception do Write_Log('SRVConsole',2,'Stop Server RuViewer');end;
end;

{ArrayClientClaster: array of TserverClst;// ������ ������� ��� ������������ �������� � ��������
  ArrayPrefixSrv: array of TPrefixSrv; // ������ ������� ��� �������� ��������� �������� � ��������, �� �������� �������� �� � �������� ��� ���
  ArrayClientData: array of TClientMRSD; // ������ ������� ��� ������������ �������� RuViewer
  }
function ThreadConsoleManager.FindPrefixSrv(ipSrv:string):string;  // ����������� �������� ������� �� IP
var
i:integer;
begin
try
   if length(ArrayPrefixSrv)>0 then
    for I := 0 to length(ArrayPrefixSrv)-1 do
     begin
     if (ArrayPrefixSrv[i].SrvIp=ipSrv) then
       begin
       result:=ArrayPrefixSrv[i].SrvPrefix; // ������� �������
       break;
       end;
     end;
except on E : Exception do
 Write_Log('SRVConsole',2,'FindPrefixSrv ');
end;
end;

function ThreadConsoleManager.ListPrefixSrv:string;  //������ ���� ��������� � ������������ ��������
var
i:integer;
strtmp:TstringList;
begin
try
  strtmp:=TstringList.Create;
  try
   if length(ArrayPrefixSrv)>0 then
    for I := 0 to length(ArrayPrefixSrv)-1 do
     begin
     if (ArrayPrefixSrv[i].SrvIp<>'') then
     strtmp.Add(ArrayPrefixSrv[i].SrvPrefix+'<|TIME|>'+ArrayPrefixSrv[i].DateCreate); // ������� �������
     end;
  result:=strtmp.CommaText;
  finally
   strtmp.Free;
  end;
except on E : Exception do
 Write_Log('SRVConsole',2,' ListPrefixSrv ');
end;
end;

function ThreadConsoleManager.ListServerClasterToList:string; // ������ ����������� � �������� � ��������
var
i:integer;
ListTmp:TstringList;
prefixSrv:string;
const
StatusConnectArr: array [0..5] of string=('','���������� ������������','������ �� �������� �� ������','�� ������ ������','������ ����������','');
DirectConnect: array [0..2] of string =('���������� �� �����������','��������','���������');
begin
try
ListTmp:=TstringList.Create;
  try
   if length(ArrayClientClaster)>0 then
    for I := 0 to length(ArrayClientClaster)-1 do
     begin
     if ArrayClientClaster[i].StatusConnect=1 then // ���� ������ ���������� �����������
      prefixSrv:=FindPrefixSrv(ArrayClientClaster[i].ServerAddress) // ����������� �������
     else prefixSrv:='';
     ListTmp.Add(ArrayClientClaster[i].ServerAddress+'<!>'+    //- ����� �������
                  StatusConnectArr[ArrayClientClaster[i].StatusConnect]+'<!>'+ // ������ ���������� 2- ������ ������ ��� ������������� ����������, 3-�� ������ ������ ��� ����������� � �������  4-������ ����������
                  Datetimetostr(ArrayClientClaster[i].DateTimeStatus)+'<!>'+ //����� ��������� ����������
                  DirectConnect[ArrayClientClaster[i].InOutput]+'<!>'+   // ��������/���������
                  prefixSrv+'<!>'+ // ������� �������
                  inttostr(ArrayClientClaster[i].SocketHandle)); // ID ����������
     end;
    result:=ListTmp.CommaText;
  finally
  ListTmp.Free;
  end;
except on E : Exception do
 Write_Log('SRVConsole',2,'ListServerClasterToList');
end;
end;

function ThreadConsoleManager.ListClientRuViewerToList:string; // ������ �������� ruviewer
var
i:integer;
ListTmp:TstringList;
begin
try
ListTmp:=TstringList.Create;
  try
   if length(ArrayClientData)>0 then
    for I := 0 to length(ArrayClientData)-1 do
     begin
     if ArrayClientData[i].ConnectBusy then // ���� ������� ��������
     begin
     ListTmp.Add(ArrayClientData[i].ID+'<!>'+    //- ID ��������
                 ArrayClientData[i].TargetID+'<!>'+
                 DateTimetostr(ArrayClientData[i].dateTimeConnect));// ����� �����������
     end;
     end;
    result:=ListTmp.CommaText;
  finally
  ListTmp.Free;
  end;
except on E : Exception do
 Write_Log('SRVConsole',2,'ListClientRuViewerToList ');
end;
end;

Function ThreadConsoleManager.ReadFileToString(FileName:string):string; // ��������� ���� � ��������� ������ ��� �������� � �����
var
i:integer;
f:TFileStream;
Encoding:TEncoding;
TmpList:TstringList;
begin
try
TmpList:=TstringList.Create;
try
Encoding := TUTF8Encoding.Create;
if FileExists(ExtractFilePath(Application.ExeName)+ FileName) then
 begin
 TmpList.LoadFromFile(ExtractFilePath(Application.ExeName)+FileName,Encoding);
 result:=TmpList.CommaText;
 end
 else result:='';
finally
  TmpList.Free;
end;
except on E : Exception do
   Write_Log('SRVConsole',2,'ReadFile ');
end;
end;

Function ThreadConsoleManager.WriteStringToFile(FileName,WriteStr:String):boolean; // ������ ������ � ��������� ����
var
TmpList:TstringList;
Encoding:TEncoding;
begin
try
  TmpList:=TstringList.Create;
  Encoding := TUTF8Encoding.Create;
  try
  TmpList.CommaText:=WriteStr;
  TmpList.SaveToFile(ExtractFilePath(Application.ExeName)+FileName,Encoding);
  result:=true;
  finally
  TmpList.Free;
  end;
 except on E : Exception do
 begin
  result:=false;
   Write_Log('SRVConsole',2,'WriteStringToFile');
 end;
end;
end;

function ThreadConsoleManager.ReadFileSettings:boolean; // ������ ���� ����������� ����������
var
setIni:TMemIniFile;
 begin
 try
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
    try
    PortConsole:=setIni.ReadInteger('Console','port',3899);  // ���� ��� �����������������
    PswdConsole:=setIni.ReadString('Console','pswd','9999');// ������ ��� ����������� �������
    LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // ������������, ��� ����������� �������
    PswdServerViewer:=setIni.ReadString('Viewer','pswd','8888');
    PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
    SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // ������� ip ����� ��� ����������� �������� RuViewer
    PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer ������� �������
    PortServerClaster:=setIni.ReadInteger('claster','port',3897);
    PswdServerClaster:=setIni.ReadString('claster','pswd','8523');
    MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // ������������ ���������� ����������� �������� ����������� � ��������
    PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
    AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // ���������/��������� ������ ������
    LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
    NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // ���������� �������� ���������� �� ��������� � ������ ������
    TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
    SendListServers:=setIni.ReadBool('claster','SendListServers',true); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
    GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
    AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',true); // ����� ������� �������� ��� ������� ������
    AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',true); // ����� ������� RuViewer ��� ������� ������
    result:=true;
    finally
    setIni.Free;
    end;
  except on E : Exception do
  begin
   result:=false;
   Write_Log('SRVConsole',2,'ReadFileSettings');
  end;
 end;
end;

function ThreadConsoleManager.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
var
posStart,posEnd:integer;
bufTmp,BufS:string;
CryptTmp,DecryptTmp:string;
step:integer;
begin
  try
  bufTmp:='';
  BufS:=s;
  step:=0;
   while BufS<>'' do // � ����� ������
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// ������ ������������� �������
      posEnd:=pos('<!!>',BufS); // ����� ������������� �������
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// �������� ����������� ������ ������� � ������� posStart+3 ����� posEnd-4 ��������
      step:=4;
      Decryptstrs(CryptTmp,PswdConsole,DecryptTmp); //���������� ������������� ������
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// ����������� �������������� ������
      step:=6;
      if (posStart=0)or (posEnd=0)  then
        begin
        step:=7;
        BufS:='';
        break;
        end
        else
        begin
        step:=8;
        delete(BufS,posStart,posEnd+3);
        end;
        step:=9;
     end;
     step:=10;
   result:=bufTmp;
  except On E: Exception do
    begin
    Write_Log('SRVConsole',2,'('+inttostr(step)+') ���������� ������ ');
     s:='';
    end;
  end;
end;

procedure ThreadConsoleManager.Execute; // ����� ��� ������� � ����������� �������� �������
var
i,posStart,PosEnd,IDtmp,TMPCountConnect,slepengtime:integer;
CryptBuf,TmpUID,TMPAct,CryptBufTemp:string;     //
Buffer,BufferTmp,pswdIN,LoginIN:string;
CryptText:string;
SendCryptTxT,TmpStr:string;
ActualDateL:boolean;
 function SendMainCryptText(s:string):boolean; // �������� �������������� ������ � main �����
  begin
 // Write_Log('SRVConnect','����� ����������� � ��������� - '+s);
  if Encryptstrs(s,PswdConsole, CryptBuf) then //������� ����� ���������
    begin
    result:=SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
    end
    else
    begin
    result:=false;
    Write_Log('SRVConsole',1,'No Encryptstrs before send');
    end;
  end;
begin
try
//Write_Log('SRVConnect','����� ���������� �������� �������');
SendMainCryptText('<|FIRSTLOAD|>'); // ������� ������� ��� ����� ������� � ����� ��������� ������ ������
slepengtime:=0;
while AdmSocket.Connected do
 BEGIN
 try
 sleep(2);

  if (AdmSocket= nil) or (not AdmSocket.Connected) then break;
  if AdmSocket.ReceiveLength<1 then continue;
  CryptText:=AdmSocket.ReceiveText;
  while not CryptText.Contains('<!!>') do // �������� ����� ������
   begin
    slepengtime:=slepengtime+2;
    if slepengtime>TimeWaitPackage then
     begin
     slepengtime:=0;
     break;
     end;
   Sleep(2);
   if AdmSocket.ReceiveLength < 1 then Continue;
   CryptBufTemp := AdmSocket.ReceiveText;
   CryptText:=CryptText+CryptBufTemp;
   end;
   slepengtime:=0;
   Buffer:=DecryptReciveText(CryptText);
 // Write_Log('SRVConnect','������� - '+Buffer);

  if Buffer.Contains('<|LISTCLIENT|>') then //��������� ������ �������� RuViewer
   begin
   TmpStr:=ListClientRuViewerToList;
   SendMainCryptText('<|LISTCLIEN|>'+TmpStr+'<|END|>');
   end;

  if Buffer.Contains('<|LISTCLASTER|>') then  //��������� ������ ���������� � ��������� ��������
   begin
   TmpStr:=ListServerClasterToList;

   SendMainCryptText('<|LISTCLASTER|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|LISTPREFIX|>') then  //���������� ������ ���������
   begin
   TmpStr:=ListPrefixSrv;
   SendMainCryptText('<|LISTPREFIX|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|STATUSSERVERRUVIEWER|>') then  //���������� ������ ������� RuViewer
   begin
      SingRunRuViewerServer:=StatusRuViewerServer;  // ���������� ������ ������� RuViewer
      SendMainCryptText('<|STATUSSRVRUVIEWER|>'+booltostr(SingRunRuViewerServer)+'<|END|>');
   end;

   if Buffer.Contains('<|STATUSSERVERCLASTER|>') then  //���������� ������� ������� Claster
   begin
    SendMainCryptText('<|STATUSSRVCLASTERIN|>'+booltostr(SingRunInConnectionClaster)+'<|END|>'+
                      '<|STATUSSRVCLASTEROUT|>'+booltostr(SingRunOutConnectClaster)+'<|END|>');
   end;


   if Buffer.Contains('<|LISTSERVERCLASTER|>') then  //��������� ������ �������� �������� �� ����� �������� SrvClaster.dat
   begin
   TmpStr:=ReadFileToString('SrvClaster.dat');
   SendMainCryptText('<|LISTSERVERCLASTER|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|READFILEPARAM|>') then // ��������� ���� � �����������
   begin
   TmpStr:=ReadFileToString('set.dat');
   SendMainCryptText('<|READFILEPARAM|>'+TmpStr+'<|END|>');
   end;


   if Buffer.Contains('<|FILEPARAM|>') then // ������ ���� � �����������
   begin  //'<|FILEPARAM|>'+ParamToIniFileToString+'<|PARAMEND|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|FILEPARAM|>',BufferTmp);
   Delete(BufferTmp,1,posStart+12);
   BufferTmp:=copy(BufferTmp,1,pos('<|PARAMEND|>',BufferTmp)-1);
   if WriteStringToFile('set.dat',BufferTmp) then //���� �������� ���� ��������
     begin
     if ReadFileSettings then  // ������������ ���� � ����������� �����������
     SendMainCryptText('<|READPARAMDONE|>') // ���� ��������� �� ������� �� ����
     else SendMainCryptText('<|NOTREADPARAM|>'); // ����� ������� ��� �� ������ ��������� ���������
     end
     else SendMainCryptText('<|NOTWRITEPARAM|>');// ����� �� �������� ��������
   except On E: Exception do       Write_Log('SRVConnect',2,'Recive file settings' );
    end;
   end;

    if Buffer.Contains('<|LISTSRVCLASTERNEW|>') then // ������ ���� SrvClaster � ��������� ��������
   begin  //'<|LISTSRVCLASTERNEW|>'+ListServerClasterToString+'<|END|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|LISTSRVCLASTERNEW|>',BufferTmp);
   Delete(BufferTmp,1,posStart+20);
   BufferTmp:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
   WriteStringToFile('SrvClaster.dat',BufferTmp); // ���������� ���� �� ������� ��������
   ListServerClaster.CommaText:=BufferTmp;
   except On E: Exception do       Write_Log('SRVConnect',2,'Update ListServerClaster ');
    end;
   end;

   if Buffer.Contains('<|CLOSECONNECT|>') then //������ ��������� ���������� �� ������ �������� �������������
   begin     //'<|CLOSECONNECT|>'+inttostr(TmpID)+'<|END|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|CLOSECONNECT|>',BufferTmp);
   Delete(BufferTmp,1,posStart+15);
   BufferTmp:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
    if TryStrToInt(BufferTmp,IDtmp) then
     begin
      if StopConnectClaster(IDtmp) then // ���� ���������� �� ���������� ����� ������ ����������
       begin
       TmpStr:=ListServerClasterToList;
       SendMainCryptText('<|LISTCLASTER|>'+TmpStr+'<|END|>');
       end;
     end
     else SendMainCryptText('<|NOCORRECTIDCONNECT|>'); // �� ���������� ID �����������

   except On E: Exception do       Write_Log('SRVConsole',2,'Close Connect');
    end;
   end;

    if Buffer.Contains('<|STOPCLASTERSERVER|>') then // ������� ��������� ������� �������������
   begin
    StopInConnectClaster;  // ��������� ������ �������� ���������� ��������
    StopOutConnectClaster;  // ��������� ������ ��������� ���������� ��������
    CleanArrayClaster;   //������� ��������� ������� ���������� � ��������
    CleanArrayPrefix;   //������� ��������� ������� ���������
   end;

     if Buffer.Contains('<|STARTCLASTERSERVER|>') then // ������� ������� ������� �������������
   begin
    RuViewerSrvService.TimerStartServerClaster.Enabled:=true;  // �������� ������ ������� �������
   end;

    if Buffer.Contains('<|STOPRUVIEWERSERVER|>') then // ������� ��������� ������� RuViewer
   begin
     StopServerRuViewerSocket; // ��������� ������� RuViewer
     CleanArrayRuViewer;   //������ ��������� �������
   end;

   if Buffer.Contains('<|STARTRUVIEWERSERVER|>') then // ������ ������� ������� RuViewer
   begin
     RuViewerSrvService.TimerStartServerRuViewer.Enabled:=true; // �������� ������ ������� �������
   end;

   if Buffer.Contains('<|REBOOTSERVICES|>') then // ���������� ������
   begin
   if RebootServices then SendMainCryptText('<|REBOOTSERVICEDONE|>');
   end;

   if Buffer.Contains('<|GETACTIVKEY|>') then // ������ ������� ��������� �������� / �������� ��� � ��� ����
   begin                                     //KeyAct  UIDAct CountConnect
   SendMainCryptText('<|ACTIVEKEY|>'+KeyAct+'<|END|><|UIDACT|>'+LocalUID+'<|END|><|COUNTCONNECT|>'+inttostr(CountConnect)+'<|END|><|DATEL|>'+datetostr(DateL)+'<|END|>');
   end;

   if Buffer.Contains('<|SETACTIVKEY|>') then // �������� ���� ��� ��������� ��������  / ����������
   begin //<|SETACTIVKEY|><|UIDSRV|>654654sdf45s656464<|END|><|KEYSRV|>154-4541-45<|END|>
         //TMPCountConnect,TmpUID,TMPAct
   BufferTmp:=Buffer;
   posStart:=pos('<|UIDSRV|>',BufferTmp);
   Delete(BufferTmp,1,posStart+9);
   TmpUID:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
   Delete(BufferTmp,1,pos('<|KEYSRV|>',BufferTmp)+9);
   TMPAct:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
     begin
      if LocalUID=TmpUID then // ���� UID ���������
       begin
        if WriteRegK(TMPAct) then // ���������� ���� ���������
          begin
           KeyAct:=TMPAct; // �������������� ����� ���������
           if ReadParemS(LocalUID,KeyAct,CountConnect,DateL,ActualDateL) then
            begin
            ActualKey:=true; //
            SendMainCryptText('<|ACTIVEKEYDONE|>'+KeyAct+'<|END|><|UIDACT|>'+LocalUID+'<|END|><|COUNTCONNECT|>'+inttostr(CountConnect)+'<|END|><|DATEL|>'+datetostr(DateL)+'<|END|>');
            end
            else
            begin
            ActualKey:=false;
            if ActualDateL then SendMainCryptText('<|NOACTIVEKEY|>')  // �� ������ ���� ���������
            else  SendMainCryptText('<|NOACTIVEDATE|>');  // ����� �� ���������� ���� ����� ���������
            end;
          end
          else SendMainCryptText('<|NOWRITEKEY|>');  // �� ������� �������� ���� ���������
        Write_Log('SRVConsole',0,'��������������� ������ : ���-�� ��������� :'+inttostr(CountConnect)+' ���� ��������� ��������� :'+datetimetostr(DateL));
       end
      else
      begin
      ActualKey:=false;
      SendMainCryptText('<|NOCORRECTUID|>');
      end;
     end;
     end;

     if Buffer.Contains('<|STATUSACTV|>') then // ������ ������� ��������� ��������
     begin
     if not ActualKey then SendMainCryptText('<|NOTACTIVATED|>');
     end;
   //-------------

    if Buffer.Contains('<|DISCONNECT|>') then // ���������� �������
   begin
     break;
   end;

   Buffer:='';
   except On E: Exception do
    begin
      Write_Log('SRVConsole',2,'�������� ����  ');
      break;
    end;
  end;
 END;
//Write_Log('SRVConnect','����� ���������� �������� ��������');
if AdmSocket.Connected then AdmSocket.Close;
except
    On E: Exception do
    begin
      Write_Log('SRVConsole',2,' ����� Manager  ' + E.ClassName+' / '+ E.Message);
    end;
  end;
 end;

//--------------------------------------------------------------


end.


