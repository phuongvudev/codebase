import 'package:flutter/material.dart';

class ScreenBreakpointBuilder extends StatelessWidget {
  final WidgetBuilder smallBuilder;
  final WidgetBuilder? mediumBuilder;
  final WidgetBuilder? largeBuilder;

  const ScreenBreakpointBuilder({
    super.key,
    required this.smallBuilder,
    this.mediumBuilder,
    this.largeBuilder,
  });

  double get tabletBreakpoint => 600.0;

  double get desktopBreakpoint => 1200.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > desktopBreakpoint && largeBuilder != null) {
          return largeBuilder!(context);
        } else if (constraints.maxWidth > tabletBreakpoint &&
            mediumBuilder != null) {
          return mediumBuilder!(context);
        } else {
          return smallBuilder(context);
        }
      },
    );
  }
}
