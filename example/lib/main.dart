import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  void goNext(context) {
    print('go');
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListPage()));
  }

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
      home: Scaffold(
        appBar: AppBar(title: Text('home')),
        body: Builder(builder: (context) {
          return Center(
            child: FlatButton(
                onPressed: () {
                  goNext(context);
                },
                child: Text('go')),
          );
        }),
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  final controller = SectionTableController(sectionTableViewScrollTo: (section, row, isScrollDown) {
    print('received scroll to $section $row scrollDown:$isScrollDown');
  });
  final refreshController = RefreshController();

  Indicator refreshHeaderBuilder(BuildContext context, int mode) {
    return ClassicIndicator(
      mode: mode,
      releaseText: '释放以刷新',
      refreshingText: '刷新中...',
      completeText: '完成',
      failedText: '失败',
      idleText: '下拉以刷新',
      noDataText: '',
    );
  }

  Indicator refreshFooterBuilder(BuildContext context, int mode) {
    return ClassicIndicator(
      mode: mode,
      releaseText: '释放以加载',
      refreshingText: '加载中...',
      completeText: '加载完成',
      failedText: '加载失败',
      idleText: '上拉以加载',
      noDataText: '',
      idleIcon: const Icon(Icons.arrow_upward, color: Colors.grey),
      releaseIcon: const Icon(Icons.arrow_downward, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ListPage'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            controller.animateTo(2, -1).then((complete) {
              print('animated $complete');
            });
          }),
      body: SafeArea(
        child: SectionTableView(
          refreshHeaderBuilder: refreshHeaderBuilder,
          refreshFooterBuilder: refreshFooterBuilder,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: (up) {
            print('on refresh $up');
            Future.delayed(const Duration(milliseconds: 2009)).then((val) {
              refreshController.sendBack(up, RefreshStatus.completed);
            });
          },
          refreshController: refreshController,
          sectionCount: 7,
          numOfRowInSection: (section) {
            return section == 0 ? 3 : 4;
          },
          cellAtIndexPath: (section, row) {
            return Container(
              height: 44.0,
              child: Center(
                child: Text('Cell $section $row'),
              ),
            );
          },
          headerInSection: (section) {
            return Container(
              height: 25.0,
              color: Colors.grey,
              child: Text('Header $section'),
            );
          },
          divider: Container(
            color: Colors.green,
            height: 1.0,
          ),
          controller: controller, //SectionTableController
          sectionHeaderHeight: (section) => 25.0,
          dividerHeight: () => 1.0,
          cellHeightAtIndexPath: (section, row) => 44.0,
        ),
      ),
    );
  }
}
