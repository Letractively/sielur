unit UAcaunt;

interface

Type
  Acaunt = class
  private
  public
    NameServer: String;  //��� ������� �������� http://aburabur.blabla.ru    
    Login: String;       //����� ������������    
    Password: String;    //������ ������������    
    UserAgetn: String;   //����� �����������, ���� ����� �������� �� ���.
    IsProxy: Boolean;    //������������� �� ������
    ProxyName: String;   //�������� ��� ��� ������
    ProxyPort: String;   //���� ������.
end;

implementation

end.