unit Osher;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.ComCtrls;

type
  TFormOsher = class(TForm)
    Resize_CheckBox: TCheckBox;
    MouseRemote_CheckBox: TCheckBox;
    KeyboardRemote_CheckBox: TCheckBox;
    RoolUpOn: TImage;
    RoolUpOff: TImage;
    UnWrapOn: TImage;
    UnWrapOff: TImage;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormOsher: TFormOsher;

implementation

{$R *.dfm}



end.
