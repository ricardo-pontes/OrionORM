unit Orion.ORM.Utils;

interface

function GetArraySize(aValue : array of string) : integer;

implementation

function GetArraySize(aValue : array of string): integer;
begin
  Result := Length(aValue);
end;

end.
