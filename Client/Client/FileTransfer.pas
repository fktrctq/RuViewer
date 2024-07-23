unit FileTransfer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.IOUtils, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.ExtCtrls,SocketCrypt,
  Vcl.VirtualImageList;

  type
  TProgressBarWithText = class(TProgressBar)
  private
    FProgressText: string;
  protected
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  published
    property ProgressText: string read FProgressText write FProgressText;
  end;
  
type
  TFormFileTransfer = class(TForm)
    LVClient: TListView;
    StatusPanel: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    LVLocal: TListView;
    EditDirClient: TEdit;
    ComboLocalDrive: TComboBoxEx;
    EditDirLocal: TEdit;
    ComboRemoteDrive: TComboBoxEx;
    PanelManagement: TPanel;
    LLocalCount: TLabel;
    LClientCount: TLabel;
    LLocalSize: TLabel;
    LClientSize: TLabel;
    VirtualImageList1: TVirtualImageList;
    ButLocalUpdate: TSpeedButton;
    ButCopyToClient: TSpeedButton;
    ButCancel: TSpeedButton;
    ButClientUpdate: TSpeedButton;
    ButCopyFromClient: TSpeedButton;
    ButLocalFolder: TSpeedButton;
    ButClientDel: TSpeedButton;
    ButLocalDel: TSpeedButton;
    ButClientFolder: TSpeedButton;
    function Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
    function SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
    function SendFilesSocket(s:ansistring):boolean; // Отправка через файловый сокет
    function SendCryptFilesSocket(s:ansistring):boolean; // Шифрование и отправка через файловый сокет
    function SendCryptMainSocket(s:ansistring):boolean; // Шифрование и отправка через основной сокет
    procedure GoToClientDirectory(Directory: string);
    procedure EnterInClientDirectory; // вормирование директории для загрузки списка файлов и папок клиентского окна
    procedure EnterInLocalDirectory;   // вормирование директории для загрузки списка файлов и папок клиентского окна
    procedure UpdateInLocalDirectory; // обновление списка каталогов и файлов текущей директории на локальном ПК
    function DeleteFile(s:string):boolean; // функция удаления файла
    function DeleteFolder(s:string):boolean; // функция удаления каталога
    Function CreateFolderLocal(s:string):boolean; // создание каталога локально
    procedure UpdateInClientDirectory; // обновление списка каталогов и файлов текущей директории на клиенте ПК
    procedure FormDefaultUpd; // форма по умолчанию кнопки и вя остальная хуйня
    procedure LVClientDblClick(Sender: TObject);
    procedure LVClientKeyPress(Sender: TObject; var Key: Char);
    procedure EditDirClientKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    Procedure GetlistDrv; // вывод списка дисков на локальном ПК
    function GetListFileFolder(Dir:string; BackDir:boolean):boolean;
    function LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; //Время последнего изменения
    function GetFileSize(const aFilename: String): String; //размер файла
    procedure ComboLocalDriveSelect(Sender: TObject);
    procedure LVLocalDblClick(Sender: TObject);
    procedure ComboRemoteDriveSelect(Sender: TObject);
    procedure ButCopyToClientClick(Sender: TObject);// вывод списка файлов и каталогов указаной директории на локальном ПК
    procedure InMessage(TextMessage:string;TypeMess:integer) ;
    procedure ButCancelClick(Sender: TObject);
    procedure ButCopyFromClientClick(Sender: TObject);
    procedure LVLocalKeyPress(Sender: TObject; var Key: Char);
    procedure ButLocalUpdateClick(Sender: TObject);
    procedure ButClientUpdateClick(Sender: TObject);
    procedure LVLocalSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LVClientSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ButClientFolderClick(Sender: TObject);
    procedure ButClientDelClick(Sender: TObject);
    procedure LVClientKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButLocalDelClick(Sender: TObject);
    procedure ButLocalFolderClick(Sender: TObject);
    procedure LVLocalKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean); // отображение сообщения для пользователя
  private
    SizeSelectFileLocal:int64;
    SizeSelectFileClient:int64;
  public
    DirectoryToSaveFile: string;
    FileStream: TFileStream;
    CancelLoadFile:boolean;

    LoadFFProgressBar:TProgressBarWithText;
    IDConnect:byte; // ID соединения, для передачи в поток копирования файлов
  end;




var
  FormFileTransfer: TFormFileTransfer;


implementation
uses Form_Main,ThReadCopyFileFolder,Form_Settings;

{$R *.dfm}

procedure TProgressBarWithText.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  prevfont: HGDIOBJ;
  prevbkmode: Integer;
  R: TRect;
begin
  inherited;
  if ProgressText <> '' then
  begin
    R := ClientRect;
    DC := GetWindowDC(Handle);
    prevbkmode := SetBkMode(DC, TRANSPARENT);
    prevfont := SelectObject(DC, Font.Handle);
    DrawText(DC, PChar(ProgressText), Length(ProgressText),
      R, DT_SINGLELINE or DT_CENTER or DT_VCENTER);
    SelectObject(DC, prevfont);
    SetBkMode(DC, prevbkmode);
    ReleaseDC(Handle, DC);
  end;
end;

procedure TFormFileTransfer.InMessage(TextMessage:string;TypeMess:integer) ; // отображение сообщения для пользователя
begin
  case TypeMess of
  0:MessageDlg(TextMessage,mtWarning, [mbYes], 0);
  1:MessageDlg(TextMessage,mtError, [mbYes], 0);
  2:MessageDlg(TextMessage,mtInformation, [mbYes], 0);
  3:MessageDlg(TextMessage,mtConfirmation, [mbYes], 0);
  4:MessageDlg(TextMessage,mtCustom, [mbYes], 0);
  end;
end;


procedure TFormFileTransfer.FormDefaultUpd;
begin
ButCancel.Visible:=false; // скрываю кнопку отмены
ButCopyFromClient.Enabled:=true; // включаем кнопку копирования
ButCopyToClient.Enabled:=true; // включаем кнопку копирования
LoadFFProgressBar.Visible:=false;//скрываем прогрессбар
LLocalSize.Caption:='';
LLocalCount.Caption:='';
LClientSize.Caption:='';
LClientCount.Caption:='';
LVLocal.Clear;
LVClient.Clear;
FormFileTransfer.Tag:=0; //1 - признак передачи файла через  поток CopyFileFolder, необхождимо чтобы file поток ожидал текущий
CancelLoadFile:=false;//признак разрешени передачи файла/ true - признак отмены загрузки
end;

function TFormFileTransfer.Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
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


function TFormFileTransfer.SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IDConnect].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IDConnect].mainSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[IDConnect].mainSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   end
  else result:=false;
end;
except on E : Exception do Log_Write('FileTransfer',2,'SendMainSocketShareFiles : '+inttostr(IDConnect)+'  '+s+'  '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.LVClientDblClick(Sender: TObject);
begin
LClientSize.Caption:='';
LClientCount.Caption:='';
EnterInClientDirectory;
end;

procedure TFormFileTransfer.LVClientKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key = VK_DELETE) then ButClientDel.Click;    // Del
 if (Key = VK_F5) then ButClientUpdate.Click; // обновить
 if (Key = VK_RETURN) then EnterInClientDirectory; // Enter
 end;

procedure TFormFileTransfer.LVClientKeyPress(Sender: TObject;
  var Key: Char);
begin
 //if (Key = #13) then EnterInClientDirectory; // Enter

end;



procedure TFormFileTransfer.LVLocalKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (Key = VK_DELETE) then ButLocalDel.Click;    // Del
 if (Key = VK_F5) then ButLocalUpdate.Click; // обновить
 if (Key = VK_RETURN) then EnterInLocalDirectory; // Enter
end;

procedure TFormFileTransfer.LVLocalKeyPress(Sender: TObject; var Key: Char);
begin
 if (Key = #13) then
    EnterInLocalDirectory;
end;






function TFormFileTransfer.SendFilesSocket(s:ansistring):boolean; // Отправка через файловый сокет
begin
try
result:=true;
if frm_Main.ArrConnectSrv[IDConnect].FilesSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[IDConnect].FilesSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[IDConnect].FilesSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   result:=true;
   end
  else result:=false;
end;
except on E : Exception do Log_Write('FileTransfer',2,'SendFilesSocketShareFiles : '+E.ClassName+': '+E.Message);  end;
end;


function TFormFileTransfer.SendCryptFilesSocket(s:ansistring):boolean; // Шифрование и отправка через файловый сокет
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
  result:=SendFilesSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь

   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('FileTransfer',2,'ERROR  - ShareFile Ошибка шифрования (F) сокет'+ E.ClassName+' / '+ E.Message);
     end;
  end;
end;


function TFormFileTransfer.SendCryptMainSocket(s:ansistring):boolean; // Шифрование и отправка через основной сокет
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
  result:=SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('FileTransfer',2,'ERROR  - ShareFile Ошибка шифрования (M) сокет'+ E.ClassName+' / '+ E.Message);
     end;
  end;

end;

procedure TFormFileTransfer.GoToClientDirectory(Directory: string); // Отправка клиенту директории для загрузки
begin
  EditDirClient.Enabled := false;
  if not (Directory[Length(Directory)] = '\') then  // проверка наличия "\"
  begin
    Directory := Directory + '\';
    EditDirClient.Text := Directory;
  end;
  SendCryptMainSocket('<|REDIRECT|><|GETFOLDERS|>' + Directory + '<|END|>');
end;




procedure TFormFileTransfer.EnterInClientDirectory;   // вормирование директории для загрузки списка файлов и папок клиентского окна
var
  Directory: string;
begin
try
  if (LVClient.ItemIndex = -1) or not(EditDirClient.Enabled) then
    exit;

  if (LVClient.Selected.ImageIndex = 0) or (LVClient.Selected.ImageIndex = 1) then
  begin
    if LVClient.Selected.Caption = 'Назад' then
    begin
      Directory := EditDirClient.Text;
      Delete(Directory, Length(Directory), Length(Directory));
      EditDirClient.Text := ExtractFilePath(Directory + '..');
    end
    else
      EditDirClient.Text := EditDirClient.Text + LVClient.Selected.Caption + '\';

   GoToClientDirectory(EditDirClient.Text);
  end;
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка EnterInClientDirectory: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.EnterInLocalDirectory;   // вормирование директории для загрузки списка файлов и папок локального окна
var
  Directory: string;
begin
try
if (LVlocal.ItemIndex = -1)  then exit;
  if (LVlocal.Selected.ImageIndex = 0) or (LVlocal.Selected.ImageIndex = 1) then
  begin
    if(LVlocal.Selected.ImageIndex = 0) and (LVlocal.Selected.Caption = 'Назад') then
     begin
      Directory := EditDirLocal.Text;
      Delete(Directory, Length(Directory), Length(Directory));
      EditDirLocal.Text := ExtractFilePath(Directory+'..');
      if EditDirLocal.Text=ComboLocalDrive.Text then
      GetListFileFolder(EditDirLocal.Text,false) // если в пути корневой диск
      else GetListFileFolder(EditDirLocal.Text,true);  // иначе в корне каталог
     end
    else // иначе переход в каталог
     begin
      EditDirLocal.Text := EditDirLocal.Text + LVLocal.Selected.Caption + '\';
      GetListFileFolder(EditDirLocal.Text,true);
     end;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка EnterInLocalDirectory: '+E.ClassName+': '+E.Message);  end;
end;


//
procedure TFormFileTransfer.UpdateInClientDirectory; // обновление списка каталогов и файлов текущей директории на клиенте ПК
begin
if EditDirClient.Text<>'' then GoToClientDirectory(EditDirClient.Text);
end;

procedure TFormFileTransfer.UpdateInLocalDirectory; // обновление списка каталогов и файлов текущей директории на локальном ПК
begin
if (EditDirLocal.Text='')and(EditDirLocal.Text='') then exit;

if EditDirLocal.Text=ComboLocalDrive.Text then // мы в корне диска
  GetListFileFolder(EditDirLocal.Text,false)
  else GetListFileFolder(EditDirLocal.Text,true);
end;

procedure TFormFileTransfer.LVLocalDblClick(Sender: TObject);
begin
LLocalSize.Caption:='';
LLocalCount.Caption:='';
EnterInLocalDirectory;
end;





procedure TFormFileTransfer.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
//if NewWidth>1000 then Resize := False;
//if NewHeight>700 then  Resize := False;
end;




procedure TFormFileTransfer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if (LoadFFProgressBar.Visible) or (FormFileTransfer.Tag=1) then // значит идет процесс копирования поток
 begin
  if MessageDlg('Остановить процесс копирования?',mtConfirmation,[mbYes,mbCancel], 0)=mrYes then
   begin
   CancelLoadFile:=true; //останавливаем процесс копирования
     while (FormFileTransfer.Tag<>0) or (LoadFFProgressBar.Visible) do //ожидаем остановки
     begin
     Application.ProcessMessages;
     sleep(2);
     end;
    FormFileTransfer.Tag:=0; //снимаем признак передачи файла через поток CopyFileFolder.
   end;
 end
 else
 begin
 CancelLoadFile:=true;
 FormFileTransfer.Tag:=0; //снимаем признак передачи файла через поток CopyFileFolder.
 end;

CanClose:=CancelLoadFile;
end;

procedure TFormFileTransfer.FormCreate(Sender: TObject);
begin
  try
  FormFileTransfer.Tag:=0;//1 - признак передачи файла через  поток CopyFileFolder, необхождимо чтобы file поток ожидал текущий
  CancelLoadFile:=false; //признак разрешени передачи файла/ true - признак отмены загрузки
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
  LoadFFProgressBar:=TProgressBarWithText.Create(StatusPanel);
  LoadFFProgressBar.Parent:= StatusPanel;
  LoadFFProgressBar.Align:=AlClient;
  //LoadFFProgressBar.Style:=pbstMarquee;
  LoadFFProgressBar.Top:=0;
  LoadFFProgressBar.Left:=0;
  LoadFFProgressBar.Width:=StatusPanel.Width-LoadFFProgressBar.Left;
  LoadFFProgressBar.Height:=StatusPanel.Height;
  LoadFFProgressBar.Max:=100;
  LoadFFProgressBar.Position:=0;
  LoadFFProgressBar.Visible:=false;
  except on E : Exception do Log_Write('FileTransfer',2,'Ошибка FormCreate FileTransfer: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.FormShow(Sender: TObject);
begin
FormDefaultUpd;
GetlistDrv; // запрос списка дисков на локальном ПК
SendCryptMainSocket('<|REDIRECT|><|GETLISTDRIVE|>'); //запрос списка дисков на удаленном ПК
end;




procedure TFormFileTransfer.ComboRemoteDriveSelect(Sender: TObject);
begin
EditDirClient.Text:=ComboRemoteDrive.Text;
GoToClientDirectory(EditDirClient.Text); // запрос директории на удаленном ПК
LClientCount.Caption:='Удаленный компьютер';
end;

procedure TFormFileTransfer.EditDirClientKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key = #13) then
  begin
    GoToClientDirectory(EditDirClient.Text);
    Key := #0;
  end;
end;

procedure TFormFileTransfer.ButCancelClick(Sender: TObject);
begin
CancelLoadFile:=true; // отменяем копирование
end;

procedure TFormFileTransfer.ButCopyToClientClick(Sender: TObject); // копирование на клиента
var
tmpListF:TstringList;
pathToCopy:string;
i:integer;
begin
try
if LVLocal.Items.Count<1 then exit;
 if LVLocal.SelCount<1 then
 begin
 showmessage('Не выбраны файлы для копирования');
 exit;
 end;
  tmpListF:=TstringList.Create;
  try
  for I := 0 to LVLocal.Items.Count-1 do
    begin  
     if LVLocal.Items[i].Selected then  // если элемент выбран
     if LVLocal.Items[i].ImageIndex<>0 then  //если это не запись Назад
      tmpListF.Add(EditDirLocal.Text+LVLocal.Items[i].Caption); // список что копируем
    end;
  if tmpListF.Count>0 then
  begin
  CancelLoadFile:=false; // разрешаем копирование
  pathToCopy:=copy(EditDirClient.Text,1,length(EditDirClient.Text)-1); // убираем последний символ слеш '\'
  ThreadCopyFileS.Create(
                      frm_Main.ArrConnectSrv[IDConnect].FilesSock, // сокет для копирвоания
                       IDConnect, // ID соединения
                       tmpListF, // список файлов и каталогов для копирования
                       pathToCopy,// куда копируем
                       frm_Main.ArrConnectSrv[IDConnect].SrvPswd);
  end
  else showmessage('Не выбраны файлы для копирования');
  finally
  tmpListF.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка CopyToClient: '+E.ClassName+': '+E.Message);  end;
end;



function TFormFileTransfer.DeleteFolder(s:string):boolean; // функция удаления каталога
begin
  try
  if TDirectory.Exists(s) then // если существует то удаляем
    begin
    TDirectory.Delete(s,true); // рекурсивное удаление
    result:=true;
    end
  else result:=false;
  except
  result:=false;
  end;
end;

function TFormFileTransfer.DeleteFile(s:string):boolean; // функция удаления файла
begin
  try
  if TFILE.Exists(s) then // если существует то удаляем
    begin
    TFILE.Delete(s);
    result:=true;
    end
  else result:=false;
  except
  result:=false;
  end;
end;

Function TFormFileTransfer.CreateFolderLocal(s:string):boolean; // создание каталога локально
begin
 try
 if not TDirectory.Exists(s) then
  begin
  TDirectory.CreateDirectory(s);
  result:=true;
  end
 else result:=false;
  except
  result:=false;
 end;
end;



procedure TFormFileTransfer.ButLocalDelClick(Sender: TObject);
begin
var
i:integer;
begin
   try
    if LVLocal.Items.Count<1 then exit;
    if LVLocal.SelCount=0 then exit;

      if LVLocal.SelCount=1 then
       begin
        if LVLocal.Selected.ImageIndex<>0 then  //если не назад
        begin
        if  MessageDlg('Подтвердите удаление!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
        if LVLocal.Selected.ImageIndex=1 then // это каталог
         DeleteFolder(EditDirLocal.text+LVLocal.Selected.Caption)
         else // иначе файл
        DeleteFile(EditDirLocal.text+LVLocal.Selected.Caption);
        end;
       end
      else
       begin
       if  MessageDlg('Подтвердите удаление!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
        for I := 0 to LVLocal.Items.Count-1 do
         begin
         Application.ProcessMessages;
          if LVLocal.Items[i].Selected then
           begin
           if LVLocal.Items[i].ImageIndex<>0 then //если не назад
            begin
            if LVLocal.Items[i].ImageIndex=1 then // это каталог
             DeleteFolder(EditDirLocal.text+LVLocal.Items[i].Caption)
             else // иначе файл
            DeleteFile(EditDirLocal.text+LVLocal.Items[i].Caption);
            end;
           end;
         end;
       end;
     UpdateInLocalDirectory; //обновить
   except on E : Exception do Log_Write('FileTransfer',2,'Ошибка DeleteLocal: '+E.ClassName+': '+E.Message);  end;
  end;
end;



procedure TFormFileTransfer.ButLocalFolderClick(Sender: TObject);
var
sF:string;
begin
if InputQuery('Новый каталог', 'Имя каталога', sF) then
if sF<>'' then
if CreateFolderLocal(EditDirLocal.text+sF) then UpdateInLocalDirectory; //обновить
end;

procedure TFormFileTransfer.ButLocalUpdateClick(Sender: TObject);
begin
UpdateInLocalDirectory; //обновить
end;

procedure TFormFileTransfer.ButClientDelClick(Sender: TObject); // удалить файлы или каталоги на клиенте
var
i:integer;
ListDelete:TstringList;
ForF:integer;
begin
try
if LVClient.Items.Count<1 then exit;
if LVClient.SelCount=0 then exit;
ListDelete:=TstringList.Create;
  try
  if LVClient.SelCount=1 then
   begin
    if LVClient.Selected.ImageIndex<>0 then  //если не назад
    begin
    ForF:=LVClient.Selected.ImageIndex;
    ListDelete.Add(LVClient.Selected.Caption+'='+inttostr(ForF));
    end;
   end
  else
   begin
    for I := 0 to LVClient.Items.Count-1 do
     begin
      if LVClient.Items[i].Selected then
       begin
       if LVClient.Items[i].ImageIndex<>0 then //если не назад
        begin
        ForF:=LVClient.Items[i].ImageIndex;
        ListDelete.Add(LVClient.Items[i].Caption+'='+inttostr(ForF));
        end;
       end;
     end;
   end;

  if  MessageDlg('Подтвердите удаление!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
  SendCryptFilesSocket('<|DELETEPATH|>'+EditDirClient.Text+'<|DELETELILST|>'+ListDelete.CommaText+'<|ENDDEL|>');
  finally
  ListDelete.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка DeleteClient: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.ButClientFolderClick(Sender: TObject); // создать каталог на клиенте
var
sF:string;
begin
if EditDirClient.Text<>'' then
 begin
 if InputQuery('Новый каталог', 'Имя каталога', sF) then
 if sF<>'' then SendCryptFilesSocket('<|CREATEFOLDER|>'+EditDirClient.Text+sF+'<|ENDDIR|>');
 end;
end;

procedure TFormFileTransfer.ButClientUpdateClick(Sender: TObject);
begin
UpdateInClientDirectory; //обновить
end;

procedure TFormFileTransfer.ButCopyFromClientClick(Sender: TObject); // копирование с клиента
var
tmpListF:TstringList;//  список выбранных файлов и каталогов
pathToCopy:string;  // куда копируем
SourseDir:string; // директория выбранных файлов и каталогов
i:integer;
begin
try
if LVClient.Items.Count<1 then exit;

if LVClient.SelCount<1 then
 begin
 showmessage('Не выбраны файлы для копирования');
 exit;
 end;
  tmpListF:=TstringList.Create;
  try
  for I := 0 to LVClient.Items.Count-1 do
    begin  
     if LVClient.Items[i].Selected then  // если элемент выбран
     if LVClient.Items[i].ImageIndex<>0 then  //если это не запись Назад
      tmpListF.Add(LVClient.Items[i].Caption); // список что копируем
    end;
  if tmpListF.Count>0 then
   begin
   CancelLoadFile:=false; // разрешаем копирование
   SourseDir:=EditDirClient.Text;
   pathToCopy:=copy(EditDirLocal.Text,1,length(EditDirLocal.Text)-1); // убираем последний символ слеш '\'
   SendCryptFilesSocket('<|SOURSEDIR|>'+SourseDir+'<|ENDSDIR|><|SOURSELIST|>'+tmpListF.CommaText+'<|SOURSELISTEND|><|DESTDIR|>'+pathToCopy+'<|ENDDDIR|>');
   end
  else showmessage('Не выбраны файлы для копирования');
  finally
  tmpListF.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка CopyToClient: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.ComboLocalDriveSelect(Sender: TObject); // выбор диска на локальном ПК
begin
EditDirLocal.Text:=ComboLocalDrive.Text;
GetListFileFolder(ComboLocalDrive.Text,false);
LLocalCount.Caption:='Локальный компьютер';
end;

function GetSysDir(drv:string): boolean;
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


Procedure TFormFileTransfer.GetlistDrv; // вывод списка дисков на локальном ПК
var
s:string;
i:byte;
begin
  try
     ComboLocalDrive.Clear;
     LVLocal.Clear;
     i:=0;
     for s in TDirectory.GetLogicalDrives do
     begin
     ComboLocalDrive.Items.Add(s);
     ComboLocalDrive.ItemsEx[i].ImageIndex:=TypeDiskDrive(s);
     inc(i);
     end;

     if ComboLocalDrive.Items.Count>0 then
     begin
     ComboLocalDrive.ItemIndex:=0;
     ComboLocalDrive.OnSelect(ComboLocalDrive);
     end
     else ComboLocalDrive.Text:='Список дисков';

  except on E : Exception do Log_Write('FileTransfer',2,'Ошибка GetlistDrv Local: '+E.ClassName+': '+E.Message);  end;
end;



function FormatByteSize(const bytes: int64; OutUnit:byte): string;
const
  B = 1; //byte
  KB = 1024 * B; //kilobyte
  MB = 1024 * KB; //megabyte
  GB = 1024 * MB; //gigabyte
begin
try
 case OutUnit of
  1: result := FormatFloat('#.## bytes', bytes); // результат в байтах
  2: Begin                                       // результат в килобайтах
     if bytes > KB then result := FormatFloat('#.## KB', bytes / KB)
     else
     result := '1 KB';
     End;
  3: result := FormatFloat('#.## MB', bytes / MB); // результат в мегабайтах
  4: result := FormatFloat('#.## GB', bytes / GB); // результат в Гигабайтах
  5: Begin                                          // результат с автоматическим определением
     if bytes > GB then
     result := FormatFloat('#.## GB', bytes / GB)
     else if bytes > MB then
     result := FormatFloat('#.## MB', bytes / MB)
     else if bytes > KB then
     result := FormatFloat('#.## KB', bytes / KB)
     else
     result := FormatFloat('#.## bytes', bytes);
     End;
 end;

except result:=''  end;
end;


procedure TFormFileTransfer.LVLocalSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
SizeTmp:Extended;
begin
try
if LVLocal.SelCount>0 then
  begin
    if LVLocal.SelCount=1 then
     Begin
       begin
       if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
         begin
          if Item.Selected then // если выделен
          begin
          SizeSelectFileLocal:=round(SizeTmp*1024);
          LLocalSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileLocal,5);
          end
          else
          begin // иначе выделеие снято
           if round(SizeTmp*1024)<SizeSelectFileLocal then
           begin
           SizeSelectFileLocal:=SizeSelectFileLocal-round(SizeTmp*1024);
           LLocalSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileLocal,5);
           end
           else
           begin
           SizeSelectFileLocal:=0;
           LLocalSize.Caption:='';
           end;
          end;
         end
        else
         begin
         SizeSelectFileLocal:=0;
         LLocalSize.Caption:='';
         end;
       end;
     End
   else
     begin
     if Item.SubItems[1]<>'' then //если указан размер файла
     if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
       begin
         if Item.Selected then // если этот итем выделен то суммируем
          begin
          SizeSelectFileLocal:=SizeSelectFileLocal+round(SizeTmp*1024);
          LLocalSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileLocal,5);
          end
          else // иначе вычитаем
          begin
          if round(SizeTmp*1024)<SizeSelectFileLocal then
           begin
           SizeSelectFileLocal:=SizeSelectFileLocal-round(SizeTmp*1024);
           LLocalSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileLocal,5);
           end
           else
           begin
           SizeSelectFileLocal:=0;
           LLocalSize.Caption:='';
           end;
          end;
       end
      else
       begin
       SizeSelectFileLocal:=0;
       LLocalSize.Caption:='';
       end;
     end;
  end;
LLocalCount.Caption:='Всего: '+inttostr(LVLocal.Items.Count)+' Выбрано: '+inttostr(LVLocal.SelCount);
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка LocalSelectItem: '+E.ClassName+': '+E.Message);  end;
end;




procedure TFormFileTransfer.LVClientSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
SizeTmp:Extended;
begin
try
if LVClient.SelCount>0 then
  begin
    if LVClient.SelCount=1 then
     Begin
       begin
       if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
         begin
          if Item.Selected then // если выделен
          begin
          SizeSelectFileClient:=round(SizeTmp*1024);
          LClientSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileClient,5);
          end
          else
          begin // иначе выделеие снято
           if round(SizeTmp*1024)<SizeSelectFileClient then
           begin
           SizeSelectFileClient:=SizeSelectFileClient-round(SizeTmp*1024);
           LClientSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileClient,5);
           end
           else
           begin
           SizeSelectFileClient:=0;
           LClientSize.Caption:='';
           end;
          end;
         end
        else
         begin
         SizeSelectFileClient:=0;
         LClientSize.Caption:='';
         end;
       end;
     End
   else
     begin
     if Item.SubItems[1]<>'' then //если указан размер файла
     if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
       begin
         if Item.Selected then // если этот итем выделен то суммируем
          begin
          SizeSelectFileClient:=SizeSelectFileClient+round(SizeTmp*1024);
          LClientSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileClient,5);
          end
          else // иначе вычитаем
          begin
          if round(SizeTmp*1024)<SizeSelectFileClient then
           begin
           SizeSelectFileClient:=SizeSelectFileClient-round(SizeTmp*1024);
           LClientSize.Caption:='Размер: '+FormatByteSize(SizeSelectFileClient,5);
           end
           else
           begin
           SizeSelectFileClient:=0;
           LClientSize.Caption:='';
           end;
          end;
       end
      else
       begin
       SizeSelectFileClient:=0;
       LClientSize.Caption:='';
       end;
     end;
  end;
LClientCount.Caption:='Всего: '+inttostr(LVClient.Items.Count)+' Выбрано: '+inttostr(LVClient.SelCount);
except on E : Exception do Log_Write('FileTransfer',2,'Ошибка ClientSelectItem: '+E.ClassName+': '+E.Message);  end;
end;


function TFormFileTransfer.GetFileSize(const aFilename: String): String; //размер файла
var
  sr : TSearchRec;
begin
try
  if FindFirst(aFilename, faAnyFile, sr ) = 0 then
  begin
     Result:=FormatByteSize(Sr.Size,2); // результат в КБ
  end else
  begin
     result :='';
  end;
  FindClose(sr);
except result:=''  end;
end;

function TFormFileTransfer.LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; //Время последнего изменения
begin
try
 if FileOrFolder then result:=DateTimeToStr(TFile.GetLastWriteTime(s))
 else result:=DateTimeToStr(TDirectory.GetLastWriteTime(s));
except result:=''  end;
end;

function TFormFileTransfer.GetListFileFolder(Dir:string; BackDir:boolean):boolean;// вывод списка файлов и каталогов указаной директории на локальном ПК
var
s:string;
begin
try
LVLocal.Clear;
 if BackDir then // если указана не корневая директория, т.е. не диск
  begin
  with LVLocal.Items.Add do //добавляем запись на возврат в предыдущую директорию
   begin
   caption:='Назад';
   imageIndex:=0;
   subitems.Add('');
   subitems.Add('');
   end;
  end;

for s in TDirectory.GetDirectories(Dir) do
  begin
   with LVLocal.Items.Add do //добавляем каталог, s содержит полный путь начиная с диска
   begin
   caption:=StringReplace(s, Dir,'',[rfIgnoreCase]);
   imageIndex:=1;
   subitems.Add(LastWriteTimeFileOrFolder(s,false));
   subitems.Add('');
   end;
  end;

for s in TDirectory.GetFiles(Dir) do
  begin
   with LVLocal.Items.Add do //добавляем файлы, s содержит полный путь начиная с диска
   begin
   caption:=ExtractFileName(s);//StringReplace(s, Dir,'',[rfIgnoreCase]);
   imageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(caption))); // запрос иконки файла на основании его расширения
   subitems.Add(LastWriteTimeFileOrFolder(s,true));
   subitems.Add(GetFileSize(s));
   end;
  end;

except on E : Exception do Log_Write('FileTransfer',2,'Ошибка GetlistFileFolder Local: '+E.ClassName+': '+E.Message);  end;
end;

end.
