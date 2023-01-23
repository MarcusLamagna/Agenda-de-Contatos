import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/*
* Declarando Strings que será o nome das nossas colunas no banco de dados
*
* final não permite mudanças nos valores das Strings delcaradas
*/
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

/*
*
* */
class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  /*
  * Declarando o banco de dados
  * */
  Database _db; //Nenhum outro local será capaz de mexer no banco de dados

  //Inicializando o banco de dados
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //Criando funcao para nosso initDb
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    //Abrir nosso banco de dados
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $contactTable("
          "$idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT,"
          "$emailColumn TEXT,"
          "$phoneColumn TEXT,"
          "$imgColumn TEXT)");
    });
  }

  /*
  * Funcao que recebe e Salva o contato cadastrado
  * */
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db; //Ontendo o banco de dados
    contact.id = await dbContact.insert(
        contactTable, contact.toMap()); //Inserindo contato
    return contact;
  }

  /*
  * Funcao para obter os dados de um contato
  * */
  Future<Contact> getContact(int id) async {
    Database dbContact = await db; //Ontendo o banco de dados
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    //Verificando se retornou um contato
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /*
  * Funcao deletar contato
  * */
  Future<int> deleteContact(int id) async {
    Database dbContact = await db; //Ontendo o banco de dados
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  /*
  * Funcao para atualizar contato
  * */
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db; //Ontendo o banco de dados
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  /*
  * Funcao para obter lista de contatos
  */
  Future<List>getAllContacts() async{
    Database dbContact = await db; //Ontendo o banco de dados
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  /*
  * Funcao
  * */
  Future<int> getNumber() async{
    Database dbContact = await db;
    //Obtendo a contagem e retornando a quantidade de elementos da tabela
    return Sqflite.firstIntValue(await dbContact.rawQuery
      ("SELECT COUNT(*) FROM $contactTable"));
  }
  //Fechasndo o banco de dados
 Future close() async {
  Database dbContact = await db;
  dbContact.close();
}
}

/*
*  Criando nossa tabela Contato
*  id   name    email     phone   img
*   0   Marcus  m@gmail   11993   imagem
*/
//Classe que define tudo o que o contato irá armazenar
class Contact {
  /*
  * late permiteque i valor inicialmente seja nule, mas, quando for utilizado
  * em alguma função ou classe, ele vai ser considerado não nulo
  * */
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  //Construtor para pegar o mapa e constroe o contato
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  /*
  * Função que retorna um mapa
  * */
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  /*
  * Quando for ler os dados do contato ele retornar os valores mencionado abaixo
  * */
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
