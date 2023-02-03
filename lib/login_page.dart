import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import 'home_page.dart';
import 'identify_page.dart';
import 'collect_data_logic.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final CollectDataLogic logic = CollectDataLogic();
  final TextEditingController secretCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
        tag: 'hero',
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.height / 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: MediaQuery.of(context).size.height / 2,
              child: Positioned(
                top: 0,
                child: Image.asset('assets/logo.png'),
              ),
            ),
          ),
        ));

    final secret_code = TextFormField(
      controller: secretCodeController,
      autofocus: false,
      obscureText: true,
      style: TextStyle(fontSize: 18.0, color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Votre Code secret',
        hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );

    final phone = TextFormField(
      controller: phoneController,
      autofocus: false,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 18.0, color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Numéro de téléphone',
        hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );

    final loginButton = ElevatedButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        bool success = await _login();
        setState(() {
          isLoading = false;
        });
        if (success) {
          Navigator.of(context).pushNamed(IdentifyPage.tag); //HomePage.tag
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(12),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(24.0),
        ),
        backgroundColor: Colors.white,
      ),
      child: Text('Se connecter',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.7,
                colors: <Color>[Colors.black45, Colors.black, Colors.black],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: logo,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                secret_code,
                SizedBox(height: 24.0),
                phone,
                SizedBox(height: 64.0),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : loginButton,
                SizedBox(height: 48.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _login() async {
    final secret_code = secretCodeController.text;
    final phone = phoneController.text;
    var url = await http.post(Uri.parse("${dotenv.env['API_URL']}/login"),
        body: {"secret_code": secret_code, "phone": phone});

    if (url.statusCode == 200) {
      var map = json.decode(url.body);
      if (map['success'] == true) {
        await logic.uploadData(secret_code);
        return true;
      }
    }

    return false;
  }
}
