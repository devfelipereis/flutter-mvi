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

class IncrementEvent extends BaseEvent {
  const IncrementEvent();
}

class DecrementEvent extends BaseEvent {
  const DecrementEvent();
}

class TestEffect extends BaseEffect {
  const TestEffect(this.message);
  final String message;
}

class TestViewModel extends BaseViewModel<TestState, BaseEvent, TestEffect> {
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
  void onEvent(BaseEvent event) {
    if (event is IncrementEvent) {
      updateState(state.value.copyWith(value: state.value.value + 1));
      addEffect(const TestEffect('Incremented'));
    } else if (event is DecrementEvent) {
      updateState(state.value.copyWith(value: state.value.value - 1));
      addEffect(const TestEffect('Decremented'));
    }
  }

  void increment() {
    addEvent(const IncrementEvent());
  }

  void decrement() {
    addEvent(const DecrementEvent());
  }

  void emitEffect(String message) {
    addEffect(TestEffect(message));
  }
}

// Helper for the tests to await async event processing
Future<void> pumpEventQueue() async {
  await Future.delayed(Duration.zero);
}

void main() {
  group('BaseViewModel', () {
    late TestViewModel viewModel;

    setUp(() {
      viewModel = TestViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should initialize with the provided initial state', () {
      // Given
      const initialState = TestState();
      final viewModel = TestViewModel();

      // Then
      final state = viewModel.state.value;

      expect(state.value, equals(initialState.value));
      expect(viewModel.initCalled, isTrue);
    });

    test('should update state when an event is processed', () async {
      // When
      viewModel.increment();

      // Allow the event to be processed
      await pumpEventQueue();

      // Then
      final state = viewModel.state.value;
      expect(state.value, equals(1));

      // When
      viewModel.decrement();
      await pumpEventQueue();

      // Then
      final newState = viewModel.state.value;
      expect(newState.value, equals(0));
    });

    test('should emit effects', () async {
      // Given
      final effectMessages = <String>[];
      viewModel.effects.listen((effect) {
        effectMessages.add(effect.message);
      });

      // When
      viewModel.emitEffect('Test effect');
      await pumpEventQueue();

      viewModel.increment();
      await pumpEventQueue();

      // Then
      expect(effectMessages, ['Test effect', 'Incremented']);
    });

    test('should allow state observation through selectors', () async {
      // Given
      final valueSelector = viewModel.select((state) => state.value);

      // Then
      expect(valueSelector.value, equals(0));

      // When
      viewModel.increment();
      await pumpEventQueue();

      // Then
      expect(valueSelector.value, equals(1));
    });

    test('should call onDispose when disposed', () {
      // When
      viewModel.dispose();

      // Then
      expect(viewModel.isDisposed, isTrue);
      expect(viewModel.disposeCalled, isTrue);
    });

    test('should not process events after disposal', () {
      // Given
      viewModel.dispose();

      // When/Then - should throw since stream is closed
      expect(
        () => viewModel.addEvent(const IncrementEvent()),
        throwsStateError,
      );
    });
  });
}
