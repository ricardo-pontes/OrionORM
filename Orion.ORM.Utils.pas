unit Orion.ORM.Utils;

interface

uses
  Orion.ORM.Interfaces;

function GetArraySize(aValue : array of string) : integer;
function ArrayStrToStr(aKeys : TKeys) : string;

implementation

function GetArraySize(aValue : array of string): integer;
begin
  Result := Length(aValue);
end;

function ArrayStrToStr(aKeys : TKeys) : string;
var
  Key : string;
begin
  Result := '';
  for Key in aKeys do
  begin
    if Result = '' then
      Result := Key
    else
     Result := Result + ';' + Key;
  end;
end;

end.
