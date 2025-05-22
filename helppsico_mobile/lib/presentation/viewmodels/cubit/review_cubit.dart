import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../domain/entities/review_entity.dart';
import '../state/review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;
  final TextEditingController comentarioController = TextEditingController();
  int _rating = 0;

  ReviewCubit({ReviewRepository? repository})
      : _repository = repository ?? ReviewRepository(),
        super(const ReviewLoading());

  Future<void> initialize(String psicologoId, String psicologoNome) async {
    try {
      final reviews = await _repository.getReviewsByPsicologoId(psicologoId);
      emit(ReviewInitial(
        psicologoId: psicologoId,
        psicologoNome: psicologoNome,
        reviews: reviews,
      ));
    } catch (e) {
      emit(ReviewError(message: 'Erro ao carregar avaliações: ${e.toString()}'));
    }
  }

  void setRating(int rating) {
    _rating = rating;
    
    if (state is ReviewInitial) {
      final currentState = state as ReviewInitial;
      emit(ReviewRated(
        psicologoId: currentState.psicologoId,
        psicologoNome: currentState.psicologoNome,
        reviews: currentState.reviews,
        rating: rating,
        comentarioController: comentarioController,
      ));
    } else if (state is ReviewRated) {
      final currentState = state as ReviewRated;
      emit(ReviewRated(
        psicologoId: currentState.psicologoId,
        psicologoNome: currentState.psicologoNome,
        reviews: currentState.reviews,
        rating: rating,
        comentarioController: comentarioController,
      ));
    }
  }

  Future<void> enviarAvaliacao() async {
    if (_rating == 0) {
      emit(const ReviewError(message: 'Por favor, selecione uma nota para a avaliação'));
      return;
    }

    if (state is ReviewInitial || state is ReviewRated) {
      try {
        final currentState = state is ReviewInitial 
            ? state as ReviewInitial 
            : (state as ReviewRated);
        
        final newReview = ReviewEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          psicologoId: currentState.psicologoId!,
          userName: 'Usuário Atual',
          rating: _rating,
          comment: comentarioController.text.trim(),
          date: DateTime.now(),
        );

        await _repository.addReview(newReview);
        final updatedReviews = await _repository.getReviewsByPsicologoId(currentState.psicologoId!);
        
        _rating = 0;
        comentarioController.clear();
        
        emit(ReviewSuccess(
          message: 'Avaliação enviada com sucesso!',
          psicologoId: currentState.psicologoId!,
          psicologoNome: currentState.psicologoNome!,
          reviews: updatedReviews,
        ));
      } catch (e) {
        emit(ReviewError(message: 'Erro ao enviar avaliação: ${e.toString()}'));
      }
    }
  }

  Future<void> deleteReview(String reviewId) async {
    if (state is ReviewInitial || state is ReviewRated || state is ReviewSuccess) {
      try {
        ReviewState currentState = state;
        String psicologoId;
        String psicologoNome;
        
        if (currentState is ReviewInitial) {
          psicologoId = currentState.psicologoId;
          psicologoNome = currentState.psicologoNome;
        } else if (currentState is ReviewRated) {
          psicologoId = currentState.psicologoId;
          psicologoNome = currentState.psicologoNome;
        } else {
          currentState = currentState as ReviewSuccess;
          psicologoId = currentState.psicologoId;
          psicologoNome = currentState.psicologoNome;
        }
        
        await _repository.deleteReview(reviewId);
        final updatedReviews = await _repository.getReviewsByPsicologoId(psicologoId);
        
        emit(ReviewDeleted(
          message: 'Comentário excluído com sucesso!',
          psicologoId: psicologoId,
          psicologoNome: psicologoNome,
          reviews: updatedReviews,
        ));
      } catch (e) {
        emit(ReviewError(message: 'Erro ao excluir avaliação: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    comentarioController.dispose();
    return super.close();
  }
}