import 'package:flutter/material.dart';
import '../../../data/models/document_model.dart';

class DocumentListItem extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDeletePressed;

  const DocumentListItem({
    super.key,
    required this.document,
    required this.onFavoritePressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: _buildFileTypeIcon(),
          title: Text(document.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.patientName),
              Text('${_formatDate(document.date)} • ${document.fileSize}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  document.isFavorite ? Icons.star : Icons.star_border,
                  color: document.isFavorite ? const Color.fromARGB(255, 243, 240, 33) : null,
                ),
                onPressed: onFavoritePressed,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDeletePressed,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeIcon() {
    Color backgroundColor;
    Color textColor;
    
    switch (document.type) {
      case DocumentType.anamnese:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case DocumentType.avaliacao:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case DocumentType.relatorio:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case DocumentType.atestado:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      case DocumentType.encaminhamento:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case DocumentType.outros:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        document.fileType,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}