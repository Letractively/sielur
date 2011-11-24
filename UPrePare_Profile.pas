unit UPrePare_Profile;
//Обработка профиля

interface
Uses
  MSHTML,
  PerlRegEx,
  Trava_Class,
  Classes,
  SysUtils,
  U_Utilites,
  Dialogs;

// Обработка профиля
procedure prepare_profileT36(document: IHTMLDocument2; AMyAccount: TAccount; FLog: TStringList);
procedure prepare_VlistT36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);
//Т4.0
procedure prepare_profileT4(document: IHTMLDocument2; DocumentHTML: IHTMLDocument2;
                            AMyAccount: TAccount; FLog: TStringList);  // Обработка профиля

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
  FLog.Add('Обработка профиля');
  Is_Capital:=False;
  sw:=false;

  if AMyAccount.UID = '' then  // Если неопределен то UID вытащим из URL
    AMyAccount.UID:=copy(document.url,length(AMyAccount.Connection_String+'/spieler.php?uid=')+1);
  FLog.Add('UID игрока -' + AMyAccount.UID);
  if AMyAccount.Race = 0 then
  begin // Раса неопределена попытаемся её определить
      //  Вытащим расу по классу ID элемента (id="qgei") -
      //       class="q_l1" - римляне
      //       class="q_l2" - тевтонцы
      //       class="q_l3" - галлы

    field_Element:=(document as IHTMLDocument3).getElementById('qgei');
    if Assigned(field_Element) then
    begin
      Tmp_ClassName:=field_Element.className;
      if pos('l1',Tmp_ClassName) > 0 then AMyAccount.Race:=1//римляне
      else if pos('l2',Tmp_ClassName) > 0 then AMyAccount.Race:=2//тевтонцы
      else if pos('l3',Tmp_ClassName) > 0 then AMyAccount.Race:=3;//галлы
    end;
  end;  // MyAccount.Race = 0

  All_Tables:=document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber,'') as IHTMLElement;
    if field_Element.id = 'profile' then sw:=true;
    if sw and (field_Element.id = '') then
    begin  // Это внутренность профиля
           //  Ранг
           //  Нация
           //  Альянс
           //  Поселений
           //  Человек
      sw:=false;
      Table_IHTML:=field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
          // Нас интересуют первые 5 строк таблицы
        if irow >= 5 then break;
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
        end;
      end;
    end;  // Это внутренность профиля

    if field_Element.id = 'villages' then
    begin  // Это список поселений!!!!
           //  Наименование (включая Столица)
           //  Население
           //  Координаты (x|y)
      Table_IHTML:=field_Element as IHTMLTable;
          // Первые две строки нам не нужны!!!
      for irow := 2 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
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
                 begin  // ссылка на карту
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
    end;   // if field_Element.id = 'villages' Это список поселений!!!!

    if field_Element.id = 'vlist' then  //  Это список поселений в правой части страницы
      prepare_VlistT36(field_Element as IHTMLTable, AMyAccount);
  end;  // for ItemNumber ....
end;

procedure prepare_VlistT36(Table_IHTML: IHTMLTable; AMyAccount: TAccount);
//  Обработка списка поселений в правой части страницы
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
  // Это список поселений!!!!
  //  Наименование
  //  Координаты (x|y)
  //  NewDid   -- Собственно из-за которого мы сюда и забрались!

  if not Assigned(Table_IHTML) then
    exit;

  // Первая строка нам не нужна!!!
  for irow := 1 to Table_IHTML.rows.length - 1 do
  begin // Строки таблицы
    Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
    //  Первая колонка нас не интересует!!!
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
//   Обработка профиля
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
  Newdid_Current_Vill: TVill; //текущая деревня в которую впихиваем NewDid
  V_NewDid: String; //храним NewDid текущей  расматриваемой строчки тега А
begin
  if not Assigned(document) then
    exit;
  FLog.Add('Обработка профиля');
  Is_Capital:=False;
  sw:=false;

  if AMyAccount.UID = '' then  // Если неопределен то UID вытащим из URL
    AMyAccount.UID:=copy(document.url,length(AMyAccount.Connection_String+'/spieler.php?uid=')+1);
  FLog.Add('UID игрока -' + AMyAccount.UID);
  FLog.Add('Определяем расу ...');
  if AMyAccount.Race = 0 then
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
          1: begin AMyAccount.Race := 1; FLog.Add('Раса РИМ'); end;
          2: begin AMyAccount.Race := 2; FLog.Add('Раса Фашист :)'); end;
          3: begin AMyAccount.Race := 3; FLog.Add('Раса Лягушатник :)'); end;
        end
      else
        begin
          FLog.Add('Касяк расу не определили !');
          showmessage('Rase Dont бля , короче не пашит ... выходим');
        end;
    finally
      Regex.Free;
    end;
  end;  // MyAccount.Race = 0
  FLog.Add('Готовимся обходить все TABLE на странице профиля ');
  All_Tables:=document.all.tags('TABLE') as IHTMLElementCollection;
  for ItemNumber := 0 to All_Tables.Length - 1 do
  begin
    field_Element := All_Tables.item(ItemNumber,'') as IHTMLElement;
    FLog.Add('Текущая структура ' + field_Element.id);
    if field_Element.id = 'details' then sw:=true;
    if sw and (field_Element.id = '') then
    begin  // Это внутренность профиля
           //  Ранг
           //  Нация
           //  Альянс
           //  Поселений
           //  Человек
      sw:=false;
      FLog.Add('Пробегаемся по строкам профиля "Ранг, Нация, Альянс..."');
      Table_IHTML:=field_Element as IHTMLTable;
      for irow := 0 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
          // Нас интересуют первые 5 строк таблицы
        if irow >= 5 then break;
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
        end;
      end;
      FLog.Add('В Row_IHTML занесли строки , в Cell_IHTML ячейки таблицы');
      FLog.Add('в Cell_Element заносим чето такое "IHTMLElement"');
    end;  // Это внутренность профиля
    FLog.Add('Берем таблицу "villages"');
    if field_Element.id = 'villages' then
    begin  // Это список поселений!!!!
           //  Наименование (включая Столица)
           //  Население
           //  Координаты (x|y)
      Table_IHTML:=field_Element as IHTMLTable;
          // Первые две строки нам не нужны!!!
          // Не не токо первая строка не нужна
      FLog.Add('проходимся по строкам таблицы....');
      for irow := 1 to Table_IHTML.rows.length - 1 do
      begin // Строки таблицы
        Row_IHTML:=Table_IHTML.rows.item(irow,'') as IHTMLTableRow;
        for icol := 0 to Row_IHTML.cells.length - 1 do
        begin
          Cell_IHTML:=Row_IHTML.cells.item(icol,'') as IHTMLTableCell;
          Cell_Element:=Row_IHTML.cells.item(icol,'') as IHTMLElement;
          FLog.Add('Терь заносим данные о деревнях');
          case icol of
            0: begin
                 V_Name:=Cell_Element.innerText;
                 Tmp_String:=Cell_Element.innerHTML;
                 Is_Capital:=(pos('SPAN',Tmp_String) > 1);
                 url:='';
                 if (cell_element.children as IHTMLElementCollection).length > 0 then
                 begin  // ссылка на карту
                   Tmp_Element:=(cell_element.children as IHTMLElementCollection).Item(0,'') as IHTMLElement;
                   if Tmp_Element.tagName='A' then
                     url:=Tmp_Element.toString;
                 end;

               end;
            //1: ЭТО ОАЗЫ !!!
            2: V_Nas:=Cell_Element.innerText;
            3: V_Coord:= Copy(Cell_Element.innerText, 0, Pos(')', Cell_Element.innerText));
          end;
        end;
        Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        FLog.Add('Устанавливеем текущую деревнюю с координатами =' + V_Coord);
        Current_Vill.Name:=V_Name;
        FLog.Add('Имя = ' + V_Name);
        Trim(V_Nas);
        Current_Vill.Nas:=bild_lvl(V_Nas);
        FLog.Add('Население = ' + V_Nas);
        Current_Vill.Is_Capital:=Is_Capital;
        if Is_Capital then
          FLog.Add('Это столица')
        else
          FLog.Add('Не столица');
        Trim(V_Coord);
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
        FLog.Add('Линк на деревню ' + copy(url,pos('?',url)+1));
      end;  // for irow
    end;   // if field_Element.id = 'villages' Это список поселений!!!!
  end;  // for ItemNumber ....
  FLog.Add('Поопределяем newdid по сылкам справа.');
  FLog.Add('Для это найдем елеменит LI class=entry и все че в нем лежит');
  //здесь и берем нами созданый DocumentHTML с исходным кодом
  DIV_List := DocumentHTML.all.tags('DIV') as IHTMLElementCollection;
  FLog.Add('Обход все LI тегов');
  for ItemNumber := 0 to DIV_List.Length - 1 do
  begin
    field_Element := DIV_List.item(ItemNumber,'') as IHTMLElement;
    FLog.Add('Текущая структура ' + field_Element.className);
    if field_Element.className = 'list' then
    begin
      FLog.Add('нашли нужный div клас = ' + field_Element.className);
      UL_List := field_Element.children as IHTMLElementCollection;
      break;
    end;
  end;
  FLog.Add('просматриваем все ' + IntToStr(UL_List.Length) + ' сылок ');
  for ItemNumber := 0 to UL_List.Length - 1  do
  begin
    //заносим в field_Element весь тег <a  ..../a> целиком
    field_Element := UL_List.item(ItemNumber,'') as IHTMLElement;
    LI_List := field_Element.children as IHTMLElementCollection;
    Break;
  end;
  for ItemNumber := 0 to LI_List.Length - 1  do
  begin
    //получили <a ...хреф с newdid каждой деревни
    field_Element := LI_List.item(ItemNumber,'') as IHTMLElement;
    Flog.Add('Берем хтмл код тега А (смотри ниже):');
    FLog.Add(field_Element.innerHTML);
    Regex := TPerlRegEx.Create(nil);
    try
      RegEx.RegEx := '<A.*coordinateX.*\((-*\d+).*coordinateY">(-*\d*)\).*href="\?newdid=(\d*).*';
      RegEx.Subject := field_Element.innerHTML;
      if Regex.Match then
        begin
          Flog.Add('Нашли по регулярки инфу по деревне');
          Flog.Add('newdid=' + Regex.SubExpressions[3]);
          Flog.Add('Координаты =' + V_Coord);
          V_NewDid := Regex.SubExpressions[3];
          V_Coord := '(' + Regex.SubExpressions[1] + '|' + Regex.SubExpressions[2] + ')';
          Newdid_Current_Vill:=AMyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
          Newdid_Current_Vill.NewDID:=V_NewDid;
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
  end;
end;


end.
