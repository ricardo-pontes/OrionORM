unit Orion.ORM.Reflection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Interfaces,
  Orion.ORM.Types;

type
  TGetProperty = record
    Obj : TObject;
    Prop : TRttiProperty;
  end;

  TOrionORMReflection = class
  private
    function GetProperty(aObject : TObject; aEntityFieldName : string) : TGetProperty;
  public
    procedure DatasetToObject(aDataset : iDataset; aObject : TObject; aMapper : iOrionORMMapper);
  end;


implementation

{ TOrionORMReflection }

procedure TOrionORMReflection.DatasetToObject(aDataset : iDataset; aObject : TObject; aMapper : iOrionORMMapper);
var
  RttiProperty : TGetProperty;
  MapperValue: TMapperValue;
begin
  for MapperValue in aMapper.Items do
  begin
    RttiProperty := GetProperty(aObject, MapperValue.EntityFieldName);
    if not Assigned(RttiProperty.Prop) then
      raise OrionORMException.Create('Entity Field Name ' + MapperValue.EntityFieldName + ' not found.');

    if not aDataset.FieldExist(MapperValue.TableFieldName) then
      raise OrionORMException.Create('Table Field Name ' + MapperValue.TableFieldName + ' not found.');

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

function TOrionORMReflection.GetProperty(aObject : TObject; aEntityFieldName : string) : TGetProperty;
var
  RttiContext : TRttiContext;
  RttiType : TRttiType;
  RttiProperty : TRttiProperty;
  Strings : TArray<string>;
  ArraySize : integer;
  EntityFieldName : string;
  ClassName : string;
  I : integer;
begin
  Result.Obj := nil;
  Result.Prop := nil;
  RttiContext := TRttiContext.Create;
  RttiType := RttiContext.GetType(aObject.ClassInfo);
  try
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
//      Result.Obj := aObject;
//      Result.Prop := RttiType.GetProperty(aEntityFieldName);
    end;
  finally
//    RttiType.DisposeOf;
//    RttiType := nil;
  end;
end;

end.
