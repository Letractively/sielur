unit
  Trava_Class;

interface

uses
  Classes
  , SysUtils
  , Trava_My_Const
  , MSHTML
  , UContainer
  , PerlRegEx
  , U_Utilites
  , Dialogs
  , Windows
  , Trava_Task_Farm_Item
;


type


  TBuilding = record
    id: integer; // Номер поля
    name: string; // Наименование строения
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

  Tprepare_dorf = procedure(Document: IHTMLDocument2; DocumentHTML:
    IHTMLDocument2; FLog: TStringList) of object;
  Tprepare_profile = procedure(WBContainer: TWBContainer; document:
    IHTMLDocument2; DocumentHTML: IHTMLDocument2; FLog: TStringList) of object;
  // Обработка профиля

  TTravianVersion = (tv36, tv40, tvNone);
type
  TAccount=class;


  TVill = class(TCollectionItem)
  private
    fName: string;
    fNas: integer;
    fcoord_X: integer;
    fcoord_Y: integer;
    fIs_Capital: Boolean;
    fNewDID: string;
    fKarte_Link: string;
    Building: array[1..40] of TBuilding;
    resource: array[0..3] of Tresource;
    fTypeField: integer;
    fprepare_dorf1: Tprepare_dorf;
    fprepare_dorf2: Tprepare_dorf;
    fprepare_vlist: Tprepare_dorf;
    FAccount: TAccount;
    FFarmLists: TFarmList; //лист с списком листов и целей ...ка кто так.
    fBuildList: string;
    function get_ID: integer;
    function get_coord: string;
    function GetBuilding(Index: integer): TBuilding;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(Collection: TCollection); override;
    function set_coord(const coord: string): Boolean;
    // Dorf1
    procedure prepare_dorf1_T36(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);
    procedure prepare_dorf1_T40(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);
    // Dorf2
    procedure prepare_dorf2_T36(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);
    procedure prepare_dorf2_T40(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);
    // Build
    function build_field(WBContainer: TWBContainer; const FId:string; const GId: string; FLog: TStringList):TBuildReturn_Code;
    function build_center(WBContainer: TWBContainer; const FId:string; const GId: string; FLog: TStringList):TBuildReturn_Code;
    //Farm
    function Send_Troop(WBContainer: TWBContainer; AFarmItem: TFarmItem; FLog: TStringList): TFarmReturn_Code;
    // Vlist
    procedure prepare_Vlist_T36(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);
    procedure prepare_Vlist_T40(Document: IHTMLDocument2; DocumentHTML:
      IHTMLDocument2; FLog: TStringList);

    //
    procedure SetGidForId40(AValue: integer);
    //    function get_coord: string;
    property Name: string read fName write fName;
    property Nas: integer read fNas write fNas;
    property coord_X: integer read fcoord_X write fcoord_X;
    property coord_Y: integer read fcoord_Y write fcoord_Y;
    property coord: string read get_coord;
    property ID: integer read get_ID;
    property Is_Capital: Boolean read fIs_Capital write fIs_Capital;
    property NewDID: string read fNewDID write fNewDID;
    property Karte_Link: string read fKarte_Link write fKarte_Link;
    property Item_Building[Index: integer]: TBuilding read GetBuilding;
    property TypeField: integer read fTypeField write fTypeField;
    property prepare_dorf1: Tprepare_dorf read fprepare_dorf1 write
      fprepare_dorf1;
    property prepare_dorf2: Tprepare_dorf read fprepare_dorf2 write
      fprepare_dorf2;
    property prepare_vlist: Tprepare_dorf read fprepare_vlist write
      fprepare_vlist;
    property BuildList: string read fBuildList write fBuildList;
    property Account: TAccount read FAccount write FAccount;
    property FarmLists: TFarmList read FFarmLists write FFarmLists;
  end;

  TVills = class(TCollection)
  private
    FOwner: TPersistent;
    FAccount: TAccount;
    function GetItems(Index: integer): TVill;
  public
    //    constructor Create(aOwner : TPersistent);virtual;
    constructor Create; virtual;
    function GetOwner: TPersistent; override;
    function CheckAndAdd_Vill_By_XY(x, y: integer): TVill;
    function CheckAndAdd_Vill_By_Coord(coord: string): TVill;

    function FindById(ID: integer): integer;
    function FindByNewDId(NewDId: string): integer;
    function FindByXY(X, Y: integer): integer;
    function FindByCoord(coord: string): integer;

    function VillById(ID: integer): TVill;
    function VillByNewDId(NewDId: string): TVill;
    function VillByXY(X, Y: integer): TVill;
    function VillByCoord(coord: string): TVill;
    property Items[Index: integer]: TVill read GetItems;
    //    procedure AddParam(Name : string; Value : Variant);
    property Account: TAccount read FAccount write FAccount;
  published
  end;

  TAccount = class
  private
    fDerevni: TVills;
    fLogin: string;
    fPassword: string;
    fConnection_String: string;
    fUID: string;
    fRace: integer; // 1 - рим  2 - тевтон   3 - галл
    FIdCurrentVill: integer;
    FTravianVersion: TTravianVersion;
    fPrepare_profile: Tprepare_profile;
    fAccount_data: TObject;
    function get_Derevni_Count: integer;
    procedure SetTravianVersion(const Value: TTravianVersion);
    function GetTravianTime: TDateTime;
  protected
    delta_time : Tdatetime;
  public
    //    constructor Create(aOwner : TPersistent);virtual;
    constructor Create; virtual;
    procedure prepare_profileT36(WBContainer: TWBContainer; document:
      IHTMLDocument2; DocumentHTML: IHTMLDocument2; FLog: TStringList);
    procedure prepare_profileT40(WBContainer: TWBContainer; document:
      IHTMLDocument2; DocumentHTML: IHTMLDocument2; FLog: TStringList);
    // Обработка профиля

    property Derevni: TVills read fDerevni write fDerevni;
    property Derevni_Count: integer read get_Derevni_Count;
    property Login: string read fLogin write fLogin;
    property Password: string read fPassword write fPassword;
    property Connection_String: string read fConnection_String write
      fConnection_String;
    property UID: string read fUID write fUID;
    property Race: integer read fRace write fRace;
    property IdCurrentVill: integer read FIdCurrentVill write FIdCurrentVill;
    //    property IsT4Version: Boolean read FIsT4Version write FIsT4Version;
    property TravianVersion: TTravianVersion read FTravianVersion write
      SetTravianVersion;
    property Prepare_profile: Tprepare_profile read fPrepare_profile write
      fPrepare_profile;

    property TravianTime: TDateTime read GetTravianTime;
    property Account_data : TObject read fAccount_data write fAccount_data;
  end;

//procedure prepare_Vlist36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);

type
  TRes_for_fields = array[1..12, 1..18] of integer;

type
  TField_coord = array[1..2, 1..40] of integer;

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

  Field_coord: TField_coord = (
    (110, 173, 234, 056, 147, 213, 270, 040, 091, 223, 278, 051, 102, 169, 248,
    097, 150, 200,
    150, 220, 285, 357, 413, 116, 189, 273, 420, 100, 215, 182, 429, 113, 254,
    372, 188, 308, 171, 294, 338, 474),
    (042, 043, 057, 075, 084, 104, 097, 128, 121, 152, 155, 181, 174, 194, 209,
    228, 239, 243,
    124, 098, 087, 102, 150, 153, 165, 150, 188, 228, 197, 222, 227, 266, 264,
    281, 302, 314, 336, 342, 221, 210)
    );

implementation

uses account_data;

type
  EGrParamError = class(Exception);

resourcestring
  rsVillBadId = SCriticalError + 'Неверное ID Поселения.';
  rsVillBadNewDId = SCriticalError + 'Неверное NewDID Поселения.';

  { TVill }

procedure TVill.AssignTo(Dest: TPersistent);
begin
  if Assigned(Dest) and Dest.InHeritsFrom(TVill) then
  begin
    (Dest as TVill).fName := fName;
    (Dest as TVill).fNas := fNas;
    (Dest as TVill).fcoord_X := fcoord_X;
    (Dest as TVill).fcoord_Y := fcoord_Y;
    (Dest as TVill).fIs_Capital := fIs_Capital;
  end
  else
    inherited;
end;

function TVill.Send_Troop(WBContainer: TWBContainer; AFarmItem: TFarmItem;
  FLog: TStringList): TFarmReturn_Code;
var
  document: IHTMLDocument2;
  DocumentHTML: IHTMLDocument2;
  Build_Element: IHTMLElement;
  field_Element :IHTMLElement;
  Tmp_Collection : IHTMLElementCollection;
  Container_Collection: IHTMLElementCollection;
  TabShit_Element :IHTMLElement;
  url: string;
  ItemNumber, TabshitNumber: Integer;
begin
  //Обнуляем резалт
  Result.Return_Code := 0;
  Result.TargetNameVil := '';
  Result.TargetNamePlayer := '';
  Result.TargetNameAli := '';
  Result.TravelTime := 0;
  Build_Element := nil;
  FLog.Add('Будем отсылать войско по координатам :(' + IntToStr(AFarmItem.FCoords.X) +
    '|' + IntToStr(AFarmItem.Coords.Y) + ')');
  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;
  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // Проверим стоим ли мы на DORF2 ????  и если нет то перейдем на неё
  if (copy(url, length(url) - 8) <> 'dorf2.php') then
  begin
    Flog.Add('Нет не стоим, будем на неё переходить');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf2.php', 1);
  end;
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf2.php') then
  begin
    Flog.Add('Что-то не то; На DORF2 так и не перешли');
    Result.Return_Code:=-1;  // showmessage('Что-то не то');
    exit;
  end;
  //теперь среди всех посроек исчем пункт збора  у нее ГИД=39
  Flog.Add('Жмем на пункт збора');
  document := FindAndClickHref(WBContainer, document,
            Account.Connection_String + '/' + 'build.php?id=39', 1);
  Flog.Add('Анализ ПЗ. Пока поверхосный, токо смотрим пункт збора это или нет');
  //Достаточно если есть <div id="build" class="gid16"> в полученой странице , значит открыли пункт збора
  //Вдальнейшем будет функа которая будет парсить всю инфу о пунке збора, особенно
  //о наличии войск и кому пренадлежат + скоко ресов в данный момент несут восйка.
  Build_Element := (Document as IHTMLDocument3).getElementById('build');
  if Assigned(Build_Element) then
  begin     //нашли пункт збора и место где кнопочки на отправку
    Flog.Add('Стоип внутри пункта збора, ищем кнопку отправит войска.');
    Tmp_Collection := Build_Element.children as IHTMLElementCollection;
    TabShit_Element := nil;
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
      if Uppercase(field_Element.className) = 'CONTENTNAVI TABNAVI' then
      begin
        //нашли панельку с кнопками на Пс , теперь найдем 2 кнопку(закладку) и тыцнем на нее
        Container_Collection := field_Element.children as IHTMLElementCollection;
        for TabshitNumber := 0 to Container_Collection.length - 1 do //по идеи 4 леемента
        // 2 елемент отправка войск
        begin
          if TabshitNumber = 1 then
          begin
            field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
            //дальше мне лень что копаться ... думаю зря все это сразу капал жмем на елемент и не мучаемся :)
            Flog.Add('Кнопку нашли;  Отправить войска');
            Flog.Add('А теперь  Нажимаем на неё');
            //даный такой изврат нужен был для того чтоб 100 % тыцнуть на кнопку , может дальше все это уберем
            WBContainer.MyElementClick(field_Element);
            document := WBContainer.HostedBrowser.Document as IHTMLDocument2;
          end
        end;
      end;
    end;
  end;
  //Щас мы по идеи должны тостья на ,,,/a2b.php ///
end;


function TVill.build_center(WBContainer: TWBContainer; const FId, GId: string;
  FLog: TStringList): TBuildReturn_Code;
//  Постройка центра
//   FId  - Id  поля на котором надо строить
//   GId  - GId здания
var
  document: IHTMLDocument2;
  url: string;

  Tmp_Collection : IHTMLElementCollection;
  field_Element :IHTMLElement;
  ItemNumber: integer;
  Contract_Element :IHTMLElement;
  Button_Element :IHTMLElement;
  DocumentHTML: IHTMLDocument2;

  Build_Element :IHTMLElement;

begin
  Result.Return_Code:=0;
  Result.R1:=0;
  Result.R2:=0;
  Result.R3:=0;
  Result.R4:=0;
  Result.R5:=0;
  Result.Duration:=0;
  Result.Wait:=0;
  Result.Text:='';


  Flog.Add('============================');
  Flog.Add('Будем строить  FId='+FID+' ('+GetBuilding(StrToInt(FID)).name+')');

  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;

  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // Проверим стоим ли мы на DORF2 ????  и если нет то перейдем на неё
  Flog.Add('Проверим стоим ли мы на DORF2 ????');
  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('Нет не стоим, будем на неё переходить');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf2.php', 1);
  end;

  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('Что-то не то; На DORF2 так и не перешли');
    Result.Return_Code:=-1;  // showmessage('Что-то не то');
    exit;
  end;

  // Итак стоим на дорф2  отпрепарируем её
  (Account.Account_data as TAccount_Data).Clone_Document(DocumentHTML);
  prepare_dorf2(document,DocumentHTML,Flog);

  // Проверим GID  (так, на всякий)

  if (Item_Building[StrToInt(FId)].gid <> 0) and (Item_Building[StrToInt(FId)].gid <> StrToInt(GId)) then
  begin
    Flog.Add('Несовпадение GID ');
    Result.Return_Code:=-1;  // showmessage('Что-то не то');
    exit;
  end;

  // Нажмем на ссылку
  Flog.Add('Нажмем на ссылку'+'build.php?id='+FId);
  document := FindAndClickHref(WBContainer, document,'build.php?id='+FId, 4);

  Contract_Element:=nil;
  if Item_Building[StrToInt(FId)].gid <> 0 then
  begin  // Существующее здание
    Flog.Add('Анализ <div id="contract"');   //<div id="contract" class="contractWrapper"><span class="none">Схованка максимального рівня</span></div>

    Contract_Element := (Document as IHTMLDocument3).getElementById('contract');
  end
  else
  begin  // Новостройка!!!!
    //  Ищем нужное здание
    Flog.Add('Анализ <div id="build"');   //<div id="build"

    build_Element := (Document as IHTMLDocument3).getElementById('build');
    Tmp_Collection := build_Element.children as IHTMLElementCollection;
    // Нужная нам последовательность
    //  h2
    //  build_desc
    //  contract
    //  clear
    //  hr
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
      if Uppercase(field_Element.tagName) = 'H2' then
      begin
        field_Element := Tmp_Collection.item(ItemNumber+1, '') as IHTMLElement;
        if Uppercase(field_Element.className) = 'BUILD_DESC' then
        begin
          field_Element :=(field_Element.children as IHTMLElementCollection).item(0, '') as IHTMLElement;
          if Uppercase(field_Element.className) = 'BUILD_LOGO' then
          begin
            field_Element :=(field_Element.children as IHTMLElementCollection).item(0, '') as IHTMLElement;
            if (Uppercase(copy(field_Element.className,1,8)) = 'BUILDING') and
               (copy(field_Element.className,length(field_Element.className)-1) = GId) then
            begin   // Это то что нам надо НАВЕРНОЕ!!!
              field_Element := Tmp_Collection.item(ItemNumber+2, '') as IHTMLElement;
              if Uppercase(field_Element.id) = 'CONTRACT' then
                Contract_Element:=field_Element;
            end;

          end;

        end;

      end;
    end;
  end;


  if Assigned(Contract_Element) then
  begin  // НАшли Contract
    Tmp_Collection := Contract_Element.children as IHTMLElementCollection;

    Result:=Prepare_Contract(Tmp_Collection,FLog);
    if Result.Return_Code = 0 then
    begin
      Flog.Add('Ищем кнопку');
      Button_Element:=nil;
      for ItemNumber := 0 to Tmp_Collection.Length - 1 do
      begin
        field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
        if Uppercase(field_Element.className) = 'CONTRACTLINK' then
        begin
          field_Element:=(field_Element.children as IHTMLElementCollection).item(0,'') as IHTMLElement;
          if Uppercase(field_Element.tagName) = 'BUTTON' then
          begin
            Button_Element:=field_Element;
            break;
          end;
        end;
      end;


      if Assigned(Button_Element) then
      begin  //  кнопка есть  нажмем на неё
        Flog.Add('Кнопку нашли;  Анализ');
        Flog.Add('А теперь  Нажимаем на неё');
        WBContainer.MyElementClick(field_Element);
      end
      else begin
        Flog.Add('Кнопки нет; Ошибка в парсере и нашей логике');
        Result.Return_Code:=-1;
      end;
    end;
  end;


  // Проверим стоим ли мы на DORF2 ????  и если нет то перейдем на неё
  Flog.Add('Проверим стоим ли мы на DORF2 ????');
  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('Нет не стоим, будем на неё переходить');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('Что-то не то; На DORF1 так и не перешли');
    Result.Return_Code:=-3;  // showmessage('Что-то не то');
    exit;
  end;

end;

function TVill.build_field(WBContainer: TWBContainer; const FId, GId: string; FLog: TStringList):TBuildReturn_Code;
//  Постройка ферм
//   FId  - Id  поля на котором надо строить
//   GId  - Не используется (введено для однообразного интерфейса с стройкой в центе)
var
  document: IHTMLDocument2;
  url: string;

  Tmp_Collection : IHTMLElementCollection;
  field_Element :IHTMLElement;
  ItemNumber: integer;
  Contract_Element :IHTMLElement;
  Button_Element :IHTMLElement;
  DocumentHTML: IHTMLDocument2;
begin
  Result.Return_Code:=0;
  Result.R1:=0;
  Result.R2:=0;
  Result.R3:=0;
  Result.R4:=0;
  Result.R5:=0;
  Result.Duration:=0;
  Result.Wait:=0;
  Result.Text:='';


  Flog.Add('============================');
  Flog.Add('Будем строить  FId='+FID+' ('+GetBuilding(StrToInt(FID)).name+')');

  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;

  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // Проверим стоим ли мы на DORF1 ????  и если нет то перейдем на неё
  Flog.Add('Проверим стоим ли мы на DORF1 ????');
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('Нет не стоим, будем на неё переходить');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('Что-то не то; На DORF1 так и не перешли');
    Result.Return_Code:=-1;  // showmessage('Что-то не то');
    exit;
  end;

  // Итак стоим на дорф1  отпрепарируем её
  (Account.Account_data as TAccount_Data).Clone_Document(DocumentHTML);
  prepare_dorf1(document,DocumentHTML,Flog);

  // Нажмем на ссылку
  Flog.Add('Нажмем на ссылку'+'build.php?id='+FId);
  document := FindAndClickHref(WBContainer, document,'build.php?id='+FId, 4);


  Flog.Add('Анализ <div id="contract"');   //<div id="contract" class="contractWrapper"><span class="none">Схованка максимального рівня</span></div>

  Contract_Element := (Document as IHTMLDocument3).getElementById('contract');
  Tmp_Collection := Contract_Element.children as IHTMLElementCollection;

  Result:=Prepare_Contract(Tmp_Collection,FLog);
  if Result.Return_Code = 0 then
  begin
    Flog.Add('Ищем кнопку');
    Button_Element:=nil;
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
      if Uppercase(field_Element.className) = 'CONTRACTLINK' then
      begin
        field_Element:=(field_Element.children as IHTMLElementCollection).item(0,'') as IHTMLElement;
        if Uppercase(field_Element.tagName) = 'BUTTON' then
        begin
          Button_Element:=field_Element;
          break;
        end;
      end;
    end;


    if Assigned(Button_Element) then
    begin  //  кнопка есть  нажмем на неё
      Flog.Add('Кнопку нашли;  Анализ');
      Flog.Add('А теперь  Нажимаем на неё');
      WBContainer.MyElementClick(field_Element);
    end
    else begin
      Flog.Add('Кнопки нет; Ошибка в парсере и нашей логике');
      Result.Return_Code:=-1;
    end;
  end;


  // Проверим стоим ли мы на DORF1 ????  и если нет то перейдем на неё
  Flog.Add('Проверим стоим ли мы на DORF1 ????');
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('Нет не стоим, будем на неё переходить');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('Что-то не то; На DORF1 так и не перешли');
    Result.Return_Code:=-3;  // showmessage('Что-то не то');
    exit;
  end;

end;

constructor TVill.Create(Collection: TCollection);
begin
  inherited;
  //создаем пустой фарм лист
  FFarmLists := TFarmList.Create;
end;

function TVill.GetBuilding(Index: integer): TBuilding;
begin
  Result := Building[Index];
end;

function TVill.get_coord: string;
begin
  Result := '(' + IntToStr(fcoord_X) + '|' + IntToStr(fcoord_Y) + ')';
end;

function TVill.get_ID: integer;
begin
  Result := 801 * abs((coord_Y - 400)) + (coord_X + 400) + 1;
end;

procedure TVill.prepare_dorf1_T36(Document: IHTMLDocument2; DocumentHTML:
  IHTMLDocument2; FLog: TStringList);
var
  field_Element: IHTMLElement;
  Tmp_Collection: IHTMLElementCollection;
  Attr_Collection: IHTMLAttributeCollection;
  Attr_Element: IHTMLDOMAttribute;

  ItemNumber: integer;
  ItemAttrNumber: integer;
  ItemBuild: integer;
  TmpStringBuild: string;
begin
  //
  // Найдем элемент по id="village_map"
  //   (<div id="village_map" class="f7">)
  //  его класс укажет нам на тип клетки
  field_Element := (document as IHTMLDocument3).getElementById('village_map');
  TypeField := StrToInt(copy(field_Element.className, 2));
  // gid полей
  for ItemBuild := 1 to 18 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := Res_for_fields[TypeField, ItemBuild];
  end;

  // Ну а теперь пройдемся по содержимому field_Element
  // и вытащим информацию о полях
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.Length - 2 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    Attr_Collection := (field_Element as IHTMLDOMNode).attributes as
      IHTMLAttributeCollection;
    TmpStringBuild := field_Element.className;
    // Ну там что-то вот такое "reslevel rf1 level10"
    TmpStringBuild := copy(TmpStringBuild, 12); // Удалили "reslevel rf"
    // Теперь до пробела это номер поля  и после lelel - это уровень постройки
    ItemBuild := StrToInt(copy(TmpStringBuild, 1, pos(' ', TmpStringBuild) -
      1));
    Building[ItemBuild].lvl := StrToInt(copy(TmpStringBuild, pos('level',
      TmpStringBuild) + 5));
    for ItemAttrNumber := 0 to Attr_Collection.Length - 1 do
    begin
      Attr_Element := Attr_Collection.item(ItemAttrNumber) as IHTMLDOMAttribute;
      if Attr_Element.specified then
        if Attr_Element.nodeName = 'alt' then
          Building[ItemBuild].name := Attr_Element.nodeValue;
    end;
  end;

  prepare_Vlist_T36(Document,DocumentHTML,FLog);
end;

procedure TVill.prepare_dorf1_T40(Document: IHTMLDocument2; DocumentHTML:
  IHTMLDocument2; FLog: TStringList);
var
  field_Element: IHTMLElement;
  Area_Element: IHTMLAreaElement;

  Tmp_Collection: IHTMLElementCollection;

  ItemNumber: integer;
  ItemBuild: integer;
  TmpStringBuild: string;
begin
  FLog.Add('Разбор Dorf1);');

  //  Вот тут и будем вытягивать инфу о фермах !
  //  <map name="rx" id="rx">
  //  <area href="build.php?id=1" coords="190,88,28" shape="circle" alt="Лесопилка Уровень 10">
  //  тип клетки тут по айдишнику определяетьс я... тут возмем уровень тип и название
  //  его класс укажет нам на тип клетки

  field_Element := (document as IHTMLDocument3).getElementById('village_map');
  TypeField := StrToInt(copy(field_Element.className, 2));

  // gid полей
  for ItemBuild := 1 to 18 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := Res_for_fields[TypeField, ItemBuild];
  end;

  // Ну а теперь пройдемся по содержимому field_Element
  // и вытащим информацию о полях
  field_Element := (DocumentHTML as IHTMLDocument3).getElementById('rx');
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);

  for ItemNumber := 0 to Tmp_Collection.Length - 2 do
  begin
    Area_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLAreaElement;
    TmpStringBuild := Area_Element.alt;
    // Чтото типа вот такого "Залізна копальня Рівень 0"
    Building[ItemNumber + 1].lvl := StrToInt(copy(TmpStringBuild,
      LastDelimiter(' ', TmpStringBuild)));
    Building[ItemNumber + 1].name := TmpStringBuild;
  end;

  prepare_Vlist_T40(Document,DocumentHTML,FLog);

end;

procedure TVill.prepare_dorf2_T36(Document: IHTMLDocument2; DocumentHTML:
  IHTMLDocument2; FLog: TStringList);
var
  field_Element: IHTMLElement;
  Tmp_Collection: IHTMLElementCollection;
  Attr_Collection: IHTMLAttributeCollection;
  Attr_Element: IHTMLDOMAttribute;

  ItemNumber: integer;
  ItemAttrNumber: integer;
  ItemBuild: integer;
  TmpStringBuild: string;
begin
  // Занулим gid полей и уровни
  for ItemBuild := 19 to 40 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := 0;
    Building[ItemBuild].lvl := 0;
  end;

  //
  // Найдем элемент по id="village_map"
  field_Element := (document as IHTMLDocument3).getElementById('village_map');

  // Ну а теперь пройдемся по содержимому field_Element
  // и вытащим информацию о полях
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to 19 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    Attr_Collection := (field_Element as IHTMLDOMNode).attributes as
      IHTMLAttributeCollection;
    TmpStringBuild := field_Element.className;
    // Ну там что-то вот такое "building d1 iso" или "building d7 g10" ну или для строящегося "building d7 g10b"
    TmpStringBuild := copy(TmpStringBuild, 11); // Удалили "building d"
    if copy(TmpStringBuild, length(TmpStringBuild), 1) = 'b' then
      // Здесь идет стройка?????
      TmpStringBuild := copy(TmpStringBuild, 1, length(TmpStringBuild) - 1);

    // Теперь до пробела это номер поля  и после -gid или iso
    ItemBuild := StrToInt(copy(TmpStringBuild, 1, pos(' ', TmpStringBuild) - 1))
      + 18;
    if copy(TmpStringBuild, pos(' ', TmpStringBuild) + 1, 1) = 'g' then
      Building[ItemBuild].gid := StrToInt(copy(TmpStringBuild, pos(' ',
        TmpStringBuild) + 2));

    for ItemAttrNumber := 0 to Attr_Collection.Length - 1 do
    begin
      Attr_Element := Attr_Collection.item(ItemAttrNumber) as IHTMLDOMAttribute;
      if Attr_Element.specified then
        if Attr_Element.nodeName = 'alt' then
          Building[ItemBuild].name := Attr_Element.nodeValue;
    end;
  end;

  // Теперь разберемся с уровнями полей
  // Найдем элемент по id="levels"
  // и вытащим информацию о уровнях
  field_Element := (document as IHTMLDocument3).getElementById('levels');
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.length - 1 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    TmpStringBuild := field_Element.className;
    // Ну там что-то вот такое "d7" или "l40"
    ItemBuild := StrToInt(copy(TmpStringBuild, 2));
    if copy(TmpStringBuild, 1, 1) = 'd' then
      ItemBuild := ItemBuild + 18;
    Building[ItemBuild].lvl := StrToInt(field_Element.innerText);
  end;

  // И теперь разберемся с пунктом сбора и оградой
  Building[39].gid := 16;
  //  Building[40].gid:=30+race;  впрочим с расой надо раньше разбираться

end;

procedure TVill.prepare_dorf2_T40(Document: IHTMLDocument2; DocumentHTML:
  IHTMLDocument2; FLog: TStringList);
var
  field_Element: IHTMLElement;
  Tmp_Collection: IHTMLElementCollection;
  Area_Element: IHTMLAreaElement;
  ItemNumber: integer;
  ItemBuild: integer;
  curentIDBuild: Integer;
  TmpStringBuild: string;
//  A : TStringList;
begin
  // Занулим gid полей и уровни
  for ItemBuild := 19 to 40 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := 0;
    Building[ItemBuild].lvl := 0;
  end;

  //

  // Найдем элемент по id="clickareas"
  field_Element := (DocumentHTML as IHTMLDocument3).getElementById('clickareas');

  // Ну а теперь пройдемся по содержимому field_Element
  // и вытащим информацию о полях
  //проходим  по всем <area alt="Торговая палата Уровень 9" shape из <map name="clickareas" id="clickareas">
  //запоминаем АЙДИ и имя постройки (хотя там можно из названия Уровень вытащить)
  //потом проходим по всем <img style="left:81px; top:57px; z-index:19" src="img/x.gif" class="building g28" alt="Торговая палата Уровень 9">
  //и вытягиваем клас потсройки , просто порядок один и тотже , но для проверки будем сравнивать названия построек.
  //P.S. Пунк збора можно построить токо на своем месте id=39, все остальное и ГЗ может быть где угодно , а да и изгородь
  //id=40 , вот собственно все.
   Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to 21 do
  begin
    Area_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLAreaElement;
    curentIDBuild :=StrToInt(copy(Area_Element.href,
                           LastDelimiter('=', Area_Element.href) + 1
                                 )
                            );
    Building[curentIDBuild].Id := curentIDBuild;
    Building[curentIDBuild].name := Area_Element.alt;
      // Уроани построек вытащим позже при определении ГИД
  end;

  //работаем над определинием ГИД
  //для внутрених полей надо токо первые 21 ИМГ ,22 -я это стенка
  field_Element := (Document as IHTMLDocument3).getElementById('village_map');
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  curentIDBuild := 19;
  for ItemNumber := 0 to Tmp_Collection.length-1 do
  begin
    begin
      field_Element:= Tmp_Collection.item(ItemNumber, '')as IHTMLElement;
      if (field_Element.tagName = 'IMG') then
      begin
        if  (curentIDBuild = 40) then
        begin
          if copy(Building[curentIDBuild].name,1,4) = 'wall' then   // Ну нет у мну теперь деревни без ограды и поэтому пока так
          begin
            TmpStringBuild:=Uppercase(Copy(field_Element.className,LastDelimiter(' ', field_Element.className) + 1));  // 'ISO' или 'Gxx' где xx - ГИД
            Building[curentIDBuild].gid := StrToInt(Copy(TmpStringBuild,2,2));
            Building[curentIDBuild].lvl := StrToInt(copy(Building[curentIDBuild].name,LastDelimiter(' ', Building[curentIDBuild].name) + 1));
            break;
          end;
        end
        else begin
          TmpStringBuild:=Uppercase(Copy(field_Element.className,LastDelimiter(' ', field_Element.className) + 1));  // 'ISO' или 'Gxx' где xx - ГИД
          if TmpStringBuild <> 'ISO' then
          begin // тобиш тут что-то построено
            Building[curentIDBuild].gid := StrToInt(Copy(TmpStringBuild,2));
            // Есть ГИД значит есть и Уровень постройки
            Building[curentIDBuild].lvl := StrToInt(copy(Building[curentIDBuild].name,LastDelimiter(' ', Building[curentIDBuild].name) + 1));
          end;
          Inc(curentIDBuild);
        end;
      end;
    end;
  end;

{
  A := TStringList.Create;
  for ItemBuild := 19 to 40 do
   A.Add('Id=' + IntToStr(Building[ItemBuild].id) + ' Name=' +
         Building[ItemBuild].name + ' Level=' + IntToStr(Building[ItemBuild].lvl) +
         ' GID=' + IntToStr(Building[ItemBuild].gid));
  showmessage(A.Text);
  A.Free;
}
end;

procedure TVill.prepare_Vlist_T36(Document, DocumentHTML: IHTMLDocument2;
  FLog: TStringList);
//  Обработка списка поселений в правой части страницы
var
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  irow: integer;
  icol: integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML: IHTMLTableCell;
  Cell_Element: IHTMLElement;
  Current_Vill: TVill;

  V_Name: string;
  V_NewDid: string;
  V_Coord: string;
  Tmp_String: string;
  t1, t2: integer;
begin
   field_Element := (document as IHTMLDocument3).getElementById('vlist');
  if not Assigned(field_Element) then
    exit;

  Table_IHTML:=(field_Element as IHTMLTable);

  // Это список поселений!!!!
  //  Наименование
  //  Координаты (x|y)
  //  NewDid   -- Собственно из-за которого мы сюда и забрались!

  if not Assigned(Table_IHTML) then
    exit;

  // Первая строка нам не нужна!!!
  for irow := 1 to Table_IHTML.rows.length - 1 do
  begin // Строки таблицы
    Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
    //  Первая колонка нас не интересует!!!
    for icol := 1 to Row_IHTML.cells.length - 1 do
    begin
      Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
      Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
      case icol of
        1:
          begin
            V_Name := Cell_Element.innerText;
            Tmp_String := Cell_Element.innerHTML;
            t1 := pos('newdid=', Tmp_String);
            t2 := pos('&', Tmp_String);
            if (t1 > 0) and (t2 > t1 + 7) then
              V_NewDid := copy(Tmp_String, t1 + 7, t2 - (t1 + 7));
          end;
        2: V_Coord := Cell_Element.innerText;
      end;
    end; // for icol
    Current_Vill := Account.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
    Current_Vill.Name := V_Name;
    Current_Vill.NewDID := V_NewDid;
    Current_Vill.set_coord(V_Coord);
  end; // for irow
end;

procedure TVill.prepare_Vlist_T40(Document, DocumentHTML: IHTMLDocument2;
  FLog: TStringList);
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  DIV_List: IHTMLElementCollection;
  UL_List: IHTMLElementCollection;
  LI_List: IHTMLElementCollection;
  V_Coord: string;
  Regex: TPerlRegEx;
  Newdid_Current_Vill: TVill; //текущая деревня в которую впихиваем NewDid
  V_NewDid: string; //храним NewDid текущей  расматриваемой строчки тега А
begin
  FLog.Add('Поопределяем newdid по сылкам справа.');
  FLog.Add('Для это найдем елеменит LI class=entry и все че в нем лежит');
  //здесь и берем нами созданый DocumentHTML с исходным кодом
  DIV_List := DocumentHTML.all.tags('DIV') as IHTMLElementCollection;
  FLog.Add('Обход все LI тегов');

  for ItemNumber := 0 to DIV_List.Length - 1 do
  begin
    field_Element := DIV_List.item(ItemNumber, '') as IHTMLElement;
    FLog.Add('Текущая структура ' + field_Element.className);
    if field_Element.className = 'list' then
    begin
      FLog.Add('нашли нужный div клас = ' + field_Element.className);
      UL_List := field_Element.children as IHTMLElementCollection;
      break;
    end;
  end;

  if Assigned(UL_List) then
  begin
    FLog.Add('просматриваем все ' + IntToStr(UL_List.Length) + ' сылок ');
    for ItemNumber := 0 to UL_List.Length - 1 do
    begin
      //заносим в field_Element весь тег <a  ..../a> целиком
      field_Element := UL_List.item(ItemNumber, '') as IHTMLElement;
      LI_List := field_Element.children as IHTMLElementCollection;
      Break;
    end;

    if Assigned(LI_List) then
    begin
      for ItemNumber := 0 to LI_List.Length - 1 do
      begin    // Просмотр всего списка
        //получили <a ...хреф с newdid каждой деревни
        field_Element := LI_List.item(ItemNumber, '') as IHTMLElement;
        Flog.Add('Берем хтмл код тега А (смотри ниже):');
        FLog.Add(field_Element.innerHTML);
        Regex := TPerlRegEx.Create(nil);
        try
          RegEx.RegEx :=
            '<A.*coordinateX.*\((-*\d+).*coordinateY">(-*\d*)\).*href="\?newdid=(\d*).*';
          RegEx.Subject := field_Element.innerHTML;
          if Regex.Match then
          begin
            Flog.Add('Нашли по регулярки инфу по деревне');
            Flog.Add('newdid=' + Regex.SubExpressions[3]);
            Flog.Add('Координаты =' + V_Coord);
            V_NewDid := Regex.SubExpressions[3];
            V_Coord := '(' + Regex.SubExpressions[1] + '|' + Regex.SubExpressions[2]
              + ')';
            Newdid_Current_Vill := Account.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
            Newdid_Current_Vill.NewDID := V_NewDid;
            Newdid_Current_Vill.set_coord(V_Coord);
          end
          else
          begin
            FLog.Add('Касяк !');
            showmessage('Rase Dont бля , короче не пашит ... выходим');
          end;
        finally
          Regex.Free;
        end;
      end;  // Просмотр всего списка
    end; // if Assigned(LI_List)
  end;  // if Assigned(UL_List)

end;


procedure TVill.SetGidForId40(AValue: integer);
begin
  Building[40].gid := AValue;
end;

function TVill.set_coord(const coord: string): Boolean;
// coord - (X|Y)
//  True  - Всё хорошо
//  False - Неверен формат входной строки
var
  tmp_string: string;
  i: integer;
begin
  //  Проверим первый и последний символ, это должны быть скобки
  Result := (Copy(coord, 1, 1) = '(') and (Copy(coord, length(coord), 1) = ')');
  fcoord_X := 0;
  fcoord_Y := 0;
  if Result then
  begin
    i := pos('|', coord);
    Result := ((i > 2) and (i < length(coord) - 1));
    if Result then
    begin
      tmp_string := Copy(coord, 2, i - 2);
      Result := TryStrToInt(tmp_string, fcoord_X);
      if Result then
      begin
        tmp_string := Copy(coord, i + 1, length(coord) - i - 1);
        Result := TryStrToInt(tmp_string, fcoord_Y);
      end;

    end;
  end;

end;

{ TVills }

function TVills.CheckAndAdd_Vill_By_Coord(coord: string): TVill;
var
  i: integer;
begin
  i := FindByCoord(coord);
  if i > -1 then
    Result := Items[i] as TVill
  else
  begin
    Result := TVill.Create(Self);
    Result.set_coord(coord);
    Result.Account := Account;
    case Account.TravianVersion of
      tv40:
        begin
          Result.prepare_dorf1 := Result.prepare_dorf1_T40;
          Result.prepare_dorf2 := Result.prepare_dorf2_T40;
          Result.prepare_vlist := Result.prepare_vlist_T40;
        end;
      tv36:
        begin
          Result.prepare_dorf1 := Result.prepare_dorf1_T36;
          Result.prepare_dorf2 := Result.prepare_dorf2_T36;
          Result.prepare_vlist := Result.prepare_vlist_T36;
        end;
    end
  end;
end;

function TVills.CheckAndAdd_Vill_By_XY(x, y: integer): TVill;
var
  i: integer;
begin
  i := FindByXY(x, y);
  if i > -1 then
    Result := Items[i] as TVill
  else
  begin
    Result := TVill.Create(Self);
    Result.fcoord_X := X;
    Result.fcoord_Y := Y;
    Result.Account := Account;
    case Account.TravianVersion of
      tv40:
        begin
          Result.prepare_dorf1 := Result.prepare_dorf1_T40;
          Result.prepare_dorf2 := Result.prepare_dorf2_T40;
          Result.prepare_vlist := Result.prepare_vlist_T40;
        end;
      tv36:
        begin
          Result.prepare_dorf1 := Result.prepare_dorf1_T36;
          Result.prepare_dorf2 := Result.prepare_dorf2_T36;
          Result.prepare_vlist := Result.prepare_vlist_T36;
        end;
    end
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
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    if ((Items[i] as TVill).fcoord_X = X) and ((Items[i] as TVill).fcoord_Y = Y)
      then
    begin
      Result := i;
      Exit;
    end;
  end;

end;

function TVills.FindByCoord(coord: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TVill).coord = coord then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TVills.FindById(ID: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TVill).ID = ID then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TVills.FindByNewDId(NewDId: string): integer;
var
  i: integer;
begin
  Result := -1;
  if Count = 1 then
    Result := 0
  else
    for i := 0 to Count - 1 do
    begin
      if (Items[i] as TVill).NewDID = NewDID then
      begin
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
  Result := FOwner;
end;

function TVills.VillByXY(X, Y: integer): TVill;
var
  i: integer;
begin
  Result := nil;
  i := FindByXY(X, Y);
  if i >= 0 then
    Result := Items[i] as TVill
end;

function TVills.VillByCoord(coord: string): TVill;
var
  i: integer;
begin
  Result := nil;
  i := FindByCoord(coord);
  if i >= 0 then
    Result := Items[i] as TVill
end;

function TVills.VillById(ID: integer): TVill;
var
  i: integer;
begin
  i := FindById(Id);
  if i >= 0 then
    Result := Items[i] as TVill
  else
    raise EGrParamError.Create(rsVillBadId + '- "' + IntToStr(Id) + '"');

end;

function TVills.VillByNewDId(NewDId: string): TVill;
var
  i: integer;
begin
  i := FindByNewDId(NewDId);
  if i >= 0 then
    Result := Items[i] as TVill
  else
    raise EGrParamError.Create(rsVillBadNewDId + '- "' + NewDId + '"');

end;


constructor TAccount.Create;
begin
  inherited;
  delta_time:=0;
  Derevni := TVills.Create;
  derevni.Account:=self;
end;

function TAccount.GetTravianTime: TDateTime;
begin
  Result := now + delta_time;
end;

function TAccount.get_Derevni_Count: integer;
begin
  result := fDerevni.Count;
end;

procedure TAccount.prepare_profileT36(WBContainer: TWBContainer; document,
  DocumentHTML: IHTMLDocument2; FLog: TStringList);
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  All_Tables: IHTMLElementCollection;
  irow, icol: integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML: IHTMLTableCell;
  Cell_Element: IHTMLElement;
  sw: Boolean;
  //  Prifile_Line: string;
  V_Name: string;
  V_Nas: string;
  V_Coord: string;
  Current_Vill: TVill;
  Is_Capital: Boolean;
  Tmp_String: string;
  Tmp_ClassName: string;
  Tmp_Element: IHTMLElement;
  url: string;
begin
  if not Assigned(document) then
    exit;
  FLog.Add('Обработка профиля');
  Is_Capital := False;
  sw := false;
  Current_Vill:=nil;

  if UID = '' then // Если неопределен то UID вытащим из URL
    UID := copy(document.url, length(Connection_String + '/spieler.php?uid=') +
      1);
  FLog.Add('UID игрока -' + UID);
  if Race = 0 then
  begin // Раса неопределена попытаемся её определить
    //  Вытащим расу по классу ID элемента (id="qgei") -
    //       class="q_l1" - римляне
    //       class="q_l2" - тевтонцы
    //       class="q_l3" - галлы

    field_Element := (document as IHTMLDocument3).getElementById('qgei');
    if Assigned(field_Element) then
    begin
      Tmp_ClassName := field_Element.className;
      if pos('l1', Tmp_ClassName) > 0 then
        Race := 1 //римляне
      else if pos('l2', Tmp_ClassName) > 0 then
        Race := 2 //тевтонцы
      else if pos('l3', Tmp_ClassName) > 0 then
        Race := 3; //галлы
    end;
  end; // MyAccount.Race = 0

  All_Tables := document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber, '') as IHTMLElement;
    if field_Element.id = 'profile' then
      sw := true;
    if sw and (field_Element.id = '') then
    begin // Это внутренность профиля
      //  Ранг
      //  Нация
      //  Альянс
      //  Поселений
      //  Человек
      sw := false;
      Table_IHTML := field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
        // Нас интересуют первые 5 строк таблицы
        if irow >= 5 then
          break;
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
        end;
      end;
    end; // Это внутренность профиля

    if field_Element.id = 'villages' then
    begin // Это список поселений!!!!
      //  Наименование (включая Столица)
      //  Население
      //  Координаты (x|y)
      Table_IHTML := field_Element as IHTMLTable;
      // Первые две строки нам не нужны!!!
      for irow := 2 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;

          case icol of
            0:
              begin
                V_Name := Cell_Element.innerText;
                Tmp_String := Cell_Element.innerHTML;
                Is_Capital := (pos('SPAN', Tmp_String) > 1);
                url := '';
                if (cell_element.children as IHTMLElementCollection).length > 0
                  then
                begin // ссылка на карту
                  Tmp_Element := (cell_element.children as
                    IHTMLElementCollection).Item(0, '') as IHTMLElement;
                  if Tmp_Element.tagName = 'A' then
                    url := Tmp_Element.toString;
                end;

              end;
            1: V_Nas := Cell_Element.innerText;
            2: V_Coord := Cell_Element.innerText;
          end;
        end;
        Current_Vill := Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        Current_Vill.Name := V_Name;
        Current_Vill.Nas := StrToInt(V_Nas);
        Current_Vill.Is_Capital := Is_Capital;
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link := copy(url, pos('?', url) + 1);
      end; // for irow
    end; // if field_Element.id = 'villages' Это список поселений!!!!

//    if field_Element.id = 'vlist' then
//      //  Это список поселений в правой части страницы
//      prepare_Vlist36(field_Element as IHTMLTable, self);
  end; // for ItemNumber ....


  if Assigned(Current_Vill) then
    Current_Vill.prepare_Vlist_T36(document, DocumentHTML, FLog)

end;

procedure TAccount.prepare_profileT40(WBContainer: TWBContainer; document,
  DocumentHTML: IHTMLDocument2; FLog: TStringList);
//   Обработка профиля
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  All_Tables: IHTMLElementCollection;
  irow, icol: integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML: IHTMLTableCell;
  Cell_Element: IHTMLElement;
  sw: Boolean;
  //  Prifile_Line: string;
  V_Name: string;
  V_Nas: string;
  V_Coord: string;
  Current_Vill: TVill;
  Is_Capital: Boolean;
  Tmp_String: string;
  Tmp_Element: IHTMLElement;
  url: string;
  Regex: TPerlRegEx;
begin
  if not Assigned(document) then
    exit;
  FLog.Add('Обработка профиля');
  Is_Capital := False;
  sw := false;
  Current_Vill:=nil;

  if UID = '' then // Если неопределен то UID вытащим из URL
    UID := copy(document.url, length(Connection_String + '/spieler.php?uid=') +
      1);
  FLog.Add('UID игрока -' + UID);
  FLog.Add('Определяем расу ...');
  if Race = 0 then
  begin // Раса неопределена попытаемся её определить
    //  Вытащим расу по классу <img class="nationBig nationBig2"
    //       nationBig1" - римляне
    //       nationBig2" - тевтонцы
    //       cnationBig3" - галлы
    Regex := TPerlRegEx.Create(nil);
    try
      RegEx.RegEx := '<img\sclass="nationBig\snationBig(\d)"';
      RegEx.Subject := Doc_GetHTMLCode(document);
      if Regex.Match then
        case StrToInt(Regex.SubExpressions[1]) of
          1:
            begin
              Race := 1;
              FLog.Add('Раса РИМ');
            end;
          2:
            begin
              Race := 2;
              FLog.Add('Раса Фашист :)');
            end;
          3:
            begin
              Race := 3;
              FLog.Add('Раса Лягушатник :)');
            end;
        end
      else
      begin
        FLog.Add('Касяк расу не определили !');
        showmessage('Rase Dont бля , короче не пашит ... выходим');
      end;
    finally
      Regex.Free;
    end;
  end; // MyAccount.Race = 0
  FLog.Add('Готовимся обходить все TABLE на странице профиля ');
  All_Tables := document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber, '') as IHTMLElement;
    FLog.Add('Текущая структура ' + field_Element.id);
    if field_Element.id = 'details' then
      sw := true;
    if sw and (field_Element.id = '') then
    begin // Это внутренность профиля
      //  Ранг
      //  Нация
      //  Альянс
      //  Поселений
      //  Человек
      sw := false;
      FLog.Add('Пробегаемся по строкам профиля "Ранг, Нация, Альянс..."');
      Table_IHTML := field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
        // Нас интересуют первые 5 строк таблицы
        if irow >= 5 then
          break;
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
        end;
      end;
      FLog.Add('В Row_IHTML занесли строки , в Cell_IHTML ячейки таблицы');
      FLog.Add('в Cell_Element заносим чето такое "IHTMLElement"');
    end; // Это внутренность профиля
    FLog.Add('Берем таблицу "villages"');
    if field_Element.id = 'villages' then
    begin // Это список поселений!!!!
      //  Наименование (включая Столица)
      //  Население
      //  Координаты (x|y)
      Table_IHTML := field_Element as IHTMLTable;
      // Первые две строки нам не нужны!!!
      // Не не токо первая строка не нужна
      FLog.Add('проходимся по строкам таблицы....');
      for irow := 1 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
          FLog.Add('Терь заносим данные о деревнях');
          case icol of
            0:
              begin
                V_Name := Cell_Element.innerText;
                Tmp_String := Cell_Element.innerHTML;
                Is_Capital := (pos('SPAN', Tmp_String) > 1);
                url := '';
                if (cell_element.children as IHTMLElementCollection).length > 0
                  then
                begin // ссылка на карту
                  Tmp_Element := (cell_element.children as
                    IHTMLElementCollection).Item(0, '') as IHTMLElement;
                  if Tmp_Element.tagName = 'A' then
                    url := Tmp_Element.toString;
                end;

              end;
            //1: ЭТО ОАЗЫ !!!
            2: V_Nas := Cell_Element.innerText;
            3: V_Coord := Copy(Cell_Element.innerText, 0, Pos(')',
                Cell_Element.innerText));
          end;
        end;
        Current_Vill := Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        FLog.Add('Устанавливеем текущую деревнюю с координатами =' + V_Coord);
        Current_Vill.Name := V_Name;
        FLog.Add('Имя = ' + V_Name);
        Trim(V_Nas);
        Current_Vill.Nas := bild_lvl(V_Nas);
        FLog.Add('Население = ' + V_Nas);
        Current_Vill.Is_Capital := Is_Capital;
        if Is_Capital then
          FLog.Add('Это столица')
        else
          FLog.Add('Не столица');
        Trim(V_Coord);
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link := copy(url, pos('?', url) + 1);
        FLog.Add('Линк на деревню ' + copy(url, pos('?', url) + 1));
      end; // for irow
    end; // if field_Element.id = 'villages' Это список поселений!!!!
  end; // for ItemNumber ....

  if Assigned(Current_Vill) then
    Current_Vill.prepare_Vlist_T40(document, DocumentHTML, FLog)

end;

procedure TAccount.SetTravianVersion(const Value: TTravianVersion);
var
  i: integer;
begin
  FTravianVersion := Value;
  case TravianVersion of
    tv40:
      begin
        Prepare_profile := prepare_profileT40;
      end;
    tv36:
      begin
        Prepare_profile := prepare_profileT36;
      end;
  end;

  for I := 0 to Derevni.Count - 1 do
  begin
    case TravianVersion of
      tv40:
        begin
          Derevni.Items[i].prepare_dorf1 := Derevni.Items[i].prepare_dorf1_T40;
          Derevni.Items[i].prepare_dorf2 := Derevni.Items[i].prepare_dorf2_T40;
          Derevni.Items[i].prepare_vlist := Derevni.Items[i].prepare_vlist_T40;
        end;
      tv36:
        begin
          Derevni.Items[i].prepare_dorf1 := Derevni.Items[i].prepare_dorf1_T36;
          Derevni.Items[i].prepare_dorf2 := Derevni.Items[i].prepare_dorf2_T36;
          Derevni.Items[i].prepare_vlist := Derevni.Items[i].prepare_vlist_T36;
        end;
    end;
  end;

end;

{
procedure prepare_Vlist36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);
//  Обработка списка поселений в правой части страницы
var
  irow: integer;
  icol: integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML: IHTMLTableCell;
  Cell_Element: IHTMLElement;
  Current_Vill: TVill;

  V_Name: string;
  V_NewDid: string;
  V_Coord: string;
  Tmp_String: string;
  t1, t2: integer;
begin
  // Это список поселений!!!!
  //  Наименование
  //  Координаты (x|y)
  //  NewDid   -- Собственно из-за которого мы сюда и забрались!

  if not Assigned(Table_IHTML) then
    exit;

  // Первая строка нам не нужна!!!
  for irow := 1 to Table_IHTML.rows.length - 1 do
  begin // Строки таблицы
    Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
    //  Первая колонка нас не интересует!!!
    for icol := 1 to Row_IHTML.cells.length - 1 do
    begin
      Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
      Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
      case icol of
        1:
          begin
            V_Name := Cell_Element.innerText;
            Tmp_String := Cell_Element.innerHTML;
            t1 := pos('newdid=', Tmp_String);
            t2 := pos('&', Tmp_String);
            if (t1 > 0) and (t2 > t1 + 7) then
              V_NewDid := copy(Tmp_String, t1 + 7, t2 - (t1 + 7));
          end;
        2: V_Coord := Cell_Element.innerText;
      end;
    end; // for icol
    Current_Vill := AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
    Current_Vill.Name := V_Name;
    Current_Vill.NewDID := V_NewDid;
    Current_Vill.set_coord(V_Coord);
  end; // for irow
end;
}

end.

