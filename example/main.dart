import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_class.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_service.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_widget.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/location_utils.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/utils.dart';
import 'package:tim_ui_kit_lbs_plugin/pages/location_picker.dart';
import 'package:tim_ui_kit_lbs_plugin/pages/location_show.dart';
import 'package:tim_ui_kit_lbs_plugin/widget/location_msg_element.dart';
import 'dart:io' show Platform;

// This sample uses Baidu Maps as the base Map SDK to demonstrate how to integrate the Tencent Cloud IM Flutter LBS plug-in.

// This sample mainly introduces how to inherit the three abstract classes of tim_ui_kit_lbs_plugin according with the selected Map SDK selected.
// Including: TIMMapService/TIMMapWidget/TIMMapState.

// And demonstrate how to call these UI widgets with these three inherited classes.
// Including: location selector (LocationPicker) / location message full display (LocationShow) / location message list display (LocationMsgElement)

// 本Sample以百度地图为底层SDK演示如何使用腾讯云IM Flutter LBS能力插件
// 有关如何快速集成本插件与百度地图Flutter SDK，请参考此文档：https://docs.qq.com/doc/DSXRBZG1CUGhIVEZx

// 本Sample主要介绍如何根据选定地图SDK继承tim_ui_kit_lbs_plugin的三个抽象类
// 分别为：TIMMapService/TIMMapWidget/TIMMapState

// 并演示如何将实例化后的三个类，传入LBS组件中，实现三个功能组件
// 分别为：位置选择器（LocationPicker）/位置消息完整展示器（LocationShow）/位置消息列表展示器（LocationMsgElement）

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Please modify index to shows different widgets.
  // 0: LocationPicker  1: LocationShow  2: LocationMsgElement
  // 请自行修改index查看不同组件用法。
  // 0: 位置选择器  1：位置消息完整展示器  2: 位置消息列表展示器
  int currentDemoPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> demoPageList() => [
        // 0: LocationPicker  1: LocationShow  2: LocationMsgElement
        // 0: 位置选择器  1：位置消息完整展示器  2: 位置消息列表展示器

        LocationPicker(
          onChange: (LocationMessage location) async {
            // The business function of sending location messages is handled here. If used with TUIKit, please refer to the plug-in README.
            // 此处处理发位置消息逻辑。若配合UIKit使用，写法请参考本插件README
            // https://pub.dev/packages/tim_ui_kit_lbs_plugin#uikit
          },
          mapBuilder: (onMapLoadDone, mapKey, onMapMoveEnd) => BaiduMap(
            onMapMoveEnd: onMapMoveEnd,
            onMapLoadDone: onMapLoadDone,
            key: mapKey,
          ),
          locationUtils: LocationUtils(BaiduMapService()), loadingWidget: CircularProgressIndicator(),
        ),
        LocationShow(
          addressName: "腾讯大厦",
          addressLocation: "广东省深圳市深南大道10000号",
          longitude: 22.546103,
          latitude: 113.941079,
          mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
            onMapLoadDone: onMapLoadDone,
            key: mapKey,
          ),
          locationUtils: LocationUtils(BaiduMapService()),
        ),
        LocationMsgElement(
          messageID: "0312",
          locationElem: LocationMessage(
              latitude: 113.941079,
              longitude: 22.546103,
              desc: "腾讯大厦/////广东省深圳市深南大道10000号"),
          isFromSelf: true,
          isShowJump: false,
          clearJump: () {},
          mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
            onMapLoadDone: onMapLoadDone,
            key: mapKey,
          ),
          locationUtils: LocationUtils(BaiduMapService()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Tencent Cloud IM Flutter LBS'),
          ),
          body: Center(
            child: demoPageList()[currentDemoPageIndex],
          )),
    );
  }
}

// The sample of inheriting TIMMapService using Baidu Map SDK
// 使用百度地图继承TIMMapService的sample
class BaiduMapService extends TIMMapService{

  // The APP Key provided by Baidu Map
  // 请前往百度地图开放平台申请iOS端AK，用于定位
  // https://lbsyun.baidu.com/apiconsole/key#/home
  String appKey = "";

  // To use the positioning ability provided by Baidu Maps needs to install the flutter_bmflocation package first.
  // 使用百度地图提供的定位能力，需要先安装flutter_bmflocation包。
  @override
  void moveToCurrentLocationActionWithSearchPOIByMapSDK({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
    void Function(TIMReverseGeoCodeSearchResult, bool)?
    onGetReverseGeoCodeSearchResult,
  }) async {
    await initBaiduLocationPermission();
    Map iosMap = initIOSOptions().getMap();
    Map androidMap = initAndroidOptions().getMap();
    final LocationFlutterPlugin _myLocPlugin = LocationFlutterPlugin();

    // moving the map center to current location and load the POI list around
    //根据定位数据挪地图及加载周边POI列表
    void dealWithLocationResult(BaiduLocation result) {
      if (result.latitude != null && result.longitude != null) {
        TIMCoordinate coordinate =
        TIMCoordinate(result.latitude!, result.longitude!);
        moveMapCenter(coordinate);
        if(onGetReverseGeoCodeSearchResult != null){
          searchPOIByCoordinate(
              coordinate: coordinate,
              onGetReverseGeoCodeSearchResult: onGetReverseGeoCodeSearchResult);
        }
      } else {
        Utils.toast(("Failed in positioning"));
      }
    }

    // The callback function after positioning
    // 设置获取到定位后的回调
    if (Platform.isIOS) {
      _myLocPlugin.singleLocationCallback(callback: (BaiduLocation result) {
        dealWithLocationResult(result);
      });
    } else if (Platform.isAndroid) {
      _myLocPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
        dealWithLocationResult(result);
        _myLocPlugin.stopLocation();
      });
    }

    // Start positioning
    // 启动定位
    await _myLocPlugin.prepareLoc(androidMap, iosMap);
    if (Platform.isIOS) {
      _myLocPlugin
          .singleLocation({'isReGeocode': true, 'isNetworkState': true});
    } else if (Platform.isAndroid) {
      _myLocPlugin.startLocation();
    }
  }

  static BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
        coorType: 'bd09ll',
        locationMode: BMFLocationMode.hightAccuracy,
        isNeedAddress: true,
        isNeedAltitude: true,
        isNeedLocationPoiList: true,
        isNeedNewVersionRgc: true,
        isNeedLocationDescribe: true,
        openGps: true,
        locationPurpose: BMFLocationPurpose.sport,
        coordType: BMFLocationCoordType.bd09ll);
    return options;
  }

  static BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
        BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
        desiredAccuracy: BMFDesiredAccuracy.best);
    return options;
  }

  initBaiduLocationPermission() async {
    LocationFlutterPlugin myLocPlugin = LocationFlutterPlugin();
    // Request positioning permission dynamically
    // 动态申请定位权限
    await LocationUtils.requestLocationPermission();
     // Set privacy
    // 设置是否隐私政策
    myLocPlugin.setAgreePrivacy(true);
    BMFMapSDK.setAgreePrivacy(true);
    if (Platform.isIOS) {
      // Set AK for iOS. For Android, please set in 'AndroidManifest.xml'
      // 设置ios端ak, Android端ak可以直接在清单文件中配置
      myLocPlugin.authAK(appKey);
    }
  }

  @override
  void poiCitySearch({
    required void Function(List<TIMPoiInfo>?, bool)
    onGetPoiCitySearchResult,
    required String keyword,
    required String city,
  }) async {
    BMFPoiCitySearchOption citySearchOption = BMFPoiCitySearchOption(
      city: city,
      keyword: keyword,
      scope: BMFPoiSearchScopeType.DETAIL_INFORMATION,
      isCityLimit: false,
    );

    BMFPoiCitySearch citySearch = BMFPoiCitySearch();

    // Callback function
    // 检索回调
    citySearch.onGetPoiCitySearchResult(
        callback: (result, errorCode) {
          List<TIMPoiInfo> tmpPoiInfoList = [];
          result.poiInfoList?.forEach((v) {
            tmpPoiInfoList.add(TIMPoiInfo.fromMap(v.toMap()));
          });
          onGetPoiCitySearchResult(
              tmpPoiInfoList,
              errorCode != BMFSearchErrorCode.NO_ERROR
          );
        }
    );

    // Start Searching
    // 发起检索
    bool result = await citySearch.poiCitySearch(citySearchOption);

    if (result) {
      print(("Search Success"));
    } else {
      print(("Search Failed"));
    }
  }

  @override
  void searchPOIByCoordinate(
      {required TIMCoordinate coordinate,
        required void Function(TIMReverseGeoCodeSearchResult, bool)
        onGetReverseGeoCodeSearchResult}) async {
    BMFReverseGeoCodeSearchOption option = BMFReverseGeoCodeSearchOption(
      location: BMFCoordinate.fromMap(coordinate.toMap()),
    );

    BMFReverseGeoCodeSearch reverseGeoCodeSearch = BMFReverseGeoCodeSearch();

    // Register the callback function for searching
    // 注册检索回调
    reverseGeoCodeSearch.onGetReverseGeoCodeSearchResult(
        callback: (result, errorCode){
          print("failed reason ${errorCode} ${errorCode.name} ${errorCode.toString()}");
          return onGetReverseGeoCodeSearchResult(
              TIMReverseGeoCodeSearchResult.fromMap(result.toMap()),
              errorCode != BMFSearchErrorCode.NO_ERROR
          );
        });

    // 发起检索
    bool result = await reverseGeoCodeSearch.reverseGeoCodeSearch(BMFReverseGeoCodeSearchOption.fromMap(option.toMap()));

    if (result) {
      print(("Search Success"));
    } else {
      print(("Search Failed"));
    }
  }

}

// The sample of inheriting TIMMapWidget using Baidu Map SDK
// 使用百度地图继承TIMMapWidget的sample
class BaiduMap extends TIMMapWidget{
  final Function? onMapLoadDone;
  final Function(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason)? onMapMoveEnd;

  const BaiduMap({Key? key, this.onMapLoadDone, this.onMapMoveEnd}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BaiduMapState();

}

// 使用百度地图继承TIMMapState的sample
class BaiduMapState extends TIMMapState<BaiduMap>{
  late BMFMapController timMapController;
  Widget mapWidget = Container();

  // Callback function for loading done
  // 创建完成回调
  void onMapCreated(BMFMapController controller) {
    timMapController = controller;

    timMapController.setMapDidLoadCallback(callback: () {
      print(('mapDidLoad-地图加载完成'));
    });

    // Register the callback function for moving end
    // 设置移动结束回调
    timMapController.setMapRegionDidChangeWithReasonCallback(callback: (status, reason) => onMapMoveEnd(
        status.targetGeoPt != null ? TIMCoordinate.fromMap(status.targetGeoPt!.toMap()) : null,
        TIMRegionChangeReason.values[reason.index]),
    );

    if(widget.onMapLoadDone != null){
      widget.onMapLoadDone!();
    }
  }

  // on map move end
  // 地图移动结束
  @override
  void onMapMoveEnd(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason){
    if(widget.onMapMoveEnd != null){
      widget.onMapMoveEnd!(targetGeoPt, regionChangeReason);
    }
  }

  // move map center
  // 移动地图视角
  @override
  void moveMapCenter(TIMCoordinate pt){
    timMapController.setCenterCoordinate(BMFCoordinate.fromMap(pt.toMap()), true, animateDurationMs: 1000);
  }

  @override
  void forbiddenMapFromInteract() {
    timMapController.updateMapOptions(BMFMapOptions(
      scrollEnabled: false,
      zoomEnabled: false,
      overlookEnabled: false,
      rotateEnabled: false,
      gesturesEnabled: false,
      changeCenterWithDoubleTouchPointEnabled: false,
    ));
  }

  @override
  void addMarkOnMap(TIMCoordinate pt, String title){
    BMFMarker marker = BMFMarker.icon(
        position: BMFCoordinate.fromMap(pt.toMap()),
        title: title,
        identifier: 'flutter_marker',
        icon: 'assets/pin_red.png');

    timMapController.addMarker(marker);
  }

  // set map options
  // 设置地图参数
  BMFMapOptions initMapOptions() {
    BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(39.917215, 116.380341),
      zoomLevel: 18,
    );
    return mapOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BMFMapWidget(
        onBMFMapCreated: onMapCreated,
        mapOptions: initMapOptions(),
      ),
    );
  }
}