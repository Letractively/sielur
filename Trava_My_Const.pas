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

  TTask_type = (ttUnknown, ttBuild, ttSendRes);   // Тоже для примера, потом разберемся

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

implementation

end.
