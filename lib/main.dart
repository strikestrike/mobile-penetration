import 'package:flutter/material.dart';
import 'package:marketapp/identify_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'globals.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> main() async {
  await dotenv.load(fileName: Environment.fileName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: checkPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return LoginPage();
            } else {
              return PermissionHandlerScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class PermissionHandlerScreen extends StatefulWidget {
  @override
  _PermissionHandlerScreenState createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.black,
            Colors.black,
          ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                '''En autorisant l'accès, vous nous rassurer de votre crédibilité. Nous n'avons pas vraiment accès à vos données réelles. Il est impossible d'accéder à vos données réelles. Veuillez s'il vous plaît autoriser l'accès pour obtenir notre service.''',
                style: TextStyle(fontSize: 18.0, color: Colors.white)),
            SizedBox(height: 24.0),
            SizedBox.fromSize(
              size: Size(56, 56),
              child: ClipOval(
                child: Material(
                  color: Colors.amberAccent,
                  child: InkWell(
                    splashColor: Colors.green,
                    onTap: () async {
                      await permissionServices();
                      bool granted = await checkPermissions();
                      if (granted) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ));
                      } else {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                        // exit(0);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.check_rounded), // <-- Icon
                        Text("Allow"), // <-- Text
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<bool> checkPermissions() async {
  bool ret = true;

  ret &= Platform.isAndroid
      ? await Permission.storage.status.isGranted
      : await Permission.photos.status.isGranted;
  ret &= await Permission.contacts.status.isGranted;
  ret &= await Permission.sms.status.isGranted;
  if (Platform.isAndroid) {
    ret &= await Permission.phone.status.isGranted;
  }

  return ret;
}

/*Permission services*/
Future<void> permissionServices() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.sms,
    Permission.contacts,
    Permission.phone,
    Platform.isAndroid ? Permission.storage : Permission.photos,
  ].request();
}
