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

  void initialize(String psicologoId, String psicologoNome) {
    final reviews = _repository.getReviewsByPsicologoId(psicologoId);
    emit(ReviewInitial(
      psicologoId: psicologoId,
      psicologoNome: psicologoNome,
      reviews: reviews,
    ));
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

  void enviarAvaliacao() {
    if (_rating == 0) {
      emit(const ReviewError(message: 'Por favor, selecione uma nota para a avaliação'));
      return;
    }

    if (state is ReviewInitial || state is ReviewRated) {
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

      _repository.addReview(newReview);
      final updatedReviews = _repository.getReviewsByPsicologoId(currentState.psicologoId!);
      
      _rating = 0;
      comentarioController.clear();
      
      emit(ReviewSuccess(
        message: 'Avaliação enviada com sucesso!',
        psicologoId: currentState.psicologoId!,
        psicologoNome: currentState.psicologoNome!,
        reviews: updatedReviews,
      ));
    }
  }

  void deleteReview(String reviewId) {
    if (state is ReviewInitial || state is ReviewRated || state is ReviewSuccess) {
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
      
      _repository.deleteReview(reviewId);
      final updatedReviews = _repository.getReviewsByPsicologoId(psicologoId);
      
      emit(ReviewDeleted(
        message: 'Comentário excluído com sucesso!',
        psicologoId: psicologoId,
        psicologoNome: psicologoNome,
        reviews: updatedReviews,
      ));
    }
  }

  @override
  Future<void> close() {
    comentarioController.dispose();
    return super.close();
  }
}