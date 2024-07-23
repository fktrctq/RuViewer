unit ShowProgressBar;

interface

//------------------------------------------------------------------------------
//
//      IProgress
//
//------------------------------------------------------------------------------
type
  TProgressStage = (psBegin, psProgress, psEnd);

  IProgress = interface
    ['{2D83C35C-72CF-4894-884D-FB1A776F136A}']
    procedure Progress(Stage: TProgressStage; CurrentProgress, MaxProgress: integer; const Msg: string; ProgressContext: pointer = nil); overload;
    procedure Progress(Stage: TProgressStage; CurrentProgress, MaxProgress: integer; ProgressContext: pointer = nil); overload;
    procedure AdvanceProgress(DeltaProgress: integer = 1; ProgressContext: pointer = nil);
    procedure UpdateMessage(const Msg: string);
    procedure Show;
    procedure Hide;
    procedure ProcessMessages;

    procedure AbortProgress;
    function GetEnableAbort: boolean;
    procedure SetEnableAbort(Value: boolean);
    property EnableAbort: boolean read GetEnableAbort write SetEnableAbort;
    procedure SuspendAbort;
    procedure ResumeAbort;
    function GetRaiseOnAbort: boolean;
    procedure SetRaiseOnAbort(Value: boolean);
    property RaiseOnAbort: boolean read GetRaiseOnAbort write SetRaiseOnAbort;
    function GetAborted: boolean;
    property Aborted: boolean read GetAborted;
    function GetMarquee: boolean;
    procedure SetMarquee(Value: boolean);
    property Marquee: boolean read GetMarquee write SetMarquee;
    function GetEnabled: boolean;
    procedure SetEnabled(Value: boolean);
    property Enabled: boolean read GetEnabled write SetEnabled; // Enabled=False prevents progress from being displayed
  end;

//------------------------------------------------------------------------------
//
//      ShowProgress()
//
//------------------------------------------------------------------------------
type
  TProgressFactory = function(const Title: string = ''; Defer: boolean = True): IProgress;

function ShowProgress(const Title: string = ''; Defer: boolean = True): IProgress; overload;


//------------------------------------------------------------------------------
//
//      Progress redirection
//
//------------------------------------------------------------------------------
function RegisterProgressHandler(const Factory: TProgressFactory): TProgressFactory;
function RegisterDefaultProgressHandler(const Factory: TProgressFactory): TProgressFactory;
function UnregisterProgressHandler(const Factory: TProgressFactory): TProgressFactory;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

var
  FProgressFactory: TProgressFactory = nil;
  FDefaultProgressFactory: TProgressFactory = nil;

function ShowProgress(const Title: string; Defer: boolean): IProgress;
begin
  Assert(Assigned(FProgressFactory));
  Result := FProgressFactory(Title, Defer);
end;

//------------------------------------------------------------------------------
//
//      RegisterProgressHandler
//
//------------------------------------------------------------------------------
function RegisterProgressHandler(const Factory: TProgressFactory): TProgressFactory;
begin
  Result := @FProgressFactory;

  FProgressFactory := Factory;

  if (FProgressFactory = nil) then
    FProgressFactory := FDefaultProgressFactory
  else
  if (not Assigned(FDefaultProgressFactory)) then
    RegisterDefaultProgressHandler(FProgressFactory);
end;

function RegisterDefaultProgressHandler(const Factory: TProgressFactory): TProgressFactory;
begin
  Result := @FDefaultProgressFactory;

  FDefaultProgressFactory := Factory;

  if (not Assigned(FProgressFactory)) then
    FProgressFactory := FDefaultProgressFactory;
end;


function UnregisterProgressHandler(const Factory: TProgressFactory): TProgressFactory;
begin
  Result := @FProgressFactory;

  if (@FProgressFactory = @Factory) then
    FProgressFactory := FDefaultProgressFactory;
end;


end.

