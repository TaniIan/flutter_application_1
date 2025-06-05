import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState extends ChangeNotifier {
  User? user;

  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }
}
