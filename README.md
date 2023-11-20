
<br>

<p align="center">
  <a href="https://www.tencentcloud.com/products/im?from=pub">
    <img src="https://qcloudimg.tencent-cloud.cn/raw/429a2f58678a1f5b150c6ae04aa0b569.png" width="320px" alt="Tencent Chat Logo" />
  </a>
</p>

<h1 align="center">Tencent Cloud Chat Location Message</h1>

<p align="center">
  Custom location message extension for Tencent Cloud Chat SDK. Allows search and pick a location, send location and show location.
</p>

<p align="center">
More languages:
  <a href="https://cloud.tencent.com/document/product/269/80881">简体中文</a>
</p>

![](https://qcloudimg.tencent-cloud.cn/raw/40e0f127ac90a8d333f8fc5748e395e1.jpg)

# Tencent Cloud Chat Flutter UIKit LBS Message Plugin

With this plugin, developers can implement lbs (location message) to projects easily.

We provided three widgets, including: location picker(LocationPicker)/ location shows in whole page(LocationShow)/ location shows in history message list(LocationMsgElement),
with the related business logic referring to them, except those interact with Map SDK.

Also, we provided complicated example code based on Baidu Map, for the sake of easy integration, which could run directly, so developers can create the whole lbs project based on our code.
## Vocabulary
POI: Point of interesting, each point without geographical significance in the map. Each POI contains coordinate, name, address and ID.
For example：The White House, The University of Sydney, etc.

## Developing Introduction
### Overall Process：
1. Choose a specific Map SDK for Flutter
2. Extends three abstract classes, in order to connect this plug-in to your Map SDK
3. Instantiate the inherited abstract class and pass it into the three components provided by this plug-in

### Choose a specific Map SDK for Flutter
The choosing of Map SDK is not limited, here shows some links.

Baidu Map (in Chinese)：https://lbsyun.baidu.com/index.php?title=flutter/loc

Google Map：https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#0

### Data Structure for interaction
This plug-in defined several data structure models to describe the data transferred, 
especially between the abstract class been implemented with Map SDK and the lbs business function.
Including:
```dart
class LocationMessage {
  final String desc;
  final double longitude;
  final double latitude;
}

/// Coordinate
class TIMCoordinate implements TIMLocationBaseModel {
  /// Latitude
  late double latitude;

  /// Longitude
  late double longitude;

  Map<String, Object> toMap();

  fromMap(Map map);
}

/// POI information class
class TIMPoiInfo implements TIMLocationBaseModel {
  /// POI name
  String? name;

  /// POI coordinate
  TIMCoordinate? pt;

  /// POI full address
  String? address;

  /// POI unique identifier 'uid'
  String? uid;

  /// Province where POI located
  String? province;

  /// City where POI located
  String? city;

  fromMap(Map map);

  Map<String, Object?> toMap();
}

/// The result class of the reverse query according to the coordinate
class TIMReverseGeoCodeSearchResult implements TIMLocationBaseModel {
  /// Coordinate
  TIMCoordinate? location;

  /// Full address
  String? address;

  /// Hierarchical address information
  TIMAddressComponent? addressDetail;

  /// POI information list around the searched address. Member type is TIMPoiInfo.
  List<TIMPoiInfo>? poiList;

  /// Semantic result description of current POI location, used as the address name. 
  /// Such as "100m south of the The Quarter Library, inside the Camperdown campus of the University of Sydney".
  String? semanticDescription;

  fromMap(Map map);

  Map<String, Object?> toMap();
}

/// Hierarchical address information
class TIMAddressComponent implements TIMLocationBaseModel {
  /// Country of the address
  String? country;

  /// Province of the address
  String? province;

  /// City of the address
  String? city;

  /// District of the address
  String? district;

  /// Town of the address
  String? town;

  fromMap(Map map);

  Map<String, Object?> toMap()
}

/// Enum：The reason why region on the screen changed
enum TIMRegionChangeReason {
  /// Triggered by user's gesture, such as double clicking, dragging or sliding the map
  Gesture,

  /// The event called by widget on the map, such as switching the map type by clicking the widget on the map
  Event,

  /// API interface event called by your program, such as re-setting map parameters and leads the changes in the map area. 
  APIs,
}

/// App information used as external navigation APP.
class NavigationMapItem{
  /// APP name
  final String name;
  /// jumping function to navigation APP
  final Function(double longitude, double latitude) jumpFunc;

  NavigationMapItem(this.name, this.jumpFunc);
}

```

### Inherit abstract classes and connect map SDK with plug-in business function
Please inherit the following three abstract classed according with the Map SDK you selected.
#### TIMMapService
Getting current location and search for POI with both keyword and coordinate.
Please implements these function with the Map SDK you selected.
```dart

  /// 【Optional】 Please implement this function, only if you need use the positioning ability from Map SDK. Switch: 'isUseMapSDKLocation' of 'LocationPicker/LocationShow'. 
  /// Need getting the current location from Map SDK then move the map center to that location by 'moveMapCenter'.
  /// Then, return the coordinate of the current location along with the list of POI around it.
  void moveToCurrentLocationActionWithSearchPOIByMapSDK({
    required void Function(TIMCoordinate coordinate) moveMapCenter,
    void Function(TIMReverseGeoCodeSearchResult, bool)?
    onGetReverseGeoCodeSearchResult,
  });

  /// Searching the POI list by keyword, those in designated city are of priority.
  void poiCitySearch({
    required void Function(List<TIMPoiInfo>?, bool)
    onGetPoiCitySearchResult,
    required String keyword,
    required String city,
  });

  /// Searching the POI list according to the coordinate, and return a function with 'TIMReverseGeoCodeSearchResult' and boolean of isError.
  void searchPOIByCoordinate(
      {required TIMCoordinate coordinate,
        required void Function(TIMReverseGeoCodeSearchResult, bool)
        onGetReverseGeoCodeSearchResult});
```
#### TIMMapWidget
The basic class to render the Map widget you choose. This is a stateful widget, needs to inherit TIMMapState.
Including the callback function after map loading done and map moving done.
```dart
  final Function? onMapLoadDone;
  final Function(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason)? onMapMoveEnd;
```
#### TIMMapState
The state of basic class to render the Map widget you choose. 
Including several functions for the interaction with map, and returns the map widget can be used directly outside.
```dart
  /// Callback function after map loading done
  void onMapLoadDone(){}

  /// Callback function after map moving 
  void onMapMoveEnd(TIMCoordinate? targetGeoPt, TIMRegionChangeReason regionChangeReason){}

  /// Move the center coordinate of the map
  void moveMapCenter(TIMCoordinate pt){}

  /// Forbidden the map from interaction with gesture, etc.
  void forbiddenMapFromInteract() {}

  /// add a mark on the specific coordinate on map
  void addMarkOnMap(TIMCoordinate pt, String title){}

/// getting the Map widget
  @override
  Widget build(BuildContext context) {
    return Container(
      child: the Map widget from the Map SDK you chosed(
        onMapCreated: onMapCreated,
      ),
    );
  }
```

### Using the LBS widgets
#### Location picker（LocationPicker）
The interface and function are similar to those in WeChat.
Users can positioning, choose a point on map, search for POI, show the POI list around.
```dart
  /// The onChange(LocationMessage) callback after users finish choosing the location. 
  /// 【Reminder】The 'LocationMessage.desc' here splicing the name and address into a string, due to the location message of Tencent Cloud Chat only includes one string, 'desc'.
  /// Such as: "The University of Sydney/////Camperdown NSW 2006".
  /// The splicing format can be parsed by anywhere in this plug-in.
  final ValueChanged<LocationMessage> onChange;

  /// LocationUtils with the TIMMapService implemented with specific Map SDK.
  final LocationUtils locationUtils;
  
  /// The default center coordinate shows before positioning.
  final TIMCoordinate? initCoordinate;

  /// To control if the poisoning ability from Map SDK is needed, if true, please make sure 'moveToCurrentLocationActionWithSearchPOIByMapSDK' been implemented correctly.
  final bool? isUseMapSDKLocation;

  /// TIMMapWidget with the inherited map widget by the Map SDK you chose.
  final TIMMapWidget Function(
      VoidCallback onMapLoadDone,
      Key mapKey,
      Function(TIMCoordinate? targetGeoPt,
              TIMRegionChangeReason regionChangeReason)
          onMapMoveEnd) mapBuilder;
```
#### Location shows in whole page（LocationShow）
The interface and function are similar to those in WeChat.
Shows in big map with location mark. The location name and address show in bottom, with the button jumping to Map APP to navigate.
```dart
  /// Address name
  final String addressName;

  /// Full address
  final String? addressLocation;

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// LocationUtils with the TIMMapService implemented with specific Map SDK.
  final LocationUtils locationUtils;

  /// To control if the poisoning ability from Map SDK is needed, if true, please make sure 'moveToCurrentLocationActionWithSearchPOIByMapSDK' been implemented correctly.
  final bool? isUseMapSDKLocation;

  /// External navigation map list for jumping out to navigate, if nothing here, default list includes "Tencent Map", "AMap", "Baidu Map", "Apple Map".
  final List<NavigationMapItem>? navigationMapList;

  /// TIMMapWidget with the inherited map widget by the Map SDK you chose.
  final TIMMapWidget Function(
      VoidCallback onMapLoadDone,
      Key mapKey) mapBuilder;
```
#### Location shows in history message list（LocationMsgElement）
This widget used to show LBS message in history message list in a smaller box.
Contains location name, full address, and a small map.
```dart
  /// message ID
  final String? messageID;

  /// V2TimLocationElem message
  final V2TimLocationElem locationElem;

  /// Whether this message is sent from self
  final bool isFromSelf;

  /// Whether shows the style represent this message is been jumped to
  final bool? isShowJump;

  /// Clear the jump function(commonly used with UIKit)
  final VoidCallback? clearJump;

  /// LocationUtils with the TIMMapService implemented with specific Map SDK.
  final LocationUtils locationUtils;

  /// To control if the poisoning ability from Map SDK is needed, if true, please make sure 'moveToCurrentLocationActionWithSearchPOIByMapSDK' been implemented correctly.
  final bool? isUseMapSDKLocation;

  /// TIMMapWidget with the inherited map widget by the Map SDK you chose.
  final TIMMapWidget Function(VoidCallback onMapLoadDone, Key mapKey)
      mapBuilder;
```

### Implements with TIM Flutter TUIKit
Though this part of code is optional, means you can use these widgets above wherever you need if you tend to self-implement integration, 
you can still read this part, to refer how to call these widgets.

#### Render message in history message list (LocationMsgElement)
Please add following parameter to 'TIMUIKitChat'. It will shows a small box in the history message list.
By clicking the this item, it will jump to 'LocationShow' directly, so it's unnecessary to call 'LocationShow' inside your program in this case.

'TIMMapWidget' and 'TIMMapService' needs to be replaced by your inherited class with specific Map SDK implemented, like shows in our example.
```dart
          messageItemBuilder: MessageItemBuilder(
          locationMessageItemBuilder: (message, isShowJump, clearJump) {
            return LocationMsgElement(
              messageID: message.msgID,
              locationElem: LocationMessage(),
              isFromSelf: message.isSelf ?? false,
              isShowJump: isShowJump,
              clearJump: clearJump,
              mapBuilder: (onMapLoadDone, mapKey) => TIMMapWidget(
                onMapLoadDone: onMapLoadDone,
                key: mapKey,
              ),
              locationUtils: LocationUtils(TIMMapService()),
            );
          },
        ),
```

#### Add a 'Location' button in More Panel to call location picker（LocationPicker）
Please add following parameter to 'TIMUIKitChat'. 
This extraAction can jump to 'LocationPicker' and send LBS message. 

'TIMMapWidget' and 'TIMMapService' needs to be replaced by your inherited class with specific Map SDK implemented, like shows in our example.
```dart
      morePanelConfig: MorePanelConfig(
        extraAction: [
          MorePanelItem(
              id: "location",
              title: ("location"),
              onTap: (c) {
				  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPicker(
            onChange: (LocationMessage location) async {
              // The message sending function here needs to be modified according to your program.
              final locationMessageInfo = await sdkInstance.v2TIMMessageManager.createLocationMessage(
                  desc: location.desc, longitude: location.longitude, latitude: location.latitude);
              final messageInfo = locationMessageInfo.data!.messageInfo;
              _timuiKitChatController.sendMessage(
                  convID: _getConvID()!,
                  convType: _getConvType(),
                  messageInfo: messageInfo
              );
            },
            mapBuilder: (onMapLoadDone, mapKey, onMapMoveEnd) => TIMMapWidget(
              onMapMoveEnd: onMapMoveEnd,
              onMapLoadDone: onMapLoadDone,
              key: mapKey,
            ),
            locationUtils: LocationUtils(TIMMapService()),
          ),
        ));
              },
              icon: Container(
                height: 64,
                width: 64,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Icon(
                  Icons.location_on,
                  color: hexToColor("5c6168"),
                  size: 32,
                ),
              ))
        ],
      ),
```
## Contact Us

Please do not hesitate to contact us in the following place, if you have any further questions or tend to learn more about the use cases.

- Telegram Group: <https://t.me/+1doS9AUBmndhNGNl>
- WhatsApp Group: <https://chat.whatsapp.com/Gfbxk7rQBqc8Rz4pzzP27A>
- QQ Group: 788910197, chat in Chinese

Our Website: <https://www.tencentcloud.com/products/im?from=pub>