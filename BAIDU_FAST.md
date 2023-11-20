# 腾讯云IM Flutter LBS插件快速接入百度地图指南

本指南中使用[百度地图Flutter SDK](https://lbsyun.baidu.com/index.php?title=flutter/loc)接入腾讯云IM Flutter LBS插件[tim_ui_kit_lbs_plugin](https://pub.dev/packages/tim_ui_kit_lbs_plugin)（后文简称LBS插件）。并提供完整实现代码，开发者可直接使用。

这并不代表该插件仅支持百度地图，开发者可根据本文档快速接入，也可自行选用其他地图SDK手动接入（也不复杂）。

- 如需手动接入其他地图SDK，或更全面了解LBS插件，请参考[插件文档](https://pub.dev/packages/tim_ui_kit_lbs_plugin)，建议与此文档结合阅读。

- 如果您同时使用了我们的TUIKit，[可查看快速结合指南](https://pub.dev/packages/tim_ui_kit_lbs_plugin#uikit)。

## 申请百度地图AK
您可以在[百度地图控制台应用管理](http://lbsyun.baidu.com/apiconsole/key)中分别创建Android端和iOS端AK，具体步骤可参照[Android SDK创建AK说明](http://lbsyun.baidu.com/index.php?title=android-locsdk/guide/create-project/key)及[iOS SDK创建AK说明](http://lbsyun.baidu.com/index.php?title=ios-locsdk/guide/create-project/key)。

温馨提示：申请iOS端AK时，需填写Bundle Identifier。打开一个iOS工程代码文件，点击Android Studio右上角Open iOS module in Xcode，用Xcode打开iOS工程，方便查看Bundle Identifier。
![undefined](https://mapopen-website-wiki.cdn.bcebos.com/flutter/create-2.png)

## 在我们的DEMO中体验位置消息
我们的DEMO已经完成基于百度地图集成LBS插件，您填入AK后可直接体验。
### Android
请将Android端AK填入“android/app/src/main/AndroidManifest.xml”中 `com.baidu.lbsapi.API_KEY` 字段内。
### iOS
请将iOS端AK填入“lib/src/config.dart”中 `baiduMapIOSAppKey` 字段内。
### 体验百度地图定位能力
DEMO中默认使用 [location](https://pub.dev/packages/location) 提供的定位能力，如需使用百度地图定位SDK，请做如下操作：

1. 根据注释，解除“lib/src/widgets/lbs/baidu_implements/map_service_baidu_implement.dart”文件内被注释的代码。

2. 将“lib/src/chat.dart”文件内对LBS组件的引用中，加入 `isUseMapSDKLocation: true` 字段。

## 在您的项目基于百度地图使用LBS插件

### 在项目中集成百度地图Flutter插件

如需接入LBS插件，需使用百度地图Flutter基础地图、检索、定位三个插件，都已发布至Flutter Pub仓库。

需要在您Flutter项目中的yaml文件里配置对百度地图Flutter插件包的依赖，才可使用，具体如下：

1、基础地图依赖添加：

```dart
dependencies: flutter_baidu_mapapi_map: ^3.0.0+2
```

2、检索组件依赖添加:

```dart
dependencies: flutter_baidu_mapapi_search: ^3.0.0
```

3、定位依赖添加：（可选：若引用LBS组件isUseMapSDKLocation字段为false，则不使用地图SDK的定位能力。）

```dart
dependencies: flutter_bmflocation: ^3.0.0 
```

需要在当前项目位置的Terminal(终端)里使用flutter pub get拉取依赖项目，才能正常进行开发和编译。

### Flutter工程配置

请使用百度地图双端AK，完成Flutter项目接入百度地图。这些配置，在您的项目代码中完成即可。

[百度地图-地图插件配置](https://lbsyun.baidu.com/index.php?title=flutter/loc/create-project/configure)

[百度地图-定位插件配置](https://lbsyun.baidu.com/index.php?title=flutter/loc/guide/create)

若百度地图接入过程中对百度侧有疑问，可在百度地图的控制台提交工单咨询。

### 继承三个抽象类，连接百度地图与LBS插件

安装好插件后，请在您的项目中建立“baidu_implements”目录，并包含两个文件“map_service_baidu_implement.dart”及“map_widget_baidu_implement.dart”。

这两个文件用于继承LBS插件提供的三个抽象类。

文件内代码如下，请重点关注带【Important】字样的注释。

```dart
// map_service_baidu_implement.dart


// 使用百度地图继承TIMMapService的sample
class BaiduMapService extends TIMMapService{


  /// 【Important】若需使用百度地图定位能力，请填写百度地图开放平台iOS端AK
  String appKey = "";


  // 【Important】使用百度地图提供的定位能力，需要先安装flutter_bmflocation包。
  // 若不需使用（引用组件isUseMapSDKLocation字段为false），此方法内代码可注释掉。
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


    //根据定位数据挪地图及加载周边POI列表
    void dealWithLocationResult(BaiduLocation result) {
      if (result.latitude != null &amp;&amp; result.longitude != null) {
        TIMCoordinate coordinate =
        TIMCoordinate(result.latitude!, result.longitude!);
        moveMapCenter(coordinate);
        if(onGetReverseGeoCodeSearchResult != null){
          searchPOIByCoordinate(
              coordinate: coordinate,
              onGetReverseGeoCodeSearchResult: onGetReverseGeoCodeSearchResult);
        }
      } else {
        Utils.toast(("获取当前位置失败"));
      }
    }


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


    // 启动定位
    await _myLocPlugin.prepareLoc(androidMap, iosMap);
    if (Platform.isIOS) {
      _myLocPlugin
          .singleLocation({'isReGeocode': true, 'isNetworkState': true});
    } else if (Platform.isAndroid) {
      _myLocPlugin.startLocation();
    }
  }


  // 同理，如果需要使用百度地图定位能力才需要此方法。
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


  // 同理，如果需要使用百度地图定位能力才需要此方法。
  static BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
        BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
        desiredAccuracy: BMFDesiredAccuracy.best);
    return options;
  }
  
  // 同理，如果需要使用百度地图定位能力才需要此方法。
  initBaiduLocationPermission() async {
    LocationFlutterPlugin myLocPlugin = LocationFlutterPlugin();
    // 动态申请定位权限
    await LocationUtils.requestLocationPermission();
    // 设置是否隐私政策
    myLocPlugin.setAgreePrivacy(true);
    BMFMapSDK.setAgreePrivacy(true);
    if (Platform.isIOS) {
      // 设置ios端ak, android端ak可以直接在清单文件中配置
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


    // 检索对象
    BMFPoiCitySearch citySearch = BMFPoiCitySearch();


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


    // 发起检索
    bool result = await citySearch.poiCitySearch(citySearchOption);


    if (result) {
      print(("发起检索成功"));
    } else {
      print(("发起检索失败"));
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


    // 检索对象
    BMFReverseGeoCodeSearch reverseGeoCodeSearch = BMFReverseGeoCodeSearch();


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
      print(("发起检索成功"));
    } else {
      print(("发起检索失败"));
    }
  }


}
```

```dart
// map_widget_baidu_implement.dart


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


  /// 创建完成回调
  void onMapCreated(BMFMapController controller) {
    timMapController = controller;


    /// 地图加载回调
    timMapController.setMapDidLoadCallback(callback: () {
      print(('mapDidLoad-地图加载完成'));
    });


    /// 设置移动结束回调
    timMapController.setMapRegionDidChangeWithReasonCallback(callback: (status, reason) => onMapMoveEnd(
        status.targetGeoPt != null ? TIMCoordinate.fromMap(status.targetGeoPt!.toMap()) : null,
        TIMRegionChangeReason.values[reason.index]),
    );


    if(widget.onMapLoadDone != null){
      widget.onMapLoadDone!();
    }
  }


  /// 地图移动结束
  @override
  void onMapMoveEnd(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason){
    if(widget.onMapMoveEnd != null){
      widget.onMapMoveEnd!(targetGeoPt, regionChangeReason);
    }
  }


  /// 移动地图视角
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


  /// 设置地图参数
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
```

### 引入LBS组件

此组件既可以配合腾讯云IM Flutter UIKIt使用，也可以单独在自实现UI中使用。

由于[插件README中已经提及如何在UIKit中使用LBS](https://pub.dev/packages/tim_ui_kit_lbs_plugin#uikit)，本部分介绍如何将百度地图实例化类接入。
#### LocationPicker组件

```dart
LocationPicker(
  isUseMapSDKLocation: true,
  onChange: (LocationMessage location) async {
    // 【Important】此处处理发位置消息逻辑。若配合UIKit使用，写法请参考本插件README
    // https://pub.dev/packages/tim_ui_kit_lbs_plugin#uikit
  },
  mapBuilder: (onMapLoadDone, mapKey, onMapMoveEnd) => BaiduMap(
    onMapMoveEnd: onMapMoveEnd,
    onMapLoadDone: onMapLoadDone,
    key: mapKey,
  ),
  locationUtils: LocationUtils(BaiduMapService()),
),
```

#### LocationMsgElement组件

本组件可点击跳转至LocationShow组件。因此一般情况下，引入此组件后，无需引入LocationShow组件。

```dart
LocationMsgElement(
  isUseMapSDKLocation: true,
  messageID: messageID,
  locationElem: locationElem,
  isFromSelf: isFromSelf,
  isShowJump: isShowJump,
  clearJump: clearJump,
  mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
    onMapLoadDone: onMapLoadDone,
    key: mapKey,
  ),
  locationUtils: LocationUtils(BaiduMapService()),
),
```

#### LocationShow组件

```dart
LocationShow(
  addressName: addressName,
  addressLocation: addressLocation,
  longitude: widget.locationElem.longitude,
  latitude: widget.locationElem.latitude,
  mapBuilder: (onMapLoadDone, mapKey) => BaiduMap(
    onMapLoadDone: onMapLoadDone,
    key: mapKey,
  ),
  locationUtils: LocationUtils(BaiduMapService()),
),
```

至此，百度地图配合LBS插件接入完成。