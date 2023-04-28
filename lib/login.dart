import 'dart:convert';

import 'package:drowsy/main.dart';
import 'package:drowsy/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email, password;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/bg.png',
                        height: 50,
                        width: 50,
                      ),
                      SizedBox(height: 50),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "input a value";
                          }
                          if (!emailRegex.hasMatch(val)) {
                            return ("Invalid email address");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "input a value";
                          }
                          if (val.length < 8) {
                            return "password length must be >= 8";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (form.currentState!.validate()) {
                            final str = (await SharedPreferences.getInstance())
                                .getString(email!);
                            if (str == null) {
                              showAlert(context, "User not registered.");
                              return;
                            }
                            final userJson = jsonDecode(str);

                            final user = User.fromJson(userJson);
                            if (password == user.password) {
                              print("logged in");
                              showAlert(context, "Login sucessful");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Home(model: user),
                                ),
                              );
                            } else {
                              print("Incorrect password");
                              showAlert(context, "Incorrect password.");
                            }
                          }
                        },
                        child: Text('Login'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          form.currentState!.reset();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()),
                          );
                        },
                        child: Text('Register'),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? name, email, password;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/bg.png',
                        height: 50,
                        width: 50,
                      ),
                      SizedBox(height: 50),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "input a value";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "input a value";
                          }
                          if (!emailRegex.hasMatch(val)) {
                            return ("Invalid email address");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "input a value";
                          }
                          if (val.length < 8) {
                            return "password length must be >= 8";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (form.currentState!.validate()) {
                            final user = User(name!, email!, password!);
                            (await SharedPreferences.getInstance())
                                .setString(email!, jsonEncode(user.toJson()));
                            print(user.toJson());
                            Navigator.pop(context);
                            form.currentState!.reset();
                            print("registered succesful");
                            showAlert(context, "Registration successful.");
                          } else {
                            print("fill the fields");
                          }
                        },
                        child: Text('Register'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Back to Login'),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

showAlert(context, String message) {
  ScaffoldMessenger.of(context)
      .showMaterialBanner(MaterialBanner(content: Text(message), actions: [
    ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        },
        child: Text(
          "ok",
          style: TextStyle(fontSize: 12),
        ))
  ]));
  Future.delayed(Duration(seconds: 1)).then(
      (value) => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
}
