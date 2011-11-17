unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, UAcaunt;

type
  TfrmLogin = class(TForm)
    pnlLogin: TPanel;
    edtLogin: TEdit;
    edtPass: TEdit;
    lblLogin: TLabel;
    lblPass: TLabel;
    pnlMain: TPanel;
    grpProxy: TGroupBox;
    lblAgent: TLabel;
    cbbAgetn: TComboBox;
    lblServer: TLabel;
    edtServer: TEdit;
    btnOk: TButton;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    FAcaunt : TAcaunt;
  public
    { Public declarations }
    procedure Show(AAcaunt: TAcaunt);
  end;

implementation

{$R *.dfm}

{ TfrmLogin }

procedure TfrmLogin.btnOkClick(Sender: TObject);
begin
  FAcaunt.NameServer := edtServer.Text;
  FAcaunt.Login := edtLogin.Text;
  FAcaunt.Password := edtPass.Text;
  FAcaunt.UserAgetn := cbbAgetn.Text;
  {FAcaunt.IsProxy :=
  FAcaunt.ProxyName :=
  FAcaunt.ProxyPort :=  }
  self.Close;
end;

procedure TfrmLogin.Show(AAcaunt: TAcaunt);
begin
  FAcaunt:= AAcaunt;
  self.ShowModal;
end;

end.
