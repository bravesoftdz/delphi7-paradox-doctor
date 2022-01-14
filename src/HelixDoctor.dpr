program HelixDoctor;



uses
  Forms,
  s in 's.pas' {MainForm},
  batchmove in 'batchmove.pas' {frmBatchMove},
  xaUtils in 'xaUtils.pas',
  TUtil32 in 'TUTIL32.PAS',
  FieldUpdate in 'FieldUpdate.pas',
  BDEUtil in 'BDEUtil .pas',
  Globals in 'Globals.pas',
  About in 'About.pas' {AboutBox};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Cervelle Data Doctor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmBatchMove, frmBatchMove);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
