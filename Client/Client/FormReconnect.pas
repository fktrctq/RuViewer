unit FormReconnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons;

type
  TFReconnect = class(TForm)
    ButtonReconnect: TSpeedButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonReconnectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FReconnect: TFReconnect;

implementation
uses Form_RemoteScreen,Form_main;
var
TimeTmp:integer;
{$R *.dfm}

procedure TFReconnect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Timer1.Enabled:=false;
TimeTmp:=10;
ButtonReconnect.Caption:='10 ���';
end;

procedure TFReconnect.FormShow(Sender: TObject);
begin
if frm_RemoteScreen.Visible then // ���� � ����������� � ��������
begin
FReconnect.top:=(frm_RemoteScreen.Height div 2)-(FReconnect.Height div 2)+frm_RemoteScreen.top;
FReconnect.left:=(frm_RemoteScreen.Width div 2)-(FReconnect.Width div 2)+frm_RemoteScreen.left;
end;

if frm_Main.Visible then // ���� � ������� � �� ��� ������������
begin
FReconnect.top:=(frm_Main.Height div 2)-(FReconnect.Height div 2)+frm_Main.top;
FReconnect.left:=(frm_Main.Width div 2)-(FReconnect.Width div 2)+frm_Main.left;
end;

TimeTmp:=10;
ButtonReconnect.Caption:='10 ���';
ButtonReconnect.Enabled:=false;
Timer1.Enabled:=true;
end;

procedure TFReconnect.Timer1Timer(Sender: TObject);
begin
TimeTmp:=Pred(TimeTmp); // ���������� ������� ������ �������
ButtonReconnect.Caption:=inttostr(TimeTmp)+' ���';
if TimeTmp<=0 then
 begin
 ButtonReconnect.Caption:='���������';
 ButtonReconnect.Enabled:=true;
 Timer1.Enabled:=false;
 exit;
 end;
end;

procedure TFReconnect.ButtonReconnectClick(Sender: TObject);
begin
Timer1.Enabled:=false;
frm_RemoteScreen.CloseDesktopSocket;
FReconnect.Close;
end;

end.
