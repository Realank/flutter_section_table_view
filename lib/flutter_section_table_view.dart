library flutter_section_table_view;

import 'package:flutter/material.dart';

typedef int RowCountInSectionCallBack(int section);
typedef Widget CellAtIndexPathCallBack(int section, int row);
typedef Widget SectionHeaderCallBack(int section);
typedef double SectionHeaderHeightCallBack(int section);
typedef double DividerHeightCallBack();
typedef double CellHeightAtIndexPathCallBack(int section, int row);

class _IndexPath {
  final int section;
  final int row;
  _IndexPath({this.section, this.row});
  @override
  String toString() {
    return 'section_${section}_row_$row';
  }
}

class SectionTableController extends ChangeNotifier {
  _IndexPath topIndex;
  bool dirty = false;
  bool animate = false;

  SectionTableController([int section = 0, int row = -1]) {
    topIndex = _IndexPath(section: section, row: row);
  }

  void jumpTo(int section, int row) {
    topIndex = _IndexPath(section: section, row: row);
    animate = false;
    dirty = true;
    notifyListeners();
  }

  void animateTo(int section, int row) {
    topIndex = _IndexPath(section: section, row: row);
    animate = true;
    dirty = true;
    notifyListeners();
  }
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

  final SectionHeaderHeightCallBack sectionHeaderHeight; // must set when use SectionTableController
  final DividerHeightCallBack dividerHeight; // must set when use SectionTableController
  final CellHeightAtIndexPathCallBack
      cellHeightAtIndexPath; // must set when use SectionTableController

  final SectionTableController
      controller; //you can use this controller to scroll section table view
  SectionTableView(
      {this.divider,
      this.sectionCount,
      this.numOfRowInSection,
      this.cellAtIndexPath,
      this.headerInSection,
      this.controller,
      this.sectionHeaderHeight,
      this.dividerHeight,
      this.cellHeightAtIndexPath});
  @override
  _SectionTableViewState createState() => new _SectionTableViewState();
}

class _SectionTableViewState extends State<SectionTableView> {
  List<_IndexPath> indexToIndexPathSearch = [];
  Map<String, double> indexPathToOffsetSearch = {};
  ScrollController scrollController;

  double scrollOffsetFromIndex(_IndexPath indexPath) {
    return indexPathToOffsetSearch[indexPath.toString()];
  }

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
        indexToIndexPathSearch.add(_IndexPath(section: i, row: -1));
      }
      int rows = widget.numOfRowInSection(i);
      for (int j = 0; j < rows; j++) {
        indexToIndexPathSearch.add(_IndexPath(section: i, row: j));
        if (showDivider) {
          indexToIndexPathSearch.add(_IndexPath(section: -1, row: -1));
        }
      }
    }

    if (widget.controller != null) {
      if (widget.sectionHeaderHeight == null ||
          widget.dividerHeight == null ||
          widget.cellHeightAtIndexPath == null) {
        print(
            '''error: if you want to use controller to scroll SectionTableView to wanted index path, 
               you need to pass parameters: 
               [sectionHeaderHeight][dividerHeight][cellHeightAtIndexPath]''');
      } else {
        double offset = 0.0;
        double dividerHeight = showDivider ? widget.dividerHeight() : 0.0;
        for (int i = 0; i < widget.sectionCount; i++) {
          if (showSectionHeader) {
            indexPathToOffsetSearch[_IndexPath(section: i, row: -1).toString()] = offset;
            offset += widget.sectionHeaderHeight(i);
          }
          int rows = widget.numOfRowInSection(i);
          for (int j = 0; j < rows; j++) {
            indexPathToOffsetSearch[_IndexPath(section: i, row: j).toString()] = offset;
            offset += widget.cellHeightAtIndexPath(i, j) + dividerHeight;
          }
        }
      }
    }

    SectionTableController sectionTableController = widget.controller;
    double initialOffset = scrollOffsetFromIndex(sectionTableController.topIndex);
    if (initialOffset == null) {
      initialOffset = 0.0;
    }
    scrollController = ScrollController(initialScrollOffset: initialOffset);
    widget.controller.addListener(() {
      print('scroll');
      if (sectionTableController.dirty) {
        sectionTableController.dirty = false;
        double offset = scrollOffsetFromIndex(sectionTableController.topIndex);
        if (offset == null) {
          return;
        }
        if (sectionTableController.animate) {
          scrollController.animateTo(offset,
              duration: Duration(milliseconds: 250), curve: Curves.decelerate);
        } else {
          scrollController.jumpTo(offset);
        }
      }
    });
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
    if (index >= indexToIndexPathSearch.length) {
      return null;
    }

    _IndexPath indexPath = indexToIndexPathSearch[index];
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
    return ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          return _buildCell(context, index);
        });
  }
}
