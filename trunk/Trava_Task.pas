unit Trava_Task;

interface

uses Trava_class
   , MSHTML
   ,Classes

   , UContainer
  , U_Utilites
   ;



type
  TTaskStatus=(tsUnknown, tsDelete, tsReady, tsRun, tsWaitAttack ); // Это так для примера, потом разберемся
              //  tsDelete     - Задание надо удалить
              //  tsReady      - Задание готово к выполнению и ожидает времени старта (TimeStart)
              //  tsRun        - Задание выполняется и ожидает времени окончания (TimeStop)
              //  tsWaitAttack - Задание ожидает события инициализации (Атаки)
              //
              //
              //

  TTask_type = (ttUnknown, ttBuild, ttSendRes);   // Тоже для примера, потом разберемся


  TTask=class
    private
//    fTimeStop: TDateTime;
    fTimeStart: TDateTime;
    fVill: TVill;
    fStatus: TTaskStatus;
    fTask_type: TTask_type;
    fStopWork: TDateTime;
    fBeginWork: TDateTime;

    protected

    public
      constructor Create; virtual;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList);  virtual;
      property Task_type :TTask_type read fTask_type write fTask_type;
      property Vill : TVill read fVill write fVill;                    // Задание будет выполняться в этой деревне

        // Время начала работы задания  и  Время окончания работы задания
        // Именно в этот период времени задание может работать
      property BeginWork: TDateTime read fBeginWork write fBeginWork;
      property StopWork: TDateTime read fStopWork write fStopWork;

      property TimeStart: TDateTime read fTimeStart write fTimeStart;  // Время запуска задания
//      property TimeStop: TDateTime read fTimeStop write fTimeStop;     // Время запуска задания
      property Status : TTaskStatus read fStatus write fStatus;        // Статус задания
  end;

  TTask_Build=class(TTask)
    private
    function get_Next_Build: string;
//    function GetBuildList: string;
//    procedure SetBuildList(const Value: string);
    protected
    public
      constructor Create; override;
//      property BuildList : string read GetBuildList write SetBuildList;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList); override;
      property Next_Build: string read get_Next_Build;
  end;

  TTask_array= array of TTask;

  TTask_queue=class
    private
     task_array: TTask_array;
    function get_count: integer;
    function GetTask(const TaskNumber: integer): TTask;
    protected
    public
      constructor Create;
      procedure AddTask(task: TTask);
      property Count: integer read get_count;
      property Task[const TaskNumber: integer]: TTask read GetTask;

  end;

{
  TTask = record
    taskid: integer; //id задания

    time: TDateTime; //время выполнения задания
    TimeW: TDateTime;
    ft_name: ftname; //имя цели деревни

    //   Событие инициализирующее старт-стоп задание
    Start_Task_OnViewAttack_DateTime: TDateTime; // Время старта при  Start_Task_OnViewAttack_kind = 0
    // иначе интервал
    Stop_Task_OnViewAttack_DateTime: TDateTime; // Время останова при  Stop_Task_OnViewAttack_kind = 0
    // иначе интервал
    SpamTimeInterval:TDateTime;   // Спам интервал при Start_Task_OnViewAttack_kind <> 0
    Start_Task_OnViewAttack_kind: integer; // 0 - обычный старт
    // 1 - Инициализация через ... после атаки на ...
    // 2 - Инициализация через ... после обнаружения атаки на ...
    // 3 - Инициализация за ... до атаки на ...

    Stop_Task_OnViewAttack_kind: integer; // 0 - обычный stop
    // 1 - Инициализация через ... после атаки на ...
    // 2 - Инициализация через ... после обнаружения атаки на ...
    // 3 - Инициализация за ... до атаки на ...

    InitTaskTime: TDateTime; // Время последней инициализации задания --
    // Вернее время по которому было последний раз инициировано задание
    // Фактически это расчетное время атаки

    Start_Task_X: integer; // Координаты атакуемой (своей деревни)
    Start_Task_Y: integer;

    Stop_Task_X: integer; // Координаты атакуемой (своей деревни)
    Stop_Task_Y: integer;


    case tip: integer of
      0: (//0-строительство
        Btip: integer; //0 - очерель, 1 - автомат
        isRim: boolean;
        );
    //3:  ////////////// останов и запуск строительства
      4: (//постройка войск
        Tzdan: integer; //тип здания: 0 - казарма 1- конюшня 2 - мастерская
        Ttip: integer; //тип войск
        Tcol: integer; //кол-во войск, 0 - максимально возможное
        Tcolvo: integer; //сколько-раз
        Tper: TdateTime; //период повтора
        );
      5: (//проверка почты
        RefreshMailTime: TdateTime;
        );
      6: (//чтение лога фарма
        which_task: integer;
        );
      7: (//обновление данных деревни
        RefreshVillagePeriod: TdateTime;
        );
      8: (//снос здания
        del_ind: integer;
        del_colvo: integer;
        del_lvl : array[0..22] of integer;
        del_ids:  array[0..22] of integer;
        );
      9: (//праздники здания
        celebrate_type: integer;
        );
      10: (//прокачка воинов
        gid: integer; //12-кузня оружия 13-кузня доспехов
        uid: integer; //тип воина для прокачки
        );
      11: (// Фарм V3
        Is_delete: boolean; // Удалить задание после обработки
        Group_Farm_V3_Id: integer; //  Id -Группы фарма
        Data_Farm_V3_Id: integer; //  Id - задания в группе фарма
        );
      12: (// Интервальная отправка (слежение за интервалами)
        Group_Farm_Id_12: integer; //  Id -Группы фарма
        );
      13: (//  Фарм - Одиночная отправка (для не ожидать возврата)
        X_F: integer; // X координата
        Y_F: integer; // Y координата
        V_Name_F: ftname; // Наименование деревни
        Time_Wait_F: TDateTime; // Время до цели
        group_F: string[250]; //состав отряда на фарм
        gf_name_F: shortstring;
        // Задержка при ошибке отправки
        Sleep_OnErrorFarm_min_F: integer;
        Sleep_OnErrorFarm_max_F: integer;
        Send_only_one_type: boolean;
        del_farm_ref_F: ftname; //ссылка отмены задания на фарм
        );
      14: (// слежение за напами
        Last_Report_Id: ShortString;
        );

      15: (// Отправка ресов
        x_15, y_15: integer; //коодинаты
        Stip_15: integer; //0 - период, 1 - пришел и ушел.
        SRKratnost_15: integer;  // Кратность Если <=0 то равна емкости торговца
        period_15: Tdatetime;
        colsend_15: integer;
        res_task_15: array[0..3] of shortstring;
        res_15: array[0..3] of integer;
        min_ost_15: array[0..3] of integer;
        res_was_sent_15: array[0..3] of integer;
        );
  end; //case tip

}
implementation

{ TTask }

constructor TTask.Create;
begin
  inherited;
  fTask_type:=ttUnknown;
  fStatus:=tsUnknown;
end;

procedure TTask.Execute(WBContainer: TWBContainer;   FLog: TStringList);
begin
//  Status:=tsRun;
end;

{ TTask_Build }

constructor TTask_Build.Create;
begin
  inherited;
  Task_type:=ttBuild;

end;

procedure TTask_Build.Execute(WBContainer: TWBContainer;   FLog: TStringList);
Var
  FID: string;
  GID: string;
  RC: TBuildReturn_Code;
begin
  inherited;

  if Status = tsRun then
  begin
    FLog.Add('Стройка закончена, переходим в режим ожидания');
    TimeStart:=Vill.Account.TravianTime + (rc.Duration+12) / 24.0/60.0;
    Status := tsReady;
    exit;
  end;

  if Next_Build = '' then
  begin
    FLog.Add('Очередь пустая.  Снимаем задачу');
    Status:=tsDelete;
    exit;
  end;

  FID:=copy(Next_Build,1,pos('-',Next_Build)-1);
  GID:=copy(Next_Build,pos('-',Next_Build)+1);

  RC:=Vill.build_center(WBContainer,FId,Gid,Flog);
  if RC.Return_Code = -1 then // Фигня какаято отметим задание на удаление
  begin
    FLog.Add('Надо разобраться Фигня какаято отметим задание на удаление');
    Status:=tsDelete;
  end;

  if RC.Return_Code = 1 then  // Чегото не хватило  Сдвинем задание
  Begin
    FLog.Add('Чегото не хватило  Сдвинем задание');
    if rc.Duration > 0 then
      TimeStart:=Vill.Account.TravianTime + (rc.Duration+4) / 24.0/60.0
    else  // Отметим на удаление и надо разбираться
    begin
      Status:=tsDelete;
      flog.Add('НЕ смогли определить время ожидания')
    end;
  End;

  if RC.Return_Code = 0 then  // Все в порядке запустилось
  begin
    FLog.Add('Стройку запустили, переходим в режим "выполнения"');
    // Надо удалить то что мы строим из очереди
    // Потом сделаем нормально!!!
    vill.BuildList:=copy(vill.BuildList,1,pos(Next_Build,vill.BuildList)-1)+
                    copy(vill.BuildList,pos(Next_Build,vill.BuildList)+length(Next_Build));
    Status:=tsRun;
    TimeStart:=Vill.Account.TravianTime + (rc.Duration+4) / 24.0/60.0;
  end;



end;

{
function TTask_Build.GetBuildList: string;
begin
  Result:=Vill.BuildList;
end;
}
function TTask_Build.get_Next_Build: string;
begin
 result:=copy(Vill.BuildList,1,pos(';',Vill.BuildList)-1);
// BuildList:=copy(BuildList,1,pos(';',BuildList)+1);
end;

{
procedure TTask_Build.SetBuildList(const Value: string);
begin
  Vill.BuildList:=Value;
end;
}

{ TTask_queue }

procedure TTask_queue.AddTask(task: TTask);
begin
  if High(task_array) <= 0 then
    SetLength(task_array, 1)
  else
    SetLength(task_array, High(task_array)+1);

    task_array[High(task_array)]:=task;
end;

constructor TTask_queue.Create;
begin
  inherited;
  SetLength(task_array, 0);
end;

function TTask_queue.GetTask(const TaskNumber: integer): TTask;
begin
  result:=task_array[TaskNumber];
end;

function TTask_queue.get_count: integer;
begin
  result:=High(task_array)+1;
end;

end.
