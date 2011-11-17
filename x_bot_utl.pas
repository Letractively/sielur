unit x_bot_utl;

interface

uses
  RzTreeVw
 ,ComCtrls
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, ExtCtrls, Menus, StdCtrls, RzPanel, IniFiles, RzTabs,
//  RzCommon, RzSplit, OleCtrls, SHDocVw,
//  UContainer, Account_data, Add_User_Form,
//  mshtml, MyIniFile, Account_Frame,Trava_Class, , ActnList ;
     ;
{
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
                        // NewDid - для Village
    Account_Data:TAccount_Data;
    FData: string;
  end;
}
//function find_node(Tree: TRzTreeView; Node: TTreeNode; NodeName: String;NodeType: integer): TTreeNode;

implementation
{
function find_node(Tree: TRzTreeView; Node: TTreeNode;
  NodeName: String; NodeType: integer): TTreeNode;
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
  Else begin
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
}
end.
