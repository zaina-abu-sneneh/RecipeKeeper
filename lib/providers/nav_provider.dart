import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // This tells the Dashboard to rebuild
  }

  // in case we sign out, reset to Home tab (0) safely
  void resetIndex() {
    _currentIndex = 0;
    notifyListeners();
  }
}
