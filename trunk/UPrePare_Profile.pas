unit UPrePare_Profile;
//��������� �������

interface
Uses
  MSHTML,
  PerlRegEx,
  Trava_Class,
  Classes,
  SysUtils,
  U_Utilites,
  Dialogs;

// ��������� �������
procedure prepare_profileT36(document: IHTMLDocument2; AMyAccount: TAccount; FLog: TStringList);
procedure prepare_VlistT36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);
//�4.0
procedure prepare_profileT4(document: IHTMLDocument2; DocumentHTML: IHTMLDocument2;
                            AMyAccount: TAccount; FLog: TStringList);  // ��������� �������

implementation

procedure prepare_profileT36(document: IHTMLDocument2; AMyAccount: TAccount; FLog: TStringList);
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  All_Tables: IHTMLElementCollection;
  irow,icol:integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML:IHTMLTableCell;
  Cell_Element: IHTMLElement;
  DIV_List: IHTMLElementCollection;
  UL_List: IHTMLElementCollection;
  LI_List:IHTMLElementCollection;
  List_IHTML: IHTMLListElement;
  sw: Boolean;
//  Prifile_Line: string;
  V_Name: string;
  V_Nas: string;
  V_Coord: string;
  Current_Vill:TVill;
  Is_Capital:Boolean;
  Tmp_String: String;
  Tmp_ClassName:String;
  Tmp_Element: IHTMLElement;
  url:string;
begin
  if not Assigned(document) then
    exit;
  FLog.Add('��������� �������');
  Is_Capital:=False;
  sw:=false;

  if AMyAccount.UID = '' then  // ���� ����������� �� UID ������� �� URL
    AMyAccount.UID:=copy(document.url,length(AMyAccount.Connection_String+'/spieler.php?uid=')+1);
  FLog.Add('UID ������ -' + AMyAccount.UID);
  if AMyAccount.Race = 0 then
  begin // ���� ������������ ���������� � ����������
      //  ������� ���� �� ������ ID �������� (id="qgei") -
      //       class="q_l1" - �������
      //       class="q_l2" - ��������
      //       class="q_l3" - �����

    field_Element:=(document as IHTMLDocument3).getElementById('qgei');
    if Assigned(field_Element) then
    begin
      Tmp_ClassName:=field_Element.className;
      if pos('l1',Tmp_ClassName) > 0 then AMyAccount.Race:=1//�������
      else if pos('l2',Tmp_ClassName) > 0 then AMyAccount.Race:=2//��������
      else if pos('l3',Tmp_ClassName) > 0 then AMyAccount.Race:=3;//�����
    end;
  end;  // MyAccount.Race = 0

  All_Tables:=document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber,'') as IHTMLElement;
    if field_Element.id = 'profile' then sw:=true;
    if sw and (field_Element.id = '') then
    begin  // ��� ������������ �������
           //  ����
           //  �����
           //  ������
           //  ���������
           //  �������
      sw:=false;
      Table_IHTML:=field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
          // ��� ���������� ������ 5 ����� �������
        if irow >= 5 then break;
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
        end;
      end;
    end;  // ��� ������������ �������

    if field_Element.id = 'villages' then
    begin  // ��� ������ ���������!!!!
           //  ������������ (������� �������)
           //  ���������
           //  ���������� (x|y)
      Table_IHTML:=field_Element as IHTMLTable;
          // ������ ��� ������ ��� �� �����!!!
      for irow := 2 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;

          case icol of
            0: begin
                 V_Name:=Cell_Element.innerText;
                 Tmp_String:=Cell_Element.innerHTML;
                 Is_Capital:=(pos('SPAN',Tmp_String) > 1);
                 url:='';
                 if (cell_element.children as IHTMLElementCollection).length > 0 then
                 begin  // ������ �� �����
                   Tmp_Element:=(cell_element.children as IHTMLElementCollection).Item(0,'') as IHTMLElement;
                   if Tmp_Element.tagName='A' then
                     url:=Tmp_Element.toString;
                 end;

               end;
            1: V_Nas:=Cell_Element.innerText;
            2: V_Coord:=Cell_Element.innerText;
          end;
        end;
        Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        Current_Vill.Name:=V_Name;
        Current_Vill.Nas:=StrToInt(V_Nas);
        Current_Vill.Is_Capital:=Is_Capital;
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
      end;  // for irow
    end;   // if field_Element.id = 'villages' ��� ������ ���������!!!!

    if field_Element.id = 'vlist' then  //  ��� ������ ��������� � ������ ����� ��������
      prepare_VlistT36(field_Element as IHTMLTable, AMyAccount);
  end;  // for ItemNumber ....
end;

procedure prepare_VlistT36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);
//  ��������� ������ ��������� � ������ ����� ��������
var
  irow: integer;
  icol: integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML:IHTMLTableCell;
  Cell_Element: IHTMLElement;
  Current_Vill:TVill;

  V_Name: string;
  V_NewDid: string;
  V_Coord: string;
  Tmp_String:string;
  t1,t2:integer;
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
    Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
    //  ������ ������� ��� �� ����������!!!
    for icol := 1 to Row_IHTML.cells.length - 1 do
    begin
      Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
      Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
      case icol of
        1: begin
             V_Name:=Cell_Element.innerText;
             Tmp_String:=Cell_Element.innerHTML;
             t1:=pos('newdid=',Tmp_String);
             t2:=pos('&',Tmp_String);
             if (t1 > 0) and (t2 > t1+7) then
               V_NewDid:=copy(Tmp_String,t1+7,t2-(t1+7));
           end;
        2: V_Coord:=Cell_Element.innerText;
      end;
    end;  // for icol
    Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
    Current_Vill.Name:=V_Name;
    Current_Vill.NewDID:=V_NewDid;
    Current_Vill.set_coord(V_Coord);
  end;  // for irow
end;


procedure prepare_profileT4(document: IHTMLDocument2; DocumentHTML: IHTMLDocument2;
                                          AMyAccount: TAccount; FLog: TStringList);
//   ��������� �������
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  All_Tables: IHTMLElementCollection;
  irow,icol:integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML:IHTMLTableCell;
  Cell_Element: IHTMLElement;
  DIV_List: IHTMLElementCollection;
  UL_List: IHTMLElementCollection;
  LI_List:IHTMLElementCollection;
  List_IHTML: IHTMLListElement;
  sw: Boolean;
//  Prifile_Line: string;
  V_Name: string;
  V_Nas: string;
  V_Coord: string;
  Current_Vill:TVill;
  Is_Capital:Boolean;
  Tmp_String: String;
  Tmp_ClassName:String;
  Tmp_Element: IHTMLElement;
  url:string;
  Regex : TPerlRegEx;
  Newdid_Current_Vill: TVill; //������� ������� � ������� ��������� NewDid
  V_NewDid: String; //������ NewDid �������  �������������� ������� ���� �
begin
  if not Assigned(document) then
    exit;
  FLog.Add('��������� �������');
  Is_Capital:=False;
  sw:=false;

  if AMyAccount.UID = '' then  // ���� ����������� �� UID ������� �� URL
    AMyAccount.UID:=copy(document.url,length(AMyAccount.Connection_String+'/spieler.php?uid=')+1);
  FLog.Add('UID ������ -' + AMyAccount.UID);
  FLog.Add('���������� ���� ...');
  if AMyAccount.Race = 0 then
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
          1: begin AMyAccount.Race := 1; FLog.Add('���� ���'); end;
          2: begin AMyAccount.Race := 2; FLog.Add('���� ������ :)'); end;
          3: begin AMyAccount.Race := 3; FLog.Add('���� ���������� :)'); end;
        end
      else
        begin
          FLog.Add('����� ���� �� ���������� !');
          showmessage('Rase Dont ��� , ������ �� ����� ... �������');
        end;
    finally
      Regex.Free;
    end;
  end;  // MyAccount.Race = 0
  FLog.Add('��������� �������� ��� TABLE �� �������� ������� ');
  All_Tables:=document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber,'') as IHTMLElement;
    FLog.Add('������� ��������� ' + field_Element.id);
    if field_Element.id = 'details' then sw:=true;
    if sw and (field_Element.id = '') then
    begin  // ��� ������������ �������
           //  ����
           //  �����
           //  ������
           //  ���������
           //  �������
      sw:=false;
      FLog.Add('����������� �� ������� ������� "����, �����, ������..."');
      Table_IHTML:=field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
          // ��� ���������� ������ 5 ����� �������
        if irow >= 5 then break;
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
        end;
      end;
      FLog.Add('� Row_IHTML ������� ������ , � Cell_IHTML ������ �������');
      FLog.Add('� Cell_Element ������� ���� ����� "IHTMLElement"');
    end;  // ��� ������������ �������
    FLog.Add('����� ������� "villages"');
    if field_Element.id = 'villages' then
    begin  // ��� ������ ���������!!!!
           //  ������������ (������� �������)
           //  ���������
           //  ���������� (x|y)
      Table_IHTML:=field_Element as IHTMLTable;
          // ������ ��� ������ ��� �� �����!!!
          // �� �� ���� ������ ������ �� �����
      FLog.Add('���������� �� ������� �������....');
      for irow := 1 to Table_IHTML.rows.length - 1 do
      begin // ������ �������
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
          FLog.Add('���� ������� ������ � ��������');
          case icol of
            0: begin
                 V_Name:=Cell_Element.innerText;
                 Tmp_String:=Cell_Element.innerHTML;
                 Is_Capital:=(pos('SPAN',Tmp_String) > 1);
                 url:='';
                 if (cell_element.children as IHTMLElementCollection).length > 0 then
                 begin  // ������ �� �����
                   Tmp_Element:=(cell_element.children as IHTMLElementCollection).Item(0,'') as IHTMLElement;
                   if Tmp_Element.tagName='A' then
                     url:=Tmp_Element.toString;
                 end;

               end;
            //1: ��� ���� !!!
            2: V_Nas:=Cell_Element.innerText;
            3: V_Coord:= Copy(Cell_Element.innerText, 0, Pos(')', Cell_Element.innerText));
          end;
        end;
        Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        FLog.Add('������������� ������� �������� � ������������ =' + V_Coord);
        Current_Vill.Name:=V_Name;
        FLog.Add('��� = ' + V_Name);
        Trim(V_Nas);
        Current_Vill.Nas:=bild_lvl(V_Nas);
        FLog.Add('��������� = ' + V_Nas);
        Current_Vill.Is_Capital:=Is_Capital;
        if Is_Capital then
          FLog.Add('��� �������')
        else
          FLog.Add('�� �������');
        Trim(V_Coord);
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
        FLog.Add('���� �� ������� ' + copy(url,pos('?',url)+1));
      end;  // for irow
    end;   // if field_Element.id = 'villages' ��� ������ ���������!!!!
  end;  // for ItemNumber ....
  FLog.Add('������������ newdid �� ������ ������.');
  FLog.Add('��� ��� ������ �������� LI class=entry � ��� �� � ��� �����');
  //����� � ����� ���� �������� DocumentHTML � �������� �����
  DIV_List := DocumentHTML.all.tags('DIV') as IHTMLElementCollection;
  FLog.Add('����� ��� LI �����');
  for ItemNumber := 0 to DIV_List.Length - 1 do
  begin
    field_Element := DIV_List.item(ItemNumber,'') as IHTMLElement;
    FLog.Add('������� ��������� ' + field_Element.className);
    if field_Element.className = 'list' then
    begin
      FLog.Add('����� ������ div ���� = ' + field_Element.className);
      UL_List := field_Element.children as IHTMLElementCollection;
      break;
    end;
  end;
  FLog.Add('������������� ��� ' + IntToStr(UL_List.Length) + ' ����� ');
  for ItemNumber := 0 to UL_List.Length - 1  do
  begin
    //������� � field_Element ���� ��� <a  ..../a> �������
    field_Element := UL_List.item(ItemNumber,'') as IHTMLElement;
    LI_List := field_Element.children as IHTMLElementCollection;
    Break;
  end;
  for ItemNumber := 0 to LI_List.Length - 1  do
  begin
    //�������� <a ...���� � newdid ������ �������
    field_Element := LI_List.item(ItemNumber,'') as IHTMLElement;
    Flog.Add('����� ���� ��� ���� � (������ ����):');
    FLog.Add(field_Element.innerHTML);
    Regex := TPerlRegEx.Create(nil);
    try
      RegEx.RegEx := '<A.*coordinateX.*\((-*\d+).*coordinateY">(-*\d*)\).*href="\?newdid=(\d*).*';
      RegEx.Subject := field_Element.innerHTML;
      if Regex.Match then
        begin
          Flog.Add('����� �� ��������� ���� �� �������');
          Flog.Add('newdid=' + Regex.SubExpressions[3]);
          Flog.Add('���������� =' + V_Coord);
          V_NewDid := Regex.SubExpressions[3];
          V_Coord := '(' + Regex.SubExpressions[1] + '|' + Regex.SubExpressions[2] + ')';
          Newdid_Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
          Newdid_Current_Vill.NewDID:=V_NewDid;
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
  end;
end;


end.
