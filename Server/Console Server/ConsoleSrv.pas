unit ConsoleSrv;

interface

uses
  Winapi.Windows,WinSvc, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,System.Win.ScktComp,
  Vcl.ComCtrls,IniFiles, Vcl.Mask, Vcl.ExtCtrls,SocketCrypt,DateUtils,
  Vcl.Buttons, Vcl.Menus, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImage,
  Vcl.DBCtrls;

type
  TMainF = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    EditRuViewerPswd: TLabeledEdit;
    EditRuViewerPrefix: TLabeledEdit;
    EditRuViewerPort: TLabeledEdit;
    EditPortServerClaster: TLabeledEdit;
    EditConsolePort: TLabeledEdit;
    EditConsoleLogin: TLabeledEdit;
    EditPswdClaster: TLabeledEdit;
    EditIPExternalClaster: TLabeledEdit;
    EditMaxNumInConnect: TLabeledEdit;
    EditPrefixLifeTime: TLabeledEdit;
    EditLiveTimeBlackList: TLabeledEdit;
    EditNumOccurentc: TLabeledEdit;
    EditTimeOutReconnect: TLabeledEdit;
    CBSendListServers: TCheckBox;
    CBGetListServers: TCheckBox;
    CBBlackListClaster: TCheckBox;
    LVServer: TListView;
    LVClient: TListView;
    LVPrefix: TListView;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    LVServerClaster: TListView;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    LVListServer: TListView;
    PanelServerControl: TPanel;
    PanelServer: TPanel;
    ButAddSrv: TSpeedButton;
    ButDelServer: TSpeedButton;
    ButEditServer: TSpeedButton;
    ButSaveServer: TSpeedButton;
    ButLoadServer: TSpeedButton;
    PPLVServer: TPopupMenu;
    N1: TMenuItem;
    PPLVServerClaster: TPopupMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Panel2: TPanel;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    VirtualImageList2: TVirtualImageList;
    PPLVListServer: TPopupMenu;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    TimerClasterStatus: TTimer;
    TimerRuViewerStatus: TTimer;
    N10: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    GroupBoxService: TGroupBox;
    ButService: TButton;
    GroupBox10: TGroupBox;
    GroupBox11: TGroupBox;
    LabelStatusClaster: TLabel;
    ImageStatusClaster: TVirtualImage;
    ButStartClaster: TButton;
    ButStopClaster: TButton;
    GroupBox12: TGroupBox;
    LabelStatusRuViwewer: TLabel;
    ImageStatusRuViewer: TVirtualImage;
    ButStartRuViewer: TButton;
    ButStopRuViewer: TButton;
    ButStatusServer: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ButDataUpdate: TButton;
    ButSaveSettings: TButton;
    Button1: TButton;
    N11: TMenuItem;
    VM23: TVirtualImageList;
    EditConsolePswd: TLabeledEdit;
    PPpassword: TPopupMenu;
    N12: TMenuItem;
    CBAutoRunSrvClaster: TCheckBox;
    CBAutoRunSrvRuViewer: TCheckBox;
    ButEditSrvClaster: TSpeedButton;
    ButDelSrvClaster: TSpeedButton;
    ButAddSrvClaster: TSpeedButton;
    procedure ClientMRSDServerConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientMRSDServerConnect(Sender: TObject; Socket: TCustomWinSocket) ;
    procedure ClientMRSDServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientMRSDServerError(Sender: TObject;   Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientMRSDServerRead(Sender: TObject; Socket: TCustomWinSocket);
    function WriteLog(s:string):boolean;
    Function ReadParamSettings:boolean; // ������ ���������� �� ini �����
    procedure WriteParamSettings; // ���������� ���������� � ini �����
    Function ReadParamFromString(StrParam:string):boolean; // ������ ���������� ���������� � ������� ����� �����
    function ParamToIniFileToString:string; // ���������� ���������� � (ini ������)������ � ����������� ����������� � ������
    function ListServerClasterToString:string;
    procedure SaveListServerToFile; // ��������� ������ �������� � ������� ������������
    procedure LoadFileServerToList; // ��������� ������ �������� � ������� ������������
    procedure FormCreate(Sender: TObject);
    function ReadListFilesClaster(ListServer:TstringList; FileName:string):boolean; // ������ ���� �� ��������
    function SeparationIpPortPswd(var SrvIP,SrvPswd:string ; var SrvPort:integer;SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
    function LoadListStrServersClaster(StrLst:string):boolean; // ��������� ������ � ListView � ���������� ������� �������� ��� ��������
    function ReadFileServersClaster:boolean; // ������ ����� �� ������� �������� ��� ��������

    function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
    procedure ButDataUpdateClick(Sender: TObject);  //�������� ������ �������
    function LoadListClasterServer(SumS:string):boolean;
    function LoadListClientRuViewer(SumS:string):boolean;
    function LoadListPrefix(SumS:string):boolean; // ��������� ����� � ��������
    function ServiceRunning(sMachine, sService: PChar): DWORD;
    function ServiceGetStatus(sMachine, sService: PChar): DWORD; // �������� ��������� ������
    function StopService(ServiceName: string):boolean;
    Function RunService(ServiceName: string):boolean;
    function ExamServicesServerRuViewer(SrvIP:string):byte; //������� �������� ������� ������ �� ��, ���� ��� ���� �� ���� ����������� ��������� � �� ������ �������
    Function ConnectServerConsole(SrvIp,SrvLogin,SrvPswd:string;srvPort:integer):boolean;
    function AddConsoleLocalServer:boolean; // �������� � ������ ���������� � ��������� ��������� ����� ���� �� ������� �� �� �� �������
    function ClearDefault:boolean; // ������� ����� ����� ������������ � ������� �������
    procedure UpdateStatusRuViewerServer; // ���������� ������� ������ �������� � ���������� ������� RuViewer
    procedure UpdateStatusClasterServer; // ���������� ������� ������ ������� �������������
    Procedure ImageStatusConnect(IpAdrs:string;indexImage:byte); // ��������� ������� ����������
    procedure ConnectSelectedserver;  //������������ ����������� � ���������� �������
    function OpenFormActivationServer(uid,Key:string;CountPC:integer; DateL:Tdatetime):boolean; // ������� ��������� � �������� ����� ��������������

    procedure DisconnectServerConsole;
    function CreateFormEditServerClaster(typeOperation:byte; srvip,srvpswd:string; srvport:integer):boolean; // �������� ����� ��� ��������������, ���������� ������ ������������ ��������
    function CreateFormEditAddServer(typeOperation:byte; srvip,srvLogin,srvpswd:string; srvport:integer):boolean;
    procedure ButSaveSettingsClick(Sender: TObject);
    procedure ButAddSrvClasterClick(Sender: TObject);
    procedure ButEditSrvClasterClick(Sender: TObject);
    procedure ButDelSrvClasterClick(Sender: TObject);
    procedure ButStopClasterClick(Sender: TObject);
    procedure ButStartRuViewerClick(Sender: TObject);
    procedure ButStopRuViewerClick(Sender: TObject);
    procedure ButStartClasterClick(Sender: TObject);
    procedure ButAddSrvClick(Sender: TObject);
    procedure ButDelServerClick(Sender: TObject);
    procedure ButEditServerClick(Sender: TObject);

    procedure ButSaveServerClick(Sender: TObject);
    procedure ButLoadServerClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure LVServerClasterDblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure ButServiceClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure LVListServerDblClick(Sender: TObject);
    procedure ButStatusServerClick(Sender: TObject);
    procedure TimerClasterStatusTimer(Sender: TObject);
    procedure TimerRuViewerStatusTimer(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure PPLVListServerPopup(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure EditConsolePswdMouseLeave(Sender: TObject);
    procedure EditConsolePswdMouseActivate(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure N12Click(Sender: TObject);

  private
    { Private declarations }
  public
       Function SendCryptTex(s:string):boolean;
  end;

var
  MainF: TMainF;
  ClientSocketMRSD:TClientSocket;
  //PortSrv LoginSrv PassSrv
  PortSrv:integer; //���� ������������ ��� ����������� ������� � �������
  LoginSrv:string;  //����� ������������ ��� ����������� ������� � �������
  PassSrv:string[255]; //����� ������������ ��� ����������� ������� � �������
  AddressHost:string; //����� ������������ ��� ����������� ������� � �������


  LoginConsole:string; // ����� ��� ����������� � ������� �� ������� ���������� ������������ ��� ��������
  PswdConsole:string[255]; // ������ ��� ����������� � ������� �� ������� ���������� ������������ ��� ��������
  PortConsole:integer; // ���� ��� ����������� � ������� �� ������� ���������� ������������ ��� ��������
  MyStreamCipherId:string; //TCodec.StreamCipherId ��� ����������
  MyBlockCipherId:string; // TCodec.BlockCipherId ��� ����������
  MyChainModeId:string; // TCodec.ChainModeId ��� ����������
  EncodingCrypt:TEncoding; // ��������� ������ ��� ���������� � ����������
  PswdServerViewer:string; // ������ ������� ��� ����������� �������� RuViewer
  PswdServerClaster:string; // ������ ��� ����������� � �������� ������� � ��������
  PortServerViewer:integer; // ���� ������� ��� ����������� �������� RuViewer
  PortServerClaster:integer; // ���� ��� ����������� � �������� ������� � ��������
  MaxNumInConnect:integer; // ������������ ���-�� �������� ����������� ��� ������������
  PrefixLifeTime:integer;  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
  NumOccurentc:integer;   // ���������� �������� ���������� �� ��������� � ������ ������
  PrefixServer:string; // ������� ������� �������
  SrvIpExternal:string; // ������� IP ����� �������� ������� ��� ����������� �������� �� ��������
  AddIpBlackListClaster:boolean; // ��������� ������ ������
  LiveTimeBlackList:integer; // ��� ����� ����� ������ � ������ ������   LiveTimeBlackList
  TimeOutReconnect:integer; //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
  SendListServers:boolean; // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
  GetListServers:boolean; // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
  LocalUID:string; // ���������� ID ��� ��
  RunConsoleLocal:boolean; // ������� ������� ������� �� �� �� �������
  SingRunRuViewerServer:boolean; // ������ ��������� ������� RuViewer
  SingRunOutConnectClaster:boolean;// ������� ���������� ������ ��������� ���������� ��������
  SingRunInConnectionClaster:boolean; // ������� ���������� ������ �������� ���������� ��������
  TimeoutWaitStatusClasterServer:integer; // ����� �������� �� ������� ������� ������� �������������
  TimeoutWaitStatusRuViewerServer:integer; // ����� �������� �� ������� ������� ������� �������������
  AutoRunSrvClaster:boolean; // ����� ������� �������� ��� ������� ������
  AutoRunSrvRuViewer:Boolean; // ����� ������� RuViewer ��� ������� ������

  UIDServer:string; // uid �������
  KeyServer:string; // ���� ��������� �������
  DateL:Tdatetime;  // ���� ��������� ���������
  CountPC:integer;  // ���������� ����������

implementation
uses UIDGen, FormAct,GenPassword;

{$R *.dfm}

function TMainF.WriteLog(s:string):boolean;
var f:TStringList;
begin

try
  if not DirectoryExists(ExtractFilePath(Application.ExeName)+'log') then CreateDir(ExtractFilePath(Application.ExeName)+'log');
      f:=TStringList.Create;
      try
        if FileExists(ExtractFilePath(Application.ExeName)+'log\Console.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\Console.log');
          f.Insert(0,DateTimeToStr(Now)+chr(9)+' - '+s);
        while f.Count>1000 do f.Delete(1000);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\Console.log');
      finally
        f.Destroy;
      end;
  except
    exit;
  end;
end;




Function TMainF.SendCryptTex(s:string):boolean;
var
CrptT:string;
begin
try
  if ClientSocketMRSD.Active then
   begin
   // WriteLog('����� ����������� � ��������� - '+s);
    if Encryptstrs(s,PassSrv,CrptT) then
    begin
    while ClientSocketMRSD.Socket.SendText('<!>'+CrptT+'<!!>')<0 do sleep(2);
    result:=true;
    end
    else
    begin
    WriteLog('ERROR No Encryptstrs before sent');
    result:=false;
    end;
   end;
except on E : Exception do
begin
result:=false;
WriteLog(E.ClassName+' SendText ������ : '+E.Message);
end;
end;
end;

function TMainF.ServiceGetStatus(sMachine, sService: PChar): DWORD; // �������� ��������� ������
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

function TMainF.StopService(ServiceName: string):boolean; // ��������� ������
var
  schService,
    schSCManager: DWORD;
  p: PChar;
  ss: _SERVICE_STATUS;
begin
  p := nil;
  schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if schSCManager = 0 then
   begin
    RaiseLastWin32Error;
    result:=false;
   end;
  try
    schService := OpenService(schSCManager, PChar(ServiceName),
      SERVICE_ALL_ACCESS);
    if schService = 0 then
     begin
      result:=false;
      RaiseLastWin32Error;
     end;
    try
      if not ControlService(schService, SERVICE_CONTROL_STOP, SS) then
      begin
       result:=false;
       RaiseLastWin32Error;
      end
       else result:=true;
    finally
      CloseServiceHandle(schService);
    end;
  finally
    CloseServiceHandle(schSCManager);
  end;
end;






Function TMainF.RunService(ServiceName: string):boolean;
var
  schService,
    schSCManager: Dword;
  p: PChar;
begin
try
  p := nil;
  schSCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if schSCManager = 0 then
   begin
    RaiseLastWin32Error;
   end;
  try
    schService := OpenService(schSCManager, PChar(ServiceName), SERVICE_START);
    if schService = 0 then
     begin
      RaiseLastWin32Error;
      result:=false;
     end;
    try
      if not StartService(schService, 0, p) then
       begin
        RaiseLastWin32Error;
        result:=false;
       end
       else result:=true;
    finally
      CloseServiceHandle(schService);
    end;
  finally
    CloseServiceHandle(schSCManager);
  end;
except on E : Exception do
 WriteLog(E.ClassName+'StartService ������ : '+E.Message);
end;
end;



function TMainF.ServiceRunning(sMachine, sService: PChar): DWORD;
begin
  Result :=ServiceGetStatus(sMachine, sService);
end;

procedure TMainF.EditConsolePswdMouseActivate(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
if (Sender is TlabelEdEdit) then (Sender as TlabelEdEdit).PasswordChar:=#0;
end;

procedure TMainF.EditConsolePswdMouseLeave(Sender: TObject);
begin
if (Sender is TlabelEdEdit) then (Sender as TlabelEdEdit).PasswordChar:=#42;
end;



function TMainF.ExamServicesServerRuViewer(SrvIP:string):byte; //������� �������� ������� ������ �� ��, ���� ��� ���� �� ���� ����������� ��������� � �� ������ �������
var
RunServ:byte;
begin
{*** -1 = Error opening service ***}
  {*** 1 = SERVICE_STOPPED ***}
  {*** 2 = SERVICE_START_PENDING ***}
  {*** 3 = SERVICE_STOP_PENDING ***}
  {*** 4 = SERVICE_RUNNING ***}
  {*** 5 = SERVICE_CONTINUE_PENDING ***}
  {*** 6 = SERVICE_PAUSE_PENDING ***}
  {*** 7 = SERVICE_PAUSED ***}
 RunServ:=0;
 if (SrvIP='')or(SrvIP='127.0.0.1')or(SrvIP='localhost') then RunServ:=ServiceRunning('','RuViewerSrvService');

 if (RunServ=0)or(RunServ=-1)  then
  begin
  ButService.Caption:='Reset'; // ���� ������ ��� �� ���������� ������ �� ����
  ButService.Hint:='������������� ������ RuViewerSrvService �� �������';
  end;

  Begin
   if (RunServ=1) then //SERVICE_STOPPED
    begin
    ButService.Caption:='Start';
    ButService.Hint:='��������� ������ RuViewerSrvService';
    end;

   if (RunServ=4) then //SERVICE_RUNNING
    begin
    ButService.Caption:='Stop';
    ButService.Hint:='���������� ������ RuViewerSrvService';
    end;
  End;
    result:=RunServ;
end;


procedure TMainF.ButServiceClick(Sender: TObject);
begin

if ButService.Caption='Start' then
begin
if RunService('RuViewerSrvService') then
  begin
  ButService.Caption:='Stop';
  ButService.Hint:='���������� ������ RuViewerSrvService';
  end;
exit;
end;

if ButService.Caption='Stop' then
begin
 if StopService('RuViewerSrvService') then
  begin
  ButService.Caption:='Start';
  ButService.Hint:='��������� ������ RuViewerSrvService';
  end;
 exit;
end;

if ButService.Caption='Reset' then SendCryptTex('<|REBOOTSERVICES|>'); //� ��� ������ ���� ������� �������� �� �� �� �� ������� �� ���������� ������� �� ���������� ������
end;

function TMainF.ClearDefault:boolean; // ������� ����� ����� ������������ � ������� �������
begin
 EditConsolePort.Text:='0';
 EditConsolePswd.Text:='';
 EditConsoleLogin.Text:='';
 EditRuViewerPswd.Text:='';
 EditRuViewerPort.Text:='0';
 EditRuViewerPrefix.Text:='';
 EditPswdClaster.Text:='';
 EditPortServerClaster.Text:='0';
 EditIPExternalClaster.Text:='';
 EditMaxNumInConnect.Text:='0';
 EditPrefixLifeTime.Text:='0';
 EditLiveTimeBlackList.Text:='0';
 EditNumOccurentc.Text:='0';
 EditTimeOutReconnect.Text:='0';
 CBSendListServers.Checked:=false;
 CBGetListServers.Checked:=false;
 CBBlackListClaster.Checked:=false;
 CBAutoRunSrvClaster.Checked:=false; // ����� ������� �������� ��� ������� ������
 CBAutoRunSrvRuViewer.Checked:=false; // ����� ������� RuViewer ��� ������� ������
 LVClient.Clear;
 LVServer.Clear;
 LVPrefix.Clear;
 LVServerClaster.Clear;
 ButStopRuViewer.Enabled:=false;
 ButStartRuViewer.Enabled:=false;
 ButStartClaster.Enabled:=false;
 ButStopClaster.Enabled:=false;
 ImageStatusClaster.ImageIndex:=6;
 ImageStatusRuViewer.ImageIndex:=6;

 TimerClasterStatus.Enabled:=false;
 LabelStatusClaster.Caption:='';
 TimerRuViewerStatus.Enabled:=false;
 LabelStatusRuViwewer.Caption:='';

end;

function TMainF.AddConsoleLocalServer:boolean; // �������� � ������ ���������� � ��������� ��������� ����� ���� �� ������� �� �� �� �������
var
i:integer;
begin
try
 with LVListServer.Items.Add do
  begin
  caption:='127.0.0.1';
  subitems.Add(inttostr(PortConsole));
  subitems.Add(LoginConsole);
  subitems.Add(PswdConsole);
  imageindex:=2;
  Selected:=true;
  end;

except on E : Exception do
 WriteLog(E.ClassName+' AddConsoleLocalServer ������ : '+E.Message);
end;
end;

procedure TMainF.UpdateStatusClasterServer; // ���������� ������� ������ �������� � ���������� ������� ��������
begin
// SingRunOutConnectClaster:boolean;// ������� ���������� ������ ��������� ���������� ��������
   // SingRunInConnectionClaster:boolean; // ������� ���������� ������ �������� ���������� ��������
 if (SingRunOutConnectClaster) or (SingRunInConnectionClaster) then // ���� ���� ���� �� �������� �������� �� ������� ���� �������� ���� ��������� ����������� � ��������
 begin
 ButStopClaster.Enabled:=true;
 ButStartClaster.Enabled:=false;
 ImageStatusClaster.ImageIndex:=4;
 end
 else
 if (not SingRunOutConnectClaster) and ( not SingRunInConnectionClaster) then // ���� ��� false ������ ������������� ��������� ���������
 begin
 ButStopClaster.Enabled:=false;
 ButStartClaster.Enabled:=true;
 ImageStatusClaster.ImageIndex:=6;
 end;
end;

procedure TMainF.UpdateStatusRuViewerServer; // ���������� ������� ������ �������� � ���������� ������� RuViewer
begin
if SingRunRuViewerServer then
begin
ButStopRuViewer.Enabled:=true;
ButStartRuViewer.Enabled:=false;
ImageStatusRuViewer.ImageIndex:=4;
end
else
begin
ButStopRuViewer.Enabled:=false;
ButStartRuViewer.Enabled:=true;
ImageStatusRuViewer.ImageIndex:=6;
end;

end;

Procedure TMainF.ImageStatusConnect(IpAdrs:string;indexImage:byte); // ��������� ������� ����������
var
i:integer;
begin
try
for I := 0 to LVListServer.Items.Count-1 do
begin
  if LVListServer.Items[i].Caption=IpAdrs then
  begin
   LVListServer.Items[i].ImageIndex:=indexImage;
   break;
  end;
end;
except on E : Exception do
 WriteLog(E.ClassName+'ImageStatusConnect ������ : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerConnect(Sender: TObject; Socket: TCustomWinSocket);
var
cryptText:string;
begin
try
ImageStatusConnect(socket.RemoteAddress,0);
WriteLog('���������� � �������� '+socket.RemoteAddress+' �����������');
Encryptstrs('<|ADMSOCKET|>'+PassSrv+'<|>'+LoginSrv+'<|END|>',PassSrv,cryptText);
//WriteLog('���������� - '+cryptText);
Socket.SendText(cryptText);
except on E : Exception do
WriteLog(E.ClassName+' Connect ������ : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
try
//WriteLog('���������� � �������� '+socket.RemoteAddress+' �����������');
ImageStatusConnect(socket.RemoteAddress,1);
except on E : Exception do
WriteLog(E.ClassName+' Connecting ������ : '+E.Message);
end;
end;


procedure TMainF.ClientMRSDServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
i:integer;
begin
try
ImageStatusConnect(socket.RemoteAddress,2);
WriteLog('���������� �� ������� '+socket.RemoteAddress);
except on E : Exception do
WriteLog(E.ClassName+' Disconnect ������ : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerError(Sender: TObject;   Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
WriteLog('Error C��������� � �������� ' +socket.RemoteAddress+' : '+ SysErrorMessage(ErrorCode));
ErrorCode:=0;
except on E : Exception do
WriteLog(E.ClassName+'������ ����������� : '+E.Message);
end;
end;



function TMainF.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
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
      Decryptstrs(CryptTmp,PassSrv,DecryptTmp); //���������� ������������� ������
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
    WriteLog('ERROR  ������ ���������� ������ '+ E.ClassName+' / '+ E.Message);
     s:='';
    end;
  end;
end;


function TmainF.LoadListClasterServer(SumS:string):boolean;
var
i:integer;
posEnd:integer;
ItmTmp,IpTmp,StatTmp,DTtmp,InOut,PrfxTmp,IDConnectTmp:string;
TstrList:TstringList;
IDInt:integer;
begin
try
LVserver.Clear;
TstrList:=Tstringlist.Create;
TstrList.CommaText:=SumS;
  try
   for I := 0 to TstrList.Count-1 do
    Begin
     ItmTmp:=TstrList[i];
     //WriteLog(ItmTmp);
     if ItmTmp<>'' then
      begin
      posEnd:=pos('<!>',ItmTmp);// ������ ������������� �������
      IpTmp:=copy(ItmTmp,1,posEnd-1);  //IP ����� �������
      Delete(ItmTmp,1,posEnd+2);
      end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       StatTmp:= copy(ItmTmp,1,posEnd-1); //������ ����������
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       DTtmp:= copy(ItmTmp,1,posEnd-1);  //���� � ����� ��������� ����������
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       InOut:= copy(ItmTmp,1,posEnd-1);  //��������/��������� ����������
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       PrfxTmp:=copy(ItmTmp,1,posEnd-1);  //�������
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then  // ID ����������
       begin
        if TryStrToint(ItmTmp,IDInt) then
         begin
         if (IDInt<>2) and (IDInt<>0) then IDConnectTmp:=inttostr(IDInt)
         else IDConnectTmp:='';
         end;
       end;

       if IpTmp<>'' then
         begin
           with LVserver.Items.Add do
           begin
           caption:=inttostr(LVserver.Items.Count);
           subitems.Add(IpTmp);
           subitems.add(StatTmp);
           subitems.add(DTtmp);
           subitems.add(InOut);
           subitems.add(PrfxTmp);
           subitems.add(IDConnectTmp);
           end;
         end;
       IpTmp:='';
       StatTmp:='';
       DTtmp:='';
       InOut:='';
       PrfxTmp:='';
       IDConnectTmp:='';
    End;
  finally
  TstrList.Free;
  end;
except
on E : Exception do WriteLog(E.ClassName+' LoadListClasterServer ������ : '+E.Message);
end;
end;

//286-210-251<!>15.12.2023 13:21:47
//286-213-352<!>15.12.2023 13:21:47
function TmainF.LoadListClientRuViewer(SumS:string):boolean; // ��������� ������ ��� ������ �������� RuViewer �������
var
i:integer;
posEnd:integer;
IDTmp,IDTargetTmp,DTtmp,ItmTmp:string;
TstrList:TstringList;
begin
try
LVClient.Clear;
TstrList:=Tstringlist.Create;
TstrList.CommaText:=SumS;
  try
   for I := 0 to TstrList.Count-1 do
    Begin
     ItmTmp:=TstrList[i];
     if ItmTmp<>'' then
      begin
      posEnd:=pos('<!>',ItmTmp);// ������ ������������� �������
      IDTmp:=copy(ItmTmp,1,posEnd-1);  //ID client
      Delete(ItmTmp,1,posEnd+2);
      end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       IDTargetTmp:= copy(ItmTmp,1,posEnd-1); //TargetID
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       DTtmp:=ItmTmp;  //�����
       end;

       with LVClient.Items.Add do
       begin
       caption:=inttostr(i+1);
       subitems.Add(IDTmp); //ID
       subitems.add(DTtmp); // time
       subitems.add(IDTargetTmp); //Target ID
       end;
       IDTmp:='';
       DTtmp:='';
       IDTargetTmp:='';
    End;
  finally
  TstrList.Free;
  end;
except
on E : Exception do WriteLog(E.ClassName+' LoadListClientRuViewer ������ : '+E.Message);
end;
end;

function TmainF.LoadListPrefix(SumS:string):boolean; // ��������� ������ ���������
var
i:integer;
posEnd:integer;
ItmTmp:string;
DtTmp:TDateTime;
TstrList:TstringList;
function parsingstr(var SDT:TdateTime; var SPrefix:string; StrParse:string):boolean;
  begin // 621-23<|TIME|>� ����
    try
    SPrefix:=copy(StrParse,1,pos('<|TIME|>',StrParse)-1);
    delete(StrParse,1,pos('<|TIME|>',StrParse)+7);
    if not TryStrToDateTime(StrParse,SDT) then SDT:=TTimeZone.local.ToUniversalTime(now);
   except on E : Exception do
    begin
     WriteLog('ParsingPrefix ' +E.ClassName+' / '+E.Message);
    end;
   end;
  end;
begin
try
LVPrefix.Clear;
TstrList:=Tstringlist.Create;
TstrList.CommaText:=SumS;
  try
   for I := 0 to TstrList.Count-1 do
    Begin
     //ItmTmp:=TstrList[i];
     //WriteLog(ItmTmp);
     parsingstr(DtTmp,ItmTmp,TstrList[i]);
       with LVPrefix.Items.Add do
       begin
       caption:=inttostr(i+1);
       subitems.Add(ItmTmp); //prefix
       subitems.Add(DateTimeToStr(TTimeZone.local.ToLocalTime(DtTmp))); // ����� ���������� ��������
       end;
    End;
  finally
  TstrList.Free;
  end;
except
on E : Exception do WriteLog(E.ClassName+' LoadListPrefix ������ : '+E.Message);
end;
end;

function TMainF.OpenFormActivationServer(uid,Key:string;CountPC:integer; DateL:Tdatetime):boolean;
begin
try
FormActivation.MemoUID.Clear;
FormActivation.EditKey.text:='';
FormActivation.EditCount.Text:='';
FormActivation.EditDate.Text:='';
FormActivation.MemoUID.Lines.Add(uid);
FormActivation.EditCount.text:=inttostr(CountPC);
FormActivation.EditKey.Text:=key;
FormActivation.EditDate.Text:=datetostr(DateL);
FormActivation.Show;
except
on E : Exception do WriteLog(E.ClassName+'Show FormActiv ������ : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerRead(Sender: TObject; Socket: TCustomWinSocket);
var
buffer,BufferTemp,CryptText,TmpStr,CryptBufTemp:string;
TempStream:TMemorystream;
position,i,slepengtime:integer;
listTmp:TstringList;
begin
try
slepengtime:=0;
 CryptText := Socket.ReceiveText;
  while not CryptText.Contains('<!!>') do // �������� ����� ������
   begin
    slepengtime:=slepengtime+2;
    if slepengtime>600 then
     begin
     slepengtime:=0;
     break;
     end;
   Sleep(2);
   if Socket.ReceiveLength < 1 then Continue;
   CryptBufTemp := Socket.ReceiveText;
   CryptText:=CryptText+CryptBufTemp;
   end;
 Buffer:=DecryptReciveText(CryptText); // ���������� ���������
 //WriteLog('������� �������� - '+Buffer);
  position:=pos('<|FIRSTLOAD|>',Buffer); // ������ �������� ������ ��� ��������� ����������
  if  position>0 then
  begin
  SendCryptTex('<|STATUSACTV|><|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|><|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>'); // ������ ������ ��������, ������ ���������� ��������, ������ ���������,��������� �����, ������� ��������
  end;

  position:=pos('<|LISTCLIEN|>',Buffer);
 if  position>0 then
  Begin
    listTmp:=TstringList.Create;
     try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,position+12);
       listTmp.CommaText:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
       LoadListClientRuViewer(listTmp.CommaText);

     finally
     listTmp.free;
     end;
  End;

  position:=pos('<|LISTCLASTER|>',Buffer); // ������ ������������� ���������� � ��������
 if  position>0 then
  Begin
    listTmp:=TstringList.Create;
     try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,position+14);
       listTmp.CommaText:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
       LoadListClasterServer(listTmp.CommaText);

     finally
     listTmp.free;
     end;
  End;

  position:=pos('<|LISTPREFIX|>',Buffer); // �������� ������ ���������
 if  position>0 then
  Begin
    listTmp:=TstringList.Create;
     try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,position+13);
       listTmp.CommaText:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
       LoadListPrefix(listTmp.CommaText);

     finally
     listTmp.free;
     end;
  End;
  //''
   position:=pos('<|LISTSERVERCLASTER|>',Buffer);  // �������� �� ������� ������ �������� �������� �� ����� ��������
  if  position>0 then //'<|LISTSERVERCLASTER|>'+TmpStr+'<|END|>'
   Begin
   listTmp:=TstringList.Create;
     try
     BufferTemp:=Buffer;
     delete(BufferTemp,1,position+20);
     listTmp.CommaText:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
     LoadListStrServersClaster(listTmp.CommaText);
     finally
     listTmp.free;
     end;
   End;
   //
   position:=pos('<|READFILEPARAM|>',Buffer);  // �������� �� ������� ������ �� ����� ��������
  if  position>0 then //'<|READFILEPARAM|>'+TmpStr+'<|END|>'
   Begin
   listTmp:=TstringList.Create;
     try
     BufferTemp:=Buffer;
     delete(BufferTemp,1,position+16);
     listTmp.CommaText:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
     ReadParamFromString(listTmp.CommaText);
     finally
     listTmp.free;
     end;
   End;


    position:=pos('<|STATUSSRVRUVIEWER|>',Buffer);  // �������� �� ������� ������ ������ �������
    if  position>0 then //'<|STATUSSRVRUVIEWER|>'+booltostr(SingRunRuViewerServer)+'<|END|>'
    begin
    BufferTemp:=Buffer;
    delete(BufferTemp,1,position+20);
    TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
    if not trystrtobool(TmpStr,SingRunRuViewerServer) then SingRunRuViewerServer:=false;// SingRunRuViewerServer:boolean; // ������ ��������� ������� RuViewer
    UpdateStatusRuViewerServer; // ���������� ������� ������ �������� � ���������� ������� RuViewer
    end;

    position:=pos('<|STATUSSRVCLASTERIN|>',Buffer);  // �������� �� ������� ������ ������ �������
    if  position>0 then  //'<|STATUSSRVCLASTERIN|>'+booltostr(SingRunInConnectionClaster)+'<|END|>'+'<|STATUSSRVCLASTEROUT|>'+booltostr(SingRunOutConnectClaster)+'<|END|>'
      begin
      BufferTemp:=Buffer;
      delete(BufferTemp,1,position+21);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtobool(TmpStr,SingRunOutConnectClaster) then SingRunOutConnectClaster:=false; // SingRunOutConnectClaster:boolean;// ������� ���������� ������ ��������� ���������� ��������
      position:=pos('<|STATUSSRVCLASTEROUT|>',BufferTemp);
      delete(BufferTemp,1,position+22);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
       if not trystrtobool(TmpStr,SingRunInConnectionClaster) then SingRunInConnectionClaster:=false; // SingRunInConnectionClaster:boolean; // ������� ���������� ������ �������� ���������� ��������
      UpdateStatusClasterServer; // ���������� ������� ������ �������� � ���������� ������� ��������
      end;

    position:=pos('<|ACTIVEKEY|>',Buffer);  // �������� �� ������� ������ � ��������
    if  position>0 then  //<|ACTIVEKEY|>KeyAct<|END|><|UIDACT|>LocalUID<|END|><|COUNTCONNECT|>inttostr(CountConnect)<|END|><|DATEL|>datetostr(DateL)<|END|>
      begin
      {UIDServer:string; // uid �������
       KeyServer:string; // ���� ��������� �������
       DateL:Tdatetime;  // ���� ��������� ���������
       CountPC:integer; // ���-�� ����������� RuViewer}
      BufferTemp:=Buffer;
      delete(BufferTemp,1,position+12);
      KeyServer:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      delete(BufferTemp,1,pos('<|UIDACT|>',BufferTemp)+9);
      UIDServer:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      delete(BufferTemp,1,pos('<|COUNTCONNECT|>',BufferTemp)+15);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtoint(TmpStr,CountPC) then CountPC:=10;
      delete(BufferTemp,1,pos('<|DATEL|>',BufferTemp)+8);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtodate(TmpStr,DateL) then DateL:=now;
      BufferTemp:='';
      OpenFormActivationServer(UIDServer,KeyServer,CountPC,DateL);
      end;

      position:=pos('<|ACTIVEKEYDONE|>',Buffer);  // �������� �� ������� ������ � ��� ��� ������ ������� ����������
    if  position>0 then  //'<|ACTIVEKEYDONE|>'+KeyAct+'<|END|><|UIDACT|>'+LocalUID+'<|END|><|COUNTCONNECT|>'+inttostr(CountConnect)+'<|END|><|DATEL|>'+datetostr(DateL)+'<|END|>'
      begin
      BufferTemp:=Buffer;
      delete(BufferTemp,1,position+16);
      KeyServer:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      delete(BufferTemp,1,pos('<|UIDACT|>',BufferTemp)+9);
      UIDServer:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      delete(BufferTemp,1,pos('<|COUNTCONNECT|>',BufferTemp)+15);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtoint(TmpStr,CountPC) then CountPC:=10;
      delete(BufferTemp,1,pos('<|DATEL|>',BufferTemp)+8);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtodate(TmpStr,DateL) then DateL:=now;
      BufferTemp:='';
      FormActivation.ActiveDone(KeyServer,CountPC,DateL);
      end;

     position:=pos('<|NOACTIVEKEY|>',Buffer);  // �������� �� ������� ����� � ��� ��� �������� �� ���������
     if  position>0 then
      begin
      FormActivation.NoActive;
      end;

     position:=pos('<|NOCORRECTUID|>',Buffer);  // �� ���������� UID �������
     if  position>0 then
      begin
      FormActivation.NoCorrectUIDSrv;
      end;

     position:=pos('<|NOACTIVEDATE|>',Buffer);  // �� ���������� ���� ����� ���������
     if  position>0 then
      begin
      FormActivation.NoCorrectDate;
      end;

       position:=pos('<|NOTACTIVATED|>',Buffer);  // ������� �� �����������
     if  position>0 then
      begin
      SendCryptTex('<|GETACTIVKEY|>'); // ������ ������� ��������
      end;

      position:=pos('<|NOWRITEKEY|>',Buffer);  // �� ������� �������� ���� ��������
     if  position>0 then
      begin
      FormActivation.NoWriteKeyAct;
      end;

      position:=pos('<|REBOOTSERVICEDONE|>',Buffer);  // ���������� ������ �������
     if  position>0 then
      begin
      MainF.ClearDefault;
      end;

     position:=pos('<|READPARAMDONE|>',Buffer);  //������ ������� � �������� ������������ ���������
     if  position>0 then
      begin
      MessageDlg('��������� ������� ���������', mtInformation,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOTREADPARAM|>',Buffer);  //������ ������� �� �� �������� ������������ ���������
     if  position>0 then
      begin
      MessageDlg('��������� ���������, ������������� ������ RuViewerSrvService.', mtInformation,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOTWRITEPARAM|>',Buffer);  //������ �� ���� ��������� ��������� � ����
     if  position>0 then
      begin
      MessageDlg('�� ������� ��������� ���������, ������������� ������ RuViewerSrvService.', mtError,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOCORRECTIDCONNECT|>',Buffer);  //������ �� ���� ��������� ��������� � ����
     if  position>0 then
      begin
      MessageDlg('�� ���������� ID �����������.', mtError,[mbOk], 0, mbOk);
      end;

except
on E : Exception do WriteLog(E.ClassName+' ClientMRSDServerRead ������ : '+E.Message);
end;
end;


function TMainF.ReadListFilesClaster(ListServer:TstringList; FileName:string):boolean; // ������ ���� �� ��������
var
i:integer;
f:TFileStream;
Encoding:TEncoding;
begin
try
Encoding := TUTF8Encoding.Create;
if FileExists(ExtractFilePath(Application.ExeName)+ FileName) then
 begin
 ListServer.LoadFromFile(ExtractFilePath(Application.ExeName)+FileName,Encoding);
 //WriteLog(FileName+' '+ListServer.CommaText);
 result:=true;
 end
 else result:=false;
except on E : Exception do
 WriteLog('������ ReadList: '+E.ClassName+': '+E.Message);
end;
end;



function TMainF.SeparationIpPortPswd(var SrvIP,SrvPswd:string ; var SrvPort:integer; SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do
WriteLog('������ �������� ���������� �����������  : '+E.ClassName+': '+E.Message);  end;
end;





function TMainF.ReadFileServersClaster:boolean; // ������ ����� �� ������� �������� ��� ��������
var                             //172.16.1.2=3897=8523=;
TmpList:TstringList;             // IP       port  pswd
i,SrvPort:integer;
SrvIP,SrvPswd:string;
begin
try
TmpList:=TstringList.Create;
LVServerClaster.Clear;
  try
  if ReadListFilesClaster(TmpList,'SrvClaster.dat') then // ���� ��������� ����
    begin
      for I := 0 to TmpList.Count-1 do
       begin
        SeparationIpPortPswd(SrvIP,SrvPswd,SrvPort,TmpList[i]);
        with LVServerClaster.Items.Add do
         begin
          caption:=inttostr(LVServerClaster.Items.Count);
          subitems.Add(SrvIP);
          subitems.Add(inttostr(SrvPort));
          subitems.Add(SrvPswd);
         end;
        SrvIP:='';
        SrvPort:=0;
        SrvPswd:='';
       end;
       result:=true;
    end
    else result:=false;

    finally
    TmpList.Free;
    end;
except on E : Exception do
 WriteLog(E.ClassName+' ReadFileServersClaster ������ : '+E.Message);
end;
end;

function TMainF.LoadListStrServersClaster(StrLst:string):boolean; // ��������� ������ � ListView � ���������� ������� �������� ��� ��������
var                             //172.16.1.2=3897=8523=;
TmpList:TstringList;             // IP       port  pswd
i,SrvPort:integer;
SrvIP,SrvPswd:string;
begin
try
TmpList:=TstringList.Create;
LVServerClaster.Clear;
  try
  TmpList.CommaText:=StrLst;
    begin
      for I := 0 to TmpList.Count-1 do
       begin
        SeparationIpPortPswd(SrvIP,SrvPswd,SrvPort,TmpList[i]);
        with LVServerClaster.Items.Add do
         begin
          caption:=inttostr(LVServerClaster.Items.Count);
          subitems.Add(SrvIP);
          subitems.Add(inttostr(SrvPort));
          subitems.Add(SrvPswd);
         end;
        SrvIP:='';
        SrvPort:=0;
        SrvPswd:='';
       end;
    end
    finally
    TmpList.Free;
    end;
except on E : Exception do
 WriteLog(E.ClassName+' LoadListStrServersClaster ������ : '+E.Message);
end;
end;



Function TMainF.ReadParamSettings:boolean;
var
setIni:TMemIniFile;
begin
 try
    {begin
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
      try
      setIni.WriteInteger('Console','port',3899);
      setIni.WriteString('Console','pswd','9999');
      setIni.WriteString('Console','Login','ConsoleAdmin');
      setIni.WriteInteger('Viewer','port',3898);
      setIni.WriteString('Viewer','pswd','1593');
      setIni.WriteString('Viewer','interface','');  // ������� ip ����� ��� ����������� �������� RuViewer
      setIni.WriteString('Viewer','prefix','');    // RuViewer ������� �������
      setIni.WriteInteger('claster','port',3897);
      setIni.WriteString('claster','pswd','8523');
      setIni.WriteInteger('claster','MaxNumInConnect',10); // ������������ ���-�� �������� ����������� ��� ������������
      setIni.WriteInteger('claster','PrefixLifeTime',10); // ������������ ����� ����� �������� ���� �� �� ���������� ����������� ��������
      setIni.WriteBool('claster','BlackList',false); //�������� ��� ��� ������ ������
      setIni.WriteInteger('claster','NumberOfLockRetries',3); // ���������� �������� ���������� �� ��������� � ������ ������
      setIni.WriteInteger('claster','BlackListLifeTime',10); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',5); //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      setIni.WriteBool('claster','SendListServers',SendListServers); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','GetListServers',GetListServers);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������

      LoginConsole:='ConsoleAdmin'; // ����� ��� ����������� � ������� �� ������� ����������
      PswdConsole:='9999'; // ������ ��� ����������� � ������� �� ������� ����������
      PortConsole:=3899; // ���� ��� ����������� � ������� �� ������� ����������
      PswdServerViewer:='1593'; // ������ ������� ��� ����������� �������� ��������
      PswdServerClaster:='8523';  // ������ ��� ����������� � ��������
      PortServerViewer:=3898; // ���� ������� ��� ����������� ��������  ��������
      PortServerClaster:=3897; // ���� ��� �������������
      MaxNumInConnect:=10; // ������������ ���-�� �������� ����������� ��� ������������
      PrefixLifeTime:=10;  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
      PrefixServer:='';  // ������� �������
      SrvIpExternal:=''; // ������� IP ����� �������� ������� ��� ����������� �������� �� ��������
      AddIpBlackListClaster:=false; // ��������� ������ ������
      NumOccurentc:=3; // ���������� �������� ��� ���������� �� �������� � ������ ������  ������ ������
      LiveTimeBlackList:=10; // ��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      TimeOutReconnect:=5; //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      SendListServers:=true; // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      GetListServers:=true; // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      finally
      setIni.UpdateFile;
      setIni.Free;
      end;
   end
   else}
   if FileExists(ExtractFilePath(Application.ExeName)+ 'set.dat') then
   begin
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
      try
      PortConsole:=setIni.ReadInteger('Console','port',3899);  // ���� ��� �����������������
      PswdConsole:=setIni.ReadString('Console','pswd','9999');// ������ ��� ����������� �������
      LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // ������������, ��� ����������� �������
      PswdServerViewer:=setIni.ReadString('Viewer','pswd','1593');
      PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
      PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer ������� �������
      SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // ������� ip ����� ��� ����������� �������� RuViewer
      PortServerClaster:=setIni.ReadInteger('claster','port',3897);
      PswdServerClaster:=setIni.ReadString('claster','pswd','8523');
      MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // ������������ ���������� ����������� �������� ����������� � ��������
      PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
      LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // ���������� �������� ���������� �� ��������� � ������ ������
      TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      SendListServers:=setIni.ReadBool('claster','SendListServers',true); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // ���������/��������� ������ ������
      AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',false); // ����� ������� �������� ��� ������� ������
      AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',false); // ����� ������� RuViewer ��� ������� ������
      finally
      setIni.Free;
      end;
     EditConsolePort.Text:=inttostr(PortConsole);
     EditConsolePswd.Text:=PswdConsole;
     EditConsoleLogin.Text:=LoginConsole;
     EditRuViewerPswd.Text:=PswdServerViewer;
     EditRuViewerPort.Text:=inttostr(PortServerViewer);
     EditRuViewerPrefix.Text:=PrefixServer;
     EditPswdClaster.Text:=PswdServerClaster;
     EditPortServerClaster.Text:=inttostr(PortServerClaster);
     EditIPExternalClaster.Text:=SrvIpExternal;
     EditMaxNumInConnect.Text:=inttostr(MaxNumInConnect);
     EditPrefixLifeTime.Text:=inttostr(PrefixLifeTime);
     EditLiveTimeBlackList.Text:=inttostr(LiveTimeBlackList);
     EditNumOccurentc.Text:=inttostr(NumOccurentc);
     EditTimeOutReconnect.Text:=inttostr(TimeOutReconnect);
     CBSendListServers.Checked:=SendListServers;
     CBGetListServers.Checked:=GetListServers;
     CBBlackListClaster.Checked:=AddIpBlackListClaster;
     CBAutoRunSrvRuViewer.Checked:=AutoRunSrvRuViewer;
     CBAutoRunSrvClaster.Checked:=AutoRunSrvClaster;
      result:=true;
   end
   else result:=false;
 except
 on E : Exception do WriteLog(' ReadParamSettings ������ : '+E.Message+' / '+E.ClassName);
 end;
end;

procedure TMainF.WriteParamSettings;
var
setIni:TMemIniFile;
begin
try
   PortConsole:=strtoint(EditConsolePort.Text);
   PswdConsole:=EditConsolePswd.Text;
   LoginConsole:=EditConsoleLogin.Text;
   PswdServerViewer:=EditRuViewerPswd.Text;
   PortServerViewer:=strtoint(EditRuViewerPort.Text);
   PrefixServer:=EditRuViewerPrefix.Text;
   PswdServerClaster:=EditPswdClaster.Text;
   PortServerClaster:=strtoint(EditPortServerClaster.Text);
   SrvIpExternal:=EditIPExternalClaster.Text;
   MaxNumInConnect:=strtoint(EditMaxNumInConnect.Text);
   PrefixLifeTime:=strtoint(EditPrefixLifeTime.Text);
   LiveTimeBlackList:=strtoint(EditLiveTimeBlackList.Text);
   NumOccurentc:=strtoint(EditNumOccurentc.Text);
   TimeOutReconnect:=strtoint(EditTimeOutReconnect.Text);
   SendListServers:=CBSendListServers.Checked;
   GetListServers:=CBGetListServers.Checked;
   AddIpBlackListClaster:=CBBlackListClaster.Checked;
   AutoRunSrvRuViewer:=CBAutoRunSrvRuViewer.Checked;
   AutoRunSrvClaster:=CBAutoRunSrvClaster.Checked;

    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
      try
      setIni.WriteInteger('Console','port',PortConsole);
      setIni.WriteString('Console','pswd',PswdConsole);
      setIni.WriteString('Console','Login',LoginConsole);

      setIni.WriteInteger('Viewer','port',PortServerViewer); //���� ������� ��������
      setIni.WriteString('Viewer','pswd',PswdServerViewer); // ������ ������� ��������
      setIni.WriteString('Viewer','interface',SrvIpExternal);  // ������� ip ����� ��� ����������� �������� RuViewer
      setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer ������� �������
      setIni.WriteInteger('claster','port',PortServerClaster); // ���� ������� ��� �������������
      setIni.WriteString('claster','pswd',PswdServerClaster); // ������ ������� ��� �������������
      setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // ������������ ���-�� �������� ����������� ��� ������������
      setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime); // ������������ ����� ����� �������� ���� �� �� ���������� ����������� ��������
      setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //�������� ��� ��� ������ ������ ��� �������������
      setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // ���������� �������� ���������� �� ��������� � ������ ������
      setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      setIni.WriteBool('claster','SendListServers',SendListServers); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','GetListServers',GetListServers);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster); // ����� ������� �������� ��� ������� ������
      setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // ����� ������� RuViewer ��� ������� ������
      finally
      setIni.UpdateFile;
      setIni.Free;
      end;
 except
 on E : Exception do WriteLog(' WriteParamSettings ������ : '+E.Message+' / '+E.ClassName);
 end;
end;


Function TMainF.ReadParamFromString(StrParam:string):boolean;  // ������ ���������� ���������� � ������� ����� �����
var
i:integer;
setIni:TMemIniFile;
TmpList:TstringList;
begin
  try
  setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'settmp.dat');
  TmpList:=TstringList.Create;
    try
    TmpList.CommaText:=StrParam;
    setIni.SetStrings(TmpList); // ��������� ������ � ����
    PortConsole:=setIni.ReadInteger('Console','port',0);  // ���� ��� �����������������
    PswdConsole:=setIni.ReadString('Console','pswd','');// ������ ��� ����������� �������
    LoginConsole:=setIni.ReadString('Console','Login',''); // ������������, ��� ����������� �������
    PswdServerViewer:=setIni.ReadString('Viewer','pswd','');
    PortServerViewer:= setIni.ReadInteger('Viewer','port',0);
    PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer ������� �������
    SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // ������� ip ����� ��� ����������� �������� RuViewer
    PortServerClaster:=setIni.ReadInteger('claster','port',0);
    PswdServerClaster:=setIni.ReadString('claster','pswd','');
    MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',0); // ������������ ���������� ����������� �������� ����������� � ��������
    PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',0);  // ������� ������ � ������ ��������� ���� ��� �� ����������� ... �����
    LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',0); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
    NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',0);  // ���������� �������� ���������� �� ��������� � ������ ������
    TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',0);  //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
    SendListServers:=setIni.ReadBool('claster','SendListServers',true); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
    GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
    AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // ���������/��������� ������ ������
    AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',false); // ����� ������� �������� ��� ������� ������
    AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',false); // ����� ������� RuViewer ��� ������� ������

    EditConsolePort.Text:=inttostr(PortConsole);
    EditConsolePswd.Text:=PswdConsole;
    EditConsoleLogin.Text:=LoginConsole;
    EditRuViewerPswd.Text:=PswdServerViewer;
    EditRuViewerPort.Text:=inttostr(PortServerViewer);
    EditRuViewerPrefix.Text:=PrefixServer;
    EditPswdClaster.Text:=PswdServerClaster;
    EditPortServerClaster.Text:=inttostr(PortServerClaster);
    EditIPExternalClaster.Text:=SrvIpExternal;
    EditMaxNumInConnect.Text:=inttostr(MaxNumInConnect);
    EditPrefixLifeTime.Text:=inttostr(PrefixLifeTime);
    EditLiveTimeBlackList.Text:=inttostr(LiveTimeBlackList);
    EditNumOccurentc.Text:=inttostr(NumOccurentc);
    EditTimeOutReconnect.Text:=inttostr(TimeOutReconnect);
    CBSendListServers.Checked:=SendListServers;
    CBGetListServers.Checked:=GetListServers;
    CBBlackListClaster.Checked:=AddIpBlackListClaster;
    CBAutoRunSrvRuViewer.Checked:=AutoRunSrvRuViewer;
    CBAutoRunSrvClaster.Checked:=AutoRunSrvClaster;

    result:=true;
    finally
    setIni.Free;
    end;
  except on E : Exception do
  begin
  result:=false;
   WriteLog(' ReadParamFromString ������ : '+E.Message+' / '+E.ClassName);
  end;
   end;
 end;



function TMainF.ParamToIniFileToString:string; // ���������� ���������� � � ������ ��� �������� ����� �����
var
setIni:TMemIniFile;
TmpStrList:TstringList;
begin
try
   PortConsole:=strtoint(EditConsolePort.Text);
   PswdConsole:=EditConsolePswd.Text;
   LoginConsole:=EditConsoleLogin.Text;
   PswdServerViewer:=EditRuViewerPswd.Text;
   PortServerViewer:=strtoint(EditRuViewerPort.Text);
   PrefixServer:=EditRuViewerPrefix.Text;
   PswdServerClaster:=EditPswdClaster.Text;
   PortServerClaster:=strtoint(EditPortServerClaster.Text);
   SrvIpExternal:=EditIPExternalClaster.Text;
   MaxNumInConnect:=strtoint(EditMaxNumInConnect.Text);
   PrefixLifeTime:=strtoint(EditPrefixLifeTime.Text);
   LiveTimeBlackList:=strtoint(EditLiveTimeBlackList.Text);
   NumOccurentc:=strtoint(EditNumOccurentc.Text);
   TimeOutReconnect:=strtoint(EditTimeOutReconnect.Text);
   SendListServers:=CBSendListServers.Checked;
   GetListServers:=CBGetListServers.Checked;
   AddIpBlackListClaster:=CBBlackListClaster.Checked;
   AutoRunSrvRuViewer:=CBAutoRunSrvRuViewer.Checked;
   AutoRunSrvClaster:=CBAutoRunSrvClaster.Checked;

  TmpStrList:=TstringList.Create;
  setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'settmp.dat');
      try
      // ������ � ���� � ������
      setIni.WriteInteger('Console','port',PortConsole);
      setIni.WriteString('Console','pswd',PswdConsole);
      setIni.WriteString('Console','Login',LoginConsole);
      setIni.WriteInteger('Viewer','port',PortServerViewer); //���� ������� ��������
      setIni.WriteString('Viewer','pswd',PswdServerViewer); // ������ ������� ��������
      setIni.WriteString('Viewer','interface',SrvIpExternal);  // ������� ip ����� ��� ����������� �������� RuViewer
      setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer ������� �������
      setIni.WriteInteger('claster','port',PortServerClaster); // ���� ������� ��� �������������
      setIni.WriteString('claster','pswd',PswdServerClaster); // ������ ������� ��� �������������
      setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // ������������ ���-�� �������� ����������� ��� ������������
      setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime); // ������������ ����� ����� �������� ���� �� �� ���������� ����������� ��������
      setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //�������� ��� ��� ������ ������ ��� �������������
      setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // ���������� �������� ���������� �� ��������� � ������ ������
      setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); //��� ����� ����� ������ � ������ ������   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //����� �������� �� ��������� ��������� ��������� ��������� ���������� � ��������
      setIni.WriteBool('claster','SendListServers',SendListServers); // ������� ������� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','GetListServers',GetListServers);   // �������� ����� ������� �������� �������������, ������ �� ������� ��������� �����������
      setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster); // ����� ������� �������� ��� ������� ������
      setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // ����� ������� RuViewer ��� ������� ������

      setIni.GetStrings(TmpStrList); // ��������� � stringlist
      result:=TmpStrList.CommaText;  // �������� � ���������
      finally
      TmpStrList.Free;
      setIni.Free;
      end;

  except
 on E : Exception do WriteLog('ParamToIniFileToString ������ : '+E.Message+' / '+E.ClassName);
 end;
end;



function TMainF.ListServerClasterToString:string;
var
i:integer;
TmpList:TstringList;
begin
try
TmpList:=TstringLIst.Create;
  try
  for I := 0 to LVServerClaster.Items.Count-1 do  //172.16.1.2=3897=8523=;
  begin                                             //ip       port pswd
   TmpList.Add(LVServerClaster.Items[i].SubItems[0]+'='+LVServerClaster.Items[i].SubItems[1]+'='+LVServerClaster.Items[i].SubItems[2]+'=;');
  end;
  result:=TmpList.CommaText;
  finally
  TmpList.Free;
  end;
except on E : Exception do
 WriteLog(E.ClassName+' ListServerClasterToString ������ : '+E.Message);
end;
end;

procedure TMainF.FormCreate(Sender: TObject);
var
buttonSelected:integer;
begin
try
MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId ��� ����������
MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId ��� ����������
MyChainModeId:='native.ECB'; // TCodec.ChainModeId ��� ����������
EncodingCrypt:=Tencoding.Create;
EncodingCrypt:=Tencoding.UTF8; // ��������� ��� ����������
LocalUID:=generateUID; // ���������� ID ��� ���������� ����������

if ReadParamSettings  then // ������ ���������� �� �����, ���� ��� ����� �� ������� �������� �� ��� ��� ����� ������
  begin
  ReadFileServersClaster; //����� ���� �� ������� �������� ��� �������������
  RunConsoleLocal:=true; // ������� ���� ��� ����������� �� �� � ������ ��������
  AddConsoleLocalServer;// ��������� ������ ���������� ������� � ������ ��������
  ConnectSelectedserver;//������������ � ����
  end
  else RunConsoleLocal:=false;
if ExamServicesServerRuViewer('')=1 then // �������� ��������� ������, ���� ������ ���� ������ ����������� ��������. ���� ��������� 1 ������ ������ ���� � ��� �����������
  begin // ����������� ������ ������
   if MessageDlg('������ RuViewerSrvService �� ��������. ���������� ������?',mtCustom, [mbYes,mbNo], 0) = mrYes then
    begin
     RunService('RuViewerSrvService');
    end;
  end;
LoadFileServerToList; // ��������� ������ �������� �� ������������ �����
except on E : Exception do
 WriteLog(E.ClassName+'Load ������ : '+E.Message);
end;
end;


Function TMainF.ConnectServerConsole(SrvIp,SrvLogin,SrvPswd:string;srvPort:integer):boolean;
begin
  try
  ExamServicesServerRuViewer(SrvIp);
  AddressHost:=SrvIp;
  PortSrv:=srvPort;
  LoginSrv:=SrvLogin;
  PassSrv:=SrvPswd;
  ClientSocketMRSD:=TClientSocket.Create(self);
  ClientSocketMRSD.Active:=false;
  ClientSocketMRSD.ClientType:=ctNonBlocking;
  ClientSocketMRSD.Port:=PortSrv;
  ClientSocketMRSD.address:=AddressHost;
  ClientSocketMRSD.OnConnect:= ClientMRSDServerConnect;
  ClientSocketMRSD.OnDisconnect:=ClientMRSDServerDisconnect;
  ClientSocketMRSD.OnRead:=ClientMRSDServerRead;
  ClientSocketMRSD.OnError:= ClientMRSDServerError;
  ClientSocketMRSD.OnConnecting:=ClientMRSDServerConnecting;
  ClientSocketMRSD.Active:=true;
  result:=true;
  except on E : Exception do
     begin
     result:=false;
     WriteLog(' Connect server ������ : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;

procedure TMainF.DisconnectServerConsole;
begin
try
if ClientSocketMRSD.Active then ClientSocketMRSD.Close;
 ClientSocketMRSD.Free;
except on E : Exception do
     begin
     //WriteLog('DisconnectServerConsole ������ : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;


procedure TMainF.PageControl1Change(Sender: TObject); // ������������ ����� ���������
begin
 if PageControl1.ActivePage.TabIndex=0 then SendCryptTex('<|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
 if PageControl1.ActivePage.TabIndex=1 then SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|>');
end;


procedure TMainF.ButDataUpdateClick(Sender: TObject); //��������� ����� � �������
begin
SendCryptTex('<|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
            //<|LISTCLIENT|- ������ �������� RuViewer,
            //<|LISTCLASTER|>- ������ ���������� � ��������� � �������,
            //<|LISTPREFIX|>- ������ ��������� ��������,
            //<|LISTSERVERCLASTER|> - ������ �������� �������� �� ����� ��������
            //<|READFILEPARAM|> - ��������� � ������� ���� � �����������
            //<|STATUSSERVERRUVIEWER|> - ������ ������� RuViewer
            //<|STATUSSERVERCLASTER|> - ������ ������� ��������
end;

procedure TMainF.Button1Click(Sender: TObject); // �������� ������ � �������
begin
 SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|>');
end;



procedure TMainF.ButSaveSettingsClick(Sender: TObject);  // ���������� ��������� �� ������
var
i:integer;
exist,existport:boolean;
buttonSelected : Integer;
begin

//if (RunConsoleLocal)and(AddressHost='127.0.0.1') then WriteParamSettings; //���� ������� �������� �� �� �� �������, ��  ���������� ���������� � ����
SendCryptTex('<|LISTSRVCLASTERNEW|>'+ListServerClasterToString+'<|END|>'); // �������� ������ �������� ��������������
SendCryptTex('<|FILEPARAM|>'+ParamToIniFileToString+'<|PARAMEND|>'); //ParamToIniFileToString ���������� ���������� � ���������� ������� ��� �������� ���������� �� ������
/// ����� �������� ���������, ��������� �� ������ ��� ����������� � ������� �� ������������ �������
// ���� ��������� �� ������ ��� ��� ������ �����������
//PortConsole:=strtoint(EditConsolePort.Text);
//PswdConsole:=EditConsolePswd.Text;
//LoginConsole:=EditConsoleLogin.Text;
//PortSrv:integer; //���� ������������ ��� ����������� ������� � �������
//LoginSrv:string;  //����� ������������ ��� ����������� ������� � �������
//PassSrv:string[255]; //����� ������������ ��� ����������� ������� � �������
exist:=false;
existport:=false;
if EditConsolePswd.Text<>PassSrv then
 begin
 PassSrv:=EditConsolePswd.Text;
 exist:=true;
 end;

if EditConsoleLogin.Text<>LoginSrv then
 begin
 LoginSrv:=EditConsoleLogin.Text;
 exist:=true;
 end;

if strtoint(EditConsolePort.Text)<>PortSrv then
 begin
  PortSrv:=strtoint(EditConsolePort.Text);
  exist:=true;
  existport:=true;
 end;

 if exist then
 begin
   for I := 0 to LVListServer.Items.Count-1 do
  begin
     if LVListServer.items[i].Caption=AddressHost then // ���� ���� � ������ ������������� ������������ IP
      begin
      LVListServer.Selected.SubItems[0]:=inttostr(PortSrv);
      LVListServer.Selected.SubItems[1]:=LoginSrv;
      LVListServer.Selected.SubItems[2]:=PassSrv; // ���������� ����� ������
      end;
  end;
  SaveListServerToFile; // ��������� ������ ���������� �.�. ������� ��������� �� �����������
 end;

 if existport then
  begin
   buttonSelected:=MessageDlg('�� �������� ���� ����������� �������, ����� ��������� �������� � ����'+#10#13
    +' ���������� ���������� ������������ ������� �������. ��������� ������������ ������?'+#10#13+' '
    ,mtCustom, [mbYes,mbCancel], 0);
   if buttonSelected = mrYes then
    begin
     SendCryptTex('<|RESTARTSERVERCONSOLE|>');
    end;
  end;
end;



//----------------------��������� � ������ ������� �������������
procedure TMainF.TimerClasterStatusTimer(Sender: TObject);// ����������� ��� ��������� ��� ������� ������� �������, ����� 21 ��� ������ ����������� ������ ��������� ������� ��� ��������� ������
begin
 inc(TimeoutWaitStatusClasterServer);
 LabelStatusClaster.Caption:='�������� '+inttostr(31-TimeoutWaitStatusClasterServer);
 if TimeoutWaitStatusClasterServer>=31 then
 begin
   if not SendCryptTex('<|STATUSSERVERCLASTER|><|LISTCLASTER|><|LISTPREFIX|>') then // ������ ������� ��������� ������� �������� � ������ ���������� � ��������
    begin
    showmessage('�� ������� ��������� � ��������');
    end;
  TimeoutWaitStatusClasterServer:=0;
  LabelStatusClaster.Caption:='';
  TimerClasterStatus.Enabled:=false;
 end;

end;

procedure TMainF.ButStartClasterClick(Sender: TObject);
begin
 if SendCryptTex('<|STARTCLASTERSERVER|>') then
  begin
  TimeoutWaitStatusClasterServer:=0;
  TimerClasterStatus.Enabled:=true;;
  ButStartClaster.Enabled:=false;
  ButStopClaster.Enabled:=false;
  end;
end;


procedure TMainF.ButStopClasterClick(Sender: TObject);
begin
 if SendCryptTex('<|STOPCLASTERSERVER|>') then
  begin
  TimeoutWaitStatusClasterServer:=0;
  TimerClasterStatus.Enabled:=true;
  ButStartClaster.Enabled:=false;
  ButStopClaster.Enabled:=false;
  end;
end;
//-----------------------------------------------------------------------------------------------------

//--------------------------------������ � ��������� ������� RuViewer
procedure TMainF.TimerRuViewerStatusTimer(Sender: TObject);
begin
 inc(TimeoutWaitStatusRuViewerServer);
 LabelStatusRuViwewer.Caption:='�������� '+inttostr(31-TimeoutWaitStatusRuViewerServer);
 if TimeoutWaitStatusRuViewerServer>=31 then
  begin
   if not SendCryptTex('<|STATUSSERVERRUVIEWER|><|LISTCLIENT|>') then // ������ ������� ��������� ������� �������� � ������ ���������� � ��������
    begin
    showmessage('�� ������� ��������� � ��������');
    end;
  TimeoutWaitStatusRuViewerServer:=0;
  LabelStatusRuViwewer.Caption:='';
  TimerRuViewerStatus.Enabled:=false;
  end;

end;

procedure TMainF.ButStartRuViewerClick(Sender: TObject);
begin
 if SendCryptTex('<|STARTRUVIEWERSERVER|>') then
   begin
   TimeoutWaitStatusRuViewerServer:=0;
   TimerRuViewerStatus.Enabled:=true;
   ButStartRuViewer.Enabled:=false;
   ButStopRuViewer.Enabled:=false;
   end;
end;

procedure TMainF.ButStopRuViewerClick(Sender: TObject);
begin
 if SendCryptTex('<|STOPRUVIEWERSERVER|>') then
   begin
   TimeoutWaitStatusRuViewerServer:=0;
   TimerRuViewerStatus.Enabled:=true;
   ButStopRuViewer.Enabled:=false;
   ButStartRuViewer.Enabled:=false;
   end;
end;

//---------------------------------------------------------------------------------


procedure TMainF.ButStatusServerClick(Sender: TObject); // ������ �������� ��������
begin
 SendCryptTex('<|STATUSSERVERRUVIEWER|>');
 SendCryptTex('<|STATUSSERVERCLASTER|>');
end;

procedure TMainF.ButAddSrvClasterClick(Sender: TObject); // �������� ������ ������ �������� �������� �� ������������ �������
begin
try
CreateFormEditServerClaster(2,'','',0);
except on E : Exception do WriteLog('AddServerClaster ������ : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.N2Click(Sender: TObject);  // �������� ������ ������ �������� �������� �� ������������ �������
begin
try
CreateFormEditServerClaster(2,'','',0);
except on E : Exception do WriteLog('AddServerClaster ������ : '+E.Message+' / '+E.ClassName);
end;
end;



procedure TMainF.ButDelSrvClasterClick(Sender: TObject); // ������� ������ �� ������ �������� �������� �� ������������ �������
var
i:integer;
begin
  try
   if LVServerClaster.SelCount=1 then
    begin
    LVServerClaster.Selected.Delete;
    for I := 0 to LVServerClaster.Items.Count-1 do
     LVServerClaster.Items[i].Caption:=inttostr(i+1);
    end;
  except on E : Exception do WriteLog('DeleteServerClaster ������ : '+E.Message+' / '+E.ClassName);
  end;
end;

procedure TMainF.N4Click(Sender: TObject); // ������� ������ �� ������ �������� �������� �� ������������ �������
var
i:integer;
begin
  try
   if LVServerClaster.SelCount=1 then
     begin
     LVServerClaster.Selected.Delete;
     for I := 0 to LVServerClaster.Items.Count-1 do
     LVServerClaster.Items[i].Caption:=inttostr(i+1);
     end;
  except on E : Exception do WriteLog('DeleteServerClaster ������ : '+E.Message+' / '+E.ClassName);
  end;
end;





procedure TMainF.ButEditSrvClasterClick(Sender: TObject); // ������������� ������ ������ �������� �������� �� ������������ �������
begin
try
 if LVServerClaster.SelCount=1 then
  CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ������ : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.LVListServerDblClick(Sender: TObject); // ������� ���� ��� ����������� � �������
begin
ConnectSelectedserver;
end;

procedure TMainF.N10Click(Sender: TObject); // �����������/���������� � ������� �� ������������ ����
begin
if LVListServer.SelCount=1 then
 begin
   if LVListServer.Selected.ImageIndex=0 then // ���� �������� ������� ���������
   begin
   DisconnectServerConsole; // �����������
   ClearDefault;            // � ������ �����
   end
    else
   if LVListServer.Selected.ImageIndex=2 then  // ���� �������� ������� ��������
   ConnectSelectedserver; // ������������ � ����
 end;
end;

procedure TMainF.N11Click(Sender: TObject); //������ ������������� ��������
begin
 if LVListServer.SelCount=1 then SendCryptTex('<|GETACTIVKEY|>'); //
end;

function CreateNewPassword(EdPswd:TlabeledEdit):boolean;
begin


end;

procedure TMainF.N12Click(Sender: TObject);
begin
if GenNewPswd.ShowModal=mrOk then (PPpassword.PopupComponent as TlabelEdEdit).Text:=GenNewPswd.TextPswd;
end;

procedure TMainF.PPLVListServerPopup(Sender: TObject);
var
i:integer;
begin
if LVListServer.SelCount=1 then
 begin
   if LVListServer.Selected.ImageIndex=0 then    // ���� ��������� ������� ���������
   begin
    for I := 0 to PPLVListServer.Items.Count-1 do
     begin
       if PPLVListServer.Items[i].Caption='����������' then
        PPLVListServer.Items[i].Caption:='���������';
     end;
   end
   else
   if LVListServer.Selected.ImageIndex=2 then   // ���� ��������� ������� ��������
   begin
    for I := 0 to PPLVListServer.Items.Count-1 do
     begin
       if PPLVListServer.Items[i].Caption='���������' then
        PPLVListServer.Items[i].Caption:='����������';
     end;
   end;
 end




end;


procedure TMainF.LVServerClasterDblClick(Sender: TObject); // ������������� ������ ������ �������� �������� �� ������������ �������
begin
try
if LVServerClaster.SelCount=1 then
CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ������ : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.N3Click(Sender: TObject);  // ������������� ������ ������ �������� �������� �� ������������ �������
begin
try
if LVServerClaster.SelCount=1 then
CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ������ : '+E.Message+' / '+E.ClassName);
end;
end;




function TMainF.CreateFormEditServerClaster(typeOperation:byte; srvip,srvpswd:string; srvport:integer):boolean; // �������� ����� ��� ��������������, ����������  ������ �������� �������� �� ������������ �������
var
FrmEdit:Tform;
EditIp,EditPswd,EditPort:TLabelEdEdit;
ButOk,ButCancel:TButton;
begin
try
FrmEdit:=Tform.Create(self);
FrmEdit.Parent:=MainF.Parent;
if typeOperation=1 then FrmEdit.Caption:='�������� �����������';
if typeOperation=2 then FrmEdit.Caption:='������� �����������';
FrmEdit.Width:=250;
FrmEdit.Height:=215;
FrmEdit.BorderStyle:=bsDialog;
FrmEdit.FormStyle:=fsStayOnTop;
FrmEdit.Position:=poOwnerFormCenter;

EditIp:=TLabelEdEdit.Create(FrmEdit);
EditPort:=TLabelEdEdit.Create(FrmEdit);
EditPswd:=TLabelEdEdit.Create(FrmEdit);
ButOk:=Tbutton.Create(FrmEdit);
ButCancel:=Tbutton.Create(FrmEdit);

 try
   with FrmEdit do
   begin
    EditIp.Parent:=FrmEdit;
    EditIp.EditLabel.Caption:='IP ����� �������';
    EditIp.Left:=17;
    EditIp.Top:=20;
    EditIp.Width:=200;
    EditIp.TabOrder:=0;
    EditIp.Text:=srvip;

    EditPort.Parent:=FrmEdit;
    EditPort.EditLabel.Caption:='TCP ����';
    EditPort.Left:=17;
    EditPort.Top:=65;
    EditPort.Width:=200;
    EditPort.NumbersOnly:=true;
    EditPort.TabOrder:=1;
    EditPort.Text:=inttostr(srvport);

    EditPswd.Parent:=FrmEdit;
    EditPswd.EditLabel.Caption:='������ �������';
    EditPswd.Left:=17;
    EditPswd.Top:=110;
    EditPswd.Width:=200;
    EditPswd.TabOrder:=2;
    EditPswd.Text:=srvpswd;

    ButOk.Parent:=FrmEdit;
    ButOk.Caption:='���������';
    ButOk.Left:=143;
    ButOk.Top:=140;
    ButOk.ModalResult:=mrOk;
    ButOk.TabOrder:=3;


    ButCancel.Parent:=FrmEdit;
    ButCancel.Caption:='������';
    ButCancel.Left:=17;
    ButCancel.Top:=140;
    ButCancel.ModalResult:= mrCancel;
    ButCancel.TabOrder:=4;

    if showmodal=ID_OK then
        begin
          if typeOperation=1 then // �������������
          begin
          LVServerClaster.Selected.SubItems[0]:=EditIp.Text;
          LVServerClaster.Selected.SubItems[1]:=EditPort.Text;
          LVServerClaster.Selected.SubItems[2]:=EditPswd.Text;
          end;
          if typeOperation=2 then  // �������� �����
           begin
            with LVServerClaster.Items.Add do
            begin
             caption:=inttostr(LVServerClaster.Items.Count);
             SubItems.add(EditIp.Text);
             SubItems.add(EditPort.Text);
             SubItems.add(EditPswd.Text);
            end;
           end;
        end;
   end;
 finally
 EditIp.Free;
 EditPort.Free;
 EditPswd.Free;
 ButOk.Free;
 ButCancel.Free;
 FrmEdit.Free;
 end;
 result:=true;
except on E : Exception do
     begin
     result:=false;
     WriteLog('FormEditServerClaster ������ : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;

//--------------------------------------------------------------------------------------------
procedure TMainF.ButAddSrvClick(Sender: TObject); // �������� ������ � ������ ����������

begin
CreateFormEditAddServer(2,'','','',0);
end;

procedure TMainF.N5Click(Sender: TObject); // �������� ������ � ������ ����������
begin
CreateFormEditAddServer(2,'','','',0);
end;

procedure TMainF.N6Click(Sender: TObject);  // ������� ������ �� ������ �����������
begin
  try
   if LVListServer.SelCount=1 then
    begin
    if MessageDlg('������� ������?',mtConfirmation,[mbYes,mbCancel], 0)=mrYes then
    LVListServer.Selected.Delete;
    end;
  except on E : Exception do WriteLog('DeleteServer ������ : '+E.Message+' / '+E.ClassName);
  end;
end;



procedure TMainF.ButDelServerClick(Sender: TObject);  // ������� ������ �� ������ �����������
begin
  try
   if LVListServer.SelCount=1 then
    begin
    LVListServer.Selected.Delete;
    end;
  except on E : Exception do WriteLog('DeleteServer ������ : '+E.Message+' / '+E.ClassName);
  end;
end;

procedure TMainF.ButEditServerClick(Sender: TObject); // ������������� ��������� ������ �� ������ �����������
begin
if LVListServer.SelCount=1 then
CreateFormEditAddServer(1,LVListServer.Selected.Caption,
                          LVListServer.Selected.SubItems[1],
                          LVListServer.Selected.SubItems[2],
                          strtoint(LVListServer.Selected.SubItems[0]));
end;

procedure TMainF.N7Click(Sender: TObject); // ������������� ��������� ������ �� ������ �����������
begin
if LVListServer.SelCount=1 then
CreateFormEditAddServer(1,LVListServer.Selected.Caption,
                          LVListServer.Selected.SubItems[1],
                          LVListServer.Selected.SubItems[2],
                          strtoint(LVListServer.Selected.SubItems[0]));
end;



procedure TMainF.ConnectSelectedserver;  //������������ ����������� � ���������� �������
begin
  if LVListServer.SelCount=1 then
    begin
     if LVListServer.Selected.Caption<>'' then
      begin
      ClearDefault;// ������ ������
      ExamServicesServerRuViewer(LVListServer.Selected.Caption); // ������������ ��� ������������� ����� ������, �� ���� ��� ��������
      if Assigned(ClientSocketMRSD) then  // ���� ����������� �������
        begin
        if ClientSocketMRSD.Active then  // ���� ��� �������
          begin
            if (AddressHost=LVListServer.Selected.Caption) then //���� ��� ���������� � ������� ��������
             begin // ���������� ������ �� ��������� ������
              SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|><|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
             end
             else  // ����� ����������� � ������� �������
             begin
             SendCryptTex('<|DISCONNECT|>');
             DisconnectServerConsole;
             with LVListServer.Selected do ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
             end;
          end
          else // ����� ����������� �� �������, ������� ��� � ������� ��������
          begin
           SendCryptTex('<|DISCONNECT|>');
           DisconnectServerConsole;
           with LVListServer.Selected do
           ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
          end;
        end
        else // ����� ����������� �� ������� ������, �������
         with LVListServer.Selected do ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
      end;
  end;
end;





procedure TMainF.N1Click(Sender: TObject); // ���������� ���������� ������ �������� �������������
var
TmpID:integer;
begin
  try
    if LVServer.SelCount=1 then
    begin
      if TryStrToint(LVServer.Selected.SubItems[5],TmpID) then SendCryptTex('<|CLOSECONNECT|>'+inttostr(TmpID)+'<|END|>');
    end;
  except on E : Exception do
    WriteLog('������ ���������� ���������� ������� � �������� : '+E.ClassName+': '+E.Message);  end;
end;



procedure TMainF.SaveListServerToFile;
var
i:integer;
TmpList:TstringList;
CryptText:string;
Encoding :TUTF8Encoding;
begin
  Encoding := TUTF8Encoding.Create;
  TmpList:=TstringList.Create;
  try
  for I := 0 to LVListServer.Items.Count-1 do
    begin
      with LVListServer.Items[i] do
      begin

      TmpList.Add(caption+'<|>'+subitems[0]+'<|>'+subitems[1]+'<|>'+subitems[2]+'<|>')
      end;
    end;
  if Encryptstrs(TmpList.CommaText,LocalUID,CryptText) then TmpList.CommaText:=CryptText;
  TmpList.SaveToFile(ExtractFilePath(Application.ExeName)+'Console.dat',Encoding)
  finally
  TmpList.Free;
  end;
end;

procedure TMainF.LoadFileServerToList;
var
i:integer;
TmpList:TstringList;
DecryptText:string;
Encoding :TUTF8Encoding;
TmpIP,TmpLogin,TmpPswd:string;
Tmpport:integer;
  function SeparationIpPortLoginPswd(var SrvIP,SrvLogin,SrvPswd:string ; var SrvPort:integer; SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
  begin                                          //172.16.1.2<|>3899<|>LgnAdmin<|>1236<|>
  try                                            //  IP         port    login     pswd
  SrvIP:=copy(SepStr,1,pos('<|>',SepStr)-1);
  Delete(SepStr,1,pos('<|>',SepStr)+2);

  if not trystrtoint(copy(SepStr,1,pos('<|>',SepStr)-1),SrvPort) then SrvPort:=0;
  Delete(SepStr,1,pos('<|>',SepStr)+2);

  SrvLogin:=copy(SepStr,1,pos('<|>',SepStr)-1);
  Delete(SepStr,1,pos('<|>',SepStr)+2);

  SrvPswd:=copy(SepStr,1,pos('<|>',SepStr)-1);
  SepStr:='';
  except on E : Exception do
  WriteLog('������ �������� ���������� �����������  : '+E.ClassName+': '+E.Message);  end;
  end;

begin
  Encoding := TUTF8Encoding.Create;
  TmpList:=TstringList.Create;
  try
  if FileExists(ExtractFilePath(Application.ExeName)+ 'Console.dat') then // ���� ���� ����������
    begin
    TmpList.loadFromFile(ExtractFilePath(Application.ExeName)+'Console.dat',Encoding);
    if Decryptstrs(TmpList.CommaText,LocalUID,DecryptText) then TmpList.CommaText:=DecryptText;

    LVListServer.Clear;
    for I := 0 to TmpList.Count-1 do
      begin
       //memo1.Lines.Add(TmpList[i]);
       SeparationIpPortLoginPswd(TmpIP,TmpLogin,TmpPswd,Tmpport,TmpList[i]);
        with LVListServer.Items.Add do
        begin
        imageindex:=2;
        caption:=TmpIP;
        subitems.Add(inttostr(Tmpport));
        subitems.Add(TmpLogin);
        subitems.Add(TmpPswd);
        end;
      end;

    end;

  finally
  TmpList.Free;
  end;
end;


procedure TMainF.N8Click(Sender: TObject);
begin
SaveListServerToFile;
end;

procedure TMainF.N9Click(Sender: TObject);
begin
LoadFileServerToList;
end;

procedure TMainF.ButSaveServerClick(Sender: TObject);
begin
SaveListServerToFile;
end;

procedure TMainF.ButLoadServerClick(Sender: TObject);
begin
LoadFileServerToList;
end;


function TMainF.CreateFormEditAddServer(typeOperation:byte; srvip,srvLogin,srvpswd:string; srvport:integer):boolean; // �������� ����� ��� ��������������, ���������� ������� � �������� ������������
var                                  //typeOperation 1- ������������� 2 -�������� ������
FrmEdit:Tform;
EditIp,EditPswd,EditPort,EditLogin:TLabelEdEdit;
ButOk,ButCancel:TButton;
i:integer;
ExistIp:boolean;
begin
try
FrmEdit:=Tform.Create(self);
FrmEdit.Parent:=MainF.Parent;
if typeOperation=1 then FrmEdit.Caption:='�������� �����������';
if typeOperation=2 then FrmEdit.Caption:='����������� � ������� RuViewer';
FrmEdit.Width:=250;
FrmEdit.Height:=270;
FrmEdit.BorderStyle:=bsDialog;
FrmEdit.FormStyle:=fsStayOnTop;
FrmEdit.Position:=poOwnerFormCenter;

EditIp:=TLabelEdEdit.Create(FrmEdit);
EditLogin:=TLabelEdEdit.Create(FrmEdit);
EditPort:=TLabelEdEdit.Create(FrmEdit);
EditPswd:=TLabelEdEdit.Create(FrmEdit);

ButOk:=Tbutton.Create(FrmEdit);
ButCancel:=Tbutton.Create(FrmEdit);

 try
   with FrmEdit do
   begin
    EditIp.Parent:=FrmEdit;
    EditIp.EditLabel.Caption:='IP ����� �������';
    EditIp.Left:=17;
    EditIp.Top:=20;
    EditIp.Width:=200;
    EditIp.TabOrder:=0;
    EditIp.Text:=srvip;

    EditPort.Parent:=FrmEdit;
    EditPort.EditLabel.Caption:='TCP ����';
    EditPort.Left:=17;
    EditPort.Top:=65;
    EditPort.Width:=200;
    EditPort.NumbersOnly:=true;
    EditPort.TabOrder:=1;
    EditPort.Text:=inttostr(srvport);

    EditLogin.Parent:=FrmEdit;
    EditLogin.EditLabel.Caption:='������������';
    EditLogin.Left:=17;
    EditLogin.Top:=110;
    EditLogin.Width:=200;
    EditLogin.TabOrder:=2;
    EditLogin.Text:=srvLogin;

    EditPswd.Parent:=FrmEdit;
    EditPswd.EditLabel.Caption:='������';
    EditPswd.Left:=17;
    EditPswd.Top:=155;
    EditPswd.Width:=200;
    EditPswd.TabOrder:=3;
    EditPswd.Text:=srvpswd;

    ButOk.Parent:=FrmEdit;
    if typeOperation=1 then ButOk.Caption:='���������';
    if typeOperation=2 then ButOk.Caption:='��������';
    ButOk.Left:=143;
    ButOk.Top:=190;
    ButOk.ModalResult:=mrOk;
    ButOk.TabOrder:=4;


    ButCancel.Parent:=FrmEdit;
    ButCancel.Caption:='������';
    ButCancel.Left:=17;
    ButCancel.Top:=190;
    ButCancel.ModalResult:= mrCancel;
    ButCancel.TabOrder:=5;

    if showmodal=ID_OK then
        begin


          if (typeOperation=1) and (LVListServer.SelCount=1) then // �������������
          begin
           with LVListServer.Selected do
            begin
            caption:=EditIp.Text;
            SubItems[0]:=EditPort.Text;
            SubItems[1]:=EditLogin.Text;
            SubItems[2]:=EditPswd.Text;
            end;
          end;
          if typeOperation=2 then  // �������� �����
           begin
              for I := 0 to LVListServer.Items.Count-1 do
              begin
               if LVListServer.Items[i].Caption=EditIp.Text then
               begin
               ExistIp:=true;
               LVListServer.Items[i].Selected:=true;
               break;
               end
               else ExistIp:=false;
              end;

             if not ExistIp then
              begin
                with LVListServer.Items.Add do
                begin
                 caption:=(EditIp.Text);
                 SubItems.add(EditPort.Text);
                 SubItems.add(EditLogin.Text);
                 SubItems.add(EditPswd.Text);
                 imageindex:=2;
                end;
               end else showmessage('������ ��� ����������');
           end;
        end;
   end;
 finally
 EditIp.Free;
 EditPort.Free;
 EditPswd.Free;
 EditLogin.Free;
 ButOk.Free;
 ButCancel.Free;
 FrmEdit.Free;
 end;
 result:=true;
except on E : Exception do
     begin
     result:=false;
     WriteLog('CreateFormEditAddServer ������ : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;

end.
