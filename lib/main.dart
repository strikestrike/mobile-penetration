import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodeversitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Nunito',
      ),
      home: PermissionHandlerScreen(),
      routes: routes,
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
    // permissionServiceCall();
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) async {
        if (value != null) {
          var smsPermission = await Permission.sms.status;
          var contactsPermission = await Permission.contacts.status;
          var storagePermission = await Permission.storage.status;
          var grant = smsPermission.isGranted &&
              contactsPermission.isGranted &&
              storagePermission.isGranted;
          if (Platform.isAndroid) {
            var phonePermission = await Permission.phone.status;
            grant = grant && phonePermission.isGranted;
          }

          if (grant) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              SystemNavigator.pop();
            }
          }
        }
      },
    );
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
      Permission.phone,
      Permission.storage,
    ].request();

    var statusStorage = await Permission.storage.status;
    if (statusStorage == PermissionStatus.permanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.storage.status.isPermanentlyDenied == true &&
                await Permission.storage.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall(); /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statusStorage == PermissionStatus.denied) {
        // permissionServiceCall();
      }
    }

    var statusContacts = await Permission.contacts.status;
    if (statusContacts == PermissionStatus.permanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.contacts.status.isPermanentlyDenied == true &&
                await Permission.contacts.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall(); /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statusContacts == PermissionStatus.denied) {
        // permissionServiceCall();
      }
    }

    var statusSms = await Permission.sms.status;
    if (statusSms == PermissionStatus.permanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.sms.status.isPermanentlyDenied == true &&
                await Permission.sms.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall(); /* opens app settings until permission is granted */
            }
          }
        },
      );
    } else {
      if (statusSms == PermissionStatus.denied) {
        // permissionServiceCall();
      }
    }

    if (Platform.isAndroid) {
      var statusPhone = await Permission.phone.status;
      if (statusPhone == PermissionStatus.permanentlyDenied) {
        await openAppSettings().then(
          (value) async {
            if (value) {
              if (await Permission.phone.status.isPermanentlyDenied == true &&
                  await Permission.phone.status.isGranted == false) {
                openAppSettings();
                // permissionServiceCall(); /* opens app settings until permission is granted */
              }
            }
          },
        );
      } else {
        if (statusPhone == PermissionStatus.denied) {
          // permissionServiceCall();
        }
      }
    }

    return statuses;
  }

  @override
  Widget build(BuildContext context) {
    // permissionServiceCall();
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
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
                      onTap: () {
                        permissionServiceCall();
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
      ),
    );
  }
}
