unit Orion.ORM.DB.Interfaces;

interface

uses
  System.Sysutils,
  System.Classes,
  Data.DB;

type
  iDBConnectionConfigurations = interface;
  iDataset = interface;

  iDBConnection = interface
    ['{FDF6B898-A497-410F-B4D9-35EDDD329583}']
    procedure Configurations(aPath, aUsername, aPassword, aServer : string; aPort : integer); overload;
    function Configurations : iDBConnectionConfigurations; overload;
    procedure StartTransaction;
    procedure Commit;
    procedure RollBack;
    function Component : TComponent; overload;
    procedure Component(aValue : TComponent); overload;
    function NewDataset : iDataset;
    function IsConnected : boolean; overload;
    function InTransaction : boolean;
    procedure Connected(aValue : boolean); overload;
  end;

  iDBConnectionConfigurations = interface
    ['{6CF32947-ED49-40C7-8706-0644027B8B93}']
    function Path : string; overload;
    procedure Path(aValue : string); overload;
    function Username : string; overload;
    procedure Username(aValue : string); overload;
    function Password : string; overload;
    procedure Password(aValue : string); overload;
    function Server : string; overload;
    procedure Server(aValue : string); overload;
    function Port : integer; overload;
    procedure Port(aValue : integer); overload;
  end;

  iConexaoFactory = interface
    function Conexao : iDBConnection;
    procedure Commit;
    procedure Rollback;
  end;

  iDataset = interface
    ['{AAA85BEC-5C3B-48F5-8D95-140622DA0E0B}']
    function RecordCount : integer;
    function FieldByName(aValue : string) : TField;
    function FieldExist(aFieldName : string) : boolean;
    function Fields : TFields;
    procedure Statement(aValue : string);
    procedure Close;
    procedure CachedUpdates(aValue : boolean);
    function ApplyUpdates(aMaxErrors : integer = -1) : integer;
    procedure Open;
    procedure Append;
    procedure Edit;
    procedure Post;
    procedure Delete;
    procedure ExecSQL;
    procedure Next;
    procedure First;
    function Locate(const AKeyFields: string; const AKeyValues: Variant; AOptions: TLocateOptions = []): Boolean;
    function Eof : boolean;
  end;
implementation

end.
