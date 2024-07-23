unit Form_Password;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,  Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage;
type
  Tfrm_Password = class(TForm)
    Ok_BitBtn: TBitBtn;
    Password_Edit: TEdit;
    PasswordIcon_Image: TImage;
    procedure Ok_BitBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Password_EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    function SendMainSocket(s:ansistring):boolean;
    function SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  frm_Password: Tfrm_Password;
  Canceled: Boolean;
implementation
{$R *.dfm}
uses
  Form_Main,SocketCrypt;

procedure Tfrm_Password.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Canceled then
  begin
    frm_Main.Status_Label.Caption := 'В сети';
    frm_Main.TargetID_MaskEdit.Enabled := true;
    frm_Main.butConnect.Enabled := true;
  end;
end;

procedure Tfrm_Password.FormCreate(Sender: TObject);
begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
end;
procedure Tfrm_Password.FormShow(Sender: TObject);
begin
  Canceled := true;
  Password_Edit.Clear;
  Password_Edit.SetFocus;
end;

function Tfrm_Password.SendMainCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
Encryptstrs(s,frm_Main.ArrConnectSrv[frm_Password.Tag].SrvPswd, CryptBuf); //шифруем перед отправкой
SendMainSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
result:=true;
  except On E: Exception do
    begin
    s:='';
    result:=false;
    frm_Main.Log_Write('app',2,'ERROR  - Ошибка шифрования перед отправкой сокета (М) внешняя функции  '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

function Tfrm_Password.SendMainSocket(s:ansistring):boolean; // отправка данных в сокет который сейчас подключается к клиенту
begin
try
result:=true;
if frm_Main.ArrConnectSrv[frm_Password.Tag].mainSock=nil then result:=false
else
begin
  if frm_Main.ArrConnectSrv[frm_Password.Tag].mainSock.Connected then
   while frm_Main.ArrConnectSrv[frm_Password.Tag].mainSock.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do frm_Main.Log_Write('app',2,'Ошибка отправки сокета (М) внешняя функции  : '+E.ClassName+': '+E.Message);  end;
end;

procedure Tfrm_Password.Ok_BitBtnClick(Sender: TObject);
begin
  SendMainCryptText('<|CHECKIDPASSWORD|>' + frm_Main.TargetID_MaskEdit.Text + '<|>' + Password_Edit.Text + '<|END|>');
  Canceled := false;
  Close;
end;

procedure Tfrm_Password.Password_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Ok_BitBtn.Click;
    Key := #0;
  end
end;
end.
