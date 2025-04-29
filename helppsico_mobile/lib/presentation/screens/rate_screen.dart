import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_reviews.dart';
import '../../data/models/review_model.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/custom_app_bar.dart';

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
  late List<ReviewModel> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = MockReviews.getReviewsByPsicologoId(widget.psicologoId);
  }

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

    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      psicologoId: widget.psicologoId,
      userName: 'Usuário Atual',
      rating: _rating,
      comment: _comentarioController.text.trim(),
      date: DateTime.now(),
    );

    setState(() {
      MockReviews.addReview(newReview);
      _reviews = MockReviews.getReviewsByPsicologoId(widget.psicologoId);
      _rating = 0;
      _comentarioController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avaliação enviada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return const CustomDrawer();
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
      appBar: const CustomAppBar(),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPsychologistCard(),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 20),
            _buildCommentSection(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            _buildReviewsList(),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Como você avalia a consulta?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deixe seu comentário',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escreva aqui sua experiência...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _enviarAvaliacao,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Enviar Avaliação",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliações',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 18,
                              color: i < review.rating ? Colors.amber : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${review.date.day}/${review.date.month}/${review.date.year}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        if (review.userName == 'Usuário Atual')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar exclusão'),
                                    content: const Text('Deseja realmente excluir este comentário?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            MockReviews.deleteReview(review.id);
                                            _reviews = MockReviews.getReviewsByPsicologoId(widget.psicologoId);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Comentário excluído com sucesso!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );          
          },
        ),
      ],
    );
  }
}
