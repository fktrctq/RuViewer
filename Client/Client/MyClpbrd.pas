unit MyClpbrd;

interface

uses clipbrd, Winapi.Windows,ShellApi,TLHelp32, System.SysUtils, System.Classes,Vcl.Forms;


function ExtCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;
function ExtCopyStreamFromClipboard(fmt: Cardinal; S: TStream):boolean;
function ExtSaveClipboardFormat(fmt: cardinal; writer: TWriter):boolean;
function ExtLoadClipboardFormat(reader: TReader):boolean;
function ExtSaveClipboardToStream(S: TStream; var FrmClpbrd:word):boolean;
function ExtLoadClipboard(S: TStream):boolean;
procedure ExtClipBoardGetFiles(const Files: TStrings); // получение списка файлов из буфера обмена
function ExtClipBoardTheFiles:boolean; // проверка буфера обмена на наличие файлов


implementation
uses Form_main;
{const
  COINIT_MULTITHREADED = 0;
  COINIT_APARTMENTTHREADED = 2;
  COINIT_DISABLE_OLE1DDE =4;
  COINIT_SPEED_OVER_MEMORY =8; }
                    //уровни целостности и обязательную политику для оценки доступа.  Windows определяет четыре уровня целостности (доступа): низкий, средний, высокий и системный.

//--------------------------------------------------------------------------------------------------------------------------
 function ExtCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;
 var
   hMem: THandle;
   pMem: Pointer;
 begin
  try
   Assert(Assigned(S));
   S.Position := 0;
   hMem       := GlobalAlloc(GHND or GMEM_DDESHARE, S.Size);
   if hMem <> 0 then
   begin
     pMem := GlobalLock(hMem);
     if pMem <> nil then
     begin
       try
         S.Read(pMem^, S.Size);
         S.Position := 0;
       finally
         GlobalUnlock(hMem);
       end;
       Clipboard.Open;
       try
         Clipboard.SetAsHandle(fmt, hMem);
         result:=true;
       finally
         Clipboard.Close;
       end;
     end { If }
     else
     begin
       GlobalFree(hMem);
       result:=false;
       frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: Ошибка GlobalAlloc: '+SysErrorMessage(GetLastError()));
     end;
   end { If }
   else
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: Ошибка GlobalAlloc: '+SysErrorMessage(GetLastError()));
    end;
  except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: Ошибка ExtCopyStreamToClipboard: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { CopyStreamToClipboard }

//-----------------------------------------------------------------------------------------------------
 function ExtCopyStreamFromClipboard(fmt: Cardinal; S: TStream):boolean;
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
          frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: Ошибка GlobalLock: '+SysErrorMessage(GetLastError()));
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
      frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: Ошибка GetClipboardData=0 fmt='+inttostr(fmt)+' Error='+SysErrorMessage(GetLastError()));
     end;
  except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: Ошибка CopyStreamFromClipboard: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { CopyStreamFromClipboard }

 //---------------------------------------------------------------------------------------------------------
function ExtSaveClipboardFormat(fmt: cardinal; writer: TWriter):boolean;
 var
   fmtname: array[0..256] of Char;
   ms: TMemoryStream;
 begin
 try
   Assert(Assigned(writer));
   if GetClipboardFormatName(fmt, fmtname, Length(fmtname))=0 then
   begin
     //frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardFormat: fmtname='+fmtname+' / GetClipboardFormatName: '+SysErrorMessage(GetLastError()));
     //fmtname[0] := #0;
   end;
   ms := TMemoryStream.Create;
   //frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardFormat: fmtname='+fmtname);
   try
     result:=ExtCopyStreamFromClipboard(fmt, ms);
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
   if not result then frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardFormat: not result: ');
  except on E : Exception do
      begin
      result:=false;
      frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardFormat: Ошибка ClipboardFormat: '+E.ClassName+': '+E.Message);
      end;
    end;
 end; { SaveClipboardFormat }
//------------------------------------------------------------------------------------------------
 function ExtLoadClipboardFormat(reader: TReader):boolean;
 var
   fmt: Integer;
   fmtname: string;
   Size: Integer;
   ms: TMemoryStream;
 begin
 try
   Assert(Assigned(reader));
   fmt     := reader.ReadInteger;
   fmtname := reader.ReadString;
   Size    := reader.ReadInteger;
   ms      := TMemoryStream.Create;
   try
     ms.Size := Size;
     reader.Read(ms.memory^, Size);
     if Length(fmtname) > 0 then
       fmt := RegisterCLipboardFormat(PChar(fmtname));
     if fmt <> 0 then
     begin
       result:=ExtCopyStreamToClipboard(fmt, ms);
     end
     else
     begin
       result:=false;
       frm_main.Log_Write('Clipboard',2,'ExtLoadClipboardFormat: Ошибка RegisterCLipboardFormat: '+SysErrorMessage(GetLastError()));
     end;
   finally
     ms.Free;
   end; { Finally }
 except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtLoadClipboardFormat: Ошибка LoadClipboardFormat: '+E.ClassName+': '+E.Message);
    end;
  end;
 end; { LoadClipboardFormat }

 //-------------------------------------------------------------------------------------------------------
function ExtShellWindow: HWND;
type
  TGetShellWindow = function(): HWND; stdcall;
var
  hUser32: THandle;
  GetShellWindow: TGetShellWindow;
begin
  Result := 0;
  hUser32 := GetModuleHandle('user32.dll');
  if hUser32 > 0 then
  begin
    @GetShellWindow := GetProcAddress(hUser32, 'GetShellWindow');
    if Assigned(GetShellWindow) then
      Result := GetShellWindow;
  end;
end;

function ExtSaveClipboardToStream(S: TStream; var FrmClpbrd:word):boolean;
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
    // frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: WinHandle='+inttostr(WinHandle));
    // OwnerClpb:=GetClipboardOwner; // определяем владельца буфера обмена
     //frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: OwnerClpb='+inttostr(OwnerClpb));

     if not OpenClipboard(Application.Handle) then //GetShellWindow     GetDesktopWindow
      frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: OpenClipboard=0 Error='+SysErrorMessage(GetLastError));

     countCBF:=CountClipboardFormats;
     //frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: CountClipboardFormats='+inttostr(countCBF));
     CBFList := TList.Create;
     try
       writer.WriteListBegin;
       CBF:=0;

       {repeat
       CBF:=EnumClipboardFormats(CBF);
       if CBF<>0 then CBFList.Add(pointer(CBF))
       else  frm_main.Log_Write('Clipboard','EnumClipboardFormats=0 Error='+SysErrorMessage(GetLastError));
       until CBF = ERROR_SUCCESS;}

       while countCBF>0 do
        begin
        CBF:=EnumClipboardFormats(CBF);
        CBFList.Add(pointer(CBF));
        dec(countCBF);
        //frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: EnumClipboardFormats='+inttostr(CBF)+' Error='+SysErrorMessage(GetLastError));
        end;

       if CBFList.Count > 0 then
       begin
         for I := 0 to CBFList.Count-1 do
           begin
           exist:=ExtSaveClipboardFormat(cardinal(CBFList[i]), writer);
           FrmClpbrd:=cardinal(CBFList[i]);
          // frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: FrmClpbrd: '+inttostr(FrmClpbrd)+' SaveClipboardFormat='+booltostr(exist));
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
    frm_main.Log_Write('Clipboard',2,' ExtSaveClipboardToStream not result: ');
    // frm_main.Log_Write('Clipboard',SysErrorMessage(GetLastError));
   end;

 except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: Ошибка SaveClipboard: '+E.ClassName+': '+E.Message); end;
 end; { SaveClipboard }

 //------------------------------------------------------------------------------------------------------
function ExtLoadClipboard(S: TStream):boolean;
 var
   reader: TReader;
 begin
 try
   Assert(Assigned(S));
   reader := TReader.Create(S, 4096);
   try
     Clipboard.Open;
     try
       clipboard.Clear;
       reader.ReadListBegin;
       while not reader.EndOfList do
         result:=ExtLoadClipboardFormat(reader);
       reader.ReadListEnd;
     finally
       Clipboard.Close;
     end; { Finally }
   finally
     reader.Free
   end; { Finally }
  except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtLoadClipboard: Ошибка LoadClipboard: '+E.ClassName+': '+E.Message); end;
 end; { LoadClipboard }

//---------------------------------------------------------------------------------------------------


 procedure ExtClipBoardGetFiles(const Files: TStrings);
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

//----------------------------------------------------------------------------------------------

function ExtClipBoardTheFiles:boolean; // проверка буфера обмена на наличие файлов
var
WinHandle:hwnd;
OwnerClpb:hwnd;
begin
  try
    // OwnerClpb:=GetClipboardOwner; // определяем владельца буфера обмена
     //frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: OwnerClpb='+inttostr(OwnerClpb));
     //WinHandle:=ExtShellWindow;
    // frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: WinHandle='+inttostr(WinHandle));
     if not OpenClipboard(Application.Handle ) then //GetShellWindow     GetDesktopWindow
      frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: OpenClipboard=0 Error='+SysErrorMessage(GetLastError));
    //Clipboard.Open;
    try
    //result:=Clipboard.HasFormat(CF_HDROP);
    result:=IsClipboardFormatAvailable(CF_HDROP);
    finally
    //Clipboard.Close;
    CloseClipboard;
    end;

    if result then  frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: В буфере обнаружены файлы')
    else frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: В буфере не обнаружены файлы')

  except on E : Exception do// если ошибка то файлов точно нет
  begin
  frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: Ошибка ClipBoardTheFiles: '+E.ClassName+': '+E.Message);
  result:=false;
  end;
  end;

end;

//----------------------------------------------------------------
//---------------------------------------------------------------------

//------------------------------------------------------------------------
function GetWinlogonProcessId(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // Получаем ID процесса winlogon указанного сеанса SessionID пользователя с системными привилегиями SystemIntegrityLevel для Vista и выше или ID процесса пользователя system для XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  UserName: WideString;
  DomainName: WideString;
  IdProcSession:DWORD;
  handWin:Thandle;
begin
  Result := 0;
  try //Делает снимок указанных процессов, а также кучу, модулей и потоков, используемых этими процессами.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-ключает в снимок все процессы в системе. Чтобы перечислить процессы, см. Process32First . 0-идентификатор процесса, если 0 то текущий процесс, в данном лучае он игногируется и в снимок включаются все процессы
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// если функция завршилась не ошибкой
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 Описывает запись из списка процессов, находящихся в системном адресном пространстве на момент создания моментального снимка. //ProcessEntry32.dwSize Размер структуры в байтах. Перед вызовом функции Process32First установите для этого члена значение sizeof(PROCESSENTRY32). Если вы не инициализируете dwSize , Process32First завершится ошибкой.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //звлекает информацию о следующем процессе, записанном в моментальный снимок системы. ToolHelp32SnapShot-снимок, ProcessEntry32 -Указатель на структуру
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// если перичисленный процесс в снимке процессов = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // узнаем номер сеанса пользователя для данного процесса
          if not IdProcSession=SessionID then frm_main.Log_Write('Clipboard',2,'GetWinlogonProcessId - IdProcSession '+inttostr(IdProcSession)+ ' = SessionID '+inttostr(SessionID))// если он равен то данный процесс запущен в нужном нам сенсе, иначе продолжаем искать в снимке другой процесс
          else
            begin // получаем уровень привелегий IntegrityLevel в заданном процессе ProcessEntry32.th32ProcessID
              begin
                Result := ProcessEntry32.th32ProcessID;

                frm_main.Log_Write('Clipboard',2,'GetWinlogonProcessId - ID = '+inttostr(Result));
                Break;
              end;
            end
       end;
      finally
      CloseHandle(ToolHelp32SnapShot);
      end;
    end;
 except on E: Exception do
  frm_main.Log_Write('Clipboard',2,'Ошибка GetWinlogonProcessId: '+e.ClassName +': '+ e.Message);
 end;
end;
end.
