unit RunOutConnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,VCL.Forms,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,DateUtils,uTPLb_CryptographicLibrary, uTPLb_Codec;

type    // ��������� ��� ��������/��������� ���������� ��������
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
   InOutput:byte; // ������� ���������� ����������
   IDConnect:byte;  //id ������ �������
   PrefixUpdate:byte; // 1 - ��������� ������ �� ��������
   StatusConnect:byte; // ������ ����������
   DateTimeStatus:TdateTime; // ���� � ����� ��������� StatusConnect
 end;





    type
     TConnectClientSocket= class (TClientSocket) // �������� ������� ��������� ���������� ��������
      private
         ClientSckt: TClientSocket;
         srvIp:string;
         srvPort:integer;
         srvPswd:string;
         IndexArray:integer; // ������ ������� ��� ������ ��� �������� �����������

       public
         constructor Create(AsrvIp:string;AsrvPort:integer; AsrvPswd:string; aIndexArray:integer); overload;
         procedure ClientClaster_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket); //���������
         procedure ClientClaster_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer); //���������
         procedure ClientClaster_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);// � ��������� ��������� ����� TThreadClient_Claster
         function DecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
         function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
         Function FindArrayConnect(IpAddress:string; port:integer; InOut:byte; var FindIndex:integer):boolean; // ����� ������������ ������� �������� ������� ��� ���������� ����������
         function ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������


     type // ����� ��������� ��������� ���������� ��� ��������
     TThreadClient_Claster = class(TThread)
      private
        TmpSocket:TCustomWinSocket;
        IDindex:integer; // ������ ������� ��� ������ ��� �������� ���������� �����������
      public
        constructor Create(aSocket: TCustomWinSocket; aIDConnect:integer ; InOut:byte); overload;
        procedure Execute; override; // ��������� ���������� ������
        function SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
        function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
        Function PrefixArrayToList(Var ListPrefix:TstringList):boolean; //   ������� �������� ��������� � ������
        function ParsingListPrefix(var NewListPrefix:TstringList):boolean; //����� ������ IP/������/��������� � ������ ���������
        function PrefixListToArray(ListPrefix:TstringList):boolean; // ������/���������� ������� ������� ��������� �� ��������� �� ListPrefix
        function ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //��������� 2� ������� ���������, ���������� � ���������
        Function MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // �������� ������ ����� ��������� �������� �������� � ��������, ��� �������� ������� �������
        function AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // ��������� ������ ���������� �������� � ������ ReciveListServerClaster
        function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
        function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
      end;
     end;

type //����� �������� ������ � ��������� ���������� �������������
  TThread_FindAndRunConnection = class (TThread)
    private
      EditListIP:boolean;
      ListClaserIP:TstringList;
      StatusWorkThread:boolean;
    public
      constructor Create(aListClaserIP:TstringList); overload;
      procedure Execute; override; // ��������� ���������� ������
      function AddRecordClaster(var NextClient:integer; InOut:byte):boolean; // �������� ������ ������� ��� �����������
      function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
      function AddEditListClasterIP(ipAddress:string;EditField:byte;InData:string):boolean;
      function ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������
      Function ComparisonListClaster:boolean; //��������� ������� �������� ��� �������������, ���������� � ����������� �� ������ ��������
 end;





implementation
uses MainModule,FunctionPrefixServer,SocketCrypt;

//--�������� ������ ��� �������� ������� ���������� � ��������
constructor TThread_FindAndRunConnection.Create(aListClaserIP:TstringList);
begin        //
  inherited Create(False);
  ListClaserIP:=TstringList.Create;
  ListClaserIP.CommaText:=aListClaserIP.CommaText;
  StatusWorkThread:=true;
  FreeOnTerminate := true;
end;

// �������� ������ ��� ��������� ��������� ����������� ��������
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
//Write_Log('OutClaster','��������� �������� ���������� ����������� '+SrvIP+' ������ '+inttostr(IndexArray)+' ��������� ');
except On E: Exception do
 begin
 ArrayClientClaster[IndexArray].StatusConnect:=4; //���� ��������� ������ �� ������ �������� �����������
 ArrayClientClaster[IndexArray].DateTimeStatus:=now;
 ClearArrayConnectBusy(IndexArray);
 Write_Log('OutClaster',2,'�������� ���������� ����������� '+SrvIP+' ConnectClientSocket.Create'{+ E.ClassName+' / '+ E.Message});
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
//---------------------------------------------

function TConnectClientSocket.ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������
begin
try
result:=false;
   if indexArray<=length(ArrayClientClaster)-1 then
   if (ArrayClientClaster[indexArray].StatusConnect=1)or(ArrayClientClaster[indexArray].StatusConnect=0) then
   begin//������� ������ ���� ���������� ����� ���� ����������� ��� ������ �� �������� �����������
  // Write_Log('OutClaster',' ClearArrayConnectBusy ������ ������� ������� � indexArray='+inttostr(indexArray));
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
   // Write_Log('OutClaster',' ClearArrayConnectBusy ��������� ������� ������� � indexArray='+inttostr(indexArray));
   end;
   result:=true;
except
    On E: Exception do Write_Log('OutClaster',2,'ClearArrayConnectBusy index='+inttostr(indexArray){+' '+ E.ClassName+' / '+ E.Message});
    end;
 end;
//--------------------------------------------------
Function TConnectClientSocket.FindArrayConnect(IpAddress:string; port:integer; InOut:byte; var FindIndex:integer):boolean; // ����� ������������ ������� �������� ������� ��� ���������� ����������
var
i:integer;
begin
try
//Write_Log('OutClaster','FindArrayConnect ����� �������� ������� ���������� ���������� '+IpAddress+' '+inttostr(port));
result:=false;
for I := 0 to Length(ArrayClientClaster)-1 do
begin
 if (ArrayClientClaster[i].InOutput=InOut) then
   if (ArrayClientClaster[i].ServerAddress=IpAddress)  and (ArrayClientClaster[i].ServerPort=port) then
   begin
     //Write_Log('OutClaster','FindArrayConnect ����� �������� ������� ���������� ���������� index '+inttostr(i)+' '+ArrayClientClaster[i].ServerAddress+' '+inttostr(ArrayClientClaster[i].ServerPort));
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
//----------------------------------------------------------------------------

function TConnectClientSocket.DecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
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
      Decryptstrs(CryptTmp,pswd,DecryptTmp); //���������� ������������� ������
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
    Write_Log('InClaster',2,'('+inttostr(step)+') ������ ���������� ������ ');
     s:='';
    end;
  end;
end;
//----------------------------------------------------------------------------
procedure TConnectClientSocket.ClientClaster_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);//���������
var
stp:integer;
res:boolean;
TimeOutExit:integer;
Buffer,BufferTmp,CryptBuf :string;
PswdSrv:string;

function SendCryptText(s:string):boolean; // �������� �������������� ������
var
CryptBuf:string;
begin
if Encryptstrs(s,PswdSrv, CryptBuf) then //������� ����� ���������
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
if TimeOutExit>1350 then // �������� 10 ���
  begin
  Write_Log('OutClaster',0,'��������� ����������� � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������');
  ArrayClientClaster[IndexArray].StatusConnect:=2; // ������ ������ �� ������
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  Socket.Close;// ���� �� �������������� � ������� 1 ������ �� ��������� �����
  break;
  end;
if socket.ReceiveLength<1 then continue;

 Buffer:=socket.ReceiveText;
 while not Buffer.Contains('<!!>') do // �������� ����� ������
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
  ArrayClientClaster[IndexArray].StatusConnect:=3; // � ������ �� ����� ������ ��� �����������
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  Write_Log('OutClaster',0,'��������� �����������  � ������� '+Socket.RemoteAddress+' ������� ��-�� ��������� ������ ');
  socket.Close;
  break;
  end;
if BufferTmp.Contains('<|ACCESSAllOWED|>') then
  BEGIN
   if SrvIpExternal='' then // ���� ��� �������� IP   . ��� ���������� ������
    begin
    SrvIpExternal:=Socket.LocalAddress;
    res:=AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer); // � ������� ������  � ������� ���������      stp:=4;
    end;
   TThreadClient_Claster.Create(Socket,IndexArray,2); // �������� �������� ������ � ����� , ������� �������, ������� ���������� �����������
   ArrayClientClaster[IndexArray].StatusConnect:=1; // ���������� �����������
   Write_Log('OutClaster',0,'��������� ����������� � ������� '+ Socket.RemoteAddress+', ������� �������');
   break;
  END;
except on E : Exception do
  begin
  if ArrayClientClaster[IndexArray].StatusConnect<>1 then ArrayClientClaster[IndexArray].StatusConnect:=4; // ����������� ������ ��� ��������� ����������
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  ClearArrayConnectBusy(IndexArray); // ������� �������� �������
   Write_Log('OutClaster',2,'('+inttostr(stp)+') (1) ��������� ����������� � ������� '+Socket.RemoteAddress+' SocketHandle-'+inttostr(Socket.SocketHandle)+' ������ ArrayConnect-'+inttostr(IndexArray));
   Socket.Close;
   break;
  end;
end;
END;


except on E : Exception do
  begin
  if ArrayClientClaster[IndexArray].StatusConnect<>1 then ArrayClientClaster[IndexArray].StatusConnect:=4; // ����������� ������ ��� ��������� ����������
  ArrayClientClaster[IndexArray].DateTimeStatus:=now;
  ClearArrayConnectBusy(IndexArray); // ������� �������� �������
   Write_Log('OutClaster',2,'('+inttostr(stp)+') (2) ��������� ����������� � ������� SocketHandle-'+inttostr(Socket.SocketHandle)+' ������ ArrayConnect-'+inttostr(IndexArray));
  end;
  end;
end;

procedure TConnectClientSocket.ClientClaster_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer); //���������
var
Msg: TMsg;
begin
try
Write_Log('OutClaster',0,'������ ���������� "'+syserrormessage(ErrorCode)+'" � �������� '+ Socket.RemoteAddress);
ErrorCode := 0;
if ArrayClientClaster[IndexArray].StatusConnect=0 then ArrayClientClaster[IndexArray].StatusConnect:=4;  // ���� ���������� �� ���� �����������
ClearArrayConnectBusy(IndexArray); // ������� �������� �������
except on E : Exception do
 begin
   Write_Log('OutClaster',2,'ClientClaster_SocketError ');
 end;
  end;
end;

procedure TConnectClientSocket.ClientClaster_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket); //���������
var
Msg: TMsg;
begin
try
  Write_Log('OutClaster',0,'���������� ���������� ����������� '+ Socket.RemoteAddress);
  if ArrayClientClaster[IndexArray].StatusConnect=0 then ArrayClientClaster[IndexArray].StatusConnect:=4;  // ���� ���������� �� ���� �����������
  ClearArrayConnectBusy(IndexArray); // ������� �������� �������
  except on E : Exception do
   Write_Log('OutClaster',2,'ClientClaster_SocketDisconnect ');
  end;
end;


//--------------------------------------------
function TThread_FindAndRunConnection.AddRecordClaster(var NextClient:integer; InOut:byte):boolean;
var     // ���������� ������ � ������ ����������  ��������� ��������
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
   // Write_Log('OutClaster',inttostr(step)+'����� ������� �������. ������� Index='+inttostr(i)+' IP='+ArrayClientClaster[i].ServerAddress+' InOutput='+inttostr(ArrayClientClaster[i].InOutput));
   if (ArrayClientClaster[i].InOutput=0)and(ArrayClientClaster[i].ServerAddress='') then
     begin
      step:=2;
      CurrentSrvClaster:=i;
      NextClient:=CurrentSrvClaster;
      ArrayClientClaster[i].SocketHandle:=2; // �� ��� ������ ���� ��� ������ ���������� ��� �� ������������� Connect ���� ������� ������� �������
      ArrayClientClaster[i].InOutput:=InOut; // ����� ���������� �������������� � ��������� ��� ����������
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
 Write_Log('OutClaster',2,'('+inttostr(step)+') ����� ���������� ������� ������� ');
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
ArrayClientClaster[NextClient].SocketHandle:=2; // �� ��� ������ ���� ��� ������ ���������� ��� �� ������������� Connect ���� ������� ������� �������
ArrayClientClaster[NextClient].InOutput:=InOut;
ArrayClientClaster[NextClient].DateTimeStatus:=now;
ArrayClientClaster[NextClient].CloseThread:=false;
exist:=true;
end;
step:=6;
//if InOut=1 then Write_Log('OutClaster','����� ������ ������� '+inttostr(NextClient)+' ��� ��������� �����������')
//else Write_Log('OutClaster','����� ������ ������� '+inttostr(NextClient)+' ��� ���������� �����������');
result:= exist;
step:=7;
except
 On E: Exception do
 begin
 result:=false;
 Write_Log('OutClaster',2,'('+inttostr(step)+') ������ ������� ������� ');
 end;
end;
end;
//----------------------------------------
 function TThread_FindAndRunConnection.AddEditListClasterIP(ipAddress:string;EditField:byte;InData:string):boolean; // �������������� ������ ip ������� ��� ��������� ����������
 var
 i,SrvPort:integer;
 SrvIP,SrvPswd:string;
function SeparationIpPortPswd(SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do Write_Log('OutClaster',2,'(1) ������� ���������� ����������� ');  end;
end;
 begin

 end;
//--------------------------------------------------

function TThread_FindAndRunConnection.ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������
begin
try
result:=false;
if indexArray<=length(ArrayClientClaster)-1 then
 begin
   //Write_Log('OutClaster',' ClearArrayConnectBusy ������ ������� ������� � indexArray='+inttostr(indexArray));
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
   //Write_Log('OutClaster',' ClearArrayConnectBusy ��������� ������� ������� � indexArray='+inttostr(indexArray));
   result:=true;
 end;
except
    On E: Exception do Write_Log('OutClaster',2,'ClearArrayConnectBusy  index='+inttostr(indexArray));
    end;
 end;
//-------------------------------------
Function TThread_FindAndRunConnection.ComparisonListClaster:boolean; //��������� ������� �������� ��� �������������, ���������� � ����������� �� ������ ��������
 var
 i,z,y,x:integer;
 exist,BreakExist:boolean;
 SrvIP,SrvPswd:string;
SrvPort:integer;
 function SeparationIpPortPswd(SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
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
Write_Log('OutClaster',2,'(2) ������� ���������� ����������� ');  end;
end;
end;
 begin //ReciveListServerClaster - ���������� ������ ��������  ListServerClaster - �������� ������
try
 //Write_Log('OutClaster','ReciveListServerClaster - '+ReciveListServerClaster.CommaText);
 for Z := 0 to ReciveListServerClaster.Count-1 do
  BEGIN
   if not SeparationIpPortPswd(ReciveListServerClaster[z]) then continue;
   if (SrvIP='')or (SrvPort=0) then continue; // ������ �� ������ ������
   if SrvIP=SrvIpExternal then  continue; // ������ �� ��������� ������ ������.

   exist:=false;
  //Write_Log('OutClaster','ReciveListServerClaster - '+SrvIP );
  //-------------------------------
   Exist:=false; // ��������� �� ��� ���������
   BreakExist:=true; // ������ ����� �� ����� ReciveListServerClaster
    for Y := 0 to ListServerClaster.Count-1 do
     begin
     if pos(SrvIP,ListServerClaster[y])>0 then // ���� ���� ip ���� � ������,
      Begin
       if (ListServerClaster[y])<>(SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;') then // ���� ������ �� ����� �� ��������
        begin
        // Write_Log('OutClaster','����� � ����� ������- '+SrvIP+'='+ListServerClaster[y]);
         ListServerClaster[y]:=SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;';
         exist:=true; // ������ ���������
         result:=true; // � ��������� ������� ��� ���� ���������
         BreakExist:=true; // ������ ���������, ����� �� ����� ReciveListServerClaster
         break;
        end
       else
        begin
        exist:=true; // ����� ��� ������ ���� � ��� ����� ��������� �� �� ����
        result:=false; // ��������� ��������� �� ���������
        BreakExist:=false; // ���������� ���� �� ������ ReciveListServerClaster ���������� ip
        break;
        end;
      End
     end;

     if not exist then
       begin
       //Write_Log('OutClaster', '��������� '+SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;');
       ListServerClaster.Add(SrvIP+'='+inttostr(SrvPort)+'='+SrvPswd+'=;');
       exist:=true; // ������ ��������� � ������
       BreakExist:=true; // ����� �� �����
       result:=true; //� ��������� ������� ��� ���� ���������
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
function SeparationIpPortPswd(SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
begin                                          //172.16.1.2=3897=1234=;
try
SrvIP:=copy(SepStr,1,pos('=',SepStr)-1);
Delete(SepStr,1,pos('=',SepStr));
trystrtoint(copy(SepStr,1,pos('=',SepStr)-1),SrvPort);
Delete(SepStr,1,pos('=',SepStr));
SrvPswd:=copy(SepStr,1,pos('=;',SepStr)-1);
SepStr:='';
except on E : Exception do Write_Log('OutClaster',2,' (3) ������� ���������� �����������');  end;
end;
begin
try
SingRunOutConnectClaster:=true; // ������� ������ ������ ��������� ���������� ��������
TimeOutThread:=0; // ��������� 0
sleep(3000);// ������� ����� ������
NumIteration:=0; // ���������� �������� � ����� �����
while not terminated do
  BEGIN
      try
      sleep(TimeOutThread); // ������� ����� ��������
      MySuccessfulConnect:=0; // ����� ���������� ������ ������������� ���������� �� ������ �������������
      inc(NumIteration);
      for I := 0 to ListClaserIP.Count-1 do
           Begin
            if terminated then break;
             SrvIP:='';
             SrvPswd:='';
             SrvPort:=0;
             exist:=false;
             SeparationIpPortPswd(ListClaserIP[i]);
             //Write_Log('OutClaster','������ - '+SrvIP+' ���� - '+inttostr(SrvPort)+' ������ - '+SrvPswd);
             if SrvIP=SrvIpExternal then   // ������ �� ��������� ������ ������.
             begin
             ListClaserIP.Delete(i);
             break;
             end;
           //---------------------------------------------------------
             if (SrvIP<>'')and(SrvPort<>0) then
             Begin
                for Z := 0 to length(ArrayClientClaster)-1 do
                if ArrayClientClaster[z].InOutput=1 then  // ���� ���������   ��������
                Begin
                 if ArrayClientClaster[z].StatusConnect=1 then // ���� ������ ���������� ��
                  begin
                   if (ArrayClientClaster[z].ServerAddress=SrvIP) then // ���� ��������� � IP �� ������ ������������
                    begin
                    inc(MySuccessfulConnect); //������� ����� ���������� ������ ������������� ���������� �� ������ �������������
                    exist:=true; // ������ ���������� �������, � �� ����� �������� ��� ��� ���������
                    break;
                    end
                   end;
                 End;
                // ������� ����� ��������� ���� ����� ���� 2 �������� �������, ��������� � ������� � �������� �� �������� ��, ������ ������� ����� ���� � ������� � ����� ��������� ����� ������� ����������
               if not exist then
               for Z := 0 to length(ArrayClientClaster)-1 do
                if ArrayClientClaster[z].InOutput=2 then  // ���� ��������� ���������
                begin
                 if ArrayClientClaster[z].StatusConnect=1 then // ���� ������ ���������� ��
                  begin
                   if (ArrayClientClaster[z].ServerAddress=SrvIP) then // ���� ��������� � IP �� ������ ������������
                    begin
                    inc(MySuccessfulConnect); //������� ����� ���������� ������ ������������� ���������� �� ������ �������������
                    exist:=true; // ������ ���������� �������, � �� ����� �������� ��� ��� ���������
                    break;
                    end
                   end;
                 end;
              End;

              //-----------------------------------------------
               if (SrvIP<>'')and(SrvPort<>0) then
               if not exist then //���� ���������� �� ����� � ������� �� �������� ������������
               for Z := 0 to length(ArrayClientClaster)-1 do
               Begin
                if SrvIP<>ArrayClientClaster[z].ServerAddress then continue;
                 if ArrayClientClaster[z].InOutput=2 then //  ���� ��� ��������� �� ��������� ��� ������
                    Begin //2- ������ ������ ��� ������������� ����������, 3-�� ������ ������ ��� ����������� � �������  4-������ ����������
                    // Write_Log('OutClaster',ArrayClientClaster[z].ServerAddress+' InOutput=2 StatusConnect='+inttostr(ArrayClientClaster[z].StatusConnect));
                     if (ArrayClientClaster[z].StatusConnect=2)or(ArrayClientClaster[z].StatusConnect=3)or(ArrayClientClaster[z].StatusConnect=4) then
                       begin
                       try
                      // Write_Log('OutClaster','Now-'+Datetimetostr(now)+' DateTimeStatus-'+DateTimetoStr(ArrayClientClaster[z].DateTimeStatus));
                       if MinutesBetween(now,ArrayClientClaster[z].DateTimeStatus)>=TimeOutReconnect then // ���� ��������� ��� ����������� ������ ... ����� �����
                         begin
                         // Write_Log('OutClaster','Now-'+Datetimetostr(now)+' DateTimeStatus-'+DateTimetoStr(ArrayClientClaster[z].DateTimeStatus));
                          ClearArrayConnectBusy(z);// ������� ������� �������
                          exist:=false; // ������ ���������� �� �������, ���� �� ��� �������� �������
                          break;
                         end
                        else
                         begin
                          exist:=true; // ���� ������ ���������� �������
                          break;
                         end;
                       except on E : Exception do
                        begin
                         ClearArrayConnectBusy(z); // ������� ������� �������
                         exist:=false; // ������ ���������� �� �������, ���� �� ��� �������� �������
                         break;
                         Write_Log('OutClaster',2,'(1) ��������� ��������� �����������');
                        end;
                       end;
                       end;
                     End;
                  End;
              //-------------------------
             if (not exist) then // ���� ���������� � �������� (�������� ��� ���������) �� ����������� ��  ������������.
              begin
               if (SrvPort<>0)and (SrvIP<>'') then
                 begin
                  if AddRecordClaster(NextClient,2) then // ���� ������ �������� ������ ������� ��� ���������� �����������
                   begin
                   //Write_Log('OutClaster','��������� �������� ���������� ����������� '+SrvIP+' ������� ������ - '+inttostr(NextClient));
                   ArrayClientClaster[NextClient].Serverpassword:=SrvPswd; // ��������� ������ ���������� �������
                   ArrayClientClaster[NextClient].ServerAddress:=SrvIP;   // ��������� ip ���������� �������
                   ArrayClientClaster[NextClient].ServerPort:=SrvPort; // �������� ����� ���������� �������
                   ArrayClientClaster[NextClient].InOutput:=2;
                   ArrayClientClaster[NextClient].StatusConnect:=0; // 0-���������, 1-����������� ����������, 2- ������ ������ ��� ����������, 3-�� ������ ������ ��� ����������� � �������  4- ������ ����������
                   ArrayClientClaster[NextClient].DateTimeStatus:=now;
                   ArrayClientClaster[NextClient].CloseThread:=false;
                   TConnectClientSocket.Create(SrvIP,SrvPort,SrvPswd,NextClient);// IP, port, password, ������ �������
                   end
                  else Write_Log('OutClaster',2,'��������� �������� ���������� ����������� ������ �� ������� - '+SrvIP+' ����='+inttostr(SrvPort));
                 sleep(5000); // ������� �� ��������� ����������!!!
                 end;
              end;
          END;// �� ����� for

       //----------------------------------------------
        AllSuccessfulConnect:=0; //����� ���������� �������������� ����������
        for z := 0 to length(ArrayClientClaster)-1 do
         begin
          if ArrayClientClaster[z].InOutput=2 then //������ �������� ��������� ����������� ����� ��������� ������ ���������
            begin
            ArrayClientClaster[z].PrefixUpdate:=1;
            sleep(2222);//�������� ��� ���� ����� ����� ������� ����������� �� ������������ � ������ ��� ������� � ����������� ������� ���������
            end;
          if ArrayClientClaster[z].InOutput<>0 then // ���� ���������� �����������, �� ����� �������� ��� ���������
          if ArrayClientClaster[z].StatusConnect=1 then inc(AllSuccessfulConnect); //������� ������ ���������� �������������� ����������
         end;

      //---------------------------- ��������� ��������� �������� � ����������� �� ������ ���������� ��������� ����������� � ��������
       {if MySuccessfulConnect>4 then  TimeOutThread:=5000*MySuccessfulConnect
       else} TimeOutThread:=20000;
      //--------------------------------------------- ��������� ������� �������������
       if NumIteration>3 then  // ���������� ����� 4 ������ �������� � �����, �������� ��� ����������� ������� ����������
       begin
       NumIteration:=0;
       if AllSuccessfulConnect<3 then // ���� ����� ���������� ������ �������������� ���������� � �������� ������ 3 ����� 4� ��������
         begin  // ������� ���� ������ ��� ������������� � ���������� �� ������ ��������
          if ComparisonListClaster then  // ���� ���� ��������� �� ��������� ���� ������
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
           Write_Log('OutClaster',2,'(2) ��������� ��������� �����������');
         end;
       end;
  END; /// while

SingRunOutConnectClaster:=false; // ������� ������ ������ ��������� ���������� ��������
//-----------------------
 except on E : Exception do
  begin
   Write_Log('OutClaster',2,'(3) ��������� ��������� ����������� ');
   SingRunOutConnectClaster:=false; // ������� ������ ������ ��������� ���������� ��������
  end;
end;
end;




//----------------------------------------------------------------------
//��� ��������� ��������� ����������� � ��������
//------------------------------------------------------------------
function TConnectClientSocket.TThreadClient_Claster.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // ������� ������ � ��� ��� ��� ������
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
function TConnectClientSocket.TThreadClient_Claster.ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //��������� 2� ������� ���������, ���������� � ���������
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
Function TConnectClientSocket.TThreadClient_Claster.MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // �������� ������ ����� ��������� �������� �������� � ��������, ��� �������� ������� �������
var                     ////172.16.1.2=3897=1234=;
i:integer;                 // IP      port  pswd
begin
try
SendListSrv.Clear; //ArrayClientClaster[IDindex].InOutput:=2;
for I := 0 to Length(ArrayClientClaster)-1 do
if ArrayClientClaster[i].InOutput=2 then // ���� ��������� �� ��� ��� ������
if ArrayClientClaster[i].StatusConnect=1 then // ���� ���������� �������
begin
if (ArrayClientClaster[i].ServerAddress<>'') and (ArrayClientClaster[i].ServerPort<>0) then
  begin
  if (ArrayClientClaster[i].ServerAddress<>CurrentConnectIP) then // ���� ����� �� ������ �� ����� �������� ���������� �������, �.�. ������� ��������� ������� ���� ��������� ��� �����������
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
function TConnectClientSocket.TThreadClient_Claster.AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // ��������� ������ ���������� �������� � ������ ReciveListServerClaster
var
i,z:integer;
exist:boolean;
listTmp:TstringList;
begin
try
if ReciveListServerClaster.Count=0 then // ���� � ���� ������ ������
  begin
  ReciveListServerClaster.CommaText:=ReciveListSrv.CommaText; // �������� ���
  end
else  //����� �������� ���������
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
function TConnectClientSocket.TThreadClient_Claster.PrefixListToArray(ListPrefix:TstringList):boolean; // ������/���������� ������� ������� ��������� �� ��������� �� ListPrefix
var
i,z,NexPrfx:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist:boolean;
CleanEl:integer; // ������ ������� �������� �������
function SeparationIpPortPswd(SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
begin                                          //172.16.1.2=3897=1234=123-58=����
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
except on E : Exception do Write_Log('OutClaster',2,'(1) ������ �������� ������ ���������');  end;
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
     if SrvIP=ArrayPrefixSrv[z].SrvIp then  // ���� IP ���� �� ��������� ������ ��� �����������
       begin
       ArrayPrefixSrv[z].SrvPort:=SrvPort;
       ArrayPrefixSrv[z].SrvPrefix:=SrvPrfx;
       ArrayPrefixSrv[z].SrvPswd:=SrvPswd;
       if DateCreate<>'' then ArrayPrefixSrv[z].DateCreate:=DateCreate;
       exist:=true;
       break;
       end
     else exist:=false;
    if ArrayPrefixSrv[z].SrvIp='' then  CleanEl:=z;  // ������� ��������� ������� �������
    End;//���� for Z :=  0 to Length(ArrayPrefixSrv)-1 do
//---------------------------------------
  if not exist then // ���� ������ ��� �� ��������� �����
   begin
    if CleanEl<>0 then NexPrfx:= CleanEl  // ���� ����� ��������� ������ �������
     else AddArrayPrefix(NexPrfx); // ����� �������� �����
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
except on E : Exception do Write_Log('OutClaster',2,'(2) ������ �������� ������ ���������');  end;
end;
//
//----------------------------------------------------------------------
function  TConnectClientSocket.TThreadClient_Claster.ParsingListPrefix(var NewListPrefix:TstringList):boolean; //����� ������ IP/������/��������� � ������ ���������
var               //SrvIpExternal     ���� ��� ������ ��� ������� �� ��������� False
i,z:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist,repl:boolean;
tmpPrefix:string;
function SeparationIpPortPswd(SepStr:string):boolean;  // ��������   ������ � �����������  ��� ����������� � ������� ��������
begin                                          //172.16.1.2=3897=1234=123-58=����
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
except on E : Exception do Write_Log('OutClaster',2,'(3) ������ �������� ������ ���������');  end;
end;
begin
try
repl:=false;
PrefixListToArray(NewListPrefix); //����� ���������/��������� � ������ ��������� ��� ����������� ������ � ���.
for I := 0 to NewListPrefix.Count-1 do // ���� ������ ��������� ������ ���� ������ � ������ NewListPrefix  � ��������������  � �������
  Begin
   exist:=false;
   SeparationIpPortPswd(NewListPrefix[i]); // ������ ������ ������
   if (SrvIP=SrvIpExternal) and (PortServerViewer=SrvPort) and (PrefixServer=SrvPrfx) and (SrvPswd=PswdServerViewer) then // ���� � ���� � ����� �������� � ��� ��
    begin   // ���� ��� ��������� �� ��� �� � ����� �� ������� ��������� ������ �� ����, ������ ��������� ����
    NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now));
    AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// //��������� ������� ������� � ���������� ������� ������ �������, ���������� ���� � ������
    exist:=true; // ����� ���� ������
    repl:=false; // ������� ��� ������ �� ��������
    break;
    end
   else
    if (SrvIP=SrvIpExternal) then // ����� ���� ���� ��� IP �� ������ ��������� ����������, ���� ��������
     begin
      PrefixServer:= GeneratePrefixServr(PrefixServer,SrvIpExternal);  // ��������� ��� ������� �� ���������� � ���������� �� ������������ �������
      NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)); // �������� � ������ ���� ������
      AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// ��������� ������� ������� � ���������� ������� ������ �������
      exist:=true;   // ����� ���� ������
      repl:=true;  // ������� ��� ������ ����������
      break;
     end;
  End;
 if not exist then  // ���� �� ����� ���� � ������, ������ ���� ��������
  begin             // �� ����� ���� ���� �������� �������� �� ������ �� �����
    TmpPrefix:=PrefixServer;
    PrefixServer:= GeneratePrefixServr(TmpPrefix,SrvIpExternal);  // ��������� ��� ������� �� ���������� � ���������� �� �������
    NewListPrefix.Add(SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)));// ��������� ������ � ������
    AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// ��������� ������� ������� � ������� ������ �������
    repl:=true;  // ������� ��� ������ ����������
    TmpPrefix:='';
  end;
result:=repl;// ���� ���� ������ �� ��������� �� ��������� false/ �������������� ���� ������ ���������� �� ����
except on E : Exception do
  begin
   result:=false;
   Write_Log('OutClaster',2,'(4) ������ �������� ������ ���������');
  end;
  end;
end;
//----------------------------------------------------------
Function TConnectClientSocket.TThreadClient_Claster.PrefixArrayToList(Var ListPrefix:TstringList):boolean; // ������� ����� ������� � ListString
var
i:integer;
PrefixDateTime:TdateTime;
begin
try
 ListPrefix.Clear;
 for I := 0 to length(ArrayPrefixSrv)-1 do
   begin
 //----------------------------�������� ������� �������� ������� � �������� ���� ������
   if ArrayPrefixSrv[i].SrvIp<>SrvIpExternal then // ���� � ������� �� ��� ������
   begin
   if TryStrtoDateTime(ArrayPrefixSrv[i].DateCreate,PrefixDateTime)then  // ������� ��������� ������ � ���� � �����
     begin
      if (MinutesBetween(TTimeZone.local.ToUniversalTime(now),PrefixDateTime))>PrefixLifeTime then // ���� ������ ������ ReCreateRecPrefix ����� ����� ���������� ���������� ���� ������ ��������� ��������
        begin                               // ������ ������� �������
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
   end;// ���� �� �������
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
function TConnectClientSocket.TThreadClient_Claster.SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
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
        Write_Log('OutClaster',2,'����� Manager ������� ������� ��������');
        end;
     end;
   end
      else result:=false;
 end;

//----------------------------------------------------
procedure TConnectClientSocket.TThreadClient_Claster.Execute; // ����� ��� ��������� ��������� ����������� � ��������
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
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// �������� ����������� ������ ������� � ������� posStart+3 ����� posEnd-4 ��������
      step:=4;
      Decryptstrs(CryptTmp,TmpPswd,DecryptTmp); //���������� ������������� ������
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
    Write_Log('OutClaster',2,'('+inttostr(step)+') ���������� ������ ');
     s:='';
    end;
  end;
end;
//-----------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
 function SendMainCryptText(s:string):boolean; // �������� �������������� ������ � main �����
 var
 Scrypt:string;
  begin
   if Encryptstrs(s,TmpPswd,Scrypt) then //������� ����� ���������
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
TmpPswd:=ArrayClientClaster[IDindex].ServerPassword; // ������ ��� ����������
sleep(1000); // ��������� ������ ���� ����� ��������� ����������
if (TmpSocket=nil) or (not TmpSocket.Connected) then
begin
Write_Log('OutClaster',1,'���������� ������ �� �������������� ���������� ��������� ���������� �����������');
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
PrefixArrayToList(ListTemp); // ������� ������� ��������� � ������
SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //������� �������������� ������ ���������
finally
ListTemp.Free;
end;
step:=2;
sleep(1000);
slepengtime:=0;
//--------------------------
//Write_Log('OutClaster '+ipAddSrv,'������� ����� ��������� ���������� ����������� ServerAddress: '+ArrayClientClaster[IDindex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDindex].ServerPort));
while TmpSocket.Connected do
 BEGIN
 try
 sleep(ProcessingSlack);
 step:=3;
 if (TmpSocket=nil) or (not TmpSocket.Connected) then  break;
 if ArrayClientClaster[IDindex].CloseThread then break;
  step:=4;
  //------------------------------------------ // ���� ������ ������� ��������
   if ArrayClientClaster[IDindex].PrefixUpdate=1 then
   begin
   step:=5;
    //---------------------------------
     ListTemp:=TstringList.Create;
    try
    step:=6;
    PrefixArrayToList(ListTemp); // ������� ������� ��������� � ������
    step:=7;
    SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //������� �������������� ������ ���������
    step:=8;
    //Write_Log('OutClaster '+ipAddSrv,'�������� ������ '+TmpSocket.RemoteAddress+' <|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>' );
    step:=9;
    finally
    ArrayClientClaster[IDindex].PrefixUpdate:=0; // ��������� � 0 ����� �� ����������
    ListTemp.Free;
    end;
    step:=10;
    //-------------------------------------
    if SendListServers then // ������� ������� ������� ��������
     begin
     ListTemp:=TstringList.Create;
     try
      if MyListActivServerClaster(ListTemp,ArrayClientClaster[IDindex].ServerAddress) then // �������� ������ ����� ��������� �������� �������� ��������
       begin
       SendMainCryptText('<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>');  //������� �������������� ������ ������ �������� �������� ��� �������������
       //Write_Log('OutClaster '+ipAddSrv,'�������� ������ '+TmpSocket.RemoteAddress+' <|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>' );
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
  //Write_Log('OutClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - ������ ������ � ������ Crypt: '+CryptText);
  while not CryptText.Contains('<!!>') do // �������� ����� ������
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
  //Write_Log('OutClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - ������ ������ � ������ Decrypt: '+Buffer);
step:=12;
//-------------------------------------------------------------------------------
   if Buffer.Contains('<|PING|>') then SendMainCryptText('<|PONG|>');
//---------------------------------------------------------------------------
step:=13;
    Position := Pos('<|SETPING|>', Buffer); // �������� ��������
    if Position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, Position + 10);
      BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      ArrayClientClaster[IDindex].MyPing := StrToInt(BufferTemp);
    end;
step:=14;
   //-----------------------------------------------------------
     if Buffer.Contains('<|SRVLST|>') then  // �������� ������ ��������
     if GetListServers then // ���� � ���������� ��������� �������������� ������� ��������
     begin    //<|SRVLST|>text<|ENDLST|>
      BufferTemp:=Buffer;
      if BufferTemp.Contains('<|ENDLST|>') then // ���� ������ ������ ������ ������������� <|ENDLST|>
       begin
        delete(BufferTemp,1,pos('<|SRVLST|>',BufferTemp)+9);
        ListTemp:=TstringList.Create;
        try
        ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDLST|>',BufferTemp)-1); // ����������� ������ � ���������
        //Write_Log('OutClaster '+ipAddSrv,'������� ������ �������� - '+ListTemp.CommaText);
        AddReciveListServerClaster(ListTemp); //���������� ���������� � ���������
        finally
        ListTemp.Free;
        end;
       end;
     end;
   //-----------------------------------------------------------
     if Buffer.Contains('<|PRFX|>') then  // �������� ������ ���������
     BEGIN     //<|PRFX|>Text<|ENDPRFX|>
step:=15;
     BufferTemp:=Buffer;
     if BufferTemp.Contains('<|ENDPRFX|>') then
       Begin
       delete(BufferTemp,1,pos('<|PRFX|>',BufferTemp)+7);
       ListTemp:=TstringList.Create;
         try
         ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDPRFX|>',BufferTemp)-1);// �������� ����� ��������� � stringList
         //Write_Log('OutClaster '+ipAddSrv,'ActiveCountPefix='+inttostr(ActiveCountPefix)+' length(ArrayPrefixSrv)='+inttostr(length(ArrayPrefixSrv)));
         if (ListTemp.Count)<ActiveCountPefix then // ���� ������������ ������ ��������� ������ ��� � ����, �� ����� �������� ������� ���.
           Begin
    step:=16;
          // ListTemp.Clear;
           //if PrefixArrayToList(ListTemp) then  // ������� ������� ��������� � StringList
          // SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // �������� ������ ���������
           End
         else  // ����� ������ ��������� ���� ����� ���� � ���� ������
           Begin
    step:=17; ParsingListPrefix(ListTemp);
          // if ParsingListPrefix(ListTemp) then // ���� ������� ���� ��������� (���� IP PSWD port � ��� �����) � ������ � ����������
         //  SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');// ���������� ������ ��������� �������
             // ���� ���� ��������� �� ������ �� ��� �� �� ������� ���������
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
    Write_Log('OutClaster',2,'(1) ('+inttostr(step)+') ��������� ���������� ���������� ServerAddress: '+ipAddSrv);
    break;
    end;
  end;
  //-----------------------------------------------------------
step:=19;
 END;
step:=20;
 //Write_Log('OutClaster '+ipAddSrv,'���������� ������ ��������� ���������� ����������� ServerAddress: '+ArrayClientClaster[IDindex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDindex].ServerPort));
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
     Write_Log('OutClaster',2,'(2) ('+inttostr(step)+') ��������� ���������� ���������� ServerAddress: '+ipAddSrv);
    end;
  end;

END;


end.
