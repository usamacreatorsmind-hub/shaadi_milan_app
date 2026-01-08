import 'package:flutter_riverpod/legacy.dart';

enum UserBottomTab { home, wishlist, visited, profile }

final userBottomNavProvider = StateProvider<UserBottomTab>(
  (ref) => UserBottomTab.home,
);
