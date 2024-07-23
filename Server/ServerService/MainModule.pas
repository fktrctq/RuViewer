unit MainModule;

interface

uses
  Winapi.Windows,Winapi.WinSock,ShellAPI, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr,
   Vcl.Dialogs,VCL.Forms,Registry,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,inifiles,
    uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants,
    uTPLb_Signatory, uTPLb_SimpleBlockCipher;
type    // структура для подключения клиентов RuViewer
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
    PCUID:String[255]; //UID компьютера
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


type    // структура для входящих/исходящих соединений кластера
 TserverClst = record
   SocketHandle:UIntPtr;
   ServerAddress:string[255];
   ServerPort:integer;
   ServerPassword:string[255];
   PingStart: Int64;
   PingEnd: Int64;
   MyPing:int64;
   PingAnswer:boolean;
   InOutput:byte; // признак исходящего или входящего соединения 1- входящее 2-исходящее 0-соединение не установлено
   IDConnect:byte;  //индекс номера массива
   PrefixUpdate:byte; // 1 - отправить запрос на проверку
   StatusConnect:byte; // статус соединения
   DateTimeStatus:TdateTime; // дата и время установки StatusConnect
   CloseThread:boolean; // признак необходимости завершить поток и закрыть сокет
 end;

Type    // структура для хранения префикса сервера в кластере
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
    procedure Execute; override; // процедура выполнения потока
    function SendMainSock(s:string):boolean;
    function SendTargetSock(s:string):boolean;
    Procedure AddConnect;
    procedure InsertPing;
    function NewCheckIDExists(ID: string): Boolean;  // существует ли данный ID и является ли это соединение активным
    function FindIDinClaster(ID: string; var ServerIP:string; var ServerPort:integer; var SrvPswd:string):boolean; //поиск префикса введенного ID в кластере
    function CorrectID( ID:string):boolean;  // функция проверки корректности ID
    function CorrectPrefixID(ID:string):boolean; // проверка ID на мой префикс
    function GenerateID: string; // генерация ID
    function NewCheckIDPassword(ID, Password: string): Boolean; //соответствие пароля и ID в строке
    function NewFindListItemID(ID: string):TClientMRSD; // передача TClientMRSD  с найденным ID
    function CleanMyConnect(IndexID:integer):boolean; // очистка элемента массива моего подключения
    function CleanTargetConnect(IndexID:integer):boolean; // очистка элемента массива целевого(target) подключения
    function FindConnectID(ID: string):integer; // передача порядкового номера элемента массива соединений  с найденным ID
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
  end;

  //Тип соединения Thread to Define — Desktop.
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



//  Поток для определения типа подключения, если основной, удаленный рабочий стол, загрузка или передача файлов.
type
  TThreadConnection_One = class(TThread)
  private
    defineSocket: TCustomWinSocket;
    IDTemp:string;
  public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override; // процедура выполнения потока // поток обрабатывает запросы клиентов на создание сокетов(подключений)
    function CorrectPrefixID(ID:string):boolean; // проверка ID на мой префикс
    function NewCheckIDExists(ID: string): Boolean;  // существует ли данный ID и является ли это соединение активным
    function AddRecordClient(var NextClient:integer):boolean;  //выдает новому подключенному клиенту индекс записи в массиве подключений
    function CorrectID( ID:string):boolean;  // функция проверки корректности ID
    function GenerateID(): string; // генерация ID
    function FindConnectID(ID: string; var OutIndex:integer):boolean; // передача порядкового номера элемента массива соединений  с найденным ID
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  //таких как - TThreadConnection_Main, TThreadConnection_Desktop, TThreadConnection_Keyboard, TThreadConnection_Files
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
  end;

  // Thread to Define type connection are Main.
  //Тип соединения Thread to Define — это Main.  Основной поток создающий подключения
  // проверка связи с клиентами RuViewer
  type
  ThreadPingClient = class(TThread) // поток для проверки доступности  клиента RuViewer
  private
    TimeoutConnect:cardinal;
    IDConnect:integer;
    TmpID:string;
  public
    constructor Create(aIDConnect:integer); overload;
    procedure Execute; override;
    function Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function SendMainSock(s:string):boolean; // функция отправки через основной сокет
  end;

  //-----поток для управления службой из консоли
  type
  ThReadConsoleManager = class(TThread)
    private
    AdmSocket: TCustomWinSocket;
    public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override; // процедура выполнения потока // поток обрабатывает запросы клиентов на создание сокетов(подключений)
    function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
    function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
    function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
    function SendMainSock(s:string):boolean; // функция отправки через сокет управления
    function ListServerClasterToList:string; // формирует строку со списком серверов кластера
    function ListClientRuViewerToList:string; //строка со списком клиентов RuViewer
    function StatusRuViewerServer:boolean;  // Определение статуса работы сервера RuViewer
    Procedure StopInConnectClaster;  // Остановка потока Входящих соединение кластера
    function RebootServices:boolean;
    Function StopOutConnectClaster:boolean;  // Остановка потока исходящих соединение кластера
    Function StopConnectClaster(ConnectID:integer):boolean;  // Остановка указаного соединения в кластере
    procedure StopServerRuViewerSocket; // Остановка сервера RuViewer
    procedure CleanArrayPrefix; // очистка элементов массива префиксов кластера
    procedure CleanArrayClaster; // очистка элементов массива для подключения серверов в кластере
    procedure CleanArrayRuViewer; // очистка элементов массива подключеных клиентов Ruviewer
    function FindPrefixSrv(ipSrv:string):string; // поиск префикса для сервера в кластере
    function ListPrefixSrv:string; // строка с полным списком префиксов в кластера
    Function ReadFileToString(FileName:string):string; // загружает файл и формирует строку для передачи в сокет
    Function WriteStringToFile(FileName,WriteStr:String):boolean; // запись строки в указанный файл
    function ReadFileSettings:boolean;  // Чтениие настроек из файла
    function ReadRegK(var res:String):boolean; // чтение значений из реестра
    function WriteRegK(KeyAct:string):boolean; // Запись  в реестр
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
    procedure StopServerRuViewerSocket; // остановка сервера RuViewer
    procedure StopServerConsoleSocket; // Остановка сервера консоли управления
    Procedure StopInConnectClaster;  // Остановка потока Входящих соединение кластера
    Procedure StopOutConnectClaster;  // Остановка потока исходящих соединение кластера
    Procedure StartOutConnectClaster;  // Запуск потока исходящих соединение кластера
    Procedure StartInConnectClaster;  // Запуск потока Входящих соединение кластера
    procedure StartServerConsoleSocket; // Запуск сервера консоли управленияя
    procedure StartServerRuViewerSocket; //Запуск сервера RuViewer
    procedure CleanArrayClaster; // очистка элементов массива для подключения серверов в кластере
    procedure CleanArrayPrefix; // очистка элементов массива префиксов кластера
    procedure CleanArrayRuViewer; // очистка элементов массива подключеных клиентов Ruviewer
    function  ReadListServerClaster(ListServer:TstringList; FileName:string):boolean; // читаем файл со списками
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure RegisterErrorLog(nameFile:string;  NumError:integer;  MessageText: string);
    procedure TimerStartServerRuViewerTimer(Sender: TObject);
    procedure TimerStartServerClasterTimer(Sender: TObject); // запись логов
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

  LoginConsole:string; // логин для подключения к серверу из консоли управления
  PswdConsole:string[255]; // пароль для подключения к серверу из консоли управления
  PortConsole:integer; // Порт для администрирования

  ArrayClientClaster: array of TserverClst;// массив записей для подключенных серверов в кластере
  ArrayPrefixSrv: array of TPrefixSrv; // массив записей для хранения префиксов серверов в кластере, не зависимо подклчен он к текущему или нет
  ArrayClientData: array of TClientMRSD; // массив записей для подключенных клиентов RuViewer
  CurentIndexPrefix:integer; // текущий индекс массива префиксов
  CurrentSrvClaster:integer; //индекс текущего входящего подключаемого сервера в кластер
  ListServerClaster:TstringList; // список серверов для кластеризации
  ReciveListServerClaster:TstringList; // список серверов для кластеризации полученный от других серверов
  BlackListServerClaster:TstringList; // черный список входящих клиентов
  AddIpBlackListClaster:boolean; // включить черный список вхоящих подключений в кластере
  SendListServers:boolean; // делится списком адресов серверов кластеризации, только из удачных исходящих подключени
  GetListServers:boolean; // получать списк адресов серверов кластеризации, только из удачных исходящих подключени
  LiveTimeBlackList:integer;    // время жизни записи в черном списке
  TimeOutReconnect:integer; //время ожидания до повторной установки неудачных исходящих соединений в кластере(минуты)
  NumOccurentc:integer; // количество повторов блокировки для попадания в черный список
  PrefixServer:String; // префикс сервера
  SrvIpExternal:String; // Мой текущий внешний интерфейс
  AutoRunSrvClaster:boolean; // старт сервера кластера при запуске службы
  AutoRunSrvRuViewer:Boolean; // старт сервера RuViewer при запуске службы


  LocalUID:string; // локальный ID ПК для шифроваия файлов
  KeyAct:string; // Ключ активации
  CountConnect:integer;// кол-во абонентов
  DateL:TdateTime; // Дата окончания поддержки и обновления
  ActualKey:boolean;  // признак активации продукта

  MyStreamCipherId:string; //TCodec.StreamCipherId для шифрования
  MyBlockCipherId:string; // TCodec.BlockCipherId для шифрования
  MyChainModeId:string; // TCodec.ChainModeId для шифрования
  EncodingCrypt:TEncoding; // кодировка текста при шифровании и дешифрации
  CurrentClient:integer;  //индекс текущего подключенного клиента
  IndexSrvConnect:integer; //индекс подключеной консоли управления
  CurrentClientClaster:integer; ////индекс текущего исходящего подключения к серверу в кластера
  SendLogToConsole:Boolean;
  SingRunOutConnectClaster:boolean; // признак запушеного потока исходящих соединений кластера
  SingRunInConnectionClaster:boolean; // признак запушеного потока входящих соединений кластера
  SingRunRuViewerServer:boolean;     // признак запущенного сервера RuViewer
  LevelLogError:integer; // уровень логирования ошибок
  TimeWaitPackage:integer; //максимальное время ожидания конца пакета секунды
  const
  ProcessingSlack = 2; // Processing slack for Sleep Commands   Обработка резерва для команд сна
  MaxTimeTimeout = 3000;  // время ожидания до закрытия потоков   PingEnd
  MAX_BUF_SIZE = $4095;


implementation
uses DataBase,RunInConnect,RunOutConnect,FunctionPrefixServer,UIDgen,SocketCrypt;
{$R *.dfm}
var
ClasterOutTHread:TThread_FindAndRunConnection;
ClasterInTHread:RunInConnect.TThread_RunInConnect;

//------------------ поток для управления сервером из консоли
constructor ThReadConsoleManager.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  AdmSocket := aSocket;
  FreeOnTerminate := true;
end;

// основной поток для обработки входящих подключений RuViewer. Создает сокеты M, D, K, F.
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
  ArrayClientData[IDConnect].ServerAddress:=aSocket.LocalAddress; // Локальный адрес сервера для кластеризации
  ArrayClientData[IDConnect].ServerPort:=aSocket.LocalPort;     // Локальный порт сервера для кластеризации
  ArrayClientData[IDConnect].PingStart := 0;
  ArrayClientData[IDConnect].PingEnd:= 64;
  ArrayClientData[IDConnect].PingAnswer:=false;
  ArrayClientData[IDConnect].PCUID:=aUID;   // уникальный идентификатор ПК
  ArrayClientData[IDConnect].Password:=aPswd; // пароль либо полученный либо сгенерированный
  ArrayClientData[IDConnect].ID:=aID;         // ID  уже проверен, либо получен либо сгенерирован
  ID:=aID; // ID для логирования
  ArrayClientData[IDConnect].NamePC:=NmPC;     // имя ПК, так чтобы был
  FreeOnTerminate := true;
 except  On E: Exception do
  //Write_Log(ArrayClientData[IDConnect].ClientAddress,'Ошибка создания M потока '+ E.ClassName+' / '+ E.Message);
 end;
end;

constructor TThreadConnection_Desktop.Create(aSocket: TCustomWinSocket; ID: string; aIDConnect:integer);
begin
  inherited Create(False);
  try
  MyID := ID;
  IDConnect:=aIDConnect; // индекс массива подключения занятого до этого момента главным подключнием TThreadConnection_Main
  ArrayClientData[IDConnect].DesktopSocket:=aSocket;
  FreeOnTerminate := true;
  except  On E: Exception do
  //Write_Log(ArrayClientData[IDConnect].ClientAddress,'Ошибка создания D потока '+ E.ClassName+' / '+ E.Message);
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
 // Write_Log(ArrayClientData[IDConnect].ClientAddress,'Ошибка создания F потока '+ E.ClassName+' / '+ E.Message);
  end;
end;

constructor ThreadPingClient.Create(aIDConnect:integer);
begin
  inherited Create(False);
  IDConnect:=aIDConnect;
  FreeOnTerminate := true;
end;






// Get current Version       Получить текущую версию программы
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

procedure TRuViewerSrvService.RegisterErrorLog(nameFile:string; NumError:integer; MessageText: string); // запись логов
var f:TStringList;
i:integer;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
try
if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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
 RegisterErrorLog('RuViewerClientConnect',0,'Подклчючение клиента - ' +Socket.RemoteAddress);
end;

procedure TRuViewerSrvService.Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent:
TErrorEvent; var ErrorCode: Integer);   // запись в лог ошибок
begin
 RegisterErrorLog('RuViewerClientConnect',0,'Ошибка подключения ' + Socket.RemoteAddress+' : '+SysErrorMessage(ErrorCode));
 ErrorCode := 0;
end;

procedure TRuViewerSrvService.Main_ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
 try
 RegisterErrorLog('RuViewerClientConnect',0,'Отключения клиента '+ Socket.RemoteAddress+' от сервера');
 except On E: Exception do
  begin
  RegisterErrorLog('RuViewerClientConnect',2,'Отключение клиента '+E.ClassName+' / '+ E.Message);
  end;
end;
 end;

//----------------------------------------------------------------------------------------------------
{TThreadConnection_Define}
function TThreadConnection_One.FindConnectID(ID: string; var OutIndex:integer):boolean; // передача порядкового номера элемента массива соединений  с найденным ID
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
function TThreadConnection_One.GenerateID(): string; // генерация ID
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
        Exists := true;//ID существует
        break;
      end
      else
        Exists := False;
    end;
   if not(Exists) then // выход из цикла если ID уникальный
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
function TThreadConnection_One.CorrectID( ID:string):boolean;  // функция проверки корректности ID
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

//------------------------выдает новому подключенному клиенту индекс записи в массиве подключений
function TThreadConnection_One.AddRecordClient(var NextClient:integer):boolean;  //выдает новому подключенному клиенту индекс записи в массиве подключений
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
      ArrayClientData[i].ItemBusy:=1; //признак занятости элемента массива, только для данной функции, чтобы другие потоки не заняли данный ID пока не установлено соединение с клиентом
      CurrentClient:=i;
      NextClient:=CurrentClient;
      break;
     end;
  end;
end;
if not exist then //если свободных нет то увеличиваем длинну массива
begin
  if Length(ArrayClientData)>(CountConnect+(CountConnect div 10)) then // если длинна массива подключений больше разрешенной
  begin
  exist:=false;
  end
  else
  begin
  SetLength(ArrayClientData,Length(ArrayClientData)+1);
  CurrentClient:=Length(ArrayClientData)-1;
  ArrayClientData[CurrentClient].ItemBusy:=1; //признак занятости элемента массива, только для данной функции, чтобы другие потоки не заняли данный ID пока не установлено соединение с клиентом
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
 if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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
function TThreadConnection_One.NewCheckIDExists(ID: string): Boolean;  // существует ли данный ID и является ли это соединение активным
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
function TThreadConnection_One.CorrectPrefixID(ID:string):boolean; // проверка ID на мой префикс
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

function TThreadConnection_One.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,PswdServerViewer,DecryptTmp); //дешифровка скопированной строки
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
    Write_Log('RuViewerClientConnect',2,'('+inttostr(step)+') Дешифрация данных ');
     s:='';
    end;
  end;
end;

// поток обрабатывает запросы клиентов на создание сокетов(подключений)
procedure TThreadConnection_One.Execute;
var
  Buffer,DecryptBuf,CryptBufTemp: string;
  CryptBuf:string;
  BufferTemp: string;
  ID: string; //для авторизованного клиента RuViewer
  position: Integer;
  PCName:String;//для авторизованного клиента RuViewer
  PCUID:String; //для авторизованного клиента RuViewer
  ManualPswd :string; //для авторизованного клиента RuViewer
  ThreadMain: TThreadConnection_Main;
  ThreadDesktop: TThreadConnection_Desktop;
  ThreadFiles: TThreadConnection_Files;
  NextClient:integer;
  RecivePswd:string;
  TimeOutTemp:integer;

function SendNoCryptText(s:string):boolean; // отправка не зашифрованного текста
begin
defineSocket.SendText(s); //----------------------->
end;

function SendCryptText(s:string):boolean; // отправка зашифрованного текста
begin
if Encryptstrs(s,PswdServerViewer, CryptBuf) then //шифруем перед отправкой
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
     if TimeOutTemp>1050 then // примерно 10 сек
      begin
      Write_Log('RuViewerClientConnect',1,'Входящее подключение клиента RuViewer '+ defineSocket.RemoteAddress+' закрывавется из-за неактивности');
      defineSocket.Close; // закрываем соединение с клиентом при ожидании более 10 сек
      exit;
      end;
      if (defineSocket = nil) or not(defineSocket.Connected) then break;
      if defineSocket.ReceiveLength < 1 then Continue;
     //PswdServerViewer -- при подклчении использовать пароль сервера для шифрования и расшифровки
      DecryptBuf := defineSocket.ReceiveText;  // установить дешифрацию текста

      while not DecryptBuf.Contains('<!!>') do // Ожидание конца пакета
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
      if position > 0 then // если есть пароль
       begin
        BufferTemp:=Buffer;
        if Pos('<|MID|>', BufferTemp)>0 then // если есть ID
          begin
            Delete(BufferTemp, 1, Pos('<|MID|>', BufferTemp)+ 6);
            RecivePswd:= copy(BufferTemp,1,Pos('<|SRVPSWD|>', BufferTemp)-1);
            BufferTemp:='';
          end;
         if Pos('<|END|>', BufferTemp)>0 then  // если конец строки обнаружен
          begin
            Delete(BufferTemp, 1, Pos('<|END|>', BufferTemp)+ 6);
            RecivePswd:= copy(BufferTemp,1,Pos('<|SRVPSWD|>', BufferTemp)-1);
            BufferTemp:='';
          end;
        position:=0;
       // Write_Log('RuViewerClientConnect','Входящее подключение клиента RuViewer '+ defineSocket.RemoteAddress+' указал пароль -'+RecivePswd+' пароль сервера-'+PswdServerViewer);
       end;
   //---------------------------------------------------------
      if RecivePswd<>PswdServerViewer then
       begin
       Write_Log('RuViewerClientConnect',1,'Входящее подключение клиента RuViewer '+ defineSocket.RemoteAddress+' закрывавется, указан не верный пароль');
       SendCryptText('<|NOCORRECTPSWD|>');//----------------------->
       defineSocket.Close; // закрываем соединение с клиентом
       exit;
       end
      else // иначе полученный пароль верный
      BEGIN
        SendCryptText('<|ACCESSALLOWED|>'); //----------------------->
        position := Pos('<|MAINSOCKET|>', Buffer); // проверяем начало строки . Storing the position in an integer variable will prevent it from having to perform two searches, gaining more performance   Сохранение позиции в целочисленной переменной избавит от необходимости выполнять два поиска, что повышает производительность
         if position > 0 then
         begin  //'<|MAINSOCKET|>'+PCn+'<|NPC|>'+leftstr(PCUID,255)+'<|UID|>'+MyPassword+'<|MPSWD|>'+MyID+'<|MID|>'+TmpPswdServer+'<|SRVPSWD|>'
          PCName:='Unknown';
          ManualPswd:='';
          PCUID:='';
          ID:='';
          BufferTemp:=Buffer;
            try
            if Pos('<|NPC|>', BufferTemp)> 0 then  //имя ПК
                begin
                Delete(BufferTemp, 1, position + 13); // удаляем <|MAINSOCKET|>
                PCName:=copy(BufferTemp,1,Pos('<|NPC|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|NPC|>', BufferTemp)+ 6); // удаляем <|NPC|>
                end;
            if Pos('<|UID|>', BufferTemp)> 0 then    // уникальный идентификатор ПК
                begin
                PCUID:=copy(BufferTemp,1,Pos('<|UID|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|UID|>', BufferTemp )+ 6); //удаляем <|UID|>
                end;
            if Pos('<|MPSWD|>', BufferTemp)> 0 then //Manual пароль, возмложно установлен неконтролируемый доступ
                begin
                ManualPswd:=copy(BufferTemp,1,Pos('<|MPSWD|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|MPSWD|>', BufferTemp )+ 8); //удаляем <|MPSWD|>
                if ManualPswd='' then ManualPswd:=GeneratePassword; // если пароль пустой то генерируем его
                end;
            if Pos('<|MID|>', BufferTemp)> 0 then  // Manual ID, возмложно установлен неконтролируемый доступ
                begin
                ID:=copy(BufferTemp,1,Pos('<|MID|>', BufferTemp)-1) ;
                Delete(BufferTemp, 1, Pos('<|MID|>', BufferTemp )+ 6); //удаляем <|MID|>
                //Write_Log('RuViewerClientConnect',2,'До проверки ID='+ID+' / Pswd='+ManualPswd);
                if not CorrectID(ID) then
                begin
                ID:=''; // если передали некорректнй ID то удаляем его
               // Write_Log('RuViewerClientConnect',2,'NotCorrectID ID='+ID+' / Pswd='+ManualPswd);
                end;
                if ID<>'' then
                    begin
                    if not CorrectPrefixID(ID) then
                     begin
                     ID:=GenerateID; // если не мой префикс то генерируем новый ID
                    // Write_Log('RuViewerClientConnect',2,'Не корректный префикс ID='+ID+' / Pswd='+ManualPswd);
                     end
                    else
                     begin
                      if NewCheckIDExists(ID) then // проверяем есть ли такой ID в списке соеденений,
                      begin
                       ID:=GenerateID;// если есть то генерируем новый
                      // Write_Log('RuViewerClientConnect',2,'ID существует ID='+ID+' / Pswd='+ManualPswd);
                      end;
                     end;
                    end
                   else ID:=GenerateID; // если не передали ID то производим генерацию
                end;
               IDTemp:=ID; //IDTemp для записи логов
              // Write_Log('RuViewerClientConnect',2,'После проверки ID='+ID+' / Pswd='+ManualPswd);
              if AddRecordClient(NextClient) then // получаем ID элемента массива
                begin
                ThreadMain := TThreadConnection_Main.Create(defineSocket,PCName,NextClient,PCUID,ManualPswd,ID) // Создаем сокет для установки соединения с клиентом
                end
               else // иначе количество абонентов превысило допустимое
                begin
                SendCryptText('<|NOFREECONNECT|>');
                Write_Log('RuViewerClientConnect',1,IDTemp+' Отсутствуют свободные подключения для клиентов RuViewer');
                defineSocket.Close; // закрываем соединение с клиентом
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
          IDTemp:=ID; //IDTemp для записи логов
          if FindConnectID(ID,NextClient) then
          ThreadDesktop := TThreadConnection_Desktop.Create(defineSocket, ID,NextClient)
          else
            begin
            SendCryptText('<|NOFINDCONNECT|>');
            Write_Log('RuViewerClientConnect',1,IDTemp+'Сокет (D) Не найден ID для подключения');
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
          IDTemp:=ID; //IDTemp для записи логов
           if FindConnectID(ID,NextClient) then
          ThreadFiles := TThreadConnection_Files.Create(defineSocket, ID,NextClient)
           else
          begin
          SendCryptText('<|NOFINDCONNECT|>');
          Write_Log('RuViewerClientConnect',1,IDTemp+'Сокет (F) Не найден ID для подключения');
          end;
          except On E: Exception do Write_Log('RuViewerClientConnect',2,IDTemp+' One Create socket (F) '{+ E.ClassName+' / '+ E.Message});  end;
          break; // Break the while
        end;
      //----------------------------------------------------------------
      END;// после проверки пароля
      TimeOutTemp:=TimeOutTemp+ProcessingSlack;
     END;// цикл while do
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
 if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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

function ThreadPingClient.SendMainSock(s:string):boolean; // функция отправки через основной сокет
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
        Write_Log(TmpID,2,'Поток P Внешняя функция отправки MainS');
        end;
     end;
   end
      else result:=false;
 end;

procedure ThreadPingClient.Execute;
var
CryptBuf:string;
function SendMainCryptText(s:string):String; // отправка зашифрованного текста в main сокет
  begin
  if Encryptstrs(s,PswdServerViewer, CryptBuf) then //шифруем перед отправкой
  SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
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
       Write_Log(TmpID,2,' (1) Поток Р');
       break;
       end;
     end;
   END;
ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
//Write_Log(TmpID,ipAdrs+' PING ЗАВЕРШЕНИЕ ПОТОКА');
except
 On E: Exception do
  begin
  ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
  Write_Log(TmpID,2,' (2) Поток Р');
  end;
end;
 end;
//---------------------------------------------------------------------------------------------
 { TThreadConnection_Main }
//--------------------------------------------------------------------------------------------

function TThreadConnection_Main.NewFindListItemID(ID: string):TClientMRSD; // передача TClientMRSD  с найденным ID
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
      Write_Log(ID,2,' Поток М NewFindListItemID ');
    end;
  end;
end;

//---------------------------------------------------
function TThreadConnection_Main.FindConnectID(ID: string):integer; // передача порядкового номера элемента массива соединений  с найденным ID
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
      Write_Log(ID,2,' Поток М FindConnectID '{ E.ClassName+' / '+ E.Message});
    end;
  end;
end;

//----------------------------------------------------------
function TThreadConnection_Main.NewCheckIDPassword(ID, Password: string): Boolean; //соответствие пароля и ID в строке
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
      Write_Log(ID,2,'Поток М NewCheckIDPassword ');
    end;
  end;
end;
//-------------------------------------------------
function TThreadConnection_Main.CorrectID( ID:string):boolean;  // функция проверки корректности ID
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
      Write_Log(ID,2,'Поток М CorrectID ');
    end;
  end;
end;
//--------------------------------------------------
function TThreadConnection_Main.FindIDinClaster(ID: string; var ServerIP:string; var ServerPort:integer; var SrvPswd:string):boolean; //поиск префикса введенного ID в кластере
var
  i: Integer;
  targetPrefix:string;
  exist:boolean;
begin
try
exist:=false;
 if CorrectID(ID) then // если ID корректный
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
      Write_Log(ID,2,'Поток М FindIDinClaster');
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
if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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
function TThreadConnection_Main.NewCheckIDExists(ID: string): Boolean;  // существует ли данный ID и является ли это соединение активным
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
      Write_Log(ID,2,'Поток М NewCheckIDExists');
    end;
  end;
end;

//-----------------------------------------------------
// данная процедура относится к главному потоку TThreadConnection_Main
Procedure TThreadConnection_Main.AddConnect;
begin
try
  ArrayClientData[IDConnect].ConnectBusy:=true; // Признак занятия записи в массиве  ArrayClientData
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
      Write_Log(ID,2,'Поток М AddConnect');
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
      Write_Log(ID,2,'Поток М CleanMyConnect ');
    end;
  end;
end;
//-------------------------------------------------------------
function TThreadConnection_Main.GenerateID: string; // генерация ID
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
        Exists := true;//ID существует
        break;
      end
      else
        Exists := False;
    end;
   if not(Exists) then // выход из цикла если ID уникальный
      break;
  end;
  Result := ID;
except On E: Exception do
  begin
  Write_Log(ID,2,'Поток М GenerateID ');
  end;
end;
end;
//-------------------------------------------------
function TThreadConnection_Main.CorrectPrefixID(ID:string):boolean; // проверка ID на мой префикс
begin  //PrefixServer   122-402-808    IDTemp
try
if copy(ID,1,6)=PrefixServer  then result:=true
 else result:=false;
except On E: Exception do
  begin
  Write_Log(ID,2,'Поток М CorrectPrefixID ');
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
      Write_Log(ID,2,'Поток М CleanTargetConnect ');
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
    Write_Log(ID,2,'Поток М ошибка Decryptstrs');
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
  Write_Log(ID,2,'Поток М ошибка Encryptstrs');
  result:=false;
  OutStr:='';
  end;
end;
end;

function TThreadConnection_Main.SendMainSock(s:string):boolean; // функция отправки через основной сокет
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
        Write_Log(ID,2,'Поток М Внешняя функция отправки MainS');
        end;
     end;
   end
      else result:=false;
 end;

 function TThreadConnection_Main.SendTargetSock(s:string):boolean; // функция отправки через target сокет
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
        Write_Log(ID,2,'Поток М Внешняя функция отправки  TargetS  ');
        end;
     end;
   end
      else result:=false;
 end;



//------------------------- Основной поток
procedure TThreadConnection_Main.Execute;
var
  Buffer,CryptBuf,DeCryptBuf,DeCryptRedirect: string;
  BufferTemp,DeCryptBufTemp: string;
  StrTmp:string;
  position: Integer;
  ConnectSRV:Integer; // ID элемента массива к которому подключаемся
  step:integer;
  TargetServerAddress:string;
  TargetServerPort:integer;
  TargetServerPSWD:string;
  pingTh:ThreadPingClient;


function SendMainCryptText(s:string):String; // отправка зашифрованного текста в main сокет
begin
try
if Encryptstrs(s,PswdCryptMain, CryptBuf) then  //шифруем перед отправкой
begin
SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
result:=CryptBuf;
end
else  Write_Log(ID,1,'No Encryptstrs before main send');
  except On E: Exception do
    begin
    s:='';
    Write_Log(ID,2,'Поток М Ошибка шифрования и отправки данных ');
    end;
  end;
end;

function SendTargetCryptText(s:string):String; // отправка зашифрованного текста в TargetMain сокет
begin
try
if Encryptstrs(s,PswdCryptTarget, CryptBuf) then //шифруем перед отправкой
begin
SendTargetSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
result:=CryptBuf;
end
 else Write_Log(ID,1,' No Encryptstrs before target send');
  except On E: Exception do
    begin
    s:='';
    Write_Log(ID,2,'Поток М Ошибка шифрования и отправки данных');
    end;
  end;
end;

function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// копируем необходимую строку
      step:=4;
      Decryptstrs(CryptTmp,PswdCryptMain,DecryptTmp); //дешифровка скопированной строки
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// объединение расшифрованной строки
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
    Write_Log(ID,2,'Поток М Ошибка дешифрации данных ');
    //Write_Log(ID,'ERROR  - ('+inttostr(step)+') Поток М Ошибка дешифрации данных BufS='+BufS+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp );
    BufS:='';
    end;
  end;
end;

  BEGIN
    inherited;
    try
      AddConnect; // добавляем данные в  запись подключения
      step:=1;
      ConnectSRV:=-1; //значит очистили или небыло подключения к какому либо клиенту
      TargetID:='';
      PswdCryptMain:=PswdServerViewer; // присваиваем пароль для шифрования в потоке
      PswdCryptTarget:=PswdServerViewer; // присваиваем пароль для шифрования в потоке
     //SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');// отправляем клиенту его ID и Password
    step:=2;
     // Write_Log(ID,'Главный поток запущен ');

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
              break; // выход из цикла т.к мой сокет закрыт
                except On E: Exception do
                  begin
                  Write_Log(ID,2,' Поток М ('+inttostr(step)+') DISCONNECTED ');
                  end;
                end;
              end;
        step:=7;

            if ArrayClientData[IDConnect].mainSocket.ReceiveLength < 1 then Continue; // переход в начала цикла  если ничего нет


            DeCryptBuf := ArrayClientData[IDConnect].mainSocket.ReceiveText;   //присваиваем данные полученые в главный сокет
            if DeCryptBuf.Contains('<!>') then
            begin
              while not DeCryptBuf.Contains('<!!>') do // ожидание конца пакета
              begin
              if not ArrayClientData[IDConnect].mainSocket.Connected then break;
              Sleep(ProcessingSlack);
              if ArrayClientData[IDConnect].mainSocket.ReceiveLength < 1 then Continue;
              DeCryptBufTemp := ArrayClientData[IDConnect].mainSocket.ReceiveText;
              DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
              end;
            end;
            Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
          //------------------------------------------------------------------------------
             position := Pos('<|RUNPING|>', Buffer); //клиент запросил запуск PING
             if position > 0 then
             begin
             pingTh:=ThreadPingClient.Create(IDConnect); // создаем поток для проверки связи с клиентом
             end;
          //-----------------------------------------------------------------------------
            position := Pos('<|GETMYID|>', Buffer); //клиент запросил его ID и пароль
             if position > 0 then
              begin // отправляем клиенту его ID
              SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');// отправляем клиенту его ID и Password
              end;
          //-------------------------------------------------------------------
           position := Pos('<|SETMYID|>', Buffer); //клиент запросил смену ID <|SETMYID|>...<|ENDID|>
             if position > 0 then
              begin
               BufferTemp := Buffer;
               Delete(BufferTemp, 1, position + 10);
               StrTmp := Copy(BufferTemp, 1, Pos('<|ENDID|>', BufferTemp)-1);
               if StrTmp<>'' then
                 begin
                 if not CorrectPrefixID(StrTmp) then StrTmp:=GenerateID // если не мой префикс то генерируем новый ID
                 else
                 if NewCheckIDExists(StrTmp) then StrTmp:=GenerateID;// проверяем есть ли такой ID в списке соеденений, если есть то генерируем новый
                 end
               else StrTmp:=GenerateID; // если не передали ID то производим генерацию
               ArrayClientData[IDConnect].ID:=StrTmp;
               SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>'); // отправляем клиенту его ID и Password
               BufferTemp:='';
              end;
          //------------------------------------------------------------------------
            position := Pos('<|SETMYPSWD|>', Buffer); //клиент запросил смену пароля <|SETMYPSWD|>...<|ENDPSWD|>
             if position > 0 then
              begin
               BufferTemp := Buffer;
                Delete(BufferTemp, 1, position + 12);
                StrTmp := Copy(BufferTemp, 1, Pos('<|ENDPSWD|>', BufferTemp)-1);
                ArrayClientData[IDConnect].Password:=StrTmp;
                SendMainCryptText('<|ID|>' + ArrayClientData[IDConnect].ID + '<|>' + ArrayClientData[IDConnect].Password + '<|END|>');  // отправляем клиенту его ID и Password
                BufferTemp:='';
              end;
          //----------------------------------------------------------------------------
        step:=8;
            position := Pos('<|FINDID|>', Buffer); //поехали искать ID
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
                if CorrectPrefixID(TargetID) then // если в ID мой префикс
                 Begin
                 if (NewCheckIDExists(TargetID))  then  //если данный TargetID есть в моем списке
                   Begin
                     if (NewFindListItemID(TargetID).TargetID = '') then   //если данный TargetIDID не подклчюен уже к кому либо или кто либо к нему не подключен.... получеам IP сервера куда он подключен
                      begin
                      SendMainCryptText('<|MYIDEXISTS!REQUESTPASSWORD|>'); // отправляем ID существует,
                      end
                     else
                      begin
                      SendMainCryptText('<|ACCESSBUSY|>');  //отправляем ПК занят
                      end
                   End
                  else //иначе если не нашли ID, отправляем что нет нихуя
                    begin
                      SendMainCryptText('<|IDNOTEXISTS|>'); //отправляем ID не существует
                      TargetID:='';
                    end;
                 End
                else  // иначе префикс не моего сервера, ищем в кластере
                 if ActualKey then //если лицензия получена то продолжаем искать по префиксу сервера в кластере
                  Begin
                  if FindIdinClaster(TargetID,TargetServerAddress,TargetServerPort,TargetServerPSWD) then    // ищем по префиксу ID в кластере
                    begin  // если нашли по искомому ID префикс целевого сервера
                     //Write_Log(ID,'MESSAGE - Поток М  FIND ID  '+ '<|SRVIDEXISTS!REQUESTPASSWORD|>'+TargetServerAddress+'<|TSA|>'+inttostr(TargetServerPort)+'<|TSP|>'+TargetServerPSWD+'<TSPSWD>');
                     SendMainCryptText('<|SRVIDEXISTS!REQUESTPASSWORD|>'+TargetServerAddress+'<|TSA|>'+inttostr(TargetServerPort)+'<|TSP|>'+TargetServerPSWD+'<TSPSWD>'); // отправляем ID существует, и подключен к какому серверу запросить пароль
                     TargetID:='';
                     // тут клиент должен подключения к другому серверу
                     end
                    else //иначе если не нашли в кластере, отправляем что нет нихуя
                    begin
                      SendMainCryptText('<|IDNOTEXISTS|>'); //отправляем ID не существует
                      TargetID:='';
                    end;
                  End
                  else //иначе лицензия не установлена, говорим что нет такого ID
                  begin
                   SendMainCryptText('<|IDNOTEXISTS|>'); //отправляем ID не существует
                   TargetID:='';
                  end;

             except On E: Exception do
                  begin
                  Write_Log(ID,2,'Поток М ('+inttostr(step)+') Поиск абонента ');
                  end;
                end;
            end;
         ////////////////////////////////////////////////////////////////////////////
        step:=10;
            if Buffer.Contains('<|PONG|>') then //получили ответ на ping
            begin
              ArrayClientData[IDConnect].PingEnd :=( GetTickCount - ArrayClientData[IDConnect].PingStart) div 2; //GetTickCount Считывает вpемя, пpошедшее с момента запуска системы.
              ArrayClientData[IDConnect].PingAnswer:=false;
              //Synchronize(InsertPing); // вставка timeout в listView
            end;
         ////////////////////////////////////////////////////////////////////////////
        step:=11;
            position := Pos('<|CHECKIDPASSWORD|>', Buffer); //проверка пароля
            if position > 0 then
            begin
            try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, position + 18);
              position := Pos('<|>', BufferTemp);
              TargetID := Copy(BufferTemp, 1, position - 1);  // получили ID для подключения к удаленному ПК
              Delete(BufferTemp, 1, position + 2);
              TargetPassword := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  // получили Iпароль для подключения к удаленному ПК
              if (NewCheckIDPassword(TargetID, TargetPassword)) then  // Проверяем соответствует ли ID и пароль
              begin
                 ConnectSRV:=FindConnectID(TargetID); // Находим к какому соединению нам надо подключится
                   // Связывает основные сокеты
                ArrayClientData[IDConnect].targetMainSocket := ArrayClientData[ConnectSRV].mainSocket;
                ArrayClientData[ConnectSRV].targetMainSocket := ArrayClientData[IDConnect].mainSocket;
                ArrayClientData[IDConnect].TargetID:=TargetID;
                ArrayClientData[IDConnect].TargetPassword:=TargetPassword;
                ArrayClientData[ConnectSRV].TargetID:=ID;
                SendMainCryptText('<|ACCESSGRANTEDMAIN|>');   //отправляем доступ разрешен основные сокеты связаны
              end
              else
              begin
                SendMainCryptText('<|ACCESSDENIED|>');   //отправляем доступ запрещен
                ArrayClientData[IDConnect].TargetID:='';
                ArrayClientData[IDConnect].TargetPassword:='';
                TargetID:='';
                TargetPassword :='';
              end;
                except On E: Exception do
                  begin
                  //while ArrayClientData[IDConnect].mainSocket.SendText('<|ACCESSDENIED|>') < 0 do   //отправляем доступ запрещен
                  //Sleep(ProcessingSlack);
                  //ArrayClientData[IDConnect].TargetID:='';
                  //ArrayClientData[IDConnect].TargetPassword:='';
                 // TargetID:='';
                 // TargetPassword :='';
                  Write_Log(ID,2,'Поток М ('+inttostr(step)+') Идентификация ');
                  end;
                end;
            end;
         step:=12;
         //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if Buffer.Contains('<|BINDDSKTPSOCK|>') then  // клиент сообщил о необходимости связать сокеты рабочего стола
            begin
             try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, pos('<|BINDDSKTPSOCK|>',BufferTemp) + 16);
              position := Pos('<|>', BufferTemp);
              ID := Copy(BufferTemp, 1, position - 1); // находим ID c которого подключаются
              Delete(BufferTemp, 1, position + 2);
              TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  //Целевой ID , куда подключаться
             if (ArrayClientData[IDConnect].TargetID=TargetID) and (ConnectSRV<>-1) then // если до этого указали верный пароль то TargetID и TargetPassword не пустой, значит я подлючаюсь к клиенту
               begin
               // Связывает удаленныйе рабочие столы  ConnectSRV получили при связываании основного сокета
               // ConnectSRV:=FindConnectID(TargetID); // Находим к какому соединению нам надо подключится
               //-----------------------------------------------------------------------------------------
               // обнуление сокетов тоже необходимо для избежания попадания ненужных данных из тарых сокетов
                if ArrayClientData[IDConnect].targetDesktopSocket<>nil then ArrayClientData[IDConnect].targetDesktopSocket:=nil;
                if ArrayClientData[ConnectSRV].targetDesktopSocket<>nil then ArrayClientData[ConnectSRV].targetDesktopSocket:=nil;
               //------------------------------------------------------------------------------------------
                ArrayClientData[IDConnect].targetDesktopSocket := ArrayClientData[ConnectSRV].desktopSocket;
                ArrayClientData[ConnectSRV].targetDesktopSocket := ArrayClientData[IDConnect].desktopSocket;
                SendMainCryptText('<|VIEWACCESSINGDESKTOP|>'); // отправляем своему клиенту инфу о связывании сокетов рабочего стола
                SendTargetCryptText('<|SRVACCESSINGDESKTOP|>'); // отправляем в сокет абоненту инфу о связывании сокетов рабочего стола
               end
                else
               begin
                 SendMainCryptText('<|ACCESSDENIEDDESKTOP|>');   //отправляем доступ запрещен
                 ArrayClientData[ConnectSRV].TargetID:='';
                 ArrayClientData[IDConnect].TargetID:='';
                 ArrayClientData[IDConnect].TargetPassword:='';
                 ArrayClientData[IDConnect].DesktopSocket.Close; // закрываем свой сокет рабочего стола
                 TargetID :='';
               end;
               except On E: Exception do
                  begin
                  // while ArrayClientData[IDConnect].mainSocket.SendText('<|ACCESSDENIEDDESKTOP|>') < 0 do   //отправляем доступ запрещен
                 // Sleep(ProcessingSlack);
                  Write_Log(ID,2,'Поток М ('+inttostr(step)+') Связывание сокетов (D)');
                  end;
                end;
            end;
            step:=13;
         ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         ///  ----------------------------------------------------------------------------
            if Buffer.Contains('<|BINDFILESSOCK|>') then  // клиент сообщил о необходимости связать сокеты для файлов
            begin
             try
              BufferTemp := Buffer;
              Delete(BufferTemp, 1, pos('<|BINDFILESSOCK|>',BufferTemp) + 16);
              position := Pos('<|>', BufferTemp);
              ID := Copy(BufferTemp, 1, position - 1); // находим ID c которого подключаются
              Delete(BufferTemp, 1, position + 2);
              TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);  //Целевой ID , куда подключаться
              if (ArrayClientData[IDConnect].TargetID=TargetID) and (ConnectSRV<>-1) then // если до этого указали верный пароль то TargetID и TargetPassword не пустой, значит я подлючаюсь к клиенту
               begin
               // Связывает файловые сокеты  ConnectSRV получили при связываании основного сокета
              // ConnectSRV:=FindConnectID(TargetID); // Находим к какому соединению нам надо подключится
                 ArrayClientData[IDConnect].targetFilesSocket := ArrayClientData[ConnectSRV].filesSocket;
                 ArrayClientData[ConnectSRV].targetFilesSocket := ArrayClientData[IDConnect].filesSocket;
                 SendMainCryptText('<|VIEWACCESSINGFILES|>');  // отправляем инфу о связывании сокетов для файлов своему клиенту
                 SendTargetCryptText('<|SRVACCESSINGFILES|>');   // отправляем инфу о связывании сокетов для файлов и абоненту
               end
                else
               begin
                 SendMainCryptText('<|ACCESSDENIEDFILES|>');   //отправляем доступ запрещен
                 ArrayClientData[ConnectSRV].TargetID:='';
                 ArrayClientData[IDConnect].TargetID:='';
                 ArrayClientData[IDConnect].TargetPassword:='';
                 ArrayClientData[IDConnect].FilesSocket.Close; // закрываем свой файловый сокет
                 TargetID :='';
               end;
             except On E: Exception do
                  begin
                  Write_Log(ID,2,'Поток М ('+inttostr(step)+') Связывание сокетов (F)');
                  end;
                end;
            end;
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Stop relations
        step:=14;
            if Buffer.Contains('<|STOPACCESS|>') then  // остановка/разрыв связи отправляется при закрытии формы управления
            begin
            try
              SendMainCryptText('<|DISCONNECTED|>');  // клиент отключается
              SendTargetCryptText('<|DISCONNECTED|>'); // абонент отключается
              ArrayClientData[IDConnect].targetMainSocket := nil;
              ArrayClientData[IDConnect].targetDesktopSocket:=nil;
              ArrayClientData[IDConnect].targetFilesSocket:=nil;
              ArrayClientData[IDConnect].TargetPassword:='';
               if ArrayClientData[IDConnect].TargetID<>'' then // если соединение было установлено то TargetID не пустой, очищаем
                begin
                ArrayClientData[IDConnect].TargetID:='';
                ArrayClientData[ConnectSRV].TargetID:='';
                ArrayClientData[ConnectSRV].targetMainSocket := nil;
                ArrayClientData[ConnectSRV].targetDesktopSocket:=nil;
                ArrayClientData[ConnectSRV].targetFilesSocket:=nil;
                end;
              ConnectSRV:=-1; //значит очистили или небыло подключения к какому либо клиенту
              TargetID :='';
            except On E: Exception do
                  begin
                  Write_Log(ID,2,'Поток М ('+inttostr(step)+') STOP ACCESS');
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
        //------------------------------------------------------------ началась хуйня ненужная. с какой целью она сдесь не понятно
        step:=17;
              if (Pos('<|FOLDERLIST|>', BufferTemp) > 0) then // список каталогов  // проверить почему нельзя отправить сразу с клиента на сервер
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

                    DeCryptBuf:= ArrayClientData[IDConnect].mainSocket.ReceiveText;   //присваиваем данные полученые в главный сокет
                    DeCryptRedirect:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                    BufferTemp := BufferTemp + DeCryptRedirect;  // аккумулирование строки
                    if (Pos('<|ENDFOLDERLIST|>', BufferTemp) > 0) then  // конец списка каталогов
                      break;
                   End;
                  except On E: Exception do
                    begin
                    Write_Log(ID,2,'Поток М ('+inttostr(step)+') REDIRECT (1) ');
                    break;
                    end;
                  end;
              end;
        step:=21;
        //---------------------------------------------------------------------
              if (Pos('<|FILESLIST|>', BufferTemp) > 0) then   //список файлов
              begin
        step:=22;
                 try
                  if ArrayClientData[IDConnect].mainSocket<>nil then
                  if ArrayClientData[IDConnect].PingEnd<MaxTimeTimeout then
                  while (ArrayClientData[IDConnect].mainSocket.Connected) do
                   Begin
                   if ArrayClientData[IDConnect].PingEnd>=MaxTimeTimeout then break;
                    Sleep(ProcessingSlack); // Avoids using 100% CPU

                    DeCryptBuf:= ArrayClientData[IDConnect].mainSocket.ReceiveText;   //присваиваем данные полученые в главный сокет
                    DeCryptRedirect:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                    BufferTemp := BufferTemp + DeCryptRedirect;  // аккумулирование строки
                    if (Pos('<|ENDFILESLIST|>', BufferTemp) > 0) then   // конец списка файлов
                      break;
                   End;
                  except On E: Exception do
                    begin
                    Write_Log(ID,2,'Поток М ('+inttostr(step)+') REDIRECT (2)');
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
                SendTargetCryptText(BufferTemp); // передача в target сокет то что клиент передал абоненту
              end;
              except On E: Exception do
                begin
                Write_Log(ID,2,'Поток М ('+inttostr(step)+') REDIRECT (3) ');
                break;
                end;
              end;
        //------------------------------------------------------------------------------------
            end; // end redirect

           except On E: Exception do
            begin
            Write_Log(ID,2,'Поток М ('+inttostr(step)+') Ошибка основного цикла ');
            break;
            end;
           end;
        END; //while
       ////////////////////////////////////////////////////////////////////////////////////////
      step:=27; // вышли из цикла, соединение закрывается. поэтому надо закрыть оставшиеся соединения если они открыты
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
       //Write_Log(ID,'MESSAGE - Поток М ЗАВЕРШЕНИЕ ПОТОКА');
       CleanMyConnect(IDConnect); // очистка элемента массива моего подключения
       if ConnectSRV <>-1 then  //елсли не равно -1 значит было подключения к какому либо клиенту и корректно очистку не произвели
        begin
        CleanTargetConnect(ConnectSRV); // очистка элемента массива целевого подключения
        ConnectSRV:=-1;
        end;
       /////////////////////////////////////////////////////////////////////////////////
      step:=29;
      //Write_Log(ID,'Главный поток завершен ');
      pingTh.Terminate; // признак завершения потока PING
       except
          On E: Exception do
          begin
          CleanMyConnect(IDConnect); // очистка элемента массива моего подключения
           if ConnectSRV <>-1 then  //елсли не равно -1 значит было подключения к какому либо клиенту и корректно очистку не произвели
            begin
            CleanTargetConnect(ConnectSRV);
            ConnectSRV:=-1;
            end;
          pingTh.Terminate; // признак завершения потока PING
          Write_Log(ID,2,'Поток М '+inttostr(step)+') Ошибка основного потока');
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
if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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
    Buffer:='';// очистка необходима. Если у клиента отключился сокет, то сервер передает данные,
                   //эти данне останутся в буфере, при переподключении они прилетят клиенту, а ни нах там не нужны.
  end;
  //Write_Log(ConnectData.ClientAddress+' Desktop','MESSAGE - '+ConnectData.ClientAddress+' ЗАВЕРШЕНИЕ ПОТОКА DESKTOP');
   if ArrayClientData[IDConnect].desktopSocket.Connected then ArrayClientData[IDConnect].desktopSocket.Close;
 except
    On E: Exception do
    begin
    Write_Log(MyID,2, 'ERROR - Поток D ');
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
if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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
    // переправка через буфер
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
                  TemPstringlist.Add(timetostr(now)+' WSAGetLastError()='+inttostr(WSAGetLastError())+' - Размер буфера SizeBuf='+inttostr(sizeOf(Sbuffer))+': Прочитали из буфера ReadBuf='+inttostr(ReadBuf)+' Отправили CurrentWriteBuf='+inttostr(CurrentWriteBuf)+' ');
                  sleep(10);
                  end;
                if not ArrayClientData[IDConnect].filesSocket.Connected then break;

                end;
            //TemPstringlist.Add(timetostr(now)+' - Размер буфера SizeBuf='+inttostr(SizeBuf)+': Прочитали из буфера ReadBuf='+inttostr(ReadBuf)+' Отправили CurrentWriteBuf='+inttostr(CurrentWriteBuf)+' ')
            end;

        end;
     // FreeMem(sBuf);
    except
      On E: Exception do
      begin
      Write_Log (ArrayClientData[IDConnect].ClientAddress,SysErrorMessage(WSAGetLastError));
      Write_Log(ArrayClientData[IDConnect].ClientAddress,'Ошибка в F потоке '+ E.ClassName+' / '+ E.Message);
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
 //Write_Log(ConnectData.ClientAddress+' File','MESSAGE - '+ConnectData.ClientAddress+' ЗАВЕРШЕНИЕ ПОТОКА FILES');

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
    Write_Log(MyID,2,' Поток F ');
    ArrayClientData[IDConnect].PingEnd:=MaxTimeTimeout;
    end;
  end;
 end;

 //////////////////////////////////////////////////////////////////////////////////////////////////////
 {ArrayClientClaster: array of TserverClst;// массив записей для подключенных серверов в кластере
  ArrayPrefixSrv: array of TPrefixSrv; // массив записей для хранения префиксов серверов в кластере, не зависимо подклчен он к текущему или нет
  ArrayClientData: array of TClientMRSD; // массив записей для подключенных клиентов RuViewer
  }
procedure TRuViewerSrvService.CleanArrayClaster; // очистка элементов массива для подключения серверов в кластере
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
procedure TRuViewerSrvService.CleanArrayPrefix; // очистка элементов массива префиксов кластера
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
procedure TRuViewerSrvService.CleanArrayRuViewer; // очистка элементов массива подключеных клиентов Ruviewer
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
Procedure TRuViewerSrvService.StopInConnectClaster;  // Остановка потока Входящих соединение кластера
begin
try
ClasterInTHread.CloseServer;
ClasterInTHread.Terminate;
except on E : Exception do RegisterErrorLog('Service',2,'StopInConnectClaster ');end;
end;
//----------------------------------------------------------------
Procedure TRuViewerSrvService.StopOutConnectClaster;  // Остановка потока исходящих соединение кластера
var
i:integer;
begin
  try
    ClasterOutTHread.Terminate; // завершение потока контролируещего и создающего исходящие подключения
     for I := 0 to length(ArrayClientClaster)-1 do
       begin
        ArrayClientClaster[i].CloseThread:=true; // Установка признака завершения потоков исходящих соединений в кластера
       end;
      try // сохраняем в файл данные для кластеризации
      if ListServerClaster.Count>0 then // если список серверов кластера пустой то и сохранять нечего
      ListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'SrvClaster.dat');
      ListServerClaster.Free;
      ReciveListServerClaster.Free;// удаляем полученный список серверов кластера
      except on E : Exception do RegisterErrorLog('Service',2,'StopOutConnectClaster  Save SrvClaster.dat '); end;
  except on E : Exception do RegisterErrorLog('Service',2,'StopOutConnectClaster ');end;
end;
//------------------------------------------------------------------------------
Procedure TRuViewerSrvService.StartOutConnectClaster;  // Запуск потока исходящих соединение кластера
begin
try
  CurrentSrvClaster:=0; // текущий индекс подключаемого сервера кластера
  CurentIndexPrefix:=0; // Текущий индекс записей префиксов серверов
  ReciveListServerClaster:=Tstringlist.Create; //список серверов в кластере полученный от других серверов
  ListServerClaster:=Tstringlist.Create; //список серверов в кластера к которым подключаемся
  if not ReadListServerClaster(ListServerClaster,'SrvClaster.dat') then   // читаем файл с серверами для кластеризации
    begin
     RegisterErrorLog('Service',1,'Не удалось загрузить файл SrvClaster.dat');
    end
  else
    begin
    if ListServerClaster.Count>0 then // если списк для подключения не пуст то запускаем поток для подключения к серверам кластера
    ClasterOutTHread:=RunOutConnect.TThread_FindAndRunConnection.Create(ListServerClaster);  // исходящие подключения  кластера
    end;
except on E : Exception do RegisterErrorLog('Service',2,'StartOutConnectClaster ' );end;
end;
//-----------------------------------------------------------------------------
Procedure TRuViewerSrvService.StartInConnectClaster;  // Запуск потока входящих соединение кластера
begin
try
  ClasterInTHread:=RunInConnect.TThread_RunInConnect.Create(ListServerClaster);       // входящие подключения кластера
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


procedure TRuViewerSrvService.TimerStartServerClasterTimer(Sender: TObject); // таймер запуска кластеризации
var
setIni:TMemIniFile;
begin
try
 if PrefixServer<>'' then
   begin // проверка префикса на корректность
    if not CorrectPrefix(PrefixServer,SrvIpExternal,PrefixServer) then
    begin
    RegisterErrorLog('Service',1,'Не удалось запустить кластеризацию из-за некорректного префикса сервера');
    exit;
    end;
   end
   else  // иначе он пустой, получаем новый
   begin
   PrefixServer:=GeneratePrefixServr('',SrvIpExternal); // Генерация префикса сервера
     setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
     try
     setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer Префикс сервера
     finally
     setIni.UpdateFile;
     setIni.Free;
     end;
   end;

  if SrvIpExternal<>'' then // добавляем в массив префиксов свою запись если указан внешний IP в настройках
  begin                     // если адреса нет то в массив добавится при первом подключении к кластеру
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
  CurrentClient:=0; // текущий индекс клиента
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
  CurrentClient:=0; // текущий индекс клиента
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

try // сохраняем в файл данные черного спсика BlackListServerClaster,'BlackList.dat'
if BlackListServerClaster.Count>0 then // если список пустой то и сохранять нечего
BlackListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'BlackList.dat');
BlackListServerClaster.Free;
except on E : Exception do RegisterErrorLog('Service',2,'Shutdown service Save BlackList.dat '); end;


setIni:=TMeminifile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
try
setIni.WriteInteger('Console','port',PortConsole);  // Порт для администрирования
setIni.WriteString('Console','pswd',PswdConsole);// пароль для подключение консоли
setIni.WriteString('Console','Login',LoginConsole); // пользователь, для подключения консоли
setIni.WriteInteger('Viewer','port',PortServerViewer);// порт сервера для подключения клиентов
setIni.WriteString('Viewer','pswd',PswdServerViewer); // пароль
setIni.WriteString('Viewer','interface',SrvIpExternal); // внешний ИП для клиентов RuViewer//
setIni.WriteString('Viewer','prefix',PrefixServer);   // префик сервера
setIni.WriteInteger('claster','port',PortServerClaster);  // порт для кластеризации
setIni.WriteString('claster','pswd',PswdServerClaster);   // пароль для кластеризации
setIni.WriteInteger('claster','MaxNumInConnect',MaxNumInConnect); // максимальное количество разрешенных входящих подключений в кластере
setIni.WriteInteger('claster','PrefixLifeTime',PrefixLifeTime);   // удалять запись в списке префиксов если она не обновлялась ... минут
setIni.WriteBool('claster','BlackList',AddIpBlackListClaster); //включать или нет черный список
setIni.WriteInteger('claster','BlackListLifeTime',LiveTimeBlackList); // время жизни записи в черном списке
setIni.WriteInteger('claster','NumberOfLockRetries',NumOccurentc); // количество повторов блокировки до попадания в черный список
setIni.WriteInteger('claster','TimeOutReconnect',TimeOutReconnect); //время ожидания до повторной установки неудачных исходящих соединений в кластере
setIni.WriteBool('claster','SendListServers',SendListServers); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
setIni.WriteBool('claster','GetListServers',GetListServers);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
setIni.WriteBool('claster','StartSrv',AutoRunSrvClaster);  // старт сервера кластера при запуске службы
setIni.WriteBool('Viewer','StartSrv',AutoRunSrvRuViewer); // старт сервера RuViewer при запуске службы
setIni.UpdateFile;
finally
setIni.Free;
end;

StopServerConsoleSocket; // остановка сервера консоли управления
StopServerRuViewerSocket; // Остановка сервера RuViewer

except on E : Exception do RegisterErrorLog('Service',2,'Shutdown service Error ' );end;
end;


function TRuViewerSrvService.ReadListServerClaster(ListServer:TstringList; FileName:string):boolean; // читаем файл со списками
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
      setIni.WriteString('Viewer','interface','');  // внешний ip адрес для подключения клиентов RuViewer
      setIni.WriteString('Viewer','prefix','');    // RuViewer Префикс сервера
      setIni.WriteInteger('claster','port',3897);
      setIni.WriteString('claster','pswd','7777');
      setIni.WriteInteger('claster','MaxNumInConnect',10); // максимальное кол-во входящих подключений для клстеризации
      setIni.WriteInteger('claster','PrefixLifeTime',10); // максимальное время жизни префикса если он не обновлялся родительски сервером
      setIni.WriteBool('claster','BlackList',false); //включать или нет черный список
      setIni.WriteInteger('claster','NumberOfLockRetries',3); // количество повторов блокировки до попадания в черный список
      setIni.WriteInteger('claster','BlackListLifeTime',10); //мин время жизни записи в черном списке   LiveTimeBlackList
      setIni.WriteInteger('claster','TimeOutReconnect',5); //время ожидания до повторной установки неудачных исходящих соединений в кластере
      setIni.WriteBool('claster','SendListServers',true); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','GetListServers',true);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
      setIni.WriteBool('claster','StartSrv',true);  // старт сервера кластера при запуске службы
      setIni.WriteBool('Viewer','StartSrv',true); // старт сервера RuViewer при запуске службы
      setIni.WriteInteger('Other','TimeWaitPackage',600); // //максимальное время ожидания конца пакета милисекунды

      TimeWaitPackage:=600; //максимальное время ожидания конца пакета милисекунды
      LevelLogError:=0;
      PswdConsole:='9999';
      LoginConsole:='ConsoleAdmin';
      PortConsole := 3899; // Порт для администрирования
      PswdServerViewer:='8888';
      PswdServerClaster:='7777';
      PortServerViewer:=3898; // порт сервера для подключения клиентов
      PortServerClaster:=3897; // порт для кластеризации
      MaxNumInConnect:=10; // максимальное кол-во входящих подключений для клстеризации
      PrefixLifeTime:=10;  // удалять запись в списке префиксов если она не обновлялась ... минут
      NumOccurentc:=3;   // количество повторов блокировки до попадания в черный список
      PrefixServer:='';
      SrvIpExternal:='';
      AddIpBlackListClaster:=false; // выключить черный список
      NumOccurentc:=3; // количество повторов для блокировки до попадаия в черный список  черном списке
      LiveTimeBlackList:=10; // мин время жизни записи в черном списке   LiveTimeBlackList
      TimeOutReconnect:=5; //время ожидания до повторной установки неудачных исходящих соединений в кластере
      SendListServers:=true; // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      GetListServers:=true; // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
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
      PortConsole:=setIni.ReadInteger('Console','port',3899);  // Порт для администрирования
      PswdConsole:=setIni.ReadString('Console','pswd','9999');// пароль для подключение консоли
      LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // пользователь, для подключения консоли
      PswdServerViewer:=setIni.ReadString('Viewer','pswd','8888');
      PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
      SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // внешний ip адрес для подключения клиентов RuViewer
      PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer Префикс сервера
      PortServerClaster:=setIni.ReadInteger('claster','port',3897);
      PswdServerClaster:=setIni.ReadString('claster','pswd','7777');
      MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // максимальное количество разрешенных входящих подключений в кластере
      PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // удалять запись в списке префиксов если она не обновлялась ... минут
      AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // выключить/выключить черный список
      LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //мин время жизни записи в черном списке   LiveTimeBlackList
      NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // количество повторов блокировки до попадания в черный список
      TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //время ожидания до повторной установки неудачных исходящих соединений в кластере
      SendListServers:=setIni.ReadBool('claster','SendListServers',true); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
      GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
      AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',true); // старт сервера кластера при запуске службы
      AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',true); // старт сервера RuViewer при запуске службы
      TimeWaitPackage:=setIni.ReadInteger('Other','TimeWaitPackage',600); //максимальное время ожидания конца пакета милисекунды
      finally
      setIni.Free;
      end;
   end;

  if PrefixServer<>'' then
   begin // проверка префикса на корректность
    if not CorrectPrefix(PrefixServer,SrvIpExternal,PrefixServer) then
    begin
    RegisterErrorLog('Service',1,'Не удалось запустить службу из-за некорректного префикса сервера');
    exit;
    end;
   end
   else  // иначе он пустой, получаем новый
   begin
   PrefixServer:=GeneratePrefixServr('',SrvIpExternal); // Генерация префикса сервера
     setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
     try
     setIni.WriteString('Viewer','prefix',PrefixServer);    // RuViewer Префикс сервера
     finally
     setIni.UpdateFile;
     setIni.Free;
     end;
   end;


  if SrvIpExternal<>'' then // добавляем в массив префиксов свою запись если указан внешний IP в настройках
  begin                     // если адреса нет то в массив добавится при первом подключении к кластеру
  AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);
  end;

  IndexSrvConnect:=0;  // индекс подключеной консоли управления
  CurrentClient:=0; // текущий индекс клиента
  CurrentSrvClaster:=0; // текущий индекс подключаемого сервера кластера
  SendLogToConsole:=false; // Не отправлять логи на подключенную консоль
  CurentIndexPrefix:=0; // Текущий индекс записей префиксов серверов

  SingRunOutConnectClaster:=false; // признак запушеного потока исходящих соединений кластера
  SingRunInConnectionClaster:=false; // признак запушеного потока входящих соединений кластера
  SingRunRuViewerServer:=false;     // признак запущенного сервера RuViewer

  MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId для шифрования
  MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId для шифрования
  MyChainModeId:='native.ECB'; // TCodec.ChainModeId для шифрования
  EncodingCrypt:=Tencoding.Create;
  EncodingCrypt:=Tencoding.UTF8; // кодировка для шифрования
  //---------------------------------------------------------- // сервер RuViewer

   if AutoRunSrvRuViewer then StartServerRuViewerSocket; // Запуск сервера RuViewer
//---------------------------------- socket для консоли
   StartServerConsoleSocket; /// Запуск сервера консоли управления
//---------------------------------------
  LocalUID:=generateUID; // генерация локального UID ПК
  KeyAct:='';
  CountConnect:=10;
  DateL:=strtodate(DateLicDefault);
  if ReadRegK(KeyAct) then // читаем ключ активации
   begin
    ActualKey:=ReadParemS(LocalUID,KeyAct,CountConnect,DateL,ActualDate);
   end
   else ActualKey:=false;



  BlackList:=Tstringlist.Create;
  ConnectList:=TstringList.Create;

  BlackListServerClaster:=Tstringlist.Create;
  if not ReadListServerClaster(BlackListServerClaster,'BlackList.dat') then   // читаем файл черных списков
    begin
     RegisterErrorLog('Service',1,'Не удалось загрузить файл BlackList.dat');
    end;


   StartOutConnectClaster;  // Запуск потока исходящих соединение кластера, сначала исходящего, т.к. там создается стринглист для списка серверов кластера
   if AutoRunSrvClaster then StartInConnectClaster;   // Запуск потока Входящих соединение кластера

    RegisterErrorLog('Service',1,'Регистрационные данные : Кол-во абонентов :'+inttostr(CountConnect)+' Дата окончания обновлений :'+datetimetostr(DateL));
  except on E : Exception do
   RegisterErrorLog('Service',2,'Ошибка запуска службы RuViewerSrvc: ' );
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


//------------------------------ end соединение кластера -----------------------------------------
//------------------------------------далее сокет для администрирования ---------------------------------------
function TRuViewerSrvService.AllDataTostream():TMemorystream; // переводим массив подключений в поток
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

Function  TRuViewerSrvService.AvailabilityIPInList(ip,handle:string;WBList:TstringList):boolean; // проверяем наличе IP адреса в списке адресов
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
//if found then RegisterErrorLog('SRVConnect','AvailabilityIPInList Ip :'+Ip+ ' Найден')
//else RegisterErrorLog('SRVConnect','AvailabilityIPInList Ip :'+Ip+ 'Не найден');
except
on E : Exception do RegisterErrorLog('SRVConsole',2,'AvailabilityIPInList');
end;
result:=found;
end;
//////////////////////////////////////////////////////////////////////////////////////////////////
Function  TRuViewerSrvService.DeleteIPInList(ip,handle:string;WBList:TstringList):boolean; // удаляем ip адресс из списка адресов
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
//if found then RegisterErrorLog('SRVConnect','WBList Ip :'+Ip+ ' Найден и удален из списка')
//else RegisterErrorLog('SRVConnect','WBList Ip :'+Ip+ 'Не найден');
except
on E : Exception do RegisterErrorLog('SRVConsole',2,'DeleteIPInLis ');
end;
result:=found;
end;
///////////////////////////////////////////////////////////////////////////////////////






procedure TRuViewerSrvService.SrvSocketConcoleAccept(Sender: TObject; Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',1,'Установка/Отказ в подключении клиента :'+socket.RemoteAddress);
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
    if TimeOutExit>1050 then // примерно 10 сек
      begin
      RegisterErrorLog('SRVConsole',0,'Входящее подключение клиента '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
      Socket.Close; // закрываем соединение с клиентом при ожидании более 10 сек
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
        RegisterErrorLog('SRVConsole',0,'Подключена консоль управления IP :'+Socket.RemoteAddress);
        break;
        end
        else
        begin
         BlackList.Add(Socket.RemoteAddress+'='+inttostr(Socket.Handle));
         RegisterErrorLog('SRVConsole',0,'Произведена попытка подключения консоли управления IP :'+Socket.RemoteAddress+ ' Указан не верный пароль или пользователь');
         Socket.Close;
         Break;
        end;
      end;
      TimeOutExit:=TimeOutExit+ProcessingSlack;
  end;
//RegisterErrorLog('SRVConnect','Подключение клиента '+ Socket.RemoteAddress+' к серверу администрирования');
end;

procedure TRuViewerSrvService.SrvSocketConcoleClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',0,'Отключения клиента '+ Socket.RemoteAddress+' от сервера администрирования');
DeleteIPInList(Socket.RemoteAddress,inttostr(Socket.Handle),ConnectList);
end;

procedure TRuViewerSrvService.SrvSocketConcoleClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
RegisterErrorLog('SRVConsole',0,'Ошибка соединения "'+syserrormessage(ErrorCode)+'" с клиентом '+ Socket.RemoteAddress);
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
RegisterErrorLog('SRVConsole',0,'Отправка данных клиенту '+ Socket.RemoteAddress);
end;


procedure TRuViewerSrvService.SrvSocketConcoleGetSocket(Sender: TObject; Socket: NativeInt;
  var ClientSocket: TServerClientWinSocket);
begin
//в обработчике этого события Вы можете отредактировать параметр ClientSocket;
RegisterErrorLog('SRVConsole',1,'SrvSocketGetSocket');
end;

procedure TRuViewerSrvService.SrvSocketConcoleGetThread(Sender: TObject;
  ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
begin
RegisterErrorLog('SRVConsole',1,'GetThread :'+ClientSocket.RemoteHost);
end;

procedure TRuViewerSrvService.SrvSocketConcoleListen(Sender: TObject; Socket: TCustomWinSocket);
begin
RegisterErrorLog('SRVConsole',1,'Режим ожидания подключения клиентов');
end;



function ThreadConsoleManager.Write_Log(nameFile:string;  NumError:integer; TextMessage:string):boolean;
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
try
if NumError<=LevelLogError then // если уровень ошибки выше чем указаный в настройках
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


function ThreadConsoleManager.SendMainSock(s:string):boolean; // функция отправки через сокет управления
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
        Write_Log('SRVConsole',2,'Поток Manager Внешняя функция отправки');
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




function ThreadConsoleManager.ReadRegK(var res:String):boolean; // чтение значений из реестра
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_READ); //KEY_READ только чтение, для доступа пользователей без прав администратора
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
    Write_Log('SRVConsole',2,'Ошибка чтения реестра ');
    result:=false;
  end;
end;
end;

function ThreadConsoleManager.WriteRegK(KeyAct:string):boolean; // Запись  в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewerServer',true) then // если удалось открыть ключ
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
    Write_Log('SRVConsole',2,'Ошибка записи в реестр ');
    result:=false;
  end;
end;
end;

procedure ThreadConsoleManager.CleanArrayClaster; // очистка элементов массива для подключения серверов в кластере
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
procedure ThreadConsoleManager.CleanArrayPrefix; // очистка элементов массива префиксов кластера
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
procedure ThreadConsoleManager.CleanArrayRuViewer; // очистка элементов массива подключеных клиентов Ruviewer
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
function ThreadConsoleManager.StatusRuViewerServer:boolean; // Определение статуса работы сервера RuViewer
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
Procedure ThreadConsoleManager.StopInConnectClaster;  // Остановка потока Входящих соединение кластера
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
SPar := '/K sc stop RuViewerSrvService & TIMEOUT /T 10 /NOBREAK & TASKKILL /F /IM RuViewerServerSrvc.exe & TIMEOUT /T 5 /NOBREAK & sc start RuViewerSrvService & exit'; // /K - Без выхода из cmd.exe после выполнения команды.
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
Function ThreadConsoleManager.StopOutConnectClaster:boolean;  // Остановка потока исходящих соединение кластера
var
i:integer;
timeOut:integer;
begin
  try
  result:=false;
  timeOut:=0;
  if ClasterOutTHread<>nil then ClasterOutTHread.Terminate; // завершение потока контролируещего и создающего исходящие подключения
   for I := 0 to length(ArrayClientClaster)-1 do
     begin
      ArrayClientClaster[i].CloseThread:=true; // Установка признака завершения потоков исходящих соединений в кластера
      while ArrayClientClaster[i].InOutput=2 do //для исходящих подключений
        begin
          sleep(10);
          timeOut:=timeOut+10;
          if timeOut>=500 then break;
        end;
     timeOut:=0;
     end;
   result:=true;
    try // сохраняем в файл данные для кластеризации
      if ListServerClaster.Count>0 then // если список серверов кластера пустой то и сохранять нечего
      ListServerClaster.SaveToFile(ExtractFilePath(Application.ExeName)+ 'SrvClaster.dat');
      ListServerClaster.Free;
      ReciveListServerClaster.Free;// удаляем полученный список серверов кластера
    except on E : Exception do Write_Log('SRVConsole',2,'StopOutConnectClaster  Save SrvClaster.dat'); end;
  except on E : Exception do
   begin
   Write_Log('SRVConsole',2,'StopOutConnectClaster');
   result:=false;
   end;
  end;
end;


//---------------------------------------------------------
Function ThreadConsoleManager.StopConnectClaster(ConnectID:integer):boolean;  // Остановка указаного соединения в кластере
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
         ArrayClientClaster[i].CloseThread:=true;  // признак необходимости завершения потока
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
procedure ThreadConsoleManager.StopServerRuViewerSocket; // Остановка сервера RuViewer
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

{ArrayClientClaster: array of TserverClst;// массив записей для подключенных серверов в кластере
  ArrayPrefixSrv: array of TPrefixSrv; // массив записей для хранения префиксов серверов в кластере, не зависимо подклчен он к текущему или нет
  ArrayClientData: array of TClientMRSD; // массив записей для подключенных клиентов RuViewer
  }
function ThreadConsoleManager.FindPrefixSrv(ipSrv:string):string;  // определение префикса сервера по IP
var
i:integer;
begin
try
   if length(ArrayPrefixSrv)>0 then
    for I := 0 to length(ArrayPrefixSrv)-1 do
     begin
     if (ArrayPrefixSrv[i].SrvIp=ipSrv) then
       begin
       result:=ArrayPrefixSrv[i].SrvPrefix; // префикс сервера
       break;
       end;
     end;
except on E : Exception do
 Write_Log('SRVConsole',2,'FindPrefixSrv ');
end;
end;

function ThreadConsoleManager.ListPrefixSrv:string;  //список всех префиксов в подключенном кластере
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
     strtmp.Add(ArrayPrefixSrv[i].SrvPrefix+'<|TIME|>'+ArrayPrefixSrv[i].DateCreate); // префикс сервера
     end;
  result:=strtmp.CommaText;
  finally
   strtmp.Free;
  end;
except on E : Exception do
 Write_Log('SRVConsole',2,' ListPrefixSrv ');
end;
end;

function ThreadConsoleManager.ListServerClasterToList:string; // список подключений к серверам в кластере
var
i:integer;
ListTmp:TstringList;
prefixSrv:string;
const
StatusConnectArr: array [0..5] of string=('','Соединение установленно','Сервер не отвечает на запрос','Не верный пароль','Ошибка соединения','');
DirectConnect: array [0..2] of string =('Соединение не установлено','Входящее','Исходящее');
begin
try
ListTmp:=TstringList.Create;
  try
   if length(ArrayClientClaster)>0 then
    for I := 0 to length(ArrayClientClaster)-1 do
     begin
     if ArrayClientClaster[i].StatusConnect=1 then // если статус соединение установлено
      prefixSrv:=FindPrefixSrv(ArrayClientClaster[i].ServerAddress) // запрашиваем префикс
     else prefixSrv:='';
     ListTmp.Add(ArrayClientClaster[i].ServerAddress+'<!>'+    //- адрес сервера
                  StatusConnectArr[ArrayClientClaster[i].StatusConnect]+'<!>'+ // статус соединения 2- сервер молчит при установленном соединении, 3-не верный пароль для подключения к серверу  4-ошибка соединения
                  Datetimetostr(ArrayClientClaster[i].DateTimeStatus)+'<!>'+ //время установки соединения
                  DirectConnect[ArrayClientClaster[i].InOutput]+'<!>'+   // входящее/исходящее
                  prefixSrv+'<!>'+ // префикс сервера
                  inttostr(ArrayClientClaster[i].SocketHandle)); // ID соединения
     end;
    result:=ListTmp.CommaText;
  finally
  ListTmp.Free;
  end;
except on E : Exception do
 Write_Log('SRVConsole',2,'ListServerClasterToList');
end;
end;

function ThreadConsoleManager.ListClientRuViewerToList:string; // список клиентов ruviewer
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
     if ArrayClientData[i].ConnectBusy then // если абонент подклчен
     begin
     ListTmp.Add(ArrayClientData[i].ID+'<!>'+    //- ID абонента
                 ArrayClientData[i].TargetID+'<!>'+
                 DateTimetostr(ArrayClientData[i].dateTimeConnect));// время подключения
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

Function ThreadConsoleManager.ReadFileToString(FileName:string):string; // загружает файл и формирует строку для передачи в сокет
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

Function ThreadConsoleManager.WriteStringToFile(FileName,WriteStr:String):boolean; // запись строки в указанный файл
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

function ThreadConsoleManager.ReadFileSettings:boolean; // Чтение всех сохраненных параметров
var
setIni:TMemIniFile;
 begin
 try
    setIni:=TMemIniFile.Create(ExtractFilePath(Application.ExeName)+ 'set.dat');
    try
    PortConsole:=setIni.ReadInteger('Console','port',3899);  // Порт для администрирования
    PswdConsole:=setIni.ReadString('Console','pswd','9999');// пароль для подключение консоли
    LoginConsole:=setIni.ReadString('Console','Login','ConsoleAdmin'); // пользователь, для подключения консоли
    PswdServerViewer:=setIni.ReadString('Viewer','pswd','8888');
    PortServerViewer:= setIni.ReadInteger('Viewer','port',3898);
    SrvIpExternal:=setIni.ReadString('Viewer','interface',''); // внешний ip адрес для подключения клиентов RuViewer
    PrefixServer:=setIni.ReadString('Viewer','prefix','');     // RuViewer Префикс сервера
    PortServerClaster:=setIni.ReadInteger('claster','port',3897);
    PswdServerClaster:=setIni.ReadString('claster','pswd','8523');
    MaxNumInConnect:=setIni.ReadInteger('claster','MaxNumInConnect',10); // максимальное количество разрешенных входящих подключений в кластере
    PrefixLifeTime:=setIni.ReadInteger('claster','PrefixLifeTime',10);  // удалять запись в списке префиксов если она не обновлялась ... минут
    AddIpBlackListClaster:=setIni.ReadBool('claster','BlackList',false);  // выключить/выключить черный список
    LiveTimeBlackList:=setIni.ReadInteger('claster','BlackListLifeTime',10); //мин время жизни записи в черном списке   LiveTimeBlackList
    NumOccurentc:=setIni.ReadInteger('claster','NumberOfLockRetries',3);  // количество повторов блокировки до попадания в черный список
    TimeOutReconnect:=setIni.ReadInteger('claster','TimeOutReconnect',5);  //время ожидания до повторной установки неудачных исходящих соединений в кластере
    SendListServers:=setIni.ReadBool('claster','SendListServers',true); // делится списком адресов серверов кластеризации, только из удачных исходящих подключений
    GetListServers:=setIni.ReadBool('claster','GetListServers',true);   // получать списк адресов серверов кластеризации, только из удачных исходящих подключений
    AutoRunSrvClaster:=setIni.ReadBool('claster','StartSrv',true); // старт сервера кластера при запуске службы
    AutoRunSrvRuViewer:=setIni.ReadBool('Viewer','StartSrv',true); // старт сервера RuViewer при запуске службы
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

function ThreadConsoleManager.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,PswdConsole,DecryptTmp); //дешифровка скопированной строки
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
    Write_Log('SRVConsole',2,'('+inttostr(step)+') Дешифрация данных ');
     s:='';
    end;
  end;
end;

procedure ThreadConsoleManager.Execute; // поток для общения с управляющей консолью сервера
var
i,posStart,PosEnd,IDtmp,TMPCountConnect,slepengtime:integer;
CryptBuf,TmpUID,TMPAct,CryptBufTemp:string;     //
Buffer,BufferTmp,pswdIN,LoginIN:string;
CryptText:string;
SendCryptTxT,TmpStr:string;
ActualDateL:boolean;
 function SendMainCryptText(s:string):boolean; // отправка зашифрованного текста в main сокет
  begin
 // Write_Log('SRVConnect','Перед шифрованием и отправкой - '+s);
  if Encryptstrs(s,PswdConsole, CryptBuf) then //шифруем перед отправкой
    begin
    result:=SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
    end
    else
    begin
    result:=false;
    Write_Log('SRVConsole',1,'No Encryptstrs before send');
    end;
  end;
begin
try
//Write_Log('SRVConnect','Поток управления сервером включен');
SendMainCryptText('<|FIRSTLOAD|>'); // говорим консоли что поток запущен и можно запросить первые данные
slepengtime:=0;
while AdmSocket.Connected do
 BEGIN
 try
 sleep(2);

  if (AdmSocket= nil) or (not AdmSocket.Connected) then break;
  if AdmSocket.ReceiveLength<1 then continue;
  CryptText:=AdmSocket.ReceiveText;
  while not CryptText.Contains('<!!>') do // Ожидание конца пакета
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
 // Write_Log('SRVConnect','Получил - '+Buffer);

  if Buffer.Contains('<|LISTCLIENT|>') then //запросили список клиентов RuViewer
   begin
   TmpStr:=ListClientRuViewerToList;
   SendMainCryptText('<|LISTCLIEN|>'+TmpStr+'<|END|>');
   end;

  if Buffer.Contains('<|LISTCLASTER|>') then  //запросили Список соединений с серверами кластера
   begin
   TmpStr:=ListServerClasterToList;

   SendMainCryptText('<|LISTCLASTER|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|LISTPREFIX|>') then  //запросилис список префиксов
   begin
   TmpStr:=ListPrefixSrv;
   SendMainCryptText('<|LISTPREFIX|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|STATUSSERVERRUVIEWER|>') then  //запросилис статус сервера RuViewer
   begin
      SingRunRuViewerServer:=StatusRuViewerServer;  // определяем статус сервера RuViewer
      SendMainCryptText('<|STATUSSRVRUVIEWER|>'+booltostr(SingRunRuViewerServer)+'<|END|>');
   end;

   if Buffer.Contains('<|STATUSSERVERCLASTER|>') then  //запросилис статусы сервера Claster
   begin
    SendMainCryptText('<|STATUSSRVCLASTERIN|>'+booltostr(SingRunInConnectionClaster)+'<|END|>'+
                      '<|STATUSSRVCLASTEROUT|>'+booltostr(SingRunOutConnectClaster)+'<|END|>');
   end;


   if Buffer.Contains('<|LISTSERVERCLASTER|>') then  //запросили Список серверов кластера из файла настроек SrvClaster.dat
   begin
   TmpStr:=ReadFileToString('SrvClaster.dat');
   SendMainCryptText('<|LISTSERVERCLASTER|>'+TmpStr+'<|END|>');
   end;

   if Buffer.Contains('<|READFILEPARAM|>') then // запросили файл с настройками
   begin
   TmpStr:=ReadFileToString('set.dat');
   SendMainCryptText('<|READFILEPARAM|>'+TmpStr+'<|END|>');
   end;


   if Buffer.Contains('<|FILEPARAM|>') then // пришел файл с настройками
   begin  //'<|FILEPARAM|>'+ParamToIniFileToString+'<|PARAMEND|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|FILEPARAM|>',BufferTmp);
   Delete(BufferTmp,1,posStart+12);
   BufferTmp:=copy(BufferTmp,1,pos('<|PARAMEND|>',BufferTmp)-1);
   if WriteStringToFile('set.dat',BufferTmp) then //если записали файл настроек
     begin
     if ReadFileSettings then  // перечитываем файл с полученными настройками
     SendMainCryptText('<|READPARAMDONE|>') // если прочитали то говорим об этом
     else SendMainCryptText('<|NOTREADPARAM|>'); // иначе говорим что не смогли прочитать настройки
     end
     else SendMainCryptText('<|NOTWRITEPARAM|>');// иначе не записали нстройки
   except On E: Exception do       Write_Log('SRVConnect',2,'Recive file settings' );
    end;
   end;

    if Buffer.Contains('<|LISTSRVCLASTERNEW|>') then // пришел файл SrvClaster с серверами кластера
   begin  //'<|LISTSRVCLASTERNEW|>'+ListServerClasterToString+'<|END|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|LISTSRVCLASTERNEW|>',BufferTmp);
   Delete(BufferTmp,1,posStart+20);
   BufferTmp:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
   WriteStringToFile('SrvClaster.dat',BufferTmp); // записываем файл со списком серверов
   ListServerClaster.CommaText:=BufferTmp;
   except On E: Exception do       Write_Log('SRVConnect',2,'Update ListServerClaster ');
    end;
   end;

   if Buffer.Contains('<|CLOSECONNECT|>') then //Запрос остановки соединения из списка серверов кластеризации
   begin     //'<|CLOSECONNECT|>'+inttostr(TmpID)+'<|END|>'
   try
   BufferTmp:=Buffer;
   posStart:=pos('<|CLOSECONNECT|>',BufferTmp);
   Delete(BufferTmp,1,posStart+15);
   BufferTmp:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
    if TryStrToInt(BufferTmp,IDtmp) then
     begin
      if StopConnectClaster(IDtmp) then // если остановили то отправляем новый список соединений
       begin
       TmpStr:=ListServerClasterToList;
       SendMainCryptText('<|LISTCLASTER|>'+TmpStr+'<|END|>');
       end;
     end
     else SendMainCryptText('<|NOCORRECTIDCONNECT|>'); // не корректный ID подключения

   except On E: Exception do       Write_Log('SRVConsole',2,'Close Connect');
    end;
   end;

    if Buffer.Contains('<|STOPCLASTERSERVER|>') then // Завпрос остановки сервера кластеризации
   begin
    StopInConnectClaster;  // Остановка потока входящих соединение кластера
    StopOutConnectClaster;  // Остановка потока исходящих соединение кластера
    CleanArrayClaster;   //Очистка элементов массива соединений в кластере
    CleanArrayPrefix;   //Очистка элементов массива префиксов
   end;

     if Buffer.Contains('<|STARTCLASTERSERVER|>') then // Завпрос запуска сервера кластеризации
   begin
    RuViewerSrvService.TimerStartServerClaster.Enabled:=true;  // включаем таймер запуска сервера
   end;

    if Buffer.Contains('<|STOPRUVIEWERSERVER|>') then // Завпрос остановки сервера RuViewer
   begin
     StopServerRuViewerSocket; // остановка сервера RuViewer
     CleanArrayRuViewer;   //Чистка элементов массива
   end;

   if Buffer.Contains('<|STARTRUVIEWERSERVER|>') then // Запрос запуска сервера RuViewer
   begin
     RuViewerSrvService.TimerStartServerRuViewer.Enabled:=true; // включаем таймер запуска сервера
   end;

   if Buffer.Contains('<|REBOOTSERVICES|>') then // перезапуск службы
   begin
   if RebootServices then SendMainCryptText('<|REBOOTSERVICEDONE|>');
   end;

   if Buffer.Contains('<|GETACTIVKEY|>') then // запрос статуса активации продукта / передаем что у нас есть
   begin                                     //KeyAct  UIDAct CountConnect
   SendMainCryptText('<|ACTIVEKEY|>'+KeyAct+'<|END|><|UIDACT|>'+LocalUID+'<|END|><|COUNTCONNECT|>'+inttostr(CountConnect)+'<|END|><|DATEL|>'+datetostr(DateL)+'<|END|>');
   end;

   if Buffer.Contains('<|SETACTIVKEY|>') then // передали ключ для активации продукта  / активируем
   begin //<|SETACTIVKEY|><|UIDSRV|>654654sdf45s656464<|END|><|KEYSRV|>154-4541-45<|END|>
         //TMPCountConnect,TmpUID,TMPAct
   BufferTmp:=Buffer;
   posStart:=pos('<|UIDSRV|>',BufferTmp);
   Delete(BufferTmp,1,posStart+9);
   TmpUID:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
   Delete(BufferTmp,1,pos('<|KEYSRV|>',BufferTmp)+9);
   TMPAct:=copy(BufferTmp,1,pos('<|END|>',BufferTmp)-1);
     begin
      if LocalUID=TmpUID then // если UID совпадает
       begin
        if WriteRegK(TMPAct) then // записываем ключ активации
          begin
           KeyAct:=TMPAct; // переназначение ключа активации
           if ReadParemS(LocalUID,KeyAct,CountConnect,DateL,ActualDateL) then
            begin
            ActualKey:=true; //
            SendMainCryptText('<|ACTIVEKEYDONE|>'+KeyAct+'<|END|><|UIDACT|>'+LocalUID+'<|END|><|COUNTCONNECT|>'+inttostr(CountConnect)+'<|END|><|DATEL|>'+datetostr(DateL)+'<|END|>');
            end
            else
            begin
            ActualKey:=false;
            if ActualDateL then SendMainCryptText('<|NOACTIVEKEY|>')  // не верный ключ активации
            else  SendMainCryptText('<|NOACTIVEDATE|>');  // иначе не актуальная дата ключа активации
            end;
          end
          else SendMainCryptText('<|NOWRITEKEY|>');  // не удалось записать ключ активации
        Write_Log('SRVConsole',0,'Регистрационные данные : Кол-во абонентов :'+inttostr(CountConnect)+' Дата окончания поддержки :'+datetimetostr(DateL));
       end
      else
      begin
      ActualKey:=false;
      SendMainCryptText('<|NOCORRECTUID|>');
      end;
     end;
     end;

     if Buffer.Contains('<|STATUSACTV|>') then // Запрос статуса активации продукта
     begin
     if not ActualKey then SendMainCryptText('<|NOTACTIVATED|>');
     end;
   //-------------

    if Buffer.Contains('<|DISCONNECT|>') then // Отключение консоли
   begin
     break;
   end;

   Buffer:='';
   except On E: Exception do
    begin
      Write_Log('SRVConsole',2,'Основной цикл  ');
      break;
    end;
  end;
 END;
//Write_Log('SRVConnect','Поток управления сервером ВЫКЛЮЧЕН');
if AdmSocket.Connected then AdmSocket.Close;
except
    On E: Exception do
    begin
      Write_Log('SRVConsole',2,' Поток Manager  ' + E.ClassName+' / '+ E.Message);
    end;
  end;
 end;

//--------------------------------------------------------------


end.


