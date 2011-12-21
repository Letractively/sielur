unit Add_Farm_Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm2 = class(TForm)
    Mainpnl: TPanel;
    pnlTroops: TPanel;
    edtT1: TEdit;
    edtT2: TEdit;
    edtT3: TEdit;
    edtT4: TEdit;
    edtT5: TEdit;
    edtT6: TEdit;
    edtT7: TEdit;
    edtT9: TEdit;
    edtT10: TEdit;
    edtT11: TEdit;
    edtT12: TEdit;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    img6: TImage;
    img7: TImage;
    img8: TImage;
    img9: TImage;
    img10: TImage;
    img11: TImage;
    rgAtaks: TRadioGroup;
    rgScan: TRadioGroup;
    pnlCoords: TPanel;
    lblVillage: TLabel;
    edtVillage: TEdit;
    lblOrXY: TLabel;
    edtX: TEdit;
    edtY: TEdit;
    grpOptions: TGroupBox;
    lblPeriods: TLabel;
    edtPeriod: TEdit;
    lbl1Dispersion: TLabel;
    edtDispersion: TEdit;
    btnAdd: TButton;
    btnCansel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
