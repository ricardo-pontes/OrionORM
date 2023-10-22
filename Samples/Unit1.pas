unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
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
  Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.Grids;

type
 TStringGridHack = class(TStringGrid)
  protected
    procedure DeleteRow(ARow: Longint); reintroduce;
    procedure InsertRow(ARow: Longint);
  end;

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
    Button4: TButton;
    Button5: TButton;
    LabeledEdit2: TLabeledEdit;
    Button6: TButton;
    StringGridContacts: TStringGrid;
    EditPhoneNumber: TLabeledEdit;
    Button7: TButton;
    EditFinancialStatus: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    FContactID : integer;
    FOrionORM : iOrionORM<TPerson>;
    FPerson : TPerson;
    procedure StringGridConfiguration;
    procedure FillStringGridContacts(aContacts : TObjectList<TContact>);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Contact : TContact;
begin
  if Assigned(FPerson) then
    FPerson.DisposeOf;

  FPerson := FOrionORM.Find([LabeledEdit2.Text]);
  EditID.Text := FPerson.ID.ToString;
  EditName.Text := FPerson.Name;
  EditSalary.Text := FPerson.Salary.ToString;
  if FPerson.Active then
    SwitchActive.State := tssOn
  else
    SwitchActive.State := tssOff;

  EditStreet.Text := FPerson.Address.Street;
  EditNumber.Text := FPerson.Address.Number;
  EditNeighborhood.Text := FPerson.Address.Neighborhood;
  EditCity.Text := FPerson.Address.City;
  EditPostalCode.Text := FPerson.Address.PostalCode;
  EditFinancialStatus.Text := TRttiEnumerationType.GetName(FPerson.FinancialStatus);
  FillStringGridContacts(FPerson.Contacts);
  Memo1.Lines.Clear;
  for Contact in FPerson.Contacts do
    Memo1.Lines.Add(Format('ID: %d - PersonID: %d - PhoneNumber: %s', [Contact.ID, Contact.PersonID, Contact.PhoneNumber]));

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

procedure TForm1.Button4Click(Sender: TObject);
var
  Person : TPerson;
  Contact : TContact;
begin
  Person := FOrionORM.FindOneWithWhere(LabeledEdit1.Text);
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

procedure TForm1.Button5Click(Sender: TObject);
begin
  FOrionORM.Delete([LabeledEdit2.Text]);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  Contact : TContact;
begin
  if not Assigned(FPerson) then
    FPerson := TPerson.Create;

  FPerson.ID := StrToIntDef(EditID.Text, 0);
  FPerson.Name := EditName.Text;
  FPerson.Salary := StrToFloat(EditSalary.Text);
  FPerson.Active := SwitchActive.IsOn;
  FPerson.FinancialStatus := TRttiEnumerationType.GetValue<TFinancialStatus>(EditFinancialStatus.Text);
  FPerson.Address.Street := EditStreet.Text;
  FPerson.Address.Number := EditNumber.Text;
  FPerson.Address.Neighborhood := EditNeighborhood.Text;
  FPerson.Address.City := EditCity.Text;
  FPerson.Address.PostalCode := EditPostalCode.Text;

//  Contact := TContact.Create;
//  Contact.PersonID := 2;
//  Contact.PhoneNumber := '99999999999';
//  FPerson.Contacts.Add(Contact);
//  FPerson.Contacts.Delete(0);
  FOrionORM.Save(FPerson);
  EditID.Text := IntToStr(FPerson.ID);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  Contact : TContact;
begin
  Contact := TContact.Create;
  Contact.PersonID := FPerson.ID;
  Contact.PhoneNumber := EditPhoneNumber.Text;
  FPerson.Contacts.Add(Contact);
end;

procedure TForm1.FillStringGridContacts(aContacts: TObjectList<TContact>);
var
  Contact: TContact;
  LPrice: string;
begin
  StringGridContacts.RowCount := 1;
  for Contact in aContacts do
  begin
    StringGridContacts.Cells[0, StringGridContacts.RowCount] := IntToStr(Contact.ID);
    StringGridContacts.Cells[1, StringGridContacts.RowCount] := IntToStr(Contact.PersonID);
    StringGridContacts.Cells[2, StringGridContacts.RowCount] := Contact.PhoneNumber;
    TStringGridHack(StringGridContacts).InsertRow(1);
  end;
  if StringGridContacts.RowCount > 1 then
    StringGridContacts.FixedRows := 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  DBConnection : iDBConnection;
begin
  StringGridConfiguration;
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
  Mapper.Add(TMapperValue.Create('ID', 'PEOPLE_ID', [PrimaryKey, FindKey, AutoInc]));
  Mapper.Add(TMapperValue.Create('Name', 'PEOPLE_NAME'));
  Mapper.Add(TMapperValue.Create('Salary', 'PEOPLE_SALARY'));
  Mapper.Add(TMapperValue.Create('Active', 'PEOPLE_ACTIVE'));
  Mapper.Add(TMapperValue.Create<TFinancialStatus>('FinancialStatus', 'PEOPLE_FINANCIAL_STATUS', TEnumConvert<TFinancialStatus>.Create));
  Mapper.Add(TMapperValue.Create('Address.Street', 'PEOPLE_STREET'));
  Mapper.Add(TMapperValue.Create('Address.Number', 'PEOPLE_NUMBER'));
  Mapper.Add(TMapperValue.Create('Address.Neighborhood', 'PEOPLE_NEIGHBORHOOD'));
  Mapper.Add(TMapperValue.Create('Address.City', 'PEOPLE_CITY'));
  Mapper.Add(TMapperValue.Create('Address.PostalCode', 'PEOPLE_POSTAL_CODE'));
  Mapper.Add(TMapperValue.Create('Contacts', MapperContacts, TAssociation.Create(OneToMany, ['PEOPLE_ID'], ['PC_PEOPLE_ID'])));
  FOrionORM.Mapper(Mapper);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FPerson) then
    FPerson.DisposeOf;
end;

procedure TForm1.StringGridConfiguration;
begin
  StringGridContacts.Cols[0].Text := 'ID';
  StringGridContacts.ColWidths[0] := 150;
  StringGridContacts.Cols[1].Text := 'PeopleID';
  StringGridContacts.ColWidths[1] := 150;
  StringGridContacts.Cols[2].Text := 'PhoneNumber';
  StringGridContacts.ColWidths[2] := 150;
end;

{ TStringGridHack }

procedure TStringGridHack.DeleteRow(ARow: Longint);
var
  GemRow: Integer;
begin
  GemRow := Row;
  if RowCount > FixedRows + 1 then
    inherited DeleteRow(ARow)
  else
    Rows[ARow].Clear;
  if GemRow < RowCount then
    Row := GemRow;
end;

procedure TStringGridHack.InsertRow(ARow: Longint);
var
  GemRow: Integer;
begin
  GemRow := Row;
  while ARow < FixedRows do
    Inc(ARow);
  RowCount := RowCount + 1;
  Row := GemRow;
end;

end.
