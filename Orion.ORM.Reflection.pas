unit Orion.ORM.Reflection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.Generics.Collections,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Interfaces,
  Orion.ORM.Types,
  Data.DB;

type
  TGetProperty = record
    Obj : TObject;
    Prop : TRttiProperty;
  end;

  TOrionORMReflection = class
  private
    function GetProperty(aObject : TObject; aEntityFieldName : string) : TGetProperty;
    function GetTableFieldName(aTableFieldName : string) : string;
  public
    procedure DatasetToObject(aDataset : iDataset; aObject : TObject; aMapper : iOrionORMMapper);
    function CreateClass(aClassType : TClass): TObject;
    procedure ClearList(aEntityFieldName: string; aObject : TObject);
    procedure IncObjectInList(aEntityFieldName: string; aOwnerObjectList, aChildObject: TObject); overload;
    procedure IncObjectInList<T:class>(aObjectList : TObjectList<T>; aObject: TObject); overload;
    function GetPrimaryKeyEntityFieldValues(aKeys : TKeys; aObject : TObject) : TKeysValues;
    function GetChildObjectList (aMapper, aChildMapper: iOrionORMMapper; aOwnerObject: TObject): TObjectList<TObject>;
    procedure ObjectToDataset(aObject : TObject; aDataset : iDataset; aMapper : iOrionORMMapper);
    procedure RefreshEntityPrimaryKeysValues(aDataset: iDataset; aObject: TObject; aMapper : iOrionORMMapper);
  end;


implementation

{ TOrionORMReflection }

procedure TOrionORMReflection.ClearList(aEntityFieldName: string; aObject : TObject);
var
  RttiProperty : TGetProperty;
begin
  RttiProperty := GetProperty(aObject, aEntityFieldName);
  TObjectList<TObject>(RttiProperty.Prop.GetValue(RttiProperty.Obj).AsObject).Clear;
end;

function TOrionORMReflection.CreateClass(aClassType : TClass): TObject;
var
  RttiType : TRttiType;
  RttiMethod: TRttiMethod;
begin
  Result := nil;
  RttiType := TRttiContext.Create.GetType(aClassType);
  for RttiMethod in RttiType.GetMethods do
  begin
    if RttiMethod.IsConstructor then
    begin
      Result := RttiMethod.Invoke(aClassType, []).AsObject;
      Exit;
    end;
  end;

end;

procedure TOrionORMReflection.DatasetToObject(aDataset : iDataset; aObject : TObject; aMapper : iOrionORMMapper);
var
  RttiProperty : TGetProperty;
  MapperValue: TMapperValue;
begin
  for MapperValue in aMapper.Items do
  begin
    if MapperValue.TableFieldName = '' then
      Continue;

    RttiProperty := GetProperty(aObject, MapperValue.EntityFieldName);
    if not Assigned(RttiProperty.Prop) then
      raise OrionORMException.Create('Entity Field Name ' + MapperValue.EntityFieldName + ' not found.');

    if not aDataset.FieldExist(MapperValue.TableFieldName) then
      raise OrionORMException.Create('Table Field Name ' + MapperValue.TableFieldName + ' not found.');

    if not RttiProperty.Prop.IsWritable then
      Continue;

    case RttiProperty.Prop.PropertyType.TypeKind of
      tkUnknown: ;
      tkInteger: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsInteger);
      tkChar: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkEnumeration: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsBoolean);
      tkFloat: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsExtended);
      tkString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkSet: ;
      tkClass: ;
      tkMethod: ;
      tkWChar: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkLString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkWString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkVariant: ;
      tkArray: ;
      tkRecord: ;
      tkInterface: ;
      tkInt64: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsLargeInt);
      tkDynArray: ;
      tkUString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(MapperValue.TableFieldName).AsString);
      tkClassRef: ;
      tkPointer: ;
      tkProcedure: ;
      tkMRecord: ;
    end;
  end;
end;

function TOrionORMReflection.GetChildObjectList(aMapper, aChildMapper: iOrionORMMapper; aOwnerObject: TObject): TObjectList<TObject>;
var
  MapperValue: TMapperValue;
  ResultGetProperty : TGetProperty;
begin
  for MapperValue in aMapper.Items do
  begin
    if MapperValue.Mapper <> aChildMapper then
      Continue;

    ResultGetProperty := GetProperty(aOwnerObject, MapperValue.EntityFieldName);
    Result := TObjectList<TObject>(ResultGetProperty.Prop.GetValue(Pointer(ResultGetProperty.Obj)).AsObject);
    Exit;
  end;
end;

function TOrionORMReflection.GetPrimaryKeyEntityFieldValues(aKeys : TKeys; aObject : TObject) : TKeysValues;
var
  Key: string;
  ResultGetProperty : TGetProperty;
begin
  Result := [];
  for Key in aKeys do
  begin
    ResultGetProperty := GetProperty(aObject, Key);
    SetLength(Result, Length(Result) + 1);
    Result[Pred(Length(Result))] := ResultGetProperty.Prop.GetValue(Pointer(aObject)).AsVariant;
  end;
end;

function TOrionORMReflection.GetProperty(aObject : TObject; aEntityFieldName : string) : TGetProperty;
var
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  Strings : TArray<string>;
  I : integer;
begin
  Result.Obj := nil;
  Result.Prop := nil;
  RttiContext := TRttiContext.Create;
  RttiType := RttiContext.GetType(aObject.ClassInfo);
  if aEntityFieldName.Contains('.') then
  begin
    Strings := aEntityFieldName.Split(['.']);
    for I := 0 to Pred(Length(Strings)) do
    begin
      if Assigned(Result.Obj) then
        Result := GetProperty(Result.Obj, Strings[i+1])
      else
        Result := GetProperty(aObject, Strings[i]);
      if Result.Prop.PropertyType.TypeKind = tkClass then
        Result := GetProperty(Result.Obj, Strings[I+1]);
      if Result.Prop.Name = Strings[Pred(Length(Strings))] then
        Break;
    end;
  end
  else
  begin
    Result.Prop := RttiType.GetProperty(aEntityFieldName);

    if (Result.Prop.PropertyType.TypeKind = tkClass) and not (Result.Prop.GetValue(Pointer(aObject)).AsObject.ClassName.Contains('TObjectList<')) then
      Result.Obj := Result.Prop.GetValue(Pointer(aObject)).AsObject
    else
      Result.Obj := aObject;
  end;

end;

function TOrionORMReflection.GetTableFieldName(aTableFieldName: string): string;
var
  SplittedString : TArray<string>;
begin
  if not aTableFieldName.Contains('.') then
  begin
    Result := aTableFieldName;
    Exit;
  end;

  SplittedString := aTableFieldName.Split(['.']);
  Result := SplittedString[Pred(Length(SplittedString))];
end;

procedure TOrionORMReflection.IncObjectInList<T>(aObjectList: TObjectList<T>; aObject: TObject);
begin
  aObjectList.Add(aObject);
end;

procedure TOrionORMReflection.ObjectToDataset(aObject: TObject; aDataset: iDataset; aMapper: iOrionORMMapper);
var
  RttiProperty : TGetProperty;
  MapperValue: TMapperValue;
  Constraint: TConstraint;
  IsAutInc : boolean;
  IsNullIfEmpty : boolean;
  IsIgnoreOnSave : boolean;
  TableFieldName : string;
begin
  for MapperValue in aMapper.Items do
  begin
    IsAutInc := False;
    IsNullIfEmpty := False;
    IsIgnoreOnSave := False;
    if MapperValue.TableFieldName = '' then
      Continue;

    for Constraint in MapperValue.Constraints do
    begin
      if Constraint = AutoInc then
      begin
        IsAutInc := True;
        aDataset.FieldByName(MapperValue.TableFieldName).AutoGenerateValue := arAutoInc;
        aDataset.FieldByName(MapperValue.TableFieldName).Required := False;
      end;

      if Constraint = NullIfEmpty then
        IsNullIfEmpty := True;

      if Constraint = IgnoreOnSave then
        IsIgnoreOnSave := True;
    end;

    if IsIgnoreOnSave or IsAutInc then
      Continue;

    RttiProperty := GetProperty(aObject, MapperValue.EntityFieldName);
    TableFieldName := GetTableFieldName(MapperValue.TableFieldName);
    if not Assigned(RttiProperty.Prop) then
      raise OrionORMException.Create('Entity Field Name ' + MapperValue.EntityFieldName + ' not found.');

    if not aDataset.FieldExist(MapperValue.TableFieldName) then
      raise OrionORMException.Create('Table Field Name ' + MapperValue.TableFieldName + ' not found.');

    if not RttiProperty.Prop.IsReadable then
      Continue;

    case RttiProperty.Prop.PropertyType.TypeKind of
      tkUnknown: ;
      tkInteger:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsInteger = 0) then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsInteger := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsInteger;
      end;
      tkChar:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
         aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkEnumeration: aDataset.FieldByName(TableFieldName).AsBoolean := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsBoolean;
      tkFloat:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsExtended = 0) then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsExtended := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsExtended;
      end;
      tkString:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkSet: ;
      tkClass: ;
      tkMethod: ;
      tkWChar:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkLString:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkWString:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkVariant: ;
      tkArray: ;
      tkRecord: ;
      tkInterface: ;
      tkInt64:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsInt64 = 0) then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsLargeInt := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsInt64;
      end;
      tkDynArray: ;
      tkUString:
      begin
        if (IsNullIfEmpty) and (RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString = '') then
          aDataset.FieldByName(TableFieldName).AsVariant := Null
        else
          aDataset.FieldByName(TableFieldName).AsString := RttiProperty.Prop.GetValue(Pointer(RttiProperty.Obj)).AsString;
      end;
      tkClassRef: ;
      tkPointer: ;
      tkProcedure: ;
      tkMRecord: ;
    end;
  end;

end;

procedure TOrionORMReflection.RefreshEntityPrimaryKeysValues(aDataset: iDataset; aObject: TObject; aMapper : iOrionORMMapper);
var
  Keys : TKeys;
  KeysTableField : TKeys;
  Key: string;
  RttiProperty : TGetProperty;
  I: Integer;
//  MapperValue : TMapperValue;
begin
  Keys := aMapper.GetPrimaryKeyEntityFieldName;
  KeysTableField := aMapper.GetPrimaryKeyTableFieldName;
  for I := 0 to Pred(Length(Keys)) do
  begin
//    MapperValue := aMapper.GetMapperValue(Keys[I]);
    RttiProperty := GetProperty(aObject, Keys[I]);

    case RttiProperty.Prop.PropertyType.TypeKind of
      tkUnknown: ;
      tkInteger: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsInteger);
      tkChar: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkEnumeration: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsBoolean);
      tkFloat: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsExtended);
      tkString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkSet: ;
      tkClass: ;
      tkMethod: ;
      tkWChar: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkLString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkWString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkVariant: ;
      tkArray: ;
      tkRecord: ;
      tkInterface: ;
      tkInt64: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsLargeInt);
      tkDynArray: ;
      tkUString: RttiProperty.Prop.SetValue(Pointer(RttiProperty.Obj), aDataset.FieldByName(KeysTableField[I]).AsString);
      tkClassRef: ;
      tkPointer: ;
      tkProcedure: ;
      tkMRecord: ;
    end;
  end;

end;

procedure TOrionORMReflection.IncObjectInList(aEntityFieldName: string; aOwnerObjectList, aChildObject: TObject);
var
  RttiProperty : TGetProperty;
begin
  RttiProperty := GetProperty(aOwnerObjectList, aEntityFieldName);
  TObjectList<TObject>(RttiProperty.Prop.GetValue(RttiProperty.Obj).AsObject).Add(aChildObject);
end;

end.
