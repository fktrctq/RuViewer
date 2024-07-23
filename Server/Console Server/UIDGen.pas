unit UIDGen;


interface

uses  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,Registry,math,WinSock,ActiveX,ComObj,
  IdBaseComponent, IdComponent, IdRawBase, IdRawClient, IdIcmpClient;

    function gandon3(r:widestring):string;    ////декодируем
    //function readdate(s:string):boolean;
    function gandon(v,g:widestring):string;
    function monterboardsn(s:string):string;
    function biossn(s:string):string;
    function generateUID():String;

implementation
var
  FSWbemLocator       : OLEVariant;
  FWMIService         : OLEVariant;
  nstring:string;
  RootPatch: HKEY;
 Const
wbemFlagForwardOnly = $00000020;
function SendARP(DestIp: DWORD; srcIP: DWORD; pMacAddr: pointer; PhyAddrLen: Pointer): DWORD;stdcall; external 'iphlpapi.dll';

function Log_write(fname, text:string):string;
var f:TStringList;
begin
try
  //if not DirectoryExists(ExtractFilePath(Application.ExeName)+'logs') then
  // CreateDir(ExtractFilePath(Application.ExeName)+'logs');
  f:=TStringList.Create;
  try
    if FileExists(ExtractFilePath(Application.ExeName)+fname+'.log') then
      f.LoadFromFile(ExtractFilePath(Application.ExeName)+fname+'.log');
    f.Insert(0,DateTimeToStr(Now)+chr(9)+text);
    while f.Count>1000 do f.Delete(1000);
    f.SaveToFile(ExtractFilePath(Application.ExeName)+fname+'.log');
  finally
    f.Destroy;
  end;
except on E : Exception do
begin
exit;
//showmessage('Ошибка записи в лог файл');
end;
  end;
end;





function MySendARP(const MyIPAddress: String): String;
var
  DestIP: ULONG;
  MacAddr: Array [0..5] of Byte;
  MacAddrLen: ULONG;
  SendArpResult: Cardinal;
begin
  DestIP := inet_addr(PAnsiChar(AnsiString(MyIPAddress)));
  MacAddrLen := Length(MacAddr);
  SendArpResult := SendARP(DestIP, 0, @MacAddr, @MacAddrLen);
  if SendArpResult = NO_ERROR then
    Result := Format('%2.2X-%2.2X-%2.2X-%2.2X-%2.2X-%2.2X',
                     [MacAddr[0], MacAddr[1], MacAddr[2],
                      MacAddr[3], MacAddr[4], MacAddr[5]])
  else
    Result := '';
end;

function ossn(s:string):string;
var
oEnum               : IEnumvariant;
iValue              : LongWord;
FWbemObjectSet      : OLEVariant;
FWbemObject         : OLEVariant;
begin
try
FWbemObjectSet:= FWMIService.ExecQuery('SELECT SerialNumber '
+' FROM Win32_OperatingSystem','WQL',wbemFlagForwardOnly);
oEnum:= IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do     //// Операционная система
    begin
      try
      if FWbemObject.SerialNumber<>null then result:=trim(string(FWbemObject.SerialNumber));
      except
      result:=MySendARP('127.0.0.1');
      end;
      FWbemObject:=Unassigned;
    end;
 Except
  on E:Exception do
     begin
     result:='unknown';
     VariantClear(FWbemObject);
     oEnum:=nil;
     VariantClear(FWbemObjectSet)
     end;
   end;
   VariantClear(FWbemObject);
   oEnum:=nil;
   VariantClear(FWbemObjectSet);
end;
/////////////////////////////////////////////////////////////////////
function biossn(s:string):string; /// получение данных о материнской плате
var
i:integer;
sn:string;
res:bool;
oEnumSNM               : IEnumvariant;
iValueSNM              : LongWord;
FWbemObjectSetSNM      : OLEVariant;
FWbemObjectSNM         : OLEVariant;
begin
try
      FWbemObjectSetSNM:= FWMIService.ExecQuery('SELECT SerialNumber FROM Win32_BIOS','WQL',wbemFlagForwardOnly);
       oEnumSNM:= IUnknown(FWbemObjectSetSNM._NewEnum) as IEnumVariant;
         while oEnumSNM.Next(1, FWbemObjectSNM, iValueSNM) = 0 do
            begin
              try
              if FWbemObjectSNM.SerialNumber<>null then
               sn:=trim(string(FWbemObjectSNM.SerialNumber));
              except
               sn:=MySendARP('127.0.0.1');
              end;
          FWbemObjectSNM:=Unassigned;
            end;
         VariantClear(FWbemObjectSNM);
         oEnumSNM:=nil;
         VariantClear(FWbemObjectSetSNM);
        result:=sn;
     except
      on E:Exception do
        begin
        Log_write('UID',datetostr(date)+'/'+timetostr(time)+'/'+s+' - Ошибка Md-'+e.Message);
         VariantClear(FWbemObjectSNM);
         oEnumSNM:=nil;
         VariantClear(FWbemObjectSetSNM);
        end;
      end;
end;
//////////////////////////////////////////////////////////////////////
function monterboardsn(s:string):string; /// получение данных о материнской плате
var
i:integer;
sn:string;
res:bool;
oEnumSNM               : IEnumvariant;
iValueSNM              : LongWord;
FWbemObjectSetSNM      : OLEVariant;
FWbemObjectSNM         : OLEVariant;
begin
try
      FWbemObjectSetSNM:= FWMIService.ExecQuery('SELECT SerialNumber FROM Win32_BaseBoard','WQL',wbemFlagForwardOnly);
       oEnumSNM:= IUnknown(FWbemObjectSetSNM._NewEnum) as IEnumVariant;
         while oEnumSNM.Next(1, FWbemObjectSNM, iValueSNM) = 0 do
            begin
              try
              if FWbemObjectSNM.SerialNumber<>null then
               sn:=trim(string(FWbemObjectSNM.SerialNumber));
              except
               sn:=MySendARP('127.0.0.1');
              end;
          FWbemObjectSNM:=Unassigned;
            end;
         VariantClear(FWbemObjectSNM);
         oEnumSNM:=nil;
         VariantClear(FWbemObjectSetSNM);
        result:=sn;
     except
      on E:Exception do
        begin
        Log_write('UID',datetostr(date)+'/'+timetostr(time)+'/'+s+' - Ошибка Md-'+e.Message);
         VariantClear(FWbemObjectSNM);
         oEnumSNM:=nil;
         VariantClear(FWbemObjectSetSNM);
        end;
      end;
end;
////////////////////////////////////////////////////////////
function snhddPhisical(idHdd:string):string; ///// функция извлечения serial number
var
FWbemObjectSetsn  : OLEVariant;
oEnumsn           : IEnumvariant;
FWbemObjectsn     : OLEVariant;
iValuesn          : LongWord;
begin
try
idHdd:=copy(idHdd,5,length(idHdd));
Result := '';
FWbemObjectSetsn:= FWMIService.ExecQuery
('SELECT * FROM Win32_PhysicalMedia WHERE Tag LIKE "%'+idHdd+'%"', 'WQL',wbemFlagForwardOnly);
oEnumsn:= IUnknown(FWbemObjectSetsn._NewEnum) as IEnumVariant;
while oEnumsn.Next(1, FWbemObjectsn, iValueSN) = 0 do
  begin
  if FWbemObjectsn.SerialNumber<>null then result:=trim(vartostr(FWbemObjectsn.SerialNumber));
   FWbemObjectsn:=Unassigned;
  end;
oEnumsn:=nil;
VariantClear(FWbemObjectsn);
VariantClear(FWbemObjectSetsn);
except
on e:Exception do
begin
Log_write('UID',datetostr(date)+'/'+timetostr(time)+'/ - ошибка DSN - '+e.Message);
end;
end;
end;
/////////////////////////////////////////////////////////////////////////////////////////////////
function Sjesk(s:string):string;
var
hddsn:string;
oEnum               : IEnumvariant;
iValue              : LongWord;
FWbemObjectSet      : OLEVariant;
FWbemObject         : OLEVariant;
begin
try
      FWbemObjectSet:= FWMIService.ExecQuery('SELECT * From Win32_DiskDrive WHERE MediaType=''Fixed hard disk media''','WQL',wbemFlagForwardOnly);
       oEnum:= IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
         while oEnum.Next(1, FWbemObject, iValue) = 0 do     //// HDD
            begin
            if FWbemObject.DeviceID<>null then
              begin
              hddsn:=hddsn+snhddPhisical(vartostr(FWbemObject.DeviceID))+'++';
              FWbemObject:=Unassigned;
              if Length(hddsn)>=10 then break;
              end;
            end;
       result:=hddsn;
  Except
  on E:Exception do
    begin
    Log_write('UID',datetostr(date)+'/'+timetostr(time)+'/'+s+' - Ошибка DD - '+e.Message);
    VariantClear(FWbemObject);
    oEnum:=nil;
    VariantClear(FWbemObjectSet);
    end;
   end;
   oEnum:=nil;
   VariantClear(FWbemObject);
   VariantClear(FWbemObjectSet);
end;
////////////////////////////////////////////////////////////////////////////////// DaysBetween Возвращает количество полных дней из промежутка времени, заданного двумя значениями TDateTime.
procedure Code(var text: WideString; password: widestring;
decode: boolean);
var
i, PasswordLength: integer;
sign: shortint;
begin
PasswordLength := length(password);
if PasswordLength = 0 then Exit;
if decode then sign := -1
else sign := 1;
for i := 1 to Length(text) do
text[i] := chr(ord(text[i]) + sign *
ord(password[i mod PasswordLength + 1]));
end;

function Crypt(varStr: WideString):WideString;
var
 k: integer;
 s: WideString;
begin
   RandSeed:=100;
   s:=varStr;
   for k:=1 to Length(s) do
    s[k]:=Chr(ord(s[k]) xor (Random(127)+1));
 Crypt:=s;
end;
/////////////////////////////////////////////////////////////



function gandon(v,g:widestring):string; //// формируем код активации
var
i,z:integer;
a,b:widestring;
s,y,u,x:string;
begin
try
a:=v;
b:=g;
s:='';
a:=trim(a);
b:=trim(b);
if Length(a)>Length(b) then
  begin
  z:=Length(a);
  for I := Length(b) to z do b:=b+'+';
  end
else
  begin
  z:=Length(b);
  for I := Length(a) to z-1 do  a:=a+'*';
  end;

for I := 1 to z do
  begin
  s:=s+inttostr((ord(a[i]))+i)+inttostr((ord(b[i]))+i);
  x:=x+inttostr((((ord(a[i]))+i))and((ord(b[i]))-i));
  end;

 y:='';
 u:='';
for I := 1 to Length(x) do
  begin
  if x[i] in ['0','1','2','3','4','5','6','7','8','9'] then
    begin
      if (i mod 2)=0 then y:=y+X[i]
      else u:=u+X[i];
    end;
  end;
if Length(y)>Length(u) then z:=Length(u)
else z:=Length(y);
a:='';
for I := 1 to z do
  begin
  a:=a+inttostr((strtoint(y[i])+i and strtoint(u[i])-i))
  end;
 result:=a;
     except
      on E:Exception do
        begin
         result:=x+'7458912354844';
         Log_write('UID',datetostr(date)+'/'+timetostr(time)+'/ - ошибка формирования кода '+e.Message);
        end;
      end;

 end;


function gandon2 (v,q:widestring):string;  /// генерация ID
var
i,z:integer;
a,b:widestring;
s,y,x:string;
begin
a:=(v);
b:=q;
s:='';
a:=trim(a);
b:=trim(b);
if Length(a)>Length(b) then
  begin
  z:=Length(a);
  for I := Length(b) to z do b:=b+'+';
  end
else
  begin
  z:=Length(b);
  for I := Length(a) to z-1 do  a:=a+'*';
  end;

for I := 1 to z do
  begin
  s:=s+inttostr((ord(a[i]))+i)+inttostr((ord(b[i]))+i);
  x:=x+inttostr(Length(inttostr(ord(a[i]))))+inttostr(Length(inttostr(ord(b[i]))))
  end;
 y:=inttostr(z);
 result:=s+inttostr(z)+inttostr(Length(y));
end;



function gandon3(r:widestring):string;    ////декодируем
var
i,z,n,l,p:integer;
a,b:widestring;
s:widestring;
y:widestring;
begin
try
s:=r;
n:=strtoint(copy(s,length(s),1));
z:=(strtoint(copy(s,length(s)-n,n)));
l:= (length(s) div 2) div z;
s:=copy(s,1,length(s)-1-length(inttostr(z)));
for I := 1 to z do
begin
a:=a+chr((strtoint(copy(s,1,2)))-i);
delete(s,1,2);
b:=b+chr((strtoint(copy(s,1,2)))-i);
delete(s,1,2);
end;

y:=a;
code(y,b,true);
b:=Crypt(b);
result:=gandon(y,b);   ///// получаем код активации
except
      on E:Exception do
        begin
         Log_write('UID','Ошибка '+ e.Message);
        end;
      end;
end;

function findsimvolS3(s:string):string;
begin
if (s='') or (pos('123456789',s)<>0)
 or ((pos(Ansiuppercase('string'),Ansiuppercase(s))<>0)
 or (pos(Ansiuppercase('Default'),Ansiuppercase(s))<>0)
 or (pos(Ansiuppercase('O.E.M'),Ansiuppercase(s))<>0)
 or (pos(Ansiuppercase('System'),Ansiuppercase(s))<>0)
 or (pos(Ansiuppercase('Number'),Ansiuppercase(s))<>0)
 or (pos(Ansiuppercase('Manuf'),Ansiuppercase(s))<>0)
 ) then result:='9512364857592'
 else result:=s;
 end;

function generateUID():String;
var
s1,s2,s3:string;
begin
 OleInitialize(nil);

  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('127.0.0.1', 'root\CIMV2','',''); ///WbemUser, WbemPassword
  s1:=monterboardsn('127.0.0.1');
  s2:=Sjesk('127.0.0.1');
  s3:=biossn('127.0.0.1');

  s3:=findsimvolS3(s3);
  if (s3='9512364857592')and(s1=findsimvolS3(s1)) then s3:=s1;
  if s1<>findsimvolS3(s1) then s1:=s3;
  if length(s1)>20 then s1:=Copy(s1,1,20);
  if (Length(s2)>20) then s2:=Copy(s2,1,20);
  if (s2='') and (s1<>'') then s2:=s1;
  if (s2='') or (Length(s2)<=5) then  s2:=s3;
  if (s2='') or (Length(s2)<=5) then  s2:=ossn('127.0.0.1');
  if length(s2)>20 then s2:=Copy(s2,1,20);
  if length(s3)>20 then s3:=Copy(s3,1,20);
  if s2='' then s2:='12365489523158';
  if s3='' then s3:='85296374145615';
  result:=(gandon2(Ansiuppercase(s2),Ansiuppercase(s3)));
end;



end.

