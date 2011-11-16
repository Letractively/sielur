unit Trava_Class;

interface

uses Classes,SysUtils,Trava_My_Const,
     MSHTML;




type
  TBuilding = record
    id: integer;     // Номер поля
    name: string;    // Наименование строения
//    res_req: array[0..3] of integer;
//    res_need: array[0..3] of integer;
//    res_time: TDatetime;
    lvl: integer;
    gid: integer; //тип строения,по build.php?gid=число
                  // (для ферм ID=1..18 здесь будет номер ресурса
                  //  1 - дерево
                  //  2 - глина
                  //  3 - железо
                  //  4 - зерно
  end;


type
  Tresource = record
    per_hour: integer;
    v_nalichee: integer;
    sklad: integer;
//    for_timer: integer;
//    last_update_res: Tdatetime;
  end;


type
TVill = class(TCollectionItem)
  private
    fName: string;
    fNas: integer;
    fcoord_X: integer;
    fcoord_Y: integer;
    fIs_Capital: Boolean;
    fNewDID: String;
    fKarte_Link: String;
    Building: array[1..40] of TBuilding;
    resource: array[0..3] of Tresource;
    fTypeField: integer;
    function get_ID: integer;
    function get_coord: string;
    function GetBuilding(Index: integer): TBuilding;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(Collection: TCollection); override;
    function set_coord(const coord: string):Boolean;
    procedure prepare_dorf1(Document: IHTMLDocument2);
    procedure prepare_dorf2(Document: IHTMLDocument2);
    procedure SetGidForId40(AValue: integer);
//    function get_coord: string;
    property Name: string read fName write fName;
    property Nas: integer read fNas write fNas;
    property coord_X: integer read fcoord_X write fcoord_X;
    property coord_Y: integer read fcoord_Y write fcoord_Y;
    property coord: string read get_coord;
    property ID: integer read get_ID;
    property Is_Capital: Boolean read fIs_Capital write fIs_Capital;
    property NewDID: String read fNewDID write fNewDID;
    property Karte_Link: String read fKarte_Link write fKarte_Link;
    property Item_Building[Index : integer]: TBuilding read GetBuilding;
    property TypeField : integer read fTypeField write fTypeField;

end;


TVills = class (TCollection)
   private
    FOwner: TPersistent;
    function GetItems(Index: integer): TVill;
   public
//    constructor Create(aOwner : TPersistent);virtual;
    constructor Create;virtual;
    function GetOwner: TPersistent; override;
    function CheckAndAdd_Vill_By_XY(x,y: integer):TVill;
    function CheckAndAdd_Vill_By_Coord(coord: string):TVill;

    function FindById(ID:integer):integer;
    function FindByNewDId(NewDId:string):integer;
    function FindByXY(X,Y:integer):integer;
    function FindByCoord(coord:string):integer;

    function VillById(ID:integer):TVill;
    function VillByNewDId(NewDId:string):TVill;
    function VillByXY(X,Y:integer):TVill;
    function VillByCoord(coord: string):TVill;
    property Items[Index : integer]: TVill read GetItems;
//    procedure AddParam(Name : string; Value : Variant);
   published
end;


TAccount=class
  private
    fDerevni: TVills;
    fLogin: string;
    fPassword: string;
    fConnection_String: string;
    fUID: string;
    fRace: integer;                  // 1 - рим  2 - тевтон   3 - галл
    FIdCurrentVill: integer;
    function get_Derevni_Count: integer;
  protected

  public
//    constructor Create(aOwner : TPersistent);virtual;
    constructor Create;virtual;
    property Derevni: TVills read fDerevni write fDerevni;
    property Derevni_Count: integer read get_Derevni_Count;
    property Login: string read fLogin write fLogin;
    property Password: string read fPassword write fPassword;
    property Connection_String: string read fConnection_String write fConnection_String;
    property UID: string read fUID write fUID;
    property Race: integer read fRace write fRace;
    property IdCurrentVill: integer read FIdCurrentVill write FIdCurrentVill;
end;

Type
 TRes_for_fields = array[1..12, 1..18] of integer;


Type
 TField_coord = array [1..2,1..40] of integer;

var
  Res_for_fields: TRes_for_fields = (
    (4, 4, 1, 4, 4, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f1 9-ка   [3,3,3,9]
    (3, 4, 1, 3, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f2        [3,4,5,6]
    (1, 4, 1, 3, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f3        [4,4,4,6]
    (1, 4, 1, 2, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f4        [4,5,3,6]
    (1, 4, 1, 3, 1, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f5        [5,3,4,6]
    (4, 4, 1, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4), //f6 15-ка  [1,1,1,15]
    (1, 4, 4, 1, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f7        [4,4,3,7]
    (3, 4, 4, 1, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f8        [3,4,4,7]
    (3, 4, 4, 1, 1, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f9        [4,3,4,7]
    (3, 4, 1, 2, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f10       [3,5,4,6]
    (3, 1, 1, 3, 1, 4, 4, 3, 3, 2, 2, 3, 1, 4, 4, 2, 4, 4), //f11       [4,3,5,6]
    (1, 4, 1, 1, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2)  //f12       [5,4,3,6]
    );

  Field_coord: TField_coord= (
    (110, 173, 234, 056, 147, 213, 270, 040, 091, 223, 278, 051, 102, 169, 248, 097, 150, 200,
     150, 220, 285, 357, 413, 116, 189, 273, 420, 100, 215, 182, 429, 113, 254, 372, 188, 308, 171, 294, 338, 474),
    (042, 043, 057, 075, 084, 104, 097, 128, 121, 152, 155, 181, 174, 194, 209, 228, 239, 243,
     124, 098, 087, 102, 150, 153, 165, 150, 188, 228, 197, 222, 227, 266, 264, 281, 302, 314, 336, 342, 221, 210)
   );

implementation
 type EGrParamError = class(Exception);

resourcestring
  rsVillBadId  = SCriticalError + 'Неверное ID Поселения.';
  rsVillBadNewDId  = SCriticalError + 'Неверное NewDID Поселения.';


{ TVill }

procedure TVill.AssignTo(Dest: TPersistent);
begin
 if Assigned(Dest) and Dest.InHeritsFrom(TVill)
 then begin
  (Dest as TVill).fName := fName;
  (Dest as TVill).fNas := fNas;
  (Dest as TVill).fcoord_X := fcoord_X;
  (Dest as TVill).fcoord_Y := fcoord_Y;
  (Dest as TVill).fIs_Capital := fIs_Capital;
 end else inherited;
end;

constructor TVill.Create(Collection: TCollection);
begin
  inherited;

end;

function TVill.GetBuilding(Index: integer): TBuilding;
begin
 Result:=Building[Index];
end;

function TVill.get_coord: string;
begin
  Result:='('+IntToStr(fcoord_X)+'|'+IntToStr(fcoord_Y)+')';
end;

function TVill.get_ID: integer;
begin
  Result:=801*abs((coord_Y-400))+(coord_X+400)+1;
end;


procedure TVill.prepare_dorf1(Document: IHTMLDocument2);
var
  field_Element: IHTMLElement;
  Tmp_Collection:IHTMLElementCollection;
  Attr_Collection:IHTMLAttributeCollection;
  Attr_Element:IHTMLDOMAttribute;

  ItemNumber: integer;
  ItemAttrNumber: integer;
  ItemBuild: integer;
  TmpStringBuild: string;
begin
//
// Найдем элемент по id="village_map"
//   (<div id="village_map" class="f7">)
//  его класс укажет нам на тип клетки
  field_Element:=(document as IHTMLDocument3).getElementById('village_map');
  TypeField:=StrToInt(copy(field_Element.className,2));
  // gid полей
  for ItemBuild := 1 to 18 do
  begin
    Building[ItemBuild].id:=ItemBuild;
    Building[ItemBuild].gid:=Res_for_fields[TypeField,ItemBuild];
  end;

// Ну а теперь пройдемся по содержимому field_Element
// и вытащим информацию о полях
  Tmp_Collection:=(field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.Length - 2 do
  begin
    field_Element:=Tmp_Collection.item(ItemNumber,'')  as IHTMLElement;
    Attr_Collection:=(field_Element as IHTMLDOMNode).attributes as IHTMLAttributeCollection;
    TmpStringBuild:=field_Element.className; // Ну там что-то вот такое "reslevel rf1 level10"
    TmpStringBuild:=copy(TmpStringBuild,12); // Удалили "reslevel rf"
     // Теперь до пробела это номер поля  и после lelel - это уровень постройки
    ItemBuild:=StrToInt(copy(TmpStringBuild,1,pos(' ',TmpStringBuild)-1));
    Building[ItemBuild].lvl:=StrToInt(copy(TmpStringBuild,pos('level',TmpStringBuild)+5));
    for ItemAttrNumber := 0 to Attr_Collection.Length - 1 do
    begin
      Attr_Element:=Attr_Collection.item(ItemAttrNumber) as IHTMLDOMAttribute;
      if Attr_Element.specified then
        if Attr_Element.nodeName = 'alt' then
          Building[ItemBuild].name:=Attr_Element.nodeValue;
    end;
  end;
end;

procedure TVill.prepare_dorf2(Document: IHTMLDocument2);
var
  field_Element: IHTMLElement;
  Tmp_Collection:IHTMLElementCollection;
  Attr_Collection:IHTMLAttributeCollection;
  Attr_Element:IHTMLDOMAttribute;

  ItemNumber: integer;
  ItemAttrNumber: integer;
  ItemBuild: integer;
  TmpStringBuild: string;
begin
  // Занулим gid полей и уровни
  for ItemBuild := 19 to 40 do
  begin
    Building[ItemBuild].id:=ItemBuild;
    Building[ItemBuild].gid:=0;
    Building[ItemBuild].lvl:=0;
  end;

//
// Найдем элемент по id="village_map"
  field_Element:=(document as IHTMLDocument3).getElementById('village_map');

// Ну а теперь пройдемся по содержимому field_Element
// и вытащим информацию о полях
  Tmp_Collection:=(field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to 19 do
  begin
    field_Element:=Tmp_Collection.item(ItemNumber,'')  as IHTMLElement;
    Attr_Collection:=(field_Element as IHTMLDOMNode).attributes as IHTMLAttributeCollection;
    TmpStringBuild:=field_Element.className; // Ну там что-то вот такое "building d1 iso" или "building d7 g10" ну или для строящегося "building d7 g10b"
    TmpStringBuild:=copy(TmpStringBuild,11); // Удалили "building d"
    if copy(TmpStringBuild,length(TmpStringBuild),1) = 'b' then  // Здесь идет стройка?????
      TmpStringBuild:=copy(TmpStringBuild,1,length(TmpStringBuild)-1);

     // Теперь до пробела это номер поля  и после -gid или iso
    ItemBuild:=StrToInt(copy(TmpStringBuild,1,pos(' ',TmpStringBuild)-1))+18;
    if copy(TmpStringBuild,pos(' ',TmpStringBuild)+1,1) = 'g' then
      Building[ItemBuild].gid:=StrToInt(copy(TmpStringBuild,pos(' ',TmpStringBuild)+2));

    for ItemAttrNumber := 0 to Attr_Collection.Length - 1 do
    begin
      Attr_Element:=Attr_Collection.item(ItemAttrNumber) as IHTMLDOMAttribute;
      if Attr_Element.specified then
        if Attr_Element.nodeName = 'alt' then
          Building[ItemBuild].name:=Attr_Element.nodeValue;
    end;
  end;

  // Теперь разберемся с уровнями полей
  // Найдем элемент по id="levels"
  // и вытащим информацию о уровнях
  field_Element:=(document as IHTMLDocument3).getElementById('levels');
  Tmp_Collection:=(field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.length-1 do
  begin
    field_Element:=Tmp_Collection.item(ItemNumber,'')  as IHTMLElement;
    TmpStringBuild:=field_Element.className; // Ну там что-то вот такое "d7" или "l40"
    ItemBuild:=StrToInt(copy(TmpStringBuild,2));
    if copy(TmpStringBuild,1,1) = 'd' then ItemBuild:=ItemBuild+18;
    Building[ItemBuild].lvl:=StrToInt(field_Element.innerText);
  end;

  // И теперь разберемся с пунктом сбора и оградой
  Building[39].gid:=16;
//  Building[40].gid:=30+race;  впрочим с расой надо раньше разбираться


end;

procedure TVill.SetGidForId40(AValue: integer);
begin
  Building[40].gid:=AValue;
end;

function TVill.set_coord(const coord: string): Boolean;
// coord - (X|Y)
//  True  - Всё хорошо
//  False - Неверен формат входной строки
var tmp_string : string;
    i : integer;
begin
  //  Проверим первый и последний символ, это должны быть скобки
  Result:=(Copy(coord,1,1) = '(') and (Copy(coord,length(coord),1) = ')');
  fcoord_X:=0;
  fcoord_Y:=0;
  if Result then
  begin
    i:=pos('|',coord);
    Result:=((i > 2) and (i < length(coord)-1));
    if Result then
    begin
      tmp_string:=Copy(coord,2,i-2);
      Result:=TryStrToInt(tmp_string,fcoord_X);
      if Result then
      begin
        tmp_string:=Copy(coord,i+1,length(coord)-i-1);
        Result:=TryStrToInt(tmp_string,fcoord_Y);
      end;

    end;
  end;

end;

{ TVills }


function TVills.CheckAndAdd_Vill_By_Coord(coord: string): TVill;
var i: integer;
begin
  i:=FindByCoord(coord);
  if i > -1 then Result:=Items[i] as TVill
  else begin
    Result := TVill.Create(Self);
    Result.set_coord(coord);
  end;
end;

function TVills.CheckAndAdd_Vill_By_XY(x,y: integer):TVill;
var i: integer;
begin
  i:=FindByXY(x,y);
  if i > -1 then Result:=Items[i] as TVill
  else begin
    Result := TVill.Create(Self);
    Result.fcoord_X:=X;
    Result.fcoord_Y:=Y;
  end;
end;
constructor TVills.Create;
begin
 inherited Create(TVill);
end;

{
constructor TVills.Create(aOwner: TPersistent);
begin
 FOwner:=aOwner;
 inherited Create(TVill);
end;
}
function TVills.FindByXY(X, Y: integer): integer;
var i : integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if ((Items[i] as TVill).fcoord_X = X) and ((Items[i] as TVill).fcoord_Y = Y) then begin
      Result := i;
      Exit;
    end;
  end;

end;

function TVills.FindByCoord(coord: string): integer;
var i : integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if (Items[i] as TVill).coord = coord then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TVills.FindById(ID: integer): integer;
var i : integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
  begin
    if (Items[i] as TVill).ID = ID then begin
      Result := i;
      Exit;
    end;
  end;
end;

function TVills.FindByNewDId(NewDId: string): integer;
var i : integer;
begin
  Result := -1;
  if Count = 1 then Result:=0
  else
    for i := 0 to Count-1 do
    begin
      if (Items[i] as TVill).NewDID = NewDID then begin
        Result := i;
        Exit;
      end;
    end;

end;

function TVills.GetItems(Index: integer): TVill;
begin
 Result := (inherited Items[index] as TVill);
end;


function TVills.GetOwner: TPersistent;
begin
 Result:=FOwner;
end;

function TVills.VillByXY(X, Y: integer): TVill;
var i :integer;
begin
 Result:=nil;
 i:=FindByXY(X,Y);
 if i>=0
   then Result:=Items[i] as TVill
end;

function TVills.VillByCoord(coord: string): TVill;
var i :integer;
begin
 Result:=nil;
 i:=FindByCoord(coord);
 if i>=0
   then Result:=Items[i] as TVill
end;

function TVills.VillById(ID: integer): TVill;
var i :integer;
begin
 i:=FindById(Id);
 if i>=0
   then Result:=Items[i] as TVill
   else raise EGrParamError.Create(rsVillBadId+'- "'+IntToStr(Id)+'"');

end;


function TVills.VillByNewDId(NewDId: string): TVill;
var i :integer;
begin
 i:=FindByNewDId(NewDId);
 if i>=0
   then Result:=Items[i] as TVill
   else raise EGrParamError.Create(rsVillBadNewDId+'- "'+NewDId+'"');


end;

{
procedure TGrParams.AddParam(Name: string; Value: Variant);
var Param : TGrParamItem;
begin
  Param := TGrParamItem.Create(Self);
  Param.Name := Name;
  Param.Value := Value;
//  Add(Param);
end;

}
{ TAccount }

{
constructor TAccount.Create(aOwner : TPersistent);
begin
  FOwner:=aOwner;
//  Derevni:=TVills.Create(FOwner);
  Derevni:=TVills.Create;
end;
}

constructor TAccount.Create;
begin
  inherited;
  Derevni:=TVills.Create;
end;

function TAccount.get_Derevni_Count: integer;
begin
  result:=fDerevni.Count;
end;



end.
