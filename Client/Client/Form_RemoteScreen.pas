unit Form_RemoteScreen;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Pipes,ScanKey,
  Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ImgList, Vcl.Buttons, Vcl.Menus,
  Vcl.VirtualImage;


type
  Tfrm_RemoteScreen = class(TForm)
    //Screen_Image: TImage;
    ScrollBox1: TScrollBox;
    CaptureKeys_Timer: TTimer;
    ScreenStart_Image1: TImage;
    UnWrapButton: TImage;
    PanelButtonParent: TPanel;
    SpeedACDButton: TSpeedButton;
    SpeedResizeButton: TSpeedButton;
    SpeedKeyboardButton: TSpeedButton;
    SpeedMouseButton: TSpeedButton;
    SpeedMonButton: TSpeedButton;
    ChatButton: TSpeedButton;
    ButtonClipboard: TSpeedButton;
    PanelParentClipboard: TPanel;
    SpeedLoadClipboard: TSpeedButton;
    SpeedDownLoadClipboard: TSpeedButton;
    PanelSelectMon: TPanel;
    LabelSelectMon: TLabel;
    TimerHidePanel: TTimer;
    ButtonFileManager: TSpeedButton;
    SpeedRoolUpButton: TImage;
    Screen_Image: TImage;
    PopupAdd: TPopupMenu;
    N1: TMenuItem;
    FileTransfer1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ImageButSet: TVirtualImage;
    DrDrButton: TVirtualImage;
    N6: TMenuItem;
    procedure Resize_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure KeyboardRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MouseRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Screen_ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Screen_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Screen_ImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CaptureKeys_TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ResizeOffClick(Sender: TObject);
    function ResizeChecked(OnOff:boolean):boolean;
    procedure KeybButtonClick(Sender: TObject);  // ���������/���������� ���������������
    function KeyBRemoteChecked(OnOff:boolean):boolean; // ���������/���������� ����������
    function RemoteMouseChecked(OnOff:boolean):boolean;
    procedure MouseOffClick(Sender: TObject);
    procedure KeybButtonMouseEnter(Sender: TObject);
    procedure KeybButtonMouseLeave(Sender: TObject);
    procedure UnWrapButtonMouseEnter(Sender: TObject);
    procedure UnWrapButtonMouseLeave(Sender: TObject);
    procedure UnWrapButtonClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: Integer);
    procedure SpeedMouseButtonClick(Sender: TObject);
    procedure SpeedKeyboardButtonClick(Sender: TObject);
    procedure SpeedResizeButtonClick(Sender: TObject);
    procedure SpeedACDButtonClick(Sender: TObject);
    procedure SpeedRoolUpButtonClick(Sender: TObject);
    procedure PanelButtonParentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelButtonParentMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelButtonParentMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrDrButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrDrButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedMonButtonClick(Sender: TObject);
    procedure SpeedLoadClipboardClick(Sender: TObject);
    procedure SpeedDownLoadClipboardClick(Sender: TObject);
    procedure ButtonClipboardClick(Sender: TObject);
    procedure ChatButtonClick(Sender: TObject);
    procedure DrDrButtonMouseEnter(Sender: TObject);
    procedure DrDrButtonMouseLeave(Sender: TObject);
    procedure SpeedRoolUpButtonMouseEnter(Sender: TObject);
    procedure SpeedRoolUpButtonMouseLeave(Sender: TObject);
    procedure ImagebuttmonClick(Sender: TObject);  // ������� ������ ������ ��������
    procedure ImagebuttonMouseEnter(Sender: TObject);
    procedure ImagebuttonMouseLeave(Sender: TObject);
    procedure TimerHidePanelTimer(Sender: TObject);
    procedure PanelSelectMonMouseEnter(Sender: TObject);
    procedure PanelSelectMonMouseLeave(Sender: TObject);
    procedure PanelParentClipboardMouseEnter(Sender: TObject);
    procedure PanelParentClipboardMouseLeave(Sender: TObject);
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ButtonFileManagerClick(Sender: TObject);
    procedure ButtonPixelFLMouseLeave(Sender: TObject);
    procedure ButtonPixelFLMouseEnter(Sender: TObject);
    procedure ButtonPixelFMMouseEnter(Sender: TObject);
    procedure ButtonPixelFMMouseLeave(Sender: TObject);
    procedure ButtonPixelFHMouseEnter(Sender: TObject);
    procedure ButtonPixelFHMouseLeave(Sender: TObject);
    procedure ButtonPixelFVHMouseEnter(Sender: TObject);
    procedure ButtonPixelFVHMouseLeave(Sender: TObject);
    procedure SpeedLoadClipboardMouseEnter(Sender: TObject);
    procedure SpeedLoadClipboardMouseLeave(Sender: TObject);
    procedure Screen_ImageDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FileTransfer1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure ImageButSetMouseEnter(Sender: TObject);
    procedure ImageButSetMouseLeave(Sender: TObject);
    procedure ImageButSetMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageButSetMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageButSetClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    function CreateFormFPS(Var TmpFPS:integer):boolean; // ����� ��� ����� FPS
  private
    Procedure sizeMove (var msg: TWMSize); message WM_SYSCOMMAND; //��� �������������, ������������ � �������������� �����
   // procedure WndProc(var Message: TMessage); override;

    { Private declarations }
  public
    RCtrlPressed, RShiftPressed, RAltPressed,LCtrlPressed,LShiftPressed,LAltPressed: Boolean;
    procedure PosDefaultPanel;  // ����������� ������ �� ���������
    Function ParentClipboardUpUn:boolean; // �������� /���������� ������ ��� ������ � ������� ������
    Function ParentMonitorUpUn:boolean; // �������� /���������� ������ ��� ������ � ������� ������
    procedure OpenDirectoryForFile; // �������� ���������� ��� �������� ������ �� ������ ������
    procedure paintbuttonmonitor; // ��������� ���� ������ ��������
    function SendFilesCryptText(s:string):Boolean; // �������� �������������� ������ � files �����
    function SendMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
    function SendMainSock(s:ansistring):boolean; // �������� ����� ������� �����
    function SendFilesSocket(s:ansistring):boolean; // �������� ����� �������� �����
    function SendDesktopSocket(s:ansistring):boolean; // �������� ����� �������� �����
    function ExistsFileSockets:boolean; // �������� ������ �� ����������
    procedure CloseFileSocket; //�������� ������� ������ ������
    procedure CloseDesktopSocket; //�������� ������� ������ �������� �����
    procedure CloseTargetSocket; // ��������   �������� ������ ��� ����������� � ������� �� ������ ������
    procedure FormResizeDefault;
   { Public declarations }
  end;

var
  frm_RemoteScreen: Tfrm_RemoteScreen;
  movingPan,UpUnButtonPanel,UpUnClipdoard,UpUnPanelMon:boolean;
  y0,x0:integer;
  FrMaxRes:boolean; // ��� ��������� �������� ����� (msg.SizeType = SC_MAXIMIZE) or (msg.SizeType = SC_RESTORE) or (msg.SizeType=61490)
  SendReolutionResize:boolean; // ���������� �� �������� ����������
  DblLeftClick:boolean; // ������� �������� �����

implementation

{$R *.dfm}

uses
  Form_Main, Form_Chat, Form_ShareFiles,Osher,MyImg,FfmProgress,ThReadMyClipboard,SocketCrypt,FileTransfer;


  /// Log File
function Log_write(fname:string; NumError:integer; TextMessage:string):boolean;
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
 except
  exit;
 end;
end;



procedure Tfrm_RemoteScreen.OpenDirectoryForFile;
begin
try
with TFileOpenDialog.Create(nil) do
  try
    Options := [fdoPickFolders];
    if Execute then
     Begin
     //SendFilesSocket('<|DOWNLOADCLPBRDDIRECTORY|>'+FileName+'<|ENDFILE|>');
     SendFilesCryptText('<|DOWNLOADCLPBRDDIRECTORY|>'+FileName+'<|ENDFILE|>');
     end;
  finally
    Free;
  end;
except on E : Exception do Log_Write('rscr',2,'OpenDirectoryForFile : ');  end;
end;


function Tfrm_RemoteScreen.SendFilesCryptText(s:string):Boolean; // �������� �������������� ������ � files �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].CurrentPswdCrypt, CryptBuf); //������� ����� ���������
SendFilesSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
//Log_Write('rscr','SendFilesCryptText ���������='+'<!>'+CryptBuf+'<!!>');
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    Log_Write('rscr',2,'������ ���������� ����� ��������� ������ (�) ������� �������');
    end;
  end;
end;

function Tfrm_RemoteScreen.SendMainCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].CurrentPswdCrypt, CryptBuf); //������� ����� ���������
SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    Log_Write('rscr',2,'������ ���������� ����� ��������� ������ (�) ������� �������');
    end;
  end;
end;


function Tfrm_RemoteScreen.SendMainSock(s:ansistring):boolean; // �������� ����� ������� �����
begin
try
result:=true;
if frm_RemoteScreen.Tag<>-1 then
if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].mainSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].mainSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   end
  else result:=false;
end;
except on E : Exception do Log_Write('rscr',2,'SendMainSocketRemoteScreen ('+inttostr(frm_RemoteScreen.tag));  end;
end;


function Tfrm_RemoteScreen.SendFilesSocket(s:ansistring):boolean; // �������� ����� �������� �����
begin
try
result:=true;
if frm_RemoteScreen.Tag<>-1 then
if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock.Connected then
   begin
   while frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock.SendText(s)<0 do
   Sleep(ProcessingSlack);
   //Log_Write('rscr','SendFilesSocket �������� - '+s);
   end
  else result:=false;
end;
except on E : Exception do Log_Write('rscr',2,'SendFilesSocketRemoteScreen');  end;
end;


function Tfrm_RemoteScreen.SendDesktopSocket(s:ansistring):boolean; // �������� ����� �������� �����
begin
try
result:=true;
if frm_RemoteScreen.Tag<>-1 then
if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].DesktopSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].DesktopSock.Connected then
   frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].DesktopSock.SendText(s)
  else result:=false;
end;
except on E : Exception do Log_Write('rscr',2,'SendFilesSocketRemoteScreen');  end;
end;

function Tfrm_RemoteScreen.ExistsFileSockets:boolean; // �������� ��������� ������ �� ����������
begin
try
result:=false;
  if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock<>nil then
  if frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock.Connected then result:=true;
 except on E : Exception do
    begin
  result:=false;
    Log_Write('rscr',2,'�������� ���������� ������ (F)');
  end;
  end;
end;




procedure Tfrm_RemoteScreen.CaptureKeys_TimerTimer(Sender: TObject);
var
  i: Byte;
  scancode:integer;
  Keyboard:TKeyboardState;
  UnicodeChar    :  Char;
  restmp,res:integer;
  resStr:string;
begin
  try
    { Combo }
    if (frm_RemoteScreen.Active) then   //������� ������� Alt, Ctrl, Shift  �� �������� �� �������� �������� ���� ������������ ��� ����������� ��������
    begin
      // LeftAlt
      if not(LAltPressed) then
      begin
        if (GetAsyncKeyState(VK_LMENU{164}) =-32767) then
        begin
          LAltPressed := true;
          SendMainCryptText('<|REDIRECT|><|LALTDOWN|>');
        end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_LMENU) =0) then
        begin
          LAltPressed := false;
          SendMainCryptText('<|REDIRECT|><|LALTUP|>');
        end;
      end;
      // RightAlt
      if not(RAltPressed) then
      begin
        if (GetAsyncKeyState(VK_RMENU) =-32767) then
        begin
          RAltPressed := true;
          SendMainCryptText('<|REDIRECT|><|RALTDOWN|>');
        end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_RMENU) =0) then
        begin
          RAltPressed := false;
          SendMainCryptText('<|REDIRECT|><|RALTUP|>');
        end;
      end;


      // LeftCtrl
      if not(LCtrlPressed) then
      begin
        if (GetAsyncKeyState(VK_LCONTROL) =-32767) then
        begin
          LCtrlPressed := true;
          SendMainCryptText('<|REDIRECT|><|LCTRLDOWN|>');
        end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_LCONTROL) =0) then
        begin
          LCtrlPressed := false;
          SendMainCryptText('<|REDIRECT|><|LCTRLUP|>');
        end;
      end;
       // RightCtrl
      if not(RCtrlPressed) then
      begin
        if (GetAsyncKeyState(VK_RCONTROL) =-32767) then
        begin
          RCtrlPressed := true;
          SendMainCryptText('<|REDIRECT|><|RCTRLDOWN|>');
        end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_RCONTROL) =0) then
        begin
          RCtrlPressed := false;
          SendMainCryptText('<|REDIRECT|><|RCTRLUP|>');
        end;
      end;
      // LeftShift
      if not(LShiftPressed) then
      begin
        if (GetAsyncKeyState(VK_LSHIFT) =-32767) then
         begin
          LShiftPressed := true;
          SendMainCryptText('<|REDIRECT|><|LSHIFTDOWN|>');
         end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_LSHIFT) =0) then
        begin
          LShiftPressed := false;
          SendMainCryptText('<|REDIRECT|><|LSHIFTUP|>');
        end;
      end;


      // RightShift
      if not(RShiftPressed) then
      begin
        if (GetAsyncKeyState(VK_RSHIFT) =-32767) then
        begin
          RShiftPressed := true;
          SendMainCryptText('<|REDIRECT|><|RSHIFTDOWN|>');
        end;
      end
      else
      begin
        if (GetAsyncKeyState(VK_RSHIFT) =0) then
        begin
          RShiftPressed := false;
          SendMainCryptText('<|REDIRECT|><|RSHIFTUP|>');
        end;
      end;

       if LShiftPressed  then // ���� ����� ctrl ����� �� ��������� ������ �� 'C '
       begin
       if GetAsyncKeyState(46) = -32767 then // ���� ������ ������� "C"
          begin // �������� ctrl+c
           SendMainCryptText('<|REDIRECT|><|CTRL+C|>');
          end
       end;

      for i := 1 to 254 do ////�������� � ����  ���� ����������� �������...
      if (GetAsyncKeyState(i) = -32767) then //���� ������� ������
      begin
       case i of
        1..15,19..159,166..254:
         begin
         GetKeyboardState(Keyboard);
         ScanCode:=MapVirtualKeyEx(i,MAPVK_VK_TO_VSC_EX,WinLocale);
         restmp:=ToUnicodeEx(i,ScanCode,Keyboard,@UnicodeChar,2,0,WinLocale);
         if restmp>0 then
         begin
         res:=VkKeyScanEx(UnicodeChar,WinLocale);
         resStr:=(inttostr(res)+','+inttostr(ScanCode));
         end;
          if restmp=0 then  resStr:=(inttostr(i)+','+inttostr(ScanCode));
         SendMainCryptText('<|REDIRECT|><|KEYPRS|>'+resStr+'<|KPEND|>');      //<|KEYPRS|>...<|KPEND|>
         //Log_Write('rscr','����������: '+resStr);
         end;
       end;
      end;
    end;
///////////////////////////////////////////////////////////////////// �������� ������� ������� ��� ���� ������������ �������
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.CaptureKeys_TimerTimer ');  end;
end;





procedure Tfrm_RemoteScreen.ChatButtonClick(Sender: TObject);
begin
try
if frm_Chat.Visible then
begin
frm_Chat.Close;
ChatButton.ImageIndex:=3;
ChatButton.HotImageIndex:=6;
ChatButton.PressedImageIndex:=4;
ChatButton.Hint:='������� ���';
end
else
begin
frm_Chat.Show;
ChatButton.ImageIndex:=4;
ChatButton.HotImageIndex:=5;
ChatButton.PressedImageIndex:=3;
ChatButton.Hint:='������� ���';
end;
except on E : Exception do Log_Write('rscr',2,'Open Chat');  end;
end;




procedure Tfrm_RemoteScreen.CloseTargetSocket;
begin
try
if TargetServerSocket<>nil then
begin
  if TargetServerSocket.Active then TargetServerSocket.Close;
end;
except on E : Exception do Log_Write('rscr',2,'CloseTargetSocket');  end;
end;

procedure Tfrm_RemoteScreen.CloseFileSocket;
begin
 try
 if frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].FilesSock<>nil then
  begin
   if frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].FilesSock.Connected then  frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].FilesSock.Close;
  end;
except on E : Exception do Log_Write('rscr',2,'CloseFileDesktpSocke');  end;
end;

procedure Tfrm_RemoteScreen.CloseDesktopSocket;
begin
 try
 if frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].DesktopSock<>nil then
  begin
   if frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].DesktopSock.Connected then  frm_Main.ArrConnectSrv[frm_RemoteScreen.tag].DesktopSock.Close;
  end;
except on E : Exception do Log_Write('rscr',2,'CloseDesktopSocket');  end;
end;






procedure Tfrm_RemoteScreen.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
try
  if (FormOsher.MouseRemote_CheckBox.Checked) then
    SendMainCryptText('<|REDIRECT|><|WHEELMOUSE|>' + IntToStr(WheelDelta) + '<|END|>');

except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.FormMouseWheel');  end;
end;


procedure Tfrm_RemoteScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
try
  if not SendMainCryptText('<|STOPACCESS|>') then  // ���� ��������� ������ �������� � ����� ������
  begin    // �������� ������������� ������� ������
  CloseTargetSocket;
  end;
  CaptureKeys_Timer.Enabled:=false;// ��������� ������
  if frm_Chat.Visible then frm_Chat.close;
  FrmMyProgress.CancelLoadFile:=true; // �������� �������� ���� ��� ����
  if FrmMyProgress.Visible then FrmMyProgress.Close;               // ��������� ���� ������������\
  frm_Main.SetOnline;
  frm_Main.Status_Label.Caption := '� ����';
   if not frm_Main.Visible then
      begin
      frm_Main.Show;
      end;
  frm_RemoteScreen.tag:=-1;
  frm_Main.Viewer := false;  // ����� �������� ���� ��� � ���������� � �������� � ������� ���� ����������

   FormResizeDefault; // ������ ����� �� ���������
   PosDefaultPanel; // �� ��������� ������ ����������
   LCtrlPressed := false;
   LShiftPressed := false;
   LAltPressed := false;
   RCtrlPressed := false;
   RShiftPressed := false;
   RAltPressed := false;
   Screen_Image.Picture.Assign(ScreenStart_Image1.Picture);
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.FormClose');  end;
end;

procedure Tfrm_RemoteScreen.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if FormFileTransfer.Visible then
  begin
  if FormFileTransfer.Tag=1 then // ���� ������� �����������
   begin
   FormFileTransfer.Show;
   FormFileTransfer.WindowState:=wsNormal;
   FormFileTransfer.Close;
   CanClose:=false;
   end
   else
   begin
   FormFileTransfer.Close;
   CanClose:=true;
   end;
  end
  else CanClose:=true;
 if frm_ShareFiles.Visible then
  begin
  frm_ShareFiles.Close;
  CanClose:=true;
  end
  else CanClose:=true;
end;

procedure Tfrm_RemoteScreen.FormCreate(Sender: TObject);
begin
try
  // Separate Window
 SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);  //  - �������������� ���������� ���� �������� ������ �� ������ �����, ����� ���� ������������.
 LCtrlPressed := false;
 LShiftPressed := false;
 LAltPressed := false;
 RCtrlPressed := false;
 RShiftPressed := false;
 RAltPressed := false;
 PosDefaultPanel; // �� ��������� ������ ����������
 Screen_Image.Picture.Assign(ScreenStart_Image1.Picture);
 except on E : Exception do Log_Write('rscr',2,'frm_RemoteScreen.FormCreate');  end
 end;
////////////////////////////////////////////////////////////////////////////// �������������� ������

procedure Tfrm_RemoteScreen.FormShow(Sender: TObject);
begin
try

SendReolutionResize:=false; // ���������� �� �������� ����������
//FormResizeDefault; // ������ ����� � bitmap  ,
LCtrlPressed := false;
LShiftPressed := false;
LAltPressed := false;
RCtrlPressed := false;
RShiftPressed := false;
RAltPressed := false;
//-----------����� ���������� ��������------------
if frm_Main.ImagePixelF=pf8bit then N3.Checked:=true;
if frm_Main.ImagePixelF=pf16bit then N4.Checked:=true;
if frm_Main.ImagePixelF=pf24bit then N5.Checked:=true;
//---------------------------------------------------
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.FormShow');  end;
end;







procedure Tfrm_RemoteScreen.KeyboardRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  if Key = VK_SPACE then
//    Key := 0;
end;

///////////////////////////////////////////////////////////   ������ ������ ��������
procedure Tfrm_RemoteScreen.ImagebuttmonClick(Sender: TObject);  // ������� ������ ������ ��������
var
selectmon:byte;
begin
try
selectmon:=(sender as TSpeedButton).Tag;
LabelSelectMon.Caption:=inttostr(Selectmon+1);
SendMainCryptText('<|REDIRECT|><|MONITORCURRENT|>'+inttostr(Selectmon)+'<|END|>');
ParentMonitorUpUn; // �������� ������ ���������
except on E : Exception do Log_Write('rscr',2,'Select Monitor');  end
end;

procedure Tfrm_RemoteScreen.ImagebuttonMouseEnter(Sender: TObject);
begin
try
(sender as TspeedButton).ImageIndex:=12;
TimerHidePanel.Enabled:=false;
except on E : Exception do Log_Write('rscr',2,'Select Monitor Enter');  end
end;

procedure Tfrm_RemoteScreen.ImagebuttonMouseLeave(Sender: TObject);
begin
try
(sender as TspeedButton).ImageIndex:=11;
TimerHidePanel.Enabled:=true;
except on E : Exception do Log_Write('rscr',2,'Select Monitor Leave');  end
end;

procedure Tfrm_RemoteScreen.paintbuttonmonitor; // �������� ������ ������ ��������
var
imagebutmon:TSpeedButton;
labelMon:Tlabel;
i:integer;
butmonLeft:integer;
begin
try
PanelSelectMon.Height:=62;
PanelSelectMon.Width:=62;
PanelSelectMon.Top:=PanelButtonParent.Top+PanelButtonParent.Height;
PanelSelectMon.Left:=(PanelButtonParent.Left+SpeedMonButton.Left+(SpeedMonButton.Width div 2))-PanelSelectMon.Width div 2;
for I := 0 to frm_Main.MonitorCount-1 do
begin
 if i>0 then
  begin
  PanelSelectMon.Width:=PanelSelectMon.Width+58;
  PanelSelectMon.Left:=(PanelButtonParent.Left+SpeedMonButton.Left+(SpeedMonButton.Width div 2))-PanelSelectMon.Width div 2;
  end;
 imagebutmon:=TSpeedButton.Create(PanelSelectMon);
 imagebutmon.Parent:=PanelSelectMon;
 imagebutmon.Name:='imagebutmon'+inttostr(i);
 imagebutmon.Images:=FormOsher.VirtualImageList1;
 imagebutmon.Tag:=i;
 imagebutmon.Width:=55;
 imagebutmon.Height:=55;
 imagebutmon.Top:=3;
 imagebutmon.ShowHint:=true;
 imagebutmon.Hint:='���������� ������� �'+inttostr(i+1);
 imagebutmon.OnClick:=ImagebuttmonClick;
 imagebutmon.OnMouseEnter:=ImagebuttonMouseEnter;
 imagebutmon.OnMouseLeave:=ImagebuttonMouseLeave;
 if i=0 then
  begin
  imagebutmon.Left:=3;
  butmonLeft:=imagebutmon.Left+imagebutmon.Width+3;
  end
 else
  begin
  imagebutmon.Left:=butmonLeft;
  butmonLeft:=imagebutmon.Left+imagebutmon.Width+3;
  end;
 imagebutmon.ImageIndex:=11;
 imagebutmon.PressedImageIndex:=12;
 labelMon:=Tlabel.Create(imagebutmon);
 labelMon.Parent:=imagebutmon.Parent;
 labelMon.Name:='labelMon'+inttostr(i);
 labelMon.AutoSize:=true;
 labelMon.Font.Height:=-22;
 labelMon.Font.Style:=[fsBold];
 labelMon.Caption:=inttostr(i+1);
 labelMon.Height:=22;
 labelMon.Left:=imagebutmon.Left+(imagebutmon.Width div 2)-7;
 labelMon.Top:=12;
end;
PanelSelectMon.Visible:=true;
except on E : Exception do Log_Write('rscr',2,'Create Monitor button ');  end
end;



procedure Tfrm_RemoteScreen.PanelButtonParentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   x0:=x;
   y0:=y;
   movingPan:=true;
end;


procedure Tfrm_RemoteScreen.PanelButtonParentMouseUp(Sender: TObject;   //
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 movingPan := false;
end;

procedure Tfrm_RemoteScreen.PanelParentClipboardMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.PanelParentClipboardMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.PanelSelectMonMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.PanelSelectMonMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;





Function Tfrm_RemoteScreen.ParentMonitorUpUn:boolean;/// ������ ��������� //ParentMonitorUpUn  UpUnPanelMon
var
i:integer;
begin
try
if not UpUnPanelMon then // ���� ������ ��� ������ � ���������� �������� �� �������������
  begin
  PanelSelectMon.Top:=PanelButtonParent.Top+PanelButtonParent.Height;
  paintbuttonmonitor; // ������ ������
  UpUnPanelMon:=true;
  SpeedMonButton.Hint:='�������� ������ ������ ��������';
  if UpUnClipdoard then ParentClipboardUpUn; // ���� ������ ������ ������ ���������� �� �������� ��
  end
else // ����� �����������
  begin
  PanelSelectMon.Top:=0-PanelParentClipboard.Height-3;
  PanelSelectMon.Visible:=false;
  UpUnPanelMon:=false; // ������ ������ � ���������� ��������
  SpeedMonButton.Hint:='���������� ������ ������ ��������';
  for I := PanelSelectMon.ComponentCount-1 downto 0 do
   PanelSelectMon.Components[i].Free; // ������� ������
  end;
TimerHidePanel.Enabled:=UpUnPanelMon;
result:=UpUnPanelMon;
except on E : Exception do Log_Write('rscr',2,'ParentMonitorUpUn');  end;
end;



Function Tfrm_RemoteScreen.ParentClipboardUpUn:boolean;/// ������ ��� ������ � ������� ������
begin
try
if not UpUnClipdoard then // ���� ������ ��� ������ � ������� �������� �� �������������
  begin
  PanelParentClipboard.Top:=PanelButtonParent.Top+PanelButtonParent.Height;
  PanelParentClipboard.Visible:=true;
  UpUnClipdoard:=true;
  ButtonClipboard.Hint:='�������� ������ ����� ������';
  if UpUnPanelMon then ParentMonitorUpUn; // ���� ������ � ���������� ���������� �� ����������� ��
  end
else // ����� �����������
  begin
  PanelParentClipboard.Top:=0-PanelParentClipboard.Height-3;
  PanelParentClipboard.Visible:=false;
  UpUnClipdoard:=false; // ������ ������ � ������� ������ ��������
  ButtonClipboard.Hint:='���������� ������ ����� ������';
  end;
TimerHidePanel.Enabled:=UpUnClipdoard;
result:=UpUnClipdoard;
except on E : Exception do Log_Write('rscr',2,'Hide panel clipboard');  end
end;

procedure Tfrm_RemoteScreen.ButtonClipboardClick(Sender: TObject);  // ������� ������ ������ ������
begin
try
PanelParentClipboard.Left:=(PanelButtonParent.left+ButtonClipboard.Left+(ButtonClipboard.Width div 2))-(PanelParentClipboard.Width div 2);
ParentClipboardUpUn;
except on E : Exception do Log_Write('rscr',2,'Open panel clipboard'); end;
end;



procedure Tfrm_RemoteScreen.ButtonPixelFVHMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFVHMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFHMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFHMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFLMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFLMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFMMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.ButtonPixelFMMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.ButtonFileManagerClick(Sender: TObject);
begin
if not frm_ShareFiles.Visible then
 begin
 FormFileTransfer.IDConnect:=frm_RemoteScreen.tag;
 FormFileTransfer.WindowState:=WsNormal;
 FormFileTransfer.Show;
 end;
end;




/////////////////////////////////////////////////////////////////////////////////////������� ������ � �������. ����������� ������ � ��������



procedure Tfrm_RemoteScreen.PanelButtonParentMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
try
if movingPan then
begin
//-- �������� ����������� ������
//ReleaseCapture;
//PanelButtonParent.perform(WM_SysCommand, $F009, 0);//������� ������!!!
//---------------------------------------------------------------------------
   if PanelButtonParent.Left>= frm_RemoteScreen.Width-(PanelButtonParent.Width) then x0:=x0+4
   else
   if PanelButtonParent.Left<=-1 then x0:=x0-4;
   begin
     PanelButtonParent.Left:=PanelButtonParent.Left+x-x0;
     PanelButtonParent.Top:=PanelButtonParent.Top;
     PanelParentClipboard.Left:=PanelParentClipboard.Left+x-x0;
     PanelParentClipboard.Top:=PanelParentClipboard.Top;
     PanelSelectMon.Left:=PanelSelectMon.Left+x-x0;
     PanelSelectMon.Top:=PanelSelectMon.Top;
     UnWrapButton.left:=UnWrapButton.left+x-x0;
     UnWrapButton.Top:=UnWrapButton.Top;
   end;
end;
except on E : Exception do Log_Write('rscr',2,'PanelButtonParentMouseMove'); end;
end;

procedure Tfrm_RemoteScreen.DrDrButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   x0:=x;
   y0:=y;
   movingPan:=true;
end;

procedure Tfrm_RemoteScreen.DrDrButtonMouseEnter(Sender: TObject);
begin
try
DrDrButton.ImageIndex:=42;
except on E : Exception do Log_Write('rscr',2,'DrDrButtonMouseEnter'); end
end;

procedure Tfrm_RemoteScreen.DrDrButtonMouseLeave(Sender: TObject);
begin
try
DrDrButton.ImageIndex:=41;
except on E : Exception do Log_Write('rscr',2,'DrDrButtonMouseLeave'); end
end;

procedure Tfrm_RemoteScreen.DrDrButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
movingPan:=false;
end;







procedure Tfrm_RemoteScreen.PosDefaultPanel;  // ����������� ������ ���������� �� ���������
begin
try
PanelButtonParent.Top:=0;
PanelButtonParent.left:=(screen_image.Width div 2)-(PanelButtonParent.Width div 2);
PanelParentClipboard.Top:=PanelButtonParent.Top-PanelParentClipboard.Height-3;
PanelParentClipboard.Left:=(PanelButtonParent.left+ButtonClipboard.Left+(ButtonClipboard.Width div 2))-(PanelParentClipboard.Width div 2);
UpUnClipdoard:=false; // ������ ������ � ������� ������ ��������
PanelSelectMon.top:=PanelButtonParent.Top-PanelSelectMon.Height-3;
PanelSelectMon.Left:=(PanelButtonParent.Left+SpeedMonButton.Left+(SpeedMonButton.Width div 2))-PanelSelectMon.Width div 2;
UpUnPanelMon:=false;// ������ � ���������� ��������
//------------------------------------
SpeedMouseButton.Hint:='�������� ����';
SpeedMouseButton.ImageIndex:=24;
SpeedMouseButton.HotImageIndex:=26;
SpeedMouseButton.PressedImageIndex:=25;
FormOsher.MouseRemote_CheckBox.Checked:=false;

SpeedKeyboardButton.Hint:='�������� ����������';
SpeedKeyboardButton.ImageIndex:=7;
SpeedKeyboardButton.HotImageIndex:=10;
SpeedKeyboardButton.PressedImageIndex:=8;
FormOsher.KeyboardRemote_CheckBox.Checked:=false;

SpeedResizeButton.Hint:='��������� ��������������';
SpeedResizeButton.ImageIndex:=18;
FormOsher.Resize_CheckBox.Checked:=true;

//SpeedMonButton
SpeedMonButton.Hint:='����� ��������';
SpeedMonButton.ImageIndex:=11;
LabelSelectMon.Caption:='1';
frm_Main.MonitorCurrent:=1;

ButtonFileManager.Hint:='���� ��������';
frm_Main.ImagePixelF:=pf8bit;
//---------------------------------------------------

UnWrapButton.Left:=(PanelButtonParent.Left+SpeedRoolUpButton.left);
UnWrapButton.Top:=-63; //�������� ������
UpUnButtonPanel:=false; // ������� ���� ��� ������ ����������
except on E : Exception do Log_Write('rscr',2,'PosDefaultPanel'); end;
end;


procedure Tfrm_RemoteScreen.SpeedRoolUpButtonClick(Sender: TObject);  // �������� ������
begin
try
UnWrapButton.Left:=(PanelButtonParent.Left+SpeedRoolUpButton.left);
PanelParentClipboard.Left:=(PanelButtonParent.left+ButtonClipboard.Left+(ButtonClipboard.Width div 2))-(PanelParentClipboard.Width div 2);
PanelSelectMon.Left:=(PanelButtonParent.Left+SpeedMonButton.Left+(SpeedMonButton.Width div 2))-PanelSelectMon.Width div 2;
if UpUnClipdoard then ParentClipboardUpUn; // �������� ������ ���������� ������� ������
if UpUnPanelMon then ParentMonitorUpUn; // �������� ������ ���������

PanelButtonParent.Top:=-PanelButtonParent.Height;
UnWrapButton.Top:=0;
except on E : Exception do Log_Write('rscr',2,'SpeedRoolUpButtonClick'); end;
end;

procedure Tfrm_RemoteScreen.SpeedRoolUpButtonMouseEnter(Sender: TObject);
begin
try
SpeedRoolUpButton.Picture.Assign(FormOsher.RoolUpOff.Picture);
except on E : Exception do Log_Write('rscr',2,'SpeedRoolUpButtonMouseEnter '); end;
end;

procedure Tfrm_RemoteScreen.SpeedRoolUpButtonMouseLeave(Sender: TObject);
begin
try
SpeedRoolUpButton.Picture.Assign(FormOsher.RoolUpOn.Picture)
except on E : Exception do Log_Write('rscr',2,'SpeedRoolUpButtonMouseLeave'); end;
end;

procedure Tfrm_RemoteScreen.TimerHidePanelTimer(Sender: TObject);
begin
try
if UpUnClipdoard then ParentClipboardUpUn; // �������� ������ ���������� ������� ������
if UpUnPanelMon then ParentMonitorUpUn; // �������� ������ ���������

TimerHidePanel.Enabled:=false;
except on E : Exception do Log_Write('rscr',2,'TimerHidePanelTimer'); end;
end;

procedure Tfrm_RemoteScreen.UnWrapButtonClick(Sender: TObject);  // ���������� ������
begin
try
PanelParentClipboard.Left:=(PanelButtonParent.left+ButtonClipboard.Left+(ButtonClipboard.Width div 2))-(PanelParentClipboard.Width div 2);
UnWrapButton.Left:=(PanelButtonParent.Left+SpeedRoolUpButton.left);
PanelButtonParent.Top:=0;
UnWrapButton.Top:=-UnWrapButton.Height;
except on E : Exception do Log_Write('rscr',2,'UnWrapButtonClick '); end;
end;

procedure Tfrm_RemoteScreen.UnWrapButtonMouseEnter(Sender: TObject);// ����� ��������
begin
try
UnWrapButton.Picture.Assign(FormOsher.UnWrapOn.Picture);
except on E : Exception do Log_Write('rscr',2,'UnWrapButtonMouseEnter: '); end;
end;

procedure Tfrm_RemoteScreen.UnWrapButtonMouseLeave(Sender: TObject);// ����� ��������
begin
try
UnWrapButton.Picture.Assign(FormOsher.UnWrapOff.Picture)
except on E : Exception do Log_Write('rscr',2,'UnWrapButtonMouseLeave: '); end;
end;


procedure Tfrm_RemoteScreen.ImageButSetClick(Sender: TObject);
begin
popupAdd.Popup(
{X}frm_RemoteScreen.Left+PanelButtonParent.Left+ImageButSet.Left{+ImageButSet.Width},
{Y}frm_RemoteScreen.Top+PanelButtonParent.Top+ImageButSet.Top+ImageButSet.Height+(frm_RemoteScreen.Height-frm_RemoteScreen.ClientHeight)
);
end;

procedure Tfrm_RemoteScreen.ImageButSetMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
ImageButSet.ImageIndex:=40;
end;

procedure Tfrm_RemoteScreen.ImageButSetMouseEnter(Sender: TObject);
begin
ImageButSet.ImageIndex:=39;
end;

procedure Tfrm_RemoteScreen.ImageButSetMouseLeave(Sender: TObject);
begin
ImageButSet.ImageIndex:=38;
end;

procedure Tfrm_RemoteScreen.ImageButSetMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
ImageButSet.ImageIndex:=39;
end;

//////////////////////////////////////////////////////////////////////////// �������� ����
function Tfrm_RemoteScreen.RemoteMouseChecked(OnOff:boolean):boolean; // true- ��������
begin
try
if OnOff then
begin

end
else
begin

end;
FormOsher.MouseRemote_CheckBox.Checked:=OnOff;
except on E : Exception do Log_Write('rscr',2,'RemoteMouseChecked: '); end;
end;


procedure Tfrm_RemoteScreen.MouseOffClick(Sender: TObject);
begin
try
RemoteMouseChecked(not FormOsher.MouseRemote_CheckBox.Checked);
except on E : Exception do Log_Write('rscr',2,'MouseOffClick: '); end;
end;


//////////////////////////////////////////////////////////////////////////////////////////////
procedure Tfrm_RemoteScreen.MouseRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) then
    Key := 0;
end;



procedure Tfrm_RemoteScreen.N3Click(Sender: TObject);
begin
try
SendMainCryptText('<|REDIRECT|><|PIXELFORMAT|>8<|END|>'); //pf8bit
  N3.Checked:=true;
  N4.Checked:=false;
  N5.Checked:=false;
except on E : Exception do Log_Write('rscr',2,'ButtonPixelFMClick'); end
end;


procedure Tfrm_RemoteScreen.N4Click(Sender: TObject);
begin
try
SendMainCryptText('<|REDIRECT|><|PIXELFORMAT|>16<|END|>'); //''pf16bit;
 N4.Checked:=true;
 N3.Checked:=false;
 N5.Checked:=false;
except on E : Exception do Log_Write('rscr',2,'ButtonPixelFHClick'); end
end;


procedure Tfrm_RemoteScreen.N5Click(Sender: TObject);
begin
try
SendMainCryptText('<|REDIRECT|><|PIXELFORMAT|>24<|END|>'); //pf24bit;
N5.Checked:=true;
N3.Checked:=false;
N4.Checked:=false;
except on E : Exception do Log_Write('rscr',2,'ButtonPixelFVHClick'); end
end;

function Tfrm_RemoteScreen.CreateFormFPS(Var TmpFPS:integer):boolean;
var
MyDlg:Tform;
EditFPS:TLabeledEdit;
BOk:Tbutton;
BNo:Tbutton;
begin
try
MyDlg:=Tform.Create(self);
MyDlg.Parent:=frm_Main.Parent;
MyDlg.BorderStyle:=bsDialog;
MyDlg.FormStyle:=fsStayOnTop;
MyDlg.position:=poScreenCenter;
EditFPS:=TLabeledEdit.Create(MyDlg);
Bok:=Tbutton.Create(MyDlg);
BNo:=Tbutton.Create(MyDlg);
try
 with MyDlg do
  begin
   caption:='���-�� ����/��� ��� ������� ������';
   width:=280;
   Height:=140;
     with EditFPS do
       begin
       parent:=MyDlg;
       Alignment:=taCenter;
       EditLabel.Caption:='�������� ��������: 5 - 60 ����/���';
       TextHint:='';
       NumbersOnly:=true;
       width:=240;
       left:=10;
       top:=30;
       end;

      with Bok do
      begin
      parent:=MyDlg;
      Caption:='Ok';
      ModalResult:=MrOk;
      width:=75;
      Height:=25;
      left:=95;
      top:=60;
      end;

      with BNo do
      begin
      parent:=MyDlg;
      Caption:='������';
      ModalResult:=MrCancel;
      width:=75;
      Height:=25;
      left:=175;
      top:=60;
      end;

    if (showmodal=ID_OK) then
     begin
     if trystrtoint(EditFPS.Text,TmpFPS) then
      begin
      result:=true;
      end
      else result:=false;
     end
    else
     begin
     result:=false;
     end;
 end;
finally
  EditFPS.Free;
  Bok.Free;
  Bno.Free;
  MyDlg.Free;
end;
except on E : Exception do Log_Write('rscr',2,'CreateFormFPS'); end;
end;


procedure Tfrm_RemoteScreen.N6Click(Sender: TObject);
var
fpstmp:integer;

begin
fpstmp:=5;
 if CreateFormFPS(fpstmp) then
 begin
 if fpstmp<5 then fpstmp:=5;
 if fpstmp>60 then fpstmp:=60;
  SendMainCryptText('<|REDIRECT|><|FPSMAXCOUNT|>'+inttostr(fpstmp)+'<|ENDFPS|>');
 end;
end;

procedure Tfrm_RemoteScreen.FileTransfer1Click(Sender: TObject);
begin
if not frm_ShareFiles.Visible then
 begin
 FormFileTransfer.IDConnect:=frm_RemoteScreen.tag;
 FormFileTransfer.WindowState:=WsNormal;
 FormFileTransfer.Show;
 end;
end;

procedure Tfrm_RemoteScreen.N1Click(Sender: TObject);
begin
if not FormFileTransfer.Visible then
 begin
 frm_ShareFiles.Tag:=frm_RemoteScreen.tag;
 frm_ShareFiles.Show;
 end;
end;

/////////////////////////////////////////////////////////////////////////////// ���������������
Procedure Tfrm_RemoteScreen.sizeMove (var msg: TWMSize);
var
mon:integer;
begin
try
 inherited;

 if (msg.SizeType = SC_MAXIMIZE) or (msg.SizeType = SC_RESTORE) or (msg.SizeType=61490)or (msg.SizeType=SC_SIZE)  then
 begin
 FrMaxRes:=true;
 SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(Screen_Image.Width) + '<|>' + IntToStr(Screen_Image.Height) + '<|END|>');
 end
 else FrMaxRes:=false;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.sizeMove');  end;
end;
//------------------------------------------------------
{procedure Tfrm_RemoteScreen.WndProc(var Message: TMessage);
begin
  inherited;
 if  Message.Msg= WM_EXITSIZEMOVE then
    begin
    SendReolutionResize:=true;

    Log_Write('rscr','Tfrm_RemoteScreen WM_EXITSIZEMOVE');
    end;
end; }
//////////////////////////////////////////////////// �������� ������� Alt+Ctrl+Del




procedure Tfrm_RemoteScreen.SpeedACDButtonClick(Sender: TObject); // ALT+CTRL+DEL
begin
try
SendMainCryptText('<|REDIRECT|><|ALT+CTR+DELETE|>');
except on E : Exception do Log_Write('rscr',2,'SpeedACDButtonClick');  end;
end;

procedure Tfrm_RemoteScreen.SpeedResizeButtonClick(Sender: TObject); // ���������/���� ��������������
begin
try
ResizeChecked(not FormOsher.Resize_CheckBox.Checked);
if FormOsher.Resize_CheckBox.Checked then
begin
SpeedResizeButton.ImageIndex:=18;
SpeedResizeButton.HotImageIndex:=19;
SpeedResizeButton.PressedImageIndex:=16;
SpeedResizeButton.Hint:='��������� ��������������';
end
else
begin
SpeedResizeButton.ImageIndex:=16;
SpeedResizeButton.HotImageIndex:=17;
SpeedResizeButton.PressedImageIndex:=18;
SpeedResizeButton.Hint:='�������� ��������������';
end;
except on E : Exception do Log_Write('rscr',2,'Scaling'); end;
end;




procedure Tfrm_RemoteScreen.SpeedKeyboardButtonClick(Sender: TObject); // ���������/��������� ����������
begin
try
KeyBRemoteChecked(not FormOsher.KeyboardRemote_CheckBox.Checked);
if FormOsher.KeyboardRemote_CheckBox.Checked then
begin
 SpeedKeyboardButton.ImageIndex:=8;
 SpeedKeyboardButton.HotImageIndex:=9;
 SpeedKeyboardButton.PressedImageIndex:=7;
 SpeedKeyboardButton.Hint:='��������� ����������';
end
else
begin
 SpeedKeyboardButton.ImageIndex:=7;
 SpeedKeyboardButton.HotImageIndex:=10;
 SpeedKeyboardButton.PressedImageIndex:=8;
 SpeedKeyboardButton.Hint:='�������� ����������';
end;
except on E : Exception do Log_Write('rscr',2,'SpeedKeyboardButtonClick');  end;
end;


procedure Tfrm_RemoteScreen.SpeedMonButtonClick(Sender: TObject);
begin
try
//frm_Main.MonitorCount:=4;
ParentMonitorUpUn;  // ������������� ������
except  exit;  end;
end;







procedure Tfrm_RemoteScreen.SpeedLoadClipboardClick(Sender: TObject); //�������� ��
var
exist:boolean;
timewaiting:integer;
begin
  try
  SpeedLoadClipboard.Enabled:=false;
  if  (FrmMyProgress.Tag=1)or(FrmMyProgress.Tag=2) then //1 - ������� �������� ������ �������� �� ������ ������
     begin
      // if not FrmMyProgress.Visible then
        FrmMyProgress.Show;
        if UpUnClipdoard then ParentClipboardUpUn; // ����������� ������
        SpeedLoadClipboard.Enabled:=true;
       exit;
     end;
   ExtFunctionClipboard(frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].FilesSock,frm_RemoteScreen.Tag,'',frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].CurrentPswdCrypt); // �������� ������ ������
   if UpUnClipdoard then ParentClipboardUpUn; // ����������� ������
   SpeedLoadClipboard.Enabled:=true;
    except on E : Exception do
     begin
     SpeedLoadClipboard.Enabled:=true;
     Log_Write('rscr',2,'SpeedLoadClipboardClick');
     end;
  end;
 end;

 procedure Tfrm_RemoteScreen.SpeedLoadClipboardMouseEnter(Sender: TObject);
begin
TimerHidePanel.Enabled:=false;
end;

procedure Tfrm_RemoteScreen.SpeedLoadClipboardMouseLeave(Sender: TObject);
begin
TimerHidePanel.Enabled:=true;
end;

procedure Tfrm_RemoteScreen.SpeedDownLoadClipboardClick(Sender: TObject);
 var
 timewaiting:integer;
  begin
    try
    SpeedDownLoadClipboard.Enabled:=false;
     if (FrmMyProgress.Tag=1)or(FrmMyProgress.Tag=2) then  //1 - ������� �������� ������ �� �������� �� ������ ������
       begin
         // if not FrmMyProgress.Visible then
          FrmMyProgress.Show;
          SpeedDownLoadClipboard.Enabled:=true;
         exit;
       end;
     if not SendFilesCryptText('<|DOWNLOADCLPBRD|>') then showmessage('������ �������� ������');
     if UpUnClipdoard then ParentClipboardUpUn; // ����������� ������
     SpeedDownLoadClipboard.Enabled:=true;

    except on E : Exception do
      begin
      SpeedDownLoadClipboard.Enabled:=true;
      Log_Write('rscr',2,'SpeedDownLoadClipboardClick');
      end;
    end;
  end;






procedure Tfrm_RemoteScreen.SpeedMouseButtonClick(Sender: TObject);
begin
try
RemoteMouseChecked(not FormOsher.MouseRemote_CheckBox.Checked);
if FormOsher.MouseRemote_CheckBox.Checked then
begin
SpeedMouseButton.ImageIndex:=25;
SpeedMouseButton.HotImageIndex:=27;
SpeedMouseButton.PressedImageIndex:=24;
SpeedMouseButton.Hint:='��������� ����';
DblLeftClick:=false; //������� �������� �����
end
else
begin
SpeedMouseButton.ImageIndex:=24;
SpeedMouseButton.HotImageIndex:=26;
SpeedMouseButton.PressedImageIndex:=25;
SpeedMouseButton.Hint:='�������� ����';
end;
except on E : Exception do Log_Write('rscr',2,'SpeedMouseButtonClick');  end;
end;





function Tfrm_RemoteScreen.ResizeChecked(OnOff:boolean):boolean; // true- ��������
begin
try
FormOsher.Resize_CheckBox.Checked:=OnOff;
 if OnOff then
  begin  //������� ���������������
    if windowstate=wsnormal then // ���� ����� �� �����������
      begin
      Screen_Image.AutoSize := false;
      Screen_Image.Align := alClient;
      end;
    if windowstate=wsmaximized then  // ���� ����� �����������
    begin
    if (frm_main.ResolutionTargetWidth<frm_RemoteScreen.Width) and
    (frm_main.ResolutionTargetHeight<frm_RemoteScreen.Height) then  // ���� ������ �������� ������ ������
       begin
       Screen_Image.AutoSize := true;
       Screen_Image.Align := alNone;
       Screen_Image.Left:=(frm_RemoteScreen.Width-Screen_Image.Width) div 2;
       Screen_Image.Top:=(frm_RemoteScreen.Height-Screen_Image.Height) div 2;
       end;
     if (frm_main.ResolutionTargetWidth>frm_RemoteScreen.Width) or
     (frm_main.ResolutionTargetHeight>frm_RemoteScreen.Height) then  // ���� ������ �������� ������ ������
       begin
       Screen_Image.AutoSize := true;
       Screen_Image.Align := alClient;
       end;
    end;
   if frm_RemoteScreen.Visible then  SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(Screen_Image.Width) + '<|>' + IntToStr(Screen_Image.Height) + '<|END|>');
   SendMainCryptText('<|REDIRECT|><|RESIZES|>1<|END|>');
  end;
 if not OnOff then // ��������� ���������������
  begin

    if windowstate=wsnormal then // ���� ����� �� �����������
      begin
      Screen_Image.AutoSize := true;
      Screen_Image.Align := alNone;
      Screen_Image.Left:=0;
      Screen_Image.Top:=0;
      end;
    if windowstate=wsmaximized then  // ���� ����� �����������
    begin
    if (frm_main.ResolutionTargetWidth<frm_RemoteScreen.Width)and // ���� �������� ������ ������
     (frm_main.ResolutionTargetHeight<frm_RemoteScreen.Height) then
       begin
       Screen_Image.AutoSize := true;
       Screen_Image.Align := alNone;
       Screen_Image.Left:=(frm_RemoteScreen.Width-Screen_Image.Width) div 2;
       Screen_Image.Top:=(frm_RemoteScreen.Height-Screen_Image.Height) div 2;
       end;
     if (frm_main.ResolutionTargetWidth>frm_RemoteScreen.Width) or
     (frm_main.ResolutionTargetHeight>frm_RemoteScreen.Height) then  // ���� ������ �������� ������ ������
       begin
       Screen_Image.AutoSize := false;
       Screen_Image.Align := alNone;
       end;
    end;
   if frm_RemoteScreen.Visible then SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(Screen_Image.Width) + '<|>' + IntToStr(Screen_Image.Height) + '<|END|>');
    SendMainCryptText('<|REDIRECT|><|RESIZES|>0<|END|>');
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.ResizeChecked');  end;
end;


procedure Tfrm_RemoteScreen.ResizeOffClick(Sender: TObject);
begin
 // ��������/��������� ���������������
//if not (windowstate=wsmaximized) then // ��� ����������� ����� ��������� ���������������
//ResizeChecked(not FormOsher.Resize_CheckBox.Checked);

end;

procedure Tfrm_RemoteScreen.FormResizeDefault; // ������ ����� �� ���������
begin
frm_RemoteScreen.WindowState:=wsNormal;
frm_RemoteScreen.Width:=(screen.ActiveForm.Monitor.Width-((screen.ActiveForm.Monitor.Width div 100)*40));
frm_RemoteScreen.Height:=screen.ActiveForm.Monitor.Height-((screen.ActiveForm.Monitor.Height div 100)*40);
Screen_Image.Picture.Bitmap.Width:=frm_RemoteScreen.ClientWidth;
Screen_Image.Picture.Bitmap.Height:=frm_RemoteScreen.ClientHeight;
end;

procedure Tfrm_RemoteScreen.FormConstrainedResize(Sender: TObject; var MinWidth, // ������� ����������� � ������������ ������ � ������ �����
  MinHeight, MaxWidth, MaxHeight: Integer);
begin
try
if frm_RemoteScreen.Visible then
  begin
  if frm_Main.ResolutionTargetWidth<(screen.ActiveForm.Monitor.Width-((screen.ActiveForm.Monitor.Width div 100)*40)) then MinWidth:=frm_Main.ResolutionTargetWidth
   else MinWidth:=(screen.ActiveForm.Monitor.Width-((screen.ActiveForm.Monitor.Width div 100)*40));
  if frm_Main.ResolutionTargetHeight<(screen.ActiveForm.Monitor.Height-((screen.ActiveForm.Monitor.Height div 100)*40)) then MinHeight:=frm_Main.ResolutionTargetHeight
   else MinHeight:=screen.ActiveForm.Monitor.Height-((screen.ActiveForm.Monitor.Height div 100)*40);

  if (windowstate=wsnormal) and (FormOsher.Resize_CheckBox.Checked) then // ������ ������������ ������ � ������  ����� (��������) ��� ����������� ����
    begin
    MaxWidth:=frm_main.ResolutionTargetWidth+(frm_RemoteScreen.Width-frm_RemoteScreen.ClientWidth);
    MaxHeight:= frm_main.ResolutionTargetHeight+(frm_RemoteScreen.Height-frm_RemoteScreen.ClientHeight);
    end;
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.FormConstrainedResize');  end;
end;

procedure Tfrm_RemoteScreen.FormResize(Sender: TObject);
begin
try
if (windowstate=wsmaximized) then //����  ����������� ����
  begin
  if not formOsher.Resize_CheckBox.Checked then  // ���� ��������� ���������������
    begin
     if (frm_main.ResolutionTargetWidth>screen.ActiveForm.Monitor.Width) or // ���� ����������� �������� �������  ������ ������ ������
     (frm_main.ResolutionTargetHeight>screen.ActiveForm.Monitor.Height) then
     begin
     Screen_Image.Align := alClient;  // ��������� �� ������� ������
     Screen_Image.AutoSize := true;  // ������������� ��� ��������
     Screen_Image.Top:=0;
     Screen_Image.Left:=0;
     end;
     if (frm_main.ResolutionTargetWidth<screen.ActiveForm.Monitor.Width)and // ���� �������� �������  ������ ������
     (frm_main.ResolutionTargetHeight<screen.ActiveForm.Monitor.Height) then
      begin
      SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(frm_main.ResolutionTargetWidth) + '<|>' + IntToStr(frm_main.ResolutionTargetHeight) + '<|END|>');
      Screen_Image.Align := alNone;
      Screen_Image.AutoSize := true;
      Screen_Image.Left:=(frm_RemoteScreen.Width-Screen_Image.Width) div 2;
      Screen_Image.Top:=(frm_RemoteScreen.Height-Screen_Image.Height) div 2;
      end;
    end;
    if formOsher.Resize_CheckBox.Checked then  // ���� ��������������� ��������
    begin
      if (frm_main.ResolutionTargetWidth<screen.ActiveForm.Monitor.Width) and
        (frm_main.ResolutionTargetHeight<screen.ActiveForm.Monitor.Height) then  // ���� ������ �������� �������  ������ ������
           begin
           SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(frm_main.ResolutionTargetWidth) + '<|>' + IntToStr(frm_main.ResolutionTargetHeight) + '<|END|>');
           Screen_Image.Align := alNone;
           Screen_Image.AutoSize := false;
           Screen_Image.Width:=frm_main.ResolutionTargetWidth;
           Screen_Image.Height:=frm_main.ResolutionTargetHeight;
           Screen_Image.Left:=(frm_RemoteScreen.Width-Screen_Image.Width) div 2;
           Screen_Image.Top:=(frm_RemoteScreen.Height-Screen_Image.Height) div 2;
           end;
         if (frm_main.ResolutionTargetWidth>screen.ActiveForm.Monitor.Width) or
         (frm_main.ResolutionTargetHeight>screen.ActiveForm.Monitor.Height) then  // ���� ������ �������� ������� ������ ������
           begin                                                          //frm_RemoteScreen.ClientWidth          //frm_RemoteScreen.ClientHeight
           SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(Screen_Image.Width) + '<|>' + IntToStr(Screen_Image.Height) + '<|END|>');
           Screen_Image.Align := alNone;
           Screen_Image.AutoSize := false;
           Screen_Image.Width:=frm_RemoteScreen.ClientWidth;
           Screen_Image.Height:=frm_RemoteScreen.ClientHeight;
           Screen_Image.Left:=0;
           Screen_Image.Top:=0;
           end;

     end;

  end;// ������������� ���� �����������

// ����� ������������� ����
  if (windowstate=wsNormal) then
    begin
    if not formOsher.Resize_CheckBox.Checked then  // ���� ��������� ���������������
      begin      // ������������� �������� ����� ��� ����. ��� ������ ����� �� ������� �� �� �������
      Screen_Image.Left:=0;
      Screen_Image.Top:=0;
      Screen_Image.AutoSize := true;
      Screen_Image.Align := alNone;
      end;

    if formOsher.Resize_CheckBox.Checked  then // ���� �������� ���������������
      begin                 // ������� �������� �� ������� �����.
      Screen_Image.AutoSize := false;
      Screen_Image.Stretch := true;
      Screen_Image.Align := alClient;

      if frm_main.ResolutionTargetWidth-Screen_Image.Width<=10 then
        frm_RemoteScreen.Width:=frm_RemoteScreen.Width+(frm_main.ResolutionTargetWidth-Screen_Image.Width);
      if frm_main.ResolutionTargetHeight-Screen_Image.Height<=10 then
        frm_RemoteScreen.Height:=frm_RemoteScreen.Height+(frm_main.ResolutionTargetHeight-Screen_Image.Height);

       if frm_RemoteScreen.Visible then
       if frm_RemoteScreen.Active then
         begin
         SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(Screen_Image.Width) + '<|>' + IntToStr(Screen_Image.Height) + '<|END|>');
         end;

      end;
    end;
// �������������� ���� ���������
/// ����� ���������� ��������� ������ � ������



except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.FormResize');  end;
end;



procedure Tfrm_RemoteScreen.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean); // ��� ��������� ������� ����� ������� ������ Timage, ��� ����������� ���������� �������� ������� ���������� ������� ��� ���������� � ����� ��������
begin
{if not FrMaxRes then // ��� wsmaximized ��� wsNormal ���������� ���������� ����������, �.�. ��� �������������� ����������
begin
if (NewWidth<>frm_RemoteScreen.Width) or (NewHeight<>frm_RemoteScreen.Height) then // ����� ��� ��������� ������� ���������� ����� ����������/ ��� �������������� ������� ���� ����������, ������� ��������� ������� � ���� ��� �� ��������� �� �������� ����� ������
if formOsher.Resize_CheckBox.Checked then SendMainCryptText('<|REDIRECT|><|RESOLUTIONRESIZE|>' + IntToStr(frm_RemoteScreen.Screen_Image.Width) + '<|>' + IntToStr(frm_RemoteScreen.Screen_Image.Height) + '<|END|>');
end; }
//if Resize then Log_Write('rscr','FormCanResize'+inttostr(NewWidth)+'/'+inttostr(NewHeight));
end;


///////////////////////////////////////////////////////////////////////////////////////////////// ��������� ����������

function Tfrm_RemoteScreen.KeyBRemoteChecked(OnOff:boolean):boolean; // true- ��������
begin
try
if OnOff then
begin

end
else
begin

end;
FormOsher.KeyboardRemote_CheckBox.Checked:=OnOff;
CaptureKeys_Timer.Enabled := OnOff; // ��������� ��� ���������� ������� ��������� ������� ������
except on E : Exception do Log_Write('rscr',2,'KeyBRemoteChecked');  end;
end;

procedure Tfrm_RemoteScreen.KeybButtonClick(Sender: TObject);
begin
try
KeyBRemoteChecked(not FormOsher.KeyboardRemote_CheckBox.Checked);
except on E : Exception do Log_Write('rscr',2,'KeybButtonClick');  end;
end;


procedure Tfrm_RemoteScreen.KeybButtonMouseEnter(Sender: TObject);
begin
if FormOsher.KeyboardRemote_CheckBox.Checked then

end;


procedure Tfrm_RemoteScreen.KeybButtonMouseLeave(Sender: TObject);
begin
if FormOsher.KeyboardRemote_CheckBox.Checked then

end;

////////////////////////////////////////////////////////////////////

procedure Tfrm_RemoteScreen.Resize_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;



procedure Tfrm_RemoteScreen.Screen_ImageDblClick(Sender: TObject);
begin
try
  if (Active) and (FormOsher.MouseRemote_CheckBox.Checked) then
  begin
  DblLeftClick:=true;
  SendMainCryptText('<|REDIRECT|><|SETMOUSEDBLCLICK|><|END|>');
  DblLeftClick:=false;
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.Screen_ImageMouseDown');  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
try
  //if  DblLeftClick then exit;

  if (Active) and (FormOsher.MouseRemote_CheckBox.Checked) then
  begin
    X := frm_Main.ResolutionTargetLeft+((X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width));
    Y := frm_Main.ResolutionTargetTop+((Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height));

    if (Button = mbLeft) then
      SendMainCryptText('<|REDIRECT|><|SETMOUSELEFTCLICKDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if (Button = mbRight) then
      SendMainCryptText('<|REDIRECT|><|SETMOUSERIGHTCLICKDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if Button = mbMiddle then
      SendMainCryptText('<|REDIRECT|><|SETMOUSEMIDDLEDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.Screen_ImageMouseDown');  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
try
  if (Active) and (FormOsher.MouseRemote_CheckBox.Checked) then
  begin
    X := frm_Main.ResolutionTargetLeft+((X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width));
    Y := frm_Main.ResolutionTargetTop+((Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height));
    SendMainCryptText('<|REDIRECT|><|SETMOUSEPOS|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>');
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.Screen_ImageMouseMove');  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
try
 //if  DblLeftClick then exit;
  if (Active) and (FormOsher.MouseRemote_CheckBox.Checked) then
  begin
    X := frm_Main.ResolutionTargetLeft+((X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width));
    Y := frm_Main.ResolutionTargetTop+((Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height));
    if (Button = mbLeft) then
      SendMainCryptText('<|REDIRECT|><|SETMOUSELEFTCLICKUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if (Button = mbRight) then
      SendMainCryptText('<|REDIRECT|><|SETMOUSERIGHTCLICKUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if Button = mbMiddle then
      SendMainCryptText('<|REDIRECT|><|SETMOUSEMIDDLEUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
  end;
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.Screen_ImageMouseUp');  end;
end;
 //-------------- ������� ��������� ������ ����
procedure Tfrm_RemoteScreen.ScrollBox1MouseWheel(Sender: TObject; // ������� ���������� �������  ScrollBox1MouseWheel
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin // ������������� �������� ������ ����, ������������� ������ ����
 try
 if (FormOsher.MouseRemote_CheckBox.Checked) then
    SendMainCryptText('<|REDIRECT|><|WHEELMOUSE|>' + IntToStr(WheelDelta) + '<|END|>');
//frm_RemoteScreen.Caption:='MouseWheel '+inttostr(WheelDelta);
{ if WheelDelta>0 then
   begin
   SendMainCryptText('<|REDIRECT|><|SETMOUSEWHEELUP|>'+IntToStr(WheelDelta)+'<|END|>')
   end
 else
   begin
   SendMainCryptText('<|REDIRECT|><|SETMOUSEWHEELDOWN|>'+IntToStr(WheelDelta)+'<|END|>')
   end; }
except on E : Exception do Log_Write('rscr',2,'Tfrm_RemoteScreen.ScrollBox1MouseWheel');  end;
end;

procedure Tfrm_RemoteScreen.ScrollBox1MouseWheelDown(Sender: TObject;  // MouseWheelDown ������� ���������� ����� MouseWheel
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
//showmessage('MouseWheelDown: MousePos.X-'+inttostr(MousePos.X)+': MousePos.Y'+inttostr(MousePos.Y));
end;

procedure Tfrm_RemoteScreen.ScrollBox1MouseWheelUp(Sender: TObject;  // MouseWheelUp ������� ���������� ����� MouseWheel
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
//showmessage('MouseWheelUp: MousePos.X-'+inttostr(MousePos.X)+': MousePos.Y'+inttostr(MousePos.Y));
end;

end.

