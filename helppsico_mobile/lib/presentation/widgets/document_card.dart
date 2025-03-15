import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppTheme.secondaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Atestado médico",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 4),
                    Text(
                      "02/02",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey
                      )
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Ver Mais",
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 