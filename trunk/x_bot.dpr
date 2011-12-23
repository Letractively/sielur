program
  x_bot;

uses
  Forms,
  x_bot_MainForm in 'x_bot_MainForm.pas' {MainForm},
  IntfDocHostUIHandler in 'IntfDocHostUIHandler.pas',
  UContainer in 'UContainer.pas',
  UNulContainer in 'UNulContainer.pas',
  MyIniFile in 'MyIniFile.pas',
  Trava_Class in 'Trava_Class.pas',
  Trava_My_Const in 'Trava_My_Const.pas',
  Account_Frame in 'Account_Frame.pas' {Account_Form: TFrame},
  Account_data in 'Account_data.pas',
  Add_User_Form in 'Add_User_Form.pas' {Add_New_User},
  x_bot_utl in 'x_bot_utl.pas',
  U_Utilites in 'U_Utilites.pas',
  Trava_Task in 'Trava_Task.pas',
  Trava_Task_Build in 'Trava_Task_Build.pas',
  Trava_Task_Farm in 'Trava_Task_Farm.pas',
  Add_Farm_Form in 'Add_Farm_Form.pas' {AddFarmForm},
  Trava_Troops_Unit in 'Trava_Troops_Unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAdd_New_User, Add_New_User);
  Application.CreateForm(TAddFarmForm, AddFarmForm);
  Application.Run;
end.
