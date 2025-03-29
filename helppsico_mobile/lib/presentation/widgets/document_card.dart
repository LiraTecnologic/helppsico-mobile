import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                    child: Icon(
                      icon,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
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
      ),
    );
  }
} 