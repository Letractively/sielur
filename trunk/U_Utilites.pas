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

function FindAndClickHref(WBContainer: TWBContainer; document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;
// Эмуляция работы пользователя - Найти ссылку и кликнуть по нец

function get_race_from_KarteT36(document: IHTMLDocument2): integer;
// Получение расы по карте

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
  href_field: IHTMLElement;
  All_Links: IHTMLElementCollection;
  url: string;
  Karte_document: IHTMLDocument2;
  field_Element: IHTMLElement;

  Tmp_Collection: IHTMLElementCollection;
  Script_Number: integer;
  tmp_txt: string;
  Race_String: string;
  iii: integer;
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

end.

