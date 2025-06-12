import 'package:example/posts/posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:mvi/mvi.dart';
import 'package:example/login/view_model/login_view_model.dart';
import 'package:example/posts/data/posts_repository.dart';
import 'package:example/posts/view_model/posts_view_model.dart';

// IMPORTANT: We use a factory function (ViewModelCreator) instead of passing a direct ViewModel instance
// to ensure the ViewModel is created when the widget needs it, not during widget tree construction.
// This avoids unnecessary recreation during rebuilds and helps manage lifecycle cleanly.
// Creating a new instance on every build can cause loss of state, wasted resources, and unintended behavior.
typedef LoginVMCreator =
    ViewModelCreator<LoginState, LoginEvent, LoginEffect, LoginViewModel>;

// ViewModelMixin provides the connection between the Widget and ViewModel
// It handles state updates, event dispatching, and effect processing
typedef LoginVMMixin =
    ViewModelMixin<
      LoginPage,
      LoginState,
      LoginEvent,
      LoginEffect,
      LoginViewModel
    >;

class LoginPage extends StatefulWidget {
  // The viewModel parameter is a factory function that creates the LoginViewModel
  // This allows for dependency injection and easier testing
  const LoginPage({required this.viewModel, super.key});
  final LoginVMCreator viewModel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginVMMixin {
  @override
  // Creates and provides the ViewModel instance for this widget
  LoginViewModel provideViewModel() => widget.viewModel();

  // Uses signals to observe the authentication state from the ViewModel
  // This creates a reactive connection that automatically updates the UI
  late final isAuthenticating = viewModel.select(
    (state) => state.isAuthenticating,
  );

  @override
  // Handles side effects produced by the ViewModel
  // Effects represent one-time actions like navigation or showing dialogs
  void onEffect(covariant LoginEffect effect, BuildContext context) =>
      switch (effect) {
        LoginSuccess() => _onLoginSuccess(context),
        LoginError() => _onLoginError(context),
      };

  void _onLoginSuccess(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => PostsScreen(
          viewModel: () => PostsViewModel(postsRepository: PostsRepository()),
        ),
      ),
    );
  }

  void _onLoginError(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Oops!'),
        content: Text('Authentication failed. Please try again.'),
      ),
    );
  }

  Future<void> _onLogin(BuildContext context) async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    // Dispatches a LoginRequested event to the ViewModel
    // Events represent user intentions or actions
    addEvent(LoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MVI Example')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Watch widget from signals_flutter automatically rebuilds this subtree
        // whenever any signal it depends on changes (in this case, viewModel.state)
        // This ensures our UI stays in sync with the ViewModel's state efficiently
        child: Watch((context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                enabled: !isAuthenticating.value,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'admin@admin.com',
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // Dispatches EmailChanged events to update the ViewModel state
                onChanged: (value) => addEvent(EmailChanged(value)),
              ),
              const SizedBox(height: 8),
              TextField(
                enabled: !isAuthenticating.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '123456',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                obscureText: true,
                // Dispatches PasswordChanged events to update the ViewModel state
                onChanged: (value) => addEvent(PasswordChanged(value)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: isAuthenticating.value
                    ? null
                    : () => _onLogin(context),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: isAuthenticating.value
                    ? const Center(child: CircularProgressIndicator())
                    : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}
