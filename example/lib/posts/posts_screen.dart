import 'package:flutter/material.dart';
import 'package:mvi/mvi.dart';
import 'package:example/posts/data/post_error.dart';
import 'package:example/posts/data/post_model.dart';
import 'package:example/posts/view_model/posts_view_model.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({required this.viewModel, super.key});

  final ViewModelCreator<PostsViewModel> viewModel;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with
        // The mixin provides the connection between widget and ViewModel
        // It handles the lifecycle, state updates, and event dispatching
        SimpleViewModelMixin<
          PostsScreen,
          PostsState,
          PostsEvent,
          PostsViewModel
        > {
  @override
  // Creates the ViewModel and immediately triggers a FetchPosts event
  // This is a good example of handling initial data loading in MVI
  PostsViewModel createViewModel() =>
      widget.viewModel()..addEvent(FetchPosts());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: RefreshIndicator(
        // Event dispatching on user interaction (pull-to-refresh)
        onRefresh: () async => addEvent(FetchPosts()),
        // Using ViewModelListener to listen to state changes
        // This is similar to Riverpod's Consumer or Signals' Watch widget
        child: ValueListenableBuilder(
          valueListenable: viewModel.state,
          builder: (context, state, child) {
            // AnimatedSwitcher provides smooth transitions between different states
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              // Pattern matching on the state to render the appropriate UI
              // This is a key concept in MVI where the UI is a pure function of state
              child: switch (state) {
                PostsLoading() => const _LoadingIndicator(),
                PostsLoaded(posts: final posts) => _PostList(posts: posts),
                PostsError(error: final error) => _ErrorMessage(error: error),
              },
            );
          },
        ),
      ),
    );
  }
}

// Post list widget
class _PostList extends StatelessWidget {
  const _PostList({required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final post = posts[index];

        return ListTile(title: Text(post.title), subtitle: Text(post.body));
      },
    );
  }
}

// Loading state representation
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// Error state representation with error type handling
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error});

  final PostError error;

  @override
  Widget build(BuildContext context) {
    // Pattern matching on error types to show appropriate messages
    final errorMessage = switch (error) {
      PostError.unknown => 'Unknown error',
      PostError.parse => 'Error parsing data',
    };

    return Center(child: Text(errorMessage));
  }
}
