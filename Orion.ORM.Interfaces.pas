unit Orion.ORM.Interfaces;

interface

uses
  System.Generics.Collections,
  Orion.ORM.Types;

type

  iOrionORMMapper = interface;
  iOrionPagination = interface;

  TKeys = array of string;
  TKeysValues = array of Variant;
  TSelects = TArray<TPair<string, string>>;
  TMappers = array of iOrionORMMapper;


  TAssociation = record
    &Type : TAssociationType;
    Keys : TKeys;
    class function Create(aType : TAssociationType; aKeys : TKeys) : TAssociation; static;
  end;

  TMapperValue = record
    EntityFieldName : string;
    TableFieldName : string;
    Constraints : TConstraints;
    Mapper : iOrionORMMapper;
    Association : TAssociation;
    class function Create(aEntityFieldName, aTableFieldName : string; aConstraints : TConstraints) : TMapperValue; overload; static;
    class function Create(aEntityFieldName, aTableFieldName : string; aConstraints : TConstraints; aMapper : iOrionORMMapper; aAssociation : TAssociation) : TMapperValue; overload; static;
  end;

  iOrionORM<T:class, constructor> = interface
    ['{D7B72D21-1344-4365-8887-990894751881}']
    procedure Mapper(aValue : iOrionORMMapper); overload;
    function Mapper : iOrionORMMapper; overload;
    function Find : TObjectList<T>; overload;
    function Find(aID : int64) : T; overload;
    function Find(aID : string) : T; overload;
    function FindOneWithWhere(aWhere : string) : T;
    function FindManyWithWhere(aWhere : string) : TObjectList<T>;
    procedure Save(aValue : T);
    procedure Delete(aID : int64); overload;
    procedure Delete(aID : string); overload;
    procedure Delete(aEntity : T); overload;
  end;

  iOrionORMMapper = interface
    ['{C1FDA3F8-DF95-4B35-8F03-E7A52F3A2731}']
    procedure SetTableName(const aValue : string);
    function GetTableName : string;
    property TableName: string read GetTableName write SetTableName;

    procedure Add(aMapperValue : TMapperValue);
    procedure ClassType(const aValue : TClass); overload;
    function ClassType : TClass; overload;
    function ContainsPrimaryKey : boolean;
    function ContainsEmptyEntityFieldName : boolean;
    function ContainsEmptyTableFieldName : boolean;
    function ContainsEmptyMapper : boolean;
    function GetPrimaryKeyEntityFieldName : TKeys;
    function GetPrimaryKeyTableFieldName : TKeys;
    function GetOneToManyMappers : TMappers;
    function Items : TList<TMapperValue>;

    procedure SetPagination(const aValue : iOrionPagination);
    function GetPagination : iOrionPagination;
    property Pagination: iOrionPagination read GetPagination write SetPagination;
  end;

  iOrionPagination = interface
    ['{293F327F-2C07-4754-9115-9224568682F6}']
    procedure SetPageSize(const aValue : integer);
    function GetPageSize : integer;
    property PageSize: integer read GetPageSize write SetPageSize;

    procedure SetPage(const aValue : integer);
    function GetPage : integer;
    property Page: integer read GetPage write SetPage;
  end;

  iOrionCriteria = interface
    ['{E3B6FDF1-FBA5-4B65-B844-17CAC51B2535}']
    function BuildSelect(aMapper : iOrionORMMapper; aWhere : string) : TSelects; overload;
    function BuildSelect(aMapper : iOrionORMMapper; aKeys : TKeys; aValues : TKeysValues) : string; overload;
    function BuildDelete(aMapper : iOrionORMMapper) : TSelects;
  end;

implementation

{ TMapperValue }

class function TMapperValue.Create(aEntityFieldName, aTableFieldName: string; aConstraints: TConstraints;
  aMapper: iOrionORMMapper; aAssociation : TAssociation): TMapperValue;
begin
  Result.EntityFieldName := aEntityFieldName;
  Result.TableFieldName := aTableFieldName;
  Result.Constraints := aConstraints;
  Result.Mapper := aMapper;
  Result.Association := aAssociation;
end;

class function TMapperValue.Create(aEntityFieldName, aTableFieldName: string; aConstraints: TConstraints): TMapperValue;
begin
  Result.EntityFieldName := aEntityFieldName;
  Result.TableFieldName := aTableFieldName;
  Result.Constraints := aConstraints;
  Result.Mapper := nil;
end;

{ TAssociation }

class function TAssociation.Create(aType: TAssociationType; aKeys: TKeys): TAssociation;
begin
  Result.&Type := aType;
  Result.Keys := aKeys;
end;

end.
