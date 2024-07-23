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
    function SendMainSock(s:ansistring):boolean; // �������� ����� ������� �����
    function SendFilesSocket(s:ansistring):boolean; // �������� ����� �������� �����
    function SendCryptFilesSocket(s:ansistring):boolean; // ���������� � �������� ����� �������� �����
    function SendCryptMainSocket(s:ansistring):boolean; // ���������� � �������� ����� �������� �����
    procedure GoToClientDirectory(Directory: string);
    procedure EnterInClientDirectory; // ������������ ���������� ��� �������� ������ ������ � ����� ����������� ����
    procedure EnterInLocalDirectory;   // ������������ ���������� ��� �������� ������ ������ � ����� ����������� ����
    procedure UpdateInLocalDirectory; // ���������� ������ ��������� � ������ ������� ���������� �� ��������� ��
    function DeleteFile(s:string):boolean; // ������� �������� �����
    function DeleteFolder(s:string):boolean; // ������� �������� ��������
    Function CreateFolderLocal(s:string):boolean; // �������� �������� ��������
    procedure UpdateInClientDirectory; // ���������� ������ ��������� � ������ ������� ���������� �� ������� ��
    procedure FormDefaultUpd; // ����� �� ��������� ������ � �� ��������� �����
    procedure LVClientDblClick(Sender: TObject);
    procedure LVClientKeyPress(Sender: TObject; var Key: Char);
    procedure EditDirClientKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    Procedure GetlistDrv; // ����� ������ ������ �� ��������� ��
    function GetListFileFolder(Dir:string; BackDir:boolean):boolean;
    function LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; //����� ���������� ���������
    function GetFileSize(const aFilename: String): String; //������ �����
    procedure ComboLocalDriveSelect(Sender: TObject);
    procedure LVLocalDblClick(Sender: TObject);
    procedure ComboRemoteDriveSelect(Sender: TObject);
    procedure ButCopyToClientClick(Sender: TObject);// ����� ������ ������ � ��������� �������� ���������� �� ��������� ��
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean); // ����������� ��������� ��� ������������
  private
    SizeSelectFileLocal:int64;
    SizeSelectFileClient:int64;
  public
    DirectoryToSaveFile: string;
    FileStream: TFileStream;
    CancelLoadFile:boolean;

    LoadFFProgressBar:TProgressBarWithText;
    IDConnect:byte; // ID ����������, ��� �������� � ����� ����������� ������
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

procedure TFormFileTransfer.InMessage(TextMessage:string;TypeMess:integer) ; // ����������� ��������� ��� ������������
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
ButCancel.Visible:=false; // ������� ������ ������
ButCopyFromClient.Enabled:=true; // �������� ������ �����������
ButCopyToClient.Enabled:=true; // �������� ������ �����������
LoadFFProgressBar.Visible:=false;//�������� �����������
LLocalSize.Caption:='';
LLocalCount.Caption:='';
LClientSize.Caption:='';
LClientCount.Caption:='';
LVLocal.Clear;
LVClient.Clear;
FormFileTransfer.Tag:=0; //1 - ������� �������� ����� �����  ����� CopyFileFolder, ����������� ����� file ����� ������ �������
CancelLoadFile:=false;//������� ��������� �������� �����/ true - ������� ������ ��������
end;

function TFormFileTransfer.Log_write(fname:string;NumError:integer; TextMessage:string):boolean;
var f:TStringList;
const
TypeError: Array [0..3] of string = ('INFO','WARNING','ERROR','FATAL ERROR') ;
 begin
   try
   result:=true;
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
  except on E : Exception do
    begin
    result:=false;
    exit;
    end;
  end;
end;


function TFormFileTransfer.SendMainSock(s:ansistring):boolean; // �������� ����� ������� �����
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
 if (Key = VK_F5) then ButClientUpdate.Click; // ��������
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
 if (Key = VK_F5) then ButLocalUpdate.Click; // ��������
 if (Key = VK_RETURN) then EnterInLocalDirectory; // Enter
end;

procedure TFormFileTransfer.LVLocalKeyPress(Sender: TObject; var Key: Char);
begin
 if (Key = #13) then
    EnterInLocalDirectory;
end;






function TFormFileTransfer.SendFilesSocket(s:ansistring):boolean; // �������� ����� �������� �����
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


function TFormFileTransfer.SendCryptFilesSocket(s:ansistring):boolean; // ���������� � �������� ����� �������� �����
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt, CryptBuf); //������� ����� ���������
  result:=SendFilesSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������

   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('FileTransfer',2,'ERROR  - ShareFile ������ ���������� (F) �����'+ E.ClassName+' / '+ E.Message);
     end;
  end;
end;


function TFormFileTransfer.SendCryptMainSocket(s:ansistring):boolean; // ���������� � �������� ����� �������� �����
var
CryptBuf:string;
begin
  try
  Encryptstrs(s,frm_Main.ArrConnectSrv[IDConnect].CurrentPswdCrypt, CryptBuf); //������� ����� ���������
  result:=SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
   except On E: Exception do
     begin
     result:=false;
     s:='';
     Log_Write('FileTransfer',2,'ERROR  - ShareFile ������ ���������� (M) �����'+ E.ClassName+' / '+ E.Message);
     end;
  end;

end;

procedure TFormFileTransfer.GoToClientDirectory(Directory: string); // �������� ������� ���������� ��� ��������
begin
  EditDirClient.Enabled := false;
  if not (Directory[Length(Directory)] = '\') then  // �������� ������� "\"
  begin
    Directory := Directory + '\';
    EditDirClient.Text := Directory;
  end;
  SendCryptMainSocket('<|REDIRECT|><|GETFOLDERS|>' + Directory + '<|END|>');
end;




procedure TFormFileTransfer.EnterInClientDirectory;   // ������������ ���������� ��� �������� ������ ������ � ����� ����������� ����
var
  Directory: string;
begin
try
  if (LVClient.ItemIndex = -1) or not(EditDirClient.Enabled) then
    exit;

  if (LVClient.Selected.ImageIndex = 0) or (LVClient.Selected.ImageIndex = 1) then
  begin
    if LVClient.Selected.Caption = '�����' then
    begin
      Directory := EditDirClient.Text;
      Delete(Directory, Length(Directory), Length(Directory));
      EditDirClient.Text := ExtractFilePath(Directory + '..');
    end
    else
      EditDirClient.Text := EditDirClient.Text + LVClient.Selected.Caption + '\';

   GoToClientDirectory(EditDirClient.Text);
  end;
except on E : Exception do Log_Write('FileTransfer',2,'������ EnterInClientDirectory: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.EnterInLocalDirectory;   // ������������ ���������� ��� �������� ������ ������ � ����� ���������� ����
var
  Directory: string;
begin
try
if (LVlocal.ItemIndex = -1)  then exit;
  if (LVlocal.Selected.ImageIndex = 0) or (LVlocal.Selected.ImageIndex = 1) then
  begin
    if(LVlocal.Selected.ImageIndex = 0) and (LVlocal.Selected.Caption = '�����') then
     begin
      Directory := EditDirLocal.Text;
      Delete(Directory, Length(Directory), Length(Directory));
      EditDirLocal.Text := ExtractFilePath(Directory+'..');
      if EditDirLocal.Text=ComboLocalDrive.Text then
      GetListFileFolder(EditDirLocal.Text,false) // ���� � ���� �������� ����
      else GetListFileFolder(EditDirLocal.Text,true);  // ����� � ����� �������
     end
    else // ����� ������� � �������
     begin
      EditDirLocal.Text := EditDirLocal.Text + LVLocal.Selected.Caption + '\';
      GetListFileFolder(EditDirLocal.Text,true);
     end;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'������ EnterInLocalDirectory: '+E.ClassName+': '+E.Message);  end;
end;


//
procedure TFormFileTransfer.UpdateInClientDirectory; // ���������� ������ ��������� � ������ ������� ���������� �� ������� ��
begin
if EditDirClient.Text<>'' then GoToClientDirectory(EditDirClient.Text);
end;

procedure TFormFileTransfer.UpdateInLocalDirectory; // ���������� ������ ��������� � ������ ������� ���������� �� ��������� ��
begin
if (EditDirLocal.Text='')and(EditDirLocal.Text='') then exit;

if EditDirLocal.Text=ComboLocalDrive.Text then // �� � ����� �����
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
 if (LoadFFProgressBar.Visible) or (FormFileTransfer.Tag=1) then // ������ ���� ������� ����������� �����
 begin
  if MessageDlg('���������� ������� �����������?',mtConfirmation,[mbYes,mbCancel], 0)=mrYes then
   begin
   CancelLoadFile:=true; //������������� ������� �����������
     while (FormFileTransfer.Tag<>0) or (LoadFFProgressBar.Visible) do //������� ���������
     begin
     Application.ProcessMessages;
     sleep(2);
     end;
    FormFileTransfer.Tag:=0; //������� ������� �������� ����� ����� ����� CopyFileFolder.
   end;
 end
 else
 begin
 CancelLoadFile:=true;
 FormFileTransfer.Tag:=0; //������� ������� �������� ����� ����� ����� CopyFileFolder.
 end;

CanClose:=CancelLoadFile;
end;

procedure TFormFileTransfer.FormCreate(Sender: TObject);
begin
  try
  FormFileTransfer.Tag:=0;//1 - ������� �������� ����� �����  ����� CopyFileFolder, ����������� ����� file ����� ������ �������
  CancelLoadFile:=false; //������� ��������� �������� �����/ true - ������� ������ ��������
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
  except on E : Exception do Log_Write('FileTransfer',2,'������ FormCreate FileTransfer: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.FormShow(Sender: TObject);
begin
FormDefaultUpd;
GetlistDrv; // ������ ������ ������ �� ��������� ��
SendCryptMainSocket('<|REDIRECT|><|GETLISTDRIVE|>'); //������ ������ ������ �� ��������� ��
end;




procedure TFormFileTransfer.ComboRemoteDriveSelect(Sender: TObject);
begin
EditDirClient.Text:=ComboRemoteDrive.Text;
GoToClientDirectory(EditDirClient.Text); // ������ ���������� �� ��������� ��
LClientCount.Caption:='��������� ���������';
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
CancelLoadFile:=true; // �������� �����������
end;

procedure TFormFileTransfer.ButCopyToClientClick(Sender: TObject); // ����������� �� �������
var
tmpListF:TstringList;
pathToCopy:string;
i:integer;
begin
try
if LVLocal.Items.Count<1 then exit;
 if LVLocal.SelCount<1 then
 begin
 showmessage('�� ������� ����� ��� �����������');
 exit;
 end;
  tmpListF:=TstringList.Create;
  try
  for I := 0 to LVLocal.Items.Count-1 do
    begin  
     if LVLocal.Items[i].Selected then  // ���� ������� ������
     if LVLocal.Items[i].ImageIndex<>0 then  //���� ��� �� ������ �����
      tmpListF.Add(EditDirLocal.Text+LVLocal.Items[i].Caption); // ������ ��� ��������
    end;
  if tmpListF.Count>0 then
  begin
  CancelLoadFile:=false; // ��������� �����������
  pathToCopy:=copy(EditDirClient.Text,1,length(EditDirClient.Text)-1); // ������� ��������� ������ ���� '\'
  ThreadCopyFileS.Create(
                      frm_Main.ArrConnectSrv[IDConnect].FilesSock, // ����� ��� �����������
                       IDConnect, // ID ����������
                       tmpListF, // ������ ������ � ��������� ��� �����������
                       pathToCopy,// ���� ��������
                       frm_Main.ArrConnectSrv[IDConnect].SrvPswd);
  end
  else showmessage('�� ������� ����� ��� �����������');
  finally
  tmpListF.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'������ CopyToClient: '+E.ClassName+': '+E.Message);  end;
end;



function TFormFileTransfer.DeleteFolder(s:string):boolean; // ������� �������� ��������
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

function TFormFileTransfer.DeleteFile(s:string):boolean; // ������� �������� �����
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

Function TFormFileTransfer.CreateFolderLocal(s:string):boolean; // �������� �������� ��������
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
        if LVLocal.Selected.ImageIndex<>0 then  //���� �� �����
        begin
        if  MessageDlg('����������� ��������!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
        if LVLocal.Selected.ImageIndex=1 then // ��� �������
         DeleteFolder(EditDirLocal.text+LVLocal.Selected.Caption)
         else // ����� ����
        DeleteFile(EditDirLocal.text+LVLocal.Selected.Caption);
        end;
       end
      else
       begin
       if  MessageDlg('����������� ��������!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
        for I := 0 to LVLocal.Items.Count-1 do
         begin
         Application.ProcessMessages;
          if LVLocal.Items[i].Selected then
           begin
           if LVLocal.Items[i].ImageIndex<>0 then //���� �� �����
            begin
            if LVLocal.Items[i].ImageIndex=1 then // ��� �������
             DeleteFolder(EditDirLocal.text+LVLocal.Items[i].Caption)
             else // ����� ����
            DeleteFile(EditDirLocal.text+LVLocal.Items[i].Caption);
            end;
           end;
         end;
       end;
     UpdateInLocalDirectory; //��������
   except on E : Exception do Log_Write('FileTransfer',2,'������ DeleteLocal: '+E.ClassName+': '+E.Message);  end;
  end;
end;



procedure TFormFileTransfer.ButLocalFolderClick(Sender: TObject);
var
sF:string;
begin
if InputQuery('����� �������', '��� ��������', sF) then
if sF<>'' then
if CreateFolderLocal(EditDirLocal.text+sF) then UpdateInLocalDirectory; //��������
end;

procedure TFormFileTransfer.ButLocalUpdateClick(Sender: TObject);
begin
UpdateInLocalDirectory; //��������
end;

procedure TFormFileTransfer.ButClientDelClick(Sender: TObject); // ������� ����� ��� �������� �� �������
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
    if LVClient.Selected.ImageIndex<>0 then  //���� �� �����
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
       if LVClient.Items[i].ImageIndex<>0 then //���� �� �����
        begin
        ForF:=LVClient.Items[i].ImageIndex;
        ListDelete.Add(LVClient.Items[i].Caption+'='+inttostr(ForF));
        end;
       end;
     end;
   end;

  if  MessageDlg('����������� ��������!',mtWarning, [mbYes,mbNo], 0)=mrNo then exit;
  SendCryptFilesSocket('<|DELETEPATH|>'+EditDirClient.Text+'<|DELETELILST|>'+ListDelete.CommaText+'<|ENDDEL|>');
  finally
  ListDelete.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'������ DeleteClient: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.ButClientFolderClick(Sender: TObject); // ������� ������� �� �������
var
sF:string;
begin
if EditDirClient.Text<>'' then
 begin
 if InputQuery('����� �������', '��� ��������', sF) then
 if sF<>'' then SendCryptFilesSocket('<|CREATEFOLDER|>'+EditDirClient.Text+sF+'<|ENDDIR|>');
 end;
end;

procedure TFormFileTransfer.ButClientUpdateClick(Sender: TObject);
begin
UpdateInClientDirectory; //��������
end;

procedure TFormFileTransfer.ButCopyFromClientClick(Sender: TObject); // ����������� � �������
var
tmpListF:TstringList;//  ������ ��������� ������ � ���������
pathToCopy:string;  // ���� ��������
SourseDir:string; // ���������� ��������� ������ � ���������
i:integer;
begin
try
if LVClient.Items.Count<1 then exit;

if LVClient.SelCount<1 then
 begin
 showmessage('�� ������� ����� ��� �����������');
 exit;
 end;
  tmpListF:=TstringList.Create;
  try
  for I := 0 to LVClient.Items.Count-1 do
    begin  
     if LVClient.Items[i].Selected then  // ���� ������� ������
     if LVClient.Items[i].ImageIndex<>0 then  //���� ��� �� ������ �����
      tmpListF.Add(LVClient.Items[i].Caption); // ������ ��� ��������
    end;
  if tmpListF.Count>0 then
   begin
   CancelLoadFile:=false; // ��������� �����������
   SourseDir:=EditDirClient.Text;
   pathToCopy:=copy(EditDirLocal.Text,1,length(EditDirLocal.Text)-1); // ������� ��������� ������ ���� '\'
   SendCryptFilesSocket('<|SOURSEDIR|>'+SourseDir+'<|ENDSDIR|><|SOURSELIST|>'+tmpListF.CommaText+'<|SOURSELISTEND|><|DESTDIR|>'+pathToCopy+'<|ENDDDIR|>');
   end
  else showmessage('�� ������� ����� ��� �����������');
  finally
  tmpListF.Free;
  end;
except on E : Exception do Log_Write('FileTransfer',2,'������ CopyToClient: '+E.ClassName+': '+E.Message);  end;
end;

procedure TFormFileTransfer.ComboLocalDriveSelect(Sender: TObject); // ����� ����� �� ��������� ��
begin
EditDirLocal.Text:=ComboLocalDrive.Text;
GetListFileFolder(ComboLocalDrive.Text,false);
LLocalCount.Caption:='��������� ���������';
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


Procedure TFormFileTransfer.GetlistDrv; // ����� ������ ������ �� ��������� ��
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
     else ComboLocalDrive.Text:='������ ������';

  except on E : Exception do Log_Write('FileTransfer',2,'������ GetlistDrv Local: '+E.ClassName+': '+E.Message);  end;
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
  1: result := FormatFloat('#.## bytes', bytes); // ��������� � ������
  2: Begin                                       // ��������� � ����������
     if bytes > KB then result := FormatFloat('#.## KB', bytes / KB)
     else
     result := '1 KB';
     End;
  3: result := FormatFloat('#.## MB', bytes / MB); // ��������� � ����������
  4: result := FormatFloat('#.## GB', bytes / GB); // ��������� � ����������
  5: Begin                                          // ��������� � �������������� ������������
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
          if Item.Selected then // ���� �������
          begin
          SizeSelectFileLocal:=round(SizeTmp*1024);
          LLocalSize.Caption:='������: '+FormatByteSize(SizeSelectFileLocal,5);
          end
          else
          begin // ����� �������� �����
           if round(SizeTmp*1024)<SizeSelectFileLocal then
           begin
           SizeSelectFileLocal:=SizeSelectFileLocal-round(SizeTmp*1024);
           LLocalSize.Caption:='������: '+FormatByteSize(SizeSelectFileLocal,5);
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
     if Item.SubItems[1]<>'' then //���� ������ ������ �����
     if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
       begin
         if Item.Selected then // ���� ���� ���� ������� �� ���������
          begin
          SizeSelectFileLocal:=SizeSelectFileLocal+round(SizeTmp*1024);
          LLocalSize.Caption:='������: '+FormatByteSize(SizeSelectFileLocal,5);
          end
          else // ����� ��������
          begin
          if round(SizeTmp*1024)<SizeSelectFileLocal then
           begin
           SizeSelectFileLocal:=SizeSelectFileLocal-round(SizeTmp*1024);
           LLocalSize.Caption:='������: '+FormatByteSize(SizeSelectFileLocal,5);
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
LLocalCount.Caption:='�����: '+inttostr(LVLocal.Items.Count)+' �������: '+inttostr(LVLocal.SelCount);
except on E : Exception do Log_Write('FileTransfer',2,'������ LocalSelectItem: '+E.ClassName+': '+E.Message);  end;
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
          if Item.Selected then // ���� �������
          begin
          SizeSelectFileClient:=round(SizeTmp*1024);
          LClientSize.Caption:='������: '+FormatByteSize(SizeSelectFileClient,5);
          end
          else
          begin // ����� �������� �����
           if round(SizeTmp*1024)<SizeSelectFileClient then
           begin
           SizeSelectFileClient:=SizeSelectFileClient-round(SizeTmp*1024);
           LClientSize.Caption:='������: '+FormatByteSize(SizeSelectFileClient,5);
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
     if Item.SubItems[1]<>'' then //���� ������ ������ �����
     if TryStrToFloat(copy(Item.SubItems[1],1,length(Item.SubItems[1])-3),SizeTmp) then
       begin
         if Item.Selected then // ���� ���� ���� ������� �� ���������
          begin
          SizeSelectFileClient:=SizeSelectFileClient+round(SizeTmp*1024);
          LClientSize.Caption:='������: '+FormatByteSize(SizeSelectFileClient,5);
          end
          else // ����� ��������
          begin
          if round(SizeTmp*1024)<SizeSelectFileClient then
           begin
           SizeSelectFileClient:=SizeSelectFileClient-round(SizeTmp*1024);
           LClientSize.Caption:='������: '+FormatByteSize(SizeSelectFileClient,5);
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
LClientCount.Caption:='�����: '+inttostr(LVClient.Items.Count)+' �������: '+inttostr(LVClient.SelCount);
except on E : Exception do Log_Write('FileTransfer',2,'������ ClientSelectItem: '+E.ClassName+': '+E.Message);  end;
end;


function TFormFileTransfer.GetFileSize(const aFilename: String): String; //������ �����
var
  sr : TSearchRec;
begin
try
  if FindFirst(aFilename, faAnyFile, sr ) = 0 then
  begin
     Result:=FormatByteSize(Sr.Size,2); // ��������� � ��
  end else
  begin
     result :='';
  end;
  FindClose(sr);
except result:=''  end;
end;

function TFormFileTransfer.LastWriteTimeFileOrFolder(s:string;FileOrFolder:boolean):string; //����� ���������� ���������
begin
try
 if FileOrFolder then result:=DateTimeToStr(TFile.GetLastWriteTime(s))
 else result:=DateTimeToStr(TDirectory.GetLastWriteTime(s));
except result:=''  end;
end;

function TFormFileTransfer.GetListFileFolder(Dir:string; BackDir:boolean):boolean;// ����� ������ ������ � ��������� �������� ���������� �� ��������� ��
var
s:string;
begin
try
LVLocal.Clear;
 if BackDir then // ���� ������� �� �������� ����������, �.�. �� ����
  begin
  with LVLocal.Items.Add do //��������� ������ �� ������� � ���������� ����������
   begin
   caption:='�����';
   imageIndex:=0;
   subitems.Add('');
   subitems.Add('');
   end;
  end;

for s in TDirectory.GetDirectories(Dir) do
  begin
   with LVLocal.Items.Add do //��������� �������, s �������� ������ ���� ������� � �����
   begin
   caption:=StringReplace(s, Dir,'',[rfIgnoreCase]);
   imageIndex:=1;
   subitems.Add(LastWriteTimeFileOrFolder(s,false));
   subitems.Add('');
   end;
  end;

for s in TDirectory.GetFiles(Dir) do
  begin
   with LVLocal.Items.Add do //��������� �����, s �������� ������ ���� ������� � �����
   begin
   caption:=ExtractFileName(s);//StringReplace(s, Dir,'',[rfIgnoreCase]);
   imageIndex:=frm_main.GetImageIndexExt(LowerCase(ExtractFileExt(caption))); // ������ ������ ����� �� ��������� ��� ����������
   subitems.Add(LastWriteTimeFileOrFolder(s,true));
   subitems.Add(GetFileSize(s));
   end;
  end;

except on E : Exception do Log_Write('FileTransfer',2,'������ GetlistFileFolder Local: '+E.ClassName+': '+E.Message);  end;
end;

end.
