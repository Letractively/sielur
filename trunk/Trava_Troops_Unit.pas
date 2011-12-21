unit Trava_Troops_Unit;

interface
//структура приблизительно такая
//юнит может быть пешим или конным, тараном , катапультой, героем, поселенцем, вождем
//почему такая градация ? да потомучто посел вождь каты и тараны специфичные
//юниты которые годяться в общем случаи токо для своих прямых обязаностей а не
//для фарма напа или защиты
Type
  Type_Troops = (tInfantry{пехота},
                 tCavalry{кавалерия},
                 tCatapult{катапульта},
                 tBattering_ram{стенобитное орудие, как 100 мм гаубица токо стреляет по стенам :)},
                 tSettler{поселенец},
                 tLeader{вождь, предводительб сенатор},//потодумаю это есчо разделить для каждой рассы
                 tHero{Имба герой Т4 версии травы});
Type
 TDefence = record
   InfantryDef: Integer;
   CavalryDef: Integer;
 end;

Type TTRoops = object
  FName: String;        //имя например легионер дубинщик итд.
  FAtack: Integer;      //атака
  FDefence: TDefence;   //защита как от пехоты так и от коней
  FSpeed: Integer;      //скорость
  FCapasity: Integer;   //грузоподйомность
  FCroopUse: Integer    //содержание кропа в час
end;

implementation

end.
