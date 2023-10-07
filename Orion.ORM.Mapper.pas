unit Orion.ORM.Mapper;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Orion.ORM.Interfaces,
  Orion.ORM.Types;

type
  TOrionMapper = class(TInterfacedObject, iOrionORMMapper)
  private
    FClassType : TClass;
    FPagination : iOrionPagination;
    FItens : TList<TMapperValue>;
    FTableName : string;
  private
    procedure SetPagination(const aValue : iOrionPagination);
    function GetPagination : iOrionPagination;
    procedure SetTableName(const aValue : string);
    function GetTableName : string;
    procedure SetClassType(const aValue : TClass); overload;
    function GetClassType : TClass; overload;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionORMMapper;

    procedure Add(aMapperValue : TMapperValue); overload;
    property ClassTyp : TClass read GetClassType write SetClassType;
    function ContainsPrimaryKey : boolean;
    function ContainsEmptyEntityFieldName : boolean;
    function ContainsEmptyTableFieldName : boolean;
    function ContainsEmptyMapper : boolean;
    function GetPrimaryKeyEntityFieldName : TKeys;
    function GetPrimaryKeyTableFieldName : TKeys;
    function GetOneToManyMappers : TMappers;
    function GetAssociationOwnerKeyFields (aMapper : iOrionORMMapper): TKeys;
    function GetAssociationChildKeyFields(aMapper : iOrionORMMapper): TKeys;
    function GetAssociationObjectListFieldName(aMapper : iOrionORMMapper) : string;
    function Items : TList<TMapperValue>;
  public
    property TableName: string read GetTableName write SetTableName;
    property Pagination: iOrionPagination read GetPagination write SetPagination;
  end;

implementation

{ TOrionMapper }

uses Orion.ORM.Pagination;

procedure TOrionMapper.Add(aMapperValue: TMapperValue);
begin
  FItens.Add(aMapperValue);
end;

function TOrionMapper.GetAssociationChildKeyFields(aMapper: iOrionORMMapper): TKeys;
var
  MapperValue: TMapperValue;
begin
  for MapperValue in FItens do
  begin
    if MapperValue.Mapper <> aMapper then
      Continue;

    Result := MapperValue.Association.ChildKeys;
    Exit;
  end;

end;

function TOrionMapper.GetAssociationObjectListFieldName(aMapper: iOrionORMMapper): string;
var
  MapperValue: TMapperValue;
begin
  for MapperValue in FItens do
  begin
    if MapperValue.Mapper <> aMapper then
      Continue;

    Result := MapperValue.EntityFieldName;
    Exit;
  end;
end;

function TOrionMapper.GetAssociationOwnerKeyFields(aMapper : iOrionORMMapper): TKeys;
var
  MapperValue: TMapperValue;
begin
  for MapperValue in FItens do
  begin
    if MapperValue.Mapper <> aMapper then
      Continue;

    Result := MapperValue.Association.OwnerKeys;
    Exit;
  end;
end;

function TOrionMapper.GetClassType: TClass;
begin
  Result := FClassType;
end;

procedure TOrionMapper.SetClassType(const aValue: TClass);
begin
  FClassType := aValue;
end;

function TOrionMapper.ContainsEmptyEntityFieldName: boolean;
var
  Mapper : TMapperValue;
begin
  Result := False;
  for Mapper in FItens do
  begin
    if Mapper.EntityFieldName.Trim.IsEmpty then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TOrionMapper.ContainsEmptyMapper: boolean;
var
  Mapper : TMapperValue;
begin
  Result := False;
  for Mapper in FItens do
  begin
    if Mapper.Mapper = nil then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TOrionMapper.ContainsEmptyTableFieldName: boolean;
var
  Mapper : TMapperValue;
begin
  Result := False;
  for Mapper in FItens do
  begin
    if (Mapper.TableFieldName.Trim.IsEmpty) and (Mapper.Mapper = nil) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TOrionMapper.ContainsPrimaryKey: boolean;
var
  Mapper : TMapperValue;
begin
  Result := False;
  for Mapper in FItens do
  begin
    for var Constraint in Mapper.Constraints do
    begin
      if Constraint = TConstraint.PrimaryKey then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

constructor TOrionMapper.Create;
begin
  FItens := TList<TMapperValue>.Create;
  FPagination := TOrionPagination.New;
end;

destructor TOrionMapper.Destroy;
begin
  FItens.DisposeOf;
  inherited;
end;

function TOrionMapper.GetOneToManyMappers: TMappers;
var
  Mapper : TMapperValue;
begin
  Result := [];
  for Mapper in FItens do
  begin
    if Assigned(Mapper.Mapper) and (Mapper.Association.&Type = TAssociationType.OneToMany) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Pred(Length(Result))] := Mapper.Mapper;
    end;
  end;
end;

function TOrionMapper.GetPagination: iOrionPagination;
begin
  Result := FPagination;
end;

function TOrionMapper.GetPrimaryKeyEntityFieldName: TKeys;
var
  Mapper : TMapperValue;
begin
  Result := [];
  for Mapper in FItens do
  begin
    for var Constraint in Mapper.Constraints do
    begin
      if Constraint = TConstraint.PrimaryKey then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Pred(Length(Result))] := Mapper.EntityFieldName;
        Exit;
      end;
    end;
  end;
end;

function TOrionMapper.GetPrimaryKeyTableFieldName: TKeys;
var
  Mapper : TMapperValue;
begin
  Result := [];
  for Mapper in FItens do
  begin
    for var Constraint in Mapper.Constraints do
    begin
      if Constraint = TConstraint.PrimaryKey then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Pred(Length(Result))] := Mapper.TableFieldName;
        Exit;
      end;
    end;
  end;

end;

function TOrionMapper.GetTableName: string;
begin
  Result := FTableName;
end;

function TOrionMapper.Items: TList<TMapperValue>;
begin
  Result := FItens;
end;

class function TOrionMapper.New: iOrionORMMapper;
begin
  Result := Self.Create;
end;

procedure TOrionMapper.SetPagination(const aValue: iOrionPagination);
begin
  FPagination := aValue;
end;

procedure TOrionMapper.SetTableName(const aValue: string);
begin
  FTableName := aValue;
end;

end.