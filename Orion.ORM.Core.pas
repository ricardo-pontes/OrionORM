unit Orion.ORM.Core;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  Orion.ORM.Interfaces,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Types,
  Orion.ORM.Reflection,
  Data.DB;

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
    procedure OpenDataset(var aDataset : iDataset; aMapper : iOrionORMMapper; aWhere : string = ''); overload;
    procedure OpenDataset(var aDataset : iDataset; aPrimaryKeys : TKeys; aPrimaryKeysValues : TKeysValues); overload;
    procedure OpenDataset(var aDataset : iDataset; aMapper, aChildMapper : iOrionORMMapper; aOwnerKeyValues : TKeysValues); overload;
    procedure SetOwnerKeyValues(aOwnerKeyFields : TKeys; var aOwnerKeyValues : TKeysValues; aDataset : iDataset);
    procedure LoadChildObjectList(aChildMapper : iOrionORMMapper; aOwnerObject : TObject; aOwnerDataset : iDataset);
    procedure SaveChildObjectList(aChildMapper : iOrionORMMapper; aOwnerObject : TObject; aOwnerDataset : iDataset);
    procedure DeleteChildObjectLists(aOneToManyMappers : TMappers; aOwnerDataset : iDataset);
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
    procedure Delete(aPrimaryKeyValues : TKeysValues); overload;
    procedure Delete(aEntity : T); overload;
    procedure Delete(aWhere : string); overload;
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

procedure TOrionORMCore<T>.Delete(aPrimaryKeyValues : TKeysValues);
var
  Keys : TKeys;
  Dataset, ChildDataset : iDataset;
  OneToManyMappers : TMappers;
  Mapper : iOrionORMMapper;
  OwnerKeysValues : TKeysValues;
begin
  Keys := FMapper.GetPrimaryKeyTableFieldName;
  OpenDataset(Dataset, Keys, aPrimaryKeyValues);
  OneToManyMappers := FMapper.GetOneToManyMappers;
  if Length(OneToManyMappers) > 0 then
    DeleteChildObjectLists(OneToManyMappers, Dataset);

  Dataset.Delete;
end;

procedure TOrionORMCore<T>.Delete(aWhere: string);
var
  Dataset : iDataset;
  OneToManyMappers : TMappers;
begin
  OpenDataset(Dataset, FMapper, aWhere);
  OneToManyMappers := FMapper.GetOneToManyMappers;
  if Length(OneToManyMappers) > 0 then
    DeleteChildObjectLists(OneToManyMappers, Dataset);

  Dataset.Delete;
end;

procedure TOrionORMCore<T>.DeleteChildObjectLists(aOneToManyMappers : TMappers; aOwnerDataset : iDataset);
var
  Keys : TKeys;
  Mapper : iOrionORMMapper;
  OwnerKeysValues : TKeysValues;
  ChildDataset : iDataset;
begin
  for Mapper in aOneToManyMappers do
  begin
    Keys := FMapper.GetAssociationOwnerKeyFields(Mapper);
    SetOwnerKeyValues(Keys, OwnerKeysValues, aOwnerDataset);
    OpenDataset(ChildDataset, FMapper, Mapper, OwnerKeysValues);
    ChildDataset.First;
    while ChildDataset.RecordCount > 0 do
      ChildDataset.Delete;
  end;
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
  OneToManyMappers : TMappers;
  Mapper : iOrionORMMapper;
begin
  ValidateMapper;
  PrimaryKeys := FMapper.GetFindKeys;

  if Length(PrimaryKeys) = 0 then
    PrimaryKeys := FMapper.GetPrimaryKeyTableFieldName;

  OpenDataset(Dataset, PrimaryKeys, aPrimaryKeyValues);
  Result := FReflection.CreateClass(FMapper.ClassType) as T;
  try
    FReflection.DatasetToObject(Dataset, Result, FMapper);
    OneToManyMappers := FMapper.GetOneToManyMappers;
    if Length(OneToManyMappers) > 0 then
    begin
      for Mapper in OneToManyMappers do
        LoadChildObjectList(Mapper, Result, Dataset);
    end;
  except on E: Exception do
    begin
      Result.DisposeOf;
      Result := nil;
    end;
  end;
end;

function TOrionORMCore<T>.Find: TObjectList<T>;
var
  Dataset : iDataset;
  Mappers : TMappers;
  Mapper : iOrionORMMapper;
begin
  ValidateMapper;
  OpenDataset(Dataset, FMapper);
  Result := TObjectList<T>.Create;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      var OwnerObject := FReflection.CreateClass(FMapper.ClassType) as T;
      FReflection.DatasetToObject(Dataset, OwnerObject, FMapper);
      Mappers := FMapper.GetOneToManyMappers;
      if Length(Mappers) > 0 then
      begin
        for Mapper in Mappers do
          LoadChildObjectList(Mapper, OwnerObject, Dataset);
      end;
      FReflection.IncObjectInList<T>(Result, OwnerObject);
      Dataset.Next;
    end;
  except on E: Exception do
    begin
      Result.DisposeOf;
      Result := nil;
    end;
  end;
end;

function TOrionORMCore<T>.FindManyWithWhere(aWhere: string): TObjectList<T>;
var
  Dataset : iDataset;
  Mappers : TMappers;
  Mapper : iOrionORMMapper;
begin
  ValidateMapper;
  OpenDataset(Dataset, FMapper, aWhere);
  Result := TObjectList<T>.Create;
    try
    Dataset.First;
    while not Dataset.Eof do
    begin
      var OwnerObject := FReflection.CreateClass(FMapper.ClassType) as T;
      FReflection.DatasetToObject(Dataset, OwnerObject, FMapper);
      Mappers := FMapper.GetOneToManyMappers;
      if Length(Mappers) > 0 then
      begin
        for Mapper in Mappers do
          LoadChildObjectList(Mapper, OwnerObject, Dataset);
      end;
      FReflection.IncObjectInList<T>(Result, OwnerObject);
      Dataset.Next;
    end;
  except on E: Exception do
    begin
      Result.DisposeOf;
      Result := nil;
    end;
  end;
end;

function TOrionORMCore<T>.FindOneWithWhere(aWhere: string): T;
var
  Dataset : iDataset;
  Mappers : TMappers;
  Mapper : iOrionORMMapper;
begin
  ValidateMapper;
  OpenDataset(Dataset, FMapper, aWhere);
  Result := FReflection.CreateClass(FMapper.ClassType) as T;
  try
    FReflection.DatasetToObject(Dataset, Result, FMapper);
    Mappers := FMapper.GetOneToManyMappers;
    if Length(Mappers) > 0 then
    begin
      for Mapper in Mappers do
        LoadChildObjectList(Mapper, Result, Dataset);
    end;
  except on E: Exception do
    begin
      Result.DisposeOf;
      Result := nil;
    end;
  end;
end;

procedure TOrionORMCore<T>.LoadChildObjectList(aChildMapper : iOrionORMMapper; aOwnerObject : TObject; aOwnerDataset : iDataset);
var
  OwnerKeyFields : TKeys;
  OwnerKeyValues : TKeysValues;
  Dataset : iDataset;
begin
  OwnerKeyFields := FMapper.GetAssociationOwnerKeyFields(aChildMapper);
  SetOwnerKeyValues(OwnerKeyFields, OwnerKeyValues, aOwnerDataset);
  OpenDataset(Dataset, FMapper, aChildMapper, OwnerKeyValues);
  FReflection.ClearList(FMapper.GetAssociationObjectListFieldName(aChildMapper), aOwnerObject);
  Dataset.First;
  while not Dataset.Eof do
  begin
    var ChildObject := FReflection.CreateClass(aChildMapper.ClassType);
    FReflection.DatasetToObject(Dataset, ChildObject, aChildMapper);
    FReflection.IncObjectInList(FMapper.GetAssociationObjectListFieldName(aChildMapper), aOwnerObject, ChildObject);
    Dataset.Next;
  end;
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

procedure TOrionORMCore<T>.OpenDataset(var aDataset: iDataset; aPrimaryKeys: TKeys; aPrimaryKeysValues: TKeysValues);
var
  Select : string;
begin
  aDataset := FDBConnection.NewDataset;
  Select := FCriteria.BuildSelect(FMapper, aPrimaryKeys, aPrimaryKeysValues);
  aDataset.Statement(Select);
  aDataset.Open;
end;

procedure TOrionORMCore<T>.OpenDataset(var aDataset: iDataset; aMapper, aChildMapper: iOrionORMMapper; aOwnerKeyValues : TKeysValues);
var
  Select : string;
begin
  Select := FCriteria.BuildSelect(aChildMapper, aMapper.GetAssociationChildKeyFields(aChildMapper), aOwnerKeyValues);
  aDataset := FDBConnection.NewDataset;
  aDataset.Statement(Select);
  aDataset.Open;
end;

procedure TOrionORMCore<T>.OpenDataset(var aDataset : iDataset; aMapper : iOrionORMMapper; aWhere : string);
var
  Select : string;
begin
  Select := FCriteria.BuildSelect(aMapper, aWhere);
  aDataset := FDBConnection.NewDataset;
  aDataset.Statement(Select);
  aDataset.Open;
end;

procedure TOrionORMCore<T>.Save(aValue: T);
var
  Dataset : iDataset;
  PrimaryKeys : TKeys;
  TableKeys : TKeys;
  KeysValues : TKeysValues;
  OneToManyMappers : TMappers;
  Mapper : iOrionORMMapper;
  Mappers : TMappers;
begin
  ValidateMapper;
  PrimaryKeys := FMapper.GetPrimaryKeyEntityFieldName;
  TableKeys := FMapper.GetPrimaryKeyTableFieldName;
  KeysValues := FReflection.GetPrimaryKeyEntityFieldValues(PrimaryKeys, aValue);
  OpenDataset(Dataset, TableKeys, KeysValues);

  if Dataset.RecordCount = 0 then
    Dataset.Append
  else
    Dataset.Edit;

  FReflection.ObjectToDataset(aValue, Dataset, FMapper);
  Dataset.Post;
  FReflection.RefreshEntityPrimaryKeysValues(Dataset, aValue, FMapper);
  Mappers := FMapper.GetOneToManyMappers;
  if Length(Mappers) > 0 then
  begin
    for Mapper in Mappers do
      SaveChildObjectList(Mapper, aValue, Dataset);
  end;
end;

procedure TOrionORMCore<T>.SaveChildObjectList(aChildMapper: iOrionORMMapper; aOwnerObject: TObject; aOwnerDataset: iDataset);
var
  OwnerKeyFields, ChildTableKeyFields, ChildKeyFields : TKeys;
  OwnerKeyValues, ChildTableKeyValues, ChildKeyValues, UpdatedRecord : TKeysValues;
  Dataset : iDataset;
  ObjectList : TObjectList<TObject>;
  Obj : TObject;
  UpdatedRecords : TDictionary<TKeysValues, boolean>;
  isEmptyDataset : boolean;
  KeyField : string;
  isInsert : boolean;
begin
  isEmptyDataset := False;
  OwnerKeyFields := FMapper.GetAssociationOwnerKeyFields(aChildMapper);
  SetOwnerKeyValues(OwnerKeyFields, OwnerKeyValues, aOwnerDataset);
  OpenDataset(Dataset, FMapper, aChildMapper, OwnerKeyValues);
  isEmptyDataset := Dataset.RecordCount = 0;
  ObjectList := FReflection.GetChildObjectList(FMapper, aChildMapper, aOwnerObject);

  if isEmptyDataset then
  begin
    for Obj in ObjectList do
    begin
      Dataset.Append;
      FReflection.ObjectToDataset(Obj, Dataset, aChildMapper);
      Dataset.Post;
      FReflection.RefreshEntityPrimaryKeysValues(Dataset, Obj, aChildMapper);
    end;
  end
  else
  begin
    UpdatedRecords := TDictionary<TKeysValues, boolean>.Create;
    try
      ChildTableKeyFields := aChildMapper.GetPrimaryKeyTableFieldName;
      ChildKeyFields := aChildMapper.GetPrimaryKeyEntityFieldName;
      Dataset.First;
      while not Dataset.Eof do
      begin
        SetLength(ChildTableKeyValues, 0);
        for KeyField in ChildTableKeyFields do
        begin
          SetLength(ChildTableKeyValues, Length(ChildTableKeyValues) + 1);
          ChildTableKeyValues[Pred(Length(ChildTableKeyValues))] := Dataset.FieldByName(KeyField).AsVariant;
        end;
        UpdatedRecords.Add(ChildTableKeyValues, False);
        Dataset.Next;
      end;

      for Obj in ObjectList do
      begin
        ChildKeyValues := FReflection.GetPrimaryKeyEntityFieldValues(ChildKeyFields, Obj);

        if Dataset.Locate(ArrayStrToStr(ChildTableKeyFields), ChildKeyValues, [loCaseInsensitive]) then
        begin
          isInsert := False;
          Dataset.Edit;
          UpdatedRecords.AddOrSetValue(ChildKeyValues, True);
        end
        else
        begin
          Dataset.Append;
          isInsert := True;
        end;

        FReflection.ObjectToDataset(Obj, Dataset, aChildMapper);
        Dataset.Post;
        if isInsert then
          FReflection.RefreshEntityPrimaryKeysValues(Dataset, Obj, aChildMapper);
      end;

      for UpdatedRecord in UpdatedRecords.Keys do begin
        if not UpdatedRecords.Items[UpdatedRecord] then begin
          Dataset.Locate(ArrayStrToStr(ChildTableKeyFields), UpdatedRecord, [loCaseInsensitive]);
          Dataset.Delete;
        end;
      end;
    finally
      UpdatedRecords.DisposeOf;
    end;
  end;
end;

procedure TOrionORMCore<T>.SetOwnerKeyValues(aOwnerKeyFields : TKeys; var aOwnerKeyValues : TKeysValues; aDataset : iDataset);
var
  Key : string;
begin
  for Key in aOwnerKeyFields do
  begin
    SetLength(aOwnerKeyValues, Length(aOwnerKeyValues) + 1);
    aOwnerKeyValues[Pred(Length(aOwnerKeyValues))] := aDataset.FieldByName(Key).AsVariant;
  end;
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
