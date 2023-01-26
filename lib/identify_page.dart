import 'package:flutter/material.dart';

class IdentifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
