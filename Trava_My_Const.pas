unit
  Trava_My_Const;

interface

const
  SCriticalError = 'Критическая ошибка. Обратитесь к разработчику.'#10#13;
type
  TSet_ACF_BuildList = procedure(const Value: String);


  TTaskStatus=(tsUnknown, tsDelete, tsReady, tsRun, tsWaitAttack ); // Это так для примера, потом разберемся
              //  tsDelete     - Задание надо удалить
              //  tsReady      - Задание готово к выполнению и ожидает времени старта (TimeStart)
              //  tsRun        - Задание выполняется и ожидает времени окончания (TimeStop)
              //  tsWaitAttack - Задание ожидает события инициализации (Атаки)
              //
              //
              //
  // Тоже для примера, потом разберемся, добавил трупиков :)
  TTask_type = (ttUnknown, ttBuild, ttSendRes, ttSendTroops);

  TBuildReturn_Code=Record
    Return_Code: integer;       // <0   - Фигня какаято. Ошибка в парсере
                                // =1   - Достигли максимального уровня
                                // =2   - Не хватает Ресурсов
                                // =3   - Не хватает производства зерна
                                // =4   - Вроде всё в порядке но стройка недоступна !!!!!!
    R1: integer;     // Дерево     (Если значение отрицательное то этого ресурса не хватает)
    R2: integer;     // Глина
    R3: integer;     // Железо
    R4: integer;     // Кроп
    R5: integer;     //  Потребление кропа
    Duration: integer;  // Время строительства  (в секундах)
    Wait : integer;      // Время ожидания для накопления ресов (в секундах)
    Text: string;
  End;
  TFarmReturn_Code = record
    Retutn_Code: Integer;   // <0   - Фигня какаято. Ошибка в парсере
                            // =1   - не хватает войск
                            // =2   - цели не существует
                            // =3   - цель в баньке париться
                            // =4   - атачим своих по алу, игрока у которого ты зам, один айпи итд...
                            // =5   - атачим сами себя, одумайся :)
                            // =6   - защита от новичков
    TargetNameVil: String;  //имя деревушки потерпельца
    TargetNamePlayer: String;// имя игрока который терпит
    TargetNameAli: String;  //имя ала в котором корм живет
    TravelTime: Integer;    //время пути до цели ...
  end;

implementation

end.
