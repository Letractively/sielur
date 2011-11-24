unit Account_data;

// ������ �� ���
//   ��� ��� ����� ������� ��� �� ��� �������� ����
//   ������� �� ����� � ����  � ���������� �������

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
      ,Windows
      ,Variants
      ,UPrePare_Profile ;

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
    //����� ��� �4 � �3.6 ������ ��������
    function is_login_page(document: IHTMLDocument2): IHTMLFormElement;   // �������� �������� �� �������� �����
    function Account_login(LoginForm: IHTMLFormElement): boolean;         //  �����
    function Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode; ALog: TStringList): boolean;  // ������ ���� ��� ����� � ���� �3,6
    //��� ������ � �������� ��� ��������� � unit UPrePare_Profile;
    function get_race_from_KarteT36(document: IHTMLDocument2): integer;      // ��������� ���� �� �����

    function FindAndClickHref(document: IHTMLDocument2; SubHref:string;TypeSubHref:integer): IHTMLDocument2;   // �������� ������ ������������ - ����� ������ � �������� �� ���

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

function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: String;NodeType: integer): TTreeNode; // ����� ����

implementation

function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: String; NodeType: integer): TTreeNode;
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
  Else begin  // ����� ��� � �����
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
  Result:=false;
  Count_input_field:=0;
  if Assigned(LoginForm) then
  begin
    for ItemNumber := 0 to LoginForm.Length - 1 do
    begin  //  ����� �� ���� ��������� �����
      field := LoginForm.Item(ItemNumber,'') as IHTMLElement;
      if Assigned(field) then
      begin
        if field.tagName = 'INPUT' then
        begin  //  ���� �����
          input_field:=field as IHTMLInputElement;
          if input_field.Name = 'name' then
          begin
            input_field.Value := MyAccount.Login;    // ������ ���� ���
            Count_input_field:=Count_input_field+1;
          end; //  'name'
          if input_field.Name = 'password' then
          begin
            input_field.Value := MyAccount.Password; // ������ ���� ������
            Count_input_field:=Count_input_field+1;
          end;  // 'password'
        end;
      end; //  ���� �����
    end;   //  ����� �� ���� ��������� �����

    if Count_input_field <> 2 then
      begin
        FLog.Add('����� ������ 2 ����� ����� , ���� ����������');
        exit;  //  ���� � ����� �� ��� ���� �����  �� �� ���-�� ���-�� ���������
      end;
    FLog.Add('������ �� ������ ...');
    fWBContainer.MyFormSubmit(LoginForm); //   ������ �� ��������

    //  �������� ������������ ��� ���
    //     ���������� �������� �����
    //  ���� �� ���������� �������� ��� ����� ������ �� �� � �������
    Result:=(is_login_page(fWBContainer.HostedBrowser.Document as IHTMLDocument2) = nil);
    if Result then
      FLog.Add('������������!')
    else
      FLog.Add('����� �� ������ �����!!!');
  end;

end;

function TAccount_Data.Bot_Start_Work(aAccounts_TreeView:TRzTreeView; aAccountNode:TTreeNode; ALog: TStringList): boolean;
//      ������ ������ ���� � �������� ����
//  aAccounts_TreeView   - ������ �������-���-�������
//  aAccountNode         - ���� ��� � ������
//
//  ���������� ������ ����� � ������� �������� ��������� ���
//
var
  Server_Name  : string;
  User_Name    : string;
  Password_Name: string;
  ServerNode: TTreeNode;
  VillNode: TTreeNode;
  SndForm: IHTMLFormElement;
  Document: IHTMLDocument2;
  DocumentHTML: IHTMLDocument2; //����� ��� ���� ����������� title (�� Win XP)
  Tmp_VillName:String;
  NodeDataPtr: PNodeData;
  t: integer;
  url: string;
  i: integer;
  next_dorf: string;
  HTML: String; //��������� ���� �������� ��� ��������
  V_HTML: OleVariant; //���� ��� ���������  HTML � DocumentHTML
begin
  //  ��������� �� ����� ��� ���-�� ���� ����� ������� ��������� ���������
  //  1. Assigned(aAccounts_TreeView)
  //        �.�. ���������� ������ ����
  //  2. (PNodeData(aAccountNode.Data)^.NodeType = -2) and (not PNodeData(aAccountNode.Data)^.Status)
  //        �.�. ��� Account � �� �� ���������
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
    FLog.Add('������������ - ' + User_Name);
    FLog.Add('������� �� ������' + MyAccount.Connection_String);
    WBContainer.MyNavigate(MyAccount.Connection_String);   //   ��������� �������� ������
    //����� �������� �������� ������ ����� ���������� ������ ����
    if WB_GetHTMLCode(WBContainer, HTML) then
       if AnsiPos('Travian.Game.version = ''4.0''',HTML) <> 0 then
         begin
           MyAccount.IsT4Version := True;
           FLog.Add('������ ���� �4.0')
         end
       else
         begin
           MyAccount.IsT4Version := False; //��� �� �4 ��� ���� ���������
           FLog.Add('������ ���� �� �4.0');
         end;
    SndForm:=is_login_page(WBContainer.HostedBrowser.Document as IHTMLDocument2);  //  ������� �� �� ����� ������
    if Assigned(SndForm) then
    begin  //  ����� ������ ����������
      Result:=Account_login(SndForm);   //  ������� ������
      if Result then
      begin  // ����� ����������!
        // �������� �� �������� �������!
        FLog.Add('��������� �� �������� �������');
        Document:=FindAndClickHref(WBContainer.HostedBrowser.Document as IHTMLDocument2,MyAccount.Connection_String+'/spieler.php?',2);
        if Document <> nil then
        begin //  �������� ������� �� �������� �������
          FLog.Add('�������� ������� �� �������� �������.');
          //������ ���������� ���� ��� ��������� ���������� IHTMLDocument2
          //����� � ���� ������ �������� ��� �������� � ��� ���������� ������
          //� ��� ������ ��������� title �����������
          if MyAccount.IsT4Version then //���� � 4.0 ������ �� ����
          //������������� ������� ��������� ��������� � �� ... ���� �������
          begin
            WB_GetHTMLCode(WBContainer,HTML);
            V_HTML := VarArrayCreate([0, 0], varVariant);
            V_HTML[0] := HTML;
            DocumentHTML := coHTMLDocument.Create as IHTMLDocument2;;
            DocumentHTML.Write(PSafeArray(TVarData(V_HTML).VArray));
            prepare_profileT4(Document, DocumentHTML, MyAccount, Flog);  // ��������� �������
          end
          else
            begin
              prepare_profileT36(Document, MyAccount, FLog);  // ��������� �������
              if MyAccount.Race = 0 then  MyAccount.Race:=get_race_from_KarteT36(Document);  // ���� � ������� ���������� �� ������! ����� � ���������� ���-�� �����!
            end;
        end;
      end;  // ����� ����������!
    end;   // Assigned(SndForm)

    PNodeData(AccountNode.Data)^.Status:=Result;
    if Result then
    begin  // ����� ����������!
      set_AccountNode_StateIndex;  //  ��������� ������ �������� ��� ��� ����� �������� � ������
      PNodeData(AccountNode.Data)^.ID:=MyAccount.UID;
      PNodeData(AccountNode.Data)^.Account_Data:=self;   // !!!!! ������ ���� !!!!!

      // �������  � ������ ������ ��������
      for t := 0 to MyAccount.Derevni_Count-1 do
      begin  //   ���������� �� ���� ��������
        //  �������� ����� ���� �� ����� ������� ���� ������������ � �������� ��������������
        //  ������������ ������� ��� ����� �������������� ����� �������� ��������
        //  ������ �� ����� ������ �� ��������� ��� ��� ��������������� � �� ������
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
      begin // ���� �� ��������
        // ������������ �� ������ �������
        // �� � ���� ��������� ���� �� �� �� �� ����� ����� �� ���!!!
        if MyAccount.Derevni_Count > 1 then
          document:=FindAndClickHref(document,'?newdid='+MyAccount.Derevni.Items[t].NewDID + '&uid=' + MyAccount.UID,4);
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
              // ��� �4 ������ ������ ������ ��������� ������ ���� .
              if MyAccount.IsT4Version then
                 MyAccount.Derevni.Items[t].prepare_dorf1T4(document)
              else
                MyAccount.Derevni.Items[t].prepare_dorf1(document);  // ���������  dorf1
              next_dorf:='dorf2.php'
            end
            else begin
              if (copy(url,length(url)-8) = 'dorf2.php') then
              begin
                MyAccount.Derevni.Items[t].prepare_dorf2(document);  // ���������  dorf2
                MyAccount.Derevni.Items[t].SetGidForId40(30+MyAccount.race);  // ��� ������!!!!
                next_dorf:='dorf1.php'
              end
              else begin
                // ���������� ������
              end;
            end;
            document:=FindAndClickHref(document,MyAccount.Connection_String+'/'+next_dorf,1);
          end; // for I
        end;  // if Assigned(document)
      end;   // ���� �� ��������
    end;    // if Result then  ����� ����������!

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
//   ����� ������ � �������� �� ���

// TypeSubHref   - ����������� ������
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
    begin  // ���� �� ���� ������� ���������
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
    end;  // ���� �� ���� ������� ���������
  end;
end;

function TAccount_Data.get_race_from_KarteT36(document: IHTMLDocument2): integer;
// ����������� ���� �� �����

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
{   � ��� �� ���� ��������������� ������� � ������ ���� ������������ �
    ������ ������������ ��� �� ��������, ����� �������� ���� �������
    �������������� ���
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
}
    Karte_document:=FindAndClickHref(document,MyAccount.Connection_String+'/karte.php', 1);
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
           // ��� ����� ����� ����� � �� ��� �������!  ���� ������� :) �� ��������� �����...
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
//  ���� �� ����� �������� ������, �� ����������� �� �� ����� � ����������
//   ����� NIL
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
