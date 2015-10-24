unit ProgressBar;

interface

uses Vcl.ComCtrls, Winapi.Messages, Vcl.Forms, Vcl.Graphics,
Windows, SysUtils, Classes, Vcl.Controls, Vcl.Dialogs, Winapi.UxTheme;

type
  TCMDProgressBar = class(TProgressBar)
    private
      FStepCount, FStepIndex, FStepPos, FStepMax : Integer;
      procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
      procedure setPosition(Value : Integer);
      procedure updateProgressBar;
    public
      constructor Create(AOwner: TComponent); override;
      procedure StartProcess(Amount : Integer);
      procedure FinishStep;
      procedure StartStep(Max : Integer);
      property StepPos : Integer read FStepPos write setPosition;
      property StepIndex : Integer read FStepIndex;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('CMD Controls', [TCMDProgressBar]);
end;

constructor TCMDProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.ShowHint := True;
  Self.DoubleBuffered := True;
end;

procedure TCMDProgressBar.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  Canvas : TCanvas;
  i : Integer;
  StepWidth: Double;
  PS : TPaintStruct;
begin
  MemDC := 0;
  DC := BeginPaint(Handle, PS);
  //MemBitmap := CreateCompatibleBitmap(DC, PS.rcPaint.Right - PS.rcPaint.Left,
        //PS.rcPaint.Bottom - PS.rcPaint.Top);
  try
    MemDC := CreateCompatibleDC(DC);
    //OldBitmap := SelectObject(MemDC, MemBitmap);
    try
      //SetWindowOrgEx(MemDC, PS.rcPaint.Left, PS.rcPaint.Top, nil);
      //Perform(WM_ERASEBKGND, MemDC, MemDC);
      Message.DC := DC;
      inherited;
      Canvas := TCanvas.Create;
      Canvas.Handle := DC;
      Canvas.Pen.Style := psDot;
      Canvas.Pen.Color := clBlack;
      Canvas.Brush.Style := bsClear;
      //Canvas.Pen.Mode := pmNot;
      if FStepCount = 0 then
        StepWidth := 0
      else
        StepWidth := Self.Width / FStepCount;
      for i := 1 to FStepCount-1 do
      begin
        Canvas.MoveTo(Round(StepWidth*i), 0);
        Canvas.LineTo(Round(StepWidth*i), Self.Height);
      end;
      //Message.DC := 0;
      //BitBlt(DC, PS.rcPaint.Left, PS.rcPaint.Top,
        //PS.rcPaint.Right - PS.rcPaint.Left,
        //PS.rcPaint.Bottom - PS.rcPaint.Top,
        //MemDC,
        //PS.rcPaint.Left, PS.rcPaint.Top, SRCCOPY);
    finally
      //SelectObject(MemDC, OldBitmap);
    end;
  finally
    EndPaint(Handle, PS);
    DeleteDC(MemDC);
    //DeleteObject(MemBitmap);
  end;
end;

procedure TCMDProgressBar.updateProgressBar;
var
StepWidth: Double;
TempPos : Integer;
begin
  Max := Self.Width;
  if FStepCount = 0 then
    StepWidth := 0
  else
    StepWidth := Self.Width / FStepCount;
  if FStepMax = 0 then
    TempPos := 0
  else
    TempPos := Round(FStepIndex * StepWidth) + Round(FStepPos/FStepMax * StepWidth);
  if TempPos <> Position then
    Position := TempPos;
  if FStepIndex = FStepCount then
    Hint := IntToStr(FStepIndex) + '/' + IntToStr(FStepCount) + ' ' + IntToStr(Round(Position/Max*100)) + '%'
  else
    Hint := IntToStr(FStepIndex+1) + '/' + IntToStr(FStepCount) + ' ' + IntToStr(Round(Position/Max*100)) + '%';
end;

procedure TCMDProgressBar.StartProcess(Amount : Integer);
begin
  FStepCount := Amount;
  FStepIndex := 0;
  FStepPos := 0;
  FStepMax := 1;
  updateProgressBar;
end;

procedure TCMDProgressBar.FinishStep;
begin
  FStepIndex := FStepIndex + 1;
  if FStepIndex > FStepCount then
    FStepIndex := FStepCount;
  FStepPos := 0;
  FStepMax := 1;
  updateProgressBar;
end;

procedure TCMDProgressBar.StartStep(Max : Integer);
begin
  FStepPos := 0;
  FStepMax := Max;
  updateProgressBar;
end;

procedure TCMDProgressBar.setPosition(Value : Integer);
begin
  FStepPos := Value;
  updateProgressBar;
end;


end.
