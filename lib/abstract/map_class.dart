import 'package:flutter/material.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';

abstract class TIMMapState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(),
    );
  }

  /// Callback function after map loading done / 地图创建完成回调
  void onMapLoadDone(){}

  /// Callback function after map moving / 地图移动结束
  void onMapMoveEnd(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason){}

  /// Move the center coordinate of the map / 移动地图视角
  void moveMapCenter(TIMCoordinate pt){}

  /// Forbidden the map from interaction with gesture, etc. / 禁用地图交互
  void forbiddenMapFromInteract() {}

  /// add a mark on the specific coordinate on map / 在地图上添加图钉
  void addMarkOnMap(TIMCoordinate pt, String title){}

}