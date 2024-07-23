unit ScanKey;
interface
uses
  SysUtils, Windows, Messages,Vcl.Forms,System.Classes;
function SendScanKeys(SendKeysString: PChar): Boolean;
function SendCharKeys(SendKeysString: String): Boolean;
function PressACS(VSkey,UpDown:dword):boolean;
Procedure GetLocale; // Определение локали Windows, вызывается один раз при запуске приложения
function AppActivate(WindowName: PChar): Boolean; overload;
function AppActivate(WindowHandle: HWND): Boolean; overload;
{ Buffer for working with PChar's }
const
  WorkBufLen = 40;
  VK_OEM_AUTO = 243;
var
  WorkBuf: array[0..WorkBufLen] of Char;
  WinLocale:HKL;
  WindowHandle: HWND;
  NumL,CapsL,ScrollL:boolean;
implementation
type
  THKeys = array[0..pred(MaxLongInt)] of byte;
var
  AllocationSize: integer;

function Log_write(fname, text:string):string;
var f:TStringList;
begin
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
end;
/////////////////////////////////////////

////////// Locale Windows
Procedure GetLocale; // Определение локали Windows, вызывается один раз при запуске приложения
var
wLang :PChar;
Nsize:integer;
Buffer : PChar;
res:HKL;
MKey:word;
begin
try
  try
  GetMem(wLang,LOCALE_NAME_MAX_LENGTH);
  GetSystemDefaultLocaleName(wLang,Nsize);
  Nsize:=GetLocaleInfoEx(LOCALE_NAME_SYSTEM_DEFAULT, LOCALE_ILANGUAGE, nil, 0);   //LOCALE_ILANGUAGE
  GetMem(Buffer, NSize * SizeOf(Char));
  GetLocaleInfoEx(LOCALE_NAME_SYSTEM_DEFAULT,LOCALE_ILANGUAGE,Buffer,NSize);      //LOCALE_ILANGUAGE
  WinLocale:=LoadKeyboardLayout(Buffer,KLF_ACTIVATE);
  finally
  freemem(Buffer);
  end;
 except on E : Exception do
   Log_write('app','Ошибка GetLocale: '+E.ClassName+': '+E.Message);
 end;
end;
////////////////////////////////////////////////////////////////////// Функция принимает  виртуальный код клавиши
function PressACS(VSkey,UpDown:dword):boolean;
begin
     if UpDown=0 then
     begin
      if (GetAsyncKeyState(VSkey) <>-32767) then
      keybd_event(VSkey, 0, 0, 0);
     end;
     if UpDown=KEYEVENTF_KEYUP then
     begin
      if (GetAsyncKeyState(VSkey) <>0) then
       keybd_event(VSkey, 0, KEYEVENTF_KEYUP, 0);
     end;
end;

function SendCharKeys(SendKeysString: string): Boolean;
var
 sTmp:string;
  Lres,Hres:dword;
  Skey,Scode:integer;
procedure SendKey(Vkey,ScanCode:dword);
  var
  IpKey:  Tinput;
  KeyPr: TKeybdInput;
  KeyBoardState: TKeyboardState;
 begin
   if (VKey = VK_NUMLOCK{144}) then //NumLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[vk_NumLock]=0))or((KeyBoardState[vk_NumLock]=1)) then
        begin
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey,0);
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(vk_NumLock)=1 then // после виртуального нажатия возвращает предыдущее состояние клавиши, почему ХЗ. Если проверить после то будет 1-вкл 0-выкл
         NumL:=true else NumL:=false;
        end;
      end
     else
     if (VKey = VK_CAPITAL{20}) then //CapsLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_CAPITAL]=0))or((KeyBoardState[VK_CAPITAL]=1)) then
        begin
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_CAPITAL)=1 then CapsL:=true
        else CapsL:=false;
        end;
      end
    else
       if (VKey = VK_SCROLL{145}) then //ScrollLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_SCROLL]=0))or((KeyBoardState[VK_SCROLL]=1)) then
        begin
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_SCROLL)=1 then ScrollL:=true
        else ScrollL:=false;
        end;
      end
  else
  begin
  KeyPr.wVk:=Vkey;
  KeyPr.wScan:=ScanCode;  //скан код физической клавиши.
  KeyPr.dwFlags:=0; //идентифицирует ключ как Down
  ZeroMemory(@IpKey,sizeof(IpKey));
  IpKey.Itype:=INPUT_KEYBOARD;
  ipKey.ki:=KeyPr;
  SendInput(1,ipKey,sizeOf(ipKey));
  KeyPr.dwFlags:=KEYEVENTF_KEYUP;
  ipKey.ki:=KeyPr;
  SendInput(1,ipKey,sizeOf(ipKey));
  end;
end;
BEGIN
sTmp:=copy(SendKeysString,1,pos(',',SendKeysString)-1);
if not trystrtoint(sTmp,Skey) then exit // если первые знаки до запятой не цифры то выходим
else
  begin
  Lres:=Lo(Skey); // в младшем байте хранится виртуальный ключ нажатой клавиши
  Hres:=Hi(Skey); // в старшем байте хранится состояние спец клавиш
  end;
sTmp:=copy(SendKeysString,pos(',',SendKeysString)+1,length(SendKeysString));
if trystrtoint(sTmp,SCode) then // получаем код сканирования клавиши
begin
 if Hres<>0 then  // нажимаем спец клавиши если старший байт не равен 0
   case Hres of
   1:if not CapsL then PressACS(VK_RSHIFT,0); // если CapsLock не нажат
   2:PressACS(VK_RCONTROL,0);
   4:PressACS(VK_RMENU,0);
   8:PressACS(VK_OEM_AUTO,0); //клавиша Hankaku - 0xF3 или 243
   end;
  SendKey(lres,Scode); // отправляем виртуальный ключ и скан ключ клавиши
 if Hres<>0 then  // отпускаем спец клавиши если старший байт не равен 0
   case Hres of
   1:if not CapsL then PressACS(VK_RSHIFT,KEYEVENTF_KEYUP); // если capslock не нажат
   2:PressACS(VK_RCONTROL,KEYEVENTF_KEYUP);
   4:PressACS(VK_RMENU,KEYEVENTF_KEYUP);
   8:PressACS(VK_OEM_AUTO,KEYEVENTF_KEYUP); //клавиша Hankaku - 0xF3 или 243
   end;
end;
//Log_Write('app',SendKeysString);
//Log_Write('app','Получаем Skey-'+inttostr(Skey)+': Scode-'+inttostr(Scode)+': Lres-'+inttostr(Lres));
END;


///////////////////////////////////////////////////////////////////////////// функция принимает код сканирования клавиши
function SendScanKeys(SendKeysString: PChar): Boolean;
var
  UsingParens, ShiftDown, ControlDown, AltDown, FoundClose: Boolean;
  PosSpace: byte;
  I, L,TmpStr: integer;
  NumTimes, MKey: Word;
  KeyString: string[20];
  procedure SendKeyDown(VKey: byte);
  var
    Cnt: Word;
    ScanCode: byte;
    KeyBoardState: TKeyboardState;
    IpKey:  Tinput;
    //IpKey: array [0..1] of Tinput;
    KeyPr: TKeybdInput;
  begin
    if (VKey = 69{VK_NUMLOCK}) then //NumLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[vk_NumLock]=0))or((KeyBoardState[vk_NumLock]=1)) then
        begin
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey,0);
        keybd_event(vk_NumLock,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(vk_NumLock)=1 then NumL:=true
        else NumL:=false;
        end;
      end
     else
     if (VKey = 58{VK_CAPITAL}) then //CapsLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_CAPITAL]=0))or((KeyBoardState[VK_CAPITAL]=1)) then
        begin
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_CAPITAL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_CAPITAL)=1 then CapsL:=true
        else CapsL:=false;

        end;
      end
    else
       if (VKey = 70{VK_SCROLL}) then //ScrollLock
      begin
      GetKeyBoardState(KeyBoardState);  //Копирует состояние 256 виртуальных ключей в указанный буфер.
      if ((KeyBoardState[VK_SCROLL]=0))or((KeyBoardState[VK_SCROLL]=1)) then
        begin
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey,0);
        keybd_event(VK_SCROLL,0,KeyEventF_ExtendedKey or KeyEventF_KeyUp,0);
        if GetKeyState(VK_SCROLL)=1 then ScrollL:=true
        else ScrollL:=false;
        end;
      end
    else
      begin
        KeyPr.wVk:=0;
        KeyPr.wScan:=VKey;  //символ Unicode, как код сканирования клавиши который должен быть отправлен в приложение переднего плана.
        //if NumL then KeyPr.dwFlags:=KEYEVENTF_SCANCODE or KEYEVENTF_EXTENDEDKEY else
        KeyPr.dwFlags:=KEYEVENTF_SCANCODE; //идентифицирует ключ как код сканирования
        ZeroMemory(@IpKey,sizeof(IpKey));
        IpKey.Itype:=INPUT_KEYBOARD;
        ipKey.ki:=KeyPr;
        SendInput(1,ipKey,sizeOf(ipKey));
       { KeyPr.wVk:=0;
        KeyPr.wScan:=VKey;  //символ Unicode, который должен быть отправлен в приложение переднего плана.
        KeyPr.dwFlags:=KEYEVENTF_SCANCODE or KEYEVENTF_KEYUP;
        IpKey.Itype:=INPUT_KEYBOARD;
        ipKey.ki:=KeyPr;
        SendInput(1,ipKey,sizeOf(ipKey));}
      end;
  end;
BEGIN
  if trystrtoint(SendKeysString,tmpstr) then
  begin
  SendKeyDown(tmpstr);
  end;

END;
////////////////////////////////////////////////////////////////////////////////////////////////////////////
{ AppActivate
 Это используется для установки текущего фокуса ввода на данное окно, используя его
  имя. Это особенно полезно для обеспечения того, чтобы окно было активным перед
  отправка ему входных сообщений с помощью функции SendKeys. Вы можете указать
  имя окна полностью или только его часть, начиная с
  левый.
}

function EnumWindowsProc(WHandle: HWND; lParam: lParam): BOOL; export; stdcall;
var
  WindowName: array[0..MAX_PATH] of Char;
begin
  { Can't test GetWindowText's return value since some windows don't have a title }
  GetWindowText(WHandle, WindowName, MAX_PATH);
  Result := (StrLIComp(WindowName, PChar(lParam), StrLen(PChar(lParam))) <> 0);
  if (not Result) then
    WindowHandle := WHandle;
end;

function AppActivate(WindowHandle: HWND): Boolean; overload;
begin
  try
    SendMessage(WindowHandle, WM_SYSCOMMAND, SC_HOTKEY, WindowHandle);
    SendMessage(WindowHandle, WM_SYSCOMMAND, SC_RESTORE, WindowHandle);
    Result := SetForegroundWindow(WindowHandle);
  except
    on Exception do
      Result := False;
  end;
end;

function AppActivate(WindowName: PChar): Boolean; overload;
begin
  try
    Result := True;
    WindowHandle := FindWindow(nil, WindowName);
    if (WindowHandle = 0) then
      EnumWindows(@EnumWindowsProc, integer(PChar(WindowName)));
    if (WindowHandle <> 0) then
    begin
      SendMessage(WindowHandle, WM_SYSCOMMAND, SC_HOTKEY, WindowHandle);
      SendMessage(WindowHandle, WM_SYSCOMMAND, SC_RESTORE, WindowHandle);
      SetForegroundWindow(WindowHandle);
    end
    else
      Result := False;
  except
    on Exception do
      Result := False;
  end;
end;


end.
