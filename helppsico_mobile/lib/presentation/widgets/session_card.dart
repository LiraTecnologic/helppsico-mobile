import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SessionCard extends StatelessWidget {
  final String date;
  final String doctorName;
  final String sessionType;
  final String timeRange;
  final String status;
  final String? paymentInfo;
  final String? location;
  final String? crp;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.date,
    required this.doctorName,
    required this.sessionType,
    required this.timeRange,
    required this.status,
    this.paymentInfo,
    this.location,
    this.crp,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor
                            )
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            timeRange,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87
                            )
                          ),
                        ),
                      ],
                    ),
                    if (location != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            location!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                            )
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.primaryColor,
                              )
                            ),
                            if (crp != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "CRP: $crp",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                                )
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: status == "Pago" ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: status == "Pago" ? Colors.green.shade100 : Colors.orange.shade100,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "Pago" ? Colors.green.shade700 : Colors.orange.shade700,
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