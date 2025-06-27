import 'package:flutter/material.dart';

import '../style/app_color.dart';

class GoodOrBad extends StatelessWidget {
  final dynamic data;
  const GoodOrBad({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return data == null
        ? Icon(
            Icons.cancel_rounded,
            color: AppColor.redColor,
          )
        : Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
          );
  }
}
