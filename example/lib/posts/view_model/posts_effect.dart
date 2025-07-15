import 'package:mvi/mvi.dart';

sealed class PostsEffect extends BaseEffect {
  @override
  String toString() => 'PostsEffect';
}
