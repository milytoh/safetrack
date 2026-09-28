import 'package:flutter/material.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(padding: padding, child: child),
    );
  }
}
