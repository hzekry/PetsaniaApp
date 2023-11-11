import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'navbar.dart';

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String name = '';
  String email = '';
  String phone = '';
  String image = '';
  String state = '';
  List<String> states = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID',
    'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS',
    'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
    'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV',
    'WI', 'WY',
  ];
  late var customerID;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();
  late File? _imageFile = null;
  late TextEditingController nameController;
  late TextEditingController stateController;
  late TextEditingController phoneController;
  bool editName = false;
  bool editState = false;
  bool editPhone = false;

  Future _getData() async {
    var user = FirebaseAuth.instance.currentUser;
    var snapshot = await FirebaseFirestore.instance
        .collection('Customer')
        .doc(user?.uid)
        .get();

    if (snapshot.exists) {
      var doc = snapshot.data();
      setState(() {
        name = doc!['name'];
        email = doc['email'];
        phone = doc['phone_number'];
        image = doc['image'];
        state = doc['state'];
        customerID = snapshot.id;
        nameController = TextEditingController(text: name);
        stateController = TextEditingController(text: state);
        phoneController = TextEditingController(text: phone);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    nameController = TextEditingController();
    stateController = TextEditingController();
    phoneController = TextEditingController();
  }

  Future _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        image = '';
      });
    }
  }

  Future _updateUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (_imageFile != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('customer_profile_images/${user!.uid}.png')
          .putFile(_imageFile!);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        image = downloadUrl;
        _imageFile = null;
      });
    }
    await _firestore.collection('Customer').doc(customerID).update({
      'name': name,
      'state': state,
      'phone_number': phone,
      'image': image, // add the image download URL to the document
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'Profile',
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.bottomLeft,
              image: ResizeImage(
                AssetImage("assets/paws.png"),
                width: 165,
                height: 165,
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            _auth.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => login()),
                            );
                          },
                          icon: Icon(Icons.logout),
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          'SignOut',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: image.isNotEmpty
                              ? NetworkImage(image)
                              : _imageFile?.path != null
                                  ? FileImage(File(_imageFile!.path))
                                  : AssetImage(
                                          'assets/profile_image_placeholder.png')
                                      as ImageProvider,
                          child: Stack(children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.indigo,
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(Icons.camera_alt),
                                  iconSize: 15,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: editName
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => name = value,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editName = !editName;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          name,
                                          style: GoogleFonts.oswald(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editName = !editName;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                        ),
                        Text(email),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: editState
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: stateController,
                                        decoration: InputDecoration(
                                          labelText: 'State',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => state = value,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editState = !editState;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          state,
                                          style: GoogleFonts.oswald(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editState = !editState;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: editPhone
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: phoneController,
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => phone = value,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editPhone = !editPhone;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          phone,
                                          style: GoogleFonts.oswald(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          editPhone = !editPhone;
                                        });
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ],
                                ),
                        ),

                        SizedBox(
                          height: 40,
                        ),
                        IconButton(
                          onPressed: () {
                            _updateUserData();
                            setState(() {
                              editPhone = false;
                              editState = false;
                              editName = false;
                            });
                          },
                          icon: Icon(Icons.save),
                          color: Colors.blueGrey,
                          iconSize: 40,
                        ),
                        Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: 2,
      ),
    );
  }
}
