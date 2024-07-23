unit GenPassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.Buttons,System.Math;

type
  TGenNewPswd = class(TForm)
    EditPswd: TLabeledEdit;
    ButOk: TButton;
    ButNo: TButton;
    VM23: TVirtualImageList;
    ImageCollection1: TImageCollection;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButOkClick(Sender: TObject);
    procedure ButNoClick(Sender: TObject);
  private
    { Private declarations }
  public
  TextPswd:string;
  function RandomPassword: string; // генерация случайного пароля
  end;

var
  GenNewPswd: TGenNewPswd;

implementation

{$R *.dfm}

procedure TGenNewPswd.ButNoClick(Sender: TObject);
begin
 GenNewPswd.Close;
end;

procedure TGenNewPswd.ButOkClick(Sender: TObject);
begin
TextPswd:=EditPswd.Text;
end;

procedure TGenNewPswd.FormShow(Sender: TObject);
begin
EditPswd.Text:=RandomPassword;
end;

function TGenNewPswd.RandomPassword: string;
  var
    strBase: string;
    strUpper: string;
    //strSpecial: string;
    strRecombine: string;
    Lpswd:integer;
  begin
    strRecombine:='';
    Result := '';
    Randomize;
    //string with all possible chars
    strBase   := 'abcdefghijklmnopqrstuvwxyz1234567890';
    strUpper:='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Lpswd:=RandomRange(6, 10);
    while Length(Result) < Lpswd do
    begin
      strRecombine:= strUpper[Random(Length(strUpper)) + 1];
      Result:=Result+strRecombine;
      Result := Result +  strBase[Random(Length(strBase)) + 1];
    end;
      RandomRange(2, Length(strBase));
      Result[RandomRange(2, Lpswd)]:=strRecombine[1];

end;

procedure TGenNewPswd.SpeedButton1Click(Sender: TObject);
begin
EditPswd.Text:=RandomPassword;
end;

end.
