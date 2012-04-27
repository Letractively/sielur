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
  ,Trava_My_Const
  ;

// �������� ������ ������������ - ����� ������ � �������� �� ���
function FindAndClickHref(WBContainer: TWBContainer; document: IHTMLDocument2;
  SubHref: string; TypeSubHref: integer): IHTMLDocument2;

// ��������� ���� �� �����
function get_race_from_KarteT36(document: IHTMLDocument2): integer;

// ������  <div id="contract"
function Prepare_Contract(Contract_Collection :IHTMLElementCollection; FLog: TStringList): TBuildReturn_Code;

//�������� �������� ��� ��������� �� ��� ����������
function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: string): Boolean;

//�������� �������� ��� ��������� �� ���������� IHTMLDocument2
function Doc_GetHTMLCode(Adocument: IHTMLDocument2): string;
function bild_lvl(s: string): integer;
//������������ WideString � String
function WideStringToString(const ws: WideString; codePage: Word): AnsiString;

implementation

//�������  �������� ����� ��������� �� �����������

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

//������� ��������� ������� ������ � ����� �� ������.

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
//   ����� ������ � �������� �� ���

// TypeSubHref   - ����������� ������
//     1 - ����� ������ ��������� ������ � SubHref
//     2 - ������ ������ ���������� � SubHref
//     3 - ������ ������ ��������� SubHref
//     4 - ������ ������ ������������� SubHref
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
    begin // ���� �� ���� ������� ���������
      href_field := All_Links.item(ItemNumber, '') as IHTMLElement;
      url := href_field.toString;
      Is_Find := (TypeSubHref = 1) and (url = SubHref);
      if not Is_Find then
        Is_Find := (TypeSubHref = 2) and (pos(SubHref, url) = 1);
      if not Is_Find then
        Is_Find := (TypeSubHref = 3) and (pos(SubHref, url) > 0);
      if not Is_Find then
        Is_Find := (TypeSubHref = 4) and (pos(SubHref, url) > 0) and (pos(SubHref, url) = length(url) - length(SubHref) + 1);
      if Is_Find then
      begin // ������� ����� ��������� ������
        WBContainer.MyElementClick(href_field);
        Result := WBContainer.HostedBrowser.Document as IHTMLDocument2;
        exit;
      end;
    end; // ���� �� ���� ������� ���������
  end;
end;

function get_race_from_KarteT36(document: IHTMLDocument2): integer;
// ����������� ���� �� �����

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
  begin // ���� ����� �� ��������, ������ ��������� � ��� �����������
    field_Element := (document as IHTMLDocument3).getElementById('a_3_3');
    // ����� �����
    url := field_Element.toString; // ������ �� ���������
    url := copy(url, pos('?', url) + 1); // ������ ��� �������

    field_Element := (document as IHTMLDocument3).getElementById('map');
    // ������ ��� ����� ������ ������
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
    begin // ������ ��� ������ �� ���� ������� ����
      // �� �������� �� �����������������
      // ��� ����� ����� ����� � �� ��� �������!  ���� ������� :) �� ��������� �����...
      tmp_txt := field_Element.innerHTML;
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // ��������� ������ ������ �����
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // ��������� ������ ������ �����
      tmp_txt := copy(tmp_txt, pos(']]', tmp_txt) + 3);
      // ��������� ������ ������ �����
      tmp_txt := copy(tmp_txt, 1, pos(']]', tmp_txt) + 1); // ����� 4-� ������
      // �������� � 4-� �������
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // ��������� ������ ������� �����
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // ��������� ������ ������� �����
      tmp_txt := copy(tmp_txt, pos(']', tmp_txt) + 2);
      // ��������� ������ ������� �����
      tmp_txt := copy(tmp_txt, 1, pos(']', tmp_txt)); // ����� 4-� �������
      // � ������ ����� �� ��� ��� �����
      // [X,Y,?,?,"URL","?","������������_�������","�����","���������","?",����]
      //  ���� = 1 - ���  2 - ������   3 - ����
      Race_String := copy(tmp_txt, length(tmp_txt) - 1, 1);
      Result := StrToInt(Race_String);
    end;
  end; // if Assigned(Karte_document)
end;

function Prepare_Contract(Contract_Collection :IHTMLElementCollection; FLog: TStringList): TBuildReturn_Code;
var
  Tmp_Collection : IHTMLElementCollection;
  field_Element :IHTMLElement;
  field_contractCosts :IHTMLElement;
  field_contractLink :IHTMLElement;
  field_Span :IHTMLElement;
  field_ShowCosts :IHTMLElement;
  ItemNumber: integer;
  Tmp_string: string;
begin
  Result.Return_Code:=0;
  Result.R1:=0;
  Result.R2:=0;
  Result.R3:=0;
  Result.R4:=0;
  Result.Duration:=0;
  Result.Wait:=0;
  Result.Text:='';

  Flog.Add('���� contractCosts � contractLink');     //<div class=....
  field_contractCosts:=nil;
  field_contractLink:=nil;
  field_Span:=nil;
  for ItemNumber := 0 to Contract_Collection.Length - 1 do
  begin
    field_Element := Contract_Collection.item(ItemNumber, '') as IHTMLElement;
    if Uppercase(field_Element.className) = 'CONTRACTCOSTS' then
      field_contractCosts:=field_Element
    else if Uppercase(field_Element.className) = 'CONTRACTLINK' then
      field_contractLink:=field_Element
    else if Uppercase(field_Element.tagName) = 'SPAN' then
      field_Span:=field_Element;

    if Assigned(field_Span) or (Assigned(field_contractCosts) and Assigned(field_contractLink)) then break;
  end;

  if Assigned(field_Span) then
  begin   // �������� ������������� ������
    Result.Text:=field_Span.innerText;
    Result.Return_Code:=1;
    exit;
  end;


  if not Assigned(field_contractCosts) then
  begin
    Flog.Add('�� �����  <div class="contractCosts">');
    Result.Return_Code:=-1;
    exit;
  end;


  Flog.Add('��������� contractCosts');             //<div class="contractCosts"
  Flog.Add('���� <div class="showCosts"...>');     //<div class="contractCosts"
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
    Flog.Add('�� ����� <div class="showCosts"...>');
    Result.Return_Code:=-2;
    exit;
  end;

  Flog.Add('��������� <div class="showCosts"...>');
  Tmp_Collection := field_ShowCosts.children as IHTMLElementCollection;
  for ItemNumber := 0 to Tmp_Collection.Length - 1 do
  begin
    field_Element := Tmp_Collection.item(ItemNumber, '') as IHTMLElement;

    if copy(Uppercase(field_Element.className),1,12) = 'RESOURCES R1' then
    begin
      Flog.Add('����� <span class="resources r1..."...>');
      Tmp_string:=field_Element.innerText;
      Result.R1:=StrToInt(Tmp_string);
      //  �������� ����� �������???
      if Uppercase(field_Element.className) <> 'RESOURCES R1' then
        Result.R1:=-Result.R1;
    end;

    if copy(Uppercase(field_Element.className),1,12) = 'RESOURCES R2' then
    begin
      Flog.Add('����� <span class="resources r2..."...>');
      Tmp_string:=field_Element.innerText;
      Result.R2:=StrToInt(Tmp_string);
      //  �������� ����� �������???
      if Uppercase(field_Element.className) <> 'RESOURCES R2' then
        Result.R2:=-Result.R2;
    end;

    if copy(Uppercase(field_Element.className),1,12) = 'RESOURCES R3' then
    begin
      Flog.Add('����� <span class="resources r3..."...>');
      Tmp_string:=field_Element.innerText;
      Result.R2:=StrToInt(Tmp_string);
      //  �������� ����� �������???
      if Uppercase(field_Element.className) <> 'RESOURCES R3' then
        Result.R3:=-Result.R3;
    end;

    if copy(Uppercase(field_Element.className),1,12) = 'RESOURCES R4' then
    begin
      Flog.Add('����� <span class="resources r4..."...>');
      Tmp_string:=field_Element.innerText;
      Result.R4:=StrToInt(Tmp_string);
      //  �������� ����� �������???
      if Uppercase(field_Element.className) <> 'RESOURCES R4' then
        Result.R4:=-Result.R4;
    end;

    if copy(Uppercase(field_Element.className),1,12) = 'RESOURCES R5' then
    begin
      Flog.Add('����� <span class="resources r5..."...>');
      Tmp_string:=field_Element.innerText;
      Result.R5:=StrToInt(Tmp_string);
      //  �������� ����� �������???
      if Uppercase(field_Element.className) <> 'RESOURCES R5' then
        Result.R5:=-Result.R5;
    end;

    if Uppercase(field_Element.className) = 'CLOCKS' then
    begin
      Flog.Add('����� <span class="clocks"...>');
      Tmp_string:=field_Element.innerText;
      Result.Duration:=StrToInt(copy(Tmp_string,1,pos(':',Tmp_string)-1))*24*60;
      Tmp_string:= Copy(Tmp_string,pos(':',Tmp_string)+1);
      Result.Duration:= Result.Duration + StrToInt(copy(Tmp_string,1,pos(':',Tmp_string)-1))*60;
      Tmp_string:= Copy(Tmp_string,pos(':',Tmp_string)+1);
      Result.Duration:= Result.Duration + StrToInt(Tmp_string);
    end;
  end;

  if (Result.r5 < 0) then Result.Return_Code:=3
  else if (Result.r1 < 0) or (Result.r2 < 0) or (Result.r3 < 0) or (Result.r4 < 0) then Result.Return_Code:=2;

  if not Assigned(field_contractLink) then
  begin
    Flog.Add('�� �����  <div class="contractLink">');
    Result.Return_Code:=-1;
    exit;
  end;

  Flog.Add('��������� contractLink');             //<div class="contractLink"

  Tmp_Collection:=field_contractLink.children as IHTMLElementCollection;
  field_Element:=Tmp_Collection.item(0,'') as IHTMLElement;
  if Uppercase(field_Element.tagName) = 'SPAN' then
  begin
    Result.Wait:=1*60*35;                    // ����� 35 �����!!!!!! �������� �� �������� ���� ��� ����� ���-�� ���������� �� field_Element.innerText
    Result.Text:=field_Element.innerText;
    if Result.Return_Code = 0 then Result.Return_Code:=4;
  end;
end;

function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], -1, @Result[1], l - 1, nil, nil);
  end;
end; { WideStringToString }

end.

