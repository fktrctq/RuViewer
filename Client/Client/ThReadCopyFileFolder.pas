unit ThReadCopyFileFolder;

interface
uses
  Winapi.Windows, Winapi.WinSock,  System.SysUtils, System.Classes,  VCL.Forms, System.Win.ScktComp, System.IOUtils,Vcl.Dialogs,
   uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Hash, uTPLb_CodecIntf, uTPLb_Constants, uTPLb_Signatory, uTPLb_SimpleBlockCipher
   ,System.Hash,Osher;

  type
  ThreadCopyFileS = class(TThread) // ����� ��� ����������� ������
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
   function GetSizeByte(bytes: Int64): string;  // ������ ������ � ������� � �����, ������, ������
   function Encryptstrs(const Instr: string; pswd: string; var OutStr:string ): boolean;
   function Decryptstrs(const Instr : string; pswd:string ; var OutStr:string ):boolean;
   function DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
   function SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
end;


implementation
uses Form_Main,SocketCrypt,FileTransfer;


function ThreadCopyFileS.GetSizeByte(bytes: Int64): string;  // ������ ������ � ������� � �����, ������, ������
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
   if NumError<=LevelLogError then // ���� ������� ������ ���� ��� �������� � ����������
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

Function ThreadCopyFileS.ScanDir(Root: String; var List: TStringList):boolean;  // �������� ������ ������ ���������
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
      if (F.Attr and faDirectory) = faDirectory then // ���� ��������� ������ ������ ���������
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
  List.Delete(0); // ������� 1-� ������ �.�. ��� �� ���������� ������� � �������
  result:=true;
  except On E: Exception do
    begin
    result:=false;
    CLBLog_write('ThCopyFileS',2,'ScanDir '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileS.ScanFiles(Root: String; var List: TStringList):boolean; // �������� ������ ������ ������
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
       if (F.Attr and faAnyFile) = faAnyFile then // ���� ��������� ������ ������ ������
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
  List.Delete(0); // ������� 1-� ������ �.�. ��� �� ���������� ������� � �������
  result:=true;
  except On E: Exception do
    begin
    result:=false;
    CLBLog_write('ThCopyFileS',2,'ScanFiles '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;

Function ThreadCopyFileS.ScanDirFull(Root: String; var List: TStringList):boolean; // �������� ������ ������ ������ � ���������
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
  List.Delete(0); // ������� 1-� ������ �.�. ��� �� ���������� ������� � �������
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
except on E : Exception do CLBLog_write('ThCopyFileS',2,'������ �������� ������ (F) ������� ������� (F)  : '+E.ClassName+': '+E.Message);  end;
end;
//---------------------------------------------

function ThreadCopyFileS.SendFileCryptText(s:string):Boolean; // �������� �������������� ������ � main �����
var
CryptBuf:string;
begin
try
Encryptstrs(s,PswrdCrypt, CryptBuf); //������� ����� ���������
SendFileSocket('<!>'+CryptBuf+'<!!>'); //-----------------------> ������ ������������� �������� ��������� <!>, ����� �� ������ ����� ��� ����������� � ������� �� �����������
result:=true;
  except On E: Exception do
    begin
    result:=false;
    s:='';
    CLBLog_write('ThCopyFileS',2,'ERROR  - ����� � ������ ���������� � �������� ������ '+ E.ClassName+' / '+ E.Message);
    end;
  end;
end;


function ThreadCopyFileS.DecryptReciveText(s:string):string; // ������� ����������� ���������� ������ �� ������
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
   while BufS<>'' do // � ����� ������
     begin
     step:=1;
      CryptTmp:='';
      DecryptTmp:='';
      step:=2;
      posStart:=pos('<!>',BufS);// ������ ������������� �������
      posEnd:=pos('<!!>',BufS); // ����� ������������� �������
      step:=3;
      CryptTmp:=copy(BufS,posStart+3,posEnd-4);// �������� ����������� ������ ������� � ������� posStart+3 ����� posEnd-4 ��������
      step:=4;
      Decryptstrs(CryptTmp,PswrdCrypt,DecryptTmp); //���������� ������������� ������
      step:=5;
      bufTmp:=bufTmp+DecryptTmp;// ����������� �������������� ������
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
    CLBLog_write('ThCopyFileS',2,'ERROR  - ����� � ������ ���������� ������ '+ E.ClassName+' / '+ E.Message);
     s:='';
    end;
  end;
end;

function ThreadCopyFileS.encryptstrs(const InStr :string; pswd:string; var OutStr:string ): boolean; // ����������
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

function ThreadCopyFileS.Decryptstrs(const inStr : string; pswd:string; var OutStr:string): boolean; // �����������
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
TmpDirDirectory:string;// ���������� �������� ��������
TmpFileDirectory:string; // ���������� ���������� �����
BadFile:boolean;
StopLoad:boolean;
SearchFile:Tstringlist;  // ��� ������ ������/��������� ���� �������� �������
SendList:TstringList;
ListError:TstringList;
begin
try
CLBLog_write('ThCopyFileS',2,'������� ����� �������� ������');
ListError:=TstringList.Create;
FormFileTransfer.Tag:=1; // ������� �������� ����� ����� ������ �����. ����������� ����� file ����� ������ �������
   if FormFileTransfer.Visible then //---------- ���� ����� �������
    begin
      Synchronize(
      procedure
      begin
       with FormFileTransfer do
        begin
        ButCancel.Visible:=true; // ��������� ������ ������
        ButCopyFromClient.Enabled:=false; // ��������� ������ �����������
        ButCopyToClient.Enabled:=false; // ��������� ������ �����������
        LoadFFProgressBar.Position:=0;
        LoadFFProgressBar.ProgressText:='������������ ������ ������';
        LoadFFProgressBar.Visible:=true;
        end;
      end);
    end;


  TRY
  //----------------------------------------------------------------��������� ������� ������� � ���������� ���� � ������ �� ����������� ���� ������
     SearchFile:=TstringList.Create;
     SendList:= TstringList.Create;
     SendPath:=''; // ���������� ��� ������� ���������
     try // ��������� ������� ������� � ���������� ���� � ������ �� ����������� ���� �������
      for I := 0 to ListFileFolder.count-1 do
        begin
        if (GetFileAttributes(pwideChar(ListFileFolder[i])) and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then // ���� � ������ �������
           begin //http://www.proghouse.ru/programming/126-ioutils#TDirectory_GetFiles
           //SearchFile.AddStrings(TDirectory.GetFileSystemEntries(ListFileFolder[i])); // ������ ������ � ���������  � ��������� ��������
           ScanDirFull(ListFileFolder[i],SearchFile); // ������ ������ � ���������  � ��������� ��������
           SendPath:=TDirectory.GetParent(ListFileFolder[i]); // ����������� ������������� �������� �������� �������� ListFileFolder[i]
           for Z := 0 to SearchFile.Count-1 do
           SendList.Add(SearchFile[z]); //��������� ��� ��������� ����� � �������� � ������ �� ��������
           end;
        end;

      if SendList.Count>0 then // ���� ������ ������ � ��������� �� ������
       begin
        for I := 0 to SendList.Count-1 do
         begin
         ListFileFolder.Add(SendList[i]);  // ��������� ��� � ����� ������ ������ � ���������
         end;
       end;

     finally
     SearchFile.Free;
     SendList.Free;
     end;
  //-----------------------------------------------------------------------
  // ListError.Add(timetostr(now)+' ���������� ��������� - '+SendPath+' ������ ���������� ��� �������� �� ������� - '+PathSave);
  if pos('\',SendPath)=length(SendPath) then delete(SendPath,length(SendPath),1);// ���� � ����� ������ ��������� '\' �� ������� ���. ����� �������� ���� �������� �� ����� ����� . C:\
  for I := 0 to ListFileFolder.count-1 do
   if ListFileFolder[i]<>'' then
     BEGIN
     if (GetFileAttributes(pwideChar(ListFileFolder[i])) and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then // ���� � ������ �������
        Begin
         if SendPath<>'' then // ���� �������������� ���� �� ������
           begin
            TmpDirDirectory:=StringReplace(ListFileFolder[i],SendPath,PathSave,[rfIgnoreCase]); //������������ ���������� �� ��������� ��������� �������� Spath � FPatch ��� ���������
            if FormFileTransfer.Visible and FormFileTransfer.LoadFFProgressBar.Visible  then //---------- ���� ����� �������
               begin
                Synchronize(
                procedure
                 begin
                  with FormFileTransfer do
                   begin
                   LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') �������� ��������: '+TmpDirDirectory;
                   end;
                 end);
               end;
            SendFileCryptText('<|CREATEFOLDER|>'+TmpDirDirectory+'<|ENDDIR|>');  // ���������� ��� ������� �������
           end;
        End
      ELSE// ����� ��� ����, �������� ���
        Begin
          try

           FileStream:=TFileStream.Create(ListFileFolder[i],fmOpenRead);
             try
             FileStream.Position:=0;
             sizeStream:=FileStream.Size;
             if FormFileTransfer.Visible  then //---------- ���� ����� �������
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
                   LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') '+'������ ����������� �����: '+ExtractFileName(ListFileFolder[i]);
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
                         begin // ���������� ������ �����, ���, ���� ��������� ExtractFileDir
                         if SendPath<>'' then TmpFileDirectory:=ExtractFilePath(StringReplace(ListFileFolder[i],SendPath,PathSave,[rfIgnoreCase])) // ���������� ���������� ��� ���������� ������ �� ��������� �������� ���� Spath � ���� ��������� FPatch
                         else TmpFileDirectory:=PathSave+'\'; // ����� ��������� ��� ����������� �� ���� �   SendPath ������  � PathSave ��� ���������� ������� '\'
                         SendFileCryptText('<|FILECOPY|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                         //CLBLog_write('ThCopyFileS',2,'��������� ����� ������������ <|FILECOPY|>'+inttostr(SizeStream)+'<|FSIZE|>'+ExtractFileName(ListFileFolder[i])+'<|FNAME|>'+TmpFileDirectory+'<|ENDFILE|>('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+')<|ENDCOUNT|>');
                         while Socket.Connected do  // �������� ������� � ���������� � �������� <|READYLOAD|>
                           BEGIN
                            if FormFileTransfer.CancelLoadFile then
                             begin
                             SendFileCryptText('<|STOPLOADFILES|>');
                             StopLoad:=true; // ��������� �������� ������
                             break; // ���� �������� �������� ����� �� �����
                             end;
                             Sleep(ProcessingSlack);
                            if Socket.ReceiveLength < 1 then
                             begin
                             slepengtime:=slepengtime+10;
                              if slepengtime>=20000 then // ���� ������ �� ����� �� ����� �������� ������ � �������� �����
                               begin
                               ListError.Add(timetostr(now)+' ����� �������� ������������� ���������� ��������  �������: '+ListFileFolder[i]);
                               SendFileCryptText('<|BADFILE|>');
                               BadFile:=true; // ������ �������� �������� �����
                               break;
                               end;
                             Continue;
                             end;

                             DeCryptBuf := Socket.ReceiveText;   //����������� ������ ��������� � �������� �����
                             Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
                             if pos('<|STOPLOADFILES|>',Buffer)>0 then //���� ��������� ���������� �������� �����
                                 begin
                                 ListError.Add(timetostr(now)+' ��������� ��������� ����������� '+ListFileFolder[i]);
                                 StopLoad:=true; // ������� ��������� �������� ������
                                 break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                                 end;
                             if pos('<|READYLOAD|>',Buffer)>0 then break;   // ������ ����� � �������� �����
                           END;

                          if (StopLoad or BadFile) then break;  // ���� ���������� �������� ������ ��� �� ��������� ������ �� �������

                           while (Sendbit < SizeStream) and (Socket.Connected) do //�������� ����� �������
                           BEGIN
                             Sleep(ProcessingSlack);
                             if StopLoad then break; // ���� ���������� �������� ������
                             if Socket.ReceiveLength > 0 then  // �������� �� ������ �������� �����
                              begin
                               DeCryptBuf := Socket.ReceiveText;   //����������� ������ ��������� � �������� �����
                               Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
                               if pos('<|STOPLOADFILES|>',Buffer)>0 then //���� ��������� ���������� �������� �����
                                 begin
                                 ListError.Add(timetostr(now)+' ��������� ��������� ����������� '+ListFileFolder[i]);
                                 StopLoad:=true; // ������� ��������� �������� ������
                                 break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                                 end;
                              end;

                             if FormFileTransfer.CancelLoadFile then // ���� � ������� � ����� ������ ��������
                               begin
                               SendFileCryptText('<|STOPLOADFILES|>');
                               ListError.Add(timetostr(now)+ ' ���������� ����������� '+ListFileFolder[i]);
                               StopLoad:=true; // ���������� �������� ������
                               break; // ���� �������� ��������
                               end;

                             GetMem(sBuf, SizeStream-Sendbit);
                             nSend := FileStream.Read(sBuf^, SizeStream-Sendbit); // ������ � ����� ������ ��� ��������
                             if nSend > 0 then // ���� ��� �� ��������� �� ������ �� ����������
                               begin
                               z:=Socket.SendBuf(sBuf^, nSend);
                               if z<1 then // ���� ������ �� ���������
                                 begin
                                 Sleep(10);
                                 ListError.Add(timetostr(now)+' WSAGetLastError='+inttostr(WSAGetLastError));
                                 ListError.Add(timetostr(now)+' nSend='+inttostr(nSend)+' ��������� z='+inttostr(z)+' ������� ������� FileStream='+inttostr(FileStream.Position-nSend));
                                  while  WSAGetLastError() = WSAEWOULDBLOCK do
                                    begin
                                    Sleep(10);
                                    ListError.Add(timetostr(now)+' - WSAGetLastError() = WSAEWOULDBLOCK');
                                    slepengtime:=slepengtime+10;
                                    if slepengtime>=5000 then // ���� ������ �� ����� �� ����� �������� ������ �����
                                      begin
                                      ListError.Add(timetostr(now)+' �� �������� ��������� ������');
                                      break;
                                      end;
                                    end;
                                 FileStream.Position:=FileStream.Position-nSend;
                                 end
                                else  // ���� ��������� ������� �� ������
                                 begin
                                 Sendbit:=Sendbit+z;
                                 FileStream.Position:=Sendbit;
                                 if z<nSend then  // ���� ���������� ������ ��� ������� ����� ���������
                                   begin
                                   sleep(ProcessingSlack);
                                   ListError.Add(timetostr(now)+' nSend='+inttostr(nSend)+' ��������� z='+inttostr(z)+' ������� ������� FileStream='+inttostr(Sendbit));
                                   end;
                                  if FormFileTransfer.Visible then //-------- ���� ������� �����
                                   begin
                                    Synchronize(
                                    procedure
                                      begin
                                      FormFileTransfer.LoadFFProgressBar.Position:=Sendbit;
                                      FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ����������� �����: '+ExtractFileName(ListFileFolder[i])+' '+GetSizeByte(SizeStream)+' / '+GetSizeByte(Sendbit);
                                      end);
                                   end;
                                 end;
                               end
                               else // nSend <= 0  ���� �� ������ ��������� ����
                                begin
                                sleep(ProcessingSlack);
                                slepengtime:=slepengtime+10;
                                if slepengtime>=5000 then // ���� ������ �� ����� �� ����� �������� ������ �����
                                  begin
                                  ListError.Add(timetostr(now)+' �� �������� ��������� ������ �� �����');
                                  break;
                                  end;
                                  if FormFileTransfer.Visible then //-------- ���� ������� �����
                                   begin
                                    Synchronize(
                                    procedure
                                      begin
                                      FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ������ ������ ������: '+ExtractFileName(ListFileFolder[i]);
                                      end);
                                   end;
                                end;
                             FreeMem(sBuf);
                             if Sendbit >= SizeStream then break;
                            END; // ��������� ����� �������� �����

                          if (Sendbit<SizeStream) then
                           begin
                           ListError.Add(timetostr(now)+' ������ ��������='+inttostr(WSAGetLastError));
                           SendFileCryptText('<|BADFILE|>');
                          // CLBLog_write('clpbrd','Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' ��������  <|BADFILE|> - 4 '+ListFileFolder[i]);
                           BadFile:=true; // ������ �������� �������� �����
                           end
                          else
                           begin
                           SendFileCryptText('<|ENDFILEFULL|>');
                           //ListError.Add(timetostr(now)+ ' Sendbit-'+ inttostr(Sendbit)+' SizeStream-'+inttostr(SizeStream)+' ��������  <|ENDFILEFULL|>'+ListFileFolder[i]);
                           BadFile:=false; // ��� ������ ��������� ����
                           end;
                        end;
                     end;
                end
                else BadFile:=true; // ����� ���� ����� =0 ������ �������� �������� �����
             finally
             FileStream.Free;
             end;


           except on E : Exception do
             begin
             if Assigned(FileStream) then FileStream.Free;
             ListError.Add(timetostr(now)+' ������ �������� ����� ��������: '+ListFileFolder[i]+'  : '+E.ClassName+': '+E.Message);
              if FormFileTransfer.Visible then //-------- ���� ������� �����
               Begin
               Synchronize( procedure
                begin
                FormFileTransfer.LoadFFProgressBar.ProgressText:='('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ������ �����������: '+ExtractFileName(ListFileFolder[i]);
                end);
               End;
             SendFileCryptText('<|BADFILE|>'+E.ClassName+': '+E.Message+'<|ENDBAD|>');
             BadFile:=true; // ������ �������� �������� �����
             end;
           end;

           if not BadFile then
           if FormFileTransfer.Visible then //-------- ���� ������� �����
             begin
             Synchronize( procedure
              begin
              FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ���������� ��������: '+ExtractFileName(ListFileFolder[i]);
              end);
             end;

           slepengtime:=0;

            WHILE  (Socket.Connected) do // �������� ������ � ������ �����
              BEGIN
               if StopLoad then break; // ���� ���������� �������� ������
               if FormFileTransfer.CancelLoadFile then
                 begin
                 SendFileCryptText('<|STOPLOADFILES|>');
                 ListError.Add(timetostr(now)+' ��������� ��������� ����������� '+ListFileFolder[i]);
                 StopLoad:=true; // ������� ��������� �������� ������
                 break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                 end;
               Sleep(ProcessingSlack);
               if Socket.ReceiveLength < 1 then
                 begin
                  slepengtime:=slepengtime+ProcessingSlack;
                  if slepengtime>=6000 then // ���� ������ �� ����� �� ����� �������� ������ � �������� �����
                     begin
                     ListError.Add(timetostr(now)+' ����� �������� ������������� �������� ����� �������: '+ListFileFolder[i]);
                     SendFileCryptText('<|BADFILE|>');
                     BadFile:=true; // ������ �������� �������� �����
                     break;
                     end;
                  Continue;
                 end;

               DeCryptBuf := Socket.ReceiveText;   //����������� ������ ��������� � ������� �����
               Buffer:=DecryptReciveText(DeCryptBuf);// ��������� �������������� ������
               if pos('<|STOPLOADFILES|>',Buffer)>0 then //���� ��������� ���������� �������� �����
                 begin
                 ListError.Add(timetostr(now)+' ��������� ��������� ����������� �����: '+ListFileFolder[i]);
                 StopLoad:=true; // ������� ��������� �������� ������
                 break; // ������� �� ������ �.�. ��� ��������� ���������� �������
                 end;

               if pos('<|DNLDCMPLT|>',Buffer)>0 then
                 begin
                  if FormFileTransfer.Visible then //-------- ���� ������� �����
                   begin
                   Synchronize( procedure
                    begin
                    FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ����������� ����� ���������: '+ExtractFileName(ListFileFolder[i]);
                    end);
                   end;
                  break;
                 end;
               if pos('<|DNLDERROR|>',Buffer)>0 then // ���� ������ ����������� �����
                 begin
                 if FormFileTransfer.Visible then //-------- ���� ������� �����
                   begin
                   Synchronize( procedure
                    begin
                    FormFileTransfer.LoadFFProgressBar.ProgressText:=' ('+inttostr(i+1)+'/'+inttostr(ListFileFolder.Count)+') ������ �����������: '+ExtractFileName(ListFileFolder[i]);
                    end);
                   end;
                 Break;
                 end;
              END; // ���� ��������� ������
           if StopLoad then break; // ���� ���������� �������� ������
        End;// �������� �����

     END;// ���� �� ������ ������������ ������

  FINALLY
  ListFileFolder.Free;
  SendFileCryptText('<|ENDOFFILECOPY|>'); // ������� ��������� �������� ���� ������
  if FormFileTransfer.Visible then //-------- ���� ������� �����
    begin
    Synchronize( procedure
      begin
      with FormFileTransfer do
        begin
        ButCancel.Visible:=false; // ������� ������ ������
        ButCopyFromClient.Enabled:=true; // �������� ������ �����������
        ButCopyToClient.Enabled:=true; // �������� ������ �����������
        LoadFFProgressBar.ProgressText:='';
        LoadFFProgressBar.Position:=0;
        LoadFFProgressBar.Visible:=false;
        ButClientUpdate.Click;// ��������� ������ ������ � ���� �������
        InMessage('����������� ���������',2);
        end;
      end);
    end;
  StopLoad:=false; // ������� ��������� �������� ������
  FormFileTransfer.Tag:=0;  //�������� ������� �������� ����� ����� ������ �����. ������ file �����  ����� ��������� � �������� ������
  for I := 0 to ListError.Count-1 do  CLBLog_write('ThCopyFileS',2,ListError[i]);
  CLBLog_write('ThCopyFileS',2,'���������� ������ ��������� Error='+inttostr(ListError.Count));
  ListError.Free;
  END;

 except on E : Exception do
    begin
      if FormFileTransfer.Visible then //-------- ���� ������� �����
         begin
         Synchronize( procedure
           begin
           FormFileTransfer.LoadFFProgressBar.Visible:=false;
           end);
         end;
     if FormFileTransfer.Tag=1 then
      begin
      SendFileCryptText('<|ENDOFFILECOPY|>'); // ������� ��������� �������� ������
      FormFileTransfer.Tag:=0; // ������� ������� ������ ������� ������, �.�. ����� ������������ 2 �� ��������
      end;
    if Assigned(ListFileFolder) then ListFileFolder.Free;
    CLBLog_write('ThCopyFileS',2,'ThreadCopyFile ������ �������� ������: '+E.ClassName+': '+E.Message);
    end;
  end;
end;





end.
