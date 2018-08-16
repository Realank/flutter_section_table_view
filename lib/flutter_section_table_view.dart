library flutter_section_table_view;

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

typedef int RowCountInSectionCallBack(int section);
typedef Widget CellAtIndexPathCallBack(int section, int row);
typedef Widget SectionHeaderCallBack(int section);
typedef double SectionHeaderHeightCallBack(int section);
typedef double DividerHeightCallBack();
typedef double CellHeightAtIndexPathCallBack(int section, int row);
typedef void SectionTableViewScrollToCallBack(int section, int row, bool isScrollDown);

class IndexPath {
  final int section;
  final int row;
  IndexPath({this.section, this.row});
  @override
  String toString() {
    return 'section_${section}_row_$row';
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
  @override
  bool operator ==(other) {
    if (other.runtimeType != IndexPath) {
      return false;
    }
    IndexPath otherIndexPath = other;
    return section == otherIndexPath.section && row == otherIndexPath.row;
  }
}

class SectionTableController extends ChangeNotifier {
  IndexPath topIndex;
  bool dirty = false;
  bool animate = false;
  SectionTableViewScrollToCallBack sectionTableViewScrollTo;

  SectionTableController({int section = 0, int row = -1, this.sectionTableViewScrollTo}) {
    topIndex = IndexPath(section: section, row: row);
  }

  void jumpTo(int section, int row) {
    topIndex = IndexPath(section: section, row: row);
    animate = false;
    dirty = true;
    notifyListeners();
  }

  Future<bool> animateTo(int section, int row) {
    topIndex = IndexPath(section: section, row: row);
    animate = true;
    dirty = true;
    notifyListeners();
    return Future.delayed(Duration(microseconds: 251), () => true);
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
  List<IndexPath> indexToIndexPathSearch = [];
  Map<String, double> indexPathToOffsetSearch;
  ScrollController scrollController;
  final listViewKey = GlobalKey();
  //scroll position check
  int currentIndex;
  double preIndexOffset;
  double nextIndexOffset;

  double scrollOffsetFromIndex(IndexPath indexPath) {
    var offset = indexPathToOffsetSearch[indexPath.toString()];
    if (offset == null) {
      return null;
    }
    final contentHeight =
        indexPathToOffsetSearch[IndexPath(section: widget.sectionCount, row: -1).toString()];

    if (listViewKey.currentContext != null && contentHeight != null) {
      final listViewHeight = listViewKey.currentContext.size.height;
      if (offset + listViewHeight > contentHeight) {
        // avoid over scroll(bounds)
        return max(0.0, contentHeight - listViewHeight);
      }
    }

    return offset;
  }

  @override
  void initState() {
    super.initState();

    if (widget.sectionCount == 0) {
      return;
    }
    //calculate index to indexPath mapping
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
        indexToIndexPathSearch.add(IndexPath(section: i, row: -1));
      }
      int rows = widget.numOfRowInSection(i);
      for (int j = 0; j < rows; j++) {
        indexToIndexPathSearch.add(IndexPath(section: i, row: j));
        if (showDivider) {
          indexToIndexPathSearch.add(IndexPath(section: -1, row: -1));
        }
      }
    }

    //calculate indexPath to offset mapping
    if (widget.controller != null) {
      if ((showSectionHeader && widget.sectionHeaderHeight == null) ||
          (showDivider && widget.dividerHeight == null) ||
          widget.cellHeightAtIndexPath == null) {
        print(
            '''error: if you want to use controller to scroll SectionTableView to wanted index path, 
               you need to pass parameters: 
               [sectionHeaderHeight][dividerHeight][cellHeightAtIndexPath]''');
      } else {
        indexPathToOffsetSearch = {};
        double offset = 0.0;
        double dividerHeight = showDivider ? widget.dividerHeight() : 0.0;
        for (int i = 0; i < widget.sectionCount; i++) {
          if (showSectionHeader) {
            indexPathToOffsetSearch[IndexPath(section: i, row: -1).toString()] = offset;
            offset += widget.sectionHeaderHeight(i);
          }
          int rows = widget.numOfRowInSection(i);
          for (int j = 0; j < rows; j++) {
            indexPathToOffsetSearch[IndexPath(section: i, row: j).toString()] = offset;
            offset += widget.cellHeightAtIndexPath(i, j) + dividerHeight;
          }
        }
        indexPathToOffsetSearch[IndexPath(section: widget.sectionCount, row: -1).toString()] =
            offset; //list view length
      }
    }

    int findValidIndexPathByIndex(int index, int pace) {
      for (int i = index + pace; (i >= 0 && i < indexToIndexPathSearch.length); i += pace) {
        final indexPath = indexToIndexPathSearch[i];
        if (indexPath.section >= 0) {
          return i;
        }
      }
      return index;
    }

    //calculate initial scroll offset
    SectionTableController sectionTableController = widget.controller;

    double initialOffset = scrollOffsetFromIndex(sectionTableController.topIndex);
    if (initialOffset == null) {
      initialOffset = 0.0;
    }
    if (indexPathToOffsetSearch != null) {
      currentIndex = 0;
      for (int i = 0; i < indexToIndexPathSearch.length; i++) {
        if (indexToIndexPathSearch[i] == sectionTableController.topIndex) {
          currentIndex = i;
        }
      }

//      final preIndexPath = findValidIndexPathByIndex(currentIndex, -1);;
      final currentIndexPath = indexToIndexPathSearch[currentIndex];
      final nextIndexPath = indexToIndexPathSearch[findValidIndexPathByIndex(currentIndex, 1)];
      preIndexOffset = indexPathToOffsetSearch[currentIndexPath.toString()];
      nextIndexOffset = indexPathToOffsetSearch[nextIndexPath.toString()];
    }

    //init scroll controller
    scrollController = ScrollController(initialScrollOffset: initialOffset);
    widget.controller.addListener(() {
      //listen section table controller to scroll the list view
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
    //listen scroll controller to feedback current index path
    if (indexPathToOffsetSearch != null) {
      scrollController.addListener(() {
        double currentOffset = scrollController.offset;
//        print('scroll offset $currentOffset');
        if (currentOffset < preIndexOffset) {
          //go previous cell
          if (currentIndex > 0) {
            final nextIndexPath = indexToIndexPathSearch[currentIndex];
            currentIndex = findValidIndexPathByIndex(currentIndex, -1);
            final currentIndexPath = indexToIndexPathSearch[currentIndex];
            preIndexOffset = indexPathToOffsetSearch[currentIndexPath.toString()];
            nextIndexOffset = indexPathToOffsetSearch[nextIndexPath.toString()];
            print('go previous index $currentIndexPath');
            if (widget.controller.sectionTableViewScrollTo != null) {
              widget.controller
                  .sectionTableViewScrollTo(currentIndexPath.section, currentIndexPath.row, false);
            }
          }
        } else if (currentOffset >= nextIndexOffset) {
          //go next cell
          if (currentIndex < indexToIndexPathSearch.length - 2) {
            currentIndex = findValidIndexPathByIndex(currentIndex, 1);
            final currentIndexPath = indexToIndexPathSearch[currentIndex];
            final nextIndexPath =
                indexToIndexPathSearch[findValidIndexPathByIndex(currentIndex, 1)];
            preIndexOffset = indexPathToOffsetSearch[currentIndexPath.toString()];
            nextIndexOffset = indexPathToOffsetSearch[nextIndexPath.toString()];
            print('go next index $currentIndexPath');
            if (widget.controller.sectionTableViewScrollTo != null) {
              widget.controller
                  .sectionTableViewScrollTo(currentIndexPath.section, currentIndexPath.row, true);
            }
          }
        }
      });
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
    if (index >= indexToIndexPathSearch.length) {
      return null;
    }

    IndexPath indexPath = indexToIndexPathSearch[index];
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
        key: listViewKey,
        controller: scrollController,
        itemBuilder: (context, index) {
          return _buildCell(context, index);
        });
  }
}
