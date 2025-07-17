import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  // isLoading controls the initial loading state or refreshing whole screen
  bool _isLoading = false;
  // isLoadingMore controls the pagination loading state
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedUserName = "Selected User Name";

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get selectedUserName => _selectedUserName;

  // Load initial users
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://reqres.in/api/users?page=1&per_page=10'),
      );

      if (response.statusCode == 200) {
        final usersResponse = UsersResponse.fromJson(
          json.decode(response.body),
        );
        _users = usersResponse.data;
        _currentPage = usersResponse.page;
        _totalPages = usersResponse.totalPages;
      }
    } catch (e) {
      print('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more users for pagination
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await http.get(
        Uri.parse('https://reqres.in/api/users?page=$nextPage&per_page=10'),
      );

      if (response.statusCode == 200) {
        final usersResponse = UsersResponse.fromJson(
          json.decode(response.body),
        );
        _users.addAll(usersResponse.data);
        _currentPage = usersResponse.page;
      }
    } catch (e) {
      print('Error loading more users: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // Select a user
  void selectUser(String userName) {
    _selectedUserName = userName;
    notifyListeners();
  }

  // Refresh users
  Future<void> refreshUsers() async {
    _currentPage = 1;
    await loadUsers();
  }
}
