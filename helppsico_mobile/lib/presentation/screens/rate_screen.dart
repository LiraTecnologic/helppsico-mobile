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
  int _rating = 0;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _enviarAvaliacao() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma nota para a avaliação'),
        ),
      );
      return;
    }

   
    print('Avaliação enviada: Nota $_rating');

    Navigator.pop(context);
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
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPsychologistCard(),
            const SizedBox(height: 20),
            _buildRatingSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildPsychologistCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              widget.psicologoNome,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Psicóloga Clínica • CRP 06/12345",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => 
                Icon(
                  Icons.star,
                  color: index < 4 ? Colors.amber : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text("(42 avaliações)", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  
  Widget _buildRatingSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(200.0),
        child: Column(
          
          children: [],
        ),
      ),
    );
  }
}
