<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

<p align="center">
<a href="https://github.com/devfelipereis/flutter-mvi/actions"><img src="https://github.com/devfelipereis/flutter-mvi/actions/workflows/test.yaml/badge.svg" alt="test"></a>
<a href="https://codecov.io/gh/devfelipereis/flutter-mvi" > 
 <img src="https://codecov.io/gh/devfelipereis/flutter-mvi/graph/badge.svg?token=8HF2PFOEQB"/> 
 </a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

# MVI - Model-View-Intent for Flutter

An implementation of the MVI (Model-View-Intent) pattern for Flutter that uses the `signals` package for managing state.

This package provides a basic structure to implement the MVI pattern in your Flutter projects, helping you to build reactive and predictable user interfaces.

## What is MVI?

MVI is a unidirectional data flow architecture pattern that helps in managing the state of your application in a more predictable way. It is composed of three main components:

-   **Model**: Represents the state of the application. It's an immutable object that holds all the data needed for the view.
-   **View**: The user interface (UI) that displays the state. In Flutter, this would be your widgets.
-   **Intent**: Represents an intention to change the state. These are usually triggered by user interactions with the UI.

## Core Concepts

This implementation is built around a few core components:

-   `BaseViewModel`: A class that holds the business logic. It receives intents, processes them, and emits new states.
-   `ViewModelMixin`: A mixin that can be used with a `StatefulWidget`'s `State` to automatically listen to state changes from a `BaseViewModel` and rebuild the UI.

## State Management with Signals

This MVI implementation uses the [signals](https://pub.dev/packages/signals) package to manage the state. The state of a `BaseViewModel` is a `Signal` that can be observed by the UI. When a new state is emitted, the UI is automatically rebuilt.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  mvi: ^1.0.0
```

Then, run `flutter pub get`.

## Usage

Check the example folder for a detailed implementation with tests.

**Note**: The architecture in this example is designed solely for simplicity and demonstration purposes.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.
