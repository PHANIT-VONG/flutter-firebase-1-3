import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_1_3/pages/create_contact_page.dart';

class ShowContactPage extends StatelessWidget {
  ShowContactPage({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _contactStream =
      FirebaseFirestore.instance.collection('contact').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20.0),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['url']),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['address']),
                  trailing: Text(data['phone']),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ContactPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
