## 2.0.0

**🚨 BREAKING CHANGES - Complete Architecture Rewrite**

This is a major rewrite of the MVI package with significant breaking changes.

### New Architecture

* **Replaced signals with ValueListenable**: Now uses Flutter's built-in ValueListenable and ValueNotifier for reactive state management
* **Dual ViewModel approach**: 
  - `SimpleViewModel` for basic state management without effects
  - `ViewModel` for full MVI pattern with effects support
* **New mixins**: 
  - `SimpleViewModelMixin` for connecting widgets to SimpleViewModels
  - `ViewModelMixin` for connecting widgets to ViewModels with effects
* **Method rename**: `provideViewModel()` renamed to `createViewModel()` for better clarity

### Migration Guide

This version is not backward compatible. To migrate:

1. Replace `BaseViewModel` with either `SimpleViewModel` or `ViewModel`
2. Update your mixins to use `SimpleViewModelMixin` or `ViewModelMixin`
3. Rename `provideViewModel()` to `createViewModel()`
4. Replace signals-based state observation with ValueListenableBuilder

### Examples

* Added complete counter example demonstrating basic MVI pattern
* Updated login/posts example with new architecture

## 1.0.6

* Log information about the ViewModel when debugLabel is not null

## 1.0.5

* Simplify code

## 1.0.4

* Add debugLabel property to the view model
* Add debugLabel parameter support to the select method
* Improve the example

## 1.0.3

* Use signals_flutter instead of signals as dependency
* Export Watch from signals_flutter

## 1.0.2

* Add cast method to BaseState

## 1.0.1

* Refactor some code and add more tests.

## 1.0.0

* Initial release.
