import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState extends ChangeNotifier {
  User? user;

  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  void clearUser() {
    user = null;
    notifyListeners();
  }
}
