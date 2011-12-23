unit Add_Farm_Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Trava_Task_Farm;

type
  TAddFarmForm = class(TForm)
    Mainpnl: TPanel;
    pnlTroops: TPanel;
    edtT1: TEdit;
    edtT2: TEdit;
    edtT3: TEdit;
    edtT4: TEdit;
    edtT5: TEdit;
    edtT6: TEdit;
    edtT7: TEdit;
    edtT8: TEdit;
    edtT9: TEdit;
    edtT10: TEdit;
    edtT11: TEdit;
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
    procedure btnCanselClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    { Private declarations }
    FFarmItem: TFarmItem;
  public
    { Public declarations }
    Procedure Show(AFarmItem: TFarmItem);
  end;

var
  AddFarmForm: TAddFarmForm;

implementation

{$R *.dfm}

procedure TAddFarmForm.btnAddClick(Sender: TObject);
var
  I: Integer;
  tmpEdit: TEdit;
begin
  //Добовляем войска
  for I := 1 to 11 do
  begin
    tmpEdit := FindComponent('edtT' + IntToStr(I)) as TEdit;
    if tmpEdit.Text ='' then
      FFarmItem.FTroops[I] := 0
    else
      FFarmItem.FTroops[I] := StrToInt(tmpEdit.Text);
  end;
  //Добовляем координаты
  FFarmItem.Coords.X := StrToInt(edtX.Text);
  FFarmItem.Coords.Y := StrToInt(edtY.Text);
  //Добовляем тип атаки
  if rgAtaks.ItemIndex = 0 then
    FFarmItem.FTypeAtaks := sireinforcement
  else
  if rgAtaks.ItemIndex = 1 then
    FFarmItem.FTypeAtaks := siattack
  else
  if rgAtaks.ItemIndex = 2 then
    FFarmItem.FTypeAtaks := siraid;
  //Добавка периода и разброса
  FFarmItem.Finterval := StrToInt(edtPeriod.Text);
  FFarmItem.FIntervalRange := StrToInt(edtDispersion.Text);
  FFarmItem.FGeneration := 0;
  FFarmItem.Enable := True;
  Close;
  //
end;

procedure TAddFarmForm.btnCanselClick(Sender: TObject);
begin
  Close;
end;

procedure TAddFarmForm.Show(AFarmItem: TFarmItem);
begin
  FFarmItem := AFarmItem;
  Self.ShowModal;
end;

end.
