import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingUtils {
  static final instance = LoadingUtils();
  late Timer timer;

  configLoading() {
    EasyLoading.instance
    // ..displayDuration = const Duration(milliseconds: 2000)
      ..boxShadow = <BoxShadow>[]
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 50.0
    // ..radius = 10.0
      ..progressColor = Colors.black
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.black
      ..textColor = Colors.black
      ..maskColor = Colors.black.withOpacity(0.2)
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  showLoading() {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.custom,
    );
  }

  hideLoading() {
    EasyLoading.dismiss(animation: true);
  }
}