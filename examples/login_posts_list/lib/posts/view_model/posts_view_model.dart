import 'package:example/posts/data/posts_repository.dart';
import 'package:example/posts/view_model/posts_event.dart';
import 'package:example/posts/view_model/posts_state.dart';
import 'package:mvi/mvi.dart';

export 'posts_event.dart';
export 'posts_state.dart';

final class PostsViewModel extends SimpleViewModel<PostsState, PostsEvent> {
  PostsViewModel({required PostsRepository postsRepository})
    : _postsRepository = postsRepository,
      super(const PostsLoading(), debugLabel: 'PostsViewModel');

  final PostsRepository _postsRepository;

  @override
  void onEvent(PostsEvent event) => switch (event) {
    FetchPosts() => _onFetchPosts(),
  };

  Future<void> _onFetchPosts() async {
    updateState(const PostsLoading());

    final result = await _postsRepository.fetchPosts();

    if (result.isSuccess()) {
      updateState(PostsLoaded(result.tryGetSuccess()!));
      return;
    }

    updateState(PostsError(result.tryGetError()!));
  }
}
