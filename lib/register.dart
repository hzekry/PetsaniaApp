import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'login.dart';
// class Pet {
//   final String name;
//   final String breed;
//   final String age;
//   final String gender;
//   final String species;
//
//   Pet({
//     required this.name,
//     required this.breed,
//     required this.age,
//     required this.gender,
//     required this.species,
//
//   });
// }
class register extends StatefulWidget {
  const register({Key? key}) : super(key: key);

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordMatch = false;
  // List<Pet> petList = [];
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
  String? selectedState;
  String? selectedCountry;
 // void _deletePet(Pet pet){
 //   setState(() {
 //     petList.remove(pet);
 //   });
 // }
  void _checkPassword() {
    if (_passwordController.text == _confirmPasswordController.text) {
      setState(() {
        _passwordMatch = true;
      });
    } else {
      setState(() {
        _passwordMatch = false;
      });
    }
  }
  // void _addPet(BuildContext context) async {
  //   TextEditingController nameController = TextEditingController();
  //   TextEditingController breedController = TextEditingController();
  //   TextEditingController ageController = TextEditingController();
  //   TextEditingController genderController = TextEditingController();
  //
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text('Add a Pet'),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: nameController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Pet Name',
  //                     ),
  //                   ),
  //                   TextField(
  //                     controller: breedController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Pet Breed',
  //                     ),
  //                   ),
  //                   TextField(
  //                     controller: ageController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Pet Age',
  //                     ),
  //                   ),
  //                   TextField(
  //                     controller: genderController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Pet Gender',
  //                     ),
  //                   ),
  //                   SingleChildScrollView(
  //                     child: DropdownButtonFormField<String>(
  //                       value: selectedSpecies,
  //                       decoration: InputDecoration(
  //                         labelText: 'Pet Species',
  //                       ),
  //                       items: speciesList.map((species) {
  //                         return DropdownMenuItem<String>(
  //                           value: species,
  //                           child: Text(species),
  //                         );
  //                       }).toList(),
  //                       onChanged: (value) {
  //                         setState(() {
  //                           selectedSpecies = value;
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     nameController.text = '';
  //                     breedController.text = '';
  //                     ageController.text = '';
  //                     genderController.text = '';
  //                     selectedSpecies = null;
  //                   });
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text(
  //                   'Cancel',
  //                   style: TextStyle(color: Color(0xff3E54AC)),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 style: ButtonStyle(
  //                   backgroundColor: MaterialStateProperty.all(Color(0xff3E54AC)),
  //                 ),
  //                 onPressed: () {
  //                   String name = nameController.text;
  //                   String breed = breedController.text;
  //                   String age = ageController.text;
  //                   String gender = genderController.text;
  //
  //                   Pet newPet = Pet(
  //                     name: name,
  //                     breed: breed,
  //                     age: age,
  //                     gender: gender,
  //                     species: selectedSpecies!,
  //                   );
  //
  //                   setState(() {
  //                     petList.add(newPet);
  //                   });
  //
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Save'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _register() async {
    try {
      final auth = FirebaseAuth.instance;
      final email = _emailController.text;

      List<String> signInMethods = await auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The account already exists for that email."),
          ),
        );
        return;
      }

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

        DocumentReference userRef =
        FirebaseFirestore.instance.collection("Customer").doc(userId);

        await userRef.set({
          'name': _nameController.text,
          'email': email,
          'country': selectedCountry,
          'state': selectedState,
          'phone_number': _phoneController.text,
          'image': '',
        });

        // for (Pet pet in petList) {
        //   await FirebaseFirestore.instance.collection('pet').add({
        //     'customer_id': userId,
        //     'name': pet.name,
        //     'breed': pet.breed,
        //     'age': pet.age,
        //     'gender': pet.gender,
        //     'species': pet.species,
        //   });
        // }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text);
        await prefs.setString('password', _passwordController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred while registering."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The password provided is too weak."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred while registering."),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.bottomRight,
              image: ResizeImage(
                AssetImage("assets/paws.png"),
                width: 171,
                height: 172,
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "PETSANIA",
                  style: GoogleFonts.yesevaOne(
                    color: Color(0xff252969),
                    fontSize: 15,
                  ),
                ),
                Image.asset(
                  "assets/logo.png",
                  width: 94,
                  height: 96,
                ),
                SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Name",

                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",

                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your email"; // Error message for empty field
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",

                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your password"; // Error message for empty field
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Confirm Password",
                              ),
                              onChanged: (_) => _checkPassword(),
                            ),
                          ),
                        ),
                      ),
                      if (!_passwordMatch)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Passwords don't match.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Country",
                              ),
                              value: selectedCountry,
                              items: [
                                'USA'
                              ].map((country) {
                                return DropdownMenuItem<String>(
                                  value: country,
                                  child: Text(country),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            ),
                          ),
                        ),

                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "State",
                              ),
                              value: selectedState,
                              items: [
                                'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID',
                                'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS',
                                'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
                                'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV',
                                'WI', 'WY'
                              ].map((state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedState = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select a state"; // Error message for empty field
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Phone Number",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your phone number"; // Error message for empty field
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),

                // Column(
                //   children: petList.map((pet) => PetCard(pet: pet, onDelete: () => _deletePet(pet),
                //   )
                //   ).toList(),
                // ),
                // ElevatedButton(onPressed: (){
                //   // _addPet(context);
                // }, child: Text('Add your Pets'),
                //   style: ButtonStyle(
                //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //       RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10.0),
                //       ),
                //     ),
                //     backgroundColor: MaterialStateProperty.all<Color>(
                //       Color(0xff3E54AC),
                //     ),
                //   ),),
                Container(
                  child: Center(
                    child: ElevatedButton(
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          // _addPet(context);
                  _register();
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text("Please fill out all required fields."),
    ),
    );
    }
    },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 80),
                        child: Text(
                          "Register",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ButtonStyle(

                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff3E54AC),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => login()),
                    );
                  },
                  child: Text(
                    "Already have an account? Sign in",
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),


                ),
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// class PetCard extends StatelessWidget {
//   final Pet pet;
//   final VoidCallback onDelete;
//
//   const PetCard({required this.pet, required this.onDelete});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Icon(Icons.pets),
//         title: Text(pet.name),
//         subtitle: Text('Breed: ${pet.breed}, Age: ${pet.age}, Gender: ${pet.gender}'),
//         trailing: IconButton(
//           icon: Icon(Icons.delete),
//           onPressed: onDelete,
//         ),
//       ),
//     );
//   }
// }
