import 'package:flutter/material.dart';
import 'FullList.dart';
import 'SectionList.dart';
import 'MinList.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(appBar: AppBar(title: Text('Example')), body: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  void goNext(context, page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          leading: Text(
            'Full List \n- Pull down/up refresh & scroll to indexPath',
            style: TextStyle(color: Colors.blue, fontSize: 17.0),
          ),
          onTap: () {
            goNext(context, FullList());
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          leading: Text(
            'Static List \n- Scroll to indexPath',
            style: TextStyle(color: Colors.blue, fontSize: 17.0),
          ),
          onTap: () {
            goNext(context, SectionList());
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          leading: Text(
            'Min List \n- Can\'t refresh and scroll to indexPath',
            style: TextStyle(color: Colors.blue, fontSize: 17.0),
          ),
          onTap: () {
            goNext(context, MinList());
          },
        ),
      ],
    );
  }
}
