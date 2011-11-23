unit U_Utilites;

interface

uses
  Windows, ActiveX, ShDocVw,MSHTML, Classes, UContainer, SysUtils, Dialogs;

  function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: String): Boolean;
  function bild_lvl(s: string): integer;
implementation

  //функция  получает Текст странички из Веббраузера
  function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: String): Boolean;
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
     if Result then ACode := Utf8ToAnsi(ss.Datastring);
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
end.
