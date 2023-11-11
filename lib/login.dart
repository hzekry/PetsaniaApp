import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'register.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const home()),
      );
      // handle successful login
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar('Invalid email or password.');
      }
    } catch (e) {
      showSnackbar('An error occurred. Please try again later.');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(color: Color(0xffD9D9D9)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Center(
                    child: TextButton(
                      onPressed: () async {
                        _login();
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                            bottom: 15,
                          ),
                        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New User?",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const register()),
                        );
                      },
                      child: Text(
                        "Register Now",
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
