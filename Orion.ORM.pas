unit Orion.ORM;

interface

uses
  System.Generics.Collections,
  Orion.ORM.Interfaces,
  Orion.ORM.DB.Interfaces, Orion.ORM.Core, Orion.ORM.Criteria;

type
  TOrionORM<T:class, constructor> = class(TInterfacedObject, iOrionORM<T>)
  private
    FCore : TOrionORMCore<T>;
  public
    constructor Create(aDBConnection : iDBConnection); overload;
    constructor Create(aDBConnection : iDBConnection; aPagination : iOrionPagination); overload;
    destructor Destroy; override;
    class function New(aDBConnection : iDBConnection) : iOrionORM<T>; overload;
    class function New(aDBConnection : iDBConnection; aPagination : iOrionPagination) : iOrionORM<T>; overload;
    procedure Mapper(aValue : iOrionORMMapper); overload;
    function Mapper : iOrionORMMapper; overload;
    function Find : TObjectList<T>; overload;
    function Find(aPrimaryKeyValues : TKeysValues) : T; overload;
    function FindOneWithWhere(aWhere : string) : T;
    function FindManyWithWhere(aWhere : string) : TObjectList<T>;
    procedure Save(aValue : T);
    procedure Delete(aID : int64); overload;
    procedure Delete(aID : string); overload;
    procedure Delete(aEntity : T); overload;
  end;

implementation

{ TOrionORM<T> }

constructor TOrionORM<T>.Create(aDBConnection : iDBConnection);
begin
  FCore := TOrionORMCore<T>.Create(TOrionORMCriteria.New, aDBConnection);
end;

constructor TOrionORM<T>.Create(aDBConnection: iDBConnection; aPagination: iOrionPagination);
begin
  FCore := TOrionORMCore<T>.Create(TOrionORMCriteria.New, aDBConnection);
end;

procedure TOrionORM<T>.Delete(aEntity: T);
begin
  FCore.Delete(aEntity);
end;

procedure TOrionORM<T>.Delete(aID: string);
begin
  FCore.Delete(aID);
end;

procedure TOrionORM<T>.Delete(aID: int64);
begin
  FCore.Delete(aID);
end;

destructor TOrionORM<T>.Destroy;
begin
  FCore.DisposeOf;
  inherited;
end;

function TOrionORM<T>.Find: TObjectList<T>;
begin
  Result := FCore.Find;
end;

function TOrionORM<T>.Find(aPrimaryKeyValues: TKeysValues): T;
begin
  Result := FCore.Find(aPrimaryKeyValues);
end;

function TOrionORM<T>.FindManyWithWhere(aWhere: string): TObjectList<T>;
begin
  Result := FCore.FindManyWithWhere(aWhere);
end;

function TOrionORM<T>.FindOneWithWhere(aWhere: string): T;
begin
  Result := FCore.FindOneWithWhere(aWhere);
end;

procedure TOrionORM<T>.Mapper(aValue: iOrionORMMapper);
begin
  FCore.Mapper(aValue);
end;

function TOrionORM<T>.Mapper: iOrionORMMapper;
begin
  Exit(FCore.Mapper);
end;

class function TOrionORM<T>.New(aDBConnection: iDBConnection; aPagination: iOrionPagination): iOrionORM<T>;
begin
  Result := Self.Create(aDBConnection, aPagination);
end;

class function TOrionORM<T>.New(aDBConnection : iDBConnection): iOrionORM<T>;
begin
  Result := Self.Create(aDBConnection);
end;

procedure TOrionORM<T>.Save(aValue: T);
begin
  FCore.Save(aValue);
end;

end.
