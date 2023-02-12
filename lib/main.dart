import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final db = FirebaseFirestore.instance;
String? value;
String? nombre;
String? apellido;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FloatingActionButton(
        onPressed: () {
          // When the User clicks on the button, display a BottomSheet
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return showBottomSheet(context, false, null);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Flutter CRUD'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        // Reading Items form our Database Using the StreamBuilder widget
        stream: db.collection('personas').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int index) {
              DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
              return ListTile(
                title: Text(documentSnapshot['apellido'] +
                    ' ' +
                    documentSnapshot['nombre']),
                onTap: () {
                  // Here We Will Add The Update Feature and passed the value 'true' to the is update
                  // feature.
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return showBottomSheet(context, true, documentSnapshot);
                    },
                  );
                },
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () {
                    // Here We Will Add The Delete Feature
                    db.collection('personas').doc(documentSnapshot.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

showBottomSheet(
    BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
  // Added the isUpdate argument to check if our item has been updated
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 75,
          child: TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              // Used a ternary operator to check if isUpdate is true then display
              // Update Todo.
              labelText: isUpdate ? 'Actualizar nombre' : 'Agregar nombre',
              hintText: 'Nombre',
            ),
            onChanged: (String val) {
              // Storing the value of the text entered in the variable value.
              nombre = val;
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              // Used a ternary operator to check if isUpdate is true then display
              // Update Todo.
              labelText: isUpdate ? 'Actualizar apellido' : 'Agregar Apellido',
              hintText: 'Apellido',
            ),
            onChanged: (String val) {
              // Storing the value of the text entered in the variable value.
              apellido = val;
            },
          ),
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Colors.lightBlueAccent),
            ),
            onPressed: () {
              // Check to see if isUpdate is true then update the value else add the value
              if (isUpdate) {
                db
                    .collection('personas')
                    .doc(documentSnapshot?.id)
                    .update({'nombre': nombre, 'apellido': apellido});
              } else {
                db
                    .collection('personas')
                    .add({'nombre': nombre, 'apellido': apellido});
              }
              Navigator.pop(context);
            },
            child: isUpdate
                ? const Text(
                    'ACTUALIZAR',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text('AGREGAR', style: TextStyle(color: Colors.white))),
      ],
    ),
  );
}
