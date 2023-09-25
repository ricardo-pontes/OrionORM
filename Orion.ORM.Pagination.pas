unit Orion.ORM.Pagination;

interface

uses
  Orion.ORM.Interfaces;

type
  TOrionPagination = class(TInterfacedObject, iOrionPagination)
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
  end;

implementation

{ TOrionPagination }

constructor TOrionPagination.Create;
begin

end;

function TOrionPagination.GetPage: integer;
begin
  Result := FPage;
end;

function TOrionPagination.GetPageSize: integer;
begin
  Result := FPageSize;
end;

class function TOrionPagination.New: iOrionPagination;
begin
  Result := Self.Create;
end;

procedure TOrionPagination.SetPage(const aValue: integer);
begin
  FPage := aValue;
end;

procedure TOrionPagination.SetPageSize(const aValue: integer);
begin
  FPageSize := aValue;
end;

end.
