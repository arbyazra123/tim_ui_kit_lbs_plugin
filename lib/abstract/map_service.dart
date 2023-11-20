import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';

abstract class TIMMapService{

  /// 【Optional】 Please implement this function, only if you need use the positioning ability from Map SDK. Switch: 'isUseMapSDKLocation' of 'LocationPicker'.
  /// Need getting the current location from Map SDK then move the map center to that location by 'moveMapCenter'.
  /// Then, return the coordinate of the current location along with the list of POI around it.
  /// 【可选】仅当您需要使用地图SDK提供的定位能力，才需要继承本方法。开关：LocationPicker的isUseMapSDKLocation字段。
  /// 需做到根据地图SDK提供的定位能力定位再通过'moveMapCenter(coordinate)'将地图挪过去，
  /// 并返回含根据新的地图中心查询附近POI的结果及是否出错参数的方法。
  void moveToCurrentLocationActionWithSearchPOIByMapSDK({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
    void Function(TIMReverseGeoCodeSearchResult, bool)?
    onGetReverseGeoCodeSearchResult,
  }){}


  /// Searching the POI list by keyword, those in designated city are of priority.
  /// 根据关键词搜索POI，优先返回在当前city内的结果，但同时也可以搜到其他city的POI。
  void poiCitySearch({
    required void Function(List<TIMPoiInfo>?, bool)
    onGetPoiCitySearchResult,
    required String keyword,
    required String city,
  }) async {}

  /// Searching the POI list according to the coordinate, and return a function with 'TIMReverseGeoCodeSearchResult' and boolean of isError.
  /// 根据地理坐标查询附近的POI，并返回包含TIMReverseGeoCodeSearchResult及是否报错参数的方法。
  void searchPOIByCoordinate(
      {required TIMCoordinate coordinate,
        required void Function(TIMReverseGeoCodeSearchResult, bool)
        onGetReverseGeoCodeSearchResult}) async {}

}