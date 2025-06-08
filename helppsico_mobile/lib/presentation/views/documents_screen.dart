import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/document_item.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/documents_tab_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final DocumentRepository _documentRepository = DocumentRepository(DocumentsDataSource(GenericHttp(),GetIt.instance.get<SecureStorageService>(), AuthService()));
  List<DocumentModel> _documents = [];
  List<DocumentModel> _filteredDocuments = [];
  DocumentType? _selectedType;
  bool _isLoading = true;
  String? _error;
  bool _showFavorites = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDocuments();
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final documents = await _documentRepository.getDocuments();
      setState(() {
        _documents = documents;
        _filteredDocuments = documents;
        _isLoading = false;
      });
      _filterDocuments();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(DocumentModel document) async {
    try {
      await _documentRepository.toggleFavorite(document.id);
      await _loadDocuments(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar favorito: $e')),
        );
      }
    }
  }

  void _filterDocuments() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredDocuments = _documents.where((doc) {
        bool matchesSearch = doc.title.toLowerCase().contains(searchQuery) ||
            doc.description.toLowerCase().contains(searchQuery) ||
            doc.patientName.toLowerCase().contains(searchQuery);
        
        bool matchesType = _selectedType == null || doc.type == _selectedType;
        bool matchesFavorites = !_showFavorites || doc.isFavorite;
        
        return matchesSearch && matchesType && matchesFavorites;
      }).toList();
    });
  }



  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.ATESTADO:
        return Icons.medical_services;
      case DocumentType.DECLARACAO:
        return Icons.description;
      case DocumentType.RELATORIO_PSICOLOGICO:
        return Icons.psychology;
      case DocumentType.LAUDO_PSICOLOGICO:
        return Icons.assessment;
      case DocumentType.PARECER_PSICOLOGICO:
        return Icons.send;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Documentos',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Pesquisar documentos...',
                    leading: const Icon(Icons.search),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
                TabBar(
                  controller: _tabController,
                  onTap: (index) {
                    setState(() {
                      _showFavorites = index == 1;
                      _selectedType = null; 
                    });
                    _filterDocuments();
                  },
                  tabs: const [
                    Tab(text: 'Todos'),
                    Tab(text: 'Favoritos'),
                  ],
                ),
                const SizedBox(height: 16.0),
                DocumentsTabBar(
                  onTypeSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                    _filterDocuments();
                  },
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _buildDocumentsList(),
                ),
              ],
            ),
      ),
      
    );
  }

  Widget _buildDocumentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocuments,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_filteredDocuments.isEmpty) {
      String message = 'Nenhum documento encontrado';
      if (_showFavorites) {
        message = 'Nenhum documento favorito encontrado';
      } else if (_selectedType != null) {
        message = 'Nenhum documento deste tipo encontrado';
      }
      return Center(child: Text(message));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return DocumentListItem(
          document: document,
          onFavoritePressed: () => _toggleFavorite(document),
          onDeletePressed: () async {
            try {
              await _documentRepository.deleteDocument(document.id);
              if (mounted) {
                setState(() {
                  _documents.removeWhere((doc) => doc.id == document.id);
                });
                _filterDocuments();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir documento: $e')),
                );
              }
            }
          },
        );
      },
    );
  }
}