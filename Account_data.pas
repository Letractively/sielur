unit
  Account_data;

// Данные по аку
//   Все что может сделать бот на аке включено сюда
//   Начиная от входа в игру  и заканчивая выходом

interface
uses
  Forms
  , Controls
  , Classes
  , SHDocVw
  , UContainer
  , Trava_Class
  , MSHTML
  , SysUtils
  , ComCtrls
  , RzTreeVw
  , x_bot_utl
  , U_Utilites
  , PerlRegEx
  , ActiveX
  , Dialogs
  , Windows
  , Variants
  , TypInfo
  , urlmon
  , wininet
  , ExtCtrls
  , Trava_My_Const
  , Trava_Task
  , Trava_Task_Build
  , Trava_Task_Farm
  ;

type
  TAccount_Data = class
    procedure WebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    fWBContainer: TWBContainer;
    fMyAccount: TAccount;
    fWebBrowser: TWebBrowser;
    fAccountNode: TTreeNode;
    fAccounts_TreeView: TRzTreeView;
    FLog: TStringList;
    fTask_Work_Timer: TTimer;
    fTask_queue: TTask_queue;
    fSet_ACF_BuildList: TSet_ACF_BuildList;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;


    //Логин для Т4 и Т3.6 версии одинаков
    function is_login_page(document: IHTMLDocument2): IHTMLFormElement;
      // Проверка страницы на страницу входа
    function Account_login(LoginForm: IHTMLFormElement): boolean; //  Логие
    function Bot_Start_Work(aAccounts_TreeView: TRzTreeView; aAccountNode:
      TTreeNode; ALog: TStringList): boolean; // Запуск бота для работі с аком Т3,6
    procedure Clone_Document(DocumentHTML: IHTMLDocument2);

    // Обработка очереди задач по таймеру
    procedure Task_Work(Sender: TObject);

    // Постановка задачи стройки ферм и зданий в очередь задач
    //  Что фактически означает начать стройку
    procedure Start_construction;
    // Удаление  задачи стройки ферм и зданий из очередь задач
    procedure Stop_construction;
    //Постановка задачи фарма в очередь задач
    //Что фактически означает начать фарм и получит много много ресов и стать
    //большим и злым  :)
    procedure Start_farm;
    //пока не знаю как его останавливать буду .. вдруг там с пару тісяч целей ...
    procedure Stop_farm;

    procedure set_AccountNode_StateIndex;
    property Log: TStringList read FLog write FLog;
    property WebBrowser: TWebBrowser read fWebBrowser write fWebBrowser;
    property WBContainer: TWBContainer read fWBContainer write fWBContainer;
    property MyAccount: TAccount read fMyAccount write fMyAccount;
    property AccountNode: TTreeNode read fAccountNode write fAccountNode;
    property Accounts_TreeView: TRzTreeView read fAccounts_TreeView write
      fAccounts_TreeView;
    property Task_Work_Timer: TTimer read fTask_Work_Timer write fTask_Work_Timer;
    property Task_queue: TTask_queue read fTask_queue write fTask_queue;
    property Set_ACF_BuildList: TSet_ACF_BuildList read fSet_ACF_BuildList write fSet_ACF_BuildList;

  end;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    NodeType: integer; // -1  - сервер
    // -2  - Account
    // -3  - Village
    Status: Boolean; // только для Account
    //  True  - Login
    //  False - Logout
    ID: string; // UID - для Account
    // ID - для Village
    Account_Data: TAccount_Data;
    FData: string; // - Сервер  (NodeType=-1)
    // - Пароль  (NodeType=-2)
  end;

function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: string;
  NodeType: integer): TTreeNode; // Поиск узла

implementation

function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: string; NodeType: integer): TTreeNode;
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
  Result := nil;

  if not Assigned(Node) then
  begin // Поиск идёт в корне
    Node := Tree.Items.GetFirstNode;
    while Assigned(Node) do
    begin
      if (Node.Text = NodeName) and (PNodeData(Node.Data)^.NodeType = NodeType)
        then
      begin
        Result := Node;
        Break;
      end;
      Node := Node.GetNextSibling;
    end;
  end // Поиск идёт в корне
  else
  begin // Поиск идёт в ветке
    for t := 0 to Node.Count - 1 do
    begin
      if (Node[t].Text = NodeName) and (PNodeData(Node[t].Data)^.NodeType =
        NodeType) then
      begin
        Result := Node[t];
        Break;
      end;
    end; // Поиск в ветке
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
  Result := false;
  Count_input_field := 0;
  if Assigned(LoginForm) then
  begin
    for ItemNumber := 0 to LoginForm.Length - 1 do
    begin //  бежим по всем элементам формы
      field := LoginForm.Item(ItemNumber, '') as IHTMLElement;
      if Assigned(field) then
      begin
        if field.tagName = 'INPUT' then
        begin //  поле ввода
          input_field := field as IHTMLInputElement;
          if input_field.Name = 'name' then
          begin
            input_field.Value := MyAccount.Login; // Внесем сюда имя
            Count_input_field := Count_input_field + 1;
          end; //  'name'
          if input_field.Name = 'password' then
          begin
            input_field.Value := MyAccount.Password; // Внесем сюда пароль
            Count_input_field := Count_input_field + 1;
          end; // 'password'
        end;
      end; //  поле ввода
    end; //  бежим по всем элементам формы

    if Count_input_field <> 2 then
    begin
      FLog.Add('Нашли больше 2 полей ввода , дето накасячили');
      exit; //  Если в форме не ДВА поля ввода  то мы где-то что-то прогавили
    end;
    FLog.Add('Нажали на кнопку ...');
    fWBContainer.MyFormSubmit(LoginForm); //   Нажали на кнопочку

    //  Проверим залогинились или нет
    //     собственно проверка тупая
    //  если на полученной страницы нет формы логина то всё в порядке
    Result := (is_login_page(fWBContainer.HostedBrowser.Document as
      IHTMLDocument2) = nil);
    if Result then
      FLog.Add('Залогинились!')
    else
      FLog.Add('Логин не удался КОСЯК!!!');
  end;

end;

function TAccount_Data.Bot_Start_Work(aAccounts_TreeView: TRzTreeView;
  aAccountNode: TTreeNode; ALog: TStringList): boolean;
//      Запуск работы бота с заданным аком
//  aAccounts_TreeView   - Дерево сервера-аки-деревни
//  aAccountNode         - Узел ака в дереве
//
//  Собственно говоря логин и парсинг текущего состояния ака
//
var
  Server_Name: string;
  User_Name: string;
  Password_Name: string;
  ServerNode: TTreeNode;
  VillNode: TTreeNode;
  SndForm: IHTMLFormElement;
  Document: IHTMLDocument2;
  DocumentHTML: IHTMLDocument2; //нужно для норм отображения title (На Win XP)
  Tmp_VillName: string;
  NodeDataPtr: PNodeData;
  t: integer;
  url: string;
  i: integer;
  next_dorf: string;
  HTML: string; //сохраняем сюда исходный код страницы
begin
  //  Проверять не будем ибо все-же надо перед вызовом процедуры проверить
  //  1. Assigned(aAccounts_TreeView)
  //        т.е. существует дерево аков
  //  2. (PNodeData(aAccountNode.Data)^.NodeType = -2) and (not PNodeData(aAccountNode.Data)^.Status)
  //        т.е. Это Account и он не залогинен
  //  -----------------------------------------------
  //THTML := TStrings.Create;

  DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;
  ;

  FLog := ALog;
  Result := False;

  Server_Name := '';
  User_Name := '';
  Password_Name := '';

  fAccounts_TreeView := aAccounts_TreeView;
  fAccountNode := aAccountNode;
  User_Name := AccountNode.Text;
  Password_Name := PNodeData(AccountNode.Data)^.FData;
  // И теперь сервер
  ServerNode := AccountNode.Parent; // Узел сервера
  // Проверим все-же!!!
  if (PNodeData(ServerNode.Data)^.NodeType = -1) then
  begin
    Server_Name := ServerNode.Text;
  end;

  if (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '') then
  begin
    MyAccount.Connection_String := 'http://' + Server_Name;
    MyAccount.Login := User_Name;
    MyAccount.Password := Password_Name;
    FLog.Add('Пользователь - ' + User_Name);
    FLog.Add('Переход по ссылке' + MyAccount.Connection_String);
    WBContainer.MyNavigate(MyAccount.Connection_String);
      //   Получение страницы логины
    //когда получили страницу логина можно определить версию игры
    MyAccount.TravianVersion := tvNone;
    if WB_GetHTMLCode(WBContainer, HTML) then
    begin
      if AnsiPos('Travian.Game.version = ''4.0''', HTML) <> 0 then
        MyAccount.TravianVersion := tv40
      else if AnsiPos('class="v35', HTML) <> 0 then
        MyAccount.TravianVersion := tv36;
    end;
    FLog.Add('Версия игры ' + GetEnumName(TypeInfo(TTravianVersion),
      Ord(MyAccount.TravianVersion)));
    if MyAccount.TravianVersion = tvNone then
    begin
      FLog.Add('Это не трава, или данная версия игры не поддерживается');
      exit;
    end;

    SndForm := is_login_page(WBContainer.HostedBrowser.Document as
      IHTMLDocument2); //  вытащим из неё форму логина
    if Assigned(SndForm) then
    begin //  форма логина существует
      Result := Account_login(SndForm); //  Попытка логина
      if Result then
      begin // Логин нормальный!
        // Перейдем на страницу профиля!
        FLog.Add('Переходим на страницу профиля');
        Document := FindAndClickHref(WBContainer,
          WBContainer.HostedBrowser.Document as IHTMLDocument2,
          MyAccount.Connection_String + '/spieler.php?', 2);
        if Document <> nil then
        begin //  Успешный переход на страницу профиля
          FLog.Add('Успешный переход на страницу профиля.');
          //Данное извращение надо для получениу екземпляра IHTMLDocument2
          //потом в него пихаем исходный код страницы и при дальнейшей работе
          //у нас вполне нормально title получаеться
          //дополнительно создать екземпляр документа и тд ... выше описано
          Clone_Document(DocumentHTML);
          MyAccount.prepare_profile(WBContainer, Document, DocumentHTML, Flog);
            // обработка профиля

        end;
      end; // Логин нормальный!
    end; // Assigned(SndForm)

    PNodeData(AccountNode.Data)^.Status := Result;
    if Result then
    begin // Логин нормальный!
      set_AccountNode_StateIndex; //  установит индекс картинки для ака будем рисовать в дереве
      PNodeData(AccountNode.Data)^.ID := MyAccount.UID;
      PNodeData(AccountNode.Data)^.Account_Data := self;
        // !!!!! Внесем себя !!!!!

      // Добавим  в дерево список деревень
      for t := 0 to MyAccount.Derevni_Count - 1 do
      begin //   Пробежимся по всем деревням
        //  Вообщето может быть не самая удачная идея использовать в качестве идентификатора
        //  наименование деревни ибо после переименования ейной возможны проблемы
        //  однако на этапе логина всё нормально ибо тут переименованием и не пахнет
        Tmp_VillName := MyAccount.Derevni.Items[t].Name + ' ' +
          MyAccount.Derevni.Items[t].coord;
        VillNode := find_node(Accounts_TreeView, AccountNode, Tmp_VillName, -3);
        if not Assigned(VillNode) then
        begin // Деревню не нашли --> добавим её
          // добавляем дочерний по отношению к AccountNode узел,
          // в качестве текста исп. Tmp_VillName
          New(NodeDataPtr);
          NodeDataPtr^.NodeType := -3;
          NodeDataPtr^.Status := False;
          NodeDataPtr^.ID := IntToStr(MyAccount.Derevni.Items[t].ID);
          NodeDataPtr^.FData := MyAccount.Derevni.Items[t].Name;
          NodeDataPtr^.Account_Data := self; // !!!!! Внесем себя !!!!!
          VillNode := Accounts_TreeView.Items.AddChildObject(AccountNode,
            Tmp_VillName, NodeDataPtr);
        end;
      end; // for t := 0 to MyAccount.Derevni_Count-1

      // Все с визуализацией временно покончили
      // Теперь надо пройтись по всем деревням и зачитать их данные
      // И будем это делать в отдельном цикле, хотя могли бы и в предыдущем
      // однако негоже смешивать две разные вещи!!!!

      // Станем на дорф1
      document := FindAndClickHref(WBContainer, document, MyAccount.Connection_String + '/dorf1.php', 1);

      for t := 0 to MyAccount.Derevni_Count - 1 do
      begin // цикл по деревням
        // Переключимся на нужную деревню
        // Ну а если деревушка одна то то мы всё равно стоим на ней!!!
        if MyAccount.Derevni_Count > 1 then
          document := FindAndClickHref(WBContainer, document, '?newdid=' + MyAccount.Derevni.Items[t].NewDID, 4);
        if Assigned(document) then
        begin // Успешное переключение!
          MyAccount.IdCurrentVill := MyAccount.Derevni.Items[t].ID;
          // Посмотрим где мы стоим
          // Если не на dorf1 или 2 то переключаемся на dorf1
          url := document.url;
          if (pos('dorf1',url) <> 0) or  (pos('dorf2',url) <> 0) then // Переключимся на dorf1
            document := FindAndClickHref(WBContainer, document, MyAccount.Connection_String + '/dorf1.php', 1);

          for I := 1 to 2 do
          begin
            Clone_Document(DocumentHTML);
            url := document.url;
            if (pos('dorf1',url) <> 0) then
            begin
              MyAccount.Derevni.Items[t].prepare_dorf1(document, DocumentHTML,
                FLog);
              next_dorf := 'dorf2.php';
            end
            else
            begin
            if (pos('dorf2',url) <> 0) then
              begin
                MyAccount.Derevni.Items[t].prepare_dorf2(document, DocumentHTML,
                  FLog); // Обработка  dorf2
                MyAccount.Derevni.Items[t].SetGidForId40(30 + MyAccount.race);
                  // Это ограда!!!!
                next_dorf := 'dorf1.php'
              end
              else
              begin
                // логическая ошибка
              end;
            end;
            if i = 1 then
              document := FindAndClickHref(WBContainer, document,MyAccount.Connection_String + '/' + next_dorf, 1);
          end; // for I
        end; // if Assigned(document)
      end; // цикл по деревням
    end; // if Result then  Логин нормальный!

    // Запускаем обработку задач
    Task_Work_Timer.Enabled:=True;
  end; // (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '')
end;

procedure TAccount_Data.Clone_Document(DocumentHTML: IHTMLDocument2);
var
  HTML: string; //сохраняем сюда исходный код страницы
  V_HTML: OleVariant; //нуна для запихания  HTML в DocumentHTML
begin
  if Assigned(DocumentHTML)  then
  begin
    DocumentHTML.close;
    WB_GetHTMLCode(WBContainer, HTML);
    V_HTML := VarArrayCreate([0, 0], varVariant);
    V_HTML[0] := HTML;
    DocumentHTML.Write(PSafeArray(TVarData(V_HTML).VArray));
  end;
end;

constructor TAccount_Data.Create(AOwner: TComponent);
begin
  //  inherited Create(AOwner) ;

  fMyAccount := TAccount.Create;
  fMyAccount.Account_data:=self;

  //крутиться тайер на который цыпляем оброботку задач из списка всех задачь
  fTask_queue := TTask_queue.Create;
  fTask_Work_Timer := TTimer.Create(nil);
  fTask_Work_Timer.Enabled:=false;
  fTask_Work_Timer.Interval:=1000;     // 1- секунда
  fTask_Work_Timer.OnTimer:=Task_Work;


  fWebBrowser := TWebBrowser.Create(AOwner);
  fWebBrowser.Silent := True;
  TWinControl(fWebBrowser).Parent := (AOwner as TWinControl);
  fWebBrowser.Align := alClient;
  fWebBrowser.OnDocumentComplete := WebBrowserDocumentComplete;

  // Создание контейнера
  fWBContainer := TWBContainer.Create(fWebBrowser);
  UrlMkSetSessionOption(URLMON_OPTION_USERAGENT, PChar('Opera/9.80 (Windows NT 6.1; U; en) Presto/2.9.168 Version/11.52'),
                        Length('Opera/9.80 (Windows NT 6.1; U; en) Presto/2.9.168 Version/11.52'), 0);
  //  fWBContainer.OptionKeyPath:= 'Software\X-bot\Explorer';  // Настройки хранятся в HKEY_CURRENT_USER
  //  fWBContainer.UseCustomCtxMenu := True;    // use our popup menu
  //  fWBContainer.Show3DBorder := False;       // no border
  //  fWBContainer.ShowScrollBars := False;     // no scroll bars
  //  fWBContainer.AllowTextSelection := False; // no text selection (**)

end;

destructor TAccount_Data.Destroy;
begin
  fWBContainer.Free;
  fWebBrowser.Free;
  fTask_Work_Timer.Free;
  fTask_queue.Free;
  fMyAccount.Free;
  inherited;
end;

function TAccount_Data.is_login_page(document: IHTMLDocument2):
  IHTMLFormElement;
//  Если на входе страница логина, то вытаскиваем из неё форму и возвращаем
//   иначе NIL
var
  allForms: IHTMLElementCollection;
begin
  //  Страница логина?????
  Result := nil;
  if Assigned(document) then
  begin
    allForms := document.forms;
    if Assigned(allForms) then
    begin
      Result := allForms.Item('snd', '') as IHTMLFormElement;
      if not Assigned(Result) then
        Result := allForms.Item('login', '') as IHTMLFormElement;
      if Assigned(Result) then
        if Result.action <> 'dorf1.php' then Result := nil;
    end;

  end;
end;

procedure TAccount_Data.set_AccountNode_StateIndex;
begin
  AccountNode.StateIndex := MyAccount.Race;
end;

procedure TAccount_Data.Start_construction;
var
  Vill: TVill;
  Task_Build: TTask_Build;
begin
//  Определимся с текущей деревней
  Vill:=MyAccount.Derevni.VillById(MyAccount.IdCurrentVill);
// Посмотрим а есть ли что-то в очереди
  if Vill.BuildList <> '' then
  begin  // Да очередь не пустая значит можно!!!!!
    // Сначала остановим обработку очереди задач
    Task_Work_Timer.Enabled:=false;


    Task_Build:=TTask_Build.Create;  // Создали задачу стройки
    Task_Build.Task_type:=ttBuild;   // Указали явно тип задачи
    Task_Build.Vill:=Vill;           // Указали Деревню
    Task_Build.BeginWork:=MyAccount.TravianTime + SecondsTime(2); // Текущее время + 2 секунды
    Task_Build.StopWork:=MyAccount.TravianTime + 1000;  // Текущее время + далекое будущее
    Task_Build.TimeCheck:=MyAccount.TravianTime + SecondsTime(3); // Текущее время + 3 секунды
    Task_Build.Status:=tsReady;
    Task_Build.Set_ACF_BuildList:=Set_ACF_BuildList;

    Task_queue.AddTask(Task_Build);
    // Теперь можно запустить обработку очереди задач
    Task_Work_Timer.Enabled:=true;
  end;
end;

procedure TAccount_Data.Start_farm;
var
  Vill: TVill;
  Task_Farm: TTask_Farm;
begin
  //  Определимся с текущей деревней
  Vill:=MyAccount.Derevni.VillById(MyAccount.IdCurrentVill);
  // Посмотрим а есть ли что-то в очереди
  if Vill.FarmLists.Count > 0 then
  begin  // Да очередь не пустая значит можно!!!!!
    // Сначала остановим обработку очереди задач
    Task_Work_Timer.Enabled:=false;


    Task_Farm:=TTask_Farm.Create;  // Создали задачу стройки
    Task_Farm.Task_type:=ttSendTroops;   // Указали явно тип задачи
    Task_Farm.Vill:=Vill;           // Указали Деревню
    Task_Farm.BeginWork:=MyAccount.TravianTime + SecondsTime(2); // Текущее время + 2 секунды
    Task_Farm.StopWork:=MyAccount.TravianTime + 1000;  // Текущее время + далекое будущее
    Task_Farm.TimeCheck:=MyAccount.TravianTime + SecondsTime(3); // Текущее время + 3 секунды
    Task_Farm.Status:=tsReady;
    Task_Farm.FarmList := Vill.FarmLists;
    Task_queue.AddTask(Task_Farm);
    // Теперь можно запустить обработку очереди задач
    Task_Work_Timer.Enabled:=true;
  end;
end;

procedure TAccount_Data.Stop_construction;
begin

end;

procedure TAccount_Data.Stop_farm;
begin

end;

procedure TAccount_Data.Task_Work(Sender: TObject);
//  Процедура обработки очереди заданий
var TaskNumber: integer;
  Task :TTask;
  r_TravianTime: TDateTime;

begin
  Task_Work_Timer.Enabled:=False;
  r_TravianTime := MyAccount.TravianTime;

  // Цикл обработки
  for TaskNumber := 0 to Task_queue.Count - 1 do
  begin
    Task:=Task_queue.Task[TaskNumber];
    if Task.BeginWork <= r_TravianTime then   // Рабочая Смена уже идет, надо работать
    begin
      if Task.TimeCheck <= r_TravianTime then
      begin  // Обработка задания
        if Task.Status in [tsReady, tsRun]  then
          Task.Execute(WBContainer,Log);
      end;
    end;

    if Task.StopWork < r_TravianTime then    // Рабочая смена истекла, безжалостно ставим его на удаление
      Task.Status:=tsDelete;
  end;

  // Здесь сортировка по времени, а также удаление задач со статусом tsDelete
  Task_queue.sort;

  Task_Work_Timer.Enabled:=true;
end;

procedure TAccount_Data.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  fWBContainer.DocLoaded := true;
end;

end.
