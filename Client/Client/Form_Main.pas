
{$R ResFile.res}
unit Form_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,System.StrUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, System.Win.ScktComp,
  Registry, Vcl.Menus, Vcl.Mask, Scankey, WinApi.ShellAPI, Pipes, Vcl.VirtualImageList,
  Vcl.VirtualImage,ThReadMainTargetID,ThReadMainID,System.IOUtils,
  System.ImageList, Vcl.ImgList;

type
  TClietnRV=Record
     ConnectBusy:boolean;  // признак того что подключен
     mainSock: TCustomWinSocket; // здесь главный сокет
     DesktopSock:TCustomWinSocket; // сокет рабочего стола
     FilesSock:TCustomWinSocket; // сокет передачи файлов
     InOut:byte;              // признак подключения, я сервер или клиент. 1- я подключаюсь, 2- ко мне поключаются
     SrvAdr:string;        // адрес сервера RuViewer
     SrvPort:integer;      // порт сервера  RuViewer
     SrvPswd:string[255];      // пароль сервера RuViewer
     MyID:string;
     MyPswd:string[255];
     MyPing: Integer;
     CurrentPswdCrypt:string[255]; // пароль для шифрования в текущий момент соединения
     CurrentPswdDecrypt:string[255]; // пароль для дешифрования в текущий момент соединения
end;



type
  Tfrm_Main = class(TForm)
    YourID_Edit: TEdit;
    YourPassword_Edit: TEdit;
    Reconnect_Timer: TTimer;
    Status_Label: TLabel;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    TargetID_MaskEdit: TMaskEdit;
    PanelSet: TPanel;
    PanelMyID: TPanel;
    PanelStatus: TPanel;
    PanelConnect: TPanel;
    ImgButList: TVirtualImageList;
    LabelTargetID: TLabel;
    LabelMyPswd: TLabel;
    LabelMyID: TLabel;
    VimgLogo: TVirtualImage;
    ButMinimize: TSpeedButton;
    ButHideTrei: TSpeedButton;
    Status_Image: TVirtualImage;
    ButConnect: TButton;
    ImageIDClient: TVirtualImage;
    ImageMyID: TVirtualImage;
    ImageMyPass: TVirtualImage;
    ButAbout: TSpeedButton;
    ButSet: TSpeedButton;
    ButExit: TSpeedButton;
    TimerHideTray: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Reconnect_TimerTimer(Sender: TObject);
    procedure Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TargetServer_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TargetServer_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure TargetServer_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TargetID_EditKeyPress(Sender: TObject; var Key: Char);
    procedure TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
    function DecryptReciveText(s,TmpPswd:string):string; // функция расщифровки полученого текста из сокета
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure ButExitClick(Sender: TObject);
    procedure ButSetClick(Sender: TObject);
    procedure ButAboutClick(Sender: TObject);
    procedure ConnectClientID;
    procedure ConnectServerTargetID(pswdTgServ:string); // процедура подключение к компьютеру на TargetServer
    procedure ButHideTreiClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButMinimize1Click(Sender: TObject);
    procedure WMDisplayChange(var Message: TMessage); message WM_DISPLAYCHANGE; // получаем сообщение о смене настроек экран
    procedure WMQueryEndSession(var Msg : TWMQueryEndSession); message WM_QueryEndSession;
    procedure WMEndSession(var Msg : TWMQueryEndSession); message  WM_ENDSESSION ;
    function CurrentUserSession:integer; // текущий сеанс пользователя
    procedure WMPowerBroadcast(var Msg: TMessage); message WM_POWERBROADCAST; // определяем засыпает комп или просыпается

    function SendMainSocket(s:ansistring):boolean; // отправка только в main сокет
    function SendTargetSocket(s:ansistring):boolean; // отправка только в Target сокет
    function SendSelectMainSocket(s:ansistring; soketId:byte):boolean; //отправка в выбранный сокет, main или target

    function SendMainCryptText(s:string;pswdMainSrv:string):Boolean; // отправка зашифрованного текста в main сокет
    function SendTargetMainCryptText(s:string;pswdTgSrv:string):Boolean; // отправка зашифрованного текста в target сокет
    function SendCryptCurrentActivSocket(s:string):boolean; // отправка зашифрованного текста в текущий активный сокет управления main или target

    procedure ButConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); // отправка в главный сокет. main
    procedure MesGlgNotFreeLic;
    procedure Status_ImageClick(Sender: TObject);
    procedure ImageMyIDMouseEnter(Sender: TObject);
    procedure ImageMyIDMouseLeave(Sender: TObject);
    procedure YourID_EditMouseEnter(Sender: TObject);
    procedure YourID_EditMouseLeave(Sender: TObject);
    procedure YourPassword_EditMouseEnter(Sender: TObject);
    procedure YourPassword_EditMouseLeave(Sender: TObject);
    procedure TargetID_MaskEditMouseEnter(Sender: TObject);
    procedure TargetID_MaskEditMouseLeave(Sender: TObject);
    procedure TimerHideTrayTimer(Sender: TObject);
    procedure EditSrvIpKeyPress(Sender: TObject; var Key: Char);

    

  public
    MovingForm:boolean; // перемещение формы по экрану
    MovingFormX:integer;
    MovingFormY:integer;
    Viewer: Boolean;
    ResolutionTargetWidth: Integer;// разрешение экрана сервера
    ResolutionTargetHeight: Integer; //разрешение экрана сервера
    ResolutionTargetLeft: Integer;//расположение экрана сервера
    ResolutionTargetTop: Integer; //Расположение экрана сервера
    ResolutionResizeWidth: Integer;  // необходимое разрешение для клиента. Картинку с таким разрешением сервер отправляет
    ResolutionResizeHeight: Integer; // необходимое разрешение для клиента. Картинку с таким разрешением сервер отправляет
    ImagePixelF:TPixelFormat; //
    ScreenResizes:boolean;
//    ListFileFolder: TStringlist; // cсписок файлов для копирования
    MonitorCurrent:integer;
    MonitorCurrentX:integer;
    MonitorCurrentY:integer;
    MonitorCurrentWidth:integer;
    MonitorCurrentHeight:integer;
    MonitorVirtualCurrentWidth:integer;
    MonitorVirtualCurrentHeight:integer;
    MonitorVirtualLeftX:integer;
    MonitorVirtualLeftY:integer;

    MonitorCount:integer;
    RedirectTempVar:string;
    TimeoutDisconnect:int64;
    MTimeScreen,MTimeCompress,MTimeCompare:string;
    TimeStart:int64;
    Accessed: Boolean;
    MyPassword: string; // Мой пароль для подключения ко мне
    PswdServer:string; // пароль для подлючения к серверу указаному в настройках
    ArrConnectSrv: array of TClietnRV; // массив для исходящих подключений к разным серверам
    HostServer:string; // адрес  сервера дя подключения
    Port:integer;  // порт сервера
    MyID: string;  // Мой ID для подключения ко мне
    PCn:string; // имя моего ПК
    Timeout: Integer;
    FExtensions   : TStringList; /// списко расширений файлов для иконок для формы передачи файлов через буфер обмена
    PCUID:String;
    ServiceUID:string[255];
    CurrentActivMainSocket:integer; // номер текущего кативного сокета. т.е. номер элемента масиива ArrConnectSrv подключеного в текущий момент для управления. -1 нет управления, с 0 начинаются активные сокеты


    procedure ClearConnection;
    procedure ClearChat;
    procedure SetOffline;
    procedure SetOnline;
    procedure ConnectMainSocket;   // Переподключение существующего Main сокета
    function ReCreateMainSocket:boolean; // пересоздание главного сокета
    function ReConnectMainSocket:boolean; // Переподключение главного сокета
    function CloseSockets:boolean;
    function ApplySetConnectMain(Host:string;Port:integer;  PasswordSrv:string; indexConnect:byte):boolean; // применение настроек Main сокета
    function ReconnectTargetIDServer(Host:string;Port:integer; TargetID:string; PasswordSrv:string):boolean; // переподключение к серверу целевого ID
    function DeleteMainSockets:boolean; // удаление Main сокета
    function CreateMainSocs:boolean;  // создание MAin сокета
    function CreateTargetserverSocket:boolean; // создание сокета для подключения к серверу клинта
    function ApplySetTargetserverSocke(Host:string;Port:integer;  PasswordSrv:string; indexConnect:byte):boolean; // применение настроек для сокета подключения к серверу клинта
    function DeleteTargetserverSockets:boolean; // удаление Targetserver сокета
    function GetImageIndexExt(const Ext: string): Integer; //системные иконки файлов
    function GetDefaultSystemIcon(ASiid: Integer;NameIco:string): Integer; // Системные иконки
    function Log_write(fname:string; NumError:integer; TextMessage:string):string;
    function CreateFormGetSetting(var IpHost:string; var Port:integer; Var SrvPswd:string; Var Autorun:string):boolean;
    function AddArraysrv(var NextIndex:byte):boolean; // добавляем запись в массив
    function FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // поиск запись в массиве
    function ClearArraysrv(AddrSrv:string):boolean; // очистка записи в массиве
     procedure InMessage(TextMessage:string;TypeMess:integer) ; // отображение сообщения для пользователя
    procedure PositionDefault;
    { Public declarations }

  end;

var
  frm_Main: Tfrm_Main;
  OldClipboardText: string;
  AutoRunApp:String; //Автозапуск программы из службы
  ControlAccess:boolean; // не контролируемый доступ
  TrayIcoClose:boolean;
  Main_Socket: TClientSocket;
  TargetServerSocket:TClientSocket;

  MyStreamCipherId:string; //TCodec.StreamCipherId для шифрования
  MyBlockCipherId:string; // TCodec.BlockCipherId для шифрования
  MyChainModeId:string; // TCodec.ChainModeId для шифрования
  EncodingCrypt:TEncoding; // кодировка текста при шифровании и дешифрации

  Thread_Connection_Main: TThread_Connection_Main;
  Thread_Connection_TargetServer: TThread_Connection_TargetMain;
  FpsMaxCount:integer; // максимальное кол-во кадров в секунду
  LevelLogError:integer;// уровень логирования

  const
  ConnectionTimeout = 60; // Timeout of connection (in secound)
  ProcessingSlack = 2; // Processing slack for Sleep Commands
  MaxTimeTimeout = 6000;


implementation


{$R *.dfm}
uses
Form_Password, Form_RemoteScreen, Form_Chat, Form_ShareFiles,FileTransfer,Form_Settings,Osher,MyClpbrd,FfmProgress,UID,ThReadMyClipboard,socketCrypt;




procedure Tfrm_Main.PositionDefault;
begin

end;

function Tfrm_Main.SendTargetMainCryptText(s:string;pswdTgSrv:string):Boolean; // отправка зашифрованного текста в Target сокет
var
CryptBuf:string;
  begin
  try
  Encryptstrs(s,pswdTgSrv, CryptBuf); //шифруем перед отправкой
  SendTargetSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
  result:=true;
    except On E: Exception do
      begin
      s:='';
      result:=false;
      Log_Write('app',2,'Ошибка шифрования перед отправкой сокета (М) внешняя функции  ');
      end;
    end;
end;

function Tfrm_Main.SendMainCryptText(s:string;pswdMainSrv:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
  begin
  try           //PswdServer
  Encryptstrs(s,pswdMainSrv, CryptBuf); //шифруем перед отправкой
  SendMainSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
  result:=true;
    except On E: Exception do
      begin
      s:='';
      result:=false;
      Log_Write('app',2,'Ошибка шифрования перед отправкой сокета (М) внешняя функции ');
      end;
    end;
end;

function Tfrm_Main.SendCryptCurrentActivSocket(s:string):boolean;
var
CryptBuf:string;
begin
 try
  if CurrentActivMainSocket=-1 then exit;// нет такого элемента массива, значит и ображаться не к кому
  if length(ArrConnectSrv)-1<CurrentActivMainSocket then exit;// если длинна массива меньше чем элемент то и ображаться не к кому
  Encryptstrs(s,ArrConnectSrv[CurrentActivMainSocket].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
  if ArrConnectSrv[CurrentActivMainSocket].mainSock=nil then result:=false
    else
    begin
      if ArrConnectSrv[CurrentActivMainSocket].mainSock.Connected then
      begin
       while ArrConnectSrv[CurrentActivMainSocket].mainSock.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(ProcessingSlack);
       result:=true;
      end
      else result:=false;
    end;
 except On E: Exception do
   begin
   s:='';
   result:=false;
   Log_Write('app',2,'Ошибка шифрования и отправки в активный сокет управления ');
   end;
    end;
 end;



function Tfrm_Main.SendMainSocket(s:ansistring):boolean;
begin // отправка в главный сокет. main или target в зависимости от того какой активен. Если активны оба (т.е. я подключился к абоненту другого сервера),  то отправка в main
    try
    result:=true;
    if Main_Socket<>nil then
      begin
      if Main_Socket.Socket.Connected then
        begin
        while Main_Socket.Socket.SendText(s)<0 do
        sleep(ProcessingSlack);
        result:=true;
        end
      else result:=false;
      end
     except on E : Exception do Log_Write('app',2,'Ошибка отправки сокета (М) внешняя функции');
    end;
end;

function Tfrm_Main.SendTargetSocket(s:ansistring):boolean;
begin // отправка в главный сокет. main или target в зависимости от того какой активен. Если активны оба (т.е. я подключился к абоненту другого сервера),  то отправка в main
    try
    result:=true;
    if TargetServerSocket<>nil then
      begin
      if TargetServerSocket.Socket.Connected then
        begin
        while TargetServerSocket.Socket.SendText(s)<0 do
        sleep(ProcessingSlack);
        result:=true;
        end
      else result:=false;
      end
     except on E : Exception do Log_Write('appT2',2,'Ошибка отправки сокета (TМ) внешняя функции');
    end;
end;


function Tfrm_Main.SendSelectMainSocket(s:ansistring; soketId:byte):boolean;
begin // отправка в главный сокет. main или target в зависимости от того какой активен. Если активны оба (т.е. я подключился к абоненту другого сервера),  то отправка в main
try
//if (Accessed) or (Viewer) then  // если ко мне подключились или я подключился
   begin
    result:=true;
    if soketId=1 then
      begin
      if Main_Socket<>nil then
        begin
          if Main_Socket.Socket.Connected then
          begin
           while Main_Socket.Socket.SendText(s)<0 do
           sleep(ProcessingSlack);
           result:=true;
          end
          else result:=false;
        end
      end;
    if soketId=2 then
      begin
      if TargetServerSocket<>nil then
        begin
          if TargetServerSocket.Socket.Connected then
          begin
           while TargetServerSocket.Socket.SendText(s)<0 do
           sleep(ProcessingSlack);
           result:=true;
          end
          else result:=false;
        end;
      end;
    if soketId=3 then // отправка в активный сокет, сначала смотрим target после main
     begin
      if TargetServerSocket<>nil then
        begin
          if TargetServerSocket.Socket.Connected then
          begin
           while TargetServerSocket.Socket.SendText(s)<0 do
           sleep(ProcessingSlack);
           result:=true;
          end
          else result:=false;
        end
        else
        if Main_Socket<>nil then
        begin
          if Main_Socket.Socket.Connected then
          begin
           while Main_Socket.Socket.SendText(s)<0 do
           sleep(ProcessingSlack);
           result:=true;
          end
          else result:=false;
        end;
     end;
  end;
except on E : Exception do Log_Write('app',2,'Отправка сокет (М) внешняя функции');  end;
end;


function Tfrm_Main.CurrentUserSession:integer; // текущий сеанс пользователя
 var
SessionId: DWORD;
begin
  try
  if ProcessIdToSessionId(GetCurrentProcessId, SessionId) then
  result:=SessionId
  else result:=-1;
   except on E : Exception do
    begin
    Log_Write('app',2,'Текущий сеанс пользователя');
    result:=-1;
    end;
  end;
end;

procedure Tfrm_Main.WMPowerBroadcast(var Msg: TMessage);  // определяем засыпает ли ПК
begin
 try
  case Msg.wParam of
    PBT_APMSUSPEND:
      begin
      Reconnect_Timer.Enabled:=false;
      SendMainCryptText('<|STOPACCESS|>',PswdServer); // отправляем данные на сервер для отключения
      CloseSockets;
      Log_Write('app',1,' Переход в спящий режим');          // переход в спящий режим
      end;
    PBT_APMRESUMESUSPEND:
      begin
       if not Reconnect_Timer.Enabled then
        begin
        if not ReCreateMainSocket then Log_Write('app',1,' Выход из спящего режима, инициированный пользователем, ошибка пересоздания сокета');
        Reconnect_Timer.Enabled:=true;
        end;
      Log_Write('app',1,' Выход из спящего режима, инициированный пользователем ');   // выход из спящего режима, инициированный пользователем (например, нажата клавиша)
      end;
    PBT_APMRESUMEAUTOMATIC:
       begin
       if not Reconnect_Timer.Enabled then
         begin
         if not ReCreateMainSocket then Log_Write('app',1,' Выход из спящего режима, ошибка пересоздания сокета');
         Reconnect_Timer.Enabled:=true;
         end;
       Log_Write('app',1,' Выход из спящего режима'); // выход из спящего режима
       end;
    else Log_Write('app',1,'WM_POWERBROADCAST другое событие = '+inttostr( Msg.wParam));
  end;
  except on E : Exception do
    begin
    Log_write('app',2,'Ошибка сообщения о зарежиме сна');
    end;
   end;
 end;


procedure Tfrm_Main.WMEndSession(var Msg: TWMQueryEndSession); //message  WM_ENDSESSION ;
{Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Source: WPARAM;
    Unused: LPARAM;
    Result: LRESULT}
begin
//inherited;   { сначала сообщание должен обработать наследуемый метод }
if msg.Unused and ENDSESSION_CLOSEAPP=ENDSESSION_CLOSEAPP then
  begin
  Log_Write('app',1,'ENDSESSION_CLOSEAPP WMEndSession value='+inttostr(msg.Unused));
  TrayIcoClose:=true; // разрешаем закрыть.
  frm_Main.Close;
  Msg.Result:=0; // после обработки возвращаем 0     https://learn.microsoft.com/ru-ru/windows/win32/shutdown/wm-endsession
  end
else
if msg.Unused and ENDSESSION_CRITICAL=ENDSESSION_CRITICAL then
  Begin
  Log_Write('app',1,'WMEndSession Принудительное завершение работы приложения value='+inttostr(msg.Unused));
  TrayIcoClose:=true; // разрешаем закрыть.
  frm_Main.Close;
  Msg.Result:=0; // после обработки возвращаем 0     https://learn.microsoft.com/ru-ru/windows/win32/shutdown/wm-endsession
  End
else
if msg.Unused and ENDSESSION_LOGOFF=ENDSESSION_LOGOFF then // завершение сеанса
  begin
  if msg.Source<>0 then   //Если сеанс завершается, этот параметр имеет значение TRUE;
   begin
   Log_Write('app',1,'WMEndSession Завершение сенса пользователя value='+inttostr(msg.Unused));
   TrayIcoClose:=true; // разрешаем закрыть.
   frm_Main.Close;
   Msg.Result:=0; // после обработки возвращаем 0     https://learn.microsoft.com/ru-ru/windows/win32/shutdown/wm-endsession
   end;
  end
 else
 if msg.Unused=0 then // 0- -завершение работы
 begin
  if msg.Source<>0 then   //Если сеанс завершается, этот параметр имеет значение TRUE;
   begin
    Log_Write('app',1,'WMEndSession Завершение работы системы или перезагрузка');
    TrayIcoClose:=true; // разрешаем закрыть.
    frm_Main.Close;
    Msg.Result:=0; // после обработки возвращаем 0     https://learn.microsoft.com/ru-ru/windows/win32/shutdown/wm-endsession
   end;
 end
else Log_Write('app',1,' WM_ENDSESSION not identified lParam='+inttostr(msg.Unused));

end;


procedure Tfrm_Main.WMQueryEndSession(var Msg : TWMQueryEndSession); //message WM_QueryEndSession;// завершение программы при изменении сеансов пользователей Windows
{Msg: Cardinal;
    MsgFiller: TDWordFiller;
    Source: WPARAM;
    Unused: LPARAM;
    Result: LRESULT}
var
resB:byte;
mesg:string;
begin
//inherited;  { сначала сообщание должен обработать наследуемый метод }
try
 try

 Log_Write('app',1,'WMQueryEndSession value='+inttostr(msg.Unused));
 if msg.Unused=0 then
  begin
  Log_Write('app',1,'WMQueryEndSession Завершение работы или перезагрузка');
  if Encryptstrs('<|SHUTDOWN|>'+inttostr(CurrentUserSession)+'<|END|>',ServiceUID,mesg) then TPBPipeClient.SendData('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5',mesg ); // отправляем сообщение службе
  mesg:='';
  end;
 if msg.Unused and ENDSESSION_LOGOFF=ENDSESSION_LOGOFF then
  begin
  Log_Write('app',1,'WMQueryEndSession Завершение сенса пользователя');
  if Encryptstrs('<|LOGOFF|>'+inttostr(CurrentUserSession)+'<|END|>',ServiceUID,mesg) then TPBPipeClient.SendData('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5',mesg ); // отправляем сообщение службе
  mesg:='';
  end;
 finally
  Msg.Result:=1;
  end;
 except on E : Exception do
    begin
    Log_write('app',2,'Сообщение о завершении работы');
    end;
   end;
end;





procedure  Tfrm_Main.WMDisplayChange(var Message: TMessage); // событие возникающее при изменении параметров экрана
begin
  try
   if (Accessed) or (Viewer) then  // если ко мне подключились или я подключился
    begin
    SendCryptCurrentActivSocket ('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Width) + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Height) + '<|END|>');
    SendCryptCurrentActivSocket('<|REDIRECT|><|MONITORLEFTTOP|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Left)+ '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Top) + '<|END|>');
    MonitorCurrentX:=screen.Monitors[MonitorCurrent].Left;
    MonitorCurrentY:=screen.Monitors[MonitorCurrent].Top;
    MonitorCurrentWidth:=screen.Monitors[MonitorCurrent].Width;
    MonitorCurrentHeight:=screen.Monitors[MonitorCurrent].Height;
    // Параметры всего виртуального рабочего стола
    MonitorVirtualCurrentWidth:=GetSystemMetrics(SM_CXVIRTUALSCREEN);// Ширина всего вируального рабочего стоал, включет все мониры
    MonitorVirtualCurrentHeight:=GetSystemMetrics(SM_CYVIRTUALSCREEN);// Высота всего вируального рабочего стоал, включет все мониры
    //Log_Write('app','MonitorVirtualCurrentWidth='+inttostr(MonitorVirtualCurrentWidth)+' MonitorVirtualCurrentHeight='+inttostr(MonitorVirtualCurrentHeight));
    MonitorVirtualLeftX:=GetSystemMetrics(SM_XVIRTUALSCREEN); // координаты верхнего левого угла виртуального рабочего стола X
    MonitorVirtualLeftY:=GetSystemMetrics(SM_YVIRTUALSCREEN); // координаты верхнего левого угла виртуального рабочего стола Y
    //Log_Write('app','MonitorVirtualLeftX='+inttostr(MonitorVirtualLeftX)+' MonitorVirtualLeftY='+inttostr(MonitorVirtualLeftY));
    end;
   inherited;
   except on E : Exception do
    begin
    Log_write('app',2,'Сообщение о смене параметров дисплея');
    end;
   end;
end;
//-------------------------------------------------------------------------

function Tfrm_Main.ClearArraysrv(AddrSrv:string):boolean; // очистка записи в массиве
var
i:integer;
exist:boolean;
begin
  try
  exist:=false;
  //Log_write('app','MESSAGE ClearRecordClient чистим '+AddrSrv);
   if AddrSrv<>'' then
    for I := 0 to Length( ArrConnectSrv)-1 do
     begin
       if ArrConnectSrv[i].SrvAdr=AddrSrv then
        begin
        ArrConnectSrv[i].ConnectBusy:=false;
        ArrConnectSrv[i].InOut:=0;
        ArrConnectSrv[i].SrvAdr:='';
        ArrConnectSrv[i].SrvPort:=0;
        ArrConnectSrv[i].SrvPswd:='';
        if ArrConnectSrv[i].mainSock<>nil then
        begin
        //Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' mainSock<>nil ');
        //if ArrConnectSrv[i].mainSock.Connected then Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' mainSock.Connected ');
        if ArrConnectSrv[i].mainSock.Connected then ArrConnectSrv[i].mainSock.Close;
        //ArrConnectSrv[i].mainSock.Free;
        //ArrConnectSrv[i].mainSock:=nil;
        end;
        if ArrConnectSrv[i].DesktopSock<>nil then
        begin
        //Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' DesktopSock<>nil ');
        //if ArrConnectSrv[i].DesktopSock.Connected then Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' DesktopSock.Connected');
        //if ArrConnectSrv[i].DesktopSock.Connected then ArrConnectSrv[i].DesktopSock.Close;
        //ArrConnectSrv[i].DesktopSock.Free;
        //ArrConnectSrv[i].DesktopSock:=nil;
        end;
        if ArrConnectSrv[i].FilesSock<>nil then
        begin
        //Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' FilesSock<>nil ');
        //if ArrConnectSrv[i].FilesSock.Connected then Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i)+ ' FilesSock.Connected');
       // if ArrConnectSrv[i].FilesSock.Connected then ArrConnectSrv[i].FilesSock.Close;
        //ArrConnectSrv[i].FilesSock.Free;
        //ArrConnectSrv[i].FilesSock:=nil;
        end;
        exist:=true;
        //Log_write('app','MESSAGE ClearRecordClient очишен индекс: '+inttostr(i));
        break;
        end;
     end;

  result:=exist;
  except On E: Exception do
    begin
    Log_write('app',2,'ClearRecordClient');
    result:=false;
    end;
  end;
end;

function Tfrm_Main.FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // поиск запись в массиве
var
i:integer;
exist:boolean;
begin
try
exist:=false;
for I := 0 to Length( ArrConnectSrv)-1 do
 begin
   if ArrConnectSrv[i].SrvAdr=AddrSrv then
    begin
    NextIndex:=i;
    exist:=true;
    break;
    end;
 end;
result:=exist;
//Log_write('app','MESSAGE FindRecordClient найден индекс: '+inttostr(NextIndex));
except On E: Exception do
  begin
  Log_write('app',2,'FindRecordClient ');
  result:=false;
  end;
end;
end;

function Tfrm_Main.AddArraySrv(var NextIndex:byte):boolean; // добавляем запись в массив
var
i:integer;
exist:boolean;
begin
try
exist:=false;

 for I := 0 to Length( ArrConnectSrv)-1 do
  begin
    if (not ArrConnectSrv[i].ConnectBusy)  then
     begin
      exist:=true;
      NextIndex:=i;
      ArrConnectSrv[i].SrvAdr:='';
      ArrConnectSrv[i].SrvPort:=0;
      ArrConnectSrv[i].SrvPswd:='';
      ArrConnectSrv[i].MyID:='';
      ArrConnectSrv[i].MyPswd:='';
      ArrConnectSrv[i].CurrentPswdCrypt:='';
      ArrConnectSrv[i].CurrentPswdDecrypt:='';
      break;
     end;
  end;

if not exist then //если свободных нет то увеличиваем длинну массива
begin
  SetLength(ArrConnectSrv,Length(ArrConnectSrv)+1);
  NextIndex:=Length(ArrConnectSrv)-1;
  exist:=true;
end;
result:= exist;
//Log_write('app','MESSAGE AddRecordClient выдан индекс: '+inttostr(NextIndex));
except On E: Exception do
  begin
  Log_write('app',2,'AddRecordClient');
  result:=false;
  end;
end;
end;



function MemoryStreamToString(M: TMemoryStream): AnsiString; //перевод из памяти в строку
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

/// Log File
function Tfrm_Main.Log_write(fname:string; NumError:integer; TextMessage:string):string;
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
       if FileExists(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log') then
        f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
        f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
        while f.Count>1000 do f.Delete(1);
          f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
      finally
      f.Destroy;
      end;
    End;
  except on E : Exception do
  begin
  exit;
  end;
  end;
end;




// Get current Version
function GetAppVersionStr: string;
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

function GetWallpaperDirectory: string;  /// картинка, директория фон рабочего стола
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Result := Reg.ReadString('Wallpaper');
  finally
    FreeAndNil(Reg);
  end;
end;

procedure ChangeWallpaper(Directory: string); // установка картинки, фона рабочег стола
var
  Reg: TRegistry;
begin
   Reg := nil;
   Reg := TRegistry.Create;
  try 
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Reg.WriteString('Wallpaper', Directory);
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, nil, SPIF_SENDWININICHANGE);
  finally
    FreeAndNil(Reg);
  end;
end;


function Tfrm_Main.GetImageIndexExt(const Ext: string): Integer;  /// иконки и расширения файлов
var
  Icon : TIcon;
  FileInfo : SHFILEINFO;
begin
  Result:=FExtensions.IndexOf(Ext);
  if Result=-1 then
  begin
    ZeroMemory(@FileInfo, SizeOf(FileInfo));
    Icon := TIcon.Create;
    try
       if SHGetFileInfo(PChar('*'+Ext), FILE_ATTRIBUTE_NORMAL, FileInfo, SizeOf(FileInfo),
       SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES ) <> 0 then
        begin
          Icon.Handle := FileInfo.hIcon;
          Result:=frm_ShareFiles.ImageIcon.AddIcon(Icon);
          FExtensions.Add(Ext);
        end;
    finally
      Icon.Free;
    end;
  end;
end;


function Tfrm_Main.GetDefaultSystemIcon(ASiid: Integer;NameIco:string): Integer;
var
  sInfo: TSHStockIconInfo;
  Icon : TIcon;
  res:Hresult;
  {SIID_DOCNOASSOC         = 0;
  SIID_DOCASSOC           = 1;
  SIID_APPLICATION        = 2;
  SIID_FOLDER             = 3;
  SIID_FOLDEROPEN         = 4;
  SIID_DRIVE525           = 5;
  SIID_DRIVE35            = 6;
  SIID_DRIVEREMOVE        = 7;
  SIID_DRIVEFIXED         = 8;
  SIID_DRIVENET           = 9;
  SIID_DRIVENETDISABLED   = 10;
  SIID_DRIVECD            = 11;
  SIID_DRIVERAM           = 12;
  SIID_WORLD              = 13;
  SIID_SERVER             = 15;
  SIID_PRINTER            = 16;
  SIID_MYNETWORK          = 17;
  SIID_FIND               = 22;
  SIID_HELP               = 23;
  SIID_SHARE              = 28;
  SIID_LINK               = 29;
  SIID_SLOWFILE           = 30;
  SIID_RECYCLER           = 31;
  SIID_RECYCLERFULL       = 32;
  SIID_MEDIACDAUDIO       = 40;
  SIID_LOCK               = 47;
  SIID_AUTOLIST           = 49;
  SIID_PRINTERNET         = 50;
  SIID_SERVERSHARE        = 51;
  SIID_PRINTERFAX         = 52;
  SIID_PRINTERFAXNET      = 53;
  SIID_PRINTERFILE        = 54;
  SIID_STACK              = 55;
  SIID_MEDIASVCD          = 56;
  SIID_STUFFEDFOLDER      = 57;
  SIID_DRIVEUNKNOWN       = 58;
  SIID_DRIVEDVD           = 59;
  SIID_MEDIADVD           = 60;
  SIID_MEDIADVDRAM        = 61;
  SIID_MEDIADVDRW         = 62;
  SIID_MEDIADVDR          = 63;
  SIID_MEDIADVDROM        = 64;
  SIID_MEDIACDAUDIOPLUS   = 65;
  SIID_MEDIACDRW          = 66;
  SIID_MEDIACDR           = 67;
  SIID_MEDIACDBURN        = 68;
  SIID_MEDIABLANKCD       = 69;
  SIID_MEDIACDROM         = 70;
  SIID_AUDIOFILES         = 71;
  SIID_IMAGEFILES         = 72;
  SIID_VIDEOFILES         = 73;
  SIID_MIXEDFILES         = 74;
  SIID_FOLDERBACK         = 75;
  SIID_FOLDERFRONT        = 76;
  SIID_SHIELD             = 77;
  SIID_WARNING            = 78;
  SIID_INFO               = 79;
  SIID_ERROR              = 80;
  SIID_KEY                = 81;
  SIID_SOFTWARE           = 82;
  SIID_RENAME             = 83;
  SIID_DELETE             = 84;
  SIID_MEDIAAUDIODVD      = 85;
  SIID_MEDIAMOVIEDVD      = 86;
  SIID_MEDIAENHANCEDCD    = 87;
  SIID_MEDIAENHANCEDDVD   = 88;
  SIID_MEDIAHDDVD         = 89;
  SIID_MEDIABLURAY        = 90;
  SIID_MEDIAVCD           = 91;
  SIID_MEDIADVDPLUSR      = 92;
  SIID_MEDIADVDPLUSRW     = 93;
  SIID_DESKTOPPC          = 94;
  SIID_MOBILEPC           = 95;
  SIID_USERS              = 96;
  SIID_MEDIASMARTMEDIA    = 97;
  SIID_MEDIACOMPACTFLASH  = 98;
  SIID_DEVICECELLPHONE    = 99;
  SIID_DEVICECAMERA       = 100;
  SIID_DEVICEVIDEOCAMERA  = 101;
  SIID_DEVICEAUDIOPLAYER  = 102;
  SIID_NETWORKCONNECT     = 103;
  SIID_INTERNET           = 104;
  SIID_ZIPFILE            = 105;
  SIID_SETTINGS           = 106;
  SIID_DRIVEHDDVD         = 132;
  SIID_DRIVEBD            = 133;
  SIID_MEDIAHDDVDROM      = 134;
  SIID_MEDIAHDDVDR        = 135;
  SIID_MEDIAHDDVDRAM      = 136;
  SIID_MEDIABDROM         = 137;
  SIID_MEDIABDR           = 138;
  SIID_MEDIABDRE          = 139;
  SIID_CLUSTEREDDRIVE     = 140;
  SIID_MAX_ICONS          = 175;}
begin
 try
  Result:=FExtensions.IndexOf(NameIco);
  if Result=-1 then
   Begin
    ZeroMemory(@sInfo, SizeOf(TSHStockIconInfo));
    //sInfo.cbSize := SizeOf(TSHStockIconInfo);
    Icon := TIcon.Create;
    try
    res := SHGetStockIconInfo(ASiid, SHGFI_ICON or SHGFI_SMALLICON, sInfo); //SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUT
    if res=S_OK then
    begin
      Icon.Handle:=sInfo.hIcon;
      Result:=frm_ShareFiles.ImageIcon.AddIcon(Icon);
      FExtensions.Add(NameIco);
       Log_Write('FileTransfer',2,'Добавлена иконка '+NameIco);
     end
    else
     begin
      Log_Write('FileTransfer',2,'Ошибка вызова функции SHGetStockIconInfo '+SysErrorMessage(res));
      result:= 0;
     end;
    finally
    Icon.Free;
    end;
   End;
 except on E : Exception do Log_Write('FileTransfer',2,'Ошибка GetDefaultSystemIcon: '+E.ClassName+': '+E.Message);  end;
 end;


procedure Tfrm_Main.ImageMyIDMouseEnter(Sender: TObject);
begin
try
(sender as TVirtualImage).ImageIndex:=20;
except on E : Exception do Log_Write('app',2,'Ошибка ImageMyIDMouseEnter: '+E.ClassName+': '+E.Message);  end;
end;


procedure Tfrm_Main.ImageMyIDMouseLeave(Sender: TObject);
begin
try
(sender as TVirtualImage).ImageIndex:=19;
except on E : Exception do Log_Write('app',2,'Ошибка ImageMyIDMouseLeave: '+E.ClassName+': '+E.Message);  end;
end;

procedure Tfrm_Main.YourID_EditMouseEnter(Sender: TObject);
begin
ImageMyID.ImageIndex:=20;
end;

procedure Tfrm_Main.YourID_EditMouseLeave(Sender: TObject);
begin
ImageMyID.ImageIndex:=19;
end;


procedure Tfrm_Main.YourPassword_EditMouseEnter(Sender: TObject);
begin
ImageMyPass.ImageIndex:=20;
end;

procedure Tfrm_Main.YourPassword_EditMouseLeave(Sender: TObject);
begin
ImageMyPass.ImageIndex:=19;
end;

procedure Tfrm_Main.TargetID_MaskEditMouseEnter(Sender: TObject);
begin
ImageIDClient.ImageIndex:=20;
end;


procedure Tfrm_Main.TargetID_MaskEditMouseLeave(Sender: TObject);
begin
ImageIDClient.ImageIndex:=19;
end;

procedure Tfrm_Main.InMessage(TextMessage:string;TypeMess:integer) ; // отображение сообщения для пользователя
begin
case TypeMess of
0:MessageDlg(TextMessage,mtWarning, [mbYes], 0);
1:MessageDlg(TextMessage,mtError, [mbYes], 0);
2:MessageDlg(TextMessage,mtInformation, [mbYes], 0);
3:MessageDlg(TextMessage,mtConfirmation, [mbYes], 0);
4:MessageDlg(TextMessage,mtCustom, [mbYes], 0);
end;
end;


procedure Tfrm_Main.ButAboutClick(Sender: TObject);
begin
MessageBox(0, 'RuViewer, программа предназначена для управления рабочим столом удаленного компьютера.' + #13 +
#13'Подробную информацию можно найти на сайте разработчика skrblog.ru', PWidechar('RuViewer '+GetAppVersionStr), MB_ICONASTERISK + MB_TOPMOST);
end;

procedure Tfrm_Main.ButConnectClick(Sender: TObject);
begin
ConnectClientID;
end;


procedure Tfrm_Main.ButSetClick(Sender: TObject);
begin
Reconnect_Timer.Enabled:=false; // после закрытия формы Form_set повтоно включаем таймер
Form_set.ShowModal;
end;

procedure Tfrm_Main.ButHideTreiClick(Sender: TObject);
begin
Hide(); // убираем иконку из панель пуск
WindowState := wsMinimized;
TrayIcon1.Visible := True;
TrayIcon1.ShowBalloonHint;
end;

procedure Tfrm_Main.ButMinimize1Click(Sender: TObject);
begin
frm_Main.WindowState:=wsMinimized;
end;

procedure Tfrm_Main.ClearConnection; // очистка форм, применение стандартных настроек
begin
  with frm_RemoteScreen do  // форма удалеенного управления
  begin
    RemoteMouseChecked(false); // отключение удаленной мыши
    KeyBRemoteChecked(false); // отключение удаленной клавиатуры
    ResizeChecked(true);// вкл масштабирования
    FormOsher.MouseRemote_CheckBox.Checked := False;
    FormOsher.KeyboardRemote_CheckBox.Checked := False;
    CaptureKeys_Timer.Enabled := False;
  end;

  with frm_Chat do   //форма чата
  begin
    Width := 230;
    Height := 340;
    Left := Screen.WorkAreaWidth - Width;
    Top := Screen.WorkAreaHeight - Height;
    NewChat.Items.Clear;
    RichEditSend.Clear;
    NewChat.Items.AddInfo.Text := 'RuViewer - Чат';
    if (Visible) then Close;
  end;
end;

procedure Tfrm_Main.ClearChat; // очитка чата
begin
with frm_Chat do   //форма чата
  begin
    Width := 230;
    Height := 340;
    Left := Screen.WorkAreaWidth - Width;
    Top := Screen.WorkAreaHeight - Height;
    NewChat.Items.Clear;
    RichEditSend.Clear;
    NewChat.Items.AddInfo.Text := 'RuViewer - Чат';
    if (Visible) then Close;
  end;
end;





procedure Tfrm_Main.ConnectMainSocket; // подключение Main сокета
begin
try
  if Main_Socket<>nil then
    begin
    if not Main_Socket.Active then
      begin
      Main_Socket.Active := true;
      end;
    end;
 except on E : Exception do
    begin
    Log_Write('app',2,'Переподключения (M) сокета');
    end;
  end;
end;

function Tfrm_Main.ReCreateMainSocket:boolean;  //полное пересоздание главного сокета
var
indexArr:byte;
begin
try
result:=false;
if CloseSockets then DeleteMainSockets;
 if AddArraysrv(indexArr) then
 begin
   if CreateMainSocs then // создаем сокет main
   if ApplySetConnectMain(HostServer,port,PswdServer,indexArr) then result:=true; // применяем настройки Основного и подключаемся
 end;

except on E : Exception do
begin
result:=false;
Log_Write('app',2,'Пересоздания главного потока ');
end;
end;
end;

function Tfrm_Main.ReConnectMainSocket:boolean;  //полное пересоздание главного сокета
var
indexArr:byte;
begin
try
result:=false;
if Main_Socket=nil then
  begin
  if CloseSockets then DeleteMainSockets;
   if AddArraysrv(indexArr) then
   begin
     if CreateMainSocs then // создаем сокет main
     if ApplySetConnectMain(HostServer,port,PswdServer,indexArr) then result:=true; // применяем настройки Основного и подключаемся
   end;
  end
  else ConnectMainSocket;
begin

end;
  

except on E : Exception do
begin
result:=false;
Log_Write('app',2,'Пересоздания главного потока ');
end;
end;
end;


function Tfrm_Main.CloseSockets:boolean;   //закрытие main сокета
begin
try

  if Main_Socket<>nil then
  begin
   if Main_Socket.Active then
   begin
   Main_Socket.Close;
   end;
  end;

  Viewer := False;


  if Accessed then
  begin
    Accessed := False;
  end;

  // Show main form and repaint
  if not Visible then
  begin
    Show;
    Repaint;
  end;
  ClearConnection;
  result:=true;
 except on E : Exception do
    begin
    result:=false;
    Log_Write('app',2,'Закрытия основного сокет ');
    end;
  end;
end;

procedure Tfrm_Main.SetOffline; // если не подключились к серверу
begin
  YourID_Edit.Text := 'Не в сети';
  YourID_Edit.Enabled := False;

  YourPassword_Edit.Text := 'Не в сети';
  YourPassword_Edit.Enabled := False;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := False;

  ButConnect.Enabled := False;


end;

procedure SetConnected; // подключаемся к серверу
begin
  with frm_Main do
  begin
    YourID_Edit.Text := 'Получение данных';
    YourID_Edit.Enabled := False;

    YourPassword_Edit.Text := 'Получение данных';
    YourPassword_Edit.Enabled := False;

    TargetID_MaskEdit.Clear;
    TargetID_MaskEdit.Enabled := False;

    ButConnect.Enabled := False;
  end;
end;

procedure Tfrm_Main.SetOnline; // подключились к серверу и получили данные
begin
  YourID_Edit.Text := MyID;
  YourID_Edit.Enabled := true;

  YourPassword_Edit.Text := MyPassword;
  YourPassword_Edit.Enabled := true;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := true;

  ButConnect.Enabled := true;
end;






procedure Tfrm_Main.Status_ImageClick(Sender: TObject);
var
question:integer;
begin
  try
  question:=mrYes;
  if Status_Image.ImageIndex=16 then // если статус соединения установлено
  question:=messageDlg('Произвести переподключение к серверу RuViewer? ',mtConfirmation,[mbYes,mbNo],0);
  if question=mrYes then
    begin
    Reconnect_Timer.Enabled:=false;
    SendMainCryptText('<|STOPACCESS|>',PswdServer); // отправляем данные на сервер для отключения
      try
      if not ReCreateMainSocket then showmessage('Повторите подключение чуть позже.');
      finally
        Reconnect_Timer.Enabled:=true;
      end;
    end;

  except on E : Exception do Log_Write('app',2,'Переподключение');  end;
end;





procedure Tfrm_Main.ConnectServerTargetID(pswdTgServ:string); // процедура подключение к компьютеру на TargetServer
begin
try
  if not(TargetID_MaskEdit.Text = '   -   -   ') then
  begin
    if (TargetID_MaskEdit.Text = MyID) then Showmessage('Вы не можете подклчится к своему ПК!!!')
    else
    begin
      SendTargetMainCryptText('<|FINDID|>' + TargetID_MaskEdit.Text + '<|END|>',pswdTgServ); // отправляем данные на сервер
      Status_Label.Caption:='Поиск компьютера';
    end;
  end
  else showmessage('Не верный ID');
except on E : Exception do Log_Write('appT',2,'Ошибка вызова запроса на соединение');  end;
end;


procedure Tfrm_Main.ConnectClientID; // процедура подключение к компьютеру
begin
try
  if not(TargetID_MaskEdit.Text = '   -   -   ') then
  begin
    if (TargetID_MaskEdit.Text = MyID) then
      Showmessage('Вы не можете подклчится к своему ПК!!!')
    else
    begin   //Main_Socket.Socket.SendText
     SendMainCryptText('<|FINDID|>' + TargetID_MaskEdit.Text + '<|END|>',PswdServer); // отправляем данные на сервер
     TargetID_MaskEdit.Enabled := False;
     ButConnect.Enabled := False;
     Status_Label.Caption:='Поиск компьютера';
    end;
  end
  else showmessage('Не верный ID');
except on E : Exception do Log_Write('app',2,'Ошибка вызова запроса на соединение');  end;
end;


function Tfrm_Main.DecryptReciveText(s,TmpPswd:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,TmpPswd,DecryptTmp); //дешифровка скопированной строки
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
    Log_Write('app',2,'('+inttostr(step)+') Дешифрация данных ');
     s:='';
    end;
  end;
end;

//----------------------------------------
procedure Tfrm_Main.TargetServer_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
buffer,CryptBuf,DeCryptBuf,CryptText:string;
TimeOutExit:integer;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////ArrConnectSrv[IndexArr].SrvPswd - при подключении использовать пароль сервера для шифрования и расшифровки
begin
Encryptstrs(s,ArrConnectSrv[IndexArr].SrvPswd,CryptBuf); // при установке соединения используем пароль сервера
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(2);
end;

function SendNoCrypText(s:string):boolean;
begin
Socket.SendText(s);
end;

begin
try
  TimeOutExit:=0;
  if FindArraysrv(Socket.RemoteAddress,IndexArr) then // если получили индекс массива
     begin
     //Log_Write('appT','Запущен сокет подключения (TM) к серверу '+ Socket.RemoteAddress+'  пароль - '+ArrConnectSrv[IndexArr].SrvPswd);
     SendCrypText('<|MAINSOCKET|>'+PCn+'<|NPC|>'+leftstr(PCUID,255)+'<|UID|>'+''+'<|MPSWD|>'+''+'<|MID|>'+ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>'); //передача строки для подключения
     end
   else
     begin
     Log_Write('appT',2,'Подключение (TM) к серверу '+ Socket.RemoteAddress+' закрывавется из-за некорректного получения индекса массива подключений, повторите подключение к серверу');
     Socket.Close;
     exit;
     end;

 while True do
  Begin
    Application.ProcessMessages; // чтобы не зависло нах
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
    if TimeOutExit>1050 then // примерно 10 сек
     begin
     Log_Write('appT',0,'Подключение (TM) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
     Socket.Close; // закрываем соединение с клиентом при ожидании более 10 сек
     exit;
     end;
    if not Socket.Connected then break;
    if Socket.ReceiveLength < 1 then  Continue;

     DecryptBuf := Socket.ReceiveText;

    while not DecryptBuf.Contains('<!!>') do // Ожидание конца пакета
     begin
      TimeOutExit:=TimeOutExit+ProcessingSlack;
      if TimeOutExit>1050 then
       begin
       TimeOutExit:=0;
       break;
       end;
     Sleep(ProcessingSlack);
     if not Socket.Connected then break;
     if Socket.ReceiveLength < 1 then Continue;
     CryptText := Socket.ReceiveText;
     DecryptBuf:=DecryptBuf+CryptText;
     end;

    Buffer:=DecryptReciveText(DecryptBuf,ArrConnectSrv[IndexArr].SrvPswd);

    // Decryptstrs(DecryptBuf,ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // дешифрация
    // Log_Write('appT','Расшифровано - '+Buffer);

    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
       //Log_Write('appT','Запуск потока  (TM) для подключение к серверу '+ Socket.RemoteAddress+' ');
       ArrConnectSrv[IndexArr].mainSock:=Socket; // назначаем сокет
       ArrConnectSrv[IndexArr].ConnectBusy:=true; // занятость элемента массива
       Thread_Connection_TargetServer := TThread_Connection_TargetMain.create(Socket,IndexArr); //TThread_Connection_Main.Create(Socket,IndexArr);//создание потока для обратобки служебных сообщений Main_Socket
       Timeout := 0;
       break; // выход из цикла
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
      begin
      Log_Write('appT',0,'Подключение (TM) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неверно указанного пароля для подключения к серверу');
      showmessage('Не верно указан пароль для подключения к серверу абонента');
      Socket.Close;
      exit;
      end;
    if Pos('<|NOFREECONNECT|>', Buffer)> 0 then
      begin
      Log_Write('appT',0,'Подключение (M) к серверу '+ Socket.RemoteAddress+' закрывавется. Превышено число подключений к серверу.');
      Socket.Close;
      MesGlgNotFreeLic;
      exit;
      end;

   TimeOutExit:=TimeOutExit+ProcessingSlack;
   End;

  except on E : Exception do
    begin
    Log_Write('appT',2,'Ошибка соединения сокета (TМ) ');
    end;
  end;
end;
//-------------------------------------------------------------------
procedure Tfrm_Main.TargetServer_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var
indexArr:byte;
function TErrorEventtoStr(s:TErrorEvent):string;
begin
case s of
 eeGeneral:result:='eeGeneral';
 eeSend:result:='eeSend';
 eeReceive:result:='eeReceive';
 eeConnect:result:='eeConnect';
 eeDisconnect:result:='eeDisconnect';
 eeAccept:result:='eeAccept';
 eeLookup:result:='eeLookup';
 else result:='Unknown';
 end;
end;
begin

try
Log_Write('appT',0,'Ошибка сокета (TМ) '+Socket.RemoteAddress+' : '+TErrorEventtoStr(ErrorEvent)+' ' +inttostr(ErrorCode)+' '+ SysErrorMessage(ErrorCode));
ErrorCode := 0;
ClearArraysrv(Socket.RemoteAddress);
if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
except on E : Exception do
    begin
    Log_Write('appT',2,'Ошибка сокета (TМ)');
    end;
  end;
end;



//--------------------------------------------------------------------
procedure Tfrm_Main.TargetServer_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
  if not frm_Main.Visible then
  begin
    frm_Main.Show;
  end;
  //Log_Write('appT','отключения сокета (TМ) ');
  except on E : Exception do
    begin
    Log_Write('appT',2,'Отключения сокета(TМ)');
    end;
  end;
end;

//-----------------------------------------------------------------------
// события сокетов
procedure Tfrm_Main.MesGlgNotFreeLic;
begin
  Reconnect_Timer.Enabled:=false;
  if messageDlg('На сервере отсутствуют свободные подключения. Повторить подключение к серверу '+frm_Main.hostServer+'?',mtError,[mbYes,mbNo],0)=mrYes then
  begin
  Reconnect_Timer.Enabled:=true;
  end;
end;

procedure Tfrm_Main.Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
buffer,CryptBuf,DecryptBuf,CryptText:string;
TimeOutExit:integer;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////ArrConnectSrv[IndexArr].SrvPswd - при подключении использовать пароль сервера для шифрования и расшифровки
begin
Encryptstrs(s,ArrConnectSrv[IndexArr].SrvPswd,CryptBuf); // при установке соединения используем пароль сервера
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(2);
end;

function SendNoCrypText(s:string):boolean;
begin
Socket.SendText(s);
end;

begin
try
  TimeOutExit:=0;
    if FindArraysrv(Socket.RemoteAddress,IndexArr) then // если получили индекс массива
     begin
     //Log_Write('app','Запущен сокет подключения (M) к серверу '+ Socket.RemoteAddress+'  пароль - '+ArrConnectSrv[IndexArr].SrvPswd);
     SendCrypText('<|MAINSOCKET|>'+PCn+'<|NPC|>'+leftstr(PCUID,255)+'<|UID|>'+MyPassword+'<|MPSWD|>'+MyID+'<|MID|>'+ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>'); //передача строки для подключения
     end
   else
     begin
     Log_Write('app',0,'Подключение (M) к серверу '+ Socket.RemoteAddress+' закрывавется из-за некорректного получения индекса массива подключений, повторите подключение к серверу');
     Socket.Close;
     exit;
     end;

 while True do
  Begin
    Application.ProcessMessages; // чтобы не зависло нах
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
   if TimeOutExit>1050 then // примерно 10 сек
     begin
     Log_Write('app',0,'Подключение (M) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
     Socket.Close; // закрываем соединение с клиентом при ожидании более 10 сек
     exit;
     end;
    if not Socket.Connected then break;
    if Socket.ReceiveLength < 1 then  Continue;

    DecryptBuf := Socket.ReceiveText;

     while not DecryptBuf.Contains('<!!>') do // Ожидание конца пакета
     begin
      TimeOutExit:=TimeOutExit+ProcessingSlack;
      if TimeOutExit>1050 then
       begin
       TimeOutExit:=0;
       break;
       end;
     Sleep(ProcessingSlack);
     if not Socket.Connected then break;
     if Socket.ReceiveLength < 1 then Continue;
     CryptText := Socket.ReceiveText;
     DecryptBuf:=DecryptBuf+CryptText;
     end;

    Buffer:=DecryptReciveText(DecryptBuf,ArrConnectSrv[IndexArr].SrvPswd);
    //Log_Write('app','Получено - '+DecryptBuf);
    //Decryptstrs(DecryptBuf,ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // дешифрация
    //Log_Write('app','Расшифровано - '+Buffer);

    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
       Status_Label.Caption := 'В сети';
       frm_Main.Status_Image.ImageIndex:=16;
       ArrConnectSrv[IndexArr].mainSock:=Socket; // назначаем сокет
       ArrConnectSrv[IndexArr].ConnectBusy:=true; // занятость элемента массива
       Thread_Connection_Main :=TThread_Connection_Main.Create(Socket,IndexArr);//создание потока для обратобки служебных сообщений Main_Socket
       Timeout := 0;
       break; // выход из цикла
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
      begin
      Log_Write('app',0,'Подключение (M) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неверно указанного пароля для подключения к серверу');
      frm_Main.Status_Image.ImageIndex:=18;
      //Status_Label.Caption := 'Не верный пароль';
      Reconnect_Timer.Enabled:=false;
      Form_set.Show;
      Form_set.EditSrvPswd.SetFocus;
      showmessage('Не верно указан пароль для подключения к серверу');
      Socket.Close;
     // ClearArraysrv(ArrConnectSrv[IndexArr].SrvAdr); // очищаем элемент массива
      exit;
      end;
    if Pos('<|NOFREECONNECT|>', Buffer)> 0 then
      begin
      Log_Write('app',0,'Подключение (M) к серверу '+ Socket.RemoteAddress+' закрывавется Превышено число подключений к серверу.');
      Socket.Close;
      MesGlgNotFreeLic;
      exit;
      end;

   TimeOutExit:=TimeOutExit+ProcessingSlack;
   End;

  //Log_Write('app','Main_Socket соединение установлено, Thread_Connection_Main - запущен');
  except on E : Exception do
    begin
    Log_Write('app',2,'Ошибка соединения сокета (М) : '+E.ClassName+': '+E.Message);
    end;
  end;
end;

procedure Tfrm_Main.Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  frm_Main.Status_Image.ImageIndex:=17;
  Status_Label.Caption := 'Подключение...';
except on E : Exception do Log_Write('app',2,'Ошибка установки соединения сокета (М)');
  end
end;

procedure Tfrm_Main.Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  if frm_RemoteScreen.Visible then
    frm_RemoteScreen.Close;
  if not frm_Main.Visible then
  begin
    frm_Main.Show;
  end; 

  SetOffline;
  frm_Main.Status_Image.ImageIndex:=18;
  Status_Label.Caption := 'Отключен.';
  //Thread_Connection_Main.Terminate; // Признак завершения потока
 // ClearArraysrv(socket.RemoteAddress); // очищаем элемент массива  // сочистка в Disconnect вызывает ошибку из за повторного обращения к сокету который уже удалили при вызове очистки при ошике соединения
 // Log_Write('ThM','Отключение сокета (M)');
  except on E : Exception do
    begin
    Log_Write('app',2,'Ошибка отключения сокета (М)');
    end;
  end;
end;
// сначала идет событие Error потом Disconnect
procedure Tfrm_Main.Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var
indexArr:byte;
function TErrorEventtoStr(s:TErrorEvent):string;
begin
case s of
 eeGeneral:result:='eeGeneral';
 eeSend:result:='eeSend';
 eeReceive:result:='eeReceive';
 eeConnect:result:='eeConnect';
 eeDisconnect:result:='eeDisconnect';
 eeAccept:result:='eeAccept';
 eeLookup:result:='eeLookup';
 else result:='Unknown';
 end;
end;
begin

try
Log_Write('app',0,'Ошибка сокета (М) '+Socket.RemoteAddress+' : '+TErrorEventtoStr(ErrorEvent)+' ' +inttostr(ErrorCode)+' '+ SysErrorMessage(ErrorCode));
ErrorCode := 0;
ClearArraysrv(Socket.RemoteAddress);
frm_Main.Status_Image.ImageIndex:=18;
if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
except on E : Exception do
    begin
    Log_Write('app',2,'Ошибка сокета (М)');
    end;
  end;
end;

///-----------------------функции закрытия программы-----------------------------------------------------------------
procedure Tfrm_Main.N1Click(Sender: TObject);
begin
try
TrayIcoClose:=true;
frm_main.Close;
except on E : Exception do Log_Write('app',2,'TrayIcoClose');
end;
end;

procedure Tfrm_Main.ButExitClick(Sender: TObject);
var
mesg:string;
begin
if messageDlg('Закрыть программу?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
 begin
  if Encryptstrs('<|FORCEEXIT|>',ServiceUID,mesg) then TPBPipeClient.SendData('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5',mesg ); // отправляем сообщение службе
  mesg:='';
  TrayIcoClose:=true; // если да то разрешаем закрыть.
  frm_Main.Close;
 end;
end;


procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 try
  Reconnect_Timer.Enabled:=false; //  включаем таймер
  SendMainCryptText('<|STOPACCESS|>',PswdServer); // отправляем данные на сервер для отключения
  DeleteMainSockets; //закрываем и удаляем основной сокет
 // RemoveClipboardFormatListener(Handle);
   except On E: Exception do
   begin
   Log_write('app',2,' Exit ');
   end;
 end;
end;


procedure Tfrm_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
CanClose:=TrayIcoClose;
if not CanClose then // если не закрываем а сворачиваем
 begin
  Hide(); // убираем иконку из панель пуск
  WindowState := wsMinimized;
  TrayIcon1.Visible := True;
  TrayIcon1.ShowBalloonHint;
 end;
end;
//-----------------------------------------------------------------------------------------





function Tfrm_Main.ApplySetConnectMain(Host:string;Port:integer;  PasswordSrv:string; indexConnect:byte):boolean; // применение настроек Main сокета
begin
  try
    Main_Socket.Host := Host; //сервер
    Main_Socket.Port := Port;// порт
    ArrConnectSrv[Indexconnect].SrvAdr:=Host;
    ArrConnectSrv[Indexconnect].SrvPort:=Port;
    ArrConnectSrv[Indexconnect].SrvPswd:=PasswordSrv;
    ArrConnectSrv[Indexconnect].MyPing := 256;
    SetOffline; // сброс элементов главной формы перед подключением
    ConnectMainSocket;  // подключение Главного сокета
    reconnect_Timer.Enabled:=true;
    result:=true;
  except on E : Exception do
    begin
    result:=false;
    Log_Write('app',2,'Ошибка применения настроек сокетов');
    end;
  end;
end;




function Tfrm_main.CreateMainSocs:boolean; // создание основного сокта
begin
   try
    Main_Socket := TClientSocket.Create(self);
    Main_Socket.Active := False;
    Main_Socket.ClientType := ctNonBlocking;
    Main_Socket.OnConnecting := Main_SocketConnecting;
    Main_Socket.OnConnect := Main_SocketConnect;
    Main_Socket.OnDisconnect := Main_SocketDisconnect;
    Main_Socket.OnError := Main_SocketError;
    result:=true;
   except on E : Exception do
      begin
      result:=false;
      Log_Write('app',2,'Ошибка создания (M) сокета');
      end;
   end;
end;


function Tfrm_Main.DeleteMainSockets:boolean; // удаление Main сокета
begin
try
  if Main_Socket.Active then  Main_Socket.Close;
  if Main_Socket<>nil then Main_Socket.Free;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    Log_Write('app',2,'Ошибка удаления (M) сокета');
  end;
  end;
end;

//-------------------------------------------------------------------------------------
function Tfrm_Main.ReconnectTargetIDServer(Host:string;Port:integer; TargetID:string;  PasswordSrv:string):boolean; // переподключение к серверу целевого ID
var
indArr:byte;
begin
  try
  Viewer := False;
  if Accessed then
  begin
    Accessed := False;
  end;
  DeleteTargetserverSockets; //  закрываем и удаляем таргет сокет если он был открыт
   if (Host<>'')and (port<>0) then
   if AddArraysrv(indArr) then // если удачно получили индекс массива то создаем подключения и передаем туды индекс
    begin
    CreateTargetserverSocket; // создаем сокет
    if ApplySetTargetserverSocke(Host,port,PasswordSrv,indArr) then
      begin
        ResolutionTargetWidth := screen.Width-((screen.Width div 100)*40);
        ResolutionTargetHeight := screen.Height-((screen.Height div 100)*40);;
        frm_Main.ResolutionTargetLeft:=0;
        frm_Main.ResolutionTargetTop:=0;
        frm_Main.MonitorCurrent:=0;
        frm_Main.ImagePixelF:=pf8bit;

        ButConnect.Enabled := true;

        sleep(1000);// ожидаем подключение к серверу целевого ID
        TargetID_MaskEdit.Text:=TargetID;
        ConnectServerTargetID(PasswordSrv);
        result:=true;
      // Log_Write('appT','MESSAGE создание сокета для Target ID завершено');
      end
      else Log_Write('appT',1,'Не получилось применить новые настройки подключения для сервера ('+Host+') абонента');
    end
     else Log_Write('appT',1,'Ошибка получения элемента массива');


  except on E : Exception do
    begin
    result:=false;
    Log_Write('appT',2,'Ошибка переподключения к серверу абонента '+Host);
    end;
  end;
end;

function Tfrm_main.CreateTargetserverSocket:boolean; // создание сокета для подключения к серверу клинта
begin
   try
    TargetServerSocket := TClientSocket.Create(nil);
    TargetServerSocket.Active := False;
    TargetServerSocket.ClientType := ctBlocking;
    TargetServerSocket.OnConnect := TargetServer_SocketConnect;
    TargetServerSocket.OnDisconnect := TargetServer_SocketDisconnect;
    TargetServerSocket.OnError := TargetServer_SocketError;
    result:=true;
   except on E : Exception do
      begin
      result:=false;
      Log_Write('appT',2,'Ошибка создания (TM) сокета');
      end;
   end;
end;

function Tfrm_Main.ApplySetTargetserverSocke(Host:string;Port:integer;  PasswordSrv:string; indexConnect:byte):boolean;
begin // применение настроек для сокета подключения к серверу клинта
  try
    TargetServerSocket.Host := Host; //сервер
    TargetServerSocket.Port := Port;// порт
    ArrConnectSrv[Indexconnect].SrvAdr:=Host;
    ArrConnectSrv[Indexconnect].SrvPort:=Port;
    ArrConnectSrv[Indexconnect].SrvPswd:=PasswordSrv;
    TargetServerSocket.Active:=true;

    result:=true;
  except on E : Exception do
    begin
    result:=false;
    Log_Write('appT',2,'Ошибка применения настроек сокета (TM)');
    end;
  end;
end;

function Tfrm_Main.DeleteTargetserverSockets:boolean; // удаление Targetserver сокета
begin
try
  if TargetServerSocket.Active then  TargetServerSocket.Close;
  if TargetServerSocket<>nil then TargetServerSocket.Free;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    Log_Write('appT',2,'Ошибка удаления (TM) сокета');
  end;
  end;
end;

procedure Tfrm_Main.EditSrvIpKeyPress(Sender: TObject; var Key: Char);
begin
try
if not (key in['0'..'9',#8,'.']) then key:=#0;
 except on E : Exception do
    begin
     Log_Write('appT',2,'Ошибка only number and point Edit key press');
  end;
  end
end;

function Tfrm_Main.CreateFormGetSetting(var IpHost:string; var Port:integer; Var SrvPswd:string; Var Autorun:string):boolean;
var
MyDlg:Tform;
MyChBox:TCheckBox;
EditIP:TLabelEdEdit;
EditPort:TLabelEdEdit;
EditPswd:TLabelEdEdit;
BOk:Tbutton;

function Calc4k(input: Integer):Integer;
begin
  result := MulDiv(Input, {Screen.PixelsPerInch}FCurrentPPI, 96);
end;
begin
MyDlg:=Tform.Create(nil);
MyDlg.Scaled:=true;
MyDlg.BorderStyle:=bsDialog;
MyDlg.FormStyle:=fsStayOnTop;
MyDlg.position:=poOwnerFormCenter;
MyDlg.width:=250;
MyDlg.Height:=230;
//MyDlg.ScaleForPPI(FCurrentPPI); // с этой хуйней форма ведет себя не адекватно
MyDlg.caption:='Настройки подключения к серверу RuViewer';

MyChBox:=TCheckBox.Create(MyDlg);
EditIP:=TLabelEdEdit.Create(MyDlg);
EditPort:=TLabelEdEdit.Create(MyDlg);
EditPswd:=TLabelEdEdit.Create(MyDlg);
Bok:=Tbutton.Create(MyDlg);

try
EditIP.top:=20;
EditIP.Alignment:=taCenter;
EditIP.TextHint:='';
EditIP.EditLabel.Caption:='IP адрес сервера RuViewer';
EditIP.width:=MyDlg.Width-30;
EditIP.OnKeyPress:=EditSrvIpKeyPress;
EditIP.left:=(((MyDlg.Width div 2)-(EditIP.Width div 2))-8);
EditIP.parent:=MyDlg;
EditIP.ScaleForPPI(FCurrentPPI);

EditPort.top:=65;
EditPort.Alignment:=taCenter;
EditPort.TextHint:='3898';
EditPort.Text:='3898';
EditPort.EditLabel.Caption:='Порт сервера RuViewer';
EditPort.width:=MyDlg.Width-30;
EditPort.left:=(((MyDlg.Width div 2)-(EditPort.Width div 2))-8);
EditPort.NumbersOnly:=true;
EditPort.parent:=MyDlg;
EditPort.ScaleForPPI(FCurrentPPI);

EditPswd.Alignment:=taCenter;
EditPswd.top:=110;
EditPswd.TextHint:='';
EditPswd.Text:='';
EditPswd.EditLabel.Caption:='Пароль сервера RuViewer';
EditPswd.width:=MyDlg.Width-30;
EditPswd.left:=(((MyDlg.Width div 2)-(EditPswd.Width div 2))-8);
EditPswd.parent:=MyDlg;
EditPswd.ScaleForPPI(FCurrentPPI);

MyChBox.top:=135;
MyChBox.caption:='Запуск при загрузке Windows';
MyChBox.width:=EditPswd.Width;
MyChBox.checked:=true;
MyChBox.left:=EditPswd.Left;
MyChBox.parent:=MyDlg;
MyChBox.ScaleForPPI(FCurrentPPI);

Bok.Caption:='OK';
Bok.ModalResult:=MrOk;
Bok.width:=MyDlg.Width-30;
Bok.Height:=30;
Bok.left:=(((MyDlg.Width div 2)-(Bok.Width div 2))-8);{(((MyDlg.Width div 2)-(Bok.Width div 2)));}
Bok.top:=155;
Bok.parent:=MyDlg;
Bok.ScaleForPPI(FCurrentPPI);

MyDlg.width:=Calc4k(MyDlg.width); // увеличиваем форму после в соответсвии с dpi
MyDlg.Height:=Calc4k(MyDlg.Height);

if (MyDlg.showmodal=ID_OK) then
 begin
   if EditIP.Text='' then IpHost:='127.0.0.1'
     else IpHost:=EditIP.Text;
   if EditPort.Text='' then Port:=3898
     else Port:=strtoint(EditPort.Text);
   SrvPswd:=Editpswd.Text;
   If MyChBox.Checked then Autorun:='Auto' else Autorun:='No';
 end
 else
 begin
   IpHost:='127.0.0.1';
   Port:=3898;
   Autorun:='Auto';
   SrvPswd:='';
 end;

finally
  EditPort.Free;
  EditIP.Free;
  EditPswd.Free;
  MyChBox.Free;
  Bok.Free;
  MyDlg.Free;
end;
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
var
portstr,TargetID,TargetPswd:string;
readSettings:boolean;
indexArr:byte;
HideTray:boolean;
colorPrivilage:Tcolor;
Tmp:integer;
begin
try
TrayIcoClose:=false; // Запрет закрытия программы, только сворачиваем в трей
readSettings:=false; // признак чтения настроек
  //Log_Write('app','ParamStr - '+inttostr(ParamCount)+' - '+ParamStr(0)+' - '+ParamStr(1)+' - '+ParamStr(2)+' - '+ParamStr(3)+' - '+ParamStr(4)+' - '+ParamStr(5)+' - '+ParamStr(6));
 MyPassword:='';
 MyID:='';
 PswdServer:='';
 AutoRunApp:='Auto';
 HideTray:=false;
 PCn:='';
 TargetID:='';
 TargetPswd:='';
 ControlAccess:=false;
 FpsMaxCount:=15; // максимальное кол-во кадр/сек
 LevelLogError:=0;  //Уровень логирования 0, ничего не логировать
 PanelSet.Caption :=Application.Title; // + GetAppVersionStr;
  if (ParamStr(1)<>'') then // Чтение параметров строки запуска приложения если параметры существуют и не пустые
    Begin
    if ParamStr(1)='FirstRun' then HideTray:=true; // если запустили программу первый раз и службой, то сворачиваем в трей, далее проверяем если настроек нет то не сворачиваем
    End;

 if ParamStr(2)<>'' then   // определения уровня привилегий запущенного процесса
   begin
    Tmp:=-1;
     if trystrtoint(ParamStr(2),Tmp) then
     begin
       case Tmp of
       0: begin
          PanelSet.Font.Color:=ClRed;
          PanelSet.ShowHint:=true;
          PanelSet.Hint:='Высокий уровень привилегий';
          end;
       1: begin
          PanelSet.Font.Color:=ClBlue;
          PanelSet.ShowHint:=true;
          PanelSet.Hint:='Средний уровень привилегий';
          end;
       2: begin
          PanelSet.Font.Color:=ClGreen;
          PanelSet.ShowHint:=true;
          PanelSet.Hint:='Низкий уровень привилегий';
          end
          else
          begin
          PanelSet.Font.Color:=ClBlack;
          PanelSet.ShowHint:=false;
          end;
       end;
     end;

   end;

     form_set.ReadRegSet(port,FpsMaxCount,LevelLogError,HostServer,pcn,MyID,MyPassword,PswdServer,ControlAccess,AutoRunApp,readSettings);// читаем реестр
     if not readSettings then // если в реестре нет ничего то читаем файл
     form_set.ReadFileSet(HostServer,pcn,MyID,MyPassword,PswdServer,port,ControlAccess,AutoRunApp,readSettings); //  читаем настройки из файла


   if  not readSettings then  // если настроек нет не в параметрах командной строки файле и в реестре то заправшиваем у пользователя и системы
     begin
     if pcn='' then PCn:=form_set.GetNamePC; // если имя ПК не прочитали в настройках то запрашиваем в системе
     HideTray:=false; // если нет настроек то трей не сворачиваем
     CreateFormGetSetting(HostServer,port,PswdServer,AutoRunApp); // создаем диалоговое окно для ввода данных

     if not Form_set.WriteRegSet(Port,hostServer,PCn,PswdServer,AutoRunApp) then //записать в реестр иначе если не получилось то в файл
     Form_set.writefileSet(hostServer,inttostr(Port),pcn,PswdServer,AutoRunApp); // запись в файл настроек

      if not Form_set.writeregIDPasAC(FpsMaxCount,LevelLogError,MyID,MyPassword,ControlAccess) then // запись настроек в реестр
      Form_set.WriteFileIDPasAC(MyID,MyPassword,ControlAccess);                  // иначе запись в файл

      Form_set.WritelevelPrivilage(0,0); // запись привелегий запуска процесса //0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
     end;

   if not ControlAccess then  // если выключен неконтролируемый доступ
     begin
     MyPassword:='';
     MyID:='';
     end;


 // Log_Write('app',2,'port='+inttostr(port)+' - srv='+hostServer+' - srvpswd='+PswdServer+' - ID='+MyID+' - Password='+MyPassword);
  if (hostServer<>'')and (port<>0) then
    begin
     if AddArraysrv(indexArr) then // если удачно получили индекс массива то создаем подключения и передаем туды индекс
     begin
      if CreateMainSocs then // создаем сокет main
      ApplySetConnectMain(HostServer,port,PswdServer,indexArr); // применяем настройки Основного и подключаемся
      //остальные подключения создаются из main потока если текущее подключение прошло успешно
      end;
    end;
  //else showmessage('Для первого запуска, запустите программу с параметрами! ...\RuViewer.exe "ServerIP" "ServerPort"');

FExtensions:=TstringList.Create; // список расширений файлов в соответствии со значками в frm_ShareFiles.ImageIcon
FExtensions.add('Back');
FExtensions.add('Folder');
FExtensions.add('LocalDisk');
FExtensions.add('LocalDiskWin');
FExtensions.add('USBDrive');
FExtensions.add('DVDDrive');
FExtensions.add('NetDrive');
FExtensions.add('RamDrive');
FExtensions.add('UnknwnDrive');

Getlocale; // Определение локали Windows, вызывается один раз при запуске приложения
PCUID:=generateUID; // генерация уникально UID
if length(PCUID)>=11 then ServiceUID:=copy(PCUID,1,10) //первые 10 символов уникального ID
 else ServiceUID:='ServiceUID';

MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId для шифрования
MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId для шифрования
MyChainModeId:='native.ECB'; // TCodec.ChainModeId для шифрования
EncodingCrypt:=Tencoding.Create;
EncodingCrypt:=Tencoding.UTF8; // кодировка для шифрования
CurrentActivMainSocket:=-1; //при connect desktop присваиваем текущий элемент массива для доступа к главному сокету управления, при disconnect desktop передаем -1, т.е. сокет для управления не активный
MovingForm:=false; // перемещение формы по экрану
// Параметры всего виртуального рабочего стола
MonitorVirtualCurrentWidth:=GetSystemMetrics(SM_CXVIRTUALSCREEN);
MonitorVirtualCurrentHeight:=GetSystemMetrics(SM_CYVIRTUALSCREEN);
//Log_Write('app','MonitorVirtualCurrentWidth='+inttostr(MonitorVirtualCurrentWidth)+' MonitorVirtualCurrentHeight='+inttostr(MonitorVirtualCurrentHeight));
MonitorVirtualLeftX:=GetSystemMetrics(SM_XVIRTUALSCREEN); // координаты верхнего левого угла виртуального рабочего стола X
MonitorVirtualLeftY:=GetSystemMetrics(SM_YVIRTUALSCREEN); // координаты верхнего левого угла виртуального рабочего стола Y
//Log_Write('app','MonitorVirtualLeftX='+inttostr(MonitorVirtualLeftX)+' MonitorVirtualLeftY='+inttostr(MonitorVirtualLeftY));
if AutoRunApp<>'Auto' then HideTray:=false; //если автозагрузки нет то сворачивать не надо
if HideTray then TimerHideTray.Enabled:=true;
 except on E : Exception do
    begin
    Log_Write('app',2,'Ошибка создания главной формы ');
  end;
  end;
end;

procedure Tfrm_Main.TimerHideTrayTimer(Sender: TObject);
begin
if Main_Socket.Socket.Connected then
 begin
 Hide(); // убираем иконку из панель пуск
 WindowState := wsMinimized;
 TrayIcon1.Visible := True;
 TrayIcon1.ShowBalloonHint;
 end;
TimerHideTray.Enabled:=false;
end;


//---------------------------------
//-- перемещение формы
procedure Tfrm_Main.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MovingForm:=true;
MovingFormX:=x;
MovingFormY:=y;
end;

procedure Tfrm_Main.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
try
if MovingForm then
 begin
 frm_Main.Left:=frm_Main.Left+x-MovingFormX;
 frm_Main.Top:= frm_Main.Top+y-MovingFormY;
end;
except on E : Exception do Log_Write('app',2,'PanelButtonParentMouseMove '); end;
end;

procedure Tfrm_Main.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MovingForm:=false;
end;
//-- окончание перемещения формы
//----------------------------------



procedure Tfrm_Main.TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
begin
try
  if Key = #13 then
  begin
    ConnectClientID;
    Key := #0;
  end
except on E : Exception do Log_Write('app',2,'EditKeyPress (1)'{+E.ClassName+': '+E.Message});
end;
end;



procedure Tfrm_Main.Reconnect_TimerTimer(Sender: TObject);
var
Rcreat:boolean;
begin
try
  Rcreat:=false;
  if Main_Socket<>nil then
  if not Main_Socket.Active then  Rcreat:=true;
  if Main_Socket=nil then Rcreat:=true;
  if Rcreat then ReCreateMainSocket;
except on E : Exception do Log_Write('app',2,'ReconnectMain'{+E.ClassName+': '+E.Message});
end;
end;

procedure Tfrm_Main.TargetID_EditKeyPress(Sender: TObject; var Key: Char);
begin
try
  if Key = #13 then
  begin
    ConnectClientID;
    Key := #0;
  end
except on E : Exception do Log_Write('app',2,'EditKeyPress (2) : '{+E.ClassName+': '+E.Message});
end;
end;



procedure Tfrm_Main.TrayIcon1DblClick(Sender: TObject);
begin
  try
   TrayIcon1.Visible := False;
   if not frm_Main.Visible then frm_Main.Visible:=true;
    frm_Main.Show;
    WindowState := wsNormal;
    Application.BringToFront();
  except on E : Exception do Log_Write('app',2,'TrayIcon1DblClick'{+E.ClassName+': '+E.Message});
  end
end;


end.






