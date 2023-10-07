unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  Orion.ORM,
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
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    LabeledEdit1: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FOrionORM : iOrionORM<TPerson>;
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
  Contact : TContact;
begin
  Person := FOrionORM.Find([1]);
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

    Memo1.Lines.Clear;
    for Contact in Person.Contacts do
      Memo1.Lines.Add(Format('ID: %d - PersonID: %d - PhoneNumber: %s', [Contact.ID, Contact.PersonID, Contact.PhoneNumber]));

  finally
    Person.DisposeOf;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Persons : TObjectList<TPerson>;
  Person: TPerson;
begin
  Persons := FOrionORM.Find;
  try
    Memo1.Lines.Clear;
    for Person in Persons do
      Memo1.Lines.Add(Format('ID: %d - Name: %s - Salary: %n - Street: %s - Number: %s - Neighborhood: %s - City: %s - PostalCode: %s', [Person.ID, Person.Name, Person.Salary, Person.Address.Street, Person.Address.Number, Person.Address.Neighborhood, Person.Address.City, Person.Address.PostalCode]));
  finally
    Persons.DisposeOf;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Persons : TObjectList<TPerson>;
  Person: TPerson;
begin
  Persons := FOrionORM.FindManyWithWhere(LabeledEdit1.Text);
  try
    Memo1.Lines.Clear;
    for Person in Persons do
      Memo1.Lines.Add(Format('ID: %d - Name: %s - Salary: %n - Street: %s - Number: %s - Neighborhood: %s - City: %s - PostalCode: %s', [Person.ID, Person.Name, Person.Salary, Person.Address.Street, Person.Address.Number, Person.Address.Neighborhood, Person.Address.City, Person.Address.PostalCode]));
  finally
    Persons.DisposeOf;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  DBConnection : iDBConnection;
begin
  DBConnection := TOrionORMDBConnectionFiredacSQLite.New;
  DBConnection.Configurations(ExtractFileDir(GetCurrentDir) + 'dbteste.sqlite3', '', '', '', 0);
  FOrionORM := TOrionORM<TPerson>.New(DBConnection);
  var Mapper := TOrionMapper.New;
  var MapperContacts := TOrionMapper.New;

  MapperContacts.TableName := 'CONTACTS';
  MapperContacts.ClassType := TContact;
  MapperContacts.Add(TMapperValue.Create('ID', 'PC_ID', [PrimaryKey, AutoInc]));
  MapperContacts.Add(TMapperValue.Create('PersonID', 'PC_PEOPLE_ID'));
  MapperContacts.Add(TMapperValue.Create('PhoneNumber', 'PC_PHONE_NUMBER'));

  Mapper.TableName := 'PEOPLES';
  Mapper.ClassType := TPerson;
  Mapper.Add(TMapperValue.Create('ID', 'PEOPLE_ID', [PrimaryKey, AutoInc]));
  Mapper.Add(TMapperValue.Create('Name', 'PEOPLE_NAME'));
  Mapper.Add(TMapperValue.Create('Salary', 'PEOPLE_SALARY'));
  Mapper.Add(TMapperValue.Create('Active', 'PEOPLE_ACTIVE'));
  Mapper.Add(TMapperValue.Create('Address.Street', 'PEOPLE_STREET'));
  Mapper.Add(TMapperValue.Create('Address.Number', 'PEOPLE_NUMBER'));
  Mapper.Add(TMapperValue.Create('Address.Neighborhood', 'PEOPLE_NEIGHBORHOOD'));
  Mapper.Add(TMapperValue.Create('Address.City', 'PEOPLE_CITY'));
  Mapper.Add(TMapperValue.Create('Address.PostalCode', 'PEOPLE_POSTAL_CODE'));
  Mapper.Add(TMapperValue.Create('Contacts', MapperContacts, TAssociation.Create(OneToMany, ['PEOPLE_ID'], ['PC_PEOPLE_ID'])));
  FOrionORM.Mapper(Mapper);
end;

end.
