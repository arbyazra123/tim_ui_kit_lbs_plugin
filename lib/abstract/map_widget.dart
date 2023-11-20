import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';

abstract class TIMMapWidget extends StatefulWidget{
  final Function? onMapLoadDone;
  final Function(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason)? onMapMoveEnd;

  const TIMMapWidget({Key? key, this.onMapLoadDone, this.onMapMoveEnd}) : super(key: key);
}