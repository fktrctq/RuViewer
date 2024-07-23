unit DataBase;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet,VCL.Forms, FireDAC.VCLUI.Script,
  FireDAC.Comp.UI, FireDAC.VCLUI.Wait;

type
  TDataModule2 = class(TDataModule)
    ConnectionDB: TFDConnection;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    FDTransaction1: TFDTransaction;
    FDQuery1: TFDQuery;
    FDTable1: TFDTable;
    FDGUIxScriptDialog1: TFDGUIxScriptDialog;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function AddItemDataBase(PCUID,ID,PSWD,NAMEPC,IPadr:string):boolean;
  end;

var
  DataModule2: TDataModule2;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure RegisterErrorLog(nameFile:string; MessageText: string); // запись логов
var f:TStringList;
i:integer;
begin
try
begin // запись в файл лог
try
  if not DirectoryExists(ExtractFilePath(Application.ExeName)+'log') then CreateDir(ExtractFilePath(Application.ExeName)+'log');
      f:=TStringList.Create;
      try
        if FileExists(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'+.log') then
          f.LoadFromFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
          f.Add(DateTimeToStr(Now)+chr(9)+MessageText);
         // f.Insert(0,DateTimeToStr(Now)+chr(9)+MessageText);
       // while f.Count>1000 do f.Delete(1);
        f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+nameFile+'.log');
      finally
        f.Destroy;
      end;
  except
    exit;
  end;
end;
except
    On E: Exception do
    begin
    exit;
    end;
  end;
end;

function TDataModule2.AddItemDataBase(PCUID,ID,PSWD,NAMEPC,IPadr:string):boolean;
var
i:integer;
TransactionWrite    : TFDTransaction;
FDQueryWrite        : TFDQuery;
begin

end;

procedure TDataModule2.DataModuleCreate(Sender: TObject);
begin
try
{CharacterSet=UTF8
User_Name=postgres
Password=tq6jg7
OidAsBlob=Yes
UnknownFormat=BYTEA
ApplicationName=AllBooks
MetaDefSchema=MySchema
ExtendedMetadata=True
Database=RVDB
Server=172.16.0.95
DriverID=PG}
{
FDPhysPgDriverLink1.VendorLib:=(ExtractFilePath(Application.ExeName))+'lib\libpq.dll';
ConnectionDB.Params.Clear;     ///чистим параметры
ConnectionDB.Params.database:='RVDB'; //имя
ConnectionDB.Params.Add('server=127.0.0.1');
ConnectionDB.Params.Add('port=5432');
ConnectionDB.Params.Add('CharacterSet=UTF8'); //WIN1251 - зависит от созданной БД
ConnectionDB.Params.add('ExtendedMetadata=false');
ConnectionDB.Params.add('OidAsBlob=Yes');
ConnectionDB.Params.add('UnknownFormat=BYTEA');
ConnectionDB.Params.add('ApplicationName=AllBooks');
ConnectionDB.Params.add('MetaDefSchema=MySchema');
ConnectionDB.Params.add('GUIDEndian=Big');
ConnectionDB.Params.DriverID:='PG';
ConnectionDB.Params.UserName:='postgres';
ConnectionDB.Params.Password:='tq6jg7';
ConnectionDB.Connected:=true;  // если автоподключение то не отображать диалог подклчения
ConnectionDB.LoginPrompt:= false;  /// отображение диалога user password
ConnectionDB.Connected:=true;
if ConnectionDB.Connected then RegisterErrorLog('DB','База данных подключена ');
 }

except
    On E: Exception do
    begin
      RegisterErrorLog('DB','Connection_DB '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

end.
