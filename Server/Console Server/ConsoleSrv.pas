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
    Function ReadParamSettings:boolean; // чтение параметров из ini файла
    procedure WriteParamSettings; // сохранение параметров в ini файле
    Function ReadParamFromString(StrParam:string):boolean; // чтение параметров полученных с сервера через сокет
    function ParamToIniFileToString:string; // сохранение параметров в (ini фпайле)памяти с последующим сохранением в строку
    function ListServerClasterToString:string;
    procedure SaveListServerToFile; // Сохранить список серверов к которым подключились
    procedure LoadFileServerToList; // Загрузить список серверов к которым подключились
    procedure FormCreate(Sender: TObject);
    function ReadListFilesClaster(ListServer:TstringList; FileName:string):boolean; // читаем файл со списками
    function SeparationIpPortPswd(var SrvIP,SrvPswd:string ; var SrvPort:integer;SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
    function LoadListStrServersClaster(StrLst:string):boolean; // Загружаем строку в ListView с полученным списокм серверов для кластера
    function ReadFileServersClaster:boolean; // чтение файла со списокм серверов для кластера

    function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
    procedure ButDataUpdateClick(Sender: TObject);  //отправка текста запроса
    function LoadListClasterServer(SumS:string):boolean;
    function LoadListClientRuViewer(SumS:string):boolean;
    function LoadListPrefix(SumS:string):boolean; // установка связи с сервером
    function ServiceRunning(sMachine, sService: PChar): DWORD;
    function ServiceGetStatus(sMachine, sService: PChar): DWORD; // проверка состояния службы
    function StopService(ServiceName: string):boolean;
    Function RunService(ServiceName: string):boolean;
    function ExamServicesServerRuViewer(SrvIP:string):byte; //Функция проверки наличия службы на ПК, если она есть то дает возможность управлять её из данной консоли
    Function ConnectServerConsole(SrvIp,SrvLogin,SrvPswd:string;srvPort:integer):boolean;
    function AddConsoleLocalServer:boolean; // добавить в список соединений с серверами локальный адрес если мы нахимся на ПК со службой
    function ClearDefault:boolean; // очистка фармы перед подключением к другому серверу
    procedure UpdateStatusRuViewerServer; // обновление статуса кнопок включени и выключения сервера RuViewer
    procedure UpdateStatusClasterServer; // обновление статуса работы сервера кластеризации
    Procedure ImageStatusConnect(IpAdrs:string;indexImage:byte); // изменение статуса соединения
    procedure ConnectSelectedserver;  //активировать подключение к выбранному серверу
    function OpenFormActivationServer(uid,Key:string;CountPC:integer; DateL:Tdatetime):boolean; // функция заполения и открытия формы лицензирования

    procedure DisconnectServerConsole;
    function CreateFormEditServerClaster(typeOperation:byte; srvip,srvpswd:string; srvport:integer):boolean; // создание формы для редактирования, добавления списка подключаемых серверов
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
  PortSrv:integer; //порт используется для подключения консоли к серверу
  LoginSrv:string;  //логин используется для подключения консоли к серверу
  PassSrv:string[255]; //парль используется для подключения консоли к серверу
  AddressHost:string; //адрес используется для подключения консоли к серверу


  LoginConsole:string; // логин для подключения к серверу из консоли управления используется для настроек
  PswdConsole:string[255]; // пароль для подключения к серверу из консоли управления используется для настроек
  PortConsole:integer; // Порт для подключения к серверу из консоли управления используется для настроек
  MyStreamCipherId:string; //TCodec.StreamCipherId для шифрования
  MyBlockCipherId:string; // TCodec.BlockCipherId для шифрования
  MyChainModeId:string; // TCodec.ChainModeId для шифрования
  EncodingCrypt:TEncoding; // кодировка текста при шифровании и дешифрации
  PswdServerViewer:string; // пароль сервера для подключения клиентов RuViewer
  PswdServerClaster:string; // пароль для подключения к текущему серверу в кластере
  PortServerViewer:integer; // порт сервера для подключения клиентов RuViewer
  PortServerClaster:integer; // порт для подключения к текущему серверу в кластере
  MaxNumInConnect:integer; // максимальное кол-во входящих подключений для клстеризации
  PrefixLifeTime:integer;  // удалять запись в списке префиксов если она не обновлялась ... минут
  NumOccurentc:integer;   // количество повторов блокировки до попадания в черный список
  PrefixServer:string; // текущий префикс сервера
  SrvIpExternal:string; // Внешний IP адрес текущего сервера для подключения клиентов из кластера
  AddIpBlackListClaster:boolean; // выключить черный список
  LiveTimeBlackList:integer; // мин время жизни записи в черном списке   LiveTimeBlackList
  TimeOutReconnect:integer; //время ожидания до повторной установки неудачных исходящих соединений в кластере
  SendListServers:boolean; // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
  GetListServers:boolean; // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
  LocalUID:string; // уникальный ID для ПК
  RunConsoleLocal:boolean; // признак запуска консоли на ПК со службой
  SingRunRuViewerServer:boolean; // статус состояния сервера RuViewer
  SingRunOutConnectClaster:boolean;// признак запушеного потока исходящих соединений кластера
  SingRunInConnectionClaster:boolean; // признак запушеного потока входящих соединений кластера
  TimeoutWaitStatusClasterServer:integer; // время ожидания до запроса статуса сервера кластеризации
  TimeoutWaitStatusRuViewerServer:integer; // время ожидания до запроса статуса сервера кластеризации
  AutoRunSrvClaster:boolean; // старт сервера кластера при запуске службы
  AutoRunSrvRuViewer:Boolean; // старт сервера RuViewer при запуске службы

  UIDServer:string; // uid сервера
  KeyServer:string; // ключ активации сервера
  DateL:Tdatetime;  // дата окончания поддержки
  CountPC:integer;  // количество соединений

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
   // WriteLog('Перед шифрованием и отправкой - '+s);
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
WriteLog(E.ClassName+' SendText ошибка : '+E.Message);
end;
end;
end;

function TMainF.ServiceGetStatus(sMachine, sService: PChar): DWORD; // проверка состояния службы
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

function TMainF.StopService(ServiceName: string):boolean; // остановка службы
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
 WriteLog(E.ClassName+'StartService ошибка : '+E.Message);
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



function TMainF.ExamServicesServerRuViewer(SrvIP:string):byte; //Функция проверки наличия службы на ПК, если она есть то дает возможность управлять её из данной консоли
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
  ButService.Caption:='Reset'; // если службы нет то перезапуск службы по сети
  ButService.Hint:='Перезапустить службу RuViewerSrvService на сервере';
  end;

  Begin
   if (RunServ=1) then //SERVICE_STOPPED
    begin
    ButService.Caption:='Start';
    ButService.Hint:='Запустить службу RuViewerSrvService';
    end;

   if (RunServ=4) then //SERVICE_RUNNING
    begin
    ButService.Caption:='Stop';
    ButService.Hint:='Остановить службу RuViewerSrvService';
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
  ButService.Hint:='Остановить службу RuViewerSrvService';
  end;
exit;
end;

if ButService.Caption='Stop' then
begin
 if StopService('RuViewerSrvService') then
  begin
  ButService.Caption:='Start';
  ButService.Hint:='Запустить службу RuViewerSrvService';
  end;
 exit;
end;

if ButService.Caption='Reset' then SendCryptTex('<|REBOOTSERVICES|>'); //в том случае если консоль запущена не на ПК со службой то отправляем команду на перезапуск службы
end;

function TMainF.ClearDefault:boolean; // очистка фармы перед подключением к другому серверу
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
 CBAutoRunSrvClaster.Checked:=false; // старт сервера кластера при запуске службы
 CBAutoRunSrvRuViewer.Checked:=false; // старт сервера RuViewer при запуске службы
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

function TMainF.AddConsoleLocalServer:boolean; // добавить в список соединений с серверами локальный адрес если мы нахимся на ПК со службой
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
 WriteLog(E.ClassName+' AddConsoleLocalServer ошибка : '+E.Message);
end;
end;

procedure TMainF.UpdateStatusClasterServer; // обновление статуса кнопок включени и выключения сервера кластреа
begin
// SingRunOutConnectClaster:boolean;// признак запушеного потока исходящих соединений кластера
   // SingRunInConnectionClaster:boolean; // признак запушеного потока входящих соединений кластера
 if (SingRunOutConnectClaster) or (SingRunInConnectionClaster) then // если хоть один из статусов истинный то запущен либо входящее либо исходящее подключение в кластере
 begin
 ButStopClaster.Enabled:=true;
 ButStartClaster.Enabled:=false;
 ImageStatusClaster.ImageIndex:=4;
 end
 else
 if (not SingRunOutConnectClaster) and ( not SingRunInConnectionClaster) then // если все false значит кластеризация выключена полностью
 begin
 ButStopClaster.Enabled:=false;
 ButStartClaster.Enabled:=true;
 ImageStatusClaster.ImageIndex:=6;
 end;
end;

procedure TMainF.UpdateStatusRuViewerServer; // обновление статуса кнопок включени и выключения сервера RuViewer
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

Procedure TMainF.ImageStatusConnect(IpAdrs:string;indexImage:byte); // изменение статуса соединения
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
 WriteLog(E.ClassName+'ImageStatusConnect ошибка : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerConnect(Sender: TObject; Socket: TCustomWinSocket);
var
cryptText:string;
begin
try
ImageStatusConnect(socket.RemoteAddress,0);
WriteLog('Соединение с сервером '+socket.RemoteAddress+' установлено');
Encryptstrs('<|ADMSOCKET|>'+PassSrv+'<|>'+LoginSrv+'<|END|>',PassSrv,cryptText);
//WriteLog('отправлено - '+cryptText);
Socket.SendText(cryptText);
except on E : Exception do
WriteLog(E.ClassName+' Connect ошибка : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
try
//WriteLog('Соединение с сервером '+socket.RemoteAddress+' установлено');
ImageStatusConnect(socket.RemoteAddress,1);
except on E : Exception do
WriteLog(E.ClassName+' Connecting ошибка : '+E.Message);
end;
end;


procedure TMainF.ClientMRSDServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
i:integer;
begin
try
ImageStatusConnect(socket.RemoteAddress,2);
WriteLog('Отключение от сервера '+socket.RemoteAddress);
except on E : Exception do
WriteLog(E.ClassName+' Disconnect ошибка : '+E.Message);
end;
end;

procedure TMainF.ClientMRSDServerError(Sender: TObject;   Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
WriteLog('Error Cоединения с сервером ' +socket.RemoteAddress+' : '+ SysErrorMessage(ErrorCode));
ErrorCode:=0;
except on E : Exception do
WriteLog(E.ClassName+'Ошибка подключения : '+E.Message);
end;
end;



function TMainF.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
   while BufS<>'' do // в цикле чистим
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// начало зашифрованной стороки
      posEnd:=pos('<!!>',BufS); // конец зашифрованной стороки
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// копируем необходимую строку начиная с символа posStart+3 ровно posEnd-4 символов
      step:=4;
      Decryptstrs(CryptTmp,PassSrv,DecryptTmp); //дешифровка скопированной строки
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// объединение расшифрованной строки
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
    WriteLog('ERROR  Ошибка дешифрации данных '+ E.ClassName+' / '+ E.Message);
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
      posEnd:=pos('<!>',ItmTmp);// начало зашифрованной стороки
      IpTmp:=copy(ItmTmp,1,posEnd-1);  //IP адрес сервера
      Delete(ItmTmp,1,posEnd+2);
      end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       StatTmp:= copy(ItmTmp,1,posEnd-1); //Статус соединения
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       DTtmp:= copy(ItmTmp,1,posEnd-1);  //дата и время установки соединения
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       InOut:= copy(ItmTmp,1,posEnd-1);  //входящее/исходящее соединение
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then
       begin
       posEnd:=pos('<!>',ItmTmp);
       PrfxTmp:=copy(ItmTmp,1,posEnd-1);  //префикс
       Delete(ItmTmp,1,posEnd+2);
       end;

     if ItmTmp<>'' then  // ID соединения
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
on E : Exception do WriteLog(E.ClassName+' LoadListClasterServer ошибка : '+E.Message);
end;
end;

//286-210-251<!>15.12.2023 13:21:47
//286-213-352<!>15.12.2023 13:21:47
function TmainF.LoadListClientRuViewer(SumS:string):boolean; // загружаем строку сос писокм клиентов RuViewer сервера
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
      posEnd:=pos('<!>',ItmTmp);// начало зашифрованной стороки
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
       DTtmp:=ItmTmp;  //Время
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
on E : Exception do WriteLog(E.ClassName+' LoadListClientRuViewer ошибка : '+E.Message);
end;
end;

function TmainF.LoadListPrefix(SumS:string):boolean; // загружаем список префиксов
var
i:integer;
posEnd:integer;
ItmTmp:string;
DtTmp:TDateTime;
TstrList:TstringList;
function parsingstr(var SDT:TdateTime; var SPrefix:string; StrParse:string):boolean;
  begin // 621-23<|TIME|>и дата
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
       subitems.Add(DateTimeToStr(TTimeZone.local.ToLocalTime(DtTmp))); // время обновления префикса
       end;
    End;
  finally
  TstrList.Free;
  end;
except
on E : Exception do WriteLog(E.ClassName+' LoadListPrefix ошибка : '+E.Message);
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
on E : Exception do WriteLog(E.ClassName+'Show FormActiv ошибка : '+E.Message);
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
  while not CryptText.Contains('<!!>') do // Ожидание конца пакета
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
 Buffer:=DecryptReciveText(CryptText); // дешифрация входящего
 //WriteLog('Консоль получила - '+Buffer);
  position:=pos('<|FIRSTLOAD|>',Buffer); // первая загрузка данных при установке соединения
  if  position>0 then
  begin
  SendCryptTex('<|STATUSACTV|><|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|><|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>'); // запрос списка клиентов, списка соединений кластера, списка префиксов,настройки служб, статусы серверов
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

  position:=pos('<|LISTCLASTER|>',Buffer); // список установленных соединений в кластере
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

  position:=pos('<|LISTPREFIX|>',Buffer); // получили список префиксов
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
   position:=pos('<|LISTSERVERCLASTER|>',Buffer);  // получили от сервера список серверов кластера из файла настроек
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
   position:=pos('<|READFILEPARAM|>',Buffer);  // получили от сервера список из файла настроек
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


    position:=pos('<|STATUSSRVRUVIEWER|>',Buffer);  // получили от сервера статус работы сервера
    if  position>0 then //'<|STATUSSRVRUVIEWER|>'+booltostr(SingRunRuViewerServer)+'<|END|>'
    begin
    BufferTemp:=Buffer;
    delete(BufferTemp,1,position+20);
    TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
    if not trystrtobool(TmpStr,SingRunRuViewerServer) then SingRunRuViewerServer:=false;// SingRunRuViewerServer:boolean; // статус состояния сервера RuViewer
    UpdateStatusRuViewerServer; // обновление статуса кнопок включени и выключения сервера RuViewer
    end;

    position:=pos('<|STATUSSRVCLASTERIN|>',Buffer);  // получили от сервера статус работы сервера
    if  position>0 then  //'<|STATUSSRVCLASTERIN|>'+booltostr(SingRunInConnectionClaster)+'<|END|>'+'<|STATUSSRVCLASTEROUT|>'+booltostr(SingRunOutConnectClaster)+'<|END|>'
      begin
      BufferTemp:=Buffer;
      delete(BufferTemp,1,position+21);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if not trystrtobool(TmpStr,SingRunOutConnectClaster) then SingRunOutConnectClaster:=false; // SingRunOutConnectClaster:boolean;// признак запушеного потока исходящих соединений кластера
      position:=pos('<|STATUSSRVCLASTEROUT|>',BufferTemp);
      delete(BufferTemp,1,position+22);
      TmpStr:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
       if not trystrtobool(TmpStr,SingRunInConnectionClaster) then SingRunInConnectionClaster:=false; // SingRunInConnectionClaster:boolean; // признак запушеного потока входящих соединений кластера
      UpdateStatusClasterServer; // обновление статуса кнопок включени и выключения сервера кластреа
      end;

    position:=pos('<|ACTIVEKEY|>',Buffer);  // получили от сервера данные о лицензии
    if  position>0 then  //<|ACTIVEKEY|>KeyAct<|END|><|UIDACT|>LocalUID<|END|><|COUNTCONNECT|>inttostr(CountConnect)<|END|><|DATEL|>datetostr(DateL)<|END|>
      begin
      {UIDServer:string; // uid сервера
       KeyServer:string; // ключ активации сервера
       DateL:Tdatetime;  // дата окончания поддержки
       CountPC:integer; // кол-во подключений RuViewer}
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

      position:=pos('<|ACTIVEKEYDONE|>',Buffer);  // получили от сервера данные о том что лицуху успешно установили
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

     position:=pos('<|NOACTIVEKEY|>',Buffer);  // получили от сервера ответ о том что лицензия не корректна
     if  position>0 then
      begin
      FormActivation.NoActive;
      end;

     position:=pos('<|NOCORRECTUID|>',Buffer);  // не корректный UID сервера
     if  position>0 then
      begin
      FormActivation.NoCorrectUIDSrv;
      end;

     position:=pos('<|NOACTIVEDATE|>',Buffer);  // не корректная дата ключа активации
     if  position>0 then
      begin
      FormActivation.NoCorrectDate;
      end;

       position:=pos('<|NOTACTIVATED|>',Buffer);  // продукт не активирован
     if  position>0 then
      begin
      SendCryptTex('<|GETACTIVKEY|>'); // запрос статуса лицензии
      end;

      position:=pos('<|NOWRITEKEY|>',Buffer);  // не удалось записать ключ продукта
     if  position>0 then
      begin
      FormActivation.NoWriteKeyAct;
      end;

      position:=pos('<|REBOOTSERVICEDONE|>',Buffer);  // перезапуск службы запущен
     if  position>0 then
      begin
      MainF.ClearDefault;
      end;

     position:=pos('<|READPARAMDONE|>',Buffer);  //сервер схранил и прочитал отправленные настройки
     if  position>0 then
      begin
      MessageDlg('Настройки успешно сохранены', mtInformation,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOTREADPARAM|>',Buffer);  //сервер схранил но не прочитал отправленные настройки
     if  position>0 then
      begin
      MessageDlg('Настройки сохранены, перезапустите службу RuViewerSrvService.', mtInformation,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOTWRITEPARAM|>',Buffer);  //сервер не смог сохранить настройки в файл
     if  position>0 then
      begin
      MessageDlg('Не удалось сохранить настройки, перезапустите службу RuViewerSrvService.', mtError,[mbOk], 0, mbOk);
      end;

     position:=pos('<|NOCORRECTIDCONNECT|>',Buffer);  //сервер не смог сохранить настройки в файл
     if  position>0 then
      begin
      MessageDlg('Не корректный ID подключения.', mtError,[mbOk], 0, mbOk);
      end;

except
on E : Exception do WriteLog(E.ClassName+' ClientMRSDServerRead ошибка : '+E.Message);
end;
end;


function TMainF.ReadListFilesClaster(ListServer:TstringList; FileName:string):boolean; // читаем файл со списками
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
 WriteLog('Ошибка ReadList: '+E.ClassName+': '+E.Message);
end;
end;



function TMainF.SeparationIpPortPswd(var SrvIP,SrvPswd:string ; var SrvPort:integer; SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do
WriteLog('Ошибка парсинга реквизитов подключения  : '+E.ClassName+': '+E.Message);  end;
end;





function TMainF.ReadFileServersClaster:boolean; // чтение файла со списокм серверов для кластера
var                             //172.16.1.2=3897=8523=;
TmpList:TstringList;             // IP       port  pswd
i,SrvPort:integer;
SrvIP,SrvPswd:string;
begin
try
TmpList:=TstringList.Create;
LVServerClaster.Clear;
  try
  if ReadListFilesClaster(TmpList,'SrvClaster.dat') then // если прочитали файл
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
 WriteLog(E.ClassName+' ReadFileServersClaster ошибка : '+E.Message);
end;
end;

function TMainF.LoadListStrServersClaster(StrLst:string):boolean; // Загружаем строку в ListView с полученным списокм серверов для кластера
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
 WriteLog(E.ClassName+' LoadListStrServersClaster ошибка : '+E.Message);
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
      setIni.WriteString('Viewer','interface','');  // внешний ip адрес для подключения клиентов RuViewer
      setIni.WriteString('Viewer','prefix','');    // RuViewer Префикс сервера
      setIni.WriteInteger('claster','port',3897);
      setIni.WriteString('claster','pswd','8523');
      setIni.WriteInteger('claster','MaxNumInConnect',10); // максимальное кол-во входящих подключений для клстеризации
      setIni.WriteInteger('claster','PrefixLifeTime',10); // максимальное время жизни префикса если он не обновлялся родительски сервером
      setIni.WriteBool('claster','BlackList',false); //включать или нет черный список
      setIni.WriteInteger('claster','NumberOfLockRetries',3); // количество повторов блокировки до попадания в черный список
      setIni.WriteInteger('claster','BlackListLifeTime',10); //мин время жизни записи в черном списке   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',5); //время ожидания до повторной установки неудачных исходящих соединений в кластере
      setIni.WriteBool('claster','SendListServers',SendListServers); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','GetListServers',GetListServers);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений

      LoginConsole:='ConsoleAdmin'; // логин для подключения к серверу из консоли управления
      PswdConsole:='9999'; // пароль для подключения к серверу из консоли управления
      PortConsole:=3899; // Порт для подключения к серверу из консоли управления
      PswdServerViewer:='1593'; // пароль сервера для подключения клиентов рувьювер
      PswdServerClaster:='8523';  // пароль для подключения в кластере
      PortServerViewer:=3898; // порт сервера для подключения клиентов  рувьювер
      PortServerClaster:=3897; // порт для кластеризации
      MaxNumInConnect:=10; // максимальное кол-во входящих подключений для клстеризации
      PrefixLifeTime:=10;  // удалять запись в списке префиксов если она не обновлялась ... минут
      PrefixServer:='';  // префикс сервера
      SrvIpExternal:=''; // Внешний IP адрес текущего сервера для подключения клиентов из кластера
      AddIpBlackListClaster:=false; // выключить черный список
      NumOccurentc:=3; // количество повторов для блокировки до попадаия в черный список  черном списке
      LiveTimeBlackList:=10; // мин время жизни записи в черном списке   LiveTimeBlackList
      TimeOutReconnect:=5; //время ожидания до повторной установки неудачных исходящих соединений в кластере
      SendListServers:=true; // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      GetListServers:=true; // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
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
      PortConsole:=setIni.ReadInteger('Console','port',3899);  // Порт для администрирования
      PswdConsole:=setIni.ReadString('Console','pswd','9999');// пароль для подключение консоли
      LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // пользователь, для подключения консоли
      PswdServerViewer:=setIni.ReadString('Viewer','pswd','1593');
      PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
      PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer Префикс сервера
      SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // внешний ip адрес для подключения клиентов RuViewer
      PortServerClaster:=setIni.ReadInteger('claster','port',3897);
      PswdServerClaster:=setIni.ReadString('claster','pswd','8523');
      MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // максимальное количество разрешенных входящих подключений в кластере
      PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // удалять запись в списке префиксов если она не обновлялась ... минут
      LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //мин время жизни записи в черном списке   LiveTimeBlackList
      NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // количество повторов блокировки до попадания в черный список
      TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //время ожидания до повторной установки неудачных исходящих соединений в кластере
      SendListServers:=setIni.ReadBool('claster','SendListServers',true); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
      AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // выключить/выключить черный список
      AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',false); // старт сервера кластера при запуске службы
      AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',false); // старт сервера RuViewer при запуске службы
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
 on E : Exception do WriteLog(' ReadParamSettings ошибка : '+E.Message+' / '+E.ClassName);
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

      setIni.WriteInteger('Viewer','port',PortServerViewer); //порт сервера рувьювер
      setIni.WriteString('Viewer','pswd',PswdServerViewer); // пароль сервера рувьювер
      setIni.WriteString('Viewer','interface',SrvIpExternal);  // внешний ip адрес для подключения клиентов RuViewer
      setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer Префикс сервера
      setIni.WriteInteger('claster','port',PortServerClaster); // порт сервера для кластеризации
      setIni.WriteString('claster','pswd',PswdServerClaster); // пароль сервера для кластеризации
      setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // максимальное кол-во входящих подключений для клстеризации
      setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime); // максимальное время жизни префикса если он не обновлялся родительски сервером
      setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //включать или нет черный список для кластеризации
      setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // количество повторов блокировки до попадания в черный список
      setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); //мин время жизни записи в черном списке   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //время ожидания до повторной установки неудачных исходящих соединений в кластере
      setIni.WriteBool('claster','SendListServers',SendListServers); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','GetListServers',GetListServers);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster); // старт сервера кластера при запуске службы
      setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // старт сервера RuViewer при запуске службы
      finally
      setIni.UpdateFile;
      setIni.Free;
      end;
 except
 on E : Exception do WriteLog(' WriteParamSettings ошибка : '+E.Message+' / '+E.ClassName);
 end;
end;


Function TMainF.ReadParamFromString(StrParam:string):boolean;  // чтение параметров полученных с сервера через сокет
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
    setIni.SetStrings(TmpList); // загружаем строку в файл
    PortConsole:=setIni.ReadInteger('Console','port',0);  // Порт для администрирования
    PswdConsole:=setIni.ReadString('Console','pswd','');// пароль для подключение консоли
    LoginConsole:=setIni.ReadString('Console','Login',''); // пользователь, для подключения консоли
    PswdServerViewer:=setIni.ReadString('Viewer','pswd','');
    PortServerViewer:= setIni.ReadInteger('Viewer','port',0);
    PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer Префикс сервера
    SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // внешний ip адрес для подключения клиентов RuViewer
    PortServerClaster:=setIni.ReadInteger('claster','port',0);
    PswdServerClaster:=setIni.ReadString('claster','pswd','');
    MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',0); // максимальное количество разрешенных входящих подключений в кластере
    PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',0);  // удалять запись в списке префиксов если она не обновлялась ... минут
    LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',0); //мин время жизни записи в черном списке   LiveTimeBlackList
    NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',0);  // количество повторов блокировки до попадания в черный список
    TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',0);  //время ожидания до повторной установки неудачных исходящих соединений в кластере
    SendListServers:=setIni.ReadBool('claster','SendListServers',true); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
    GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
    AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // выключить/выключить черный список
    AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',false); // старт сервера кластера при запуске службы
    AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',false); // старт сервера RuViewer при запуске службы

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
   WriteLog(' ReadParamFromString ошибка : '+E.Message+' / '+E.ClassName);
  end;
   end;
 end;



function TMainF.ParamToIniFileToString:string; // сохранение параметров в в строку для передачи через сокет
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
      // запись в файл в памяти
      setIni.WriteInteger('Console','port',PortConsole);
      setIni.WriteString('Console','pswd',PswdConsole);
      setIni.WriteString('Console','Login',LoginConsole);
      setIni.WriteInteger('Viewer','port',PortServerViewer); //порт сервера рувьювер
      setIni.WriteString('Viewer','pswd',PswdServerViewer); // пароль сервера рувьювер
      setIni.WriteString('Viewer','interface',SrvIpExternal);  // внешний ip адрес для подключения клиентов RuViewer
      setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer Префикс сервера
      setIni.WriteInteger('claster','port',PortServerClaster); // порт сервера для кластеризации
      setIni.WriteString('claster','pswd',PswdServerClaster); // пароль сервера для кластеризации
      setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // максимальное кол-во входящих подключений для клстеризации
      setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime); // максимальное время жизни префикса если он не обновлялся родительски сервером
      setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //включать или нет черный список для кластеризации
      setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // количество повторов блокировки до попадания в черный список
      setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); //мин время жизни записи в черном списке   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //время ожидания до повторной установки неудачных исходящих соединений в кластере
      setIni.WriteBool('claster','SendListServers',SendListServers); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','GetListServers',GetListServers);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster); // старт сервера кластера при запуске службы
      setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // старт сервера RuViewer при запуске службы

      setIni.GetStrings(TmpStrList); // сохраняем в stringlist
      result:=TmpStrList.CommaText;  // передача в результат
      finally
      TmpStrList.Free;
      setIni.Free;
      end;

  except
 on E : Exception do WriteLog('ParamToIniFileToString ошибка : '+E.Message+' / '+E.ClassName);
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
 WriteLog(E.ClassName+' ListServerClasterToString ошибка : '+E.Message);
end;
end;

procedure TMainF.FormCreate(Sender: TObject);
var
buttonSelected:integer;
begin
try
MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId для шифрования
MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId для шифрования
MyChainModeId:='native.ECB'; // TCodec.ChainModeId для шифрования
EncodingCrypt:=Tencoding.Create;
EncodingCrypt:=Tencoding.UTF8; // кодировка для шифрования
LocalUID:=generateUID; // уникальный ID для локального шифрования

if ReadParamSettings  then // чтение параметров из файла, если нет файла то консоль запущена не там где стоит служба
  begin
  ReadFileServersClaster; //читам файл со списком серверов для кластеризации
  RunConsoleLocal:=true; // признак того что запустились на ПК с файлом настроек
  AddConsoleLocalServer;// добавляем запись локального сервера в список серверов
  ConnectSelectedserver;//подключаемся к нему
  end
  else RunConsoleLocal:=false;
if ExamServicesServerRuViewer('')=1 then // проверка состояния службы, если служба есть значит запустились локально. Если результат 1 значит служба есть и она остановлена
  begin // запрашиваем запуск службы
   if MessageDlg('Служба RuViewerSrvService не запущена. Произвести запуск?',mtCustom, [mbYes,mbNo], 0) = mrYes then
    begin
     RunService('RuViewerSrvService');
    end;
  end;
LoadFileServerToList; // загрузить список серверов из сохраненного файла
except on E : Exception do
 WriteLog(E.ClassName+'Load ошибка : '+E.Message);
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
     WriteLog(' Connect server ошибка : '+E.Message+' / '+E.ClassName);
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
     //WriteLog('DisconnectServerConsole ошибка : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;


procedure TMainF.PageControl1Change(Sender: TObject); // Переключение между вкладками
begin
 if PageControl1.ActivePage.TabIndex=0 then SendCryptTex('<|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
 if PageControl1.ActivePage.TabIndex=1 then SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|>');
end;


procedure TMainF.ButDataUpdateClick(Sender: TObject); //получение даных с сервера
begin
SendCryptTex('<|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
            //<|LISTCLIENT|- Список клиентов RuViewer,
            //<|LISTCLASTER|>- список соединений с серверами в кластре,
            //<|LISTPREFIX|>- Список префиксов кластера,
            //<|LISTSERVERCLASTER|> - Список серверов кластера из файла настроек
            //<|READFILEPARAM|> - запросили с сервера файл с настройками
            //<|STATUSSERVERRUVIEWER|> - статус сервера RuViewer
            //<|STATUSSERVERCLASTER|> - статус сервера кластера
end;

procedure TMainF.Button1Click(Sender: TObject); // получить данные с сервера
begin
 SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|>');
end;



procedure TMainF.ButSaveSettingsClick(Sender: TObject);  // отправляем настройки на сервер
var
i:integer;
exist,existport:boolean;
buttonSelected : Integer;
begin

//if (RunConsoleLocal)and(AddressHost='127.0.0.1') then WriteParamSettings; //если консоль запушена на ПК со службой, то  сохранение параметров в файл
SendCryptTex('<|LISTSRVCLASTERNEW|>'+ListServerClasterToString+'<|END|>'); // Отправка списка серверов кластреризации
SendCryptTex('<|FILEPARAM|>'+ParamToIniFileToString+'<|PARAMEND|>'); //ParamToIniFileToString сохранение параметров в переменные истроку для отправки параметров на сервер
/// после отправки проверяем, изменился ли пароль для подключения к консоли на подключенном сервере
// если изменился то меняем его для нашего подключения
//PortConsole:=strtoint(EditConsolePort.Text);
//PswdConsole:=EditConsolePswd.Text;
//LoginConsole:=EditConsoleLogin.Text;
//PortSrv:integer; //порт используется для подключения консоли к серверу
//LoginSrv:string;  //логин используется для подключения консоли к серверу
//PassSrv:string[255]; //парль используется для подключения консоли к серверу
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
     if LVListServer.items[i].Caption=AddressHost then // если итем в списке соответствует подключеному IP
      begin
      LVListServer.Selected.SubItems[0]:=inttostr(PortSrv);
      LVListServer.Selected.SubItems[1]:=LoginSrv;
      LVListServer.Selected.SubItems[2]:=PassSrv; // производим смену пароля
      end;
  end;
  SaveListServerToFile; // сохраняем список подклчений т.к. сменили реквизиты дя подключения
 end;

 if existport then
  begin
   buttonSelected:=MessageDlg('Вы изменили порт подключения консоли, чтобы изменения вступили в силу'+#10#13
    +' необходимо произвести перезагрузку сервера консоли. Выполнить перезагрузку сейчас?'+#10#13+' '
    ,mtCustom, [mbYes,mbCancel], 0);
   if buttonSelected = mrYes then
    begin
     SendCryptTex('<|RESTARTSERVERCONSOLE|>');
    end;
  end;
end;



//----------------------остановка и запуск сервера кластеризации
procedure TMainF.TimerClasterStatusTimer(Sender: TObject);// запускается при остановке или запуске сервера кластра, после 21 сек работы запрашивает статус состояния сервера для включения кнопок
begin
 inc(TimeoutWaitStatusClasterServer);
 LabelStatusClaster.Caption:='Ожидание '+inttostr(31-TimeoutWaitStatusClasterServer);
 if TimeoutWaitStatusClasterServer>=31 then
 begin
   if not SendCryptTex('<|STATUSSERVERCLASTER|><|LISTCLASTER|><|LISTPREFIX|>') then // запрос статуса состояния сервера кластера и списка соединений в кластере
    begin
    showmessage('Не удалось связаться с сервером');
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

//--------------------------------запуск и остановка сервера RuViewer
procedure TMainF.TimerRuViewerStatusTimer(Sender: TObject);
begin
 inc(TimeoutWaitStatusRuViewerServer);
 LabelStatusRuViwewer.Caption:='Ожидание '+inttostr(31-TimeoutWaitStatusRuViewerServer);
 if TimeoutWaitStatusRuViewerServer>=31 then
  begin
   if not SendCryptTex('<|STATUSSERVERRUVIEWER|><|LISTCLIENT|>') then // запрос статуса состояния сервера кластера и списка соединений в кластере
    begin
    showmessage('Не удалось связаться с сервером');
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


procedure TMainF.ButStatusServerClick(Sender: TObject); // запрос статусов серверов
begin
 SendCryptTex('<|STATUSSERVERRUVIEWER|>');
 SendCryptTex('<|STATUSSERVERCLASTER|>');
end;

procedure TMainF.ButAddSrvClasterClick(Sender: TObject); // добавить запись списка серверов кластера на подключенном сервере
begin
try
CreateFormEditServerClaster(2,'','',0);
except on E : Exception do WriteLog('AddServerClaster ошибка : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.N2Click(Sender: TObject);  // добавить запись списка серверов кластера на подключенном сервере
begin
try
CreateFormEditServerClaster(2,'','',0);
except on E : Exception do WriteLog('AddServerClaster ошибка : '+E.Message+' / '+E.ClassName);
end;
end;



procedure TMainF.ButDelSrvClasterClick(Sender: TObject); // Удалить запись из списка серверов кластера на подключенном сервере
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
  except on E : Exception do WriteLog('DeleteServerClaster ошибка : '+E.Message+' / '+E.ClassName);
  end;
end;

procedure TMainF.N4Click(Sender: TObject); // Удалить запись из списка серверов кластера на подключенном сервере
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
  except on E : Exception do WriteLog('DeleteServerClaster ошибка : '+E.Message+' / '+E.ClassName);
  end;
end;





procedure TMainF.ButEditSrvClasterClick(Sender: TObject); // редактировать запись списка серверов кластера на подключенном сервере
begin
try
 if LVServerClaster.SelCount=1 then
  CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ошибка : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.LVListServerDblClick(Sender: TObject); // двойной клик для подключения к серверу
begin
ConnectSelectedserver;
end;

procedure TMainF.N10Click(Sender: TObject); // подключение/отключение к серверу из контекстного меню
begin
if LVListServer.SelCount=1 then
 begin
   if LVListServer.Selected.ImageIndex=0 then // если выбраный сервера подключен
   begin
   DisconnectServerConsole; // отключаемся
   ClearDefault;            // и чистим форму
   end
    else
   if LVListServer.Selected.ImageIndex=2 then  // если выбраный сервера отключен
   ConnectSelectedserver; // подключаемся к нему
 end;
end;

procedure TMainF.N11Click(Sender: TObject); //запрос установленной лицензии
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
   if LVListServer.Selected.ImageIndex=0 then    // если выбраного сервера подключен
   begin
    for I := 0 to PPLVListServer.Items.Count-1 do
     begin
       if PPLVListServer.Items[i].Caption='Подключить' then
        PPLVListServer.Items[i].Caption:='Отключить';
     end;
   end
   else
   if LVListServer.Selected.ImageIndex=2 then   // если выбраного сервера отключен
   begin
    for I := 0 to PPLVListServer.Items.Count-1 do
     begin
       if PPLVListServer.Items[i].Caption='Отключить' then
        PPLVListServer.Items[i].Caption:='Подключить';
     end;
   end;
 end




end;


procedure TMainF.LVServerClasterDblClick(Sender: TObject); // редактировать запись списка серверов кластера на подключенном сервере
begin
try
if LVServerClaster.SelCount=1 then
CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ошибка : '+E.Message+' / '+E.ClassName);
end;
end;

procedure TMainF.N3Click(Sender: TObject);  // редактировать запись списка серверов кластера на подключенном сервере
begin
try
if LVServerClaster.SelCount=1 then
CreateFormEditServerClaster(1,LVServerClaster.Selected.SubItems[0],LVServerClaster.Selected.SubItems[2],strtoint(LVServerClaster.Selected.SubItems[1]));
except on E : Exception do WriteLog('EditServerClaster ошибка : '+E.Message+' / '+E.ClassName);
end;
end;




function TMainF.CreateFormEditServerClaster(typeOperation:byte; srvip,srvpswd:string; srvport:integer):boolean; // создание формы для редактирования, добавления  списка серверов кластера на подключенном сервере
var
FrmEdit:Tform;
EditIp,EditPswd,EditPort:TLabelEdEdit;
ButOk,ButCancel:TButton;
begin
try
FrmEdit:=Tform.Create(self);
FrmEdit.Parent:=MainF.Parent;
if typeOperation=1 then FrmEdit.Caption:='Изменить подключение';
if typeOperation=2 then FrmEdit.Caption:='Добавть подключение';
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
    EditIp.EditLabel.Caption:='IP адрес сервера';
    EditIp.Left:=17;
    EditIp.Top:=20;
    EditIp.Width:=200;
    EditIp.TabOrder:=0;
    EditIp.Text:=srvip;

    EditPort.Parent:=FrmEdit;
    EditPort.EditLabel.Caption:='TCP порт';
    EditPort.Left:=17;
    EditPort.Top:=65;
    EditPort.Width:=200;
    EditPort.NumbersOnly:=true;
    EditPort.TabOrder:=1;
    EditPort.Text:=inttostr(srvport);

    EditPswd.Parent:=FrmEdit;
    EditPswd.EditLabel.Caption:='Пароль сервера';
    EditPswd.Left:=17;
    EditPswd.Top:=110;
    EditPswd.Width:=200;
    EditPswd.TabOrder:=2;
    EditPswd.Text:=srvpswd;

    ButOk.Parent:=FrmEdit;
    ButOk.Caption:='Сохранить';
    ButOk.Left:=143;
    ButOk.Top:=140;
    ButOk.ModalResult:=mrOk;
    ButOk.TabOrder:=3;


    ButCancel.Parent:=FrmEdit;
    ButCancel.Caption:='Отмена';
    ButCancel.Left:=17;
    ButCancel.Top:=140;
    ButCancel.ModalResult:= mrCancel;
    ButCancel.TabOrder:=4;

    if showmodal=ID_OK then
        begin
          if typeOperation=1 then // редактировать
          begin
          LVServerClaster.Selected.SubItems[0]:=EditIp.Text;
          LVServerClaster.Selected.SubItems[1]:=EditPort.Text;
          LVServerClaster.Selected.SubItems[2]:=EditPswd.Text;
          end;
          if typeOperation=2 then  // добавить новый
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
     WriteLog('FormEditServerClaster ошибка : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;

//--------------------------------------------------------------------------------------------
procedure TMainF.ButAddSrvClick(Sender: TObject); // Добавить сервер в список подклчений

begin
CreateFormEditAddServer(2,'','','',0);
end;

procedure TMainF.N5Click(Sender: TObject); // Добавить сервер в список подклчений
begin
CreateFormEditAddServer(2,'','','',0);
end;

procedure TMainF.N6Click(Sender: TObject);  // удалить сервер из списка подключений
begin
  try
   if LVListServer.SelCount=1 then
    begin
    if MessageDlg('Удалить запись?',mtConfirmation,[mbYes,mbCancel], 0)=mrYes then
    LVListServer.Selected.Delete;
    end;
  except on E : Exception do WriteLog('DeleteServer ошибка : '+E.Message+' / '+E.ClassName);
  end;
end;



procedure TMainF.ButDelServerClick(Sender: TObject);  // удалить сервер из списка подключений
begin
  try
   if LVListServer.SelCount=1 then
    begin
    LVListServer.Selected.Delete;
    end;
  except on E : Exception do WriteLog('DeleteServer ошибка : '+E.Message+' / '+E.ClassName);
  end;
end;

procedure TMainF.ButEditServerClick(Sender: TObject); // редактировать выбранный сервер из списка подключений
begin
if LVListServer.SelCount=1 then
CreateFormEditAddServer(1,LVListServer.Selected.Caption,
                          LVListServer.Selected.SubItems[1],
                          LVListServer.Selected.SubItems[2],
                          strtoint(LVListServer.Selected.SubItems[0]));
end;

procedure TMainF.N7Click(Sender: TObject); // редактировать выбранный сервер из списка подключений
begin
if LVListServer.SelCount=1 then
CreateFormEditAddServer(1,LVListServer.Selected.Caption,
                          LVListServer.Selected.SubItems[1],
                          LVListServer.Selected.SubItems[2],
                          strtoint(LVListServer.Selected.SubItems[0]));
end;



procedure TMainF.ConnectSelectedserver;  //активировать подключение к выбранному серверу
begin
  if LVListServer.SelCount=1 then
    begin
     if LVListServer.Selected.Caption<>'' then
      begin
      ClearDefault;// чистим панель
      ExamServicesServerRuViewer(LVListServer.Selected.Caption); // Определяемся как перезапускать будем службу, по сети или локально
      if Assigned(ClientSocketMRSD) then  // если подключение создано
        begin
        if ClientSocketMRSD.Active then  // если оно активно
          begin
            if (AddressHost=LVListServer.Selected.Caption) then //если это соединение с текущим сервером
             begin // отправляем запрос на получение данных
              SendCryptTex('<|LISTCLIENT|><|LISTCLASTER|><|LISTPREFIX|><|LISTSERVERCLASTER|><|READFILEPARAM|><|STATUSSERVERRUVIEWER|><|STATUSSERVERCLASTER|>');
             end
             else  // иначе подключение к другому серверу
             begin
             SendCryptTex('<|DISCONNECT|>');
             DisconnectServerConsole;
             with LVListServer.Selected do ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
             end;
          end
          else // иначе подключение не активно, удаляем его и создаем повторно
          begin
           SendCryptTex('<|DISCONNECT|>');
           DisconnectServerConsole;
           with LVListServer.Selected do
           ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
          end;
        end
        else // иначе подключение не создано вообще, создаем
         with LVListServer.Selected do ConnectServerConsole(Caption,SubItems[1],SubItems[2],strtoint(SubItems[0]));
      end;
  end;
end;





procedure TMainF.N1Click(Sender: TObject); // отключение соединения списка серверов кластеризации
var
TmpID:integer;
begin
  try
    if LVServer.SelCount=1 then
    begin
      if TryStrToint(LVServer.Selected.SubItems[5],TmpID) then SendCryptTex('<|CLOSECONNECT|>'+inttostr(TmpID)+'<|END|>');
    end;
  except on E : Exception do
    WriteLog('Ошибка отключения соединения сервера в кластере : '+E.ClassName+': '+E.Message);  end;
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
  function SeparationIpPortLoginPswd(var SrvIP,SrvLogin,SrvPswd:string ; var SrvPort:integer; SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
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
  WriteLog('Ошибка парсинга реквизитов подключения  : '+E.ClassName+': '+E.Message);  end;
  end;

begin
  Encoding := TUTF8Encoding.Create;
  TmpList:=TstringList.Create;
  try
  if FileExists(ExtractFilePath(Application.ExeName)+ 'Console.dat') then // если файл существует
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


function TMainF.CreateFormEditAddServer(typeOperation:byte; srvip,srvLogin,srvpswd:string; srvport:integer):boolean; // создание формы для редактирования, добавления сервера к которому подключаемся
var                                  //typeOperation 1- редактировать 2 -добавить запись
FrmEdit:Tform;
EditIp,EditPswd,EditPort,EditLogin:TLabelEdEdit;
ButOk,ButCancel:TButton;
i:integer;
ExistIp:boolean;
begin
try
FrmEdit:=Tform.Create(self);
FrmEdit.Parent:=MainF.Parent;
if typeOperation=1 then FrmEdit.Caption:='Изменить подключение';
if typeOperation=2 then FrmEdit.Caption:='Подключение к серверу RuViewer';
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
    EditIp.EditLabel.Caption:='IP адрес сервера';
    EditIp.Left:=17;
    EditIp.Top:=20;
    EditIp.Width:=200;
    EditIp.TabOrder:=0;
    EditIp.Text:=srvip;

    EditPort.Parent:=FrmEdit;
    EditPort.EditLabel.Caption:='TCP порт';
    EditPort.Left:=17;
    EditPort.Top:=65;
    EditPort.Width:=200;
    EditPort.NumbersOnly:=true;
    EditPort.TabOrder:=1;
    EditPort.Text:=inttostr(srvport);

    EditLogin.Parent:=FrmEdit;
    EditLogin.EditLabel.Caption:='Пользователь';
    EditLogin.Left:=17;
    EditLogin.Top:=110;
    EditLogin.Width:=200;
    EditLogin.TabOrder:=2;
    EditLogin.Text:=srvLogin;

    EditPswd.Parent:=FrmEdit;
    EditPswd.EditLabel.Caption:='Пароль';
    EditPswd.Left:=17;
    EditPswd.Top:=155;
    EditPswd.Width:=200;
    EditPswd.TabOrder:=3;
    EditPswd.Text:=srvpswd;

    ButOk.Parent:=FrmEdit;
    if typeOperation=1 then ButOk.Caption:='Сохранить';
    if typeOperation=2 then ButOk.Caption:='Добавить';
    ButOk.Left:=143;
    ButOk.Top:=190;
    ButOk.ModalResult:=mrOk;
    ButOk.TabOrder:=4;


    ButCancel.Parent:=FrmEdit;
    ButCancel.Caption:='Отмена';
    ButCancel.Left:=17;
    ButCancel.Top:=190;
    ButCancel.ModalResult:= mrCancel;
    ButCancel.TabOrder:=5;

    if showmodal=ID_OK then
        begin


          if (typeOperation=1) and (LVListServer.SelCount=1) then // редактировать
          begin
           with LVListServer.Selected do
            begin
            caption:=EditIp.Text;
            SubItems[0]:=EditPort.Text;
            SubItems[1]:=EditLogin.Text;
            SubItems[2]:=EditPswd.Text;
            end;
          end;
          if typeOperation=2 then  // добавить новый
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
               end else showmessage('Запись уже существует');
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
     WriteLog('CreateFormEditAddServer ошибка : '+E.Message+' / '+E.ClassName);
     end;
   end;
end;

end.
