unit MyClpbrd;

interface

uses clipbrd, Winapi.Windows,ShellApi,TLHelp32, System.SysUtils, System.Classes,Vcl.Forms;


function ExtCopyStreamToClipboard(fmt: Cardinal; S: TStream):boolean;
function ExtCopyStreamFromClipboard(fmt: Cardinal; S: TStream):boolean;
function ExtSaveClipboardFormat(fmt: cardinal; writer: TWriter):boolean;
function ExtLoadClipboardFormat(reader: TReader):boolean;
function ExtSaveClipboardToStream(S: TStream; var FrmClpbrd:word):boolean;
function ExtLoadClipboard(S: TStream):boolean;
procedure ExtClipBoardGetFiles(const Files: TStrings); // ��������� ������ ������ �� ������ ������
function ExtClipBoardTheFiles:boolean; // �������� ������ ������ �� ������� ������


implementation
uses Form_main;
{const
  COINIT_MULTITHREADED = 0;
  COINIT_APARTMENTTHREADED = 2;
  COINIT_DISABLE_OLE1DDE =4;
  COINIT_SPEED_OVER_MEMORY =8; }
                    //������ ����������� � ������������ �������� ��� ������ �������.  Windows ���������� ������ ������ ����������� (�������): ������, �������, ������� � ���������.

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
       frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: ������ GlobalAlloc: '+SysErrorMessage(GetLastError()));
     end;
   end { If }
   else
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: ������ GlobalAlloc: '+SysErrorMessage(GetLastError()));
    end;
  except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamToClipboard: ������ ExtCopyStreamToClipboard: '+E.ClassName+': '+E.Message);
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
          frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: ������ GlobalLock: '+SysErrorMessage(GetLastError()));
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
      frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: ������ GetClipboardData=0 fmt='+inttostr(fmt)+' Error='+SysErrorMessage(GetLastError()));
     end;
  except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtCopyStreamFromClipboard: ������ CopyStreamFromClipboard: '+E.ClassName+': '+E.Message);
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
      frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardFormat: ������ ClipboardFormat: '+E.ClassName+': '+E.Message);
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
       frm_main.Log_Write('Clipboard',2,'ExtLoadClipboardFormat: ������ RegisterCLipboardFormat: '+SysErrorMessage(GetLastError()));
     end;
   finally
     ms.Free;
   end; { Finally }
 except on E : Exception do
    begin
    result:=false;
    frm_main.Log_Write('Clipboard',2,'ExtLoadClipboardFormat: ������ LoadClipboardFormat: '+E.ClassName+': '+E.Message);
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
    // OwnerClpb:=GetClipboardOwner; // ���������� ��������� ������ ������
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

 except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtSaveClipboardToStream: ������ SaveClipboard: '+E.ClassName+': '+E.Message); end;
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
  except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtLoadClipboard: ������ LoadClipboard: '+E.ClassName+': '+E.Message); end;
 end; { LoadClipboard }

//---------------------------------------------------------------------------------------------------


 procedure ExtClipBoardGetFiles(const Files: TStrings);
{
  �� ������ Ctrl+C ��� Ctrl+X => ������� ������ � ����� ������.
  ��� ��� ��� ������� ���������� ������ ������/�����, ������� ������� � �����.
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
    // OwnerClpb:=GetClipboardOwner; // ���������� ��������� ������ ������
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
   except on E : Exception do frm_main.Log_Write('Clipboard',2,'ExtClipBoardGetFiles: ������ ClipBoardGetFiles: '+E.ClassName+': '+E.Message); end;
  end;

//----------------------------------------------------------------------------------------------

function ExtClipBoardTheFiles:boolean; // �������� ������ ������ �� ������� ������
var
WinHandle:hwnd;
OwnerClpb:hwnd;
begin
  try
    // OwnerClpb:=GetClipboardOwner; // ���������� ��������� ������ ������
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

    if result then  frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: � ������ ���������� �����')
    else frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: � ������ �� ���������� �����')

  except on E : Exception do// ���� ������ �� ������ ����� ���
  begin
  frm_main.Log_Write('Clipboard',2,'ExtClipBoardTheFiles: ������ ClipBoardTheFiles: '+E.ClassName+': '+E.Message);
  result:=false;
  end;
  end;

end;

//----------------------------------------------------------------
//---------------------------------------------------------------------

//------------------------------------------------------------------------
function GetWinlogonProcessId(SessionID:dword;ProcessName:string): Cardinal;//winlogon.exe
var   // �������� ID �������� winlogon ���������� ������ SessionID ������������ � ���������� ������������ SystemIntegrityLevel ��� Vista � ���� ��� ID �������� ������������ system ��� XP
  ToolHelp32SnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
  UserName: WideString;
  DomainName: WideString;
  IdProcSession:DWORD;
  handWin:Thandle;
begin
  Result := 0;
  try //������ ������ ��������� ���������, � ����� ����, ������� � �������, ������������ ����� ����������.
    ToolHelp32SnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0); //TH32CS_SNAPPROCESS-������� � ������ ��� �������� � �������. ����� ����������� ��������, ��. Process32First . 0-������������� ��������, ���� 0 �� ������� �������, � ������ ����� �� ������������ � � ������ ���������� ��� ��������
    if ToolHelp32SnapShot <> INVALID_HANDLE_VALUE then //Log_Write('service','GetWinlogonProcessId - ToolHelp32SnapShot: '+SysErrorMessage(GetLastError()))// ���� ������� ���������� �� �������
    begin
      try
        ProcessEntry32.dwSize := SizeOf(TProcessEntry32); //ProcessEntry32 ��������� ������ �� ������ ���������, ����������� � ��������� �������� ������������ �� ������ �������� ������������� ������. //ProcessEntry32.dwSize ������ ��������� � ������. ����� ������� ������� Process32First ���������� ��� ����� ����� �������� sizeof(PROCESSENTRY32). ���� �� �� ��������������� dwSize , Process32First ���������� �������.
        while Process32Next(ToolHelp32SnapShot, ProcessEntry32) = True do  //�������� ���������� � ��������� ��������, ���������� � ������������ ������ �������. ToolHelp32SnapShot-������, ProcessEntry32 -��������� �� ���������
        begin
          if (LowerCase(ProcessEntry32.szExeFile) = ProcessName) then //Log_Write('service','GetWinlogonProcessId - '+LowerCase(ProcessEntry32.szExeFile)+' <> '+ProcessName)// ���� ������������� ������� � ������ ��������� = winlogon.exe
          if ProcessIdToSessionId(ProcessEntry32.th32ProcessID,IdProcSession) then //Log_Write('service','GetWinlogonProcessId - ProcessIdToSessionId') // ������ ����� ������ ������������ ��� ������� ��������
          if not IdProcSession=SessionID then frm_main.Log_Write('Clipboard',2,'GetWinlogonProcessId - IdProcSession '+inttostr(IdProcSession)+ ' = SessionID '+inttostr(SessionID))// ���� �� ����� �� ������ ������� ������� � ������ ��� �����, ����� ���������� ������ � ������ ������ �������
          else
            begin // �������� ������� ���������� IntegrityLevel � �������� �������� ProcessEntry32.th32ProcessID
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
  frm_main.Log_Write('Clipboard',2,'������ GetWinlogonProcessId: '+e.ClassName +': '+ e.Message);
 end;
end;
end.
