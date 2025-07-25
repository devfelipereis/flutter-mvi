import 'dart:async';

import 'package:flutter/material.dart';
import 'mvi_base.dart';
import 'view_models.dart';

/// A mixin that implements the View part of the MVI pattern for StatefulWidget classes.
///
/// This mixin handles the connection between a Flutter widget and its ViewModel,
/// automatically subscribing to state changes and effect streams.
///
/// Generic parameters:
/// - T: The StatefulWidget type this mixin is applied to
/// - S: The state type that extends BaseState
/// - E: The event type that extends BaseEvent
/// - F: The effect type that extends BaseEffect
/// - VM: The ViewModel type that extends BaseViewModel
mixin ViewModelMixin<
  T extends StatefulWidget,
  S extends BaseState,
  E extends BaseEvent,
  F extends BaseEffect,
  VM extends ViewModel<S, E, F>
>
    on State<T> {
  /// The ViewModel instance that manages state and business logic
  late final VM viewModel;

  /// Subscription to the effects stream from the ViewModel
  late final StreamSubscription<F> _effectSubscription;

  /// Override this method to provide a ViewModel instance for this widget
  ///
  /// This is where you should initialize and return your ViewModel
  @protected
  VM provideViewModel();

  /// Override this method to handle effects (side effects) from the ViewModel
  ///
  /// Effects are one-time events that don't affect state, such as navigation,
  /// showing snackbars, or other UI actions
  @protected // coverage:ignore-line
  void onEffect(F effect, BuildContext context) {}

  /// Override this method to handle errors in the effect stream
  ///
  /// By default, errors are logged to the console
  @protected // coverage:ignore-line
  void onEffectError(Object error, StackTrace stackTrace) {
    debugPrint('Error in effect stream: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel
    viewModel = provideViewModel();
    // Subscribe to the effects stream
    _effectSubscription = viewModel.effects.listen(
      (effect) {
        if (!mounted) return;
        onEffect(effect, context);
      },
      onError: (dynamic error, StackTrace stackTrace) {
        onEffectError(error as Object, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    // Clean up resources when the widget is disposed
    _effectSubscription.cancel();
    viewModel.dispose();
    super.dispose();
  }

  /// Dispatches an event to the ViewModel
  ///
  /// Use this method to send user actions or other events to the ViewModel
  /// for processing. The ViewModel will update its state in response.
  void addEvent(E event) {
    if (!mounted || viewModel.isDisposed) return;
    viewModel.addEvent(event);
  }
}

/// A mixin that implements the View part of the MV pattern for StatefulWidget classes.
///
/// This mixin handles the connection between a Flutter widget and its SimpleViewModel,
/// automatically subscribing to state changes. Use this for simple state management without effects.
///
/// Generic parameters:
/// - T: The StatefulWidget type this mixin is applied to
/// - S: The state type that extends BaseState
/// - E: The event type that extends BaseEvent
/// - VM: The SimpleViewModel type that extends SimpleViewModel
mixin SimpleViewModelMixin<
  T extends StatefulWidget,
  S extends BaseState,
  E extends BaseEvent,
  VM extends SimpleViewModel<S, E>
>
    on State<T> {
  /// The ViewModel instance that manages state and business logic
  late final VM viewModel;

  /// Override this method to provide a ViewModel instance for this widget
  ///
  /// This is where you should initialize and return your ViewModel
  @protected
  VM provideViewModel();

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel
    viewModel = provideViewModel();
  }

  @override
  void dispose() {
    // Clean up resources when the widget is disposed
    viewModel.dispose();
    super.dispose();
  }

  /// Dispatches an event to the ViewModel
  ///
  /// Use this method to send user actions or other events to the ViewModel
  /// for processing. The ViewModel will update its state in response.
  void addEvent(E event) {
    if (!mounted || viewModel.isDisposed) return;
    viewModel.addEvent(event);
  }
}
