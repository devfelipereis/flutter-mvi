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

    if (event is IncrementEvent) {
      updateState(state.value.copyWith(counter: state.value.counter + 1));
    }
  }

  void triggerEffect(String message) {
    addEffect(TestEffect(message: message));
  }

  void triggerEffectError() {
    addEffectError(Exception('Test error'));
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
  final List<String> errors = [];

  @override
  TestViewModel provideViewModel() {
    return widget.viewModelCreator?.call() ?? TestViewModel();
  }

  @override
  void onEffect(TestEffect effect, BuildContext context) {
    super.onEffect(effect, context);
    effects.add(effect);
    widget.onEffectCallback?.call(effect, context);
  }

  @override
  void onEffectError(Object error, StackTrace stackTrace) {
    errors.add(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  group('ViewModelMixin', () {
    testWidgets('should initialize viewModel in initState', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.viewModel, isNotNull);
      expect(state.viewModel.isDisposed, isFalse);
      expect(state.viewModel.initCalled, isTrue);
    });

    testWidgets('should dispose viewModel when widget is disposed', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      final viewModel = state.viewModel;

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));

      expect(viewModel.isDisposed, isTrue);
      expect(viewModel.disposeCalled, isTrue);
    });

    testWidgets('should handle effects from viewModel', (tester) async {
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

      state.viewModel.triggerEffect('Test effect 1');
      state.viewModel.triggerEffect('Test effect 2');
      await tester.pump();

      expect(effectMessages, ['Test effect 1', 'Test effect 2']);
    });

    testWidgets('should forward events to viewModel', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      expect(state.viewModel.eventHandled, isFalse);

      state.addEvent(const TestEvent());
      await tester.pumpAndSettle();

      expect(state.viewModel.eventHandled, isTrue);
    });

    testWidgets('should not forward events when widget is unmounted', (
      tester,
    ) async {
      final viewModel = TestViewModel();

      await tester.pumpWidget(
        MaterialApp(home: TestWidget(viewModelCreator: () => viewModel)),
      );

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));
      await tester.pumpAndSettle();

      expect(viewModel.isDisposed, isTrue);
      expect(() => viewModel.addEvent(const TestEvent()), throwsStateError);
    });

    testWidgets('should use state selector to observe part of state', (
      tester,
    ) async {
      final viewModel = TestViewModel();
      await tester.pumpWidget(
        MaterialApp(home: TestWidget(viewModelCreator: () => viewModel)),
      );

      final counterValue = viewModel.select((state) => state.counter).value;
      expect(counterValue, 0);

      viewModel.updateState(const TestState(counter: 1));
      await tester.pump();

      expect(viewModel.state.value.counter, 1);
      expect(viewModel.select((state) => state.counter).value, 1);
    });

    testWidgets('should expose current state via getter', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestWidgetState>(find.byType(TestWidget));

      expect(state.viewModel.state.value, isA<TestState>());
      expect(state.viewModel.state.value.counter, 0);
    });

    testWidgets('should handle effect stream errors gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TestWidget()));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      state.viewModel.triggerEffectError();
      await tester.pumpAndSettle();

      expect(state.errors.length, 1);
      expect(state.errors.first, contains('Test error'));
    });

    testWidgets('should use default error handler if not overridden', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TestWidget()));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      state.viewModel.triggerEffectError();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('should not allow adding effect errors to disposed viewModel', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: TestWidget()));

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      final viewModel = state.viewModel;
      viewModel.dispose();

      expect(
        () => viewModel.triggerEffectError(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot add effect error to a disposed ViewModel',
          ),
        ),
      );
    });

    testWidgets('should not process effects when widget is not mounted', (
      tester,
    ) async {
      final effectsProcessed = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            onEffectCallback: (effect, context) {
              effectsProcessed.add(effect.message);
            },
          ),
        ),
      );

      final state = tester.state<TestWidgetState>(find.byType(TestWidget));
      final viewModel = state.viewModel;

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));

      expect(viewModel.isDisposed, isTrue);
      expect(effectsProcessed, isEmpty);
    });

    testWidgets(
      'should not process events when viewModel is disposed but widget is mounted',
      (tester) async {
        final viewModel = TestViewModel();

        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => viewModel)),
        );

        final state = tester.state<TestWidgetState>(find.byType(TestWidget));
        viewModel.dispose();
        state.addEvent(const TestEvent());
        await tester.pump();

        expect(viewModel.eventHandled, isFalse);
      },
    );
  });
}
