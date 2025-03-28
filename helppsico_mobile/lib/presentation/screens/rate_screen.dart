import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AvaliarPsicologoScreen extends StatefulWidget {
  final String psicologoId;
  final String psicologoNome;

  const AvaliarPsicologoScreen({
    Key? key,
    required this.psicologoId,
    required this.psicologoNome,
  }) : super(key: key);

  @override
  State<AvaliarPsicologoScreen> createState() => _AvaliarPsicologoScreenState();
}

class _AvaliarPsicologoScreenState extends State<AvaliarPsicologoScreen> {
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
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmptyCard(),  
          ],
        ),
      ),
    );
  }

  
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
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
                _buildDrawerItem(Icons.notifications, "Notificações", () {
                  Navigator.pushNamed(context, '/notifications');
                }),
                _buildDrawerItem(Icons.calendar_today, "Sessões", () {}),
                _buildDrawerItem(Icons.insert_drive_file, "Documentos", () {}),
                _buildDrawerItem(Icons.star, "Avaliar psicólogo", () {}),
                _buildDrawerItem(Icons.home, "Meu painel", () {
                  Navigator.pushNamed(context, '/menu');
                }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildDrawerItem(Icons.exit_to_app, "Sair", () {
                Navigator.pushNamed(context, '/login');
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      title: Text(title, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      onTap: onTap,
    );
  }


  Widget _buildEmptyCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(400.0),
      ),
    );
  }
}
