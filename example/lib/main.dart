import 'package:flutter/material.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ListPage(),
    );
  }
}

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListPage'),
      ),
      body: SectionTableView(
        sectionCount: 2,
        numOfRowInSection: (section) {
          return section == 0 ? 3 : 4;
        },
        cellAtIndexPath: (section, row) {
          return ListTile(
            leading: Text('Cell $section $row'),
          );
        },
        headerInSection: (section) {
          return Container(
            color: Colors.grey,
            child: Text('Header $section'),
          );
        },
        divider: Container(
          color: Colors.green,
          height: 1.0,
        ),
      ),
    );
  }
}
