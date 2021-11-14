import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _addressController = TextEditingController();

  // ---------- Image ----------
  File? _image;
  final _picker = ImagePicker();
  _fromGallery() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.gallery);
    setState(() => _image = File(pickedFile!.path));
  }

  _fromCamera() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.camera);
    setState(() => _image = File(pickedFile!.path));
  }

  _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text('Photo Library'),
                  onTap: () {
                    _fromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    _fromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  get _buildPickerImage {
    return Center(
      child: GestureDetector(
        onTap: () {
          _showPicker(context);
        },
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.red,
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 100,
                  height: 100,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
        ),
      ),
    );
  }

//--------------------------
  Future<void> _buildDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message'),
          content: Container(
            child: Text(message),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  CollectionReference _contact =
      FirebaseFirestore.instance.collection('contact');
  Future<String> _addContact() async {
    await firebase_storage.FirebaseStorage.instance
        .ref('upload/${_image!.path.split("/").last}')
        .putFile(_image!);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('upload/${_image!.path.split("/").last}')
        .getDownloadURL();
    print("URL : $downloadURL");
    return _contact
        .add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'url': downloadURL
        })
        .then((value) => 'Data has been submited!')
        .catchError((error) => 'Failed to add user: $error');
  }

  Future<void> _submit() async {
    String dataFeedback = await _addContact();
    if (dataFeedback.isNotEmpty) {
      _buildDialog(dataFeedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Contact'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPickerImage,
              SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  hintText: 'Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.call),
                  border: OutlineInputBorder(),
                  hintText: 'Phone',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  hintText: 'Address',
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                height: 60.0,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    //
                    _submit();
                  },
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
