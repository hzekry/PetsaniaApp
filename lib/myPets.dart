import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petapp/medicalRecords.dart';

import 'navbar.dart';

class Pet {
  final String name;
  final String breed;
  final String age;
  final String gender;
  final String species;
  final String? image;

  Pet({
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.species,
     this.image,
  });
}

class PetsScreen extends StatefulWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _petsStream;
  List<Pet> _pets = [];
  late File? _imageFile = null;
  String downloadUrl = '';
  final List<String> speciesList = [
    'Dog',
    'Cat',
    'Bird',
    'Fish',
    'Ferret',
    'Snake',
    'Guinea Pig',
    'Hamster',
    'Hedgehog',
    'Rabbit',
  ];
  String? selectedSpecies;
  String image = '';
  @override
  void initState() {
    super.initState();
    _petsStream = FirebaseFirestore.instance
        .collection('pet')
        .where('customer_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Future<void> _addPet(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController breedController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController genderController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add a Pet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(children: [
                      CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: _imageFile != null
                              ? Image.file(_imageFile!)
                              : Container(),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blueGrey,
                          child: IconButton(
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _imageFile = File(pickedFile.path);
                                });
                              }
                            },
                            icon: Icon(Icons.camera_alt),
                            iconSize: 15,
                          ),
                        ),
                      )
                    ]),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                      ),
                    ),
                    TextField(
                      controller: breedController,
                      decoration: InputDecoration(
                        labelText: 'Pet Breed',
                      ),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Pet Age',
                      ),
                    ),
                    TextField(
                      controller: genderController,
                      decoration: InputDecoration(
                        labelText: 'Pet Gender',
                      ),
                    ),
                    SingleChildScrollView(
                      child: DropdownButtonFormField<String>(
                        value: selectedSpecies,
                        decoration: InputDecoration(
                          labelText: 'Pet Species',
                        ),
                        items: speciesList.map((species) {
                          return DropdownMenuItem<String>(
                            value: species,
                            child: Text(species),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecies = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      nameController.text = '';
                      breedController.text = '';
                      ageController.text = '';
                      genderController.text = '';
                      selectedSpecies = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xff3E54AC)),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Color(0xff3E54AC))),
                  onPressed: () async {
                    var downloadUrl;
                    if (_imageFile != null) {
                      var snapshot = await FirebaseStorage.instance
                          .ref()
                          .child(
                          'pet_images/${nameController.text}-${DateTime.now().millisecondsSinceEpoch}.png')
                          .putFile(_imageFile!);
                      downloadUrl = await snapshot.ref.getDownloadURL();
                      setState(() {
                        _imageFile = null;
                      });
                    }
                    String name = nameController.text;
                    String breed = breedController.text;
                    String age = ageController.text;
                    String gender = genderController.text;

                    Pet newPet = Pet(
                      name: name,
                      breed: breed,
                      age: age,
                      gender: gender,
                      species: selectedSpecies!,
                      image: downloadUrl,
                    );

                    FirebaseFirestore.instance.collection('pet').add({
                      'customer_id': FirebaseAuth.instance.currentUser!.uid,
                      'name': newPet.name,
                      'breed': newPet.breed,
                      'age': newPet.age,
                      'gender': newPet.gender,
                      'species': newPet.species,
                      'imageUrl': newPet.image!,
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editPet(BuildContext context, Pet pet, String petId) async {
    TextEditingController nameController =
    TextEditingController(text: pet.name ?? '');
    TextEditingController breedController =
    TextEditingController(text: pet.breed ?? '');
    TextEditingController ageController =
    TextEditingController(text: pet.age ?? '');
    TextEditingController genderController =
    TextEditingController(text: pet.gender ?? '');
    String? selectedSpecies = pet.species;
    _imageFile = null;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Pet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(children: [
                      CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child:  _imageFile != null
                              ? Image.file(_imageFile!)
                              : pet.image != null && pet.image!.isNotEmpty
                              ? Image.network(pet.image!)
                              : Container(), // display the picked image if available, else an empty container
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blueGrey,
                          child: IconButton(
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _imageFile = File(pickedFile.path);
                                });
                              }
                            },
                            icon: Icon(Icons.camera_alt),
                            iconSize: 15,
                          ),
                        ),
                      )
                    ]),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                      ),
                    ),
                    TextField(
                      controller: breedController,
                      decoration: InputDecoration(
                        labelText: 'Pet Breed',
                      ),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Pet Age',
                      ),
                    ),
                    TextField(
                      controller: genderController,
                      decoration: InputDecoration(
                        labelText: 'Pet Gender',
                      ),
                    ),
                    SingleChildScrollView(
                      child: DropdownButtonFormField<String>(
                        value: selectedSpecies,
                        decoration: InputDecoration(
                          labelText: 'Pet Species',
                        ),
                        items: speciesList.map((species) {
                          return DropdownMenuItem<String>(
                            value: species,
                            child: Text(species),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecies = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      nameController.text = '';
                      breedController.text = '';
                      ageController.text = '';
                      genderController.text = '';
                      selectedSpecies = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xff3E54AC)),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Color(0xff3E54AC))),
                  onPressed: () async {
                    var downloadUrl;
                    if (_imageFile != null) {
                      var snapshot = await FirebaseStorage.instance
                          .ref()
                          .child(
                          'pet_images/${nameController.text}-${DateTime.now().millisecondsSinceEpoch}.png')
                          .putFile(_imageFile!);
                      downloadUrl = await snapshot.ref.getDownloadURL();
                      setState(() {
                        _imageFile = null;
                      });
                    }
                    String name = nameController.text;
                    String breed = breedController.text;
                    String age = ageController.text;
                    String gender = genderController.text;

                    Pet newPet = Pet(
                      name: name,
                      breed: breed,
                      age: age,
                      gender: gender,
                      species: selectedSpecies!,
                      image: downloadUrl?? pet.image,
                    );
                    FirebaseFirestore.instance
                        .collection('pet')
                        .doc(petId)
                        .update({
                      'customer_id': FirebaseAuth.instance.currentUser!.uid,
                      'name': newPet.name,
                      'breed': newPet.breed,
                      'age': newPet.age,
                      'gender': newPet.gender,
                      'species': newPet.species,
                      'imageUrl': newPet.image,
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removePet(String petId) {
    FirebaseFirestore.instance.collection('pet').doc(petId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'My Pets',
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading pets'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No pets added yet.'),
            );
          }

          _pets = snapshot.data!.docs.map((doc) {
            return Pet(
              name: doc['name'] ?? '',
              breed: doc['breed'] ?? '',
              age: doc['age'] ?? '',
              gender: doc['gender'] ?? '',
              species: doc['species'] ?? '',
              image: doc['imageUrl'] ?? '',
            );
          }).toList();

          return ListView.builder(
            itemCount: _pets.length,
            itemBuilder: (context, index) {
              Pet pet = _pets[index];

              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => medicalRecords(
                              petId: snapshot.data!.docs[index].id,
                            )));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: pet.image != null ? NetworkImage(pet.image!) : null,

                        radius: 30,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name ?? '',
                              style: GoogleFonts.oswald(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              pet.breed ?? '',
                              style: GoogleFonts.roboto(),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${pet.age} old'?? '',
                              style: GoogleFonts.roboto(),
                            ),
                            SizedBox(height: 4),
                            Text(
                              pet.gender ?? '',
                              style: GoogleFonts.roboto(),
                            ),
                            SizedBox(height: 4),
                            Text(
                              pet.species ?? '',
                              style: GoogleFonts.roboto(),
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  IconButton(
                                    color: Colors.blueGrey,
                                    onPressed: () {
                                      _editPet(context, pet,
                                          snapshot.data!.docs[index].id);
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    color: Colors.blueGrey,
                                    onPressed: () async {
                                      bool confirm = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Are you sure you want to delete this pet?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            );
                                          });
                                      if (confirm == true) {
                                        _removePet(
                                            snapshot.data!.docs[index].id);
                                      }
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffD9D9D9),
        onPressed: () {
          _addPet(context);
        },
        child: Stack(children: [
          Icon(
            Icons.pets_sharp,
            size: 50,
            color: Color(0xff3E54AC),
          ),
          Positioned(
              left: 0, right: 0, bottom: 0, top: 15, child: Icon(Icons.add)),
        ]),
      ),
      bottomNavigationBar: bottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}