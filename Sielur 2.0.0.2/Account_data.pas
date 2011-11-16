unit Account_data;

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
  public
    constructor Create(AOwner:TComponent);
    function is_login_page(document: IHTMLDocument2): IHTMLFormElement;
    function Account_login(LoginForm: IHTMLFormElement): boolean;

    function Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode): boolean;
    procedure prepare_profile(document: IHTMLDocument2);
    procedure prepare_Vlist(Table_IHTML: IHTMLTable);
    function get_race_from_Karte(document: IHTMLDocument2): integer;

    function FindAndClickHref(document: IHTMLDocument2; SubHref:string;TypeSubHref:integer): IHTMLDocument2;

    procedure set_AccountNode_StateIndex;
    property WebBrowser: TWebBrowser read fWebBrowser write fWebBrowser;
    property WBContainer: TWBContainer read fWBContainer write fWBContainer;
    property MyAccount: TAccount read fMyAccount write fMyAccount;
    property AccountNode:TTreeNode read fAccountNode write fAccountNode;
    property Accounts_TreeView:TRzTreeView read fAccounts_TreeView write fAccounts_TreeView;
end;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    NodeType: integer;  // -1  - ������
                        // -2  - Account
                        // -3  - Village
    Status: Boolean;    // ������ ��� Account
                        //  True  - Login
                        //  False - Logout
    ID:    string;      // UID - ��� Account
                        // ID - ��� Village
    Account_Data:TAccount_Data;
    FData: string;      // - ������  (NodeType=-1)
                        // - ������  (NodeType=-2)
  end;

function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: String;NodeType: integer): TTreeNode;

implementation

function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: String; NodeType: integer): TTreeNode;
var
  t: integer;
begin
  Result:=nil;

  IF not Assigned(Node) then
  Begin  // ����� ��� � �����
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
  End  // ����� ��� � �����
  Else begin
    For t:=0 to Node.Count - 1 Do
    Begin
      IF (Node[t].Text = NodeName) and (PNodeData(Node[t].Data)^.NodeType = NodeType) then
       Begin
         Result:=Node[t];
         Break;
       End;
     End; // ����� � �����
  end;
end;



{ TAccount_Data }

function TAccount_Data.Account_login(LoginForm: IHTMLFormElement): boolean;
var
  ItemNumber: integer;
  field: IHTMLElement;
  input_field: IHTMLInputElement;
  Count_input_field: integer;
begin
// �����

  Result:=false;
  Count_input_field:=0;
  if Assigned(LoginForm) then
  begin
    for ItemNumber := 0 to LoginForm.Length - 1 do
    begin
      field := LoginForm.Item(ItemNumber,'') as IHTMLElement;
      if Assigned(field) then
      begin
        if field.tagName = 'INPUT' then
        begin
          input_field:=field as IHTMLInputElement;
          if input_field.Name = 'name' then
          begin
            input_field.Value := MyAccount.Login;
            Count_input_field:=Count_input_field+1;
          end;
          if input_field.Name = 'password' then
          begin
            input_field.Value := MyAccount.Password;
            Count_input_field:=Count_input_field+1;
          end;
        end;
      end;
    end;

    if Count_input_field <> 2 then exit;

    fWBContainer.MyFormSubmit(LoginForm);

    Result:=(is_login_page(fWBContainer.HostedBrowser.Document as IHTMLDocument2) = nil);
  end;

end;

function TAccount_Data.Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode): boolean;
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
begin
  //  ��������� �� ����� ��� ���-�� ���� ����� ������� ��������� ���������
  //  1. Assigned(aAccounts_TreeView)
  //        �.�. ���������� ������ ����
  //  2. (PNodeData(aAccountNode.Data)^.NodeType = -2) and (not PNodeData(aAccountNode.Data)^.Status)
  //        �.�. ��� Account � �� �� ���������
  //  -----------------------------------------------

  Result:=False;

  Server_Name:='';
  User_Name:='';
  Password_Name:='';

  fAccounts_TreeView:=aAccounts_TreeView;
  fAccountNode:=aAccountNode;
  User_Name:=AccountNode.Text;
  Password_Name:=PNodeData(AccountNode.Data)^.FData;
      // � ������ ������
  ServerNode:=AccountNode.Parent;   // ���� �������
      // �������� ���-��!!!
  if (PNodeData(ServerNode.Data)^.NodeType = -1) then
  begin
    Server_Name:=ServerNode.Text;
  end;

  if (Server_Name <> '') and (User_Name <> '') and (Password_Name <> '') then
  begin
    MyAccount.Connection_String:='http://'+Server_Name;
    MyAccount.Login:=User_Name;
    MyAccount.Password:=Password_Name;

    Result:=True;
    WBContainer.MyNavigate(MyAccount.Connection_String);
    SndForm:=is_login_page(WBContainer.HostedBrowser.Document as IHTMLDocument2);
    if Assigned(SndForm) then
    begin
      if not Account_login(SndForm) then
      begin // ������ ��� ������
        Result:=False;
      end
      else begin
        // ����� ����������!
        // �������� �� �������� �������!
//        Document:=get_profile_document(WBContainer.HostedBrowser.Document as IHTMLDocument2);
        Document:=FindAndClickHref(WBContainer.HostedBrowser.Document as IHTMLDocument2,MyAccount.Connection_String+'/spieler.php?',2);

        if Document <> nil then
          prepare_profile(Document);
        if MyAccount.Race = 0 then
        begin  // ���� � ������� ���������� �� ������! ����� � ���������� ���-�� �����!
          MyAccount.Race:=get_race_from_Karte(Document);
        end;  // MyAccount.Race = 0
      end; // not Account_login(SndForm)
    end;   // Assigned(SndForm)

    PNodeData(AccountNode.Data)^.Status:=Result;
    if Result then
    begin  // ����� ����������!
      set_AccountNode_StateIndex;
      PNodeData(AccountNode.Data)^.ID:=MyAccount.UID;
      PNodeData(AccountNode.Data)^.Account_Data:=self;   // !!!!! ������ ���� !!!!!

      // ������� ������ ��������
      for t := 0 to MyAccount.Derevni_Count-1 do
      begin
        Tmp_VillName:=MyAccount.Derevni.Items[t].Name+' '+MyAccount.Derevni.Items[t].coord;
        VillNode:=find_node(Accounts_TreeView,AccountNode,Tmp_VillName,-3);
        if not Assigned(VillNode) then
        begin // ������� �� ����� --> ������� �
              // ��������� �������� �� ��������� � AccountNode ����,
              // � �������� ������ ���. Tmp_VillName
          New(NodeDataPtr);
          NodeDataPtr^.NodeType:=-3;
          NodeDataPtr^.Status:=False;
          NodeDataPtr^.ID:=IntToStr(MyAccount.Derevni.Items[t].ID);
          NodeDataPtr^.FData:=MyAccount.Derevni.Items[t].Name;
          NodeDataPtr^.Account_Data:=self;   // !!!!! ������ ���� !!!!!
          VillNode:=Accounts_TreeView.Items.AddChildObject(AccountNode, Tmp_VillName, NodeDataPtr);
        end;
      end;  // for t := 0 to MyAccount.Derevni_Count-1
      // ��� � ������������� �������� ���������
      // ������ ���� �������� �� ���� �������� � �������� �� ������
      // � ����� ��� ������ � ��������� �����, ���� ����� �� � � ����������
      // ������ ������ ��������� ��� ������ ����!!!!
      for t := 0 to MyAccount.Derevni_Count-1 do
      begin
        // ������������ �� ������ �������
        // �� � ���� ��������� ���� �� �� �� �� ����� ����� �� ���!!!
        if MyAccount.Derevni_Count > 1 then
          document:=FindAndClickHref(document,'?newdid='+MyAccount.Derevni.Items[t].NewDID,4);
        if Assigned(document) then
        begin  // �������� ������������!
           MyAccount.IdCurrentVill:=MyAccount.Derevni.Items[t].ID;
          // ��������� ��� �� �����
          // ���� �� �� dorf1 ��� 2 �� ������������� �� dorf1
          url:=document.url;
          if (copy(url,length(url)-4) <> 'dorf1') and (copy(url,length(url)-4) <> 'dorf2') then // ������������ �� dorf1
            document:=FindAndClickHref(document,MyAccount.Connection_String+'/dorf1.php',1);

          for I := 1 to 2 do
          begin
            url:=document.url;
            if (copy(url,length(url)-8) = 'dorf1.php') then
            begin
              MyAccount.Derevni.Items[t].prepare_dorf1(document);
              next_dorf:='dorf2.php'
            end
            else begin
              if (copy(url,length(url)-8) = 'dorf2.php') then
              begin
                MyAccount.Derevni.Items[t].prepare_dorf2(document);
                MyAccount.Derevni.Items[t].SetGidForId40(30+MyAccount.race);  // ��� ������!!!!

                next_dorf:='dorf1.php'
              end
              else begin
                // ���������� ������
              end;
            end;
            document:=FindAndClickHref(document,MyAccount.Connection_String+'/'+next_dorf,1);
          end;  // for I
        end;    // if Assigned(document)
      end;      // for t
    end;   // if Result then  ����� ����������!

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

  // �������� ����������
  fWBContainer := TWBContainer.Create(fWebBrowser);
//  fWBContainer.OptionKeyPath:= 'Software\X-bot\Explorer';  // ��������� �������� � HKEY_CURRENT_USER
//  fWBContainer.UseCustomCtxMenu := True;    // use our popup menu
//  fWBContainer.Show3DBorder := False;       // no border
//  fWBContainer.ShowScrollBars := False;     // no scroll bars
//  fWBContainer.AllowTextSelection := False; // no text selection (**)

end;

function TAccount_Data.FindAndClickHref(document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;
// TypeSubHref
//     1 - ����� ������ ��������� ������ � SubHref
//     2 - ������ ������ ���������� � SubHref
//     3 - ������ ������ ��������� SubHref
//     4 - ������ ������ ������������� SubHref
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
    begin
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
      begin // ������� ����� ��������� ������
        WBContainer.MyElementClick(href_field);
        Result:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
        exit;
      end;
    end;
  end;
end;

function TAccount_Data.get_race_from_Karte(document: IHTMLDocument2): integer;
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
  // ������� ������ ������ �� ����� � ������� �� ���
  // ���� ������� �� �������� �����
  if Assigned(document) then
  begin
    All_Links:=document.links;
    for ItemNumber := 0 to All_Links.Length - 1 do
    begin
      href_field := All_Links.item(ItemNumber,'') as IHTMLElement;
      url:=href_field.toString;
      if url = (MyAccount.Connection_String+'/karte.php') then
      begin // ������� ����� ������ �� �����
        WBContainer.MyElementClick(href_field);
        Karte_document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
        break;
      end;
    end;
  end;

  if Assigned(Karte_document) then
  begin  // ���� ����� �� ��������, ������ ��������� � ��� �����������
    field_Element:=(document as IHTMLDocument3).getElementById('a_3_3');  // ����� �����
    url:=field_Element.toString;   // ������ �� ���������
    url:=copy(url,pos('?',url)+1);     // ������ ��� �������

    field_Element:=(document as IHTMLDocument3).getElementById('map');  // ������ ��� ����� ������ ������
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
    begin  // ������ ��� ������ �� ���� ������� ����
           // �� �������� �� �����������������
           // ��� ����� ����� ����� � �� ��� �������!
      tmp_txt:=field_Element.innerHTML;
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // ��������� ������ ������ �����
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // ��������� ������ ������ �����
      tmp_txt:=copy(tmp_txt,pos(']]',tmp_txt)+3);   // ��������� ������ ������ �����
      tmp_txt:=copy(tmp_txt,1,pos(']]',tmp_txt)+1);   // ����� 4-� ������
           // �������� � 4-� �������
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // ��������� ������ ������� �����
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // ��������� ������ ������� �����
      tmp_txt:=copy(tmp_txt,pos(']',tmp_txt)+2);   // ��������� ������ ������� �����
      tmp_txt:=copy(tmp_txt,1,pos(']',tmp_txt));   // ����� 4-� �������
           // � ������ ����� �� ��� ��� �����
           // [X,Y,?,?,"URL","?","������������_�������","�����","���������","?",����]
           //  ���� = 1 - ���  2 - ������   3 - ����
      Race_String:=copy(tmp_txt,length(tmp_txt)-1,1);
      Result:=StrToInt(Race_String);
    end;
  end;  // if Assigned(Karte_document)
end;

function TAccount_Data.is_login_page(document: IHTMLDocument2): IHTMLFormElement;
var
  allForms: IHTMLElementCollection;
begin
  //  �������� ������?????
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
var
  ItemNumber: integer;
  field_Element: IHTMLElement;
  Table_IHTML: IHTMLTable;
  All_Tables: IHTMLElementCollection;
  irow,icol:integer;
  Row_IHTML: IHTMLTableRow;
  Cell_IHTML:IHTMLTableCell;
  Cell_Element: IHTMLElement;
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

  Is_Capital:=False;
  sw:=false;

  if MyAccount.UID = '' then  // ���� ����������� �� UID ������� �� URL
    MyAccount.UID:=copy(document.url,length(MyAccount.Connection_String+'/spieler.php?uid=')+1);

  if MyAccount.Race = 0 then
  begin // ���� ������������ ���������� � ����������
      //  ������� ���� �� ������ ID �������� (id="qgei") -
      //       class="q_l1" - �������
      //       class="q_l2" - ��������
      //       class="q_l3" - �����

    field_Element:=(document as IHTMLDocument3).getElementById('qgei');
    if Assigned(field_Element) then
    begin
      Tmp_ClassName:=field_Element.className;
      if pos('l1',Tmp_ClassName) > 0 then MyAccount.Race:=1//�������
      else if pos('l2',Tmp_ClassName) > 0 then MyAccount.Race:=2//��������
      else if pos('l3',Tmp_ClassName) > 0 then MyAccount.Race:=3;//�����
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
        Current_Vill:=MyAccount.Derevni.CheckAndAdd_Vill_By_Coord(V_Coord);
        Current_Vill.Name:=V_Name;
        Current_Vill.Nas:=StrToInt(V_Nas);
        Current_Vill.Is_Capital:=Is_Capital;
        Current_Vill.set_coord(V_Coord);
        Current_Vill.Karte_Link:=copy(url,pos('?',url)+1);
      end;  // for irow
    end;   // if field_Element.id = 'villages' ��� ������ ���������!!!!
    if field_Element.id = 'vlist' then
      prepare_Vlist(field_Element as IHTMLTable);
  end;  // for ItemNumber ....
end;

procedure TAccount_Data.prepare_Vlist(Table_IHTML: IHTMLTable);
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
