import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _allUsers = [];
  bool _loading = false;
  String? _error;

  List<UserModel> get users => _allUsers;
  bool get isLoading => _loading;
  String? get error => _error;

  void initialize() {
    _loading = true;
    notifyListeners();
    _firestore.collection('users').orderBy('displayName').snapshots().listen((snapshot) {
      _allUsers = snapshot.docs.map((d) => UserModel.fromFirestore(d)).toList();
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    });
  }

  List<UserModel> searchByStartsWith(String query) {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return _allUsers.where((u) => u.displayName.toLowerCase().startsWith(lower)).toList();
  }
}
