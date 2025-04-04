import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/document_item.dart';
import 'package:helppsico_mobile/presentation/widgets/documents/documents_tab_bar.dart';
import 'package:helppsico_mobile/presentation/widgets/notifications/custom_app_bar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for demonstration
  final List<DocumentItem> documents = [
    DocumentItem(
      title: 'Relatório de Avaliação',
      date: '24 Nov 2023',
      fileSize: '2.4 MB',
      fileType: 'PDF',
      isFavorite: true,
    ),
    DocumentItem(
      title: 'Questionário de Anamnese',
      date: '18 Nov 2023',
      fileSize: '1.2 MB',
      fileType: 'DOC',
      isFavorite: false,
    ),
    DocumentItem(
      title: 'Resultados de Testes',
      date: '16 Nov 2023',
      fileSize: '3.6 MB',
      fileType: 'PDF',
      isFavorite: false,
    ),
    DocumentItem(
      title: 'Relatório de Avaliação',
      date: '24 Nov 2023',
      fileSize: '2.4 MB',
      fileType: 'PDF',
      isFavorite: true,
    ),
    DocumentItem(
      title: 'Relatório de Avaliação',
      date: '24 Nov 2023',
      fileSize: '2.4 MB',
      fileType: 'PDF',
      isFavorite: true,
    ),
  ];

  void _toggleFavorite(int index) {
    setState(() {
      documents[index] = documents[index].copyWith(
        isFavorite: !documents[index].isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Container(
              // apenas para alinhar o texto
              alignment: Alignment.centerLeft,
              child: Text(
                'Documentos',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
              backgroundColor: WidgetStateProperty.all(Colors.white),

              //não aceita Colors.white
            ),
          ),

          const SizedBox(height: 16.0),
          Container(
            alignment: Alignment.centerLeft,
            child: const DocumentsTabBar(),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return DocumentListItem(
                    document: documents[index],
                    onFavoritePressed: () => _toggleFavorite(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
