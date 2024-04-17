import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class IOSOnly extends StatelessWidget {
  final Widget child;
  const IOSOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UniversalPlatform.isIOS ? child : Container();
  }
}
