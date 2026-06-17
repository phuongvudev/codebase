import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef BaseErrorFallbackBuilder =
    Widget Function(
      BuildContext context,
      Object error,
      StackTrace stackTrace,
      VoidCallback retry,
    );

typedef BaseErrorListener =
    void Function(Object error, StackTrace stackTrace);

class BaseErrorBoundaryController extends ChangeNotifier {
  Object? _error;
  StackTrace? _stackTrace;

  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  bool get hasError => _error != null;

  void capture(Object error, [StackTrace? stackTrace]) {
    _store(error, stackTrace);
    notifyListeners();
  }

  /// Stores an error without notifying listeners.
  ///
  /// Used internally by [BaseErrorBoundary] when a synchronous build error is
  /// already triggering an immediate fallback render in the same frame.
  /// Notifying listeners there would be redundant because the fallback is
  /// returned immediately from the current build. External callers should use
  /// [capture] so listeners are notified as expected.
  void captureSilently(Object error, [StackTrace? stackTrace]) {
    _store(error, stackTrace);
  }

  void _store(Object error, [StackTrace? stackTrace]) {
    _error = error;
    _stackTrace = stackTrace ?? StackTrace.current;
  }

  void clear() {
    if (!hasError) {
      return;
    }

    _error = null;
    _stackTrace = null;
    notifyListeners();
  }
}

class BaseErrorBoundary extends StatefulWidget {
  const BaseErrorBoundary({
    required this.builder,
    this.controller,
    this.fallbackBuilder,
    this.onError,
    this.resetKeys = const <Object?>[],
    super.key,
  });

  /// Builds the protected subtree.
  ///
  /// This catches synchronous exceptions thrown by this callback only.
  /// Descendant widget build failures are still handled by Flutter's own error
  /// pipeline. For async or event-driven failures, call
  /// [BaseErrorBoundary.of] and use the controller's
  /// [BaseErrorBoundaryController.capture] method.
  final WidgetBuilder builder;
  final BaseErrorBoundaryController? controller;
  final BaseErrorFallbackBuilder? fallbackBuilder;
  final BaseErrorListener? onError;

  /// Resets the stored error when any value changes.
  ///
  /// Synchronous build failures stay on the fallback UI until either [retry] is
  /// called from the fallback, [controller.clear] is called, or these keys
  /// change. Treat these values as the dependencies that should retry the
  /// protected build when they update.
  final List<Object?> resetKeys;

  static BaseErrorBoundaryController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BaseErrorBoundaryScope>()
        ?.controller;
  }

  static BaseErrorBoundaryController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(
      controller != null,
      'BaseErrorBoundary.of() called with a context that does not contain a BaseErrorBoundary in its widget tree. Wrap your widget with a BaseErrorBoundary ancestor.',
    );
    return controller!;
  }

  @override
  State<BaseErrorBoundary> createState() => _BaseErrorBoundaryState();
}

class _BaseErrorBoundaryState extends State<BaseErrorBoundary> {
  late BaseErrorBoundaryController _controller;
  late bool _ownsController;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant BaseErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }

    if (!listEquals(oldWidget.resetKeys, widget.resetKeys)) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _unbindController(disposeOwned: true);
    super.dispose();
  }

  void _bindController(BaseErrorBoundaryController? controller) {
    _controller = controller ?? BaseErrorBoundaryController();
    _ownsController = controller == null;
    _syncControllerState();
    _controller.addListener(_onControllerChanged);
  }

  void _unbindController({bool disposeOwned = false}) {
    _controller.removeListener(_onControllerChanged);
    if (disposeOwned && _ownsController) {
      _controller.dispose();
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(_syncControllerState);
    }
  }

  void _syncControllerState() {
    _error = _controller.error;
    _stackTrace = _controller.stackTrace;
  }

  void _captureBuildError(Object error, StackTrace stackTrace) {
    widget.onError?.call(error, stackTrace);
    _controller.captureSilently(error, stackTrace);
    _syncControllerState();
  }

  Widget _buildFallback(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (widget.fallbackBuilder case final fallbackBuilder?) {
      return fallbackBuilder(context, error, stackTrace, _controller.clear);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Something went wrong'),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildFallback(
        context,
        _error!,
        _stackTrace ?? StackTrace.current,
      );
    }

    return _BaseErrorBoundaryScope(
      controller: _controller,
      child: Builder(
        builder: (context) {
          try {
            return widget.builder(context);
          } catch (error, stackTrace) {
            _captureBuildError(error, stackTrace);
            return _buildFallback(context, error, stackTrace);
          }
        },
      ),
    );
  }
}

class _BaseErrorBoundaryScope extends InheritedWidget {
  const _BaseErrorBoundaryScope({
    required this.controller,
    required super.child,
  });

  final BaseErrorBoundaryController controller;

  @override
  bool updateShouldNotify(covariant _BaseErrorBoundaryScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
