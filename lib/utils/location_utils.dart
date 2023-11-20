import 'dart:async';
import 'dart:io' show Platform;
import 'package:location/location.dart' as flutter_location;
import 'package:permission_handler/permission_handler.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_service.dart';

class LocationUtils {
  static LocationUtils? _instance;
  LocationUtils._internal(this.service);
  factory LocationUtils(TIMMapService service) {
    _instance ??= LocationUtils._internal(service);
    return _instance!;
  }

  final TIMMapService service;

  static Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<TIMCoordinate?> getAddressByFlutter() async {
    final isAvailable = await LocationUtils.requestLocationPermission();
    if (isAvailable == true) {
      flutter_location.Location location = flutter_location.Location();
      final locationData = await location.getLocation();
      return TIMCoordinate(locationData.latitude!, locationData.longitude!);
    }
    return null;
  }

  void moveToCurrentLocationActionWithSearchPOI({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
    void Function(TIMReverseGeoCodeSearchResult, bool)?
        onGetReverseGeoCodeSearchResult,
  }) {
    service.moveToCurrentLocationActionWithSearchPOIByMapSDK(
        moveMapCenter: moveMapCenter,
        onGetReverseGeoCodeSearchResult: onGetReverseGeoCodeSearchResult);
  }

  Future<TIMCoordinate?> moveToCurrentLocationActionWithoutSearchPOI({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
  }) async {
    final TIMCoordinate? location = await LocationUtils.getAddressByFlutter();
    if (location != null) {
      moveMapCenter(location);
      return location;
    }
    return null;
  }

  poiCitySearch({
    required void Function(List<TIMPoiInfo>?, bool) onGetPoiCitySearchResult,
    required String keyword,
    required String city,
  }) async {
    service.poiCitySearch(
        onGetPoiCitySearchResult: onGetPoiCitySearchResult,
        keyword: keyword,
        city: city);
  }

  void searchPOIByCoordinate(
      {required TIMCoordinate coordinate,
      required void Function(TIMReverseGeoCodeSearchResult, bool)
          onGetReverseGeoCodeSearchResult}) async {
    service.searchPOIByCoordinate(
        coordinate: coordinate,
        onGetReverseGeoCodeSearchResult: onGetReverseGeoCodeSearchResult);
  }

  // Developers can self-defined the following functions to call navigation App

  /// AMap / 高德地图
  static Future<bool> gotoAMap(longitude, latitude) async {
    var url =
        '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=$latitude&lon=$longitude&dev=0&style=2';

    bool canLaunchMap = await canLaunchUrl(Uri.parse(url));

    if (!canLaunchMap) {
      Utils.toast(('未检测到高德地图')); // "Not detect AMap"
      return false;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    return true;
  }

  /// Tencent Map / 腾讯地图
  static Future<bool> gotoTencentMap(longitude, latitude) async {
    var url =
        'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=$latitude,$longitude&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
    bool canLaunchMap = await canLaunchUrl(Uri.parse(url));

    if (!canLaunchMap) {
      Utils.toast(('未检测到腾讯地图')); // "Not detect Tencent Map"
      return false;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    return canLaunchMap;
  }

  /// Google Map
  static Future<bool> gotoGoogleMap(longitude, latitude) async {
    var url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    bool canLaunchMap = await canLaunchUrl(Uri.parse(url));

    if (!canLaunchMap) {
      Utils.toast(('未检测到腾讯地图')); // "Not detect Tencent Map"
      return false;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    return canLaunchMap;
  }

  /// Baidu Map / 百度地图
  static Future<bool> gotoBaiduMap(longitude, latitude) async {
    var url =
        'baidumap://map/direction?destination=$latitude,$longitude&coord_type=bd09ll&mode=driving';

    bool canLaunchMap = await canLaunchUrl(Uri.parse(url));

    if (!canLaunchMap) {
      Utils.toast(('未检测到百度地图')); // "Not detect Baidu Map"
      return false;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    return canLaunchMap;
  }

  /// Apple Map / 苹果地图
  static Future<bool> gotoAppleMap(longitude, latitude) async {
    var url = 'http://maps.apple.com/?&daddr=$latitude,$longitude';

    bool canLaunchMap = await canLaunchUrl(Uri.parse(url));

    if (!canLaunchMap) {
      Utils.toast(('打开失败')); // "Open failed"
      return false;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    return canLaunchMap;
  }

  static debounce(
    Function(String text) fun, [
    Duration delay = const Duration(milliseconds: 500),
  ]) {
    Timer? timer;
    return (String text) {
      if (timer != null) {
        timer?.cancel();
      }

      timer = Timer(delay, () {
        fun(text);
      });
    };
  }
}
