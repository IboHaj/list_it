import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:list_it/ChangeNotifiers/client.dart';
import 'package:list_it/screens/main_page.dart';
import 'package:list_it/utils/extensions.dart';
import 'package:list_it/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();

  bool validateEmail(String? email) {
    RegExp regexp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (email == null || email.isEmpty) {
      log("Email is empty");
      return false;
    } else {
      if (!regexp.hasMatch(email)) {
        log("Email isn't a match");
        return false;
      }
    }

    return true;
  }

  bool validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      log("Password is empty");
      return false;
    } else {
      if (password.length < 8) {
        log("Password is short");
        return false;
      }
    }

    return true;
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credentials.user;
    } catch (e) {
      log('something went wrong');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Client>(
      builder: (context, client, child) => Scaffold(
        backgroundColor: context.secondaryContainer,
        appBar: CustomAppBar(
          bgColor: context.secondaryContainer,
          size: 60,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
        ),
        body: Stack(
          children: [
            if (client.logging) Opacity(opacity: 0.4, child: LinearProgressIndicator()),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Welcome to List it! Your one stop for managing various to-do lists and tasks.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            wordSpacing: 6,
                            shadows: [
                              Shadow(offset: Offset(-10, 10.0), blurRadius: 15, color: Color.fromARGB(40, 0, 0, 0)),
                            ],
                          ),
                        ).paddingOnlyB(100),
                      TextField(
                          controller: emailTEC,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: context.onSecondaryContainer,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 3, color: context.onInverseSurface),
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: context.onPrimaryContainer,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).paddingSymmetric(10, 20),
                      TextField(
                          controller: passwordTEC,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: context.onSecondaryContainer,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 3, color: context.onInverseSurface),
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: context.onPrimaryContainer,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).paddingSymmetric(10, 20),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        width: context.width / 3.5,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            onTap: () async {
                              if (validateEmail(emailTEC.text) && validatePassword(passwordTEC.text)) {
                                client.notify(() => client.logging = true);
                                User? user = await createUserWithEmailAndPassword(emailTEC.text, passwordTEC.text);
                                if (user != null && context.mounted) {
                                  client.notify(() => client.logging = false);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainPage()),
                                    (predicate) => false,
                                  );
                                } else if (context.mounted) {
                                  client.notify(() => client.logging = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "There's an account registered with this email, try another email.",
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Please make sure that the email and password fields are not empty or that your password must be 8 letters or higher in length and your email is correct.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            splashColor: context.inversePrimary,
                            child: Text(
                              "Sign Up",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(offset: Offset(-10, 10.0), blurRadius: 10, color: Color.fromARGB(40, 0, 0, 0)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
