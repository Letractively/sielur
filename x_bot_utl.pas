unit
  x_bot_utl;

interface

uses
  RzTreeVw
  , ComCtrls
  //  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  //  Dialogs, ExtCtrls, Menus, StdCtrls, RzPanel, IniFiles, RzTabs,
  //  RzCommon, RzSplit, OleCtrls, SHDocVw,
  //  UContainer, Account_data, Add_User_Form,
  //  mshtml, MyIniFile, Account_Frame,Trava_Class, , ActnList ;
  ;

  function SecondsTime(const IValue: Double) : Double;

implementation

function SecondsTime(const IValue: Double) : Double;
begin
  result:= IValue/24.0/60.0/60.0;
end;

end.

