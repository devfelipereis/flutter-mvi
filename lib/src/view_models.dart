import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'mvi_base.dart';

/// Base interface for all ViewModels.
abstract interface class BaseViewModel<
  S extends BaseState,
  E extends BaseEvent
> {
  ValueListenable<S> get state;
  ValueListenable<R> select<R>(
    R Function(S state) selector, {
    String? debugLabel,
  });
  void addEvent(E event);
  bool get isDisposed;
  void dispose();
}

/// Simple ViewModel without effects for basic state management.
/// Implements the MV (Model-View) pattern with unidirectional data flow:
/// - Model: State represents the UI state at any point in time
/// - View: UI observes the state and renders accordingly
///
/// Generic parameters:
/// - S: The state type that extends [BaseState] (Model)
/// - E: The event type that extends [BaseEvent] (Intent)
abstract class SimpleViewModel<S extends BaseState, E extends BaseEvent>
    implements BaseViewModel<S, E> {
  /// Creates a new SimpleViewModel with the given [initialState].
  /// If [debugLabel] is not null, it will be used to log information about the ViewModel.
  SimpleViewModel(S initialState, {String? debugLabel})
    : _state = ValueNotifier(initialState),
      _debugLabel = debugLabel {
    _eventsSubscription = _events.stream.listen(onEvent);

    if (_debugLabel != null) {
      log('$_debugLabel: Created');
    }

    onInit();
  }

  /// Debug label for logging purposes.
  final String? _debugLabel;

  /// Debug label for logging purposes.
  @protected
  String? get debugLabel => _debugLabel;

  /// Whether this ViewModel has been disposed.
  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  /// The internal state holder that manages the reactive state.
  late final ValueNotifier<S> _state;

  /// Keeps track of all created selectors to ensure they're disposed.
  final _selectors = <_DerivedValueListenable<S, dynamic>>[];

  /// The public read-only state that UI components (View) can observe.
  @override
  ValueListenable<S> get state => _state;

  /// Creates a ValueListenable that computes a value from the current state.
  /// Use this to observe specific parts of the state.
  /// The selector function will be called whenever the state changes.
  @override
  ValueListenable<R> select<R>(
    R Function(S state) selector, {
    String? debugLabel,
  }) {
    if (_isDisposed) {
      throw StateError('Cannot select from a disposed ViewModel');
    }

    final derived = _DerivedValueListenable<S, R>(
      _state,
      selector,
      debugLabel: '$_debugLabel ($debugLabel)',
    );

    _selectors.add(derived);

    return derived;
  }

  /// Stream controller for events (Intents) dispatched to this ViewModel.
  final _events = StreamController<E>();

  /// Subscription to the events stream.
  late final StreamSubscription<E> _eventsSubscription;

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

    if (_debugLabel != null && _state.value != newState) {
      log('$_debugLabel: Previous State => ${_state.value}');
      log('$_debugLabel: Current State => $newState');
    }

    _state.value = newState;
  }

  /// Dispatches an event (Intent) to this ViewModel.
  /// The event will be processed by [onEvent].
  @override
  void addEvent(E event) {
    if (_isDisposed) {
      throw StateError('Cannot add event to a disposed ViewModel');
    }

    if (_debugLabel != null) {
      log('$_debugLabel: Event => $event');
    }

    _events.add(event);
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

  /// Disposes the ViewModel, releasing all resources.
  /// This cancels all subscriptions and closes all streams.
  @override
  void dispose() {
    onDispose();

    // Dispose all created selectors
    for (final selector in _selectors) {
      selector.dispose();
    }
    _selectors.clear();

    _state.dispose();
    _eventsSubscription.cancel();
    _events.close();
    _isDisposed = true;

    if (_debugLabel != null) {
      log('$_debugLabel: Disposed');
    }
  }
}

/// Full-featured ViewModel with effects for complex state management.
/// Extends SimpleViewModel and adds effects support for the full MVI pattern.
///
/// Generic parameters:
/// - S: The state type that extends [BaseState] (Model)
/// - E: The event type that extends [BaseEvent] (Intent)
/// - F: The effect type that extends [BaseEffect] (Side Effects)
abstract class ViewModel<
  S extends BaseState,
  E extends BaseEvent,
  F extends BaseEffect
>
    extends SimpleViewModel<S, E> {
  /// Creates a new ViewModel with the given [initialState].
  /// If [debugLabel] is not null, it will be used to log information about the ViewModel.
  ViewModel(super.initialState, {super.debugLabel});

  /// Stream controller for effects emitted by this ViewModel.
  final _effects = StreamController<F>();

  /// Public stream of effects that UI components can listen to.
  late final Stream<F> effects = _effects.stream;

  /// Emits an effect from this ViewModel.
  /// Effects are one-time occurrences like navigation or showing dialogs
  /// that don't affect the state but trigger UI actions.
  @protected
  void addEffect(F effect) {
    if (isDisposed) {
      throw StateError('Cannot add effect to a disposed ViewModel');
    }

    if (debugLabel != null) {
      log('$debugLabel: Effect => $effect');
    }

    _effects.add(effect);
  }

  /// Adds an error to the effect stream. This is only used for testing.
  @protected
  @visibleForTesting
  void addEffectError(Object error) {
    _effects.addError(error);
  }

  /// Disposes the ViewModel, releasing all resources.
  /// This cancels all subscriptions and closes all streams.
  @override
  void dispose() {
    _effects.close();
    super.dispose();
  }
}

/// A ValueListenable that derives its value from another Listenable using a selector function.
class _DerivedValueListenable<S, R> extends ValueNotifier<R> {
  _DerivedValueListenable(this._source, this._selector, {String? debugLabel})
    : _debugLabel = debugLabel,
      super(_selector(_source.value)) {
    _source.addListener(_onSourceChanged);
    log('$_debugLabel: Created');
  }

  final ValueNotifier<S> _source;
  final R Function(S) _selector;
  final String? _debugLabel;

  void _onSourceChanged() {
    final newValue = _selector(_source.value);
    if (_debugLabel != null && value != newValue) {
      log('$_debugLabel: Previous State => $value');
      log('$_debugLabel: Current State => $newValue');
    }
    value = newValue;
  }

  @override
  void dispose() {
    _source.removeListener(_onSourceChanged);
    super.dispose();
    if (_debugLabel != null) {
      log('$_debugLabel: Disposed');
    }
  }
}
