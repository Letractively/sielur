unit x_bot_MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ComCtrls, StdCtrls, RzPanel, IniFiles, RzTabs,
  RzCommon, RzSplit, OleCtrls, SHDocVw,
  UContainer, Account_data, Add_User_Form,x_bot_utl,
  mshtml, MyIniFile, Account_Frame,Trava_Class, RzTreeVw, ActnList, ImgList ;


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
    // ��� ����� ������� ��� ��� ������ � �����, ��� ���������:)
    property Log: TStringList read FLog write FLog;
  end;



var
  MainForm: TMainForm;
  App_Dir: string;
  App_Name: string;
  App_Ext: string;

  ACF:TAccount_Form;

  CurrentAccount:TAccount_Data;

implementation
uses TypInfo;

{$R *.dfm}




procedure TMainForm.Login1Click(Sender: TObject);
begin
  Login_Account;
end;

procedure TMainForm.Login_Account;
var
    AccountNode: TTreeNode;
    Account_Data:TAccount_Data;
begin
  if Assigned(Acf) then
  begin
    // �� ������ ������ ��������
    if Accounts_TreeView.Items.Count > 0 then
    begin
      AccountNode:=Accounts_TreeView.Selected;
      if (PNodeData(AccountNode.Data)^.NodeType = -2) and (not PNodeData(AccountNode.Data)^.Status) then
      begin  // ��� Account � �� �� ���������
        FLog.Add('��������� TAccount_Data.Create(ACF.Browser_RzPanel)');
        Account_Data:=TAccount_Data.Create(ACF.Browser_RzPanel);
        ACF.RzPageControl1.ActivePageIndex:=13;
        FLog.Add('�������� ����� Account_Data.Bot_Start_Work(Accounts_TreeView,AccountNode);');
        Account_Data.Bot_Start_Work(Accounts_TreeView,AccountNode, FLog);
        ACF.Account_data:=Account_Data;
      end;
    end;
  end;
  FLog.Add('�������� FLog.Add( � procedure TMainForm.Login_Account; � ���������� � ����');
  FLog.SaveToFile('C:\AdskiyLog.txt');
end;

procedure TMainForm.Accounts_TreeViewChange(Sender: TObject; Node: TTreeNode);
//var
//    Account_Data:TAccount_Data;
begin
  if Assigned(Acf) then
  begin
    // �� ������ ������ ��������
    if Accounts_TreeView.Items.Count <= 0 then ACF.Account_data:=nil
    else begin
      if (PNodeData(Node.Data)^.NodeType = -3) then // �������
        PNodeData(Node.Data)^.Account_Data.MyAccount.IdCurrentVill:=StrToInt(PNodeData(Node.Data)^.ID);
      if  (PNodeData(Node.Data)^.NodeType = -3) or ((PNodeData(Node.Data)^.NodeType = -2) and  PNodeData(Node.Data)^.Status) then
        ACF.Account_data:=PNodeData(Node.Data)^.Account_Data  // ��� Account � �� ���������
      else
        ACF.Account_data:=nil;
    end;
  end;
end;

procedure TMainForm.Accounts_TreeViewNodeContextMenu(aSender: TObject;
  aNode: TTreeNode; var aPos: TPoint; var aMenu: TPopupMenu);
var
    NodeType: integer;
    Status: Boolean;
begin

  NodeType:=-1;
  Status:=False;
  if Assigned(aNode) then
  begin
    Accounts_TreeView.selected:=aNode;
    NodeType:=PNodeData(aNode.Data)^.NodeType;
    Status:=PNodeData(aNode.Data)^.Status;
  end;


  // �� � ������ ����� ����������� ��� ��������� � ��� ���������
  // NodeType = -1 - ������
  //      Add_User    +
  //      Login       -
  //      Logout      -
  //      Delete_User -
  // NodeType = -2 - Account
  //      Add_User    +
  //      Login       + ���� Status = False (����� ������� ��������� Logout)
  //      Logout      + ���� Status = True (����� ������� ��������� Login)
  //      Delete_User + ���� Status = False (����� ������� ��������� Logout)

  // NodeType = -3 - Village
  //      Add_User    +
  //      Logi       -
  //      Logout      +
  //      Delete_User -

  aMenu.Items[0].Enabled:=True;
  aMenu.Items[1].Enabled:=((NodeType = -2) and not Status);
  aMenu.Items[2].Enabled:=(NodeType = -3) or ((NodeType = -2) and Status);
  aMenu.Items[3].Enabled:=((NodeType = -2) and not Status);
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
    Server_Name: String;
    User_Name: String;
    Password_Name: String;
    NodeDataPtr: PNodeData;
begin
  // ������� ���������� ���-�� ��� �������� � Server_name
  Add_New_User.Server_Name.Text:='';
  if Accounts_TreeView.Items.Count > 0 then
  begin
    Tmp_Node:=Accounts_TreeView.Selected;
    // ���� ��������� �� �����
    while Tmp_Node.Parent <> nil do
      Tmp_Node := Tmp_Node.Parent;

    // �� ������ ������ ��������
    if PNodeData(Tmp_Node.Data)^.NodeType = -1 then
      Add_New_User.Server_Name.Text:=PNodeData(Tmp_Node.Data)^.FData;
  end;

  Add_New_User.User_Name.Text:='';
  Add_New_User.Password_Name.Text:='';


  if Add_New_User.ShowModal = mrOk then
  begin
    Server_Name:=Add_New_User.Server_Name.Text;
    User_Name:=Add_New_User.User_Name.Text;
    Password_Name:=Add_New_User.Password_Name.Text;

    // ������� ������ � ������
         // ������ � ������ �������� ������
    ServerNode:=find_node(Accounts_TreeView,nil,Server_Name,-1);
    if not Assigned(ServerNode) then  // ������ �� ����� --> ������� ���
    begin
      New(NodeDataPtr);
      NodeDataPtr^.NodeType:=-1;
      NodeDataPtr^.Status:=False;
      NodeDataPtr^.ID:='';
      NodeDataPtr^.FData:=Server_Name;
      ServerNode:=Accounts_TreeView.Items.AddObject(nil,Server_Name, NodeDataPtr);
    end;

    // ������� Account � ������
    AccountNode:=find_node(Accounts_TreeView,ServerNode,User_Name,-2);
    if not Assigned(AccountNode) then
     begin // Account �� ����� --> ������� ���
        // ��������� �������� �� ��������� � ServerNode ����,
        // � �������� ������ ���. User_Name
      New(NodeDataPtr);
      NodeDataPtr^.NodeType:=-2;
      NodeDataPtr^.Status:=False;
      NodeDataPtr^.ID:='';
//      NodeDataPtr^.FData:=Password_Name;
      AccountNode:=Accounts_TreeView.Items.AddChildObject(ServerNode, User_Name, NodeDataPtr);
    end;
      // ������ ������ ������ ���� ��� ��� �� ���������
      // ���� �� ��� ��������� �� ������ �� ������
    if not PNodeData(AccountNode.Data)^.Status then
      PNodeData(AccountNode.Data)^.FData:=Password_Name;

    AccountNode.Selected:=True;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
    ff: Textfile;
    str: string;
    script:string;

IDoc1: IHTMLDocument2;
  win: IHTMLWindow2;
  Olelanguage: Olevariant;
  language: string;
begin
{
//  Execute Js Scripr
  AssignFile(ff,'D:\razrabotka\x_bot\Scr.js');
  Reset(ff);
  script:='';
  while not EOF(ff) do
  begin
    readln(ff,str);
    script:=script+str+#13;
  end;
  CloseFile(ff);

  language:='JavaScript';
 IDoc1:=Account_Data.WebBrowser.Document as IHTMLDocument2;
  if idoc1 <> nil then
  begin
    try
      win := idoc1.parentWindow;
      if win <> nil then
      begin
        try
          Olelanguage := language;
          win.ExecScript(script, Olelanguage);
        finally
          win := nil;
        end;
      end;
    finally
      idoc1 := nil;
    end;
  end;
}
end;


procedure TMainForm.Delete_Account;
var
    Tmp_Node: TTreeNode;
begin
    // �� ������ ������ ��������
  if Accounts_TreeView.Items.Count > 0 then
  begin
    Tmp_Node:=Accounts_TreeView.Selected;
    if (PNodeData(Tmp_Node.Data)^.NodeType = -2) and
       (not PNodeData(Tmp_Node.Data)^.Status )
    then
      Tmp_Node.Delete;
  end;
end;

procedure TMainForm.Delete_Account_MenuItemClick(Sender: TObject);
begin
  Delete_Account;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Save_control;          // �������� ��������� �����
  Save_Accounts_Tree;    // �������� ��������� ����
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FLog := TStringList.Create;
  App_Dir:=ExtractFilePath(Application.ExeName);
  App_Ext:=ExtractFileExt(Application.ExeName);
  App_Name:=ExtractFileName(Application.ExeName);
  App_Name:=copy(App_Name,1,length(App_Name)-length(App_ext));

  Load_Control;             // �������� ��������� �����
  Load_Accounts_Tree;       // �������� ��������� ����

  Acf:=TAccount_Form.Create(self);
  Acf.Parent:=Account_Panel;
  Acf.Align:=alClient;

end;





procedure TMainForm.Load_Accounts_Tree;
var
  Ini: TMyIniFile;

  LS, LV: TStrings;
  t,r: integer;

  ServerNode: TTreeNode;
  AccountNode: TTreeNode;
  Server_Name: String;
  User_Name: String;
  Password_Name: String;
  NodeDataPtr: PNodeData;
begin
  Accounts_TreeView.Items.Clear;
  Ini := TMyIniFile.Create(App_Dir+App_Name+'_Connect'+'.INI');
  try
    LS := TStringList.Create;  // ������ �������� ������
    try
      ini.ReadSections(LS);      // ������ ��� ������ � ������ (�� ����� ���� ��� ���� �������)
      LV := TStringList.Create;   // ������ ��� "���=��������"
      try
        for t := 0 to LS.Count-1 do   // ��� ���� ������...
        begin
          Server_Name:=LS[t];
                      // ��������� �������� ���� (��� �������)
          New(NodeDataPtr);
          NodeDataPtr^.NodeType:=-1;
          NodeDataPtr^.Status:=False;
          NodeDataPtr^.ID:='';
          NodeDataPtr^.FData:=Server_Name;
          ServerNode:=Accounts_TreeView.Items.AddObject(nil,Server_Name, NodeDataPtr);

          LV.Clear;                   // ���������� ������
          ini.ReadSection(Server_Name, LV);  // ������ ������ ������ (����) ������� ������
                                             // ���������� �� ����� ��� �� ����� ��� ����
                                             //   'User_Name#nnn'
                                             //   'Password_Name#nnn'
                                             // ��� nnn - ����� ����
                                             //           ������ ��������� ��� ���������� � ���� � ����
                                             // � ������� �� ������� �����
          for r := 0 to (LV.Count div 2)-1 do // ��� ���� ������
          begin
            User_Name:=ini.ReadUTF8(Server_Name,'User_Name#'+IntToStr(r),'');
            Password_Name:=ini.ReadUTF8(Server_Name,'Password_Name#'+IntToStr(r),'');
               // ��������� �������� �� ��������� � ServerNode ����,
               // � �������� ������ ���. User_Name
            New(NodeDataPtr);
            NodeDataPtr^.NodeType:=-2;
            NodeDataPtr^.Status:=False;
            NodeDataPtr^.ID:='';
            NodeDataPtr^.FData:=Password_Name;
            AccountNode:=Accounts_TreeView.Items.AddChildObject(ServerNode, User_Name, NodeDataPtr);
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
    VList_Align.Checked:=ini.ReadBool('View','VList_Align.Checked',VList_Align.Checked);
    L_panel.Width:=ini.ReadInteger('View','L_panel.Width',L_panel.Width);
    ini.LoadProperty('View', 'L_panel.Align', L_panel,'Align','alRight');
    Vill_List_Panel.Height:=ini.ReadInteger('View','Vill_List_Panel.Height',Vill_List_Panel.Height);
  finally
    Ini.Free;
  end;


end;


procedure TMainForm.Save_Accounts_Tree;
var
  Ini: TMyIniFile;
  ServerNode: TTreeNode;

  Server_Name: String;
  User_Name: String;
  Password_Name: String;
  t: integer;
begin
  DeleteFile(App_Dir+App_Name+'_Connect'+'.INI');
  Ini := TMyIniFile.Create(App_Dir+App_Name+'_Connect'+'.INI');
  try
    ServerNode:=Accounts_TreeView.Items.GetFirstNode;
    While Assigned(ServerNode)
    Do Begin
      IF (PNodeData(ServerNode.Data)^.NodeType = -1) then  // ������
      Begin  // ��� ������!!!
        Server_Name:=PNodeData(ServerNode.Data)^.FData;

        For t:=0 to ServerNode.Count - 1 Do
        Begin
          IF (PNodeData(ServerNode[t].Data)^.NodeType = -2) then
          Begin // Account
            User_Name:=ServerNode[t].Text;
            Password_Name:=PNodeData(ServerNode[t].Data)^.FData;
            ini.WriteUTF8(Server_Name,'User_Name#'+IntToStr(t),User_Name);
            ini.WriteUTF8(Server_Name,'Password_Name#'+IntToStr(t),Password_Name);
//            ini.WriteString(Server_Name,'User_Name#'+IntToStr(t),User_Name);
//            ini.WriteString(Server_Name,'Password_Name#'+IntToStr(t),Password_Name);
          End; // Account
        end;  // FOR
      End;  // ��� ������!!!
      ServerNode:=ServerNode.GetNextSibling;
    End;  // While
  finally
    Ini.Free;
  end;
end;

procedure TMainForm.Save_control;
var
  Ini: TMyIniFile;
begin

  Ini := TMyIniFile.Create(App_Dir+App_Name+'.INI');
  try
    ini.WriteBool('View','VList_Align.Checked',VList_Align.Checked);
    ini.WriteInteger('View','L_panel.Width',L_panel.Width);
    ini.WriteProperty('View', 'L_panel.Align', L_panel,'Align');
    ini.WriteInteger('View','Vill_List_Panel.Height',Vill_List_Panel.Height);
  finally
    Ini.Free;
  end;


end;

procedure TMainForm.Set_VList_Align(value: boolean);
begin
  if Value then
    L_Panel.Align:=alLeft
  else
    L_Panel.Align:=alRight;
end;


procedure TMainForm.VList_AlignClick(Sender: TObject);
begin
  VList_Align.Checked:=not VList_Align.Checked;
  Set_VList_Align(VList_Align.Checked);

end;





end.