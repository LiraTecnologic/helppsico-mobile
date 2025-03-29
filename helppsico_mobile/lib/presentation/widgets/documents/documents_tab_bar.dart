import 'package:flutter/material.dart';
import '../../../data/models/document_model.dart';

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
          _buildTab('Anamnese', DocumentType.anamnese),
          _buildTab('Avaliação', DocumentType.avaliacao),
          _buildTab('Relatórios', DocumentType.relatorio),
          _buildTab('Atestados', DocumentType.atestado),
          _buildTab('Encaminhamentos', DocumentType.encaminhamento),
          _buildTab('Outros', DocumentType.outros),
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