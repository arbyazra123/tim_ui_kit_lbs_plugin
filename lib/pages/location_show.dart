import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'dart:io' show Platform;

import 'package:tim_ui_kit_lbs_plugin/abstract/map_class.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_widget.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/location_utils.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';

class LocationShow extends StatefulWidget {
  /// Address name / 位置名称标题
  final String addressName;

  /// Full address / 位置地址
  final String? addressLocation;

  /// Latitude / 纬度
  final double latitude;

  /// Longitude / 经度
  final double longitude;

  /// To control if the poisoning ability from Map SDK is needed, if true, please make sure 'moveToCurrentLocationActionWithSearchPOIByMapSDK' been implemented correctly.
  /// 用于控制是否使用地图SDK定位能力。若使用，请确保moveToCurrentLocationActionWithSearchPOIByMapSDK方法继承正确。
  final bool? isUseMapSDKLocation;

  /// LocationUtils with the TIMMapService implemented with specific Map SDK.
  /// 传入根据选定地图SDK实例化后的LocationUtils
  final LocationUtils locationUtils;

  /// External navigation map list for jumping out to navigate, if nothing here, default list includes "Tencent Map", "AMap", "Baidu Map", "Apple Map".
  /// 第三方导航APP列表，如果没传，则默认腾讯/百度/高德/苹果地图。
  final List<NavigationMapItem>? navigationMapList;

  /// TIMMapWidget with the inherited map widget by the Map SDK you chose.
  /// 传入根据选定地图SDK实例化后的地图组件TIMMapWidget
  final TIMMapWidget Function(VoidCallback onMapLoadDone, Key mapKey)
      mapBuilder;

  /// To control is allow the location show page has a location button on bottom right. / 是否显示定位按钮
  final bool isAllowCurrentLocation;

  const LocationShow({
    Key? key,
    required this.addressName,
    this.addressLocation,
    required this.latitude,
    required this.longitude,
    required this.locationUtils,
    required this.mapBuilder,
    this.isUseMapSDKLocation = true,
    this.navigationMapList,
    this.isAllowCurrentLocation = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LocationShowState();
}

class LocationShowState extends State<LocationShow> {
  List<TIMPoiInfo> poiInfoList = [];
  String currentSearchCity = "深圳市"; // "Shenzhen City"
  TIMCoordinate? currentCoordinate;
  String currentSelectedPOI = "";
  String currentLocationName = "";
  TextEditingController inputKeywordEditingController = TextEditingController();
  String dividerForDesc = "/////";
  GlobalKey<TIMMapState> mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void onMapLoadDone() {
    TIMCoordinate pt = TIMCoordinate(widget.latitude, widget.longitude);
    mapKey.currentState?.addMarkOnMap(pt, widget.addressName);
    mapKey.currentState?.moveMapCenter(pt);
  }

  void moveToCurrentLocation() {
    if (widget.isUseMapSDKLocation != null &&
        widget.isUseMapSDKLocation == true) {
      widget.locationUtils.moveToCurrentLocationActionWithSearchPOI(
        moveMapCenter: mapKey.currentState!.moveMapCenter,
      );
    } else {
      widget.locationUtils.moveToCurrentLocationActionWithoutSearchPOI(
          moveMapCenter: mapKey.currentState!.moveMapCenter);
    }
  }

  List<NavigationMapItem> navigationMapList() {
    if (widget.navigationMapList != null &&
        widget.navigationMapList!.isNotEmpty) {
      return widget.navigationMapList!;
    }

    List<NavigationMapItem> appList = [
      NavigationMapItem(
        TIM_t("Google Map"),
        LocationUtils.gotoGoogleMap,
      ), // "Tencent Map"
      // NavigationMapItem(
      //     TIM_t("腾讯地图"), LocationUtils.gotoTencentMap), // "Tencent Map"
      // NavigationMapItem(TIM_t("高德地图"), LocationUtils.gotoAMap), // "AMap"
      // NavigationMapItem(
      //     TIM_t("百度地图"), LocationUtils.gotoBaiduMap), // "Baidu Map"
    ];
    if (Platform.isIOS) {
      appList = [
        ...appList,
        NavigationMapItem(TIM_t("苹果地图"), LocationUtils.gotoAppleMap)
      ]; // "Apple Map"
    }
    return appList;
  }

  CupertinoActionSheet mapAppSheet() {
    return CupertinoActionSheet(
      actions: [
        ...navigationMapList()
            .map((e) => CupertinoActionSheetAction(
                  onPressed: () =>
                      e.jumpFunc(widget.longitude, widget.latitude),
                  child: Text(
                    e.name,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ))
            .toList()
      ],
    );
  }

  void _onJumpToMapApp() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => mapAppSheet()).then((value) => null);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      widget.mapBuilder(
                        onMapLoadDone,
                        mapKey,
                      ),
                      // if (widget.isAllowCurrentLocation)
                      //   Positioned(
                      //     right: 16,
                      //     bottom: 26,
                      //     child: GestureDetector(
                      //       onTap: moveToCurrentLocation,
                      //       child: Container(
                      //         decoration: const BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius:
                      //               BorderRadius.all(Radius.circular(22)),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               blurRadius: 6,
                      //               spreadRadius: 0.4,
                      //               color: CommonColor.weakTextColor,
                      //             ),
                      //           ],
                      //         ),
                      //         child: const SizedBox(
                      //           child: Icon(
                      //             Icons.my_location,
                      //             color: CommonColor.primaryColor,
                      //             size: 24,
                      //           ),
                      //           height: 44,
                      //           width: 44,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      Positioned(
                        top: 52,
                        left: 28,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: SizedBox(
                    // height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.addressName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              if (widget.addressLocation != null)
                                Text(
                                  widget.addressLocation!,
                                  style: const TextStyle(
                                      color: CommonColor.weakTextColor,
                                      fontSize: 12),
                                )
                            ],
                          )),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 14, right: 10),
                            child: IconButton(
                              icon: const Icon(
                                Icons.assistant_direction,
                                color: CommonColor.primaryColor,
                                size: 50,
                              ),
                              onPressed: _onJumpToMapApp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
