import 'package:equatable/equatable.dart';
import 'package:mvi/mvi.dart';

final class CounterState extends BaseState with EquatableMixin {
  const CounterState({this.count = 0});

  final int count;

  CounterState copyWith({int? count}) =>
      CounterState(count: count ?? this.count);

  @override
  List<Object?> get props => [count];

  @override
  String toString() => 'CounterState(count: $count)';
}
