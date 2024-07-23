unit PipeS;

interface

uses
  Windows,
  Classes,
  Forms,
  SyncObjs,
  SysUtils  ;

type
  TPBPipeServerReceivedDataEvent = procedure(AData: string) of object;

  TPBPipeServer = class
  private
    type
      TPBPipeServerThread = class(TThread)
      private
        FServer: TPBPipeServer;
      protected
      public
        procedure Execute; override;
        property  Server: TPBPipeServer read FServer;
      end;
  private
    FOnReceivedData: TPBPipeServerReceivedDataEvent;
    FPath: string;
    FPipeHandle: THandle;
    FShutdownEvent: TEvent;
    FThread: TPBPipeServerThread;
  protected
  public
    constructor Create(APath: string);
    destructor Destroy; override;

    property  Path: string read FPath;

    property  OnReceivedData: TPBPipeServerReceivedDataEvent read FOnReceivedData write FOnReceivedData;
  end;

  TPBPipeClient = class
  private
    FPath: string;
  protected
  public
    constructor Create(APath: string);
    destructor Destroy; override;

    property  Path: string read FPath;

    procedure SendData(AData: string); overload;
    class procedure SendData(APath, AData: string); overload;
  end;

implementation
 uses Form_Main;
const
  PIPE_MESSAGE_SIZE = $20000;

{ TPipeServer }

constructor TPBPipeServer.Create(APath: string);
begin
  FPath := APath;

  FShutdownEvent := TEvent.Create(nil, True, False, '');

  FPipeHandle := CreateNamedPipe(
    PWideChar(FPath),
    PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT,
    PIPE_UNLIMITED_INSTANCES,
    SizeOf(Integer),
    PIPE_MESSAGE_SIZE,
    NMPWAIT_USE_DEFAULT_WAIT,
    nil
  );

  if FPipeHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  FThread := TPBPipeServerThread.Create(true);
  FThread.FreeOnTerminate := false;
  FThread.FServer := self;
  FThread.Resume;
end;

destructor TPBPipeServer.Destroy;
begin
  FShutdownEvent.SetEvent;
  FreeAndNil(FThread);
  CloseHandle(FPipeHandle);
  FreeAndNil(FShutdownEvent);

  inherited;
end;


/// Log File
function Log_write(fname:string;NumError:integer; TextMessage:string):string;
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
        while f.Count>1000 do f.Delete(1000);
          f.SaveToFile(ExtractFilePath(Application.ExeName)+'log\'+fname+'.log');
        finally
          f.Destroy;
        end;
      End;
    except on E : Exception do
      begin
      exit;
      //showmessage('Ошибка записи в лог файл');
      end;
    end;
end;
///////////////////////////////////
{ TPipeServer.TPipeServerThread }

procedure TPBPipeServer.TPBPipeServerThread.Execute;
var
  ConnectEvent, ReadEvent: TEvent;
  events: THandleObjectArray;
  opconnect, opread: TOverlapped;
  Signal: THandleObject;
  buffer: TBytes;
  bytesRead, error: Cardinal;
begin
  inherited;

  //SetThreadName('TPBPipeServer.TPBPipeServerThread');

  ConnectEvent := TEvent.Create(nil, False, False, '');
  try
    setlength(events, 2);
    events[1] := Server.FShutdownEvent;

    FillMemory(@opconnect, SizeOf(TOverlapped), 0);
    opconnect.hEvent := ConnectEvent.Handle;

    while not Terminated do
    begin
      ConnectNamedPipe(Server.FPipeHandle, @opconnect);

      events[0] := ConnectEvent;
      THandleObject.WaitForMultiple(events, INFINITE, False, Signal);
      if Signal = ConnectEvent then
      try
        // successful connect!
        ReadEvent := TEvent.Create(nil, True, False, '');
        try
          FillMemory(@opread, SizeOf(TOverlapped), 0);
          opread.hEvent := ReadEvent.Handle;
          setlength(buffer, PIPE_MESSAGE_SIZE);

          if not ReadFile(Server.FPipeHandle, buffer[0], PIPE_MESSAGE_SIZE, bytesRead, @opread) then
          begin
            error := GetLastError;
            if error = ERROR_IO_PENDING then
            begin
              if not GetOverlappedResult(Server.FPipeHandle, opread, bytesRead, True) then
                error := GetLastError
              else
                error := ERROR_SUCCESS;
            end;
            if error = ERROR_BROKEN_PIPE then
              // ignore, but discard data
              bytesRead := 0
            else if error = ERROR_SUCCESS then
              // ignore
            else
              RaiseLastOSError(error);
          end;

          if (bytesRead > 0) and Assigned(Server.OnReceivedData) then
            Server.OnReceivedData(TEncoding.Unicode.GetString(buffer, 0, bytesRead));

          // Set result to 1
          PInteger(@buffer[0])^ := 1;
          if not WriteFile(Server.FPipeHandle, buffer[0], SizeOf(Integer), bytesRead, @opread) then
          begin
            error := GetLastError;
            if error = ERROR_IO_PENDING then
            begin
              if not GetOverlappedResult(Server.FPipeHandle, opread, bytesRead, True) then
                error := GetLastError
              else
                error := ERROR_SUCCESS;
            end;
            if error = ERROR_BROKEN_PIPE then
              // ignore
            else if error = ERROR_SUCCESS then
              // ignore
            else
              RaiseLastOSError(error);
          end;
        finally
          FreeAndNil(ReadEvent);
        end;
      finally
        DisconnectNamedPipe(Server.FPipeHandle);
      end
      else if Signal = Server.FShutdownEvent then
      begin
        // server is shutting down!
        Terminate;
      end;
    end;
  finally
    FreeAndNil(ConnectEvent);
  end;
end;

{ TPBPipeClient }

constructor TPBPipeClient.Create(APath: string);
begin
  FPath := APath;
end;

destructor TPBPipeClient.Destroy;
begin

  inherited;
end;

class procedure TPBPipeClient.SendData(APath, AData: string);
var
  bytesRead: Cardinal;
  success: Integer;
begin
  if not CallNamedPipe(PWideChar(APath), PWideChar(AData), length(AData) * SizeOf(Char), @success, SizeOf(Integer), bytesRead, NMPWAIT_USE_DEFAULT_WAIT) then
   begin
   PipeS.Log_write('app',2,'SendData error: '+SysErrorMessage(GetLastError()));;
    //RaiseLastOSError;
   end;
end;

procedure TPBPipeClient.SendData(AData: string);
var
  bytesRead: Cardinal;
  success: boolean;
begin
  if not CallNamedPipe(PWideChar(FPath), PWideChar(AData), length(AData) * SizeOf(Char), @success, SizeOf(Integer), bytesRead, NMPWAIT_USE_DEFAULT_WAIT) then
   begin
   PipeS.Log_write('app',2,'SendData error: '+SysErrorMessage(GetLastError()));;
    //RaiseLastOSError;
   end;
end;

end.
