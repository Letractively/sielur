unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

end.
