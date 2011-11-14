unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls;

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

end.
