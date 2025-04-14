import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/common/session_card.dart';
import '../widgets/common/document_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            onPressed: () {},
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
            const SessionCard(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Todas sessões"),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Último documento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const DocumentCard(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Documentos"),
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
                  _buildDrawerItem(Icons.notifications, "Notificações"),
                  _buildDrawerItem(Icons.calendar_today, "Sessões"),
                  _buildDrawerItem(Icons.insert_drive_file, "Documentos"),
                  _buildDrawerItem(Icons.star, "Avaliar psicólogo"),
                  _buildDrawerItem(Icons.home, "Meu painel"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildDrawerItem(Icons.exit_to_app, "Sair"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      title: Text(title, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      onTap: () {},
    );
  }
}
