import 'package:flutter/material.dart';
import 'package:tencent_im_base/theme/color.dart';

class LocationLstItem extends StatelessWidget {
  final String name;
  final String? address;
  final VoidCallback? onClick;
  final bool isSelected;

  const LocationLstItem({Key? key,
    required this.name,
    this.address,
    this.onClick,
    required this.isSelected}) : super(key: key);

  _renderAddress(String? text){
    return (text != null) ?
    Text(
      text,
      style: const TextStyle(color: CommonColor.weakTextColor, height: 1.5, fontSize: 14),
    ) : Container(height: 0,);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: hexToColor("DBDBDB"), width: 0.5))
        ),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        softWrap: true,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400),
                      ),
                      _renderAddress(address),
                    ],
                  ),
                )
            ),
            if(isSelected) const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.check,
                color: CommonColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}