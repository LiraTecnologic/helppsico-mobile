import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/document_item.dart';
// import 'package:helppsico_mobile/presentation/widgets/documents/documents_tab_bar.dart'; // Removido se não for mais usado
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final DocumentRepository _documentRepository;
  List<DocumentModel> _documents = [];
  List<DocumentModel> _filteredDocuments = [];
  DocumentType? _selectedType; 
  bool _isLoading = true;
  String? _error;
  bool _showFavoritesOnly = false; 
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    final secureStorage = GetIt.instance.get<SecureStorageService>();
    final genericHttp = GenericHttp(); 
    final authService = GetIt.instance.get<AuthService>();
    final documentsDataSource = DocumentsDataSource(genericHttp, secureStorage, authService);
    _documentRepository = DocumentRepository(documentsDataSource, secureStorage);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _showFavoritesOnly = _tabController.index == 1;
          _filterDocuments();
        });
      } else if (!_tabController.indexIsChanging && _tabController.index == 1 && !_showFavoritesOnly) {
        // Caso especial: se o usuário voltou para a aba de favoritos e ela não estava ativa
        setState(() {
          _showFavoritesOnly = true;
          _filterDocuments();
        });
      } else if (!_tabController.indexIsChanging && _tabController.index == 0 && _showFavoritesOnly) {
        // Caso especial: se o usuário voltou para a aba 'Todos' e favoritos estava ativo
         setState(() {
          _showFavoritesOnly = false;
          _filterDocuments();
        });
      }
    });

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final documents = await _documentRepository.getDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
          // _filteredDocuments = documents; // O filtro será aplicado em _filterDocuments
          _isLoading = false;
        });
        _filterDocuments(); // Aplicar filtros iniciais
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erro ao carregar documentos: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(DocumentModel document) async {
    try {
      await _documentRepository.toggleFavorite(document.id);
      // Atualizar o estado local do documento
      final docIndex = _documents.indexWhere((d) => d.id == document.id);
      if (docIndex != -1) {
        if (mounted) {
          setState(() {
            _documents[docIndex].isFavorite = !_documents[docIndex].isFavorite;
            _filterDocuments();
          });
        }
      }
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
     
        bool matchesFavorites = !_showFavoritesOnly || doc.isFavorite;
        
        return matchesSearch && matchesType && matchesFavorites;
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
              child: Text(
                'Documentos',
                style: TextStyle(
                  fontSize: 24.0, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField( 
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar documentos...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none, 
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Favoritos'),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorView()
                      : _buildDocumentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_filteredDocuments.isEmpty) {
      String message = 'Nenhum documento encontrado.';
      if (_showFavoritesOnly) {
        message = 'Nenhum documento favorito.';
      } else if (_selectedType != null) {
        message = 'Nenhum documento deste tipo encontrado.';
      } else if (_searchController.text.isNotEmpty) {
        message = 'Nenhum documento encontrado para sua pesquisa.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center,),
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return DocumentListItem(
          document: document,
          onFavoritePressed: () => _toggleFavorite(document),
          onDeletePressed: () async {
           
            final confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: Text('Tem certeza que deseja excluir o documento "${document.title}"?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              try {
                await _documentRepository.deleteDocument(document.id);
                if (mounted) {
                  setState(() {
                    _documents.removeWhere((doc) => doc.id == document.id);
                    _filterDocuments(); 
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Documento "${document.title}" excluído.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir documento: $e')),
                  );
                }
              }
            }
          },
       
        );
      },
    );
  }
}