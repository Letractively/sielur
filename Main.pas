unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, OleCtrls, SHDocVw, ULogin, UAcaunt;

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
    procedure FormCreate(Sender: TObject);
    procedure MenuLoginClick(Sender: TObject);
  private
    {
    Panel1: TPanel; Private declarations }
    CurDispatch: IDispatch;
    procedure Login_Trava;
    function NaVigateLink(Link: string):string;
    procedure WebBrowser1NavigateComplete2(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
    procedure WebBrowser1DocumentComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
  public
    { Public declarations }
    FAcauntInfo: TAcaunt;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


procedure TMainForm.FormCreate(Sender: TObject);
begin
  //иницилизируем все и всех
  FAcauntInfo  := TAcaunt.Create;
end;

//открываем окошко где заносим занчение логина и имя сервера
procedure TMainForm.LoginPreferenceClick(Sender: TObject);
var
  AfrmLogin: TfrmLogin;
begin
  AfrmLogin := TfrmLogin.Create(nil);
  try
    AfrmLogin.Show(FAcauntInfo);
  finally
    AfrmLogin.Free;
  end; //try
end;

procedure TMainForm.Login_Trava;
begin
  NaVigateLink(FAcauntInfo.NameServer);
end;

//грубо говоря тут проиойдет вход на сервак
procedure TMainForm.MenuLoginClick(Sender: TObject);
begin
  //для начала заходим на страницу сервера
  Login_Trava;
  showmessage('Типа Грузанули')
end;

function TMainForm.NaVigateLink(Link: string):string;
begin
  wbMain.OnNavigateComplete2 := WebBrowser1NavigateComplete2;
  wbMain.OnDocumentComplete := WebBrowser1DocumentComplete;
  wbMain.navigate(Link);
end;

procedure TMainForm.WebBrowser1NavigateComplete2(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);

begin
  if CurDispatch = nil then
    CurDispatch := pDisp; { save for comparison }
end;

procedure TMainForm.WebBrowser1DocumentComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
  if (pDisp = CurDispatch) then
  begin
    Beep; {the document is loaded, not just a frame }
    CurDispatch := nil; {clear the global variable }
  end;
end;

end.
