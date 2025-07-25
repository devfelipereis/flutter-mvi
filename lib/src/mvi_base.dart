/// Base class for all state objects in the application.
/// States should be immutable and contain all the data needed to render a UI.
/// In MVI, the state represents the Model component.
abstract class BaseState {
  const BaseState();

  /// Cast this state to a specific type.
  T cast<T extends BaseState>() => this as T;
}

/// Base class for all events that can be dispatched to the ViewModel.
/// Events represent user actions or system events that should trigger state changes.
/// In MVI, events are Intents that express the user's intention.
abstract class BaseEvent {
  const BaseEvent();
}

/// Base class for all effects that can be emitted by the ViewModel.
/// Effects represent one-time side effects like navigation, showing a snackbar, etc.
/// These are part of the MVI pattern for handling UI actions that don't affect state.
abstract class BaseEffect {
  const BaseEffect();
}