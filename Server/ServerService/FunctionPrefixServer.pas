unit FunctionPrefixServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,VCL.Forms,
    Variants,  ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp,inifiles,DateUtils;

function GeneratePrefixServr(oldPrefix,MyIP:string):String;// prefix сервера длинной 5 символов, 4 символа на префикс клиента
Function AddPrefixMySrv(InsertPrfx:boolean;SrvIP,SrvPswd,SrvPrfx:string;SrvPort:integer):boolean;// добавить в массив префиксов запись о себе
function AddArrayPrefix(var NextClient:integer):boolean; // добавление пустой записи в массив префиксов
function CorrectPrefix(prefix,SrvIp:string; var outPrefix:string):boolean;  // функция проверки корректности префикса
implementation
uses MainModule;

function CorrectPrefix( prefix,SrvIp:string; var outPrefix:string):boolean;  // функция проверки корректности префикса
var           //375-84
i,z:integer;
strTmp:string;
correct:boolean;
begin
try
correct:=true;
strTmp:=StringReplace(prefix, ' ', '',[rfReplaceAll, rfIgnoreCase]);
if length(strTmp)<>6 then
begin
correct:=false;
end
else
for I := 1 to length(strTmp) do
Begin
if i=4 then
  begin
  if strTmp[i]<>'-' then
   begin
    correct:=false;
    break;
   end;
  end
  else
 begin
 if not trystrtoint(strTmp[i],z) then
   begin
   correct:=false;
   break;
   end;
 end;
End;
if correct then outPrefix:=strTmp
else
begin
outPrefix:=GeneratePrefixServr('',SrvIp);
correct:=true;
end;
result:=correct;
except
 On E: Exception do
 begin
  result:=false;
  RuViewerSrvService.RegisterErrorLog('Service',2,'Ошибка проверки корректности префикса ');
 end;
end;
end;

function GeneratePrefixServr(oldPrefix,MyIP:string):String;// prefix сервера длинной 5 символов, 4 символа на префикс клиента
var
i:integer;
Prfx:string;
Exist:boolean;
begin //
try
Exist:=true;
if oldPrefix<>'' then // если передали ставрый префикc , то проверяем есть ли такой в списке
begin
if Length(ArrayPrefixSrv)=0 then
begin
 Exist:=false;
 Prfx:=oldPrefix;
end
 else
 for I := 0 to Length(ArrayPrefixSrv)-1 do
    begin
     if (ArrayPrefixSrv[i].SrvPrefix=oldPrefix) and (ArrayPrefixSrv[i].SrvIp<>MyIP) then
      begin
        Exist:=true;
        break;
      end
      else Exist:=false;
    end;
if not Exist then Prfx:=oldPrefix;
end;

while Exist do // соответственно если в предыдущем цикле нашли префикс то генерируем новый
  BEGIN
 Randomize;
 Prfx := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9));
 if Length(ArrayPrefixSrv)=0 then break;
    for I := 0 to Length(ArrayPrefixSrv)-1 do
      begin
       if (ArrayPrefixSrv[i].SrvPrefix=Prfx) then // проверка на совпадение
        begin
          Exist:=true;
          break;
        end
        else Exist:=false;
      end;
  END;

result:=Prfx;
except
 On E: Exception do RuViewerSrvService.RegisterErrorLog('Service',2,'Ошибка GeneratePrefixServr ');
end;
end;



Function AddPrefixMySrv(InsertPrfx:boolean;SrvIP,SrvPswd,SrvPrfx:string;SrvPort:integer):boolean;// добавить в массив префиксов запись о себе
var
i:integer;
exist:boolean;
Begin
try
if InsertPrfx then
begin
if length(ArrayPrefixSrv)=0 then // вставка только если массив пустой
 Begin
 AddArrayPrefix(i);
 ArrayPrefixSrv[i].SrvIp:=SrvIP;
 ArrayPrefixSrv[i].SrvPswd:=SrvPswd;
 ArrayPrefixSrv[i].SrvPort:=SrvPort;
 ArrayPrefixSrv[i].SrvPrefix:=SrvPrfx;
 ArrayPrefixSrv[i].DateCreate:=DateTimetostr(TTimeZone.local.ToUniversalTime(now));
 result:=true;
 end
 else
 begin
  for I := 0 to length(ArrayPrefixSrv)-1 do
   begin
     if ArrayPrefixSrv[i].SrvIp=SrvIP then
      begin
      ArrayPrefixSrv[i].SrvPswd:=SrvPswd;
      ArrayPrefixSrv[i].SrvPort:=SrvPort;
      ArrayPrefixSrv[i].SrvPrefix:=SrvPrfx;
      ArrayPrefixSrv[i].DateCreate:=DateTimetostr(TTimeZone.local.ToUniversalTime(now));
      result:=true;
      break;
      end;
   end;
 end;
End;

if not InsertPrfx then
Begin
 exist:=false;
 for I := 0 to length(ArrayPrefixSrv)-1 do
  begin
   if ArrayPrefixSrv[i].SrvIp=SrvIP then
    begin
     ArrayPrefixSrv[i].SrvPrefix:=SrvPrfx;
     ArrayPrefixSrv[i].SrvPort:=SrvPort;
     ArrayPrefixSrv[i].SrvPswd:=SrvPswd;
     ArrayPrefixSrv[i].DateCreate:=DateTimetostr(TTimeZone.local.ToUniversalTime(now));
     exist:=true;
     result:=true;
     break;
    end;
  end;
 if not exist then
  begin
   AddArrayPrefix(i);
   ArrayPrefixSrv[i].SrvIp:=SrvIP;
   ArrayPrefixSrv[i].SrvPswd:=SrvPswd;
   ArrayPrefixSrv[i].SrvPort:=SrvPort;
   ArrayPrefixSrv[i].SrvPrefix:=SrvPrfx;
   ArrayPrefixSrv[i].DateCreate:=DateTimetostr(TTimeZone.local.ToUniversalTime(now));
   result:=true;
  end;
End;
except on E : Exception do RuViewerSrvService.RegisterErrorLog('Service',2,'AddPrefixMySrv  : ');  end;
End;
//-----------------------------------------------------

function AddArrayPrefix(var NextClient:integer):boolean; // добавление пустой записи в массив префиксов
var
i:integer;
exist:boolean;
begin
try
exist:=false;
setLength(ArrayPrefixSrv,Length(ArrayPrefixSrv)+1);
CurentIndexPrefix:=Length(ArrayPrefixSrv)-1;
NextClient:=CurentIndexPrefix;
exist:=true;
result:= exist;
except
 On E: Exception do RuViewerSrvService.RegisterErrorLog('Service',2,'Ошибка AddArrayPrefix');
end;
end;
//---------------------------------------------------

end.
