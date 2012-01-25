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
    id: integer; // ����� ����
    name: string; // ������������ ��������
    //    res_req: array[0..3] of integer;
    //    res_need: array[0..3] of integer;
    //    res_time: TDatetime;
    lvl: integer;
    gid: integer; //��� ��������,�� build.php?gid=�����
    // (��� ���� ID=1..18 ����� ����� ����� �������
    //  1 - ������
    //  2 - �����
    //  3 - ������
    //  4 - �����
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
  // ��������� �������

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
    FFarmLists: TFarmList; //���� � ������� ������ � ����� ...�� ��� ���.
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
    fRace: integer; // 1 - ���  2 - ������   3 - ����
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
    // ��������� �������

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
    (4, 4, 1, 4, 4, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f1 9-��   [3,3,3,9]
    (3, 4, 1, 3, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f2        [3,4,5,6]
    (1, 4, 1, 3, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f3        [4,4,4,6]
    (1, 4, 1, 2, 2, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f4        [4,5,3,6]
    (1, 4, 1, 3, 1, 2, 3, 4, 4, 3, 3, 4, 4, 1, 4, 2, 1, 2), //f5        [5,3,4,6]
    (4, 4, 1, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4), //f6 15-��  [1,1,1,15]
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
  rsVillBadId = SCriticalError + '�������� ID ���������.';
  rsVillBadNewDId = SCriticalError + '�������� NewDID ���������.';

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
  //�������� ������
  Result.Return_Code := 0;
  Result.TargetNameVil := '';
  Result.TargetNamePlayer := '';
  Result.TargetNameAli := '';
  Result.TravelTime := 0;
  Build_Element := nil;
  FLog.Add('����� �������� ������ �� ����������� :(' + IntToStr(AFarmItem.FCoords.X) +
    '|' + IntToStr(AFarmItem.Coords.Y) + ')');
  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;
  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // �������� ����� �� �� �� DORF2 ????  � ���� ��� �� �������� �� ��
  if (copy(url, length(url) - 8) <> 'dorf2.php') then
  begin
    Flog.Add('��� �� �����, ����� �� �� ����������');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf2.php', 1);
  end;
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf2.php') then
  begin
    Flog.Add('���-�� �� ��; �� DORF2 ��� � �� �������');
    Result.Return_Code:=-1;  // showmessage('���-�� �� ��');
    exit;
  end;
  //������ ����� ���� ������� ����� ����� �����  � ��� ���=39
  Flog.Add('���� �� ����� �����');
  document := FindAndClickHref(WBContainer, document,
            Account.Connection_String + '/' + 'build.php?id=39', 1);
  Flog.Add('������ ��. ���� �����������, ���� ������� ����� ����� ��� ��� ���');
  //���������� ���� ���� <div id="build" class="gid16"> � ��������� �������� , ������ ������� ����� �����
  //����������� ����� ����� ������� ����� ������� ��� ���� � ����� �����, ��������
  //� ������� ����� � ���� ����������� + ����� ����� � ������ ������ ����� ������.
  Build_Element := (Document as IHTMLDocument3).getElementById('build');
  if Assigned(Build_Element) then
  begin     //����� ����� ����� � ����� ��� �������� �� ��������
    Flog.Add('����� ������ ������ �����, ���� ������ �������� ������.');
    Tmp_Collection := Build_Element.children as IHTMLElementCollection;
    TabShit_Element := nil;
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
      if Uppercase(field_Element.className) = 'CONTENTNAVI TABNAVI' then
      begin
        //����� �������� � �������� �� �� , ������ ������ 2 ������(��������) � ������ �� ���
        Container_Collection := field_Element.children as IHTMLElementCollection;
        for TabshitNumber := 0 to Container_Collection.length - 1 do //�� ���� 4 ��������
        // 2 ������� �������� �����
        begin
          if TabshitNumber = 1 then
          begin
            field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
            //������ ��� ���� ��� �������� ... ����� ��� ��� ��� ����� ����� ���� �� ������� � �� �������� :)
            Flog.Add('������ �����;  ��������� ������');
            Flog.Add('� ������  �������� �� ��');
            //����� ����� ������ ����� ��� ��� ���� ���� 100 % ������� �� ������ , ����� ������ ��� ��� ������
            WBContainer.MyElementClick(field_Element);
            document := WBContainer.HostedBrowser.Document as IHTMLDocument2;
          end
        end;
      end;
    end;
  end;
  //��� �� �� ���� ������ ������ �� ,,,/a2b.php ///
end;


function TVill.build_center(WBContainer: TWBContainer; const FId, GId: string;
  FLog: TStringList): TBuildReturn_Code;
//  ��������� ������
//   FId  - Id  ���� �� ������� ���� �������
//   GId  - GId ������
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
  Flog.Add('����� �������  FId='+FID+' ('+GetBuilding(StrToInt(FID)).name+')');

  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;

  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // �������� ����� �� �� �� DORF2 ????  � ���� ��� �� �������� �� ��
  Flog.Add('�������� ����� �� �� �� DORF2 ????');
  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('��� �� �����, ����� �� �� ����������');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf2.php', 1);
  end;

  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('���-�� �� ��; �� DORF2 ��� � �� �������');
    Result.Return_Code:=-1;  // showmessage('���-�� �� ��');
    exit;
  end;

  // ���� ����� �� ����2  ������������� �
  (Account.Account_data as TAccount_Data).Clone_Document(DocumentHTML);
  prepare_dorf2(document,DocumentHTML,Flog);

  // �������� GID  (���, �� ������)

  if (Item_Building[StrToInt(FId)].gid <> 0) and (Item_Building[StrToInt(FId)].gid <> StrToInt(GId)) then
  begin
    Flog.Add('������������ GID ');
    Result.Return_Code:=-1;  // showmessage('���-�� �� ��');
    exit;
  end;

  // ������ �� ������
  Flog.Add('������ �� ������'+'build.php?id='+FId);
  document := FindAndClickHref(WBContainer, document,'build.php?id='+FId, 4);

  Contract_Element:=nil;
  if Item_Building[StrToInt(FId)].gid <> 0 then
  begin  // ������������ ������
    Flog.Add('������ <div id="contract"');   //<div id="contract" class="contractWrapper"><span class="none">�������� ������������� ����</span></div>

    Contract_Element := (Document as IHTMLDocument3).getElementById('contract');
  end
  else
  begin  // �����������!!!!
    //  ���� ������ ������
    Flog.Add('������ <div id="build"');   //<div id="build"

    build_Element := (Document as IHTMLDocument3).getElementById('build');
    Tmp_Collection := build_Element.children as IHTMLElementCollection;
    // ������ ��� ������������������
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
            begin   // ��� �� ��� ��� ���� ��������!!!
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
  begin  // ����� Contract
    Tmp_Collection := Contract_Element.children as IHTMLElementCollection;

    Result:=Prepare_Contract(Tmp_Collection,FLog);
    if Result.Return_Code = 0 then
    begin
      Flog.Add('���� ������');
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
      begin  //  ������ ����  ������ �� ��
        Flog.Add('������ �����;  ������');
        Flog.Add('� ������  �������� �� ��');
        WBContainer.MyElementClick(field_Element);
      end
      else begin
        Flog.Add('������ ���; ������ � ������� � ����� ������');
        Result.Return_Code:=-1;
      end;
    end;
  end;


  // �������� ����� �� �� �� DORF2 ????  � ���� ��� �� �������� �� ��
  Flog.Add('�������� ����� �� �� �� DORF2 ????');
  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('��� �� �����, ����� �� �� ����������');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if pos('dorf2.php',url) <= 0 then
  begin
    Flog.Add('���-�� �� ��; �� DORF1 ��� � �� �������');
    Result.Return_Code:=-3;  // showmessage('���-�� �� ��');
    exit;
  end;

end;

function TVill.build_field(WBContainer: TWBContainer; const FId, GId: string; FLog: TStringList):TBuildReturn_Code;
//  ��������� ����
//   FId  - Id  ���� �� ������� ���� �������
//   GId  - �� ������������ (������� ��� ������������� ���������� � �������� � �����)
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
  Flog.Add('����� �������  FId='+FID+' ('+GetBuilding(StrToInt(FID)).name+')');

  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;

  document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
  // �������� ����� �� �� �� DORF1 ????  � ���� ��� �� �������� �� ��
  Flog.Add('�������� ����� �� �� �� DORF1 ????');
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('��� �� �����, ����� �� �� ����������');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('���-�� �� ��; �� DORF1 ��� � �� �������');
    Result.Return_Code:=-1;  // showmessage('���-�� �� ��');
    exit;
  end;

  // ���� ����� �� ����1  ������������� �
  (Account.Account_data as TAccount_Data).Clone_Document(DocumentHTML);
  prepare_dorf1(document,DocumentHTML,Flog);

  // ������ �� ������
  Flog.Add('������ �� ������'+'build.php?id='+FId);
  document := FindAndClickHref(WBContainer, document,'build.php?id='+FId, 4);


  Flog.Add('������ <div id="contract"');   //<div id="contract" class="contractWrapper"><span class="none">�������� ������������� ����</span></div>

  Contract_Element := (Document as IHTMLDocument3).getElementById('contract');
  Tmp_Collection := Contract_Element.children as IHTMLElementCollection;

  Result:=Prepare_Contract(Tmp_Collection,FLog);
  if Result.Return_Code = 0 then
  begin
    Flog.Add('���� ������');
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
    begin  //  ������ ����  ������ �� ��
      Flog.Add('������ �����;  ������');
      Flog.Add('� ������  �������� �� ��');
      WBContainer.MyElementClick(field_Element);
    end
    else begin
      Flog.Add('������ ���; ������ � ������� � ����� ������');
      Result.Return_Code:=-1;
    end;
  end;


  // �������� ����� �� �� �� DORF1 ????  � ���� ��� �� �������� �� ��
  Flog.Add('�������� ����� �� �� �� DORF1 ????');
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('��� �� �����, ����� �� �� ����������');
    document := FindAndClickHref(WBContainer, document,
              Account.Connection_String + '/' + 'dorf1.php', 1);
  end;

  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    Flog.Add('���-�� �� ��; �� DORF1 ��� � �� �������');
    Result.Return_Code:=-3;  // showmessage('���-�� �� ��');
    exit;
  end;

end;

constructor TVill.Create(Collection: TCollection);
begin
  inherited;
  //������� ������ ���� ����
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
  // ������ ������� �� id="village_map"
  //   (<div id="village_map" class="f7">)
  //  ��� ����� ������ ��� �� ��� ������
  field_Element := (document as IHTMLDocument3).getElementById('village_map');
  TypeField := StrToInt(copy(field_Element.className, 2));
  // gid �����
  for ItemBuild := 1 to 18 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := Res_for_fields[TypeField, ItemBuild];
  end;

  // �� � ������ ��������� �� ����������� field_Element
  // � ������� ���������� � �����
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.Length - 2 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    Attr_Collection := (field_Element as IHTMLDOMNode).attributes as
      IHTMLAttributeCollection;
    TmpStringBuild := field_Element.className;
    // �� ��� ���-�� ��� ����� "reslevel rf1 level10"
    TmpStringBuild := copy(TmpStringBuild, 12); // ������� "reslevel rf"
    // ������ �� ������� ��� ����� ����  � ����� lelel - ��� ������� ���������
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
  FLog.Add('������ Dorf1);');

  //  ��� ��� � ����� ���������� ���� � ������ !
  //  <map name="rx" id="rx">
  //  <area href="build.php?id=1" coords="190,88,28" shape="circle" alt="��������� ������� 10">
  //  ��� ������ ��� �� ��������� ������������ �... ��� ������ ������� ��� � ��������
  //  ��� ����� ������ ��� �� ��� ������

  field_Element := (document as IHTMLDocument3).getElementById('village_map');
  TypeField := StrToInt(copy(field_Element.className, 2));

  // gid �����
  for ItemBuild := 1 to 18 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := Res_for_fields[TypeField, ItemBuild];
  end;

  // �� � ������ ��������� �� ����������� field_Element
  // � ������� ���������� � �����
  field_Element := (DocumentHTML as IHTMLDocument3).getElementById('rx');
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);

  for ItemNumber := 0 to Tmp_Collection.Length - 2 do
  begin
    Area_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLAreaElement;
    TmpStringBuild := Area_Element.alt;
    // ����� ���� ��� ������ "������ �������� г���� 0"
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
  // ������� gid ����� � ������
  for ItemBuild := 19 to 40 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := 0;
    Building[ItemBuild].lvl := 0;
  end;

  //
  // ������ ������� �� id="village_map"
  field_Element := (document as IHTMLDocument3).getElementById('village_map');

  // �� � ������ ��������� �� ����������� field_Element
  // � ������� ���������� � �����
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to 19 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    Attr_Collection := (field_Element as IHTMLDOMNode).attributes as
      IHTMLAttributeCollection;
    TmpStringBuild := field_Element.className;
    // �� ��� ���-�� ��� ����� "building d1 iso" ��� "building d7 g10" �� ��� ��� ����������� "building d7 g10b"
    TmpStringBuild := copy(TmpStringBuild, 11); // ������� "building d"
    if copy(TmpStringBuild, length(TmpStringBuild), 1) = 'b' then
      // ����� ���� �������?????
      TmpStringBuild := copy(TmpStringBuild, 1, length(TmpStringBuild) - 1);

    // ������ �� ������� ��� ����� ����  � ����� -gid ��� iso
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

  // ������ ���������� � �������� �����
  // ������ ������� �� id="levels"
  // � ������� ���������� � �������
  field_Element := (document as IHTMLDocument3).getElementById('levels');
  Tmp_Collection := (field_Element.children as ihtmlelementcollection);
  for ItemNumber := 0 to Tmp_Collection.length - 1 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    TmpStringBuild := field_Element.className;
    // �� ��� ���-�� ��� ����� "d7" ��� "l40"
    ItemBuild := StrToInt(copy(TmpStringBuild, 2));
    if copy(TmpStringBuild, 1, 1) = 'd' then
      ItemBuild := ItemBuild + 18;
    Building[ItemBuild].lvl := StrToInt(field_Element.innerText);
  end;

  // � ������ ���������� � ������� ����� � �������
  Building[39].gid := 16;
  //  Building[40].gid:=30+race;  ������� � ����� ���� ������ �����������

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
  // ������� gid ����� � ������
  for ItemBuild := 19 to 40 do
  begin
    Building[ItemBuild].id := ItemBuild;
    Building[ItemBuild].gid := 0;
    Building[ItemBuild].lvl := 0;
  end;

  //

  // ������ ������� �� id="clickareas"
  field_Element := (DocumentHTML as IHTMLDocument3).getElementById('clickareas');

  // �� � ������ ��������� �� ����������� field_Element
  // � ������� ���������� � �����
  //��������  �� ���� <area alt="�������� ������ ������� 9" shape �� <map name="clickareas" id="clickareas">
  //���������� ���� � ��� ��������� (���� ��� ����� �� �������� ������� ��������)
  //����� �������� �� ���� <img style="left:81px; top:57px; z-index:19" src="img/x.gif" class="building g28" alt="�������� ������ ������� 9">
  //� ���������� ���� ��������� , ������ ������� ���� � ����� , �� ��� �������� ����� ���������� �������� ��������.
  //P.S. ���� ����� ����� ��������� ���� �� ����� ����� id=39, ��� ��������� � �� ����� ���� ��� ������ , � �� � ��������
  //id=40 , ��� ���������� ���.
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
      // ������ �������� ������� ����� ��� ����������� ���
  end;

  //�������� ��� ������������ ���
  //��� ��������� ����� ���� ���� ������ 21 ��� ,22 -� ��� ������
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
          if copy(Building[curentIDBuild].name,1,4) = 'wall' then   // �� ��� � ��� ������ ������� ��� ������ � ������� ���� ���
          begin
            TmpStringBuild:=Uppercase(Copy(field_Element.className,LastDelimiter(' ', field_Element.className) + 1));  // 'ISO' ��� 'Gxx' ��� xx - ���
            Building[curentIDBuild].gid := StrToInt(Copy(TmpStringBuild,2,2));
            Building[curentIDBuild].lvl := StrToInt(copy(Building[curentIDBuild].name,LastDelimiter(' ', Building[curentIDBuild].name) + 1));
            break;
          end;
        end
        else begin
          TmpStringBuild:=Uppercase(Copy(field_Element.className,LastDelimiter(' ', field_Element.className) + 1));  // 'ISO' ��� 'Gxx' ��� xx - ���
          if TmpStringBuild <> 'ISO' then
          begin // ����� ��� ���-�� ���������
            Building[curentIDBuild].gid := StrToInt(Copy(TmpStringBuild,2));
            // ���� ��� ������ ���� � ������� ���������
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
//  ��������� ������ ��������� � ������ ����� ��������
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

  // ��� ������ ���������!!!!
  //  ������������
  //  ���������� (x|y)
  //  NewDid   -- ���������� ��-�� �������� �� ���� � ���������!

  if not Assigned(Table_IHTML) then
    exit;

  // ������ ������ ��� �� �����!!!
  for irow := 1 to Table_IHTML.rows.length - 1 do
  begin // ������ �������
    Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
    //  ������ ������� ��� �� ����������!!!
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
  Newdid_Current_Vill: TVill; //������� ������� � ������� ��������� NewDid
  V_NewDid: string; //������ NewDid �������  �������������� ������� ���� �
begin
  FLog.Add('������������ newdid �� ������ ������.');
  FLog.Add('��� ��� ������ �������� LI class=entry � ��� �� � ��� �����');
  //����� � ����� ���� �������� DocumentHTML � �������� �����
  DIV_List := DocumentHTML.all.tags('DIV') as IHTMLElementCollection;
  FLog.Add('����� ��� LI �����');

  for ItemNumber := 0 to DIV_List.Length - 1 do
  begin
    field_Element := DIV_List.item(ItemNumber, '') as IHTMLElement;
    FLog.Add('������� ��������� ' + field_Element.className);
    if field_Element.className = 'list' then
    begin
      FLog.Add('����� ������ div ���� = ' + field_Element.className);
      UL_List := field_Element.children as IHTMLElementCollection;
      break;
    end;
  end;

  if Assigned(UL_List) then
  begin
    FLog.Add('������������� ��� ' + IntToStr(UL_List.Length) + ' ����� ');
    for ItemNumber := 0 to UL_List.Length - 1 do
    begin
      //������� � field_Element ���� ��� <a  ..../a> �������
      field_Element := UL_List.item(ItemNumber, '') as IHTMLElement;
      LI_List := field_Element.children as IHTMLElementCollection;
      Break;
    end;

    if Assigned(LI_List) then
    begin
      for ItemNumber := 0 to LI_List.Length - 1 do
      begin    // �������� ����� ������
        //�������� <a ...���� � newdid ������ �������
        field_Element := LI_List.item(ItemNumber, '') as IHTMLElement;
        Flog.Add('����� ���� ��� ���� � (������ ����):');
        FLog.Add(field_Element.innerHTML);
        Regex := TPerlRegEx.Create(nil);
        try
          RegEx.RegEx :=
            '<A.*coordinateX.*\((-*\d+).*coordinateY">(-*\d*)\).*href="\?newdid=(\d*).*';
          RegEx.Subject := field_Element.innerHTML;
          if Regex.Match then
          begin
            Flog.Add('����� �� ��������� ���� �� �������');
            Flog.Add('newdid=' + Regex.SubExpressions[3]);
            Flog.Add('���������� =' + V_Coord);
            V_NewDid := Regex.SubExpressions[3];
            V_Coord := '(' + Regex.SubExpressions[1] + '|' + Regex.SubExpressions[2]
              + ')';
            Newdid_Current_Vill := Account.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
            Newdid_Current_Vill.NewDID := V_NewDid;
            Newdid_Current_Vill.set_coord(V_Coord);
          end
          else
          begin
            FLog.Add('����� !');
            showmessage('Rase Dont ��� , ������ �� ����� ... �������');
          end;
        finally
          Regex.Free;
        end;
      end;  // �������� ����� ������
    end; // if Assigned(LI_List)
  end;  // if Assigned(UL_List)

end;


procedure TVill.SetGidForId40(AValue: integer);
begin
  Building[40].gid := AValue;
end;

function TVill.set_coord(const coord: string): Boolean;
// coord - (X|Y)
//  True  - �� ������
//  False - ������� ������ ������� ������
var
  tmp_string: string;
  i: integer;
begin
  //  �������� ������ � ��������� ������, ��� ������ ���� ������
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
  FLog.Add('��������� �������');
  Is_Capital := False;
  sw := false;
  Current_Vill:=nil;

  if UID = '' then // ���� ����������� �� UID ������� �� URL
    UID := copy(document.url, length(Connection_String + '/spieler.php?uid=') +
      1);
  FLog.Add('UID ������ -' + UID);
  if Race = 0 then
  begin // ���� ������������ ���������� � ����������
    //  ������� ���� �� ������ ID �������� (id="qgei") -
    //       class="q_l1" - �������
    //       class="q_l2" - ��������
    //       class="q_l3" - �����

    field_Element := (document as IHTMLDocument3).getElementById('qgei');
    if Assigned(field_Element) then
    begin
      Tmp_ClassName := field_Element.className;
      if pos('l1', Tmp_ClassName) > 0 then
        Race := 1 //�������
      else if pos('l2', Tmp_ClassName) > 0 then
        Race := 2 //��������
      else if pos('l3', Tmp_ClassName) > 0 then
        Race := 3; //�����
    end;
  end; // MyAccount.Race = 0

  All_Tables := document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber, '') as IHTMLElement;
    if field_Element.id = 'profile' then
      sw := true;
    if sw and (field_Element.id = '') then
    begin // ��� ������������ �������
      //  ����
      //  �����
      //  ������
      //  ���������
      //  �������
      sw := false;
      Table_IHTML := field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
        // ��� ���������� ������ 5 ����� �������
        if irow >= 5 then
          break;
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
        end;
      end;
    end; // ��� ������������ �������

    if field_Element.id = 'villages' then
    begin // ��� ������ ���������!!!!
      //  ������������ (������� �������)
      //  ���������
      //  ���������� (x|y)
      Table_IHTML := field_Element as IHTMLTable;
      // ������ ��� ������ ��� �� �����!!!
      for irow := 2 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
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
                begin // ������ �� �����
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
    end; // if field_Element.id = 'villages' ��� ������ ���������!!!!

//    if field_Element.id = 'vlist' then
//      //  ��� ������ ��������� � ������ ����� ��������
//      prepare_Vlist36(field_Element as IHTMLTable, self);
  end; // for ItemNumber ....


  if Assigned(Current_Vill) then
    Current_Vill.prepare_Vlist_T36(document, DocumentHTML, FLog)

end;

procedure TAccount.prepare_profileT40(WBContainer: TWBContainer; document,
  DocumentHTML: IHTMLDocument2; FLog: TStringList);
//   ��������� �������
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
  FLog.Add('��������� �������');
  Is_Capital := False;
  sw := false;
  Current_Vill:=nil;

  if UID = '' then // ���� ����������� �� UID ������� �� URL
    UID := copy(document.url, length(Connection_String + '/spieler.php?uid=') +
      1);
  FLog.Add('UID ������ -' + UID);
  FLog.Add('���������� ���� ...');
  if Race = 0 then
  begin // ���� ������������ ���������� � ����������
    //  ������� ���� �� ������ <img class="nationBig nationBig2"
    //       nationBig1" - �������
    //       nationBig2" - ��������
    //       cnationBig3" - �����
    Regex := TPerlRegEx.Create(nil);
    try
      RegEx.RegEx := '<img\sclass="nationBig\snationBig(\d)"';
      RegEx.Subject := Doc_GetHTMLCode(document);
      if Regex.Match then
        case StrToInt(Regex.SubExpressions[1]) of
          1:
            begin
              Race := 1;
              FLog.Add('���� ���');
            end;
          2:
            begin
              Race := 2;
              FLog.Add('���� ������ :)');
            end;
          3:
            begin
              Race := 3;
              FLog.Add('���� ���������� :)');
            end;
        end
      else
      begin
        FLog.Add('����� ���� �� ���������� !');
        showmessage('Rase Dont ��� , ������ �� ����� ... �������');
      end;
    finally
      Regex.Free;
    end;
  end; // MyAccount.Race = 0
  FLog.Add('��������� �������� ��� TABLE �� �������� ������� ');
  All_Tables := document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber, '') as IHTMLElement;
    FLog.Add('������� ��������� ' + field_Element.id);
    if field_Element.id = 'details' then
      sw := true;
    if sw and (field_Element.id = '') then
    begin // ��� ������������ �������
      //  ����
      //  �����
      //  ������
      //  ���������
      //  �������
      sw := false;
      FLog.Add('����������� �� ������� ������� "����, �����, ������..."');
      Table_IHTML := field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
        // ��� ���������� ������ 5 ����� �������
        if irow >= 5 then
          break;
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
        end;
      end;
      FLog.Add('� Row_IHTML ������� ������ , � Cell_IHTML ������ �������');
      FLog.Add('� Cell_Element ������� ���� ����� "IHTMLElement"');
    end; // ��� ������������ �������
    FLog.Add('����� ������� "villages"');
    if field_Element.id = 'villages' then
    begin // ��� ������ ���������!!!!
      //  ������������ (������� �������)
      //  ���������
      //  ���������� (x|y)
      Table_IHTML := field_Element as IHTMLTable;
      // ������ ��� ������ ��� �� �����!!!
      // �� �� ���� ������ ������ �� �����
      FLog.Add('���������� �� ������� �������....');
      for irow := 1 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
        Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML := Row_IHTML.cells.item(icol, '') as IHTMLTableCell;
          Cell_Element := Row_IHTML.cells.item(icol, '') as IHTMLElement;
          FLog.Add('���� ������� ������ � ��������');
          case icol of
            0:
              begin
                V_Name := Cell_Element.innerText;
                Tmp_String := Cell_Element.innerHTML;
                Is_Capital := (pos('SPAN', Tmp_String) > 1);
                url := '';
                if (cell_element.children as IHTMLElementCollection).length > 0
                  then
                begin // ������ �� �����
                  Tmp_Element := (cell_element.children as
                    IHTMLElementCollection).Item(0, '') as IHTMLElement;
                  if Tmp_Element.tagName = 'A' then
                    url := Tmp_Element.toString;
                end;

              end;
            //1: ��� ���� !!!
            2: V_Nas := Cell_Element.innerText;
            3: V_Coord := Copy(Cell_Element.innerText, 0, Pos(')',
                Cell_Element.innerText));
          end;
        end;
        Current_Vill := Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        FLog.Add('������������� ������� �������� � ������������ =' + V_Coord);
        Current_Vill.Name := V_Name;
        FLog.Add('��� = ' + V_Name);
        Trim(V_Nas);
        Current_Vill.Nas := bild_lvl(V_Nas);
        FLog.Add('��������� = ' + V_Nas);
        Current_Vill.Is_Capital := Is_Capital;
        if Is_Capital then
          FLog.Add('��� �������')
        else
          FLog.Add('�� �������');
        Trim(V_Coord);
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link := copy(url, pos('?', url) + 1);
        FLog.Add('���� �� ������� ' + copy(url, pos('?', url) + 1));
      end; // for irow
    end; // if field_Element.id = 'villages' ��� ������ ���������!!!!
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
//  ��������� ������ ��������� � ������ ����� ��������
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
  // ��� ������ ���������!!!!
  //  ������������
  //  ���������� (x|y)
  //  NewDid   -- ���������� ��-�� �������� �� ���� � ���������!

  if not Assigned(Table_IHTML) then
    exit;

  // ������ ������ ��� �� �����!!!
  for irow := 1 to Table_IHTML.rows.length - 1 do
  begin // ������ �������
    Row_IHTML := Table_IHTML.rows.item(irow, '') as IHTMLTableRow;
    //  ������ ������� ��� �� ����������!!!
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

