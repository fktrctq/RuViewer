unit FormAct;

interface

uses
  Winapi.Windows,ShellAPI, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormActivation = class(TForm)
    MemoUID: TMemo;
    Label1: TLabel;
    ButActivation: TButton;
    EditCount: TLabeledEdit;
    EditDate: TLabeledEdit;
    EditKey: TButtonedEdit;
    Label2: TLabel;
    Button1: TButton;
    procedure ButActivationClick(Sender: TObject);
    procedure EditKeyRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    function ActiveDone(ActKey:string;CountPC:integer; DateL:TdateTime):boolean;
    function NoActive:boolean;
    function NoCorrectUIDSrv:boolean;
    function NoCorrectDate:boolean;
    function NoWriteKeyAct:boolean;
  end;

var
  FormActivation: TFormActivation;

implementation
uses ConsoleSrv;
{$R *.dfm}

function TFormActivation.ActiveDone(ActKey:string;CountPC:integer; DateL:TdateTime):boolean;
begin
EditKey.Text:=ActKey;
EditCount.Text:=inttostr(CountPC);
EditDate.Text:=DatetimeToStr(DateL);
MessageDlg('Активация продукта прошла успешно!', mtInformation,[mbOk], 0, mbOk);
end;

function TFormActivation.NoActive:boolean;
begin
EditKey.Text:='';
EditCount.Text:='10';
EditDate.Text:=DateToStr(Now);
MessageDlg('Некорректный ключ продукта.', mtError,[mbOk], 0, mbOk);
end;

function TFormActivation.NoCorrectUIDSrv:boolean;
begin
MessageDlg('Некорректный UID.', mtError,[mbOk], 0, mbOk);
end;

function TFormActivation.NoCorrectDate:boolean;
begin
MessageDlg('Ключ активации не подходит к текущей версии продукта', mtError,[mbOk], 0, mbOk);
end;

function TFormActivation.NoWriteKeyAct:boolean;
begin
MessageDlg('Не удалось записать ключ активации', mtError,[mbOk], 0, mbOk);
end;

procedure TFormActivation.ButActivationClick(Sender: TObject);
var
tmpuid:string;
begin
tmpuid:=memouid.Lines.Text;
tmpuid:=StringReplace(tmpuid, #13, '', [rfReplaceAll, rfIgnoreCase]);
tmpuid:=StringReplace(tmpuid, #10, '', [rfReplaceAll, rfIgnoreCase]);
MainF.SendCryptTex('<|SETACTIVKEY|><|UIDSRV|>'+tmpuid+'<|END|><|KEYSRV|>'+EditKey.Text+'<|END|>');
ButActivation.Enabled:=false;
end;


procedure TFormActivation.Button1Click(Sender: TObject);
begin
try
    ShellApi.ShellExecute(0, 'Open', PChar('https://skrblog.ru/buy/'), nil, nil,SW_SHOWNORMAL);
except
on E: Exception do
MainF.WriteLog('Ошибка при открытии приложения : ' + E.Message);
end;

end;

procedure TFormActivation.EditKeyRightButtonClick(Sender: TObject);
var
TmpKey:string;
begin
if InputQuery('Введите ключ активации программы', '', TmpKey) then
 begin
   if TmpKey<>'' then
    begin
    EditKey.Text:=TmpKey;
    ButActivation.Enabled:=true;
    end;
 end;
end;

procedure TFormActivation.FormShow(Sender: TObject);
begin
ButActivation.Enabled:=false;
end;

end.
