import 'dart:developer';

import 'package:a123pan_direct_download/lib123pan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a123pan_direct_download/logo.dart';

class A123PanLoginPage extends StatefulWidget {
  const A123PanLoginPage({super.key});

  @override
  State<A123PanLoginPage> createState() => _A123PanLoginPageState();
}

class _A123PanLoginPageState extends State<A123PanLoginPage> {
  late SharedPreferences pref;
  bool hidePassword = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initSettings();
  }

  void _initSettings() async {
    pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    void navigateToHome() {
      //Navigator.push(
      //    context,
      //    MaterialPageRoute<void>(
      //        builder: (BuildContext context) => MyAppHome()));
      Navigator.pop(context);
    }

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("登录"),
            centerTitle: true,
          ),
            body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LogoImage, // Top logo
        Card(
          margin: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PreferredSize(
                    preferredSize: const Size.fromWidth(80),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          prefixIcon: Icon(Icons.accessibility)),
                    )),
                const SizedBox(
                  height: 20,
                ),
                PreferredSize(
                    preferredSize: const Size.fromWidth(80),
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                            icon: Icon(hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          )),
                      obscureText: hidePassword,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showDialog(context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              icon: const Icon(Icons.error),
                              title: const Text("Not support"),
                              content: const Text("Please go to signup on web!"),
                              actions: [
                                ElevatedButton(onPressed: () {
                                  Navigator.pop(context);
                                }, child: const Text("OK"))
                              ],
                            );
                          });
                        }, child: const Text("Sign in")),
                    const SizedBox(
                      width: 20,
                    ),
                    FilledButton.tonal(
                        onPressed: () async {
                          var loginInfo = await A123Pan.login(usernameController.text, passwordController.text);
                          if (loginInfo != null) {
                            pref.setString("tokens", loginInfo['token']);
                            //Fluttertoast.showToast(msg: "😊 Login success!");
                            navigateToHome();
                          } else {
                            //Fluttertoast.showToast(msg: "😟 Login failed!");
                          }
                        }, child: const Text("Login")),
                    const SizedBox(
                      width: 20,
                    ),
                    FilledButton(
                        onPressed: () async {
                          SharedPreferences perf =
                              await SharedPreferences.getInstance();
                          if (perf.getString("tokens") != null) {
                            log("Skip login so remove tokens");
                            await perf.remove("tokens");
                          }
                          navigateToHome();
                        },
                        child: const Text("Skip login")),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    )));
  }
}
