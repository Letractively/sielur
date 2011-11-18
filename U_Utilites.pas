unit U_Utilites;

interface

uses
  Windows, ActiveX, ShDocVw,MSHTML, Classes, UContainer;

  function WB_GetHTMLCode(WBContainer: TWBContainer; var ACode: String): Boolean;
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
     if Result then ACode := ss.Datastring;
   finally
     ss.Free;
   end;
 end;
end.
