/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'default_constants.dart';
import 'package:flutter/widgets.dart';

typedef void OnRefresh(bool up);
typedef void OnOffsetChange(bool up, double offset);
typedef Widget IndicatorBuilder(BuildContext context, int mode);

/*
 * This will use to configure the Wrapper action
 */
abstract class Config {
  // How many distances should be dragged to trigger refresh
  final double triggerDistance;

  const Config({required this.triggerDistance});
}

class RefreshConfig extends Config {
  // display time of success or failed
  final int completeDuration;
  // emptySpace height
  final double visibleRange;
  const RefreshConfig(
      {this.visibleRange: default_VisibleRange,
      double triggerDistance: default_refresh_triggerDistance,
      this.completeDuration: default_completeDuration})
      : super(triggerDistance: triggerDistance);
}

class LoadConfig extends Config {
  // if autoLoad when touch outside
  final bool autoLoad;
  // Whether the interface is at the bottom when the interface is loaded
  final bool bottomWhenBuild;

  final bool enableOverScroll;
  const LoadConfig({
    this.autoLoad: default_AutoLoad,
    this.bottomWhenBuild: default_BottomWhenBuild,
    this.enableOverScroll: default_enableOverScroll,
    double triggerDistance: default_load_triggerDistance,
  }) : super(triggerDistance: triggerDistance);
}
