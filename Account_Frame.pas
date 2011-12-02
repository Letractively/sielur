unit
  Account_Frame;

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
  , OleCtrls
  , SHDocVw
  , ExtCtrls
  , RzPanel
  , RzTabs
  , UContainer
  , Account_data
  , Trava_Class
  , RzSplit
  , Grids
  , RzGrids
  , ImgList
  , pngimage
  ;

type
  TAccount_Form = class(TFrame)
    RzPageControl1: TRzPageControl;
    TabSheet1: TRzTabSheet;
    TabSheet2: TRzTabSheet;
    TabSheet3: TRzTabSheet;
    TabSheet4: TRzTabSheet;
    TabSheet5: TRzTabSheet;
    TabSheet6: TRzTabSheet;
    TabSheet7: TRzTabSheet;
    TabSheet8: TRzTabSheet;
    TabSheet9: TRzTabSheet;
    TabSheet10: TRzTabSheet;
    TabSheet11: TRzTabSheet;
    RzPanel3: TRzPanel;
    User_Name: TLabeledEdit;
    Password_Name: TLabeledEdit;
    TabSheet12: TRzTabSheet;
    TabSheet13: TRzTabSheet;
    TabSheet14: TRzTabSheet;
    TabSheet15: TRzTabSheet;
    Memo1: TMemo;
    Browser_RzPanel: TRzPanel;
    Building_Panel: TRzSizePanel;
    RzPanel1: TRzPanel;
    Level_ImageList: TImageList;
    Field_ImageList: TImageList;
    Center_ImageList: TImageList;
    Panel2: TPanel;
    VillCenterImage: TImage;
    VillCenterLabel: TLabel;
    Panel1: TPanel;
    VillFieldImage: TImage;
    VillFieldNameLabel: TLabel;
    Building_ImageList: TImageList;
    procedure Building_PanelResize(Sender: TObject);
    procedure Building_GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Building_GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VillFieldImageClick(Sender: TObject);
    procedure VillFieldImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VillCenterImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    ColBuilding_Grid: integer;
    RowBuilding_Grid: integer;

    FAccount_data: TAccount_data;
    procedure SetAccount_data(const Value: TAccount_data);
    { Private declarations }
    procedure View_Account(Account_data: TAccount_data);

    procedure DrawCurrentVill;
    procedure DrawVillField(IdVill: integer);
    procedure DrawVillCenter(IdVill: integer);
    procedure DrawVill(IdVill: integer);
  public
    { Public declarations }
    property Account_data: TAccount_data read FAccount_data write
      SetAccount_data;
  end;

implementation

{$R *.dfm}

procedure TAccount_Form.Building_GridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  img_index: integer;
  Lvl_index: integer;
  IdCurrentVill: integer;
  CurrentVill: TVill;
  CIndex: integer;
begin
  if Account_data = nil then
    exit;

  IdCurrentVill := Account_data.MyAccount.IdCurrentVill;
  CurrentVill := Account_data.MyAccount.Derevni.VillById(IdCurrentVill);
  CIndex := (ARow * 8) + ACol + 1;

  img_index := CurrentVill.Item_Building[CIndex].gid;
  Lvl_index := CurrentVill.Item_Building[CIndex].lvl;
  if img_index > 0 then
  begin
    if (CIndex = 40) and (CurrentVill.Item_Building[40].lvl = 0) then
      img_index := 0;

    if img_index <= 41 then
    begin
      with (Sender as TRzStringGrid) do
      begin
        {...}
        Building_ImageList.Draw(Canvas, Rect.Left, Rect.Top, img_index, true);
        Level_ImageList.Draw(Canvas, Rect.Left, Rect.Top, Lvl_index, true);
        {...}
      end;
    end;
  end; // if gid > 0
end;

procedure TAccount_Form.Building_GridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  r: integer;
  c: integer;

  IdCurrentVill: integer;
  CurrentVill: TVill;
  CIndex: integer;
begin
  {
    if Account_data = nil then exit;

    Building_Grid.MouseToCell(X, Y, C, R);
    if (c < 0) or (c > 7) or (r < 0) or (r > 4) then exit;

    if ((RowBuilding_Grid <> r) or
        (ColBuilding_Grid <> c)) then begin
      RowBuilding_Grid := r;
      ColBuilding_Grid := c;

      CIndex:=(R*8)+C+1;
      IdCurrentVill:=Account_data.MyAccount.IdCurrentVill;
      CurrentVill:=Account_data.MyAccount.Derevni.VillById(IdCurrentVill);

      Application.CancelHint;
      Building_Grid.Hint := CurrentVill.Item_Building[CIndex].name;

    end;
  }
end;

procedure TAccount_Form.Building_PanelResize(Sender: TObject);
begin
  {
    Building_Grid.DefaultColWidth:=((Building_Panel.Width - 20) div 8);
    Building_Grid.DefaultRowHeight:=((Building_Panel.Height - 20) div 5);
  }
end;

procedure TAccount_Form.DrawCurrentVill;
var
  IdVill: integer;
begin
  IdVill := -1;

  if Account_data <> nil then
    IdVill := Account_data.MyAccount.IdCurrentVill;

  DrawVill(IdVill);
end;

procedure TAccount_Form.DrawVill(IdVill: integer);
begin
  DrawVillField(IdVill);
  DrawVillCenter(IdVill);
end;

procedure TAccount_Form.DrawVillCenter(IdVill: integer);
var
  img_fn: string;
  VillForDraw: TVill;
  CIndex: integer;
  Lvl_index: integer;
  field_img: TImage;
  Build_index: integer;
  iw, ih: integer;
begin
  VillCenterImage.Hide;
  if Account_data = nil then
    exit;

  iw := Building_ImageList.Width;
  ih := Building_ImageList.Height;
  VillForDraw := Account_data.MyAccount.Derevni.VillById(IdVill);

  if VillForDraw.Item_Building[40].lvl = 0 then
    img_fn := 'image/center/bg015.png'
  else
    img_fn := 'image/center/bg' + IntToStr(Account_data.MyAccount.Race) +
      '15.png';

  field_img := TImage.Create(self);
  field_img.Picture.LoadFromFile(img_fn);
  VillCenterImage.Canvas.Draw(2, 2, field_img.Picture.Graphic);

  for CIndex := 19 to 40 do
  begin
    Lvl_index := VillForDraw.Item_Building[CIndex].lvl;
    if CIndex < 40 then
    begin
      if VillForDraw.Item_Building[CIndex].gid > 0 then
      begin
        Build_index := VillForDraw.Item_Building[CIndex].gid;
        Building_ImageList.Draw(VillCenterImage.Canvas, Field_coord[1, CIndex] +
          25 - iw, Field_coord[2, CIndex] + 25 - ih, Build_index, true);
      end;
    end;

    if Lvl_index > 0 then
      Level_ImageList.Draw(VillCenterImage.Canvas, Field_coord[1, CIndex] - 10,
        Field_coord[2, CIndex] - 15, Lvl_index, true);

  end;

  VillCenterImage.Show;
end;

procedure TAccount_Form.DrawVillField(IdVill: integer);
var
  img_fn: string;
  VillForDraw: TVill;
  CIndex: integer;
  Lvl_index: integer;
  field_img: TImage;
begin

  VillFieldImage.Hide;
  if Account_data = nil then
    exit;

  VillForDraw := Account_data.MyAccount.Derevni.VillById(IdVill);

  img_fn := '00' + IntToStr(VillForDraw.TypeField);
  img_fn := copy(img_fn, length(img_fn) - 1, 2);

  img_fn := 'image/field/f' + img_fn + '.png';

  field_img := TImage.Create(self);
  field_img.Picture.LoadFromFile(img_fn);
  VillFieldImage.Canvas.Draw(2, 2, field_img.Picture.Graphic);

  for CIndex := 1 to 18 do
  begin
    Lvl_index := VillForDraw.Item_Building[CIndex].lvl;
    Level_ImageList.Draw(VillFieldImage.Canvas, Field_coord[1, CIndex] - 4,
      Field_coord[2, CIndex] - 4, Lvl_index, true);

  end;

  VillFieldImage.Show;

end;

procedure TAccount_Form.VillCenterImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  //
end;

procedure TAccount_Form.VillFieldImageClick(Sender: TObject);
begin
  //

end;

procedure TAccount_Form.VillFieldImageMouseMove(Sender: TObject; Shift:
  TShiftState; X,
  Y: Integer);
var
  r: integer;
  c: integer;

  IdCurrentVill: integer;
  CurrentVill: TVill;
  CIndex: integer;
begin
  if Account_data = nil then
    exit;

  IdCurrentVill := Account_data.MyAccount.IdCurrentVill;
  CurrentVill := Account_data.MyAccount.Derevni.VillById(IdCurrentVill);

  VillFieldNameLabel.Caption := '';
  for CIndex := 1 to 18 do
  begin
    if ((X - Field_coord[1, CIndex]) * (X - Field_coord[1, CIndex]) + (Y -
      Field_coord[2, CIndex]) * (Y - Field_coord[2, CIndex])) < 400 then
    begin
      VillFieldNameLabel.Caption := CurrentVill.Item_Building[CIndex].name;
      break;
    end;
  end;

end;

procedure TAccount_Form.SetAccount_data(const Value: TAccount_data);
begin
  FAccount_data := Value;
  DrawCurrentVill;
end;

procedure TAccount_Form.View_Account(Account_data: TAccount_data);
begin
end;

end.

