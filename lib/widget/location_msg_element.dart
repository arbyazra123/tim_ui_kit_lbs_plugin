import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tencent_im_base/theme/color.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/tim_location_model.dart';
import 'package:tim_ui_kit_lbs_plugin/abstract/map_widget.dart';
import 'package:tim_ui_kit_lbs_plugin/utils/location_utils.dart';
import '../pages/location_show.dart';
import '/abstract/map_class.dart';

class LocationMsgElement extends StatefulWidget {
  /// message ID / 消息ID
  final String? messageID;

  /// LocationMessage message / LocationMessage消息
  final LocationMessage locationElem;
  final TextStyle? textStyle;
  final TextStyle? headerTextStyle;

  /// Whether this message is sent from self / 是否自己发送
  final bool isFromSelf;

  /// Whether shows the style represent this message is been jumped to / 是否显示被跳转样式
  final bool? isShowJump;

  /// Clear the jump function(commonly used with UIKit) / 清除跳转方法
  final VoidCallback? clearJump;

  /// LocationUtils with the TIMMapService implemented with specific Map SDK. / 传入根据选定地图SDK实例化后的LocationUtils
  final LocationUtils locationUtils;
  final Color? backgroundColor;

  /// TIMMapWidget with the inherited map widget by the Map SDK you chose. / 传入根据选定地图SDK实例化后的地图组件TIMMapWidget
  final TIMMapWidget Function(VoidCallback onMapLoadDone, Key mapKey)
      mapBuilder;

  /// To control if the poisoning ability from Map SDK is needed, if true, please make sure 'moveToCurrentLocationActionWithSearchPOIByMapSDK' been implemented correctly.
  /// 用于控制是否使用地图SDK定位能力。若使用，请确保moveToCurrentLocationActionWithSearchPOIByMapSDK方法继承正确。
  final bool? isUseMapSDKLocation;

  /// To control is allow the location show page has a location button on bottom right. / 是否显示定位按钮
  final bool isAllowCurrentLocation;

  const LocationMsgElement(
      {Key? key,
      required this.messageID,
      required this.locationElem,
      required this.isFromSelf,
      this.isShowJump = false,
      this.clearJump,
      required this.locationUtils,
      required this.mapBuilder,
      this.isUseMapSDKLocation = true,
      this.isAllowCurrentLocation = true,
      this.backgroundColor,
      this.textStyle,
      this.headerTextStyle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationMsgElementState();
}

class _LocationMsgElementState extends State<LocationMsgElement> {
  String filePath = "";
  bool isShowJumpState = false;
  String dividerForDesc = "/////";
  GlobalKey<TIMMapState> mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  _showJumpColor() {
    int shineAmount = 10;
    setState(() {
      isShowJumpState = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.clearJump != null) {
        widget.clearJump!();
      }
    });
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        timer.cancel();
      }
      shineAmount--;
    });
  }

  void onMapLoadDone() {
    mapKey.currentState?.moveMapCenter(TIMCoordinate(
        widget.locationElem.latitude, widget.locationElem.longitude));
    mapKey.currentState?.forbiddenMapFromInteract();
  }

  @override
  Widget build(BuildContext context) {
    String address = widget.locationElem.desc; // "Unknown place"
    String addressName = address;
    String? addressLocation;
    if (RegExp(dividerForDesc).hasMatch(address)) {
      addressName = address.split(dividerForDesc)[0];
      addressLocation = address.split(dividerForDesc)[1] != "null"
          ? address.split(dividerForDesc)[1]
          : null;
    }
    final borderRadius = widget.isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    if (widget.isShowJump == true) {
      _showJumpColor();
    }
    final backgroundColor = isShowJumpState
        ? const Color.fromRGBO(245, 166, 35, 1)
        : widget.backgroundColor ?? Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationShow(
                isAllowCurrentLocation: widget.isAllowCurrentLocation,
                addressName: addressName,
                addressLocation: addressLocation,
                longitude: widget.locationElem.longitude,
                latitude: widget.locationElem.latitude,
                mapBuilder: widget.mapBuilder,
                locationUtils: widget.locationUtils,
              ),
            ));
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            // border: Border.all(color: hexToColor("DDDDDD")),
          ),
          constraints: const BoxConstraints(maxWidth: 240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (addressName.isNotEmpty)
                      //   Text(
                      //     addressName,
                      //     softWrap: true,
                      //     style: widget.headerTextStyle ??
                      //         const TextStyle(fontSize: 16),
                      //   ),
                      // const SizedBox(
                      //   height: 2,
                      // ),
                      if (addressLocation != null && addressLocation.isNotEmpty)
                        Text(
                          addressLocation,
                          softWrap: true,
                          style: widget.textStyle ??
                              const TextStyle(
                                  fontSize: 12,
                                  color: CommonColor.weakTextColor),
                        ),
                    ],
                  )),
              SizedBox(
                height: 100,
                width: 238,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: widget.mapBuilder(
                          onMapLoadDone,
                          mapKey,
                        ),
                      ),
                    ),
                    // Positioned(
                    //     child: Container(
                    //       margin: const EdgeInsets.only(bottom: 15),
                    //       child: const Icon(
                    //         Icons.place,
                    //         color: CommonColor.primaryColor,
                    //         size: 30,
                    //       ),
                    //     )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationShow(
                                isUseMapSDKLocation:
                                    widget.isUseMapSDKLocation ?? true,
                                addressName: addressName,
                                addressLocation: addressLocation,
                                longitude: widget.locationElem.longitude,
                                latitude: widget.locationElem.latitude,
                                mapBuilder: widget.mapBuilder,
                                locationUtils: widget.locationUtils,
                              ),
                            ));
                      },
                      child: Container(
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
