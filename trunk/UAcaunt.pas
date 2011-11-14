unit UAcaunt;

interface

Type
  TAcaunt = class
  private
  public
    NameServer: String;  //имя сервера, например, http://aburabur.blabla.ru
    Login: String;       //логин пользователя
    Password: String;    //пароль пользователя
    UserAgetn: String;   //Агент подключения, типа Опера Фаирфокс ИЕ итд.
    IsProxy: Boolean;    //используется ли проскя
    ProxyName: String;   //айпишник или имя прокси
    ProxyPort: String;   //порт прокси.
end;

implementation

end.