import 'package:flutter_bloc/flutter_bloc.dart';
part 'navigation_bar_state.dart';

class NavigationBarCubit extends Cubit<NavigationBarState> {
  NavigationBarCubit() : super(NavigationBarState(currentIndex: 0));

  void navigateTo(int index) {
    emit(NavigationBarState(currentIndex: index));
  }
}
