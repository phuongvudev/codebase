

sealed class BaseState<T> {
  final T? data;
  const BaseState({this.data});
}

class InitialState<T> extends BaseState<T> {
  const InitialState();
}

class LoadingState<T> extends BaseState<T> {
  const LoadingState();
}

class ProgressState<T> extends BaseState<T> {
  final double progress; // 0.0 to 1.0
  const ProgressState(this.progress);
}

class ProcessingState<T> extends BaseState<T> {
  final String message;
  const ProcessingState(this.message);
}

class SuccessState<T> extends BaseState<T> {
  const SuccessState({super.data});
}

class FailureState<T> extends BaseState<T> {
  final String message;
  const FailureState(this.message);
}
