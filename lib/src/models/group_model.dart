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

  String getNameFromNumber(String number) {
    for (UserModel user in _users) {
      if (user.number == number) {
        return user.name;
      }
    }
    return number;
  }

  void makeAdmin(String number, bool admin) {
    for (UserModel user in _users) {
      if (user.number == number) {
        user.setAdmin(admin);
      }
    }
  }
}
