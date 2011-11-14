unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    MenuMain: TMenuItem;
    MenuPreference: TMenuItem;
    MenuLogin: TMenuItem;
    MenuQuit: TMenuItem;
    N5: TMenuItem;
    MenuAbout: TMenuItem;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

// Примерно так будет совместная работа... ;)

end.
