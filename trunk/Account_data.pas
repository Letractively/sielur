unit Account_data;

// Данные по аку
//   Все что может сделать бот на аке включено сюда
//   Начиная от входа в игру  и заканчивая выходом

interface
uses   Forms
      ,Controls
      ,Classes
      ,SHDocVw
      ,UContainer
      ,Trava_Class
      ,MSHTML
      ,SysUtils
      ,ComCtrls
      ,RzTreeVw
      ,x_bot_utl
      ,U_Utilites
      ,PerlRegEx
      ,ActiveX
      ,Dialogs
      ,Windows  ;

type TAccount_Data = class

    procedure WebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    fWBContainer: TWBContainer;
    fMyAccount: TAccount;
    fWebBrowser: TWebBrowser;
    fAccountNode: TTreeNode;
    fAccounts_TreeView: TRzTreeView;
    FLog: TStringList;
  public
    constructor Create(AOwner:TComponent);
    function is_login_page(document: IHTMLDocument2): IHTMLFormElement;   // Проверка страницы на страницу входа
    function Account_login(LoginForm: IHTMLFormElement): boolean;         //  Логие

    function Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode; ALog: TStringList): boolean;  // Запуск бота для работі с аком
    procedure prepare_profile(document: IHTMLDocument2);                  // Обработка профиля
    procedure prepare_Vlist(Table_IHTML: IHTMLTable);                     // Обработка профиля - Список деревень
    function get_race_from_Karte(document: IHTMLDocument2): integer;      // Получение расы по карте

    function FindAndClickHref(document: IHTMLDocument2; SubHref:string;TypeSubHref:integer): IHTMLDocument2;   // Эмуляция работы пользователя - Найти ссылку и кликнуть по нец

    procedure set_AccountNode_StateIndex;
    property Log: TStringList read FLog write FLog;
    property WebBrowser: TWebBrowser read fWebBrowser write fWebBrowser;
    property WBContainer: TWBContainer read fWBContainer write fWBContainer;
    property MyAccount: TAccount read fMyAccount write fMyAccount;
    property AccountNode:TTreeNode read fAccountNode write fAccountNode;
    property Accounts_TreeView:TRzTreeView read fAccounts_TreeView write fAccounts_TreeView;
end;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    NodeType: integer;  // -1  - сервер
                        // -2  - Account
                        // -3  - Village
    Status: Boolean;    // только для Account
                        //  True  - Login
                        //  False - Logout
    ID:    string;      // UID - для Account
                        // ID - для Village
    Account_Data:TAccount_Data;
    FData: string;      // - Сервер  (NodeType=-1)
                        // - Пароль  (NodeType=-2)
  end;

function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: String;NodeType: integer): TTreeNode; // Поиск узла

implementation

function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: String; NodeType: integer): TTreeNode;
  // Поиск узла
  //    Если узел не найден то возвращается  nil
  //    иначе найденный узел
  //  Tree       -   Дерево  сервера-акки-деревни
  //  Node       -   Узел (ветка) в котором надо найти требуемы "под-узел" если он не указан то поиск идет начиная с корня дерева
  //  NodeName   -   Имя узла который надо найти
  //  NodeType   -   Тип узла который надо найти
  //
var
  t: integer;
begin
  Result:=nil;

  IF not Assigned(Node) then
  Begin  // Поиск идёт в корне
    Node:=Tree.Items.GetFirstNode;
    While Assigned(Node) Do
    Begin
      IF (Node.Text = NodeName) and (PNodeData(Node.Data)^.NodeType = NodeType) then
      Begin
        Result:=Node;
        Break;
      End;
      Node:=Node.GetNextSibling;
    End;
  End  // Поиск идёт в корне
  Else begin  // Поиск идёт в ветке
    For t:=0 to Node.Count - 1 Do
    Begin
      IF (Node[t].Text = NodeName) and (PNodeData(Node[t].Data)^.NodeType = NodeType) then
       Begin
         Result:=Node[t];
         Break;
       End;
     End; // Поиск в ветке
  end;
end;



{ TAccount_Data }

function TAccount_Data.Account_login(LoginForm: IHTMLFormElement): boolean;
//  Логин
//     Возвращает  TRUE  -  при успешном логине
//                 FALSE -  при неудачном
// LoginForm   -  Страница логина
//
var
  ItemNumber: integer;
  field: IHTMLElement;
  input_field: IHTMLInputElement;
  Count_input_field: integer;
begin
// Логика работы
//  Пробежаться по всем полям формы
//  найти нужные нам поля ('name' и 'password')
//   заполнить их и нажать на кнопочку Вход
  FLog.Add('Логинимся ...');
  Result:=false;
  Count_input_field:=0;
  if Assigned(LoginForm) then
  begin
    for ItemNumber := 0 to LoginForm.Length - 1 do
    begin  //  бежим по всем элементам формы
      field := LoginForm.Item(ItemNumber,'') as IHTMLElement;
      if Assigned(field) then
      begin
        if field.tagName = 'INPUT' then
        begin  //  поле ввода
          input_field:=field as IHTMLInputElement;
          if input_field.Name = 'name' then
          begin
            input_field.Value := MyAccount.Login;    // Внесем сюда имя
            Count_input_field:=Count_input_field+1;
          end; //  'name'
          if input_field.Name = 'password' then
          begin
            input_field.Value := MyAccount.Password; // Внесем сюда пароль
            Count_input_field:=Count_input_field+1;
          end;  // 'password'
        end;
      end; //  поле ввода
    end;   //  бежим по всем элементам формы

    if Count_input_field <> 2 then
      begin
        FLog.Add('Нашли больше 2 полей ввода , дето накасячили');
        exit;  //  Если в форме не ДВА поля ввода  то мы где-то что-то прогавили
      end;
    FLog.Add('Нажали на кнопку ...');
    fWBContainer.MyFormSubmit(LoginForm); //   Нажали на кнопочку

    //  Проверим залогинились или нет
    //     собственно проверка тупая
    //  если на полученной страницы нет формы логина то всё в порядке
    Result:=(is_login_page(fWBContainer.HostedBrowser.Document as IHTMLDocument2) = nil);
    if Result then
      FLog.Add('Залогинились!')
    else
      FLog.Add('Логин не удался КОСЯК!!!');
  end;

end;

function TAccount_Data.Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode; ALog: TStringList): boolean;
//      Запуск работы бота с заданным аком
//  aAccounts_TreeView   - Дерево сервера-аки-деревни
//  aAccountNode         - Узел ака в дереве
//
//  Собственно говоря логин и парсинг текущего состояния ака
//
var
  Server_Name  : string;
  User_Name    : string;
  Password_Name: string;

  ServerNode: TTreeNode;
  VillNode: TTreeNode;

  SndForm: IHTMLFormElement;
  Document: IHTMLDocument2;
  Tmp_VillName:String;
  NodeDataPtr: PNodeData;
  t: integer;
  url: string;
  i: integer;
  next_dorf: string;
  THTML: String;
begin
  //  Проверять не будем ибо все-же надо перед вызовом процедуры проверить
  //  1. Assigned(aAccounts_TreeView)
  //        т.е. существует дерево аков
  //  2. (PNodeData(aAccountNode.Data)^.NodeType = -2) and (not PNodeData(aAccountNode.Data)^.Status)
  //        т.е. Это Account и он не залогинен
  //  -----------------------------------------------
  //THTML := TStrings.Create;
  FLog := ALog;
  Result:=False;

  Server_Name:='';
  User_Name:='';
  Password_Name:='';

  fAccounts_TreeView:=aAccounts_TreeView;
  fAccountNode:=aAccountNode;
  User_Name:=AccountNode.Text;
  Password_Name:=PNodeData(AccountNode.Data)^.FData;
      // И теперь сервер
  ServerNode:=AccountNode.Parent;   // Узел сервера
      // Проверим все-же!!!
  if (PNodeData(ServerNode.Data)^.NodeType = -1) then
  begin
    Server_Name:=ServerNode.Text;
  end;

  if (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '') then
  begin
    MyAccount.Connection_String:='http://'+Server_Name;
    MyAccount.Login:=User_Name;
    MyAccount.Password:=Password_Name;
    FLog.Add('Пользователь - ' + User_Name);
    FLog.Add('Переход по ссылке' + MyAccount.Connection_String);
    WBContainer.MyNavigate(MyAccount.Connection_String);   //   Получение страницы логины
    //когда получили страницу логина можно определить версию игры
    if WB_GetHTMLCode(WBContainer, THTML) then
       if AnsiPos('Travian.Game.version = ''4.0''',THTML) <> 0 then
         begin
           MyAccount.IsT4Version := True;
           FLog.Add('Версия игры Т4.0')
         end
       else
         begin
           MyAccount.IsT4Version := False; //или не Т4 или дето накасячил
           FLog.Add('Версия игры НЕ Т4.0');
         end;
    SndForm:=is_login_page(WBContainer.HostedBrowser.Document as IHTMLDocument2);  //  вытащим из неё форму логина
    if Assigned(SndForm) then
    begin  //  форма логина существует
      Result:=Account_login(SndForm);   //  Попытка логина
      if Result then
      begin  // Логин нормальный!
        // Перейдем на страницу профиля!
        FLog.Add('Переходим на страницу профиля');
        Document:=FindAndClickHref(WBContainer.HostedBrowser.Document as IHTMLDocument2,MyAccount.Connection_String+'/spieler.php?',2);
        if Document <> nil then
        begin //  Успешный переход на страницу профиля
          FLog.Add('Успешный переход на страницу профиля.');
          prepare_profile(Document);  // обработка профиля
          if MyAccount.Race = 0 then  MyAccount.Race:=get_race_from_Karte(Document);  // Расу в профиле определить не смогли! Будем её определять как-то иначе!
        end;
      end;  // Логин нормальный!
    end;   // Assigned(SndForm)

    PNodeData(AccountNode.Data)^.Status:=Result;
    if Result then
    begin  // Логин нормальный!
      set_AccountNode_StateIndex;  //  установит индекс картинки для ака будем рисовать в дереве
      PNodeData(AccountNode.Data)^.ID:=MyAccount.UID;
      PNodeData(AccountNode.Data)^.Account_Data:=self;   // !!!!! Внесем себя !!!!!

      // Добавим  в дерево список деревень
      for t := 0 to MyAccount.Derevni_Count-1 do
      begin  //   Пробежимся по всем деревням
        //  Вообщето может быть не самая удачная идея использовать в качестве идентификатора
        //  наименование деревни ибо после переименования ейной возможны проблемы
        //  однако на этапе логина всё нормально ибо тут переименованием и не пахнет
        Tmp_VillName:=MyAccount.Derevni.Items[t].Name+' '+MyAccount.Derevni.Items[t].coord;
        VillNode:=find_node(Accounts_TreeView,AccountNode,Tmp_VillName,-3);
        if not Assigned(VillNode) then
        begin // Деревню не нашли --> добавим её
              // добавляем дочерний по отношению к AccountNode узел,
              // в качестве текста исп. Tmp_VillName
          New(NodeDataPtr);
          NodeDataPtr^.NodeType:=-3;
          NodeDataPtr^.Status:=False;
          NodeDataPtr^.ID:=IntToStr(MyAccount.Derevni.Items[t].ID);
          NodeDataPtr^.FData:=MyAccount.Derevni.Items[t].Name;
          NodeDataPtr^.Account_Data:=self;   // !!!!! Внесем себя !!!!!
          VillNode:=Accounts_TreeView.Items.AddChildObject(AccountNode, Tmp_VillName, NodeDataPtr);
        end;
      end;  // for t := 0 to MyAccount.Derevni_Count-1

      // Все с визуализацией временно покончили
      // Теперь надо пройтись по всем деревням и зачитать их данные
      // И будем это делать в отдельном цикле, хотя могли бы и в предыдущем
      // однако негоже смешивать две разные вещи!!!!
      for t := 0 to MyAccount.Derevni_Count-1 do
      begin // цикл по деревням
        // Переключимся на нужную деревню
        // Ну а если деревушка одна то то мы всё равно стоим на ней!!!
        if MyAccount.Derevni_Count > 1 then
          document:=FindAndClickHref(document,'?newdid='+MyAccount.Derevni.Items[t].NewDID,4);
        if Assigned(document) then
        begin  // Успешное переключение!
           MyAccount.IdCurrentVill:=MyAccount.Derevni.Items[t].ID;
          // Посмотрим где мы стоим
          // Если не на dorf1 или 2 то переключаемся на dorf1
          url:=document.url;
          if (copy(url,length(url)-4) <> 'dorf1') and (copy(url,length(url)-4) <> 'dorf2') then // Переключимся на dorf1
            document:=FindAndClickHref(document,MyAccount.Connection_String+'/dorf1.php',1);

          for I := 1 to 2 do
          begin
            url:=document.url;
            if (copy(url,length(url)-8) = 'dorf1.php') then
            begin
              MyAccount.Derevni.Items[t].prepare_dorf1(document);  // Обработка  dorf1
              next_dorf:='dorf2.php'
            end
            else begin
              if (copy(url,length(url)-8) = 'dorf2.php') then
              begin
                MyAccount.Derevni.Items[t].prepare_dorf2(document);  // Обработка  dorf2
                MyAccount.Derevni.Items[t].SetGidForId40(30+MyAccount.race);  // Это ограда!!!!
                next_dorf:='dorf1.php'
              end
              else begin
                // логическая ошибка
              end;
            end;
            document:=FindAndClickHref(document,MyAccount.Connection_String+'/'+next_dorf,1);
          end; // for I
        end;  // if Assigned(document)
      end;   // цикл по деревням
    end;    // if Result then  Логин нормальный!

  end;  // (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '')
end;

constructor TAccount_Data.Create(AOwner:TComponent);
begin
//  inherited Create(AOwner) ;



  fMyAccount:=TAccount.Create;

  fWebBrowser:=TWebBrowser.Create(AOwner);
  TWinControl(fWebBrowser).Parent:=(AOwner as TWinControl);
  fWebBrowser.Align:=alClient;
  fWebBrowser.OnDocumentComplete:=WebBrowserDocumentComplete;

  // Создание контейнера
  fWBContainer := TWBContainer.Create(fWebBrowser);
//  fWBContainer.OptionKeyPath:= 'Software\X-bot\Explorer';  // Настройки хранятся в HKEY_CURRENT_USER
//  fWBContainer.UseCustomCtxMenu := True;    // use our popup menu
//  fWBContainer.Show3DBorder := False;       // no border
//  fWBContainer.ShowScrollBars := False;     // no scroll bars
//  fWBContainer.AllowTextSelection := False; // no text selection (**)

end;

function TAccount_Data.FindAndClickHref(document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;
//   Найти ссилку и кликнуть по ней

// TypeSubHref   - Модификатор поиска
//     1 - найти полное равенство ссылки с SubHref
//     2 - ссылка должна начинаться с SubHref
//     3 - ссылка должна содержать SubHref
//     4 - ссылка должна заканчиваться SubHref
var
  ItemNumber: integer;
  href_field: IHTMLElement;
  All_Links: IHTMLElementCollection;
  url:string;
  Is_Find: boolean;
begin
  Result:=nil;
  if Assigned(document) then
  begin
    All_Links:=document.links;
    for ItemNumber := 0 to All_Links.Length - 1 do
    begin  // цикл по всем ссылкам документа
      href_field := All_Links.item(ItemNumber,'') as IHTMLElement;
      url:=href_field.toString;
      Is_Find:=(TypeSubHref = 1) and (url = SubHref);
      if not Is_Find then
        Is_Find:=(TypeSubHref = 2) and (pos(SubHref,url) = 1);
      if not Is_Find then
        Is_Find:=(TypeSubHref = 3) and (pos(SubHref,url) > 0);
      if not Is_Find then
        Is_Find:=(TypeSubHref = 4) and (pos(SubHref,url) = length(url)-length(SubHref)+1);

      if Is_Find then
      begin // Отлично нашли требуемую ссылку
        WBContainer.MyElementClick(href_field);
        Result:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
        exit;
      end;
    end;  // цикл по всем ссылкам документа
  end;
end;

function TAccount_Data.get_race_from_Karte(document: IHTMLDocument2): integer;
// Определение расы по карте

var
  ItemNumber: integer;
  href_field: IHTMLElement;
  All_Links: IHTMLElementCollection;
  url:string;
  Karte_document: IHTMLDocument2;
  field_Element: IHTMLElement;

  Tmp_Collection:IHTMLElementCollection;
  Script_Number: integer;
  tmp_txt: string;
  Race_String: string;
  iii: integer;
begin
  Result:=0;
  // Сначала найдем ссылку на карту и кликнем по ней
  // дабы перейти на страницу карты
  if Assigned(document) then
  begin
{   У нас же есть соответствующая функция и значит надо использовать её
    просто закоментарил ибо не проверял, после проверки надо удалить
    закоментаренній код
    All_Links:=document.links;
    for ItemNumber := 0 to All_Links.Length - 1 do
    begin
      href_field := All_Links.item(ItemNumber,'') as IHTMLElement;
      url:=href_field.toString;
      if url = (MyAccount.Connection_String+'/karte.php') then
      begin // Отлично нашли ссылку на карту
        WBContainer.MyElementClick(href_field);
        Karte_document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
        break;
      end;
    end;
}
    Karte_document:=FindAndClickHref(document,MyAccount.Connection_String+'/karte.php', 1);
  end;

  if Assigned(Karte_document) then
  begin  // Итак карту мы получили, теперь попробуем с ней разобраться
    field_Element:=(document as IHTMLDocument3).getElementById('a_3_3');  // Центр карты
    url:=field_Element.toString;   // ссылка на деревушку
    url:=copy(url,pos('?',url)+1);     // нужный нам кусочек

    field_Element:=(document as IHTMLDocument3).getElementById('map');  // Отсюда нам нужен второй скрипт
    Script_Number:=0;
    Tmp_Collection:=(field_Element.children as ihtmlelementcollection);
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element:=Tmp_Collection.item(ItemNumber,'')  as IHTMLElement;
      if field_Element.tagName = 'SCRIPT' then
      begin
        Script_Number:=Script_Number+1;
        if Script_Number >= 2 then break;
      end;
    end;
    if Script_Number = 2 then
    begin  // Нужный нам скрипт Из него вытащим расу
           // По простому по рабочекрестьянски
           // Нам нужен центр карты и мы его получим!
      tmp_txt:=field_Element.innerHTML;
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // Выбросили первую строку карты
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // Выбросили вторую строку карты
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // Выбросили третюю строку карты
      tmp_txt:=copy(tmp_txt,1,pos(']]',tmp_txt)+1);   // Взяли 4-ю строку
           // Работаем с 4-й строкой
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // Выбросили первую колонку карты
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // Выбросили вторую колонку карты
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // Выбросили третюю колонку карты
      tmp_txt:=copy(tmp_txt,1,pos(']',tmp_txt));   // Взяли 4-ю колонку
           // И теперь имеем то что нам нужно
           // [X,Y,?,?,"URL","?","Наименование_Деревни","Игрок","Население","?",Раса]
           //  Раса = 1 - рим  2 - тевтон   3 - галл
      Race_String:=copy(tmp_txt,length(tmp_txt)-1,1);
      Result:=StrToInt(Race_String);
    end;
  end;  // if Assigned(Karte_document)
end;

function TAccount_Data.is_login_page(document: IHTMLDocument2): IHTMLFormElement;
//  Если на входе страница логина, то вытаскиваем из неё форму и возвращаем
//   иначе NIL
var
  allForms: IHTMLElementCollection;
begin
  //  Страница логина?????
  Result:=nil;
  if  Assigned(document) then
  begin
    allForms:=document.forms;
    if Assigned(allForms) then
      Result:=allForms.Item('snd','') as IHTMLFormElement;
      if Assigned(Result) then
        if Result.action <> 'dorf1.php' then Result:=nil;
  end;
end;

procedure TAccount_Data.prepare_profile(document: IHTMLDocument2);

  function GetHTMLCode(Adocument: IHTMLDocument2): String;
   var
     ps: IPersistStreamInit;
     ss: TStringStream;
     sa: IStream;
     s: string;
   begin
     ps := Adocument as IPersistStreamInit;
     s := '';
     ss := TStringStream.Create(s);
     try
       sa := TStreamAdapter.Create(ss, soReference) as IStream;
       Succeeded(ps.Save(sa, True));
       Result := ss.Datastring;
     finally
       ss.Free;
     end;
   end;

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
  All_List: IHTMLElementCollection;
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
begin
  if not Assigned(document) then
    exit;
  FLog.Add('Обработка профиля');
  Is_Capital:=False;
  sw:=false;

  if MyAccount.UID = '' then  // Если неопределен то UID вытащим из URL
    MyAccount.UID:=copy(document.url,length(MyAccount.Connection_String+'/spieler.php?uid=')+1);
  FLog.Add('UID игрока -' + MyAccount.UID);
  //Дальше для Т4 отдельно все обрабатываем
  if MyAccount.IsT4Version then
  begin
    FLog.Add('Определяем расу ...');
    if MyAccount.Race = 0 then
    begin // Раса неопределена попытаемся её определить
      //  Вытащим расу по классу <img class="nationBig nationBig2"
      //       nationBig1" - римляне
      //       nationBig2" - тевтонцы
      //       cnationBig3" - галлы
      Regex := TPerlRegEx.Create(nil);
      try
        RegEx.RegEx := '<img\sclass="nationBig\snationBig(\d)"';
        RegEx.Subject := GetHTMLCode(document);
        if Regex.Match then
          case StrToInt(Regex.SubExpressions[1]) of
            1: begin MyAccount.Race := 1; FLog.Add('Раса РИМ'); end;
            2: begin MyAccount.Race := 2; FLog.Add('Раса Фашист :)'); end;
            3: begin MyAccount.Race := 3; FLog.Add('Раса Лягушатник :)'); end;
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
              3: V_Coord:=Cell_Element.innerText;
            end;
          end;
          Current_Vill:=MyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
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
          //FLog.Add('');
          Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
          FLog.Add('Линк на деревню ' + copy(url,pos('?',url)+1));
        end;  // for irow
      end;   // if field_Element.id = 'villages' Это список поселений!!!!
      FLog.Add('Поределяем newdid по сылкам справа.');
      if field_Element.id = 'vilagelist' then  //  Это список поселений в правой части страницы
        prepare_Vlist(field_Element as IHTMLTable);
    end;  // for ItemNumber ....
    FLog.Add('Поопределяем newdid по сылкам справа.');
    FLog.Add('Для это найдем елеменит LI class=entry и все че в нем лежит');
    All_List := document.all.tags('LI') as IHTMLElementCollection;
    FLog.Add('Обход все LI - ов');
    for ItemNumber := 0 to All_List.Length - 1 do
    begin
      field_Element := All_List.item(ItemNumber,'') as IHTMLElement;
      FLog.Add('Текущая структура ' + field_Element.className);
      if field_Element.className = 'entry' then
      begin
        List_IHTML:= field_Element as IHTMLListElement;
        FLog.Add('нашли нужный Li клас = ' + field_Element.id);
        //List_IHTML.
        //field_Element.
      end;
    end;
  end
  else //Для не Т4 версии
    begin
      if MyAccount.Race = 0 then
      begin // Раса неопределена попытаемся её определить
          //  Вытащим расу по классу ID элемента (id="qgei") -
          //       class="q_l1" - римляне
          //       class="q_l2" - тевтонцы
          //       class="q_l3" - галлы

        field_Element:=(document as IHTMLDocument3).getElementById('qgei');
        if Assigned(field_Element) then
        begin
          Tmp_ClassName:=field_Element.className;
          if pos('l1',Tmp_ClassName) > 0 then MyAccount.Race:=1//римляне
          else if pos('l2',Tmp_ClassName) > 0 then MyAccount.Race:=2//тевтонцы
          else if pos('l3',Tmp_ClassName) > 0 then MyAccount.Race:=3;//галлы
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
            Current_Vill:=MyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
            Current_Vill.Name:=V_Name;
            Current_Vill.Nas:=StrToInt(V_Nas);
            Current_Vill.Is_Capital:=Is_Capital;
            Current_Vill.set_coord(V_Coord);
            Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
          end;  // for irow
        end;   // if field_Element.id = 'villages' Это список поселений!!!!

        if field_Element.id = 'vlist' then  //  Это список поселений в правой части страницы
          prepare_Vlist(field_Element as IHTMLTable);
      end;  // for ItemNumber ....
    end;
end;

procedure TAccount_Data.prepare_Vlist(Table_IHTML: IHTMLTable);
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
    Current_Vill:=MyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
    Current_Vill.Name:=V_Name;
    Current_Vill.NewDID:=V_NewDid;
    Current_Vill.set_coord(V_Coord);
  end;  // for irow
end;

procedure TAccount_Data.set_AccountNode_StateIndex;
begin
  AccountNode.StateIndex:=MyAccount.Race;
end;




procedure TAccount_Data.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  fWBContainer.DocLoaded := true;
end;

end.
