import 'package:codebase/codebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/abstract_analytics_handler.dart';
import 'analytics_bloc_data.dart';
import 'analytics_bloc_event.dart';

final class AnalyticsBloc
    extends BaseAppBloc<AnalyticsBlocEvent, AnalyticsBlocData> {
  AnalyticsBloc({required AbstractAnalyticsHandler analyticsHandler})
      : _analyticsHandler = analyticsHandler {
    on<TrackAnalyticsEventRequested>(_onTrackEventRequested);
    on<TrackAnalyticsScreenRequested>(_onTrackScreenRequested);
    on<IdentifyAnalyticsUserRequested>(_onIdentifyUserRequested);
    on<ResetAnalyticsRequested>(_onResetRequested);
  }

  final AbstractAnalyticsHandler _analyticsHandler;

  Future<void> _onTrackEventRequested(
    TrackAnalyticsEventRequested event,
    Emitter<BaseState<AnalyticsBlocData>> emit,
  ) async {
    try {
      await _analyticsHandler.trackEvent(event.event);
      emit(SuccessState(data: AnalyticsEventTracked(event: event.event)));
    } catch (error) {
      emit(FailureState('Failed to track event "${event.event.name}": $error'));
    }
  }

  Future<void> _onTrackScreenRequested(
    TrackAnalyticsScreenRequested event,
    Emitter<BaseState<AnalyticsBlocData>> emit,
  ) async {
    try {
      await _analyticsHandler.trackScreen(
        event.screenName,
        parameters: event.parameters,
      );
      emit(
        SuccessState(
          data: AnalyticsScreenTracked(screenName: event.screenName),
        ),
      );
    } catch (error) {
      emit(
        FailureState(
          'Failed to track screen "${event.screenName}": $error',
        ),
      );
    }
  }

  Future<void> _onIdentifyUserRequested(
    IdentifyAnalyticsUserRequested event,
    Emitter<BaseState<AnalyticsBlocData>> emit,
  ) async {
    try {
      await _analyticsHandler.identify(event.user);
      emit(SuccessState(data: AnalyticsUserIdentified(user: event.user)));
    } catch (error) {
      emit(
        FailureState(
          'Failed to identify analytics user: $error',
        ),
      );
    }
  }

  Future<void> _onResetRequested(
    ResetAnalyticsRequested event,
    Emitter<BaseState<AnalyticsBlocData>> emit,
  ) async {
    emit(const ProcessingState('Resetting analytics...'));

    try {
      await _analyticsHandler.reset();
      emit(const SuccessState(data: AnalyticsResetCompleted()));
    } catch (error) {
      emit(FailureState('Failed to reset analytics: $error'));
    }
  }
}
