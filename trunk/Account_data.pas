unit
  Account_data;

// ������ �� ���
//   ��� ��� ����� ������� ��� �� ��� �������� ����
//   ������� �� ����� � ����  � ���������� �������

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


    //����� ��� �4 � �3.6 ������ ��������
    function is_login_page(document: IHTMLDocument2): IHTMLFormElement;
      // �������� �������� �� �������� �����
    function Account_login(LoginForm: IHTMLFormElement): boolean; //  �����
    function Bot_Start_Work(aAccounts_TreeView: TRzTreeView; aAccountNode:
      TTreeNode; ALog: TStringList): boolean; // ������ ���� ��� ����� � ���� �3,6
    procedure Clone_Document(DocumentHTML: IHTMLDocument2);

    // ��������� ������� ����� �� �������
    procedure Task_Work(Sender: TObject);

    // ���������� ������ ������� ���� � ������ � ������� �����
    //  ��� ���������� �������� ������ �������
    procedure Start_construction;
    // ��������  ������ ������� ���� � ������ �� ������� �����
    procedure Stop_construction;
    //���������� ������ ����� � ������� �����
    //��� ���������� �������� ������ ���� � ������� ����� ����� ����� � �����
    //������� � ����  :)
    procedure Start_farm;
    //���� �� ���� ��� ��� ������������� ���� .. ����� ��� � ���� ���� ����� ...
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
    NodeType: integer; // -1  - ������
    // -2  - Account
    // -3  - Village
    Status: Boolean; // ������ ��� Account
    //  True  - Login
    //  False - Logout
    ID: string; // UID - ��� Account
    // ID - ��� Village
    Account_Data: TAccount_Data;
    FData: string; // - ������  (NodeType=-1)
    // - ������  (NodeType=-2)
  end;

function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: string;
  NodeType: integer): TTreeNode; // ����� ����

implementation

function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: string; NodeType: integer): TTreeNode;
// ����� ����
//    ���� ���� �� ������ �� ������������  nil
//    ����� ��������� ����
//  Tree       -   ������  �������-����-�������
//  Node       -   ���� (�����) � ������� ���� ����� �������� "���-����" ���� �� �� ������ �� ����� ���� ������� � ����� ������
//  NodeName   -   ��� ���� ������� ���� �����
//  NodeType   -   ��� ���� ������� ���� �����
//
var
  t: integer;
begin
  Result := nil;

  if not Assigned(Node) then
  begin // ����� ��� � �����
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
  end // ����� ��� � �����
  else
  begin // ����� ��� � �����
    for t := 0 to Node.Count - 1 do
    begin
      if (Node[t].Text = NodeName) and (PNodeData(Node[t].Data)^.NodeType =
        NodeType) then
      begin
        Result := Node[t];
        Break;
      end;
    end; // ����� � �����
  end;
end;

{ TAccount_Data }

function TAccount_Data.Account_login(LoginForm: IHTMLFormElement): boolean;
//  �����
//     ����������  TRUE  -  ��� �������� ������
//                 FALSE -  ��� ���������
// LoginForm   -  �������� ������
//
var
  ItemNumber: integer;
  field: IHTMLElement;
  input_field: IHTMLInputElement;
  Count_input_field: integer;
begin
  // ������ ������
  //  ����������� �� ���� ����� �����
  //  ����� ������ ��� ���� ('name' � 'password')
  //   ��������� �� � ������ �� �������� ����
  FLog.Add('��������� ...');
  Result := false;
  Count_input_field := 0;
  if Assigned(LoginForm) then
  begin
    for ItemNumber := 0 to LoginForm.Length - 1 do
    begin //  ����� �� ���� ��������� �����
      field := LoginForm.Item(ItemNumber, '') as IHTMLElement;
      if Assigned(field) then
      begin
        if field.tagName = 'INPUT' then
        begin //  ���� �����
          input_field := field as IHTMLInputElement;
          if input_field.Name = 'name' then
          begin
            input_field.Value := MyAccount.Login; // ������ ���� ���
            Count_input_field := Count_input_field + 1;
          end; //  'name'
          if input_field.Name = 'password' then
          begin
            input_field.Value := MyAccount.Password; // ������ ���� ������
            Count_input_field := Count_input_field + 1;
          end; // 'password'
        end;
      end; //  ���� �����
    end; //  ����� �� ���� ��������� �����

    if Count_input_field <> 2 then
    begin
      FLog.Add('����� ������ 2 ����� ����� , ���� ����������');
      exit; //  ���� � ����� �� ��� ���� �����  �� �� ���-�� ���-�� ���������
    end;
    FLog.Add('������ �� ������ ...');
    fWBContainer.MyFormSubmit(LoginForm); //   ������ �� ��������

    //  �������� ������������ ��� ���
    //     ���������� �������� �����
    //  ���� �� ���������� �������� ��� ����� ������ �� �� � �������
    Result := (is_login_page(fWBContainer.HostedBrowser.Document as
      IHTMLDocument2) = nil);
    if Result then
      FLog.Add('������������!')
    else
      FLog.Add('����� �� ������ �����!!!');
  end;

end;

function TAccount_Data.Bot_Start_Work(aAccounts_TreeView: TRzTreeView;
  aAccountNode: TTreeNode; ALog: TStringList): boolean;
//      ������ ������ ���� � �������� ����
//  aAccounts_TreeView   - ������ �������-���-�������
//  aAccountNode         - ���� ��� � ������
//
//  ���������� ������ ����� � ������� �������� ��������� ���
//
var
  Server_Name: string;
  User_Name: string;
  Password_Name: string;
  ServerNode: TTreeNode;
  VillNode: TTreeNode;
  SndForm: IHTMLFormElement;
  Document: IHTMLDocument2;
  DocumentHTML: IHTMLDocument2; //����� ��� ���� ����������� title (�� Win XP)
  Tmp_VillName: string;
  NodeDataPtr: PNodeData;
  t: integer;
  url: string;
  i: integer;
  next_dorf: string;
  HTML: string; //��������� ���� �������� ��� ��������
begin
  //  ��������� �� ����� ��� ���-�� ���� ����� ������� ��������� ���������
  //  1. Assigned(aAccounts_TreeView)
  //        �.�. ���������� ������ ����
  //  2. (PNodeData(aAccountNode.Data)^.NodeType = -2) and (not PNodeData(aAccountNode.Data)^.Status)
  //        �.�. ��� Account � �� �� ���������
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
  // � ������ ������
  ServerNode := AccountNode.Parent; // ���� �������
  // �������� ���-��!!!
  if (PNodeData(ServerNode.Data)^.NodeType = -1) then
  begin
    Server_Name := ServerNode.Text;
  end;

  if (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '') then
  begin
    MyAccount.Connection_String := 'http://' + Server_Name;
    MyAccount.Login := User_Name;
    MyAccount.Password := Password_Name;
    FLog.Add('������������ - ' + User_Name);
    FLog.Add('������� �� ������' + MyAccount.Connection_String);
    WBContainer.MyNavigate(MyAccount.Connection_String);
      //   ��������� �������� ������
    //����� �������� �������� ������ ����� ���������� ������ ����
    MyAccount.TravianVersion := tvNone;
    if WB_GetHTMLCode(WBContainer, HTML) then
    begin
      if AnsiPos('Travian.Game.version = ''4.0''', HTML) <> 0 then
        MyAccount.TravianVersion := tv40
      else if AnsiPos('class="v35', HTML) <> 0 then
        MyAccount.TravianVersion := tv36;
    end;
    FLog.Add('������ ���� ' + GetEnumName(TypeInfo(TTravianVersion),
      Ord(MyAccount.TravianVersion)));
    if MyAccount.TravianVersion = tvNone then
    begin
      FLog.Add('��� �� �����, ��� ������ ������ ���� �� ��������������');
      exit;
    end;

    SndForm := is_login_page(WBContainer.HostedBrowser.Document as
      IHTMLDocument2); //  ������� �� �� ����� ������
    if Assigned(SndForm) then
    begin //  ����� ������ ����������
      Result := Account_login(SndForm); //  ������� ������
      if Result then
      begin // ����� ����������!
        // �������� �� �������� �������!
        FLog.Add('��������� �� �������� �������');
        Document := FindAndClickHref(WBContainer,
          WBContainer.HostedBrowser.Document as IHTMLDocument2,
          MyAccount.Connection_String + '/spieler.php?', 2);
        if Document <> nil then
        begin //  �������� ������� �� �������� �������
          FLog.Add('�������� ������� �� �������� �������.');
          //������ ���������� ���� ��� ��������� ���������� IHTMLDocument2
          //����� � ���� ������ �������� ��� �������� � ��� ���������� ������
          //� ��� ������ ��������� title �����������
          //������������� ������� ��������� ��������� � �� ... ���� �������
          Clone_Document(DocumentHTML);
          MyAccount.prepare_profile(WBContainer, Document, DocumentHTML, Flog);
            // ��������� �������

        end;
      end; // ����� ����������!
    end; // Assigned(SndForm)

    PNodeData(AccountNode.Data)^.Status := Result;
    if Result then
    begin // ����� ����������!
      set_AccountNode_StateIndex; //  ��������� ������ �������� ��� ��� ����� �������� � ������
      PNodeData(AccountNode.Data)^.ID := MyAccount.UID;
      PNodeData(AccountNode.Data)^.Account_Data := self;
        // !!!!! ������ ���� !!!!!

      // �������  � ������ ������ ��������
      for t := 0 to MyAccount.Derevni_Count - 1 do
      begin //   ���������� �� ���� ��������
        //  �������� ����� ���� �� ����� ������� ���� ������������ � �������� ��������������
        //  ������������ ������� ��� ����� �������������� ����� �������� ��������
        //  ������ �� ����� ������ �� ��������� ��� ��� ��������������� � �� ������
        Tmp_VillName := MyAccount.Derevni.Items[t].Name + ' ' +
          MyAccount.Derevni.Items[t].coord;
        VillNode := find_node(Accounts_TreeView, AccountNode, Tmp_VillName, -3);
        if not Assigned(VillNode) then
        begin // ������� �� ����� --> ������� �
          // ��������� �������� �� ��������� � AccountNode ����,
          // � �������� ������ ���. Tmp_VillName
          New(NodeDataPtr);
          NodeDataPtr^.NodeType := -3;
          NodeDataPtr^.Status := False;
          NodeDataPtr^.ID := IntToStr(MyAccount.Derevni.Items[t].ID);
          NodeDataPtr^.FData := MyAccount.Derevni.Items[t].Name;
          NodeDataPtr^.Account_Data := self; // !!!!! ������ ���� !!!!!
          VillNode := Accounts_TreeView.Items.AddChildObject(AccountNode,
            Tmp_VillName, NodeDataPtr);
        end;
      end; // for t := 0 to MyAccount.Derevni_Count-1

      // ��� � ������������� �������� ���������
      // ������ ���� �������� �� ���� �������� � �������� �� ������
      // � ����� ��� ������ � ��������� �����, ���� ����� �� � � ����������
      // ������ ������ ��������� ��� ������ ����!!!!

      // ������ �� ����1
      document := FindAndClickHref(WBContainer, document, MyAccount.Connection_String + '/dorf1.php', 1);

      for t := 0 to MyAccount.Derevni_Count - 1 do
      begin // ���� �� ��������
        // ������������ �� ������ �������
        // �� � ���� ��������� ���� �� �� �� �� ����� ����� �� ���!!!
        if MyAccount.Derevni_Count > 1 then
          document := FindAndClickHref(WBContainer, document, '?newdid=' + MyAccount.Derevni.Items[t].NewDID, 4);
        if Assigned(document) then
        begin // �������� ������������!
          MyAccount.IdCurrentVill := MyAccount.Derevni.Items[t].ID;
          // ��������� ��� �� �����
          // ���� �� �� dorf1 ��� 2 �� ������������� �� dorf1
          url := document.url;
          if (pos('dorf1',url) <> 0) or  (pos('dorf2',url) <> 0) then // ������������ �� dorf1
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
                  FLog); // ���������  dorf2
                MyAccount.Derevni.Items[t].SetGidForId40(30 + MyAccount.race);
                  // ��� ������!!!!
                next_dorf := 'dorf1.php'
              end
              else
              begin
                // ���������� ������
              end;
            end;
            if i = 1 then
              document := FindAndClickHref(WBContainer, document,MyAccount.Connection_String + '/' + next_dorf, 1);
          end; // for I
        end; // if Assigned(document)
      end; // ���� �� ��������
    end; // if Result then  ����� ����������!

    // ��������� ��������� �����
    Task_Work_Timer.Enabled:=True;
  end; // (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '')
end;

procedure TAccount_Data.Clone_Document(DocumentHTML: IHTMLDocument2);
var
  HTML: string; //��������� ���� �������� ��� ��������
  V_HTML: OleVariant; //���� ��� ���������  HTML � DocumentHTML
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

  //��������� ����� �� ������� ������� ��������� ����� �� ������ ���� ������
  fTask_queue := TTask_queue.Create;
  fTask_Work_Timer := TTimer.Create(nil);
  fTask_Work_Timer.Enabled:=false;
  fTask_Work_Timer.Interval:=1000;     // 1- �������
  fTask_Work_Timer.OnTimer:=Task_Work;


  fWebBrowser := TWebBrowser.Create(AOwner);
  fWebBrowser.Silent := True;
  TWinControl(fWebBrowser).Parent := (AOwner as TWinControl);
  fWebBrowser.Align := alClient;
  fWebBrowser.OnDocumentComplete := WebBrowserDocumentComplete;

  // �������� ����������
  fWBContainer := TWBContainer.Create(fWebBrowser);
  UrlMkSetSessionOption(URLMON_OPTION_USERAGENT, PChar('Opera/9.80 (Windows NT 6.1; U; en) Presto/2.9.168 Version/11.52'),
                        Length('Opera/9.80 (Windows NT 6.1; U; en) Presto/2.9.168 Version/11.52'), 0);
  //  fWBContainer.OptionKeyPath:= 'Software\X-bot\Explorer';  // ��������� �������� � HKEY_CURRENT_USER
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
//  ���� �� ����� �������� ������, �� ����������� �� �� ����� � ����������
//   ����� NIL
var
  allForms: IHTMLElementCollection;
begin
  //  �������� ������?????
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
//  ����������� � ������� ��������
  Vill:=MyAccount.Derevni.VillById(MyAccount.IdCurrentVill);
// ��������� � ���� �� ���-�� � �������
  if Vill.BuildList <> '' then
  begin  // �� ������� �� ������ ������ �����!!!!!
    // ������� ��������� ��������� ������� �����
    Task_Work_Timer.Enabled:=false;


    Task_Build:=TTask_Build.Create;  // ������� ������ �������
    Task_Build.Task_type:=ttBuild;   // ������� ���� ��� ������
    Task_Build.Vill:=Vill;           // ������� �������
    Task_Build.BeginWork:=MyAccount.TravianTime + SecondsTime(2); // ������� ����� + 2 �������
    Task_Build.StopWork:=MyAccount.TravianTime + 1000;  // ������� ����� + ������� �������
    Task_Build.TimeCheck:=MyAccount.TravianTime + SecondsTime(3); // ������� ����� + 3 �������
    Task_Build.Status:=tsReady;
    Task_Build.Set_ACF_BuildList:=Set_ACF_BuildList;

    Task_queue.AddTask(Task_Build);
    // ������ ����� ��������� ��������� ������� �����
    Task_Work_Timer.Enabled:=true;
  end;
end;

procedure TAccount_Data.Start_farm;
var
  Vill: TVill;
  Task_Farm: TTask_Farm;
begin
  //  ����������� � ������� ��������
  Vill:=MyAccount.Derevni.VillById(MyAccount.IdCurrentVill);
  // ��������� � ���� �� ���-�� � �������
  if Vill.FarmLists.Count > 0 then
  begin  // �� ������� �� ������ ������ �����!!!!!
    // ������� ��������� ��������� ������� �����
    Task_Work_Timer.Enabled:=false;


    Task_Farm:=TTask_Farm.Create;  // ������� ������ �������
    Task_Farm.Task_type:=ttSendTroops;   // ������� ���� ��� ������
    Task_Farm.Vill:=Vill;           // ������� �������
    Task_Farm.BeginWork:=MyAccount.TravianTime + SecondsTime(2); // ������� ����� + 2 �������
    Task_Farm.StopWork:=MyAccount.TravianTime + 1000;  // ������� ����� + ������� �������
    Task_Farm.TimeCheck:=MyAccount.TravianTime + SecondsTime(3); // ������� ����� + 3 �������
    Task_Farm.Status:=tsReady;
    Task_Farm.FarmList := Vill.FarmLists;
    Task_queue.AddTask(Task_Farm);
    // ������ ����� ��������� ��������� ������� �����
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
//  ��������� ��������� ������� �������
var TaskNumber: integer;
  Task :TTask;
  r_TravianTime: TDateTime;

begin
  Task_Work_Timer.Enabled:=False;
  r_TravianTime := MyAccount.TravianTime;

  // ���� ���������
  for TaskNumber := 0 to Task_queue.Count - 1 do
  begin
    Task:=Task_queue.Task[TaskNumber];
    if Task.BeginWork <= r_TravianTime then   // ������� ����� ��� ����, ���� ��������
    begin
      if Task.TimeCheck <= r_TravianTime then
      begin  // ��������� �������
        if Task.Status in [tsReady, tsRun]  then
          Task.Execute(WBContainer,Log);
      end;
    end;

    if Task.StopWork < r_TravianTime then    // ������� ����� �������, ����������� ������ ��� �� ��������
      Task.Status:=tsDelete;
  end;

  // ����� ���������� �� �������, � ����� �������� ����� �� �������� tsDelete
  Task_queue.sort;

  Task_Work_Timer.Enabled:=true;
end;

procedure TAccount_Data.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  fWBContainer.DocLoaded := true;
end;

end.
