unit
  Add_User_Form;

interface

uses
  Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , StdCtrls
  , ExtCtrls
  , RzPanel
  ;

type
  TAdd_New_User = class(TForm)
    RzPanel3: TRzPanel;
    Server_Name: TLabeledEdit;
    User_Name: TLabeledEdit;
    Password_Name: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Add_New_User: TAdd_New_User;

implementation

{$R *.dfm}

procedure TAdd_New_User.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (ModalResult <> mrOk) or
    ((Server_Name.Text <> '') and (User_Name.Text <> '') and (Password_Name.Text
    <> ''));

  if not CanClose then
    if Server_Name.Text = '' then
      Server_Name.SetFocus
    else if User_Name.Text = '' then
      User_Name.SetFocus
    else
      Password_Name.SetFocus;

end;

procedure TAdd_New_User.FormShow(Sender: TObject);
begin
  if Server_Name.Text = '' then
    Server_Name.SetFocus
  else
    User_Name.SetFocus;

end;

end.

