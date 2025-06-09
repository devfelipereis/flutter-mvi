import 'base_view_model.dart';

/// A function type that creates and returns a new ViewModel instance.
///
/// Generic parameters:
/// - S: The state type that extends BaseState
/// - E: The event type that extends BaseEvent
/// - F: The effect type that extends BaseEffect
/// - VM: The ViewModel type that extends BaseViewModel
typedef ViewModelCreator<
  S extends BaseState,
  E extends BaseEvent,
  F extends BaseEffect,
  VM extends BaseViewModel<S, E, F>
> = VM Function();
