import 'package:meta/meta.dart';

@immutable
class AppState {
  final int counter;

  AppState({
    this.counter = 0,
  });

  AppState copyWith({int counter}) => AppState(counter: counter ?? this.counter);
}
