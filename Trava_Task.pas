unit Trava_Task;

interface

uses Trava_class
   , MSHTML
   ,Classes
   ,Trava_My_Const
   , UContainer
  , U_Utilites
  ,x_bot_utl   ;



type


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
      property Vill : TVill read fVill write fVill;                    // ������� ����� ����������� � ���� �������

        // ����� ������ ������ �������  �  ����� ��������� ������ �������
        // ������ � ���� ������ ������� ������� ����� ��������
      property BeginWork: TDateTime read fBeginWork write fBeginWork;
      property StopWork: TDateTime read fStopWork write fStopWork;

      property TimeStart: TDateTime read fTimeStart write fTimeStart;  // ����� ������� �������
//      property TimeStop: TDateTime read fTimeStop write fTimeStop;     // ����� ������� �������
      property Status : TTaskStatus read fStatus write fStatus;        // ������ �������
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
    taskid: integer; //id �������

    time: TDateTime; //����� ���������� �������
    TimeW: TDateTime;
    ft_name: ftname; //��� ���� �������

    //   ������� ���������������� �����-���� �������
    Start_Task_OnViewAttack_DateTime: TDateTime; // ����� ������ ���  Start_Task_OnViewAttack_kind = 0
    // ����� ��������
    Stop_Task_OnViewAttack_DateTime: TDateTime; // ����� �������� ���  Stop_Task_OnViewAttack_kind = 0
    // ����� ��������
    SpamTimeInterval:TDateTime;   // ���� �������� ��� Start_Task_OnViewAttack_kind <> 0
    Start_Task_OnViewAttack_kind: integer; // 0 - ������� �����
    // 1 - ������������� ����� ... ����� ����� �� ...
    // 2 - ������������� ����� ... ����� ����������� ����� �� ...
    // 3 - ������������� �� ... �� ����� �� ...

    Stop_Task_OnViewAttack_kind: integer; // 0 - ������� stop
    // 1 - ������������� ����� ... ����� ����� �� ...
    // 2 - ������������� ����� ... ����� ����������� ����� �� ...
    // 3 - ������������� �� ... �� ����� �� ...

    InitTaskTime: TDateTime; // ����� ��������� ������������� ������� --
    // ������ ����� �� �������� ���� ��������� ��� ������������ �������
    // ���������� ��� ��������� ����� �����

    Start_Task_X: integer; // ���������� ��������� (����� �������)
    Start_Task_Y: integer;

    Stop_Task_X: integer; // ���������� ��������� (����� �������)
    Stop_Task_Y: integer;


    case tip: integer of
      0: (//0-�������������
        Btip: integer; //0 - �������, 1 - �������
        isRim: boolean;
        );
    //3:  ////////////// ������� � ������ �������������
      4: (//��������� �����
        Tzdan: integer; //��� ������: 0 - ������� 1- ������� 2 - ����������
        Ttip: integer; //��� �����
        Tcol: integer; //���-�� �����, 0 - ����������� ���������
        Tcolvo: integer; //�������-���
        Tper: TdateTime; //������ �������
        );
      5: (//�������� �����
        RefreshMailTime: TdateTime;
        );
      6: (//������ ���� �����
        which_task: integer;
        );
      7: (//���������� ������ �������
        RefreshVillagePeriod: TdateTime;
        );
      8: (//���� ������
        del_ind: integer;
        del_colvo: integer;
        del_lvl : array[0..22] of integer;
        del_ids:  array[0..22] of integer;
        );
      9: (//��������� ������
        celebrate_type: integer;
        );
      10: (//�������� ������
        gid: integer; //12-����� ������ 13-����� ��������
        uid: integer; //��� ����� ��� ��������
        );
      11: (// ���� V3
        Is_delete: boolean; // ������� ������� ����� ���������
        Group_Farm_V3_Id: integer; //  Id -������ �����
        Data_Farm_V3_Id: integer; //  Id - ������� � ������ �����
        );
      12: (// ������������ �������� (�������� �� �����������)
        Group_Farm_Id_12: integer; //  Id -������ �����
        );
      13: (//  ���� - ��������� �������� (��� �� ������� ��������)
        X_F: integer; // X ����������
        Y_F: integer; // Y ����������
        V_Name_F: ftname; // ������������ �������
        Time_Wait_F: TDateTime; // ����� �� ����
        group_F: string[250]; //������ ������ �� ����
        gf_name_F: shortstring;
        // �������� ��� ������ ��������
        Sleep_OnErrorFarm_min_F: integer;
        Sleep_OnErrorFarm_max_F: integer;
        Send_only_one_type: boolean;
        del_farm_ref_F: ftname; //������ ������ ������� �� ����
        );
      14: (// �������� �� ������
        Last_Report_Id: ShortString;
        );

      15: (// �������� �����
        x_15, y_15: integer; //���������
        Stip_15: integer; //0 - ������, 1 - ������ � ����.
        SRKratnost_15: integer;  // ��������� ���� <=0 �� ����� ������� ��������
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
