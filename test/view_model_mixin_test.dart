import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvi/mvi.dart';

// Test implementation of the necessary components
class TestState extends BaseState {
  const TestState({this.counter = 0});
  final int counter;

  TestState copyWith({int? counter}) {
    return TestState(counter: counter ?? this.counter);
  }
}

class TestEvent extends BaseEvent {
  const TestEvent();
}

class IncrementEvent extends TestEvent {
  const IncrementEvent();
}

class TestEffect extends BaseEffect {
  const TestEffect({required this.message});
  final String message;
}

class TestViewModel extends BaseViewModel<TestState, TestEvent, TestEffect> {
  TestViewModel() : super(const TestState());

  bool eventHandled = false;
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
  void onEvent(TestEvent event) {
    eventHandled = true;
    addEffect(const TestEffect(message: 'Effect triggered'));

    if (event is IncrementEvent) {
      updateState(currentState.copyWith(counter: currentState.counter + 1));
    }
  }

  void triggerEffect(String message) {
    addEffect(TestEffect(message: message));
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key, this.onEffectCallback, this.viewModelCreator});

  final void Function(TestEffect effect, BuildContext context)?
  onEffectCallback;
  final ViewModelCreator<TestState, TestEvent, TestEffect, TestViewModel>?
  viewModelCreator;

  @override
  TestWidgetState createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget>
    with
        ViewModelMixin<
          TestWidget,
          TestState,
          TestEvent,
          TestEffect,
          TestViewModel
        > {
  final List<TestEffect> effects = [];

  @override
  TestViewModel provideViewModel() {
    return widget.viewModelCreator != null
        ? createViewModel(widget.viewModelCreator!)
        : TestViewModel();
  }

  @override
  void onEffect(TestEffect effect, BuildContext context) {
    super.onEffect(effect, context);
    effects.add(effect);
    widget.onEffectCallback?.call(effect, context);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Helper for the tests to await async event processing
Future<void> pumpEventQueue() async {
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
}

void main() {
  group('ViewModelMixin', () {
    testWidgets('should initialize viewModel in initState', (tester) async {
      // When
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));

      // Then
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.viewModel, isNotNull);
      expect(state.viewModel.isDisposed, isFalse);
      expect(state.viewModel.initCalled, isTrue);
    });

    testWidgets('should dispose viewModel when widget is disposed', (
      tester,
    ) async {
      // Given
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      final viewModel = state.viewModel;

      // When
      await tester.pumpWidget(const MaterialApp(home: Placeholder()));

      // Then
      expect(viewModel.isDisposed, isTrue);
      expect(viewModel.disposeCalled, isTrue);
    });

    testWidgets('should handle effects from viewModel', (tester) async {
      // Given
      final effectMessages = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            onEffectCallback: (effect, context) {
              effectMessages.add(effect.message);
            },
          ),
        ),
      );
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // When
      state.viewModel.triggerEffect('Test effect 1');
      state.viewModel.triggerEffect('Test effect 2');
      await tester.pump();

      // Then
      expect(effectMessages, ['Test effect 1', 'Test effect 2']);
    });

    testWidgets('should forward events to viewModel', (tester) async {
      // Given
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.viewModel.eventHandled, isFalse);

      // When
      state.addEvent(const TestEvent());
      await tester.pumpAndSettle();

      // Then
      expect(state.viewModel.eventHandled, isTrue);
    });

    testWidgets('should not forward events when widget is unmounted', (
      tester,
    ) async {
      // Given
      final viewModel = TestViewModel();

      // Mount the widget
      await tester.pumpWidget(
        MaterialApp(home: TestWidget(viewModelCreator: () => viewModel)),
      );

      // When - unmount the widget
      await tester.pumpWidget(const MaterialApp(home: Placeholder()));
      await tester.pumpAndSettle();

      // Then - viewModel should be disposed
      expect(viewModel.isDisposed, isTrue);

      // When/Then - adding an event should throw
      expect(() => viewModel.addEvent(const TestEvent()), throwsStateError);
    });

    testWidgets('should use state selector to observe part of state', (
      tester,
    ) async {
      // Given
      final viewModel = TestViewModel();
      await tester.pumpWidget(
        MaterialApp(home: TestWidget(viewModelCreator: () => viewModel)),
      );

      final counterValue = viewModel.select((state) => state.counter).value;
      expect(counterValue, 0);

      // When - Update the state directly to bypass event handling
      viewModel.updateState(const TestState(counter: 1));
      await tester.pump();

      // Then
      expect(viewModel.currentState.counter, 1);
      expect(viewModel.select((state) => state.counter).value, 1);
    });

    testWidgets('should expose current state via getter', (tester) async {
      // Given
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      // Then
      expect(state.currentState, isA<TestState>());
      expect(state.currentState.counter, 0);
    });
  });
}
