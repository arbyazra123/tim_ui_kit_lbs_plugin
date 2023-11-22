import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class LocationInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChange;

  const LocationInput({
    required this.controller,
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LocationInputState();
}

class LocationInputState extends State<LocationInput> {
  late FocusNode focusNode = FocusNode();
  late TextEditingController textEditingController = widget.controller;
  bool isEmptyInput = true;

  @override
  void initState() {
    super.initState();
    isEmptyInput = textEditingController.text.isEmpty;
  }

  hideAllPanel() {
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      transform: Matrix4.translationValues(0, -10, 0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                onChanged: (value) async {
                  final isEmpty = value.isEmpty;
                  setState(() {
                    isEmptyInput = isEmpty ? true : false;
                  });
                  widget.onChange(value);
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                maxLines: 4,
                minLines: 1,
                focusNode: focusNode,
                controller: textEditingController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    // borderSide: BorderSide(
                    //   // color: colorIconSecondary,
                    //   width: 0,
                    // ),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: hexToColor("717171"),
                  ),
                  fillColor: CommonColor.weakBackgroundColor,
                  filled: true,
                  isDense: true,
                  suffixIcon: IconButton(
                    onPressed: () {
                      textEditingController.clear();
                      setState(() {
                        isEmptyInput = true;
                      });
                      widget.onChange("");
                    },
                    icon: const Icon(
                      Icons.clear_rounded,
                    ),
                  ),
                  hintText:
                      "Cari lokasi...", // Search POI by keyword "Search for location"
                  prefixIcon: Icon(
                    Icons.search,
                    color: hexToColor("717171"),
                  ),
                ),
              ),
            ),
          ),
          // if (!isEmptyInput)
          //   Container(
          //       margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          //       child: GestureDetector(
          //         onTap: () {
          //           textEditingController.text = "";
          //           setState(() {
          //             isEmptyInput = true;
          //           });
          //           widget.onChange("");
          //         },
          //         child: Text(TIM_t("取消"), // "cancel"
          //             style: const TextStyle(
          //               color: CommonColor.weakTextColor,
          //             )),
          //       ))
        ],
      ),
    );
  }
}
