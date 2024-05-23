# OrionORM
Framework ORM para aplicações Delphi

#### Principais características
* Suporte a master detail;
* Mapeamento de tipos primitivos, enums e objetos dentro de objetos;
* Paginação de dados de forma simples;
* Suporte a driver FireDAC, mas pode ser extendido para utilizar qualquer outro driver, implementando as interfaces de conexão;
* Funciona sem a utilização de custom attributes, reduzindo assim o acoplamento;

## Instalação

Para instalar basta registrar no library patch do delphi o caminho da pasta src da biblioteca ou utilizar o Boss (https://github.com/HashLoad/boss) para facilitar ainda mais, executando o comando

```
boss install https://github.com/ricardo-pontes/OrionORM
```
## Como utilizar

É necessário adicionar ao uses do seu formulário as units:

```
  Orion.ORM,
  Orion.ORM.Mapper,
  Orion.ORM.Interfaces,
  Orion.ORM.DB.Interfaces,
  Orion.ORM.Types,
  Orion.ORM.DBConnection.FireDAC.SQLite;
```

Instancie uma variável de conexão e configure as informações do banco de dados(atualmente suporte a firebird e sqlite);
```
  //DBConnection := TOrionORMDBConnectionFiredacSQLite.New;
  //DBConnection := TOrionORMDBConnectionFiredacFirebird.New;
  DBConnection := TOrionORMDBConnectionFiredacSQLite.New;
  DBConnection.Configurations(ExtractFileDir(GetCurrentDir) + 'dbteste.sqlite3', '', '', '', 0);
```
Instancie uma variável do ORM para começar a configurar (a paginação é um parâmetro opcional) e logo após, comece o mapeamento da classe;
```
  FOrionORM := TOrionORM<TPerson>.New(DBConnection, TOrionPaginationSQLite.New);
  Mapper := TOrionMapper.New;
  MapperContacts := TOrionMapper.New;

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
  Mapper.OrderBy := 'PEOPLE_NAME';
  FOrionORM.Mapper(Mapper);
```
`DBConnection` Interface de conexão com o banco de dados;
`FOrionORM` interface do ORM que irá trabalhar com a classe;
`Mapper` interface de mapeamento da classe;

Feito isto, o ORM está pronto para uso;

##Operações
####Find
O Find tem 2 sobrecargas, podendo ser utilizado tanto na obtenção de um único registro podendo ser obtido por um ou mais parâmetros, como na obtenção de todos sem passar parâmetros;
```
  People := FOrionORM.Find([1]);
  Peoples := FOrionORM.Find;
```
####FindOneWithWhere
O FindOneWithWhere é utilizado para obter um único registro, porém de forma mais flexível, através de cláusula where;
```
  Person := FOrionORM.FindOneWithWhere('SUA CLAUSULA WHERE AQUI');
```

####FindManyWithWhere
O FindManyWithWhere é utilizado para obter vários registros, porém de forma mais flexível, através de cláusula where;
```
  Persons := FOrionORM.FindManyWithWhere('SUA CLAUSULA WHERE AQUI');
```
####Save
O Save é utilizado para persistir os dados no banco, e ele persistirá tanto as alterações no registro mestre, quanto nos registros detalhe;
```
  FOrionORM.Save(FPerson);
```

####Delete
O Delete tem 2 sobrecargas, podendo ser utilizado para a deleção de um único registro por um ou mais parâmetros, como na deleção por cláusula where;
```
  FOrionORM.Delete([1]);
  FOrionORM.Delete('SUA CLAUSULA WHERE AQUI');
```
####Paginação
Para se trabalhar com paginação é muito simples, basta utilizar a interface de paginação e fazer o controle de tamanho de página e em qual página você quer obter os dados;
```
  FOrionORM.Pagination.PageSize := 5;
  FOrionORM.Pagination.Page := 1;
  Persons := FOrionORM.Find;
```
