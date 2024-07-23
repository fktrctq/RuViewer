unit PipeS;

interface

uses
  Windows,
  Classes,
  Forms,
  SyncObjs,
  SysUtils
  ;

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

const
  PIPE_MESSAGE_SIZE = $20000;

{ TPipeServer }

constructor TPBPipeServer.Create(APath: string);
var
  sa: TSecurityAttributes;
  sd: TSecurityDescriptor;
  hEvent: THandle;
begin
    // Создаем дескриптор безопасности
  InitializeSecurityDescriptor(@sd,SECURITY_DESCRIPTOR_REVISION);
  // DACL не установлен - объект незащищен
  SetSecurityDescriptorDacl(@sd,true,nil,false);
  // Настраиваем атрибуты безопасности, передавая туда указатель на
  // дескриптор безопасности sd и создаем объект-событие
  sa.nLength:=SizeOf(TSecurityAttributes);
  sa.lpSecurityDescriptor:=@sd;
  sa.bInheritHandle:=false;
 // hEvent:=CreateEvent(@sa,true,false,'Global\evMyServerObject');

  FPath := APath;
  FShutdownEvent := TEvent.Create(@sa, True, False, '');

  FPipeHandle := CreateNamedPipe(
    PWideChar(FPath),
    PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT,
    PIPE_UNLIMITED_INSTANCES,
    SizeOf(Integer),
    PIPE_MESSAGE_SIZE,
    NMPWAIT_USE_DEFAULT_WAIT,
    @sa
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
    RaiseLastOSError;
end;

procedure TPBPipeClient.SendData(AData: string);
var
  bytesRead: Cardinal;
  success: boolean;
begin
  if not CallNamedPipe(PWideChar(FPath), PWideChar(AData), length(AData) * SizeOf(Char), @success, SizeOf(Integer), bytesRead, NMPWAIT_USE_DEFAULT_WAIT) then
    RaiseLastOSError;
end;

end.
