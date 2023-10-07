unit Orion.ORM.Criteria;

interface

uses
  System.SysUtils,
  System.Variants,
  Orion.ORM.Interfaces;

type
  TOrionORMCriteria = class(TInterfacedObject, iOrionCriteria)
  private
    function BuildBaseSelect (aMapper : iOrionORMMapper): string;
    function GetWhereClause(aKeys : TKeys; aValues : TKeysValues) : string;
  public
    class function New : iOrionCriteria;

    function BuildSelect(aMapper : iOrionORMMapper) : string; overload;
    function BuildSelect(aMapper : iOrionORMMapper; aWhere : string) : TSelects; overload;
    function BuildSelect(aMapper : iOrionORMMapper; aKeys : TKeys; aValues : TKeysValues) : string; overload;
    function BuildDelete(aMapper : iOrionORMMapper) : TSelects;
  end;

implementation

{ TOrionORMCriteria }

uses Orion.ORM.Utils, Orion.ORM.Types;

function TOrionORMCriteria.BuildBaseSelect(aMapper : iOrionORMMapper): string;
var
  MapperValue: TMapperValue;
  AssociationMappers : array of iOrionORMMapper;
begin
  Result := 'SELECT ';
  for MapperValue in aMapper.Items do
  begin
    if Assigned(MapperValue.Mapper) then
    begin
      SetLength(AssociationMappers, Length(AssociationMappers) + 1);
      AssociationMappers[Pred(Length(AssociationMappers))] := MapperValue.Mapper;
      Continue;
    end;

    if Result <> 'SELECT ' then
      Result := Result + ', ';

    Result := Result + ' ' + MapperValue.TableFieldName;
  end;

  Result := Result + ' FROM ' + aMapper.TableName;
end;

function TOrionORMCriteria.BuildDelete(aMapper : iOrionORMMapper) : TSelects;
begin

end;

function TOrionORMCriteria.BuildSelect(aMapper: iOrionORMMapper; aWhere: string): TSelects;
begin

end;

function TOrionORMCriteria.BuildSelect(aMapper: iOrionORMMapper; aKeys: TKeys; aValues: TKeysValues): string;
var
  Select : string;
begin
  Select := '';
  if aMapper.Items.Count = 0 then
    Exit;

  Select := BuildBaseSelect(aMapper);
  Select := Select + GetWhereClause(aKeys, aValues);
  Result := Select;

end;

function TOrionORMCriteria.BuildSelect(aMapper: iOrionORMMapper): string;
begin
  Result := '';
  if aMapper.Items.Count = 0 then
    Exit;

  Result := BuildBaseSelect(aMapper);
end;

function TOrionORMCriteria.GetWhereClause(aKeys: TKeys; aValues: TKeysValues): string;
var
  I : integer;
begin
  Result := ' WHERE ';
  for I := 0 to Pred(Length(aKeys)) do
    Result := Result + aKeys[I] + ' = ' +  VarToStr(aValues[I]);
end;

class function TOrionORMCriteria.New: iOrionCriteria;
begin
  Result := Self.Create;
end;

end.
