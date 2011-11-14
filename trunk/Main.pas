unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, OleCtrls, SHDocVw, ULogin;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    MenuMain: TMenuItem;
    MenuPreference: TMenuItem;
    MenuLogin: TMenuItem;
    MenuQuit: TMenuItem;
    N5: TMenuItem;
    MenuAbout: TMenuItem;
    splMainPnlAndWebBrous: TSplitter;
    pnlWeb: TPanel;
    wbMain: TWebBrowser;
    LoginPreference: TMenuItem;
    procedure LoginPreferenceClick(Sender: TObject);
  private
    {
    Panel1: TPanel; Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

// Примерно так будет совместная работа... ;)

procedure TMainForm.LoginPreferenceClick(Sender: TObject);
var
  AfrmLogin: TfrmLogin;
begin
  AfrmLogin := TfrmLogin.Create(nil);
  try
    AfrmLogin.ShowModal;
  finally
    AfrmLogin.Free;
  end; //try
end;

end.
