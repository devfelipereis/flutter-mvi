import 'package:mvi/mvi.dart';

sealed class LoginEffect extends BaseEffect {}

final class LoginSuccess extends LoginEffect {}

final class LoginError extends LoginEffect {}
