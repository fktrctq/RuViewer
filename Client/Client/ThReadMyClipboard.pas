unit ThReadMyClipboard;

interface
uses
  Winapi.Windows, Winapi.WinSock,ShellApi,  System.SysUtils, System.Classes,  VCL.Forms, System.Win.ScktComp, System.IOUtils,Vcl.Dialogs,
   uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants, uTPLb_Signatory, uTPLb_SimpleBlockCipher
   ,System.Hash,Osher;

 type
  ThreadCopyFileSClipboard = class(TThread) // поток для копирования файлов из буфера обмена
   Socket :TCustomWinSocket;
   IDConect:Byte;
   PathSave:string;
   PswrdCrypt:string[255];
   constructor Create(aSocket: TCustomWinSocket; aIDConect:byte;  aPathSave:string; aPswrdCrypt:string); overload;
   procedure Execute; override;
   function SendFileSocket(s:ansistring):boolean;
   Function ScanDirFull(Root: String; var List: TStringList):boolean;
   Function ScanDir(Root: String; var List: TStringList):boolean;
   Function ScanFiles(Root: String; var List: TStringList):boolean;
   function CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
   function GetSizeByte(bytes: Int64): string;  // расчет оъемов и перевод в байты, Кбайты, Мбайты
   function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
   function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
   function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
   function SendTgFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
   procedure ThClipBoardGetFiles(const Files: TStrings);
end;

 type
  ThreadSendClipboard = class(TThread) // поток для копирования данных из буфера обмена
   Socket :TCustomWinSocket;
   PswdCrypt:string[255];
   constructor Create(aSocket: TCustomWinSocket; aPswrdCrypt:string); overload;
   procedure Execute; override;
   function CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
   function SendFileSocket(s:ansistring):boolean;
   function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
   function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
   function DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
   function SendTgFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
   function ThSaveClipboardToStream(S: TStream; var FrmClpbrd:word):boolean;
   function ThSaveClipboardFormat(fmt: cardinal; writer: TWriter):boolean;
   function ThCopyStreamFromClipboard(fmt: Cardinal; S: TStream):boolean;
 end;

   function ExtFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean;


implementation
uses FfmProgress,Form_Main,MyClpbrd,Form_ShareFiles,SocketCrypt;


function Log_write(fname:string; NumError:integer; TextMessage:string):string;
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
    except on E : Exception do
    begin
    exit;
    end;
    end;
 end;

function ExtFunctionClipboard(Socket :TCustomWinSocket; IDConect:Byte; DirPath:string; PswdCryptClbrd:string):boolean; // функция запускается из формы управления для передачи буфера обмена
var
PswdCrypt:string[255];
begin
  try
  PswdCrypt:=PswdCryptClbrd;
       begin
        IF ExtClipBoardTheFiles then // если в буфере обмена файлы
           BEGIN
            if not frm_Main.Viewer then // если абонент и передаю буфер
             Begin
             ThreadCopyFileSClipboard.Create(Socket,IDConect,DirPath,PswdCrypt);
             End
             else // если я клиент передаю буфер подключенному абоненту
             Begin // запрос на укзание директории для сохранения
             frm_ShareFiles.Tag:=IDConect;
              if frm_ShareFiles.ShowModal=1 then // если указали директорию сохранения файла
              Begin
              ThreadCopyFileSClipboard.Create(Socket,IDConect,frm_ShareFiles.DirectoryToSaveFile,PswdCrypt);
              End;
             End;
           END
         ELSE //иначе там файлов нет, передаем что в буфере потоком
            BEGIN
            ThreadSendClipboard.Create(socket,PswdCrypt); // запуск потока передачи буфера обмена
            END;
       end;
   except on E : Exception do
    begin
    Log_Write('ExtFClipboard',2,'Общая ошибка работы с буфером обмена : '{+E.ClassName+': '+E.Message});
    end;
   end;

end;


function ThreadCopyFileSClipboard.GetSizeByte(bytes: Int64): string;  // расчет оъемов и перевод в байты, Кбайты, Мбайты
begin
try
  if bytes < 1024 then
    Result := IntToStr(bytes) + ' B'
  else if bytes < 1048576 then
    Result := FloatToStrF(bytes / 1024, ffFixed, 10, 1) + ' KB'
  else if bytes < 1073741824 then
    Result := FloatToStrF(bytes / 1048576, ffFixed, 10, 1) + ' MB'
  else if bytes > 1073741824 then
    Result := FloatToStrF(bytes / 1073741824, ffFixed, 10, 1) + ' GB';
except On E: Exception do
    begin
    result:='';
    end;
  end;
end;



constructor ThreadCopyFileSClipboard.Create(aSocket: TCustomWinSocket; aIDConect:byte;aPathSave:string; aPswrdCrypt:string);
begin
  inherited Create(False);
  Socket := aSocket;
  IDConect:=aIDConect;
  PathSave:=aPathSave;
  PswrdCrypt:=aPswrdCrypt;
  FreeOnTerminate := true;
end;


function ThreadCopyFileSClipboard.CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
var
f:TStringList;
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

Function ThreadCopyFileSClipboard.ScanDir(Root: String; var List: TStringList):boolean;  // получаем только список каталогов
var
  F: TSearchRec;
  h: THandle;
  i: Integer;
begin
try
    List.Clear;
    List.Add(Root);
    i := 0;
    while i < List.Count do begin
      Root := IncludeTrailingPathDelimiter(List[i]);
      h := FindFirst(Root + '*.*', faAnyFile, F);
      while h = 0 do begin
      if (F.Attr and faDirectory) = faDirectory then // если необходим только список каталогов
         begin
            if (F.Name <> '.') and (F.Name <> '..') then begin
               begin
               List.Add(Root + F.Name);
               //CLBLog_write('search',Root + F.Name);
               end;
            end;
          end;
        h := FindNext(F);
      end;
      FindClose(F);
      Inc(i);
    end;
  List.Delete(0); // удаляем 1-ю запись т.к. это та диреткория которую я передал
  result:=true;
  except On E: Exception do
    begin
    result:=false;
    CLBLog_write('ThClipboardFile',2,'ScanDir '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileSClipboard.ScanFiles(Root: String; var List: TStringList):boolean; // получаем только список файлов
var
  F: TSearchRec;
  h: THandle;
  i: Integer;
begin
  try
    List.Clear;
    List.Add(Root);
    i := 0;
    while i < List.Count do begin
      Root := IncludeTrailingPathDelimiter(List[i]);
      h := FindFirst(Root + '*.*', faAnyFile, F);
      while h = 0 do begin
       if (F.Attr and faAnyFile) = faAnyFile then // если необходим только список файлов
         begin
            if (F.Name <> '.') and (F.Name <> '..') then begin
               begin
               List.Add(Root + F.Name);
               //CLBLog_write('search',Root + F.Name);
               end;
            end;
          end;
        h := FindNext(F);
      end;
      FindClose(F);
      Inc(i);
    end;
  List.Delete(0); // удаляем 1-ю запись т.к. это та диреткория которую я передал
  result:=true;
  except On E: Exception do
    begin
    result:=false;
    CLBLog_write('ThClipboardFile',2,'ScanFiles '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileSClipboard.ScanDirFull(Root: String; var List: TStringList):boolean; // получаем полный список файлов и каталогов
var
  F: TSearchRec;
  h: THandle;
  i: Integer;
begin
  try
    List.Clear;
    List.Add(Root);
    i := 0;
    while i < List.Count do begin
      Root := IncludeTrailingPathDelimiter(List[i]);
      h := FindFirst(Root + '*.*', faAnyFile, F);
      while h = 0 do begin
         begin
            if (F.Name <> '.') and (F.Name <> '..') then begin
               begin
               List.Add(Root + F.Name);
               //CLBLog_write('search',Root + F.Name);
               end;
            end;
          end;
        h := FindNext(F);
      end;
      FindClose(F);
      Inc(i);
    end;
  List.Delete(0); // удаляем 1-ю запись т.к. это та диреткория которую я передал
  result:=true;
  except On E: Exception do
    begin
    result:=false;
    CLBLog_write('ThClipboardFile',2,'ScanDirFull '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

//------------------------------------------------------
function ThreadCopyFileSClipboard.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if Socket=nil then result:=false
else
begin
  if Socket.Connected then
   while Socket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do CLBLog_write('ThClipboardFile',2,'Ошибка отправки сокета (F) внешняя функция (F)  : '+E.ClassName+': '+E.Message);  end;
end;
//---------------------------------------------

function ThreadCopyFileSClipboard.SendTgFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswrdCrypt, CryptBuf); //шифруем перед отправкой
SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
result:=true;
  except On E: Exception do
    begin
    result:=false;
    s:='';
    CLBLog_write('ThClipboardFile',2,'ERROR  - Поток М Ошибка шифрования и отправки данных '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;


function ThreadCopyFileSClipboard.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
var
posStart,posEnd:integer;
bufTmp,BufS:string;
CryptTmp,DecryptTmp:string;
step:integer;
begin
  try
  bufTmp:='';
  BufS:=s;
  step:=0;
   while BufS<>'' do // в цикле чистим
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// начало зашифрованной стороки
      posEnd:=pos('<!!>',BufS); // конец зашифрованной стороки
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// копируем необходимую строку начиная с символа posStart+3 ровно posEnd-4 символов
      step:=4;
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //дешифровка скопированной строки
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// объединение расшифрованной строки
      step:=6;
      if (posStart=0)or (posEnd=0)  then
        begin
        step:=7;
        BufS:='';
        break;
        end
        else
        begin
        step:=8;
        delete(BufS,posStart,posEnd+3);
        end;
        step:=9;
     end;
     step:=10;
   result:=bufTmp;
  except On E: Exception do
    begin
    CLBLog_write('ThClipboardFile',2,'ERROR  - Поток М Ошибка дешифрации данных '+ E.ClassName+' / '+ E.Message);
     s:='';
    end;
  end;
end;

function ThreadCopyFileSClipboard.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

function ThreadCopyFileSClipboard.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:= false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.DecryptString(OutStr, inStr, EncodingCrypt);
    Result := true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;

except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;

procedure ThreadCopyFileSClipboard.Execute;
var
FileStream:TFilestream;
z,i:integer;
p:pointer;
nSend : Int64;
sBuf : Pointer;
sizeStream,Sendbit:int64;
slepengtime:integer;
Buffer,DeCryptBuf,SendPath:String;
TmpDirDirectory:string;// директория создания каталога
TmpFileDirectory:string; // директория сохранения файла
BadFile:boolean;
SearchFile:Tstringlist;  // для списка файлов/каталогов если копируют каталог
SendList:TstringList;
AddSearch,StopLoad:boolean;
ListError:TstringList;
ListFileFolder:Tstringlist;
Files : Array of String;
begin
try
CLBLog_write('ThClipboardFile',2,'Зашущен поток передачи файлов');

 ListError:=TstringList.Create;
 ListFileFolder:=Tstringlist.Create;
 ThClipBoardGetFiles(ListFileFolder);
try
if ListFileFolder.Count>0 then
 BEGIN
  FrmMyProgress.Tag:=1; // признак передачи файла через данный поток. Необхождимо чтобы file поток ожидал текущий
  FrmMyProgress.CancelLoadFile:=false; //признак разрешени передачи файла/ true - признак отмены загрузки
     if frm_Main.Viewer then //---------- если я клиент, т.е. я подключился
      begin
        Synchronize(
        procedure
        begin
        FrmMyProgress.Show;  // отображаем форму прогресс бара
        FrmMyProgress.Caption:='Формирование списка файлов';
        FrmMyProgress.Height:=90;
        end);
      end;
  try
    //----------------------------------------------------------------заполняем спискок файлами и каталогами если в списке на копирование есть катало
     SearchFile:=TstringList.Create;
     SendList:= TstringList.Create;
     SendPath:=''; // директория при наличии каталогов
     try // заполняем спискок файлами и каталогами если в списке на копирование есть каталог
      for I := 0 to ListFileFolder.count-1 do
        begin
        if (GetFileAttributes(pwideChar(ListFileFolder[i])) and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then // если в списке каталог
           begin //http://www.proghouse.ru/programming/126-ioutils#TDirectory_GetFiles
           //SearchFile.AddStrings(TDirectory.GetFileSystemEntries(ListFileFolder[i])); // список файлов и каталогов  в выбранном каталоге
           ScanDirFull(ListFileFolder[i],SearchFile); // список файлов и каталогов  в выбранном каталоге
           SendPath:=TDirectory.GetParent(ListFileFolder[i]); // определение родительского каталога текущего каталога ListFileFolder[i]
           for Z := 0 to SearchFile.Count-1 do
           SendList.Add(SearchFile[z]); //добавляем все найденные файлы и каталоги в список на отправку
           end;
        end;

      if SendList.Count>0 then // если список файлов и каталогов не пустой
       begin
        for I := 0 to SendList.Count-1 do
        begin
         ListFileFolder.Add(SendList[i]);  // добавляем его в общий список файлов и каталогов
        end;
       end;

     finally
     SearchFile.Free;
     SendList.Free;
     end;
  //-----------------------------------------------------------------------
    // ListError.Add(timetostr(now)+' Директория каталогов - '+SendPath+' Пришла директория для загрузки из функции - '+PathSave);

     if pos('\',SendPath)=length(SendPath) then delete(SendPath,length(SendPath),1);// если в конце строки источника '\' то удаляем его. может появится если копируем из корня диска . C:\

  for I := 0 to ListFileFolder.count-1 do
  if ListFileFolder[i]<>'' then
   if (GetFileAttributes(pwideChar(ListFileFolder[i])) and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then // если в списке каталог
    BEGIN
     if SendPath<>'' then // если сформированный патч не пустой
       begin
        TmpDirDirectory:=StringReplace(ListFileFolder[i],SendPath,PathSave,[rfIgnoreCase]); //формирование директории на основании корневого каталога Spath и FPatch где сохранять
       // CLBLog_write('ListFileFolder','Директория перед отправкой создания каталога '+TmpDirDirectory);
        //SendFileSocket('<|CREATEFOLDER|>'+TmpDirDirectory+'<|ENDDIR|>');  // отправляем где создать каталог
        SendTgFileCryptText('<|CREATEFOLDER|>'+TmpDirDirectory+'<|ENDDIR|>');  // отправляем где создать каталог
       end;
    END
    ELSE// иначе это файл, передаем его
    BEGIN
      try
       FileStream:=TFileStream.Create(ListFileFolder[i],fmOpenRead);
         try
         FileStream.Position:=0;
         sizeStream:=FileStream.Size;
            if frm_Main.Viewer then //---------- если я клиент  т.е. я подключился
             begin
               Synchronize(
               procedure
               begin
               FrmMyProgress.ProgressBar1.Max:= sizeStream;
               FrmMyProgress.ProgressBar1.Min:=0;
               FrmMyProgress.ProgressBar1.Position:=0;
               FrmMyProgress.Caption:='Копирование: '+ExtractFileName(ListFileFolder[i])+' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')';
               end);
             end;
         Sendbit:=0;
         z:=0;
         slepengtime:=0;
         BadFile:=false;
         StopLoad:=false;
         if sizeStream>0 then
             begin
               if Socket<>nil then
                 begin
                   if (Socket.Connected) then
                     begin // отправляем размер файла, имя, куда сохранить ExtractFileDir
                     if SendPath<>'' then TmpFileDirectory:=ExtractFilePath(StringReplace(ListFileFolder[i],SendPath,PathSave,[rfIgnoreCase])) // Определяем директорию для сохранения файлов на основании текущего пути Spath и куда сохранять FPatch
                     else TmpFileDirectory:=PathSave+'\'; // иначе каталогов для копирования не было и   SendPath пустой  а PathSave без последнего символа '\'
                    // CLBLog_write('ListFileFolder','Директория перед отправкой файла '+TmpFileDirectory);
                    // SendFileSocket('<|FILESTREAM|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                     SendTgFileCryptText('<|FILESTREAM|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                     while Socket.Connected do  // ожидание клиента к готовности к загрузке <|READYLOAD|>
                       BEGIN
                          if FrmMyProgress.CancelLoadFile then
                          begin
                          SendTgFileCryptText('<|STOPLOADFILES|>');
                          //ListError.Add(timetostr(now)+ ' Отправил  <|BADFILE|> - 1 '+ListFileFolder[i]);
                          StopLoad:=true; // ошибка передачи текущего файла
                          break; // если отменили загрузку выход из цикла
                          end;
                           Sleep(ProcessingSlack);
                           if Socket.ReceiveLength < 1 then
                           begin
                           slepengtime:=slepengtime+10;
                            if slepengtime>=20000 then // если больше то выйти из цикла ожидания ответа о загрузке файла
                             begin
                             ListError.Add(timetostr(now)+' Время ожидания подтверждения готовности загрузки  истекло: '+ListFileFolder[i]);
                             //SendFileSocket('<|BADFILE|>');
                             SendTgFileCryptText('<|BADFILE|>');
                             BadFile:=true; // ошибка передачи текущего файла
                             break;
                             end;
                           Continue;
                           end;

                         //Buffer:=Socket.ReceiveText;
                         DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в файловый сокет
                         Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                         if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                           begin
                           ListError.Add(timetostr(now)+' Запросили остановку копирования '+ListFileFolder[i]);
                           StopLoad:=true; // ошибка передачи текущего файла
                           break; // выходим из потока т.к. нас попросили остановить загузку
                           end;
                         if pos('<|READYLOAD|>',Buffer)>0 then break;   // клиент готов к загрузке файла
                       END;
                      slepengtime:=0;
                      if (StopLoad or BadFile) then break;  // если остановили передачу файлов или не дождались ответа от клиента

                      while (Sendbit < SizeStream) and (Socket.Connected) do //передача файла буфером
                       BEGIN
                         Sleep(ProcessingSlack);
                         if Socket.ReceiveLength > 1 then  // проверка на отмену передачи файла
                         begin
                           DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в файловый сокет
                           Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                           if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                           begin
                           ListError.Add(timetostr(now)+' Запросили остановку копирования '+ListFileFolder[i]);
                           StopLoad:=true; // ошибка передачи текущего файла
                           break; // выходим из потока т.к. нас попросили остановить загузку
                           end;
                         end;
                         if FrmMyProgress.CancelLoadFile then // если я передаю и нажал отмена передачи
                           begin
                           SendTgFileCryptText('<|STOPLOADFILES|>');
                           ListError.Add(timetostr(now)+ ' Остановить копирование '+ListFileFolder[i]);
                           StopLoad:=true; // ошибка передачи текущего файла
                           break; // если отменили загрузку
                           end;

                         GetMem(sBuf, SizeStream-Sendbit);
                         nSend := FileStream.Read(sBuf^, SizeStream-Sendbit); // читаем в буфер данные для отправки
                         if nSend > 0 then // если что то прочитали из потока то отправляем
                           begin
                           z:=Socket.SendBuf(sBuf^, nSend);
                           if z=-1 then // если ничего не отправили
                             begin
                             Sleep(10);
                             ListError.Add(timetostr(now)+' WSAGetLastError='+inttostr(WSAGetLastError));
                             ListError.Add(timetostr(now)+' nSend='+inttostr(nSend)+' отправили z='+inttostr(z)+' текущая позиция FileStream='+inttostr(FileStream.Position-nSend));
                              while  WSAGetLastError() = WSAEWOULDBLOCK do
                                begin
                                Sleep(10);
                                ListError.Add(timetostr(now)+' - WSAGetLastError() = WSAEWOULDBLOCK');
                                slepengtime:=slepengtime+10;
                                if slepengtime>=5000 then // если больше то выйти из цикла ожидания чтения файла
                                  begin
                                  ListError.Add(timetostr(now)+' Не возможно прочитать данные из файла');
                                  break;
                                  end;
                                end;
                             FileStream.Position:=FileStream.Position-nSend;
                             end
                           else  // если отправили сколько то данных
                             begin
                             Sendbit:=Sendbit+z;
                             FileStream.Position:=Sendbit;
                             if z<nSend then  // если отправлено меньше чем считано перед отправкой
                               begin
                               sleep(ProcessingSlack);
                               ListError.Add(timetostr(now)+' nSend='+inttostr(nSend)+' отправили z='+inttostr(z)+' текущая позиция FileStream='+inttostr(Sendbit));
                               end;
                              if frm_Main.Viewer then //-------- если я клиент
                               begin
                                Synchronize(
                                procedure
                                  begin
                                  FrmMyProgress.ProgressBar1.Position:=Sendbit;
                                  end);
                               end;
                             end;
                           end
                           else // nSend <= 0  если не смогли прочитать файл
                            begin
                            sleep(ProcessingSlack);
                            slepengtime:=slepengtime+5;
                            if slepengtime>=5000 then // если больше то выйти из цикла ожидания чтения файла
                              begin
                              ListError.Add(timetostr(now)+' Не возможно прочитать данные из файла');
                              break;
                              end;
                            end;
                         FreeMem(sBuf);
                         if Sendbit = SizeStream then break;
                        END; // окончание цикла отправки файла

                        if (Sendbit<SizeStream) then
                         begin
                         ListError.Add(timetostr(now)+' Ошибка отправки='+inttostr(WSAGetLastError));
                         //SendFileSocket('<|BADFILE|>');
                         SendTgFileCryptText('<|BADFILE|>');
                        // CLBLog_write('clpbrd','Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' Отправил  <|BADFILE|> - 4 '+ListFileFolder[i]);
                         BadFile:=true; // ошибка передачи текущего файла
                         end
                        else
                         begin
                         //SendFileSocket('<|ENDFILEFULL|>');
                         SendTgFileCryptText('<|ENDFILEFULL|>');
                         //ListError.Add(timetostr(now)+ ' Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' Отправил  <|ENDFILEFULL|>'+ListFileFolder[i]);
                         BadFile:=false; // без ошибки отправили файл
                         end;

                    end;
                 end;
            end;
         finally
         FileStream.Free;
         end;


       except on E : Exception do
         begin
         if Assigned(FileStream) then FileStream.Free;
         ListError.Add(timetostr(now)+' Ошибка передачи файла абоненту: '+ListFileFolder[i]+'  : '+E.ClassName+': '+E.Message);
         Synchronize( procedure
            begin
            FrmMyProgress.Height:=172;
            FrmMyProgress.MemoLog.Lines.Add('Ошибка копирования файла: '+ListFileFolder[i]+' : '+E.ClassName+': '+E.Message);
            FrmMyProgress.Caption:='Копирование: '+ExtractFileName(ListFileFolder[i])+' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')';
            end);
          if (Sendbit<SizeStream) then SendTgFileCryptText('<|BADFILE|>'+E.ClassName+': '+E.Message+'<|ENDBAD|>');// SendFileSocket('<|BADFILE|>'+E.ClassName+': '+E.Message+'<|ENDBAD|>');
         BadFile:=true; // ошибка передачи текущего файла
         end;
       end;

       if not BadFile then
       if (frm_Main.Viewer) then //-------- если я клиент
         begin
         Synchronize( procedure
          begin
          FrmMyProgress.Caption:='Завершение: '+ExtractFileName(ListFileFolder[i])+' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')';
          end);
         end;

       slepengtime:=0;
        WHILE  (Socket.Connected)do // ожидание ответа о приеме файла
          BEGIN
           if StopLoad then break; // если остановили передачу файлов
           if FrmMyProgress.CancelLoadFile then
             begin
             SendTgFileCryptText('<|STOPLOADFILES|>');
             StopLoad:=true; // ошибка передачи текущего файла
             break; // если отменили загрузку
             end;
           Sleep(ProcessingSlack);
           if Socket.ReceiveLength < 1 then
             begin
              slepengtime:=slepengtime+ProcessingSlack;
              if slepengtime>=60000 then // если больше то выйти из цикла ожидания ответа о загрузке файла
                 begin
                 ListError.Add(timetostr(now)+' Время ожидания подтверждения загрузки файла истекло: '+ListFileFolder[i]);
                 slepengtime:=0;
                 SendTgFileCryptText('<|BADFILE|>');
                 BadFile:=true; // Признак получения файла клиентом
                 break;
                 end;
              Continue;
             end;

           DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в главный сокет
           Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
           //
           if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
           begin
           ListError.Add(timetostr(now)+' Запросили остановку копирования файла: '+ListFileFolder[i]);
           StopLoad:=true; // ошибка передачи текущего файла
           break; // выходим из потока т.к. нас попросили остановить загузку
           end;

           if pos('<|DNLDCMPLT|>',Buffer)>0 then
             begin
              break;
             end;
           if pos('<|DNLDERROR|>',Buffer)>0 then // если ошибка копирования файла
              begin
              BadFile:=true;
              if frm_Main.Viewer then //-------- если я клиент
                 begin
                 Synchronize( procedure
                   begin
                   FrmMyProgress.Height:=172;
                   FrmMyProgress.MemoLog.Lines.Add('Абонент сообщил об ошибке копирования файла: '+ExtractFileName(ListFileFolder[i])+' -> '+TmpFileDirectory);
                   FrmMyProgress.Caption:='Ошибка: '+ExtractFileName(ListFileFolder[i])+' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')';
                   end);
                 end;
              Break;
              end;
           Delete(Buffer, 1,length(Buffer));
          END; // цикл получения ответа
     if StopLoad then break; // если остановили передачу файлов
    END; // цикл по списку передаваемых файлов

    FINALLY
    if FrmMyProgress.Visible then //-------- если я клиент
      begin
      Synchronize( procedure
         begin
         FrmMyProgress.Close;
         end);
      end
      else SendTgFileCryptText('<|ENDOFFILETRANSFER|>');//SendFileSocket('<|ENDOFFILETRANSFER|>'); // Признак окончания передачи всех файлов
    FrmMyProgress.Tag:=0;  //отменяем признак передачи файла через данный поток. Теперь file поток  может принимать и получать данные
    for I := 0 to ListError.Count-1 do  CLBLog_write('ThClipboard',2,ListError[i]);
    CLBLog_write('ThClipboardFile',2,'Копироваие файлов завершено Error='+inttostr(ListError.Count));
    END;

 END;
finally
ListError.Free;
ListFileFolder.Free;
end;

 except on E : Exception do
    begin
      if frm_Main.Viewer then //-------- если я клиент
         begin
         Synchronize( procedure
           begin
           FrmMyProgress.Close;
           end);
         end;
     if FrmMyProgress.Tag=1 then
      begin
      //SendFileSocket('<|ENDOFFILETRANSFER|>'); // Признак окончания передачи файлов
      SendTgFileCryptText('<|ENDOFFILETRANSFER|>'); // Признак окончания передачи файлов
      FrmMyProgress.Tag:=0; // снимаем признак работы данного потока, т.к. сокет используется 2 мя потоками
      end;
    CLBLog_write('ThClipboardFile',2,'ThreadCopyFile Ошибка передачи файлов: '+E.ClassName+': '+E.Message);
    end;
  end;
end;

//--------------------------------------------------------------------------------
 procedure ThreadCopyFileSClipboard.ThClipBoardGetFiles(const Files: TStrings); //Получение списка файлов
{
  Вы нажали Ctrl+C или Ctrl+X => послали данные в буфер обмена.
  Так вот эта функция возвращает список файлов/папок, которые посланы в буфер.
}
var
  FilePath: array [0 .. MAX_PATH] of Char;
  i, FileCount: Integer;
   h: THandle;
   WinHandle:HWND;
  OwnerClpb:HWND;
begin
 try
  Files.Clear;
  h:= 0;
  begin
    // OwnerClpb:=GetClipboardOwner; // определяем владельца буфера обмена
     //frm_main.Log_Write('Clipboard',2,'ExtClipBoardGetFiles: OwnerClpb='+inttostr(OwnerClpb));
     //WinHandle:=ExtShellWindow;
     //frm_main.Log_Write('Clipboard',2,'ExtClipBoardGetFiles: WinHandle='+inttostr(WinHandle));
   // Clipboard.Open;
     OpenClipboard({WinHandle}Application.Handle);
    try
     h := GetClipboardData(CF_HDROP);
      //h := Clipboard.GetAsHandle(CF_HDROP);
    finally
     // Clipboard.Close;
      CloseClipboard;
    end;
  end;
  if h = 0 then
    exit;
  FileCount := DragQueryFile(h, $FFFFFFFF, nil, 0);
  for i := 0 to FileCount - 1 do
  begin
    DragQueryFile(h, i, FilePath, SizeOf(FilePath));
    Files.Add(FilePath);
  end;
   except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtClipBoardGetFiles: Ошибка ClipBoardGetFiles: '+E.ClassName+': '+E.Message); end;
  end;
//----------------------------------------------------------------------------
//-------------Передача буфера обмена-----------------------------------------

function ThreadSendClipboard.CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
var
f:TStringList;
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
//----------------------------------------------------------------------------------
function ThreadSendClipboard.SendTgFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswdCrypt, CryptBuf); //шифруем перед отправкой
SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
result:=true;
  except On E: Exception do
    begin
    result:=false;
    s:='';
    CLBLog_write('ThSendClipboard',2,'ERROR  - Поток М Ошибка шифрования и отправки данных '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;
//-----------------------------------------------------------------------------------------
function ThreadSendClipboard.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
var
posStart,posEnd:integer;
bufTmp,BufS:string;
CryptTmp,DecryptTmp:string;
step:integer;
begin
  try
  bufTmp:='';
  BufS:=s;
  step:=0;
   while BufS<>'' do // в цикле чистим
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// начало зашифрованной стороки
      posEnd:=pos('<!!>',BufS); // конец зашифрованной стороки
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// копируем необходимую строку начиная с символа posStart+3 ровно posEnd-4 символов
      step:=4;
      Decryptstrs(CryptTmp,PswdCrypt,DecryptTmp); //дешифровка скопированной строки
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// объединение расшифрованной строки
      step:=6;
      if (posStart=0)or (posEnd=0)  then
        begin
        step:=7;
        BufS:='';
        break;
        end
        else
        begin
        step:=8;
        delete(BufS,posStart,posEnd+3);
        end;
        step:=9;
     end;
     step:=10;
   result:=bufTmp;
  except On E: Exception do
    begin
    CLBLog_write('ThSendClipboard',2,'ERROR  - Поток М Ошибка дешифрации данных '+ E.ClassName+' / '+ E.Message);
     s:='';
    end;
  end;
end;

//--------------------------------------------------------------------------------------
function ThreadSendClipboard.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:=false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.EncryptString(InStr, OutStr, EncodingCrypt);
    result:=true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;
except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;
///////////////////////////////////////////////////////////
function ThreadSendClipboard.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
var
FLibrary : TCryptographicLibrary;
FCodec : TCodec;
begin
try
  Result:= false;
  FLibrary := TCryptographicLibrary.Create(nil);
  FCodec := TCodec.Create(nil);
  try
    FCodec.CryptoLibrary := FLibrary;
    FCodec.StreamCipherId := MyStreamCipherId;
    FCodec.BlockCipherId := MyBlockCipherId;
    FCodec.ChainModeId := MyChainModeId;
    FCodec.Password := pswd;
    FCodec.DecryptString(OutStr, inStr, EncodingCrypt);
    Result := true;
  finally
  FreeAndNil(FCodec);
  FreeAndNil(FLibrary);
  end;

except on E : Exception do
  begin
  result:=false;
  OutStr:='';
  end;
end;
end;
//-------------------------------------------------------------------------
function ThreadSendClipboard.SendFileSocket(s:ansistring):boolean;
begin
try
result:=true;
if Socket=nil then result:=false
else
begin
  if Socket.Connected then
   while Socket.SendText(s)<0 do
   sleep(ProcessingSlack)
  else result:=false;
end;
except on E : Exception do CLBLog_write('ThSendClipboard',2,'Ошибка отправки сокета (F) внешняя функция (F)  : '+E.ClassName+': '+E.Message);  end;
end;
//---------------------------------------------

constructor ThreadSendClipboard.Create(aSocket: TCustomWinSocket; aPswrdCrypt:string);
begin
  inherited Create(False);
  Socket := aSocket;
  PswdCrypt:=aPswrdCrypt;
  FreeOnTerminate := true;
end;


procedure ThreadSendClipboard.Execute;
var
ClpbrdStream:TMemoryStream;
z,i:integer;
p:pointer;
nSend : Integer;
sBuf : Pointer;
sizeStream,Sendbit:integer;
slepengtime:integer;
FormatClpbrd:word;
h:THandle;
DeCryptBuf,Buffer:string;
function sendFileSocket(s:string):boolean;
begin
 try
 if Socket.Connected then
   begin
    while socket.SendText(s)<0 do sleep(2);
    result:=true;
   end;
  except On E: Exception do
   begin
   s:='';
   result:=false;
   Log_Write('ThSendClipboard',2,'ERROR  - Буфер обмена Поток F Ошибка отправки данных '{+ E.ClassName+' / '+ E.Message});
   end;
 end;
end;

  function SendFilesCryptText(s:string):Boolean; // отправка зашифрованного текста в files сокет
  var
  CryptBuf:string;
  begin
  try
  Encryptstrs(s,PswdCrypt, CryptBuf); //шифруем перед отправкой
  SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> каждый защифрованный фрагмент разделяем <!>, иначе на приеме может все объеденится и нихрена не расшифруешь
  result:=true;
    except On E: Exception do
      begin
      s:='';
      result:=false;
      Log_Write('ThSendClipboard',2,'ERROR  - Буфер обмена Поток F Ошибка шифрования данных '{+ E.ClassName+' / '+ E.Message});
      end;
    end;
  end;
begin
try
CLBLog_write('ThSendClipboard',2,'Зашущен поток отправки буфера обмена');
ClpbrdStream:=TMemoryStream.Create;
 try
 if ThSaveClipboardToStream(ClpbrdStream,FormatClpbrd) then  // если удачно извлекли буфер обмена
 if FormatClpbrd<>49171 then //если там не файлы
  begin
  ClpbrdStream.Position:=0;
  sizeStream:=ClpbrdStream.Size;
  Sendbit:=0;
  slepengtime:=0;
   if sizeStream>0 then
     begin
      if Socket<>nil then
       begin
        if (Socket.Connected) then
         begin
         SendFilesCryptText('<|CLIPBOARD|>'+inttostr(ClpbrdStream.Size)+'<|ENDCLPBRD|>');
         sleep(250);
          if frm_Main.Viewer then // Если я передаю абоненту буфер обмена
          Synchronize(
            procedure
            begin
             FrmMyProgress.Height:=90;
             FrmMyProgress.ProgressBar1.Max:=sizeStream;
             FrmMyProgress.ProgressBar1.Position:=0;
             FrmMyProgress.Caption:='Передача буфера обмена';
             FrmMyProgress.CancelLoadFile:=false;
             FrmMyProgress.Show;
            end);
          while Sendbit < SizeStream do
           begin
           GetMem(sBuf, SizeStream-Sendbit+1);
           nSend := ClpbrdStream.Read(sBuf^, SizeStream-Sendbit+1);
           if FrmMyProgress.CancelLoadFile then
            begin
            SendFilesCryptText('<|STOPLOADCLPBRD|>');
            break;  // выход из цикла если отменили передачу буфера
            end;
            if nSend > 0 then
             begin
             z:=Socket.SendBuf(sBuf^, nSend);
              if z=-1 then
               begin
               sleep(10);
               slepengtime:=slepengtime+10;
               if frm_Main.Viewer then // Если я передаю абоненту буфер обмена
                 Synchronize(
                  procedure
                   begin
                   FrmMyProgress.ProgressBar1.Position:=Sendbit;
                   FrmMyProgress.Caption:='Ожидание передачи буфера обмена';
                   end);
                if slepengtime>=10000 then
                 begin
                 FreeMem(sBuf);
                 break;
                 end;
               end
               else
               begin
               Sendbit:=Sendbit+z; //if z=-1
               if frm_Main.Viewer then // Если я передаю абоненту буфер обмена
                Synchronize(
                  procedure
                   begin
                   FrmMyProgress.ProgressBar1.Position:=Sendbit;
                   end);
               end;
               Sleep(2);
             end
              else // if nSend > 0
               begin
               FreeMem(sBuf);
               break;
               end;
           FreeMem(sBuf);
           if Socket.ReceiveLength>0 then
             begin
             DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в главный сокет
             Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
             if pos('<|STOPLOADCLPBRD|>',Buffer)>0 then //если попросили остановить передачу буфера
              begin
              break;
              end;
             end;

           end; // while
         end;
       end;
      //Log_Write('app','ClipboardStream size: '+inttostr(ClpbrdStream.Size)+ ' Отправлено (Sendbit) - '+inttostr(Sendbit));
     end;
   end;
  finally
  ClpbrdStream.Free;
  if frm_Main.Viewer then // Если я передаю абоненту буфер обмена
   Synchronize(
    procedure
     begin
     FrmMyProgress.ProgressBar1.Position:=0;
     FrmMyProgress.Caption:='';
     if FrmMyProgress.Visible then FrmMyProgress.Close;
     end);
  end;
CLBLog_write('ThSendClipboard',2,'Завершен поток отправки буфера обмена');
 except on E : Exception do
    begin
    SendTgFileCryptText('<|ERRORCLIPBOARD|>'+E.ClassName+': '+E.Message+'<|ENDERROR|>'); // Признак ошибки удаления файлов
    CLBLog_write('ThSendClipboard',2,'ThreadDeleteList Ошибка потока отправки буфера обмена: '+E.ClassName+': '+E.Message);
    end;
  end;
end;


function ThreadSendClipboard.ThSaveClipboardToStream(S: TStream; var FrmClpbrd:word):boolean;
 var
   writer: TWriter;
   exist:boolean;
   i: Integer;
   CBF: Cardinal;
   CBFList: TList;
   countCBF:integer;
   WinHandle:HWND;
   OwnerClpb:HWND;
 begin
 try
   Assert(Assigned(S));
   writer := TWriter.Create(S,255);
   result:=false;
   try
    // Clipboard.Open;
    // WinHandle:=ExtShellWindow;
    // CLBLog_write('Clipboard',2,'ExtSaveClipboardToStream: WinHandle='+inttostr(WinHandle));
    // OwnerClpb:=GetClipboardOwner; // определяем владельца буфера обмена
     //CLBLog_write('Clipboard',2,'ExtSaveClipboardToStream: OwnerClpb='+inttostr(OwnerClpb));

     if not OpenClipboard(Application.Handle) then //GetShellWindow     GetDesktopWindow
      CLBLog_write('ThSendClipboard',2,'ThSaveClipboardToStream: OpenClipboard=0 Error='+SysErrorMessage(GetLastError));

     countCBF:=CountClipboardFormats;
    // CLBLog_write('ThSendClipboard',2,'ThSaveClipboardToStream: CountClipboardFormats='+inttostr(countCBF));
     CBFList := TList.Create;
     try
       writer.WriteListBegin;
       CBF:=0;

       {repeat
       CBF:=EnumClipboardFormats(CBF);
       if CBF<>0 then CBFList.Add(pointer(CBF))
       else  CLBLog_write('Clipboard','EnumClipboardFormats=0 Error='+SysErrorMessage(GetLastError));
       until CBF = ERROR_SUCCESS;}

       while countCBF>0 do
        begin
        CBF:=EnumClipboardFormats(CBF);
        CBFList.Add(pointer(CBF));
        dec(countCBF);
       // CLBLog_write('ThSendClipboard',2,'ThSaveClipboardToStream: EnumClipboardFormats='+inttostr(CBF)+' Error='+SysErrorMessage(GetLastError));
        end;

       if CBFList.Count > 0 then
       begin
         for I := 0 to CBFList.Count-1 do
           begin
           exist:=ThSaveClipboardFormat(cardinal(CBFList[i]), writer);
           FrmClpbrd:=cardinal(CBFList[i]);
           //CLBLog_write('ThSendClipboard',2,'ThSaveClipboardToStream: FrmClpbrd: '+inttostr(FrmClpbrd)+' SaveClipboardFormat='+booltostr(exist));
           if exist then
             begin
             result:=exist;
             end;
           end;
       end;
       writer.WriteListEnd;
     finally
        CloseClipboard;
        CBFList.Free;
     end; { Finally }
   finally
     writer.Free;
   end; { Finally }
   if not result then
   begin
    CLBLog_write('ThSendClipboard',2,' ThSaveClipboardToStream not result: ');
    // CLBLog_write('Clipboard',SysErrorMessage(GetLastError));
   end;

 except on E : Exception do CLBLog_write('ThSendClipboard',2,'ThSaveClipboardToStream: Ошибка SaveClipboard: '+E.ClassName+': '+E.Message); end;
 end; { SaveClipboard }


 function ThreadSendClipboard.ThSaveClipboardFormat(fmt: cardinal; writer: TWriter):boolean;
 var
   fmtname: array[0..256] of Char;
   ms: TMemoryStream;
 begin
 try
   Assert(Assigned(writer));
   if GetClipboardFormatName(fmt, fmtname, Length(fmtname))=0 then
   begin
    // CLBLog_write('ThSendClipboard',2,'ThSaveClipboardFormat: fmtname='+fmtname+' / GetClipboardFormatName: '+SysErrorMessage(GetLastError()));
     //fmtname[0] := #0;
   end;
   ms := TMemoryStream.Create;
  // CLBLog_write('ThSendClipboard',2,'ThSaveClipboardFormat: fmtname='+fmtname);
   try
     result:=ThCopyStreamFromClipboard(fmt, ms);
     if ms.Size > 0 then
     begin
       writer.WriteInteger(fmt);
       writer.WriteString(fmtname);
       writer.WriteInteger(ms.Size);
       writer.Write(ms.Memory^, ms.Size);
       result:=true;
     end; // else result:=false;
   finally
     ms.Free
   end; { Finally }
   if not result then CLBLog_write('ThSendClipboard',2,'ThSaveClipboardFormat: not result: ');
  except on E : Exception do
      begin
      result:=false;
      CLBLog_write('ThSendClipboard',2,'ThSaveClipboardFormat: Ошибка ClipboardFormat: '+E.ClassName+': '+E.Message);
      end;
    end;
 end; { SaveClipboardFormat }


 function ThreadSendClipboard.ThCopyStreamFromClipboard(fmt: Cardinal; S: TStream):boolean;
 var
   hMem: THandle;
   pMem: Pointer;
 begin
  try
   hMem := GetClipboardData(fmt);
    if hMem <> 0 then
     begin
       pMem := GlobalLock(hMem);
        try
         if pMem <> nil then
         begin
          Assert(Assigned(S));
          S.Write(pMem^, GlobalSize(hMem));
          S.Position := 0;
          result:=true;
          end { If }
         else
         begin
          result:=false;
          CLBLog_write('ThSendClipboard',2,'ThCopyStreamFromClipboard: Ошибка GlobalLock: '+SysErrorMessage(GetLastError()));
         //  raise Exception.Create('CopyStreamFromClipboard: could not lock global handle ' +
         //    'obtained from clipboard!');
         end;
       finally
       GlobalUnlock(hMem);
       end;
     end
    else { If }
     begin
      result:=false;
      CLBLog_write('ThSendClipboard',2,'ThCopyStreamFromClipboard: Ошибка GetClipboardData=0 fmt='+inttostr(fmt)+' Error='+SysErrorMessage(GetLastError()));
     end;
  except on E : Exception do
    begin
    result:=false;
    CLBLog_write('ThSendClipboard',2,'ThCopyStreamFromClipboard: Ошибка CopyStreamFromClipboard: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { CopyStreamFromClipboard }

end.
