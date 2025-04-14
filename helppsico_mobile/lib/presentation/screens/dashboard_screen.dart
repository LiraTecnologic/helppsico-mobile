import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/session_card.dart';
import '../widgets/document_card.dart';
import '../screens/documents_screen.dart';
import '../screens/sessions_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/login_screen.dart';
import '../../data/mock_documents.dart';
import '../../data/mock_sessions.dart';
import '../../data/models/document_model.dart';
import '../../data/models/session_model.dart';
import '../widgets/drawer/custom_drawer.dart';
import 'package:helppsico_mobile/presentation/widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DocumentModel? _lastDocument;
  SessionModel? _nextSession;
  final MockDocumentRepository _documentRepository = MockDocumentRepository();
  final MockSessionRepository _sessionRepository = MockSessionRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadLastDocument(),
        _loadNextSession(),
      ]);
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  Future<void> _loadLastDocument() async {
    try {
      final documents = await _documentRepository.getDocuments();
      if (documents.isNotEmpty) {
        setState(() {
          _lastDocument = documents.first; 
        });
      }
    } catch (e) {
      print('Erro ao carregar último documento: $e');
    }
  }

  Future<void> _loadNextSession() async {
    try {
      final nextSession = await _sessionRepository.getNextSession();
      if (nextSession != null) {
        setState(() {
          _nextSession = nextSession;
        });
      }
    } catch (e) {
      print('Erro ao carregar próxima sessão: $e');
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.ATESTADO:
        return Icons.medical_services;
      case DocumentType.DECLARACAO:
        return Icons.description;
      case DocumentType.RELATORIO_PSICOLOGICO:
        return Icons.psychology;
      case DocumentType.RELATORIO_MULTIPROFISSIONAL:
        return Icons.group;
      case DocumentType.LAUDO_PSICOLOGICO:
        return Icons.assessment;
      case DocumentType.PARECER_PSICOLOGICO:
        return Icons.send;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getSessionStatus(SessionStatus status) {
    switch (status) {
      case SessionStatus.pending:
        return "Pendente";
      case SessionStatus.scheduled:
        return "Pago";
      case SessionStatus.completed:
        return "Concluída";
      case SessionStatus.canceled:
        return "Cancelada";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Próxima sessão",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_nextSession != null)
                SessionCard(
                  date: _nextSession!.date,
                  doctorName: _nextSession!.doctorName,
                  sessionType: _nextSession!.sessionType,
                  timeRange: _nextSession!.timeRange,
                  status: _getSessionStatus(_nextSession!.status),
                  paymentInfo: _nextSession!.paymentInfo,
                  location: _nextSession!.location,
                  crp: _nextSession!.crp,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SessionsPage()),
                    );
                  },
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SessionsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Ver mais"),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Último documento",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_lastDocument != null)
                DocumentCard(
                  title: _lastDocument!.title,
                  date: "${_lastDocument!.date.day}/${_lastDocument!.date.month}",
                  icon: _getDocumentIcon(_lastDocument!.type),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                    );
                  },
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Ver mais"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
