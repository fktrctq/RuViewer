unit StreamManager;


interface

uses
  Windows, Classes, {Graphics,}jpeg,System.SysUtils,vcl.forms,Vcl.Graphics,pngimage;

procedure GetScreenToMemoryStreamJpeg(DrawCur,resize: Boolean; Width, Height:integer; TargetMemoryStream: TMemoryStream);//original
function ScreenPNGSaveStream(srcMon:integer; inDC:string{HDC}; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream):boolean; //save png to stream
function ScreenBMPSaveStream(srcMon:integer; inDC:string; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream):boolean; // screen bmp save to stream
function ScreenBmpCanvasSaveStream(srcMon:integer; inDC:HDC; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream; Mybmp: TBitmap; DrawCur:boolean;pixF:TPixelFormat):boolean;
function ScreenBmpCanvasSaveBMP(MonX,MonY,MonWidth,MonHeight:integer; inDC:HDC; resizes:boolean; wR,hR:integer;Mybmp: TBitmap; DrawCur:boolean; pixF:TPixelFormat; var TimeCompare:Double):boolean; // screen bmp save to bmp
procedure GetScreenToMemoryStreamOriginal(DrawCur: Boolean; TargetMemoryStream: TMemoryStream);

procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeResume:string);
procedure ResumeStreamXOR(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);
procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeCompare:string);
procedure MyCompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeCompare:string);
procedure CompareStreamXOR(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);

Procedure NoLineCompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream; var ResStr:string; var TimeResume:Double);
Procedure CompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream; var ResStr:string; var TimeResume:Double);
procedure ResumeStreamXORBMP(var   FirstBMP,     CompareBMP:Tbitmap; var SecondBMP:TmemoryStream; var ResStr:string; var SecondSize:int64; var TimeResume:double);


procedure ResizeBmp(bmp: TBitmap; Width, Height: Integer);
function FResizeBmp(bmp: TBitmap; Width, Height: Integer):Tbitmap;

implementation
uses Form_main;

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



// Resize the Bitmap ( Best quality )  ��������� ������� ���������� ����������� (������ ��������)
function FResizeBmp(bmp: TBitmap; Width, Height: Integer):Tbitmap;

begin
  result := TBitmap.Create;
  try
      result.PixelFormat:=bmp.PixelFormat;
      result.Width  := Width;
      result.Height := Height;
      SetStretchBltMode(result.Canvas.Handle, HALFTONE);
      StretchBlt(result.Canvas.Handle, 0, 0, result.Width, result.Height, bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, SRCCOPY);

  finally
    result.Free;
  end;
end;

procedure ResizeBmp(bmp: TBitmap; Width, Height: Integer);
var
  SrcBMP : TBitmap;
  DestBMP: TBitmap;
begin
  SrcBMP := TBitmap.Create;
  try
    SrcBMP.Assign(bmp);
    DestBMP := TBitmap.Create;
    try
      DestBMP.Width  := Width;
      DestBMP.Height := Height;
      SetStretchBltMode(DestBMP.Canvas.Handle, HALFTONE);
      StretchBlt(DestBMP.Canvas.Handle, 0, 0, DestBMP.Width, DestBMP.Height, SrcBMP.Canvas.Handle, 0, 0, SrcBMP.Width, SrcBMP.Height, SRCCOPY);
      bmp.Assign(DestBMP);
    finally
      DestBMP.Free;
    end;
  finally
    SrcBMP.Free;
  end;
end;
//////////////////////////////////////////////////////////

function ScreenPNGSaveStream(srcMon:integer; inDC:string{HDC}; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream):boolean; //save file or stream
var
  DC,bmpDC    : HDC;
  GDWhWnd     :HWND;
  bmp,oldbmp  : HBITMAP;
  x0,y0,h,w,nScreenWidth,nScreenHeight,wTMP,hTMP:integer;
  //png1 : TPNGObject;
  res:boolean;
function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
  begin
    dec(Alignment);
    Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result shr 3;
  end;
const
CAPTUREBLT = $40000000;
begin
{  GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
  DC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
  try
    begin
    x0:=screen.Monitors[srcMon].Left;
    y0:=screen.Monitors[srcMon].Top;
    w:=screen.Monitors[srcMon].Width;
    h:=screen.Monitors[srcMon].Height;
    bmpDC  := CreateCompatibleDC(DC); //������� �������� ���������� ������ (DC), ����������� � ��������� �����������.
    bmp    := CreateCompatibleBitmap(DC, w, h);//������� ��������� �����������, ����������� � �����������, ��������� � ��������� ���������� ����������.
    oldbmp := SelectObject(bmpDC, bmp); //�������� ������ � ��������� ��������� ���������� (DC). ����� ������ �������� ���������� ������ ���� �� ����.
    try
     if resizes then begin wTMP:=wR; hTMP:=hR end else begin wTMP:=w; hTMP:=h end; // ����� �������� ������� ������ ���������� ������ ������� ��� ������������ TPNGObject
     with TPNGObject.CreateBlank(COLOR_RGB,16,wTMP,hTMP)do // COLOR_RGB- https://documentation.help/PNG-Delphi/tpngobjectcreateblank.htm
     begin
       if resizes then
       begin
       if SetStretchBltMode(bmpDC, HALFTONE)<>0 then//COLORONCOLOR HALFTONE  BLACKONWHITE
        SetBrushOrgEx    (bmpDC, 0,0, NIL); // use else HALFTONE
       res:=StretchBlt(canvas.Handle, 0, 0, wTMP, hTMP, DC, x0, y0, w, h, SRCCOPY or CAPTUREBLT);
       end
         else res:=BitBlt(canvas.Handle, 0,0,W,H, DC, x0,y0, SRCCOPY or CAPTUREBLT);
       SaveToStream(TargetMemoryStream);
       Free;
     end;
    finally
      DeleteObject(SelectObject(bmpDC, oldbmp));
    end;
    end;
  finally
    releaseDC(GDWhWnd, DC);
  end;
  result:=res;  }
end;
//---------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////
function ScreenBmpCanvasSaveStream(srcMon:integer; inDC:HDC; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream; Mybmp: TBitmap; DrawCur:boolean; pixF:TPixelFormat):boolean; // screen bmp save to stream
var
  bmpDC,DC : HDC;
  GDWhWnd:HWND;
  bmp,oldbmp  : HBITMAP;
  hDesktop: HDESK;
  x0,y0,h,w,nScreenWidth,nScreenHeight,hTMP,wTMP:integer;
  res:boolean;
  step:integer;
  //////////////////
  Cursorx, Cursory: Integer;
  R               : TRect;
  DrawPos         : TPoint;
  MyCursor        : TIcon;
  hld             : hwnd;
  Threadld        : dword;
  mp              : TPoint;
  pIconInfo       : TIconInfo;
const
CAPTUREBLT = $40000000;
begin
try

 step:=0;
  GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
  DC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
  //dc:=GetDCEx(0,DCX_INTERSECTRGN,DCX_WINDOW);
 step:=1;
  try
    begin
  step:=2;
    x0:=screen.Monitors[srcMon].Left;
    y0:=screen.Monitors[srcMon].Top;
    w:=screen.Monitors[srcMon].Width;
    h:=screen.Monitors[srcMon].Height;
 step:=3;
    if resizes then
     begin
     wTMP:=wR; hTMP:=hR;
     end
    else
     begin
     wTMP:=w; hTMP:=h;
     end;
 step:=4;
    Mybmp.Canvas.Lock;
    Mybmp.PixelFormat := pixF; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom
    Mybmp.Width  := wTMP;
    Mybmp.Height := hTMP;
 step:=5;
    //bmpDC  := CreateCompatibleDC(DC); //������� �������� ���������� ������ (DC), ����������� � ��������� �����������.
    //bmp    := CreateCompatibleBitmap(DC, w, h);//������� ��������� �����������, ����������� � �����������, ��������� � ��������� ���������� ����������.
    //oldbmp := SelectObject(bmpDC, bmp); //�������� ������ � ��������� ��������� ���������� (DC). ����� ������ �������� ���������� ������ ���� �� ����.
      try
         if resizes then
        begin
 step:=6;
        if SetStretchBltMode({bmpDC}Mybmp.Canvas.Handle, HALFTONE)<>0 then;//COLORONCOLOR HALFTONE  BLACKONWHITE
        SetBrushOrgEx    ({bmpDC}Mybmp.Canvas.Handle, 0,0, NIL); // use else HALFTONE
        res:=StretchBlt(Mybmp.Canvas.Handle, 0, 0, wTMP, hTMP, DC, x0, y0, w, h, SRCCOPY);
        end
       else
        res:=BitBlt(Mybmp.Canvas.Handle, 0, 0, w, h, DC, x0, y0, SRCCOPY);
 step:=7;
        if DrawCur then
          begin
            GetCursorPos(DrawPos);
            MyCursor := TIcon.Create;
            GetCursorPos(mp);
            hld      := WindowFromPoint(mp);
            Threadld := GetWindowThreadProcessId(hld, nil);
            AttachThreadInput(GetCurrentThreadId, Threadld, True);
            MyCursor.Handle := Getcursor();
            AttachThreadInput(GetCurrentThreadId, Threadld, False);
            GetIconInfo(MyCursor.Handle, pIconInfo);
            Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
            Cursory := DrawPos.y - round(pIconInfo.yHotspot);
            Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
            DeleteObject(pIconInfo.hbmColor);
            DeleteObject(pIconInfo.hbmMask);
            MyCursor.ReleaseHandle;
            MyCursor.Free;
          end;
    //Mybmp.PixelFormat := pixF; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom

    Mybmp.SaveToStream(TargetMemoryStream);
    step:=8;
    Mybmp.Canvas.Unlock;
    finally
      //DeleteObject(SelectObject(bmpDC, oldbmp));
      //DeleteObject(bmp);
    end;
    end;
  finally
   releaseDC(GDWhWnd,DC);
   step:=9;
    //releaseDC(0,bmpDC)
  end;

except on E : Exception do
begin
res:=false;
Log_write('ThD',inttostr(step)+') - ������ ScreenBmpCanvasSaveStream: '+E.ClassName+': '+E.Message);
end;
end;
result:=res;
end;
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ScreenBMPSaveStream(srcMon:integer; inDC:string{HDC}; resizes:boolean; wR,hR:integer;TargetMemoryStream: TMemoryStream):boolean; // screen bmp save to stream
var
  DC,bmpDC : HDC;
  GDWhWnd:HWND;
  bmp,oldbmp  : HBITMAP;
  x0,y0,h,w,nScreenWidth,nScreenHeight,hTMP,wTMP:integer;
   bm        : Windows.TBitmap;
  pBitmap   : Pointer;
  BFH       : BITMAPFILEHEADER;
  BI        : BITMAPINFO;
  BitCount      : Word;
 // FileHandle    : THandle;
  Size, Count  : DWORD;
  colorsize:integer;
  res:boolean;
function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
  begin
    dec(Alignment);
    Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result shr 3;
  end;
const
CAPTUREBLT = $40000000;
begin
  GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
  DC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
  try
    begin
    x0:=screen.Monitors[srcMon].Left;
    y0:=screen.Monitors[srcMon].Top;
    w:=screen.Monitors[srcMon].Width;
    h:=screen.Monitors[srcMon].Height;
    if resizes then
     begin
     wTMP:=wR; hTMP:=hR;
     end
    else
     begin
     wTMP:=w; hTMP:=h;
     end;
    bmpDC  := CreateCompatibleDC(DC); //������� �������� ���������� ������ (DC), ����������� � ��������� �����������.
    bmp    := CreateCompatibleBitmap(DC, w, h);//������� ��������� �����������, ����������� � �����������, ��������� � ��������� ���������� ����������.
    oldbmp := SelectObject(bmpDC, bmp); //�������� ������ � ��������� ��������� ���������� (DC). ����� ������ �������� ���������� ������ ���� �� ����.
      try
         if resizes then
        begin
        if SetStretchBltMode(bmpDC, HALFTONE)<>0 then;//COLORONCOLOR HALFTONE  BLACKONWHITE
        SetBrushOrgEx    (bmpDC, 0,0, NIL); // use else HALFTONE
        res:=StretchBlt(bmpDC, 0, 0, wTMP, hTMP, DC, x0, y0, w, h, SRCCOPY);
        end
       else
        res:=BitBlt(bmpDC, 0, 0, w, h, DC, x0, y0, SRCCOPY);
        ///////////////////////////////////////////////////////////////////API save file bmp
          GetObject(bmp, Sizeof(bm), @bm);
          Size := BytesPerScanLine(wTMP, bm.bmBitsPixel, 32) * hTMP;
          BitCount := bm.bmPlanes * bm.bmBitsPixel;
          if (BitCount <> 24) then ColorSize := SizeOf(TRGBQuad) * (1 shl BitCount) else ColorSize := 0;
          GetMem(pBitmap, Size);
          try
          FillChar(BI, SizeOf(BI), 0);
          with BI.bmiHeader do
          begin
            biSize          := SizeOf(BITMAPINFOHEADER);
            biWidth         := wTMP;
            biHeight        := hTMP;
            biPlanes        := 1;
            biBitCount      := BitCount;
            biSizeImage     := Size;
            if (BitCount < 16) then biClrUsed     := (1 shl BitCount);
          end;

          FillChar(BFH, SizeOf(BFH), 0);
          BFH.bfOffBits:=SizeOf(BFH) + SizeOf(TBitmapInfo) + ColorSize;
          BFH.bfType    := $4D42;
          BFH.bfOffBits := SizeOf(BFH) + SizeOf(BITMAPINFOHEADER) + BI.bmiHeader.biClrUsed * SizeOf(RGBQUAD);
          BFH.bfSize    := BFH.bfOffBits + Size;
          GetDIBits(DC, bmp, 0, hTMP, pBitmap, BI, DIB_RGB_COLORS);

         ////////////////////////////////// write memorystream
          TargetMemoryStream.WriteBuffer(BFH, SizeOf(BFH));
          TargetMemoryStream.WriteBuffer((BI), SizeOf(TBitmapInfo) +ColorSize );
          TargetMemoryStream.WriteBuffer(pBitmap^, Size);
          finally
          FreeMem(pBitmap)
          end;
      /////////////////////////////////////////////////////////////////////////////////////
    finally
      DeleteObject(SelectObject(bmpDC, oldbmp));
      DeleteObject(bmp);
    end;
    end;
  finally
    releaseDC(GDWhWnd, DC);
    releaseDC(0,bmpDC)
  end;
result:=res;
end;
//////////////////////////////////////////////////////////////////////////////////
procedure GetScreenToMemoryStreamOriginal(DrawCur: Boolean; TargetMemoryStream: TMemoryStream);
const
  CAPTUREBLT = $40000000;
var
  Mybmp           : TBitmap;
  Cursorx, Cursory: Integer;
  dc              : hdc;
  R               : TRect;
  DrawPos         : TPoint;
  MyCursor        : TIcon;
  hld             : hwnd;
  Threadld        : dword;
  mp              : TPoint;
  pIconInfo       : TIconInfo;
  hDesktop: HDESK;
  step:string;
  GDWhWnd:HWND;
  RhDC:HDC;
begin

  Mybmp := TBitmap.Create;
  try
  hDesktop := OpenInputDesktop(0, true, MAXIMUM_ALLOWED); //��������� ������� ����, ���������� ������� ������ ������������.   //https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openinputdesktop
   if hDesktop <> 0 then
    begin
      SetThreadDesktop(hDesktop); //��������� ��������� ������� ���� ����������� ������. //https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddesktop
      CloseHandle(hDesktop);
    end;
   GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
   RhDC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
   //dc := GetWindowDC(0);  //��������
    R            := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
    Mybmp.Width  := R.Right;
    Mybmp.Height := R.Bottom;
    BitBlt(Mybmp.Canvas.Handle, 0, 0, Mybmp.Width, Mybmp.Height, RhDC, 0, 0, SRCCOPY or CAPTUREBLT);
    //BitBlt(Mybmp.Canvas.Handle, 0, 0, Mybmp.Width, Mybmp.Height, dc, 0, 0, SRCCOPY or CAPTUREBLT); //��������
  finally
     releaseDC(GDWhWnd, RhDC);
    //releaseDC(0, dc);  //��������
  end;

  if DrawCur then
  begin
    GetCursorPos(DrawPos);
    MyCursor := TIcon.Create;
    GetCursorPos(mp);
    hld      := WindowFromPoint(mp);
    Threadld := GetWindowThreadProcessId(hld, nil);
    AttachThreadInput(GetCurrentThreadId, Threadld, True);
    MyCursor.Handle := Getcursor();
    AttachThreadInput(GetCurrentThreadId, Threadld, False);
    GetIconInfo(MyCursor.Handle, pIconInfo);
    Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
    Cursory := DrawPos.y - round(pIconInfo.yHotspot);
    Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
    DeleteObject(pIconInfo.hbmColor);
    DeleteObject(pIconInfo.hbmMask);
    MyCursor.ReleaseHandle;
    MyCursor.Free;
  end;
  Mybmp.PixelFormat := pfDevice; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom
  // ResizeBMP(Mybmp, Width, Height);
  TargetMemoryStream.Clear;
  Mybmp.SaveToStream(TargetMemoryStream);
  Mybmp.Free;

end;
//////////////////////////////////////////////////////////////////////////////////
// Screenshot to jpeg
procedure GetScreenToMemoryStreamJpeg(DrawCur,resize: Boolean; Width, Height:integer; TargetMemoryStream: TMemoryStream);
const
  CAPTUREBLT = $40000000;
var
  Mybmp           : TBitmap;
  Cursorx, Cursory: Integer;
  dc              : hdc;
  R               : TRect;
  DrawPos         : TPoint;
  MyCursor        : TIcon;
  hld             : hwnd;
  Threadld        : dword;
  mp              : TPoint;
  pIconInfo       : TIconInfo;
  hDesktop: HDESK;
  step:string;
  GDWhWnd:HWND;
  RhDC:HDC;
  /////////////
  //Jpegimg:TJpegImage;
begin
try
  step:='1';
  Mybmp := TBitmap.Create;
  //Jpegimg:=TJpegImage.Create;
  GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
  RhDC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
   step:='2';
  //RhDC := GetWindowDC(0);  //��������
  try
  hDesktop := OpenInputDesktop(0, true, MAXIMUM_ALLOWED); //��������� ������� ����, ���������� ������� ������ ������������.   //https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openinputdesktop
   if hDesktop <> 0 then
    begin
     step:='3';
      SetThreadDesktop(hDesktop); //��������� ��������� ������� ���� ����������� ������. //https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddesktop
      CloseHandle(hDesktop);
    end;
    step:='4';
    R            := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
    Mybmp.Width  := R.Right;
    Mybmp.Height := R.Bottom;
    Mybmp.PixelFormat := pfDevice; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom
    step:='5';
    if not BitBlt(Mybmp.Canvas.Handle, 0, 0, Mybmp.Width, Mybmp.Height, RhDC, 0, 0, SRCCOPY or CAPTUREBLT) then
    Log_write('app','BitBlt: '+SysErrorMessage(GetLastError()));
    //BitBlt(Mybmp.Canvas.Handle, 0, 0, Mybmp.Width, Mybmp.Height, dc, 0, 0, SRCCOPY or CAPTUREBLT); //��������


  if DrawCur then
  begin
    GetCursorPos(DrawPos);
    MyCursor := TIcon.Create;
    GetCursorPos(mp);
    hld      := WindowFromPoint(mp);
    Threadld := GetWindowThreadProcessId(hld, nil);
    AttachThreadInput(GetCurrentThreadId, Threadld, True);
    MyCursor.Handle := Getcursor();
    AttachThreadInput(GetCurrentThreadId, Threadld, False);
    GetIconInfo(MyCursor.Handle, pIconInfo);
    Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
    Cursory := DrawPos.y - round(pIconInfo.yHotspot);
    Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
    DeleteObject(pIconInfo.hbmColor);
    DeleteObject(pIconInfo.hbmMask);
    MyCursor.ReleaseHandle;
    MyCursor.Free;
  end;
   if resize then ResizeBMP(Mybmp,Width, Height);
   ////////////////////////////////////////////////// jpeg
   step:='9';
  // Jpegimg.Assign(Mybmp);
   step:='10';
   //Jpegimg.CompressionQuality:=50;
   //Jpegimg.Compress;
   step:='11';
   TargetMemoryStream.Clear;
   TargetMemoryStream.Position:=0;
  // Jpegimg.SaveToStream(TargetMemoryStream);
   step:='12';
   ////////////////////////////////////////////bmp
  //TargetMemoryStream.Clear;
  //TargetMemoryStream.Position:=0;
  //Mybmp.SaveToStream(TargetMemoryStream);

  step:='13';
 ////////////////////////////////////////////
   finally
     Mybmp.Free;
    // Jpegimg.Free;
     step:='14';
     releaseDC(GDWhWnd, RhDC);
     //releaseDC(0, dc);  //��������
  end;
except on E : Exception do   Log_write('ThD',step+'-������ GetScreenToMemoryStream: '+E.ClassName+': '+E.Message);
    end;

end;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function ScreenBmpCanvasSaveBMP(MonX,MonY,MonWidth,MonHeight:integer; inDC:HDC; resizes:boolean; wR,hR:integer; Mybmp: TBitmap; DrawCur:boolean; pixF:TPixelFormat; var TimeCompare:Double):boolean; // screen bmp save to bmp
var
  bmpDC,DC : HDC;
  GDWhWnd:HWND;
  bmp,oldbmp  : HBITMAP;
  hDesktop: HDESK;
  x0,y0,h,w,nScreenWidth,nScreenHeight,hTMP,wTMP:integer;
  res,ParamRead:boolean;
  step:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
  //////////////////
  Cursorx, Cursory: Integer;
  R               : TRect;
  DrawPos         : TPoint;
  MyCursor        : TIcon;
  hld             : hwnd;
  Threadld        : dword;
  mp              : TPoint;
  pIconInfo       : TIconInfo;
const
CAPTUREBLT = $40000000;
begin
try
  //QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
 // QueryPerformanceCounter(T1); //������� ����� ������ ��������
 step:=0;
  GDWhWnd:=GetDesktopWindow();// ��������� ���������� ���� �������� �����. ���� �������� ����� �������� ���� �����. ���� �������� ����� � ��� �������, ������ ������� �������� ������ ����.
  DC:=GetWindowDC(GDWhWnd); //��������� �������� ���������� (DC) ��� ����� ����, ������� ������ ���������, ���� � ������ ���������.
 step:=1;
  try
    begin
  step:=2;
      try
      x0:=MonX;
      y0:=MonY;
      w:=MonWidth;
      h:=MonHeight;
      ParamRead:=true;
      except on E : Exception do
       begin
       Log_write('ThD',inttostr(step)+') - ������ ScreenBmpCanvasSaveStream ParamRead: '+E.ClassName+': '+E.Message);
       Log_write('ThD','x0='+inttostr(x0)+' y0='+inttostr(y0)+' w='+inttostr(w)+' h='+inttostr(h));
       ParamRead:=false;
       res:=false;
       end;
      end;
     step:=3;
      if ParamRead then
       Begin
          if resizes then
           begin
           wTMP:=wR; hTMP:=hR;
           end
          else
           begin
           wTMP:=w; hTMP:=h;
           end;
       step:=4;
          Mybmp.Canvas.Lock;
           try
            Mybmp.PixelFormat := pixF; //pfDevice pf4bit pf8bit pf15bit  pf16bit  pf24bit pf132bit pfCustom
            Mybmp.Width  := wTMP;
            Mybmp.Height := hTMP;
            step:=5;
                 if resizes then
                begin
            step:=6;
                if SetStretchBltMode({bmpDC}Mybmp.Canvas.Handle, HALFTONE)<>0 then;//COLORONCOLOR HALFTONE  BLACKONWHITE
                SetBrushOrgEx({bmpDC}Mybmp.Canvas.Handle, 0,0, NIL); // use else HALFTONE
                res:=StretchBlt(Mybmp.Canvas.Handle, 0, 0, wTMP, hTMP, DC, x0, y0, w, h, SRCCOPY);
                end
               else
                res:=BitBlt(Mybmp.Canvas.Handle, 0, 0, w, h, DC, x0, y0, SRCCOPY);
            step:=7;
               { if DrawCur then
                  begin
                    GetCursorPos(DrawPos);
                    MyCursor := TIcon.Create;
                    GetCursorPos(mp);
                    hld      := WindowFromPoint(mp);
                    Threadld := GetWindowThreadProcessId(hld, nil);
                    AttachThreadInput(GetCurrentThreadId, Threadld, True);
                    MyCursor.Handle := Getcursor();
                    AttachThreadInput(GetCurrentThreadId, Threadld, False);
                    GetIconInfo(MyCursor.Handle, pIconInfo);
                    Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
                    Cursory := DrawPos.y - round(pIconInfo.yHotspot);
                    Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
                    DeleteObject(pIconInfo.hbmColor);
                    DeleteObject(pIconInfo.hbmMask);
                    MyCursor.ReleaseHandle;
                    MyCursor.Free;
                  end;}
            step:=8;
           finally
           Mybmp.Canvas.Unlock;
           end;
        End;
     end;
    step:=9;
  finally
   releaseDC(GDWhWnd,DC);
  end;
   step:=10;
 // QueryPerformanceCounter(T2);//������� ����� ���������
 // TimeCompare:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
 //  if  not res then Log_write('ThD','������ Screen:' +SysErrorMessage(GetLastError()));
  except on E : Exception do
    begin
    res:=false;
    Log_write('ThD',inttostr(step)+') - ������ ScreenBmpCanvasSaveStream: '+E.ClassName+': '+E.Message);
    end;
  end;
result:=res;
end;
////////////////////////////////////////////////////////////////////////////////////////////////////////


procedure MyCompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeCompare:string);
const
  Block_Size = 2048;
var
  I : Integer;
  P1: ^AnsiChar;
  P2: ^AnsiChar;
  P3: ^AnsiChar;
  Buffer_1: array[0..Block_Size-1] of byte;
  Buffer_2: array[0..Block_Size-1] of byte;
  Buffer_Length: integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
  QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
  QueryPerformanceCounter(T1); //������� ����� ������ ��������
  // Check if the resolution has been changed    ���������, �� ���������� �� ����������
  if MyFirstStream.Size <> MySecondStream.Size then
  begin
    MyFirstStream.LoadFromStream(MySecondStream);
    MyCompareStream.LoadFromStream(MySecondStream);
    Exit;
  end;
  MyFirstStream.Position:=0;
  MySecondStream.Position:=0;
  MyCompareStream.Clear;
  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;

  while MyFirstStream.Position < MyFirstStream.Size do
  begin
    Buffer_Length := MyFirstStream.Read(Buffer_1, Block_Size);
    MySecondStream.Read(Buffer_2, Block_Size);
    if not CompareMem(@Buffer_1, @Buffer_2, Buffer_Length) then // ���� ����� ������ � ������� �� �����
     begin
      for I := MyFirstStream.Position to MyFirstStream.Position+Buffer_Length-1 do
        begin
        P3^ := P2^;   // ��������� MyCompareStream
        Inc(P1);
        Inc(P2);
        Inc(P3);
        end;
     end
     else
      begin
      FillChar(P3^, Block_Size * sizeof(char), '0');
      Inc(P1,Block_Size);
      Inc(P2,Block_Size);
      Inc(P3,Block_Size);
      end;
    { for I := MyFirstStream.Position to MyFirstStream.Position+Buffer_Length-1 do
       begin
       P3^ := '0';
       Inc(P1);
       Inc(P2);
       Inc(P3);
       end; }
  end;
  MyFirstStream.LoadFromStream(MySecondStream);
  QueryPerformanceCounter(T2);//������� ����� ���������
  TimeCompare:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
end;

// Compare Streams and separate when the Bitmap Pixels are equal.
// �������� ������ � ��������� ��, ���� ������� ���������� ����������� �����.
procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeCompare:string);
var
  I : Integer;
  P1: ^AnsiChar;
  P2: ^AnsiChar;
  P3: ^AnsiChar;
     iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
  QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
  QueryPerformanceCounter(T1); //������� ����� ������ ��������
  // Check if the resolution has been changed    ���������, �� ���������� �� ����������
  if MyFirstStream.Size <> MySecondStream.Size then
  begin
    MyFirstStream.LoadFromStream(MySecondStream);
    MyCompareStream.LoadFromStream(MySecondStream);
    Exit;
  end;
  MyCompareStream.Clear;
  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;
  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P1^ = P2^ then // ���� ������� ����������� ����������� � �������� �����
      P3^ := '0'    // ��������� ��� ����� � MyCompareStream
    else
      P3^ := P2^;   // ��������� MyCompareStream
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;

  MyFirstStream.LoadFromStream(MySecondStream);
  QueryPerformanceCounter(T2);//������� ����� ���������
  TimeCompare:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
end;

// Modifies Streams to set the Pixels of Bitmap       �������� ������, ����� ���������� ������� ���������� �����������
procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream; var TimeResume:string);
var
  I : Integer;
  P1: ^AnsiChar;
  P2: ^AnsiChar;
  P3: ^AnsiChar;
   iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
  QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
  QueryPerformanceCounter(T1); //������� ����� ������ ��������
  // Check if the resolution has been changed    ���������, �� ���������� �� ����������
  if MyFirstStream.Size <> MyCompareStream.Size then
  begin
    MyFirstStream.LoadFromStream(MyCompareStream);
    MySecondStream.LoadFromStream(MyCompareStream);
    Exit;
  end;
  P1 := MyFirstStream.Memory;
  MySecondStream.SetSize(MyFirstStream.Size);
  P2 := MySecondStream.Memory;
  P3 := MyCompareStream.Memory;
  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P3^ = '0' then
      P2^ := P1^
    else
      P2^ := P3^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;

  MyFirstStream.LoadFromStream(MySecondStream);
  MySecondStream.Position := 0;
  QueryPerformanceCounter(T2);//������� ����� ���������
  TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
end;

//--------------------------------------XOR BMP

// ���������� ����� ���� �� �������
function GetBytesPerPixel(APixelFormat: Vcl.Graphics.TPixelFormat): Byte; overload;
const
  ByteCounts: array [Vcl.Graphics.TPixelFormat] of Byte =
    (4,0,0,1,2,2,3,4,2);
begin
  Result := ByteCounts[APixelFormat];
end;


//-------------------------------------------------------------------------------------------------------
Procedure NoLineCompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream; var ResStr:string; var TimeResume:Double);
var
  I,Z,X,Y,BytesPerPixel : Integer;
  ScanBytes   : Integer;
  P1: ^byte; // ��������� �� byte ���������� Pbyte
  P2: ^byte;
  P3: ^byte;
  h,w:integer;
  step:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
   try
   //QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
  // QueryPerformanceCounter(T1); //������� ����� ������ ��������
   step:=0;
      if (MyFirstBMP.Width<>MySecondBMP.Width) or (MyFirstBMP.Height<>MySecondBMP.Height) or (MyFirstBMP.PixelFormat<>MySecondBMP.PixelFormat)  then
      begin
      step:=1;
      CompareBMP.Position:=0;
      MySecondBMP.SaveToStream(CompareBMP);
      MyFirstBMP.Assign(MySecondBMP);
      step:=2;
      end
     else
      Begin
       step:=3;
       MySecondBMP.Canvas.Lock;
       MyFirstBMP.Canvas.Lock;
         try
         step:=4;
         ScanBytes := Abs(Integer(MyFirstBMP.Scanline[1]) - Integer(MyFirstBMP.Scanline[0])); // ���������� ������ ����� ����� ��������
         BytesPerPixel:=GetBytesPerPixel(MyFirstBMP.PixelFormat);  // ���������� ���������� ���� �� �������
         step:=5;
         h:=MyFirstBMP.Height;
         w:=MyFirstBMP.Width;
         ResStr:='ScanBytes='+inttostr(ScanBytes)+' BytesPerPixel='+inttostr(BytesPerPixel)+' h/w='+inttostr(h)+'/'+inttostr(w);
         CompareBMP.SetSize(ScanBytes*h*BytesPerPixel); // ������ ������ � ������������ � �������� ������� (ScanBytes(������ ����� ����� ��������)*������*���-�� ���� �� �������)
         CompareBMP.Position:=0;
         P3 := CompareBMP.Memory;
         P1 := MyFirstBMP.Scanline[0]; //������ � Bitmap ����������� � �����, ������� ��� ��������� ��������� �� 0� ������ �� ��������� � ����� �����
         P2 := MySecondBMP.Scanline[0];
         step:=6;
          for i:= 0 to h-1 do
            Begin
             if CompareMem(P1,P2,ScanBytes) then // ���� ��� ��������� � ������ �������� ���� ��� ���������, ������ ��������� � ������ ������� ������ ���
               begin
                step:=7;
               ZeroMemory(P3,ScanBytes); // ��������� � �������������� ������ ��� ������ ������
               inc(P3,ScanBytes);
               Dec(P2,ScanBytes); // ������� �� ��������� ������ Bitmap. ������ � Bitmap ����������� � �����, ������� ��� ��������� ��������� �� 0� ������ �� ��������� � ����� �����
               Dec(P1,ScanBytes); // ������� �� ��������� ������ Bitmap
               step:=8;
               end
             else // ����� ��������� ������ ������� � ����� ���
               begin
                for X := 0 to w-1 do
                 begin
                  for Y := 0 to BytesPerPixel - 1 do
                    begin
                    step:=9;
                    P3^:=P1^ XOR P2^;
                    inc(P3);
                    inc(P1);
                    inc(P2);
                    step:=10;
                    end;
                 end;
               step:=11;
               Dec(P2,(w*BytesPerPixel)+ScanBytes);  // ������� �� ��������� ������ Bitmap � ������ ���� ��� �� ������ � ����� ������ � �� � ������
               Dec(P1,(w*BytesPerPixel)+ScanBytes);  // ������� �� ��������� ������ Bitmap � ������ ���� ��� �� ������ � ����� ������ � �� � ������
               step:=12;
               end;
            End;
         step:=13;
         MyFirstBMP.Assign(MySecondBMP);
         step:=14;
         finally
         MySecondBMP.Canvas.UnLock;
         MyFirstBMP.Canvas.UnLock;
         //p1:=nil;
         //p2:=nil;
         //p3:=nil;
         end;
        step:=15;
      end;
     // QueryPerformanceCounter(T2);//������� ����� ���������
    //  TimeResume:=(T2 - T1)/iCounterPerSec;
    except on E : Exception do
      begin
       MySecondBMP.Canvas.UnLock;
       MyFirstBMP.Canvas.UnLock;
       ResStr:=ResStr+' step='+inttostr(step)+' Error: '+E.ClassName+': '+E.Message;
      end;
    end;
end;
//-------------------------------------------------------------------------------------------------------
Procedure CompareStreamXORBMP(var MyFirstBMP, MySecondBMP:Tbitmap; var CompareBMP:TmemoryStream; var ResStr:string; var TimeResume:Double);             //MyCompareBMP
var
  I,Z,X,Y,BytesPerPixel,Rtmp,HW : Integer;
  ScanBytes   : Integer;
  P1: ^byte; // ��������� �� byte ���������� Pbyte
  P2: ^byte;
  P3: ^byte;
  h,w:integer;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
begin
  //QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
 // QueryPerformanceCounter(T1); //������� ����� ������ ��������
  if (MyFirstBMP.Width<>MySecondBMP.Width) or (MyFirstBMP.Height<>MySecondBMP.Height) or (MyFirstBMP.PixelFormat<>MySecondBMP.PixelFormat)  then
  begin
    CompareBMP.Position:=0;
    MySecondBMP.SaveToStream(CompareBMP);
    MyFirstBMP.Assign(MySecondBMP);
  end
  else
  Begin
   MySecondBMP.Canvas.Lock;
   MyFirstBMP.Canvas.Lock;
   ScanBytes := Abs(Integer(MyFirstBMP.Scanline[1]) - Integer(MyFirstBMP.Scanline[0])); // ���������� ������ ����� ����� ��������
   BytesPerPixel:=GetBytesPerPixel(MyFirstBMP.PixelFormat);  // ���������� ���������� ���� �� �������
   h:=MyFirstBMP.Height;
   w:=MyFirstBMP.Width;
   hw:=h*w;
   ResStr:='ScanBytes='+inttostr(ScanBytes)+' BytesPerPixel='+inttostr(BytesPerPixel)+' h/w='+inttostr(h)+'/'+inttostr(w);
   CompareBMP.SetSize(ScanBytes*h*BytesPerPixel); // ������ ������ � ������������ � �������� ������� (ScanBytes(������ ����� ����� ��������)*������*���-�� ���� �� �������)
   CompareBMP.Position:=0;
   P3 := CompareBMP.Memory;
    for i:=0 to h-1 do
     Begin
       if CompareMem(MyFirstBMP.ScanLine[i],MySecondBMP.ScanLine[i],ScanBytes) then // ���� ��� ��������� � ������ �������� ���� ��� ���������, ������ ��������� � ������ ������� ������ ���
         begin  // ��������� � �������������� ������ ��� ������ ������
         ZeroMemory(P3,ScanBytes);
         inc(P3,ScanBytes);
         end
       else // ����� ��������� ������ ������� � ����� ���
         begin
         P1 := MyFirstBMP.Scanline[I];
         P2 := MySecondBMP.Scanline[I];
          for X := 0 to w-1 do
           for Y := 0 to BytesPerPixel - 1 do // 1, to 4, dep. on pixelformat
            begin
            P3^:=P1^ XOR P2^;
            Inc(P1);
            Inc(P2);
            Inc(P3);
            end;
         end;
     End;
  MyFirstBMP.Assign(MySecondBMP);
  MySecondBMP.Canvas.UnLock;
  MyFirstBMP.Canvas.UnLock;
  end;
 //QueryPerformanceCounter(T2);//������� ����� ���������
//TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
end;


procedure ResumeStreamXORBMP( var   FirstBMP,     CompareBMP:Tbitmap; var SecondBMP:TmemoryStream; var ResStr:string; var SecondSize:int64; var TimeResume:double);
var                           //������ �������� - ������������         - ����� ������� ������
  I,X,Y,ScanBytes,BytesPerPixel : Integer;
  h,w:integer;
  P1: ^byte;
  P2: ^byte;
  P3: ^byte;
  ZeroArray : Array of byte;
  iCounterPerSec: TLargeInteger;
  T1, T2: TLargeInteger; //�������� �������� �� � ����� ��������
  step:integer;
  function LengthScanLine:integer; // ���������� ������ ����� ����� ��������
  begin
    try
    result:=Abs(Integer(FirstBMP.Scanline[1]) - Integer(FirstBMP.Scanline[0])); // ���������� ������ ����� ����� ��������
      except on E : Exception do
      begin
      ResStr:=ResStr+' LengthScanLine: result='+inttostr(result)+' Error: '+E.ClassName+': '+E.Message+' |'
      end;
    end;
  end;
begin
  try
   //QueryPerformanceFrequency(iCounterPerSec);//�������� ������� ��������
   //QueryPerformanceCounter(T1); //������� ����� ������ ��������
   step:=0;
   if (SecondSize<>0) and (SecondSize<>SecondBMP.Size) then // ���� ������ ���������� ������ �� ����� �����������, �� �������� ���������� ����������
    begin
    step:=1;
    SecondSize:=SecondBMP.Size;
    SecondBMP.Position:=0;
    CompareBMP.LoadFromStream(SecondBMP);
    SecondBMP.Position:=0;
    FirstBMP.LoadFromStream(SecondBMP);
    step:=2;
    end
   else
     begin
     step:=3;
      FirstBMP.Canvas.lock;
      CompareBMP.Canvas.Lock;
       try
       step:=4;
       SecondSize:=SecondBMP.Size; // ��������� ������ ����������� ������ ��� ������������ ���������
       step:=5;
       ScanBytes :=LengthScanLine; // ���������� ������ ����� ����� ��������
       step:=6;
       BytesPerPixel:=GetBytesPerPixel(FirstBMP.PixelFormat);  // ���������� ���������� ���� �� �������
       step:=7;
       h:=FirstBMP.Height;
       step:=8;
       w:=FirstBMP.Width;
       step:=9;
       ResStr:='ScanBytes='+inttostr(ScanBytes)+' BytesPerPixel='+inttostr(BytesPerPixel)+' h/w='+inttostr(h)+'/'+inttostr(w)+' SecondSize='+inttostr(SecondSize);
       SecondBMP.Position:=0; // ����������� �������
       P3:=SecondBMP.Memory;
       step:=10;
       SetLength(ZeroArray,ScanBytes); // ������ �������� �������
       ZeroMemory(ZeroArray,ScanBytes); // �������� ������
       step:=11;
        for i:=0 to h-1 do
          Begin
           if CompareMem(ZeroArray,P3,ScanBytes) then // ���� ��� ��������� � ������ �������� ���� ��� ��������� (�������� �� ������ ������)
            begin  //  ������ ��������� � ������ ������� �� �������������. �� ���������� ������ ������ ��� ���������� ��������
            inc(P3,ScanBytes);
            step:=12;
            end
           else // ����� ��������� ������ ������� � ����� ���
             begin
             P1 := FirstBMP.Scanline[I];
             P2 := CompareBMP.Scanline[I];
             step:=13;
              for X := 0 to w-1 do
               for Y := 0 to BytesPerPixel - 1 do // 1, to 4, dep. on pixelformat
                begin
                P2^:=P3^ XOR P1^;
                Inc(P1);
                Inc(P2);
                Inc(P3);
                end;
             end;
          step:=14;
          End;
       step:=15;
       FirstBMP.Assign(CompareBMP);
       ZeroArray:=nil;
       step:=16;
       finally
       FirstBMP.Canvas.Unlock;
       CompareBMP.Canvas.UnLock;
       end;
       step:=17;
     end;
     step:=18;
   //QueryPerformanceCounter(T2);//������� ����� ���������
   //TimeResume:=FormatFloat('0.0000', (T2 - T1)/iCounterPerSec) + ' ���.';
   step:=19;
  except on E : Exception do
    begin
     FirstBMP.Canvas.Unlock;
     CompareBMP.Canvas.UnLock;
     ResStr:=' ('+inttostr(step)+') '+ResStr+' Error: '+E.ClassName+': '+E.Message+' |';
    end;
  end;

end;
//-------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------

procedure ResumeStreamXOR(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);
var                          //����������      �������       ������������
  I : Integer;
  P1: ^byte;
  P2: ^byte;
  P3: ^byte;
begin
  //    ��������, �� ���������� �� ����������
  if MyFirstStream.Size <> MySecondStream.Size then
  begin
    MyFirstStream.LoadFromStream(MySecondStream);
    MyCompareStream.LoadFromStream(MySecondStream);
    Exit;
  end;
  P1 := MyFirstStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P2 := MyCompareStream.Memory;
  P3 := MySecondStream.Memory;
  for I := 0 to MyFirstStream.Size - 1 do
  begin
     P2^ := P3^ XOR P1^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;
  MyFirstStream.LoadFromStream(MyCompareStream);
  MyCompareStream.Position := 0;
end;

//----------------------------------------------XOR
procedure CompareStreamXOR(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);
var
  I : Integer;
  P1: ^byte;
  P2: ^byte;
  P3: ^byte;
begin
  // Check if the resolution has been changed    ���������, �� ���������� �� ����������
  if MyFirstStream.Size <> MySecondStream.Size then
  begin
    MyFirstStream.LoadFromStream(MySecondStream);
    MyCompareStream.LoadFromStream(MySecondStream);
    Exit;
  end;
  MyCompareStream.Clear;
  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;
  for I := 0 to MyFirstStream.Size - 1 do
  begin
    P3^:=P1^ XOR P2^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
   end;
  MyFirstStream.LoadFromStream(MySecondStream);
end;



end.

