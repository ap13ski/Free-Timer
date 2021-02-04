unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Unix, LCLType, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonStart: TButton;
    CheckBoxRepeat: TCheckBox;
    CheckBoxPopup: TCheckBox;
    ComboBoxMode: TComboBox;
    LabelCountdown: TLabel;
    LabelHoursCount: TLabel;
    LabelMinutes: TLabel;
    LabelHours: TLabel;
    LabelSeconds: TLabel;
    LabelMinutesCount: TLabel;
    LabelSecondsCount: TLabel;
    TimerGlobal: TTimer;
    TrackBarMinutes: TTrackBar;
    TrackBarHours: TTrackBar;
    TrackBarSeconds: TTrackBar;
    procedure ButtonStartClick(Sender: TObject);
    procedure ComboBoxModeChange(Sender: TObject);
    procedure TimerGlobalTimer(Sender: TObject);
    procedure TrackBarHoursChange(Sender: TObject);
    procedure TrackBarMinutesChange(Sender: TObject);
    procedure TrackBarSecondsChange(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  tHours, tMinutes, tSeconds: Integer;
  tSecondsTotal: Integer;
  tSelectedTime: Integer;
  bActivated: Boolean;
  sName: String = 'Free Timer';
  sH: String = ' h ';
  sM: String = ' m ';
  sS: String = ' s ';
  fH, fM, fS: String;
  var sPath: AnsiString;

implementation

{$R *.lfm}

{ TForm1 }

function LMinutes(): Integer;
begin
  LMinutes := Trunc(tSecondsTotal / 60);
end;

function RHours(): Integer;
begin
  RHours := Trunc(tSecondsTotal / 3600);
end;

function RMinutes(): Integer;
begin
  RMinutes := LMinutes() - RHours() * 60;
end;

function RSeconds(): Integer;
begin
  RSeconds := tSecondsTotal - LMinutes() * 60;
end;

procedure UpdateLabelCountdown();
begin
  if (RHours() > 9) then fH := IntToStr(RHours())
  else fH := '0' + IntToStr(RHours());
  if (RMinutes() > 9) then fM := IntToStr(RMinutes())
  else fM := '0' + IntToStr(RMinutes());
  if (RSeconds() > 9) then fS := IntToStr(RSeconds())
  else fS := '0' + IntToStr(RSeconds());
  Form1.LabelCountdown.Caption := fH + ':' + fM + ':' + fS;
end;

procedure CheckTimeZero();
begin
  if tSecondsTotal = 0 then Form1.ButtonStart.Enabled := False
  else Form1.ButtonStart.Enabled := True;
end;

procedure UpdateFormCaption();
begin
  if tSecondsTotal = 0 then
    Form1.Caption := sName;
  if (tSecondsTotal < 60) and (tSecondsTotal <> 0) then
    Form1.Caption :=
    IntToStr(tSecondsTotal) + sS +
    '- ' + sName;
  if (tSecondsTotal >= 60) and (tSecondsTotal < 3600) then
    Form1.Caption :=
    IntToStr(LMinutes()) + sM +
    IntToStr(RSeconds()) + sS +
    '- ' + sName;
  if (tSecondsTotal >= 3600) then
    Form1.Caption :=
    IntToStr(RHours()) + sH +
    IntToStr(RMinutes()) + sM +
    IntToStr(RSeconds()) + sS +
    '- ' + sName;
end;

procedure UpdateTrackBars();
begin
  Form1.TrackBarHours.Position := RHours();
  Form1.TrackBarMinutes.Position := RMinutes();
  Form1.TrackBarSeconds.Position := RSeconds();
end;

procedure UpdateLabels();
begin
  Form1.LabelHoursCount.Caption := IntToStr(RHours());
  Form1.LabelMinutesCount.Caption := IntToStr(RMinutes());
  Form1.LabelSecondsCount.Caption := IntToStr(RSeconds());
  UpdateLabelCountdown();
end;

procedure SetHMSFromTrackbars();
begin
  tHours := Form1.TrackBarHours.Position;
  tMinutes := Form1.TrackBarMinutes.Position;
  tSeconds := Form1.TrackBarSeconds.Position;
end;

procedure ResetStateRepeat();
begin
  tSecondsTotal := tSelectedTime;
  UpdateTrackBars();
  UpdateLabels();
  SetHMSFromTrackbars();
  UpdateFormCaption();
  Form1.TimerGlobal.Enabled := True;
end;

procedure SetTimerActivatedState(bState: Boolean);
begin
  bActivated := bState;
  Form1.TimerGlobal.Enabled := bState;
end;

procedure SetElementsEnabledState(bState: Boolean);
begin
  Form1.TrackBarHours.Enabled := bState;
  Form1.TrackBarMinutes.Enabled := bState;
  Form1.TrackBarSeconds.Enabled := bState;
  Form1.LabelHours.Enabled := bState;
  Form1.LabelHoursCount.Enabled := bState;
  Form1.LabelMinutes.Enabled := bState;
  Form1.LabelMinutesCount.Enabled := bState;
  Form1.LabelSeconds.Enabled := bState;
  Form1.LabelSecondsCount.Enabled := bState;
  Form1.ComboBoxMode.Enabled := bState;
  Form1.CheckBoxRepeat.Enabled:= bState;
  Form1.CheckBoxPopup.Enabled:= bState;
end;

procedure CheckRepeatPopupState();
begin
  if Form1.ComboBoxMode.ItemIndex = 0 then
    begin
      Form1.CheckBoxRepeat.Enabled := True;
      Form1.CheckBoxPopup.Enabled := True;
    end
  else
  begin
    Form1.CheckBoxRepeat.Enabled := False;
    Form1.CheckBoxRepeat.Checked := False;
    Form1.CheckBoxPopup.Enabled := False;
    Form1.CheckBoxPopup.Checked := False;
  end;
end;

procedure ResetState();
begin
  Form1.ButtonStart.Caption := 'Start';
  SetTimerActivatedState(False);
  SetElementsEnabledState(True);
  CheckRepeatPopupState();
  CheckTimeZero();
end;

procedure ActivateTimer();
begin
  tSelectedTime := tSecondsTotal;
  Form1.ButtonStart.Caption := 'Stop';
  SetTimerActivatedState(True);
  SetElementsEnabledState(False);
end;

procedure Execute();
begin
  if Form1.ComboBoxMode.ItemIndex = 0 then
  begin
    if Form1.CheckBoxPopup.Checked = True then Form1.Show;
    sPath := ExtractFilePath(ParamStr(0)) + 'alarm.wav';
    fpSystem('paplay ' + sPath);
    if Form1.CheckBoxRepeat.Checked = True then ResetStateRepeat()
    else ResetState();
  end;
  if Form1.ComboBoxMode.ItemIndex = 1 then fpSystem('/sbin/shutdown -r now');
  if Form1.ComboBoxMode.ItemIndex = 2 then fpSystem('/sbin/shutdown -P now');
end;

procedure UpdateTimeTotal();
begin
  tSecondsTotal:= tHours * 3600 + tMinutes * 60 + tSeconds;
  UpdateFormCaption();
end;

procedure UpdateTimeVariablesState();
begin
  SetHMSFromTrackbars();
  UpdateTimeTotal();
  CheckTimeZero();
end;

procedure TForm1.TrackBarHoursChange(Sender: TObject);
begin
  if bActivated = False then
  begin
    LabelHoursCount.Caption := IntToStr(TrackBarHours.Position);
    UpdateTimeVariablesState();
    UpdateLabelCountdown();
  end;
end;

procedure TForm1.TrackBarMinutesChange(Sender: TObject);
begin
  if bActivated = False then
  begin
    LabelMinutesCount.Caption := IntToStr(TrackBarMinutes.Position);
    UpdateTimeVariablesState();
    UpdateLabelCountdown();
  end;
end;

procedure TForm1.TrackBarSecondsChange(Sender: TObject);
begin
  if bActivated = False then
  begin
    LabelSecondsCount.Caption := IntToStr(TrackBarSeconds.Position);
    UpdateTimeVariablesState();
    UpdateLabelCountdown();
  end;
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  if bActivated = False then ActivateTimer()
  else ResetState();
end;

procedure TForm1.ComboBoxModeChange(Sender: TObject);
begin
  CheckRepeatPopupState();
end;

procedure TForm1.TimerGlobalTimer(Sender: TObject);
begin
  if tSecondsTotal > 0 then
  begin
    tSecondsTotal := tSecondsTotal - 1;
    UpdateFormCaption();
    UpdateTrackBars();
    UpdateLabels();
  end;
  if tSecondsTotal = 0 then
  begin
    TimerGlobal.Enabled := False;
    Execute();
  end;
end;

end.

