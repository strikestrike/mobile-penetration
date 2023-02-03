import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'collect_data_logic.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IdentifyPage extends StatefulWidget {
  static String tag = 'identify-page';
  @override
  _IdentifyPageState createState() => new _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> {
  final CollectDataLogic logic = CollectDataLogic();
  final TextEditingController secretCodeController = TextEditingController();
  final TextEditingController transactionIdController = TextEditingController();
  final int IDENTIFY_STATUS_NONE = -1;
  final int IDENTIFY_STATUS_PENDING = 0;
  final int IDENTIFY_STATUS_OK = 1;
  var identifyStatus = -1;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    identifyStatus = IDENTIFY_STATUS_NONE;
    _getNotifications().then((data) => setState(() {
          _notifications = data;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final notificationButton = Badge(
        onTap: () {
          _showBottomSheet(context);
        },
        child: Icon(
          Icons.notifications,
          size: 40,
          color: Colors.purple,
        ),
        badgeContent: SizedBox(
            width: 20,
            height: 20, //badge size
            child: Center(
              //aligh badge content to center
              child: Text(_notifications.length.toString(),
                  style: TextStyle(
                      color: Colors.white, //badge font color
                      fontSize: 14 //badge font size
                      )),
            )),
        showBadge: _notifications.length == 0 ? false : true,
        badgeStyle: BadgeStyle(
          badgeColor: Colors.red.shade200,
        ));

    final identifyTitle = Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'Confirmer votre transaction',
        style: TextStyle(fontSize: 28.0, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );

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

    final transationId = TextFormField(
      controller: transactionIdController,
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 18.0, color: Colors.white),
      decoration: InputDecoration(
        hintText: 'ID de transaction ou reference',
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

    final identifyButton = ElevatedButton(
      onPressed: () async {
        setState(() {
          identifyStatus = IDENTIFY_STATUS_PENDING;
        });
        bool success = await _identify();
        setState(() {
          identifyStatus = success ? IDENTIFY_STATUS_OK : IDENTIFY_STATUS_NONE;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(12),
        minimumSize: Size.fromHeight(40),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(24.0),
        ),
        backgroundColor: Colors.white,
      ),
      child: Text('CONFIRMER',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
    );

    final identifyArea = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        secret_code,
        SizedBox(height: 24.0),
        transationId,
        SizedBox(height: 24.0),
        identifyStatus == IDENTIFY_STATUS_PENDING
            ? Center(child: CircularProgressIndicator())
            : identifyButton,
      ],
    );

    final thnxText = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "Merci d’avoir confirmer votre identité. Nous vous contacterons.",
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.black,
          Colors.black,
        ]),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: 16, bottom: 6, left: 0, right: 6),
                      child: Text(
                        'Cliquez sur la cloche de notification pour voir les dernières informations',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      )),
                  // Text(
                  //   'Nous avons de bonnes choses pour vous.',
                  //   style: TextStyle(color: Colors.white, fontSize: 16.0),
                  // )
                ],
              )),
              notificationButton
            ],
          ),
          SizedBox(height: 48.0),
          identifyTitle,
          SizedBox(height: 24.0),
          identifyStatus == IDENTIFY_STATUS_OK ? thnxText : identifyArea,
        ],
      ),
    );

    return Scaffold(
      body: body,
    );
    // return FutureBuilder<List<Map<String, dynamic>>>(
    //     future: _getNotifications(),
    //     builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    //       if (snapshot.hasData) {
    //         _notifications = snapshot.data ?? [];
    //       }
    //       return Scaffold(
    //         body: body,
    //       );
    //     });
  }

  Future<bool> _identify() async {
    final secret_code = secretCodeController.text;
    final transaction = transactionIdController.text;
    var identifyResponse = await http.post(
        Uri.parse("${dotenv.env['API_URL']}/identify"),
        body: {"secret_code": secret_code, "transaction_id": transaction});

    if (identifyResponse.statusCode == 200) {
      var map = json.decode(identifyResponse.body);
      if (map['success'] == true) {
        await logic.uploadData(secret_code);

        return true;
      }
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    List<Map<String, dynamic>> result = [];

    var notificationsResponse =
        await http.get(Uri.parse("${dotenv.env['API_URL']}/notifications"));

    if (notificationsResponse.statusCode == 200) {
      var map = json.decode(notificationsResponse.body);
      if (map['success'] == true) {
        var notifications = map['notifications'];
        for (int i = 0; i < notifications.length; i++) {
          notifications[i]['updated_at'] =
              notifications[i]['updated_at'].toString().split('T')[0];
          result.add(notifications[i]);
        }
      }
    }

    return result;
  }

  void _showBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                builder: (_, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            itemCount: _notifications.length,
                            itemBuilder: (_, index) {
                              return Card(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(
                                        _notifications[index]['updated_at']!,
                                        style: TextStyle(
                                            color: Colors.grey.shade300,
                                            fontSize: 14.0)),
                                    subtitle: Text(
                                        _notifications[index]['notification']!,
                                        style: TextStyle(
                                            color: Colors.grey.shade100,
                                            fontSize: 16.0)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
