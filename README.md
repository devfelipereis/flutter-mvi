<p align="center">
  <a href="https://pub.dev/packages/mvi">
    <img alt="Pub Version" src="https://img.shields.io/pub/v/mvi">
  </a>
  <a href="https://github.com/devfelipereis/flutter-mvi/actions">
    <img src="https://github.com/devfelipereis/flutter-mvi/actions/workflows/test.yaml/badge.svg" alt="test">
  </a>
  <a href="https://codecov.io/gh/devfelipereis/flutter-mvi" > 
    <img src="https://codecov.io/gh/devfelipereis/flutter-mvi/graph/badge.svg"/> 
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT">
  </a>
</p>

# MVI - Model-View-Intent for Flutter

A clean and efficient implementation of the MVI (Model-View-Intent) pattern for Flutter using ValueListenable for reactive state management.

This package provides a robust architecture to implement the MVI pattern in your Flutter projects, helping you build reactive, predictable, and testable user interfaces.

## What is MVI?

MVI is a unidirectional data flow architecture pattern that helps manage application state predictably. It consists of three main components:

-   **Model**: Represents the state of the application. It's an immutable object that holds all the data needed for the view.
-   **View**: The user interface (UI) that displays the state. In Flutter, this would be your widgets.
-   **Intent**: Represents an intention to change the state. These are usually triggered by user interactions with the UI.

Additionally, this implementation supports **Effects** for handling one-time side effects like navigation, showing snackbars, or other UI actions that don't affect state.

## Core Components

### Base Classes

-   **`BaseState`**: Abstract base class for all state objects. States should be immutable.
-   **`BaseEvent`**: Abstract base class for all events (intents) that can trigger state changes.
-   **`BaseEffect`**: Abstract base class for all effects (one-time side effects).

### ViewModels

-   **`SimpleViewModel`**: For state management without effects.
-   **`ViewModel`**: For state management with effects support.

### Mixins

-   **`SimpleViewModelMixin`**: Mixin for connecting widgets to SimpleViewModels.
-   **`ViewModelMixin`**: Mixin for connecting widgets to ViewModels with effects support.

## State Management with ValueListenable

This MVI implementation uses Flutter's built-in `ValueListenable` and `ValueNotifier` for reactive state management. The state is observable and automatically triggers UI rebuilds when changed.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  mvi: ^2.0.0
```

Then, run `flutter pub get`.

## Example

Check the examples folder for complete implementations and tests:

- [`examples/counter/`](examples/counter/) - Simple counter app demonstrating basic MVI pattern
- [`examples/login_posts_list/`](examples/login_posts_list/) - Complete app with login flow and data fetching

## Features

- ✅ **Reactive State Management**: Built on Flutter's ValueListenable
- ✅ **Effects Support**: Handle side effects like navigation and dialogs
- ✅ **Performance Optimized**: Selectors prevent unnecessary rebuilds
- ✅ **Debug Support**: Built-in logging for development
- ✅ **Testable**: Easy to unit test ViewModels and business logic

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.
