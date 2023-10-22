unit Orion.ORM.Types;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Rtti;

type
  TConstraint = (PrimaryKey, ForeignKey, FindKey, AutoInc, NullIfEmpty, IgnoreOnSave);

  TAssociationType = (OneToOne, OneToMany);

  TConstraints = set of TConstraint;

  TEnumConvert<T> = class
  private

  public
    constructor Create;
    destructor Destroy; override;
    function ConvertToEnum(aValue : string) : T;
    function ConvertToString(aValue : TValue) : string;
  end;

  TDatabase = (Firebird);

  OrionORMException = class(Exception)

  end;

implementation

{ TEnumConvert<T> }

function TEnumConvert<T>.ConvertToString(aValue : TValue) : string;
begin
  Result := TRttiEnumerationType.GetName<T>(aValue.AsType<T>);
end;

constructor TEnumConvert<T>.Create;
begin

end;

destructor TEnumConvert<T>.Destroy;
begin

  inherited;
end;

function TEnumConvert<T>.ConvertToEnum(aValue: string): T;
begin
  Result := TRttiEnumerationType.GetValue<T>(aValue);
end;

end.
