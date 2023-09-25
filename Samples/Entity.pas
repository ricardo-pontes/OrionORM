unit Entity;

interface

type
  TAddress = class;

  TPerson = class
  private
    FID: integer;
    FName: string;
    FSalary: Double;
    FActive: boolean;
    FAddress: TAddress;

  public
    constructor Create;
    destructor Destroy; override;

    property ID: integer read FID write FID;
    property Name: string read FName write FName;
    property Salary: Double read FSalary write FSalary;
    property Active: boolean read FActive write FActive;
    property Address: TAddress read FAddress write FAddress;
  end;

  TAddress = class
  private
    FStreet: string;
    FNumber: string;
    FNeighborhood: string;
    FCity: string;
    FState: string;
    FPostalCode: string;

  public
    property Street: string read FStreet write FStreet;
    property Number: string read FNumber write FNumber;
    property Neighborhood: string read FNeighborhood write FNeighborhood;
    property City: string read FCity write FCity;
    property State: string read FState write FState;
    property PostalCode: string read FPostalCode write FPostalCode;
  end;

implementation

{ TPerson }

constructor TPerson.Create;
begin
  FAddress := TAddress.Create;
end;

destructor TPerson.Destroy;
begin
  FAddress.DisposeOf;
  inherited;
end;

end.
