unit Orion.ORM.Pagination.Firebird;

interface

uses
  System.SysUtils,
  Orion.ORM.Interfaces;

type
  TOrionPaginationFirebird = class(TInterfacedObject, iOrionPagination)
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

{ TOrionPaginationFirebird }

constructor TOrionPaginationFirebird.Create;
begin
  FPage := 1;
end;

function TOrionPaginationFirebird.GetPage: integer;
begin
  Result := FPage;
end;

function TOrionPaginationFirebird.GetPageSize: integer;
begin
  Result := FPageSize;
end;

class function TOrionPaginationFirebird.New: iOrionPagination;
begin
  Result := Self.Create;
end;

function TOrionPaginationFirebird.Result: string;
begin
  var PosicaoInicial := (FPage * FPageSize) - FPageSize +1;
  var PosicaoFinal := (FPage * FPageSize);
  Result :=  Format(' ROWS %d to %d', [PosicaoInicial, PosicaoFinal]);
end;

procedure TOrionPaginationFirebird.SetPage(const aValue: integer);
begin
  FPage := aValue;
end;

procedure TOrionPaginationFirebird.SetPageSize(const aValue: integer);
begin
  FPageSize := aValue;
end;

end.
