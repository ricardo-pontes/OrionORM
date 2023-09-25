unit Orion.ORM.Types;

interface

uses
  System.SysUtils;

type
  TConstraint = (PrimaryKey, ForeignKey, AutoInc, Nullable);

  TAssociationType = (OneToOne, OneToMany);

  TConstraints = set of TConstraint;


  TDatabase = (Firebird);

  OrionORMException = class(Exception)

  end;

implementation

end.
