import 'package:flutter/material.dart';
import 'package:flutter_section_table_view/flutter_section_table_view.dart';

class MinList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Min List'),
      ),
      body: SafeArea(
        child: SectionTableView(
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
        ),
      ),
    );
  }
}
