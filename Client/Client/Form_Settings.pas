unit Form_Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,inifiles,Registry, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Mask,Math, Vcl.Buttons, Vcl.ImgList,
  Vcl.Imaging.pngimage, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.VirtualImage;

type
  TForm_set = class(TForm)
    EditNamePC: TEdit;
    Label3: TLabel;
    PanelButton: TPanel;
    GroupBox1: TGroupBox;
    EditSrvIp: TButtonedEdit;
    EditSrvPort: TButtonedEdit;
    EditSrvPswd: TButtonedEdit;
    EditFPS: TButtonedEdit;
    EditMyID: TButtonedEdit;
    EditMyPswd: TButtonedEdit;
    GroupBox2: TGroupBox;
    LLAccessControl: TLinkLabel;
    LLAutoRun: TLinkLabel;
    CheckAutoRun: TCheckBox;
    CheckCA: TCheckBox;
    ImageCButoon: TImageCollection;
    ImageButList: TVirtualImageList;
    ImageAutoRun: TVirtualImage;
    ImageCheckCA: TVirtualImage;
    ButtonCancel: TSpeedButton;
    ButtonSave: TSpeedButton;
    LLPrivilageLevel: TLinkLabel;

    procedure ButtonCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure CheckCAClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditMyPswdRightButtonClick(Sender: TObject);
    procedure EditMyIDRightButtonClick(Sender: TObject);
    procedure ImageCheckCAqClick(Sender: TObject);
    procedure ImageAutoRunaClick(Sender: TObject);
    Procedure CheckImageAutoRun; // смена изображения на автозапуск
    Procedure CheckImageAccessControl;
    procedure EditSrvIpRightButtonClick(Sender: TObject);
    procedure EditSrvPortRightButtonClick(Sender: TObject);
    procedure EditSrvPswdRightButtonClick(Sender: TObject);
    procedure EditFPSRightButtonClick(Sender: TObject);
    procedure EditFPSMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditSrvPswdMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditSrvPswdMouseLeave(Sender: TObject);
    procedure LLPrivilageLevelClick(Sender: TObject);
    procedure EditSrvIpKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public

   Procedure ReadFileSet(var srv,NamePC,MyID,MyPswd,Srvpswd:string; var Port:integer; var CntlAcs:boolean; var AutoRun:string; var result:boolean);
   function WriteFileSet(srv,port,NamePC,SrvPswd:string; AutoRun:string):boolean;
   Procedure ReadRegSet(var port,fps,LogLevel:Integer; var srv,NamePC,MyID,MyPswd,PswdServer:string; var CntlAcs:boolean; var autorun:string; var result:boolean);
   function WriteRegSet(port:Integer;srv,NamePC,SrvPswd:string; AutoRun:string):boolean;

   Function ReadlevelPrivilage(var LevelSrvc,LevelUser:Integer):boolean; // чтение настроек уровня запуска процесса
   function WritelevelPrivilage(LevelSrvc,LevelUser:Integer):boolean; // Запись настроек привелегий запуска в реестр

   function WriteFileIDPasAC(MyID,MyPswd:string;CntlAcs:boolean):boolean;
   function WriteRegIDPasAC(fps,LogLevel:integer; MyID,MyPswd:string; CntlAcs:boolean):boolean;
   function WriteRegFPS(fps:integer):boolean; // Запись настроек в реестр

   Function WriteFileID(ID:string):boolean;
   Function WriteRegID(ID:string):boolean;
   function WriteLog(fname:string; NumError:integer; TextMessage:string):boolean;
   function GetNamePC:string;
   Procedure DefaultPosition; // Чтение параметров запуска из командной стороки
  end;

var
  Form_set: TForm_set;

implementation
uses Form_main,FormSetLevelPrivelage;

{$R *.dfm}

Procedure TForm_set.DefaultPosition;
var
WidthElement:integer;
begin
try
WidthElement:=GroupBox2.Width-20;
EditMyID.Width:=WidthElement;
EditMyPswd.Width:=WidthElement;
EditFPS.Width:=WidthElement;

EditMyID.Left:=(GroupBox2.Width div 2)-(EditMyID.Width div 2);
EditMyPswd.Left:=(GroupBox2.Width div 2)-(EditMyPswd.Width div 2);
EditFPS.Left:=(GroupBox2.Width div 2)-(EditFPS.Width div 2);
ImageCheckCA.Left:=(EditMyID.Left+EditMyID.Width)-ImageCheckCA.Width;
ImageAutoRun.Left:=(EditMyID.Left+EditMyID.Width)-ImageAutoRun.Width;
LLAccessControl.Left:= (GroupBox2.Width div 2)-(LLAccessControl.Width div 2)-(ImageCheckCA.Width div 2);
LLAutoRun.Left:= (GroupBox2.Width div 2)-(LLAutoRun.Width div 2)-(ImageAutoRun.Width div 2);
LLPrivilageLevel.Left:= (GroupBox2.Width div 2)-(LLPrivilageLevel.Width div 2);

EditSrvIp.Width:=WidthElement;
EditSrvPort.Width:=WidthElement;
EditSrvPswd.Width:=WidthElement;
EditSrvIp.Left:=(GroupBox2.Width div 2)-(EditSrvIp.Width div 2);
EditSrvPort.Left:=(GroupBox2.Width div 2)-(EditSrvPort.Width div 2);
EditSrvPswd.Left:=(GroupBox2.Width div 2)-(EditSrvPswd.Width div 2);

except
 WriteLog('set',2,'Ошибка Default position :');
 end;
end;


function TForm_set.WriteLog(fname:string; NumError:integer; TextMessage:string):boolean;  // запись логов
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
 except
 exit;
 end;
end;

Procedure Tform_set.ReadFileSet(var srv,NamePC,MyID,MyPswd,Srvpswd:string; var Port:integer; var CntlAcs:boolean; var AutoRun:string; var result:boolean);// чтение настроек из файла
var
Fileset: TMemInifile;
begin
if FileExists(ExtractFilePath(Application.ExeName) + '\data.dat') then // чтение файла параметров если он существует
    begin
      Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName) +
        '\data.dat', TEncoding.Unicode);
      try
      Port:=Fileset.ReadInteger('Net','Port',0); //3898
      srv:=Fileset.ReadString('Net','IP','');   //сервер
      NamePC:=fileset.ReadString('Other','PCn','Unknw');
      AutoRun:= fileset.ReadString('Other','AutoRun','Auto');
      MyID:= fileset.ReadString('Other','ID','');
      MyPswd:=fileset.ReadString('Other','pswd','');
      Srvpswd:=fileset.ReadString('Other','SrvPswd','');
      CntlAcs:= fileset.ReadBool('Other','ControlAccess',false);
      Fileset.Free;
      result:=true;
     // WriteLog('set','Чтение файла настроек :'+inttostr(port)+': '+srv+': '+NamePC);
       except on  E : Exception do
       begin
        WriteLog('set',2,'Ошибка чтения файла настроек :');
        result:=false;
       end;
       end;
     end
   else result:=false; // если нет файла настроек
end;


function TForm_set.WriteFileID(ID:string):boolean; // запись ID в файл
var
Fileset: TMemInifile;
begin
 Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName)+'\data.dat', TEncoding.Unicode);
 try
if ID<>'' then  fileset.WriteString('Other','ID',ID);
fileset.UpdateFile;
Fileset.Free;
result:=true;
 except on  E : Exception do
 begin
 WriteLog('set',2,'Ошибка записи файла настроек :');
 result:=false;
 end;
 end;
end;


function TForm_set.WriteFileIDPasAC(MyID,MyPswd:string;CntlAcs:boolean):boolean; // запись настроек в файл
var
Fileset: TMemInifile;
begin
 Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName)+'\data.dat', TEncoding.Unicode);
 try
if MyID<>'' then  fileset.WriteString('Other','ID',MyID);
if MyPswd<>'' then fileset.WriteString('Other','pswd',MyPswd);
fileset.WriteBool('Other','ControlAccess',CntlAcs);
fileset.UpdateFile;
Fileset.Free;
result:=true;
 except on  E : Exception do
 begin
 WriteLog('set',2,'Ошибка записи файла настроек');
 result:=false;
 end;
 end;
end;

function TForm_set.WriteFileSet(srv,port,NamePC,SrvPswd:string;  AutoRun:string):boolean; // запись настроек в файл
var
Fileset: TMemInifile;
begin

 Fileset := TMemInifile.Create(ExtractFilePath(Application.ExeName)+'\data.dat', TEncoding.Unicode);
 try
if port<>'' then Fileset.writestring('Net','Port',port); //3898
if srv<>'' then Fileset.writestring('Net','IP',srv);   //сервер
if NamePC<>'' then fileset.WriteString('Other','PCn',NamePC);
if AutoRun<>'' then fileset.WriteString('Other','AutoRun',AutoRun);
if SrvPswd<>'' then fileset.WriteString('Other','SrvPswd',SrvPswd);

fileset.UpdateFile;
Fileset.Free;
result:=true;
 except on  E : Exception do
 begin
 WriteLog('set',2,'Ошибка записи файла настроек');
 result:=false;
 end;
 end;
end;

Procedure Tform_set.ReadRegSet(var port,fps,LogLevel:Integer; var srv,NamePC,MyID,MyPswd,PswdServer:string; var CntlAcs:boolean; var autorun:String; var result:boolean); // чтение настроек из реестра
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_READ); //KEY_READ только чтение, для доступа пользователей без прав администратора
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',false) then
      begin
      port:=Reg.ReadInteger('Port');
      srv:=Reg.ReadString('IP');
      NamePC:=Reg.ReadString('PCn');
      Autorun:=Reg.ReadString('Autorun');
      MyID:=Reg.ReadString('ID');
      MyPswd:=Reg.ReadString('pswd');
      PswdServer:= Reg.ReadString('SrvPswd');
      CntlAcs:=Reg.ReadBool('ControlAccess');
      Fps:=Reg.ReadInteger('fps');
      LogLevel:=Reg.ReadInteger('LogLevel');
      result:=true;
      end
     else result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('set',2,'Ошибка чтения настроек в реестре');
    result:=false;
  end;
end;
end;

Function Tform_set.ReadlevelPrivilage(var LevelSrvc,LevelUser:Integer):boolean; // чтение настроек уровня запуска процесса
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_READ); //KEY_READ только чтение, для доступа пользователей без прав администратора
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',false) then
      begin
      LevelSrvc:=Reg.ReadInteger('LevelAutoRun');
      LevelUser:=Reg.ReadInteger('LevelManualRun');
      result:=true;
      end
     else result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('set',2,'Ошибка чтения привелегий в реестре');
    result:=false;
  end;
end;
end;


function Tform_set.WriteRegID(ID:string):boolean; // ЗаписьID в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
      begin
      if ID<>'' then reg.WriteString('ID',ID);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('set',2,'Ошибка записи настроек в реестр');
    result:=false;
  end;
end;
end;

function Tform_set.WriteRegFPS(fps:integer):boolean; // Запись настроек в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
      begin
      Reg.writeInteger('fps',Fps);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('app',2,'FPS Ошибка записи настроек в реестр');
    result:=false;
  end;
end;
end;



function Tform_set.WriteRegIDPasAC(fps,LogLevel:integer; MyID,MyPswd:string;CntlAcs:boolean):boolean; // Запись настроек в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
      begin
      if MyID<>'' then reg.WriteString('ID',MyID);
      if MyPswd<>'' then reg.WriteString('pswd',MyPswd);
      Reg.WriteBool('ControlAccess',CntlAcs);
      Reg.writeInteger('fps',Fps);
      Reg.WriteInteger('LogLevel',LogLevel);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('app',2,'Ошибка записи настроек в реестр');
    result:=false;
  end;
end;
end;


function Tform_set.WriteRegSet(port:Integer;srv,NamePC,SrvPswd:string; autorun:string):boolean; // Запись настроек в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
      begin
      if port<>0 then Reg.WriteInteger('Port',Port);
      if srv<>'' then Reg.WriteString('IP',srv);
      if NamePC<>'' then Reg.WriteString('PCn',NamePC);
      if autorun<>'' then reg.WriteString('Autorun',autorun);
      if SrvPswd<>'' then reg.WriteString('SrvPswd',SrvPswd);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('app',2,'Ошибка записи настроек в реестр');
    result:=false;
  end;
end;
end;

function Tform_set.WritelevelPrivilage(LevelSrvc,LevelUser:Integer):boolean; // Запись настроек привелегий запуска в реестр
var
  Reg: TRegistry;
begin
try
  Reg := nil;
  try
  {LevelSrvc:=Reg.ReadInteger('LevelAutoRun');
      LevelSrvc:=Reg.ReadInteger('LevelManualRun');}
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\RuViewer',true) then // если удалось открыть ключ
      begin
      Reg.WriteInteger('LevelAutoRun',LevelSrvc);
      Reg.WriteInteger('LevelManualRun',LevelUser);
      result:=true;
      end
      else  result:=false;
  finally
    reg.Free;
  end;
except on E:Exception do
  begin
    WriteLog('app',2,'Ошибка записи привелегий в реестр');
    result:=false;
  end;
end;
end;


function RandomPassword1(PLen: Integer): string;
var
  str: string;
begin
  Randomize;
  str    := '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = PLen)
end;

function RandomPassword(PLen: Integer): string;
  var
    strBase: string;
    strUpper: string;
    strSpecial: string;
    strRecombine: string;
  begin
    strRecombine:='';
    Result := '';
    Randomize;
    //string with all possible chars
    strBase   := 'abcdefghijklmnopqrstuvwxyz1234567890';
    strUpper:='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    strSpecial:='@!_*#';
    // Start Random
    strRecombine:= strUpper[Random(Length(strUpper)) + 1];
    Result:=strRecombine;
    strRecombine:= strSpecial[Random(Length(strSpecial))+1];
    repeat
      Result := Result +  strBase[Random(Length(strBase)) + 1];
    until (Length(Result) = PLen);
      RandomRange(2, Length(strBase));
      Result[RandomRange(2, PLen)]:=strRecombine[1];
  //result:=Result+strRecombine;
end;





procedure TForm_set.ButtonCancelClick(Sender: TObject);
begin
Form_set.Close;
end;

procedure TForm_set.EditMyPswdRightButtonClick(Sender: TObject);
begin
EditMyPswd.Text:=RandomPassword(6);
end;

procedure TForm_set.EditSrvIpKeyPress(Sender: TObject; var Key: Char);
begin
if not (key in['0'..'9',#8,'.']) then key:=#0;
end;

procedure TForm_set.EditSrvIpRightButtonClick(Sender: TObject);
begin
EditSrvIp.ReadOnly:=not EditSrvIp.ReadOnly;
if not EditSrvIp.ReadOnly then
begin
EditSrvIp.SetFocus;
EditSrvIp.SelectAll;
EditSrvIp.RightButton.ImageIndex:=1;
end
else
begin
EditSrvIp.RightButton.ImageIndex:=2;
end;
end;

procedure TForm_set.EditSrvPortRightButtonClick(Sender: TObject);
begin
EditSrvPort.ReadOnly:=not EditSrvPort.ReadOnly;
if not EditSrvPort.ReadOnly then
begin
EditSrvPort.SetFocus;
EditSrvPort.SelectAll;
EditSrvPort.RightButton.ImageIndex:=1;
end
else
begin
EditSrvPort.RightButton.ImageIndex:=7;
end;

end;


procedure TForm_set.EditSrvPswdMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if not EditSrvPswd.ReadOnly then EditSrvPswd.PasswordChar:=#0;
end;

procedure TForm_set.EditSrvPswdMouseLeave(Sender: TObject);
begin
EditSrvPswd.PasswordChar:=#42;
end;

procedure TForm_set.EditSrvPswdRightButtonClick(Sender: TObject);
begin
EditSrvPswd.ReadOnly:=not EditSrvPswd.ReadOnly;
if not EditSrvPswd.ReadOnly then
begin
EditSrvPswd.SetFocus;
EditSrvPswd.SelectAll;
EditSrvPswd.RightButton.ImageIndex:=1;
end
else
begin
EditSrvPswd.RightButton.ImageIndex:=6;
end;
end;


procedure TForm_set.ButtonSaveClick(Sender: TObject);  //button save
var
strAutoRun:string;
exist:boolean;
indexArr:byte;
 Begin
  if CheckAutoRun.Checked then strAutoRun:='Auto' else strAutoRun:='No';
  exist:=false;
   if FpsMaxCount<>strtoint(EditFPS.Text) then
   begin
    FpsMaxCount:=strtoint(EditFPS.Text);
    WriteRegFPS(FpsMaxCount);
   end;


   if (frm_Main.hostServer<>EditSrvIp.Text) or (frm_Main.port<>strtoint(EditSrvPort.Text)) or (frm_Main.PswdServer<>EditSrvPswd.Text) then // если изменили настройки подключения
    begin
      frm_Main.hostServer:=EditSrvIp.Text;  // ip сервера
      frm_Main.port:=strtoint(EditSrvPort.Text);   // порт сервера
      frm_Main.PswdServer:=EditSrvPswd.Text;   // пароль сервера
      frm_Main.PCn:=EditNamePC.Text;         // имя пк
      if not writeregset(strtoint(EditSrvPort.Text),EditSrvIp.Text,EditNamePC.Text,EditSrvPswd.Text,strAutoRun) then // запись настроек в реестр
      WriteFileSet(EditSrvIp.Text,EditSrvPort.Text,EditNamePC.Text,EditSrvPswd.Text,strAutoRun);                  // иначе запись в файл
      exist:=true;
    end;

    if not exist then
   if (AutoRunApp<>strAutoRun) then
    begin
     AutoRunApp:=strAutoRun;
     if not writeregset(strtoint(EditSrvPort.Text),EditSrvIp.Text,EditNamePC.Text,EditSrvPswd.Text,strAutoRun) then // запись настроек в реестр
      WriteFileSet(EditSrvIp.Text,EditSrvPort.Text,EditNamePC.Text,EditSrvPswd.Text,strAutoRun);
    end;

   if (frm_Main.MyID<>EditMyID.Text) or (frm_Main.MyPassword<>EditMyPswd.Text) or (CheckCA.Checked<>ControlAccess)  then
     begin
       if frm_Main.MyPassword<>EditMyPswd.Text then
         begin
         if frm_Main.SendMainCryptText('<|SETMYPSWD|>'+EditMyPswd.Text+'<|ENDPSWD|>',frm_Main.PswdServer) then // запрос обновления пароля на моем сервере
          frm_Main.MyPassword:=EditMyPswd.Text; // Мой пароль
         end;

       if frm_Main.MyID<>EditMyID.Text then
         begin
         if frm_Main.SendMainCryptText('<|SETMYID|>'+EditMyID.Text+'<|ENDID|>',frm_Main.PswdServer) then  // запрос обновления ID на моем сервере
          frm_Main.MyID:=EditMyID.Text; // Мой ID
         end;

       ControlAccess:=CheckCA.Checked;// неконтролируемый доступ

       if not writeregIDPasAC(FpsMaxCount,LevelLogError,frm_Main.MyID,frm_Main.MyPassword,ControlAccess) then // запись настроек в реестр
          WriteFileIDPasAC(frm_Main.MyID,frm_Main.MyPassword,ControlAccess);  // иначе запись в файл
     end;



   if exist then // если меняли настройки то переподключаемся
      begin
         if messageDlg('Произвести переподключение к серверу с новыми настройками? '+frm_Main.hostServer+'?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
         begin
           try
           if frm_Main.CurrentActivMainSocket<>-1 then // если в текущий момент к абоненту подключены, то надо сокеты разеденить
           frm_Main.SendMainCryptText('<|STOPACCESS|>',frm_Main.ArrConnectSrv[frm_Main.CurrentActivMainSocket].CurrentPswdCrypt);
            if frm_Main.CloseSockets then
            if frm_Main.AddArraysrv(indexArr) then
             begin
             if not frm_Main.ApplySetConnectMain(EditSrvIp.Text,strtoint(EditSrvPort.Text),frm_Main.PswdServer,indexArr) then
             showmessage('Перезапустите приложение');
             end;
            except On E: Exception do
             begin
             WriteLog('app',2,'Ошибка переподключения к серверу ');
             end;
           end;
         end;
      end;



   exist:=false;
   form_set.Close;
 End;

procedure TForm_set.CheckCAClick(Sender: TObject);
begin
if CheckCA.Checked then EditMyPswd.Text:=RandomPassword(6);
end;

procedure TForm_set.EditFPSMouseLeave(Sender: TObject);
var
tmpfps:integer;
begin
tmpfps:=strtoint(EditFPS.Text);
if (tmpfps<5)or (tmpfps>60) then
  begin
   if (tmpfps<5) then EditFPS.Text:='5';
   if (tmpfps>60) then EditFPS.Text:='60';
  ShowMessage('Допустимы диапазон значений FPS от 5 до 60 кадр/сек.');
  end;
end;

procedure TForm_set.EditFPSRightButtonClick(Sender: TObject);
var
tmpfps:integer;
begin
tmpfps:=strtoint(EditFPS.Text);
if (tmpfps<5)or (tmpfps>60) then
  begin
   if (tmpfps<5) then EditFPS.Text:='5';
   if (tmpfps>60) then EditFPS.Text:='60';
  ShowMessage('Допустимы диапазон значений FPS от 5 до 60 кадр/сек.');
  end;

EditFPS.ReadOnly:=not EditFPS.ReadOnly;
if not EditFPS.ReadOnly then
begin
EditFPS.SetFocus;
EditFPS.SelectAll;
EditFPS.RightButton.ImageIndex:=1;
end
else
begin
EditFPS.RightButton.ImageIndex:=10;
end;
end;

procedure TForm_set.EditMyIDRightButtonClick(Sender: TObject);
begin
EditMyID.Text:=frm_Main.MyID;
WriteRegID(EditMyID.Text);
end;

function CheckPrefixServer(ID1,ID2:string):boolean; // сравнение 2х префиксов  ID. Одного в настройках, второго полученого с сервера
begin         //286-216-878
try
  if copy(ID1,1,6)=copy(ID2,1,6) then result:=true
  else result:=false;
except
result:=false;
end;
end;

procedure TForm_set.FormClose(Sender: TObject; var Action: TCloseAction);
begin
frm_Main.Reconnect_Timer.Enabled:=true;
end;

procedure TForm_set.FormCreate(Sender: TObject);
begin
EditSrvIp.BorderStyle:=bsNone;
EditSrvPort.BorderStyle:=bsNone;
EditSrvPswd.BorderStyle:=bsNone;
EditFPS.BorderStyle:=bsNone;;
EditMyID.BorderStyle:=bsNone;
EditMyPswd.BorderStyle:=bsNone;
end;

procedure TForm_set.FormShow(Sender: TObject);
var
readset,AcTmp:boolean;
port:integer;
srv,SrvPswd,IDtmp,PswdTmp,namepc:string;
begin
readset:=false;
ReadRegSet(port,FpsMaxCount,LevelLogError,srv,namepc,IDtmp,PswdTmp,SrvPswd,AcTmp,AutoRunApp,readset);
if not readset then ReadFileSet(srv,namepc,IDtmp,PswdTmp,SrvPswd,port,AcTmp,AutoRunApp,readset);
EditSrvIp.Text:=srv;
EditSrvPort.Text:=inttostr(port);
EditNamePC.Text:=NamePC;
EditSrvPswd.Text:=SrvPswd;
EditFps.Text:=inttostr(FpsMaxCount);
CheckCA.Checked:=AcTmp;
if AcTmp then  // если настроен неконтролируемый доступ
  begin
  EditMyID.Text:=frm_Main.MyID;//IDtmp;
  EditMyPswd.Text:=frm_Main.MyPassword;//PswdTmp;
  //EditMyID.RightButton.Enabled:=true; // кнопка приравнивания ID в настройках к полученному ID
  end
else
  begin
  EditMyID.Text:=frm_Main.MyID;
  EditMyPswd.Text:=frm_Main.MyPassword;
  //EditMyID.RightButton.Enabled:=false;
  end;

if AutoRunApp='Auto' then CheckAutoRun.Checked:=true
else CheckAutoRun.Checked:=false;

CheckImageAutoRun; //смена картинок в соответствии с чекбоксом
CheckImageAccessControl; //смена картинок в соответствии с чекбоксом
EditSrvIp.ReadOnly:=true; // запрет редактирования
EditSrvPort.ReadOnly:=true; // запрет редактирования
EditSrvPswd.ReadOnly:=true; // запрет редактирования
EditFps.ReadOnly:=true;
EditSrvPswd.RightButton.ImageIndex:=6;
EditSrvPort.RightButton.ImageIndex:=7;
EditSrvIp.RightButton.ImageIndex:=2;
EditFps.RightButton.ImageIndex:=10;
DefaultPosition;
end;

function Tform_set.GetNamePC:string;  // запрос имени ПК
var
i: DWORD;
p: PChar;
begin
  try  // имя ПК
  i:=255;
  GetMem(p, i);
  GetComputerName(p, i);
  result:=String(p);
  finally
  FreeMem(p);
  end;
end;

Procedure TForm_set.CheckImageAutoRun;
begin
if CheckAutoRun.Checked then
  begin
  ImageAutoRun.ImageIndex:=1;
  end
else
  begin
  ImageAutoRun.ImageIndex:=10;
  end;
end;

Procedure TForm_set.CheckImageAccessControl;
begin
if CheckCA.Checked then
  begin
   ImageCheckCA.ImageIndex:=1;
  end
else
  begin
  ImageCheckCA.ImageIndex:=10;
  end;
end;

procedure TForm_set.ImageAutoRunaClick(Sender: TObject);
begin
CheckAutoRun.Checked:=not CheckAutoRun.Checked;
CheckImageAutoRun;
end;
//CheckImageAutoRun; CheckImageAccessControl;
procedure TForm_set.ImageCheckCAqClick(Sender: TObject);
begin
CheckCA.Checked:=not CheckCA.Checked;
CheckImageAccessControl;
end;

procedure TForm_set.LLPrivilageLevelClick(Sender: TObject);
begin
ReadlevelPrivilage(FormPrivilage.LevelAutoRun,FormPrivilage.LevelRunManual);
FormSetLevelPrivelage.FormPrivilage.ShowModal;
end;

end.
