unit MyIniFile;

interface
uses IniFiles;

type
TMyIniFile=class(TIniFile)
  public
    function ReadUTF8(const Section: string; const Ident: string; const Default: string):String;
    procedure WriteUTF8(const Section: string; const Ident: string; const Value: string);
    procedure WriteProperty(const Section: string; const Ident: string; Obj:TObject; const Property_Name: string);
    procedure LoadProperty(const Section: string; const Ident: string;  Obj:TObject; const Property_Name: string;const Default: string);
end;

implementation
uses Classes,SysUtils,TypInfo;

{ TMyIniFile }

procedure TMyIniFile.LoadProperty(const Section, Ident: string; Obj: TObject;
  const Property_Name: string;const Default: string);
var
   PropInfo: PPropInfo;
   IntValue: Integer;
   StrValue: string;
   FloatValue: Extended;
begin
//
  PropInfo := GetPropInfo(Obj.ClassInfo, Property_Name);
  if PropInfo^.SetProc <> nil then
  begin
    if PropInfo^.PropType^.Kind in tkProperties then
    begin
      case PropInfo^.PropType^.Kind of
        tkInteger, tkChar, tkWChar:
        begin
          IntValue := Self.ReadInteger( Section, Ident, StrToInt(Default));
          SetOrdProp( Obj, PropInfo, IntValue );
        end;

        tkEnumeration:
        begin
          StrValue := Self.ReadUTF8( Section, Ident, Default );
          SetEnumProp( Obj, PropInfo, StrValue );
        end;

        tkSet:
        begin
          StrValue := Self.ReadUTF8( Section, Ident, Default );
          SetSetProp( Obj, PropInfo, StrValue );
        end;

        tkFloat:
        begin
          FloatValue := Self.ReadFloat( Section, Ident, StrToFloat(Default));
          SetFloatProp( Obj, PropInfo, FloatValue );
        end;

        tkString, tkLString:
        begin
          StrValue := Self.ReadUTF8( Section, Ident, Default );
          SetStrProp( Obj, PropInfo, StrValue );
        end;

        tkWString:
        begin
          StrValue := Self.ReadUTF8( Section, Ident, Default );
          SetWideStrProp( Obj, PropInfo, StrValue );
        end;

        {$IFDEF UNICODE}
        tkUString:
        begin
          StrValue := Self.ReadUTF8( Section, Ident, Default);
          SetUnicodeStrProp( Obj, PropInfo, StrValue );
        end;
        {$ENDIF}
      end;
    end;
  end;
end;

function TMyIniFile.ReadUTF8(const Section, Ident, Default: string): String;
var
  StrStream:TStringStream;
  s:string;
begin
 Result:='';
 StrStream := TStringStream.Create(s,TEncoding.UTF8);
 try
   self.ReadBinaryStream(Section,Ident,StrStream);
   Result:=StrStream.DataString;
 finally
   StrStream.Free;
   if Result = '' then Result:=Default;
 end;
end;

procedure TMyIniFile.WriteProperty(const Section, Ident: string;
   Obj: TObject; const Property_Name: string);
var
   PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Obj.ClassInfo,Property_Name);



  if PropInfo^.GetProc <> nil then
  begin
    if PropInfo^.PropType^.Kind in tkProperties then
    begin
      case PropInfo^.PropType^.Kind of
        tkInteger, tkChar, tkWChar:
          Self.WriteInteger( Section, Ident, GetOrdProp( Obj, PropInfo ) );
        tkEnumeration:
          Self.WriteUTF8( Section, Ident, GetEnumProp( Obj, PropInfo ) );
        tkSet:
          Self.WriteUTF8( Section, Ident, GetSetProp( Obj, PropInfo ) );
        tkFloat:
          Self.WriteFloat( Section, Ident, GetFloatProp( Obj, PropInfo ) );
        tkString, tkLString:
          Self.WriteUTF8( Section, Ident, GetStrProp( Obj, PropInfo ) );
        tkWString:
          Self.WriteUTF8( Section, Ident, GetWideStrProp( Obj, PropInfo ) );
        {$IFDEF UNICODE}
        tkUString:
          Self.WriteUTF8( Section, Ident, GetUnicodeStrProp( Obj, PropInfo ) );
        {$ENDIF}
      end;
    end;
  end;

end;

procedure TMyIniFile.WriteUTF8(const Section, Ident, Value: string);
var
  StrStream:TStringStream;
begin
 StrStream := TStringStream.Create(Value,TEncoding.UTF8);
 Self.WriteBinaryStream(Section,Ident,StrStream);
 StrStream.Free;end;
end.
