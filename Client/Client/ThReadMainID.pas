unit ThReadMainID;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,System.UITypes, Vcl.Graphics, VCL.Forms,
      ComCtrls,  System.Win.ScktComp, StreamManager,Winapi.MMSystem,System.IOUtils,Vcl.ExtCtrls,
       Zlib, Form_RemoteScreen,Form_Password,Form_Chat, Form_ShareFiles,FileTransfer,Osher,FfmProgress,FormReconnect,
       System.Generics.Collections,System.Types, uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants,
      uTPLb_Signatory, uTPLb_SimpleBlockCipher,System.Hash,Comobj,ActiveX,Clipbrd,ShellApi,System.NetEncoding,HGM.Controls.Chat;

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
  TThread_Connection_Main = class(TThread)
    MainSocket: TCustomWinSocket;
    IDConnect:byte;
    RecreateFileSocket:boolean; // признак необходимости пересоздавать файловый сокет если он отключен
    ReconnectFileSocketCount:integer;
    RecreateDesktopSocket:boolean; // признак необходимости пересоздавать сокет раочего стола если он отключен
    ReconnectDesktopSocketCount:integer;
    PswrdCrypt:string[255]; // пароль для шифрования
    constructor Create(aSocket: TCustomWinSocket; aIDConect:byte); overload;
    //destructor Destroy; override;
    procedure Execute; override;
    function DesOpenInputMain(FirstDesk:HDESK):boolean;
    function SendSocket(s:ansistring):boolean;
    function SendDesktopSocket(s:ansistring):boolean;
    function SendFilesSocket(s:ansistring):boolean;
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function CloseMainSocket:boolean; // закрытие основного сокета
    function CreateDesktopSocs:boolean;   // создание desktop сокета
    function CreateFileSocs:boolean; // Создание File сокета
    function FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // поиск запись в массиве
    procedure Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Desktop_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Files_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    function DeleteDesktopSockets:boolean; // удаление Desktop сокета
    function DeleteFileSockets:boolean; // удаление File сокета ,
    function CloseFileSockets:boolean; // закрытие File сокета
    function CloseDesktopSockets:boolean; // закрытие File сокета
    function ApplySetConnectDesktop(Host:string;Port:integer):boolean; // применение настроек Desktop сокета
    function ApplySetConnectFile(Host:string;Port:integer):boolean; // применение настроек File сокета
    procedure ReconnectDesktop; // Переподключение Desktop сокета
    procedure ReconnectFile; // Переподключение File сокета
    function ExistsFileSockets:boolean; // проверка сокета на активность
    function ExistsDektopSockets:boolean; // проверка сокета на активность
    function GetSize(bytes: Int64): string;  // расчет оъемов и перевод в текст
    function GetSizeByte(bytes: Int64): Int64;  // расчет оъемов и перевод в байты, Кбайты, Мбайты
    function ListlogDrive:string; // возвращает список локальных дисков
    function FormatByteSize(const bytes: int64): string; // приводим размер файла к читабельному
    function GetFileSize(const aFilename: String): String;  // размер файла  int64
    function LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; // дата и время последнего изменения каталогов или файлов
    function ListFiles(FileName, Ext: string; var ListFile:TstringList): boolean;  // чтение списка файлов
    function ParsingFileDateSize(InS:string; var OutD,OutS:string):boolean;  // функция парсинга строки  "дата и время+размер"
    function ListFolders(Directory: string): string; // чтение каталогов
    procedure FullFilesSocketReconnect; //проверка и переподключения файлового сокета
    procedure FullDesktopSocketReconnect;  // проверка и переподключение сокета рабочего стола
    function CreateKeyMouseThread:boolean;
    function DeleteKeyMouseThread:boolean;
    function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
    function SendMainCryptText(s:string):boolean; // отправка зашифрованного текста в main сокет
    function SendFilesCryptText(s:string):boolean; // отправка зашифрованного текста в files сокет
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    function ParsingTextToExpansion(Stmp:string):boolean;  // парсинг строки с расширением экрана и вкл/выкл масштабирования

 type
  TThread_Connection_Desktop = class(TThread)
    DesktopSocket: TCustomWinSocket;
    InOut:boolean;
    BindSockDesktop:boolean; // признак связываниея сокетов на сервере
    StartThreadBegin:Boolean; // начать работу потока с начала
    ClearReciveBuf:boolean; // очистить весь входящий буфер.
    TmpHdl:integer; //handle socket
    IDConnect:byte;
    PswrdCrypt:string[255]; // пароль для шифрования
    HashPswrdCrypt:string[255];
    constructor Create(aSocket: TCustomWinSocket; aInOut:boolean; aIDConect:byte); overload;
    procedure Execute; override;
    function  ScreenBmpCanvasSaveBMP(MonX,MonY,MonWidth,MonHeight:integer; inDC:HDC; resizes:boolean; wR,hR:integer; Mybmp: TBitmap; DrawCur:boolean; pixF:TPixelFormat; var TimeCompare:Double; var ResStr:string):boolean; // screen bmp save to bmp
    Procedure NoLineCompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream;  var TimeResume:Double; var ResStr:string; var ResB:boolean);
    procedure ResumeStreamXORBMP( var   FirstBMP, CompareBMP:Tbitmap; var SecondBMP:TmemoryStream;var SecondSize:int64; var TimeResume:double; var ResStr:string; var ResB:boolean);
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function SendMainSocket(s:ansistring):boolean;
    function DesOpenInput(var FirstDesktop:HDESK):boolean;
    Function CloseDesctopSocket(Mes:string):boolean;
    function DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
    function CompressStreamWithZLib(SrcStream: TMemoryStream; var TimeResume:Double): Boolean;
    function MemoryStreamToString(M: TMemoryStream): AnsiString; //перевод из памяти в строку
    function GetBindSockDesktop:boolean;  // чтение свойства признака связывания сокетов BindSockDesktop
    Procedure SetBindSockDesktop(BindS:boolean);  //запись свойства признака связывания сокетов BindSockDesktop
    function ZConpress(Var InCompressStream,OutCompressStream:TmemoryStream; var TimeResume:Double):Boolean;
    function ZDeconpress(InDeCompressStream,UotDeCompressStream:TmemoryStream):boolean;
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    public
    Property BindSockD   : boolean read GetBindSockDesktop write SetBindSockDesktop; // читаем и записываем параметр из потока
    Property StartThBegin: boolean read  StartThreadBegin write StartThreadBegin;
    Property ClearRecBuf: boolean read  ClearReciveBuf write ClearReciveBuf;
  end;

  type
  TThread_Connection_Files = class(TThread)
    FileSocket: TCustomWinSocket;
    IDConnect:byte;
    BindSockFiles:Boolean; // признак связывания файловых сокетов на сервере
    PswrdCrypt:string[255]; // пароль для шифрования
    HR : HRESULT;
    constructor Create(aSocket: TCustomWinSocket; aIDConect:byte); overload;
    procedure Execute; override;
    function DesOpenInputMain(FirstDesk:HDESK):boolean;
    procedure CloseFilesSocket;
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function SendMainSocket(s:ansistring):boolean;
    function SendFileSocket(s:ansistring):boolean;
    function GetSize(bytes: Int64): string;  // расчет оъемов и перевод в текст
    function GetBindSockFiles:boolean;  // чтение свойства признака связывания сокетов BindSockFiles
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean; // функция шифрования
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean; //функциярасщифровки
    function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
    function SendFileCryptText(s:string):Boolean; // отправка зашифрованного текста в Files соке
    function SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
    Procedure SetBindSockFiles(BindS:boolean);  //запись свойства признака связывания сокетов BindSockFiles
    function CompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
    function DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
    //--------------------буфер обмена-------------------------------
    function ThLoadClipboardFormat(reader: TReader):boolean; //определение формата буфера обмена
    function ThLoadClipboard(S: TStream):boolean; //Загрузка потока в буфер обмена
    function ThCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;// непосредственно перенос потока в буфер в соответствии с форматом
    function ThShellWindow: HWND;
    function ThClipBoardTheFiles:boolean; // проверка буфера обмена на наличие файлов
    function ThFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean; //функция определения что в буфере для передачи, и запуска потоков копирования файлов или буфера
    //-----------------------------------------------------------------
    public
    Property BindSockF :boolean read GetBindSockFiles write SetBindSockFiles;  // читаем и записываем параметр из потока
  end;


  type
   TThread_Redirect_KeyMouse = class (TThread)
     NumL,CapsL,ScrollL:boolean;
    constructor create(aStrRedirect:string); overload;
    procedure execute; Override;
    procedure PressCtrlC;   //эмуляция нажатия ctrl+c
    function DesOpenInput(var FirstDesktop:HDESK):boolean;
    function SendCharKeys(SendKeysString: string): Boolean;
    function MousePress(x,y:integer;MousFlags:Dword;MouseData:DWORD):boolean;
    function MouseDblPress:boolean;
    function MouseClick(SFlags:Cardinal):boolean;
    function PressACS(VSkey,UpDown:dword):boolean;
    function IsMouseBtnDown(MouseButton:integer): Boolean;
    function CleanMouseBtnDown: Boolean; //Сброс состояния кнопок мыши
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;

    const
    VK_OEM_AUTO = 243;
    MOUSEEVENTF_XDOWN=$0080;
    MOUSEEVENTF_XUP=$0100;
    MOUSEEVENTF_VIRTUALDESK=$4000;

  end;


   var
   Thread_Connection_Desktop: TThread_Connection_Desktop;
   Thread_Connection_Files: TThread_Connection_Files;
   Thread_RedirectKM:TThread_Redirect_KeyMouse;
   Desktop_Socket: TClientSocket;
   Files_Socket: TClientSocket;

  end;



implementation
uses  PipeS,ThReadMyClipboard,Form_Main,MyClpbrd,ThReadCopyFileFolder, ThReadDelete;

var
strRedirect:TThreadedQueue<string>;
CurrentFPSSession:integer;


{destructor TThread_Connection_Main.Destroy;
begin
inherited Destroy;
{FilesConnectTimer.Free;
DesktopConnectTimer.Free;
if Files_Socket<>nil then
begin
  if Files_Socket.Active then Files_Socket.Close;
  Files_Socket.Free;
end;
if Desktop_Socket<>nil then
begin
  if Desktop_Socket.Active then Desktop_Socket.Close;
  Desktop_Socket.Free;
end;
end; }


function TThread_Connection_Main.TThread_Redirect_KeyMouse.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
  except
   exit;
  end;
end;

constructor TThread_Connection_Main.Create(aSocket: TCustomWinSocket; aIDConect:byte);
begin
  inherited Create(False);
  MainSocket := aSocket;
  IDConnect:=aIDConect;
  RecreateFileSocket:=false; // признак пересоздания файлового сокета
  ReconnectFileSocketCount:=0;// текущее кол-во переподулючений файлового сокета
  RecreateDesktopSocket:=false; // признак пересоздания сокета рабочего стола
  ReconnectDesktopSocketCount:=0;// текущее кол-во переподулючений сокета рабочего стола
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Main.TThread_Redirect_KeyMouse.Create(aStrRedirect:string);
begin
 inherited Create(False);
 FreeOnTerminate := true;
end;


////////////////////////////////////////////////////////////////////// Функция принимает  виртуальный код клавиши
function TThread_Connection_Main.TThread_Redirect_KeyMouse.PressACS(VSkey,UpDown:dword):boolean;
begin
     if UpDown=0 then
     begin
      if (GetAsyncKeyState(VSkey) <>-32767) then
      keybd_event(VSkey, 0, 0, 0);
     end;
     if UpDown=KEYEVENTF_KEYUP then
     begin
      if (GetAsyncKeyState(VSkey) <>0) then
       keybd_event(VSkey, 0, KEYEVENTF_KEYUP, 0);
     end;
end;

function TThread_Connection_Main.TThread_Redirect_KeyMouse.SendCharKeys(SendKeysString: string): Boolean;
var
  sTmp:string;
  Lres,Hres:dword;
  Skey,Scode:integer;
procedure SendKey(Vkey,ScanCode:dword);
  var
  IpKey:  Tinput;
  KeyPr: TKeybdInput;
  KeyBoardState: TKeyboardState;
 begin
   if (VKey = VK_NUMLOCK{144}) then //NumLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[vk_NumLock]=0))or((KeyBoardState[vk_NumLock]=1)) then
        begin
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey,0);
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(vk_NumLock)=1 then // после виртуального нажатия возвращает предыдущее состояние клавиши, почему ХЗ. Если проверить после то будет 1-вкл 0-выкл
         NumL:=true else NumL:=false;
        end;
      end
     else
     if (VKey = VK_CAPITAL{20}) then //CapsLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_CAPITAL]=0))or((KeyBoardState[VK_CAPITAL]=1)) then
        begin
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_CAPITAL)=1 then CapsL:=true
        else CapsL:=false;
        end;
      end
    else
       if (VKey = VK_SCROLL{145}) then //ScrollLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_SCROLL]=0))or((KeyBoardState[VK_SCROLL]=1)) then
        begin
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_SCROLL)=1 then ScrollL:=true
        else ScrollL:=false;
        end;
      end
  else
  begin
  KeyPr.wVk:=Vkey;
  KeyPr.wScan:=ScanCode;  //скан код физической клавиши.
  KeyPr.dwFlags:=0; //идентифицирует ключ как Down
  ZeroMemory(@IpKey,sizeof(IpKey));
  IpKey.Itype:=INPUT_KEYBOARD;
  ipKey.ki:=KeyPr;
  SendInput(1,ipKey,sizeOf(ipKey));
  KeyPr.dwFlags:=KEYEVENTF_KEYUP;
  ipKey.ki:=KeyPr;
  SendInput(1,ipKey,sizeOf(ipKey));
  end;
end;
BEGIN
try
sTmp:=copy(SendKeysString,1,pos(',',SendKeysString)-1);
if not trystrtoint(sTmp,Skey) then exit // если первые знаки до запятой не цифры то выходим
else
  begin
  Lres:=Lo(Skey); // в младшем байте хранится виртуальный ключ нажатой клавиши
  Hres:=Hi(Skey); // в старшем байте хранится состояние спец клавиш
  end;
sTmp:=copy(SendKeysString,pos(',',SendKeysString)+1,length(SendKeysString));
if trystrtoint(sTmp,SCode) then // получаем код сканирования клавиши
begin
 if Hres<>0 then  // нажимаем спец клавиши если старший байт не равен 0
   case Hres of
   1:if not CapsL then PressACS(VK_RSHIFT,0); // если CapsLock не нажат
   2:PressACS(VK_RCONTROL,0);
   4:PressACS(VK_RMENU,0);
   8:PressACS(VK_OEM_AUTO,0); //клавиша Hankaku - 0xF3 или 243
   end;
  SendKey(lres,Scode); // отправляем виртуальный ключ и скан ключ клавиши
 if Hres<>0 then  // отпускаем спец клавиши если старший байт не равен 0
   case Hres of
   1:if not CapsL then PressACS(VK_RSHIFT,KEYEVENTF_KEYUP); // если capslock не нажат
   2:PressACS(VK_RCONTROL,KEYEVENTF_KEYUP);
   4:PressACS(VK_RMENU,KEYEVENTF_KEYUP);
   8:PressACS(VK_OEM_AUTO,KEYEVENTF_KEYUP); //клавиша Hankaku - 0xF3 или 243
   end;
end;
//Log_Write('app',SendKeysString);
//Log_Write('app','Получаем Skey-'+inttostr(Skey)+': Scode-'+inttostr(Scode)+': Lres-'+inttostr(Lres));
except on E : Exception do
    begin
    ThLog_Write('ThKM',2,'SendInputKeyboard: ');
    end;
   end;
END;


function TThread_Connection_Main.TThread_Redirect_KeyMouse.MousePress(x,y:integer;MousFlags:Dword;MouseData:DWORD):boolean;
 var
  IpKey:  Tinput;
  MousePr: TMouseInput;
  x_tl,y_tl:integer;
begin
try
  MousePr.time:=0;
 // MousePr.dwExtraInfo:=GetMessageExtraInfo;
  MousePr.dwFlags:=MousFlags; //Набор битовых флагов, которые определяют различные аспекты движения мыши и щелчков кнопок
  //если MousFlags=MOUSEEVENTF_WHEEL  то mouseData= определяет величину перемещения колеса
  //если MousFlags=MOUSEEVENTF_XDOWN или MousFlags=MOUSEEVENTF_XUP  то  mouseData= какиа кнопка X были нажата или отпущена (XBUTTON1, XBUTTON2...)
  if (MousFlags=MOUSEEVENTF_WHEEL)or(MousFlags=MOUSEEVENTF_XDOWN)or(MousFlags=MOUSEEVENTF_XUP) then
  begin
  MousePr.mouseData:=MouseData;
  MousePr.dx:=0; //Абсолютное положение мыши или количество движений с момента создания последнего события мыши в зависимости от значения члена dwFlags
  MousePr.dy:=0; //Абсолютное положение мыши или количество движений с момента создания последнего события мыши в зависимости от значения члена dwFlags                            '
  end
  else
  begin
  MousePr.mouseData:=0;
  if frm_Main.MonitorVirtualCurrentWidth<>0 then // если получил координаты виртуального рабочего стола
    begin
    x_tl := ABS(x-frm_Main.MonitorVirtualLeftX);
    y_tl := ABS(y-frm_Main.MonitorVirtualLeftY);
    MousePr.dx:=MulDiv(x_tl, 65535, frm_Main.MonitorVirtualCurrentWidth - 1);
    MousePr.dy:= MulDiv(y_tl, 65535, frm_Main.MonitorVirtualCurrentHeight - 1);
    end
    else
    begin
    MousePr.dx:=MulDiv(x,65535 , frm_Main.MonitorCurrentWidth-1); //Абсолютное положение мыши или количество движений с момента создания последнего события мыши в зависимости от значения члена dwFlags
    MousePr.dy:=MulDiv(y,65535 , frm_Main.MonitorCurrentHeight-1); //Абсолютное положение мыши или количество движений с момента создания последнего события мыши в зависимости от значения члена dwFlags
    end;
  end;

  ZeroMemory(@IpKey,sizeof(IpKey));
  IpKey.Itype:=INPUT_MOUSE;
  ipKey.mi:=MousePr; // mi определяет события мыши
  if SendInput(1,ipKey,sizeOf(ipKey))=0 then
  begin
    result:=false;
    ThLog_Write('ThKM',2,'SendInput Error MousePress :'+SysErrorMessage(GetLastError()));
  end
  else result:=true;

except on E : Exception do
    begin
    ThLog_Write('ThKM',2,'SendInput MousePress ');
    end;
   end;
end;

function TThread_Connection_Main.TThread_Redirect_KeyMouse.MouseDblPress:boolean;
 var
  IpKey: array [0..3] of Tinput;
  MousePr: TMouseInput;
begin
 try
  ZeroMemory(@IpKey,sizeof(IpKey));

  MousePr.dx:=0;
  MousePr.dy:=0;
  MousePr.mouseData:=0;
  MousePr.time:=0;
  MousePr.dwExtraInfo:=GetMessageExtraInfo;

  IpKey[0].Itype:=INPUT_MOUSE;
  MousePr.dwFlags:=MOUSEEVENTF_LEFTDOWN;
  ipKey[0].mi:=MousePr; // mi определяет события мыши

  IpKey[1].Itype:=INPUT_MOUSE;
  MousePr.dwFlags:=MOUSEEVENTF_LEFTUP;
  ipKey[1].mi:=MousePr; // mi определяет события мыши

  IpKey[2].Itype:=INPUT_MOUSE;
  MousePr.dwFlags:=MOUSEEVENTF_LEFTDOWN;
  ipKey[2].mi:=MousePr; // mi определяет события мыши

  IpKey[3].Itype:=INPUT_MOUSE;
  MousePr.dwFlags:=MOUSEEVENTF_LEFTUP;
  ipKey[3].mi:=MousePr; // mi определяет события мыши
  if SendInput(4,ipKey[0],sizeOf(Tinput))=0 then
  begin
    result:=false;
    ThLog_Write('ThKM',2,'SendInput Error DoubleClick :'+SysErrorMessage(GetLastError()));
  end
  else result:=true;
except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThKM',2,'SendInput DoubleClick');
    end;
   end;
end;

function TThread_Connection_Main.TThread_Redirect_KeyMouse.MouseClick(SFlags:Cardinal):boolean;
 var
  IpKey:Tinput;
  MousePr: TMouseInput;
begin
 try
  ZeroMemory(@IpKey,sizeof(IpKey));

  MousePr.dx:=0;
  MousePr.dy:=0;
  MousePr.mouseData:=0;
  MousePr.time:=0;
  //MousePr.dwExtraInfo:=GetMessageExtraInfo;

  IpKey.Itype:=INPUT_MOUSE;
  MousePr.dwFlags:=SFlags;
  ipKey.mi:=MousePr; // mi определяет события мыши


  if SendInput(1,ipKey,sizeOf(Tinput))=0 then
  begin
    result:=false;
    ThLog_Write('ThKM',2,'SendInput Error Click :'+SysErrorMessage(GetLastError()));
  end
  else result:=true;
except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThKM',2,'SendInput DoubleClick');
    end;
   end;
end;


function TThread_Connection_Main.TThread_Redirect_KeyMouse.DesOpenInput(var FirstDesktop:HDESK):boolean;
 var
 hDesktop: HDESK;
 begin
 try
  ///-----------------------------------------------------------------------------------------
   result:=false;
   if not frm_Main.Accessed then exit; // если доступ разрешен то выолняем, иначе если мы клиент то это лишние действия
   hDesktop := OpenInputDesktop(0,true,MAXIMUM_ALLOWED); //Открывает рабочий стол, получающий входные данные пользователя.
   try
    if FirstDesktop<>hDesktop then
      begin
       if hDesktop<>0 then
         begin
         if not SetThreadDesktop(hDesktop)then //Назначает указанный рабочий стол вызывающему потоку.
         ThLog_write('ThKM',1,'Поток (K): Ошибка STD: '+SysErrorMessage(GetLastError()));
         result:=true;
         FirstDesktop:=hDesktop;
         end
         else
         begin
         ThLog_write('ThKM',1,'Поток (K): Ошибка OID: '+SysErrorMessage(GetLastError()));
         result:=false;
         end;
      end;
   finally
   CloseHandle(hDesktop);
   end;
  ///-----------------------------------------------------------------------------------------
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThKM',2,'Ошибка STD/OID потока (K)');
      end;
    end;
 end;

function TThread_Connection_Main.TThread_Redirect_KeyMouse.IsMouseBtnDown( MouseButton:integer): Boolean;// проверка состояния кнопок мыши
begin
try
 case MouseButton of
 VK_LBUTTON:  Result := (GetAsyncKeyState(VK_LBUTTON))and $8000 <> 0;
 VK_RBUTTON:  Result := (GetAsyncKeyState(VK_RBUTTON))and $8000 <> 0;
 VK_MBUTTON:  Result := (GetAsyncKeyState(VK_MBUTTON))and $8000 <> 0;
 end;
 except on E : Exception do
  begin
  Result := false;
  ThLog_Write('ThKM',2,'Ошибка IsMouseBtnDown потока (K)');
  end;
end;
end;

function TThread_Connection_Main.TThread_Redirect_KeyMouse.CleanMouseBtnDown: Boolean; //Сброс состояния кнопок мыши
begin
try
if IsMouseBtnDown(VK_MBUTTON) then MousePress(0, 0, MOUSEEVENTF_MIDDLEUP,0);
if IsMouseBtnDown(VK_RBUTTON) then MousePress(0, 0, MOUSEEVENTF_RIGHTUP or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK, 0);
if IsMouseBtnDown(VK_LBUTTON) then MousePress(0, 0, MOUSEEVENTF_LEFTUP or MOUSEEVENTF_ABSOLUTE  or MOUSEEVENTF_VIRTUALDESK,0);
 except on E : Exception do
  begin
  Result := false;
  ThLog_Write('ThKM',2,'Ошибка CleanMouseBtnDown потока (K)');
  end;
end;
end;

procedure TThread_Connection_Main.TThread_Redirect_KeyMouse.PressCtrlC;
const
VK_CONTROL = $11; VK_C = $43; KEYEVENTF_KEYUP = $02;
begin
try
 keybd_event(VK_CONTROL, 0, 0, 0); // Press the 'C' key
 keybd_event(VK_C, 0, 0, 0);
 keybd_event(VK_C, 0, KEYEVENTF_KEYUP, 0); // Release the Ctrl key
 keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
 except on E : Exception do
  begin
  ThLog_Write('ThKM',2,'Ошибка Ctrl+C');
  end;
end;
end;

procedure TThread_Connection_Main.TThread_Redirect_KeyMouse.Execute;
var
Exist:boolean;
hDesktop,CurentDesk: HDESK;
Buffer,BufferTemp:string;
KeyTemp:string;
Position,MousePosX,MousePosY:integer;
MouseButtonLeftDown:boolean; // нажата левая клавиша мыши
MouseButtonRightDown:boolean; // зажата правая клавиша мыши
TmpY,TmpX:integer;
LeftButDown:integer;
RightButDown:integer;
step:byte;
begin
try
ThLog_Write('ThKM',2,'Поток запущен');
CurentDesk:=0;
DesOpenInput(CurentDesk);//----------------------------------->
CleanMouseBtnDown; // очистка состояни кнопок мыши

//if IsMouseBtnDown(VK_LBUTTON) then MouseButtonLeftDown:=true
//else MouseButtonLeftDown:=false;
//if IsMouseBtnDown(VK_RBUTTON) then MouseButtonRightDown:=true
//else MouseButtonRightDown:=false;

MouseButtonRightDown:=false;
MouseButtonLeftDown:=false;

MousePosX:=0;
MousePosY:=0;
StrRedirect:=TThreadedQueue<string>.create(400,50,300); // созданее очереди сообщений клавы и мыши для обмена с другим потоком потоком/ удаляется при выходе из цикла в самом потоке
try
while not terminated do
  begin
  //DesOpenInput(CurentDesk);//----------------------------------->
    while (strRedirect.PopItem(Buffer)<>wrSignaled) do
    begin // спим в цикле пока не вернется wrSignaled сигнал о том что элемент добавлен в список
    if terminated then
     begin
     break;
     end;
     Sleep(2);
    end;
    step:=1;
    try
    DesOpenInput(CurentDesk);//----------------------------------->


     //-------------mouse-------------------------------------------------
    step:=2;
        Position := Pos('<|SETMOUSEDBLCLICK|>', Buffer);  //двойной клик
        if Position > 0 then
        begin
        //ThLog_Write('ThKM',2,'SETMOUSEDBLCLICK');
         MouseDblPress; // двойной клик
         // далее очищаем если пришел одиночный клик
        {Position := Pos('<|SETMOUSELEFTCLICKDOWN|>', Buffer); //<|SETMOUSELEFTCLICKDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>
         if Position>0 then
          begin
           Delete(Buffer, 1, Pos('<|END|>', Buffer)+6);
          end;
         Position := Pos('<|SETMOUSELEFTCLICKUP|>', Buffer);
          if Position>0 then
          begin
           Delete(Buffer, 1, Pos('<|END|>', Buffer)+6);
          end;}
        end;
    step:=3;

         Position := Pos('<|SETMOUSEPOS|>', Buffer);  //позиция мыши
        if Position > 0 then
        begin
          try
            BufferTemp := Buffer;
            Position := Pos('<|SETMOUSEPOS|>', BufferTemp);
            Delete(BufferTemp, 1, Position + 14);
            Position := Pos('<|>', BufferTemp);
            if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
            Delete(BufferTemp, 1, Position + 2);
            if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
            //SetCursorPos(MousePosX, MousePosY); api функция перемещения указателя в позицию XY

           if MouseButtonLeftDown then
              begin
              MousePress(MousePosX, MousePosY, MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0) // перемещение курсора с зажатой кнопкой
              end
            else
            if MouseButtonRightDown then
              begin
              MousePress(MousePosX, MousePosY, MOUSEEVENTF_RIGHTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0) // перемещение курсора с зажатой кнопкой
              end
            else MousePress(MousePosX, MousePosY, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0); // перемещение курсора

          // Position := Pos('<|SETMOUSEPOS|>', Buffer);
          // while Position > 0 do
          //  begin
          //  Delete(BufferTemp, 1, Position + 14);
          //  Position := Pos('<|>', BufferTemp);
          //  if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          //  Delete(BufferTemp, 1, Position + 2);
          //  if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //   MousePress(MousePosX, MousePosY, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0); // перемещение курсора
          //   Position := Pos('<|SETMOUSEPOS|>', BufferTemp);
          //  end;
           except on E : Exception do
           begin
           ThLog_Write('ThKM',2,'('+inttostr(step)+') Ошибка данных (KM) MOUSEPOS');
           end;
          end;
        end;

        Position := Pos('<|SETMOUSELEFTCLICKDOWN|>', Buffer); //нажата левая копка мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 24);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          //Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
          MouseButtonLeftDown:=true;
          MousePress(MousePosX, MousePosY, MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK or MOUSEEVENTF_MOVE,0);
         //MouseClick(MOUSEEVENTF_LEFTDOWN {or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK});
        end;
    step:=4;
        Position := Pos('<|SETMOUSELEFTCLICKUP|>', Buffer);   //отпущена левая кнопка мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 22);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          //Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, MousePosX, MousePosY, 0, 0);
          MouseButtonLeftDown:=false;
          MousePress(MousePosX, MousePosY, MOUSEEVENTF_LEFTUP or MOUSEEVENTF_ABSOLUTE  or MOUSEEVENTF_VIRTUALDESK or MOUSEEVENTF_MOVE,0);
          //MouseClick( MOUSEEVENTF_LEFTUP {or MOUSEEVENTF_ABSOLUTE  or MOUSEEVENTF_VIRTUALDESK});
        end;
    step:=5;
        Position := Pos('<|SETMOUSERIGHTCLICKDOWN|>', Buffer); // нажата правая кнопка мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 25);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          //Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, MousePosX, MousePosY, 0, 0);
          MouseButtonRightDown:=true;
          MousePress(MousePosX, MousePosY, MOUSEEVENTF_RIGHTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK or MOUSEEVENTF_MOVE,0);
          //MouseClick(MOUSEEVENTF_RIGHTDOWN {or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK});
        end;
    step:=6;
        Position := Pos('<|SETMOUSERIGHTCLICKUP|>', Buffer);    // отпущена правая кнопка мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 23);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          //Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
          MouseButtonRightDown:=false;
          MousePress(MousePosX, MousePosY, MOUSEEVENTF_RIGHTUP or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK or MOUSEEVENTF_MOVE, 0);
          //MouseClick(MOUSEEVENTF_RIGHTUP{ or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_VIRTUALDESK});
        end;
    step:=7;
        Position := Pos('<|SETMOUSEMIDDLEDOWN|>', Buffer); // нажали колесо на мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 21);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
          //MousePress(0, 0, MOUSEEVENTF_MIDDLEDOWN,0);
        end;
    step:=8;
        Position := Pos('<|SETMOUSEMIDDLEUP|>', Buffer);// отпустили колесо мыши
        if Position > 0 then
        begin
          BufferTemp := Buffer;
          Delete(BufferTemp, 1, Position + 19);
          Position := Pos('<|>', BufferTemp);
          if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          Delete(BufferTemp, 1, Position + 2);
          if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //SetCursorPos(MousePosX, MousePosY);
          //Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
          MousePress(0, 0, MOUSEEVENTF_MIDDLEUP,0);
        end;
    step:=9;
        Position := Pos('<|WHEELMOUSE|>', Buffer);// колесо перемонтки мыши
        if Position > 0 then
        begin
          try
            BufferTemp := Buffer;
            while Position > 0 do
            begin
            Delete(BufferTemp, 1, Position + 13);
            BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
            //Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(StrToInt(BufferTemp)), 0);
            MousePress(0, 0, MOUSEEVENTF_WHEEL,DWORD(StrToInt(BufferTemp)));
            Position := Pos('<|WHEELMOUSE|>', BufferTemp);
            end;
          except on E : Exception do
           begin
           ThLog_Write('ThKM',2,'('+inttostr(step)+') Ошибка данных (KM) WHEELMOUSE');
           end;
          end;
        end;
    step:=10;
      {  Position := Pos('<|SETMOUSEPOS|>', Buffer);  //позиция мыши
        if Position > 0 then
        begin
          try
           BufferTemp := Buffer;
           Delete(BufferTemp, 1, Position + 14);
            Position := Pos('<|>', BufferTemp);
            if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
            Delete(BufferTemp, 1, Position + 2);
            if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
           if MouseButtonLeftDown then
              begin
              MousePress(MousePosX, MousePosY, MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0) // перемещение курсора с зажатой кнопкой
              end
            else
            if MouseButtonRightDown then
              begin
              MousePress(MousePosX, MousePosY, MOUSEEVENTF_RIGHTDOWN or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0) // перемещение курсора с зажатой кнопкой
              end
            else MousePress(MousePosX, MousePosY, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0); // перемещение курсора

          // Position := Pos('<|SETMOUSEPOS|>', Buffer);
          // while Position > 0 do
          //  begin
          //  Delete(BufferTemp, 1, Position + 14);
          //  Position := Pos('<|>', BufferTemp);
          //  if trystrtoint(Copy(BufferTemp, 1, Position - 1),TmpX) then MousePosX:=TmpX;
          //  Delete(BufferTemp, 1, Position + 2);
          //  if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpY) then MousePosY:=TmpY;
          //   MousePress(MousePosX, MousePosY, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE or MOUSEEVENTF_VIRTUALDESK,0); // перемещение курсора
          //   Position := Pos('<|SETMOUSEPOS|>', BufferTemp);
          //  end;
           exgin
           ThLog_Write('ThKM',2,'('+inttostr(step)+') Ошибка данных (KM) MOUSEPOS');
           endcept on E : Exception do
           be;
          end;

        end;}

    step:=11;
       // ---------------------------keyboard ----------------------------------------------------------------------------------------------
         if Buffer.Contains('<|CTRL+C|>') then
        begin
          Buffer := StringReplace(Buffer, '<|CTRL+C|>', '', [rfReplaceAll]);
          PressCtrlC;
        end;

         if Buffer.Contains('<|LALTDOWN|>') then
        begin
          Buffer := StringReplace(Buffer, '<|LALTDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_LMENU,0);
        end;
    step:=12;
         if Buffer.Contains('<|LALTUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|LALTUP|>', '', [rfReplaceAll]);
          PressACS(VK_LMENU,KEYEVENTF_KEYUP);
        end;
    step:=13;
        //RightAlt
         if Buffer.Contains('<|RALTDOWN|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RALTDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_RMENU,0);
        end;
    step:=14;
         if Buffer.Contains('<|RALTUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RALTUP|>', '', [rfReplaceAll]);
          PressACS(VK_RMENU,KEYEVENTF_KEYUP)
        end;
    step:=15;
        //LeftCtrl
        if Buffer.Contains('<|LCTRLDOWN|>') then
        begin

          Buffer := StringReplace(Buffer, '<|LCTRLDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_LCONTROL,0);
        end;
    step:=16;
        if Buffer.Contains('<|LCTRLUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|LCTRLUP|>', '', [rfReplaceAll]);
          PressACS(VK_LCONTROL,KEYEVENTF_KEYUP);
        end;
    step:=17;
        //RightCtrl
        if Buffer.Contains('<|RCTRLDOWN|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RCTRLDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_RCONTROL,0);
        end;
    step:=18;
        if Buffer.Contains('<|RCTRLUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RCTRLUP|>', '', [rfReplaceAll]);
          PressACS(VK_RCONTROL,KEYEVENTF_KEYUP);
        end;
    step:=19;
        //LeftShift
        if Buffer.Contains('<|LSHIFTDOWN|>') then
        begin
          Buffer := StringReplace(Buffer, '<|LSHIFTDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_LSHIFT,0);
        end;
    step:=20;
        if Buffer.Contains('<|LSHIFTUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|LSHIFTUP|>', '', [rfReplaceAll]);
          PressACS(VK_LSHIFT,KEYEVENTF_KEYUP);
        end;
    step:=21;
         //RightShift
          if Buffer.Contains('<|RSHIFTDOWN|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RSHIFTDOWN|>', '', [rfReplaceAll]);
          PressACS(VK_RSHIFT,0);
        end;
    step:=22;
        if Buffer.Contains('<|RSHIFTUP|>') then
        begin
          Buffer := StringReplace(Buffer, '<|RSHIFTUP|>', '', [rfReplaceAll]);
          PressACS(VK_RSHIFT,KEYEVENTF_KEYUP);
        end;
    step:=23;
        if Buffer.Contains('<|KEYPRS|>') then  // <|KEYPRS|>...<|KPEND|>
         begin
           BufferTemp:=Buffer;
           delete(BufferTemp,1,pos('<|KEYPRS|>',BufferTemp)+9);
           KeyTemp:=copy(BufferTemp,1,pos('<|KPEND|>',BufferTemp)-1);
           SendCharKeys(KeyTemp);
           BufferTemp:='';
           KeyTemp:='';
         end;
     //if terminated then break;
    except on E : Exception do
      begin
      ThLog_Write('ThKM',2,'('+inttostr(step)+') Ошибка данных (KM) ');
      end;
     end;
    Buffer:='';
  // if terminated then break;     // выход из цикла по завершению нажатия всех кнопок
  end;
finally
CleanMouseBtnDown; // очистка состояни кнопок мыши
StrRedirect.Free;
end;
ThLog_Write('ThKM',2,' Завершение токота (KM)');
except on E : Exception do
    begin
    ThLog_Write('ThKM',2,'Ошибка потока (KM)');
    end;
   end;
end;

constructor TThread_Connection_Main.TThread_Connection_Desktop.Create(aSocket: TCustomWinSocket; aInOut:boolean; aIDConect:byte);
begin
  inherited Create(False);
  DesktopSocket := aSocket;
  IDConnect:=aIDConect;
  InOut:=aInOut;
  frm_Main.Accessed := False;
  BindSockDesktop:=false; //признак связывания сокетов на сервере
  StartThreadBegin:=false;  // признак возврата потока в начальный цикл
  ClearReciveBuf:=false; // признак необходимости очистки входящего буфера
  TmpHdl:=DesktopSocket.Handle;
  FreeOnTerminate := true;
end;

function  TThread_Connection_Main.TThread_Connection_Desktop.GetBindSockDesktop:boolean; // чтение свойства признака связывания сокетов
begin
 result:=BindSockDesktop;
end;

Procedure  TThread_Connection_Main.TThread_Connection_Desktop.SetBindSockDesktop(BindS:boolean); // запись свойства признака связывания сокетов
begin
 BindSockDesktop:=BindS;
end;


constructor TThread_Connection_Main.TThread_Connection_Files.Create(aSocket: TCustomWinSocket; aIDConect:byte);
begin
  inherited Create(False);
  FileSocket := aSocket;
  IDConnect:=aIDConect;
  BindSockFiles:=false; //признак связывания сокетов на сервере
  FreeOnTerminate := true;
end;

function  TThread_Connection_Main.TThread_Connection_Files.GetBindSockFiles:boolean; // чтение свойства признака связывания сокетов
begin
 result:=BindSockFiles;
end;

Procedure  TThread_Connection_Main.TThread_Connection_Files.SetBindSockFiles(BindS:boolean); // запись свойства признака связывания сокетов
begin
 BindSockFiles:=BindS;
end;
//-------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------


procedure TThread_Connection_Main.FullDesktopSocketReconnect;
var
Exist:boolean;
begin
//ThLog_Write('ThM',' Пересоздание сокета (D)');
  try
      try
      Exist:=false;
        if Desktop_Socket<>nil then
        if Desktop_Socket.Active then Exist:=true;
       // if Exist then ThLog_Write('ThM',' Пересоздание сокета (D). Desktop_Socket.Active=true')
      //  else ThLog_Write('ThM',' Пересоздание сокета (D). Desktop_Socket.Active=false')
       except on E : Exception do
        begin
        Exist:=false;
        //ThLog_Write('ThM',' (1) Повторное создания сокета (D): '+E.ClassName+': '+E.Message);
        end;
        end;
  //if not Exist then // если сокет не активный
     begin
     DeleteDesktopSockets;   // сначала удаляем, вдруг он остался
     if CreateDesktopSocs then  // создаем сокет desktop
     ApplySetConnectDesktop(frm_Main.ArrConnectSrv[IDConnect].SrvAdr,frm_Main.ArrConnectSrv[IDConnect].SrvPort); // применяем настройки Desktop сокета и подключаемся
     end;
  except on E : Exception do
    begin
    ThLog_Write('ThM',2,'(2) Повторное создания сокета (D): ');
    end;
   end;
end;




procedure TThread_Connection_Main.FullFilesSocketReconnect;
var
Exist:boolean;
begin
//ThLog_Write('ThM',' Пересоздание сокета (F)');
  try
      try
      Exist:=false;
        if Files_Socket<>nil then
        if Files_Socket.Active then Exist:=true;
       except on E : Exception do
        begin
        Exist:=false;
        //ThLog_Write('ThM',' (1) Повторное создания сокета (F): '+E.ClassName+': '+E.Message);
        end;
        end;
  if not Exist then // если сокет не активный
     begin
     DeleteFileSockets;   // сначала удаляем, вдруг он остался
     if CreateFileSocs then  // создаем сокет File
     ApplySetConnectFile(frm_Main.ArrConnectSrv[IDConnect].SrvAdr,frm_Main.ArrConnectSrv[IDConnect].SrvPort); // применяем настройки File сокета и подключаемся
     end;
  except on E : Exception do
    begin
    ThLog_Write('ThM',2,'(2) Повторное создания сокета (F)');
    end;
   end;
end;

//----------------------------------------------------------------------------------------------------
// Процедуры и функции основного потока
//------------------------------------------------------------------------------------------------------
function TThread_Connection_Main.FormatByteSize(const bytes: int64): string; // приводим размер файла к читабельному
const
  B = 1; //byte
  KB = 1024 * B; //kilobyte
  MB = 1024 * KB; //megabyte
  GB = 1024 * MB; //gigabyte
begin
try

  if bytes > KB then
    result := FormatFloat('#.## KB', bytes / KB)
  else
    result := '1 KB';
 { if bytes > GB then
    result := FormatFloat('#.## GB', bytes / GB)
  else if bytes > MB then
    result := FormatFloat('#.## MB', bytes / MB)
  else if bytes > KB then
    result := FormatFloat('#.## KB', bytes / KB)
  else
    result := FormatFloat('#.## bytes', bytes);}

except result:=''  end;
end;

function TThread_Connection_Main.GetFileSize(const aFilename: String): String;  // размер файла  int64
var
  sr : TSearchRec;
begin
  try
    if FindFirst(aFilename, faAnyFile, sr ) = 0 then
    begin
       Result:=FormatByteSize(Sr.Size);
    end
    else
    begin
       result :='';
    end;
    FindClose(sr);
  except result:=''  end;
end;

function TThread_Connection_Main.LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string;
begin
try
 if FileOrFolder then result:=DateTimeToStr(TFile.GetLastWriteTime(s))
 else result:=DateTimeToStr(TDirectory.GetLastWriteTime(s));
except result:=''  end;
end;

function TThread_Connection_Main.ListFolders(Directory: string): string; // чтение каталогов
var
  FileName: string;
  Dirlist: TstringList;
  Searchrec: TWin32FindData;
  FindHandle: THandle;
  ReturnStr: string;
begin
 try
  ReturnStr := '';
  try
    Dirlist:= TstringList.Create;
    FindHandle := FindFirstFile(PChar(Directory + '*.*'), Searchrec);
    if FindHandle <> INVALID_HANDLE_VALUE then
      repeat
        FileName := Searchrec.cFileName;
        if (FileName = '.') then
          Continue;
        if ((Searchrec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        begin
          Dirlist.add(FileName+'='+LastWriteTimeFileOrFolder(Directory+FileName,false)); // имя каталога=дата изменения
        end;
      until FindNextFile(FindHandle, Searchrec) = False;
  finally
    Winapi.Windows.FindClose(FindHandle);
    if Dirlist.Count>0 then result:=Dirlist.CommaText
    else result:='';
    Dirlist.Free;
  end;
  except on E : Exception do ThLog_Write('ThM',2,'Ошибка ListFolders: '+E.ClassName+': '+E.Message);  end;
end;

function TThread_Connection_Main.ParsingFileDateSize(InS:string; var OutD,OutS:string):boolean;  // функция парсинга строки  "дата и время+размер"
var
position:integer;
Tmps:string;
begin  //LastWriteTimeFileOrFolder(FileName+SearchFile.Name,true)+'='+GetFileSize(FileName+SearchFile.Name)
 try
 position:=pos('=',Ins);
 OutD:=copy(InS,1,position-1);
 delete(Ins,1,Position);
 OutS:=copy(InS,1,length(InS));
 except OutD:='';OutS:=''; end;
end;

function TThread_Connection_Main.ListFiles(FileName, Ext: string; var ListFile:TstringList): boolean;  // чтение списка файлов
var
  SearchFile: TSearchRec;
  FindResult: Integer;
begin
 try
  FindResult := FindFirst(FileName + Ext, faArchive, SearchFile);
  try
    while FindResult = 0 do
    begin
      ListFile.Add(SearchFile.Name+'='+LastWriteTimeFileOrFolder(FileName+SearchFile.Name,true)+'='+GetFileSize(FileName+SearchFile.Name));  // имя файла=дата изменения
      FindResult := FindNext(SearchFile);
    end;
  finally
    FindClose(SearchFile);
    if ListFile.Count>0 then result:=true
    else result:=false;
  end;
 except on E : Exception do
  begin
  result:=false;
  ThLog_Write('ThM',2,'Ошибка ListFiles: '+E.ClassName+': '+E.Message);
  end;
 end;
end;

function TThread_Connection_Main.ListLogDrive:string; // возвращает список локальных дисков
var
s:string;
TmpList:TstringList;

function GetSysDir(drv:string): boolean; //
  var
    buf: array[0..MAX_PATH] of Char;
    res:string;
    position:byte;
 begin
 try
  GetSystemDirectory(buf, SizeOf(buf));
  res := (buf);
  position:=pos(drv,res);
  if position=1 then result:=true
   else result:=false;
 except result:=false; end;
 end;

function TypeDiskDrive(s:string):integer;
var
i:cardinal;
  begin
   try
    i:=GetDriveType(Pchar(s));
    case i of
     DRIVE_UNKNOWN{0}:result:=8; // неизвестный диск
     DRIVE_NO_ROOT_DIR {1}:result:=8;//не верный символ диска
     DRIVE_REMOVABLE{2}:result:=4;// usb диск
     DRIVE_FIXED{3}:result:=2;//локальный диск на HDD
     DRIVE_REMOTE{4}:result:=6;// сетевой диск
     DRIVE_CDROM{5}:result:=5;// cd/DVD rom
     DRIVE_RAMDISK{6}:result:=7;// RAM диск
     else result:=2;
    end;
    if GetSysDir(s) then result:=3; // если это диск с установленной ОС
   except result:=2  end;
  end;
BEGIN
  try
   TmpList:=TstringList.Create;
   try
   for s in TDirectory.GetLogicalDrives do TmpList.Add(s+'='+inttostr(TypeDiskDrive(s)));
   result:=TmpList.CommaText;
   finally
   TmpList.Free;
   end;
  except on E : Exception do ThLog_Write('ThM',2,'Ошибка ListlogDrive: '+E.ClassName+': '+E.Message);  end;
END;

function TThread_Connection_Main.GetSize(bytes: Int64): string;  // расчет оъемов и перевод в текст
begin
  if bytes < 1024 then
    Result := IntToStr(bytes) + ' B'
  else if bytes < 1048576 then
    Result := FloatToStrF(bytes / 1024, ffFixed, 10, 1) + ' KB'
  else if bytes < 1073741824 then
    Result := FloatToStrF(bytes / 1048576, ffFixed, 10, 1) + ' MB'
  else if bytes > 1073741824 then
    Result := FloatToStrF(bytes / 1073741824, ffFixed, 10, 1) + ' GB';
end;

function TThread_Connection_Main.GetSizeByte(bytes: Int64): Int64;  // расчет оъемов и перевод в байты, Кбайты, Мбайты
begin
  if bytes < 1024 then  Result := bytes    // B
  else if bytes < 1048576 then Result := bytes div 1024 // ' KB'
  else if bytes < 1073741824 then Result := bytes div 1048576// ' MB'
  else if bytes > 1073741824 then Result := bytes div 1073741824 //' GB';
end;


function TThread_Connection_Main.CreateDesktopSocs:boolean;   // создание desktop сокета
begin
 try
  Desktop_Socket := TClientSocket.Create(nil);
  Desktop_Socket.Active := False;
  Desktop_Socket.ClientType := ctBlocking;
  Desktop_Socket.OnConnect := Desktop_SocketConnect;
  Desktop_Socket.OnError := Desktop_SocketError;
  Desktop_Socket.OnDisconnect:=Desktop_SocketDisconnect;
  result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThM',2,'Ошибка создания (D) сокета ');
    end;
  end;
end;

function TThread_Connection_Main.CreateFileSocs:boolean;   // создание file сокета
begin
 try
  Files_Socket := TClientSocket.Create(nil);
  Files_Socket.Active := False;
  Files_Socket.ClientType := ctBlocking;
  Files_Socket.OnConnect := Files_SocketConnect;
  Files_Socket.OnError := Files_SocketError;
  Files_Socket.OnDisconnect:=Files_SocketDisconnect;
  result:=true;
   except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThM',2,'Ошибка создания (F) сокета');
    end;
  end;
end;
//-------------------------------------------------------------------------------------------------------
procedure TThread_Connection_Main.ReconnectDesktop; // Переподключение Desktop сокета
begin
try
 if Desktop_Socket<>nil then //
  if not Desktop_Socket.Active then
  Desktop_Socket.Active:=true;
 except on E : Exception do
    begin
    ThLog_Write('ThM',2,'Ошибка переподключения (D) сокета');
    end;
  end;
end;

procedure TThread_Connection_Main.ReconnectFile; //
begin
try
 if Files_Socket<>nil then
  if not Files_Socket.Active then
   Files_Socket.Active:=true;
 except on E : Exception do
    begin
    ThLog_Write('ThM',2,'Ошибка переподключения (F) сокета');
    end;
  end;
end;
//-----------------------------------------------------------------------------------------------------------

function TThread_Connection_Main.ApplySetConnectDesktop(Host:string;Port:integer):boolean; // применение настроек Desktop сокета
begin
  try
    Desktop_Socket.Host := Host;
    Desktop_Socket.Port := Port;
    frm_Main.ResolutionTargetWidth := screen.Width-((screen.Width div 100)*40); // разрешение рабочего стола сервера
    frm_Main.ResolutionTargetHeight := screen.Height-((screen.Height div 100)*40); // разрешение рабочего стола сервера
    frm_Main.ResolutionTargetLeft:=0;
    frm_Main.ResolutionTargetTop:=0;
    frm_Main.MonitorCurrent:=0;
    frm_Main.ImagePixelF:=pf8bit;
    ReconnectDesktop;  // переподключение Desktop сокета
    result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThM',2,'Ошибка применения настроек сокетов');
    end;
  end;
end;

function TThread_Connection_Main.ApplySetConnectFile(Host:string;Port:integer):boolean; // применение настроек File сокета
begin
  try
    Files_Socket.Host := Host;
    Files_Socket.Port := Port;
    ReconnectFile;  // переподключение File сокета
    result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThM',2,'Ошибка применения настроек сокетов');
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------
function TThread_Connection_Main.CloseMainSocket:boolean; // закрытие Main сокета
begin
try
  if MainSocket<>nil then
  begin
  if MainSocket.Connected then  MainSocket.Close;
  end;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Удаление (M) сокета');
  end;
  end;
end;


function TThread_Connection_Main.DeleteDesktopSockets:boolean; // удаление Desktop сокета
begin
try
  //ThLog_Write('ThM','Удаление (D) сокета: ');
 if Desktop_Socket<>nil then
  begin
  //ThLog_Write('ThM','Удаление (D) сокета: Desktop_Socket<>nil');
  if Desktop_Socket.Active then Desktop_Socket.Close;
  if Desktop_Socket<>nil then Desktop_Socket:=nil;
  end;
   //frm_Main.Viewer:=false;   //отменяем признак открытия окна управления если я управляю абонентом
  // Accessed := False; //отменяем признак разрешения доступа если я сервер
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Удаление (D) сокета');
  end;
  end;
end;

function TThread_Connection_Main.DeleteFileSockets:boolean; // удаление File сокета
begin
try
   if Files_Socket<>nil then
  begin
  if Files_Socket.Active then Files_Socket.Close;
  if Files_Socket<>nil then Files_Socket:=nil;
  end;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Удаление (F) сокета');
  end;
  end;
end;

function TThread_Connection_Main.CloseFileSockets:boolean; // узакрытие File сокета
begin
try
   if Files_Socket<>nil then
  begin
  if Files_Socket.Active then Files_Socket.Close;
  end;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Ошибка закрытия (F) сокета');
  end;
  end;
end;

function TThread_Connection_Main.CloseDesktopSockets:boolean; // закрытие Desktop сокета
begin
try
 result:=false;
 if Desktop_Socket<>nil then
 if Desktop_Socket.Active then
  begin
  Desktop_Socket.Close;
  result:=true;
  end;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Ошибка закрытия (D) сокета');
  end;
  end;
end;

function TThread_Connection_Main.ExistsFileSockets:boolean; // проверка сокета на активность
begin
try
result:=false;
  if Files_Socket<>nil then
  if Files_Socket.Active then result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Проверка активности сокета (F)');
  end;
  end;
end;

function TThread_Connection_Main.ExistsDektopSockets:boolean; // проверка сокета на активность
begin
try
result:=false;
  if Desktop_Socket<>nil then
  if Desktop_Socket.Active then result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThM',2,'Проверка активности сокета (D)');
  end;
  end;
end;

//--------------------------------------------------------------------------------------------------------
procedure TThread_Connection_Main.Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
Buffer,CryptBuf,DeCryptBuf,CryptText:string;
TimeOutExit:integer;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////PswdServer - при подключении использовать пароль сервера для шифрования и расшифровки
begin
Encryptstrs(s,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,CryptBuf); // при установке соединения используем пароль сервера
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(ProcessingSlack);
end;
function SendNoCrypText(s:string):boolean;
begin
Socket.SendText(s);
end;

function SDecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,pswd,DecryptTmp); //дешифровка скопированной строки
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
    ThLog_Write('ThM',2,'Files_Connect Ошибка дешифрации данных ');
     s:='';
    end;
  end;
end;


begin    //Если подключено, то отправить MyID для идентификации на Сервере для передачи файлов и создать поток
  try
  TimeOutExit:=0;
  if FindArraysrv(Socket.RemoteAddress,IndexArr) then // если получили индекс массива то создаем поток
     begin                           //frm_Main.MyID
      SendCrypText('<|FILESSOCKET|>'+frm_Main.ArrConnectSrv[IndexArr].MyID+'<|END|>'+frm_Main.ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>'); // открыть сокет для передачи файлов
     end
   else
     begin
     ThLog_Write('ThM',1,'Подключение (F) к серверу '+ Socket.RemoteAddress+' закрывавется из-за некорректного получения индекса массива подключений, повторите подключение к серверу');
     Socket.Close;
     exit;
     end;

  while True do
   begin
    Application.ProcessMessages; // чтобы не зависло нах
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
   if TimeOutExit>1050 then // примерно 10 сек
    begin
    ThLog_Write('ThM',0,'Подключение (F) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
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
    //ThLog_Write('ThM',2,'Получил сокет (F) до расшифровки: '+DecryptBuf);
    Buffer:=SDecryptReciveText(DecryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd);
    //Decryptstrs(DeCryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // дешифрация
    //ThLog_Write('ThM',2,'Получил сокет (F) после расшифровки: '+Buffer);

    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
       frm_Main.ArrConnectSrv[IndexArr].FilesSock:=socket;
       Thread_Connection_Files := TThread_Connection_Files.Create(Socket,IndexArr); // передача текущего сокета в поток
       break; // выход из цикла
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
      begin
      ThLog_Write('ThM',0,'Подключение (F) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неверно указанного пароля для подключения к серверу');
      Socket.Close;
      exit;
      end;


   TimeOutExit:=TimeOutExit+ProcessingSlack;
   end;

  ///Log_Write('app','Files_Socket соединение установлено, Thread_Connection_Files - запущен');
  except on E : Exception do
   ThLog_Write('ThM',2,'Ошибка при подключении сокета (F): ');
  end;
end;

procedure TThread_Connection_Main.Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
ThLog_Write('ThM',0,'Ошибка сокета (F): ' + SysErrorMessage(ErrorCode));
ErrorCode := 0;
except on E : Exception do
  ThLog_Write('ThM',2,'Ошибка сокета (F)');
  end;
end;

procedure TThread_Connection_Main.Files_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  if Thread_Connection_Files<>nil then Thread_Connection_Files.Terminate; // признак завершения потока
  if ReconnectFileSocketCount>10 then  //за один сеанс связи не более 11 повторений связать файловые сокеты при их disconnect
  begin
  RecreateFileSocket:=false; // убираем признак необходимости пересоздания файлового сокета
  ReconnectFileSocketCount:=0; // обнуляем текущее кол-во переподключений файлового сокета
  end;
  if RecreateFileSocket then
  begin
  FullFilesSocketReconnect; //если в майн потоке стоит признак пересоздания сокета если он отключился то создаем подлючение повторно
  inc(ReconnectFileSocketCount);
  end
   else CloseFileSockets;  // иначе закрываем файловый сокет
  //ThLog_Write('ThM','Отключение сокета (F): ');
  except on E : Exception do
   ThLog_Write('ThM',2,'Ошибка отключения сокета (F)');
  end;
end;

//------------------------------------------------------------------------------------------------------------------
procedure TThread_Connection_Main.Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
TimeOutExit:integer;
buffer,CryptBuf,DeCryptBuf,CryptText:string;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////PswdServer - при подключении использовать пароль сервера для шифрования и расшифровки
begin
Encryptstrs(s,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,CryptBuf);  // при установке соединения используем пароль сервера
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(ProcessingSlack);
end;


function SDecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,pswd,DecryptTmp); //дешифровка скопированной строки
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
    ThLog_Write('ThM',2,'Desktop_Connect Ошибка дешифрации данных ');
     s:='';
    end;
  end;
end;

begin
try
  TimeOutExit:=0;
 //  Если подключено, то отправить MyID для идентификации на Сервере и создать поток
  if FindArraysrv(Socket.RemoteAddress,IndexArr) then // если получили индекс массива то создаем поток
     begin                            // frm_Main.MyID
     SendCrypText('<|DESKTOPSOCKET|>' + frm_Main.ArrConnectSrv[IndexArr].MyID + '<|END|>'+frm_Main.ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>');
     end
   else
     begin
     ThLog_Write('ThM',1,'Подключение (D) к серверу '+ Socket.RemoteAddress+' закрывавется из-за некорректного получения индекса массива подключений, повторите подключение к серверу');
     Socket.Close;
     exit;
     end;
  while True do
   begin
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
    if TimeOutExit>1050 then // примерно 10 сек
      begin
      ThLog_Write('ThM',0,'Подключение (D) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
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

   // ThLog_Write('ThM',2, 'Сокет (D) до расшифровки: '+DecryptBuf );
    Buffer:=SDecryptReciveText(DecryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd);
    //Decryptstrs(DeCryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // дешифрация
    // ThLog_Write('ThM',2, 'Сокет (D) после расшифровки: '+Buffer );

    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
      frm_Main.ArrConnectSrv[IndexArr].DesktopSock:=socket;
      Thread_Connection_Desktop := TThread_Connection_Desktop.Create(Socket,true,IndexArr); // предаем текущий сокет (Desktop_Socket) для передачи и приема картинки
      frm_Main.CurrentActivMainSocket:=IndexArr; //при connect desktop присваиваем текущий элемент массива для доступа к главному сокету управления, при disconnect desktop передаем -1, т.е. сокет для управления не активный
      break; // выход из цикла
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
       begin
       ThLog_Write('ThM',0,'Подключение (D) к серверу '+ Socket.RemoteAddress+' закрывавется из-за неверно указанного пароля для подключения к серверу');
       Socket.Close;
       exit;
       end;
   TimeOutExit:=TimeOutExit+ProcessingSlack;
   end;

 // Log_Write('app','Desktop_Socket соединение установлено, Thread_Connection_Desktop - запущен');
  except on E : Exception do
  ThLog_Write('ThM',2,'Ошибка при подключении сокета (D)');
  end;
  end;

procedure TThread_Connection_Main.Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
ThLog_Write('ThM',1,'Ошибка сокета (D): ' + SysErrorMessage(ErrorCode));
ErrorCode := 0;
 except on E : Exception do
   ThLog_Write('ThM',2,'Ошибка сокета (D)');
  end;
end;

procedure TThread_Connection_Main.Desktop_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  if Thread_Connection_Desktop<>nil then
  begin
  //ThLog_Write('ThM','Thread_Connection_Desktop<>nil из Desktop_SocketDisconnect');
  Thread_Connection_Desktop.Terminate; // Признак завершения потока
  end;

  if ReconnectDesktopSocketCount>10 then // если достигнуто предельное кол-во переподклчений при одном сеансе
  begin
   RecreateDesktopSocket:=false;
   ThLog_Write('ThM',1,' Пересоздание сокета (D). Кол-во повтоных подключений превысило допустимое');
  end;

  if RecreateDesktopSocket then
   begin
    //ThLog_Write('ThM','Переподключение сокета (D) из Desktop_SocketDisconnect');
    Synchronize(FReconnect.Show); // отображаем диалог переподключения рабочего стола
    FullDesktopSocketReconnect;
    inc(ReconnectDesktopSocketCount);  // увеличение кол-ва переподключений сокета
   end
   else
   begin
   if FReconnect.Visible then Synchronize(FReconnect.Close); // закрываем диалог переподключения рабочего стола если он открыт
   if frm_RemoteScreen.Visible then // если форма открыта то закрываем
      begin
       Synchronize(
       procedure
         begin
         if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
         frm_ShareFiles.Hide;
         frm_Chat.Hide;
         frm_Main.SetOnline;
         frm_Main.Status_Label.Caption := 'В сети';
         if not frm_Main.Visible then
           begin
           frm_Main.Show;
           end;
         end);
      end
     else // иначе я абонент, или окно уже закрыто, отправляю на сервер признак разрва связи
      SendMainCryptText('<|STOPACCESS|>'); // отправляем в главный сокет признак разрыва связи

   frm_Main.Viewer:=false;   //отменяем признак открытия окна управления если я управляю абонентом
   frm_Main.Accessed := False; //отменяем признак разрешения доступа если я сервер
   //ThLog_Write('ThM','Отключаю сокеты (D) и (F) из Desktop_SocketDisconnect');
   RecreateFileSocket:=false; // отменяет признак необходимости пересоздания файлового сокета при его разрыве
   CloseFileSockets; // закрываем файловый сокет
   RecreateDesktopSocket:=false; // отменяет признак необходимости пересоздания сокета рабочего стола при его разрыве
   CloseDesktopSockets; // закрываем сокет рабочего стол
   if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
   end;
  frm_Main.CurrentActivMainSocket:=-1; //при connect desktop присваиваем текущий элемент массива для доступа к главному сокету управления, при disconnect desktop передаем -1, т.е. сокет для управления не активный
  //ThLog_Write('ThM','Отключения сокета (D): Desktop_SocketDisconnect');
 except on E : Exception do
  begin
   ThLog_Write('ThM',2,'Ошибка отключения сокета (D) Desktop_SocketDisconnect ');
   frm_Main.CurrentActivMainSocket:=-1; //при connect desktop присваиваем текущий элемент массива для доступа к главному сокету управления, при disconnect desktop передаем -1, т.е. сокет для управления не активный
  end;
  end;
end;

//------------------------------------------------------------------------------------------------
function TThread_Connection_Main.FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // поиск запись в массиве
var
i:integer;
exist:boolean;
begin
try
exist:=false;
for I := 0 to Length( frm_Main.ArrConnectSrv)-1 do
 begin
   if frm_Main.ArrConnectSrv[i].SrvAdr=AddrSrv then
    begin
    NextIndex:=i;
    exist:=true;
    break;
    end;
 end;
result:=exist;
except On E: Exception do
  begin
  ThLog_Write('ThM',2,'ERROR FindRecordClient');
  result:=false;
  end;
end;
end;
//------------------------------------------------------------------------------------------
// Выполнение основного потка
function TThread_Connection_Main.SendDesktopSocket(s:ansistring):boolean;
begin
try
result:=true;
if Desktop_Socket.Socket=nil then result:=false
else
begin
  if Desktop_Socket.Socket.Connected then
   while Desktop_Socket.Socket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_Write('ThM',2,'Ошибка отправки сокета (D) внешняя функции  ');  end;
end;

function TThread_Connection_Main.SendFilesSocket(s:ansistring):boolean;
begin
try
result:=true;
if Files_Socket.Socket=nil then result:=false
else
begin
  if Files_Socket.Socket.Connected then
   while Files_Socket.Socket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_Write('ThM',2,'Ошибка отправки сокета (D) внешняя функции ');  end;
end;


function TThread_Connection_Main.SendSocket(s:ansistring):boolean;
begin
  try
  result:=true;
   if MainSocket=nil then result:=false
  else
    begin
      if MainSocket.Connected then
       while MainSocket.SendText(s)<0 do
       sleep(ProcessingSlack)
      else result:=false;
    end;
  except on E : Exception do ThLog_Write('ThM',2,'Ошибка отправки сокета (М) внешняя функции');  end;
end;

function TThread_Connection_Main.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
except exit;  end;
end;

function TThread_Connection_Main.DeleteKeyMouseThread:boolean;
begin
 try
  Thread_RedirectKM.Terminate;
  Thread_RedirectKM:=nil;
  except on E : Exception do
   begin
   Result := false;
   ThLog_Write('ThM',2,'Ошибка удаления потока KM');
   end;
  end;
end;

function TThread_Connection_Main.CreateKeyMouseThread:boolean;
begin
  try
  Thread_RedirectKM:=TThread_Redirect_KeyMouse.create('');  // создание потока обработки сообщений клавиатуры и мыши
  result:=true;
   except on E : Exception do
    begin
    Result := false;
    ThLog_Write('ThM',2,'Ошибка создания потока KM');
    end;
   end;
end;

function TThread_Connection_Main.ParsingTextToExpansion(Stmp:string):boolean;  // парсинг строки с расширением экрана и вкл/выкл масштабирования
 var
 position,TmpNum:integer;
 TempText:string;
 begin  //<|FIRSTSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
   try
    TempText:=Stmp;        //FIRSTSTARTDATA SECONDSTARTDATA
    Position := Pos('STARTDATA|>', TempText);
    Delete(TempText, 1, Position + 10);
    Position := Pos('<|>', TempText);
    if TryStrToInt(Copy(TempText, 1, Position - 1),TmpNum) then frm_Main.ResolutionResizeWidth :=TmpNum;
    Delete(TempText, 1, Position + 2);
    if TryStrToInt(Copy(TempText, 1, Pos('<|END|>', TempText) - 1),TmpNum) then frm_Main.ResolutionResizeHeight :=TmpNum;

    Position := Pos('<|RESIZES|>', TempText); //определяем включать ли масштабирование
    if position>0 then
    begin
      Delete(TempText, 1, Position + 10);
      if TryStrToInt(Copy(TempText, 1, 1),TmpNum) then
      if TmpNum=1 then frm_Main.ScreenResizes :=true
       else frm_Main.ScreenResizes :=false;
    end;

    if (frm_Main.ResolutionResizeWidth=0)or(frm_Main.ResolutionResizeHeight=0)  then //если данные не корректные, т.е. в разрешении есть нулевое значение
     result:=false
     else result:=true;
    except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThM',2,'ParsingTextToExpansion поток (M) : '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
      end;
    end;
  end;

function TThread_Connection_Main.DesOpenInputMain(FirstDesk:HDESK):boolean;
var
hDesktopMain: HDESK;
 begin
 try
  ///-----------------------------------------------------------------------------------------
   result:=false;
   if not frm_Main.Accessed then exit; // если доступ разрешен то выолняем, иначе если мы клиент то это лишние действия
   hDesktopMain := OpenInputDesktop(0,true,MAXIMUM_ALLOWED); //Открывает рабочий стол, получающий входные данные пользователя.
   if FirstDesk<>hDesktopMain then
   if hDesktopMain<>0 then
     begin
     if not SetThreadDesktop(hDesktopMain)then //Назначает указанный рабочий стол вызывающему потоку.
     ThLog_write('ThM',1,'Поток (M): Ошибка STD: '+SysErrorMessage(GetLastError()));
     CloseHandle(hDesktopMain);
     result:=true;
     FirstDesk:=hDesktopMain;
     end
   else
     begin
     ThLog_write('ThM',1,'Поток (M): Ошибка OID: '+SysErrorMessage(GetLastError()));
     result:=false;
     end
  ///-----------------------------------------------------------------------------------------
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThM',2,'Ошибка STD/OID потока (M) : ');
      end;
    end;
 end;

function TThread_Connection_Main.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
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

function TThread_Connection_Main.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
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

function TThread_Connection_Main.SendMainCryptText(s:string):boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
 if Encryptstrs(s,PswrdCrypt, CryptBuf) then   //шифруем перед отправкой
 begin
 result:=SendSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
 end
 else
 begin
 ThLog_Write('ThM',1,'Поток М Не удалось защифровать данные сокет M');
 result:=false;
 end;
  except On E: Exception do
    begin
    result:=false;
    ThLog_Write('ThM',2,'Поток М Ошибка шифрования и отправки данных сокет M');
    end;
  end;
end;

function TThread_Connection_Main.SendFilesCryptText(s:string):boolean; // отправка зашифрованного текста в files сокет
var
CryptBuf:string;
begin
try
if Encryptstrs(s,PswrdCrypt, CryptBuf) then //шифруем перед отправкой
result:=SendFilesSocket('<!>'+CryptBuf+'<!!>') //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
else
begin
ThLog_Write('ThM',1,'Поток М Не удалось защифровать данные сокет F');
result:=false;
end;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThM',2,'Поток М Ошибка шифрования и отправки данных сокет F ');
    end;
  end;
end;


function TThread_Connection_Main.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //дешифровка скопированной строки
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
    ThLog_Write('ThM',2,'('+inttostr(step)+') Поток М  Ошибка дешифрации данных ');
    //ThLog_Write('ThM','ERROR  - Поток М Ошибка дешифрации данных Пароль - '
   // +PswrdCrypt+' s='+s+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp+
   // ' CryptTmp='+CryptTmp);

     s:='';
    end;
  end;
end;

procedure TThread_Connection_Main.Execute;
var
  Buffer,CryptBuf,DeCryptBuf,DeCryptRedirect: string;
  BufferTemp,DeCryptBufTemp,TempI,TempZ: string;
  KeyTemp:string;
  i: Integer;
  Position: Integer;
  FoldersAndFiles: TStringList;
  FileToUpload: TFileStream;
  step:integer;
  pixF:byte;
  TargetSeverIP:string;
  TargetServerPort:integer;
  TargetServerPswd:string;
  TargetIDTmp:string;
  mesg:string;
  iViewer:boolean;  // признак того что я подключаюсь к абоненту
  TmpNum:integer;

function ReciveDecodeBase64(mes:string):string;
begin
try
result:=TNetEncoding.Base64.Decode(mes);
except On E: Exception do
    begin
    result:='';
    ThLog_Write('ThM',2,'Ошибка ReciveDecodeBase64');
    end;
  end;
end;


Begin
  inherited;
try
//DesOpenInputMain; //------------------------------------->
//ThLog_Write('ThM','Поток (M) запущен');
PswrdCrypt:=frm_Main.ArrConnectSrv[IDConnect].SrvPswd; // присваиваем пароль для шифрования в потоке
frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt:=frm_Main.ArrConnectSrv[IDConnect].SrvPswd; // присваиваем текущий пароль для шифрования в формах
FoldersAndFiles := nil;
FileToUpload := nil;
step:=1;
 frm_Main.TimeoutDisconnect:=0;//GetTickCount;
 frm_Main.TimeStart:= GetTickCount;
 iViewer:=false; // я не подключаюсь, ко мне можно подключится
 SendMainCryptText('<|GETMYID|><|RUNPING|>'); // Запрашиваем свой ID и запуск PING

 WHILE (not terminated) and (MainSocket.Connected)  DO
  BEGIN
      Sleep(ProcessingSlack); // Avoids using 100% CPU
      if (MainSocket = nil)  then break;
      if not(MainSocket.Connected) then break;
  step:=2;
      if MainSocket.ReceiveLength < 1 then Continue;
  step:=3;
      DeCryptBuf := MainSocket.ReceiveText;   //присваиваем данные полученые в главный сокет
      if DeCryptBuf.Contains('<!>') then   // начало пакета данных
      while not DeCryptBuf.Contains('<!!>') do // Ожидание конца пакета
      begin
      if terminated then break;
      Sleep(ProcessingSlack);
      if MainSocket.ReceiveLength < 1 then Continue;
      DeCryptBufTemp := MainSocket.ReceiveText;
      DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
      end;
      Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки

  step:=4;
      frm_Main.Timeout := 0;
      //DesOpenInputMain; //------------------------------------->
   step:=5;
        // Если получили идентификатор и пароль с сервера
      Position := Pos('<|ID|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;  // передаем текст во временную
        Delete(BufferTemp, 1, Position + 5);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ArrConnectSrv[IDConnect].MyID:=Copy(BufferTemp, 1, Position - 1);
        frm_Main.MyID:=frm_Main.ArrConnectSrv[IDConnect].MyID;
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ArrConnectSrv[IDConnect].MyPswd:=Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        frm_Main.MyPassword := frm_Main.ArrConnectSrv[IDConnect].MyPswd;
        Synchronize(frm_Main.SetOnline); // активируем элементы главной формы, вывод полученных данных  MyID и MyPassword
        Synchronize(frm_Main.TargetID_MaskEdit.SetFocus);
        //ThLog_Write('ThM','Получил ID='+frm_Main.ArrConnectSrv[IDConnect].MyID+' Password='+frm_Main.ArrConnectSrv[IDConnect].MyPswd);
       end;
  step:=6;
  step:=7;
      // Ping /типа отправляем что мы тут если нас спросили
       frm_Main.TimeoutDisconnect:=GetTickCount-frm_Main.TimeStart;
      if Buffer.Contains('<|PING|>') then
      begin
       SendMainCryptText('<|PONG|>');
       frm_Main.TimeoutDisconnect:=0;
       frm_Main.TimeStart:=GetTickCount;
      end;
       step:=8;
      Position := Pos('<|SETPING|>', Buffer); //пришло значение таймаута от сервера
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        frm_Main.ArrConnectSrv[IDConnect].MyPing := StrToInt(BufferTemp);
        frm_Main.TimeoutDisconnect:=0;
        frm_Main.TimeStart:=GetTickCount;
      end;
  step:=9;

  step:=10;
  //----------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|SRVIDEXISTS!REQUESTPASSWORD|>') then  // переподключение на другой сервер
      begin    //<|SRVIDEXISTS!REQUESTPASSWORD|>+TargetServerAddress+<|TSA|>+inttostr(TargetServerPort)+<|TSP|>+TargetServerPSWD+<TSPSWD>
      BufferTemp:=Buffer;
      Delete(BufferTemp, 1, pos('<|SRVIDEXISTS!REQUESTPASSWORD|>',BufferTemp)+30);
       if Pos('<|TSA|>', BufferTemp)>0 then // если в ответ прилетел IP сервера TargetID
        Begin
         TargetSeverIP:='';
         TargetServerPort:=0;
         TargetServerPswd:='';
         TargetSeverIP := Copy(BufferTemp, 1, Pos('<|TSA|>', BufferTemp) - 1);
         Delete(BufferTemp, 1, pos('<|TSA|>',BufferTemp)+6);
         if Pos('<|TSP|>', BufferTemp)>0 then  // порт сервера целевого ID
           begin
           TryStrtoInt(Copy(BufferTemp, 1, Pos('<|TSP|>', BufferTemp) - 1),TargetServerPort);
           Delete(BufferTemp, 1, pos('<|TSP|>',BufferTemp)+6);
           if TargetServerPort=0 then TargetServerPort:=frm_Main.Port;
           end;
         if Pos('<TSPSWD>', BufferTemp)>0 then
           begin
           TargetServerPswd:=copy(BufferTemp,1,Pos('<TSPSWD>', BufferTemp) - 1);
           BufferTemp:='';
           end;
         //
          if (TargetSeverIP<>'') then //сервер подключения другой у целевого ID,  необходимо переподключится
            begin
            TargetIDTmp:= frm_Main.TargetID_MaskEdit.Text; // целевой ID к которому подключаемся
            //ThLog_Write('ThMain',TargetSeverIP+' порт='+inttostr(TargetServerPort)+' пароль сервера='+TargetServerPswd+' TargetIDTmp - '+TargetIDTmp);
            frm_Main.ReconnectTargetIDServer(TargetSeverIP,TargetServerPort,TargetIDTmp,TargetServerPswd);// подключение TArgetSocket
            end;
         End;
        end;
  //------------------------------------------------------------------------------------------------------------------
       if Buffer.Contains('<|MYIDEXISTS!REQUESTPASSWORD|>') then // если клиент на сервере к котрому я подключен открываем форму ввода пароля
      begin    //<|IDEXISTS!REQUESTPASSWORD|>
      BufferTemp:=Buffer;
      Delete(BufferTemp, 1, pos('<|MYIDEXISTS!REQUESTPASSWORD|>',BufferTemp)+29);
          Synchronize(
            procedure
            begin
             frm_Password.Tag:=IDConnect;
             frm_Main.Status_Label.Caption := 'Идентификация...';
             frm_Password.ShowModal; // запрос ввода пароля
            end);
        end;
  //------------------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|ACCESSGRANTEDMAIN|>') then  //сервер сообщил что свящал основные сокеты после проверки пароля
      begin // значит я отправлял просьюу на подключение к абоненту, т.е. сначала ID потом пароль
        iViewer:=true; // я подключаюсь к абоненту для управления
        frm_RemoteScreen.Tag:=IDConnect; // присваиваем номер элемента массива для доступа к основному сокету из формы управления

        SendMainCryptText('<|REDIRECT|><|CREATESOCKDESKTP|>'); //теперь с абонентом общаемся на прямую, сообщаем ему о необходимости создать сокеты раочего стола
        FullDesktopSocketReconnect; // создание/пересоздания сокета рабочего стола
        ReconnectDesktopSocketCount:=0; // текущее кол-во переосздания  сокета рабочего стола

        SendMainCryptText('<|REDIRECT|><|CREATESOCKFILES|>');  // отправляем запрос абоненту на содание файлового сокета
        FullFilesSocketReconnect; // создание/пересоздания файлового сокета
        ReconnectFileSocketCount:=0; // текущее кол-во переосздания файлового сокета
        RecreateFileSocket:=true; // признак необходимости пересоздания файлового сокета при его разрыве
        Synchronize(
            procedure
            begin
              frm_Main.Status_Label.Caption := 'Аутентификация...';
            end);

      end;
  //----------------------------------------------------------------------------------------------

         //Предупреждает о доступе
      if Buffer.Contains('<|ACCESSING|>') then
      begin
        //ThLog_Write('ThMain','<|REDIRECT|><|MONITORCOUNT|> '+inttostr(screen.MonitorCount));
       Synchronize(
          procedure
          begin
            frm_Main.butConnect.Enabled := False;
            frm_Main.TargetID_MaskEdit.Enabled := False;
            frm_Main.Status_Label.Caption := 'Внешнее управление!';
            frm_Main.Accessed := true;  // признак того что я сервер
          end);
       frm_Main.Accessed := true;  // признак того что я сервер
       iViewer:=false;// еще раз подктверждаем что я абонент а не подключась к клиенту
       CreateKeyMouseThread; //создание потока для клавы и мыши
       //ThLog_Write('ThM',' Сервер сообщил что ко мне подключились. Server');
      end;
 //----------------------------------------------------------------------------
  step:=11;
      if Buffer.Contains('<|IDNOTEXISTS|>') then
      begin
      frm_Main.InMessage('Введенного ID не существует.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
       iViewer:=false;// тут я стал абоннтом и ко мне можно подключится
      end;
  step:=12;
      if Buffer.Contains('<|ACCESSDENIED|>') then
      begin
       frm_Main.InMessage('Не верный пароль.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
       iViewer:=false;// тут я стал абоннтом и ко мне можно подключится
      end;
  step:=13;
      if Buffer.Contains('<|ACCESSBUSY|>') then
      begin
      frm_Main.InMessage('Абонентское подключение занято. Повторите попытку подключюения.',0);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// тут я стал абоннтом и ко мне можно подключится
      end;

      if Buffer.Contains('<|ACCESSDENIEDDESKTOP|>') then
      begin
       frm_Main.InMessage('Не удалось включить управление рабочим столом. Повторите попытку подключюения.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// тут я стал абоннтом и ко мне можно подключится
      end;

      if Buffer.Contains('<|ACCESSDENIEDFILES|>') then
      begin
       frm_Main.InMessage('Не удалось включить передачу файлов. Повторите попытку подключюения.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
      end;


  step:=14;
     //-----------------------------------------------------------------------------------------------
     //---------------------------работа с сокетом рабочего стола------------------------------------------------
      if Buffer.Contains('<|DSKTPCREATED|>') then  //если клиент мне ответил что создал сокеты рабочего стола, , отправляется при создании потока обработки сокета рабочего стола
      begin // сообщаем серверу о необходимости связать сокеты рабочего стола
       if iViewer then // если я подключаюсь к абоненту, то прошу сервер связать сокеты рабочего стола
         begin
          if Thread_Connection_Desktop<>nil then // если desktop поток существует
            begin
            if Thread_Connection_Desktop.Started then  // если desktop поток запущен
               begin
                if not Thread_Connection_Desktop.BindSockD then //и если в потоке нет признака связи сокетов на сервере
                  begin //значит поток запустили в первый раз, просим сервер связать сокеты
                  SendMainCryptText('<|BINDDSKTPSOCK|>'+frm_Main.MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>');
                  if frm_Main.Visible then // если окно открыто
                    begin
                    Synchronize(
                      procedure
                      begin
                        frm_Main.Status_Label.Caption := 'Connect Desktop';
                      end);
                     end;
                  //ThLog_Write('ThM',' Я Viewer, у меня сокеты НЕ связаны мне пришло <|DSKTPCREATED|>, прошу сервер связать сокеты');
                  end
                  else // иначе если у меня связаны, возможно клиент переосоздал сокет надо их связать
                  begin
                  //ThLog_Write('ThM',' Я Viewer, у меня сокеты СВЯЗАНЫ мне пришло <|DSKTPCREATED|>, закрываю сокет для пересоздания');
                  CloseDesktopSockets;
                  end;
               end
               else
               begin
               ThLog_Write('ThM',2,'1) Viewer, поток (D) не запущен');
               //FullDesktopSocketReconnect;
               end;
            end
            else // иначе потока нет
            begin // создаю сокеты
            ThLog_Write('ThM',2,'2) Viewer, поток (D) не запущен');
            //FullDesktopSocketReconnect;
            end;

         end;
        if not iViewer then // если ко мне подключились и я являюсь абонентом
          begin
            if RecreateDesktopSocket then // если переподключение активно значит первое соединение уже было после запроса CREATESOCKDESKTP
             begin
              if Thread_Connection_Desktop<>nil then // если desktop поток существует
               begin
                if Thread_Connection_Desktop.Started then  // если desktop поток запущен
                 begin
                  if Thread_Connection_Desktop.BindSockD then //и если в потоке признак связи сокетов на сервере
                   begin
                   // ThLog_Write('ThM',' Sever,1) BindSock FullRecreate (D)');
                    CloseDesktopSockets;
                   end
                   else
                   begin
                   //ThLog_Write('ThM',' Sever, 2) Repeat BindSock (D)');
                   SendMainCryptText('<|REDIRECT|><|REPEATBINDDESKTOPSOCKET|>');
                   end;
                 end
                 else
                 begin
                 ThLog_Write('ThM',2,' Sever, 3) BindSock FullRecreate (D)');
                 //FullDesktopSocketReconnect;
                 end;
               end
               else
               begin
               ThLog_Write('ThM',2,' Sever, 4) BindSock FullRecreate (D)');
               //FullDesktopSocketReconnect;
               end;

             end;
          end;
      end;
  step:=110;
     //-------------------------------------------------------------------------------------------------
       if Buffer.Contains('<|VIEWACCESSINGDESKTOP|>') then  // сервер сообщил что по моей прозьбе связал сокеты рабочего стола
       begin
          Synchronize(  // открываю у себя форму управления рабочим столом
            procedure
              begin
                if not frm_RemoteScreen.Visible then // если форма еще не открыта
                  begin
                  frm_Main.Status_Label.Caption := 'Управление подключено';
                  frm_Main.Viewer := true;  // признак того что я подкючился к абонентуи открыто окно управления
                  frm_Main.ClearConnection; //
                  frm_RemoteScreen.Show;
                  frm_Main.Hide;
                  end;
              end);
       iViewer:=true;// и еще раз подтверждаю что я подключился к абоненту а не на оборот
       // отправляем необходимое разрешение на сервер для получения картинки нужного размена / предстартовые данные
       if FormOsher.Resize_CheckBox.Checked then
        SendMainCryptText('<|REDIRECT|><|FIRSTSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // масштабирование картинки
        else SendMainCryptText('<|REDIRECT|><|FIRSTSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // или нет
        // ThLog_Write('ThM',2,' <|FIRSTSTARTDATA|> : W='+inttostr(frm_RemoteScreen.Screen_Image.Width)+' / H='+inttostr(frm_RemoteScreen.Screen_Image.Height));
       end;
        //-----------------------------------------------------------------------------------------------------------

       if Buffer.Contains('<|FIRSTSTARTDATA|>') then // если ко мне пришли предстартовые данные
       begin    //<|FIRSTSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
       if ParsingTextToExpansion(BufferTemp)  then //если данные корректные
        SendMainCryptText('<|REDIRECT|><|READYGO|>') //отправляю что готов к старту передачи рабочего стола
       else //если данные не корректные, т.е. в разрешении есть нулевое значение
         begin
         sleep(300); // спим перед повторным запросом
         SendMainCryptText('<|REDIRECT|><|GETSECONDSTARTDATA|>'); // повторный запрос на получение данных для старта
         ThLog_Write('ThM',2,'Not first data start: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
         end;

       end;

     //-------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|GETSECONDSTARTDATA|>') then // абонент попросил повторно отправить стартовые данные т.к. первичные были не коррекны, в необходимом мне разрешение картинки одно из значений 0
       begin
        if FormOsher.Resize_CheckBox.Checked then
        SendMainCryptText('<|REDIRECT|><|SECONDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // масштабирование картинки
        else SendMainCryptText('<|REDIRECT|><|SECONDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // или нет
       end;
     //--------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|SECONDSTARTDATA|>') then // если ко мне пришли повторные предстартовые данные
       begin    //<|SECONDSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
        if ParsingTextToExpansion(BufferTemp)  then //если данные корректные
        SendMainCryptText('<|REDIRECT|><|READYGO|>') //отправляю что готов к старту передачи рабочего стола
        else //если данные не корректные, т.е. в разрешении есть нулевое значение
        begin // последний 3 запрос на повторное получение данных
        sleep(600);
        SendMainCryptText('<|REDIRECT|><|GETTHIRDSTARTDATA|>'); // последний 3й запрос на получение данных для старта
        ThLog_Write('ThM',2,'Not second data start: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
        end;
       end;
     //--------------------------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|GETTHIRDSTARTDATA|>') then // абонент попросил 3й раз ототправить стартовые данные т.к. 1й и 2й были не коррекны, в необходимом мне разрешение картинки одно из значений 0
       begin
        if FormOsher.Resize_CheckBox.Checked then
        SendMainCryptText('<|REDIRECT|><|THIRDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // масштабирование картинки
        else SendMainCryptText('<|REDIRECT|><|THIRDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // или нет
       end;
     //------------------------------------------------------------------------------------------------------------------
     if Buffer.Contains('<|THIRDSTARTDATA|>') then // если ко мне 3й раз пришли  предстартовые данные
       begin    //<|THIRDSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
        if ParsingTextToExpansion(BufferTemp)  then //если данные корректные
        SendMainCryptText('<|REDIRECT|><|READYGO|>') //отправляю что готов к старту передачи рабочего стола
        else //если данные не корректные, т.е. в разрешении есть нулевое значение
        begin // отключение клиента и предупреждение о повторном соединении
        sleep(600);
        SendMainCryptText('<|REDIRECT|><|NOTSTARTDATA|>'); // отправляем сообщения о том что мы не получили стартовые данные даже с 3го раза, и делаем дисконект
        SendMainCryptText('<|STOPACCESS|>'); // отправка на сервер прозьбу об отключении
        ThLog_Write('ThM',2,'Not third data start. stop connect: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
        end;
       end;
     //----------------------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|READYGO|>') then // если ко мне абонент ответил что готов передавать данные рабочего стола
       begin
       SendMainCryptText('<|REDIRECT|><|ACCESSING|>'); //сообщаем клиенту что мы к нему подклчаемся
       sleep(300); //немного спим для того чтобы инстерфейс проги подготовился, иначе могут быть баги первого скрина
       SendDesktopSocket('<!>'+THashSHA2.GetHashString(PswrdCrypt,SHA256)+'<!!>'); // отправляем хеш установленного пароля, для получения первой картинки от клиента
       if Thread_Connection_Desktop<>nil then
       if Thread_Connection_Desktop.Started then
       Thread_Connection_Desktop.BindSockD:=true; // признак связывания сокетов у меня в потоке
       if RecreateDesktopSocket then // если это не первое подключение, то диалог переподключения должен отображаться
        begin
        if FReconnect.Visible then Synchronize(FReconnect.Close); // закрываем диалог переподключения рабочего стола
        end;
       RecreateDesktopSocket:=true; // признак необходимости пересоздания сокета рабочего стола при его разрыве
       end;
  step:=111;
      //----------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|NOTSTARTDATA|>') then
      begin
       frm_Main.InMessage('Не получилось отправить данные для подключения. Повторите попытку подключюения.',0);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := 'В сети';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// тут я стал абоннтом и ко мне можно подключится
      end;
     //------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|SRVACCESSINGDESKTOP|>') then // если ко мне подключаются то сервер сообщает мне о связи сокетов рабочего стола
       begin
       if Thread_Connection_Desktop<>nil then
       if Thread_Connection_Desktop.Started then
       Thread_Connection_Desktop.BindSockD:=true; // признак связывания сокетов у меня в потоке
       RecreateDesktopSocket:=true; // признак необходимости пересоздания сокета рабочего стола при его разрыве. В этом месте т.к. при первом создании <|CREATESOCKDESKTP|> придет еще от клиента '<|DSKTPCREATED|>', и чтобы не связал/создал 2 раза сокет этот признак будет тут
       frm_Main.Accessed := true; // повторный признак того ко мне подключились и я сервер
       frm_Main.ScreenResizes:=true; // при подключении устанавливаем масштабирование картинки по умолчанию
       frm_Main.MonitorCurrent:=0; // при подключении устанавливаем монитор по умолчанию
       frm_Main.MonitorCurrentX:=screen.Monitors[frm_Main.MonitorCurrent].Left;
       frm_Main.MonitorCurrentY:=screen.Monitors[frm_Main.MonitorCurrent].Top;
       frm_Main.MonitorCurrentWidth:=screen.Monitors[frm_Main.MonitorCurrent].Width;
       frm_Main.MonitorCurrentHeight:=screen.Monitors[frm_Main.MonitorCurrent].Height;
         // выше параметры монитора изображение которого передаю
        SendMainCryptText('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Width) // разрешение своего экрана
         + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Height) + '<|END|>');
        SendMainCryptText('<|REDIRECT|><|MONITORLEFTTOP|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Left)     // положение своего экрана
         + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Top) + '<|END|>');
        SendMainCryptText('<|REDIRECT|><|MONITORCOUNT|>'+inttostr(screen.MonitorCount)+'<|END|>'); // отправляем количество подключенных мониторов
       //ThLog_Write('ThM',2,' Сервер включил передачу изображения. Server MonLeftTop X='+inttostr(frm_Main.MonitorCurrentX)+' Y='+inttostr(frm_Main.MonitorCurrentY)+' Width='+inttostr(frm_Main.MonitorCurrentWidth)+' Height='+inttostr(frm_Main.MonitorCurrentHeight));
       Synchronize(
          procedure //очищаем чат
          begin
          frm_Main.ClearChat;
          end);
       end;
  step:=112;
     //---------------------------------------------------------------------------------------------------------
       if Buffer.Contains('<|CREATESOCKDESKTP|>') then  //ко мне подключились и просят создать сокеты для управления рабочим столом
      begin
       //ThLog_Write('ThM','<|CREATESOCKDESKTP|> Я абонент, ко мне пришел запрос на созадние сокета');
       FullDesktopSocketReconnect;// пересоздание сокета рабочего стола
       ReconnectDesktopSocketCount:=0; //сброс текущее кол-во повторов переосздания  сокета
       // после создания сокета сокет передаст инфу о том что он создался <|DSKTPCREATED|>
      end;
     //--------------------------------------------------------------------------------------------
     if Buffer.Contains('<|REPEATBINDDESKTOPSOCKET|>')  then // пришел ответ от клиента, я отправил ему что создал сокет рабочего стола, он проверил и сказал что у него они не связаны,
      begin            // далее доп.проверки
      if RecreateDesktopSocket then // если перво соединение уже было, и есть признак переподключения
      if iViewer then // если я подключаюсь к абоненту
         begin
          if Thread_Connection_Desktop<>nil then  // если поток рабочего стола существует
            Begin
              if Thread_Connection_Desktop.Started then // если поток рабочего стола запущен
               begin
                 if not Thread_Connection_Desktop.BindSockD then // если в потоке нет признака связи сокетов
                   begin
                   //ThLog_Write('ThM',' Я Viewer, у меня сокет не связан, пришел <|REPEATBINDDESKTOPSOCKET|> отправляю на сервер просьбу связать сокеты <|BINDDSKTPSOCK|>');
                   SendMainCryptText('<|BINDDSKTPSOCK|>'+frm_Main.MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>'); // прошу сервер связать сокеты повторно
                   end
                   else // иначе если они связны надо пересоздать
                   begin
                   //ThLog_Write('ThM',' Я Viewer, у меня сокет связан, пришел <|REPEATBINDDESKTOPSOCKET|>, закрываю сокет для пересоздания');
                   CloseDesktopSockets; // пересоздание сокета рабочего стола
                   end;
               end
               else
               begin
               //ThLog_Write('ThM',' Я Viewer, у меня поток не запущен, пришел <|REPEATBINDDESKTOPSOCKET|>, надо пересоздать сокет');
              // FullDesktopSocketReconnect;// пересоздание сокета рабочего стол
               end;
            End
            else
             begin
             //ThLog_Write('ThM',' Я Viewer, у меня поток отсутствует, пришел <|REPEATBINDDESKTOPSOCKET|>, надо пересоздать сокет');
             //FullDesktopSocketReconnect;// пересоздание сокета рабочего стола
             end;
         end;
      end;
     //----------------------------------------------------------------------------------------------

  step:=117;
      //---------------------------------работа с файловым сокетом---------------------------------------------
     if Buffer.Contains('<|FILESCREATED|>') then  //если мне ответил что создали сокет для файлов, отправляется при создании потока обработки файлового сокета
      begin
       if iViewer then // если я подключаюсь к абоненту то я прошу у сервера связать сокеты
        begin
        SendMainCryptText('<|BINDFILESSOCK|>'+frm_Main.MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>');
       // ThLog_Write('ThM',' Я Viewer, мне пришло <|FILESCREATED|>');
        end;
       if not iViewer then // если ко мне подключились и я являюсь абонентом
        begin
         if Thread_Connection_Files<>nil then // если файловый поток существует
         if Thread_Connection_Files.Started then  // если файловый поток запущен
         if Thread_Connection_Files.BindSockF then //и если в потоке есть признак мой сокет свзян на сервере
          SendMainCryptText('<|REDIRECT|><|REPEATBINDFILESOCKET|>'); // говорю тому кто ко мне подключен, свяжи повторно файловые сокеты, т.к. твой файловый сокет возможно был отключен
         // ThLog_Write('ThM',' Я абонент, мне пришло <|FILESCREATED|>');
        end;
      end;
   step:=118;
    //-------------------------------------------------------------------------------------
     if Buffer.Contains('<|REPEATBINDFILESOCKET|>')  then // пришел ответ от клиента, я отправил ему что создал файловый сокет, он проверил и сказал что у него они уже были связаны, значит сокет у меня был отключен и повторно включен
      begin            // далее доп.проверки
      if iViewer then // если я подключаюсь к абоненту
       begin
        if Thread_Connection_Files<>nil then  // если файловый поток существует
        if Thread_Connection_Files.Started then // если файловый поток запущен
        if not Thread_Connection_Files.BindSockF then // если в потоке нет признака связи сокетов
        SendMainCryptText('<|BINDFILESSOCK|>'+frm_Main.MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>'); // прошу сервер связать сокеты повторно
       end;
      end;
  step:=119;
    //--------------------------------------------------------------------------------------------
     if Buffer.Contains('<|CREATESOCKFILES|>') then  //ко мне подключаются и просят создать файловый сокет
      begin
       if ExistsFileSockets then SendMainCryptText('<|REDIRECT|><|FILESCREATED|>')  // если файловый сокет активный отправляем что все создали
        else // иначе создаем
        begin
        RecreateFileSocket:=true; // признак необходимости пересоздания файлового сокета при его разрыве
        ReconnectFileSocketCount:=0; // текущее кол-во повторов переосздания файлового сокета
        FullFilesSocketReconnect; // создание/пересоздания файлового сокета
         //ThLog_Write('ThF','<|CREATESOCKFILES|> Я абонент меня попросили создать файловый сокет');
        end;
      end;
  step:=120;
  //--------------------------------------------------------------------------------------------
     if Buffer.Contains('<|VIEWACCESSINGFILES|>') then  // я отправил серверу <|BINDFILESSOCK|> просьбу связать файловые сокеты мой поток на сервере сказал что связал файловые сокеты
       begin
       if Thread_Connection_Files<>nil then
       if Thread_Connection_Files.Started then
       Thread_Connection_Files.BindSockF:=true; // признак связывания сокетов
       //ThLog_Write('ThM',' Сервер включил передачу файлов. Client');
       end;
  step:=121;
  //---------------------------------------------------------------------------------
     if Buffer.Contains('<|SRVACCESSINGFILES|>') then  //чужой поток на сервере сказал что ко мне подключились и попросили связать файловые сокеты
       begin
       if Thread_Connection_Files<>nil then
       if Thread_Connection_Files.Started then
       Thread_Connection_Files.BindSockF:=true; // признак связывания советов
       //ThLog_Write('ThM',' Сервер включил передачу файлов. Server');
       end;
  step:=122;
  //------------------------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------------------------
   step:=15;
       if Buffer.Contains('<|DISCONNECTED|>') then // при отклчении соврачиваем форму управления,чат,проводник
      begin
        Synchronize(
          procedure
          begin
           if FormFileTransfer.Visible then FormFileTransfer.Close;
           if frm_RemoteScreen.Visible then frm_RemoteScreen.close;
           if frm_ShareFiles.Visible then frm_ShareFiles.Close;
           if frm_Chat.Visible then frm_Chat.close;
           frm_Main.SetOnline;
           frm_Main.Status_Label.Caption := 'В сети';
           frm_Main.Show;
          end);
       if frm_Main.ArrConnectSrv[IDConnect].DesktopSock<>nil then frm_Main.ArrConnectSrv[IDConnect].DesktopSock:=nil;
       if frm_Main.ArrConnectSrv[IDConnect].FilesSock<>nil then frm_Main.ArrConnectSrv[IDConnect].FilesSock:=nil;
       iViewer:=false; // после отключения я снова могу быть абонентом
       ReconnectDesktopSocketCount:=0; // текущее кол-во переосздания  сокета рабочего стола
       ReconnectFileSocketCount:=0; // текущее кол-во переосздания файлового сокета
       RecreateFileSocket:=false; // отменяет признак необходимости пересоздания файлового сокета при его разрыве
       RecreateDesktopSocket:=false; // отменяет признак необходимости пересоздания сокета рабочего стола при его разрыве
       DeleteDesktopSockets;// удаляем сокет рабочего стола
       DeleteFileSockets;  // удаляем файловый сокет
       DeleteKeyMouseThread; // завершаем поток для клавы и мыши
       frm_Main.Accessed := false; // сброс признака того ко мне подключились
       frm_Main.Viewer := false;  // сброс признака того что я подкючился к абоненту
       frm_Main.ResolutionResizeWidth :=0;
       frm_Main.ResolutionResizeHeight :=0;
      end;
  step:=16;
      { Redirected commands }
     //---------------------далее команды относящиесе к управлению---------------------------------------
      Position := Pos('<|RESOLUTION|>', Buffer); // принимаем разрешение экрана от сервера
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionTargetWidth := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionTargetHeight := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
       //ThLog_Write('ThMain',2,'<|RESOLUTION|> '+inttostr(frm_Main.ResolutionTargetWidth)+'x'+inttostr(frm_Main.ResolutionTargetHeight));
      end;
      Position := Pos('<|MONITORLEFTTOP|>', Buffer); // принимаем положение экрана на сервере
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 17);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionTargetLeft := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionTargetTop := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        //ThLog_Write('ThMain',2,'<|MONITORLEFTTOP|> '+inttostr(frm_Main.ResolutionTargetLeft)+'x'+inttostr(frm_Main.ResolutionTargetTop));
      end;
  step:=17;
       Position := Pos('<|MONITORCOUNT|>', Buffer); // принимаем количество мониторов от сервера '<|MONITORCOUNT|>...<|END|>'
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 15);
        frm_Main.MonitorCount := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        Delete(BufferTemp, 1, length(BufferTemp));
        //ThLog_Write('ThMain',2,'<|MONITORCOUNT|> '+inttostr(frm_Main.MonitorCount));
      end;
      Position := Pos('<|MONITORCURRENT|>', Buffer); // принимаем текущий нобходимый монитор для клиента '<|MONITORCURRENT|>...<|END|>'
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 17);
        if trystrtoint(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1),TmpNum) then frm_Main.MonitorCurrent:=TmpNum;
        //frm_Main.MonitorCurrent := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        Delete(BufferTemp, 1, length(BufferTemp));
        frm_Main.MonitorCurrentX:=screen.Monitors[frm_Main.MonitorCurrent].Left;
        frm_Main.MonitorCurrentY:=screen.Monitors[frm_Main.MonitorCurrent].Top;
        frm_Main.MonitorCurrentWidth:=screen.Monitors[frm_Main.MonitorCurrent].Width;
        frm_Main.MonitorCurrentHeight:=screen.Monitors[frm_Main.MonitorCurrent].Height;
        SendMainCryptText('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Width)
        + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Height) + '<|END|>');
        SendMainCryptText('<|REDIRECT|><|MONITORLEFTTOP|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Left)
        + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Top) + '<|END|>');
      //ThLog_Write('ThMain','<|MONITORCURRENT|> '+inttostr(frm_Main.MonitorCurrent));
      //ThLog_Write('ThM',2,' <|MONITORCURRENT|>='+inttostr(frm_Main.MonitorCurrent)+ ' X='+inttostr(frm_Main.MonitorCurrentX)+' Y='+inttostr(frm_Main.MonitorCurrentY)+' Width='+inttostr(frm_Main.MonitorCurrentWidth)+' Height='+inttostr(frm_Main.MonitorCurrentHeight));
      end;

       Position := Pos('<|PIXELFORMAT|>', Buffer); // принимаем количество мониторов от сервера '<|PIXELFORMAT|>...<|END|>'
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 14);
        pixF:=StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        case pixF  of
        4:frm_Main.ImagePixelF:=pf4bit;
        8:frm_Main.ImagePixelF:=pf8bit;
        15:frm_Main.ImagePixelF:=pf15bit;
        16:frm_Main.ImagePixelF:=pf16bit;
        24:frm_Main.ImagePixelF:=pf24bit;
        32:frm_Main.ImagePixelF:=pf32bit;
        64:frm_Main.ImagePixelF:=pfDevice;
        end;
        Delete(BufferTemp, 1, length(BufferTemp));
      end;
      //
       Position := Pos('<|FPSMAXCOUNT|>', Buffer); // принимаем максимальное кол-во кадр/сек для текущей сессии
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 14);
        if trystrtoint(copy(BufferTemp,1,pos('<|ENDFPS|>',BufferTemp)-1),TmpNum) then CurrentFPSSession:=TmpNum;
        BufferTemp:='';
      end;

      //--------------------------------------------------------------------------------------------------------------------
      Position := Pos('<|TEMPVAR|>', Buffer); // Принимает значение временной переменной, для административных целей!!!!
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        frm_Main.RedirectTempVar := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        Delete(BufferTemp, 1, length(BufferTemp));
      end;
      //---------------------------------------------------------------------------------------------------------------------
      Position := Pos('<|RESOLUTIONRESIZE|>', Buffer); // принимаем разрешение от клиента необходимое для картинки скрина при resizes
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 19);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionResizeWidth := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionResizeHeight := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        //ThLog_Write('ThM',2,'<|RESOLUTIONRESIZE|>'+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight));
      end;
  step:=18;
      Position := Pos('<|RESIZES|>', Buffer); // масштабирование картинки
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        if (Copy(BufferTemp, 1, 1))='1' then
        frm_Main.ScreenResizes :=true
        else
        frm_Main.ScreenResizes :=false;
       // Log_Write('app','<|RESIZES|>'+(Copy(BufferTemp, 1, 1)));
      end;
  //-------------------------------------------------------------------------------------------------------------------------
    Position := Pos('<|TSC|>', Buffer); // Время затраченое на скрин //SendMainSocket('<|REDIRECT|><|TSC|>'+TimeScreen+'<|TCPS|>'+TimeCompress+'<|TCPR|>'+TimeCompare+'<|END|>'); // время скрина
      if Position > 0 then  //MTimeScreen,MTimeCompress,MTimeCompare
      begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, Position + 6);
      Position := Pos('<|TCPS|>', BufferTemp);
      if Position>0 then frm_Main.MTimeScreen:= Copy(BufferTemp, 1, Position - 1);
      BufferTemp :='';
      end;
   //------------------------------------------------------------
      if Buffer.Contains('<|ALT+CTR+DELETE|>') then
      begin
        Buffer := StringReplace(Buffer, '<|ALT+CTR+DELETE|>', '', [rfReplaceAll]);
        //mesg:='<|ALT+CTR+DELETE|>';
        //ThLog_Write('app','Получил <|ALT+CTR+DELETE|>');
       // ThLog_Write('app',' ServiceUID- '+frm_Main.ServiceUID);
        if Encryptstrs('<|ALT+CTR+DELETE|>',frm_Main.ServiceUID,mesg) then
        begin
       // ThLog_Write('app',' mesg - '+mesg);
        TPBPipeClient.SendData('\\.\pipe\pipe server E5DE3B9655BE4885ABD5C90196EF0EC5', mesg); // отправляем сообщение службе
        end;
        mesg:='';
       end;
  //-------------mouse-------------------------------------------------
  step:=18;

       Position := Pos('<|SETMOUSEDBLCLICK|>', Buffer);  //позиция мыши
      if Position > 0 then
      begin
        strRedirect.PushItem('<|SETMOUSEDBLCLICK|>');
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=19;
      Position := Pos('<|SETMOUSEPOS|>', Buffer);  //позиция мыши
      if Position > 0 then
      begin
      // strRedirect.PushItem(Buffer); // если позиция мыши то добавляем весь буфер
      // Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);

      // ниже перемещение по первым координатам которые передались, меньше точность позиционирование
      strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
      Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);

      //ниже плавне перемещение курсора по всем координатам которые предались
       {BufferTemp:=Buffer;
        while Position > 0 do
          begin
          strRedirect.PushItem(copy(BufferTemp,Position,Pos('<|END|>', BufferTemp)+6));
          Delete(BufferTemp, 1, Pos('<|END|>', BufferTemp)+6);
          Position := Pos('<|SETMOUSEPOS|>', BufferTemp);
          end;}

      end;
  step:=20;
      Position := Pos('<|SETMOUSELEFTCLICKDOWN|>', Buffer); //нажата левая копка мыши
      if Position > 0 then
      begin
      strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
       Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=21;
      Position := Pos('<|SETMOUSELEFTCLICKUP|>', Buffer);   //отпущена левая кнопка мыши
      if Position > 0 then
      begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=22;
      Position := Pos('<|SETMOUSERIGHTCLICKDOWN|>', Buffer); // нажата правая кнопка мыши
      if Position > 0 then
      begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=23;
      Position := Pos('<|SETMOUSERIGHTCLICKUP|>', Buffer);    // отпущена правая кнопка мыши
      if Position > 0 then
      begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=24;
      Position := Pos('<|SETMOUSEMIDDLEDOWN|>', Buffer);
      if Position > 0 then
      begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=25;
      Position := Pos('<|SETMOUSEMIDDLEUP|>', Buffer);
      if Position > 0 then
      begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=26;
      Position := Pos('<|WHEELMOUSE|>', Buffer);
      if Position > 0 then
      begin
        //strRedirect.PushItem(copy(Buffer,Position,Pos('<|END|>', Buffer)+6));
        strRedirect.PushItem(Buffer); // если прокрутка мыши то добавляем весь буфер
        Delete(Buffer,Position, Pos('<|END|>', Buffer)+6);
      end;
  step:=27;
  // ---------------------------keyboard ----------------------------------------------------------------------------------------------
      if Buffer.Contains('<|CTRL+C|>') then
      begin
        strRedirect.PushItem('<|CTRL+C|>');
        Buffer := StringReplace(Buffer, '<|CTRL+C|>', '', [rfReplaceAll]);
      end;
        if Buffer.Contains('<|LALTDOWN|>') then
      begin
        strRedirect.PushItem('<|LALTDOWN|>');
        Buffer := StringReplace(Buffer, '<|LALTDOWN|>', '', [rfReplaceAll]);
      end;
       if Buffer.Contains('<|LALTUP|>') then
      begin
        strRedirect.PushItem( '<|LALTUP|>');
        Buffer := StringReplace(Buffer, '<|LALTUP|>', '', [rfReplaceAll]);
      end;
      //RightAlt
       if Buffer.Contains('<|RALTDOWN|>') then
      begin
        strRedirect.PushItem('<|RALTDOWN|>');
        Buffer := StringReplace(Buffer, '<|RALTDOWN|>', '', [rfReplaceAll]);
      end;
       if Buffer.Contains('<|RALTUP|>') then
      begin
        strRedirect.PushItem('<|RALTUP|>');
        Buffer := StringReplace(Buffer, '<|RALTUP|>', '', [rfReplaceAll]);
      end;
      //LeftCtrl
      if Buffer.Contains('<|LCTRLDOWN|>') then
      begin
        strRedirect.PushItem('<|LCTRLDOWN|>');
        Buffer := StringReplace(Buffer, '<|LCTRLDOWN|>', '', [rfReplaceAll]);
      end;
      if Buffer.Contains('<|LCTRLUP|>') then
      begin
        strRedirect.PushItem('<|LCTRLUP|>');
        Buffer := StringReplace(Buffer, '<|LCTRLUP|>', '', [rfReplaceAll]);
      end;
      //RightCtrl
      if Buffer.Contains('<|RCTRLDOWN|>') then
      begin
        strRedirect.PushItem('<|RCTRLDOWN|>');
        Buffer := StringReplace(Buffer, '<|RCTRLDOWN|>', '', [rfReplaceAll]);
      end;
      if Buffer.Contains('<|RCTRLUP|>') then
      begin
        strRedirect.PushItem('<|RCTRLUP|>');
        Buffer := StringReplace(Buffer, '<|RCTRLUP|>', '', [rfReplaceAll]);
      end;
      //LeftShift
      if Buffer.Contains('<|LSHIFTDOWN|>') then
      begin
        strRedirect.PushItem('<|LSHIFTDOWN|>');
        Buffer := StringReplace(Buffer, '<|LSHIFTDOWN|>', '', [rfReplaceAll]);
      end;
      if Buffer.Contains('<|LSHIFTUP|>') then
      begin
        strRedirect.PushItem('<|LSHIFTUP|>');
        Buffer := StringReplace(Buffer, '<|LSHIFTUP|>', '', [rfReplaceAll]);
      end;
       //RightShift
        if Buffer.Contains('<|RSHIFTDOWN|>') then
      begin
        strRedirect.PushItem('<|RSHIFTDOWN|>');
        Buffer := StringReplace(Buffer, '<|RSHIFTDOWN|>', '', [rfReplaceAll]);
      end;

      if Buffer.Contains('<|RSHIFTUP|>') then
      begin
        strRedirect.PushItem('<|RSHIFTUP|>');
        Buffer := StringReplace(Buffer, '<|RSHIFTUP|>', '', [rfReplaceAll]);
      end;

      Position := Pos('<|KEYPRS|>', Buffer);
      if Position > 0 then  // <|KEYPRS|>...<|KPEND|>
       begin
       while Position > 0 do
        begin
        strRedirect.PushItem(copy(Buffer,Position,Pos('<|KPEND|>', Buffer)+8));
        Delete(Buffer,Position, Pos('<|KPEND|>', Buffer)+8);
        Position := Pos('<|KEYPRS|>', Buffer);
        end;
       end;

       {if Buffer.Contains('<|KEYPRS|>') then  // <|KEYPRS|>...<|KPEND|>
        begin
        strRedirect.PushItem(Buffer);
        end;}

  step:=28;
  // Chat-----------------------------------------------------------------------------------------
      Position := Pos('<|CHAT|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 7);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        BufferTemp:=ReciveDecodeBase64(BufferTemp); // декодируем из base64
  step:=29;
        Synchronize(
          procedure
          begin
            with frm_Chat do
            begin
  step:=30;    
                with NewChat.Items.AddMessage do
                begin
                From:='Абонент'; //кто написал
                Date:=now;
                FromColor:=clGradientActiveCaption;// цвет   clGradientActiveCaption
                FromType:=TChatMessageType.mtOpponent;          //mtOpponent, mtMe  кто написал, я или мне
                Text:=BufferTemp; // текст сообщения
                date:=now;
                end;

              if not(Visible) then
              begin
                PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                Show;
              end;
  step:=32;
              if not(Active) then
              begin
                PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                FlashWindow(frm_Main.Handle, true);
                FlashWindow(frm_Chat.Handle, true);
              end;
            end
          end);
      end;
  step:=33;
 //---- запросили список каталогов директории--------------------------------------------------------------------------------
      Position := Pos('<|GETFOLDERS|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        SendMainCryptText('<|REDIRECT|><|FOLDERLIST|>' + ListFolders(BufferTemp) + '<|ENDFOLDERLIST|>');
      end;
  step:=34;
      // запросили список файлов в директории
      Position := Pos('<|GETFILES|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 11);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
       FoldersAndFiles := TStringList.Create;
        try
         if ListFiles(BufferTemp, '*.*',FoldersAndFiles) then
          begin
          if not SendMainCryptText('<|REDIRECT|><|FILESLIST|>'+FoldersAndFiles.CommaText+'<|ENDFILESLIST|>') then
           ThLog_Write('ThM',2,'Не удалось отправить список файлов директории '+BufferTemp);
          end
         else SendMainCryptText('<|REDIRECT|><|FILESLIST|><|ENDFILESLIST|>');
        finally
         FoldersAndFiles.Free;
        end;

      end;
  step:=35;
      // запросили список локалных дисков
      Position := Pos('<|GETLISTDRIVE|>', Buffer);
      if Position > 0 then
      begin
       SendMainCryptText('<|REDIRECT|><|LISTDRIVE|>' +ListlogDrive+ '<|END|>');
      end;
    // пришел список дисков удаленного ПК--------------------------------------------------------------------------------------------
      Position := Pos('<|LISTDRIVE|>', Buffer); //
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 12);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        FoldersAndFiles := TStringList.Create;
        try
        FoldersAndFiles.CommaText:=BufferTemp;

         if frm_ShareFiles.Visible then  // если открыта форма передачи файлов из буфера обмена
          Begin
          Synchronize(
            procedure
            var i,z: Integer;
            begin
              frm_ShareFiles.ComboRemoteDrive.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
              frm_ShareFiles.ComboRemoteDrive.Items.Add(FoldersAndFiles.Names[i]);
              if tryStrtoint(FoldersAndFiles.ValueFromIndex[i],z) then frm_ShareFiles.ComboRemoteDrive.ItemsEx[i].ImageIndex:=z
              else frm_ShareFiles.ComboRemoteDrive.ItemsEx[i].ImageIndex:=2;
              end;
              if frm_ShareFiles.ComboRemoteDrive.Items.Count>0 then
              begin
               frm_ShareFiles.ComboRemoteDrive.ItemIndex:=0;
               frm_ShareFiles.ComboRemoteDrive.OnSelect(FormFileTransfer.ComboRemoteDrive);
              end;
            end);
          End;

        if FormFileTransfer.Visible then //если открыта форма передачи файлов и каталогов
          Begin
           Synchronize(
            procedure
            var i,z: Integer;
            begin
              FormFileTransfer.ComboRemoteDrive.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
              FormFileTransfer.ComboRemoteDrive.Items.Add(FoldersAndFiles.Names[i]);
              if tryStrtoint(FoldersAndFiles.ValueFromIndex[i],z) then FormFileTransfer.ComboRemoteDrive.ItemsEx[i].ImageIndex:=z
              else FormFileTransfer.ComboRemoteDrive.ItemsEx[i].ImageIndex:=2;
              end;
              if FormFileTransfer.ComboRemoteDrive.Items.Count>0 then
              begin
               FormFileTransfer.ComboRemoteDrive.ItemIndex:=0;
               FormFileTransfer.ComboRemoteDrive.OnSelect(FormFileTransfer.ComboRemoteDrive);
              end;
            end);
          End;
        finally
        FoldersAndFiles.Free;
        end;
      end;
    // пришел список каталогов запрошеной директории -----------------------------------------------------------------------------------------------------------
      Position := Pos('<|FOLDERLIST|>', Buffer); //
      if Position > 0 then
      if Buffer.Contains('<|ENDFOLDERLIST|>') then
      begin
  step:=36;
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);
        FoldersAndFiles := TStringList.Create;
        try
        FoldersAndFiles.CommaText := Copy(BufferTemp, 1, Pos('<|ENDFOLDERLIST|>', BufferTemp) - 1);
        FoldersAndFiles.Sort;
  step:=37;
        if frm_ShareFiles.Visible then  // если открыта форма передачи файлов из буфера обмена
          Begin
          Synchronize(
            procedure
            var i: Integer;
            begin
              frm_ShareFiles.ShareFiles_ListView.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                if FoldersAndFiles.Names[i]='..' then // если значение "на каталог выше"
                begin
                 with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                  begin
                  Caption := 'Назад';
                  ImageIndex := 0;
                  SubItems.Add(''); // дата и время
                  SubItems.Add(''); // размер файла
                  end;
                end
                else
                begin
                 with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                  begin
                  Caption := FoldersAndFiles.Names[i];
                  ImageIndex := 1;
                  SubItems.Add(FoldersAndFiles.ValueFromIndex[i]); // дата и время
                  SubItems.Add(''); // размер файла
                  end;
                end;
              end;
            end);
          SendMainCryptText('<|REDIRECT|><|GETFILES|>' + frm_ShareFiles.EditDirClient.Text + '<|END|>');
          End;

        if FormFileTransfer.Visible then //если открыта форма передачи файлов и каталогов
          Begin
           Synchronize(
            procedure
            var i: Integer;
            begin
              FormFileTransfer.LVClient.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                if FoldersAndFiles.Names[i]='..' then // если значение "на каталог выше"
                begin
                 with FormFileTransfer.LVClient.Items.Add do
                  begin
                  Caption := 'Назад';
                  ImageIndex := 0;
                  SubItems.Add(''); // дата и время
                  SubItems.Add(''); // размер файла
                  end;
                end
                else
                begin
                 with FormFileTransfer.LVClient.Items.Add do
                  begin
                  Caption := FoldersAndFiles.Names[i];
                  ImageIndex := 1;
                  SubItems.Add(FoldersAndFiles.ValueFromIndex[i]); // дата и время
                  SubItems.Add(''); // размер файла
                  end;
                end;
                //FormFileTransfer.Caption := 'Каталоги и файлы - ' + IntToStr(FormFileTransfer.LVClient.Items.count) + ' элементов';
              end;
            end);
          SendMainCryptText('<|REDIRECT|><|GETFILES|>' + FormFileTransfer.EditDirClient.Text + '<|END|>');
          End;
        finally
        FreeAndNil(FoldersAndFiles);
        end;
      end;
  // -----------------------------------------------------------------------------------------------------------
  // пришел список файлов запрошеной директории------------------------------------------------------------------------------------------------
      Position := Pos('<|FILESLIST|>', Buffer);  //
      if Buffer.Contains('<|ENDFILESLIST|>') then
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 12);
        FoldersAndFiles := TStringList.Create;
        try
        FoldersAndFiles.CommaText := Copy(BufferTemp, 1, Pos('<|ENDFILESLIST|>', BufferTemp) - 1);
        FoldersAndFiles.Sort;
        if frm_ShareFiles.Visible  then  // если открыта форма передачи файлов из буфера обмена
          Begin
          Synchronize(
            procedure
            var i: Integer;
            begin
             if (frm_ShareFiles.ShareFiles_ListView.Items.Count=0) then
              begin
               with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                begin
                Caption := 'Назад';
                ImageIndex:=0;
                SubItems.Add(''); // дата и время
                SubItems.Add(''); // размер файла
                end;
              end;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                begin
                Caption := FoldersAndFiles.Names[i];
                ImageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(Caption)));
                ParsingFileDateSize(FoldersAndFiles.ValueFromIndex[i],TempI,TempZ);
                SubItems.Add(TempI); // дата и время
                SubItems.Add(TempZ); // размер файла
                end;
              end;
              frm_ShareFiles.EditDirClient.Enabled := true;
            end);
          End;

          if FormFileTransfer.Visible then //если открыта форма передачи файлов и каталогов
           Begin
             Synchronize(
            procedure
            var i: Integer;
            begin
             if (FormFileTransfer.LVClient.Items.Count=0) then
              begin
               with FormFileTransfer.LVClient.Items.Add do
                begin
                Caption := 'Назад';
                ImageIndex:=0;
                SubItems.Add(''); // дата и время
                SubItems.Add(''); // размер файла
                end;
              end;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
               with FormFileTransfer.LVClient.Items.Add do
                begin
                Caption := FoldersAndFiles.Names[i];
                ImageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(Caption)));
                ParsingFileDateSize(FoldersAndFiles.ValueFromIndex[i],TempI,TempZ);
                SubItems.Add(TempI); // дата и время
                SubItems.Add(TempZ); // размер файла
                end;
              end;
              FormFileTransfer.EditDirClient.Enabled := true;
              //FormFileTransfer.Caption := 'Каталоги и файлы - ' + IntToStr(FormFileTransfer.LVClient.Items.count) + ' элементов';
            end);
           End;
        finally
        FreeAndNil(FoldersAndFiles);
        end;
      end;
  END; // while
   frm_Main.ArrConnectSrv[IDConnect].ConnectBusy:=false; // признак освобождения элемента массива
   RecreateFileSocket:=false; // отменяет признак необходимости пересоздания файлового сокета при его разрыве
   RecreateDesktopSocket:=false; // отменяет признак необходимости пересоздания  сокета рабочего стола при его разрыве
   DeleteKeyMouseThread;
   //ThLog_Write('ThM','Поток (M) завершен');
  except on E : Exception do
    begin
    RecreateFileSocket:=false; // отменяет признак необходимости пересоздания файлового сокета при его разрыве
    RecreateDesktopSocket:=false; // отменяет признак необходимости пересоздания  сокета рабочего стола при его разрыве
    CloseMainSocket;// если произошла ошибка потока то сокеты возможно рабочие надо закрыть для последующего автозапус4ка сокета и потока
    DeleteKeyMouseThread; // завершаем поток для клавы и мыши если была ошибка
    ThLog_Write('ThM',2,inttostr(step)+') Общая ошибка главного потока : ');
    end;
  end;
end;



//-------------------------------------------------------------------------

//-------------------------------------------------------------
// подключение экранов рабочего стола
//-----------------------------------------------------

//-------------------------------------------------------------------------

function TThread_Connection_Main.TThread_Connection_Desktop.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
     end;
   except
   exit;
   end;
end;
                            //Function CloseDesctopSocket(Mes:string):boolean;
Function TThread_Connection_Main.TThread_Connection_Desktop.CloseDesctopSocket(Mes:string):boolean;
  begin
   try
   if DesktopSocket<>nil then
   begin
   if DesktopSocket.Connected then DesktopSocket.Close;
   //if DesktopSocket<>nil then DesktopSocket.Free;
   //ThLog_Write('ThD','Отключение сокета (D) из потока '+Mes);
   end;
   except on E : Exception do
    begin
    ThLog_Write('ThD',2,'Ошибка закрытия из потока сокета (D) '+Mes);
    end;
  end;
  end;

// Compress Stream with zLib архивация данных перед отправкой
function TThread_Connection_Main.TThread_Connection_Desktop.CompressStreamWithZLib(SrcStream: TMemoryStream; var TimeResume:Double): Boolean;
var
  InputStream: TMemoryStream;
  inbuffer: Pointer;
  outbuffer: Pointer;
  count, outcount: longint;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
begin
  try
   //QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
  // QueryPerformanceCounter(T1); //засекли время начала операции
    Result := False;
    InputStream := TMemoryStream.Create;
    try
      InputStream.LoadFromStream(SrcStream);
      count := InputStream.Size;
      getmem(inbuffer, count);
      InputStream.ReadBuffer(inbuffer^, count);
      zcompress(inbuffer, count, outbuffer, outcount, zcDefault);
      SrcStream.Clear;
      SrcStream.Write(outbuffer^, outcount);
      Result := true;
    finally
      FreeAndNil(InputStream);
      FreeMem(inbuffer, count);
      FreeMem(outbuffer, outcount);
    end;
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThD',2,'Ошибка архивации потока (D)');
      end;
    end;
// QueryPerformanceCounter(T2);//засекли время окончания
// TimeResume:= (T2 - T1)/iCounterPerSec;
end;

// Decompress Stream with zLib   разархивация данных при получении
function TThread_Connection_Main.TThread_Connection_Desktop.DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
var
  InputStream: TMemoryStream;
  inbuffer: Pointer;
  outbuffer: Pointer;
  count: longint;
  outcount: longint;
begin
try
  Result := False;
  InputStream := TMemoryStream.Create;

  try
    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    zdecompress(inbuffer, count, outbuffer, outcount);
    SrcStream.Clear;
    SrcStream.Write(outbuffer^, outcount);
    Result := true;
  finally
    FreeAndNil(InputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThD',3,'Ошибка извлечения потока из архива (D) - '+inttostr(TmpHdl));
      end;
    end;
end;
//---------------------------------------------------------------------------------

function TThread_Connection_Main.TThread_Connection_Desktop.DesOpenInput(var FirstDesktop:HDESK):boolean;
 var
 hDesktop: HDESK;
 begin
 try
  ///-----------------------------------------------------------------------------------------
   result:=false;
   if not frm_Main.Accessed then exit; // если доступ разрешен то выолняем, иначе если мы клиент то это лишние действия
   hDesktop := OpenInputDesktop(0,true,MAXIMUM_ALLOWED); //Открывает рабочий стол, получающий входные данные пользователя.
   try
    if FirstDesktop<>hDesktop then
      begin
       if hDesktop<>0 then
         begin
         if not SetThreadDesktop(hDesktop)then //Назначает указанный рабочий стол вызывающему потоку.
         ThLog_write('ThD',1,'Поток (D): Ошибка STD: '+SysErrorMessage(GetLastError()));
         result:=true;
         FirstDesktop:=hDesktop;
         end
         else
         begin
         ThLog_write('ThD',1,'Поток (D): Ошибка OID: '+SysErrorMessage(GetLastError()));
         result:=false;
         end;
      end;
   finally
   CloseHandle(hDesktop);
   end;
  ///-----------------------------------------------------------------------------------------
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThD',2,'Ошибка STD/OID потока (D)');
      end;
    end;
 end;

//------------------- поток для Desktop

function TThread_Connection_Main.TThread_Connection_Desktop.MemoryStreamToString(M: TMemoryStream): AnsiString; //перевод из памяти в строку
begin
try
  SetString(Result, PAnsiChar(M.Memory), M.Size);
except on E : Exception do ThLog_write('ThD',2,'Ошибка MemoryToS');  end;
end;

function TThread_Connection_Main.TThread_Connection_Desktop.SendMainSocket(s:ansistring):boolean;
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IdConnect].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IdConnect].mainSock.Connected then
   while frm_Main.ArrConnectSrv[IdConnect].mainSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_write('ThD',2,'Ошибка отправки сокета (М) внешняя функции');  end;
end;


function TThread_Connection_Main.TThread_Connection_Desktop.ZConpress(Var InCompressStream,OutCompressStream:TmemoryStream; var TimeResume:Double):Boolean;
var
 PackCompress:TZCompressionStream;
 iCounterPerSec: TLargeInteger;
 T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
begin
  try
  //QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
 // QueryPerformanceCounter(T1); //засекли время начала операции
  PackCompress:=TZCompressionStream.Create(clDefault,OutCompressStream); //clDefault clMax clFastest
  PackCompress.CopyFrom(InCompressStream,InCompressStream.Size);
  PackCompress.Free;
  //QueryPerformanceCounter(T2);//засекли время окончания
  //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' сек.';
  result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_write('ThD',2,'Ошибка Conpress');
    end;
  end;
end;




function TThread_Connection_Main.TThread_Connection_Desktop.ZDeconpress(InDeCompressStream,UotDeCompressStream:TmemoryStream):boolean;
var
 PackDeCompress:TZDecompressionStream;
begin
  try
  PackDeCompress:=TZDecompressionStream.Create(InDeCompressStream);
  UotDeCompressStream.CopyFrom(PackDeCompress,0);
  PackDeCompress.Free;
  result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_write('ThD',2,'Ошибка DeConpress ');
    end;
  end;
end;

function TThread_Connection_Main.TThread_Connection_Desktop.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
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

function TThread_Connection_Main.TThread_Connection_Desktop.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
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

//------------------------------------------------------------------------------------------------
Procedure TThread_Connection_Main.TThread_Connection_Desktop.NoLineCompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream; var TimeResume:Double; var ResStr:string; var ResB:boolean);
var
  I,Z,X,Y,BytesPerPixel : Integer;
  ScanBytes   : Integer;
  P1: ^byte; // указатель на byte аналогично Pbyte
  P2: ^byte;
  P3: ^byte;
  h,w:integer;
  step:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
  function GetBytesPerPixel(APixelFormat: Vcl.Graphics.TPixelFormat): Byte; overload;
  const
    ByteCounts: array [Vcl.Graphics.TPixelFormat] of Byte =
      (4,0,0,1,2,2,3,4,2);
  begin
    Result := ByteCounts[APixelFormat];
  end;

  function LengthScanLine(tmpBmp:Tbitmap; var LenghtLine:Integer):boolean; // определяем длинну одной линии пикселей
  begin
    try
    LenghtLine:=Abs(Integer(tmpBmp.Scanline[1]) - Integer(tmpBmp.Scanline[0])); // определяем длинну одной линии пикселей
    result:=true;
      except on E : Exception do
      begin
      result:=false;
      ResStr:=ResStr+' LengthScanLine: result='+inttostr(LenghtLine)+' Error: '+E.ClassName+': '+E.Message+' |'
      end;
    end;
  end;


begin
   try
   //QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
  // QueryPerformanceCounter(T1); //засекли время начала операции
   step:=0;
      if (MyFirstBMP.Width<>MySecondBMP.Width) or (MyFirstBMP.Height<>MySecondBMP.Height) or (MyFirstBMP.PixelFormat<>MySecondBMP.PixelFormat)  then
      begin
      step:=1;
      CompareBMP.Position:=0;
      MySecondBMP.SaveToStream(CompareBMP);
      MyFirstBMP.Assign(MySecondBMP);
      step:=2;
      end
     else
      Begin
       step:=3;
       ResB:=LengthScanLine(MyFirstBMP,ScanBytes); // определяем длинну одной линии пикселей
        if ResB then
         Begin
         MySecondBMP.Canvas.Lock;
         MyFirstBMP.Canvas.Lock;
           try
           step:=4;
               BytesPerPixel:=GetBytesPerPixel(MyFirstBMP.PixelFormat);  // определяем количество байт на пиксель
               step:=5;
               h:=MyFirstBMP.Height;
               w:=MyFirstBMP.Width;
               //ResStr:='ScanBytes='+inttostr(ScanBytes)+' BytesPerPixel='+inttostr(BytesPerPixel)+' h/w='+inttostr(h)+'/'+inttostr(w);
               CompareBMP.SetSize(ScanBytes*h*BytesPerPixel); // размер потока в соответствии с размером битмапа (ScanBytes(длинну одной линии пикселей)*высота*кол-во байт на пиксель)
               CompareBMP.Position:=0;
               P3 := CompareBMP.Memory;
               P1 := MyFirstBMP.Scanline[0]; //строки в Bitmap расположены с конца, поэтому при получении указателя на 0ю строку мы находимся в конце файла
               P2 := MySecondBMP.Scanline[0];
               step:=6;
                for i:= 0 to h-1 do
                  Begin
                   if CompareMem(P1,P2,ScanBytes) then // если при сравнение в памяти массивов байт они идентичны, значит изменений в данной области экрана нет
                     begin
                      step:=7;
                     ZeroMemory(P3,ScanBytes); // заполняем в результирующем потоке всю строку нулями
                     inc(P3,ScanBytes);
                     Dec(P2,ScanBytes); // переход на следующую строку Bitmap. строки в Bitmap расположены с конца, поэтому при получении указателя на 0ю строку мы находимся в конце файла
                     Dec(P1,ScanBytes); // переход на следующую строку Bitmap
                     step:=8;
                     end
                   else // иначе проверяем каждый пиксель и хорим его
                     begin
                      for X := 0 to w-1 do
                       begin
                        for Y := 0 to BytesPerPixel - 1 do
                          begin
                          step:=9;
                          P3^:=P1^ XOR P2^;
                          inc(P3);
                          inc(P1);
                          inc(P2);
                          step:=10;
                          end;
                       end;
                     step:=11;
                     Dec(P2,(w*BytesPerPixel)+ScanBytes);  // переход на следующую строку Bitmap с учетом того что мы сейчас в конце строки а не в начале
                     Dec(P1,(w*BytesPerPixel)+ScanBytes);  // переход на следующую строку Bitmap с учетом того что мы сейчас в конце строки а не в начале
                     step:=12;
                     end;
                  End;
               step:=13;
               MyFirstBMP.Assign(MySecondBMP);
               step:=14;
           finally
           MySecondBMP.Canvas.UnLock;
           MyFirstBMP.Canvas.UnLock;
           //p1:=nil;
           //p2:=nil;
           //p3:=nil;
           end;
        end;
        step:=15;
      end;
      // QueryPerformanceCounter(T2);//засекли время окончания
    //  TimeResume:=(T2 - T1)/iCounterPerSec;
    except on E : Exception do
      begin
       ResB:=false;
       MySecondBMP.Canvas.UnLock;
       MyFirstBMP.Canvas.UnLock;
       ResStr:='step='+inttostr(step)+' Error: '+E.ClassName+': '+E.Message;
      end;
    end;
end;
//------------------------------------------------------------------------------------------------
function  TThread_Connection_Main.TThread_Connection_Desktop.ScreenBmpCanvasSaveBMP(MonX,MonY,MonWidth,MonHeight:integer; inDC:HDC; resizes:boolean; wR,hR:integer; Mybmp: TBitmap; DrawCur:boolean; pixF:TPixelFormat; var TimeCompare:Double; var ResStr:string):boolean; // screen bmp save to bmp
var
  DC : HDC;
  GDWhWnd:HWND;
  x0,y0,h,w,hTMP,wTMP:integer;
  res:boolean;
  step:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
begin
try
  //QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
 // QueryPerformanceCounter(T1); //засекли время начала операции
 step:=0;
  GDWhWnd:=GetDesktopWindow();// Извлекает дескриптор окна рабочего стола. Окно рабочего стола занимает весь экран. Окно рабочего стола — это область, поверх которой рисуются другие окна.
  DC:=GetWindowDC(GDWhWnd); //извлекает контекст устройства (DC) для всего окна, включая строку заголовка, меню и полосы прокрутки.
 step:=1;
  try
    begin
  step:=2;
      x0:=MonX;
      y0:=MonY;
      w:=MonWidth;
      h:=MonHeight;
     step:=3;
          if resizes then
           begin
           wTMP:=wR; hTMP:=hR;
           end
          else
           begin
           wTMP:=w; hTMP:=h;
           end;
       step:=4;
          Mybmp.Canvas.Lock;
           try
            Mybmp.PixelFormat := pixF; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom
        step:=5;
            Mybmp.Width  := wTMP;
        step:=6;
            Mybmp.Height := hTMP;
            step:=7;
                 if resizes then
                begin
            step:=8;
                if SetStretchBltMode({bmpDC}Mybmp.Canvas.Handle, HALFTONE)<>0 then;//COLORONCOLOR HALFTONE  BLACKONWHITE
                SetBrushOrgEx({bmpDC}Mybmp.Canvas.Handle, 0,0, NIL); // use else HALFTONE
                res:=StretchBlt(Mybmp.Canvas.Handle, 0, 0, wTMP, hTMP, DC, x0, y0, w, h, SRCCOPY);
                end
               else
                res:=BitBlt(Mybmp.Canvas.Handle, 0, 0, w, h, DC, x0, y0, SRCCOPY);
             if not res then ResStr:=SysErrorMessage(GetLastError());

            step:=9;
            step:=10;
           finally
           Mybmp.Canvas.Unlock;
           end;
     end;
    step:=11;
  finally
   releaseDC(GDWhWnd,DC);
  end;
   step:=12;
 // QueryPerformanceCounter(T2);//засекли время окончания
 // TimeCompare:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' сек.';
 //  if  not res then Log_write('ThD','Ошибка Screen:' +SysErrorMessage(GetLastError()));
  except on E : Exception do
    begin
    res:=false;
    ResStr:=ResStr+' / Error: '+E.ClassName+': '+E.Message;
    ThLog_Write('ThD',2,inttostr(step)+') - Ошибка ScreenBmpCanvasSaveStream: ');
    end;
  end;
result:=res;
end;
////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TThread_Connection_Main.TThread_Connection_Desktop.ResumeStreamXORBMP(
   var FirstBMP, CompareBMP:Tbitmap;  //первая/предыдущая картинка - будущая объединенная  (FirstBMP+SecondBMP)
   var SecondBMP:TmemoryStream;        //   - поток который пришел, в нем разница между предыдущей картинкой и той которую надо сформировать
   var SecondSize:int64;              // размер полученого потока
   var TimeResume:double;            // время. для расчета затраченого времени
   var ResStr:string;               // рузультат/ошибка в текста
   var ResB:boolean              // результат в boolean
   );
var
  I,X,Y : Integer;
  h,w,ScanBytes,BytesPerPixel:integer;
  P1: ^byte;
  P2: ^byte;
  P3: ^byte;
  ZeroArray : Array of byte;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
  step:integer;


  function LengthScanLine(TmpBmp:Tbitmap; var LenghtLine:Integer):boolean; // определяем длинну одной линии пикселей
  begin
    try
    LenghtLine:=Abs(Integer(TmpBmp.Scanline[1]) - Integer(TmpBmp.Scanline[0])); // определяем длинну одной линии пикселей
    result:=true;
      except on E : Exception do
      begin
      result:=false;
      ResStr:=' LengthScanLine: result='+inttostr(LenghtLine)+' Error: '+E.ClassName+': '+E.Message+' |'
      end;
    end;
  end;

 function GetBytesPerPixel(APixelFormat: Vcl.Graphics.TPixelFormat): Byte; overload;
  const
   ByteCounts: array [Vcl.Graphics.TPixelFormat] of Byte = (4,0,0,1,2,2,3,4,2);
   begin
    Result := ByteCounts[APixelFormat];
   end;

begin
  try
   ResB:=true;
   //QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
   //QueryPerformanceCounter(T1); //засекли время начала операции
   step:=0;
   if (SecondSize<>0) and (SecondSize<>SecondBMP.Size) then // если размер пришедшего потока не равен предыдущему, то возможно изменилось разрешение
    begin
    step:=1;
    SecondSize:=SecondBMP.Size;
    SecondBMP.Position:=0;
    CompareBMP.LoadFromStream(SecondBMP);
    SecondBMP.Position:=0;
    FirstBMP.LoadFromStream(SecondBMP);
    end
   else
     begin
     step:=3;
      FirstBMP.Canvas.lock;
      CompareBMP.Canvas.Lock;
      step:=4;
      ResB:=LengthScanLine(FirstBMP,ScanBytes); // определяем длинну одной линии пикселей
       try
       if ResB then
          begin
          step:=5;
          SecondSize:=SecondBMP.Size; // указываем размер полученного потока для последующего сравнения
          step:=6;
          BytesPerPixel:=GetBytesPerPixel(FirstBMP.PixelFormat);  // определяем количество байт на пиксель
          step:=7;
          h:=FirstBMP.Height;
          step:=8;
          w:=FirstBMP.Width;
          step:=9;
          SecondBMP.Position:=0; // обязательно перевод
          P3:=SecondBMP.Memory;// т.к потоко содержит только строки bmp без заголовков
          step:=10;
          SetLength(ZeroArray,ScanBytes); // длинна нулевого массива
          ZeroMemory(ZeroArray,ScanBytes); // заполяем нулями
            try
            step:=11;
            for i:=0 to h-1 do
               Begin
                if CompareMem(ZeroArray,P3,ScanBytes) then // если при сравнение в памяти массивов байт они идентичны (проверка на пустую строку)
                 begin  //  значит изменения в данной области не производились. то пропускаем данную память для дальнейшей проверки
                 inc(P3,ScanBytes);
                 step:=12;
                 end
                else // иначе проверяем каждый пиксель и хорим его
                 begin
                 P1 := FirstBMP.Scanline[I];
                 P2 := CompareBMP.Scanline[I];
                 step:=13;
                 for X := 0 to w-1 do
                  for Y := 0 to BytesPerPixel - 1 do // 1, to 4, dep. on pixelformat
                   begin
                   P2^:=P3^ XOR P1^;
                   Inc(P1);
                   Inc(P2);
                   Inc(P3);
                   end;
                 end;
               step:=14;
               End;
             step:=15;
             finally
             ZeroArray:=nil;
             end;
           FirstBMP.Assign(CompareBMP);
          end;
       finally
       step:=16;
       FirstBMP.Canvas.Unlock;
       CompareBMP.Canvas.UnLock;
       end;
       //SecondBMP.Clear;
      // CompareBMP.SaveToStream(SecondBMP);
      // SecondBMP.Position:=0;
       step:=17;
     end;
     step:=18;
   //QueryPerformanceCounter(T2);//засекли время окончания
   //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' сек.';
   step:=19;
  except on E : Exception do
    begin
     resb:=false;
     FirstBMP.Canvas.Unlock;
     CompareBMP.Canvas.UnLock;
     ResStr:=ResStr+' ('+inttostr(step)+') Error: '+E.ClassName+': '+E.Message+' |';
    end;
  end;

end;
//-------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

procedure TThread_Connection_Main.TThread_Connection_Desktop.Execute;
var
  PosStart,Position: Integer;
  Buffer: string;
  TempBuffer: string;
  PackStream: TMemoryStream;
  CompareBmp:Tbitmap;
  FirstBmp:Tbitmap;
  SecondBmp:Tbitmap;
  SeconStreamSize:int64;
  FirstStreamSize:int64;
  GetBmp:boolean;
  GDWhWnd:HWND;
  CurrentDesktop: HDESK;
  DC: HDC;
  TimeFPS,TimeScreen,TimeCompare,TimeResume,TimeCompress,TimeDecompress:Double;
  CountFps:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
  ResScrn,ResCompare,ResResume:boolean;
  ResScrnStr,ResCompareStr,ResResumeStr:string;
  RcvLScanLine,RcvPixFormat,RcvWbmp,RcvHbmp:integer;
  GetFullSrcn:boolean;
  Step:integer;
  SendImage:boolean;
function SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
if Encryptstrs(s,PswrdCrypt, CryptBuf) then  //шифруем перед отправкой
SendMainSocket('<!>'+CryptBuf+'<!!>') //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
else ThLog_Write('ThD',1,'Поток D Не удалось защифровать данные');
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThD',2,'Поток D Ошибка шифрования и отправки данных ');
    end;
  end;
end;


function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
var
i:integer;
posStart,posEnd:integer;
bufTmp:string;
CryptTmp,DecryptTmp:string;
begin
  try
  bufTmp:='';
   while s<>'' do // в цикле чистим
     begin
      CryptTmp:='';
      DecryptTmp:='';
      posStart:=pos('<!>',s);// начало зашифрованной стороки
      posEnd:=pos('<!!>',s); // конец зашифрованной стороки
      CryptTmp:=copy(s,posStart+3,posEnd-4);// копируем необходимую строку
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //дешифровка скопированной строки
      bufTmp:=bufTmp+DecryptTmp;// объединение расшифрованной строки
      delete(s,posStart+3,posEnd-4);
      if posStart=0 then
        begin
        s:='';
        break;
        end;
     end;
   result:=bufTmp;
  except On E: Exception do
    begin
    s:='';
    ThLog_Write('ThD',2,' Поток D Ошибка дешифрации данных ');
    end;
  end;
end;
//----------------------------------------------------------------------
 function GetBytesPerPixel(APixelFormat: Vcl.Graphics.TPixelFormat): Byte; overload;
    const
      ByteCounts: array [Vcl.Graphics.TPixelFormat] of Byte =
        (4,0,0,1,2,2,3,4,2);
    begin
      Result := ByteCounts[APixelFormat];
    end;

 function LengthScanLine(TmpBmp:Tbitmap; var ScLine:integer):boolean; // определяем длинну одной линии пикселей
  begin
    try
    ScLine:=Abs(Integer(TmpBmp.Scanline[1]) - Integer(TmpBmp.Scanline[0])); // определяем длинну одной линии пикселей
    result:=true;
      except on E : Exception do
      begin
      result:=false;
      ThLog_Write('ThD',2,'Поток (D) ошибка First LengthScanLine : Error: '+E.ClassName+': '+E.Message);
      end;
    end;
  end;
//-------------------------------------------------------------------------------------------------------
begin
try
  inherited;
  //ThLog_Write('ThD','Поток D запущен - '+inttostr(TmpHdl));
  step:=1;
  PswrdCrypt:=frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt; // присваиваем пароль для шифрования в потоке
  HashPswrdCrypt:=THashSHA2.GetHashString(PswrdCrypt,SHA256); // Расчет хеша установленного пароля
  CurrentDesktop:=0;
  CurrentFPSSession:=FpsMaxCount; //кадры в секунду
  step:=2;
  DesOpenInput(CurrentDesktop);//------------------------------>
  if not SendMainCryptText('<|REDIRECT|><|DSKTPCREATED|>')  then // отправка данных в основной сокет для того кто ко мне подключился
  begin
  //ThLog_Write('ThD','НЕ УДАЛОСЬ ОТПРАВИТЬ <|REDIRECT|><|DSKTPCREATED|>');
  CloseDesctopSocket('НЕ УДАЛОСЬ ОТПРАВИТЬ ПОДТВЕРЖДЕНИЕ СОЗДАНИЯ ПОТОКА (D)'); // отключаем сокет рабочего стола т.к. не сообщили о содании потока, и выходим из потока.
  exit;   // сообщаем клиенту о создании сокета для экрана
  end;
  step:=3;
  SendImage:=false; // принимаю или отправляю картинку
  PackStream := TMemoryStream.Create;
  SecondBmp:=Tbitmap.Create;
  SecondBmp.PixelFormat:=frm_Main.ImagePixelF;
  FirstBmp:=Tbitmap.Create;
  FirstBmp.PixelFormat:=frm_Main.ImagePixelF;
  CompareBMP:=Tbitmap.Create;
  CompareBMP.PixelFormat:=frm_Main.ImagePixelF;
  SeconStreamSize:=0;
  FirstStreamSize:=0;
  CountFps:=0;
  TimeScreen:=0;
  QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
  GetFullSrcn:=false;

  step:=4;
  while not terminated do
  begin
   if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
    Sleep(ProcessingSlack); // Avoids using 100% CPU
    if (DesktopSocket = nil) or not(DesktopSocket.Connected) then Break;
    if DesktopSocket.ReceiveLength < 1 then Continue;
   step:=5;
    Buffer := Buffer + DesktopSocket.ReceiveText; // сохраняем в буфер все что получаем

    ////////////////////////////////////////////////////////// отдаем картинку, т.е. я сервер
    Position := Pos('<!>'+HashPswrdCrypt+'<!!>', Buffer); // признак необходимости отправить первый скрин
    if Position > 0 then
    begin
    step:=6;
      Delete(Buffer, 1, Position + 20);
     SendMainCryptText('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Width) // разрешение экрана
      + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Height) + '<|END|>');
      SendMainCryptText('<|REDIRECT|><|MONITORLEFTTOP|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Left)     // положение экрана
      + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Top) + '<|END|>');
      step:=7;
        try
         DesOpenInput(CurrentDesktop);//------------------------------>  если не получили доступ к рабочему столу то выходим из цикла потока
         ResScrn:=ScreenBmpCanvasSaveBMP(frm_Main.MonitorCurrentX,frm_Main.MonitorCurrentY,frm_Main.MonitorCurrentWidth,frm_Main.MonitorCurrentHeight,DC,frm_Main.ScreenResizes,frm_Main.ResolutionResizeWidth,frm_Main.ResolutionResizeHeight,FirstBmp,false,frm_Main.ImagePixelF,TimeScreen,ResScrnStr);
         if not ResScrn then ThLog_Write('ThD',2,'Поток (D) ошибка First ScreenShot : '+ResScrnStr);
      step:=8;
          Begin
              PackStream.Clear;
              FirstBmp.SaveToStream(PackStream); // это первый скрин
              PackStream.Position:=0;
              CompressStreamWithZLib(PackStream,TimeCompress); // сжимаем картинку
              PackStream.Position:=0;
              if (DesktopSocket<>nil)and (DesktopSocket.Connected) then
                begin
                while DesktopSocket.SendText('<|!F|>' + MemoryStreamToString(PackStream) + '<|!F!|>')<0 do  // отправляем первую картинку
                Sleep(ProcessingSlack);
                end
              else break;
           end ;
       step:=9;
         SendImage:=true; //я отправляю картинку
          while not terminated do
            BEGIN
              if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
              if (DesktopSocket = nil) or not(DesktopSocket.Connected) then Break;
              QueryPerformanceCounter(T1); //засекли время начала операции
              step:=10;

               if DesktopSocket.ReceiveLength > 1 then
                begin
                 Buffer := DesktopSocket.ReceiveText;
                 step:=17;
                  if Buffer.Contains('<|FULLSCRNSHOT|>') then
                   begin
                   Buffer:='';
                   step:=18;
                   DesOpenInput(CurrentDesktop);//------------------------------>  если не получили доступ к рабочему столу то выходим из цикла потока
                   ResScrn:=ScreenBmpCanvasSaveBMP(frm_Main.MonitorCurrentX,frm_Main.MonitorCurrentY,frm_Main.MonitorCurrentWidth,frm_Main.MonitorCurrentHeight,DC,frm_Main.ScreenResizes,frm_Main.ResolutionResizeWidth,frm_Main.ResolutionResizeHeight,FirstBmp,false,frm_Main.ImagePixelF,TimeScreen,ResScrnStr);
                   if not ResScrn then ThLog_Write('ThD',2,'Поток (D) ошибка FullScreenShot : '+ResScrnStr);
                   PackStream.Clear;
                   FirstBmp.SaveToStream(PackStream); // это первый скрин
                   PackStream.Position:=0;
                   CompressStreamWithZLib(PackStream,TimeCompress); // сжимаем картинку
                   PackStream.Position:=0;
                   step:=19;
                   if (DesktopSocket<>nil)and (DesktopSocket.Connected) then
                     begin
                     while DesktopSocket.SendText('<|!F|>' + MemoryStreamToString(PackStream) + '<|!F!|>')<0 do  // отправляем первую картинку
                     Sleep(ProcessingSlack);
                     end
                     else break;
                     GetFullSrcn:=false;
                     continue; //если отправили полный скрин то возвращаемся для ожтдания запроса;
                   end;
                 end;
                     step:=20;

              try
              DesOpenInput(CurrentDesktop); //---------------------------->
              ResScrn:=ScreenBmpCanvasSaveBMP(frm_Main.MonitorCurrentX,frm_Main.MonitorCurrentY,frm_Main.MonitorCurrentWidth,frm_Main.MonitorCurrentHeight,DC,frm_Main.ScreenResizes,frm_Main.ResolutionResizeWidth,frm_Main.ResolutionResizeHeight,SecondBmp,false,frm_Main.ImagePixelF,TimeScreen,ResScrnStr);
              if not ResScrn then ThLog_Write('ThD',2,'Поток (D) ошибка Second  ScreenShot : '+ResScrnStr);
              except
                DesOpenInput(CurrentDesktop);//---------------------------------->
                ResScrn:=ScreenBmpCanvasSaveBMP(frm_Main.MonitorCurrentX,frm_Main.MonitorCurrentY,frm_Main.MonitorCurrentWidth,frm_Main.MonitorCurrentHeight,DC,frm_Main.ScreenResizes,frm_Main.ResolutionResizeWidth,frm_Main.ResolutionResizeHeight,SecondBmp,false,frm_Main.ImagePixelF,TimeScreen,ResScrnStr);
                if not ResScrn then ThLog_Write('ThD',2,'Поток (D) ошибка ExSecond ScreenShot : '+ResScrnStr);
              end;
               step:=11;
              if ResScrn then // если удачный скрин
                Begin
                  PackStream.Clear;
                  PackStream.Position := 0;
                   step:=12;
                    NoLineCompareStreamXORBmp(FirstBmp,SecondBmp,PackStream,TimeCompare,ResCompareStr,ResCompare);
                   if ResCompare then // если удачно вычислили разницу между скринами
                    Begin
                     PackStream.Position := 0;
                    step:=13;
                     if CompressStreamWithZLib(PackStream,TimeCompress) then
                      begin
                      step:=14;
                       if PackStream.Size>0 then
                         begin
                          if (DesktopSocket <> nil) and (DesktopSocket.Connected) then
                           begin
                             try
                             step:=15;
                             QueryPerformanceCounter(T2);//засекли время окончания
                             TimeFPS:= (T2 - T1)/iCounterPerSec;
                             if TimeFPS<(1/CurrentFPSSession) then // ограничиваем скорость по кадрам
                               begin
                               sleep(Round(((1/CurrentFPSSession)-TimeFPS)*1000));
                               TimeFPS:=(1/CurrentFPSSession);
                               end;
                             TimeScreen:=TimeScreen+TimeFPS; // подсчет общего времени
                             inc(CountFps); // увеличиваем кол-во кадров
                             if TimeScreen>=1 then // если общее время больше или равно 1 сек
                               begin
                               SendMainCryptText('<|REDIRECT|><|TSC|>'+inttostr(CountFps)+'<|TCPS|>'); // кадров в сек
                               CountFps:=0;
                               TimeScreen:=0;
                               end;
                             except TimeScreen:=0;
                             end;
                           step:=16;
                               PackStream.Position:=0;
                               while DesktopSocket.SendText('<|!|>' + MemoryStreamToString(PackStream) + '<|!!|>') < 0 do
                               Sleep(ProcessingSlack);
                            end;
                         end;
                      end;
                     End
                     else
                      begin
                      //ResScrn:=ScreenBmpCanvasSaveBMP(frm_Main.MonitorCurrentX,frm_Main.MonitorCurrentY,frm_Main.MonitorCurrentWidth,frm_Main.MonitorCurrentHeight,DC,frm_Main.ScreenResizes,frm_Main.ResolutionResizeWidth,frm_Main.ResolutionResizeHeight,SecondBmp,false,frm_Main.ImagePixelF,TimeScreen,ResScrnStr);
                      ThLog_Write('ThD',2,'Поток (D) ошибка CompareScreenShot : '+ResCompareStr+#10+
                      ' W='+inttostr(frm_Main.MonitorCurrentWidth)+' H='+inttostr(frm_Main.MonitorCurrentHeight)+#10+
                      'FirstW='+inttostr(FirstBmp.Width)+' FirstH='+inttostr(FirstBmp.Height)+#10+
                      ' SecondW='+inttostr(SecondBmp.Width)+' SecondH='+inttostr(SecondBmp.Height)+#10+
                      ' ResizeW='+inttostr(frm_Main.ResolutionResizeWidth)+' ResizeH='+inttostr(frm_Main.ResolutionResizeHeight));
                      ResCompareStr:='';
                      end
                End;
            END;
       except on E : Exception do
          begin
          ThLog_Write('ThD',2,'Поток (D) Общая ошибка SendScreenShot / ResScrn='+ResScrnStr+' / ResCompare='+ResCompareStr);
          end;
       end;
    end;
 ////////////////////////////////////////////////////////////////////принимаем картинку, т.е. я клиент

     if Buffer.Contains('<|!F!|>') then  // полный скрин
      BEGIN   //'<|!F|>...<|!F!|>'
      step:=21;
      GetFullSrcn:=false; //  пришел запрошеный ранее полный скрин
        Delete(Buffer, 1, Pos('<|!F|>', Buffer) + 5);
        Position := Pos('<|!F!|>', Buffer);
        TempBuffer := Copy(Buffer, 1, Position - 1); // копирвоание во временный буфер того что надо засунть в потоко
        //Delete(Buffer, 1, Position + 6); //  Очищает буфер/память изображения, которое было обработано.
        Buffer:='';
        PackStream.Write(AnsiString(TempBuffer)[1], Length(TempBuffer)); // запись в поток то что получили
        PackStream.Position := 0;
        step:=22;
        if PackStream.Size>0 then // если поток не нулевой
        if DeCompressStreamWithZLib(PackStream) then  //если удачно извлекли из архива то что пришло
           begin
           step:=23;
             begin
              step:=24;
              FirstStreamSize:=PackStream.Size; // уазываем размер полученого первого потока
              PackStream.Position:=0;
              FirstBMP.LoadFromStream(PackStream); // загружаем первую картинку
              PackStream.Position:=0;
              CompareBMP.LoadFromStream(PackStream); // дублируем первцю картнку
              PackStream.Position:=0;
              step:=25;
               try
               Synchronize(
               procedure                                           //MTimeScreen,MTimeCompress,MTimeCompare
                begin
                frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); //данная загрузка является лучше чем  Bitmap.Assign(CompareBMP)
                frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConnect].MyPing) + ' мс) fps~'+frm_Main.MTimeScreen;
                end);
                while DesktopSocket.SendText('<|NEXTSHOT|>')<0 do Sleep(ProcessingSlack);
                except on E : Exception do
                  begin
                  //ThLog_Write('ThD',2,'Поток (D) Load First ScreenShot : '+E.ClassName+': '+E.Message);
                  while DesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //повторный запрос полного скрина
                  GetFullSrcn:=true;
                 end;
               end;
               step:=26;
             end;
         end
         else
          begin
          while DesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //повторный запрос полного скрина
          GetFullSrcn:=true;
          //ThLog_Write('ThD',2,'Поток (D) Not decompress FullScreen ');
          end;
        TempBuffer :='';
      END;


     while (Buffer.Contains('<|!!|>')) and (not GetFullSrcn) do  // разница между предыдущим и текущим
      BEGIN
        //if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
        step:=21;
        Delete(Buffer, 1, Pos('<|!|>', Buffer) + 4);
        Position := Pos('<|!!|>', Buffer);
        TempBuffer := Copy(Buffer, 1, Position - 1); // копирвоание во временный буфер того что надо засунть в потоко
        Delete(Buffer, 1, Position + 5); //  Очищает буфер/память изображения, которое было обработано.
        PackStream.Write(AnsiString(TempBuffer)[1], Length(TempBuffer)); // запись в поток то что получили
        PackStream.Position := 0;
        step:=22;
        if PackStream.Size>0 then // если поток не нулевой
        if DeCompressStreamWithZLib(PackStream) then  //если удачно извлекли из архива то что пришло
           begin
           step:=23;
            if FirstStreamSize = 0 then // если пришла первая картинка
             begin
             step:=24;
              FirstStreamSize:=PackStream.Size; // уазываем размер полученого первого потока
              PackStream.Position:=0;
              FirstBMP.LoadFromStream(PackStream); // загружаем первую картинку
              PackStream.Position:=0;
              CompareBMP.LoadFromStream(PackStream); // дублируем первцю картнку
              PackStream.Position:=0;
              step:=25;
               try
               Synchronize(
               procedure
                begin
                frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); //данная загрузка является лучше чем  Bitmap.Assign(CompareBMP)
                frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConnect].MyPing) + ' мс) fps~'+frm_Main.MTimeScreen;
                end);
                except on E : Exception do
                  begin
                  //ThLog_Write('ThD',2,'Поток (D) Load First ScreenShot : '+E.ClassName+': '+E.Message);
                  while DesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //повторный запрос полного скрина
                  GetFullSrcn:=true;
                  end;
               end;
               step:=26;
             end
            else
             begin
              PackStream.Position := 0;  //CompareBMP
              ResumeStreamXORBMP(FirstBmp,CompareBMP,PackStream,SeconStreamSize,TimeResume,ResResumeStr,ResResume);
              step:=27;
              if not ResResume then
               begin
               while DesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //повторный запрос полного скрина
               //ThLog_Write('ThD',2,'Поток (D) ошибка Resume ScreenShot : '+ResResumeStr);
               ResResumeStr:='';
               Buffer:='';
               GetFullSrcn:=true;
               step:=28;
               end
               else
               begin
                 try
                  Synchronize(
                   procedure
                   begin
                    //frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); // вроде вызывает записание приложения
                    frm_RemoteScreen.Screen_Image.Picture.Bitmap.Assign(CompareBMP);
                    frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConnect].MyPing) + ' мс) fps~'+frm_Main.MTimeScreen;
                   end);
                 except on E : Exception do
                  begin
                   while DesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //повторный запрос полного скрина
                   //ThLog_Write('ThD',2,'Поток (D) Load Second ScreenShot : '+E.ClassName+': '+E.Message);
                   Buffer:='';
                   GetFullSrcn:=true;
                  end;
                 end;
                step:=29;
               end;
             end;
          end
          else
          begin
          //ThLog_Write('ThD',2,'Поток (D) Not DeCompressStream');
          end;
       PackStream.Clear;
      END;

 ////////////////////////////////////////////////////////////////////////////////
  end;
  step:=30;
  CompareBmp.Free;
  FirstBmp.Free;
  SecondBMP.Free;
  FreeAndNil(PackStream);
  Buffer :='';
  TempBuffer:='';
  StartThBegin:=false;
  step:=31;
  if not SendImage then // если я принимающая сторона, то обновляю картинку по умолчанию
   begin
   Synchronize(
   procedure
   begin
   frm_RemoteScreen.Screen_Image.Picture.Assign(frm_RemoteScreen.ScreenStart_Image1.Picture);
   end);
  end;
  //ThLog_Write('ThD','Поток D завершен  - '+inttostr(TmpHdl)+' strTmp='+strTmp);
except on E : Exception do
    begin
    Buffer :='';
    if assigned(CompareBmp) then CompareBmp.Free;
    if assigned(FirstBmp) then FirstBmp.Free;
    if assigned(SecondBmp) then SecondBmp.Free;
    if assigned(PackStream) then  FreeAndNil(PackStream);
    CloseDesctopSocket('Ошибка потока D '); // отключаем сокет рабочего стола на тот случай если поток завершается аварийно а сокет работает
    ThLog_Write('ThD',2,'('+inttostr(step)+') Поток (D) общая ошибка  - '+inttostr(TmpHdl)+' : '+E.ClassName+': '+E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------------------------------------
// Connection of Share Files
//---------------------------------------------------------------------------------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
      end;
   except on E : Exception do
    exit;
    end;
end;
//--------------------------------------------------------------------------

procedure TThread_Connection_Main.TThread_Connection_Files.CloseFilesSocket;
  begin
   try
   if FileSocket<>nil then
   begin
   if FileSocket.Connected then FileSocket.Close;
  // if FileSocket<>nil then FileSocket.Free;
   end;
   except on E : Exception do
    begin
    ThLog_Write('ThF',2,'Ошибка закрытия из потока сокета (F)');
    end;
  end;
  end;

//-----------------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.GetSize(bytes: Int64): string;  // расчет оъемов и перевод в текст
begin
  if bytes < 1024 then
    Result := IntToStr(bytes) + ' B'
  else if bytes < 1048576 then
    Result := FloatToStrF(bytes / 1024, ffFixed, 10, 1) + ' KB'
  else if bytes < 1073741824 then
    Result := FloatToStrF(bytes / 1048576, ffFixed, 10, 1) + ' MB'
  else if bytes > 1073741824 then
    Result := FloatToStrF(bytes / 1073741824, ffFixed, 10, 1) + ' GB';
end;

//------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if FileSocket=nil then result:=false
else
begin
  if FileSocket.Connected then
  begin
  while FileSocket.SendText(s)<0 do sleep(ProcessingSlack);
 //ThLog_Write('ThF','SendFileSocket отправляю - '+s);
  end
  else result:=false;
end;
except on E : Exception do ThLog_write('ThF',2,'Ошибка отправки сокета (F) внешняя функция (F) ');  end;
end;
//-----------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.SendMainSocket(s:ansistring):boolean;
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IdConnect].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IdConnect].mainSock.Connected then
   while frm_Main.ArrConnectSrv[IdConnect].mainSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_write('ThF',2,'Ошибка отправки сокета (М) внешняя функции (F)');  end;
end;
//---------------------------------------------------------------------------------------------
// Compress Stream with zLib архивация данных перед отправкой
function TThread_Connection_Main.TThread_Connection_Files.CompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
var
  InputStream: TMemoryStream;
  inbuffer: Pointer;
  outbuffer: Pointer;
  count, outcount: longint;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
begin
  try
  // QueryPerformanceFrequency(iCounterPerSec);//получаем частоту счётчика
  // QueryPerformanceCounter(T1); //засекли время начала операции
    Result := False;
    InputStream := TMemoryStream.Create;
    try
      InputStream.LoadFromStream(SrcStream);
      count := InputStream.Size;
      getmem(inbuffer, count);
      InputStream.ReadBuffer(inbuffer^, count);
      zcompress(inbuffer, count, outbuffer, outcount, zcDefault);
      SrcStream.Clear;
      SrcStream.Write(outbuffer^, outcount);
      Result := true;
    finally
      FreeAndNil(InputStream);
      FreeMem(inbuffer, count);
      FreeMem(outbuffer, outcount);
    end;
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThF',2,'Ошибка архивации потока (F)');
      end;
    end;
// QueryPerformanceCounter(T2);//засекли время окончания
 //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' сек.';
end;

// Decompress Stream with zLib   разархивация данных при получении
function TThread_Connection_Main.TThread_Connection_Files.DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
var
  InputStream: TMemoryStream;
  inbuffer: Pointer;
  outbuffer: Pointer;
  count: longint;
  outcount: longint;
begin
try
  Result := False;
  InputStream := TMemoryStream.Create;

  try
    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    zdecompress(inbuffer, count, outbuffer, outcount);
    SrcStream.Clear;
    SrcStream.Write(outbuffer^, outcount);
    Result := true;
  finally
    FreeAndNil(InputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThF',2,'Ошибка извлечения потока из архива (F)');
      end;
    end;
end;
//-------------------------------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
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
  ThLog_Write('ThF',2,'Поток F Ошибка шифрования: ');
  result:=false;
  OutStr:='';
  end;
end;
end;

function TThread_Connection_Main.TThread_Connection_Files.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
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
  ThLog_Write('ThF',2,'Поток F Ошибка дешифрации');
  result:=false;
  OutStr:='';
  end;
end;
end;

//----------------------------------------------------------------------------------------

function TThread_Connection_Main.TThread_Connection_Files.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //дешифровка скопированной строки
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
    ThLog_Write('ThF',2,'Поток F Ошибка дешифрации полученых данных');
    //ThLog_Write('ThF','ERROR  - Поток F Ошибка дешифрации данных Пароль - '
   // +PswrdCrypt+' s='+s+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp+
   // ' CryptTmp='+CryptTmp);

     s:='';
    end;
  end;
end;
//------------------------------------------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
if Encryptstrs(s,PswrdCrypt, CryptBuf) then //шифруем перед отправкой
SendMainSocket('<!>'+CryptBuf+'<!!>') //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
else ThLog_Write('ThF',1,'Поток F Не удалось защифровать данные сокет М');
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThF',2,'Поток F Ошибка шифрования и отправки данных сокет М');
    end;
  end;
end;

function TThread_Connection_Main.TThread_Connection_Files.SendFileCryptText(s:string):Boolean; // отправка зашифрованного текста в Files сокет
var
CryptBuf:string;
begin
try
if Encryptstrs(s,PswrdCrypt, CryptBuf) then //шифруем перед отправкой
SendFileSocket('<!>'+CryptBuf+'<!!>') //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
else ThLog_Write('ThF',1,'Поток F Не удалось защифровать данные сокет F');
// ThLog_Write('ThF','SendFileCryptText отправляю - '+CryptBuf);
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThF',2,'Поток F Ошибка шифрования и отправки данных сокет F');
    end;
  end;
end;

function TThread_Connection_Main.TThread_Connection_Files.DesOpenInputMain(FirstDesk:HDESK):boolean;
var
hDesktopMain: HDESK;
 begin
 try
  ///-----------------------------------------------------------------------------------------
   result:=false;
   if not frm_Main.Accessed then exit; // если доступ разрешен то выолняем, иначе если мы клиент то это лишние действия
   hDesktopMain := OpenInputDesktop(0,true,MAXIMUM_ALLOWED); //Открывает рабочий стол, получающий входные данные пользователя.
   try
    if FirstDesk<>hDesktopMain then
     begin
     if hDesktopMain<>0 then
       begin
       if not SetThreadDesktop(hDesktopMain)then //Назначает указанный рабочий стол вызывающему потоку.
       ThLog_Write('ThF',1,'Поток (F): Ошибка STD: '+SysErrorMessage(GetLastError()));
       result:=true;
       FirstDesk:=hDesktopMain;
       end
     else
       begin
       ThLog_write('ThF',1,'Поток (F): Ошибка OID: '+SysErrorMessage(GetLastError()));
       result:=false;
       end;
     end;
   finally
   CloseHandle(hDesktopMain);
   end;

  ///-----------------------------------------------------------------------------------------
  except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThF',2,'Ошибка STD/OID потока (F)');
      end;
    end;
 end;


//------------------------------------------------------------------------------------
procedure TThread_Connection_Main.TThread_Connection_Files.Execute;
var
  Position,PosStart,PosEnd,i: Integer;
  FileSize: Int64;
  ReceivingFile: Boolean;
  Buffer,DeCryptBuf,DeCryptBufTemp: string;
  BufferTemp: string;
  FName,CountS:String;
  FPatch,DWNLPathc:string;
  TmpList:TstringList;
  FileStream: TFileStream;
  NewFileStream: TFileStream;
  ClpbrdStream:TmemoryStream;
  SizeClpbdr,SizeFile:Int64;
  readBuf:Int64;
  //BufTmp: array[0..1024*256] of Byte;
  bSize:Int64;
  readBit:Int64;
  clpbrtbool:boolean;
  BadFile,EndFile:boolean;
  slepengtime:integer;
  step:integer;
  HR : HRESULT;
  CurentDesk: HDESK;
begin
try


  inherited;
  //ThLog_Write('ThF','Поток F запущен HR='+inttostr(HR));
  CurentDesk:=0;
  //DesOpenInputMain(CurentDesk);//----------------------------------->
 // EmptyClipboard; // становлючь владельцем буфера обмена
  PswrdCrypt:=frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt; // присваиваем пароль для шифрования в потоке
  ReceivingFile := False;
  FileStream := nil;
  bSize:=4096;
  readBit:=0;

  if not SendMainCryptText('<|REDIRECT|><|FILESCREATED|>') then exit;
  while not terminated {FileSocket.Connected} do
    begin
      Sleep(ProcessingSlack); // Avoids using 100% CPU
      if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
      if (FileSocket = nil) or not(FileSocket.Connected) then Break;
       while (FrmMyProgress.Tag=1)or(FormFileTransfer.Tag=1) do {идет процесс копирования в потоке Clipboard}   {идет процесс копирования в потоке CopyFileFolder}
        begin
        Sleep(ProcessingSlack); // Avoids using 100% CPU
        if terminated then break;
        if (FileSocket = nil) or not(FileSocket.Connected) then Break;
        end;

      if FileSocket.ReceiveLength < 1 then Continue;

      DeCryptBuf := FileSocket.ReceiveText;   //присваиваем данные полученые в файловый сокет

      if DeCryptBuf.Contains('<!>') then   // начало пакета данных
      while not DeCryptBuf.Contains('<!!>') do // Ожидание конца пакета
      begin
      if terminated then break;
      Sleep(ProcessingSlack);
      if FileSocket.ReceiveLength < 1 then Continue;
      DeCryptBufTemp := FileSocket.ReceiveText;
      DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
      end;

      Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки

  ///------------------------------------------------------------------
      Position := Pos('<|CLIPBOARD|>', Buffer);
      if Position > 0 then
      begin
        try
        ClpbrdStream:=TmemoryStream.Create;
          try
          Delete(Buffer, 1, pos('<|CLIPBOARD|>',Buffer) + 12);
          SizeClpbdr:=strtoint(copy(Buffer,1,Pos('<|ENDCLPBRD|>', Buffer) - 1));
          bSize:=0;
          readBit:=0;
          clpbrtbool:=true;
          ClpbrdStream.Position:=0;
           if frm_Main.Viewer then // Если я передаю абоненту буфер обмена
          Synchronize(
            procedure
            begin
             FrmMyProgress.Height:=90;
             FrmMyProgress.ProgressBar1.Max:=SizeClpbdr;
             FrmMyProgress.ProgressBar1.Position:=0;
             FrmMyProgress.Caption:='Прием буфера обмена';
             FrmMyProgress.CancelLoadFile:=false;
             FrmMyProgress.Show;
            end);
           while readBit<SizeClpbdr do
            begin
            if FrmMyProgress.CancelLoadFile then
             begin
             SendFileCryptText('<|STOPLOADCLPBRD|>');
             break;  // выход из цикла если отменили передачу буфера
             end;
            Sleep(ProcessingSlack);
            if FileSocket.ReceiveLength < 1 then  Continue;
            BufferTemp:=FileSocket.ReceiveText;
            bSize:=Length(BufferTemp);
            readBit:=readBit+bSize;
            if frm_Main.Viewer then // Если я принимаю от абонента буфер обмена
             Synchronize(
              procedure
               begin
               FrmMyProgress.ProgressBar1.Position:=readBit;
               end);
            if bSize > 0 then
             begin
             ClpbrdStream.WriteBuffer(AnsiString(BufferTemp)[1],bSize);
             end
            else
             begin
             sleep(2);
             end;

            Buffer:=DecryptReciveText(BufferTemp);// получение расшифрованной строки
             if pos('<|STOPLOADCLPBRD|>',Buffer)>0 then //если попросили остановить передачу буфера
              begin
              break;
              end;
            end;
          ClpbrdStream.Position:=0;
          if ClpbrdStream.Size>0 then
          if not ThLoadClipboard(ClpbrdStream) then ThLog_Write('ThF',1,'Ошибка загрузки буфера обмена');
          Delete(Buffer, 1,length(Buffer));
          Delete(BufferTemp, 1,length(BufferTemp));
          finally
          ClpbrdStream.Free;
          if frm_Main.Viewer then // Если я принимаю от абонента буфер обмена
           Synchronize(
            procedure
             begin
             FrmMyProgress.ProgressBar1.Position:=0;
             FrmMyProgress.Caption:='';
             if FrmMyProgress.Visible then FrmMyProgress.Close;
             end);
          end;
         except on E : Exception do
          begin
          ThLog_Write('ThF',2,'Общая ошибка загрузки буфера обмена');
          end;
         end;
      end;
   //---------------------------------------------------------------------------------
   if Pos('<|CREATEFOLDER|>', Buffer)>0 then    //'<|CREATEFOLDER|>'+ListFileFolder[i]+'<|ENDDIR|>'
     begin
      try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,pos('<|CREATEFOLDER|>',BufferTemp)+15);
       FPatch:=copy(BufferTemp,1,pos('<|ENDDIR|>',BufferTemp)-1);
       if not TDirectory.Exists(FPatch) then
        begin
        TDirectory.CreateDirectory(FPatch);
        SendFileCryptText('<|FOLDERSUCCESSFULLY|>'+FPatch+'<|FEND|>');
        end
        else SendFileCryptText('<|FOLDERSUCCESSFULLY|><|FEND|>');
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'Ошибка потока  (F), создание каталога ');
        end;
      end;
     end;
   //---------------------------------------------------------------------------------
     if Pos('<|FOLDERSUCCESSFULLY|>', Buffer)>0 then  //подтверждение создания каталога
      begin    //'<|FOLDERSUCCESSFULLY|>'+FPatch+'<|FEND|>'
      try
      BufferTemp:=Buffer;
      delete(BufferTemp,1,pos('<|FOLDERSUCCESSFULLY|>',BufferTemp)+21);
      FPatch:=copy(BufferTemp,1,pos('<|FEND|>',BufferTemp)-1);
       if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
         begin
         Synchronize(
         procedure
           begin
           with FormFileTransfer do
             begin
              if FPatch<>'' then
              begin
              if EditDirClient.Text=ExtractFilePath(FPatch+ '..') then  ButClientUpdate.Click;
              //FormFileTransfer.InMessage('Каталог "'+FPatch+'" создан',2);
              end
              else
              begin
              FormFileTransfer.InMessage('Каталог уже существует',2);
              end;
             end;
           end);
          end;
      except on E : Exception do
       begin
       ThLog_Write('ThF',2,'Ошибка потока  (F), подтверждение создания каталога ');
       end;
      end;
      end;
   //--------------------------------------------------------------------------
    if Pos('<|DELETEPATH|>', Buffer)>0 then // пришел список файлов и каталогов дя удаления из формы передачи файлов
     begin  //'<|DELETEPATH|>'+EditDirClient.Text+'<|DELETELILST|>'+ListDelete.CommaText+'<|ENDDEL|>'
      try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,pos('<|DELETEPATH|>',BufferTemp)+13);
       FPatch:=copy(BufferTemp,1,pos('<|DELETELILST|>',BufferTemp)-1);
       delete(BufferTemp,1,pos('<|DELETELILST|>',BufferTemp)+14);
       BufferTemp:=copy(BufferTemp,1,pos('<|ENDDEL|>',BufferTemp)-1);
       ThLog_Write('ThF',2,'Путь='+FPatch+' Список='+BufferTemp);
       ThReadDelete.ThreadDeleteList.Create(FileSocket,BufferTemp,FPatch,PswrdCrypt);// после удаления из потока придет сообщение об удалении '<|DELETESUCCESSFULLY|>
      except on E : Exception do
       begin
       ThLog_Write('ThF',2,'Общая ошибка формирования списка на удаление');
       end;
      end;
     end;
   //--------------------------------------------------------------------------
     if Pos('<|DELETESUCCESSFULLY|>', Buffer)>0 then // пришло подтверждение удаления из формы передачи файлов
     begin //'<|DELETESUCCESSFULLY|>'+PathDel+'<|END|>'
      BufferTemp:=Buffer;
      delete(BufferTemp,1,pos('<|DELETESUCCESSFULLY|>',BufferTemp)+21);
      FPatch:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
       begin
       Synchronize(
       procedure
         begin
         with FormFileTransfer do
           begin
           if EditDirClient.Text=FPatch then  ButClientUpdate.Click;
           //FormFileTransfer.InMessage('Удаление завершено',2);
           end;
         end);
       end;
     end;
   //--------------------------------------------------------------------------
   //'<|REDIRECT|><|FILESTREAM|>'+inttostr(FileStream.Size)+'<|FSIZE|>'+ExtractFileName(frm_Main.ListFileFolder[i])+'<|FNAME|>'+FPatch+'<|ENDFILE|>'
    Position := Pos('<|FILESTREAM|>', Buffer);
    if Position > 0 then
      BEGIN
      TRY
          TRY
          FrmMyProgress.CancelLoadFile:=false;
          BadFile:=false;
          EndFile:=false;
          BufferTemp:=Buffer;
          Delete(BufferTemp, 1, pos('<|FILESTREAM|>',BufferTemp) + 13);
          SizeFile:=strtoint64(copy(BufferTemp,1,Pos('<|FSIZE|>', BufferTemp) - 1));
          Delete(BufferTemp, 1, pos('<|FSIZE|>',BufferTemp) + 8);
          FName:=(copy(BufferTemp,1,Pos('<|FNAME|>', BufferTemp) - 1));
          Delete(BufferTemp, 1, pos('<|FNAME|>',BufferTemp) + 8);
          FPatch:=(copy(BufferTemp,1,Pos('<|ENDFILE|>', BufferTemp) - 1));
          Delete(BufferTemp, 1, pos('<|ENDFILE|>',BufferTemp) + 10);
          CountS:=(copy(BufferTemp,1,Pos('<|ENDCOUNT|>', BufferTemp) - 1));
          Delete(BufferTemp, 1,length(BufferTemp));

          //ThLog_Write('ThF',2,'Поток (F) FName='+FName+' SizeFile='+inttostr(SizeFile));
           // создание каталога если его нет
           if not TDirectory.Exists(FPatch) then TDirectory.CreateDirectory(FPatch);
           NewFilestream:=TfileStream.Create(FPatch+Fname+'.tmp',fmCreate or fmOpenReadWrite);
           slepengtime:=0;
           if (frm_Main.Viewer) then //---------- если я клиент
              begin
                Synchronize(
                procedure
                begin
                FrmMyProgress.Tag:=2; // признак приема файлов от подключеного абонента, необходимо чтобы повторно не запустили обмен файлами
                FrmMyProgress.ProgressBar1.Max:=SizeFile;
                FrmMyProgress.ProgressBar1.Position:=0;
                FrmMyProgress.Caption:='Загрузка файла '+FName+' '+CountS;
                if not FrmMyProgress.Visible then  //и окно не открыто
                 begin
                 FrmMyProgress.Height:=90;
                 FrmMyProgress.Show;
                 end;
                end);
              end;
                try
                  bSize:=0;
                  readBit:=0;
                  NewFilestream.Position:=0;
                  SendFileCryptText('<|READYLOAD|>'); // признак готовностии к загрузке
                   while (readBit<SizeFile) and (not EndFile) do
                    BEGIN
                       if terminated then break;
                       if FrmMyProgress.CancelLoadFile then
                        begin
                        SendFileCryptText('<|STOPLOADFILES|>');
                        BadFile:=true;
                        break;
                        end;
                       //if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
                       Sleep(ProcessingSlack);
                       if FileSocket.ReceiveLength < 1 then  Continue;

                      DeCryptBuf := FileSocket.ReceiveText;   //присваиваем данные полученые в главный сокет
                      bSize:=Length(DeCryptBuf);
                       if bSize > 0 then
                         begin
                         readBit:=readBit+bSize;
                         NewFilestream.WriteBuffer(AnsiString(DeCryptBuf)[1],bSize);
                         slepengtime:=0;
                         end
                       else
                         begin
                         sleep(ProcessingSlack);
                         slepengtime:=slepengtime+ProcessingSlack;
                          if slepengtime>60000 then
                           begin
                           ThLog_Write('ThF',1,'Поток (F) Истекло время ожидания приема данных - '+inttostr(slepengtime));
                           SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
                           BadFile:=true;
                           slepengtime:=0;
                           break;
                           end;
                         end;

                      BufferTemp:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                       if pos('<|ENDFILEFULL|>',BufferTemp)>0 then
                        begin
                        //ThLog_Write('ThF','Поток (F) Пришел <|ENDFILEFULL|>');
                        BufferTemp := StringReplace(BufferTemp, '<|ENDFILEFULL|>', '', [rfReplaceAll]);
                        BadFile:=false;
                        EndFile:=true; // если чт то осталось то возможно это данные из файла, задаем признак окончания данных файла
                        end;    // далее он считает остаки и выйдет по признаку  EndFile:=true;
                      if pos('<|BADFILE|>',BufferTemp)>0 then
                        begin
                        //ThLog_Write('ThF','Поток (F) Пришел <|BADFILE|>');
                        BadFile:=true;
                        break;
                        end;
                      if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                        begin
                        BadFile:=true; // ошибка файла
                        break; // выходим из потока т.к. нас попросили остановить загузку
                        end;

                      if frm_Main.Viewer then //---------- если я клиент
                        begin
                          Synchronize(
                          procedure
                          begin
                          FrmMyProgress.ProgressBar1.Position:=readBit;
                          end);
                        end;
                    END;
                  NewFilestream.Position:=0;
                  BufferTemp:='';
                finally
                NewFilestream.Free;
                FrmMyProgress.Tag:=0;
                end;
             if not BadFile then
              begin
              if (FileExists(FPatch+Fname)) then  DeleteFile(FPatch+Fname);
              RenameFile(FPatch+Fname+'.tmp', FPatch+Fname);
              end;

             EXCEPT ON E : Exception DO
                begin
                if frm_Main.Viewer then //---------- если я клиент
                  begin
                    Synchronize(
                    procedure
                    begin
                    FrmMyProgress.Tag:=0; //отмена признак приема файлов от подключеного абонента, необходимо чтобы повторно не запустили обмен файлами
                    FrmMyProgress.Close;
                    end);
                  end;
                SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
                ThLog_Write('ThF',2,'Поток (F) Общая ошибка загрузки файла');
                end;
           END;  //TRY

       FINALLY
       if not BadFile then
         begin
         SendFileCryptText('<|DNLDCMPLT|>'+Fname+'<|END|>'); // подтверждение об окончании загрузки файла
         end
        else SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
       FrmMyProgress.Tag:=0;
       if BadFile then  // если ошибка приема файла
        if frm_Main.Viewer then //---------- если я клиент
          begin
            Synchronize(
            procedure
            begin
            if FrmMyProgress.Visible then FrmMyProgress.Close;
            end);
          end;
        END; //try

    END;//<|FILESTREAM|>
  //----------------------------------------------------------------------------------------------------------------------------------------
     Position := Pos('<|FILECOPY|>', Buffer);
    if Position > 0 then
      BEGIN
      TRY
          TRY
          BadFile:=false;
          EndFile:=false;
          step:=1;
          BufferTemp:=Buffer;
          Delete(BufferTemp, 1, pos('<|FILECOPY|>',BufferTemp) + 11);
          SizeFile:=strtoint64(copy(BufferTemp,1,Pos('<|FSIZE|>', BufferTemp) - 1));
          step:=2;
          Delete(BufferTemp, 1, pos('<|FSIZE|>',BufferTemp) + 8);
          FName:=(copy(BufferTemp,1,Pos('<|FNAME|>', BufferTemp) - 1));
          step:=3;
          Delete(BufferTemp, 1, pos('<|FNAME|>',BufferTemp) + 8);
          FPatch:=(copy(BufferTemp,1,Pos('<|ENDFILE|>', BufferTemp) - 1));
          step:=4;
          Delete(BufferTemp, 1, pos('<|ENDFILE|>',BufferTemp) + 10);
          CountS:=(copy(BufferTemp,1,Pos('<|ENDCOUNT|>', BufferTemp) - 1));
          Delete(BufferTemp, 1,length(BufferTemp));
          step:=5;
          //ThLog_Write('ThF',2,'Поток (F) FName='+FName+' SizeFile='+inttostr(SizeFile));
           if not TDirectory.Exists(FPatch) then TDirectory.CreateDirectory(FPatch); // создание каталога если его нет
           NewFilestream:=TfileStream.Create(FPatch+Fname+'.tmp',fmCreate or fmOpenReadWrite);
          step:=6;
            if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
              begin
                Synchronize(
                procedure
                begin
                 with FormFileTransfer do
                  begin
                  ButCancel.Visible:=true; // показываю кнопку отмены
                  ButCopyFromClient.Enabled:=false; // выключаем кнопку копирования
                  ButCopyToClient.Enabled:=false; // выключаем кнопку копирования
                  LoadFFProgressBar.Max:=SizeFile;
                  LoadFFProgressBar.Min:=0;
                  LoadFFProgressBar.Position:=0;
                  LoadFFProgressBar.ProgressText:=CountS+' Загрузка файла '+FName;
                  LoadFFProgressBar.Visible:=true;
                  end;
                end);
              end;
          step:=7;
              try
               slepengtime:=0;
               bSize:=0;
               readBit:=0;
               NewFilestream.Position:=0;
               SendFileCryptText('<|READYLOAD|>'); // признак готовностии к загрузке
               step:=8;
                while (NewFilestream.Size<SizeFile) and (not EndFile) do
                 BEGIN
                  if terminated then break;
                  if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
                  if FormFileTransfer.CancelLoadFile then//-- Если отменили загрузку
                   begin
                   SendFileCryptText('<|STOPLOADFILES|>');
                   ThLog_Write('ThF',1,'Поток (F) Отмена загрузки файла');
                   BadFile:=true;
                   break;
                   end;
                   Sleep(ProcessingSlack);
                  if FileSocket.ReceiveLength < 1 then  Continue;
                  step:=9;
                   DeCryptBuf := FileSocket.ReceiveText;   //присваиваем данные полученые в сокет
                   bSize:=Length(DeCryptBuf);
                   if bSize > 0 then
                    begin
                    readBit:=readBit+bSize;
                    NewFilestream.WriteBuffer(AnsiString(DeCryptBuf)[1],bSize);
                    end
                   else
                    begin
                    sleep(ProcessingSlack);
                    slepengtime:=slepengtime+10;
                    if slepengtime>6000 then
                      begin
                      ThLog_Write('ThF',1,'Поток (F) Истекло время ожидания приема данных - '+inttostr(slepengtime));
                      SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
                      BadFile:=true;
                      slepengtime:=0;
                      break;
                      end;
                    end;
                  step:=10;
                   BufferTemp:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки

                   if pos('<|ENDFILEFULL|>',BufferTemp)>0 then
                    begin
                    BufferTemp := StringReplace(BufferTemp, '<|ENDFILEFULL|>', '', [rfReplaceAll]);
                    BadFile:=false;// ошибки нет
                    EndFile:=true; // если чт то осталось то возможно это данные из файла, задаем признак окончания данных файла
                    end;    // далее он считает остаки и выйдет по признаку  EndFile:=true;
                    if pos('<|BADFILE|>',BufferTemp)>0 then
                    begin
                    BadFile:=true;// ошибка файла
                    break;
                    end;
                   if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                    begin
                    BadFile:=true; // ошибка файла
                    break; // выходим из потока т.к. нас попросили остановить загузку
                    end;
                  step:=11;
                   if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
                    begin
                    Synchronize(
                    procedure
                     begin
                     FormFileTransfer.LoadFFProgressBar.Position:=readBit;
                     FormFileTransfer.LoadFFProgressBar.ProgressText:=CountS+' Загрузка файла '+FName;
                     end);
                    end;
                  step:=12;
                 END;
                  NewFilestream.Position:=0;
                  BufferTemp:='';
              finally
              NewFilestream.Free;
              end;
             if not BadFile then
              begin
              if (FileExists(FPatch+Fname)) then  DeleteFile(FPatch+Fname);
              RenameFile(FPatch+Fname+'.tmp', FPatch+Fname);
              end;

           EXCEPT ON E : Exception DO
            begin
            SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
            ThLog_Write('ThF',2,'Поток (F) Общая ошибка загрузки файла ('+inttostr(step)+') '+FName+' - '+E.ClassName+': '+E.Message);
            end;
           END;  //TRY

       FINALLY
        if not BadFile then
         begin
         SendFileCryptText('<|DNLDCMPLT|>'+Fname+'<|END|>'); // подтверждение об окончании загрузки файла
         end
         else
         begin
         SendFileCryptText('<|DNLDERROR|>'); // признак ошибки загрузки файла
         if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
           begin
            Synchronize(
            procedure
            begin
            with FormFileTransfer do
             begin
             LoadFFProgressBar.Visible:=false;
             ButCancel.Visible:=false; // скрываю кнопку отмены
             ButCopyFromClient.Enabled:=true; // включаем кнопку копирования
             ButCopyToClient.Enabled:=true; // включаем кнопку копирования
             end;
            end);
           end;
         end;
        if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
          begin
            Synchronize(
            procedure
            begin
            FormFileTransfer.LoadFFProgressBar.Visible:=false;
            end);
          end;
        END; //try

    END;//<|FILECOPY|>

  //-----------------------------------------------------------------------------------------------------------------------------------------

      if Pos('<|ENDOFFILECOPY|>', Buffer)>0 then // признак окончания передачи всех файлов
     BEGIN
      try
      if FormFileTransfer.Visible  then //---------- Если открыта форма копирования файлов
       begin
       Synchronize(
       procedure
         begin
         with FormFileTransfer do
           begin
           ButCancel.Visible:=false; // скрываю кнопку отмены
           ButCopyFromClient.Enabled:=true; // включаем кнопку копирования
           ButCopyToClient.Enabled:=true; // включаем кнопку копирования
           FormFileTransfer.LoadFFProgressBar.ProgressText:='';
           FormFileTransfer.LoadFFProgressBar.Visible:=false;
           ButLocalUpdate.Click; //обновить список на локаном ПК
           FormFileTransfer.InMessage('Копирование завершено',2);
           end;
         end);
       end;
      Buffer := StringReplace(Buffer, '<|ENDOFFILETRANSFER|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'ошибка потока (F) Окончание загрузки файлов');
        end;
      end;
     END;


    if Pos('<|ENDOFFILETRANSFER|>', Buffer)>0 then
     BEGIN
      try
      if frm_Main.Viewer then //---------- если я клиент
       begin
       Synchronize(
       procedure
         begin
         FrmMyProgress.Tag:=0;
         FrmMyProgress.Caption:='Загрузка завершена';
         FrmMyProgress.Close;
         end);
       end;
      Buffer := StringReplace(Buffer, '<|ENDOFFILETRANSFER|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'ошибка потока (F) Окончание загрузки файлов');
        end;
      end;
     END;


 //-------------------------------------------------------------------------- обратная передача буфера обмена
 Position := Pos('<|DOWNLOADCLPBRD|>', Buffer); //
  if Position > 0 then
    BEGIN
      try
      step:=0;
      if ThClipBoardTheFiles then // если в буфере обмена находятся файлы
       begin
       step:=1;
       SendFileCryptText('<|DIRECTORYDOWNLOAD|>'); // запросить директорию для загрузки файлов
       step:=2;
       end
       else
       begin
       step:=3;
       ThFunctionClipboard(FileSocket,IDConnect,'',PswrdCrypt);
       //ExtFunctionClipboard(FileSocket,IDConnect,'',PswrdCrypt);
       step:=4;
       end;
       step:=5;
      Buffer := StringReplace(Buffer, '<|DOWNLOADCLPBRD|>', '', [rfReplaceAll]);
      step:=6;
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,inttostr(step)+') Ошибка потока (F) Запрос буфера обмена');
        end;
      end;
    END;
//------------------------------------------------------------------------ если пришел запрос на директорию для загузки файлов из буфера обмена
  Position := Pos('<|DIRECTORYDOWNLOAD|>', Buffer);
  if Position > 0 then
    BEGIN
      try
        Buffer := StringReplace(Buffer, '<|DIRECTORYDOWNLOAD|>', '', [rfReplaceAll]);
        Synchronize(frm_RemoteScreen.OpenDirectoryForFile);
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'ошибка потока (F) Запрос на директорию загрузки');
        end;
      end;
    END;
 //----------------------------------------------------------------------------- '<|DOWNLOADCLPBRDDIRECTORY|>'+FileName+'<|ENDFILE|>'
   Position := Pos('<|DOWNLOADCLPBRDDIRECTORY|>', Buffer);  //директория загрузки файлов
   if Position > 0 then
    BEGIN
      try
      bufferTemp:=Buffer;
      Delete(bufferTemp, 1, pos('<|DOWNLOADCLPBRDDIRECTORY|>',bufferTemp) + 26);
      frm_ShareFiles.DirectoryToSaveFile:=(copy(bufferTemp,1,Pos('<|ENDFILE|>', bufferTemp) - 1));
      ThFunctionClipboard(FileSocket,IDConnect,frm_ShareFiles.DirectoryToSaveFile,PswrdCrypt);
      //ExtFunctionClipboard(FileSocket,IDConnect,frm_ShareFiles.DirectoryToSaveFile,PswrdCrypt);
      ThLog_Write('ThF',2,'Пришла директория загрузки файлов, запустил функцию ThFunctionClipboard');
      Delete(bufferTemp, 1,length(bufferTemp));
      Buffer := StringReplace(Buffer, '<|DIRECTORYDOWNLOAD|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'Ошибка потока (F) Запрос на запуск функции буфера обмена');
        end;
      end;
    END;
//-------------------------------------------------------------------------------
    Position := Pos('<|SOURSEDIR|>', Buffer);  //копирование файлов с клиента
   if Position > 0 then//'<|SOURSEDIR|>'+SourseDir+'<|ENDSDIR|><|SOURSELIST|>'+tmpListF.CommaText+'<|SOURSELISTEND|><|DESTDIR|>'+pathToCopy+'<|ENDDDIR|>'
    BEGIN  {FPatch,DWNLPathc:string; TmpList:TstringList;}
     try
     bufferTemp:=Buffer;
     delete(bufferTemp,1,position+12);
     posStart:= Pos('<|ENDSDIR|>', bufferTemp);
     DWNLPathc:=copy(bufferTemp,1,posStart-1); // Директория от куда передавать файлы и каталоги
     if bufferTemp.Contains('<|SOURSELISTEND|>')  then // если есть законченый список файлов и каталогов дя копирования
      begin
      TmpList:=TstringList.Create;
        try
        posStart:= Pos('<|SOURSELIST|>', bufferTemp);
        delete(bufferTemp,1,posStart+13);
        posEnd:=Pos('<|SOURSELISTEND|>', bufferTemp);
        TmpList.CommaText:=copy(bufferTemp,1,posEnd-1);
        for I := 0 to TmpList.count-1 do TmpList[i]:=DWNLPathc+TmpList[i]; // формируем полный путь до файлов и каталогов
        delete(bufferTemp,1,posEnd+16);
         if bufferTemp.Contains('<|ENDDDIR|>') then // если есть каталог куда копировать
          begin
           posStart:= Pos('<|DESTDIR|>', bufferTemp);
           delete(bufferTemp,1,posStart+10);
           posEnd:=Pos('<|ENDDDIR|>', bufferTemp);
           FPatch:=copy(bufferTemp,1,posEnd-1);
           ThreadCopyFileS.Create(
                      FileSocket, // сокет для копирвоания
                       IDConnect, // ID соединения
                       TmpList, // список файлов и каталогов для копирования
                       FPatch,// куда копируем
                      PswrdCrypt);  // пароль для шифрования
          end;
        finally
        TmpList.Free;
        end;
      end;
      except on E : Exception do
        begin
        ThLog_Write('ThF',2,'Ошибка потока (F) Запрос копирования файлов и каталогов');
        end;
     end;
    END;

  end; //while

 //ThLog_Write('ThF','Поток F завершен');
except on E : Exception do
    begin
    CloseFilesSocket; // закрываем сокет, возможно из потока вышли аварийно
    ThLog_Write('ThF',2,'Общая ошибка потока (F)');
    end;
  end;
end;

//-----------------------------------------------------------------------------------------------------------------
//далее работа с буфером обмена
//----------------------------------------------------------------------------------------------------------------
function TThread_Connection_Main.TThread_Connection_Files.ThClipBoardTheFiles:boolean; // проверка буфера обмена на наличие файлов
var
WinHandle:HWND;
OwnerClpb:HWND;
begin
  try

   //  OwnerClpb:=GetClipboardOwner; // определяем владельца буфера обмена
    // ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: OwnerClpb='+inttostr(OwnerClpb));
    // WinHandle:=ThShellWindow;
    // ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: WinHandle='+inttostr(WinHandle));
    if not OpenClipboard(Application.Handle) then //GetShellWindow     GetDesktopWindow
      ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: OpenClipboard=0 Error='+SysErrorMessage(GetLastError));
    try
    result:=IsClipboardFormatAvailable(CF_HDROP);
    finally
    CloseClipboard;
    end;
    if result then  ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: В буфере обнаружены файлы')
    else ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: В буфере не обнаружены файлы');
  except on E : Exception do// если ошибка то файлов точно нет
  begin
  ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: Ошибка ClipBoardTheFiles: '+E.ClassName+': '+E.Message);
  result:=false;
  end;
  end;

end;


function TThread_Connection_Main.TThread_Connection_Files.ThFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean;
var
PswdCrypt:string[255];
begin
  try
  PswdCrypt:=PswdCryptClbrd;
    begin
     IF ThClipBoardTheFiles then // если в буфере обмена файлы
      BEGIN
       if not frm_Main.Viewer then // если я сервер и передаю буфер  клиенту
        Begin
         ThreadCopyFileSClipboard.Create(Socket,IDConect,DirPath,PswdCrypt);
        End
         else // если я клиент передаю буфер на сервер
        Begin // запрос на укзание директории для сохранения
        frm_ShareFiles.Tag:=IDConect;
        if frm_ShareFiles.ShowModal=1 then // если указали директорию сохранения файла
          Begin
          ThreadCopyFileSClipboard.Create(Socket,IDConect,frm_ShareFiles.DirectoryToSaveFile,PswdCrypt);
          End;
        End;
       END
       ELSE //
      BEGIN
      ThreadSendClipboard.Create(socket,PswdCrypt); // запуск потока передачи буфера обмена
      END;
   end;
   except on E : Exception do
    begin
    ThLog_Write('Clipboard',2,'ThFunctionClipboardT: Общая ошибка работы с буфером обмена : '+E.ClassName+': '+E.Message);
    end;
   end;
end;



function TThread_Connection_Main.TThread_Connection_Files.ThShellWindow: HWND;
type
  TGetShellWindow = function(): HWND; stdcall;
var
  hUser32: THandle;
  GetShellWindow: TGetShellWindow;
begin
  Result := 0;
  hUser32 := GetModuleHandle('user32.dll');
  if hUser32 > 0 then
  begin
    @GetShellWindow := GetProcAddress(hUser32, 'GetShellWindow');
    if Assigned(GetShellWindow) then
      Result := GetShellWindow;
  end;
end;




function TThread_Connection_Main.TThread_Connection_Files.ThLoadClipboard(S: TStream):boolean;
 var
   reader: TReader;
 begin
 try
   Assert(Assigned(S));
   reader := TReader.Create(S, 4096);
   try
     Clipboard.Open;
     //OpenClipboard(Application.Handle);
     try
       clipboard.Clear;
       //EmptyClipboard;
       reader.ReadListBegin;
       while not reader.EndOfList do
         result:=ThLoadClipboardFormat(reader);
       reader.ReadListEnd;
     finally
       //CloseClipboard;
       Clipboard.Close;
     end; { Finally }
   finally
     reader.Free
   end; { Finally }
  except on E : Exception do ThLog_Write('Clipboard',2,'ThLoadClipboard : '+E.ClassName+': '+E.Message); end;
 end; { LoadClipboard }


function TThread_Connection_Main.TThread_Connection_Files.ThLoadClipboardFormat(reader: TReader):boolean;
 var
   fmt: Integer;
   fmtname: string;
   Size: Integer;
   ms: TMemoryStream;
 begin
 try
   Assert(Assigned(reader));
   fmt     := reader.ReadInteger;
   fmtname := reader.ReadString;
   Size    := reader.ReadInteger;
   ms      := TMemoryStream.Create;
   try
     ms.Size := Size;
     reader.Read(ms.memory^, Size);
     if Length(fmtname) > 0 then
       fmt := RegisterCLipboardFormat(PChar(fmtname));
     if fmt <> 0 then
     begin
       result:=ThCopyStreamToClipboard(fmt, ms);
     end
     else
     begin
       result:=false;
       ThLog_Write('Clipboard',2,'ThLoadClipboardFormat: Ошибка RegisterCLipboardFormat: '+SysErrorMessage(GetLastError()));
     end;
   finally
     ms.Free;
   end; { Finally }
 except on E : Exception do
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThLoadClipboardFormat: Ошибка LoadClipboardFormat: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { LoadClipboardFormat }

function TThread_Connection_Main.TThread_Connection_Files.ThCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;
 var
   hMem: THandle;
   pMem: Pointer;
 begin
  try
   Assert(Assigned(S));
   S.Position := 0;
   hMem       := GlobalAlloc(GHND or GMEM_DDESHARE, S.Size);
   if hMem <> 0 then
   begin
     pMem := GlobalLock(hMem);
     if pMem <> nil then
     begin
       try
         S.Read(pMem^, S.Size);
         S.Position := 0;
       finally
         GlobalUnlock(hMem);
       end;
       Clipboard.Open;
       //OpenClipboard(Application.Handle);
       try
         Clipboard.SetAsHandle(fmt, hMem);
         result:=true;
       finally
       // CloseClipboard;
        Clipboard.Close;
       end;
     end { If }
     else
     begin
       GlobalFree(hMem);
       result:=false;
       ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: Ошибка GlobalAlloc: '+SysErrorMessage(GetLastError()));
     end;
   end { If }
   else
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: Ошибка GlobalAlloc: '+SysErrorMessage(GetLastError()));
    end;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: Ошибка CopyStreamToClipboard: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { CopyStreamToClipboard }


//------------------------------------------------------------------------------------------------------------------------



end.
