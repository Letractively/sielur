unit Trava_Troops_Unit;

interface
//��������� �������������� �����
//���� ����� ���� ����� ��� ������, ������� , �����������, ������, ����������, ������
//������ ����� �������� ? �� ��������� ����� ����� ���� � ������ �����������
//����� ������� �������� � ����� ������ ���� ��� ����� ������ ����������� � ��
//��� ����� ���� ��� ������
Type
  Type_Troops = (tInfantry{������},
                 tCavalry{���������},
                 tCatapult{����������},
                 tBattering_ram{����������� ������, ��� 100 �� ������� ���� �������� �� ������ :)},
                 tSettler{���������},
                 tLeader{�����, ������������� �������},//��������� ��� ���� ��������� ��� ������ �����
                 tHero{���� ����� �4 ������ �����});
Type
 TDefence = record
   InfantryDef: Integer;
   CavalryDef: Integer;
 end;

Type TTRoops = object
  FName: String;        //��� �������� �������� �������� ���.
  FAtack: Integer;      //�����
  FDefence: TDefence;   //������ ��� �� ������ ��� � �� �����
  FSpeed: Integer;      //��������
  FCapasity: Integer;   //����������������
  FCroopUse: Integer    //���������� ����� � ���
end;

implementation

end.
