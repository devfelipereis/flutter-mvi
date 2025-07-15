import 'package:mvi/mvi.dart';

sealed class LoginEvent extends BaseEvent {}

final class EmailChanged extends LoginEvent {
  EmailChanged(this.email);
  final String email;

  @override
  String toString() => 'EmailChanged(email: $email)';
}

final class PasswordChanged extends LoginEvent {
  PasswordChanged(this.password);
  final String password;

  @override
  String toString() => 'PasswordChanged(password: $password)';
}

final class LoginRequested extends LoginEvent {
  @override
  String toString() => 'LoginRequested';
}
