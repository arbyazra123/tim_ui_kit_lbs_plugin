import 'package:flutter/cupertino.dart';

abstract class TIMLocationBaseModel {
  /// model -> map
  @required
  Map<String, Object?> toMap();

  /// map -> dynamic
  @required
  dynamic fromMap(Map map);
}

class LocationMessage {
  final String desc;
  final double longitude;
  final double latitude;

  LocationMessage({required this.desc, required this.longitude, required this.latitude});
}

/// Coordinate / 代表经纬度
class TIMCoordinate implements TIMLocationBaseModel {
  /// Latitude / 纬度
  late double latitude;

  /// Longitude / 经度
  late double longitude;

  /// Constructor of TIMCoordinate / TIMCoordinate构造方法
  TIMCoordinate(this.latitude, this.longitude);

  /// map => TIMCoordinate
  TIMCoordinate.fromMap(Map map)
      : assert(map.containsKey('latitude'),
  'Construct a TIMCoordinate，The parameter latitude cannot be null'),
        assert(map.containsKey('longitude'),
        'Construct a TIMCoordinate，The parameter longitude cannot be null') {
    latitude = map['latitude'] as double;
    longitude = map['longitude'] as double;
  }

  @override
  Map<String, Object> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  fromMap(Map map) {
    return TIMCoordinate.fromMap(map);
  }
}

/// POI information class / POI信息类
class TIMPoiInfo implements TIMLocationBaseModel {
  /// POI name / POI名称
  String? name;

  /// POI coordinate / POI坐标
  TIMCoordinate? pt;

  /// POI full address / POI地址信息
  String? address;

  /// POI unique identifier 'uid' / POI唯一标识符uid√
  String? uid;

  /// Province where POI located / POI所在省份
  String? province;

  /// City where POI located / POI所在城市
  String? city;

  /// Constructor of TIMPoiInfo / TIMPoiInfo构造方法
  TIMPoiInfo({
    this.name,
    this.pt,
    this.address,
    this.uid,
    this.province,
    this.city,
  });

  /// map => TIMPoiInfo
  TIMPoiInfo.fromMap(Map map)
      : assert(
  map != null, // ignore: unnecessary_null_comparison
  'Construct a TIMPoiInfo，The parameter map cannot be null !') {
    name = map['name'];
    pt = map['pt'] == null ? null : TIMCoordinate.fromMap(map['pt']);
    address = map['address'];
    uid = map['uid'];
    province = map['province'];
    city = map['city'];
  }
  @override
  fromMap(Map map) {
    return TIMPoiInfo.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'pt': pt?.toMap(),
      'address': address,
      'uid': uid,
      'province': province,
      'city': city,
    };
  }
}

/// The result class of the reverse query according to the coordinate / 根据地理坐标反向查询结果类
class TIMReverseGeoCodeSearchResult implements TIMLocationBaseModel {
  /// Coordinate / 地址坐标
  TIMCoordinate? location;

  /// Full address / 地址
  String? address;

  /// Hierarchical address information / 层次化地址信息
  TIMAddressComponent? addressDetail;

  /// POI information list around the searched address. Member type is TIMPoiInfo. / 地址周边POI信息，成员类型为TIMPoiInfo
  List<TIMPoiInfo>? poiList;

  /// Semantic result description of current POI location, used as the address name. Such as "100m south of the The Quarter Library, inside the Camperdown campus of the University of Sydney".
  /// 结合当前位置POI的语义化结果描述， 用于地址名称字段。例如"腾讯大厦内，招行信息研发大厦附近18米"。
  String? semanticDescription;

  /// Constructor of TIMReverseGeoCodeSearchResult / 有参构造
  TIMReverseGeoCodeSearchResult({
    this.location,
        this.address,
        this.addressDetail,
        this.poiList,
        this.semanticDescription,
    });

  /// map => TIMReverseGeoCodeSearchResult
  TIMReverseGeoCodeSearchResult.fromMap(Map map)
      : assert(
  map != null, // ignore: unnecessary_null_comparison
  'Construct a TIMReverseGeoCodeSearchResult，The parameter map cannot be null !') {
    location =
    map['location'] == null ? null : TIMCoordinate.fromMap(map['location']);
    address = map['address'];
    addressDetail = map['addressDetail'] == null
        ? null
        : TIMAddressComponent.fromMap(map['addressDetail']);
    if (map['poiList'] != null) {
      List<TIMPoiInfo> tmpPoiList = [];
      map['poiList'].forEach((v) {
        tmpPoiList.add(TIMPoiInfo.fromMap(v as Map));
      });
      poiList = tmpPoiList;
    }
    semanticDescription = map['semanticDescription'];
    semanticDescription = map['sematicDescription']; // 百度的SDK拼错了，得适配下
  }

  @override
  fromMap(Map map) {
    return TIMReverseGeoCodeSearchResult.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'location': location?.toMap(),
      'address': address,
      'addressDetail': addressDetail?.toMap(),
      'poiList': poiList?.map((p) => p.toMap()).toList(),
      'semanticDescription': semanticDescription
    };
  }
}

/// Hierarchical address information / 地址结果的层次化信息
class TIMAddressComponent implements TIMLocationBaseModel {
  /// Country of the address / 国家
  String? country;

  /// Province of the address / 省份名称
  String? province;

  /// City of the address / 城市名称
  String? city;

  /// District of the address / 区县名称
  String? district;

  /// Town of the address / 乡镇
  String? town;

  /// Constructor of TIMAddressComponent / 有参构造
  TIMAddressComponent({
    this.country,
    this.province,
    this.city,
    this.district,
    this.town,
  });

  /// map => TIMAddressComponent
  TIMAddressComponent.fromMap(Map map)
      : assert(
  map != null, // ignore: unnecessary_null_comparison
  'Construct a TIMAddressComponent，The parameter map cannot be null !') {
    country = map['country'];
    province = map['province'];
    city = map['city'];
    district = map['district'];
    town = map['town'];
  }
  @override
  fromMap(Map map) {
    return TIMAddressComponent.fromMap(map);
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'town': town,
    };
  }
}

/// Enum：The reason why region on the screen changed
/// 枚举：地图区域改变原因
enum TIMRegionChangeReason {
  /// Triggered by user's gesture, such as double clicking, dragging or sliding the map.
  /// 手势触发导致地图区域变化，如双击、拖拽、滑动地图。
  Gesture,

  /// The event called by widget on the map, such as switching the map type by clicking the widget on the map.
  /// 地图上控件事件，如点击指南针返回2D地图。
  Event,

  /// API interface event called by your program, such as re-setting map parameters and leads the changes in the map area.
  /// 开发者调用接口、设置地图参数等导致地图区域变化。
  APIs,
}

/// App information used as external navigation APP.
/// 用于作为外部导航软件的App信息
class NavigationMapItem{
  /// APP name / APP 名称
  final String name;
  /// jumping function to navigation APP / 唤起外部导航APP的方法
  final Function(double longitude, double latitude) jumpFunc;

  NavigationMapItem(this.name, this.jumpFunc);
}
