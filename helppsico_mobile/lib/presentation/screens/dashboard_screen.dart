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
          _lastDocument = documents.first; // O primeiro documento é o mais recente
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
      case DocumentType.anamnese:
        return Icons.note_alt;
      case DocumentType.avaliacao:
        return Icons.assessment;
      case DocumentType.relatorio:
        return Icons.description;
      case DocumentType.atestado:
        return Icons.medical_services;
      case DocumentType.encaminhamento:
        return Icons.send;
      case DocumentType.outros:
        return Icons.insert_drive_file;
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/icons/logo.png',
            height: 65,
            width: 65,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
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
            Align(
              alignment: Alignment.centerLeft,
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
                child: const Text("Todas sessões"),
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
            Align(
              alignment: Alignment.centerLeft,
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
                child: const Text("Todos documentos"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: Container(
          color: AppTheme.primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20), 
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          "Menu",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 25),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), 
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: "Meu Painel",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: "Sessões",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SessionsPage()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: "Documentos",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: "Notificações",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDrawerItem(
                  icon: Icons.logout,
                  title: "Sair",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
