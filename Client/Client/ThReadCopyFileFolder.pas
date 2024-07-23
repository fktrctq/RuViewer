unit ThReadCopyFileFolder;

interface
uses
  Winapi.Windows, Winapi.WinSock,  System.SysUtils, System.Classes,  VCL.Forms, System.Win.ScktComp, System.IOUtils,Vcl.Dialogs,
   uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants, uTPLb_Signatory, uTPLb_SimpleBlockCipher
   ,System.Hash,Osher;

  type
  ThreadCopyFileS = class(TThread) // поток для копирования файлов
   Socket :TCustomWinSocket;
   IDConect:Byte;
   ListFileFolder:Tstringlist;
   PathSave:string;
   PswrdCrypt:string[255];
   constructor Create(aSocket: TCustomWinSocket; aIDConect:byte; TempListFile:TstringList; aPathSave:string; aPswrdCrypt:string); overload;
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
   function SendFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
end;


implementation
uses Form_Main,SocketCrypt,FileTransfer;


function ThreadCopyFileS.GetSizeByte(bytes: Int64): string;  // расчет оъемов и перевод в байты, Кбайты, Мбайты
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



constructor ThreadCopyFileS.Create(aSocket: TCustomWinSocket; aIDConect:byte; TempListFile:TstringList; aPathSave:string; aPswrdCrypt:string);
begin
  inherited Create(False);
  Socket := aSocket;
  IDConect:=aIDConect;
  PathSave:=aPathSave;
  PswrdCrypt:=aPswrdCrypt;
  ListFileFolder:=Tstringlist.Create;
  ListFileFolder.CommaText:=TempListFile.CommaText;
  FreeOnTerminate := true;
end;


function ThreadCopyFileS.CLBLog_write(fname:string; NumError:integer; TextMessage:string):boolean;
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

Function ThreadCopyFileS.ScanDir(Root: String; var List: TStringList):boolean;  // получаем только список каталогов
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
    CLBLog_write('ThCopyFileS',2,'ScanDir '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileS.ScanFiles(Root: String; var List: TStringList):boolean; // получаем только список файлов
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
    CLBLog_write('ThCopyFileS',2,'ScanFiles '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileS.ScanDirFull(Root: String; var List: TStringList):boolean; // получаем полный список файлов и каталогов
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
    CLBLog_write('ThCopyFileS',2,'ScanDirFull '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

//------------------------------------------------------
function ThreadCopyFileS.SendFileSocket(s:ansistring):boolean;
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
except on E : Exception do CLBLog_write('ThCopyFileS',2,'Ошибка отправки сокета (F) внешняя функция (F)  : '+E.ClassName+': '+E.Message);  end;
end;
//---------------------------------------------

function ThreadCopyFileS.SendFileCryptText(s:string):Boolean; // отправка зашифрованного текста в main сокет
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
    CLBLog_write('ThCopyFileS',2,'ERROR  - Поток М Ошибка шифрования и отправки данных '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;


function ThreadCopyFileS.DecryptReciveText(s:string):string; // функция расщифровки полученого текста из сокета
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
    CLBLog_write('ThCopyFileS',2,'ERROR  - Поток М Ошибка дешифрации данных '+ E.ClassName+' / '+ E.Message);
     s:='';
    end;
  end;
end;

function ThreadCopyFileS.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // Шифрование
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

function ThreadCopyFileS.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // расшифровка
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



procedure ThreadCopyFileS.Execute;
var
FileStream:TFilestream;
z,i:integer;
sizeStream,nSend,Sendbit:int64;
sBuf : Pointer;
slepengtime:integer;
Buffer,DeCryptBuf,SendPath:String;
TmpDirDirectory:string;// директория создания каталога
TmpFileDirectory:string; // директория сохранения файла
BadFile:boolean;
StopLoad:boolean;
SearchFile:Tstringlist;  // для списка файлов/каталогов если копируют каталог
SendList:TstringList;
ListError:TstringList;
begin
try
CLBLog_write('ThCopyFileS',2,'Зашущен поток передачи файлов');
ListError:=TstringList.Create;
FormFileTransfer.Tag:=1; // признак передачи файла через данный поток. Необхождимо чтобы file поток ожидал текущий
   if FormFileTransfer.Visible then //---------- если форма открыта
    begin
      Synchronize(
      procedure
      begin
       with FormFileTransfer do
        begin
        ButCancel.Visible:=true; // показываю кнопку отмены
        ButCopyFromClient.Enabled:=false; // выключаем кнопку копирования
        ButCopyToClient.Enabled:=false; // выключаем кнопку копирования
        LoadFFProgressBar.Position:=0;
        LoadFFProgressBar.ProgressText:='Формирование списка файлов';
        LoadFFProgressBar.Visible:=true;
        end;
      end);
    end;


  TRY
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
     BEGIN
     if (GetFileAttributes(pwideChar(ListFileFolder[i])) and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then // если в списке каталог
        Begin
         if SendPath<>'' then // если сформированный патч не пустой
           begin
            TmpDirDirectory:=StringReplace(ListFileFolder[i],SendPath,PathSave,[rfIgnoreCase]); //формирование директории на основании корневого каталога Spath и FPatch где сохранять
            if FormFileTransfer.Visible and FormFileTransfer.LoadFFProgressBar.Visible  then //---------- если форма открыта
               begin
                Synchronize(
                procedure
                 begin
                  with FormFileTransfer do
                   begin
                   LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Создание каталога: '+TmpDirDirectory;
                   end;
                 end);
               end;
            SendFileCryptText('<|CREATEFOLDER|>'+TmpDirDirectory+'<|ENDDIR|>');  // отправляем где создать каталог
           end;
        End
      ELSE// иначе это файл, передаем его
        Begin
          try

           FileStream:=TFileStream.Create(ListFileFolder[i],fmOpenRead);
             try
             FileStream.Position:=0;
             sizeStream:=FileStream.Size;
             if FormFileTransfer.Visible  then //---------- если форма открыта
               begin
                Synchronize(
                procedure
                 begin
                  with FormFileTransfer do
                   begin
                   LoadFFProgressBar.Max:=sizeStream;
                   LoadFFProgressBar.Min:=0;
                   LoadFFProgressBar.Position:=0;
                   LoadFFProgressBar.Step:=1;
                   LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') '+'Запуск копирования файла: '+ExtractFileName(ListFileFolder[i]);
                   end;
                 end);
               end;
             z:=0;
             slepengtime:=0;
             Sendbit:=0;
             nSend:=0;
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
                         SendFileCryptText('<|FILECOPY|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                         //CLBLog_write('ThCopyFileS',2,'Отправляю перед копированием <|FILECOPY|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                         while Socket.Connected do  // ожидание клиента к готовности к загрузке <|READYLOAD|>
                           BEGIN
                            if FormFileTransfer.CancelLoadFile then
                             begin
                             SendFileCryptText('<|STOPLOADFILES|>');
                             StopLoad:=true; // остановка передачи файлов
                             break; // если отменили загрузку выход из цикла
                             end;
                             Sleep(ProcessingSlack);
                            if Socket.ReceiveLength < 1 then
                             begin
                             slepengtime:=slepengtime+10;
                              if slepengtime>=20000 then // если больше то выйти из цикла ожидания ответа о загрузке файла
                               begin
                               ListError.Add(timetostr(now)+' Время ожидания подтверждения готовности загрузки  истекло: '+ListFileFolder[i]);
                               SendFileCryptText('<|BADFILE|>');
                               BadFile:=true; // ошибка передачи текущего файла
                               break;
                               end;
                             Continue;
                             end;

                             DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в файловый сокет
                             Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                             if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                                 begin
                                 ListError.Add(timetostr(now)+' Запросили остановку копирования '+ListFileFolder[i]);
                                 StopLoad:=true; // абонент остановил загрузку файлов
                                 break; // выходим из потока т.к. нас попросили остановить загузку
                                 end;
                             if pos('<|READYLOAD|>',Buffer)>0 then break;   // клиент готов к загрузке файла
                           END;

                          if (StopLoad or BadFile) then break;  // если остановили передачу файлов или не дождались ответа от клиента

                           while (Sendbit < SizeStream) and (Socket.Connected) do //передача файла буфером
                           BEGIN
                             Sleep(ProcessingSlack);
                             if StopLoad then break; // если остановили передачу файлов
                             if Socket.ReceiveLength > 0 then  // проверка на отмену передачи файла
                              begin
                               DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в файловый сокет
                               Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
                               if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                                 begin
                                 ListError.Add(timetostr(now)+' Запросили остановку копирования '+ListFileFolder[i]);
                                 StopLoad:=true; // абонент остановил загрузку файлов
                                 break; // выходим из потока т.к. нас попросили остановить загузку
                                 end;
                              end;

                             if FormFileTransfer.CancelLoadFile then // если я передаю и нажал отмена передачи
                               begin
                               SendFileCryptText('<|STOPLOADFILES|>');
                               ListError.Add(timetostr(now)+ ' Остановить копирование '+ListFileFolder[i]);
                               StopLoad:=true; // Остановили передачу файлов
                               break; // если отменили загрузку
                               end;

                             GetMem(sBuf, SizeStream-Sendbit);
                             nSend := FileStream.Read(sBuf^, SizeStream-Sendbit); // читаем в буфер данные для отправки
                             if nSend > 0 then // если что то прочитали из потока то отправляем
                               begin
                               z:=Socket.SendBuf(sBuf^, nSend);
                               if z<1 then // если ничего не отправили
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
                                      ListError.Add(timetostr(now)+' Не возможно отправить данные');
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
                                  if FormFileTransfer.Visible then //-------- если открыта форма
                                   begin
                                    Synchronize(
                                    procedure
                                      begin
                                      FormFileTransfer.LoadFFProgressBar.Position:=Sendbit;
                                      FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Копирование файла: '+ExtractFileName(ListFileFolder[i])+' '+GetSizeByte(SizeStream)+' / '+GetSizeByte(Sendbit);
                                      end);
                                   end;
                                 end;
                               end
                               else // nSend <= 0  если не смогли прочитать файл
                                begin
                                sleep(ProcessingSlack);
                                slepengtime:=slepengtime+10;
                                if slepengtime>=5000 then // если больше то выйти из цикла ожидания чтения файла
                                  begin
                                  ListError.Add(timetostr(now)+' Не возможно прочитать данные из файла');
                                  break;
                                  end;
                                  if FormFileTransfer.Visible then //-------- если открыта форма
                                   begin
                                    Synchronize(
                                    procedure
                                      begin
                                      FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Ошибка чтения данных: '+ExtractFileName(ListFileFolder[i]);
                                      end);
                                   end;
                                end;
                             FreeMem(sBuf);
                             if Sendbit >= SizeStream then break;
                            END; // окончание цикла отправки файла

                          if (Sendbit<SizeStream) then
                           begin
                           ListError.Add(timetostr(now)+' Ошибка отправки='+inttostr(WSAGetLastError));
                           SendFileCryptText('<|BADFILE|>');
                          // CLBLog_write('clpbrd','Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' Отправил  <|BADFILE|> - 4 '+ListFileFolder[i]);
                           BadFile:=true; // ошибка передачи текущего файла
                           end
                          else
                           begin
                           SendFileCryptText('<|ENDFILEFULL|>');
                           //ListError.Add(timetostr(now)+ ' Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' Отправил  <|ENDFILEFULL|>'+ListFileFolder[i]);
                           BadFile:=false; // без ошибки отправили файл
                           end;
                        end;
                     end;
                end
                else BadFile:=true; // иначе если поток =0 ошибка передачи текущего файла
             finally
             FileStream.Free;
             end;


           except on E : Exception do
             begin
             if Assigned(FileStream) then FileStream.Free;
             ListError.Add(timetostr(now)+' Ошибка передачи файла абоненту: '+ListFileFolder[i]+'  : '+E.ClassName+': '+E.Message);
              if FormFileTransfer.Visible then //-------- если открыта форма
               Begin
               Synchronize( procedure
                begin
                FormFileTransfer.LoadFFProgressBar.ProgressText:='('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Ошибка копирования: '+ExtractFileName(ListFileFolder[i]);
                end);
               End;
             SendFileCryptText('<|BADFILE|>'+E.ClassName+': '+E.Message+'<|ENDBAD|>');
             BadFile:=true; // ошибка передачи текущего файла
             end;
           end;

           if not BadFile then
           if FormFileTransfer.Visible then //-------- если открыта форма
             begin
             Synchronize( procedure
              begin
              FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Завершение передачи: '+ExtractFileName(ListFileFolder[i]);
              end);
             end;

           slepengtime:=0;

            WHILE  (Socket.Connected) do // ожидание ответа о приеме файла
              BEGIN
               if StopLoad then break; // если остановили передачу файлов
               if FormFileTransfer.CancelLoadFile then
                 begin
                 SendFileCryptText('<|STOPLOADFILES|>');
                 ListError.Add(timetostr(now)+' Запросили остановку копирования '+ListFileFolder[i]);
                 StopLoad:=true; // абонент остановил загрузку файлов
                 break; // выходим из потока т.к. нас попросили остановить загузку
                 end;
               Sleep(ProcessingSlack);
               if Socket.ReceiveLength < 1 then
                 begin
                  slepengtime:=slepengtime+ProcessingSlack;
                  if slepengtime>=6000 then // если больше то выйти из цикла ожидания ответа о загрузке файла
                     begin
                     ListError.Add(timetostr(now)+' Время ожидания подтверждения загрузки файла истекло: '+ListFileFolder[i]);
                     SendFileCryptText('<|BADFILE|>');
                     BadFile:=true; // ошибка передачи текущего файла
                     break;
                     end;
                  Continue;
                 end;

               DeCryptBuf := Socket.ReceiveText;   //присваиваем данные полученые в главный сокет
               Buffer:=DecryptReciveText(DeCryptBuf);// получение расшифрованной строки
               if pos('<|STOPLOADFILES|>',Buffer)>0 then //если попросили остановить передачу файла
                 begin
                 ListError.Add(timetostr(now)+' Запросили остановку копирования файла: '+ListFileFolder[i]);
                 StopLoad:=true; // абонент остановил загрузку файлов
                 break; // выходим из потока т.к. нас попросили остановить загузку
                 end;

               if pos('<|DNLDCMPLT|>',Buffer)>0 then
                 begin
                  if FormFileTransfer.Visible then //-------- если открыта форма
                   begin
                   Synchronize( procedure
                    begin
                    FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Копирование файла завершено: '+ExtractFileName(ListFileFolder[i]);
                    end);
                   end;
                  break;
                 end;
               if pos('<|DNLDERROR|>',Buffer)>0 then // если ошибка копирования файла
                 begin
                 if FormFileTransfer.Visible then //-------- если открыта форма
                   begin
                   Synchronize( procedure
                    begin
                    FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') Ошибка копирования: '+ExtractFileName(ListFileFolder[i]);
                    end);
                   end;
                 Break;
                 end;
              END; // цикл получения ответа
           if StopLoad then break; // если остановили передачу файлов
        End;// передача файла

     END;// цикл по списку передаваемых файлов

  FINALLY
  ListFileFolder.Free;
  SendFileCryptText('<|ENDOFFILECOPY|>'); // Признак окончания передачи всех файлов
  if FormFileTransfer.Visible then //-------- если открыта форма
    begin
    Synchronize( procedure
      begin
      with FormFileTransfer do
        begin
        ButCancel.Visible:=false; // скрываю кнопку отмены
        ButCopyFromClient.Enabled:=true; // включаем кнопку копирования
        ButCopyToClient.Enabled:=true; // включаем кнопку копирования
        LoadFFProgressBar.ProgressText:='';
        LoadFFProgressBar.Position:=0;
        LoadFFProgressBar.Visible:=false;
        ButClientUpdate.Click;// обновляем список файлов в окне клиента
        InMessage('Копирование завершено',2);
        end;
      end);
    end;
  StopLoad:=false; // абонент остановил загрузку файлов
  FormFileTransfer.Tag:=0;  //отменяем признак передачи файла через данный поток. Теперь file поток  может принимать и получать данные
  for I := 0 to ListError.Count-1 do  CLBLog_write('ThCopyFileS',2,ListError[i]);
  CLBLog_write('ThCopyFileS',2,'Копироваие файлов завершено Error='+inttostr(ListError.Count));
  ListError.Free;
  END;

 except on E : Exception do
    begin
      if FormFileTransfer.Visible then //-------- если открыта форма
         begin
         Synchronize( procedure
           begin
           FormFileTransfer.LoadFFProgressBar.Visible:=false;
           end);
         end;
     if FormFileTransfer.Tag=1 then
      begin
      SendFileCryptText('<|ENDOFFILECOPY|>'); // Признак окончания передачи файлов
      FormFileTransfer.Tag:=0; // снимаем признак работы данного потока, т.к. сокет используется 2 мя потоками
      end;
    if Assigned(ListFileFolder) then ListFileFolder.Free;
    CLBLog_write('ThCopyFileS',2,'ThreadCopyFile Ошибка передачи файлов: '+E.ClassName+': '+E.Message);
    end;
  end;
end;





end.
