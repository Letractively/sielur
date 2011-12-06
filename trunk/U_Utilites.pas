unit
  U_Utilites;

interface

uses
  Windows
  , ActiveX
  , ShDocVw
  , MSHTML
  , Classes
  , UContainer
  , SysUtils
  , Dialogs
  ;

// Эмуляция работы пользователя - Найти ссылку и кликнуть по нец
function FindAndClickHref(WBContainer: TWBContainer; document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;

// Получение расы по карте
function get_race_from_KarteT36(document: IHTMLDocument2): integer;

// Разбор  <div id="contract"
function get_duration(Contract_Collection :IHTMLElementCollection; FLog: TStringList): integer;

//получает исходный код странички из Веб контейнера
function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: string): Boolean;
//Получает исходный код странички из екземпляра IHTMLDocument2
function Doc_GetHTMLCode(Adocument: IHTMLDocument2): string;
function bild_lvl(s: string): integer;

implementation

//функция  получает Текст странички из Веббраузера

function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: string): Boolean;
var
  ps: IPersistStreamInit;
  ss: TStringStream;
  sa: IStream;
  s: string;
begin
  ps := WBContainer.HostedBrowser.Document as IPersistStreamInit;
  s := '';
  ss := TStringStream.Create(s);
  try
    sa := TStreamAdapter.Create(ss, soReference) as IStream;
    Result := Succeeded(ps.Save(sa, True));
    if Result then
      ACode := Utf8ToAnsi(ss.Datastring);
  finally
    ss.Free;
  end;
end;

//функция переводит карявую строку в число со знаком.

function bild_lvl(s: string): integer;
var
  i: integer;
  num: string;
  sw: boolean;
begin
  sw := false;
  num := '';
  for i := 1 to length(s) do
  begin
    case s[i] of
      '-', '0'..'9':
        begin
          if sw then
            num := '';
          num := num + s[i];
          sw := false;
        end
    else
      sw := (num <> '');
    end; //case
  end; //for i
  if num = '' then
    bild_lvl := 0
  else
    try
      bild_lvl := StrToInt(num);
    except
      bild_lvl := 0
    end;
end;

function Doc_GetHTMLCode(Adocument: IHTMLDocument2): string;
var
  ps: IPersistStreamInit;
  ss: TStringStream;
  sa: IStream;
  s: string;
begin
  ps := Adocument as IPersistStreamInit;
  s := '';
  ss := TStringStream.Create(s);
  try
    sa := TStreamAdapter.Create(ss, soReference) as IStream;
    Succeeded(ps.Save(sa, True));
    Result := Utf8ToAnsi(ss.Datastring);
  finally
    ss.Free;
  end;
end;

function FindAndClickHref(WBContainer: TWBContainer; document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;
//   Найти ссилку и кликнуть по ней

// TypeSubHref   - Модификатор поиска
//     1 - найти полное равенство ссылки с SubHref
//     2 - ссылка должна начинаться с SubHref
//     3 - ссылка должна содержать SubHref
//     4 - ссылка должна заканчиваться SubHref
var
  ItemNumber: integer;
  href_field: IHTMLElement;
  All_Links: IHTMLElementCollection;
  url: string;
  Is_Find: boolean;
begin
  Result := nil;
  if Assigned(document) then
  begin
    All_Links := document.links;
    for ItemNumber := 0 to All_Links.Length - 1 do
    begin // цикл по всем ссылкам документа
      href_field := All_Links.item(ItemNumber, '') as IHTMLElement;
      url := href_field.toString;
      Is_Find := (TypeSubHref = 1) and (url = SubHref);
      if not Is_Find then
        Is_Find := (TypeSubHref = 2) and (pos(SubHref, url) = 1);
      if not Is_Find then
        Is_Find := (TypeSubHref = 3) and (pos(SubHref, url) > 0);
      if not Is_Find then
        Is_Find := (TypeSubHref = 4) and (pos(SubHref, url) = length(url) -
          length(SubHref) + 1);
      if Is_Find then
      begin // Отлично нашли требуемую ссылку
        WBContainer.MyElementClick(href_field);
        Result := WBContainer.HostedBrowser.Document as IHTMLDocument2;
        exit;
      end;
    end; // цикл по всем ссылкам документа
  end;
end;

function get_race_from_KarteT36(document: IHTMLDocument2): integer;
// Определение расы по карте

var
  ItemNumber: integer;
  url: string;
  Karte_document: IHTMLDocument2;
  field_Element: IHTMLElement;

  Tmp_Collection: IHTMLElementCollection;
  Script_Number: integer;
  tmp_txt: string;
  Race_String: string;
begin
  Result := 0;

  if Assigned(Karte_document) then
  begin // Итак карту мы получили, теперь попробуем с ней разобраться
    field_Element := (document as IHTMLDocument3).getElementById('a_3_3');
    // Центр карты
    url := field_Element.toString; // ссылка на деревушку
    url := copy(url, pos('?', url) + 1); // нужный нам кусочек

    field_Element := (document as IHTMLDocument3).getElementById('map');
    // Отсюда нам нужен второй скрипт
    Script_Number := 0;
    Tmp_Collection := (field_Element.children as ihtmlelementcollection);
    for ItemNumber := 0 to Tmp_Collection.Length - 1 do
    begin
      field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
      if field_Element.tagName = 'SCRIPT' then
      begin
        Script_Number := Script_Number + 1;
        if Script_Number >= 2 then
          break;
      end;
    end;
    if Script_Number = 2 then
    begin // Нужный нам скрипт Из него вытащим расу
      // По простому по рабочекрестьянски
      // Нам нужен центр карты и мы его получим!  Петр упорный :) яб регулярку юзнул...
      tmp_txt := field_Element.innerHTML;
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // Выбросили первую строку карты
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // Выбросили вторую строку карты
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // Выбросили третюю строку карты
      tmp_txt := copy(tmp_txt, 1, pos(']]', tmp_txt) + 1); // Взяли 4-ю строку
      // Работаем с 4-й строкой
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // Выбросили первую колонку карты
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // Выбросили вторую колонку карты
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // Выбросили третюю колонку карты
      tmp_txt := copy(tmp_txt, 1, pos(']', tmp_txt)); // Взяли 4-ю колонку
      // И теперь имеем то что нам нужно
      // [X,Y,?,?,"URL","?","Наименование_Деревни","Игрок","Население","?",Раса]
      //  Раса = 1 - рим  2 - тевтон   3 - галл
      Race_String := copy(tmp_txt, length(tmp_txt) - 1, 1);
      Result := StrToInt(Race_String);
    end;
  end; // if Assigned(Karte_document)
end;

function get_duration(Contract_Collection :IHTMLElementCollection; FLog: TStringList): integer;
var
  Tmp_Collection : IHTMLElementCollection;
  field_Element :IHTMLElement;
  field_contractCosts :IHTMLElement;
  field_ShowCosts :IHTMLElement;
  ItemNumber: integer;
  Tmp_string: string;
begin
  Result:=0;
  Flog.Add('Ищем <div class="contractCosts">');     //<div class="contractCosts"
  field_contractCosts:=nil;
  for ItemNumber := 0 to Contract_Collection.Length - 1 do
  begin
    field_Element := Contract_Collection.item(ItemNumber, '') as IHTMLElement;
    if Uppercase(field_Element.className) = 'CONTRACTCOSTS' then
    begin
      field_contractCosts:=field_Element;
      break;
    end;
  end;
  if not Assigned(field_contractCosts) then
  begin
    Flog.Add('НЕ НАШЛИ  <div class="contractCosts">');
    exit;
  end;


  Flog.Add('Ищем <div class="showCosts"...>');     //<div class="contractCosts"
  Tmp_Collection := field_contractCosts.children as IHTMLElementCollection;
  field_ShowCosts:=nil;
  for ItemNumber := 0 to Contract_Collection.Length - 1 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    if Uppercase(field_Element.className) = 'SHOWCOSTS' then
    begin
      field_ShowCosts:=field_Element;
      break;
    end;
  end;

  if not Assigned(field_ShowCosts) then
  begin
    Flog.Add('НЕ НАШЛИ Ищем <div class="showCosts"...>');
    exit;
  end;

  Flog.Add('Ищем <span class="clocks"...>');
  Tmp_Collection := field_ShowCosts.children as IHTMLElementCollection;
  for ItemNumber := 0 to Tmp_Collection.Length - 1 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;
    if Uppercase(field_Element.className) = 'CLOCKS' then
    begin
      Flog.Add('Нашли <span class="clocks"...>');
      Tmp_string:=field_Element.innerText;
      Result:= Result + StrToInt(copy(Tmp_string,1,pos(':',Tmp_string)-1))*24*60;
      Tmp_string:= Copy(Tmp_string,pos(':',Tmp_string)+1);
      Result:= Result + StrToInt(copy(Tmp_string,1,pos(':',Tmp_string)-1))*60;
      Tmp_string:= Copy(Tmp_string,pos(':',Tmp_string)+1);
      Result:= Result + StrToInt(Tmp_string);

      showmessage(field_Element.innerText+'='+IntToStr(Result));
    end;
  end;

end;

end.

