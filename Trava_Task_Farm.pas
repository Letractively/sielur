unit Trava_Task_Farm;
interface
uses  Trava_class
     ,MSHTML
     ,Classes
     ,Trava_My_Const
     ,UContainer
     ,U_Utilites
     ,Trava_Task
     ,x_bot_utl
     ,Windows
     ,IniFiles;

type
  {: Состояние элементов списка }
  TStateItem = (siNone, siDelete, siInsert, siUpdate);
type
  {: Тип атаки : Подкрепление , нападение , набег}
  TTypeAtaks = (sireinforcement, siattack, siraid);
  {: Базовый класс элемента списка }
  {: Зарание делаю такую структуру ибо всетаки думаю прикрутить БД!!!}
type
  TCustomItem = class
  private
    FId: integer;
    FOrderId: Integer;
    FRowId: string;
    procedure SetOrderId(const Value: Integer);
  public
    FEnable: boolean;
    FName: string;
    FState: TStateItem;
    constructor Create(AId: Integer; AEnable: Boolean; AName: string;
      AState: TStateItem = siNone; AOrderId: Integer = 0); overload;
    constructor Create(AId: Integer); overload;
    function GetEnable: Boolean; virtual;
    function GetName: string; virtual;
    procedure SetEnable(const Value: boolean); virtual;
    procedure SetName(const Value: string); virtual;
    function GetState: TStateItem; virtual;
    procedure SetState(const Value: TStateItem); virtual;
    property Id: integer read FId write FId;
    property Enable: Boolean read GetEnable write SetEnable default False;
    property Name: string read GetName write SetName;
    property OrderId: Integer read FOrderId write SetOrderId;
    {: Псевдостолбец. Уникальный идентификатор записи БД  }
    property RowId: string read FRowId write FRowId;
    property State: TStateItem read GetState write SetState default siNone;
  end;

  {: Базовый класс списка элементов }
  TCustomItems = class
  private
    FIniFile: TIniFile;
    FList: TList;
    FLock: TRTLCriticalSection;
    FIsLoaded: Boolean;
    FOwner: TCustomItem;
    function GetLastItem: TCustomItem;
    procedure SetIsLoaded(const IsValue: Boolean);
 protected
    function GetIsLoaded: Boolean;
    function GetCount: integer;
    function GetItems(Index: integer): TCustomItem;
    function GetLastId: Integer;
  public
    constructor Create; overload;
    constructor Create(APathToConfig: string); overload;
    destructor Destroy; override;
    function Add(AItem: TCustomItem): TCustomItem; overload;
    procedure Clear(AIsFreeItems: Boolean = True); virtual;
    procedure Delete(AItem: TCustomItem); overload;
    procedure Delete(AId: Integer); overload;
    procedure DestroyNotClear;
    function GetItemById(AId: integer): TCustomItem;
    function GetItemByName(AName: string): TCustomItem;
    function GetItemsByEbl(AEnable: boolean): TCustomItems;
    function GetNameById(AId: Integer): string;
    function GetFirstIdByName(AName: string): Integer;
    function IsDuplicate(AName: string): Boolean; overload;
    function IsDuplicate(AId: Integer): Boolean; overload;
    function IsModify: boolean;
    function IsUpdated: boolean;
    procedure Insert(AItem: TCustomItem);
    function LockList: TList;
    procedure Remove(AItem: TCustomItem; IsFreeItem: Boolean = False);
    procedure SetAllState(AState: TStateItem);
    procedure Sort(ACompare: TListSortCompare);
    procedure UnlockList;
    procedure Update(AItem: TCustomItem); overload;
    property Count: integer read GetCount;
    property IniFile: TIniFile read FIniFile;
    property IsLoaded: Boolean read GetIsLoaded write SetIsLoaded;
    property Items[Index: integer]: TCustomItem read GetItems; default;
    property LastId: Integer read GetLastId;
    property LastItem: TCustomItem read GetLastItem;
    property Owner: TCustomItem read FOwner write FOwner;
  end;

Type
  TTroops = array [1..11] of integer;

Type
  TFarmItem = class(TCustomItem)
  //тут допишу седня или завтра
    //координаты цели  Coords.X Coords.Y
    Coords: TPoint;
    FTroops: TTroops; //здесь подрузумиваеться тип юнитов но их пока нету
    Finterval: Integer; //период фарма
    FIntervalRange: Integer; //разброс при фарме
    FTypeAtaks: TTypeAtaks; // тип атаки , нападение набег подкрепление
    FProfitFarm: String; //в дальнейшем будет учитываться прибыьл фарма
    FProfitHistory: String; //история фарма , пока думаю скоко ресов утянули скоко войск потеряли
    FCasualtiesInpRocPerAtack: Integer; //допустимые потери при атаке, тоесть если
                                        //больше данного процента то преращаем туда бегать
    FQuantity: integer;  //количество ходок , думаю при 1000 безконечтно бегать...
    FGeneration: integer; //поколение , тоесть скок раз туда збегали.
  public
    constructor Create (AId: Integer; AEnable: Boolean; AName: string;
                        AState: TStateItem; AOrderId: Integer;
                        ACoords: TPoint; ATroops: TTroops;
                        AInterval, AIntervalRange: Integer; ATypeAtaks: TTypeAtaks;
                        AProfitFarm, AProfitHistory: String; ACasualtiesInpRocPerAtack,
                        AQuantity, FGeneration: Integer); overload;
  end;

Type
 TFarmList = class (TCustomItems)
   public
     procedure Add(AFarmItem: TFarmItem) overload;
 end;
{type
  //скопировал как шаблон но полностьюпеределывать
    TTask_Farm=class(TTask)
    private
      function GetFarmList: TFarmList;
    protected
    public
      constructor Create; override;
      property FarmList : string read GetFarmList write GetFarmList;
      procedure Execute(WBContainer: TWBContainer;   FLog: TStringList); override;
      property Next_Build: string read get_Next_Build;
      property Set_ACF_BuildList: TSet_ACF_BuildList read fSet_ACF_BuildList write fSet_ACF_BuildList;
  end;
 }

implementation

function CompareById(AItem1, AItem2: Pointer): Integer;
var
  Item1, Item2: TCustomItem;
begin
  Result := 0;
  Item1 := TCustomItem(AItem1);
  Item2 := TCustomItem(AItem2);
  if Item1.Id > Item2.Id then
    Result := 1
  else if Item1.Id = Item2.Id then
    Result := 0
  else if Item1.Id < Item2.Id then
    Result := -1;
end;

function CompareByName(AItem1, AItem2: Pointer): Integer;
var
  Item1, Item2: TCustomItem;
begin
  Result := 0;
  Item1 := TCustomItem(AItem1);
  Item2 := TCustomItem(AItem2);
  if Item1.Name > Item2.Name then
    Result := 1
  else if Item1.Name = Item2.Name then
    Result := 0
  else if Item1.Name < Item2.Name then
    Result := -1;
end;

{ TOREObjects }

function TCustomItems.Add(AItem: TCustomItem): TCustomItem;
begin
  Result := nil;
  LockList;
  try
    FList.Add(AItem);
    Result := AItem;
  finally
    UnlockList;
  end;
end;

procedure TCustomItems.Clear(AIsFreeItems: Boolean = True);
var
  I: Integer;
begin
//  LockList;
  try
    if AIsFreeItems then
      for I := FList.Count - 1 downto 0 do
        if Assigned(FList[I]) then
          TCustomItem(FList[I]).Free;
    FList.Clear;
  finally
//    UnlockList;
  end;
end;

constructor TCustomItems.Create(APathToConfig: string);
begin
  Create;
  FIniFile := TIniFile.Create(APathToConfig);
end;

constructor TCustomItems.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
end;

procedure TCustomItems.Delete(AItem: TCustomItem);
var
  I: Integer;
begin
  LockList;
  try
    for I := 0 to Count - 1 do
    if Items[I] = AItem then
    begin
      Items[I].State := siDelete;
      Break;
    end;
  finally
    UnlockList;
  end;
end;

procedure TCustomItems.DestroyNotClear;
begin
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

destructor TCustomItems.Destroy;
begin
  Clear;
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
  if Assigned(FIniFile) then
    FIniFile.Free;
end;

function TCustomItems.GetCount: integer;
begin
  Result := FList.Count;
end;

function TCustomItems.GetFirstIdByName(AName: string): Integer;
var
  Item: TCustomItem;
begin
  Result := 0;
  Item := GetItemByName(AName);
  if Assigned(Item) then
    Result := Item.Id;
end;

//получение даннных  о загрузке неоднозначны , так как если есть елементы в списке то
//не имеет смысла изменять  FIsLoaded при write property.
function TCustomItems.GetIsLoaded: Boolean;
begin
  Result := FIsLoaded or (Count > 0);
end;

function TCustomItems.GetItemById(AId: integer): TCustomItem;
var
  I: integer;
  Item: TCustomItem;
begin
  Result := nil;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      Item := FList[I];
      if Assigned(Item) then
        if (Item.Id = AId) and (Item.State <> siDelete) then
        begin
          Result := Item;
          Break;
        end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.GetItemByName(AName: string): TCustomItem;
var
  I: integer;
  Item: TCustomItem;
begin
  Result := nil;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      Item := FList[I];
      if Assigned(Item) then
        if (Item.Name = AName) and (Item.State <> siDelete) then
        begin
          Result := Item;
          Break;
        end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.GetItems(Index: integer): TCustomItem;
begin
  if Index < FList.Count then
    Result := FList[Index] else
    Result := nil;
end;

function TCustomItems.GetItemsByEbl(AEnable: boolean): TCustomItems;
var
  I: integer;
begin
  Result := TCustomItems.Create;
  LockList;
  try
    for I := 0 to Count - 1 do
      if (Items[I].Enable = AEnable) and (Items[I].State <> siDelete) then
        Result.Add(Items[I]);
  finally
    UnlockList;
  end;
end;

function TCustomItems.GetLastId: Integer;
var
  I: Integer;
  Item: TCustomItem;
begin
  Result := 0;
  if Assigned(FList) then
  begin
    LockList;
    try
      for I := 0 to FList.Count - 1 do
      begin
        Item := FList[I];
        if Result < Item.Id then
          Result := Item.Id;
      end;
    finally
      UnlockList;
    end;
  end;
end;

function TCustomItems.GetLastItem: TCustomItem;
begin
  Result := nil;
  if Assigned(Items[Count - 1]) then
    Result := Items[Count - 1];
end;

function TCustomItems.GetNameById(AId: Integer): string;
var
  Item: TCustomItem;
begin
  Result := '';
  Item := GetItemById(AId);
  if Assigned(Item) then
    Result := Item.Name;
end;

{ TCustomItem }

constructor TCustomItem.Create(AId: Integer; AEnable: Boolean; AName: string;
  AState: TStateItem = siNone; AOrderId: Integer = 0);
begin
  FId := AId;
  FOrderId := AOrderId;
  FEnable := AEnable;
  FName := AName;
  FState := AState;
end;

constructor TCustomItem.Create(AId: Integer);
begin
  FId := AId;
  FOrderId := 0;
  FEnable := True;
  FName := '';
  FState := siNone;
end;

function TCustomItem.GetEnable: boolean;
begin
  Result := FEnable;
end;

function TCustomItem.GetName: string;
begin
  Result := FName;
end;

function TCustomItem.GetState: TStateItem;
begin
  Result := FState;
end;

procedure TCustomItem.SetEnable(const Value: boolean);
begin
  if FEnable <> Value then
  begin
    FEnable := Value;
    State := siUpdate;
  end;
end;

procedure TCustomItem.SetName(const Value: string);
begin
  if FName <> Value then
  begin
    FName := Value;
    State := siUpdate;
  end;
end;

procedure TCustomItem.SetOrderId(const Value: Integer);
begin
  if FOrderId <> Value then
  begin
    FOrderId := Value;
    State := siUpdate;
  end;
end;

procedure TCustomItem.SetState(const Value: TStateItem);
begin
  { Проверка был ли узел уже удален }
  if (FState <> Value) then
  begin
    { Проверка на редактирование еще не добавленного в БД узла }
    if ((FState = siInsert) and (Value = siUpdate)) or
    { Проверка на вставку еще не обновленного в БД узла }
       ((FState = siUpdate) and (Value = siInsert)) then
      Exit
    else
      FState := Value;
  end;
end;

procedure TCustomItems.Insert(AItem: TCustomItem);
begin
  if (AItem.State <> siInsert) and
     (AItem.State <> siDelete) then
    AItem.State := siInsert;
end;

function TCustomItems.IsDuplicate(AName: string): Boolean;
var
  I: integer;
begin
  Result := False;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      if (Items[I].State <> siDelete) and (Items[I].State <> siDelete) and
        (Items[I].Name = AName) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.IsDuplicate(AId: Integer): Boolean;
var
  I: integer;
begin
  Result := False;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      if Items[I].Id = AId then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.IsModify: boolean;
var
  I: integer;
begin
  Result := False;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      if (Items[I].State <> siNone) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.IsUpdated: boolean;
var
  I: integer;
begin
  Result := False;
  LockList;
  try
    for I := 0 to Count - 1 do
    begin
      if (Items[I].State = siUpdate) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

function TCustomItems.LockList: TList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TCustomItems.Remove(AItem: TCustomItem; IsFreeItem: Boolean = False);
var
  I: Integer;
begin
  LockList;
  try
    for I := 0 to Count - 1 do
    if FList[I] = AItem then
    begin
      if IsFreeItem then
        AItem.Free;
      FList.Delete(I);
      Break;
    end;
  finally
    UnlockList;
  end;
end;

procedure TCustomItems.Delete(AId: Integer);
var
  Item: TCustomItem;
begin
  Item := GetItemById(AId);
  if Assigned(Item) then
    Item.State := siDelete;
end;

procedure TCustomItems.SetAllState(AState: TStateItem);
var
  I: integer;
begin
  {Установить состояние узлов в списке}
  LockList;
  try
    for I := 0 to Count - 1 do
      if (Items[I].State <> siDelete) then
        Items[I].State := AState;
  finally
    UnlockList;
  end;
end;

procedure  TCustomItems.SetIsLoaded(const IsValue: Boolean);
begin
  if IsValue then
    FIsLoaded := True
  else
    begin
      FIsLoaded := False;
      FList.Count := 0;
    end
end;

procedure TCustomItems.Sort(ACompare: TListSortCompare);
begin
  FList.Sort(ACompare);
end;

procedure TCustomItems.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

procedure TCustomItems.Update(AItem: TCustomItem);
begin
  if (AItem.State <> siInsert) and
     (AItem.State <> siDelete) then
    AItem.State := siUpdate;
end;

{ TFarmList }

procedure TFarmList.Add(AFarmItem: TFarmItem);
begin
   inherited Add(TFarmItem.Create(AFarmItem.Id, AFarmItem.Enable, AFarmItem.Name,
                 AFarmItem.GetState, AFarmItem.OrderId, AFarmItem.Coords,
                 AFarmItem.FTroops, AFarmItem.Finterval, AFarmItem.FIntervalRange,
                 AFarmItem.FTypeAtaks, AFarmItem.FProfitFarm, AFarmItem.FProfitHistory,
                 AFarmItem.FCasualtiesInpRocPerAtack, AFarmItem.FQuantity,
                 AFarmItem.FGeneration))
end;

{ TFarmItem }

constructor TFarmItem.Create(AId: Integer; AEnable: Boolean; AName: string;
                          AState: TStateItem ; AOrderId: Integer;
                          ACoords: TPoint; ATroops: TTroops;
                          AInterval, AIntervalRange: Integer; ATypeAtaks: TTypeAtaks;
                          AProfitFarm, AProfitHistory: String;
                          ACasualtiesInpRocPerAtack, AQuantity, FGeneration: Integer);
begin
  Inherited Create(AId, AEnable, AName);
  Inherited Create;
    Coords := ACoords;
    FTroops := ATroops;
    Finterval := AInterval;
    FIntervalRange := AIntervalRange;
    FTypeAtaks := ATypeAtaks;
    FProfitFarm := AProfitFarm;
    FProfitHistory := AProfitHistory;
    FCasualtiesInpRocPerAtack := ACasualtiesInpRocPerAtack;
    FQuantity := AQuantity;
    FGeneration := FGeneration;
end;

end.
