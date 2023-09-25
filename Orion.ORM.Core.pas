unit Orion.ORM.Core;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Orion.ORM.Interfaces,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Types,
  Orion.ORM.Reflection;

type
  TOrionORMCore<T : class, constructor> = class
  private
    FMapper : iOrionORMMapper;
    FCriteria : iOrionCriteria;
    FDBConnection : iDBConnection;
    FReflection : TOrionORMReflection;
  public
    constructor Create(aCriteria : iOrionCriteria; aDBConnection : iDBConnection);
    destructor Destroy; override;

    procedure Mapper(aValue : iOrionORMMapper); overload;
    function Mapper : iOrionORMMapper; overload;
    function Find : TObjectList<T>; overload;
    function Find(aPrimaryKeyValues : TKeysValues) : T; overload;
    function FindOneWithWhere(aWhere : string) : T;
    function FindManyWithWhere(aWhere : string) : TObjectList<T>;
    procedure Save(aValue : T);
    procedure Delete(aID : Variant); overload;
    procedure Delete(aEntity : T); overload;
  end;

implementation

{ TOrionORMCore<T> }

uses Orion.ORM.Utils;

constructor TOrionORMCore<T>.Create(aCriteria : iOrionCriteria; aDBConnection : iDBConnection);
begin
  if not Assigned(aCriteria) then
    raise OrionORMException.Create('Criteria not assigned.');

  if not Assigned(aDBConnection) then
    raise OrionORMException.Create('DBConnection not assigned.');

  FCriteria := aCriteria;
  FDBConnection := aDBConnection;
  FReflection := TOrionORMReflection.Create;
end;

procedure TOrionORMCore<T>.Delete(aEntity: T);
begin

end;

procedure TOrionORMCore<T>.Delete(aID: Variant);
begin

end;

destructor TOrionORMCore<T>.Destroy;
begin
  FReflection.DisposeOf;
  inherited;
end;

function TOrionORMCore<T>.Find(aPrimaryKeyValues : TKeysValues): T;
var
  Dataset : iDataset;
  PrimaryKeys : TKeys;
  Select : string;
  Mappers : TMappers;
begin
  if not FMapper.ContainsPrimaryKey then
    raise OrionORMException.Create('The Mapper not contains a Primary Key');

  if FMapper.ContainsEmptyEntityFieldName then
    raise OrionORMException.Create('The Mapper contains empty Entity Field Name');

  if FMapper.ContainsEmptyTableFieldName then
    raise OrionORMException.Create('The Mapper contains empty Table Field Name');

  Dataset := FDBConnection.NewDataset;

  PrimaryKeys := FMapper.GetPrimaryKeyTableFieldName;
  Select := FCriteria.BuildSelect(FMapper, PrimaryKeys, aPrimaryKeyValues);

  Dataset.Statement(Select);
  Dataset.Open;

  Result := T.Create;
  FReflection.DatasetToObject(Dataset, Result, FMapper);
  Mappers := FMapper.GetOneToManyMappers;
  if Length(Mappers) > 0 then
  begin

  end;
end;

function TOrionORMCore<T>.Find: TObjectList<T>;
begin
  Result := TObjectList<T>.Create;
end;

function TOrionORMCore<T>.FindManyWithWhere(aWhere: string): TObjectList<T>;
begin

end;

function TOrionORMCore<T>.FindOneWithWhere(aWhere: string): T;
begin

end;

procedure TOrionORMCore<T>.Mapper(aValue: iOrionORMMapper);
begin
  FMapper := aValue;
  if FMapper.ClassType = nil then
    FMapper.ClassType(T);
end;

function TOrionORMCore<T>.Mapper: iOrionORMMapper;
begin
  Result := FMapper;
end;

procedure TOrionORMCore<T>.Save(aValue: T);
begin

end;

end.
