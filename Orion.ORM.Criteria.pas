unit Orion.ORM.Criteria;

interface

uses
  System.SysUtils,
  System.Variants,
  Orion.ORM.Interfaces;

type
  TOrionORMCriteria = class(TInterfacedObject, iOrionCriteria)
  private
    function GetWhereClause(aKeys : TKeys; aValues : TKeysValues) : string;
  public
    class function New : iOrionCriteria;

    function BuildSelect(aMapper : iOrionORMMapper; aWhere : string) : TSelects; overload;
    function BuildSelect(aMapper : iOrionORMMapper; aKeys : TKeys; aValues : TKeysValues) : string; overload;
    function BuildDelete(aMapper : iOrionORMMapper) : TSelects;
  end;

implementation

{ TOrionORMCriteria }

uses Orion.ORM.Utils, Orion.ORM.Types;

function TOrionORMCriteria.BuildDelete(aMapper : iOrionORMMapper) : TSelects;
begin

end;

function TOrionORMCriteria.BuildSelect(aMapper: iOrionORMMapper; aWhere: string): TSelects;
begin

end;

function TOrionORMCriteria.BuildSelect(aMapper: iOrionORMMapper; aKeys: TKeys; aValues: TKeysValues): string;
var
  MapperValue: TMapperValue;
  Select : string;
  AssociationMappers : array of iOrionORMMapper;
begin
  Select := '';
  if aMapper.Items.Count = 0 then
    Exit;

  Select := 'SELECT ';
  for MapperValue in aMapper.Items do
  begin
    if Assigned(MapperValue.Mapper) then
    begin
      SetLength(AssociationMappers, Length(AssociationMappers) + 1);
      AssociationMappers[Pred(Length(AssociationMappers))] := MapperValue.Mapper;
      Continue;
    end;

    if Select <> 'SELECT ' then
      Select := Select + ', ';

    Select := Select + ' ' + MapperValue.TableFieldName;
  end;

  Select := Select + ' FROM ' + aMapper.TableName;

  if GetArraySize(aKeys) = 0 then
    raise OrionORMException.Create('Keys not assigned.');

  Select := Select + GetWhereClause(aKeys, aValues);
  Result := Select;

//  if Length(AssociationMappers) > 0 then
//  begin
//    for Mapper in AssociationMappers do
//    begin
//      SetLength(Result, Length(Result) + 1);
//      Result[Pred(Length(Result))].Key := Mapper.TableName;
//      Result[Pred(Length(Result))].Value := BuildSelect();
//    end;
//  end;
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
