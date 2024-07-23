unit FfmProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TFrmMyProgress = class(TForm)
    ProgressBar1: TProgressBar;
    Button1: TButton;
    MemoLog: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
  CancelLoadFile:boolean;
    { Public declarations }
  end;

var
  FrmMyProgress: TFrmMyProgress;

implementation

{$R *.dfm}

procedure TFrmMyProgress.Button1Click(Sender: TObject);
begin
CancelLoadFile:=true;
FrmMyProgress.Close;
end;

procedure TFrmMyProgress.FormCreate(Sender: TObject);
begin
CancelLoadFile:=false;
tag:=0;
end;

procedure TFrmMyProgress.FormShow(Sender: TObject);
begin
CancelLoadFile:=false;
MemoLog.Clear;
end;

end.
