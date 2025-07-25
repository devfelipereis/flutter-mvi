import 'package:equatable/equatable.dart';
import 'package:mvi/mvi.dart';
import 'package:example/posts/data/post_error.dart';
import 'package:example/posts/data/post_model.dart';

sealed class PostsState extends BaseState with EquatableMixin {
  const PostsState();
}

final class PostsLoading extends PostsState {
  const PostsLoading();

  @override
  List<Object?> get props => [];
}

final class PostsLoaded extends PostsState {
  const PostsLoaded(this.posts);

  final List<Post> posts;

  @override
  List<Object?> get props => [posts];

  @override
  String toString() => 'PostsLoaded(posts: $posts)';
}

final class PostsError extends PostsState {
  const PostsError(this.error);

  final PostError error;

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'PostsError(error: $error)';
}
