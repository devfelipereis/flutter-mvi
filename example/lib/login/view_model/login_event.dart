import 'package:mvi/mvi.dart';

sealed class LoginEvent extends BaseEvent {}

final class EmailChanged extends LoginEvent {
  EmailChanged(this.email);
  final String email;
}

final class PasswordChanged extends LoginEvent {
  PasswordChanged(this.password);
  final String password;
}

final class LoginRequested extends LoginEvent {}
