import 'package:flutter/material.dart';

class MockDocument {
  final String id;
  final String title;
  final int pageCount;
  final String date;
  final String type;

  MockDocument({
    required this.id,
    required this.title,
    required this.pageCount,
    required this.date,
    required this.type,
  });
}

class DocumentProvider extends ChangeNotifier {
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasLoaded = false;

  final List<MockDocument> _allDocs = [
    MockDocument(
      id: '1',
      title: 'Chapter 1: Introduction to AI',
      pageCount: 24,
      date: '2 days ago',
      type: 'pdf',
    ),
    MockDocument(
      id: '2',
      title: 'Machine Learning Basics',
      pageCount: 45,
      date: '3 days ago',
      type: 'pdf',
    ),
    MockDocument(
      id: '3',
      title: 'Neural Networks Architecture',
      pageCount: 12,
      date: '1 week ago',
      type: 'ppt',
    ),
    MockDocument(
      id: '4',
      title: 'Computer Vision Overview',
      pageCount: 30,
      date: '2 weeks ago',
      type: 'pdf',
    ),
    MockDocument(
      id: '5',
      title: 'Natural Language Processing',
      pageCount: 56,
      date: '3 weeks ago',
      type: 'pdf',
    ),
    MockDocument(
      id: '6',
      title: 'Reinforcement Learning',
      pageCount: 18,
      date: '1 month ago',
      type: 'pdf',
    ),
  ];

  List<MockDocument> get documents {
    if (_isLoading) return [];
    if (_searchQuery.isEmpty) return _allDocs;
    return _allDocs
        .where(
          (doc) => doc.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadDocuments() async {
    if (_hasLoaded || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
