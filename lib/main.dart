import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DB Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'DB Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  final databaseReference = Firestore.instance;

  void createRecord() async {
    await databaseReference
        .collection("testboop")
        .document("1")
        .setData({'title': 'bladibla', 'desc': 'ladida'});
    DocumentReference docRef = await databaseReference
        .collection("testboop")
        .add({'title': 'WOOOOP', 'desc': 'slurpad'});
    print(docRef.documentID);
  }

  void getData() {
    databaseReference
        .collection("testboops")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('${f.data}}'));
    });
  }

  void deleteData() {
    try {
      databaseReference
        .collection('testboops')
        .document('1')
        .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database.reference().child('items');
    itemRef.onChildAdded
        .listen(_onEntryAdded); //fixa func om entry läggs till i db
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      //checks if no errors
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.title),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.title = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.text_fields),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.plus_one),
                          onPressed: () {
                            createRecord();
                          },
                          color: Colors.greenAccent,
                          splashColor: Colors.green,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteData();
                          },
                          color: Colors.redAccent,
                          splashColor: Colors.red,
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: handleSubmit,
                          color: Colors.tealAccent,
                          splashColor: Colors.greenAccent,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext cont, DataSnapshot snap,
                  Animation<double> anim, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title: Text(items[index].title),
                  subtitle: Text(items[index].body),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  String key;
  String title;
  String body;

  Item(this.title, this.body);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        body = snapshot.value["body"];

  toJson() {
    return {
      "title": title,
      "body": body,
    };
  }
}
