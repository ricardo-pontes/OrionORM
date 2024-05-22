unit Orion.ORM.Pagination.SQLite;

interface

uses
  System.SysUtils,
  Orion.ORM.Interfaces;

type
  TOrionPaginationSQLite = class(TInterfacedObject, iOrionPagination)
  private
    FPage : integer;
    FPageSize : integer;
  private
    procedure SetPageSize(const aValue : integer);
    function GetPageSize : integer;

    procedure SetPage(const aValue : integer);
    function GetPage : integer;
  public
    constructor Create;
    class function New : iOrionPagination;
  public
    property Page: integer read GetPage write SetPage;
    property PageSize: integer read GetPageSize write SetPageSize;
    function Result : string;
  end;

implementation

{ TOrionPaginationSQLite }

constructor TOrionPaginationSQLite.Create;
begin
  FPage := 1;
end;

function TOrionPaginationSQLite.GetPage: integer;
begin
  Result := FPage;
end;

function TOrionPaginationSQLite.GetPageSize: integer;
begin
  Result := FPageSize;
end;

class function TOrionPaginationSQLite.New: iOrionPagination;
begin
  Result := Self.Create;
end;

function TOrionPaginationSQLite.Result: string;
begin
  var PosicaoInicial := (FPage * FPageSize) - FPageSize;
  Result :=  Format(' LIMIT %d OFFSET %d', [FPageSize, PosicaoInicial]);
end;

procedure TOrionPaginationSQLite.SetPage(const aValue: integer);
begin
  FPage := aValue;
end;

procedure TOrionPaginationSQLite.SetPageSize(const aValue: integer);
begin
  FPageSize := aValue;
end;

end.
