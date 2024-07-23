unit RunOutConnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,VCL.Forms,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,DateUtils,uTPLb_CryptographicLibrary, uTPLb_Codec;

type    // структура для входящих/исходящих соединений кластера
 TserverClst = record
  // MainSocket:TCustomWinSocket;
   SocketHandle:UIntPtr;
   ServerAddress:string[255];
   ServerPort:integer;
   ServerPassword:string[255];
   PingStart: Int64;
   PingEnd: Int64;
   MyPing:int64;
   PingAnswer:boolean;
   InOutput:byte; // признак исходящего соединения
   IDConnect:byte;  //id номера массива
   PrefixUpdate:byte; // 1 - отправить запрос на проверку
   StatusConnect:byte; // статус соединения
   DateTimeStatus:TdateTime; // дата и время установки StatusConnect
 end;





    type
     TConnectClientSocket= class (TClientSocket) // создание клиента исходящих соединений кластера
      private
         ClientSckt: TClientSocket;
         srvIp:string;
         srvPort:integer;
         srvPswd:string;
         IndexArray:integer; // индекс массива для потока при создании подключения

       public
         constructor Create(AsrvIp:string;AsrvPort:integer; AsrvPswd:string; aIndexArray:integer); overload;
         procedure ClientClaster_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket); //исходящее
         procedure ClientClaster_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer); //исходящее
         procedure ClientClaster_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);// в процедуре создается поток TThreadClient_Claster
         function DecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
         function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
         Function FindArrayConnect(IpAddress:string; port:integer; InOut:byte; var FindIndex:integer):boolean; // поиск необходимого индекса элемента массива для исходящего соединения
         function ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента


     type // поток обработки исходящих соединений для кластера
     TThreadClient_Claster = class(TThread)
      private
        TmpSocket:TCustomWinSocket;
        IDindex:integer; // индекс массива для потока при создании исходящего подключения
      public
        constructor Create(aSocket: TCustomWinSocket; aIDConnect:integer ; InOut:byte); overload;
        procedure Execute; override; // процедура выполнения потока
        function SendMainSock(s:string):boolean; // функция отправки через сокет управления
        function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
        Function PrefixArrayToList(Var ListPrefix:TstringList):boolean; //   перевод масссива префиксов в строку
        function ParsingListPrefix(var NewListPrefix:TstringList):boolean; //поиск своего IP/замена/добавлеие в списке префиксов
        function PrefixListToArray(ListPrefix:TstringList):boolean; // замена/добавление массива записей префиксов на полученые из ListPrefix
        function ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //сравнение 2х списков префиксов, локального и принятого
        Function MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // получаем список своих исходящих активных серверов в кластере, для передачи другому серверу
        function AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // добавляем список полученных серверов в список ReciveListServerClaster
        function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
        function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
      end;
     end;

type //поток проверка списка и установка соединений кластеризации
  TThread_FindAndRunConnection = class (TThread)
    private
      EditListIP:boolean;
      ListClaserIP:TstringList;
      StatusWorkThread:boolean;
    public
      constructor Create(aListClaserIP:TstringList); overload;
      procedure Execute; override; // процедура выполнения потока
      function AddRecordClaster(var NextClient:integer; InOut:byte):boolean; // выделяет индекс массива для подключения
      function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
      function AddEditListClasterIP(ipAddress:string;EditField:byte;InData:string):boolean;
      function ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента
      Function ComparisonListClaster:boolean; //сравнение списков серверов для кластеризации, локального и полученного от других серверов
 end;





implementation
uses MainModule,FunctionPrefixServer,SocketCrypt;

//--создание потока для проверки списков соединений в кластере
constructor TThread_FindAndRunConnection.Create(aListClaserIP:TstringList);
begin        //
  inherited Create(False);
  ListClaserIP:=TstringList.Create;
  ListClaserIP.CommaText:=aListClaserIP.CommaText;
  StatusWorkThread:=true;
  FreeOnTerminate := true;
end;

// создание потока для обработки исходящих подключений кластера
constructor TConnectClientSocket.TThreadClient_Claster.Create(aSocket: TCustomWinSocket; aIDConnect:integer; InOut:byte);
begin        //
  inherited Create(False);
  TmpSocket:=aSocket;
  IDindex:=aIDConnect;
end;
//--------------------------------------
constructor TConnectClientSocket.Create(AsrvIp:string;AsrvPort:integer; AsrvPswd:string; aIndexArray:integer);
begin        //
try
srvIp:=AsrvIp;
srvPort:=AsrvPort;
srvPswd:=AsrvPswd;
IndexArray:=aIndexArray;
ClientSckt:=TClientSocket.Create(self);
ClientSckt.Active := False;
ClientSckt.ClientType :=ctBlocking; //ctBlocking;  ctNonBlocking
ClientSckt.OnConnect := ClientClaster_SocketConnect;
ClientSckt.OnDisconnect := ClientClaster_SocketDisconnect;
ClientSckt.OnError := ClientClaster_SocketError;
ClientSckt.Host:=srvIp;
ClientSckt.Port:=srvPort;
ClientSckt.Tag:=IndexArray;
ClientSckt.Active:=true;
//Write_Log('OutClaster','Настройка создания исходящего подключения '+SrvIP+' индекс '+inttostr(IndexArray)+' завершена ');
except On E: Exception do
 begin
 ArrayClientClaster[IndexArray].StatusConnect:=4; //если произошла ошибка на уровне создания подключения
 ArrayClientClaster[IndexArray].DateTimeStatus:=now;
 ClearArrayConnectBusy(IndexArray);
 Write_Log('OutClaster',2,'Создание исходящего подключения '+SrvIP+' ConnectClientSocket.Create'{+ E.ClassName+' / '+ E.Message});
 end;
end;
end;
//---------------------------------------------------------
function TConnectClientSocket.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
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
//---------------------------------------------

function TConnectClientSocket.ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента
begin
try
result:=false;
   if indexArray<=length(ArrayClientClaster)-1 then
   if (ArrayClientClaster[indexArray].StatusConnect=1)or(ArrayClientClaster[indexArray].StatusConnect=0) then
   begin//очистка только если соединение ранее было установлено или вообще не пыталось установится
  // Write_Log('OutClaster',' ClearArrayConnectBusy начало очистки массива с indexArray='+inttostr(indexArray));
   ArrayClientClaster[indexArray].ServerAddress:='';
   ArrayClientClaster[indexArray].Serverport:=0;
   ArrayClientClaster[indexArray].ServerPassword:='';
   ArrayClientClaster[indexArray].SocketHandle:=0;
   ArrayClientClaster[indexArray].InOutput:=0;
   ArrayClientClaster[indexArray].IDConnect:=0;
   ArrayClientClaster[indexArray].PrefixUpdate:=0;
   ArrayClientClaster[indexArray].StatusConnect:=0;
   ArrayClientClaster[indexArray].DateTimeStatus:=now;
   ArrayClientClaster[indexArray].CloseThread:=false;
   // Write_Log('OutClaster',' ClearArrayConnectBusy завершена очистка массива с indexArray='+inttostr(indexArray));
   end;
   result:=true;
except
    On E: Exception do Write_Log('OutClaster',2,'ClearArrayConnectBusy index='+inttostr(indexArray){+' '+ E.ClassName+' / '+ E.Message});
    end;
 end;
//--------------------------------------------------
Function TConnectClientSocket.FindArrayConnect(IpAddress:string; port:integer; InOut:byte; var FindIndex:integer):boolean; // поиск необходимого индекса элемента массива для исходящего соединения
var
i:integer;
begin
try
//Write_Log('OutClaster','FindArrayConnect поиск элемента массива исходящего соединения '+IpAddress+' '+inttostr(port));
result:=false;
for I := 0 to Length(ArrayClientClaster)-1 do
begin
 if (ArrayClientClaster[i].InOutput=InOut) then
   if (ArrayClientClaster[i].ServerAddress=IpAddress)  and (ArrayClientClaster[i].ServerPort=port) then
   begin
     //Write_Log('OutClaster','FindArrayConnect нашли элемента массива исходящего соединения index '+inttostr(i)+' '+ArrayClientClaster[i].ServerAddress+' '+inttostr(ArrayClientClaster[i].ServerPort));
     FindIndex:=i;
     result:=true;
     break;
   end;
end;
except
    On E: Exception do
    begin
     result:=false;
     Write_Log('OutClaster',2,'FindArrayConnect '{+ E.ClassName+' / '+ E.Message});
    end;
  end;
end;
//--------------------------------


function TThread_FindAndRunConnection.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
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
//----------------------------------------------------------------------------

function TConnectClientSocket.DecryptReciveText(s,pswd:string):string; // функция расщифровки полученого текста из сокета
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
//----------------------------------------------------------------------------
procedure TConnectClientSocket.ClientClaster_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);//исходящее
var
stp:integer;
res:boolean;
TimeOutExit:integer;
Buffer,BufferTmp,CryptBuf :string;
PswdSrv:string;

function SendCryptText(s:string):boolean; // отправка зашифрованного текста
var
CryptBuf:string;
begin
if Encryptstrs(s,PswdSrv, CryptBuf) then //шифруем перед отправкой
 begin
 while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do
 sleep(ProcessingSlack); //----------------------->
 result:=true;
 end
 else result:=false;
end;

begin
try
TimeOutExit:=0;
PswdSrv:=ArrayClientClaster[IndexArray].Serverpassword;
SendCryptText('<|PSWDSRV|>'+PswdSrv+'<|ENDPSWD|>');
WHILE socket.Connected DO    //<|PSWDSRV|>...<|ENDPSWD|>
BEGIN
try
sleep(ProcessingSlack);
TimeOutExit:=TimeOutExit+ProcessingSlack;
if TimeOutExit>1350 then // примерно 10 сек
  begin
  Write_Log('OutClaster',0,'Исходящее подключение к серверу '+ Socket.RemoteAddress+' закрывавется из-за неактивности');
  ArrayClientClaster[IndexArray].StatusConnect:=2; // сервер молчит на запрос
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  Socket.Close;// если не авторизовались в течении 1 минуты то закрываем сокет
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
  BufferTmp:=DecryptReciveText(Buffer,PswdSrv);

 if BufferTmp.Contains('<|INCORRECTPSWD|>') then
  begin
  ArrayClientClaster[IndexArray].StatusConnect:=3; // я указал не верны пароль для подключения
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  Write_Log('OutClaster',0,'Исходящее подключение  к серверу '+Socket.RemoteAddress+' закрыто из-за неверного пароля ');
  socket.Close;
  break;
  end;
if BufferTmp.Contains('<|ACCESSAllOWED|>') then
  BEGIN
   if SrvIpExternal='' then // если нет внешнего IP   . это соединение первое
    begin
    SrvIpExternal:=Socket.LocalAddress;
    res:=AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer); // и создаем запись  в массиве префиксов      stp:=4;
    end;
   TThreadClient_Claster.Create(Socket,IndexArray,2); // передача текущего сокета в поток , индекса массива, признак исходящего подключения
   ArrayClientClaster[IndexArray].StatusConnect:=1; // соединение установлено
   Write_Log('OutClaster',0,'Исходящее подключение к серверу '+ Socket.RemoteAddress+', успешно создано');
   break;
  END;
except on E : Exception do
  begin
  if ArrayClientClaster[IndexArray].StatusConnect<>1 then ArrayClientClaster[IndexArray].StatusConnect:=4; // неизвестная ошибка при установке соединения
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  ClearArrayConnectBusy(IndexArray); // очистка элемента массива
   Write_Log('OutClaster',2,'('+inttostr(stp)+') (1) Обработка подключения к серверу '+Socket.RemoteAddress+' SocketHandle-'+inttostr(Socket.SocketHandle)+' Индекс ArrayConnect-'+inttostr(IndexArray));
   Socket.Close;
   break;
  end;
end;
END;


except on E : Exception do
  begin
  if ArrayClientClaster[IndexArray].StatusConnect<>1 then ArrayClientClaster[IndexArray].StatusConnect:=4; // неизвестная ошибка при установке соединения
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  ClearArrayConnectBusy(IndexArray); // очистка элемента массива
   Write_Log('OutClaster',2,'('+inttostr(stp)+') (2) Обработка подключения к серверу SocketHandle-'+inttostr(Socket.SocketHandle)+' Индекс ArrayConnect-'+inttostr(IndexArray));
  end;
  end;
end;

procedure TConnectClientSocket.ClientClaster_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer); //исходящее
var
Msg: TMsg;
begin
try
Write_Log('OutClaster',0,'Ошибка соединения "'+syserrormessage(ErrorCode)+'" с сервером '+ Socket.RemoteAddress);
ErrorCode := 0;
if ArrayClientClaster[IndexArray].StatusConnect=0 then ArrayClientClaster[IndexArray].StatusConnect:=4;  // если соединения не было установлено
ClearArrayConnectBusy(IndexArray); // очистка элемента массива
except on E : Exception do
 begin
   Write_Log('OutClaster',2,'ClientClaster_SocketError ');
 end;
  end;
end;

procedure TConnectClientSocket.ClientClaster_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket); //исходящее
var
Msg: TMsg;
begin
try
  Write_Log('OutClaster',0,'Отключения исходящего подключения '+ Socket.RemoteAddress);
  if ArrayClientClaster[IndexArray].StatusConnect=0 then ArrayClientClaster[IndexArray].StatusConnect:=4;  // если соединения не было установлено
  ClearArrayConnectBusy(IndexArray); // очистка элемента массива
  except on E : Exception do
   Write_Log('OutClaster',2,'ClientClaster_SocketDisconnect ');
  end;
end;


//--------------------------------------------
function TThread_FindAndRunConnection.AddRecordClaster(var NextClient:integer; InOut:byte):boolean;
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
   // Write_Log('OutClaster',inttostr(step)+'Поиск индекса массива. Текущий Index='+inttostr(i)+' IP='+ArrayClientClaster[i].ServerAddress+' InOutput='+inttostr(ArrayClientClaster[i].InOutput));
   if (ArrayClientClaster[i].InOutput=0)and(ArrayClientClaster[i].ServerAddress='') then
     begin
      step:=2;
      CurrentSrvClaster:=i;
      NextClient:=CurrentSrvClaster;
      ArrayClientClaster[i].SocketHandle:=2; // на тот случай если при ошибке соединения еще не подключенного Connect надо чистить элемент массива
      ArrayClientClaster[i].InOutput:=InOut; // сразу установить принадлежность к входящему или исходящему
      ArrayClientClaster[i].DateTimeStatus:=now;
      ArrayClientClaster[i].CloseThread:=false;
      exist:=true;
      step:=3;
      break;
     end;
  end;
except
 On E: Exception do
 begin
 exist:=false;
 Write_Log('OutClaster',2,'('+inttostr(step)+') Поиск свободного индекса массива ');
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
ArrayClientClaster[NextClient].DateTimeStatus:=now;
ArrayClientClaster[NextClient].CloseThread:=false;
exist:=true;
end;
step:=6;
//if InOut=1 then Write_Log('OutClaster','Выдан индекс массива '+inttostr(NextClient)+' для входящего подключения')
//else Write_Log('OutClaster','Выдан индекс массива '+inttostr(NextClient)+' для исходящего подключения');
result:= exist;
step:=7;
except
 On E: Exception do
 begin
 result:=false;
 Write_Log('OutClaster',2,'('+inttostr(step)+') Выдача индекса массива ');
 end;
end;
end;
//----------------------------------------
 function TThread_FindAndRunConnection.AddEditListClasterIP(ipAddress:string;EditField:byte;InData:string):boolean; // редактирование списка ip адресов для исходящих соединений
 var
 i,SrvPort:integer;
 SrvIP,SrvPswd:string;
function SeparationIpPortPswd(SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do Write_Log('OutClaster',2,'(1) Парсинг реквизитов подключения ');  end;
end;
 begin

 end;
//--------------------------------------------------

function TThread_FindAndRunConnection.ClearArrayConnectBusy(indexArray:integer):boolean; // очистка элемента массива и изменение статуса занятости этого элемента
begin
try
result:=false;
if indexArray<=length(ArrayClientClaster)-1 then
 begin
   //Write_Log('OutClaster',' ClearArrayConnectBusy начало очистки массива с indexArray='+inttostr(indexArray));
   ArrayClientClaster[indexArray].ServerAddress:='';
   ArrayClientClaster[indexArray].Serverport:=0;
   ArrayClientClaster[indexArray].ServerPassword:='';
   ArrayClientClaster[indexArray].SocketHandle:=0;
   ArrayClientClaster[indexArray].InOutput:=0;
   ArrayClientClaster[indexArray].IDConnect:=0;
   ArrayClientClaster[indexArray].PrefixUpdate:=0;
   ArrayClientClaster[indexArray].StatusConnect:=0;
   ArrayClientClaster[indexArray].DateTimeStatus:=now;
   ArrayClientClaster[indexArray].CloseThread:=false;
   //Write_Log('OutClaster',' ClearArrayConnectBusy завершена очистка массива с indexArray='+inttostr(indexArray));
   result:=true;
 end;
except
    On E: Exception do Write_Log('OutClaster',2,'ClearArrayConnectBusy  index='+inttostr(indexArray));
    end;
 end;
//-------------------------------------
Function TThread_FindAndRunConnection.ComparisonListClaster:boolean; //сравнение списков серверов для кластеризации, локального и полученного от других серверов
 var
 i,z,y,x:integer;
 exist,BreakExist:boolean;
 SrvIP,SrvPswd:string;
SrvPort:integer;
 function SeparationIpPortPswd(SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
result:=true;

except on E : Exception do
begin
result:=false;
Write_Log('OutClaster',2,'(2) Парсинг реквизитов подключения ');  end;
end;
end;
 begin //ReciveListServerClaster - полученный список серверов  ListServerClaster - локальнй список
try
 //Write_Log('OutClaster','ReciveListServerClaster - '+ReciveListServerClaster.CommaText);
 for Z := 0 to ReciveListServerClaster.Count-1 do
  BEGIN
   if not SeparationIpPortPswd(ReciveListServerClaster[z]) then continue;
   if (SrvIP='')or (SrvPort=0) then continue; // защита от пустых данных
   if SrvIP=SrvIpExternal then  continue; // защита от получения своего адреса.

   exist:=false;
  //Write_Log('OutClaster','ReciveListServerClaster - '+SrvIP );
  //-------------------------------
   Exist:=false; // вносились ии нет изменения
   BreakExist:=true; // просим выйти из цикла ReciveListServerClaster
    for Y := 0 to ListServerClaster.Count-1 do
     begin
     if pos(SrvIP,ListServerClaster[y])>0 then // если этот ip есть в строке,
      Begin
       if (ListServerClaster[y])<>(SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;') then // если строки не равны то заменяем
        begin
        // Write_Log('OutClaster','поиск в своем списке- '+SrvIP+'='+ListServerClaster[y]);
         ListServerClaster[y]:=SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;';
         exist:=true; // внесли изменения
         result:=true; // в результат говорим что были изменения
         BreakExist:=true; // внесли изменения, выход из цикла ReciveListServerClaster
         break;
        end
       else
        begin
        exist:=true; // иначе это строка есть и они равны вставлять ее не надо
        result:=false; // результат изменения не вносились
        BreakExist:=false; // продолжаем цикл по списку ReciveListServerClaster полученных ip
        break;
        end;
      End
     end;

     if not exist then
       begin
       //Write_Log('OutClaster', 'Добавляем '+SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;');
       ListServerClaster.Add(SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;');
       exist:=true; // внесли изменения в список
       BreakExist:=true; // выход из цикла
       result:=true; //в результат говорим что были изменения
       break;
       end;
  //---------------------------------
  if BreakExist then break;
  END;

  except On E: Exception do
  begin
  result:=false;
  Write_Log('OutClaster',2,'ComparisonListClaster ');
  end;
  end;
 end;
//-------------------------------------------------------
procedure TThread_FindAndRunConnection.Execute;
var                  //172.16.1.2=3897=1234=;
i,z:integer;
SrvIP,SrvPswd:string;
SrvPort,NextClient:integer;
exist:boolean;
TimeOutThread,MySuccessfulConnect,AllSuccessfulConnect,NumIteration:integer;
function SeparationIpPortPswd(SepStr:string):boolean;  // получаем   строку с реквизитами  для подключения к серверу кластера
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do Write_Log('OutClaster',2,' (3) Парсинг реквизитов подключения');  end;
end;
begin
try
SingRunOutConnectClaster:=true; // признак работы потока исходящих соединений кластера
TimeOutThread:=0; // начальный 0
sleep(3000);// ожидаем после старта
NumIteration:=0; // количество итераций в общем цикле
while not terminated do
  BEGIN
      try
      sleep(TimeOutThread); // ожидаем после итерации
      MySuccessfulConnect:=0; // общее количество удачно установленных соединений из списка кластеризации
      inc(NumIteration);
      for I := 0 to ListClaserIP.Count-1 do
           Begin
            if terminated then break;
             SrvIP:='';
             SrvPswd:='';
             SrvPort:=0;
             exist:=false;
             SeparationIpPortPswd(ListClaserIP[i]);
             //Write_Log('OutClaster','Сервер - '+SrvIP+' порт - '+inttostr(SrvPort)+' Пароль - '+SrvPswd);
             if SrvIP=SrvIpExternal then   // защита от получения своего адреса.
             begin
             ListClaserIP.Delete(i);
             break;
             end;
           //---------------------------------------------------------
             if (SrvIP<>'')and(SrvPort<>0) then
             Begin
                for Z := 0 to length(ArrayClientClaster)-1 do
                if ArrayClientClaster[z].InOutput=1 then  // если подключен   входящий
                Begin
                 if ArrayClientClaster[z].StatusConnect=1 then // если статус соединения ок
                  begin
                   if (ArrayClientClaster[z].ServerAddress=SrvIP) then // если подключен к IP из списка класеризации
                    begin
                    inc(MySuccessfulConnect); //подсчет общее количество удачно установленных соединений из списка кластеризации
                    exist:=true; // данное соединение активно, и не важно входящее оно или исходящее
                    break;
                    end
                   end;
                 End;
                // двойной поиск необходим если вдруг есть 2 элемента массива, исходящее с ошибкой и входящее со статусом ОК, первый элемент может быть с ошибкой и прога постоянно будет пытатья подключить
               if not exist then
               for Z := 0 to length(ArrayClientClaster)-1 do
                if ArrayClientClaster[z].InOutput=2 then  // если подключен исходящее
                begin
                 if ArrayClientClaster[z].StatusConnect=1 then // если статус соединения ок
                  begin
                   if (ArrayClientClaster[z].ServerAddress=SrvIP) then // если подключен к IP из списка класеризации
                    begin
                    inc(MySuccessfulConnect); //подсчет общее количество удачно установленных соединений из списка кластеризации
                    exist:=true; // данное соединение активно, и не важно входящее оно или исходящее
                    break;
                    end
                   end;
                 end;
              End;

              //-----------------------------------------------
               if (SrvIP<>'')and(SrvPort<>0) then
               if not exist then //если соединение не нашли в массиве со статусом подключенных
               for Z := 0 to length(ArrayClientClaster)-1 do
               Begin
                if SrvIP<>ArrayClientClaster[z].ServerAddress then continue;
                 if ArrayClientClaster[z].InOutput=2 then //  если это исходящее то проверяем его статус
                    Begin //2- сервер молчит при установленном соединении, 3-не верный пароль для подключения к серверу  4-ошибка соединения
                    // Write_Log('OutClaster',ArrayClientClaster[z].ServerAddress+' InOutput=2 StatusConnect='+inttostr(ArrayClientClaster[z].StatusConnect));
                     if (ArrayClientClaster[z].StatusConnect=2)or(ArrayClientClaster[z].StatusConnect=3)or(ArrayClientClaster[z].StatusConnect=4) then
                       begin
                       try
                      // Write_Log('OutClaster','Now-'+Datetimetostr(now)+' DateTimeStatus-'+DateTimetoStr(ArrayClientClaster[z].DateTimeStatus));
                       if MinutesBetween(now,ArrayClientClaster[z].DateTimeStatus)>=TimeOutReconnect then // если последний раз соединялись больше ... минут назад
                         begin
                         // Write_Log('OutClaster','Now-'+Datetimetostr(now)+' DateTimeStatus-'+DateTimetoStr(ArrayClientClaster[z].DateTimeStatus));
                          ClearArrayConnectBusy(z);// очищаем элемент массива
                          exist:=false; // данное соединение не активно, надо бы его повторно создать
                          break;
                         end
                        else
                         begin
                          exist:=true; // типа данное соединение активно
                          break;
                         end;
                       except on E : Exception do
                        begin
                         ClearArrayConnectBusy(z); // очищаем элемент массива
                         exist:=false; // данное соединение не активно, надо бы его повторно создать
                         break;
                         Write_Log('OutClaster',2,'(1) Обработка исходящих подключений');
                        end;
                       end;
                       end;
                     End;
                  End;
              //-------------------------
             if (not exist) then // если соединение с сервером (входящее или исходящее) не установлено то  подключаемся.
              begin
               if (SrvPort<>0)and (SrvIP<>'') then
                 begin
                  if AddRecordClaster(NextClient,2) then // если удачно получили индекс массива для исходящего подключения
                   begin
                   //Write_Log('OutClaster','Настройка создания исходящего подключения '+SrvIP+' получен индекс - '+inttostr(NextClient));
                   ArrayClientClaster[NextClient].Serverpassword:=SrvPswd; // установка пароля удаленного сервера
                   ArrayClientClaster[NextClient].ServerAddress:=SrvIP;   // установка ip удаленного сервера
                   ArrayClientClaster[NextClient].ServerPort:=SrvPort; // установа порта удаленного сервера
                   ArrayClientClaster[NextClient].InOutput:=2;
                   ArrayClientClaster[NextClient].StatusConnect:=0; // 0-свободное, 1-установлено соединение, 2- сервер молчит при соединении, 3-не верный пароль для подключения к серверу  4- ошибка соединения
                   ArrayClientClaster[NextClient].DateTimeStatus:=now;
                   ArrayClientClaster[NextClient].CloseThread:=false;
                   TConnectClientSocket.Create(SrvIP,SrvPort,SrvPswd,NextClient);// IP, port, password, индекс массива
                   end
                  else Write_Log('OutClaster',2,'Настройка создания исходящего подключения индекс не получен - '+SrvIP+' порт='+inttostr(SrvPort));
                 sleep(5000); // таймаут на установку соединения!!!
                 end;
              end;
          END;// по циклу for

       //----------------------------------------------
        AllSuccessfulConnect:=0; //общее количество установвленных соединений
        for z := 0 to length(ArrayClientClaster)-1 do
         begin
          if ArrayClientClaster[z].InOutput=2 then //любойе активное исходящее подключение пусть обновляет списки префиксов
            begin
            ArrayClientClaster[z].PrefixUpdate:=1;
            sleep(2222);//ожидание для того чтобы поток данного подключения не конфликтовал с другим при доступе к глобальному массиву префиксов
            end;
          if ArrayClientClaster[z].InOutput<>0 then // если соединение установлено, не важно входящее или исходящее
          if ArrayClientClaster[z].StatusConnect=1 then inc(AllSuccessfulConnect); //подсчет общего количества установвленных соединений
         end;

      //---------------------------- установка интервала таймаута в зависимости от общего количества исходящих подключений в кластере
       {if MySuccessfulConnect>4 then  TimeOutThread:=5000*MySuccessfulConnect
       else} TimeOutThread:=20000;
      //--------------------------------------------- сравнение списков кластеризации
       if NumIteration>3 then  // пропускаем кажды 4 первые итерации в цикле, возможно все подключения удастся установить
       begin
       NumIteration:=0;
       if AllSuccessfulConnect<3 then // если общее количество удачно устанновленных соединений в кластере меньше 3 после 4х итераций
         begin  // сверяем свой список для кластеризации с полученным от других серверов
          if ComparisonListClaster then  // если были изменения то обновляем свой список
           Begin
           ListClaserIP.Clear;
           ListClaserIP.CommaText:= ListServerClaster.CommaText;
           End;
         end;
       end;
       //--------------------------------------------
       //Write_Log('OutClaster',' TimeOutReconnect='+inttostr(TimeOutThread)+' NumIteration='+inttostr(NumIteration)+' MySuccessfulConnect='+inttostr(MySuccessfulConnect)+' AllSuccessfulConnect='+inttostr(AllSuccessfulConnect));

       except on E : Exception do
         begin
           TimeOutThread:=20000;
           Write_Log('OutClaster',2,'(2) Обработка исходящих подключений');
         end;
       end;
  END; /// while

SingRunOutConnectClaster:=false; // признак работы потока исходящих соединений кластера
//-----------------------
 except on E : Exception do
  begin
   Write_Log('OutClaster',2,'(3) Обработка исходящих подключений ');
   SingRunOutConnectClaster:=false; // признак работы потока исходящих соединений кластера
  end;
end;
end;




//----------------------------------------------------------------------
//для обработки исходящих подключений в кластере
//------------------------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // функция записи в лог для для потока
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
function TConnectClientSocket.TThreadClient_Claster.ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //сравнение 2х списков префиксов, локального и принятого
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
Function TConnectClientSocket.TThreadClient_Claster.MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // получаем список своих исходящих активных серверов в кластере, для передачи другому серверу
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
Write_Log('OutClaster',2,'MyListActivServerClaster');
end;
 end;
end;
//-----------------------------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // добавляем список полученных серверов в список ReciveListServerClaster
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
  Write_Log('OutClaster',2,'AddReciveListServerClaster ');
  end;
 end;
end;
//----------------------------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.PrefixListToArray(ListPrefix:TstringList):boolean; // замена/добавление массива записей префиксов на полученые из ListPrefix
var
i,z,NexPrfx:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist:boolean;
CleanEl:integer; // индекс чистого элемента массива
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
except on E : Exception do Write_Log('OutClaster',2,'(1) Ошибка парсинга строки префиксов');  end;
end;
begin
try
result:=false;
 for I := 0 to ListPrefix.Count-1 do
 BEGIN
 exist:=false;
 CleanEl:=0;
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
    End;//цикл for Z :=  0 to Length(ArrayPrefixSrv)-1 do
//---------------------------------------
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
  End;//if (SrvIP<>'') and(SrvPort<>0) and (SrvPrfx<>'') then
END;
result:=true;
except on E : Exception do Write_Log('OutClaster',2,'(2) Ошибка парсинга строки префиксов');  end;
end;
//
//----------------------------------------------------------------------
function  TConnectClientSocket.TThreadClient_Claster.ParsingListPrefix(var NewListPrefix:TstringList):boolean; //поиск своего IP/замена/добавлеие в списке префиксов
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
except on E : Exception do Write_Log('OutClaster',2,'(3) Ошибка парсинга строки префиксов');  end;
end;
begin
try
repl:=false;
PrefixListToArray(NewListPrefix); //сразу добавляем/обновляем в массив префиксов для последующей работы с ним.
for I := 0 to NewListPrefix.Count-1 do // Наша задача проверить только свою запись в списке NewListPrefix  а соответственно  в массиве
  Begin
   exist:=false;
   SeparationIpPortPswd(NewListPrefix[i]); // парсим строку списка
   if (SrvIP=SrvIpExternal) and (PortServerViewer=SrvPort) and (PrefixServer=SrvPrfx) and (SrvPswd=PswdServerViewer) then // если я есть в списе серверов и все ОК
    begin   // если все совпадает то все ок и делть со списком префиксов ничего не надо, просто обновляем дату
    NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now));
    AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// //обновляем элемент массива с измененной записью своего сервера, обновление даты и врмени
    exist:=true; // нашли свою запись
    repl:=false; // говорим что данные не менялись
    break;
    end
   else
    if (SrvIP=SrvIpExternal) then // иначе если есть мой IP но другие параметры изменились, надо обновить
     begin
      PrefixServer:= GeneratePrefixServr(PrefixServer,SrvIpExternal);  // проверяем наш префикс на совпадение с префиксами из обновленного массива
      NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)); // изменяем в списке нашу запись
      AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// обновляем элемент массива с измененной записью своего сервера
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
    AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// добавляем элемент массива с записью своего сервера
    repl:=true;  // говорим что данные изменились
    TmpPrefix:='';
  end;
result:=repl;// если свою запись не обновляли то результат false/ соответственно этот список отправлять не надо
except on E : Exception do
  begin
   result:=false;
   Write_Log('OutClaster',2,'(4) Ошибка парсинга строки префиксов');
  end;
  end;
end;
//----------------------------------------------------------
Function TConnectClientSocket.TThreadClient_Claster.PrefixArrayToList(Var ListPrefix:TstringList):boolean; // Перевод всего массива в ListString
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
      if (MinutesBetween(TTimeZone.local.ToUniversalTime(now),PrefixDateTime))>PrefixLifeTime then // если прошло больше ReCreateRecPrefix минут после последнего обновления этой записи удаленным сервером
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
   end;// цикл по массиву
result:=true;
except on E : Exception do
  begin
   Write_Log('OutClaster',2,'PrefixArrayToList');
   result:=false;
  end;
end;
end;
//--------------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
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
   Write_Log('OutClaster',0,'Encryptstrs '+E.ClassName+' / '+E.Message);
  result:=false;
  OutStr:='';
  end;
end;
end;

function TConnectClientSocket.TThreadClient_Claster.Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
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
   Write_Log('OutClaster',0,'Encryptstrs '+E.ClassName+' / '+E.Message);
  result:=false;
  OutStr:='';
  end;
end;
end;

//-----------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.SendMainSock(s:string):boolean; // функция отправки через сокет управления
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
        Write_Log('OutClaster',2,'Поток Manager Внешняя функция отправки');
        end;
     end;
   end
      else result:=false;
 end;

//----------------------------------------------------
procedure TConnectClientSocket.TThreadClient_Claster.Execute; // поток для обработки исходящих подключений в кластере
var
i:integer;
Buffer,BufferTemp,CryptText,CryptBufTemp:string;
ipAddSrv:string;
TmpPswd:string;
Position,slepengtime:integer;
FindTrgtPswd:string;
FindTrgID:string;
ListTemp:TstringList;
step,posStr:integer;
L:integer;
//------------------------------------------------
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
//----------------------------------------------------
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
    Write_Log('OutClaster',2,'('+inttostr(step)+') Дешифрация данных ');
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
//------------------------------------------------------
BEGIN
try
TmpPswd:=ArrayClientClaster[IDindex].ServerPassword; // пароль для шифрования
sleep(1000); // активация потока чуть позже установки соединения
if (TmpSocket=nil) or (not TmpSocket.Connected) then
begin
Write_Log('OutClaster',1,'Завершение потока не установленного соединения обработки исходящего подключения');
exit;
end;
ipAddSrv:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDindex].ServerAddress:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDindex].ServerPort:=TmpSocket.RemotePort;
ArrayClientClaster[IDindex].SocketHandle:=TmpSocket.SocketHandle;
ArrayClientClaster[IDindex].InOutput:=2;
step:=1;
//----------------------
ListTemp:=TstringList.Create;
try
PrefixArrayToList(ListTemp); // перевод массива префиксов в список
SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //отравка зашифрованного списка префиксов
finally
ListTemp.Free;
end;
step:=2;
sleep(1000);
slepengtime:=0;
//--------------------------
//Write_Log('OutClaster '+ipAddSrv,'Запущен поток обработки исходящего подключения ServerAddress: '+ArrayClientClaster[IDindex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDindex].ServerPort));
while TmpSocket.Connected do
 BEGIN
 try
 sleep(ProcessingSlack);
 step:=3;
 if (TmpSocket=nil) or (not TmpSocket.Connected) then  break;
 if ArrayClientClaster[IDindex].CloseThread then break;
  step:=4;
  //------------------------------------------ // если таймер поменял значение
   if ArrayClientClaster[IDindex].PrefixUpdate=1 then
   begin
   step:=5;
    //---------------------------------
     ListTemp:=TstringList.Create;
    try
    step:=6;
    PrefixArrayToList(ListTemp); // перевод массива префиксов в список
    step:=7;
    SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //отравка зашифрованного списка префиксов
    step:=8;
    //Write_Log('OutClaster '+ipAddSrv,'Отправка данных '+TmpSocket.RemoteAddress+' <|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>' );
    step:=9;
    finally
    ArrayClientClaster[IDindex].PrefixUpdate:=0; // установка в 0 чтобы не зациклится
    ListTemp.Free;
    end;
    step:=10;
    //-------------------------------------
    if SendListServers then // делится списком адресов кластера
     begin
     ListTemp:=TstringList.Create;
     try
      if MyListActivServerClaster(ListTemp,ArrayClientClaster[IDindex].ServerAddress) then // получаем список своих исходящих активных серверов кластера
       begin
       SendMainCryptText('<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>');  //отравка зашифрованного своего списка активных серверов для кластеризации
       //Write_Log('OutClaster '+ipAddSrv,'Отправка данных '+TmpSocket.RemoteAddress+' <|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>' );
       end;
     finally
     ListTemp.Free;
     end;
    end;
    //--------------------------
   end;
 //---------------------------------------------------------------------------------

 if TmpSocket.ReceiveLength<1 then continue;
 step:=11;
//--------------------------------------------------------------------------------
  CryptText:=TmpSocket.ReceiveText;
  //Write_Log('OutClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - Чтение данных в сокете Crypt: '+CryptText);
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
  //Write_Log('OutClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - Чтение данных в сокете Decrypt: '+Buffer);
step:=12;
//-------------------------------------------------------------------------------
   if Buffer.Contains('<|PING|>') then SendMainCryptText('<|PONG|>');
//---------------------------------------------------------------------------
step:=13;
    Position := Pos('<|SETPING|>', Buffer); // значение таймаута
    if Position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, Position + 10);
      BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      ArrayClientClaster[IDindex].MyPing := StrToInt(BufferTemp);
    end;
step:=14;
   //-----------------------------------------------------------
     if Buffer.Contains('<|SRVLST|>') then  // получили список серверов
     if GetListServers then // если в настройках разрешено получатьсписки адресов серверов
     begin    //<|SRVLST|>text<|ENDLST|>
      BufferTemp:=Buffer;
      if BufferTemp.Contains('<|ENDLST|>') then // если строка полная значит заканчивается <|ENDLST|>
       begin
        delete(BufferTemp,1,pos('<|SRVLST|>',BufferTemp)+9);
        ListTemp:=TstringList.Create;
        try
        ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDLST|>',BufferTemp)-1); // скопировали строку с серверами
        //Write_Log('OutClaster '+ipAddSrv,'Получен список серверов - '+ListTemp.CommaText);
        AddReciveListServerClaster(ListTemp); //отправляем сравнивать и добавлять
        finally
        ListTemp.Free;
        end;
       end;
     end;
   //-----------------------------------------------------------
     if Buffer.Contains('<|PRFX|>') then  // получили список префиксов
     BEGIN     //<|PRFX|>Text<|ENDPRFX|>
step:=15;
     BufferTemp:=Buffer;
     if BufferTemp.Contains('<|ENDPRFX|>') then
       Begin
       delete(BufferTemp,1,pos('<|PRFX|>',BufferTemp)+7);
       ListTemp:=TstringList.Create;
         try
         ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDPRFX|>',BufferTemp)-1);// добавили списо префиксов в stringList
         //Write_Log('OutClaster '+ipAddSrv,'ActiveCountPefix='+inttostr(ActiveCountPefix)+' length(ArrayPrefixSrv)='+inttostr(length(ArrayPrefixSrv)));
         if (ListTemp.Count)<ActiveCountPefix then // если отправленный список префиксов меньше чем у меня, то пусть проверит сначала сам.
           Begin
    step:=16;
          // ListTemp.Clear;
           //if PrefixArrayToList(ListTemp) then  // перевод массива префиксов в StringList
          // SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // отправка списка префиксов
           End
         else  // иначе списки префиксов либо равны либо у меня меньше
           Begin
    step:=17; ParsingListPrefix(ListTemp);
          // if ParsingListPrefix(ListTemp) then // если вносили свои изменения (свой IP PSWD port и так далее) в список с префиксами
         //  SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');// отправляем список префиксов обратно
             // если свои изменения не внесли то все ок со списком префиксов
           End;
    step:=18
         finally
         ListTemp.Free;
         end;
       End;
     END;
//---------------------------------------------------------------------
  except
    On E: Exception do
    begin
    Write_Log('OutClaster',2,'(1) ('+inttostr(step)+') Обработка исходящего соединения ServerAddress: '+ipAddSrv);
    break;
    end;
  end;
  //-----------------------------------------------------------
step:=19;
 END;
step:=20;
 //Write_Log('OutClaster '+ipAddSrv,'Завершение потока обработки исходящего подключения ServerAddress: '+ArrayClientClaster[IDindex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDindex].ServerPort));
step:=21;
//////////////////////////////
ArrayClientClaster[IDindex].ServerAddress:='';
ArrayClientClaster[IDindex].InOutput:=0;
ArrayClientClaster[IDindex].SocketHandle:=0;
ArrayClientClaster[IDindex].ServerPort:=0;
ArrayClientClaster[IDindex].PrefixUpdate:=0;
ArrayClientClaster[IDindex].ServerPassword:='';
ArrayClientClaster[IDindex].CloseThread:=false;
if TmpSocket.Connected then TmpSocket.Close;
step:=22;
 except
    On E: Exception do
    begin
     ArrayClientClaster[IDindex].ServerAddress:='';
     ArrayClientClaster[IDindex].InOutput:=0;
     ArrayClientClaster[IDindex].SocketHandle:=0;
     ArrayClientClaster[IDindex].ServerPort:=0;
     ArrayClientClaster[IDindex].PrefixUpdate:=0;
     ArrayClientClaster[IDindex].ServerPassword:='';
     Write_Log('OutClaster',2,'(2) ('+inttostr(step)+') Обработка исходящего соединения ServerAddress: '+ipAddSrv);
    end;
  end;

END;


end.
