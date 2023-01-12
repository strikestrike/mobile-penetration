import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

  @override
  Widget build(BuildContext context) {
    final marketing = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircleAvatar(
          radius: 150.0,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/marketing.png'),
        ),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'Bienvenue',
        style: TextStyle(fontSize: 28.0, color: Colors.white),
      ),
    );

    final lorem = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Nous avons de bonnes choses pour vous.',
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
        children: <Widget>[marketing, welcome, lorem],
      ),
    );

    return Scaffold(
      body: body,
    );
  }
}
