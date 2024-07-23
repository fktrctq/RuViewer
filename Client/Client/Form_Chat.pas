unit Form_Chat;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,System.NetEncoding,
  Vcl.ExtCtrls, Vcl.Buttons, HGM.Controls.Chat;
type
  Tfrm_Chat = class(TForm)
    Panel1: TPanel;
    RichEditSend: TRichEdit;
    NewChat: ThChat;
    ButtonSend: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function Log_write(fname:string; NumError:integer; TextMessage:string):string;
    function SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
    function SendMainCryptText(s:string):Boolean; //шифрование
    function SendEncodeBase64(mes:string; var outmes:string):boolean; // Перевод текста в base64
    procedure RichEditSendKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure RichEditSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    { Private declarations }
  public
    { Public declarations }
  end;
var
  frm_Chat: Tfrm_Chat;
implementation
{$R *.dfm}
uses
  Form_Main,Form_RemoteScreen,Osher,SocketCrypt;


function Tfrm_Chat.Log_write(fname:string; NumError:integer; TextMessage:string):string;
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
  exit;
  end;
  end;
end;



function Tfrm_Chat.SendMainSock(s:ansistring):boolean; // Отправка через главный сокет
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
   result:=true;
   end
  else result:=false;
end;
except on E : Exception do Log_Write('Chat',2,'SendMainSocketRemoteScreen ('+inttostr(frm_RemoteScreen.tag));  end;
end;

procedure Tfrm_Chat.ButtonSendClick(Sender: TObject);
var
tmps:string;
begin
try
 if Length(RichEditSend.Text) > 0 then
  begin
  tmps:='';
  if SendEncodeBase64(RichEditSend.Text,tmps) then
   if SendMainCryptText('<|REDIRECT|><|CHAT|>' + tmps + '<|END|>') then
    Begin
     with NewChat.Items.AddMessage do
      begin
      From:='я написал'; //кто написал
      FromColor:=clSkyBlue;// цвет
      FromType:=TChatMessageType.mtMe;          //mtOpponent, mtMe  кто написал, я или мне
      color:=clBlack;
      Text:=RichEditSend.Text; // текст сообщения
      date:=now;
      end;
    RichEditSend.Clear;
    end;
  End;
except on E : Exception do Log_Write('Chat',2,'ButtonSendClick')  end;
end;

function Tfrm_Chat.SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
Encryptstrs(s,frm_Main.ArrConnectSrv[frm_RemoteScreen.Tag].CurrentPswdCrypt, CryptBuf); //шифруем перед отправкой
result:=SendMainSock('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
except On E: Exception do
 begin
 s:='';
 result:=false;
 Log_Write('Chat',2,'Ошибка шифрования перед отправкой сокета (М) внешняя функции');
 end;
end;
end;

function Tfrm_Chat.SendEncodeBase64(mes:string; var outmes:string):boolean;
begin
try
outmes:=TNetEncoding.Base64.Encode(mes);
if outmes<>'' then result:=true;

except On E: Exception do
    begin
    result:=false;
    Log_Write('Chat',2,'Ошибка SendEncodeBase64');
    end;
  end;
end;

procedure Tfrm_Chat.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
{ sets Size-limits for the Form }
var
  MinMaxInfo: PMinMaxInfo;
begin
  inherited;
  MinMaxInfo := Message.MinMaxInfo;
  MinMaxInfo^.ptMinTrackSize.X := 400; // Minimum Width
  MinMaxInfo^.ptMinTrackSize.Y := 340; // Minimum Height
end;
procedure Tfrm_Chat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
frm_RemoteScreen.ChatButton.ImageIndex:=3;
frm_RemoteScreen.ChatButton.HotImageIndex:=6;
frm_RemoteScreen.ChatButton.PressedImageIndex:=4;
frm_RemoteScreen.ChatButton.Hint:='Открыть Чат';
end;

procedure Tfrm_Chat.FormCreate(Sender: TObject);
begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
  Left := Screen.WorkAreaWidth - Width;
  Top := Screen.WorkAreaHeight - Height;
  RichEditSend.Clear;
  NewChat.Items.Clear;
  with NewChat.Items.AddInfo do
  begin
    Text := 'RuViewer - Чат';
  end;
end;


procedure Tfrm_Chat.FormShow(Sender: TObject);
begin
RichEditSend.SetFocus;
end;

//------------------------------------------------------------------------------------

procedure Tfrm_Chat.RichEditSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var
 tmps:string;
begin
try
if (ssShift in Shift) and (key=VK_RETURN) then
 begin
 key:=VK_RETURN;
 end
 else
 if key=VK_RETURN then
  begin
    if Length(RichEditSend.Text) > 0 then
    begin
     tmps:='';
     if SendEncodeBase64(RichEditSend.Text,tmps) then
     if SendMainCryptText('<|REDIRECT|><|CHAT|>' + tmps + '<|END|>') then
      Begin
       with NewChat.Items.AddMessage do
          begin
           //From:='я написал'; //кто написал
           FromColor:=clSkyBlue;// цвет
           FromType:=TChatMessageType.mtMe;          //mtOpponent, mtMe  кто написал, я или мне
           Text:=RichEditSend.Text; // текст сообщения
           date:=now;
          end;
       RichEditSend.Clear;
      End;
    end;
  Key := 0;
  end;
except on E : Exception do Log_Write('Chat',2,'SendKeyDown')  end;
end;

procedure Tfrm_Chat.RichEditSendKeyPress(Sender: TObject; var Key: Char);

begin

end;
//----------------------------------------------------------------------------------------------
end.

