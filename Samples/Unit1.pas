unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  Orion.ORM.Core,
  Orion.ORM.Mapper,
  Orion.ORM.Interfaces,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Types,
  Orion.ORM.DBConnection.FireDAC.SQLite,
  Orion.ORM.Criteria,
  Entity,
  Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    EditID: TLabeledEdit;
    EditName: TLabeledEdit;
    EditSalary: TLabeledEdit;
    SwitchActive: TToggleSwitch;
    EditStreet: TLabeledEdit;
    EditNumber: TLabeledEdit;
    EditNeighborhood: TLabeledEdit;
    EditCity: TLabeledEdit;
    EditPostalCode: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FOrionCore : TOrionORMCore<TPerson>;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Person : TPerson;
begin
  Person := FOrionCore.Find([1]);
  try
    EditID.Text := Person.ID.ToString;
    EditName.Text := Person.Name;
    EditSalary.Text := Person.Salary.ToString;
    if Person.Active then
      SwitchActive.State := tssOn
    else
      SwitchActive.State := tssOff;

    EditStreet.Text := Person.Address.Street;
    EditNumber.Text := Person.Address.Number;
    EditNeighborhood.Text := Person.Address.Neighborhood;
    EditCity.Text := Person.Address.City;
    EditPostalCode.Text := Person.Address.PostalCode;
  finally
    Person.DisposeOf;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  DBConnection : iDBConnection;
  Dataset : iDataset;
  Script : string;
begin
  DBConnection := TOrionORMDBConnectionFiredacSQLite.New;
  DBConnection.Configurations(ExtractFileDir(GetCurrentDir) + 'dbteste.sqlite3', '', '', '', 0);

  Script := ' CREATE TABLE IF NOT EXISTS PEOPLES ('
              + 'PEOPLE_ID INTEGER NOT NULL PRIMARY KEY,'
              + 'PEOPLE_NAME VARCHAR(200), '
              + 'PEOPLE_SALARY FLOAT, '
              + 'PEOPLE_ACTIVE BOOLEAN '
              + ')';
  Dataset := DBConnection.NewDataset;
  Dataset.Statement(Script);
  Dataset.ExecSQL;

  FOrionCore := TOrionORMCore<TPerson>.Create(TOrionORMCriteria.New, DBConnection);
  var Mapper := TOrionMapper.New;
  Mapper.TableName := 'PEOPLES';
  Mapper.ClassType(TPerson);
  Mapper.Add(TMapperValue.Create('ID', 'PEOPLE_ID', [PrimaryKey, AutoInc]));
  Mapper.Add(TMapperValue.Create('Name', 'PEOPLE_NAME', []));
  Mapper.Add(TMapperValue.Create('Salary', 'PEOPLE_SALARY', []));
  Mapper.Add(TMapperValue.Create('Active', 'PEOPLE_ACTIVE', []));
  Mapper.Add(TMapperValue.Create('Address.Street', 'PEOPLE_STREET', []));
  Mapper.Add(TMapperValue.Create('Address.Number', 'PEOPLE_NUMBER', []));
  Mapper.Add(TMapperValue.Create('Address.Neighborhood', 'PEOPLE_NEIGHBORHOOD', []));
  Mapper.Add(TMapperValue.Create('Address.City', 'PEOPLE_CITY', []));
  Mapper.Add(TMapperValue.Create('Address.PostalCode', 'PEOPLE_POSTAL_CODE', []));
  FOrionCore.Mapper(Mapper);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FOrionCore.DisposeOf;
end;

end.
