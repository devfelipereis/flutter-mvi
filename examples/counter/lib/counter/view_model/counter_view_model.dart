import 'package:counter/counter/view_model/counter_event.dart';
import 'package:counter/counter/view_model/counter_state.dart';
import 'package:mvi/mvi.dart';

export 'counter_event.dart';
export 'counter_state.dart';

final class CounterViewModel
    extends SimpleViewModel<CounterState, CounterEvent> {
  CounterViewModel()
    : super(const CounterState(), debugLabel: 'CounterViewModel');

  @override
  void onEvent(CounterEvent event) => switch (event) {
    Increment() => _onIncrement(),
    Decrement() => _onDecrement(),
  };

  void _onIncrement() {
    final currentState = state.value;
    updateState(currentState.copyWith(count: currentState.count + 1));
  }

  void _onDecrement() {
    final currentState = state.value;
    updateState(currentState.copyWith(count: currentState.count - 1));
  }
}
