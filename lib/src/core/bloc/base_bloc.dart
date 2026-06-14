import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_state.dart';

abstract class BaseAppBloc<E, T> extends Bloc<E, BaseState<T>> {
  BaseAppBloc() : super(const InitialState());

}
