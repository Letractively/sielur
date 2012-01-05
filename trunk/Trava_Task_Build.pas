unit Trava_Task_Build;

interface
uses Trava_class
   , MSHTML
   ,Classes
   , SysUtils
   ,Trava_My_Const
   , UContainer
  , U_Utilites
  ,Trava_Task
  ,x_bot_utl   ;


type
    TTask_Build=class(TTask)
    private
    fSet_ACF_BuildList: TSet_ACF_BuildList;
    //получаем следующее в очереди что надо строить
    function get_Next_Build: string;
    //получаем полный перечень елементов которые надо строить
    function GetBuildList: string;
    //задает лист строительства
    procedure SetBuildList(const Value: string);
    protected
    public
      constructor Create; override;
      property BuildList : string read GetBuildList write SetBuildList;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList); override;
      property Next_Build: string read get_Next_Build;
      property Set_ACF_BuildList: TSet_ACF_BuildList read fSet_ACF_BuildList write fSet_ACF_BuildList;
  end;

implementation

{ TTask_Build }

constructor TTask_Build.Create;
begin
  inherited;
  //указываем тип задачи
  Task_type := ttBuild;

end;

procedure TTask_Build.Execute(WBContainer: TWBContainer;   FLog: TStringList);
Var
  FID: string;
  GID: string;
  RC: TBuildReturn_Code;
  document : IHTMLDocument2;
begin
  inherited;

  if Status = tsRun then
  begin
    FLog.Add('Стройка закончена, переходим в режим ожидания');
    TimeCheck:=Vill.Account.TravianTime + SecondsTime(12);  // 12 секунд
    Status := tsReady;
    exit;
  end;

  if Next_Build = '' then
  begin
    FLog.Add('Очередь пустая.  Снимаем задачу');
    Status:=tsDelete;
    exit;
  end;

  // Перейдем на нужную деревню
  if Vill.Account.Derevni_Count > 1 then
  begin
    document:=WBContainer.HostedBrowser.Document as IHTMLDocument2;
    document := FindAndClickHref(WBContainer, document, '?newdid=' + Vill.NewDID, 4);
  end;


  FID:=copy(Next_Build,1,pos('-',Next_Build)-1);
  GID:=copy(Next_Build,pos('-',Next_Build)+1);

  if StrToInt(GID) <= 5 then
    RC:=Vill.build_field(WBContainer,FId,Gid,Flog)
  else
    RC:=Vill.build_center(WBContainer,FId,Gid,Flog);

  if RC.Return_Code = -1 then // Фигня какаято отметим задание на удаление
  begin
    FLog.Add('Надо разобраться Фигня какаято отметим задание на удаление');
    Status:=tsDelete;
  end;

  if RC.Return_Code = 1 then // Достигли максимального уровня
  begin
    FLog.Add('Достигли максимального уровня  отметим задание на удаление');
    Status:=tsDelete;
  end;

  if RC.Return_Code = 2 then  // Чего то не хватило  Сдвинем задание
  Begin
    FLog.Add('Чегото не хватило  Сдвинем задание');
    TimeCheck:=Vill.Account.TravianTime + SecondsTime(rc.Wait+4)   // +4 секунды к времени ожидания
  End;

  if RC.Return_Code = 3 then  // Не хватает производства кропа
  Begin
    FLog.Add('Не хватает производства кропа. Сдвинем задание на ДООООЛГО');
    TimeCheck:=Vill.Account.TravianTime + SecondsTime(rc.Wait+4)   // +4 секунды к времени ожидания
  End;

  if RC.Return_Code = 4 then  //  Вроде всё в порядке но стройка недоступна !!!!!!
  Begin
    FLog.Add(' Вроде всё в порядке но стройка недоступна !!!!!!. Сдвинем задание на ДООООЛГО');
    TimeCheck:=Vill.Account.TravianTime + SecondsTime(rc.Wait+4)   // +4 секунды к времени ожидания
  End;

  if RC.Return_Code = 0 then  // Все в порядке запустилось
  begin
    FLog.Add('Стройку запустили, переходим в режим "выполнения"');
    // Надо удалить то что мы строим из очереди
    // Потом сделаем нормально!!!
    BuildList:=copy(vill.BuildList,1,pos(Next_Build,vill.BuildList)-1)+
                    copy(vill.BuildList,pos(Next_Build,vill.BuildList)+length(Next_Build)+1);
    Status:=tsRun;
    TimeCheck:=Vill.Account.TravianTime + SecondsTime(rc.Duration+4);  // +4-ре секунды к ожидаемому времени окончания
  end;



end;


function TTask_Build.GetBuildList: string;
begin
  Result:=Vill.BuildList;
end;

function TTask_Build.get_Next_Build: string;
begin
 result:=copy(BuildList,1,pos(';',BuildList)-1);
// BuildList:=copy(BuildList,1,pos(';',BuildList)+1);
end;


procedure TTask_Build.SetBuildList(const Value: string);
begin
  Vill.BuildList:=Value;

  if vill.ID = Vill.Account.IdCurrentVill then
    if Assigned(Set_ACF_BuildList) then Set_ACF_BuildList(Value);
end;

end.
