import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/viewmodels/document/document_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:helppsico_mobile/presentation/widgets/common/custom_app_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/drawer/custom_drawer.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/document_item.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State with SingleTickerProviderStateMixin {
  late final DocumentsViewModel _viewModel;
  late final TextEditingController _searchController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = DocumentsViewModel();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel.loadDocuments();
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _viewModel.setShowFavorites(_tabController.index == 1);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: const CustomAppBar(),
            drawer: const CustomDrawer(),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'Documentos',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    tabs: const [Tab(text: 'Todos'), Tab(text: 'Favoritos')],
                  ),
                  Expanded(
                    child: ((vm as DocumentsViewModel).isLoading)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : (vm).error != null
                            ? _buildErrorView(vm)
                            : _buildList(vm),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(DocumentsViewModel vm) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.loadDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Tentar Novamente',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

  Widget _buildList(DocumentsViewModel vm) {
    if (vm.documents.isEmpty) {
      String message = 'Nenhum documento encontrado.';
      if (vm.showFavoritesOnly) {
        message = 'Nenhum documento favorito.';
      } else if (vm.selectedType != null) {
        message = 'Nenhum documento deste tipo encontrado.';
      } else if (_searchController.text.isNotEmpty) {
        message = 'Nenhum documento encontrado para sua pesquisa.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.documents.length,
      itemBuilder: (context, index) {
        final doc = vm.documents[index];
        return DocumentListItem(
          document: doc,
          onFavoritePressed: () => _viewModel.toggleFavorite(doc),
          onDeletePressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: Text('Excluir "${doc.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Excluir',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _viewModel.deleteDocument(doc);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Documento "${doc.title}" excluído.')),
              );
            }
          },
        );
      },
    );
  }
}


