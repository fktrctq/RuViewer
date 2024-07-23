unit FormSetLevelPrivelage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormPrivilage = class(TForm)
    ComboLevelAuto: TComboBox;
    ComboLevelManual: TComboBox;
    LAutoRun: TLabel;
    LManualRun: TLabel;
    PanelButton: TPanel;
    ButtonCancel: TSpeedButton;
    ButtonSave: TSpeedButton;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
  LevelAutoRun:integer;//0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_SID
  LevelRunManual:integer;//0-SYSTEM_INTEGRITY_SID 1-HIGH_INTEGRITY_SID  2-MEDIUM_INTEGRITY_
  //procedure defaultposition;
  end;

var
  FormPrivilage: TFormPrivilage;


implementation
uses Form_Settings;
{$R *.dfm}

{procedure TFormPrivilage.defaultposition;
begin
ComboLevelAuto.Width:=FormPrivilage.Width-35;
ComboLevelManual.Width:=FormPrivilage.Width-35;
LAutoRun.Left:=(Panel1.Width div 2)-(LAutoRun.Width div 2);
ComboLevelAuto.Left:=(Panel1.Width div 2)-(ComboLevelAuto.Width div 2);
LManualRun.Left:=(Panel1.Width div 2)-(LManualRun.Width div 2);
ComboLevelManual.Left:=(Panel1.Width div 2)-(ComboLevelManual.Width div 2);

end; }


procedure TFormPrivilage.ButtonCancelClick(Sender: TObject);
begin
FormPrivilage.Close;
end;

procedure TFormPrivilage.ButtonSaveClick(Sender: TObject);
begin
if Form_set.WritelevelPrivilage(ComboLevelAuto.itemindex,ComboLevelManual.itemindex) then
FormPrivilage.Close
else showmessage('Не удалось сохранить настройки!!!');
end;

procedure TFormPrivilage.FormShow(Sender: TObject);
begin
if (LevelAutoRun>3)and(LevelAutoRun<0) then LevelAutoRun:=0;
if (LevelRunManual>3)and(LevelRunManual<0) then LevelRunManual:=0;
ComboLevelAuto.itemindex:=LevelAutoRun;
ComboLevelManual.itemindex:=LevelRunManual;

ComboLevelAuto.Width:=FormPrivilage.Width-35;
ComboLevelManual.Width:=FormPrivilage.Width-35;
ComboLevelAuto.Left:=10;
ComboLevelManual.Left:=10;
end;



end.
