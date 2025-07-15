import 'base_view_model.dart';

/// A function type that creates and returns a new ViewModel instance.
typedef ViewModelCreator<VM extends BaseViewModel> = VM Function();
