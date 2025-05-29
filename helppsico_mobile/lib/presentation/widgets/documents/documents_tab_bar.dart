import 'package:flutter/material.dart';
import '../../../domain/entities/document_model.dart';

class DocumentsTabBar extends StatelessWidget {
  final Function(DocumentType?) onTypeSelected;

  const DocumentsTabBar({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab('Atestados', DocumentType.ATESTADO),
          _buildTab('Declarações', DocumentType.DECLARACAO),
          _buildTab('Relatórios Psicológicos', DocumentType.RELATORIO_PSICOLOGICO),
          _buildTab('Laudos Psicológicos', DocumentType.LAUDO_PSICOLOGICO),
          _buildTab('Pareceres Psicológicos', DocumentType.PARECER_PSICOLOGICO),
        ],
      ),
    );
  }

  Widget _buildTab(String label, DocumentType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[200],
        onSelected: (selected) {
          onTypeSelected(selected ? type : null);
        },
      ),
    );
  }
}