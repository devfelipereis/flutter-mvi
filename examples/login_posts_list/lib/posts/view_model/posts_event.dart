import 'package:mvi/mvi.dart';

sealed class PostsEvent extends BaseEvent {}

final class FetchPosts extends PostsEvent {
  @override
  String toString() => 'FetchPosts';
}
