unit RunInConnect;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,VCL.Forms,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,DateUtils, uTPLb_CryptographicLibrary, uTPLb_Codec;

 type //
  TThread_RunInConnect = class (TThread)
    private
    SrvSocketClaster: TServerSocket;
    ListClaserIP:TstringList;
    IndexArray:integer;
    public
    constructor Create(aListClaserIP:TstringList); overload;
    procedure Execute; override; // процедура выполнения потока
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function AddRecordClaster(var NextClient:integer; InOut:byte):boolean;
   // function AddArrayPrefix(var NextClient:integer):boolean; // добавление пустой записи в массив префиксов
    //Function AddPrefixMySrv(InsertPrfx:boolean;SrvIP,SrvPswd,SrvPrfx:string;SrvPort:integer):boolean;// добавить в массив префиксов запись о себе
    function ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента
    function FindArrayConnectBusy(SocketHandle:integer; SrvIp:string; InOut:byte):boolean; // очистка
    function DecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
    procedure SrvSocketClasterClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketClasterClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketClasterClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    function CloseClientConnect(ipAddress:string):boolean; // закрыть подключение от клиента
    function AddFindBlackList(AddOrFind:byte;IpAddress:string):boolean; // Добавляем в черный список ip адрес
    Procedure CloseServer; // выключение сервера входящих подключений

   type  //поток обработки входящего соединения кластера
  TThreadConnection_Claster = class(TThread)
  private
    //ConnectInClaster:^TserverClst;
    TmpSocket:TCustomWinSocket;
    IDIndex:integer;
  public
    constructor Create(aSocket: TCustomWinSocket; aIDConnect:integer); overload;
    procedure Execute; override; // процедура выполнения потока
    function SendMainSock(s:string):boolean; // функция отправки через сокет управления
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function  ParsingListPrefix(var NewListPrefix:TstringList):boolean; //поиск своего IP/замена/добавлеие в списке префиксов
    function PrefixListToArray(ListPrefix:TstringList):boolean; // замена/добавление массива записей префиксов на полученые из ListPrefix
    Function PrefixArrayToList(Var ListPrefix:TstringList):boolean; // Перевод всего массива в ListString
    function ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //сравнение 2х списков префиксов, локального и принятого
    Function MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // получаем список своих исходящих активных серверов в кластере, для передачи другому серверу
    function AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // добавляем список полученных серверов в список ReciveListServerClaster
    function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
    function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
  end;


  end;



implementation
Uses MainModule,FunctionPrefixServer,SocketCrypt;
//---------------- создание потока для создания сервера входящих и обраотки массива для входящих соединений
 constructor TThread_RunInConnect.Create(aListClaserIP:TstringList);
begin        //
  inherited Create(False);
  try
  ListClaserIP:=TstringList.Create;
  ListClaserIP.CommaText:=aListClaserIP.CommaText;
  SrvSocketClaster:=TServerSocket.Create(nil);
  SrvSocketClaster.Active:=false;
  SrvSocketClaster.OnClientConnect:=SrvSocketClasterClientConnect;
  SrvSocketClaster.OnClientDisconnect:=SrvSocketClasterClientDisconnect;
  SrvSocketClaster.OnClientError:=SrvSocketClasterClientError;
  SrvSocketClaster.ServerType :=stNonBlocking;// stNonBlocking; stThreadBlocking;
  SrvSocketClaster.Port :=PortServerClaster;
  SrvSocketClaster.Active:=true;
  FreeOnTerminate := true;
except On E: Exception do
 begin
 Write_Log('InClaster',2,'TThreadRunOutConnect.Create '{+ E.ClassName+' / '+ E.Message});
 end;
end;
end;
// создание потока для обработки входящих подключений кластера
constructor TThread_RunInConnect.TThreadConnection_Claster.Create(aSocket: TCustomWinSocket; aIDConnect:integer);
begin
  inherited Create(False);
  TmpSocket:=aSocket;
  IDindex:=aIDConnect;
  FreeOnTerminate := true;
end;
//---------------------------------------------------------
function TThread_RunInConnect.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // функция записи в лог для для потока
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
try
 if NumError<=LevelLogError then // если уровень ошибки ниже чем указаный в настройках
  Begin
  if not DirectoryExists('log') then CreateDir('log');
      f:=TStringList.Create;
      try
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
         while f.Count>1000 do f.Delete(0);;
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;
//------------------------------------------------------
Procedure TThread_RunInConnect.CloseServer; // Закрытие сервера входящих подключений
 var i:integer;
 begin
   try
    for I := 0 to SrvSocketClaster.Socket.ActiveConnections-1 do
    begin
    SrvSocketClaster.Socket.Connections[i].Close; //закрыть подключение от клиента.
    end;
    SrvSocketClaster.Socket.close;
   // SrvSocketClaster.Close;
    except On E: Exception do
     begin
     Write_Log('InClaster',2,'CloseServer '{+ E.ClassName+' / '+ E.Message});
     end;
   end;
 end;

//----------------------------------------------------------------
 function TThread_RunInConnect.CloseClientConnect(ipAddress:string):boolean; // закрыть подключение от клиента.
 var i:integer;
 begin
 try
  for I := 0 to SrvSocketClaster.Socket.ActiveConnections-1 do
  begin
    if SrvSocketClaster.Socket.Connections[i].RemoteAddress=ipAddress then
    begin
     SrvSocketClaster.Socket.Connections[i].Close;
     result:=true;
     break;
    end
    else result:=false;
  end;
except On E: Exception do
 begin
 result:=false;
 Write_Log('InClaster',2,'CloseClientConnect '{+ E.ClassName+' / '+ E.Message});
 end;
end;
 end;
 //----------------------------------------------------
 function TThread_RunInConnect.AddFindBlackList(AddOrFind:byte; IpAddress:string):boolean;
 var
 i,NumConnect:integer;
 SrvIP,DateCreate:string;
 TmpDateCreate:TdateTime;
 exist:boolean;
function SeparationText(SepStr:string):boolean;  // получаем   строку с реквизитами  blacklist
begin                                          //172.16.1.2=кол-во=датавремя=;
try
SrvIP:='';DateCreate:=''; NumConnect:=0;
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),NumConnect);
Delete(SepStr,1,pos('=',SepStr));
if TryStrToDateTime(copy(SepStr,1,pos('=;',SepStr)-1),TmpDateCreate) then DateCreate:=DateTimeTostr(TmpDateCreate) else DateCreate:='';
SepStr:='';
result:=true;
 except on E : Exception do begin
  result:=false;
  Write_Log('InClaster',2,'(1) Парсинг строки BlackList  : '{+E.ClassName+': '+E.Message});
  end; end;
end;
 begin
try
if not AddIpBlackListClaster then   // если черный список выключен
begin
result:=false;
exit;
end;
 exist:=false;
 //-------------------------------
 if AddOrFind=0 then  // добавить в черный список
 Begin
  Write_Log('InClaster',1,'('+inttostr(AddOrFind)+') Добавляю в черный список '+IpAddress+' '+DatetimetoStr(now));
 for I := 0 to BlackListServerClaster.Count-1 do
  begin
  if SeparationText(BlackListServerClaster[i]) then
   begin
    if SrvIP=IpAddress then // если ip существует в списке
     begin
     exist:=true; // обновляем запись
     BlackListServerClaster[i]:=IpAddress+'='+inttostr(NumConnect+1)+'='+DateTimeToStr(now)+'=;';
     break;
     end;
    end;
  end; //цикл
   if not exist then  // если не нашли то добавляем в список
   begin
   BlackListServerClaster.add(IpAddress+'=1='+DateTimeToStr(now)+'=;');
   exist:=true; // добавили
   end;
  End;
 //-----------------------------------

 if AddOrFind=1 then  // поиск в черном списке
  Begin
  //Write_Log('InClaster',inttostr(AddOrFind)+' Поиск в черном списке '+IpAddress);
   for I := 0 to BlackListServerClaster.Count-1 do
    begin
     if SeparationText(BlackListServerClaster[i]) then
      begin
       if (SrvIP=IpAddress)then
       if MinutesBetween(now,TmpDateCreate)>=LiveTimeBlackList then
        begin
         Write_Log('InClaster',1,'('+inttostr(AddOrFind)+') Удаляю из черного списка '+IpAddress+' DateCreate='+DatetimetoStr(TmpDateCreate) );
        BlackListServerClaster.Delete(i);
        exist:=false; //т.к. удалили из списка то говорим что этого его тут нет
        break;      // валим из цикла
        end;
       if (SrvIP=IpAddress) and (NumConnect>=NumOccurentc) then // если IP в списке и количество повторов блокировки превышает допустимое
        begin
        BlackListServerClaster[i]:=IpAddress+'='+inttostr(NumConnect+1)+'='+DateTimeToStr(now)+'=;'; // обновляем запись
        exist:=true; // нашли и выходим из списка
        break;
        end;
      end;
    end
  End;
 //------------------------------------------
 result:=exist;
 except on E : Exception do begin
  result:=false;
  Write_Log('InClaster',2,'('+inttostr(AddOrFind)+') Добавление и поиск в BlackList : '{+E.ClassName+': '+E.Message});
  end; end;
 end;
//---------------------------------------------------
function TThread_RunInConnect.ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента
begin
try
result:=false;
if indexArray<=length(ArrayClientClaster)-1 then
 begin
  // Write_Log('InClaster',' ClearArrayConnectBusy начало очистки массива с indexArray='+inttostr(indexArray));
   ArrayClientClaster[indexArray].ServerAddress:='';
   ArrayClientClaster[indexArray].Serverport:=0;
   ArrayClientClaster[indexArray].ServerPassword:='';
   ArrayClientClaster[indexArray].SocketHandle:=0;
   ArrayClientClaster[indexArray].MyPing:=64;
   ArrayClientClaster[indexArray].InOutput:=0;
   ArrayClientClaster[indexArray].IDConnect:=0;
   ArrayClientClaster[indexArray].CloseThread:=false;
  // Write_Log('InClaster',' ClearArrayConnectBusy завершена очистка массива с indexArray='+inttostr(indexArray));
   result:=true;
 end;
except
    On E: Exception do Write_Log('InClaster',2,'ClearArrayConnectBusy index='+inttostr(indexArray){+' '+ E.ClassName+' / '+ E.Message});
    end;
 end;
//---------------------------------------------------

function TThread_RunInConnect.FindArrayConnectBusy(SocketHandle:integer; SrvIp:string; InOut:byte):boolean; // очистка
var   // поиск элемента массива и изменение статуса занятости этого элемента Вызывается при Disconect соединения и SocketError
i:integer;
begin
try
result:=false;
//Write_Log('InClaster','FindArrayConnectBusy Поиск для очистки SocketHandle='+inttostr(SocketHandle)+ ' адрес - '+SrvIp);
if SrvIp='' then
begin
 for I := 0 to Length(ArrayClientClaster)-1 do
 if ((ArrayClientClaster[i].SocketHandle=SocketHandle) or (ArrayClientClaster[i].SocketHandle=2)) and (ArrayClientClaster[i].InOutput=InOut) then // поиск по handle если ип пустой
 begin
   //Write_Log('InClaster','FindArrayConnectBusy Нашли и очищаем SocketHandle='+inttostr(SocketHandle)+ ' InOutput='+inttostr(InOut));
   ArrayClientClaster[i].ServerAddress:='';
   ArrayClientClaster[i].Serverport:=0;
   ArrayClientClaster[i].ServerPassword:='';
   ArrayClientClaster[i].SocketHandle:=0;
   ArrayClientClaster[i].MyPing:=64;
   ArrayClientClaster[i].InOutput:=0;
   ArrayClientClaster[i].IDConnect:=0;
   ArrayClientClaster[i].StatusConnect:=0;
   ArrayClientClaster[i].CloseThread:=false;
   result:=true;
   break;
 end;
end
else
 begin
  for I := 0 to Length(ArrayClientClaster)-1 do
 if (ArrayClientClaster[i].ServerAddress=SrvIp) and (ArrayClientClaster[i].InOutput=InOut) then // только IP потому что соединение с сервером может быть только одно
 begin
   //Write_Log('InClaster','FindArrayConnectBusy Нашли SocketHandle='+inttostr(SocketHandle)+' ServerAddress='+SrvIp+ ' InOutput='+inttostr(InOut));
   ArrayClientClaster[i].ServerAddress:='';
   ArrayClientClaster[i].Serverport:=0;
   ArrayClientClaster[i].ServerPassword:='';
   ArrayClientClaster[i].SocketHandle:=0;
   ArrayClientClaster[i].MyPing:=64;
   ArrayClientClaster[i].InOutput:=0;
   ArrayClientClaster[i].StatusConnect:=0;
   ArrayClientClaster[i].IDConnect:=0;
   ArrayClientClaster[i].CloseThread:=false;
 end;
 end;

except
    On E: Exception do Write_Log('InClaster',2,'FindArrayConnectBusy SocketHandle='+inttostr(SocketHandle){+' '+E.ClassName+' / '+ E.Message});
    end;
 end;
//----------------------------------------------------
function TThread_RunInConnect.AddRecordClaster(var NextClient:integer; InOut:byte):boolean;
var     // добавление записи в массив соединений  серверами кластера
i:integer;
exist:boolean;
step:integer;
begin
try
exist:=false;
begin
try
step:=1;
 for I := 0 to Length(ArrayClientClaster)-1 do
  begin
   if (ArrayClientClaster[i].InOutput=0) then
     begin
      step:=2;
      CurrentSrvClaster:=i;
      NextClient:=CurrentSrvClaster;
      ArrayClientClaster[NextClient].SocketHandle:=2; // на тот случай если при ошибке соединения еще не подключенного Connect надо чистить элемент массива
      ArrayClientClaster[NextClient].InOutput:=InOut; // сразу установить принадлежность к входящему или исходящему
      ArrayClientClaster[NextClient].CloseThread:=false;
      exist:=true;
      step:=3;
      break;
     end;
  end;
except
 On E: Exception do
 begin
 exist:=false;
 Write_Log('InClaster',2,'('+inttostr(step)+')Ошибка поиска свободного индекса массива '{+ E.ClassName+' / '+ E.Message});
 end;
end;
end;
step:=4;
if not exist  then
begin
step:=5;
setLength(ArrayClientClaster,Length(ArrayClientClaster)+1);
CurrentSrvClaster:=Length(ArrayClientClaster)-1;
NextClient:=CurrentSrvClaster;
ArrayClientClaster[NextClient].SocketHandle:=2; // на тот случай если при ошибке соединения еще не подключенного Connect надо чистить элемент массива
ArrayClientClaster[NextClient].InOutput:=InOut;
ArrayClientClaster[NextClient].CloseThread:=false;
exist:=true;
end;
step:=6;
//if InOut=1 then Write_Log('InClaster','Выдан индекс массива '+inttostr(NextClient)+' для входящего подключения')
//else Write_Log('InClaster','Выдан индекс массива '+inttostr(NextClient)+' для исходящего подключения');
result:= exist;
step:=7;
except
 On E: Exception do
 begin
 result:=false;
 Write_Log('InClaster',2,'('+inttostr(step)+') Ошибка выдачи индекса массива '{+ E.ClassName+' / '+ E.Message});
 end;
end;
end;


//-----------------------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
Write_Log('InClaster',0,'Ошибка входящего подключения "'+syserrormessage(ErrorCode)+'" клиента  '+ Socket.RemoteAddress+' с сервером кластера');
ErrorCode:=0;
FindArrayConnectBusy(Socket.SocketHandle,'',1); // сброс элемента массива входящего соединений в свободное сотояние
except
 On E: Exception do Write_Log('InClaster',2,'Client connect Error'{+' '+ E.ClassName+' / '+ E.Message});
end;
end;
//-------------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
try
Write_Log('InClaster',0,'Отключения входящего подключения '+ Socket.RemoteAddress+' от сервера кластера');
FindArrayConnectBusy(Socket.SocketHandle,'',1);  // сброс элемента массива входящего соединений в свободное сотояние
except
 On E: Exception do Write_Log('InClaster',2,'Client Disconnect'{+' '+ E.ClassName+' / '+ E.Message});
end;
end;


function TThread_RunInConnect.DecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
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
    Write_Log('InClaster',2,'('+inttostr(step)+') Ошибка дешифрации данных ');
     s:='';
    end;
  end;
end;


//-------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
  var
  NextClientClaster:integer;
  Buffer,BufferTmp,CryptBuf:string;
  TimeOutExit:integer;
function findConnect(ipStr:string):boolean; // поиск подключения
var
z:integer;
exist:boolean;
begin
exist:=false;
   if (ipStr<>'') then
   Begin
   for Z := 0 to length(ArrayClientClaster)-1 do
     Begin
      if (ArrayClientClaster[z].InOutput<>0) then  // если подключен   0-означает не подключен
      begin
       if ArrayClientClaster[z].StatusConnect=1 then // если статус соединения ок
        begin
         if (ArrayClientClaster[z].ServerAddress=ipStr) then // если подключен к IP из списка класеризации
          begin
          exist:=true; // данное соединение активно, и не важно входящее оно или исходящее
          break;
          end
         end;
       end;
     End;
   End  else exist:=false;
result:=exist;
end;

function SendCryptText(s:string):boolean; // отправка зашифрованного текста
var
CryptBuf:string;
begin
if Encryptstrs(s,PswdServerClaster, CryptBuf) then //шифруем перед отправкой
 begin
 while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do
 sleep(ProcessingSlack); //----------------------->
 result:=true;
 end
 else result:=false;
end;

begin
try
NextClientClaster:=99999999;

if Socket.RemoteAddress<>'' then
if AddFindBlackList(1,Socket.RemoteAddress) then //найти в черном списке
begin
Write_Log('InClaster',0,'Адрес '+Socket.RemoteAddress+' в черном списке');
CloseClientConnect(Socket.RemoteAddress); // закрываем соединение если блокировка в черном списке
exit;
end;


if SrvSocketClaster.Socket.ActiveConnections>=MaxNumInConnect then //отключаемся если превышено число разрешенных входящих подключений
  begin
  Write_Log('InClaster',0,'Входящее подключение клиента '+ Socket.RemoteAddress+'  к серверу закрыто из-за превышения числа разрешенных подключений '+inttostr(MaxNumInConnect));
  CloseClientConnect(Socket.RemoteAddress); // закрываем соединение с клиентом
  exit;
  end;

{if findConnect(Socket.RemoteAddress) then
 begin
  Write_Log('InClaster','Входящее подключение клиента '+ Socket.RemoteAddress+' закрыто. Соединение с сервером '+Socket.RemoteAddress+' уже существует ');
  CloseClientConnect(Socket.RemoteAddress); // закрываем соединение с клиентом
  exit;
  end; }

TimeOutExit:=0;
//Write_Log('InClaster','Входящее подключение клиента '+ Socket.RemoteAddress+'  к серверу');
WHILE socket.Connected DO    //<|PSWDSRV|>...<|ENDPSWD|>
BEGIN
try
sleep(ProcessingSlack);
TimeOutExit:=TimeOutExit+ProcessingSlack;
if TimeOutExit>1050 then // примерно 10 сек
  begin
  if Socket.RemoteAddress<>'' then AddFindBlackList(0,Socket.RemoteAddress); // добавить в черный список
  Write_Log('InClaster',0,'Входящее подключение клиента '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
  CloseClientConnect(Socket.RemoteAddress); // закрываем соединение с клиентом при ожидании более 10 сек
  break;
  end;
if socket.ReceiveLength<1 then continue;

 Buffer:=socket.ReceiveText;
 while not Buffer.Contains('<!!>') do // Ожидание конца пакета
  begin
  TimeOutExit:=TimeOutExit+ProcessingSlack;
  if TimeOutExit>TimeWaitPackage then
   begin
   TimeOutExit:=0;
   break;
   end;
   Sleep(2);
  if not Socket.Connected then break;
  if Socket.ReceiveLength < 1 then Continue;
  CryptBuf := Socket.ReceiveText;
  Buffer:=Buffer+CryptBuf;
  end;
  BufferTmp:=DecryptReciveText(Buffer,PswdServerClaster);

 if BufferTmp.Contains('<|PSWDSRV|>') then
begin
  if BufferTmp.Contains('<|ENDPSWD|>') then
   begin
    Delete(BufferTmp, 1, Pos('<|PSWDSRV|>', BufferTmp)+ 10);
  //-------------------------------
    if (copy(BufferTmp,1,Pos('<|ENDPSWD|>', BufferTmp)- 1))=PswdServerClaster then // проверяем пароль
     BEGIN   // если верный то создаем подключение
     if not SendCryptText('<|ACCESSAllOWED|>') then //шифрование текста----------------------------------------------------------------
      begin
      CloseClientConnect(Socket.RemoteAddress); // закрываем соединение с клиентом
      break;
      end;

        NextClientClaster:=99999999;
        if AddRecordClaster(NextClientClaster,1) then // получени индекса массива входящего соединения
          begin
            if SrvIpExternal='' then // если нет внешнего IP
             begin
             SrvIpExternal:=Socket.LocalAddress; // присваиваем
             AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer); // и создаем запись c префиксом т.к. при загрузке службы она не создалась
             end;
          ArrayClientClaster[NextClientClaster].SocketHandle:=Socket.SocketHandle;
          ArrayClientClaster[NextClientClaster].ServerAddress:=Socket.RemoteAddress;
          ArrayClientClaster[NextClientClaster].ServerPort:=Socket.LocalPort;
          ArrayClientClaster[NextClientClaster].InOutput:=1; // входящее подключение
          ArrayClientClaster[NextClientClaster].StatusConnect:=1; // установка статуса соединение установлено
          ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;// дата и время установки соединения

          TThreadConnection_Claster.Create(Socket,NextClientClaster);
          Write_Log('InClaster',0,'Входящее подключение клиента '+ Socket.RemoteAddress+' успешно создано');
          end;
       break;
      END
     else // иначе пароль не верный
     begin
       Write_Log('InClaster',1,'Клиент указал не верный пароль '+ Socket.RemoteAddress+' соединение  закрывается');
       SendCryptText('<|INCORRECTPSWD|>');
       CloseClientConnect(Socket.RemoteAddress);
       break;
     end;
   end;
end;
TimeOutExit:=TimeOutExit+ProcessingSlack; // если вдруг будет слать всякую дрянь в сокет то тоже считаем
except
 On E: Exception do
 begin
 if NextClientClaster<>99999999 then
  begin
  ArrayClientClaster[NextClientClaster].StatusConnect:=4; //  4-ошибка соединения
  ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;
  ClearArrayConnectBusy(NextClientClaster);
  end;
 Write_Log('InClaster',2,'(1) Ошибка Цикла обработки входящего подключение клиента SocketHandle-'+inttostr(Socket.SocketHandle)+' Индекс -'+inttostr(NextClientClaster)
+ ' '{+E.ClassName+': '+E.Message});
 CloseClientConnect(Socket.RemoteAddress);
 break;
 end;
end;
END;


except
 On E: Exception do
 begin
 if NextClientClaster<>99999999 then
  begin
  ArrayClientClaster[NextClientClaster].StatusConnect:=4; //  4-ошибка соединения
  ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;
  ClearArrayConnectBusy(NextClientClaster);  //очистка если ранее выдавался
  end;
 Write_Log('InClaster',2,'(2) Входящее подключение клиента SocketHandle-'+inttostr(Socket.SocketHandle)+' Индекс -'+inttostr(NextClientClaster)
+ ' '{+E.ClassName+': '+E.Message});
 end;
end;
end;
//------------------------------------------------
procedure TThread_RunInConnect.Execute;
var
i,z:integer;
SrvIP,SrvPswd:string;
SrvPort,NextClient:integer;
exist:boolean;
TimeOutThread,CountActivConnect:integer;
begin
try
SingRunInConnectionClaster:=true; // признак запушеного потока входящих соединений кластера
TimeOutThread:=0; // 1 минуты
if (ListServerClaster.Count<10) then
sleep(10000*ListServerClaster.Count)// ожидаем 10 сек на одно исходящее для установки исходящих
 else if ListServerClaster.Count>10 then sleep(100000); // иначе 100 сек
while SrvSocketClaster.Active do
  BEGIN
    try
    sleep(TimeOutThread); // ожидаем после итерации
    CountActivConnect:=0;
     for Z := 0 to length(ArrayClientClaster)-1 do
      if (ArrayClientClaster[z].InOutput=1) then  // любое входящее активное подключение,   0-означает не подключен
        begin
         inc(CountActivConnect); // подсчет количества подключений
         ArrayClientClaster[z].PrefixUpdate:=1; //любойе входящее активное подключение пусть обновляет списки префиксов
         sleep(2000);//ожидание для того чтобы поток данного подключения не конфликтовал с другим при доступе к глобальному массиву префиксов
        end;
    //---------------------------- установка интервала таймаута в зависимости от количества активных подключений в кластере
     {if CountActivConnect>3 then  TimeOutThread:=6000*CountActivConnect
     else} TimeOutThread:=25000;

     except on E : Exception do
       Write_Log('InClaster',2,'(1) TThreadRunOutConnect'{+E.ClassName+': '+E.Message});
    end;
   END;
 SingRunInConnectionClaster:=false; // признак запушеного потока входящих соединений кластера
//-----------------------
 except on E : Exception do
  begin
   SingRunInConnectionClaster:=false; // признак запушеного потока входящих соединений кластера
   Write_Log('InClaster',2,'(2) TThreadRunOutConnect'{E.ClassName+': '+E.Message});
  end;
end;
end;
//------------------------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // добавляем список полученных серверов в список ReciveListServerClaster
var
i,z:integer;
exist:boolean;
listTmp:TstringList;
begin
try
if ReciveListServerClaster.Count=0 then // если у меня список пустой
  begin
  ReciveListServerClaster.CommaText:=ReciveListSrv.CommaText; // доавляем все
  end
else  //иначе начинаем проверять
 Begin
 listTmp:=TstringList.Create;
 try
 for I := 0 to ReciveListSrv.Count-1 do  // ReciveListServerClaster
   begin
    exist:=false;
     for Z := 0 to ReciveListServerClaster.Count-1 do  //ReciveListSrv
      if ReciveListServerClaster[z]=ReciveListSrv[i] then
      begin
      exist:=true;
      break;
      end;
   if not exist then
   listTmp.Add(ReciveListSrv[i]);
   end;
 if listTmp.Count>0 then
  begin
  for I := 0 to listTmp.Count-1 do
   ReciveListServerClaster.Add(listTmp[i]);
  end;
 finally
 listTmp.Free;
 end;
 End;
result:=true;
except on E : Exception do
begin
result:=false;
Write_Log('InClaster',2,'(1) Ошибка AddReciveListServerClaster '{+E.ClassName+': '+E.Message});
end;
 end;
end;
//-------------------------------------------------------------
Function TThread_RunInConnect.TThreadConnection_Claster.MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // получаем список своих исходящих активных серверов в кластере, для передачи другому серверу
var                     ////172.16.1.2=3897=1234=;
i:integer;                 // IP      port  pswd
begin
try
SendListSrv.Clear; //ArrayClientClaster[IDindex].InOutput:=2;
for I := 0 to Length(ArrayClientClaster)-1 do
if ArrayClientClaster[i].InOutput=2 then // если исходящее то это мой список
if ArrayClientClaster[i].StatusConnect=1 then // если соединение активно
begin
if (ArrayClientClaster[i].ServerAddress<>'') and (ArrayClientClaster[i].ServerPort<>0) then
  begin
  if (ArrayClientClaster[i].ServerAddress<>CurrentConnectIP) then // если адрес из списка не равен текущему удаленному серверу, т.к. нахрена удаленому серверу свои реквизиты для подключения
  SendListSrv.Add(ArrayClientClaster[i].ServerAddress+'='+inttostr(ArrayClientClaster[i].ServerPort)+'='+ArrayClientClaster[i].ServerPassword+'=;')
  end;
end;

if SendListSrv.Count>0 then result:=true
else result:=false;

except on E : Exception do
begin
result:=false;
Write_Log('InClaster',2,'(1) MyListActivServerClaster'{+E.ClassName+': '+E.Message});
end;
 end;
end;
//--------------------------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //сравнение 2х списков префиксов, локального и принятого
var
i,z:integer;
exist:boolean;
begin
 for I := 0 to ListPrefixRecive.Count-1 do
 BEGIN
   exist:=false;
   for z := 0 to ListPrefixLocal.Count-1 do
   begin
     if ListPrefixRecive[i]=ListPrefixLocal[z] then
     begin
       exist:=true;
       break;
     end;
   end;
 if not exist then break;
 END;
 result:=exist;
end;
//---------------------------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.PrefixListToArray(ListPrefix:TstringList):boolean; // замена/добавление массива записей префиксов на полученые из ListPrefix
var
i,z,NexPrfx,CleanEl:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist:boolean;
function SeparationIpPortPswd(SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=123-58=дата
try                                            //  IP=port=pswd=prefix
SrvPort:=0; SrvIP:=''; SrvPswd:=''; SrvPrfx:='';DateCreate:='';
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
SrvPrfx:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
if TryStrToDateTime(copy(SepStr,1,pos('=;',SepStr)-1),TmpDateCreate) then DateCreate:=DateTimeTostr(TmpDateCreate) else DateCreate:='';
SepStr:='';
except on E : Exception do Write_Log('InClaster',2,'(1) Ошибка парсинга строки префиксов'{+E.ClassName+': '+E.Message});  end;
end;
begin
try
result:=false;
 for I := 0 to ListPrefix.Count-1 do
 BEGIN
 exist:=false;
 SeparationIpPortPswd(ListPrefix[i]);
 if (SrvIP<>'') and(SrvPort<>0) and (SrvPrfx<>'') then
  Begin
  for Z :=  0 to Length(ArrayPrefixSrv)-1 do
    Begin
     if SrvIP=ArrayPrefixSrv[z].SrvIp then  // если IP есть то обновляем данные для подключения
       begin
       ArrayPrefixSrv[z].SrvPort:=SrvPort;
       ArrayPrefixSrv[z].SrvPrefix:=SrvPrfx;
       ArrayPrefixSrv[z].SrvPswd:=SrvPswd;
       if DateCreate<>'' then ArrayPrefixSrv[z].DateCreate:=DateCreate;
       exist:=true;
       break;
       end
     else exist:=false;
     if ArrayPrefixSrv[z].SrvIp='' then  CleanEl:=z;  // находим свободный элемент массива
   End;
  if not exist then // если записи нет то добавляем новую
   begin
    if CleanEl<>0 then NexPrfx:= CleanEl  // если нашли свободный индекс массива
     else AddArrayPrefix(NexPrfx); // иначе получаем новый
    ArrayPrefixSrv[NexPrfx].SrvIp:=SrvIP;
    ArrayPrefixSrv[NexPrfx].SrvPort:=SrvPort;
    ArrayPrefixSrv[NexPrfx].SrvPrefix:=SrvPrfx;
    ArrayPrefixSrv[NexPrfx].SrvPswd:=SrvPswd;
    if DateCreate<>'' then ArrayPrefixSrv[NexPrfx].DateCreate:=DateCreate
    else  ArrayPrefixSrv[NexPrfx].DateCreate:=DateTimeToStr(TTimeZone.local.ToUniversalTime(now));
   end;
  End;
END;
result:=true;
except on E : Exception do Write_Log('InClaster',2,'Ошибка парсинга массива префиксов '{+E.ClassName+': '+E.Message});  end;
end;
//-----------------------------------------------------------------

function  TThread_RunInConnect.TThreadConnection_Claster.ParsingListPrefix(var NewListPrefix:TstringList):boolean; //поиск своего IP/замена/добавлеие в списке префиксов
var               //SrvIpExternal     если нет замены или вставки то результат False
i,z:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist,repl:boolean;
tmpPrefix:string;
function SeparationIpPortPswd(SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=123-58=Дата
try                                            //  IP=port=pswd=prefix
SrvPort:=0; SrvIP:=''; SrvPswd:=''; SrvPrfx:='';
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
SrvPrfx:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
if TryStrToDateTime(copy(SepStr,1,pos('=;',SepStr)-1),TmpDateCreate) then DateCreate:=DateTimeTostr(TmpDateCreate) else DateCreate:='';
SepStr:='';
except on E : Exception do Write_Log('InClaster',2,'(2) Ошибка парсинга строки префиксов  '{+E.ClassName+': '+E.Message});  end;
end;
begin
try
repl:=false;
PrefixListToArray(NewListPrefix); //без обновления даты и времени сразу добавляем/обновляем в массив префиксов для последующей работы с ним.
for I := 0 to NewListPrefix.Count-1 do // Наша задача проверить только свою запись в списке NewListPrefix  а соответственно  в массиве
  Begin
   exist:=false;
   SeparationIpPortPswd(NewListPrefix[i]); // парсим строку списка
   if (SrvIP=SrvIpExternal) and (PortServerViewer=SrvPort) and (PrefixServer=SrvPrfx) and (SrvPswd=PswdServerViewer) then // если я есть в списе серверов и все ОК
    begin   // если все совпадает то все ок и делть со списком префиксов ничего не надо, просто обновляем дату
    NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now));
    AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);//обновляем элемент массива с измененной записью своего сервера, обновление даты и врмени
    exist:=true; // нашли свою запись
    repl:=false; // говорим что данные не менялись
    break;
    end
   else
    if (SrvIP=SrvIpExternal) then // иначе если есть IP но другие параметры изменились, надо обновить
     begin
      PrefixServer:= GeneratePrefixServr(PrefixServer,SrvIpExternal);  // проверяем наш префикс на совпадение с префиксами из обновленного массива
      NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)); // изменяем в списке нашу запись
      AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// обновляем элемент массива с измененной записью своего сервера, обновление даты и врмени
      exist:=true;   // нашли свою запись
      repl:=true;  // говорим что данные изменились
      break;
     end;
  End;
 if not exist then  // если не нашли себя в списке, значит надо добавить
  begin             // но перед этим надо сравнить префиксы из списка со своим
    TmpPrefix:=PrefixServer;
    PrefixServer:= GeneratePrefixServr(TmpPrefix,SrvIpExternal);  // проверяем наш префикс на совпадение с префиксами из массива
    NewListPrefix.Add(SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)));// добавляем запись в список
    AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// добавляем элемент массива с измененной записью своего сервера, обновление даты и врмени
    repl:=true; // говорим что данные изменились
    TmpPrefix:='';
  end;
result:=repl;// если свою запись не обновляли то результат false/ соответственно этот список отправлять не надо
except on E : Exception do
  begin
   result:=false;
   Write_Log('InClaster',2,'Ошибка парсинга списка строк префиксов  : '{+E.ClassName+': '+E.Message});
  end;
  end;
end;

//----------------------------------------------------------------------
Function TThread_RunInConnect.TThreadConnection_Claster.PrefixArrayToList(Var ListPrefix:TstringList):boolean; // Перевод всего массива в ListString
var
i:integer;
PrefixDateTime:TdateTime;
begin
try
 ListPrefix.Clear;
 for I := 0 to length(ArrayPrefixSrv)-1 do
   begin
  //----------------------------проверка времени создания записей и удаление если старая
   if ArrayPrefixSrv[i].SrvIp<>SrvIpExternal then // если в массиве не моя запись
   begin
   if TryStrtoDateTime(ArrayPrefixSrv[i].DateCreate,PrefixDateTime)then  // пробуем перевести запись в дату и время
     begin
     if (MinutesBetween(TTimeZone.local.ToUniversalTime(now),PrefixDateTime))>PrefixLifeTime then // если прошло больше ReCreateRecPrefix минут после последнего обновления
      begin                               // чистим элемент массива
      ArrayPrefixSrv[i].DateCreate:='';
      ArrayPrefixSrv[i].SrvPrefix:='';
      ArrayPrefixSrv[i].SrvPort:=0;
      ArrayPrefixSrv[i].SrvIp:='';
      ArrayPrefixSrv[i].SrvPswd:='';
      end;
     end;
   end;
//----------------------------------------------------------------------
   if (ArrayPrefixSrv[i].SrvIp<>'') and (ArrayPrefixSrv[i].SrvPort<>0) then
    begin
    ListPrefix.Add(ArrayPrefixSrv[i].SrvIp+'='+inttostr(ArrayPrefixSrv[i].SrvPort)+'='+ArrayPrefixSrv[i].SrvPswd+'='+ArrayPrefixSrv[i].SrvPrefix+'='+ArrayPrefixSrv[i].DateCreate+'=;');
    end;
   end; //  цикл по массиву
result:=true;
except on E : Exception do
  begin
   Write_Log('InClaster',2,'PrefixArrayToList  : '{+E.ClassName+': '+E.Message});
   result:=false;
  end;
end;
end;
//------------------------------------------------------------------------------

function TThread_RunInConnect.TThreadConnection_Claster.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
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
  Write_Log('InClaster',2,'Decryptstrs '+E.ClassName+' / '+E.Message);
  result:=false;
  OutStr:='';
  end;
end;
end;

function TThread_RunInConnect.TThreadConnection_Claster.Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
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
   Write_Log('InClaster',2,'Encryptstrs '+E.ClassName+' / '+E.Message);
  result:=false;
  OutStr:='';
  end;
end;
end;


//--------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // функция записи в лог для для потока
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
         while f.Count>1000 do f.Delete(0);;
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  End;
  except
    exit;
  end;
end;
//---------------------------- поток обработки входящих соединений с сервером кластера
function TThread_RunInConnect.TThreadConnection_Claster.SendMainSock(s:string):boolean; // функция отправки через сокет управления
 begin
 if (TmpSocket <> nil) and (TmpSocket.Connected) then
   begin
     try
       begin
       while TmpSocket.SendText(s) < 0 do Sleep(ProcessingSlack);
       result:=true;
       end;
       except On E: Exception do
        begin
        result:=false;
        Write_Log('InClaster',2,'Внешняя функция отправки');
        end;
     end;
   end
      else result:=false;
 end;
//---------------------------------------------------------------------------------
procedure TThread_RunInConnect.TThreadConnection_Claster.Execute;
var
i,slepengtime:integer;
Buffer,BufferTemp,CryptText,CryptBufTemp:string;
ipAddSrv:string;
TmpPswd:string;
FindTrgID:string;
FindTrgtPswd:string;
ListTemp,ListTmpLocal:tstringlist;
step:integer;
resClearArray:boolean;
FLibrary : TCryptographicLibrary;
EnDeCrypt : TCodec;
L:integer;

function ActiveCountPefix:integer;
var
z:integer;
countActiv:integer;
begin
countActiv:=0;
for z := 0 to length(ArrayPrefixSrv)-1 do
begin
  if ArrayPrefixSrv[z].SrvIp<>'' then
   countActiv:=countActiv+1;
end;
result:=countActiv;
end;

//-----------------------------------------------------------------------------------

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
    Write_Log('InClaster',2,'('+inttostr(step)+') Дешифрация данных ');
     s:='';
    end;
  end;
end;
//-----------------------------------------------------------------------------------

//------------------------------------------------------------------------------------
 function SendMainCryptText(s:string):boolean; // отправка зашифрованного текста в main сокет
 var
 Scrypt:string;
  begin
   if Encryptstrs(s,TmpPswd,Scrypt) then //шифруем перед отправкой
    begin
    result:=SendMainSock('<!>'+Scrypt+'<!!>')
    end
    else
    begin
    result:=false;
    Write_Log('InClaster',2,'No Encryptstrs and send');
    end;
  end;
//--------------------------------------------

begin
try
TmpPswd:=PswdServerClaster; // пароль для шифрования
sleep(1000); // активация потока чуть позже установки соединения
 if (TmpSocket=nil) or (not TmpSocket.Connected) then // проверка
  begin
  Write_Log('InClaster',1,'Завершение потока не установленного соединения обработки входящего подключения');
  exit;
  end;
step:=1;
resClearArray:=false;
ipAddSrv:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDIndex].ServerAddress:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDIndex].ServerPort:=TmpSocket.LocalPort;
ArrayClientClaster[IDIndex].SocketHandle:=TmpSocket.SocketHandle;
ArrayClientClaster[IDIndex].InOutput:=1; // входящее
step:=2;
//--------------------------
ListTemp:=TstringList.Create;
try
if PrefixArrayToList(ListTemp) then  // перевод массива префиксов в список
SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // отправка списка префиксов
finally
ListTemp.Free;
end;
step:=3;
sleep(1000);
//------------------------------------------
//Write_Log('InClaster '+ipAddSrv,'Запущен поток обработки входящего подключения ServerAddress: '+ArrayClientClaster[IDIndex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDIndex].ServerPort));
slepengtime:=0;
while TmpSocket.Connected do
 BEGIN
 try
 sleep(ProcessingSlack);
 step:=4;
 if (TmpSocket=nil) or (not TmpSocket.Connected) then  break;
 if ArrayClientClaster[IDindex].CloseThread then break;
 step:=5;
 //---------------------------------------------------- если таймер поменял значение на запрос обновления префиксов
   if ArrayClientClaster[IDIndex].PrefixUpdate=1 then
    begin
    step:=6;
    //----------------------------------
     ListTemp:=TstringList.Create;
    try
    PrefixArrayToList(ListTemp); // перевод массива префиксов в список
    SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //отравка списка префиксов
   // Write_Log('InClaster '+ipAddSrv,'Отправка данных '+TmpSocket.RemoteAddress+' '+'<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>' );
    step:=7;
      finally
      ArrayClientClaster[IDIndex].PrefixUpdate:=0; // установка в 0 чтобы не зациклится
      ListTemp.Free;
      end;
    step:=8;
     //-----------------------------------
     if SendListServers then // делится списком адресов кластера
      begin
       ListTemp:=TstringList.Create;
       try
        if MyListActivServerClaster(ListTemp,ArrayClientClaster[IDindex].ServerAddress) then // получаем список своих исходящих активных серверов кластера
         begin
         SendMainCryptText('<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>');  //отравка своего списка активных серверов для кластеризации
        // Write_Log('InClaster '+ipAddSrv,'Отправка данных '+TmpSocket.RemoteAddress+' '+'<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>' );
         end;
       finally
       ListTemp.Free;
       end;
      end;
      //----------------------------------
    end;
 //---------------------------------------------------------
  step:=9;
 if TmpSocket.ReceiveLength<1 then continue;
 step:=10;
  CryptText:=TmpSocket.ReceiveText;
  //Write_Log('InClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - Чтение данных в сокете Crypt: '+CryptText);
  while not CryptText.Contains('<!!>') do // Ожидание конца пакета
   begin
    slepengtime:=slepengtime+2;
    if slepengtime>TimeWaitPackage then
     begin
     slepengtime:=0;
     break;
     end;
   Sleep(2);
   if not TmpSocket.Connected then break;
   if TmpSocket.ReceiveLength < 1 then Continue;
   CryptBufTemp := TmpSocket.ReceiveText;
   CryptText:=CryptText+CryptBufTemp;
   end;
   slepengtime:=0;
   Buffer:=DecryptReciveText(CryptText);
   //Write_Log('InClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - Чтение данных в сокете Decrypt: '+Buffer);
 step:=11;
 // Write_Log('InClaster '+ipAddSrv,TmpSocket.RemoteAddress+' - Чтение данных в сокете : '+Buffer);
 step:=12;
   if Buffer.Contains('<|PONG|>') then //получили ответ на ping
    begin
      ArrayClientClaster[IDIndex].PingEnd :=(GetTickCount - ArrayClientClaster[IDIndex].PingStart) div 2; //GetTickCount Считывает вpемя, пpошедшее с момента запуска системы.
      ArrayClientClaster[IDIndex].PingAnswer:=false;
    end;
step:=13;
//------------------------------------------ // список серверов
   if Buffer.Contains('<|SRVLST|>') then  // получили список серверов
    if GetListServers then
     BEGIN     //<|SRVLST|>text<|ENDLST|>
      BufferTemp:=Buffer;
     if BufferTemp.Contains('<|ENDLST|>') then
       begin
        delete(BufferTemp,1,pos('<|SRVLST|>',BufferTemp)+9);
        ListTemp:=TstringList.Create;
        try
        ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDLST|>',BufferTemp)-1); // скопировали строку с серверами
        //Write_Log('InClaster '+ipAddSrv,'Получен список серверов - '+ListTemp.CommaText);
        AddReciveListServerClaster(ListTemp);
        finally
        ListTemp.Free;
        end;
       end;
     END;
//---------------------------------------  // префиксы
   if Buffer.Contains('<|PRFX|>') then  // получили список префиксов
     begin     //<|PRFX|>Text<|ENDPRFX|>
     BufferTemp:=Buffer;
      if BufferTemp.Contains('<|ENDPRFX|>') then
       Begin
       delete(BufferTemp,1,pos('<|PRFX|>',BufferTemp)+7);
       ListTemp:=TstringList.Create;
       ListTmpLocal:=TstringList.Create;
  step:=14;
         try
         ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDPRFX|>',BufferTemp)-1);// добавили списо префиксов
         //Write_Log('InClaster '+ipAddSrv,'ActiveCountPefix='+inttostr(ActiveCountPefix)+' length(ArrayPrefixSrv)='+inttostr(length(ArrayPrefixSrv)));
         if (ListTemp.Count)<ActiveCountPefix then // если отправленный список префиксов меньше чем у меня, то пусть проверит сначала сам.
           begin
           //ListTemp.Clear;
           //if PrefixArrayToList(ListTemp) then  // перевод массива префиксов
          // SendMainSocket('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // отправка списка префиксов
    step:=15;
           end
         else  // иначе списки префиксов либо равны либо у меня меньше
           begin
            ParsingListPrefix(ListTemp);
           // if ParsingListPrefix(ListTemp) then // если вносили свои изменения (свой IP PSWD port и так далее) в список с префиксами
            // SendMainSocket('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');// отправляем список префиксов обратно
              // если свои изменения не внесли то все ок со списком префиксов
    step:=16;
           end;
         finally
         ListTemp.Free;
         end;
       End;
step:=17;
     end;
  //---------------------
  except
    On E: Exception do
    begin
    Write_Log('InClaster',2,'(1) ('+inttostr(step)+') Обработка входящего соединения ServerAddress: '+ipAddSrv{+' '+ E.ClassName+' / '+ E.Message});
    break;
    end;
  end;
  //---------------------
//--------------------------------------------------------
 END;
step:=18;
//------------------------------------------------------

//Write_Log('InClaster '+ipAddSrv,'Завершение потока обработки входящего подключения ServerAddress: '+ArrayClientClaster[IDIndex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDIndex].ServerPort));
ArrayClientClaster[IDIndex].ServerAddress:='';
ArrayClientClaster[IDIndex].InOutput:=0;
ArrayClientClaster[IDIndex].SocketHandle:=0;
ArrayClientClaster[IDIndex].ServerPort:=0;
ArrayClientClaster[IDIndex].PrefixUpdate:=0;
ArrayClientClaster[IDIndex].ServerPassword:='';
ArrayClientClaster[IDIndex].CloseThread:=false;
if TmpSocket.Connected then  TmpSocket.Close;
// удаление объекта дял шифрования и дешифрации

except
    On E: Exception do
    begin
      ArrayClientClaster[IDIndex].ServerAddress:='';
      ArrayClientClaster[IDIndex].InOutput:=0;
      ArrayClientClaster[IDIndex].SocketHandle:=0;
      ArrayClientClaster[IDIndex].ServerPort:=0;
      ArrayClientClaster[IDIndex].PrefixUpdate:=0;
      ArrayClientClaster[IDIndex].ServerPassword:='';
      ArrayClientClaster[IDIndex].CloseThread:=false;
      Write_Log('InClaster',2,'(2) ('+inttostr(step)+') Обработка входящего соединения ServerAddress: '+ipAddSrv{+' '+ E.ClassName+' / '+ E.Message});
    end;
  end;

end;

end.
