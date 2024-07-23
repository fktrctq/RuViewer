unit Form_ShareFiles;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ImgList,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, System.ImageList,SocketCrypt;

type
  Tfrm_ShareFiles = class(TForm)
    ShareFiles_ListView: TListView;
    Menu_Panel: TPanel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    EditDirClient: TEdit;
    ImageIcon: TImageList;
    Button1: TButton;
    Button2: TButton;
    ComboRemoteDrive: TComboBoxEx;
    procedure FormShow(Sender: TObject);
    procedure EditDirClientKeyPress(Sender: TObject; var Key: Char);
    procedure ShareFiles_ListViewDblClick(Sender: TObject);
    procedure ShareFiles_ListViewKeyPress(Sender: TObject; var Key: Char);

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboRemoteDriveSelect(Sender: TObject);
  private
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure GoToDirectory(Directory: string);
    procedure EnterInDirectory;
    function SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
    function SendFilesSocket(s:ansistring):boolean; // Отправка через файловый соке
    function SendCryptFilesSocket(s:ansistring):boolean; // Отправка защифрованных данных в файловый сокет
    function SendCryptMainSocket(s:ansistring):boolean;  // Отправка защифрованных данных в основной сокет
    function Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
    { Private declarations }
  public
    DirectoryToSaveFile: string;
    FileStream: TFileStream;

    { Public declarations }
  end;

var
  frm_ShareFiles: Tfrm_ShareFiles;

implementation

{$R *.dfm}

uses
  Form_Main,Form_RemoteScreen,Osher;

  /// Log File
function Tfrm_ShareFiles.Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
 begin
   try
   result:=true;
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
    result:=false;
    exit;
    end;
  end;
end;

function Tfrm_ShareFiles.SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
begin
try
result:=true;
if frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].mainSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].mainSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   end
  else result:=false;
end;
except on E : Exception do Log_Write('app',2,'SendMainSocketShareFiles : '+inttostr(frm_ShareFiles.tag)+'  '+s+'  '+E.ClassName+': '+E.Message);  end;
end;

function Tfrm_ShareFiles.SendFilesSocket(s:ansistring):boolean; // Отправка через файловый сокет
begin
try
result:=true;
if frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].FilesSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].FilesSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].FilesSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   result:=true;
   end
  else result:=false;
end;
except on E : Exception do Log_Write('app',2,'SendFilesSocketShareFiles : '+E.ClassName+': '+E.Message);  end;
end;

function Tfrm_ShareFiles.SendCryptFilesSocket(s:ansistring):boolean;
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
  SendFilesSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
  result:=true;
   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('app',2,'ERROR  - ShareFile Ошибка шифрования (F) сокет'+ E.ClassName+' / '+ E.Message);
     end;
  end;

end;

function Tfrm_ShareFiles.SendCryptMainSocket(s:ansistring):boolean;
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[frm_ShareFiles.Tag].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
  SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
  result:=true;
   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('app',2,'ERROR  - ShareFile Ошибка шифрования (M) сокет'+ E.ClassName+' / '+ E.Message);
     end;
  end;

end;

procedure Tfrm_ShareFiles.GoToDirectory(Directory: string);
begin
  EditDirClient.Enabled := false;

  if not (Directory[Length(Directory)] = '\') then
  begin
    Directory := Directory + '\';
    EditDirClient.Text := Directory;
  end;

  SendCryptMainSocket('<|REDIRECT|><|GETFOLDERS|>' + Directory + '<|END|>');
end;



procedure Tfrm_ShareFiles.EnterInDirectory;
var
  Directory: string;
begin
  if (ShareFiles_ListView.ItemIndex = -1) or not(EditDirClient.Enabled) then
    exit;

  if (ShareFiles_ListView.Selected.ImageIndex = 0) or (ShareFiles_ListView.Selected.ImageIndex = 1) then
  begin
    if ShareFiles_ListView.Selected.Caption = 'Назад' then
    begin
      Directory := EditDirClient.Text;
      Delete(Directory, Length(Directory), Length(Directory));
      EditDirClient.Text := ExtractFilePath(Directory + '..');
    end
    else
      EditDirClient.Text := EditDirClient.Text + ShareFiles_ListView.Selected.Caption + '\';

    GoToDirectory(EditDirClient.Text);
  end;
end;

procedure Tfrm_ShareFiles.ShareFiles_ListViewDblClick(Sender: TObject);
begin
  EnterInDirectory;
end;

procedure Tfrm_ShareFiles.ShareFiles_ListViewKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    EnterInDirectory;
end;


procedure Tfrm_ShareFiles.Button1Click(Sender: TObject);
begin
DirectoryToSaveFile:=copy(EditDirClient.Text,1,length(EditDirClient.Text)-1); // убираем последний символ слеш '\'
end;

procedure Tfrm_ShareFiles.Button2Click(Sender: TObject);
begin
DirectoryToSaveFile:='';
end;

procedure Tfrm_ShareFiles.ComboRemoteDriveSelect(Sender: TObject);
begin
EditDirClient.Text:=ComboRemoteDrive.Text;
GoToDirectory(EditDirClient.Text); // запрос директории на удаленном ПК
end;

procedure Tfrm_ShareFiles.EditDirClientKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    GoToDirectory(EditDirClient.Text);
    Key := #0;
  end;
end;

procedure Tfrm_ShareFiles.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//frm_RemoteScreen.FolderButton.Picture.Assign(FormOsher.FolderCopyOff.Picture);
end;

procedure Tfrm_ShareFiles.FormCreate(Sender: TObject);
begin

  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
end;

procedure Tfrm_ShareFiles.FormShow(Sender: TObject);
begin
  SendCryptMainSocket('<|REDIRECT|><|GETLISTDRIVE|>'); //запрос списка дисков на удаленном ПК
  //GoToDirectory(Directory_Edit.Text);
end;

procedure Tfrm_ShareFiles.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
{ sets Size-limits for the Form }
var
  MinMaxInfo: PMinMaxInfo;
begin
{  inherited;
  MinMaxInfo := Message.MinMaxInfo;
  MinMaxInfo^.ptMinTrackSize.X := 515;
  MinMaxInfo^.ptMinTrackSize.Y := 460; }
end;

end.

