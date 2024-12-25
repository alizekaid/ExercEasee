import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  /*String email = '';
  String pass = '';*/

  bool notvisible = true;
  bool notVisiblePassword = true;
  Icon passwordIcon = const Icon(Icons.visibility);

  var id = TextEditingController();
  var password = TextEditingController();
  var nameSurname = TextEditingController(); 
  var age = TextEditingController(); 

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility);
    } else {
      passwordIcon = const Icon(Icons.visibility_off);
    }
  }

  void sendVerificationEmail() {
    User user = FirebaseAuth.instance.currentUser!;
    user.sendEmailVerification();
  }

  Future<void> create_user() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: id.text.toString().trim(),
            password: password.text.toString().trim());

    if (userCredential.user != null) {
      sendVerificationEmail();
      // Add user info to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid) // Use the UID of the newly created user
          .set({
        'email': id.text.trim(),
        'name_surname': nameSurname.text.trim(), // Save name and surname
        'age': int.tryParse(age.text.trim()) ?? 0, // Save age as an integer
        'created_at': Timestamp.now(),
        'uid': userCredential.user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Verification mail has been sent to registered Email ID. Verify your account and login again.',
        ),
      ));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const LoginPage();
      }));
    }
  } catch (e) {
    print('Error creating user: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to sign up: ${e.toString()}")),
    );
  }
}
      

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              // Topmost image
              SizedBox(
                height: size.height / 3,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.asset(
                    'assets/images/signup.jpg',
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                child: Column(
                  children: [
                    // Register Text
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                    // Sized box
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                        child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            labelText: 'Name Surname',
                          ),
                          controller: nameSurname,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.numbers,
                              color: Colors.grey,
                            ),
                            labelText: 'Age',
                          ),
                          keyboardType: TextInputType.number, // Ensures only numbers can be entered
                          controller: age,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.alternate_email_outlined,
                              color: Colors.grey,
                            ),
                            labelText: 'Email',
                          ),
                          controller: id,
                        ),
                        TextFormField(
                          obscureText: notvisible,
                          decoration: InputDecoration(
                              icon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey,
                              ),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      notvisible = !notvisible;
                                      notVisiblePassword = !notVisiblePassword;
                                      passwordVisibility();
                                    });
                                  },
                                  icon: passwordIcon)),
                          controller: password,
                        )
                      ],
                    )),

                    const SizedBox(height: 13),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          child: const Text(
                            'By signing up, you agree to our Terms & conditions and Privacy Policy',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                    // SignUp Button
                    ElevatedButton(
                      onPressed: () {
                        create_user();
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Center(
                          child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 15),
                      )),
                    ),

                    // Sized box
                    const SizedBox(height: 25),
                    // Login button
                    Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Joined us before? ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        GestureDetector(
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginPage();
                            }));
                          },
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
