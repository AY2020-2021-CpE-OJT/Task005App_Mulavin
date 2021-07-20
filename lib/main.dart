import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

final List <contacts_Todo> conts_Todo = <contacts_Todo>[];

void main(){
  runApp(
    MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.normal
          ),
          headline1: TextStyle(
              fontSize: 90.0,
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      title: 'Contact List',
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/second': (context) => CustomForm(),
      },
    ),
  );
}
class contacts_Todo{
  final String firstName;
  final String lastName;
  final List<String> contactNumbers;

  contacts_Todo(this.firstName, this.lastName, this.contactNumbers);
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Contact List'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.pushNamed(context,'/second'
              );
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context)
              => FinalDisplayScreen(todo: conts_Todo)));
        },
        child: Text ('Go to Contact List Display'),
        )
      )
    );
  }
}
class CustomForm extends StatefulWidget {
  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  final _forController1 = TextEditingController();
  final _forController2 = TextEditingController();
  List <TextEditingController> _numController = <TextEditingController>[
    TextEditingController()
  ];
  int forNumbers = 1;
  Future<ContactList>? _futureContactList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _forController1.dispose();
    _forController2.dispose();
    super.dispose();
  }
  void _saveLatestValue(){

  }
  void addNumbers(){
    setState(() {
      forNumbers++;
      _numController.insert(0, TextEditingController());
    });
  }
  void removeNumbers(){
    setState(() {
      if (forNumbers != 0){
        forNumbers--;
        _numController.removeAt(0);
      }
    });
  }
  void goToFinalDisplayScreen(){
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => FinalDisplayScreen(todo: conts_Todo)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contacts'),
      ),
        body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: TextFormField(
                 controller: _forController1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter First Name',
                      labelText: 'First Name*'
                  ),
                 inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[0-9]+"))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You need to enter a Name with no special characters';
                    }
                    return null;
                  },
                ),
             ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _forController2,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Last Name',
                      labelText: 'Last Name*'
                  ),
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[0-9]+"))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You need to enter a Name with no special characters';
                    }
                    return null;
                  },
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: forNumbers,
                itemBuilder: (context, i){
                  return TextFormField(
                    controller: _numController[i],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Phone Number',
                        labelText: 'Phone Number ${i +1}*'
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You need to enter a Name with no special characters';
                      }
                      return null;
                      },
                  );
                  },
                separatorBuilder: (context, i){
                  return Divider();
                  },
              ),
            ),
            new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'addButton',
                    child: Icon(Icons.add),
                    onPressed: addNumbers,
                  ),
                  FloatingActionButton(
                    heroTag: 'removeButton',
                    child: Icon(Icons.remove),
                    onPressed: removeNumbers,
                  )
                ]
            ),
             new Flexible(
                fit: FlexFit.loose,
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 'homeButton',
                        child: Icon(Icons.home),
                          onPressed: (){
                          Navigator.pushNamed(context, '/');
                          }
                      ),
                      FloatingActionButton(
                        heroTag: 'saveButton',
                        child: Icon(Icons.check),
                          onPressed: (){
                            _saveLatestValue();
                            List<String> numContacts = <String>[];
                            for (int i = 0; i < forNumbers; i++){
                              numContacts.add(_numController[i].text);
                            }
                            setState(() {
                              conts_Todo.insert(0, contacts_Todo(_forController1.text, _forController2.text, numContacts));
                              _futureContactList = createContactListSecured(_forController2.text, _forController1.text, numContacts);
                            });
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => FinalDisplayScreen(todo: conts_Todo)));
                          }
                      )
                    ]
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class FinalDisplayScreen extends StatelessWidget {
  final List<contacts_Todo> todo;
  FinalDisplayScreen({Key? key, required this.todo}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text ('Contact Number Lists'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ContactListDB()
      ),
      floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.home),
          onPressed: (){
            Navigator.pushNamed(context, '/');
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
final hostLink = 'https://contact-list-activity.herokuapp.com';
Future<ContactList> createContactListSecured(String lastname, String firstname, List<dynamic> contactNumbers) async {
  final res = await http.post(
    Uri.parse('$hostLink/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<dynamic, dynamic>{
      'email':'joiiie_keiiil@yahoo.com',
      'password': '1100011'
    })
  ); final String token = jsonDecode(res.body)['token'];

  await http.post(
      Uri.parse('$hostLink/user/contactNumbers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
         HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lastname,
        'first_name': firstname,
        'phone_numbers' : contactNumbers
      })
  );
  if (res.statusCode == 200) {
    return ContactList.fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to update the Contact List.');
  }
}
Future<ContactList> fetchContactListSecured(int index) async {
  final res = await http.post(
      Uri.parse('$hostLink/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'email':'joiiie_keiiil@yahoo.com',
        'password': '1100011'
      })
  ); final String token = jsonDecode(res.body)['token'];

  final response = await http.get(
      Uri.parse('$hostLink/user/contactNumbers'),
      headers:{
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
  if (response.statusCode == 200) {
    return ContactList.fromJson(jsonDecode(response.body)[index]);
  } else {
    throw Exception('Failed to load the Contact List.');
  }
}
Future<ContactList> updateContactListSecured(String lastname, String firstname, List<dynamic> contactNumbers, String id) async {
  final res = await http.post(
      Uri.parse('$hostLink/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'email':'joiiie_keiiil@yahoo.com',
        'password': '1100011'
      })
  ); final String token = jsonDecode(res.body)['token'];

  await http.put(
      Uri.parse('$hostLink/user/contactNumbers/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lastname,
        'first_name': firstname,
        'phone_numbers' : contactNumbers
      })
  );
  if (res.statusCode == 200) {
    return ContactList.fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to update the Contact List.');
  }
}
deleteContactListSecured(String id) async {
  final res = await http.post(
      Uri.parse('$hostLink/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'email':'joiiie_keiiil@yahoo.com',
        'password': '1100011'
      })
  ); final String token = jsonDecode(res.body)['token'];
  await http.delete(
      Uri.parse('$hostLink/user/contactNumbers/$id'),
      headers:{
        HttpHeaders.authorizationHeader: 'Bearer $token'
      });
  if (res.statusCode != 200) {
    throw Exception('Failed to delete Contact List.');
  }
}
contactListLogin() async {
  final res = await http.post(
      Uri.parse('$hostLink/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'email':'joiiie_keiiil@yahoo.com',
        'password': '1100011'
      })
  );
}
class ContactList {
  final String firstname;
  final String lastname;
  final List<dynamic> contactNumbers;
  final dynamic id;

  ContactList({
    required this.lastname, required this.firstname, required this.contactNumbers, required this.id
  });

  factory ContactList.fromJson(Map<String, dynamic> json) {
    return ContactList(
      lastname: json['last_name'],
      firstname: json['first_name'],
      contactNumbers: json['phone_numbers'],
      id: json['_id'],
    );
  }
}
class ContactListDB extends StatefulWidget {
  const ContactListDB({Key? key}) : super(key: key);

  @override
  _ContactListDBState createState() => _ContactListDBState();
}

class _ContactListDBState extends State<ContactListDB> {
  List<Future<ContactList>> futureContactList = <Future<ContactList>>[];
  int numContacts = 0;
  var stringconts = '';
  @override
  void initState(){
    super.initState();
    fetchNumContacts().then((result){
      setState((){
        numContacts = int.parse(result);
        for (int i = 0; i < numContacts; i++){
          futureContactList.insert(i, fetchContactListSecured(i));
        }
      });
    });
  }
  var continfo;
  fetchNumContacts() async{
    final req = await http.get(
        Uri.parse('$hostLink/contactNumbers/totalCount'));
    continfo = req.body;
    return continfo;
  }
@override
Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: numContacts,
      itemBuilder: (context, index){
        return Row(
          children: [
            Expanded(
              child: ListTile(
                title: FutureBuilder<ContactList>(
                  builder: (context, snapshot){
                    if (snapshot.hasData){
                      return Text('${snapshot.data!.firstname.toString()} ${snapshot.data!.lastname.toString()}');
                    } else if (snapshot.hasError){
                      return Text ("${snapshot.error}");
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                  future: futureContactList[index],
                ),
                subtitle: FutureBuilder<ContactList>(
                  builder: (context, snapshot){
                    if (snapshot.hasData){
                      return Text (snapshot.data!.contactNumbers.toString());
                    }else if (snapshot.hasError){
                      return Text ("${snapshot.error}");
                    }
                    return Center(
                        child: CircularProgressIndicator()
                    );
                  },
                  future: futureContactList[index],
                ),
              ),
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForUpdatingContacts(index: index)));
                  },
                ),
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20.0,
                      color: Colors.white,
                    ),
                    onPressed: (){
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) =>
                              AlertDialog(
                                title: const Text('Delete'),
                                content: const Text('Are you sure you want to delete this contact?'),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel')
                                  ),
                                  FutureBuilder<ContactList>(
                                    builder: (context, snapshot) {
                                      return TextButton(
                                          onPressed: () {
                                            deleteContactListSecured(snapshot.data!.id.toString());
                                            fetchNumContacts().then((result){
                                              setState((){
                                                numContacts = int.parse(result);
                                                for (int i = 0; i < numContacts; i++){
                                                  futureContactList.insert(i, fetchContactListSecured(i));
                                                }
                                              });
                                            });
                                            Navigator.pop(context, 'Delete');
                                          },
                                          child: const Text('Delete')
                                      );
                                    },
                                    future: futureContactList[index],
                                  )
                                ],
                              )
                      );
                    },
                )
              ],
            ),
          ],
        );
      },
      separatorBuilder: (context, i){
        return Divider();
      },
    );
  }
}
class ForUpdatingContacts extends StatefulWidget {
  final int index;
  const ForUpdatingContacts({Key? key, required this.index}) : super(key: key);

  @override
  _ForUpdatingContactsState createState() => _ForUpdatingContactsState();
}

class _ForUpdatingContactsState extends State<ForUpdatingContacts> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  List<TextEditingController> _contactsController = <TextEditingController>[
    TextEditingController()
  ];

  int contacts = 1;
  Future<ContactList>? _futureContacts;
  @override
  void initState(){
    super.initState();
    _futureContacts = fetchContactListSecured(widget.index);
  }
  void _saveLatestValue(){

  }
  void addNumbers(){
    setState(() {
      contacts++;
      _contactsController.insert(0, TextEditingController());
    });
  }
  void removeNumbers(){
    setState(() {
      if (contacts != 0){
        contacts--;
        _contactsController.removeAt(0);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Updating Contacts'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<ContactList>(
          future: _futureContacts,
           builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Text (snapshot.data!.lastname),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Last Name',
                          labelText: 'Last Name*'
                        ),
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[0-9]+"))],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You need to enter a Name with no special characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter First Name',
                            labelText: 'First Name*'
                        ),
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp("[0-9]+"))],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You need to enter a Name with no special characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: contacts,
                        itemBuilder: (context, i){
                          return TextFormField(
                            controller: _contactsController[i],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter Phone Number',
                                labelText: 'Phone Number ${i +1}*'
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'You need to enter a Name with no special characters';
                              }
                              return null;
                            },
                          );
                        },
                        separatorBuilder: (context, i){
                          return Divider();
                        },
                      ),
                    ),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FloatingActionButton(
                            child: Icon(Icons.add),
                            onPressed: addNumbers,
                          ),
                          FloatingActionButton(
                            child: Icon(Icons.remove),
                            onPressed: removeNumbers,
                          )
                        ]
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: FutureBuilder<ContactList>(
                        future: _futureContacts,
                        builder: (context, snapshot) {
                           return ElevatedButton(
                            child: Text('Save'),
                            onPressed: () {
                              _saveLatestValue();
                              List<String> numContacts = <String>[];
                              for (int i = 0; i < contacts; i++) {
                                numContacts.add(_contactsController[i].text);
                              }
                              setState(() {
                                conts_Todo.insert(0, contacts_Todo(
                                    _firstNameController.text,
                                    _lastNameController.text, numContacts));
                                _futureContacts = updateContactListSecured(
                                  _firstNameController.text,
                                  _lastNameController.text, numContacts, snapshot.data!.id.toString());
                              });
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      FinalDisplayScreen(todo: conts_Todo)));
                            },
                          );
                        }
                      ),
                    )
                  ],
                );
              }
            }
            return Text('');
           },
        ),
      ),
    );
  }
}





