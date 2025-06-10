import 'package:flutter/material.dart';
import '../../../domain/entities/document_model.dart';

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
          leading: const Icon(Icons.file_copy_sharp, color: Color.fromARGB(255, 114, 184, 240), size: 32,),
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
             
            ],
          ),
        ),
      ),
    );
  }

  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}