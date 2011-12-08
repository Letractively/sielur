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


implementation

end.
