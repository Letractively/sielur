unit Travian_Task_Farm;

interface
Uses
   Trava_Task_Farm_Item
  ,Trava_Task
  ,MSHTML
  ,UContainer
  ,Classes
  ,Trava_My_Const
  ;
Type
    TTask_Farm=class(TTask)
    private
      FFarmList: TFarmList;
      //получаем указатель на фарм лист деревни в AFarmList
      procedure GetFarmList(AFarmList: TFarmList);
    protected
    public
      constructor Create; override;
      //property FarmList : string read GetFarmList write GetFarmList;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList); override;
      //property Next_Build: string read get_Next_Build;
      //property Set_ACF_BuildList: TSet_ACF_BuildList read fSet_ACF_BuildList write fSet_ACF_BuildList;
    end;


implementation

{ TTask_Farm }

constructor TTask_Farm.Create;
begin
  inherited;
  Task_type := ttSendTroops;
end;

procedure TTask_Farm.Execute(WBContainer: TWBContainer; FLog: TStringList);
begin
  inherited;

end;

procedure TTask_Farm.GetFarmList(AFarmList: TFarmList);
begin
  if Assigned(Vill.FarmLists) then
    AFarmList := Vill.FarmLists;
end;

end.
