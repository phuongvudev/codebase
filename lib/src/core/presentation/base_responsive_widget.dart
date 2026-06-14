import 'package:flutter/material.dart';

abstract class BaseResponsiveWidget extends StatelessWidget {
  const BaseResponsiveWidget({super.key});

  Widget buildSmall(BuildContext context);
  Widget buildLarge(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) return buildLarge(context);
        return buildSmall(context);
      },
    );
  }
}