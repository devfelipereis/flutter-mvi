import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvi/mvi.dart';

// Test implementations
class TestState extends BaseState {
  const TestState({this.counter = 0});

  final int counter;

  TestState copyWith({int? counter}) {
    return TestState(counter: counter ?? this.counter);
  }
}

sealed class TestEvent extends BaseEvent {
  const TestEvent();
}

final class IncrementEvent extends TestEvent {
  const IncrementEvent();
}

sealed class TestEffect extends BaseEffect {
  const TestEffect();
}

final class MessageEffect extends TestEffect {
  const MessageEffect(this.message);
  final String message;
}

class TestViewModel extends ViewModel<TestState, TestEvent, TestEffect> {
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

  void emitTestEffect(String message) {
    addEffect(MessageEffect(message));
  }

  void triggerEffectError() {
    addEffectError(Exception('Test error'));
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({
    super.key,
    this.onEffectCallback,
    required this.viewModelCreator,
  });

  final void Function(TestEffect effect, BuildContext context)?
  onEffectCallback;
  final TestViewModel Function() viewModelCreator;

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
  final List<String> errors = [];

  @override
  TestViewModel provideViewModel() => widget.viewModelCreator();

  @override
  void onEffect(TestEffect effect, BuildContext context) {
    if (effect case MessageEffect effect) {
      widget.onEffectCallback?.call(effect, context);
    }
  }

  @override
  void onEffectError(Object error, StackTrace stackTrace) {
    // Call default implementation to verify it works... it contributes to the test coverage
    super.onEffectError(error, stackTrace);
    // Also capture error for test verification
    errors.add(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  group('ViewModelMixin', () {
    late TestViewModel testViewModel;

    setUp(() {
      testViewModel = TestViewModel();
    });

    tearDown(() {
      if (!testViewModel.isDisposed) {
        testViewModel.dispose();
      }
    });

    group('initialization', () {
      testWidgets('should initialize viewModel in initState', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => testViewModel)),
        );

        final state = tester.state<TestWidgetState>(find.byType(TestWidget));
        expect(state.viewModel, testViewModel);
        expect(state.viewModel.isDisposed, isFalse);
        expect(state.viewModel.initCalled, isTrue);
      });

      testWidgets('should dispose viewModel when widget is disposed', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => testViewModel)),
        );

        await tester.pumpWidget(const MaterialApp(home: Placeholder()));

        expect(testViewModel.isDisposed, isTrue);
        expect(testViewModel.disposeCalled, isTrue);
      });
    });

    group('effects', () {
      testWidgets('should handle effects from viewModel', (tester) async {
        final effectMessages = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              viewModelCreator: () => testViewModel,
              onEffectCallback: (effect, context) {
                if (effect case MessageEffect effect) {
                  effectMessages.add(effect.message);
                }
              },
            ),
          ),
        );

        testViewModel.emitTestEffect('Test effect 1');
        testViewModel.emitTestEffect('Test effect 2');

        await tester.pump();

        expect(effectMessages, ['Test effect 1', 'Test effect 2']);
      });

      testWidgets(
        'should handle effect stream errors with default implementation',
        (tester) async {
          // Temporarily redirect debug output to avoid cluttering test output
          final debugPrintOriginal = debugPrint;
          debugPrint = (String? message, {int? wrapWidth}) {};

          await tester.pumpWidget(
            MaterialApp(
              home: TestWidget(viewModelCreator: () => testViewModel),
            ),
          );

          final state = tester.state<TestWidgetState>(find.byType(TestWidget));
          testViewModel.triggerEffectError();
          await tester.pumpAndSettle();

          expect(state.errors.length, 1);
          expect(state.errors.first, contains('Test error'));
          // Restore original debug print
          debugPrint = debugPrintOriginal;
        },
      );

      testWidgets('should not process effects when widget is unmounted', (
        tester,
      ) async {
        final effectMessages = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              viewModelCreator: () => testViewModel,
              onEffectCallback: (effect, context) {
                if (effect case MessageEffect effect) {
                  effectMessages.add(effect.message);
                }
              },
            ),
          ),
        );

        await tester.pumpWidget(const MaterialApp(home: Placeholder()));

        expect(testViewModel.isDisposed, isTrue);
        expect(effectMessages, isEmpty);
      });
    });

    group('events', () {
      testWidgets('should forward events to viewModel', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => testViewModel)),
        );

        expect(testViewModel.eventHandled, isFalse);

        final state = tester.state<TestWidgetState>(find.byType(TestWidget));
        state.addEvent(const IncrementEvent());
        await tester.pumpAndSettle();

        expect(testViewModel.eventHandled, isTrue);
      });

      testWidgets('should not process events when widget is unmounted', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => testViewModel)),
        );

        final state = tester.state<TestWidgetState>(find.byType(TestWidget));

        await tester.pumpWidget(const MaterialApp(home: Placeholder()));
        await tester.pump();

        state.addEvent(const IncrementEvent());
        await tester.pump();

        expect(testViewModel.eventHandled, isFalse);
      });
    });

    group('state', () {
      testWidgets('should use state selector to observe part of state', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(home: TestWidget(viewModelCreator: () => testViewModel)),
        );

        final counterValue = testViewModel
            .select((state) => state.counter)
            .value;
        expect(counterValue, 0);

        testViewModel.updateState(const TestState(counter: 1));
        await tester.pump();

        expect(testViewModel.state.value.counter, 1);
        expect(testViewModel.select((state) => state.counter).value, 1);
      });
    });
  });
}
