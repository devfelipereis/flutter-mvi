# Counter MVI Example

A simple counter app demonstrating the MVI pattern using the `mvi` package.

## Features

- Increment and decrement counter
- Uses `SimpleViewModel` for basic state management without effects
- Demonstrates the MVI pattern with clean separation of concerns

## Structure

```
lib/
├── counter/
│   ├── view_model/
│   │   ├── counter_state.dart      # State definition
│   │   ├── counter_event.dart      # Events (Increment/Decrement)
│   │   └── counter_view_model.dart # Business logic
│   └── counter_page.dart           # UI implementation
└── main.dart                       # App entry point
```

## Key Components

- **CounterState**: Holds the counter value
- **CounterEvent**: Defines increment and decrement actions
- **CounterViewModel**: Handles business logic and state updates
- **CounterPage**: UI that connects to the ViewModel using `SimpleViewModelMixin`

## Running

```bash
flutter run
```

This example demonstrates the basic MVI pattern without effects, making it perfect for understanding the core concepts.
