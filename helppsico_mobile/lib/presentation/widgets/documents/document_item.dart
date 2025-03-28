import 'package:flutter/material.dart';

class DocumentItem {
  final String title;
  final String date;
  final String fileSize;
  final String fileType;
  final bool isFavorite;

  DocumentItem({
    required this.title,
    required this.date,
    required this.fileSize,
    required this.fileType,
    required this.isFavorite,
  });

  DocumentItem copyWith({
    String? title,
    String? date,
    String? fileSize,
    String? fileType,
    bool? isFavorite,
  }) {
    return DocumentItem(
      title: title ?? this.title,
      date: date ?? this.date,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class DocumentListItem extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onFavoritePressed;

  const DocumentListItem({
    super.key,
    required this.document,
    required this.onFavoritePressed,
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
          subtitle: Text('${document.date} • ${document.fileSize}'),
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
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                //implementar
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: document.fileType == 'PDF' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        document.fileType,
        style: TextStyle(
          color: document.fileType == 'PDF' ? Colors.red : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}