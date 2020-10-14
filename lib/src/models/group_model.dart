import 'dart:collection';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class GroupModel extends ChangeNotifier {
  final List<UserModel> _users = [];

  /// An unmodifiable view of the users in the group
  UnmodifiableListView<UserModel> get users => UnmodifiableListView(_users);

  void add(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  void remove(UserModel user) {
    _users.remove(user);
    notifyListeners();
  }

  void clear() {
    _users.clear();
    notifyListeners();
  }
}
