unit Trava_Task_Farm;

interface
Uses
   Trava_Task_Farm_Item
  ,Trava_Task
  ,MSHTML
  ,UContainer
  ,Classes
  ,Trava_My_Const
  ,U_Utilites
  ;
Type
    TTask_Farm=class(TTask)
    private
      FFarmList: TFarmList;
      //получаем указатель на фарм лист деревни в AFarmList
      procedure GetFarmList(var AFarmList: TFarmList);
    protected
    public
      constructor Create; override;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList); override;
      //property Next_Build: string read get_Next_Build;
      //property Set_ACF_BuildList: TSet_ACF_BuildList read fSet_ACF_BuildList write fSet_ACF_BuildList;
      //сюда передаем указатель на фарм лист деревни
      //при изменениее фарм листа не безпокоимс€ про измениее задч на фарм .. как то так
      property FarmList: TFarmList read FFarmList write FFarmList;
    end;


implementation

{ TTask_Farm }

constructor TTask_Farm.Create;
begin
  inherited;
  Task_type := ttSendTroops;
  //загрузили фарм лист
  //GetFarmList(FFarmList);
end;

procedure TTask_Farm.Execute(WBContainer: TWBContainer; FLog: TStringList);
var
    document : IHTMLDocument2;
    FRC: TFarmReturn_Code;
    FarmItem: TFarmItem;
begin
  inherited;
  if Status = tsRun then
  // » тут начинаетьс€ творчечтво ...
  // ≈сли фарм активен .. то должны вз€ть елемент списка фарма , гл€нуть врем€
  //когда его надо выполнить и соотвецтвенно или выполнить или вз€ть следующий елемент...
  begin
    FLog.Add('‘арм активный выбираем следующий елемент дл€ отправки');
    // ѕерейдем на нужную деревню
    if Vill.Account.Derevni_Count > 1 then
    begin
      document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
      document := FindAndClickHref(WBContainer, document, '?newdid=' + Vill.NewDID, 4);
    end;
  end;
  FarmItem := Vill.FarmLists.GetItemById(1) as TFarmItem;
  FRC := Vill.Send_Troop(WBContainer, FarmItem, FLog);
end;

procedure TTask_Farm.GetFarmList(var AFarmList: TFarmList);
begin
  if Assigned(Vill.FarmLists) then
    AFarmList := Vill.FarmLists;
end;

end.

