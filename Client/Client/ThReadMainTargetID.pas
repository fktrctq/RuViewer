unit ThReadMainTargetID;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,System.UITypes, Vcl.Graphics, VCL.Forms,
      ComCtrls,  System.Win.ScktComp, StreamManager,Winapi.MMSystem,System.IOUtils,Vcl.ExtCtrls,
       Zlib, Form_RemoteScreen,Form_Password,Form_Chat, Form_ShareFiles,FileTransfer,Osher,FfmProgress,FormReconnect,
       System.Generics.Collections,System.Types, uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants,
      uTPLb_Signatory, uTPLb_SimpleBlockCipher,System.Hash,Comobj,ActiveX,Clipbrd,ShellApi,System.NetEncoding,HGM.Controls.Chat;


TYPE
  TThread_Connection_TargetMain = class(TThread)
    TgMainSocket: TCustomWinSocket;
    IDConect:byte;

    RecreateFileSocket:boolean; // ������� ������������� ������������� �������� ����� ���� �� ��������
    ReconnectFileSocketCount:integer;
    RecreateDesktopSocket:boolean; // ������� ������������� ������������� ����� ������� ����� ���� �� ��������
    ReconnectDesktopSocketCount:integer;
    PswrdCrypt:string[255]; // ������ ��� ����������
    constructor Create(aSocket: TCustomWinSocket; aIDConect:byte); overload;
    procedure Execute; override;
    function SendSocket(s:ansistring):boolean;
    function SendDesktopSocket(s:ansistring):boolean;
    function SendFileSocket(s:ansistring):boolean;
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function CloseTgMainSocket:boolean; // �������� ��������� ������
    function CreateDesktopSocs:boolean;   // �������� desktop ������
    function CreateFileSocs:boolean; // �������� File ������
    function FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // ����� ������ � �������
    procedure Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Desktop_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Files_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    function DeleteDesktopSockets:boolean; // �������� Desktop ������
    function DeleteFileSockets:boolean; // �������� File ������ ,
    function CloseTgFileSockets:boolean; // �������� File ������
    function CloseTgDesktopSockets:boolean; // �������� File ������
    function ApplySetConnectDesktop(Host:string;Port:integer):boolean; // ���������� �������� Desktop ������
    function ApplySetConnectFile(Host:string;Port:integer):boolean; // ���������� �������� File ������
    function ExistsTgFileSockets:boolean; // �������� ������ �� ����������
    Function ReconnectDesktop:boolean; // ��������������� Desktop ������
    procedure ReconnectFile; // ��������������� File ������
    procedure FullTgFilesSocketReconnect; //�������� � ��������������� ��������� ������
    procedure FullDesktopSocketReconnect; // ��������������� ������ �������� �����
    function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
    function SendTgMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
    function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    function ParsingTextToExpansion(Stmp:string):boolean;  // ������� ������ � ����������� ������ � ���/���� ���������������
    function LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; // ���� � ����� �� ������ ������ � ���������
    function ListFolders(Directory: string): string; // ������ ���������
    function ListFiles(FileName, Ext: string; var ListFile:TstringList): boolean;  // ������ ������ ������
    function ListLogDrive:string; // ���������� ������ ��������� ������
    function FormatByteSize(const bytes: int64): string; // �������� ������ ����� � ������������
    function GetFileSize(const aFilename: String): String;  // ������ �����  int64
    function ParsingFileDateSize(InS:string; var OutD,OutS:string):boolean;  // ������� �������� ������  "���� � �����+������"

  type
  TThread_Connection_Desktop = class(TThread)
    TgDesktopSocket: TCustomWinSocket;
    InOut:boolean;
    IDConect:byte;
    TmpHdl:integer; //handle socket
    BindSockDesktop:boolean; // ������� ����������� ������� �� �������
    PswrdCrypt:string[255]; // ������ ��� ����������
    HashPswrdCrypt:string[255];
    constructor Create(aSocket: TCustomWinSocket; aInOut:boolean; aIDConect:byte); overload;
    procedure Execute; override;
    procedure ResumeStreamXORBMP( var   FirstBMP, CompareBMP:Tbitmap; var SecondBMP:TmemoryStream;var SecondSize:int64; var TimeResume:double; var ResStr:string; var ResB:boolean);
    function SendMainSocket(s:ansistring):boolean;
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    Function CloseDesctopSocket(Mes:string):boolean;
    function DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
    function CompressStreamWithZLib(SrcStream: TMemoryStream; var TimeResume:Double): Boolean;
    function MemoryStreamToString(M: TMemoryStream): AnsiString; //������� �� ������ � ������
    function GetBindSockDesktop:boolean;  // ������ �������� �������� ���������� ������� BindSockDesktop
    Procedure SetBindSockDesktop(BindS:boolean);  //������ �������� �������� ���������� ������� BindSockDesktop
    Function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
    public
    Property BindSockD   : boolean read GetBindSockDesktop write SetBindSockDesktop; // ������ � ���������� �������� �� ������
  end;

  type
  TThread_Connection_Files = class(TThread)
    TgFileSocket: TCustomWinSocket;
    IDConect:byte;
    BindSockFiles:Boolean; // ������� ���������� �������� ������� �� �������
    PswrdCrypt:string[255]; // ������ ��� ����������
    constructor Create(aSocket: TCustomWinSocket; aIDConect:byte); overload;
    procedure Execute; override;
    procedure CloseFilesSocket;
    function SendMainSocket(s:ansistring):boolean;
    function SendFileSocket(s:ansistring):boolean;
    function SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � Files ����
    function SendMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
    function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
    function ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function GetBindSockFiles:boolean;  // ������ �������� �������� ���������� ������� BindSockFiles
    Procedure SetBindSockFiles(BindS:boolean);  //������ �������� �������� ���������� ������� BindSockFiles
    Function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
    function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
     //--------------------����� ������-------------------------------
    function ThLoadClipboardFormat(reader: TReader):boolean; //����������� ������� ������ ������
    function ThLoadClipboard(S: TStream):boolean; //�������� ������ � ����� ������
    function ThCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;// ��������������� ������� ������ � ����� � ������������ � ��������
    function ThShellWindow: HWND;
    function ThClipBoardTheFiles:boolean; // �������� ������ ������ �� ������� ������
    function ThFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean; //������� ����������� ��� � ������ ��� ��������, � ������� ������� ����������� ������ ��� ������
    //-----------------------------------------------------------------
    public
    Property BindSockF :boolean read GetBindSockFiles write SetBindSockFiles;  // ������ � ���������� �������� �� ������
  end;


   var
   Thread_Connection_Desktop: TThread_Connection_Desktop;
   Thread_Connection_Files: TThread_Connection_Files;
   Desktop_Socket: TClientSocket;
   Files_Socket: TClientSocket;
   MyIDTarget:string; // ��� ID �� ������� ������� � �������� ����������
   MyPasswordTarget:string; // ��� ������ �� ������� ������� � �������� ����������

END;




implementation
uses  PipeS,ThReadMyClipboard,Form_Main,MyClpbrd,ThReadCopyFileFolder, ThReadDelete;

constructor TThread_Connection_TargetMain.Create(aSocket: TCustomWinSocket; aIDConect:byte);
begin
  inherited Create(False);
  TgMainSocket := aSocket;
  IDConect:=aIDConect;
  RecreateFileSocket:=false; // ������� ������������ ��������� ������
  ReconnectFileSocketCount:=0;// ������� ���-�� ��������������� ��������� ������
  RecreateDesktopSocket:=false; // ������� ������������ ������ �������� �����
  ReconnectDesktopSocketCount:=0;// ������� ���-�� ��������������� ������ �������� �����
  FreeOnTerminate := true;
end;


constructor TThread_Connection_TargetMain.TThread_Connection_Desktop.Create(aSocket: TCustomWinSocket; aInOut:boolean; aIDConect:byte);
begin
  inherited Create(False);
  TgDesktopSocket := aSocket;
  IDConect:=aIDConect;
  InOut:=aInOut;
  BindSockDesktop:=false; //������� ���������� ������� �� �������
  TmpHdl:=TgDesktopSocket.Handle;
  FreeOnTerminate := true;
end;

function  TThread_Connection_TargetMain.TThread_Connection_Desktop.GetBindSockDesktop:boolean; // ������ �������� �������� ���������� �������
begin
 result:=BindSockDesktop;
end;

Procedure  TThread_Connection_TargetMain.TThread_Connection_Desktop.SetBindSockDesktop(BindS:boolean); // ������ �������� �������� ���������� �������
begin
 BindSockDesktop:=BindS;
end;


constructor TThread_Connection_TargetMain.TThread_Connection_Files.Create(aSocket: TCustomWinSocket; aIDConect:byte);
begin
  inherited Create(False);
  TgFileSocket := aSocket;
  IDConect:=aIDConect;
  BindSockFiles:=false; //������� ���������� ������� �� �������
  FreeOnTerminate := true;
end;

function  TThread_Connection_TargetMain.TThread_Connection_Files.GetBindSockFiles:boolean; // ������ �������� �������� ���������� �������
begin
 result:=BindSockFiles;
end;

Procedure  TThread_Connection_TargetMain.TThread_Connection_Files.SetBindSockFiles(BindS:boolean); // ������ �������� �������� ���������� �������
begin
 BindSockFiles:=BindS;
end;
//--------------------------------------------------
function TThread_Connection_TargetMain.FormatByteSize(const bytes: int64): string; // �������� ������ ����� � ������������
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

function TThread_Connection_TargetMain.GetFileSize(const aFilename: String): String;  // ������ �����  int64
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

function TThread_Connection_TargetMain.LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string;
begin
try
 if FileOrFolder then result:=DateTimeToStr(TFile.GetLastWriteTime(s))
 else result:=DateTimeToStr(TDirectory.GetLastWriteTime(s));
except result:=''  end;
end;

// Function to List Folders
function TThread_Connection_TargetMain.ListFolders(Directory: string): string; // ������ ���������
var
  FileName: string;
  Filelist: string;
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
          Dirlist.add(FileName+'='+LastWriteTimeFileOrFolder(Directory+FileName,false)); // ��� ��������=���� ���������
        end;
      until FindNextFile(FindHandle, Searchrec) = False;
  finally
    Winapi.Windows.FindClose(FindHandle);
    if Dirlist.Count>0 then result:=Dirlist.CommaText
    else result:='';
    Dirlist.Free;
  end;
  except on E : Exception do ThLog_Write('ThMT',2,'������ ListFolders: '+E.ClassName+': '+E.Message);  end;
end;

// Function to List Files
function TThread_Connection_TargetMain.ListFiles(FileName, Ext: string; var ListFile:TstringList): boolean;  // ������ ������ ������
var
  SearchFile: TSearchRec;
  FindResult: Integer;
begin
 try
  FindResult := FindFirst(FileName + Ext, faArchive, SearchFile);
  try
    while FindResult = 0 do
    begin
      ListFile.Add(SearchFile.Name+'='+LastWriteTimeFileOrFolder(FileName+SearchFile.Name,true)+'='+GetFileSize(FileName+SearchFile.Name));  // ��� �����=���� ���������
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
  ThLog_Write('ThMT',2,'������ ListFiles: '+E.ClassName+': '+E.Message);
  end;
 end;
end;

function TThread_Connection_TargetMain.ParsingFileDateSize(InS:string; var OutD,OutS:string):boolean;  // ������� �������� ������  "���� � �����+������"
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

function TThread_Connection_TargetMain.ListLogDrive:string; // ���������� ������ ��������� ������
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
     DRIVE_UNKNOWN{0}:result:=8; // ����������� ����
     DRIVE_NO_ROOT_DIR {1}:result:=8;//�� ������ ������ �����
     DRIVE_REMOVABLE{2}:result:=4;// usb ����
     DRIVE_FIXED{3}:result:=2;//��������� ���� �� HDD
     DRIVE_REMOTE{4}:result:=6;// ������� ����
     DRIVE_CDROM{5}:result:=5;// cd/DVD rom
     DRIVE_RAMDISK{6}:result:=7;// RAM ����
     else result:=2;
    end;
    if GetSysDir(s) then result:=3; // ���� ��� ���� � ������������� ��
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
  except on E : Exception do ThLog_Write('ThMT',2,'������ ListlogDrive: '+E.ClassName+': '+E.Message);  end;
END;

//----------------------------------------------------------------------------------------------------
// ��������� � ������� ��������� ������
//------------------------------------------------------------------------------------------------------
function TThread_Connection_TargetMain.CreateDesktopSocs:boolean;   // �������� desktop ������
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
    ThLog_Write('ThMT',2,'�������� (TD) ������');
    end;
  end;
end;

function TThread_Connection_TargetMain.CreateFileSocs:boolean;   // �������� file ������
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
    ThLog_Write('ThMT',2,'�������� (TF) ������ ');
    end;
  end;
end;
//-------------------------------------------------------------------------------------------------------
Function TThread_Connection_TargetMain.ReconnectDesktop:boolean; // ��������������� Desktop ������
begin
try
 result:=false;
 if Desktop_Socket<>nil then
 begin
  if not Desktop_Socket.Active then
    begin
    Desktop_Socket.Active:=true;
    result:=true;
    end;
 end;
  ThLog_Write('ThMT',1,'��������������� (TD) ������: '+Desktop_Socket.Host+':'+inttostr(Desktop_Socket.Port));
 except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThMT',2,'��������������� (TD) ������');
    end;
  end;
end;

procedure TThread_Connection_TargetMain.ReconnectFile; //
begin
try
 if Files_Socket<>nil then
  if not Files_Socket.Active then
   Files_Socket.Active:=true;
   ThLog_Write('ThMT',1,'��������������� (FT) ������: '+Files_Socket.Host+':'+inttostr(Files_Socket.Port));
 except on E : Exception do
    begin
    ThLog_Write('ThMT',2,'��������������� (FT) ������');
    end;
  end;
end;
//-----------------------------------------------------------------------------------------------------------
function TThread_Connection_TargetMain.CloseTgMainSocket:boolean; // �������� Main ������
begin
try
  if TgMainSocket<>nil then
  begin
  if TgMainSocket.Connected then  TgMainSocket.Close;
  if TgMainSocket<>nil then TgMainSocket.Free;
  end;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThMT',2,'�������� (MT) ������');
  end;
  end;
end;

function TThread_Connection_TargetMain.ApplySetConnectDesktop(Host:string;Port:integer):boolean; // ���������� �������� Desktop ������
begin
  try
    Desktop_Socket.Host := Host;
    Desktop_Socket.Port := Port;
    frm_Main.ResolutionTargetWidth := screen.Width-((screen.Width div 100)*40);
    frm_Main.ResolutionTargetHeight := screen.Height-((screen.Height div 100)*40);;
    frm_Main.ResolutionTargetLeft:=0;
    frm_Main.ResolutionTargetTop:=0;
    frm_Main.MonitorCurrent:=0;
    frm_Main.ImagePixelF:=pf8bit;
    result:= ReconnectDesktop;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThMT',2,'���������� ��������  (DT) ������ ');
    end;
  end;
end;

function TThread_Connection_TargetMain.ApplySetConnectFile(Host:string;Port:integer):boolean; // ���������� �������� File ������
begin
  try
    Files_Socket.Host := Host;
    Files_Socket.Port := Port;
    // ThLog_Write('ThMT','MESSAGE ���������� �������� ������ (FT): '+Host+':'+inttostr(port));
    ReconnectFile;  // ��������������� File ������
    result:=true;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('ThMT',2,'���������� �������� (FT) ������ ');
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------

function TThread_Connection_TargetMain.DeleteDesktopSockets:boolean; // �������� Desktop ������
begin
try
  if Desktop_Socket<>nil then
  begin
  if Desktop_Socket.Active then Desktop_Socket.Close;
  if Desktop_Socket<>nil then Desktop_Socket:=nil;
  end;
result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThMT',2,'�������� (DT) ������');
  end;
  end;
end;

function TThread_Connection_TargetMain.DeleteFileSockets:boolean; // �������� File ������
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
    ThLog_Write('ThMT',2,'�������� (FT) ������');
  end;
  end;
end;

function TThread_Connection_TargetMain.CloseTgFileSockets:boolean; // �������� File ������
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
    ThLog_Write('ThMT',2,'�������� (FT) ������');
  end;
  end;
end;

function TThread_Connection_TargetMain.CloseTgDesktopSockets:boolean; // �������� File ������
begin
try
   if Desktop_Socket<>nil then
  begin
  if Desktop_Socket.Active then Desktop_Socket.Close;
  end;
  result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThMT',2,'�������� (DT) ������');
  end;
  end;
end;

function TThread_Connection_TargetMain.ExistsTgFileSockets:boolean; // �������� ������ �� ����������
begin
try
result:=false;
  if Files_Socket<>nil then
  if Files_Socket.Active then result:=true;
 except on E : Exception do
    begin
  result:=false;
    ThLog_Write('ThMT',2,'�������� ���������� ������ (FT)');
  end;
  end;
end;

procedure TThread_Connection_TargetMain.FullTgFilesSocketReconnect;
var
Exist:boolean;
begin
//ThLog_Write('ThM',' ������������ ������ (F)');
  try
      try
      Exist:=false;
        if Files_Socket<>nil then
        if Files_Socket.Active then Exist:=true;
       except on E : Exception do
        begin
        Exist:=false;
        //ThLog_Write('ThMT',' (1) ��������� �������� ������ (F): '+E.ClassName+': '+E.Message);
        end;
        end;
  if not Exist then // ���� ����� �� ��������
     begin
     DeleteFileSockets;   // ������� �������, ����� �� �������
     if CreateFileSocs then  // ������� ����� File
     ApplySetConnectFile(frm_Main.ArrConnectSrv[IDConect].SrvAdr,frm_Main.ArrConnectSrv[IDConect].SrvPort); // ��������� ��������� File ������ � ������������
     end;
  except on E : Exception do
    begin
    ThLog_Write('ThMT',2,'��������� �������� ������ (FT)');
    end;
   end;
end;

procedure TThread_Connection_TargetMain.FullDesktopSocketReconnect;
var
Exist:boolean;
begin
ThLog_Write('ThMT',1,' ������������ ������ (DT)');
  try
      try
      Exist:=false;
        if Desktop_Socket<>nil then
        if Desktop_Socket.Active then Exist:=true;
        //if Exist then ThLog_Write('ThMT',' ������������ ������ (DT). Desktop_Socket.Active=true')
       //else ThLog_Write('ThMT',' ������������ ������ (DT). Desktop_Socket.Active=false')
       except on E : Exception do
        begin
        Exist:=false;
        ThLog_Write('ThMT',2,' (1) ��������� �������� ������ (DT) ');
        end;
        end;
  //if not Exist then // ���� ����� �� ��������
     begin
     DeleteDesktopSockets;   // ������� �������, ����� �� �������
     if CreateDesktopSocs then  // ������� ����� desktop
     begin
     //ThLog_Write('ThMT',' ������������ ������ (DT). ������� ����� (DT)');
    ApplySetConnectDesktop(frm_Main.ArrConnectSrv[IDConect].SrvAdr,frm_Main.ArrConnectSrv[IDConect].SrvPort);  // ��������� ��������� Desktop ������ � ������������
     //ThLog_Write('ThMT',' ������������ ������ (DT). ��������� ��������� ������ (DT)');
     end;
     end;
  except on E : Exception do
    begin
    ThLog_Write('ThMT',2,'(2) ��������� �������� ������ (DT)');
    end;
   end;
end;

//--------------------------------------------------------------------------------------------------------
procedure TThread_Connection_TargetMain.Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
Buffer,CryptBuf,DeCryptBuf,CryptText:string;
TimeOutExit:integer;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////PswdServer - ��� ����������� ������������ ������ ������� ��� ���������� � �����������
begin
Encryptstrs(s,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,CryptBuf);
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(ProcessingSlack);
end;

function SDecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
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
    ThLog_Write('ThMT',2,'Files_Connect ������ ���������� ������ ');
     s:='';
    end;
  end;
end;

begin    //���� ����������, �� ��������� MyID ��� ������������� �� ������� ��� �������� ������ � ������� �����
  try
  TimeOutExit:=0;
  if FindArraysrv(Socket.RemoteAddress,IndexArr) then // ���� �������� ������ ������� �� ������� �����
     begin                          //MyIDTarget
     SendCrypText('<|FILESSOCKET|>'+frm_Main.ArrConnectSrv[IndexArr].MyID+'<|END|>'+frm_Main.ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>'); // ������� ����� ��� �������� ������
     end
   else
     begin
     ThLog_Write('ThMT',1,'����������� (FT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������� ��������� ������� ������� �����������, ��������� ����������� � �������');
     Socket.Close;
     exit;
     end;

  while True do
   begin
    Application.ProcessMessages; // ����� �� ������� ���
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
   if TimeOutExit>1050 then // �������� 10 ���
    begin
    ThLog_Write('ThMT',1,'����������� (FT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������');
    Socket.Close; // ��������� ���������� � �������� ��� �������� ����� 10 ���
    exit;
    end;
    if Socket.ReceiveLength < 1 then  Continue;
    if not Socket.Connected then break;

    DeCryptBuf:= Socket.ReceiveText;

     while not DecryptBuf.Contains('<!!>') do // �������� ����� ������
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
   // ThLog_Write('ThMT',2,'������� ����� (F) �� �����������: '+DecryptBuf);
    Buffer:=SDecryptReciveText(DecryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd);
   // Decryptstrs(DeCryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // ����������
   // ThLog_Write('ThMT',2,'������� ����� (F) ����� �����������: '+Buffer);
    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
       //ThLog_Write('ThMT','�������� ����� (FT). ������ '+ Socket.RemoteAddress);
       frm_Main.ArrConnectSrv[IndexArr].FilesSock:=socket;
       Thread_Connection_Files := TThread_Connection_Files.Create(Socket,IndexArr); // �������� �������� ������ � �����
       break; // ����� �� �����
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
      begin
      ThLog_Write('ThMT',1,'����������� (FT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������� ���������� ������ ��� ����������� � �������');
      Socket.Close;
      exit;
      end;
   TimeOutExit:=TimeOutExit+ProcessingSlack;
   end;

  ///Log_Write('appT','Files_Socket ���������� �����������, Thread_Connection_Files - �������');
  except on E : Exception do
   ThLog_Write('ThMT',2,'����������� ������ (FT): '+E.ClassName+': '+E.Message);
  end;
end;

procedure TThread_Connection_TargetMain.Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
ThLog_Write('ThMT',1,'������ ������ (FT) : ' + SysErrorMessage(ErrorCode));
ErrorCode := 0;
except on E : Exception do
  ThLog_Write('ThMT',2,'������ ������ (FT)');
  end;
end;

procedure TThread_Connection_TargetMain.Files_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
  if Thread_Connection_Files<>nil then Thread_Connection_Files.Terminate; // ������� ���������� ������
  if ReconnectFileSocketCount>10 then  //�� ���� ����� ����� �� ����� 11 ���������� ������� �������� ������ ��� �� disconnect
  begin
  RecreateFileSocket:=false; // ������� ������� ������������� ������������ ��������� ������
  ReconnectFileSocketCount:=0; // �������� ������� ���-�� ��������������� ��������� ������
  end;
  if RecreateFileSocket then
   begin
   FullTgFilesSocketReconnect; //���� � ���� ������ ����� ������� ������������ ������ ���� �� ���������� �� ������� ���������� ��������
   inc(ReconnectFileSocketCount);
   end
   else CloseTgFileSockets;  // ����� ��������� �������� �����
   //ThLog_Write('ThMT','���������� ������ (FT): ');
  except on E : Exception do
   ThLog_Write('ThMT',2,'���������� ������ (FT): '+E.ClassName+': '+E.Message);
  end;
end;

//------------------------------------------------------------------------------------------------------------------
procedure TThread_Connection_TargetMain.Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
TimeOutExit:integer;
buffer,CryptBuf,DeCryptBuf,CryptText:string;
IndexArr:byte;

function SendCrypText(s:string):boolean; ////PswdServer - ��� ����������� ������������ ������ ������� ��� ���������� � �����������
begin
Encryptstrs(s,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,CryptBuf);
while Socket.SendText('<!>'+CryptBuf+'<!!>')<0 do sleep(ProcessingSlack);
end;
function SendNoCrypText(s:string):boolean;
begin
Socket.SendText(s);
end;

function SDecryptReciveText(s,pswd:string):string; // ������� ����������� ���������� ������ �� ������
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
    ThLog_Write('ThMT',2,'Desctop_Connect ������ ���������� ������ ');
     s:='';
    end;
  end;
end;

begin
try
  TimeOutExit:=0;
 //  ���� ����������, �� ��������� MyIDTarget ��� ������������� �� ������� � ������� �����
  if FindArraysrv(Socket.RemoteAddress,IndexArr) then // ���� �������� ������ ������� �� ������� �����
     begin                              //MyIDTarget
     SendCrypText('<|DESKTOPSOCKET|>'+frm_Main.ArrConnectSrv[IndexArr].MyID+'<|END|>'+frm_Main.ArrConnectSrv[IndexArr].SrvPswd+'<|SRVPSWD|>');
     end
   else
     begin
     ThLog_Write('ThMT',1,'����������� (DT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������� ��������� ������� ������� �����������, ��������� ����������� � �������');
     Socket.Close;
     exit;
     end;
  while True do
   begin
    Application.ProcessMessages; // ����� �� ������� ���
    Sleep(ProcessingSlack);
    TimeOutExit:=TimeOutExit+ProcessingSlack;
   if TimeOutExit>1050 then // �������� 10 ���
      begin
      ThLog_Write('ThMT',1,'����������� (DT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������������');
      Socket.Close; // ��������� ���������� � �������� ��� �������� ����� 10 ���
      exit;
      end;
    if Socket.ReceiveLength < 1 then  Continue;
    if not Socket.Connected then break;

    DeCryptBuf:=Socket.ReceiveText;
     while not DecryptBuf.Contains('<!!>') do // �������� ����� ������
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
    // ThLog_Write('ThMT',2, '����� (D) �� �����������: '+DecryptBuf );
    Buffer:=SDecryptReciveText(DecryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd);
    //DeCryptstrs(DeCryptBuf,frm_Main.ArrConnectSrv[IndexArr].SrvPswd,Buffer);  // ����������
   // ThLog_Write('ThMT',2, '����� (D) ����� �����������: '+Buffer);

    if Pos('<|ACCESSALLOWED|>', Buffer)> 0 then
      begin
      // ThLog_Write('ThMT','�������� ����� (DT). ������ '+ Socket.RemoteAddress);
      frm_Main.ArrConnectSrv[IndexArr].DesktopSock:=socket;
      Thread_Connection_Desktop := TThread_Connection_Desktop.Create(Socket,true,IndexArr); // ������� ������� ����� (Desktop_Socket) ��� �������� � ������ ��������
      frm_Main.CurrentActivMainSocket:=IndexArr; //��� connect desktop ����������� ������� ������� ������� ��� ������� � �������� ������ ����������, ��� disconnect desktop �������� -1, �.�. ����� ��� ���������� �� ��������
      break; // ����� �� �����
      end;
    if Pos('<|NOCORRECTPSWD|>', Buffer)> 0 then
       begin
       ThLog_Write('ThMT',1,'����������� (DT) � ������� '+ Socket.RemoteAddress+' ������������ ��-�� ������� ���������� ������ ��� ����������� � �������');
       Socket.Close;
       exit;
       end;
   TimeOutExit:=TimeOutExit+ProcessingSlack;
   end;

 // Log_Write('appT','Desktop_Socket ���������� �����������, Thread_Connection_Desktop - �������');
  except on E : Exception do
  ThLog_Write('ThMT',2,'����������� ������ (DT): '+E.ClassName+': '+E.Message);
  end;
  end;

procedure TThread_Connection_TargetMain.Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
try
ThLog_Write('ThMT',1,'������ ������ (DT): ' + SysErrorMessage(ErrorCode));
ErrorCode := 0;
 except on E : Exception do
   ThLog_Write('ThMT',2,'������ ������ (DT) ');
  end;
end;

procedure TThread_Connection_TargetMain.Desktop_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
try
    if Thread_Connection_Desktop<>nil then
  begin
  //ThLog_Write('ThMT','Thread_Connection_Desktop<>nil �� Desktop_SocketDisconnect');
  Thread_Connection_Desktop.Terminate; // ������� ���������� ������
  end;

  if ReconnectDesktopSocketCount>10 then // ���� ���������� ���������� ���-�� �������������� ��� ����� ������
  begin
   RecreateDesktopSocket:=false;
   ThLog_Write('ThMT',1,' ������������ ������ (D). ���-�� �������� ����������� ��������� ����������');
  end;

  if RecreateDesktopSocket then
   begin
    //ThLog_Write('ThMT','��������������� ������ (D) �� Desktop_SocketDisconnect');
    Synchronize(FReconnect.Show); // ���������� ������ ��������������� �������� �����
    FullDesktopSocketReconnect;
    inc(ReconnectDesktopSocketCount);  // ���������� ���-�� ��������������� ������
   end
   else
   begin
   if FReconnect.Visible then Synchronize(FReconnect.Close); // ��������� ������ ��������������� �������� ����� ���� �� ������
   if frm_RemoteScreen.Visible then // ���� ����� ������� �� ���������
      begin
       Synchronize(
       procedure
         begin
         if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
         frm_ShareFiles.Hide;
         frm_Chat.Hide;
         frm_Main.SetOnline;
         frm_Main.Status_Label.Caption := '� ����';
         if not frm_Main.Visible then
           begin
           frm_Main.Show;
           end;
         end);
      end
     else // ����� � �������, ��� ���� ��� �������, ��������� �� ������ ������� ������ �����
      SendTgMainCryptText('<|STOPACCESS|>'); // ���������� � ������� ����� ������� ������� �����
      //
   frm_Main.Viewer:=false;   //�������� ������� �������� ���� ���������� ���� � �������� ���������
   frm_Main.Accessed := False; //�������� ������� ���������� ������� ���� � ������
   //ThLog_Write('ThMT','�������� ������ (D) � (F) �� Desktop_SocketDisconnect');
   RecreateFileSocket:=false; // �������� ������� ������������� ������������ ��������� ������ ��� ��� �������
   CloseTgFileSockets; // ��������� �������� �����
   RecreateDesktopSocket:=false; // �������� ������� ������������� ������������ ������ �������� ����� ��� ��� �������
   CloseTgDesktopSockets; // ��������� ����� �������� ����
   if frm_RemoteScreen.Visible then frm_RemoteScreen.Close;
   end;
   frm_Main.CurrentActivMainSocket:=-1; //��� connect desktop ����������� ������� ������� ������� ��� ������� � �������� ������ ����������, ��� disconnect desktop �������� -1, �.�. ����� ��� ���������� �� ��������
 except on E : Exception do
  begin
   ThLog_Write('ThMT',2,'���������� ������ (DT)');
   frm_Main.CurrentActivMainSocket:=-1; //��� connect desktop ����������� ������� ������� ������� ��� ������� � �������� ������ ����������, ��� disconnect desktop �������� -1, �.�. ����� ��� ���������� �� ��������
  end;
  end;
end;

//------------------------------------------------------------------------------------------------
function TThread_Connection_TargetMain.FindArraysrv(AddrSrv:string; var NextIndex:byte):boolean; // ����� ������ � �������
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
  ThLog_Write('ThMT',2,' FindRecordClient');
  result:=false;
  end;
end;
end;
//------------------------------------------------------------------------------------------
// ���������� ��������� �����

function TThread_Connection_TargetMain.SendDesktopSocket(s:ansistring):boolean;
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
except on E : Exception do ThLog_Write('ThMT',2,'�������� ������ (D) ������� ������� ');  end;
end;


function TThread_Connection_TargetMain.SendSocket(s:ansistring):boolean;
begin
try
result:=true;
if TgMainSocket=nil then result:=false
else
begin
  if TgMainSocket.Connected then
   while TgMainSocket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_Write('ThMT',2,'������ �������� ������ (�) ������� �������');  end;
end;
//--------------------------------------------------------------------
function TThread_Connection_TargetMain.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IdConect].FilesSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IdConect].FilesSock.Connected then
   while frm_Main.ArrConnectSrv[IdConect].FilesSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_write('ThMT',2,'�������� ������ (�) ������� �������' );  end;
end;
//----------------------------------------------------------------------
function TThread_Connection_TargetMain.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
         if FileExists(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log') then
        f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
        f.Add(DateTimeToStr(Now)+chr(9)+TypeError[NumError]+chr(9)+TextMessage);
        while f.Count>1000 do f.Delete(1);
          f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
        finally
          f.Destroy;
        end;
      End;
  except exit; end;
end;
//----------------------------------------

function TThread_Connection_TargetMain.SendTgMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
if Encryptstrs(s,PswrdCrypt, CryptBuf) then  //������� ����� ���������
begin
SendSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
end
else ThLog_Write('ThMT',1,'����� �T �� ������� ����������� ������');
result:=true;
  except On E: Exception do
    begin
    result:=false;
    s:='';
    ThLog_Write('ThMT',2,'����� �T ������ ���������� � �������� ������ ');
    end;
  end;
end;


function TThread_Connection_TargetMain.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
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
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //���������� ������������� ������
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
    ThLog_Write('ThMT',2,'����� � ������ ���������� ������ ');
   //ThLog_Write('ThMT','ERROR  - ����� � ������ ���������� ������ ������ - '
   // +PswrdCrypt+' s='+s+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp+
   // ' CryptTmp='+CryptTmp);

     s:='';
    end;
  end;
end;

function TThread_Connection_TargetMain.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // ����������
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

function TThread_Connection_TargetMain.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // �����������
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


function TThread_Connection_TargetMain.ParsingTextToExpansion(Stmp:string):boolean;  // ������� ������ � ����������� ������ � ���/���� ���������������
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

    Position := Pos('<|RESIZES|>', TempText); //���������� �������� �� ���������������
    if position>0 then
    begin
      Delete(TempText, 1, Position + 10);
      if TryStrToInt(Copy(TempText, 1, 1),TmpNum) then
      if TmpNum=1 then frm_Main.ScreenResizes :=true
       else frm_Main.ScreenResizes :=false;
    end;

    if (frm_Main.ResolutionResizeWidth=0)or(frm_Main.ResolutionResizeHeight=0)  then //���� ������ �� ����������, �.�. � ���������� ���� ������� ��������
     result:=false
     else result:=true;
    except on E : Exception do
      begin
      Result := false;
      ThLog_Write('ThMT',2,'ParsingTextToExpansion ����� (M) : '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
      end;
    end;
  end;

//------------------------------------------------------
procedure TThread_Connection_TargetMain.Execute;
var
  Buffer,DeCryptBuf,DeCryptRedirect: string;
  BufferTemp,DeCryptBufTemp: string;
  KeyTemp,TempI,TempZ:string;
  i: Integer;
  Position,TmpNum: Integer;
  FoldersAndFiles: TStringList;
  L: TListItem;
  FileToUpload: TFileStream;
  step:integer;
  pixF:byte;
  TargetSeverIP:string;
  TargetServerPort:integer;
  TargetServerPswd:string;
  TargetIDTmp:string;
  mesg:string;
  iViewer:boolean;  // ������� ���� ��� � ����������� � ��������

function ReciveDecodeBase64(mes:string):string;
begin
try
result:=TNetEncoding.Base64.Decode(mes);
except On E: Exception do
    begin
    result:='';
    ThLog_Write('ThMT',2,'������ ReciveDecodeBase64');
    end;
  end;
end;


Begin
  inherited;
try
 // ThLog_Write('ThMT','����� (TM) �������');
  PswrdCrypt:=frm_Main.ArrConnectSrv[IDConect].SrvPswd; // ����������� ������ ��� ���������� � ������
  frm_Main.ArrConnectSrv[IDConect].CurrentPswdCrypt:=frm_Main.ArrConnectSrv[IDConect].SrvPswd; // ����������� ������ ��� ���������� � ���������� ������

  FoldersAndFiles := nil;
  FileToUpload := nil;
step:=1;
  SendTgMainCryptText('<|GETMYID|><|RUNPING|>'); // ����������� ���� ID � ������ PING
 WHILE (not terminated) and (TgMainSocket.Connected)  DO
    BEGIN
      Sleep(ProcessingSlack); // Avoids using 100% CPU
      if (TgMainSocket = nil)  then break;
      if not(TgMainSocket.Connected) then break;
  step:=2;
      if TgMainSocket.ReceiveLength < 1 then Continue;
  step:=3;

      DeCryptBuf := TgMainSocket.ReceiveText;   //����������� ������ ��������� � ������� �����
      if DeCryptBuf.Contains('<!>') then   // ������ ������ ������
      while not DeCryptBuf.Contains('<!!>') do // �������� ����� ������
      begin
      if terminated then break;
      Sleep(ProcessingSlack);
      if TgMainSocket.ReceiveLength < 1 then Continue;
      DeCryptBufTemp := TgMainSocket.ReceiveText;
      DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
      end;
      Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������

  step:=4;
      // Received data, then resets the timeout
      frm_Main.Timeout := 0;
   step:=5;
        // ���� �������� ������������� � ������ � �������
      Position := Pos('<|ID|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;  // �������� ����� �� ���������
        Delete(BufferTemp, 1, Position + 5);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ArrConnectSrv[IDConect].MyID:=Copy(BufferTemp, 1, Position - 1);
        MyIDTarget := frm_Main.ArrConnectSrv[IDConect].MyID;
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ArrConnectSrv[IDConect].MyPswd:=Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        MyPasswordTarget  := frm_Main.ArrConnectSrv[IDConect].MyPswd;
      //  ThLog_Write('ThMT','MyIDTarget='+MyIDTarget+' MyPasswordTarget='+MyPasswordTarget);
       end;
  step:=6;
  step:=7;
      // Ping /���� ���������� ��� �� ��� ���� ��� ��������
      if Buffer.Contains('<|PING|>') then
      begin
       SendTgMainCryptText('<|PONG|>');
      end;
       step:=8;
      Position := Pos('<|SETPING|>', Buffer); // �������� ��������
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        frm_Main.ArrConnectSrv[IDConect].MyPing := StrToInt(BufferTemp);
      end;
  step:=9;
  //------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------

       if Buffer.Contains('<|SRVIDEXISTS!REQUESTPASSWORD|>') then  // ��������������� �� ������ ������
      begin    //<|SRVIDEXISTS!REQUESTPASSWORD|>+TargetServerAddress+<|TSA|>+inttostr(TargetServerPort)+<|TSP|>+TargetServerPSWD+<TSPSWD>
      BufferTemp:=Buffer;
      Delete(BufferTemp, 1, pos('<|SRVIDEXISTS!REQUESTPASSWORD|>',BufferTemp)+30);
       if Pos('<|TSA|>', BufferTemp)>0 then // ���� � ����� �������� IP ������� TargetID
        Begin
         TargetSeverIP:='';
         TargetServerPort:=0;
         TargetServerPswd:='';
         TargetSeverIP := Copy(BufferTemp, 1, Pos('<|TSA|>', BufferTemp) - 1);
         Delete(BufferTemp, 1, pos('<|TSA|>',BufferTemp)+6);
         if Pos('<|TSP|>', BufferTemp)>0 then  // ���� ������� �������� ID
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
          if (TargetSeverIP<>'') then //������ ����������� ������ � �������� ID,  ���������� ���������������
            begin
            TargetIDTmp:= frm_Main.TargetID_MaskEdit.Text; // ������� ID � �������� ������������
            //ThLog_Write('ThMain',TargetSeverIP+' ����='+inttostr(TargetServerPort)+' ������ �������='+TargetServerPswd+' TargetIDTmp - '+TargetIDTmp);
            frm_Main.ReconnectTargetIDServer(TargetSeverIP,TargetServerPort,TargetIDTmp,TargetServerPswd);// ����������� TArgetSocket
            end;
         End;
        end;
     step:=10;
   //----------------------------------------------------------------------------------------------
        if Buffer.Contains('<|MYIDEXISTS!REQUESTPASSWORD|>') then // ���� ������� �� ���� ������� ��������� ����� ����� ������
      begin    //<|IDEXISTS!REQUESTPASSWORD|>
      BufferTemp:=Buffer;
      Delete(BufferTemp, 1, pos('<|MYIDEXISTS!REQUESTPASSWORD|>',BufferTemp)+29);
          Synchronize(
            procedure
            begin
             frm_Password.Tag:=IDConect;
             frm_Main.Status_Label.Caption := '�������������...';
             frm_Password.ShowModal; // ������ ����� ������
            end);
        end;
    step:=11;
   //------------------------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|ACCESSGRANTEDMAIN|>') then  //������ ������� ��� ������ �������� ������ ����� �������� ������
      begin // ������ � ��������� ������� �� ����������� � ��������, �.�. ������� ID ����� ������
        iViewer:=true; // � ����������� � �������� ��� ����������
        frm_RemoteScreen.Tag:=IDConect; // ����������� ����� �������� ������� ��� ������� � ��������� ������ �� ����� ����������

        SendTgMainCryptText('<|REDIRECT|><|CREATESOCKDESKTP|>'); //������ � ��������� �������� �� ������, �������� ��� � ������������� ������� ������ ������� �����
        FullDesktopSocketReconnect; // ��������/������������ ������ �������� �����
        ReconnectDesktopSocketCount:=0; // ������� ���-�� ������������  ������ �������� �����


        SendTgMainCryptText('<|REDIRECT|><|CREATESOCKFILES|>');  // ���������� ������ �������� �� ������� ��������� ������
        FullTgFilesSocketReconnect; // ��������/������������ ��������� ������
        ReconnectFileSocketCount:=0; // ������� ���-�� ������������ ��������� ������
        RecreateFileSocket:=true; // ������� ������������� ������������ ��������� ������ ��� ��� �������
        Synchronize(
            procedure
            begin
              frm_Main.Status_Label.Caption := '��������������...';
            end);

      end;
     step:=12;
    //--------------------------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|IDNOTEXISTS|>') then
      begin
      frm_Main.InMessage('���������� ID �� ����������.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����.';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
       iViewer:=false;// ��� � ���� �������� � �� ��� ����� �����������
       SendTgMainCryptText('<|STOPACCESS|>');
       break;
      end;

   step:=14;
  //------------------------------------------------------------------------------------------
    step:=15;
      if Buffer.Contains('<|ACCESSDENIED|>') then
      begin
      frm_Main.InMessage('�� ������ ������.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����.';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
       iViewer:=false;// ��� � ���� �������� � �� ��� ����� �����������
       SendTgMainCryptText('<|STOPACCESS|>');
       break;
      end;
  step:=16;
      if Buffer.Contains('<|ACCESSBUSY|>') then
      begin
      frm_Main.InMessage('����������� ����������� ������. ��������� ������� ������������.',0);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����.';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// ��� � ���� �������� � �� ��� ����� �����������
        SendTgMainCryptText('<|STOPACCESS|>');
        break;
      end;
  step:=17;

  //----------------------------------------------------------------------------------------
       if Buffer.Contains('<|ACCESSDENIEDDESKTOP|>') then
      begin
      frm_Main.InMessage('�� ������� �������� ���������� ������� ������. ��������� ������� ������������.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����.';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// ��� � ���� �������� � �� ��� ����� �����������
        SendTgMainCryptText('<|STOPACCESS|>');
        break;
      end;
  step:=18;
      if Buffer.Contains('<|ACCESSDENIEDFILES|>') then
      begin
      frm_Main.InMessage('�� ������� �������� �������� ������. ��������� ������� ������������.',1);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����.';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
         SendTgMainCryptText('<|STOPACCESS|>');
        break;
      end;
  step:=19;
   //----------------------------------------------------------------------------------------------------
   //---------------------------������ � ������� �������� �����------------------------------------------------
      if Buffer.Contains('<|DSKTPCREATED|>') then  //���� ������ ��� ������� ��� ������ ������ �������� �����, , ������������ ��� �������� ������ ��������� ������ �������� �����
        begin // �������� ������� � ������������� ������� ������ �������� �����
        if iViewer then // ���� � ����������� � ��������, �� ����� ������ ������� ������ �������� �����
         begin
          if Thread_Connection_Desktop<>nil then // ���� desktop ����� ����������
            begin
            if Thread_Connection_Desktop.Started then  // ���� desktop ����� �������
               begin
                if not Thread_Connection_Desktop.BindSockD then //� ���� � ������ ��� �������� ����� ������� �� �������
                  begin //������ ����� ��������� � ������ ���, ������ ������ ������� ������
                  SendTgMainCryptText('<|BINDDSKTPSOCK|>'+frm_Main.ArrConnectSrv[IDConect].MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>');
                  if frm_Main.Visible then // ���� ���� �������
                    begin
                    Synchronize(
                      procedure
                      begin
                        frm_Main.Status_Label.Caption := '����������� �������� �����';
                      end);
                     end;
                 // ThLog_Write('ThMT',' � Viewer, � ���� ������ �� ������� ��� ������ <|DSKTPCREATED|>, ����� ������ ������� ������');
                  end
                  else // ����� ���� � ���� �������, �������� ������ ����������� ����� ���� �� �������
                  begin
                 // ThLog_Write('ThMT',' � Viewer, � ���� ������ ������� ��� ������ <|DSKTPCREATED|>, �������� ����� ��� ������������');
                  CloseTgDesktopSockets;
                  end;
               end
               else
               begin
              // ThLog_Write('ThMT',' � Viewer, � ���� ����� �� �������');
               end;
            end
            else // ����� ������ ���
            begin // ������ ������
            //ThLog_Write('ThMT',' � Viewer, � ���� ��� ������ ��� ������ <|DSKTPCREATED|>, ���� ������� ����� � ����� ');
            end;

         end;
        if not iViewer then // ���� �� ��� ������������ � � ������� ���������
          begin
            if RecreateDesktopSocket then // ���� ��������������� ������� ������ ������ ���������� ��� ���� ����� ������� CREATESOCKDESKTP
             begin
              if Thread_Connection_Desktop<>nil then // ���� desktop ����� ����������
               begin
                if Thread_Connection_Desktop.Started then  // ���� desktop ����� �������
                 begin
                  if Thread_Connection_Desktop.BindSockD then //� ���� � ������ ������� ����� ������� �� �������
                   begin
                   // ThLog_Write('ThMT',' � �������, ������ ����������� ��� ����, � ���� ������ ������� ��� ������ <|DSKTPCREATED|> �������� ����� ��� ������������, �.� � ���� ��� ����������� ����� �����');
                    CloseTgDesktopSockets;
                   end
                   else
                   begin
                   //ThLog_Write('ThMT',' � �������, ������ ����������� ��� ����, � ���� ������ �� �������, ��� ������ <|DSKTPCREATED|> ��������� ������� ������ �� ����� �������');
                   SendTgMainCryptText('<|REDIRECT|><|REPEATBINDDESKTOPSOCKET|>');
                   end;
                 end
                 else
                 begin
                 //ThLog_Write('ThMT',' � �������, ������ ����������� ��� ����, � ���� ����� �� ��������, ��� ������ <|DSKTPCREATED|> ���������� �����');
                 end;
               end
               else
               begin
               //ThLog_Write('ThMT',' � �������, ������ ����������� ��� ����, � ���� ��� ������, ��� ������ <|DSKTPCREATED|> ���������� �����');
               end;

             end;
          end;
      end;
  step:=115;
     //-------------------------------------------------------------------------------------------------
       if Buffer.Contains('<|VIEWACCESSINGDESKTOP|>') then  // ������ ������� ��� �� ���� ������� ������ ������ �������� �����
       begin

          begin
          Synchronize(
            procedure
              begin
                if not frm_RemoteScreen.Visible then // ���� ����� ��� �� �������
                  begin
                  frm_Main.Status_Label.Caption := '���������� ����������';
                  frm_Main.Viewer := true;  // ������� ���� ��� � ���������� � ��������� ������� ���� ����������
                  frm_Main.ClearConnection;
                  frm_RemoteScreen.Show;
                  frm_Main.Hide;
                  end;
              end);
          end;

       iViewer:=true;// � ��� ��� ����������� ��� � ����������� � �������� � �� �� ������
        // ���������� ����������� ���������� �� ������ ��� ��������� �������� ������� ������� / ������������� ������
       if FormOsher.Resize_CheckBox.Checked then
        SendTgMainCryptText('<|REDIRECT|><|FIRSTSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // ��������������� ��������
        else SendTgMainCryptText('<|REDIRECT|><|FIRSTSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // ��� ���
        // ThLog_Write('ThM',2,' <|FIRSTSTARTDATA|> : W='+inttostr(frm_RemoteScreen.Screen_Image.Width)+' / H='+inttostr(frm_RemoteScreen.Screen_Image.Height));
       end;
  step:=116;
     //------------------------------------------------------------------------------------------------------
       if Buffer.Contains('<|FIRSTSTARTDATA|>') then // ���� �� ��� ������ ������������� ������
       begin    //<|FIRSTSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
       if ParsingTextToExpansion(BufferTemp)  then //���� ������ ����������
        SendTgMainCryptText('<|REDIRECT|><|READYGO|>') //��������� ��� ����� � ������ �������� �������� �����
       else //���� ������ �� ����������, �.�. � ���������� ���� ������� ��������
         begin
         sleep(300); // ���� ����� ��������� ��������
         SendTgMainCryptText('<|REDIRECT|><|GETSECONDSTARTDATA|>'); // ��������� ������ �� ��������� ������ ��� ������
         ThLog_Write('ThM',2,'Not first data start: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
         end;

       end;

     //-------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|GETSECONDSTARTDATA|>') then // ������� �������� �������� ��������� ��������� ������ �.�. ��������� ���� �� ��������, � ����������� ��� ���������� �������� ���� �� �������� 0
       begin
        if FormOsher.Resize_CheckBox.Checked then
        SendTgMainCryptText('<|REDIRECT|><|SECONDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // ��������������� ��������
        else SendTgMainCryptText('<|REDIRECT|><|SECONDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // ��� ���
       end;
     //--------------------------------------------------------------------------------------------------------------
        if Buffer.Contains('<|SECONDSTARTDATA|>') then // ���� �� ��� ������ ��������� ������������� ������
       begin    //<|SECONDSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
        if ParsingTextToExpansion(BufferTemp)  then //���� ������ ����������
        SendTgMainCryptText('<|REDIRECT|><|READYGO|>') //��������� ��� ����� � ������ �������� �������� �����
        else //���� ������ �� ����������, �.�. � ���������� ���� ������� ��������
        begin // ��������� 3 ������ �� ��������� ��������� ������
        sleep(600);
        SendTgMainCryptText('<|REDIRECT|><|GETTHIRDSTARTDATA|>'); // ��������� 3� ������ �� ��������� ������ ��� ������
        ThLog_Write('ThM',2,'Not second data start: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
        end;
       end;
     //--------------------------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|GETTHIRDSTARTDATA|>') then // ������� �������� 3� ��� ����������� ��������� ������ �.�. 1� � 2� ���� �� ��������, � ����������� ��� ���������� �������� ���� �� �������� 0
       begin
        if FormOsher.Resize_CheckBox.Checked then
        SendTgMainCryptText('<|REDIRECT|><|THIRDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>') // ��������������� ��������
        else SendTgMainCryptText('<|REDIRECT|><|THIRDSTARTDATA|>'
        + IntToStr(frm_RemoteScreen.Screen_Image.Width)+'<|>'+IntToStr(frm_RemoteScreen.Screen_Image.Height) +
         '<|END|><|RESIZES|>1<|END|>'); // ��� ���
       end;
     //------------------------------------------------------------------------------------------------------------------
     if Buffer.Contains('<|THIRDSTARTDATA|>') then // ���� �� ��� 3� ��� ������  ������������� ������
       begin    //<|THIRDSTARTDATA|>111<|>454<|END|><|RESIZES|>1<|END|>
        BufferTemp := Buffer;
        if ParsingTextToExpansion(BufferTemp)  then //���� ������ ����������
        SendTgMainCryptText('<|REDIRECT|><|READYGO|>') //��������� ��� ����� � ������ �������� �������� �����
        else //���� ������ �� ����������, �.�. � ���������� ���� ������� ��������
        begin // ���������� ������� � �������������� � ��������� ����������
        sleep(600);
        SendTgMainCryptText('<|REDIRECT|><|NOTSTARTDATA|>'); // ���������� ��������� � ��� ��� �� �� �������� ��������� ������ ���� � 3�� ����, � ������ ���������
        SendTgMainCryptText('<|STOPACCESS|>'); // �������� �� ������ ������� �� ����������
        ThLog_Write('ThM',2,'Not third data start. stop connect: '+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight)+' / resize='+inttostr(TmpNum));
        end;
       end;
     //----------------------------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|READYGO|>') then // ���� �� ��� ������� ������� ��� ����� ���������� ������ �������� �����
       begin
       SendTgMainCryptText('<|REDIRECT|><|ACCESSING|>'); //�������� ������� ��� �� � ���� �����������
       sleep(300); //������� ���� ��� ���� ����� ���������� ����� ������������, ����� ����� ���� ���� ������� ������
       SendDesktopSocket('<!>'+THashSHA2.GetHashString(PswrdCrypt,SHA256)+'<!!>'); // ���������� ��� �������������� ������, ��� ��������� ������ �������� �� �������
       if Thread_Connection_Desktop<>nil then
       if Thread_Connection_Desktop.Started then
       Thread_Connection_Desktop.BindSockD:=true; // ������� ���������� ������� � ���� � ������
       if RecreateDesktopSocket then // ���� ��� �� ������ �����������, �� ������ ��������������� ������ ������������
        begin
        if FReconnect.Visible then Synchronize(FReconnect.Close); // ��������� ������ ��������������� �������� �����
        end;
       RecreateDesktopSocket:=true; // ������� ������������� ������������ ������ �������� ����� ��� ��� �������
       end;
  step:=111;
      //----------------------------------------------------------------------------------------------------
      if Buffer.Contains('<|NOTSTARTDATA|>') then
      begin
       frm_Main.InMessage('�� ���������� ��������� ������ ��� �����������. ��������� ������� ������������.',0);
        Synchronize(
          procedure
          begin
            frm_Main.Status_Label.Caption := '� ����';
            frm_Main.TargetID_MaskEdit.Enabled := true;
            frm_Main.butConnect.Enabled := true;
            frm_Main.TargetID_MaskEdit.SetFocus;
          end);
        iViewer:=false;// ��� � ���� �������� � �� ��� ����� �����������
        SendTgMainCryptText('<|STOPACCESS|>');
        break;
      end;
      //-------------------------------------------------------------------------------------------
      if Buffer.Contains('<|REPEATBINDDESKTOPSOCKET|>')  then // ������ ����� �� �������, � �������� ��� ��� ������ ����� �������� �����, �� �������� � ������ ��� � ���� ��� �� �������,
      begin            // ����� ���.��������
      if RecreateDesktopSocket then // ���� ����� ���������� ��� ����, � ���� ������� ���������������
      if iViewer then // ���� � ����������� � ��������
         begin
          if Thread_Connection_Desktop<>nil then  // ���� ����� �������� ����� ����������
            Begin
              if Thread_Connection_Desktop.Started then // ���� ����� �������� ����� �������
               begin
                 if not Thread_Connection_Desktop.BindSockD then // ���� � ������ ��� �������� ����� �������
                   begin
                   //ThLog_Write('ThMT',' � Viewer, � ���� ����� �� ������, ������ <|REPEATBINDDESKTOPSOCKET|> ��������� �� ������ ������� ������� ������ <|BINDDSKTPSOCK|>');
                   SendTgMainCryptText('<|BINDDSKTPSOCK|>'+frm_Main.ArrConnectSrv[IDConect].MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>'); // ����� ������ ������� ������ ��������
                   end
                   else // ����� ���� ��� ������ ���� �����������
                   begin
                   //ThLog_Write('ThM',' � Viewer, � ���� ����� ������, ������ <|REPEATBINDDESKTOPSOCKET|>, �������� ����� ��� ������������');
                   CloseTgDesktopSockets; // ������������ ������ �������� �����
                   end;
               end
               else
               begin
               //ThLog_Write('ThMT',' � Viewer, � ���� ����� �� �������, ������ <|REPEATBINDDESKTOPSOCKET|>, ���� ����������� �����');
               // FullDesktopSocketReconnect;// ������������ ������ �������� ����
               end;
            End
            else
             begin
             //ThLog_Write('ThMT',' � Viewer, � ���� ����� �����������, ������ <|REPEATBINDDESKTOPSOCKET|>, ���� ����������� �����');
             //FullDesktopSocketReconnect;// ������������ ������ �������� �����
             end;
         end;
      end;


  //-------------------------------------------------------------------------------------------------
   //---------------------------------������ � �������� �������---------------------------------------------
     if Buffer.Contains('<|FILESCREATED|>') then  //���� ��� ������� ��� ������� ����� ��� ������, ������������ ��� �������� ������ ��������� ��������� ������
      begin
       if iViewer then // ���� � ����������� � �������� �� � ����� � ������� ������� ������
        begin
        SendTgMainCryptText('<|BINDFILESSOCK|>'+frm_Main.ArrConnectSrv[IDConect].MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>');
        end;
       if not iViewer then // ���� �� ��� ������������ � � ������� ���������
        begin
         if Thread_Connection_Files<>nil then // ���� �������� ����� ����������
         if Thread_Connection_Files.Started then  // ���� �������� ����� �������
         if Thread_Connection_Files.BindSockF then //� ���� � ������ ���� ������� ��� ����� ����� �� �������
          SendTgMainCryptText('<|REDIRECT|><|REPEATBINDFILESOCKET|>'); // ������ ���� ��� �� ��� ���������, ����� �������� �������� ������, �.�. ���� �������� ����� �������� ��� ��������
        end;
      end;
   step:=118;
    //-------------------------------------------------------------------------------------
     if Buffer.Contains('<|REPEATBINDFILESOCKET|>')  then // ������ ����� �� �������, � �������� ��� ��� ������ �������� �����, �� �������� � ������ ��� � ���� ��� ��� ���� �������, ������ ����� � ���� ��� �������� � �������� �������
      begin            // ����� ���.��������
      if iViewer then // ���� � ����������� � ��������
       begin
        if Thread_Connection_Files<>nil then  // ���� �������� ����� ����������
        if Thread_Connection_Files.Started then // ���� �������� ����� �������
        if not Thread_Connection_Files.BindSockF then // ���� � ������ ��� �������� ����� �������
        SendTgMainCryptText('<|BINDFILESSOCK|>'+frm_Main.ArrConnectSrv[IDConect].MyID+'<|>'+frm_Main.TargetID_MaskEdit.Text+'<|END|>'); // ����� ������ ������� ������ ��������
       end;
      end;
  step:=119;
    //--------------------------------------------------------------------------------------------
     if Buffer.Contains('<|VIEWACCESSINGFILES|>') then  // � �������� ������� <|BINDFILESSOCK|> ������� ������� �������� ������ ��� ����� �� ������� ������ ��� ������ �������� ������
       begin
       if Thread_Connection_Files<>nil then
       if Thread_Connection_Files.Started then
       Thread_Connection_Files.BindSockF:=true; // ������� ���������� �������
       //ThLog_Write('ThMT',' ������ ������� �������� ������. Client');
       end;
  step:=121;
  //---------------------------------------------------------------------------------

   step:=15;
       if Buffer.Contains('<|DISCONNECTED|>') then // ��� ��������� ����������� ����� ����������,���,���������
      begin
       Synchronize(
          procedure
          begin
            if FormFileTransfer.Visible then FormFileTransfer.Close;
            if frm_RemoteScreen.Visible then frm_RemoteScreen.close;
            if frm_ShareFiles.Visible then frm_ShareFiles.Close;
            if frm_Chat.Visible then frm_Chat.close;
            frm_Main.SetOnline;
            frm_Main.Status_Label.Caption := '� ����';
            frm_Main.Show;
          end);

       ReconnectDesktopSocketCount:=0; // ������� ���-�� ������������  ������ �������� �����
       ReconnectFileSocketCount:=0; // ������� ���-�� ������������ ��������� ������
       RecreateFileSocket:=false; // �������� ������� ������������� ������������ ��������� ������ ��� ��� �������
       RecreateDesktopSocket:=false; // �������� ������� ������������� ������������ ������ �������� ����� ��� ��� �������
       iViewer:=false; // ����� ���������� � ����� ���� ���� ���������
       DeleteDesktopSockets;// ������� ����� �������� �����
       DeleteFileSockets;  // ������� �������� �����
       if frm_Main.ArrConnectSrv[IDConect].DesktopSock<>nil then frm_Main.ArrConnectSrv[IDConect].DesktopSock:=nil;
       if frm_Main.ArrConnectSrv[IDConect].FilesSock<>nil then frm_Main.ArrConnectSrv[IDConect].FilesSock:=nil;
       frm_Main.Accessed := false; // ����� �������� ���� �� ��� ������������
       frm_Main.Viewer := false;  // ����� �������� ���� ��� � ���������� � ��������
       break; // ������� �� ������ ,�.�. ��� ���������� ���������
      end;
  step:=16;
  //--------------------------------------------------------------------------------------------
      { Redirected commands }
      // Desktop Remote
      Position := Pos('<|RESOLUTION|>', Buffer); // ��������� ���������� ������ �������
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionTargetWidth := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionTargetHeight := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        //ThLog_Write('ThMain','<|RESOLUTION|> '+inttostr(frm_Main.ResolutionTargetWidth)+'x'+inttostr(frm_Main.ResolutionTargetHeight));
      end;
      Position := Pos('<|MONITORLEFTTOP|>', Buffer); // ��������� ��������� ������ �� �������
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 17);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionTargetLeft := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionTargetTop := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
       // ThLog_Write('ThMain','<||MONITORLEFTTOP|> '+inttostr(frm_Main.ResolutionTargetLeft)+'x'+inttostr(frm_Main.ResolutionTargetTop));
      end;
  step:=17;
       Position := Pos('<|MONITORCOUNT|>', Buffer); // ��������� ���������� ��������� �� ������� '<|MONITORCOUNT|>...<|END|>'
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 15);
        frm_Main.MonitorCount := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        Delete(BufferTemp, 1, length(BufferTemp));
      //ThLog_Write('ThMain','<|MONITORCOUNT|> '+inttostr(frm_Main.MonitorCount));
      end;
      Position := Pos('<|MONITORCURRENT|>', Buffer); // ��������� ������� ���������� ������� ��� ������� '<|MONITORCURRENT|>...<|END|>'
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 17);
        frm_Main.MonitorCurrent := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        Delete(BufferTemp, 1, length(BufferTemp));
        frm_Main.MonitorCurrentX:=screen.Monitors[frm_Main.MonitorCurrent].Left;
        frm_Main.MonitorCurrentY:=screen.Monitors[frm_Main.MonitorCurrent].Top;
        frm_Main.MonitorCurrentWidth:=screen.Monitors[frm_Main.MonitorCurrent].Width;
        frm_Main.MonitorCurrentHeight:=screen.Monitors[frm_Main.MonitorCurrent].Height;
        SendTgMainCryptText('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Width)
        + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Height) + '<|END|>');
        SendTgMainCryptText('<|REDIRECT|><|MONITORLEFTTOP|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Left)
        + '<|>' + IntToStr(Screen.Monitors[frm_Main.MonitorCurrent].Top) + '<|END|>');
      //ThLog_Write('ThMain','<|MONITORCURRENT|> '+inttostr(frm_Main.MonitorCurrent));
      end;
       Position := Pos('<|PIXELFORMAT|>', Buffer); //  '<|PIXELFORMAT|>...<|END|>'
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

      //--------------------------------------------------------------------------------------------------------------------
      Position := Pos('<|TEMPVAR|>', Buffer); // ��������� �������� ��������� ����������, ��� ���������������� �����!!!!
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        frm_Main.RedirectTempVar := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        Delete(BufferTemp, 1, length(BufferTemp));
      end;
      //---------------------------------------------------------------------------------------------------------------------
      Position := Pos('<|RESOLUTIONRESIZE|>', Buffer); // ��������� ���������� �� ������� ����������� ��� �������� ������ ��� resizes
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 19);
        Position := Pos('<|>', BufferTemp);
        frm_Main.ResolutionResizeWidth := StrToInt(Copy(BufferTemp, 1, Position - 1));
        Delete(BufferTemp, 1, Position + 2);
        frm_Main.ResolutionResizeHeight := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
        //Log_Write('appT','<|RESOLUTIONRESIZE|>'+inttostr(frm_Main.ResolutionResizeWidth)+'X'+inttostr(frm_Main.ResolutionResizeHeight));
      end;
  step:=18;
      Position := Pos('<|RESIZES|>', Buffer); // ��������������� ��������
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 10);
        if (Copy(BufferTemp, 1, 1))='1' then
        frm_Main.ScreenResizes :=true
        else
        frm_Main.ScreenResizes :=false;
       // Log_Write('appT','<|RESIZES|>'+(Copy(BufferTemp, 1, 1)));
      end;
  //---------------------------------------------
     //SendMainSocket('<|REDIRECT|><|TSC|>'+TimeScreen+'<|TCPS|>'+TimeCompress+'<|TCPR|>'+TimeCompare+'<|END|>'); // ����� ������
    Position := Pos('<|TSC|>', Buffer); // ����� ���������� �� �����
      if Position > 0 then  //MTimeScreen,MTimeCompress,MTimeCompare
      begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, Position + 6);
      Position := Pos('<|TCPS|>', BufferTemp);
      frm_Main.MTimeScreen:= Copy(BufferTemp, 1, Position - 1);
      BufferTemp :='';
      end;
  step:=28;
  // Chat-----------------------------------------------------------------------------------------
      Position := Pos('<|CHAT|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 7);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        BufferTemp:=ReciveDecodeBase64(BufferTemp); // ���������� �� base64
  step:=29;
        Synchronize(
          procedure
          begin
           with frm_Chat do
            begin
  step:=30;    
                with NewChat.Items.AddMessage do
                begin
                From:='�������'; //��� �������
                Date:=now;
                FromColor:=clGradientActiveCaption;// ����   clGradientActiveCaption
                FromType:=TChatMessageType.mtOpponent;          //mtOpponent, mtMe  ��� �������, � ��� ���
                Text:=BufferTemp; // ����� ���������
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
      // Share Files
      // Request Folder List
      Position := Pos('<|GETFOLDERS|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        SendTgMainCryptText('<|REDIRECT|><|FOLDERLIST|>' + ListFolders(BufferTemp) + '<|ENDFOLDERLIST|>');
      end;
  step:=34;
      // Request Files List
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
          if not SendTgMainCryptText('<|REDIRECT|><|FILESLIST|>'+FoldersAndFiles.CommaText+'<|ENDFILESLIST|>') then
           ThLog_Write('ThM',2,'�� ������� ��������� ������ ������ ���������� '+BufferTemp);
          end
         else SendTgMainCryptText('<|REDIRECT|><|FILESLIST|><|ENDFILESLIST|>');
        finally
         FoldersAndFiles.Free;
        end;
      end;
       // ��������� ������ �������� ������
      Position := Pos('<|GETLISTDRIVE|>', Buffer);
      if Position > 0 then
      begin
       SendTgMainCryptText('<|REDIRECT|><|LISTDRIVE|>' +ListlogDrive+ '<|END|>');
      end;
  step:=35;
// ������ ������ ������ ���������� ��--------------------------------------------------------------------------------------------
      Position := Pos('<|LISTDRIVE|>', Buffer); //
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 12);
        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        FoldersAndFiles := TStringList.Create;
        try
        FoldersAndFiles.CommaText:=BufferTemp;

        if frm_ShareFiles.Visible then  // ���� ������� ����� �������� ������ �� ������ ������
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

        if FormFileTransfer.Visible then //���� ������� ����� �������� ������ � ���������
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
    // ������ ������ ��������� ���������� ���������� -----------------------------------------------------------------------------------------------------------
      Position := Pos('<|FOLDERLIST|>', Buffer);
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
        if frm_ShareFiles.Visible then  // ���� ������� ����� �������� ������ �� ������ ������
          Begin
          Synchronize(
            procedure
            var i: Integer;
            begin
              frm_ShareFiles.ShareFiles_ListView.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                if FoldersAndFiles.Names[i]='..' then // ���� �������� "�� ������� ����"
                begin
                 with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                  begin
                  Caption := '�����';
                  ImageIndex := 0;
                  SubItems.Add(''); // ���� � �����
                  SubItems.Add(''); // ������ �����
                  end;
                end
                else
                begin
                 with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                  begin
                  Caption := FoldersAndFiles.Names[i];
                  ImageIndex := 1;
                  SubItems.Add(FoldersAndFiles.ValueFromIndex[i]); // ���� � �����
                  SubItems.Add(''); // ������ �����
                  end;
                end;
              end;
            end);
          SendTgMainCryptText('<|REDIRECT|><|GETFILES|>' + frm_ShareFiles.EditDirClient.Text + '<|END|>');
          End;

        if FormFileTransfer.Visible then //���� ������� ����� �������� ������ � ���������
          Begin
           Synchronize(
            procedure
            var i: Integer;
            begin
              FormFileTransfer.LVClient.Clear;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                if FoldersAndFiles.Names[i]='..' then // ���� �������� "�� ������� ����"
                begin
                 with FormFileTransfer.LVClient.Items.Add do
                  begin
                  Caption := '�����';
                  ImageIndex := 0;
                  SubItems.Add(''); // ���� � �����
                  SubItems.Add(''); // ������ �����
                  end;
                end
                else
                begin
                 with FormFileTransfer.LVClient.Items.Add do
                  begin
                  Caption := FoldersAndFiles.Names[i];
                  ImageIndex := 1;
                  SubItems.Add(FoldersAndFiles.ValueFromIndex[i]); // ���� � �����
                  SubItems.Add(''); // ������ �����
                  end;
                end;
                //FormFileTransfer.Caption := '�������� � ����� - ' + IntToStr(FormFileTransfer.LVClient.Items.count) + ' ���������';
              end;
            end);
          SendTgMainCryptText('<|REDIRECT|><|GETFILES|>' + FormFileTransfer.EditDirClient.Text + '<|END|>');
          End;
        finally
        FreeAndNil(FoldersAndFiles);
        end;
      end;
  step:=40;
   //--------------------������ ����������� ������ ������
      Position := Pos('<|FILESLIST|>', Buffer);
      if Buffer.Contains('<|ENDFILESLIST|>') then
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 12);
        FoldersAndFiles := TStringList.Create;
        try
        FoldersAndFiles.CommaText := Copy(BufferTemp, 1, Pos('<|ENDFILESLIST|>', BufferTemp) - 1);
        FoldersAndFiles.Sort;
        if frm_ShareFiles.Visible  then  // ���� ������� ����� �������� ������ �� ������ ������
          Begin
          Synchronize(
            procedure
            var i: Integer;
            begin
             if (frm_ShareFiles.ShareFiles_ListView.Items.Count=0) then
              begin
               with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                begin
                Caption := '�����';
                ImageIndex:=0;
                SubItems.Add(''); // ���� � �����
                SubItems.Add(''); // ������ �����
                end;
              end;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
                with frm_ShareFiles.ShareFiles_ListView.Items.Add do
                begin
                Caption := FoldersAndFiles.Names[i];
                ImageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(Caption)));
                ParsingFileDateSize(FoldersAndFiles.ValueFromIndex[i],TempI,TempZ);
                SubItems.Add(TempI); // ���� � �����
                SubItems.Add(TempZ); // ������ �����
                end;
              end;
              frm_ShareFiles.EditDirClient.Enabled := true;
            end);
          End;

          if FormFileTransfer.Visible then //���� ������� ����� �������� ������ � ���������
           Begin
             Synchronize(
            procedure
            var i: Integer;
            begin
             if (FormFileTransfer.LVClient.Items.Count=0) then
              begin
               with FormFileTransfer.LVClient.Items.Add do
                begin
                Caption := '�����';
                ImageIndex:=0;
                SubItems.Add(''); // ���� � �����
                SubItems.Add(''); // ������ �����
                end;
              end;
              for i := 0 to FoldersAndFiles.count - 1 do
              begin
               with FormFileTransfer.LVClient.Items.Add do
                begin
                Caption := FoldersAndFiles.Names[i];
                ImageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(Caption)));
                ParsingFileDateSize(FoldersAndFiles.ValueFromIndex[i],TempI,TempZ);
                SubItems.Add(TempI); // ���� � �����
                SubItems.Add(TempZ); // ������ �����
                end;
              end;
              FormFileTransfer.EditDirClient.Enabled := true;
              //FormFileTransfer.Caption := '�������� � ����� - ' + IntToStr(FormFileTransfer.LVClient.Items.count) + ' ���������';
            end);
           End;
        finally
        FreeAndNil(FoldersAndFiles);
        end;
      end;
  step:=47;

  END;
  //ThLog_Write('ThMT','����� (TM) ��������');
  frm_Main.ArrConnectSrv[IDConect].ConnectBusy:=false; // ������� ������������ �������� �������
  RecreateFileSocket:=false; // �������� ������� ������������� ������������ ��������� ������ ��� ��� �������
  RecreateDesktopSocket:=false; // �������� ������� ������������� ������������  ������ �������� ����� ��� ��� �������
  DeleteDesktopSockets;// ������� ����� �������� �����
  DeleteFileSockets;  // ������� �������� �����
  CloseTgMainSocket; // �������� � �������� ��������� ������
  except on E : Exception do
    begin
    frm_Main.ArrConnectSrv[IDConect].ConnectBusy:=false; // ������� ������������ �������� �������
    RecreateFileSocket:=false; // �������� ������� ������������� ������������ ��������� ������ ��� ��� �������
    RecreateDesktopSocket:=false; // �������� ������� ������������� ������������  ������ �������� ����� ��� ��� �������
    DeleteDesktopSockets;// ������� ����� �������� �����
    DeleteFileSockets;  // ������� �������� �����
    CloseTgMainSocket; // �������� � �������� ��������� ������
    ThLog_Write('ThMT',2,inttostr(step)+') ����� ������ (TM) ������ : ');
    end;
  end;
end;

//-------------------------------------------------------------
// ����������� ������� �������� �����
//-----------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Desktop.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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

//--------------------------------------------------------------------

Function TThread_Connection_TargetMain.TThread_Connection_Desktop.CloseDesctopSocket(Mes:string):boolean;
  begin
   try
   if TgDesktopSocket<>nil then
   begin
   if TgDesktopSocket.Connected then TgDesktopSocket.Close;
   //if DesktopSocket<>nil then DesktopSocket.Free;
   //ThLog_Write('ThDT','���������� ������ (D) �� ������ '+Mes);
   end;
   except on E : Exception do
    begin
    ThLog_Write('ThDT',2,'������ �������� �� ������ ������ (DT) : ');
    end;
  end;
  end;
//---------------------------------------------------------------------------
// Compress Stream with zLib    ��������� ������ ����� ���������
function TThread_Connection_TargetMain.TThread_Connection_Desktop.CompressStreamWithZLib(SrcStream: TMemoryStream; var TimeResume:Double): Boolean;
var
  InputStream: TMemoryStream;
  inbuffer: Pointer;
  outbuffer: Pointer;
  count, outcount: longint;
   iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
  try
   ///QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
   //  QueryPerformanceCounter(T1); //������� ����� ������ ��������
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
        ThLog_Write('ThDT',2,'������ ��������� ������ (DT) : ');
        end;
      end;
  //QueryPerformanceCounter(T2);//������� ����� ���������
 //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
end;

// Decompress Stream with zLib   ������������ ������ ��� ���������
function TThread_Connection_TargetMain.TThread_Connection_Desktop.DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
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
      ThLog_Write('ThDT',2,'������ ���������� ������ �� ������ (DT) - '+inttostr(TmpHdl));
           end;
    end;
end;

//-----------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Desktop.MemoryStreamToString(M: TMemoryStream): AnsiString; //������� �� ������ � ������
begin
try
  SetString(Result, PAnsiChar(M.Memory), M.Size);
 except on E : Exception do ThLog_write('ThDT',2,'������ MToS ');  end;
end;

//---------------------------------------------------------------------------------

function TThread_Connection_TargetMain.TThread_Connection_Desktop.SendMainSocket(s:ansistring):boolean;
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IdConect].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IdConect].mainSock.Connected then
   while frm_Main.ArrConnectSrv[IdConect].mainSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_Write('ThDT',2,'������ �������� ������ (�) ������� ������� ');  end;
end;

function TThread_Connection_TargetMain.TThread_Connection_Desktop.Encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // ����������
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

function TThread_Connection_TargetMain.TThread_Connection_Desktop.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // �����������
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


procedure TThread_Connection_TargetMain.TThread_Connection_Desktop.ResumeStreamXORBMP(var FirstBMP, CompareBMP:Tbitmap;  //������/���������� �������� - ������� ������������  (FirstBMP+SecondBMP)
   var SecondBMP:TmemoryStream;        //   - ����� ������� ������, � ��� ������� ����� ���������� ��������� � ��� ������� ���� ������������
   var SecondSize:int64;              // ������ ���������� ������
   var TimeResume:double;            // �����. ��� ������� ����������� �������
   var ResStr:string;               // ���������/������ � ������
   var ResB:boolean              // ��������� � boolean
   );
var
  I,X,Y : Integer;
  h,w,ScanBytes,BytesPerPixel:integer;
  P1: ^byte;
  P2: ^byte;
  P3: ^byte;
  ZeroArray : Array of byte;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
  step:integer;


  function LengthScanLine(TmpBmp:Tbitmap; var LenghtLine:Integer):boolean; // ���������� ������ ����� ����� ��������
  begin
    try
    LenghtLine:=Abs(Integer(TmpBmp.Scanline[1]) - Integer(TmpBmp.Scanline[0])); // ���������� ������ ����� ����� ��������
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
   //QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
   //QueryPerformanceCounter(T1); //������� ����� ������ ��������
   step:=0;
   if (SecondSize<>0) and (SecondSize<>SecondBMP.Size) then // ���� ������ ���������� ������ �� ����� �����������, �� �������� ���������� ����������
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
      ResB:=LengthScanLine(FirstBMP,ScanBytes); // ���������� ������ ����� ����� ��������
       try
       if ResB then
          begin
          step:=5;
          SecondSize:=SecondBMP.Size; // ��������� ������ ����������� ������ ��� ������������ ���������
          step:=6;
          BytesPerPixel:=GetBytesPerPixel(FirstBMP.PixelFormat);  // ���������� ���������� ���� �� �������
          step:=7;
          h:=FirstBMP.Height;
          step:=8;
          w:=FirstBMP.Width;
          step:=9;
          SecondBMP.Position:=0; // ����������� �������
          P3:=SecondBMP.Memory;
          step:=10;
          SetLength(ZeroArray,ScanBytes); // ������ �������� �������
          ZeroMemory(ZeroArray,ScanBytes); // �������� ������
            try
            step:=11;
            for i:=0 to h-1 do
               Begin
                if CompareMem(ZeroArray,P3,ScanBytes) then // ���� ��� ��������� � ������ �������� ���� ��� ��������� (�������� �� ������ ������)
                 begin  //  ������ ��������� � ������ ������� �� �������������. �� ���������� ������ ������ ��� ���������� ��������
                 inc(P3,ScanBytes);
                 step:=12;
                 end
                else // ����� ��������� ������ ������� � ����� ���
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
   //QueryPerformanceCounter(T2);//������� ����� ���������
   //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
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

procedure TThread_Connection_TargetMain.TThread_Connection_Desktop.Execute;
var
  Position,step: Integer;
  Buffer,ResResumeStr: string;
  strTmp:string;
  TempBuffer: string;
  PackStream: TMemoryStream;
  CompareBmp:Tbitmap;
  FirstBmp:Tbitmap;
  SecondBmp:Tbitmap;
  SeconStreamSize:int64;
  FirstStreamSize:int64;
  GetBmp:boolean;
  GDWhWnd:HWND;
  DC: HDC;
  TimeScreen,TimeCompare,TimeResume,TimeCompress,TimeDecompress:Double;
  GetFullSrcn,ResResume:boolean;
Procedure RecreateBmp(var tmpb:Tbitmap; PF:TpixelFormat);
begin
if assigned(tmpb) then tmpb.Free;
tmpb:=Tbitmap.Create;
tmpb.PixelFormat:=PF;
end;

function SendMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
Encryptstrs(s, PswrdCrypt, CryptBuf); //������� ����� ���������
SendMainSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThD',2,'����� D ������ ���������� � �������� ������ ');
    end;
  end;
end;


function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
var
i:integer;
posStart,posEnd:integer;
bufTmp:string;
CryptTmp,DecryptTmp:string;
begin
  try
  bufTmp:='';
   while s<>'' do // � ����� ������
     begin
      CryptTmp:='';
      DecryptTmp:='';
      posStart:=pos('<!>',s);// ������ ������������� �������
      posEnd:=pos('<!!>',s); // ����� ������������� �������
      CryptTmp:=copy(s,posStart+3,posEnd-4);// �������� ����������� ������
      Decryptstrs(CryptTmp, PswrdCrypt,DecryptTmp); //���������� ������������� ������
      bufTmp:=bufTmp+DecryptTmp;// ����������� �������������� ������
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
    ThLog_Write('ThD',2,'����� D ������ ���������� ������ ');
    end;
  end;
end;

begin
try
  inherited;
 // ThLog_Write('ThDT','����� (DF) �������');
  PswrdCrypt:=frm_Main.ArrConnectSrv[IDConect].CurrentPswdCrypt; // ����������� ������� ������ ��� ���������� � ������
  HashPswrdCrypt:=THashSHA2.GetHashString(PswrdCrypt,SHA256); // ������ ���� �������������� ������
  if not SendMainCryptText('<|REDIRECT|><|DSKTPCREATED|>')  then  // �������� ������� � �������� ������ ��� ������
  begin
 // ThLog_Write('ThD','�� ������� ��������� <|REDIRECT|><|DSKTPCREATED|>');
  CloseDesctopSocket('�� ������� ��������� <|REDIRECT|><|DSKTPCREATED|>'); // ��������� ����� �������� ����� �.�. �� �������� � ������� ������, � ������� �� ������.
  exit;
  end;


  PackStream := TMemoryStream.Create;
  SecondBmp:=Tbitmap.Create;
  SecondBmp.PixelFormat:=frm_Main.ImagePixelF;
  FirstBmp:=Tbitmap.Create;
  FirstBmp.PixelFormat:=frm_Main.ImagePixelF;
  CompareBMP:=Tbitmap.Create;
  CompareBMP.PixelFormat:=frm_Main.ImagePixelF;
  SeconStreamSize:=0;
  FirstStreamSize:=0;
  GetFullSrcn:=false;

  while not terminated do
  begin
   if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
    Sleep(ProcessingSlack); // Avoids using 100% CPU
    if (TgDesktopSocket = nil) or not(TgDesktopSocket.Connected) then
      Break;

    if TgDesktopSocket.ReceiveLength < 1 then
      Continue;
    Buffer := Buffer + TgDesktopSocket.ReceiveText; // ��������� � ����� ��� ��� ��������


 ////////////////////////////////////////////////////////////////////��������� ��������, �.�. � ������
     if Buffer.Contains('<|!F!|>') then  // ������ �����
      BEGIN   //'<|!F|>...<|!F!|>'
      step:=21;
      GetFullSrcn:=false; //  ������ ���������� ����� ������ �����
        Delete(Buffer, 1, Pos('<|!F|>', Buffer) + 5);
        Position := Pos('<|!F!|>', Buffer);
        TempBuffer := Copy(Buffer, 1, Position - 1); // ����������� �� ��������� ����� ���� ��� ���� ������� � ������
        //Delete(Buffer, 1, Position + 6); //  ������� �����/������ �����������, ������� ���� ����������.
        Buffer:='';
        PackStream.Write(AnsiString(TempBuffer)[1], Length(TempBuffer)); // ������ � ����� �� ��� ��������
        PackStream.Position := 0;
        step:=22;
        if PackStream.Size>0 then // ���� ����� �� �������
        if DeCompressStreamWithZLib(PackStream) then  //���� ������ �������� �� ������ �� ��� ������
           begin
           step:=23;
             begin
              step:=24;
              FirstStreamSize:=PackStream.Size; // �������� ������ ���������� ������� ������
              PackStream.Position:=0;
              FirstBMP.LoadFromStream(PackStream); // ��������� ������ ��������
              PackStream.Position:=0;
              CompareBMP.LoadFromStream(PackStream); // ��������� ������ �������
              PackStream.Position:=0;
              step:=25;
               try
               Synchronize(
               procedure                                           //MTimeScreen,MTimeCompress,MTimeCompare
                begin
                frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); //������ �������� �������� ����� ���  Bitmap.Assign(CompareBMP)
                frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConect].MyPing) + ' ��) fps~'+frm_Main.MTimeScreen;
                end);
                while TgDesktopSocket.SendText('<|NEXTSHOT|>')<0 do Sleep(ProcessingSlack);
                except on E : Exception do
                  begin
                  //ThLog_Write('ThDT',2,'����� (D) Load First ScreenShot : '+E.ClassName+': '+E.Message);
                  while TgDesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //��������� ������ ������� ������
                  GetFullSrcn:=true;
                 end;
               end;
               step:=26;
             end;
         end
         else
          begin
          while TgDesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //��������� ������ ������� ������
          GetFullSrcn:=true;
          //ThLog_Write('ThDT',2,'����� (D) Not decompress FullScreen ');
          end;
        TempBuffer :='';
      END;
    // ������������ ���� �����, ������� ��������� � ������.
     while (Buffer.Contains('<|!!|>')) and (not GetFullSrcn) do  // ������� ����� ���������� � �������
      BEGIN
        //if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
        step:=21;
        Delete(Buffer, 1, Pos('<|!|>', Buffer) + 4);
        Position := Pos('<|!!|>', Buffer);
        TempBuffer := Copy(Buffer, 1, Position - 1); // ����������� �� ��������� ����� ���� ��� ���� ������� � ������
        Delete(Buffer, 1, Position + 5); //  ������� �����/������ �����������, ������� ���� ����������.
        PackStream.Write(AnsiString(TempBuffer)[1], Length(TempBuffer)); // ������ � ����� �� ��� ��������
        PackStream.Position := 0;
        step:=22;
        if PackStream.Size>0 then // ���� ����� �� �������
        if DeCompressStreamWithZLib(PackStream) then  //���� ������ �������� �� ������ �� ��� ������
           begin
           step:=23;
            if FirstStreamSize = 0 then // ���� ������ ������ ��������
             begin
             step:=24;
              FirstStreamSize:=PackStream.Size; // �������� ������ ���������� ������� ������
              PackStream.Position:=0;
              FirstBMP.LoadFromStream(PackStream); // ��������� ������ ��������
              PackStream.Position:=0;
              CompareBMP.LoadFromStream(PackStream); // ��������� ������ �������
              PackStream.Position:=0;
              step:=25;
               try
               Synchronize(
               procedure
                begin
                frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); //������ �������� �������� ����� ���  Bitmap.Assign(CompareBMP)
                frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConect].MyPing) + ' ��) fps~'+frm_Main.MTimeScreen;
                end);
                except on E : Exception do
                  begin
                  //ThLog_Write('ThDT',2,'����� (D) Load First ScreenShot : '+E.ClassName+': '+E.Message);
                  while TgDesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //��������� ������ ������� ������
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
               while TgDesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //��������� ������ ������� ������
               //ThLog_Write('ThDT',2,'����� (D) ������ Resume ScreenShot : '+ResResumeStr);
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
                    //frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(PackStream); // ����� �������� ��������� ����������
                    frm_RemoteScreen.Screen_Image.Picture.Bitmap.Assign(CompareBMP);
                    frm_RemoteScreen.Caption := 'RuViewer (Timeout Server: ' + IntToStr(frm_Main.ArrConnectSrv[IDConect].MyPing) + ' ��) fps~'+frm_Main.MTimeScreen;
                   end);
                 except on E : Exception do
                  begin
                   while TgDesktopSocket.SendText('<|FULLSCRNSHOT|>')<0 do Sleep(ProcessingSlack); //��������� ������ ������� ������
                   //ThLog_Write('ThDT',2,'����� (D) Load Second ScreenShot : '+E.ClassName+': '+E.Message);
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
          //ThLog_Write('ThDT',2,'����� (D) Not DeCompressStream');
          end;
       PackStream.Clear;
      END;
 ////////////////////////////////////////////////////////////////////////////////

  end;

  CompareBmp.Free;
  FirstBmp.Free;
  SecondBMP.Free;
  FreeAndNil(PackStream);
  Buffer :='';
  Synchronize(
   procedure
   begin
   frm_RemoteScreen.Screen_Image.Picture.Assign(frm_RemoteScreen.ScreenStart_Image1.Picture);
   end);
  //ThLog_Write('ThDT','����� (DF) ��������');
except on E : Exception do
    begin
    Buffer :='';
    if assigned(CompareBmp) then CompareBmp.Free;
    if assigned(FirstBmp) then FirstBmp.Free;
    if assigned(SecondBmp) then SecondBmp.Free;
    if assigned(PackStream) then  FreeAndNil(PackStream);
    CloseDesctopSocket('������ ������ D '); //���� �������� ��������� ����� �� ��������� ������
    ThLog_Write('ThDT',2,'����� (DT) ����� ������ : ');
    end;
  end;
end;




// Connection of Share Files
function TThread_Connection_TargetMain.TThread_Connection_Files.ThLog_write(fname:string;NumError:integer; TextMessage:string):boolean;
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
//--------------------------------------------------------------------
procedure TThread_Connection_TargetMain.TThread_Connection_Files.CloseFilesSocket;
  begin
   try
   if TgFileSocket<>nil then
   begin
   if TgFileSocket.Connected then TgFileSocket.Close;
  // if TgFileSocket<>nil then TgFileSocket.Free;
   end;
   except on E : Exception do
    begin
    ThLog_Write('ThF',2,'������ �������� �� ������ ������ (F) : ');
    end;
  end;
  end;
//-------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Files.SendMainSocket(s:ansistring):boolean;
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IdConect].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IdConect].mainSock.Connected then
   while frm_Main.ArrConnectSrv[IdConect].mainSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_write('appT',2,'������ �������� ������ (FT) ������� ������� (MT)  : ');  end;
end;
//------------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Files.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if TgFileSocket=nil then result:=false
else
begin
  if TgFileSocket.Connected then
   while TgFileSocket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do ThLog_write('appT',2,'������ �������� ������ (FT) ������� ������� (FT) ');  end;
end;
//-----------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Files.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // ����������
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

function TThread_Connection_TargetMain.TThread_Connection_Files.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // �����������
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
//-----------------------------------------------------------------------------

function TThread_Connection_TargetMain.TThread_Connection_Files.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
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
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //���������� ������������� ������
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
    ThLog_Write('ThFT',2,'����� FT ������ ���������� ������ ');
   // ThLog_Write('ThFT','ERROR  - ����� FT ������ ���������� ������ ������ - '
   // +PswrdCrypt+' s='+s+' posStart='+inttostr(posStart)+' posEnd'+inttostr(posEnd)+' bufTmp'+bufTmp+
   // ' CryptTmp='+CryptTmp);

     s:='';
    end;
  end;
end;
//----------------------------------------------------------------------------------1
function TThread_Connection_TargetMain.TThread_Connection_Files.SendMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswrdCrypt, CryptBuf); //������� ����� ���������
SendMainSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThFT',2,' ����� FT ������ ���������� � �������� ������ ');
    end;
  end;
end;

function TThread_Connection_TargetMain.TThread_Connection_Files.SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � Files �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswrdCrypt, CryptBuf); //������� ����� ���������
SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
// ThLog_Write('ThFT','SendFileCryptText ��������� - '+CryptBuf);
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    ThLog_Write('ThFT',2,'����� FT ������ ���������� � �������� ������ ');
    end;
  end;
end;

//-----------------------------------------------------------------------------
procedure TThread_Connection_TargetMain.TThread_Connection_Files.Execute;
var
  Position,posStart,posEnd,i: Integer;
  FileSize: Int64;
  ReceivingFile: Boolean;
  Buffer,DeCryptBuf,DeCryptBufTemp: string;
  BufferTemp: string;
  FName:String;
  FPatch,CountS,DWNLPathc:string;
  FileStream: TFileStream;
  NewFileStream: TFileStream;
  ClpbrdStream:TmemoryStream;
  SizeClpbdr,SizeFile:Int64;
  readBuf,sizeR:Int64;
  nRead : Int64;
  rBuf : Pointer;
  bSize:Int64;
  readBit:Int64;
  clpbrtbool:boolean;
  BadFile,EndFile:boolean;
  slepengtime,step:integer;
  TmpList:TstringList;
begin
try
  inherited;
  //ThLog_Write('ThFT','����� (FT) �������');
  PswrdCrypt:=frm_Main.ArrConnectSrv[IDConect].CurrentPswdCrypt; // ����������� ������� ������ ��� ���������� � ������
  ReceivingFile := False;
  FileStream := nil;
  bSize:=4096;
  readBit:=0;
  if not SendMainCryptText('<|REDIRECT|><|FILESCREATED|>')  then exit;
  while not terminated do
  begin
    Sleep(ProcessingSlack); // Avoids using 100% CPU
      if frm_Main.TimeoutDisconnect>MaxTimeTimeout then break;
      if (TgFileSocket = nil) or not(TgFileSocket.Connected) then Break;

     while (FrmMyProgress.Tag=1)or(FormFileTransfer.Tag=1) do
        begin
        Sleep(ProcessingSlack); // Avoids using 100% CPU
        if terminated then break;
        if (TgFileSocket = nil) or not(TgFileSocket.Connected) then Break;
        end;
     if TgFileSocket.ReceiveLength < 1 then Continue;

    DeCryptBuf := TgFileSocket.ReceiveText;   //����������� ������ ��������� � �������� �����
     if DeCryptBuf.Contains('<!>') then   // ������ ������ ������
      while not DeCryptBuf.Contains('<!!>') do // �������� ����� ������
      begin
      if terminated then break;
      Sleep(ProcessingSlack);
      if TgFileSocket.ReceiveLength < 1 then Continue;
      DeCryptBufTemp := TgFileSocket.ReceiveText;
      DeCryptBuf:=DeCryptBuf+DeCryptBufTemp;
      end;

    Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������

///------------------------------------------------------------------
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
           if frm_Main.Viewer then // ���� � ������� �������� ����� ������
          Synchronize(
            procedure
            begin
             FrmMyProgress.Height:=90;
             FrmMyProgress.ProgressBar1.Max:=SizeClpbdr;
             FrmMyProgress.ProgressBar1.Position:=0;
             FrmMyProgress.Caption:='����� ������ ������';
             FrmMyProgress.CancelLoadFile:=false;
             FrmMyProgress.Show;
            end);
           while readBit<SizeClpbdr do
            begin
            if FrmMyProgress.CancelLoadFile then
             begin
             SendFileCryptText('<|STOPLOADCLPBRD|>');
             break;  // ����� �� ����� ���� �������� �������� ������
             end;
            Sleep(ProcessingSlack);
            if TgFileSocket.ReceiveLength < 1 then  Continue;
            BufferTemp:=TgFileSocket.ReceiveText;
            bSize:=Length(BufferTemp);
            readBit:=readBit+bSize;
            if frm_Main.Viewer then // ���� � �������� �� �������� ����� ������
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

            Buffer:=DecryptReciveText(BufferTemp);// ��������� �������������� ������
             if pos('<|STOPLOADCLPBRD|>',Buffer)>0 then //���� ��������� ���������� �������� ������
              begin
              break;
              end;
            end;
          ClpbrdStream.Position:=0;
          if ClpbrdStream.Size>0 then
          if not ThLoadClipboard(ClpbrdStream) then ThLog_Write('ThF',1,'������ �������� ������ ������');
          Delete(Buffer, 1,length(Buffer));
          Delete(BufferTemp, 1,length(BufferTemp));
          finally
          ClpbrdStream.Free;
          if frm_Main.Viewer then // ���� � �������� �� �������� ����� ������
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
          ThLog_Write('ThF',2,'����� ������ �������� ������ ������');
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
        ThLog_Write('ThTF',2,'������ ������  (F), �������� �������� ');
        end;
      end;
     end;
   //---------------------------------------------------------------------------------
     if Pos('<|FOLDERSUCCESSFULLY|>', Buffer)>0 then  //������������� �������� ��������
      begin    //'<|FOLDERSUCCESSFULLY|>'+FPatch+'<|FEND|>'
      try
      BufferTemp:=Buffer;
      delete(BufferTemp,1,pos('<|FOLDERSUCCESSFULLY|>',BufferTemp)+21);
      FPatch:=copy(BufferTemp,1,pos('<|FEND|>',BufferTemp)-1);
       if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
         begin
         Synchronize(
         procedure
           begin
           with FormFileTransfer do
             begin
              if FPatch<>'' then
              begin
              if EditDirClient.Text=ExtractFilePath(FPatch+ '..') then  ButClientUpdate.Click;
              //FormFileTransfer.InMessage('������� "'+FPatch+'" ������',2);
              end
              else
              begin
              FormFileTransfer.InMessage('������� ��� ����������',2);
              end;
             end;
           end);
          end;
      except on E : Exception do
       begin
       ThLog_Write('ThTF',2,'������ ������  (F), ������������� �������� �������� ');
       end;
      end;
      end;
   //--------------------------------------------------------------------------
    if Pos('<|DELETEPATH|>', Buffer)>0 then // ������ ������ ������ � ��������� �� �������� �� ����� �������� ������
     begin  //'<|DELETEPATH|>'+EditDirClient.Text+'<|DELETELILST|>'+ListDelete.CommaText+'<|ENDDEL|>'
      try
       BufferTemp:=Buffer;
       delete(BufferTemp,1,pos('<|DELETEPATH|>',BufferTemp)+13);
       FPatch:=copy(BufferTemp,1,pos('<|DELETELILST|>',BufferTemp)-1);
       delete(BufferTemp,1,pos('<|DELETELILST|>',BufferTemp)+14);
       BufferTemp:=copy(BufferTemp,1,pos('<|ENDDEL|>',BufferTemp)-1);
       //ThLog_Write('ThTF',2,'����='+FPatch+' ������='+BufferTemp);
       ThReadDelete.ThreadDeleteList.Create(TgFileSocket,BufferTemp,FPatch,PswrdCrypt);// ����� �������� �� ������ ������ ��������� �� �������� '<|DELETESUCCESSFULLY|>
      except on E : Exception do
       begin
       ThLog_Write('ThTF',2,'����� ������ ������������ ������ �� ��������');
       end;
      end;
     end;
   //--------------------------------------------------------------------------
     if Pos('<|DELETESUCCESSFULLY|>', Buffer)>0 then // ������ ������������� �������� �� ����� �������� ������
     begin //'<|DELETESUCCESSFULLY|>'+PathDel+'<|END|>'
      BufferTemp:=Buffer;
      delete(BufferTemp,1,pos('<|DELETESUCCESSFULLY|>',BufferTemp)+21);
      FPatch:=copy(BufferTemp,1,pos('<|END|>',BufferTemp)-1);
      if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
       begin
       Synchronize(
       procedure
         begin
         with FormFileTransfer do
           begin
           if EditDirClient.Text=FPatch then  ButClientUpdate.Click;
           //FormFileTransfer.InMessage('�������� ���������',2);
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

          //ThLog_Write('ThF',2,'����� (F) FName='+FName+' SizeFile='+inttostr(SizeFile));
           // �������� �������� ���� ��� ���
           if not TDirectory.Exists(FPatch) then TDirectory.CreateDirectory(FPatch);
           NewFilestream:=TfileStream.Create(FPatch+Fname+'.tmp',fmCreate or fmOpenReadWrite);
           slepengtime:=0;
           if (frm_Main.Viewer) then //---------- ���� � ������
              begin
                Synchronize(
                procedure
                begin
                FrmMyProgress.Tag:=2; // ������� ������ ������ �� ������������ ��������, ���������� ����� �������� �� ��������� ����� �������
                FrmMyProgress.ProgressBar1.Max:=SizeFile;
                FrmMyProgress.ProgressBar1.Position:=0;
                FrmMyProgress.Caption:='�������� ����� '+FName+' '+CountS;
                if not FrmMyProgress.Visible then  //� ���� �� �������
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
                  SendFileCryptText('<|READYLOAD|>'); // ������� ����������� � ��������
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
                       if TgFileSocket.ReceiveLength < 1 then  Continue;

                      DeCryptBuf := TgFileSocket.ReceiveText;   //����������� ������ ��������� � ������� �����
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
                           ThLog_Write('ThF',1,'����� (F) ������� ����� �������� ������ ������ - '+inttostr(slepengtime));
                           SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
                           BadFile:=true;
                           slepengtime:=0;
                           break;
                           end;
                         end;

                      BufferTemp:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
                       if pos('<|ENDFILEFULL|>',BufferTemp)>0 then
                        begin
                        //ThLog_Write('ThF','����� (F) ������ <|ENDFILEFULL|>');
                        BufferTemp := StringReplace(BufferTemp, '<|ENDFILEFULL|>', '', [rfReplaceAll]);
                        BadFile:=false;
                        EndFile:=true; // ���� �� �� �������� �� �������� ��� ������ �� �����, ������ ������� ��������� ������ �����
                        end;    // ����� �� ������� ������ � ������ �� ��������  EndFile:=true;
                      if pos('<|BADFILE|>',BufferTemp)>0 then
                        begin
                        //ThLog_Write('ThF','����� (F) ������ <|BADFILE|>');
                        BadFile:=true;
                        break;
                        end;
                      if pos('<|STOPLOADFILES|>',Buffer)>0 then //���� ��������� ���������� �������� �����
                        begin
                        BadFile:=true; // ������ �����
                        break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                        end;

                      if frm_Main.Viewer then //---------- ���� � ������
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
                if frm_Main.Viewer then //---------- ���� � ������
                  begin
                    Synchronize(
                    procedure
                    begin
                    FrmMyProgress.Tag:=0; //������ ������� ������ ������ �� ������������ ��������, ���������� ����� �������� �� ��������� ����� �������
                    FrmMyProgress.Close;
                    end);
                  end;
                SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
                ThLog_Write('ThF',2,'����� (F) ����� ������ �������� �����');
                end;
           END;  //TRY

       FINALLY
       if not BadFile then
         begin
         SendFileCryptText('<|DNLDCMPLT|>'+Fname+'<|END|>'); // ������������� �� ��������� �������� �����
         end
        else SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
       FrmMyProgress.Tag:=0;
       if BadFile then  // ���� ������ ������ �����
        if frm_Main.Viewer then //---------- ���� � ������
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
      TRY //<|FILECOPY|>inttostr(SizeStream)<|FSIZE|>ExtractFileName(ListFileFolder[i])<|FNAME|>TmpFileDirectory<|ENDFILE|>(inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>'
          TRY
          BadFile:=false;
          EndFile:=false;
          BufferTemp:=Buffer;
          step:=1;
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
          step:=5;
          Delete(BufferTemp, 1,length(BufferTemp));
          //ThLog_Write('ThTF',2,'����� (F) FName='+FName+' SizeFile='+inttostr(SizeFile));
           if not TDirectory.Exists(FPatch) then TDirectory.CreateDirectory(FPatch); // �������� �������� ���� ��� ���
           NewFilestream:=TfileStream.Create(FPatch+Fname+'.tmp',fmCreate or fmOpenReadWrite);
          step:=6;
            if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
              begin
                Synchronize(
                procedure
                begin
                 with FormFileTransfer do
                  begin
                  ButCancel.Visible:=true; // ��������� ������ ������
                  ButCopyFromClient.Enabled:=false; // ��������� ������ �����������
                  ButCopyToClient.Enabled:=false; // ��������� ������ �����������
                  LoadFFProgressBar.Max:=SizeFile;
                  LoadFFProgressBar.Min:=0;
                  LoadFFProgressBar.Position:=0;
                  LoadFFProgressBar.ProgressText:=CountS+' �������� ����� '+FName;
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
               SendFileCryptText('<|READYLOAD|>'); // ������� ����������� � ��������
                while (NewFilestream.Size<SizeFile) and (not EndFile) do
                 BEGIN
                  if terminated then break;
                  if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
                  if FormFileTransfer.CancelLoadFile then//-- ���� �������� ��������
                   begin
                   SendFileCryptText('<|STOPLOADFILES|>');
                   ThLog_Write('ThTF',1,'����� (F) ������ �������� �����');
                   BadFile:=true;
                   break;
                   end;
                   Sleep(ProcessingSlack);
                  if TgFileSocket.ReceiveLength < 1 then  Continue;
                   DeCryptBuf := TgFileSocket.ReceiveText;   //����������� ������ ��������� � �����
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
                      ThLog_Write('ThTF',1,'����� (F) ������� ����� �������� ������ ������ - '+inttostr(slepengtime));
                      SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
                      BadFile:=true;
                      slepengtime:=0;
                      break;
                      end;
                    end;
                   step:=8;
                   BufferTemp:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������

                   if pos('<|ENDFILEFULL|>',BufferTemp)>0 then
                    begin
                    BufferTemp := StringReplace(BufferTemp, '<|ENDFILEFULL|>', '', [rfReplaceAll]);
                    BadFile:=false;// ������ ���
                    EndFile:=true; // ���� �� �� �������� �� �������� ��� ������ �� �����, ������ ������� ��������� ������ �����
                    end;    // ����� �� ������� ������ � ������ �� ��������  EndFile:=true;
                    if pos('<|BADFILE|>',BufferTemp)>0 then
                    begin
                    BadFile:=true;// ������ �����
                    break;
                    end;
                   if pos('<|STOPLOADFILES|>',Buffer)>0 then //���� ��������� ���������� �������� �����
                    begin
                    BadFile:=true; // ������ �����
                    break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                    end;
                    step:=9;
                   if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
                    begin
                    Synchronize(
                    procedure
                     begin
                     FormFileTransfer.LoadFFProgressBar.Position:=readBit;
                     FormFileTransfer.LoadFFProgressBar.ProgressText:=CountS+' �������� ����� '+FName;
                     end);
                    end;
                   step:=10;
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
            SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
            ThLog_Write('ThTF',2,'����� (F) ����� ������ �������� ����� ('+inttostr(step)+') '+FName+' - '+E.ClassName+': '+E.Message);
            end;
           END;  //TRY

       FINALLY
        if not BadFile then
         begin
         SendFileCryptText('<|DNLDCMPLT|>'+Fname+'<|END|>'); // ������������� �� ��������� �������� �����
         end
         else
          begin
          SendFileCryptText('<|DNLDERROR|>'); // ������� ������ �������� �����
          if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
           begin
            Synchronize(
            procedure
            begin
            with FormFileTransfer do
             begin
             LoadFFProgressBar.Visible:=false;
             ButCancel.Visible:=false; // ������� ������ ������
             ButCopyFromClient.Enabled:=true; // �������� ������ �����������
             ButCopyToClient.Enabled:=true; // �������� ������ �����������
             end;
            end);
           end;
          end;
        if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
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

      if Pos('<|ENDOFFILECOPY|>', Buffer)>0 then // ������� ��������� �������� ���� ������
     BEGIN
      try
      if FormFileTransfer.Visible  then //---------- ���� ������� ����� ����������� ������
       begin
       Synchronize(
       procedure
         begin
         with FormFileTransfer do
           begin
           ButCancel.Visible:=false; // ������� ������ ������
           ButCopyFromClient.Enabled:=true; // �������� ������ �����������
           ButCopyToClient.Enabled:=true; // �������� ������ �����������
           FormFileTransfer.LoadFFProgressBar.ProgressText:='';
           FormFileTransfer.LoadFFProgressBar.Visible:=false;
           ButLocalUpdate.Click; //�������� ������ �� ������� ��
           FormFileTransfer.InMessage('����������� ���������',2);
           end;
         end);
       end;
      Buffer := StringReplace(Buffer, '<|ENDOFFILETRANSFER|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,'������ ������ (F) ��������� �������� ������');
        end;
      end;
     END;


    if Pos('<|ENDOFFILETRANSFER|>', Buffer)>0 then
     BEGIN
      try
     //ThLog_Write('ThF','����� (F) ������ <|ENDOFFILETRANSFER|>');
      if frm_Main.Viewer then //---------- ���� � ������
       begin
       Synchronize(
       procedure
         begin
         FrmMyProgress.Tag:=0;
         FrmMyProgress.Caption:='�������� ���������';
         FrmMyProgress.Close;
         end);
       end;
      Buffer := StringReplace(Buffer, '<|ENDOFFILETRANSFER|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,'������ ������ (F) ��������� �������� ������');
        end;
      end;
     END;


 //-------------------------------------------------------------------------- �������� �������� ������ ������
 Position := Pos('<|DOWNLOADCLPBRD|>', Buffer); //
  if Position > 0 then
    BEGIN
      try
      step:=0;
      if ThClipBoardTheFiles then // ���� � ������ ������ ��������� �����
       begin
       step:=1;
       SendFileCryptText('<|DIRECTORYDOWNLOAD|>'); // ��������� ���������� ��� �������� ������
       step:=2;
       end
       else
       begin
       step:=3;
       ThFunctionClipboard(TgFileSocket,IDConect,'',PswrdCrypt);
       step:=4;
       end;
       step:=5;
      Buffer := StringReplace(Buffer, '<|DOWNLOADCLPBRD|>', '', [rfReplaceAll]);
      step:=6;
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,inttostr(step)+') ������ ������ (F) ������ ������ ������');
        end;
      end;
    END;
//------------------------------------------------------------------------ ���� ������ ������ �� ���������� ��� ������� ������ �� ������ ������
  Position := Pos('<|DIRECTORYDOWNLOAD|>', Buffer);
  if Position > 0 then
    BEGIN
      try
        Buffer := StringReplace(Buffer, '<|DIRECTORYDOWNLOAD|>', '', [rfReplaceAll]);
        Synchronize(frm_RemoteScreen.OpenDirectoryForFile);
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,'������ ������ (F) ������ �� ���������� ��������');
        end;
      end;
    END;
 //----------------------------------------------------------------------------- '<|DOWNLOADCLPBRDDIRECTORY|>'+FileName+'<|ENDFILE|>'
   Position := Pos('<|DOWNLOADCLPBRDDIRECTORY|>', Buffer);  //���������� �������� ������
   if Position > 0 then
    BEGIN
      try
      bufferTemp:=Buffer;
      Delete(bufferTemp, 1, pos('<|DOWNLOADCLPBRDDIRECTORY|>',bufferTemp) + 26);
      frm_ShareFiles.DirectoryToSaveFile:=(copy(bufferTemp,1,Pos('<|ENDFILE|>', bufferTemp) - 1));
      ThFunctionClipboard(TgFileSocket,IDConect,frm_ShareFiles.DirectoryToSaveFile,PswrdCrypt);
      ThLog_Write('ThTF',2,'������ ���������� �������� ������, �������� ������� ThFunctionClipboard');
      Delete(bufferTemp, 1,length(bufferTemp));
      Buffer := StringReplace(Buffer, '<|DIRECTORYDOWNLOAD|>', '', [rfReplaceAll]);
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,'������ ������ (F) ������ �� ������ ������� ������ ������');
        end;
      end;
    END;
//-------------------------------------------------------------------------------
    Position := Pos('<|SOURSEDIR|>', Buffer);  //����������� ������ � �������
   if Position > 0 then//'<|SOURSEDIR|>'+SourseDir+'<|ENDSDIR|><|SOURSELIST|>'+tmpListF.CommaText+'<|SOURSELISTEND|><|DESTDIR|>'+pathToCopy+'<|ENDDDIR|>'
    BEGIN  {FPatch,DWNLPathc:string; TmpList:TstringList;}
     try
     bufferTemp:=Buffer;
     delete(bufferTemp,1,position+12);
     posStart:= Pos('<|ENDSDIR|>', bufferTemp);
     DWNLPathc:=copy(bufferTemp,1,posStart-1); // ���������� �� ���� ���������� ����� � ��������
     if bufferTemp.Contains('<|SOURSELISTEND|>')  then // ���� ���� ���������� ������ ������ � ��������� �� �����������
      begin
      TmpList:=TstringList.Create;
        try
        posStart:= Pos('<|SOURSELIST|>', bufferTemp);
        delete(bufferTemp,1,posStart+13);
        posEnd:=Pos('<|SOURSELISTEND|>', bufferTemp);
        TmpList.CommaText:=copy(bufferTemp,1,posEnd-1);
        for I := 0 to TmpList.count-1 do TmpList[i]:=DWNLPathc+TmpList[i]; // ��������� ������ ���� �� ������ � ���������
        delete(bufferTemp,1,posEnd+16);
         if bufferTemp.Contains('<|ENDDDIR|>') then // ���� ���� ������� ���� ����������
          begin
           posStart:= Pos('<|DESTDIR|>', bufferTemp);
           delete(bufferTemp,1,posStart+10);
           posEnd:=Pos('<|ENDDDIR|>', bufferTemp);
           FPatch:=copy(bufferTemp,1,posEnd-1);
           ThreadCopyFileS.Create(
                      TgFileSocket, // ����� ��� �����������
                       IDConect, // ID ����������
                       TmpList, // ������ ������ � ��������� ��� �����������
                       FPatch,// ���� ��������
                      PswrdCrypt);  // ������ ��� ����������
          end;
        finally
        TmpList.Free;
        end;
      end;
      except on E : Exception do
        begin
        ThLog_Write('ThTF',2,'������ ������ (F) ������ ����������� ������ � ���������');
        end;
     end;
    END;

  end;  // while

//ThLog_Write('ThFT','����� (FT) ��������');
except on E : Exception do
    begin
    CloseFilesSocket; // ��������� �����, �������� �� ������ ����� ��������
    ThLog_Write('ThTF',2,'����� ������ ������ (FT): ');
    end;
  end;
end;


//-----------------------------------------------------------------------------------------------------------------
//����� ������ � ������� ������
//----------------------------------------------------------------------------------------------------------------
function TThread_Connection_TargetMain.TThread_Connection_Files.ThClipBoardTheFiles:boolean; // �������� ������ ������ �� ������� ������
var
WinHandle:HWND;
OwnerClpb:HWND;
begin
  try

     //OwnerClpb:=GetClipboardOwner; // ���������� ��������� ������ ������
     //ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: OwnerClpb='+inttostr(OwnerClpb));
    // WinHandle:=ThShellWindow;
     //ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: WinHandle='+inttostr(WinHandle));
    if not OpenClipboard(Application.Handle) then //GetShellWindow     GetDesktopWindow
      ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: OpenClipboard=0 Error='+SysErrorMessage(GetLastError));
    try
    result:=IsClipboardFormatAvailable(CF_HDROP);
    finally
    CloseClipboard;
    end;
    if result then  ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: � ������ ���������� �����')
    else ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: � ������ �� ���������� �����');
  except on E : Exception do// ���� ������ �� ������ ����� ���
  begin
  ThLog_Write('Clipboard',2,'ThClipBoardTheFiles: ������ ClipBoardTheFiles: '+E.ClassName+': '+E.Message);
  result:=false;
  end;
  end;

end;


function TThread_Connection_TargetMain.TThread_Connection_Files.ThFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean;
var
PswdCrypt:string[255];
begin
  try
  PswdCrypt:=PswdCryptClbrd;
    begin
     IF ThClipBoardTheFiles then // ���� � ������ ������ �����
      BEGIN
       if not frm_Main.Viewer then // ���� � ������ � ������� �����  �������
        Begin
         ThreadCopyFileSClipboard.Create(Socket,IDConect,DirPath,PswdCrypt);
        End
         else // ���� � ������ ������� ����� �� ������
        Begin // ������ �� ������� ���������� ��� ����������
        frm_ShareFiles.Tag:=IDConect;
        if frm_ShareFiles.ShowModal=1 then // ���� ������� ���������� ���������� �����
          Begin
          ThreadCopyFileSClipboard.Create(Socket,IDConect,frm_ShareFiles.DirectoryToSaveFile,PswdCrypt);
          End;
        End;
       END
       ELSE //
      BEGIN
      ThreadSendClipboard.Create(socket,PswdCrypt); // ������ ������ �������� ������ ������
      END;
   end;
   except on E : Exception do
    begin
    ThLog_Write('Clipboard',2,'ThFunctionClipboardT: ����� ������ ������ � ������� ������ : '+E.ClassName+': '+E.Message);
    end;
   end;
end;



function TThread_Connection_TargetMain.TThread_Connection_Files.ThShellWindow: HWND;
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





function TThread_Connection_TargetMain.TThread_Connection_Files.ThLoadClipboard(S: TStream):boolean; ///
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
      // CloseClipboard;
       Clipboard.Close;
     end; { Finally }
   finally
     reader.Free
   end; { Finally }
  except on E : Exception do ThLog_Write('Clipboard',2,'ThLoadClipboard : '+E.ClassName+': '+E.Message); end;
 end; { LoadClipboard }


function TThread_Connection_TargetMain.TThread_Connection_Files.ThLoadClipboardFormat(reader: TReader):boolean;///
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
       ThLog_Write('Clipboard',2,'ThLoadClipboardFormat: ������ RegisterCLipboardFormat: '+SysErrorMessage(GetLastError()));
     end;
   finally
     ms.Free;
   end; { Finally }
 except on E : Exception do
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThLoadClipboardFormat: ������ LoadClipboardFormat: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { LoadClipboardFormat }

function TThread_Connection_TargetMain.TThread_Connection_Files.ThCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean; ////
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
      // OpenClipboard(Application.Handle);
       try
         Clipboard.SetAsHandle(fmt, hMem);
         result:=true;
       finally
        //CloseClipboard;
         Clipboard.Close;
       end;
     end { If }
     else
     begin
       GlobalFree(hMem);
       result:=false;
       ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: ������ GlobalAlloc: '+SysErrorMessage(GetLastError()));
     end;
   end { If }
   else
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: ������ GlobalAlloc: '+SysErrorMessage(GetLastError()));
    end;
  except on E : Exception do
    begin
    result:=false;
    ThLog_Write('Clipboard',2,'ThCopyStreamToClipboard: ������ CopyStreamToClipboard: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { CopyStreamToClipboard }


//------------------------------------------------------------------------------------------------------------------------


end.

