library flutter_section_table_view;

import 'package:flutter/material.dart';

typedef int RowCountInSectionCallBack(int section);
typedef Widget CellAtIndexPathCallBack(int section, int row);
typedef Widget SectionHeaderCallBack(int section);

class IndexPath {
  final int section;
  final int row;
  IndexPath({this.section, this.row});
}

class SectionTableView extends StatefulWidget {
  final Widget divider;
  @required
  final int sectionCount;
  @required
  final RowCountInSectionCallBack numOfRowInSection;
  @required
  final CellAtIndexPathCallBack cellAtIndexPath;
  final SectionHeaderCallBack headerInSection;
  SectionTableView(
      {this.divider,
      this.sectionCount,
      this.numOfRowInSection,
      this.cellAtIndexPath,
      this.headerInSection});
  @override
  _SectionTableViewState createState() => new _SectionTableViewState();
}

class _SectionTableViewState extends State<SectionTableView> {
  List indexPathSearch = [];

  @override
  void initState() {
    super.initState();
    bool showDivider = false;
    bool showSectionHeader = false;
    if (widget.divider != null) {
      showDivider = true;
    }
    if (widget.headerInSection != null) {
      showSectionHeader = true;
    }

    for (int i = 0; i < widget.sectionCount; i++) {
      if (showSectionHeader) {
        indexPathSearch.add(IndexPath(section: i, row: -1));
      }
      int rows = widget.numOfRowInSection(i);
      for (int j = 0; j < rows; j++) {
        indexPathSearch.add(IndexPath(section: i, row: j));
        if (showDivider) {
          indexPathSearch.add(IndexPath(section: -1, row: -1));
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(SectionTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _buildCell(BuildContext context, int index) {
    if (index >= indexPathSearch.length) {
      return null;
    }

    IndexPath indexPath = indexPathSearch[index];
    //section header
    if (indexPath.section >= 0 && indexPath.row < 0) {
      return widget.headerInSection(indexPath.section);
    }

    if (indexPath.section < 0 && indexPath.row < 0) {
      return widget.divider;
    }

    Widget cell = widget.cellAtIndexPath(indexPath.section, indexPath.row);
    return cell;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return _buildCell(context, index);
    });
  }
}
