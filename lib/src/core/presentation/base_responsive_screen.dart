import 'package:codebase/src/core/presentation/screen_breakpoint_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseResponsiveScreen<B extends Bloc<dynamic, S>, S> extends StatelessWidget {
  const BaseResponsiveScreen({super.key});

  /// Factory method to create the BLoC.
  B bloc(BuildContext context);

  /// Optimization: Control when the UI should rebuild.
  bool buildWhen(S previous, S current) => previous != current;
  
  /// Optimization: Control when the UI should listen for state changes.
  bool listenWhen(S previous, S current) => previous != current;
  
  /// Listener for side effects (e.g., showing SnackBars on errors).
  void listener(BuildContext context, S state) {}
  
  /// Define the breakpoints and layouts for different screen sizes.


  /// Adaptive layouts for different screen sizes.
  Widget buildSmallScreen(BuildContext context, S state);
  Widget buildMediumScreen(BuildContext context, S state) => buildSmallScreen(context, state);
  Widget buildLargeScreen(BuildContext context, S state) => buildMediumScreen(context, state);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: bloc,
      child: BlocConsumer<B, S>(
        listenWhen: listenWhen,
        buildWhen: buildWhen,
        listener: listener,
        builder: (context, state) {
         return ScreenBreakpointBuilder(
           smallBuilder: (context) => buildSmallScreen(context, state),
           mediumBuilder: (context) => buildMediumScreen(context, state),
           largeBuilder: (context) => buildLargeScreen(context, state),
         );
        },
      ),
    );
  }
  
  /// Optional: Common UI states for error, loading, and empty states.
  Widget buildError(BuildContext context, String message) {
    return Center(child: Text(message));
  }
  
  /// Optional: Common UI states for error, loading, and empty states.
  Widget buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  /// Optional: Common UI states for error, loading, and empty states.
  Widget buildEmpty(BuildContext context) {
    return const Center(child: Text('No data available'));
  }
  
  /// Optional: Common UI states for error, loading, and empty states.
  Widget buildPlaceholder(BuildContext context) {
    return const Center(child: Text('Something went wrong'));
  }
}
