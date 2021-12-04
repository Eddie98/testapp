import 'dart:collection';

import 'package:flutter/material.dart';

import 'models.dart';

class AppModel extends ChangeNotifier {
  final List<Photo> _favoritesList = [];

  UnmodifiableListView<Photo> get favoritesList =>
      UnmodifiableListView(_favoritesList);

  void addFavorite(Photo favorite) {
    _favoritesList.add(favorite);
    notifyListeners();
  }

  void removeFavorite(Photo favorite) {
    _favoritesList.removeWhere((el) => el.id == favorite.id);
    notifyListeners();
  }
}
