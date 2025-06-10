import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

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

/// Abstract base class for all ViewModels in the application.
/// Implements the MVI (Model-View-Intent) pattern with unidirectional data flow:
/// - Intent: User actions are captured as Events
/// - Model: State represents the UI state at any point in time
/// - View: UI observes the state and renders accordingly
///
/// Generic parameters:
/// - S: The state type that extends [BaseState] (Model)
/// - E: The event type that extends [BaseEvent] (Intent)
/// - F: The effect type that extends [BaseEffect] (Side Effects)
abstract class BaseViewModel<
  S extends BaseState,
  E extends BaseEvent,
  F extends BaseEffect
> {
  /// Creates a new ViewModel with the given [initialState].
  /// Initializes the event stream and calls [onInit].
  BaseViewModel(S initialState) : _state = Signal(initialState) {
    _eventsSubscription = _events.stream.listen(onEvent);
    onInit();
  }

  /// Whether this ViewModel has been disposed.
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  /// The internal mutable state signal.
  late final Signal<S> _state;

  /// The public read-only state signal that UI components (View) can observe.
  ReadonlySignal<S> get state => _state.readonly();

  /// Creates a derived signal that computes a value from the current state.
  /// Use this to observe specific parts of the state.
  ReadonlySignal<R> select<R>(R Function(S state) selector) {
    return computed(() => selector(_state.value));
  }

  /// Stream controller for events (Intents) dispatched to this ViewModel.
  final _events = StreamController<E>();
  late final StreamSubscription<E> _eventsSubscription;

  /// Stream controller for effects emitted by this ViewModel.
  final _effects = StreamController<F>();

  /// Public stream of effects that UI components can listen to.
  late final Stream<F> effects = _effects.stream;

  /// Handle an event (Intent) dispatched to this ViewModel.
  /// Subclasses must implement this method to process events and update state.
  /// This is where the business logic resides that transforms intents into state changes.
  @protected
  void onEvent(E event);

  /// Updates the state (Model) of this ViewModel.
  /// Throws an error if the ViewModel has been disposed.
  @protected
  // ignore: use_setters_to_change_properties
  @visibleForTesting
  void updateState(S newState) {
    if (_isDisposed) {
      throw StateError('Cannot update state of a disposed ViewModel');
    }
    _state.value = newState;
  }

  /// Dispatches an event (Intent) to this ViewModel.
  /// The event will be processed by [onEvent].
  void addEvent(E event) {
    if (_isDisposed) {
      throw StateError('Cannot add event to a disposed ViewModel');
    }
    _events.add(event);
  }

  /// Emits an effect from this ViewModel.
  /// Effects are one-time occurrences like navigation or showing dialogs
  /// that don't affect the state but trigger UI actions.
  @protected
  void addEffect(F effect) {
    if (_isDisposed) {
      throw StateError('Cannot add effect to a disposed ViewModel');
    }
    _effects.add(effect);
  }

  /// Called when the ViewModel is initialized.
  /// Override this method to perform initialization logic.
  @protected
  void onInit() {
    // Override this method for initialization logic
  }

  /// Called when the ViewModel is about to be disposed.
  /// Override this method to perform cleanup logic.
  @protected
  void onDispose() {
    // Override this method for cleanup logic
  }

  /// Adds an error to the effect stream. This is only used for testing.
  @protected
  @visibleForTesting
  void addEffectError(Object error) {
    _effects.addError(error);
  }

  /// Disposes the ViewModel, releasing all resources.
  /// This cancels all subscriptions and closes all streams.
  void dispose() {
    onDispose();
    _state.dispose();
    _eventsSubscription.cancel();
    _events.close();
    _effects.close();
    _isDisposed = true;
  }
}
