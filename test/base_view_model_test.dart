import 'package:flutter_test/flutter_test.dart';
import 'package:mvi/mvi.dart';

// Test implementation of BaseViewModel
class TestState extends BaseState {
  const TestState({this.value = 0});
  final int value;

  TestState copyWith({int? value}) {
    return TestState(value: value ?? this.value);
  }
}

sealed class TestEvent extends BaseEvent {}

final class IncrementEvent extends TestEvent {}

final class DecrementEvent extends TestEvent {}

sealed class TestEffect extends BaseEffect {}

final class CounterEffect extends TestEffect {
  CounterEffect(this.message);
  final String message;
}

class TestViewModel extends BaseViewModel<TestState, TestEvent, TestEffect> {
  TestViewModel() : super(const TestState());

  bool initCalled = false;
  bool disposeCalled = false;

  @override
  void onInit() {
    super.onInit();
    initCalled = true;
  }

  @override
  void onDispose() {
    super.onDispose();
    disposeCalled = true;
  }

  @override
  void onEvent(TestEvent event) => switch (event) {
    IncrementEvent() => _onIncrement(),
    DecrementEvent() => _onDecrement(),
  };

  void _onIncrement() {
    updateState(state.value.copyWith(value: state.value.value + 1));
    addEffect(CounterEffect('Incremented'));
  }

  void _onDecrement() {
    updateState(state.value.copyWith(value: state.value.value - 1));
    addEffect(CounterEffect('Decremented'));
  }

  void increment() {
    addEvent(IncrementEvent());
  }

  void decrement() {
    addEvent(DecrementEvent());
  }

  void emitEffect(String message) {
    addEffect(CounterEffect(message));
  }
}

class _TestState extends BaseState {
  const _TestState();
}

class _AnotherState extends TestState {
  const _AnotherState();
}

void main() {
  group('BaseState', () {
    test('should cast state to a specific type', () {
      // just to simulate receiving a base state class
      const BaseState state = _TestState();
      final castedState = state.cast<_TestState>();
      expect(castedState, isA<_TestState>());
    });

    test('should throw an error when casting to a wrong type', () {
      const state = _TestState();
      expect(() => state.cast<_AnotherState>(), throwsA(isA<TypeError>()));
    });
  });

  group('BaseViewModel', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should initialize with the provided initial state', () {
      const initialState = TestState();
      final viewModel = TestViewModel();

      final state = viewModel.state.value;

      expect(state.value, equals(initialState.value));
      expect(viewModel.initCalled, isTrue);
    });

    test('should update state when an event is processed', () async {
      viewModel.increment();

      await pumpEventQueue();

      final state = viewModel.state.value;
      expect(state.value, equals(1));

      viewModel.decrement();
      await pumpEventQueue();

      final newState = viewModel.state.value;
      expect(newState.value, equals(0));
    });

    test('should emit effects', () async {
      final effectMessages = <String>[];

      viewModel.effects.listen((effect) {
        switch (effect) {
          case CounterEffect():
            effectMessages.add(effect.message);
        }
      });

      viewModel.emitEffect('Test effect');
      await pumpEventQueue();

      viewModel.increment();
      await pumpEventQueue();

      expect(effectMessages, ['Test effect', 'Incremented']);
    });

    test('should allow state observation through selectors', () async {
      final valueSelector = viewModel.select((state) => state.value);

      expect(valueSelector.value, equals(0));

      viewModel.increment();
      await pumpEventQueue();

      expect(valueSelector.value, equals(1));
    });

    test('should call onDispose when disposed', () {
      viewModel.dispose();

      expect(viewModel.isDisposed, isTrue);
      expect(viewModel.disposeCalled, isTrue);
    });

    test('should not process events after disposal', () {
      viewModel.dispose();

      // should throw since stream is closed
      expect(() => viewModel.addEvent(IncrementEvent()), throwsStateError);
    });

    test('should not allow adding effects after disposal', () {
      viewModel.dispose();

      // should throw since stream is closed
      expect(() => viewModel.emitEffect('Test effect'), throwsStateError);
    });

    test('should not allow updating state after disposal', () {
      viewModel.dispose();

      // should throw since ViewModel is disposed
      expect(
        () => viewModel.updateState(const TestState(value: 1)),
        throwsStateError,
      );
    });
  });
}
