import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';

class DocumentsViewModel extends ChangeNotifier {
  final DocumentRepository _repository;

  List _documents = [];
  List _filteredDocuments = [];
  bool _isLoading = false;
  String? _error;
  bool _showFavoritesOnly = false;
  DocumentType? _selectedType;
  String _searchQuery = '';

  DocumentsViewModel()
      : _repository = DocumentRepository(
          DocumentsDataSource(
            GenericHttp(),
            GetIt.instance.get(),
            GetIt.instance.get(),
          ),
          GetIt.instance.get(),
        );

  List get documents => _filteredDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showFavoritesOnly => _showFavoritesOnly;
  DocumentType? get selectedType => _selectedType;

  Future loadDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _documents = await _repository.getDocuments();
      _applyFilters();
    } catch (e) {
      _error = 'Erro ao carregar documentos: \$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setShowFavorites(bool show) {
    _showFavoritesOnly = show;
    _applyFilters();
  }

  void setSelectedType(DocumentType? type) {
    _selectedType = type;
    _applyFilters();
  }

  Future toggleFavorite(DocumentModel document) async {
    try {
      await _repository.toggleFavorite(document.id);
      final idx = _documents.indexWhere((d) => d.id == document.id);
      if (idx != -1) {
        _documents[idx].isFavorite = !_documents[idx].isFavorite;
        _applyFilters();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future deleteDocument(DocumentModel document) async {
    try {
      await _repository.deleteDocument(document.id);
      _documents.removeWhere((d) => d.id == document.id);
      _applyFilters();
    } catch (e) {
      rethrow;
    }
  }

  void _applyFilters() {
    _filteredDocuments = _documents.where((doc) {
      final matchesSearch = doc.title.toLowerCase().contains(_searchQuery) ||
          doc.description.toLowerCase().contains(_searchQuery) ||
          doc.patientName.toLowerCase().contains(_searchQuery);
      final matchesType = _selectedType == null || doc.type == _selectedType;
      final matchesFavorites = !_showFavoritesOnly || doc.isFavorite;
      return matchesSearch && matchesType && matchesFavorites;
    }).toList();
    notifyListeners();
  }
}
