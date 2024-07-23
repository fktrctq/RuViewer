unit ThReadDelete;

interface
uses
  Winapi.Windows, Winapi.WinSock,  System.SysUtils, System.Classes,  VCL.Forms, System.Win.ScktComp, System.IOUtils,Vcl.Dialogs,
   uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants, uTPLb_Signatory, uTPLb_SimpleBlockCipher
   ,System.Hash,Osher;

  type
  ThreadDeleteList = class(TThread) // ����� ��� ����������� ������
   Socket :TCustomWinSocket;
   IDConect:Byte;
   ListFileFolder:Tstringlist;
   PathDel:string;
   PswrdCrypt:string[255];
   constructor Create(aSocket: TCustomWinSocket; TempListFile:String; aPathDel:string; aPswrdCrypt:string); overload;
   procedure Execute; override;
   function DeleteFolder(s:string):boolean; // ������� �������� ��������
   function DeleteFile(s:string):boolean; // ������� �������� �����
   function SendFileSocket(s:ansistring):boolean;
   function CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
   function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
   function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
   function SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
end;




implementation
uses Form_Main,SocketCrypt,FileTransfer;







constructor ThreadDeleteList.Create(aSocket: TCustomWinSocket; TempListFile:String; aPathDel:string; aPswrdCrypt:string);
begin
  inherited Create(False);
  Socket := aSocket;
  PathDel:=aPathDel;
  PswrdCrypt:=aPswrdCrypt;
  ListFileFolder:=Tstringlist.Create;
  ListFileFolder.CommaText:=TempListFile;
  FreeOnTerminate := true;
end;


function ThreadDeleteList.CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
var
f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
begin
 try
   if NumError<=LevelLogError then // ���� ������� ������ ���� ��� �������� � ����������
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



//------------------------------------------------------
function ThreadDeleteList.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if Socket=nil then result:=false
else
begin
  if Socket.Connected then
   while Socket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do CLBLog_write('ThDelete',2,'������ �������� ������ (F) ������� ������� (F)  : '+E.ClassName+': '+E.Message);  end;
end;
//---------------------------------------------

function ThreadDeleteList.SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswrdCrypt, CryptBuf); //������� ����� ���������
SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=true;
  except On E: Exception do
    begin
    result:=false;
    s:='';
    CLBLog_write('ThDelete',2,'ERROR  - ����� � ������ ���������� � �������� ������ '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;


function ThreadDeleteList.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // ����������
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

function ThreadDeleteList.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // �����������
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

function ThreadDeleteList.DeleteFolder(s:string):boolean; // ������� �������� ��������
begin
  try
  if TDirectory.Exists(s) then // ���� ���������� �� �������
    begin
    TDirectory.Delete(s,true); // ����������� ��������
    result:=true;
    end
  else result:=false;
  except
  result:=false;
  end;
end;

function ThreadDeleteList.DeleteFile(s:string):boolean; // ������� �������� �����
begin
  try
  if TFILE.Exists(s) then // ���� ���������� �� �������
    begin
    TFILE.Delete(s);
    result:=true;
    end
  else result:=false;
  except
  result:=false;
  end;
end;

procedure ThreadDeleteList.Execute;
var
i,z:integer;
begin
try
//CLBLog_write('ThDelete',2,'������� ����� ��������');
for I := 0 to ListFileFolder.Count-1 do
  begin
   if TryStrtoInt(ListFileFolder.ValueFromIndex[i],z) then
    begin
      if z=1 then // ������� �������
       DeleteFolder(PathDel+ListFileFolder.Names[i])
       else //����� ��� ����
       DeleteFile(PathDel+ListFileFolder.Names[i]);
    end;
  end;
SendFileCryptText('<|DELETESUCCESSFULLY|>'+PathDel+'<|END|>');
//CLBLog_write('ThDelete',2,'�������� ����� ��������');
 except on E : Exception do
    begin
    SendFileCryptText('<|ERRORDELETELIST|>'+E.ClassName+': '+E.Message+'<|ENDERROR|>'); // ������� ������ �������� ������
    CLBLog_write('ThDelete',2,'ThreadDeleteList ������ ������ ��������: '+E.ClassName+': '+E.Message);
    end;
  end;
end;
end.
