import 'package:mvi/mvi.dart';

sealed class CounterEvent extends BaseEvent {}

final class Increment extends CounterEvent {
  @override
  String toString() => 'Increment';
}

final class Decrement extends CounterEvent {
  @override
  String toString() => 'Decrement';
}
