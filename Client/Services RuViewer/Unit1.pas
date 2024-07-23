unit Unit1;

interface

uses
  Winapi.Windows,Winapi.Messages, System.SysUtils, System.Classes,
   Vcl.SvcMgr, Vcl.Dialogs, Vcl.ExtCtrls,VCL.Forms,TlHelp32,RunAsSystem,Inifiles,Registry,ShellApi,
  Pipes,System.Hash;

type
  TRuViewerSrvc = class(TService) // опрделения уровня привелегий запуска процесса
    function RunProcInSession(numSession:integer; RunAs:string):boolean;// запуск процессо в указаном сеансе
    Function RunNowProcess(RunAs:string):boolean; // запуск процесса по требованию, в том числе при старте службы
    function IDSessionRunProcessConsole(exeFileName: string; var IDProcess:integer): boolean; // ID сеанса процесса запушенного в консольной сессии
    function processExists(exeFileName: string;IDSession:cardinal): Boolean;
    function KillprocessSession(exeFileName: string;IDSession:cardinal): Boolean;//найти и завершить процесс запушенный в сеансе IDSession
    function KillAllprocess(exeFileName: string): Boolean; ////найти и завершить процесс запушенный
    function FindprocessPID(exeFileName: string; PID:integer; ReadPID:boolean; var PIDProc:integer): Boolean; // Поиск процесса по его имени и PID


    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    Procedure ShutDownAndStopSrevice(tmpStr:string);

    procedure timerFW;
    procedure TimeFWstart(Sender: TObject);
    function GetNamePC:string; // Чтение имени ПК
    function ReadParamsRun(var LevelRunSrvc,LevelRunUser,LevelLog,port:integer; var Host,NamePC,AutoRun:string):boolean;
    function WriteRegSet(port:Integer;srv,NamePC,Autorun:string):boolean; // Запись настроек в реестр
    Procedure ReadFileSet(var LevelRunSrvc,LevelRunUser:integer ;var srv,NamePC:string; var Port:integer; var AutoRun:String; var result:boolean);// чтение настроек из файла
    function WriteFileSet(srv,port,NamePC,AutoRun:string):boolean; // запись настроек в файл
    Procedure ReadRegSet(var LevelRunSrvc,LevelRunUser,levelLog,port:Integer; var srv,NamePC,Autorun:string; var result:boolean); // чтение настроек из реестра
    function WriteRegSendSAS(meaning:integer; DelValue:boolean; var OldMeaning:integer):boolean; // Запись настроек Disable or enable software Secure Attention Sequence в реестр
    function EqualArraySessionID(var AddSession:ArraySession; Var DelSession:ArraySession; AllSession:ArraySession; CurSession:ArraySession):boolean;
    function HashRunFile(pachFile:string):boolean;
    procedure ServiceShutdown(Sender: TService);
    // функция поиска элементов в массиве. Сравнение массивав текущих и предыдущих сеансов пользователей
     //// завершение программы при перезагрузке или выключениии Windows
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
  CurrentConsoleSessionID:cardinal; //текущий активный консольный сеанс
  SessionIDConsoleRunProc:integer; //консольный сеанс в котором запущен процесс (в RDP саенсах процессы запускаются не зависимо)
  TimeFW:Ttimer;
  AllSessionID:ArraySession;// Массив с номерами консольных сеасов пользователей + 0 сеанс
  AllRDPSessionID:ArraySession; // массив с номерами RDP сеансов. В данных сеансах процессы запускаются независимо от консольного сеанса
  PidConsoleProc:integer;
  ForceRunApp:boolean;
  ApplicationExit:boolean;
  PipeServer:TPBPipeServer; // именованый канал
  MyStreamCipherId:string; //TCodec.StreamCipherId для шифрования
  MyBlockCipherId:string; // TCodec.BlockCipherId для шифрования
  MyChainModeId:string; // TCodec.ChainModeId для шифрования
  EncodingCrypt:TEncoding; // кодировка текста при шифровании и дешифрации
  PCUID:string;
  ServiceUID:string[255]; // для расшифровки сообщений полученных от программы
  ThreadRunPause:boolean; //приостановка/пауза потока
  ThreadRunBreak:boolean; // признак завершения потока
  ThRunStart:TThread_Run_Process;
  ShutDownPC:boolean;
  LogOffUser:boolean;
  LevelLogError:integer; // уровень логирования
  LevelAutoRun:integer; // с какими правами запускать при автозапуске программы (ruviewer)
  //0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
  LevelRunManual:integer; // с какими правами запускать при ручном запуске программы (ruviewer)
  ////0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID

  const
  TimeOutThread=3000; //время бездействия потока
  TimeOutShutDown=15000;  // время ожидания потока до запуска процесса если не выключаемся а засыпаем, проснется и запустит процес
  TimeOutLogOff=10000;  // время ожидания потока до запуска процесса при выходе пользователя из системы


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
   RuViewerSrvc.Log_Write('Thservice',1,'Основной поток запущен');
   TimeShutdown:=TimeOutShutDown; //16 секунд
   TimeLogOff:=TimeOutLogOff;  //10 сек
   TimeWait:=0;
   while (not terminated) do
     Begin
      // RuViewerSrvc.Log_Write('Thservice',0,'Основной поток работает');
      TimeWait:=0;
       while TimeWait<TimeOutThread do //спим
       begin
       TimeWait:=TimeWait+14;
       sleep(2);
       if ThreadRunBreak then break; // признак выхода из цикла
       end;
       if ThreadRunBreak then break; // признак выхода из цикла

       while ThreadRunPause do
       begin
       sleep(10);
       if ThreadRunBreak then break; // признак выхода из цикла
       end;
       if ThreadRunBreak then break; // признак выхода из цикла

      if ShutDownPC then // если признак выключения ПК то если это гибернация или еще какой сон, то служба не остановится а заснет, и тут мне пригодится данный цикл чтобы запустить прогу при возобновлении работы
      begin
      TimeShutdown:=TimeShutdown-TimeOutThread;
      ApplicationExit:=false; // на случай если упали в гибернацию или сон а перед этим закрыли ручками программу
       if TimeShutdown<=0 then
        begin
        ShutDownPC:=false;
        TimeShutdown:=TimeOutShutDown;
        end;
      //RuViewerSrvc.Log_Write('Thservice',0,'ShutDownPC='+booltostr(ShutDownPC)+' TimeShutdown='+inttostr(TimeShutdown));
      end; //

      if LogOffUser then // если признак завершения сеанса пользователя
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
     RuViewerSrvc.Log_Write('Thservice',1,'Основной поток остановлен');
    except on E: Exception do
      begin
      RuViewerSrvc.Log_Write('Thservice',3,'Ошибка основного потока : '+e.ClassName +': '+ e.Message);
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
except on E: Exception do
  begin
  exit;
  end;
end
 end;
//////////////////////проверка hash суммы файла
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
  Log_Write('service',0,'hash - '+HashAsString); //закоментирвоать перед релизом
  result:=true; //закоментирвоать перед релизом
  end;
 finally
 fs.Free;
 end;
  except on E: Exception do
  begin
  Log_Write('service',3,'Hash Ошибка : '+e.ClassName +': '+ e.Message);
  result:=true;
  end;
  end
end;
//////////////////////////////////////////////////////
////////////////////////////////////////////////////// функция общения сервиса с приложением по именованному канал
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
  NumSes:= strtoint(Copy(Adata, 1, pos('<|END|>', Adata) - 1)); // номер сеанса из которого попросили запустить программу
  ForceRunApp:=true; // признак запуска процесса в ручную
  ApplicationExit:=false; // если программу закрывали вручную (т.е.не нажали кнопку выход), сейчас ее запустили вручную, значит контролирем ее налицие в системе
  RunProcInSession(NumSes,'RunUser'); // запускаем программу в сеансе полученном от приложения
  end;

 if Pos('<|ALT+CTR+DELETE|>', DecryptText)>0 then
 Begin
   if WriteRegSendSAS(1,false,oldData) then // Передаем 1 для разрешения SendSAS для служб. False т.к. ничего не удаляем. OldData считываем предыдущее значение
   begin
    SendSAS(false);
    keybd_event(18, 0, 0, 0); //ALT
    keybd_event(17, 0, 0, 0); // CTRL
    keybd_event(46, 0, 0, 0); //DELETE
    sleep(200);
    keybd_event(18, 0, KEYEVENTF_KEYUP, 0); //ALT
    keybd_event(17, 0, KEYEVENTF_KEYUP, 0); // CTRL
    keybd_event(46, 0, KEYEVENTF_KEYUP, 0); //DELETE
    //Log_Write('service','Выполнил AltCtrlDelete.');
   end
   else Log_Write('service',2,'AltCtrlDelete. Ошибка внесения изменений');
   if oldData<>5 then // если запись в реестр прошла успешно
   begin
   if oldData=4 then WriteRegSendSAS(0,true,tmpData) // если приняли предыдущее значение 4 то ключа не было, удаляем его.
   else WriteRegSendSAS(oldData,false,tmpData); // иначе если oldData=0,1,2,3 то политика была включена, записываем значение обратно в реестр
   end;
 End;



  if Pos('<|FORCEEXIT|>', DecryptText)>0 then
  begin
  ApplicationExit:=true; // признак того что программу закрыли вручную (т.е. нажали кнопку выход), значит запускать ее не надо
  Log_Write('service',1,'FORCEEXIT');
  end;

  if Pos('<|SHUTDOWN|>', DecryptText)>0 then  // сообщение от  RuViewer о том что OC завершает работу
  begin
  Delete(DecryptText, 1, Pos('<|SHUTDOWN|>', DecryptText)+11);
  if not trystrtoint(Copy(DecryptText, 1, pos('<|END|>', DecryptText) - 1),NumSes) then NumSes:=-1;
  ShutDownPC:=true;
  Log_Write('service',0,'SHUTDOWN '+inttostr(NumSes));
  end;

  if Pos('<|LOGOFF|>', DecryptText)>0 then   // сообщение от  RuViewer о том что пользователь завершил сеанс
  begin
  Delete(DecryptText, 1, Pos('<|LOGOFF|>', DecryptText)+9);
  if not trystrtoint(Copy(DecryptText, 1, pos('<|END|>', DecryptText) - 1),NumSes) then NumSes:=-1; // номер сеанса из которого запустили выключение ПК
  LogOffUser:=true;
  Log_Write('service',1,'LOGOFF '+inttostr(NumSes));
  end;


 except on E: Exception do
  Log_Write('service',3,'PipeMessage. Ошибка : '+e.ClassName +': '+ e.Message);
  end
end;

//////////////////////////////////////////////////////// ID сеанса процесса запушенного в консольной сессии
function TRuViewerSrvc.IDSessionRunProcessConsole(exeFileName: string; var IDProcess:integer): boolean;
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //номер сеанса которому принадлежит процесс
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
     //Log_Write('service','Поиск процесса IDSessionRunProcessConsole: '+ (UpperCase(FProcessEntry32.szExeFile))+' = '+UpperCase(ExeFileName));
     if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession в каком сеансе запушен процесс
     if Length(AllRDPSessionID)=0 then // если массив RDP сессий пустой
       begin
       IDProcess:=IdProcSession;
       result:=true;
       end
     else
       begin
       for I := 0 to Length(AllRDPSessionID)-1 do //исключаем RDP сеансы
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
        //Log_Write('service','IDSessionRunProcessConsole Процесс запущен в : IdProcSession = '+ inttostr(IDProcess));
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
  Log_Write('service',3,'Ошибка. IDSessionRunProcessConsole : '+e.ClassName +': '+ e.Message);
  end;
  end
end;

function TRuViewerSrvc.FindprocessPID(exeFileName: string; PID:integer; ReadPID:boolean; var PIDProc:integer): Boolean; // Поиск процесса по его имени и PID
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //номер сеанса которому принадлежит процесс
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
      if readPID then // если надо узнать PID процесса
        begin
        PIDProc:=FProcessEntry32.th32ProcessID;
        result:=true;
        end
      else  /// иначе надо проверить еслть ли процесс с данным PID
      if PID=FProcessEntry32.th32ProcessID then
        begin
         Result := True; // если запущен в нужном сеансе
         PIDProc:=FProcessEntry32.th32ProcessID;
        end;
      end;
  end;
  CloseHandle(FSnapshotHandle);
  except on E: Exception do
  Log_Write('service',3,'Ошибка поиска процесса по PID: '+e.ClassName +': '+ e.Message);
  end
end;

function TRuViewerSrvc.processExists(exeFileName: string; IDSession:cardinal): Boolean; // Поиск процесса в нужном сеансе
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  IdProcSession:Cardinal; //номер сеанса которому принадлежит процесс
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
   // Log_Write('service',1,'Поиск процесса НАЙДЕН: '+ (UpperCase(FProcessEntry32.szExeFile))+' = '+UpperCase(ExeFileName)+' ProcessID='+inttostr(FProcessEntry32.th32ProcessID));
    if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession в каком сеансе запушен процесс
    begin
    if IDSession=IdProcSession then
      begin
       Result := True; // если запущен в нужном сеансе
      // Log_Write('service',1,'Процесс уже запущен в : IdProcSession='+ inttostr(IdProcSession)+' IDSession='+inttostr(IDSession)+' PID = '+inttostr(FProcessEntry32.th32ProcessID));
       break; // выходим из цикла т.к. нашли
      end;
      //else Log_Write('service','Сеанс процесса: IDSession = '+ inttostr(IDSession)+' <> IdProcSession = '+inttostr(IdProcSession));
    end;
    //else Log_Write('service','Поиск процесса: ProcessIdToSessionId False - IdProcSession: '+inttostr (IdProcSession));
  end;
  end;
  CloseHandle(FSnapshotHandle);
  except on E: Exception do
  Log_Write('service',3,'Ошибка поиска процесса: '+e.ClassName +': '+ e.Message);
  end
end;
///////////////////////////////////////////////
function TRuViewerSrvc.KillprocessSession(exeFileName: string;IDSession:cardinal): Boolean;
////найти и завершить процесс запушенный в сеансе IDSession
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
          //Log_Write('service','Поиск и завершение процесса процесса: НАЙДЕН ');
          if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession в каком сеансе запушен процесс
            begin
           // Log_Write('service','Поиск и завершение процесса процесса: ProcessIdToSessionId: IDSession='+inttostr(IDSession)+' - IdProcSession='+inttostr(IdProcSession));
            if IDSession=IdProcSession then // если запущен в нужном сеансе
              begin
             // Log_Write('service','Поиск и завершение процесса процесса: IDSession='+inttostr(IDSession)+'==IdProcSession='+inttostr(IdProcSession));
             TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),FProcessEntry32.th32ProcessID),0);
              //Log_Write('service','Поиск и завершение процесса процесса: Завершение процесса '+ UpperCase(FProcessEntry32.szExeFile)+': PID'+inttostr(FProcessEntry32.th32ProcessID)+': IdProcSession'+inttostr(IdProcSession));
              Result := True;
              end;
            end;
          end;
      end;
      CloseHandle(FSnapshotHandle);
    except on E: Exception do
    Log_Write('service',3,'Ошибка завершение процесса '+exeFileName+': '+e.ClassName +': '+ e.Message);
    end;
end;

function TRuViewerSrvc.KillAllprocess(exeFileName: string): Boolean; ////найти и завершить процесс запушенный во всех сеансах
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
          //Log_Write('service','Поиск и завершение процесса процесса: НАЙДЕН: '+UpperCase(FProcessEntry32.szExeFile)+': PID = '+inttostr(FProcessEntry32.th32ProcessID));
          if ProcessIdToSessionId(FProcessEntry32.th32ProcessID,IdProcSession) then //IdProcSession в каком сеансе запушен процесс
            begin
             TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),FProcessEntry32.th32ProcessID),0);
            ///Log_Write('service','Поиск и завершение процесса процесса: Завершение процесса: '+ UpperCase(FProcessEntry32.szExeFile)+': PID = '+inttostr(FProcessEntry32.th32ProcessID)+' : IdProcSession = '+inttostr(IdProcSession))
            //else Log_Write('service','Ошибка при завершении процесса: '+SysErrorMessage(GetLastError()));
            Result := True;
            end;
          end;
      end;
      CloseHandle(FSnapshotHandle);
    except on E: Exception do
    Log_Write('service',3,'Ошибка завершение процесса '+exeFileName+': '+e.ClassName +': '+ e.Message);
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

function TRuViewerSrvc.GetNamePC:string;  // запрос имени ПК
var
i: DWORD;
p: PChar;
begin
  try  // имя ПК
  i:=255;
  GetMem(p, i);
  GetComputerName(p, i);
  result:=String(p);
  finally
  FreeMem(p);
  end;
end;

Procedure TRuViewerSrvc.ReadFileSet(var LevelRunSrvc,LevelRunUser:integer ;var srv,NamePC:string; var Port:integer; var AutoRun:String; var result:boolean);// чтение настроек из файла
var
Fileset: TMemInifile;
begin
if FileExists(ExtractFilePath(Application.ExeName) + '\data.dat') then // чтение файла параметров если он существует
    begin
      Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName) +
        '\data.dat', TEncoding.Unicode);
      try
      Port:=Fileset.ReadInteger('Net','Port',0); //3898
      srv:=Fileset.ReadString('Net','IP','');   //сервер
      NamePC:=fileset.ReadString('Other','PCn','Unknw');
      AutoRun:= fileset.ReadString('Other','AutoRun','Auto');
      LevelRunSrvc:=Fileset.ReadInteger('Privileges','LevelAutoRun',0);
      LevelRunUser:=Fileset.ReadInteger('Privileges','LevelManualRun',0);
      Fileset.Free;
      result:=true;
     // Log_Write('service','Чтение файла настроек :'+inttostr(port)+': '+srv+': '+NamePC);
       except on  E : Exception do
       begin
        Log_Write('service',3,'Ошибка чтения файла настроек :'+E.Message);
        result:=false;
       end;
       end;
     end
   else result:=false; // если нет файла настроек
end;

function TRuViewerSrvc.WriteFileSet(srv,port,NamePC,AutoRun:string):boolean; // запись настроек в файл
var
Fileset: TMemInifile;
begin
 Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName)+'\data.dat', TEncoding.Unicode);
 try
if port<>'' then Fileset.writestring('Net','Port',port); //3898
if srv<>'' then Fileset.writestring('Net','IP',srv);   //сервер
if NamePC<>'' then fileset.WriteString('Other','PCn',NamePC);
if AutoRun<>'' then fileset.WriteString('Other','AutoRun',AutoRun);
fileset.UpdateFile;
Fileset.Free;
 except on  E : Exception do Log_Write('service',3,'Ошибка записи файла настроек :'+E.Message);
 end;
end;

Procedure TRuViewerSrvc.ReadRegSet(var LevelRunSrvc,LevelRunUser,levelLog,port:Integer; var srv,NamePC:string; var Autorun:String; var result:boolean); // чтение настроек из реестра
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    result:=false;
    Reg := TRegistry.Create(KEY_WOW64_64KEY); //в 64х битных системах читаем реестр для 64 бит. т.к. служба 32х то этот ключ необходим для чтения раздела реестра
    Reg.RootKey := HKEY_LOCAL_MACHINE;        //HKEY_LOCAL_MACHINE\SOFTWARE\RuViewer а не HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\RuViewer который будет выдавать система изи редиректа 32х битных приложений в системах 64х
    if Reg.OpenKeyReadOnly('SOFTWARE\RuViewer') then  // ключ только читаем
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
    Log_Write('service',3,'Ошибка чтения настроек в реестре :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.WriteRegSet(port:Integer; srv,NamePC,Autorun:String):boolean; // Запись настроек в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
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
    Log_Write('service',3,'Ошибка записи настроек в реестр :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.WriteRegSendSAS(meaning:Integer; DelValue:boolean; {Удалить ключ} var OldMeaning:integer):boolean; // Запись настроек Disable or enable software Secure Attention Sequence в реестр
var  //HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system - SoftwareSASGeneration - Отсутствие ключа- Политика отключена. 0- политика.вкл значение для программ и служб Нет. 1 - Разрешено службам 2- Разрешено Приложениям 3-службам и приложениям
  Reg: TRegistry; //https://gpsearch.azurewebsites.net/#2810
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system',false) then // если удалось открыть ключ
      begin       //Log_Write('service','Открыли ключ реестра');
       if not delValue then // Если необходимо записать данные
        begin
        if Reg.ValueExists('SoftwareSASGeneration') then // если ключ существует то читаем его занчение
        OldMeaning:=Reg.ReadInteger('SoftwareSASGeneration')
        else OldMeaning:=4; // иначе данного ключа не существует и политика не включена. Передаем занчение доя последующего применения.
        // в любом случае далее записываем значение ключа
        //Log_Write('service','Открыли ключ реестра: Предыдущее значение: '+inttostr(OldMeaning));
        Reg.WriteInteger('SoftwareSASGeneration',meaning);
        //Log_Write('service','Открыли ключ реестра: Записали значение: '+inttostr(meaning));
        result:=true;
        end;
       if DelValue then result:=Reg.DeleteValue('SoftwareSASGeneration'); // Если необходимо удалить значение;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    Log_Write('service',3,'Ошибка записи настроек SendSAS в реестр :'+E.Message);
    result:=false;
  end;
end;
end;


function TRuViewerSrvc.ReadParamsRun(var LevelRunSrvc,LevelRunUser, LevelLog,port:integer; var Host,NamePC,AutoRun:string ):boolean; /// Чтение параметров запуска
var
readSettings:boolean;
portstr:string;
begin
try
 readSettings:=false;
  {if (ParamStr(1)<>'') then // Чтение параметров строки запуска приложения если параметры существуют и не пустые
    Begin
      Host := ParamStr(1);  // первый параметр это ip адрес сервера для подключения
      if (ParamStr(2)<>'') then
      if not trystrtoint(ParamStr(2),port) then port:=0;// если второй параметр не integer  то 0
      if (ParamStr(3)='Auto') then AutoRun:='Auto' else AutoRun:='No';
      if (ParamStr(4)<>'') then NamePC:=ParamStr(4) else NamePC:=GetNamePC; // Передаем Имя компьютера
      if not WriteRegSet(Port,host,NamePC,AutoRun) then //записать в реестр иначе если не получилось то в файл
      writefileSet(host,inttostr(Port),NamePC,AutoRun); // запись в файл настроек
      readSettings:=true;
    End
   else } // иначе настройки читаем в файле или реестре
    begin
     //Log_Write('service','Чтение параметров запуска в реестре');
     ReadRegSet(LevelRunSrvc,LevelRunUser,LevelLog,port,Host,NamePC,AutoRun,readSettings);// читаем реестр
     if not readSettings then // если в реестре нет ничего то читаем файл
     begin
     ReadFileSet(LevelRunSrvc,LevelRunUser,Host,NamePC,port,AutoRun,readSettings); //  читаем настройки из файла
     end;
    end;
result:=readSettings;
except on E:Exception do
  begin
    Log_Write('service',3,'Ошибка чтения параметров запуска :'+E.Message);
    result:=false;
  end;
end;
end;


function TRuViewerSrvc.RunProcInSession(numSession:integer; RunAs:string):boolean; // запуск процесса пользоватлем из приложения
var
typeSession,Host,NamePC,AutoRunStr:string; // Console или Rdp
PidTmp,port:integer;
RdpSession:boolean;
PlevelManual:RunAsSystem.TIntegrityLevel;
begin
try
 ThreadRunPause:=true; // включаем паузу для потока
 ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// чтение параметров запуска процесса
 LevelLogErrorRun:=LevelLogError; // уровень логирования в юните AsRunSystem
 //log_Write('service',2,'RunNowProcess port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr+' LevelManual='+inttostr(LevelRunManual));
  case LevelRunManual of
   0:PlevelManual:=RunAsSystem.SystemIntegrityLevel;
   1:PlevelManual:=RunAsSystem.HighIntegrityLevel;
   2:PlevelManual:=RunAsSystem.MediumIntegrityLevel;
   else PlevelManual:=RunAsSystem.SystemIntegrityLevel;
  end;
  typeSession:=GetTypeSession(numSession); // определние типа сессии RDP или console
 // log_Write('service',2,RunAs+' Session='+inttostr(numSession)+' Type='+typeSession);

  if typeSession='Console' then RdpSession:=false
  else if typeSession='Rdp' then RdpSession:=true;
   if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // если hash файла соответствует
   begin
    if RunProcAsSystemRunUser(ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' '+inttostr(LevelRunManual),numSession,RdpSession,PidConsoleProc, PlevelManual) then
     begin
     //if not RdpSession then log_Write('service', 'RunSession Процесс RuViewer.exe запустил в сеансе '+inttostr(numSession)+'  PID процесса  = '+inttostr(PidConsoleProc) )
     //else log_Write('service', 'RDP Процесс RuViewer.exe запустил в сеансе '+inttostr(numSession)+' PID процесса = '+inttostr(PidTmp));
     end
     else log_Write('service',2, 'ManualRun Не удалось запустить процесс: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe в сеансе '+inttostr(numSession) );
   end
    else log_Write('service', 2,'ManualRun Файл изменен: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
 ThreadRunPause:=false; // выключаем паузу для потока
except on E:Exception do
  begin
    Log_Write('service',3,'Ошибка ручного запуска :'+E.Message);
    result:=false;
  end;
end;
end;

function TRuViewerSrvc.RunNowProcess(RunAs:string):boolean; // запуск процесса при старте службы
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
PidConsoleProc:=0; // при старте сервиса узнаем PID процесса запущенного для консольного сеанса
ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// чтение параметров запуска процесса
 case LevelAutoRun of
   0:PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
   1:PLevelAuto:=RunAsSystem.HighIntegrityLevel;
   2:PLevelAuto:=RunAsSystem.MediumIntegrityLevel;
   else PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
  end;
log_Write('service',1,'RunNowProcess port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr+' LevelAutoRun='+inttostr(LevelAutoRun));
AllSessionID:=GetCurentSession; // получаем номера активных консольных сеансов пользователей
AllRDPSessionID:=GetCurentRDPSession; // получаем номера активных RDP сеансов пользователей
CurrentConsoleSessionID:=0;
CurrentConsoleSessionID:=GetCurentSessionConsole; // Консольня сессия активного пользователя
//log_Write('service','AllSessionID length='+inttostr(length(AllSessionID))+' AllRDPSessionID length='+inttostr(length(AllRDPSessionID))+' CurrentConsoleSessionID='+inttostr(CurrentConsoleSessionID));
if (AutoRunStr<>'No') then // если автозапуск не отключен
  Begin
    for I := 0 to Length(AllSessionID)-1 do // консольные сеансы
    begin
      if not ProcessExists('RuViewer.exe',AllSessionID[i]) then    //// запущен ли процесс в консольном сеансе если нет и получаем его PID если он запущен то запускаем новый
       begin
       if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // если hash файла соответствует
        begin // в консольном сеансе процесс всегда запускается с наивисшими правами RunAsSystem.SystemIntegrityLevel, уровень системы
         if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' 0',AllSessionID[i],false,PidConsoleProc,PLevelAuto ) then
          begin
          RunConsole:=true;
          log_Write('service',1, 'RunNowProcess Console Процесс RuViewer.exe запустил в сеансе '+inttostr(AllSessionID[i])+'  PID процесса  = '+inttostr(PidConsoleProc) );
          end
           else log_Write('service', 2,'RunNowProcess Console Не удалось запустить процесс: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe в сеансе '+inttostr(AllSessionID[i]) );
        end
        else log_Write('service', 2,'RunNowProcess Console Файл изменен: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');

       end;
    end;

     for I := 0 to Length(AllRDPSessionID)-1 do  // терминальные (RDP) сеансы
     if not ProcessExists('RuViewer.exe',AllRDPSessionID[i]) then    //// запущен ли процесс если нет то запускаем новый
      begin
       if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // если hash файла соответствует
       begin
        if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe','RuViewer.exe '+RunAs+' '+inttostr(LevelAutoRun),AllRDPSessionID[i],true,PidTmp,PLevelAuto) then
         begin
         log_Write('service',1, 'RunNowProcess RDP Процесс RuViewer.exe запустил в сеансе '+inttostr(AllRDPSessionID[i])+' PID процесса = '+inttostr(PidTmp));
         end
          else log_Write('service',2, 'RunNowProcess RDP Не удалось запустить процесс: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe в сеансе '+inttostr(AllRDPSessionID[i]) );
       end
       else log_Write('service', 2,'RunNowProcess RDP Файл изменен: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');

      end;
   ForceRunApp:=false; // признак  запуска процесса вручную
  End;
if not RunConsole then // если не запустили процесс в консоли
PidConsoleProc:= PidTmp; // присваиваем пид процесса в RDP

except on E: Exception do
Log_Write('service',3,'Ошибка RunNowProcess: '+e.ClassName +': '+ e.Message);
end;
end;






Function TRuViewerSrvc.ControlRunProcess(NameProcessRun:string):boolean; // запуск процесса из контрольного потока
var
port,i:integer;
Host,NamePC:string;
DSession,ASession,CurentSession:ArraySession;
pidtmp:integer;
AutoRunstr:String;
PLevelAuto:RunAsSystem.TIntegrityLevel;
begin
///////////////////////////////////////////////////////////////////// консольные и Winlogon сеансы
  try
  DSession:=nil;
  ASession:=nil;
  CurentSession:=nil;
  ReadParamsRun(LevelAutoRun,LevelRunManual,LevelLogError,port,Host,NamePC,AutoRunStr);// чтение параметров запуска процесса
  LevelLogErrorRun:=LevelLogError; // уровень логирования в юните AsRunSystem
  case LevelAutoRun of
   0:PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
   1:PLevelAuto:=RunAsSystem.HighIntegrityLevel;
   2:PLevelAuto:=RunAsSystem.MediumIntegrityLevel;
   else PLevelAuto:=RunAsSystem.SystemIntegrityLevel;
  end;
  //log_Write('service', 'Timer port='+inttostr(port)+' Host='+Host+' NamePC='+NamePC+' AutoRun='+AutoRunStr);
  //AllSessionID - список сеансов предыдущей операции
  CurentSession:=GetCurentSession; // получаем номера всех консольных сеансов пользователей в текуший момент
  CurrentConsoleSessionID:=GetCurentSessionConsole; // получаем номер активной сессии консольного пользователя
  if  ((AutoRunStr<>'No') and (not ApplicationExit)) then // если автозапуск и программу принудительно не выключили или запросили запуск из приложения
     Begin
        if not IDSessionRunProcessConsole('RuViewer.exe',SessionIDConsoleRunProc) then  //проверяем запущен процесс в консольном сеансе или нет и получаем ID сеанса процесса(в RDP саенсах процессы запускаются не зависимо)
        begin
        // Log_Write('service',0,'Консольный процесс ЗАПУЩЕН в сеансе SessionIDConsoleRunProc='+ inttostr(SessionIDConsoleRunProc));
        if SessionIDConsoleRunProc=0 then
          begin
         // Log_Write('service','Консольный процесс НЕ запущен SessionIDConsoleRunProc='+ inttostr(SessionIDConsoleRunProc));
          for I := 0 to Length(CurentSession)-1 do // запуск процессов в новых сеансах
            begin
            // Log_Write('service',2,'поиск и запуск процесса в консольном сеансе='+inttostr(CurentSession[i]));
              if not FindProcessPID('RuViewer.exe',PidConsoleProc,false,PidTmp) then // проверяем запущен ли процесс с PID=PidConsoleProc- это процесс запущенный в консоли, если нет то думаем как его запустить
              begin // если незапущен то запускаем и получаем его PID
               if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // если hash файла соответствует
               begin
                if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe RunService 0',CurentSession[i],false,PidConsoleProc,PLevelAuto ) then // в консольном сеансе процесс всегда запускается с наивисшими правами RunAsSystem.SystemIntegrityLevel, уровень системы
                 begin
                 Log_Write('service',1,'ControlRunProcess Console Запущен процесс RuViewer.exe в сеансе: '+inttostr(CurentSession[i]));
                 //log_Write('service', 'Console PID процесса '+inttostr(PidConsoleProc));
                 end
                 else Log_Write('service',2,'ControlRunProcess Console не удалось запустить процесс RuViewer.exe в сеансе: '+inttostr(CurentSession[i]));
               end
                else log_Write('service', 2,'ControlRunProcess Console Файл изменен: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
              end;
            end;
          end;
        end;
     End;

    {if EqualArraySessionID(ASession,DSession,AllSessionID,CurentSession) then //Получаем список удаленных и новых сеансов
      begin
        //for I := 0 to Length(DSession)-1 do // завершение процессов завершенных сеансов???
       // begin
         //if ProcessExists('RuViewer.exe',DSession[i])then
        // if KillprocessSession('RuViewer.exe',DSession[i]) then
        // Log_Write('service', 'Произведено завершение процесса в сеансе: '+inttostr(DSession[i]) );
       // end;

        for I := 0 to Length(ASession)-1 do // запуск процессов в новых сеансах
        begin
          if not ProcessExists('RuViewer.exe',ASession[i]) then
          if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe '+Host+' '+inttostr(Port)+' '+NamePC,ASession[i],false,pidtmp,RunAsSystem.SystemIntegrityLevel ) then
          begin
           Log_Write('service', 'Запущен процесс RuViewer.exe в сеансе: '+inttostr(ASession[i]));
           log_Write('service', 'PID процесса '+inttostr(PidTmp));
          end
          else Log_Write('service', 'Не удалось запустить процесс RuViewer.exe в сеансе: '+inttostr(ASession[i]));
        end;
      end;}

   // Log_Write('service', 'Текущий активный консольный сеанс WTSGetActiveConsoleSessionId: '+inttostr(WTSGetActiveConsoleSessionId));
   // Log_Write('service', 'Текущий активный консольный сеанс: '+inttostr(CurrentConsoleSessionID));
   // Log_Write('service', 'Консольный процесс запущен в сеансе: '+inttostr(SessionIDConsoleRunProc));

    AllSessionID:=nil;
    AllSessionID:=GetCurentSession; // получаем номера всех консольных сеансов пользователей в текуший момент
    DSession:=nil;
    ASession:=nil;
    CurentSession:=nil;
     except on E: Exception do
      Log_Write('service',3,'Ошибка процедуры контроля приложений в консольных сеансах: '+e.ClassName +': '+ e.Message);
     end;
/////////////////////////////////////////////////////////////////////////////////////////////// RDP сеансы
  try
  DSession:=nil;
  ASession:=nil;
  CurentSession:=nil;
  //AllRDPSessionID - список RDP сеансов предыдущей операции
  CurentSession:=GetCurentRDPSession; // получаем номера активных RDP сеансов пользователей в текуший момент
  if ((AutoRunStr<>'No')and (not ApplicationExit)) then /// если автозапуск и программу принудительно не выключили или запросили запуск из приложения
    Begin                  //новые, удаленные, предыдущие, текущие сеансы
    if EqualArraySessionID(ASession,DSession,AllRDPSessionID,CurentSession) then //Получаем список удаленных и новых сеансов
      begin
        for I := 0 to Length(DSession)-1 do // завершение процессов завершенных сеансов???
        begin
         if CurrentConsoleSessionID<>DSession[i] then   // если RDP сеанс не был консольным до этого
           begin
           if ProcessExists('RuViewer.exe',DSession[i])then // ищем процесс
           KillprocessSession('RuViewer.exe',DSession[i]); // удаляем если он есть
          // Log_Write('service', 'Произведено завершение процесса в сеансе: '+inttostr(DSession[i]) );
           end;
        end;

        for I := 0 to Length(ASession)-1 do // запуск процессов в новых сеансах
        begin
          if not ProcessExists('RuViewer.exe',ASession[i]) then // если процесс не найден
            begin
            //Log_Write('service',2,'RDP сеанс, процесс НЕ ЗАПУЩЕН в сеансе ='+ inttostr(ASession[i]));
              if HashRunFile(ExtractFilePath(Application.ExeName)+'RuViewer.exe') then // если hash файла соответствует
              begin
               if RunProcAsSystem( ExtractFilePath(Application.ExeName)+'RuViewer.exe', 'RuViewer.exe RunService '+inttostr(LevelAutoRun),ASession[i],true,PidTmp,PLevelAuto ) then
               begin
               Log_Write('service',1, 'ControlRunProcess RDP Запущен процесс RuViewer.exe в сеансе: '+inttostr(ASession[i]));
               //log_Write('service', 'RPD PID процесса '+inttostr(PidTmp));
               end
                else Log_Write('service', 2,'ControlRunProcess RDP Не удалось запустить процесс RuViewer.exe в сеансе: '+inttostr(ASession[i]));
              end
              else log_Write('service', 2,'ControlRunProcess RDP Файл изменен: ' +  ExtractFilePath(Application.ExeName)+'RuViewer.exe');
            end;
        end;
      end;
    End;
    AllRDPSessionID:=nil;
    AllRDPSessionID:=GetCurentRDPSession; // получаем номера активных RDP сеансов пользователей в текуший момент
    DSession:=nil;
    ASession:=nil;
    CurentSession:=nil;
   except on E: Exception do
    Log_Write('service',3,'Ошибка процедуры контроля приложений в RDP сеансах: '+e.ClassName +': '+ e.Message);
   end;
end;







Function TRuViewerSrvc.EqualArraySessionID(var AddSession:ArraySession; Var DelSession:ArraySession; AllSession:ArraySession; CurSession:ArraySession):boolean;
var
i,j:integer;
function DelElArray(r:integer; var Delmas:ArraySession):boolean; // Функция поиска и удаления элемента из массива
var
Y,Z:integer;
begin
try
for Y := 0 to Length(delmas)-1 do
begin
 if delmas[Y]=r then  // если нашли этот элемент
  begin
   for Z := Y to Length(delmas)-2 do // перемещаем элементы с найденного до предпоследнего, потому как Z+1
    begin
    delmas[Z]:=delmas[Z+1]; // присваиваем ему значение следующего
    end;
  Setlength(delmas,length(delmas)-1); // уменьшам длинну массива
  //break;
  end;
end;
except on E: Exception do Log_Write('service',3,'Удаения элементов массива: '+e.ClassName +': '+ e.Message);
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
      //Log_Write('service','Сравнение AllSession['+inttostr(i)+']: '+inttostr(AllSession[i])+' = CurSession['+inttostr(j)+']: '+inttostr(CurSession[j]));
      if AllSession[i]=CurSession[j] then  // если элементы массивов равны
       begin
       //Log_Write('service','Равны AllSession['+inttostr(i)+']: '+inttostr(AllSession[i])+' = CurSession['+inttostr(j)+']: '+inttostr(CurSession[j]));
       DelElArray(AllSession[i],DelSession);       //производим его удаление в массиве DelSession. в итоге останутся только удаленные сеансы
       DelElArray(CurSession[j],AddSession);    // производим его удаление в массиве AddSession. в итоге останутся только сеансы вновь запущеные
      // break;
       end
     end;
 end;
result:=true;
except on E: Exception do
begin
Log_Write('service',3,'Ошибка EqualArraySessionID сравнения сеансов: '+e.ClassName +': '+ e.Message);
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
      // Прописываем себе описание
      Reg.WriteString('Description', 'Служба RuViewer');
    finally
      FreeAndNil(Reg);
    end;
   except on E: Exception do
    begin
    Log_Write('service',3,'Ошибка Add Description RuViewerSrvc: '+e.ClassName +': '+ e.Message);
    end;
  end;
end;



procedure TRuViewerSrvc.ServiceStart(Sender: TService; var Started: Boolean);
begin
try
LevelLogErrorRun:=0; // уровень логирования в юните AsRunSystem
LevelLogError:=0; // уровень логирования
LevelAutoRun:=0; //0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
LevelRunManual:=0;//0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID

Log_Write('service',1,'Запуск службы');
PCUID:=generateUID; // генерация уникально UID
if length(PCUID)>=11 then ServiceUID:=copy(PCUID,1,10) //первые 10 символов уникального ID
 else ServiceUID:='ServiceUID';
MyStreamCipherId:='native.StreamToBlock'; //TCodec.StreamCipherId для шифрования
MyBlockCipherId:='native.AES-256'; // TCodec.BlockCipherId для шифрования
MyChainModeId:='native.ECB'; // TCodec.ChainModeId для шифрования
EncodingCrypt:=Tencoding.Create;
EncodingCrypt:=Tencoding.UTF8; // кодировка для шифрования
ForceRunApp:=false; // признак  запуска процесса вручную
ApplicationExit:=false; // признак того что программу не закрыли вручную (т.е.не нажали кнопку выход)
RunNowProcess('FirstRun'); // запускаем процесс
pipesCreate; // создаем именованный канал для связи службы с приложением
ShutDownPC:=false; // вроде как признак выключения ПК если значение =true
LogOffUser:=false; // вроде как признак завершения сеанса пользователя если значение =true
ThreadRunBreak:=false; //признак завершения потока
ThreadRunPause:=false; // признак паузы
ThRunStart:=TThread_Run_Process.Create('RuViewer.exe',TimeOutThread); // запуск потока
Log_Write('service',1,'Служба запущена');
Started:=true;
except on E: Exception do
    begin
    Log_Write('service',3,'Ошибка запуска службы : '+e.ClassName +': '+ e.Message);
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
Log_Write('service',1,tmpStr+' Остановка службы');
ThreadRunBreak:=true; // признак выхода из цикла в потоке
ThreadRunPause:=false; //отключаем паузу
ThRunStart.Terminate; // признак завершения потока
FreeAndNil(ThRunStart);
pipesDelete; // удаление сервера именованого канала
if KillAllprocess('RuViewer.exe') then  Log_Write('service',0,'Процессы остановлены');
Log_Write('service',1,tmpStr+' Служба остановлена');
except on E: Exception do
Log_Write('service',0,tmpStr+' Ошибка : '+e.ClassName +': '+ e.Message);
end;
end;


end.

