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
    FPagination : iOrionPagination;
  private
    procedure ValidateMapper;
  public
    constructor Create(aCriteria : iOrionCriteria; aDBConnection : iDBConnection); overload;
    constructor Create(aCriteria : iOrionCriteria; aDBConnection : iDBConnection; aPagination : iOrionPagination); overload;
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

constructor TOrionORMCore<T>.Create(aCriteria: iOrionCriteria; aDBConnection: iDBConnection; aPagination: iOrionPagination);
begin
  if not Assigned(aCriteria) then
    raise OrionORMException.Create('Criteria not assigned.');

  if not Assigned(aDBConnection) then
    raise OrionORMException.Create('DBConnection not assigned.');

  FCriteria := aCriteria;
  FDBConnection := aDBConnection;
  FPagination := aPagination;
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
  Dataset, OneToManyDataset : iDataset;
  PrimaryKeys, OwnerKeyFields : TKeys;
  OwnerKeyValues : TKeysValues;
  Select : string;
  Mappers : TMappers;
  Mapper : iOrionORMMapper;
  Key: string;
begin
  ValidateMapper;
  Dataset := FDBConnection.NewDataset;

  PrimaryKeys := FMapper.GetPrimaryKeyTableFieldName;
  Select := FCriteria.BuildSelect(FMapper, PrimaryKeys, aPrimaryKeyValues);

  Dataset.Statement(Select);
  Dataset.Open;

  Result := FReflection.CreateClass(FMapper.ClassType) as T;
  FReflection.DatasetToObject(Dataset, Result, FMapper);
  Mappers := FMapper.GetOneToManyMappers;
  if Length(Mappers) > 0 then
  begin
    for Mapper in Mappers do
    begin
      OneToManyDataset := FDBConnection.NewDataset;
      OwnerKeyFields := FMapper.GetAssociationOwnerKeyFields(Mapper);
      for Key in OwnerKeyFields do
      begin
        SetLength(OwnerKeyValues, Length(OwnerKeyValues) + 1);
        OwnerKeyValues[Pred(Length(OwnerKeyValues))] := Dataset.FieldByName(Key).AsVariant;
      end;

      Select := FCriteria.BuildSelect(Mapper, FMapper.GetAssociationChildKeyFields(Mapper), OwnerKeyValues);
      OneToManyDataset.Statement(Select);
      OneToManyDataset.Open;

      FReflection.ClearList(FMapper.GetAssociationObjectListFieldName(Mapper), Result);
      OneToManyDataset.First;
      while not OneToManyDataset.Eof do
      begin
        var ChildObject := FReflection.CreateClass(Mapper.ClassType);
        FReflection.DatasetToObject(OneToManyDataset, ChildObject, Mapper);
        FReflection.IncObjectInList(FMapper.GetAssociationObjectListFieldName(Mapper), Result, ChildObject);
        OneToManyDataset.Next;
      end;
    end;
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
var
  Mapper: TObject;
begin
  FMapper := aValue;
  if FMapper.ClassType = nil then
    FMapper.ClassType := T;
end;

function TOrionORMCore<T>.Mapper: iOrionORMMapper;
begin
  Result := FMapper;
end;

procedure TOrionORMCore<T>.Save(aValue: T);
begin

end;

procedure TOrionORMCore<T>.ValidateMapper;
begin
  if not FMapper.ContainsPrimaryKey then
    raise OrionORMException.Create('The Mapper not contains a Primary Key');

  if FMapper.ContainsEmptyEntityFieldName then
    raise OrionORMException.Create('The Mapper contains empty Entity Field Name');

  if FMapper.ContainsEmptyTableFieldName then
    raise OrionORMException.Create('The Mapper contains empty Table Field Name');

end;

end.
