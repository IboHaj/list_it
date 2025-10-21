import 'package:flutter/material.dart';
import 'package:list_it/ChangeNotifiers/client.dart';
import 'package:list_it/screens/main_page.dart';
import 'package:list_it/screens/signup_page.dart';
import 'package:list_it/utils/auth.dart';
import 'package:list_it/utils/connection.dart';
import 'package:list_it/utils/extensions.dart';
import 'package:list_it/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../utils/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  final ValueNotifier<bool> isChecked = ValueNotifier(false);

  bool validateEmail(String? email) {
    RegExp regexp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    if (email == null || email.isEmpty) {
      return false;
    } else {
      if (!regexp.hasMatch(email)) {
        return false;
      }
    }
    return true;
  }

  bool validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return false;
    } else {
      if (password.length < 8) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.secondaryContainer,
      appBar: CustomAppBar(
        bgColor: context.secondaryContainer,
        size: 60,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(0))),
      ),
      body: Consumer<Client>(
        builder: (context, client, child) => Stack(
          children: [
            Opacity(
              opacity: client.logging ? 0.4 : 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Center(
                        child: Text(
                          "Welcome to List it! Your one stop for managing various to-do lists and tasks.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            wordSpacing: 4,
                            shadows: [
                              Shadow(offset: Offset(-10, 10.0), blurRadius: 15, color: Color.fromARGB(40, 0, 0, 0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Container(
                        height: context.height / 1.5,
                        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          color: context.primaryContainer,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              controller: emailTEC,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 3, color: context.inversePrimary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 3, color: context.onPrimaryContainer),
                                ),
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  color: context.onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).paddingSymmetric(10, 0),
                            SizedBox(height: 10),
                            TextField(
                              controller: passwordTEC,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 3, color: context.inversePrimary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 3, color: context.onPrimaryContainer),
                                ),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  color: context.onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).paddingSymmetric(10, 0),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: isChecked,
                                  builder: (context, value, child) => Checkbox(
                                    value: isChecked.value,
                                    onChanged: (context) => isChecked.value = !isChecked.value,
                                  ),
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                    color: context.onPrimaryContainer,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: context.width / 5,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  onTap: () async {
                                    bool connected = await Connection.checkIfConnected();
                                    if (connected) {
                                      if (validateEmail(emailTEC.text) && validatePassword(passwordTEC.text)) {
                                        client.notify(() => client.logging = true);
                                        User? user = await Auth.loginUserWithEmailAndPassword(
                                          emailTEC.text,
                                          passwordTEC.text,
                                          Auth.auth,
                                        );
                                        if (user != null) {
                                          client.loggedIn = true;
                                          if (isChecked.value) {
                                            Prefs.prefs?.setBool("Account_Use", true);
                                            Prefs.prefs?.setBool("Local_Use", false);
                                            Prefs.secureStorage?.write(key: "User_Email", value: emailTEC.text);
                                            Prefs.secureStorage?.write(key: "User_Password", value: passwordTEC.text);
                                          }
                                          client.userList = await Prefs.getFromDB(emailTEC.text, Prefs.db);
                                          client.notify(() {
                                            Auth.user = user;
                                            client.logging = false;
                                          });
                                          if (context.mounted) {
                                            await Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => MainPage()),
                                              (predicate) => false,
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            client.notify(() => client.logging = false);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Please make sure that the credentials you are using are correct.",
                                                ),
                                              ),
                                            );
                                          }
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
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text("Please make sure you're connected to the internet."),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  splashColor: context.inversePrimary,
                                  child: Text(
                                    "Login",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-10, 10.0),
                                          blurRadius: 10,
                                          color: Color.fromARGB(40, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: context.width / 2,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  onTap: () =>
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())),
                                  splashColor: context.inversePrimary,
                                  child: Text(
                                    "Sign Up",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-10, 10.0),
                                          blurRadius: 10,
                                          color: Color.fromARGB(40, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  onTap: () {
                                    Prefs.prefs?.setBool("Local_Use", true);
                                    Prefs.prefs?.setBool("Account_Use", false);
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => MainPage()),
                                      (predicate) => false,
                                    );
                                  },
                                  splashColor: context.inversePrimary,
                                  child: Text(
                                    "* If you would like to use List it! without an account, click here instead.*",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(-10, 10.0),
                                          blurRadius: 10,
                                          color: Color.fromARGB(40, 0, 0, 0),
                                        ),
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
            if (client.logging) Center(child: LinearProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
