import 'package:mvi/mvi.dart';

sealed class LoginEffect extends BaseEffect {}

final class LoginSuccess extends LoginEffect {
  @override
  String toString() => 'LoginSuccess';
}

final class LoginError extends LoginEffect {
  @override
  String toString() => 'LoginError';
}
