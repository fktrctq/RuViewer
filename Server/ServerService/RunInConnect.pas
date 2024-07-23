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
    procedure Execute; override; // ��������� ���������� ������
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function AddRecordClaster(var NextClient:integer; InOut:byte):boolean;
   // function AddArrayPrefix(var NextClient:integer):boolean; // ���������� ������ ������ � ������ ���������
    //Function AddPrefixMySrv(InsertPrfx:boolean;SrvIP,SrvPswd,SrvPrfx:string;SrvPort:integer):boolean;// �������� � ������ ��������� ������ � ����
    function ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������
    function FindArrayConnectBusy(SocketHandle:integer; SrvIp:string; InOut:byte):boolean; // �������
    function DecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
    procedure SrvSocketClasterClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketClasterClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure SrvSocketClasterClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    function CloseClientConnect(ipAddress:string):boolean; // ������� ����������� �� �������
    function AddFindBlackList(AddOrFind:byte;IpAddress:string):boolean; // ��������� � ������ ������ ip �����
    Procedure CloseServer; // ���������� ������� �������� �����������

   type  //����� ��������� ��������� ���������� ��������
  TThreadConnection_Claster = class(TThread)
  private
    //ConnectInClaster:^TserverClst;
    TmpSocket:TCustomWinSocket;
    IDIndex:integer;
  public
    constructor Create(aSocket: TCustomWinSocket; aIDConnect:integer); overload;
    procedure Execute; override; // ��������� ���������� ������
    function SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
    function Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;
    function  ParsingListPrefix(var NewListPrefix:TstringList):boolean; //����� ������ IP/������/��������� � ������ ���������
    function PrefixListToArray(ListPrefix:TstringList):boolean; // ������/���������� ������� ������� ��������� �� ��������� �� ListPrefix
    Function PrefixArrayToList(Var ListPrefix:TstringList):boolean; // ������� ����� ������� � ListString
    function ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //��������� 2� ������� ���������, ���������� � ���������
    Function MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // �������� ������ ����� ��������� �������� �������� � ��������, ��� �������� ������� �������
    function AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // ��������� ������ ���������� �������� � ������ ReciveListServerClaster
    function Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean;
    function Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean;
  end;


  end;



implementation
Uses MainModule,FunctionPrefixServer,SocketCrypt;
//---------------- �������� ������ ��� �������� ������� �������� � �������� ������� ��� �������� ����������
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
// �������� ������ ��� ��������� �������� ����������� ��������
constructor TThread_RunInConnect.TThreadConnection_Claster.Create(aSocket: TCustomWinSocket; aIDConnect:integer);
begin
  inherited Create(False);
  TmpSocket:=aSocket;
  IDindex:=aIDConnect;
  FreeOnTerminate := true;
end;
//---------------------------------------------------------
function TThread_RunInConnect.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // ������� ������ � ��� ��� ��� ������
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
Procedure TThread_RunInConnect.CloseServer; // �������� ������� �������� �����������
 var i:integer;
 begin
   try
    for I := 0 to SrvSocketClaster.Socket.ActiveConnections-1 do
    begin
    SrvSocketClaster.Socket.Connections[i].Close; //������� ����������� �� �������.
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
 function TThread_RunInConnect.CloseClientConnect(ipAddress:string):boolean; // ������� ����������� �� �������.
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
function SeparationText(SepStr:string):boolean;  // ��������   ������ � �����������  blacklist
begin                                          //172.16.1.2=���-��=���������=;
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
  Write_Log('InClaster',2,'(1) ������� ������ BlackList  : '{+E.ClassName+': '+E.Message});
  end; end;
end;
 begin
try
if not AddIpBlackListClaster then   // ���� ������ ������ ��������
begin
result:=false;
exit;
end;
 exist:=false;
 //-------------------------------
 if AddOrFind=0 then  // �������� � ������ ������
 Begin
  Write_Log('InClaster',1,'('+inttostr(AddOrFind)+') �������� � ������ ������ '+IpAddress+' '+DatetimetoStr(now));
 for I := 0 to BlackListServerClaster.Count-1 do
  begin
  if SeparationText(BlackListServerClaster[i]) then
   begin
    if SrvIP=IpAddress then // ���� ip ���������� � ������
     begin
     exist:=true; // ��������� ������
     BlackListServerClaster[i]:=IpAddress+'='+inttostr(NumConnect+1)+'='+DateTimeToStr(now)+'=;';
     break;
     end;
    end;
  end; //����
   if not exist then  // ���� �� ����� �� ��������� � ������
   begin
   BlackListServerClaster.add(IpAddress+'=1='+DateTimeToStr(now)+'=;');
   exist:=true; // ��������
   end;
  End;
 //-----------------------------------

 if AddOrFind=1 then  // ����� � ������ ������
  Begin
  //Write_Log('InClaster',inttostr(AddOrFind)+' ����� � ������ ������ '+IpAddress);
   for I := 0 to BlackListServerClaster.Count-1 do
    begin
     if SeparationText(BlackListServerClaster[i]) then
      begin
       if (SrvIP=IpAddress)then
       if MinutesBetween(now,TmpDateCreate)>=LiveTimeBlackList then
        begin
         Write_Log('InClaster',1,'('+inttostr(AddOrFind)+') ������ �� ������� ������ '+IpAddress+' DateCreate='+DatetimetoStr(TmpDateCreate) );
        BlackListServerClaster.Delete(i);
        exist:=false; //�.�. ������� �� ������ �� ������� ��� ����� ��� ��� ���
        break;      // ����� �� �����
        end;
       if (SrvIP=IpAddress) and (NumConnect>=NumOccurentc) then // ���� IP � ������ � ���������� �������� ���������� ��������� ����������
        begin
        BlackListServerClaster[i]:=IpAddress+'='+inttostr(NumConnect+1)+'='+DateTimeToStr(now)+'=;'; // ��������� ������
        exist:=true; // ����� � ������� �� ������
        break;
        end;
      end;
    end
  End;
 //------------------------------------------
 result:=exist;
 except on E : Exception do begin
  result:=false;
  Write_Log('InClaster',2,'('+inttostr(AddOrFind)+') ���������� � ����� � BlackList : '{+E.ClassName+': '+E.Message});
  end; end;
 end;
//---------------------------------------------------
function TThread_RunInConnect.ClearArrayConnectBusy(indexArray:integer):boolean; // ������� �������� ������� � ��������� ������� ��������� ����� ��������
begin
try
result:=false;
if indexArray<=length(ArrayClientClaster)-1 then
 begin
  // Write_Log('InClaster',' ClearArrayConnectBusy ������ ������� ������� � indexArray='+inttostr(indexArray));
   ArrayClientClaster[indexArray].ServerAddress:='';
   ArrayClientClaster[indexArray].Serverport:=0;
   ArrayClientClaster[indexArray].ServerPassword:='';
   ArrayClientClaster[indexArray].SocketHandle:=0;
   ArrayClientClaster[indexArray].MyPing:=64;
   ArrayClientClaster[indexArray].InOutput:=0;
   ArrayClientClaster[indexArray].IDConnect:=0;
   ArrayClientClaster[indexArray].CloseThread:=false;
  // Write_Log('InClaster',' ClearArrayConnectBusy ��������� ������� ������� � indexArray='+inttostr(indexArray));
   result:=true;
 end;
except
    On E: Exception do Write_Log('InClaster',2,'ClearArrayConnectBusy index='+inttostr(indexArray){+' '+ E.ClassName+' / '+ E.Message});
    end;
 end;
//---------------------------------------------------

function TThread_RunInConnect.FindArrayConnectBusy(SocketHandle:integer; SrvIp:string; InOut:byte):boolean; // �������
var   // ����� �������� ������� � ��������� ������� ��������� ����� �������� ���������� ��� Disconect ���������� � SocketError
i:integer;
begin
try
result:=false;
//Write_Log('InClaster','FindArrayConnectBusy ����� ��� ������� SocketHandle='+inttostr(SocketHandle)+ ' ����� - '+SrvIp);
if SrvIp='' then
begin
 for I := 0 to Length(ArrayClientClaster)-1 do
 if ((ArrayClientClaster[i].SocketHandle=SocketHandle) or (ArrayClientClaster[i].SocketHandle=2)) and (ArrayClientClaster[i].InOutput=InOut) then // ����� �� handle ���� �� ������
 begin
   //Write_Log('InClaster','FindArrayConnectBusy ����� � ������� SocketHandle='+inttostr(SocketHandle)+ ' InOutput='+inttostr(InOut));
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
 if (ArrayClientClaster[i].ServerAddress=SrvIp) and (ArrayClientClaster[i].InOutput=InOut) then // ������ IP ������ ��� ���������� � �������� ����� ���� ������ ����
 begin
   //Write_Log('InClaster','FindArrayConnectBusy ����� SocketHandle='+inttostr(SocketHandle)+' ServerAddress='+SrvIp+ ' InOutput='+inttostr(InOut));
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
   if (ArrayClientClaster[i].InOutput=0) then
     begin
      step:=2;
      CurrentSrvClaster:=i;
      NextClient:=CurrentSrvClaster;
      ArrayClientClaster[NextClient].SocketHandle:=2; // �� ��� ������ ���� ��� ������ ���������� ��� �� ������������� Connect ���� ������� ������� �������
      ArrayClientClaster[NextClient].InOutput:=InOut; // ����� ���������� �������������� � ��������� ��� ����������
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
 Write_Log('InClaster',2,'('+inttostr(step)+')������ ������ ���������� ������� ������� '{+ E.ClassName+' / '+ E.Message});
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
ArrayClientClaster[NextClient].CloseThread:=false;
exist:=true;
end;
step:=6;
//if InOut=1 then Write_Log('InClaster','����� ������ ������� '+inttostr(NextClient)+' ��� ��������� �����������')
//else Write_Log('InClaster','����� ������ ������� '+inttostr(NextClient)+' ��� ���������� �����������');
result:= exist;
step:=7;
except
 On E: Exception do
 begin
 result:=false;
 Write_Log('InClaster',2,'('+inttostr(step)+') ������ ������ ������� ������� '{+ E.ClassName+' / '+ E.Message});
 end;
end;
end;


//-----------------------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
Write_Log('InClaster',0,'������ ��������� ����������� "'+syserrormessage(ErrorCode)+'" �������  '+ Socket.RemoteAddress+' � �������� ��������');
ErrorCode:=0;
FindArrayConnectBusy(Socket.SocketHandle,'',1); // ����� �������� ������� ��������� ���������� � ��������� ��������
except
 On E: Exception do Write_Log('InClaster',2,'Client connect Error'{+' '+ E.ClassName+' / '+ E.Message});
end;
end;
//-------------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
try
Write_Log('InClaster',0,'���������� ��������� ����������� '+ Socket.RemoteAddress+' �� ������� ��������');
FindArrayConnectBusy(Socket.SocketHandle,'',1);  // ����� �������� ������� ��������� ���������� � ��������� ��������
except
 On E: Exception do Write_Log('InClaster',2,'Client Disconnect'{+' '+ E.ClassName+' / '+ E.Message});
end;
end;


function TThread_RunInConnect.DecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
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


//-------------------------------
procedure TThread_RunInConnect.SrvSocketClasterClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
  var
  NextClientClaster:integer;
  Buffer,BufferTmp,CryptBuf:string;
  TimeOutExit:integer;
function findConnect(ipStr:string):boolean; // ����� �����������
var
z:integer;
exist:boolean;
begin
exist:=false;
   if (ipStr<>'') then
   Begin
   for Z := 0 to length(ArrayClientClaster)-1 do
     Begin
      if (ArrayClientClaster[z].InOutput<>0) then  // ���� ���������   0-�������� �� ���������
      begin
       if ArrayClientClaster[z].StatusConnect=1 then // ���� ������ ���������� ��
        begin
         if (ArrayClientClaster[z].ServerAddress=ipStr) then // ���� ��������� � IP �� ������ ������������
          begin
          exist:=true; // ������ ���������� �������, � �� ����� �������� ��� ��� ���������
          break;
          end
         end;
       end;
     End;
   End  else exist:=false;
result:=exist;
end;

function SendCryptText(s:string):boolean; // �������� �������������� ������
var
CryptBuf:string;
begin
if Encryptstrs(s,PswdServerClaster, CryptBuf) then //������� ����� ���������
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
if AddFindBlackList(1,Socket.RemoteAddress) then //����� � ������ ������
begin
Write_Log('InClaster',0,'����� '+Socket.RemoteAddress+' � ������ ������');
CloseClientConnect(Socket.RemoteAddress); // ��������� ���������� ���� ���������� � ������ ������
exit;
end;


if SrvSocketClaster.Socket.ActiveConnections>=MaxNumInConnect then //����������� ���� ��������� ����� ����������� �������� �����������
  begin
  Write_Log('InClaster',0,'�������� ����������� ������� '+ Socket.RemoteAddress+'  � ������� ������� ��-�� ���������� ����� ����������� ����������� '+inttostr(MaxNumInConnect));
  CloseClientConnect(Socket.RemoteAddress); // ��������� ���������� � ��������
  exit;
  end;

{if findConnect(Socket.RemoteAddress) then
 begin
  Write_Log('InClaster','�������� ����������� ������� '+ Socket.RemoteAddress+' �������. ���������� � �������� '+Socket.RemoteAddress+' ��� ���������� ');
  CloseClientConnect(Socket.RemoteAddress); // ��������� ���������� � ��������
  exit;
  end; }

TimeOutExit:=0;
//Write_Log('InClaster','�������� ����������� ������� '+ Socket.RemoteAddress+'  � �������');
WHILE socket.Connected DO    //<|PSWDSRV|>...<|ENDPSWD|>
BEGIN
try
sleep(ProcessingSlack);
TimeOutExit:=TimeOutExit+ProcessingSlack;
if TimeOutExit>1050 then // �������� 10 ���
  begin
  if Socket.RemoteAddress<>'' then AddFindBlackList(0,Socket.RemoteAddress); // �������� � ������ ������
  Write_Log('InClaster',0,'�������� ����������� ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������');
  CloseClientConnect(Socket.RemoteAddress); // ��������� ���������� � �������� ��� �������� ����� 10 ���
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
  BufferTmp:=DecryptReciveText(Buffer,PswdServerClaster);

 if BufferTmp.Contains('<|PSWDSRV|>') then
begin
  if BufferTmp.Contains('<|ENDPSWD|>') then
   begin
    Delete(BufferTmp, 1, Pos('<|PSWDSRV|>', BufferTmp)+ 10);
  //-------------------------------
    if (copy(BufferTmp,1,Pos('<|ENDPSWD|>', BufferTmp)- 1))=PswdServerClaster then // ��������� ������
     BEGIN   // ���� ������ �� ������� �����������
     if not SendCryptText('<|ACCESSAllOWED|>') then //���������� ������----------------------------------------------------------------
      begin
      CloseClientConnect(Socket.RemoteAddress); // ��������� ���������� � ��������
      break;
      end;

        NextClientClaster:=99999999;
        if AddRecordClaster(NextClientClaster,1) then // �������� ������� ������� ��������� ����������
          begin
            if SrvIpExternal='' then // ���� ��� �������� IP
             begin
             SrvIpExternal:=Socket.LocalAddress; // �����������
             AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer); // � ������� ������ c ��������� �.�. ��� �������� ������ ��� �� ���������
             end;
          ArrayClientClaster[NextClientClaster].SocketHandle:=Socket.SocketHandle;
          ArrayClientClaster[NextClientClaster].ServerAddress:=Socket.RemoteAddress;
          ArrayClientClaster[NextClientClaster].ServerPort:=Socket.LocalPort;
          ArrayClientClaster[NextClientClaster].InOutput:=1; // �������� �����������
          ArrayClientClaster[NextClientClaster].StatusConnect:=1; // ��������� ������� ���������� �����������
          ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;// ���� � ����� ��������� ����������

          TThreadConnection_Claster.Create(Socket,NextClientClaster);
          Write_Log('InClaster',0,'�������� ����������� ������� '+ Socket.RemoteAddress+' ������� �������');
          end;
       break;
      END
     else // ����� ������ �� ������
     begin
       Write_Log('InClaster',1,'������ ������ �� ������ ������ '+ Socket.RemoteAddress+' ����������  �����������');
       SendCryptText('<|INCORRECTPSWD|>');
       CloseClientConnect(Socket.RemoteAddress);
       break;
     end;
   end;
end;
TimeOutExit:=TimeOutExit+ProcessingSlack; // ���� ����� ����� ����� ������ ����� � ����� �� ���� �������
except
 On E: Exception do
 begin
 if NextClientClaster<>99999999 then
  begin
  ArrayClientClaster[NextClientClaster].StatusConnect:=4; //  4-������ ����������
  ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;
  ClearArrayConnectBusy(NextClientClaster);
  end;
 Write_Log('InClaster',2,'(1) ������ ����� ��������� ��������� ����������� ������� SocketHandle-'+inttostr(Socket.SocketHandle)+' ������ -'+inttostr(NextClientClaster)
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
  ArrayClientClaster[NextClientClaster].StatusConnect:=4; //  4-������ ����������
  ArrayClientClaster[NextClientClaster].DateTimeStatus:=now;
  ClearArrayConnectBusy(NextClientClaster);  //������� ���� ����� ���������
  end;
 Write_Log('InClaster',2,'(2) �������� ����������� ������� SocketHandle-'+inttostr(Socket.SocketHandle)+' ������ -'+inttostr(NextClientClaster)
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
SingRunInConnectionClaster:=true; // ������� ���������� ������ �������� ���������� ��������
TimeOutThread:=0; // 1 ������
if (ListServerClaster.Count<10) then
sleep(10000*ListServerClaster.Count)// ������� 10 ��� �� ���� ��������� ��� ��������� ���������
 else if ListServerClaster.Count>10 then sleep(100000); // ����� 100 ���
while SrvSocketClaster.Active do
  BEGIN
    try
    sleep(TimeOutThread); // ������� ����� ��������
    CountActivConnect:=0;
     for Z := 0 to length(ArrayClientClaster)-1 do
      if (ArrayClientClaster[z].InOutput=1) then  // ����� �������� �������� �����������,   0-�������� �� ���������
        begin
         inc(CountActivConnect); // ������� ���������� �����������
         ArrayClientClaster[z].PrefixUpdate:=1; //������ �������� �������� ����������� ����� ��������� ������ ���������
         sleep(2000);//�������� ��� ���� ����� ����� ������� ����������� �� ������������ � ������ ��� ������� � ����������� ������� ���������
        end;
    //---------------------------- ��������� ��������� �������� � ����������� �� ���������� �������� ����������� � ��������
     {if CountActivConnect>3 then  TimeOutThread:=6000*CountActivConnect
     else} TimeOutThread:=25000;

     except on E : Exception do
       Write_Log('InClaster',2,'(1) TThreadRunOutConnect'{+E.ClassName+': '+E.Message});
    end;
   END;
 SingRunInConnectionClaster:=false; // ������� ���������� ������ �������� ���������� ��������
//-----------------------
 except on E : Exception do
  begin
   SingRunInConnectionClaster:=false; // ������� ���������� ������ �������� ���������� ��������
   Write_Log('InClaster',2,'(2) TThreadRunOutConnect'{E.ClassName+': '+E.Message});
  end;
end;
end;
//------------------------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.AddReciveListServerClaster(ReciveListSrv:Tstringlist):boolean; // ��������� ������ ���������� �������� � ������ ReciveListServerClaster
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
Write_Log('InClaster',2,'(1) ������ AddReciveListServerClaster '{+E.ClassName+': '+E.Message});
end;
 end;
end;
//-------------------------------------------------------------
Function TThread_RunInConnect.TThreadConnection_Claster.MyListActivServerClaster(SendListSrv:TstringList; CurrentConnectIP:string):boolean; // �������� ������ ����� ��������� �������� �������� � ��������, ��� �������� ������� �������
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
Write_Log('InClaster',2,'(1) MyListActivServerClaster'{+E.ClassName+': '+E.Message});
end;
 end;
end;
//--------------------------------------------------------------------
function TThread_RunInConnect.TThreadConnection_Claster.ComparisonListPrefix(ListPrefixRecive,ListPrefixLocal:TstringList):boolean; //��������� 2� ������� ���������, ���������� � ���������
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
function TThread_RunInConnect.TThreadConnection_Claster.PrefixListToArray(ListPrefix:TstringList):boolean; // ������/���������� ������� ������� ��������� �� ��������� �� ListPrefix
var
i,z,NexPrfx,CleanEl:integer;
SrvIP,SrvPswd,SrvPrfx,DateCreate:string;
TmpDateCreate:TdateTime;
SrvPort:integer;
exist:boolean;
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
except on E : Exception do Write_Log('InClaster',2,'(1) ������ �������� ������ ���������'{+E.ClassName+': '+E.Message});  end;
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
   End;
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
  End;
END;
result:=true;
except on E : Exception do Write_Log('InClaster',2,'������ �������� ������� ��������� '{+E.ClassName+': '+E.Message});  end;
end;
//-----------------------------------------------------------------

function  TThread_RunInConnect.TThreadConnection_Claster.ParsingListPrefix(var NewListPrefix:TstringList):boolean; //����� ������ IP/������/��������� � ������ ���������
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
except on E : Exception do Write_Log('InClaster',2,'(2) ������ �������� ������ ���������  '{+E.ClassName+': '+E.Message});  end;
end;
begin
try
repl:=false;
PrefixListToArray(NewListPrefix); //��� ���������� ���� � ������� ����� ���������/��������� � ������ ��������� ��� ����������� ������ � ���.
for I := 0 to NewListPrefix.Count-1 do // ���� ������ ��������� ������ ���� ������ � ������ NewListPrefix  � ��������������  � �������
  Begin
   exist:=false;
   SeparationIpPortPswd(NewListPrefix[i]); // ������ ������ ������
   if (SrvIP=SrvIpExternal) and (PortServerViewer=SrvPort) and (PrefixServer=SrvPrfx) and (SrvPswd=PswdServerViewer) then // ���� � ���� � ����� �������� � ��� ��
    begin   // ���� ��� ��������� �� ��� �� � ����� �� ������� ��������� ������ �� ����, ������ ��������� ����
    NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now));
    AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);//��������� ������� ������� � ���������� ������� ������ �������, ���������� ���� � ������
    exist:=true; // ����� ���� ������
    repl:=false; // ������� ��� ������ �� ��������
    break;
    end
   else
    if (SrvIP=SrvIpExternal) then // ����� ���� ���� IP �� ������ ��������� ����������, ���� ��������
     begin
      PrefixServer:= GeneratePrefixServr(PrefixServer,SrvIpExternal);  // ��������� ��� ������� �� ���������� � ���������� �� ������������ �������
      NewListPrefix[i]:=SrvIpExternal+'='+inttostr(PortServerViewer)+'='+PswdServerViewer+'='+PrefixServer+'='+DateTimeToStr(TTimeZone.local.ToUniversalTime(now)); // �������� � ������ ���� ������
      AddPrefixMySrv(false,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// ��������� ������� ������� � ���������� ������� ������ �������, ���������� ���� � ������
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
    AddPrefixMySrv(true,SrvIpExternal,PswdServerViewer,PrefixServer,PortServerViewer);// ��������� ������� ������� � ���������� ������� ������ �������, ���������� ���� � ������
    repl:=true; // ������� ��� ������ ����������
    TmpPrefix:='';
  end;
result:=repl;// ���� ���� ������ �� ��������� �� ��������� false/ �������������� ���� ������ ���������� �� ����
except on E : Exception do
  begin
   result:=false;
   Write_Log('InClaster',2,'������ �������� ������ ����� ���������  : '{+E.ClassName+': '+E.Message});
  end;
  end;
end;

//----------------------------------------------------------------------
Function TThread_RunInConnect.TThreadConnection_Claster.PrefixArrayToList(Var ListPrefix:TstringList):boolean; // ������� ����� ������� � ListString
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
     if (MinutesBetween(TTimeZone.local.ToUniversalTime(now),PrefixDateTime))>PrefixLifeTime then // ���� ������ ������ ReCreateRecPrefix ����� ����� ���������� ����������
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
   end; //  ���� �� �������
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
function TThread_RunInConnect.TThreadConnection_Claster.Write_Log(nameFile:string; NumError:integer; TextMessage:string):boolean;  // ������� ������ � ��� ��� ��� ������
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
//---------------------------- ����� ��������� �������� ���������� � �������� ��������
function TThread_RunInConnect.TThreadConnection_Claster.SendMainSock(s:string):boolean; // ������� �������� ����� ����� ����������
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
        Write_Log('InClaster',2,'������� ������� ��������');
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
    Write_Log('InClaster',2,'('+inttostr(step)+') ���������� ������ ');
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
//--------------------------------------------

begin
try
TmpPswd:=PswdServerClaster; // ������ ��� ����������
sleep(1000); // ��������� ������ ���� ����� ��������� ����������
 if (TmpSocket=nil) or (not TmpSocket.Connected) then // ��������
  begin
  Write_Log('InClaster',1,'���������� ������ �� �������������� ���������� ��������� ��������� �����������');
  exit;
  end;
step:=1;
resClearArray:=false;
ipAddSrv:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDIndex].ServerAddress:=TmpSocket.RemoteAddress;
ArrayClientClaster[IDIndex].ServerPort:=TmpSocket.LocalPort;
ArrayClientClaster[IDIndex].SocketHandle:=TmpSocket.SocketHandle;
ArrayClientClaster[IDIndex].InOutput:=1; // ��������
step:=2;
//--------------------------
ListTemp:=TstringList.Create;
try
if PrefixArrayToList(ListTemp) then  // ������� ������� ��������� � ������
SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // �������� ������ ���������
finally
ListTemp.Free;
end;
step:=3;
sleep(1000);
//------------------------------------------
//Write_Log('InClaster '+ipAddSrv,'������� ����� ��������� ��������� ����������� ServerAddress: '+ArrayClientClaster[IDIndex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDIndex].ServerPort));
slepengtime:=0;
while TmpSocket.Connected do
 BEGIN
 try
 sleep(ProcessingSlack);
 step:=4;
 if (TmpSocket=nil) or (not TmpSocket.Connected) then  break;
 if ArrayClientClaster[IDindex].CloseThread then break;
 step:=5;
 //---------------------------------------------------- ���� ������ ������� �������� �� ������ ���������� ���������
   if ArrayClientClaster[IDIndex].PrefixUpdate=1 then
    begin
    step:=6;
    //----------------------------------
     ListTemp:=TstringList.Create;
    try
    PrefixArrayToList(ListTemp); // ������� ������� ��������� � ������
    SendMainCryptText('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');  //������� ������ ���������
   // Write_Log('InClaster '+ipAddSrv,'�������� ������ '+TmpSocket.RemoteAddress+' '+'<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>' );
    step:=7;
      finally
      ArrayClientClaster[IDIndex].PrefixUpdate:=0; // ��������� � 0 ����� �� ����������
      ListTemp.Free;
      end;
    step:=8;
     //-----------------------------------
     if SendListServers then // ������� ������� ������� ��������
      begin
       ListTemp:=TstringList.Create;
       try
        if MyListActivServerClaster(ListTemp,ArrayClientClaster[IDindex].ServerAddress) then // �������� ������ ����� ��������� �������� �������� ��������
         begin
         SendMainCryptText('<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>');  //������� ������ ������ �������� �������� ��� �������������
        // Write_Log('InClaster '+ipAddSrv,'�������� ������ '+TmpSocket.RemoteAddress+' '+'<|SRVLST|>'+ListTemp.CommaText+'<|ENDLST|>' );
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
  //Write_Log('InClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - ������ ������ � ������ Crypt: '+CryptText);
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
   //Write_Log('InClaster '+ipAddSrv,0,TmpSocket.RemoteAddress+' - ������ ������ � ������ Decrypt: '+Buffer);
 step:=11;
 // Write_Log('InClaster '+ipAddSrv,TmpSocket.RemoteAddress+' - ������ ������ � ������ : '+Buffer);
 step:=12;
   if Buffer.Contains('<|PONG|>') then //�������� ����� �� ping
    begin
      ArrayClientClaster[IDIndex].PingEnd :=(GetTickCount - ArrayClientClaster[IDIndex].PingStart) div 2; //GetTickCount ��������� �p���, �p������� � ������� ������� �������.
      ArrayClientClaster[IDIndex].PingAnswer:=false;
    end;
step:=13;
//------------------------------------------ // ������ ��������
   if Buffer.Contains('<|SRVLST|>') then  // �������� ������ ��������
    if GetListServers then
     BEGIN     //<|SRVLST|>text<|ENDLST|>
      BufferTemp:=Buffer;
     if BufferTemp.Contains('<|ENDLST|>') then
       begin
        delete(BufferTemp,1,pos('<|SRVLST|>',BufferTemp)+9);
        ListTemp:=TstringList.Create;
        try
        ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDLST|>',BufferTemp)-1); // ����������� ������ � ���������
        //Write_Log('InClaster '+ipAddSrv,'������� ������ �������� - '+ListTemp.CommaText);
        AddReciveListServerClaster(ListTemp);
        finally
        ListTemp.Free;
        end;
       end;
     END;
//---------------------------------------  // ��������
   if Buffer.Contains('<|PRFX|>') then  // �������� ������ ���������
     begin     //<|PRFX|>Text<|ENDPRFX|>
     BufferTemp:=Buffer;
      if BufferTemp.Contains('<|ENDPRFX|>') then
       Begin
       delete(BufferTemp,1,pos('<|PRFX|>',BufferTemp)+7);
       ListTemp:=TstringList.Create;
       ListTmpLocal:=TstringList.Create;
  step:=14;
         try
         ListTemp.CommaText:=copy(BufferTemp,1,pos('<|ENDPRFX|>',BufferTemp)-1);// �������� ����� ���������
         //Write_Log('InClaster '+ipAddSrv,'ActiveCountPefix='+inttostr(ActiveCountPefix)+' length(ArrayPrefixSrv)='+inttostr(length(ArrayPrefixSrv)));
         if (ListTemp.Count)<ActiveCountPefix then // ���� ������������ ������ ��������� ������ ��� � ����, �� ����� �������� ������� ���.
           begin
           //ListTemp.Clear;
           //if PrefixArrayToList(ListTemp) then  // ������� ������� ���������
          // SendMainSocket('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>'); // �������� ������ ���������
    step:=15;
           end
         else  // ����� ������ ��������� ���� ����� ���� � ���� ������
           begin
            ParsingListPrefix(ListTemp);
           // if ParsingListPrefix(ListTemp) then // ���� ������� ���� ��������� (���� IP PSWD port � ��� �����) � ������ � ����������
            // SendMainSocket('<|PRFX|>'+ListTemp.CommaText+'<|ENDPRFX|>');// ���������� ������ ��������� �������
              // ���� ���� ��������� �� ������ �� ��� �� �� ������� ���������
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
    Write_Log('InClaster',2,'(1) ('+inttostr(step)+') ��������� ��������� ���������� ServerAddress: '+ipAddSrv{+' '+ E.ClassName+' / '+ E.Message});
    break;
    end;
  end;
  //---------------------
//--------------------------------------------------------
 END;
step:=18;
//------------------------------------------------------

//Write_Log('InClaster '+ipAddSrv,'���������� ������ ��������� ��������� ����������� ServerAddress: '+ArrayClientClaster[IDIndex].ServerAddress+' RemotePort: '+inttostr(ArrayClientClaster[IDIndex].ServerPort));
ArrayClientClaster[IDIndex].ServerAddress:='';
ArrayClientClaster[IDIndex].InOutput:=0;
ArrayClientClaster[IDIndex].SocketHandle:=0;
ArrayClientClaster[IDIndex].ServerPort:=0;
ArrayClientClaster[IDIndex].PrefixUpdate:=0;
ArrayClientClaster[IDIndex].ServerPassword:='';
ArrayClientClaster[IDIndex].CloseThread:=false;
if TmpSocket.Connected then  TmpSocket.Close;
// �������� ������� ��� ���������� � ����������

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
      Write_Log('InClaster',2,'(2) ('+inttostr(step)+') ��������� ��������� ���������� ServerAddress: '+ipAddSrv{+' '+ E.ClassName+' / '+ E.Message});
    end;
  end;

end;

end.
