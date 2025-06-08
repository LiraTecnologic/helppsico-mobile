import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../domain/entities/review_entity.dart';
import '../viewmodels/cubit/review_cubit.dart';
import '../viewmodels/state/review_state.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/common/custom_app_bar.dart';

class AvaliarPsicologoScreen extends StatefulWidget {
  const AvaliarPsicologoScreen({Key? key}) : super(key: key);
 
  

  @override
  _AvaliarPsicologoScreenState createState() {
    print('[AvaliarPsicologoScreen] createState called');
    return _AvaliarPsicologoScreenState();
  }
}

class _AvaliarPsicologoScreenState extends State<AvaliarPsicologoScreen> {
  late final ReviewCubit _reviewCubit;

  @override
  void initState() {
    print('[AvaliarPsicologoScreen] initState called');
    super.initState();
    _reviewCubit = ReviewCubit.instance();
    // A inicialização agora é chamada sem parâmetros e buscará os dados do storage.
    // Verifica se o estado é Loading ou se é a primeira vez que o cubit é inicializado
    // para evitar múltiplas chamadas de initialize se a tela for reconstruída.
    if (_reviewCubit.state is ReviewLoading || _reviewCubit.state is ReviewInitial && (_reviewCubit.state as ReviewInitial).psicologoId.isEmpty) {
      print('[AvaliarPsicologoScreen] Calling ReviewCubit.initialize()');
      _reviewCubit.initialize();
    }
  }

  @override
  void dispose() {
    // Com a instância única, o dispose pode ser gerenciado de forma diferente
    // ou chamado em um ponto mais global se necessário, ou não chamado aqui
    // se a instância deve persistir durante a vida útil da app após o login.
    // ReviewCubit.disposeInstance(); // Descomente se desejar limpar a instância ao sair da tela.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[AvaliarPsicologoScreen] build called');
    return BlocProvider.value(
      value: _reviewCubit,
      child: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ReviewSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ReviewDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text((state.message) as String ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          print('[AvaliarPsicologoScreen] BlocBuilder called with state: ${state.runtimeType}');
          if (state is ReviewLoading) {
            print('[AvaliarPsicologoScreen] Rendering loading state');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          return _buildScaffold(context, state);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ReviewState state) {
    List<ReviewEntity> reviews = [];
    String psicologoNome = "Psicólogo"; // Default name

    if (state is ReviewInitial) {
      reviews = state.reviews;
      psicologoNome = state.psicologoNome;
    } else if (state is ReviewRated) {
      reviews = state.reviews;
      psicologoNome = state.psicologoNome;
    } else if (state is ReviewSuccess) {
      reviews = state.reviews;
      psicologoNome = state.psicologoNome;
    } else if (state is ReviewDeleted) {
      reviews = state.reviews;
      psicologoNome = state.psicologoNome;
    } else if (state is ReviewError) {
      reviews = state.reviews;
      // Se o nome do psicólogo não estiver no estado de erro, usa o padrão.
      // Isso pode acontecer se o cubit falhar ao carregar os dados do psicólogo.
      psicologoNome = state.psicologoNome ?? "Psicólogo"; 
    }
    
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPsychologistCard(psicologoNome),
            const SizedBox(height: 20),
            _buildRatingSection(context),
            const SizedBox(height: 20),
            _buildCommentSection(context),
            const SizedBox(height: 20),
            _buildSubmitButton(context),
            const SizedBox(height: 20),
            _buildReviewsList(context, reviews),
          ],
        ),
      ),
    );
  }

  Widget _buildPsychologistCard(String psicologoNome) {
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
              psicologoNome,
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

  Widget _buildRatingSection(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        int currentRating = 0;
        if (state is ReviewRated) {
          currentRating = state.rating;
        }
        
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
                        index < currentRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () {
                        context.read<ReviewCubit>().setRating(index + 1);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentSection(BuildContext context) {
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
              controller: context.read<ReviewCubit>().comentarioController,
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

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
        print('[AvaliarPsicologoScreen] Send review button pressed');
        context.read<ReviewCubit>().enviarAvaliacao();
      },
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

  Widget _buildReviewsList(BuildContext context, List<ReviewEntity> reviews) {
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
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
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
                              print('[AvaliarPsicologoScreen] Delete button pressed for review: ${review.id}');
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar exclusão'),
                                    content: const Text('Deseja realmente excluir este comentário?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          print('[AvaliarPsicologoScreen] Delete dialog cancelled');
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                          print('[AvaliarPsicologoScreen] Delete confirmed for reviewId: ${review.id}');
                          Navigator.of(context).pop();
                          context.read<ReviewCubit>().deleteReview(review.id);
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
