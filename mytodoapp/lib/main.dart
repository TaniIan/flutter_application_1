import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDgysxbzYb20cVlS5Z-yPmDTW5DkULOtQc",
        authDomain: "mytodoapp-5b1c5.firebaseapp.com",
        projectId: "mytodoapp-5b1c5",
        storageBucket: "mytodoapp-5b1c5.firebasestorage.app",
        messagingSenderId: "713225149531",
        appId: "1:713225149531:web:efd1d311a8baa4c0b1b37e",
        measurementId: "G-P4MLCGCX3T",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const TodoApp());
}
