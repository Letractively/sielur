program Sielur;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  ULogin in 'ULogin.pas' {frmLogin},
  UAcaunt in 'UAcaunt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  //Application.CreateForm(TfrmLogin, frmLogin);
  Application.Run;
end.
