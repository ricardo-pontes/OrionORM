unit Entity;

interface

uses
  System.Generics.Collections;

type
  TFinancialStatus = (None, Blocked, Test);
  TAddress = class;
  TContact = class;

  TPerson = class
  private
    FID: integer;
    FName: string;
    FSalary: Double;
    FActive: boolean;
    FAddress: TAddress;
    FContacts: TObjectList<TContact>;
    FFinancialStatus: TFinancialStatus;

  public
    constructor Create;
    destructor Destroy; override;

    property ID: integer read FID write FID;
    property Name: string read FName write FName;
    property Salary: Double read FSalary write FSalary;
    property Active: boolean read FActive write FActive;
    property FinancialStatus: TFinancialStatus read FFinancialStatus write FFinancialStatus;
    property Address: TAddress read FAddress write FAddress;
    property Contacts: TObjectList<TContact> read FContacts write FContacts;
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

  TContact = class
  private
    FID: integer;
    FPersonID: integer;
    FPhoneNumber: string;
  public
    property ID: integer read FID write FID;
    property PersonID: integer read FPersonID write FPersonID;
    property PhoneNumber: string read FPhoneNumber write FPhoneNumber;
  end;

implementation

{ TPerson }

constructor TPerson.Create;
begin
  FAddress := TAddress.Create;
  FContacts := TObjectList<TContact>.Create;
end;

destructor TPerson.Destroy;
begin
  FAddress.DisposeOf;
  FContacts.DisposeOf;
  inherited;
end;

end.
