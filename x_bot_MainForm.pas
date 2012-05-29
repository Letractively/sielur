unit
  x_bot_MainForm;

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
  , ExtCtrls
  , Menus
  , ComCtrls
  , StdCtrls
  , RzPanel
  , IniFiles
  , RzTabs
  , RzCommon
  , RzSplit
  , OleCtrls
  , SHDocVw
  , UContainer
  , Account_data
  , Add_User_Form
  , x_bot_utl
  , MSHtml
  , MyIniFile
  , Account_Frame
  , Trava_Class
  , RzTreeVw
  , ActnList
  , ImgList
  , Trava_task
  , U_Utilites
  , pcre
  , PerlRegEx
  ;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    RzPanel1: TRzPanel;
    RzPanel2: TRzPanel;
    Account_Panel: TRzPanel;
    Exit2: TMenuItem;
    View1: TMenuItem;
    VList_Align: TMenuItem;
    L_panel: TRzSizePanel;
    Vill_List_Panel: TRzSizePanel;
    RzPanel4: TRzPanel;
    Accounts_TreeView: TRzTreeView;
    RzPanel3: TRzPanel;
    Server_Name_Display: TLabeledEdit;
    User_Name: TLabeledEdit;
    Password_Name: TLabeledEdit;
    Accounts_TreeView_PopupMenu: TPopupMenu;
    Add_Account_MenuItem: TMenuItem;
    Login1: TMenuItem;
    LogOn1: TMenuItem;
    Delete_Account_MenuItem: TMenuItem;
    Button1: TButton;
    Unit_ImageList: TImageList;
    State_ImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VList_AlignClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Accounts_TreeViewNodeContextMenu(aSender: TObject;
      aNode: TTreeNode; var aPos: TPoint; var aMenu: TPopupMenu);
    procedure Add_Account_MenuItemClick(Sender: TObject);
    procedure Delete_Account_MenuItemClick(Sender: TObject);
    procedure Login1Click(Sender: TObject);
    procedure Accounts_TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure Exit2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
//    fWBContainer: TWBContainer;
    FLog: TStringList;
    procedure Set_VList_Align(value: boolean);
    procedure Save_control;
    procedure Save_Accounts_Tree;
    procedure Load_Control;
    procedure Load_Accounts_Tree;
    procedure Add_Account;
    procedure Delete_Account;
    procedure Login_Account;
  public
    { Public declarations }
    // тут будем хранить все что делаем с ботом, всю стаистику:)
    property Log: TStringList read FLog write FLog;
  end;

  procedure Set_ACF_BuildList(const Value: string);

var
  MainForm: TMainForm;
  App_Dir: string;
  App_Name: string;
  App_Ext: string;

  ACF: TAccount_Form;

  CurrentAccount: TAccount_Data;

implementation

uses
  TypInfo;

{$R *.dfm}

procedure TMainForm.Login1Click(Sender: TObject);
begin
  Login_Account;
end;

procedure TMainForm.Login_Account;
var
  AccountNode: TTreeNode;
  Account_Data: TAccount_Data;
begin
  if Assigned(Acf) then
  begin
    // На всякий случай проверим
    if Accounts_TreeView.Items.Count > 0 then
    begin
      AccountNode := Accounts_TreeView.Selected;
      if (PNodeData(AccountNode.Data)^.NodeType = -2) and (not
        PNodeData(AccountNode.Data)^.Status) then
      begin // Это Account и он не залогинен
        FLog.Add('Выполнили TAccount_Data.Create(ACF.Browser_RzPanel)');
        Account_Data := TAccount_Data.Create(ACF.Browser_RzPanel);
        ACF.RzPageControl1.ActivePageIndex := 13;
        FLog.Add('Стартуем ббота Account_Data.Bot_Start_Work(Accounts_TreeView,AccountNode);');
        if Account_Data.Bot_Start_Work(Accounts_TreeView, AccountNode, FLog)
          then
        begin
          Account_Data.Set_ACF_BuildList:=Set_ACF_BuildList;
          ACF.Account_data := Account_Data;
        end;
      end;
    end;
  end;
  FLog.Add('выкосить FLog.Add( в procedure TMainForm.Login_Account; и сохранение в файл');
  if DirectoryExists('log') = false then CreateDir('log');
  FLog.SaveToFile(App_Dir+'log\AdskiyLog.txt');
  FLog.Clear;
end;

procedure TMainForm.Accounts_TreeViewChange(Sender: TObject; Node: TTreeNode);
//var
//    Account_Data:TAccount_Data;
begin
  if Assigned(Acf) then
  begin
    // На всякий случай проверим
    if Accounts_TreeView.Items.Count <= 0 then
      ACF.Account_data := nil
    else
    begin
      if (PNodeData(Node.Data)^.NodeType = -3) then // Деревня
        PNodeData(Node.Data)^.Account_Data.MyAccount.IdCurrentVill :=
          StrToInt(PNodeData(Node.Data)^.ID);
      if (PNodeData(Node.Data)^.NodeType = -3) or
        ((PNodeData(Node.Data)^.NodeType = -2) and PNodeData(Node.Data)^.Status)
          then
        ACF.Account_data := PNodeData(Node.Data)^.Account_Data
          // Это Account и он залогинен
      else
        ACF.Account_data := nil;
    end;
  end;
end;

procedure TMainForm.Accounts_TreeViewNodeContextMenu(aSender: TObject;
  aNode: TTreeNode; var aPos: TPoint; var aMenu: TPopupMenu);
var
  NodeType: integer;
  Status: Boolean;
begin

  NodeType := -1;
  Status := False;
  if Assigned(aNode) then
  begin
    Accounts_TreeView.selected := aNode;
    NodeType := PNodeData(aNode.Data)^.NodeType;
    Status := PNodeData(aNode.Data)^.Status;
  end;

  // Ну а теперь будем разбираться что разрешить а что запретить
  // NodeType = -1 - Сервер
  //      Add_User    +
  //      Login       -
  //      Logout      -
  //      Delete_User -
  // NodeType = -2 - Account
  //      Add_User    +
  //      Login       + Если Status = False (тобиш текущее состояние Logout)
  //      Logout      + Если Status = True (тобиш текущее состояние Login)
  //      Delete_User + Если Status = False (тобиш текущее состояние Logout)

  // NodeType = -3 - Village
  //      Add_User    +
  //      Logi       -
  //      Logout      +
  //      Delete_User -

  aMenu.Items[0].Enabled := True;
  aMenu.Items[1].Enabled := ((NodeType = -2) and not Status);
  aMenu.Items[2].Enabled := (NodeType = -3) or ((NodeType = -2) and Status);
  aMenu.Items[3].Enabled := ((NodeType = -2) and not Status);
end;

procedure TMainForm.Add_Account_MenuItemClick(Sender: TObject);
begin
  Add_Account;
end;

procedure TMainForm.Add_Account;
var
  Tmp_Node: TTreeNode;
  ServerNode: TTreeNode;
  AccountNode: TTreeNode;
  Server_Name: string;
  User_Name: string;
  Password_Name: string;
  NodeDataPtr: PNodeData;
begin
  // сначала разберемся что-же нам воткнуть в Server_name
  Add_New_User.Server_Name.Text := '';
  if Accounts_TreeView.Items.Count > 0 then
  begin
    Tmp_Node := Accounts_TreeView.Selected;
    // Надо добраться до корня
    while Tmp_Node.Parent <> nil do
      Tmp_Node := Tmp_Node.Parent;

    // На всякий случай проверим
    if PNodeData(Tmp_Node.Data)^.NodeType = -1 then
      Add_New_User.Server_Name.Text := PNodeData(Tmp_Node.Data)^.FData;
  end;

  Add_New_User.User_Name.Text := '';
  Add_New_User.Password_Name.Text := '';

  if Add_New_User.ShowModal = mrOk then
  begin
    Server_Name := Add_New_User.Server_Name.Text;
    User_Name := Add_New_User.User_Name.Text;
    Password_Name := Add_New_User.Password_Name.Text;

    // Добавим сервер в список
         // Найдем в списке заданный сервер
    ServerNode := find_node(Accounts_TreeView, nil, Server_Name, -1);
    if not Assigned(ServerNode) then // Сервер не нашли --> добавим его
    begin
      New(NodeDataPtr);
      NodeDataPtr^.NodeType := -1;
      NodeDataPtr^.Status := False;
      NodeDataPtr^.ID := '';
      NodeDataPtr^.FData := Server_Name;
      ServerNode := Accounts_TreeView.Items.AddObject(nil, Server_Name,
        NodeDataPtr);
    end;

    // Добавим Account в список
    AccountNode := find_node(Accounts_TreeView, ServerNode, User_Name, -2);
    if not Assigned(AccountNode) then
    begin // Account не нашли --> добавим его
      // добавляем дочерний по отношению к ServerNode узел,
      // в качестве текста исп. User_Name
      New(NodeDataPtr);
      NodeDataPtr^.NodeType := -2;
      NodeDataPtr^.Status := False;
      NodeDataPtr^.ID := '';
      //      NodeDataPtr^.FData:=Password_Name;
      AccountNode := Accounts_TreeView.Items.AddChildObject(ServerNode,
        User_Name, NodeDataPtr);
    end;
    // Пароль вносим только если акк еще не залогинен
    // Если же акк залогинен то пароль не вносим
    if not PNodeData(AccountNode.Data)^.Status then
      PNodeData(AccountNode.Data)^.FData := Password_Name;

    AccountNode.Selected := True;
  end;
end;


procedure TMainForm.Delete_Account;
var
  Tmp_Node: TTreeNode;
begin
  // На всякий случай проверим
  if Accounts_TreeView.Items.Count > 0 then
  begin
    Tmp_Node := Accounts_TreeView.Selected;
    if (PNodeData(Tmp_Node.Data)^.NodeType = -2) and
      (not PNodeData(Tmp_Node.Data)^.Status) then
      Tmp_Node.Delete;
  end;
end;

procedure TMainForm.Delete_Account_MenuItemClick(Sender: TObject);
begin
  Delete_Account;
end;

procedure TMainForm.Exit2Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (MessageBox(Application.Handle, 'Really want to exit?', 'Confirmation', MB_OKCANCEL + MB_ICONWARNING) = ID_OK);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Save_control; // Запомним настройки формы
  Save_Accounts_Tree; // Запомним настройки аков

  FLog.Add('Завершаем работу');
  if DirectoryExists('log') = false then CreateDir('log');
  FLog.SaveToFile(App_Dir+'log\WLog.txt');
  FLog.Clear;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLog := TStringList.Create;
  App_Dir := ExtractFilePath(Application.ExeName);
  App_Ext := ExtractFileExt(Application.ExeName);
  App_Name := ExtractFileName(Application.ExeName);
  App_Name := copy(App_Name, 1, length(App_Name) - length(App_ext));

  Load_Control; // Загрузим настройки формы
  Load_Accounts_Tree; // Загрузим настройки аков

  Acf := TAccount_Form.Create(self);
  Acf.Parent := Account_Panel;
  Acf.Align := alClient;

end;

procedure TMainForm.Load_Accounts_Tree;
var
  Ini: TMyIniFile;

  LS, LV: TStrings;
  t, r: integer;

  ServerNode: TTreeNode;
  AccountNode: TTreeNode;
  Server_Name: string;
  User_Name: string;
  Password_Name: string;
  NodeDataPtr: PNodeData;
begin
  Accounts_TreeView.Items.Clear;
  Ini := TMyIniFile.Create(App_Dir + App_Name + '_Connect' + '.INI');
  try
    LS := TStringList.Create; // список названий секций
    try
      ini.ReadSections(LS);
      // читаем все секции в список (на самом деле это наши сервера)
      LV := TStringList.Create; // список пар "имя=значение"
      try
        for t := 0 to LS.Count - 1 do // для всех секций...
        begin
          Server_Name := LS[t];
          // добавляем корневой узел (имя серверв)
          New(NodeDataPtr);
          NodeDataPtr^.NodeType := -1;
          NodeDataPtr^.Status := False;
          NodeDataPtr^.ID := '';
          NodeDataPtr^.FData := Server_Name;
          ServerNode := Accounts_TreeView.Items.AddObject(nil, Server_Name,
            NodeDataPtr);

          LV.Clear; // подготовим список
          ini.ReadSection(Server_Name, LV);
          // читаем список ключей (имен) текущей секции
        // собственно мы знаем что их всего два типа
        //   'User_Name#nnn'
        //   'Password_Name#nnn'
        // где nnn - номер пары
        //           причем нумерация пар непрерывна и идет с Нуля
        // И поэтому всё намного проще
          for r := 0 to (LV.Count div 2) - 1 do // для всех ключей
          begin
            User_Name := ini.ReadUTF8(Server_Name, 'User_Name#' + IntToStr(r),
              '');
            Password_Name := ini.ReadUTF8(Server_Name, 'Password_Name#' +
              IntToStr(r), '');
            // добавляем дочерний по отношению к ServerNode узел,
            // в качестве текста исп. User_Name
            New(NodeDataPtr);
            NodeDataPtr^.NodeType := -2;
            NodeDataPtr^.Status := False;
            NodeDataPtr^.ID := '';
            NodeDataPtr^.FData := Password_Name;
            AccountNode := Accounts_TreeView.Items.AddChildObject(ServerNode,
              User_Name, NodeDataPtr);
          end;
        end;
      finally
        LV.Free;
      end;
    finally
      LS.Free;
    end;
  finally
    Ini.Free;
  end;

end;

procedure TMainForm.Load_Control;
var
  Ini: TMyIniFile;
begin
  Ini := TMyIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
  try
    VList_Align.Checked := ini.ReadBool('View', 'VList_Align.Checked',
      VList_Align.Checked);
    L_panel.Width := ini.ReadInteger('View', 'L_panel.Width', L_panel.Width);
    ini.LoadProperty('View', 'L_panel.Align', L_panel, 'Align', 'alRight');
    Vill_List_Panel.Height := ini.ReadInteger('View', 'Vill_List_Panel.Height',
      Vill_List_Panel.Height);
  finally
    Ini.Free;
  end;

end;

procedure TMainForm.Save_Accounts_Tree;
var
  Ini: TMyIniFile;
  ServerNode: TTreeNode;

  Server_Name: string;
  User_Name: string;
  Password_Name: string;
  t: integer;
begin
  DeleteFile(App_Dir + App_Name + '_Connect' + '.INI');
  Ini := TMyIniFile.Create(App_Dir + App_Name + '_Connect' + '.INI');
  try
    ServerNode := Accounts_TreeView.Items.GetFirstNode;
    while Assigned(ServerNode) do
    begin
      if (PNodeData(ServerNode.Data)^.NodeType = -1) then // Сервер
      begin // Это сервер!!!
        Server_Name := PNodeData(ServerNode.Data)^.FData;

        for t := 0 to ServerNode.Count - 1 do
        begin
          if (PNodeData(ServerNode[t].Data)^.NodeType = -2) then
          begin // Account
            User_Name := ServerNode[t].Text;
            Password_Name := PNodeData(ServerNode[t].Data)^.FData;
            ini.WriteUTF8(Server_Name, 'User_Name#' + IntToStr(t), User_Name);
            ini.WriteUTF8(Server_Name, 'Password_Name#' + IntToStr(t),
              Password_Name);
            //            ini.WriteString(Server_Name,'User_Name#'+IntToStr(t),User_Name);
            //            ini.WriteString(Server_Name,'Password_Name#'+IntToStr(t),Password_Name);
          end; // Account
        end; // FOR
      end; // Это сервер!!!
      ServerNode := ServerNode.GetNextSibling;
    end; // While
  finally
    Ini.Free;
  end;
end;

procedure TMainForm.Save_control;
var
  Ini: TMyIniFile;
begin

  Ini := TMyIniFile.Create(App_Dir + App_Name + '.INI');
  try
    ini.WriteBool('View', 'VList_Align.Checked', VList_Align.Checked);
    ini.WriteInteger('View', 'L_panel.Width', L_panel.Width);
    ini.WriteProperty('View', 'L_panel.Align', L_panel, 'Align');
    ini.WriteInteger('View', 'Vill_List_Panel.Height', Vill_List_Panel.Height);
  finally
    Ini.Free;
  end;

end;

procedure TMainForm.Set_VList_Align(value: boolean);
begin
  if Value then
    L_Panel.Align := alLeft
  else
    L_Panel.Align := alRight;
end;

procedure TMainForm.VList_AlignClick(Sender: TObject);
begin
  VList_Align.Checked := not VList_Align.Checked;
  Set_VList_Align(VList_Align.Checked);

end;


procedure TMainForm.Button1Click(Sender: TObject);
var
//  tb: TTask_Build;
//  tt:TTask_queue;
//  BID: string;
//  document: IHTMLDocument2;
//  url: string;

//  Tmp_Collection : IHTMLElementCollection;
//  fieldButton_Element :IHTMLButtonElement;
//  field_Element :IHTMLElement;
//  ItemNumber: integer;
  duration: integer;
begin

//  acf.Account_data.MyAccount.Derevni.VillByXY(80,71).build_center(acf.Account_data.WBContainer,'8','',acf.Account_data.log);
//  showmessage(IntToStr(duration));

{
  tt:=TTask_queue.Create;
  tb:=TTask_Build.Create;

  tt.AddTask(tb);
  tb.Build_List:='6;7;';
  tb.Vill:=acf.Account_data.MyAccount.Derevni.VillByXY(80,71);

  // Получим ID поля на котором надо строить
  //  build.php?id=4
  BID:=tb.Next_Build;

  if BID = '' then
  begin
    showmessage('Очередь пустая');
    exit;
  end;

  document:=acf.Account_data.WBContainer.HostedBrowser.Document as IHTMLDocument2;
    // Проверим стоим ли мы на DORF1 ????  и если нет то перейдем на неё
  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
    document := FindAndClickHref(acf.Account_data.WBContainer, document,
              acf.Account_data.MyAccount.Connection_String + '/' + 'dorf1.php', 1);


  url := document.url;
  if (copy(url, length(url) - 8) <> 'dorf1.php') then
  begin
    showmessage('Что-то не то');
    exit;
  end;

  // Нажмем на ссылку
  document := FindAndClickHref(acf.Account_data.WBContainer, document,
              'build.php?id='+BID, 4);


  Tmp_Collection := Document.all.tags('button') as IHTMLElementCollection;

  // Если кнопка есть то нажмем на неё
  field_Element:=nil;
  for ItemNumber := 0 to Tmp_Collection.Length - 1 do
  begin
    fieldButton_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLButtonElement;
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    acf.Account_Data.WBContainer.MyElementClick(field_Element);
    break;
  end;
  if Assigned(field_Element) then
  begin
    acf.Account_Data.WBContainer.MyElementClick(field_Element);
    // Анализ когда закончится стройка
  end
  else begin
    // Анализ почему стройка недоступна
    showmessage('Стройка недоступна');
  end;

//  document:=acf.Account_data.WBContainer.HostedBrowser.Document as IHTMLDocument2;
}
end;

// Это мне не нравится, но как по другому сделать пока не придумал
procedure Set_ACF_BuildList(const Value: string);
begin
  acf.BuildList.Text:=Value;

end;
end.
