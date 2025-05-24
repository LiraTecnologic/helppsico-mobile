import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../domain/entities/review_entity.dart';
import '../state/review_state.dart';
import 'dart:math';





class ReviewCubit extends Cubit<ReviewState> {
  static final Map<String, ReviewCubit> _instances = {};
  static final Map<String, int> _refCounts = {};

  final ReviewRepository _repository;
  final TextEditingController comentarioController = TextEditingController();
  int _rating = 0;
  final String _instanceId = Random().nextInt(10000).toString(); 

 
  ReviewCubit._internal(this._repository, String psicologoId, String psicologoNome)
      : super(const ReviewLoading()) {
    print('[ReviewCubit-$_instanceId] Instância INTERNA criada para $psicologoId, estado inicial: $state');
    
  }


  factory ReviewCubit.instanceFor(String psicologoId, String psicologoNome, {ReviewRepository? repository}) {
    if (!_instances.containsKey(psicologoId)) {
      print('[ReviewCubitFactory] Criando NOVA instância para $psicologoId');
      _instances[psicologoId] = ReviewCubit._internal(
        repository ?? ReviewRepository(),
        psicologoId,
        psicologoNome,
      );
      _refCounts[psicologoId] = 0;
      
    } else {
      print('[ReviewCubitFactory] Reutilizando instância EXISTENTE para $psicologoId');
    }
    _refCounts[psicologoId] = (_refCounts[psicologoId] ?? 0) + 1;
    print('[ReviewCubitFactory] Contagem de referência para $psicologoId: ${_refCounts[psicologoId]}');
    return _instances[psicologoId]!;
  }

  static void disposeInstance(String psicologoId) {
    if (_instances.containsKey(psicologoId)) {
      _refCounts[psicologoId] = (_refCounts[psicologoId] ?? 1) - 1;
      print('[ReviewCubitFactory] Contagem de referência para $psicologoId após dispose: ${_refCounts[psicologoId]}');
      if (_refCounts[psicologoId]! <= 0) {
        print('[ReviewCubitFactory] Fechando e removendo instância para $psicologoId');
        _instances[psicologoId]!.close();
        _instances.remove(psicologoId);
        _refCounts.remove(psicologoId);
      } else {
        print('[ReviewCubitFactory] Instância para $psicologoId ainda em uso, não fechada.');
      }
    }
  }


  Future<void> initialize (String psicologoId, String psicologoNome) async {
    print('[ReviewCubit-$_instanceId] initialize chamado com psicologoId: $psicologoId, psicologoNome: $psicologoNome, estado atual: $state');
    try {
      final reviews = await _repository.getReviewsByPsicologoId(psicologoId);
      print('[ReviewCubit-$_instanceId] Reviews carregadas: ${reviews.length} avaliações');
      emit(ReviewInitial(
        psicologoId: psicologoId,
        psicologoNome: psicologoNome,
        reviews: reviews,
      ));
      print('[ReviewCubit-$_instanceId] [initialize] Estado atual após inicialização: $state');
    } catch (e) {
      emit(ReviewError(message: 'Erro ao carregar avaliações: ${e.toString()}'));
    }
  }

  void setRating(int rating) {
    print('[ReviewCubit-$_instanceId] setRating chamado com rating: $rating, estado atual: $state');
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
    } else if (state is ReviewDeleted){
      final currentState = state as ReviewDeleted;
      emit(ReviewRated(
        psicologoId: currentState.psicologoId,
        psicologoNome: currentState.psicologoNome,
        reviews: currentState.reviews,
        rating: rating, 
        comentarioController: comentarioController,
      ));
    } else if (state is ReviewSuccess) { 
      final currentState = state as ReviewSuccess;
      emit(ReviewRated(
        psicologoId: currentState.psicologoId,
        psicologoNome: currentState.psicologoNome,
        reviews: currentState.reviews,
        rating: rating,
        comentarioController: comentarioController,
      ));
    } else if (state is ReviewError && (state as ReviewError).reviews.isNotEmpty) { 
      final currentState = state as ReviewError;
      emit(ReviewRated(
        psicologoId: currentState.psicologoId!,
        psicologoNome: currentState.psicologoNome!,
        reviews: currentState.reviews,
        rating: rating,
        comentarioController: comentarioController,
      ));
    }
  }

  Future<void> enviarAvaliacao() async {
    print('[ReviewCubit-$_instanceId] enviarAvaliacao chamado com rating: $_rating, comentário: ${comentarioController.text}, estado atual: $state');
    try {
      if (_rating == 0) {
        if (state is ReviewInitial || state is ReviewRated) {
        
          emit(state);
        }
        return;
      }

  
      final List<ReviewEntity> currentReviews2 = _getCurrentReviews();
      final String currentPsicologoId = _getCurrentPsicologoId();
      final String currentPsicologoNome = _getCurrentPsicologoNome();
      if (currentReviews2.any((review) => review.userName == 'Usuário Atual')) {
        emit(ReviewError(
          message: 'Você já possui uma avaliação para este psicólogo. Exclua a avaliação anterior para adicionar uma nova.',
          reviews: currentReviews2,
          psicologoId: currentPsicologoId,
          psicologoNome: currentPsicologoNome,
        ));
        return;
      }

      final comment = comentarioController.text.trim();
      final currentState = state;
      
      if (currentState is! ReviewInitial && currentState is! ReviewRated) {
        return;
      }

      String psicologoId;
      String psicologoNome;
      List<ReviewEntity> currentReviews;
  
      if (currentState is ReviewInitial) {
        psicologoId = currentState.psicologoId;
        psicologoNome = currentState.psicologoNome;
        currentReviews = currentState.reviews;
      } else {
        final ratedState = currentState as ReviewRated;
        psicologoId = ratedState.psicologoId;
        psicologoNome = ratedState.psicologoNome;
        currentReviews = ratedState.reviews;
      }
  
      final newReview = ReviewEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        psicologoId: psicologoId,
        userName: 'Usuário Atual',
        rating: _rating,
        comment: comment.isEmpty ? "Sem comentário" : comment,
        date: DateTime.now(),
      );
  
      psicologoId = _getCurrentPsicologoId();

      await _repository.addReview(newReview);
      final updatedReviews = await _repository.getReviewsByPsicologoId(psicologoId);
      
      _rating = 0;
      comentarioController.clear();
      
      emit(ReviewSuccess(
        message: 'Avaliação enviada com sucesso!',
        psicologoId: psicologoId,
        psicologoNome: psicologoNome,
        reviews: updatedReviews,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'Erro ao enviar avaliação: ${e.toString()}'
      ));
    }
  }


  String _getCurrentPsicologoId() {
    print('[ReviewCubit-$_instanceId] _getCurrentPsicologoId chamado, state: $state');
    if (state is ReviewInitial) {
      return (state as ReviewInitial).psicologoId;
    } else if (state is ReviewRated) {
      return (state as ReviewRated).psicologoId;
    } else if (state is ReviewSuccess) {
      return (state as ReviewSuccess).psicologoId;
    }
    return '';
  }

  String _getCurrentPsicologoNome() {
    print('[ReviewCubit-$_instanceId] _getCurrentPsicologoNome chamado, state: $state');
    if (state is ReviewInitial) {
      return (state as ReviewInitial).psicologoNome;
    } else if (state is ReviewRated) {
      return (state as ReviewRated).psicologoNome;
    } else if (state is ReviewSuccess) {
      return (state as ReviewSuccess).psicologoNome;
    }
    return '';
  }

  List<ReviewEntity> _getCurrentReviews() {
    print('[ReviewCubit-$_instanceId] _getCurrentReviews chamado, state: $state');
    if (state is ReviewInitial) {
      return (state as ReviewInitial).reviews;
    } else if (state is ReviewRated) {
      return (state as ReviewRated).reviews;
    } else if (state is ReviewSuccess) {
      return (state as ReviewSuccess).reviews;
    }
    return [];
  }

  Future<void> deleteReview(String reviewId) async {
    print('[ReviewCubit-$_instanceId] deleteReview chamado para reviewId: $reviewId, estado atual: $state');

    if (state is ReviewInitial || state is ReviewRated || state is ReviewSuccess || state is ReviewDeleted) {
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
        } else if (currentState is ReviewDeleted) {
          psicologoId = currentState.psicologoId;
          psicologoNome = currentState.psicologoNome;
        } else if (currentState is ReviewSuccess){ 
          psicologoId = currentState.psicologoId;
          psicologoNome = currentState.psicologoNome;
        }else{
          final errorState = currentState as ReviewError;
          psicologoId = errorState.psicologoId!;
          psicologoNome = errorState.psicologoNome!; 
        }
        
        await _repository.deleteReview(reviewId);

         print("[ReviewCubit-$_instanceId] psicologoId: $psicologoId,  psicologoNome: $psicologoNome,  reviewId: $reviewId");
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
    } else if (state is ReviewLoading) {
      print('[ReviewCubit-$_instanceId] deleteReview: Tentativa de exclusão durante o estado de carregamento. Operação não permitida.');
      emit(ReviewError(message: 'Operação de exclusão não permitida durante o carregamento. Por favor, tente novamente mais tarde.'));
    } else {
      
      print('[ReviewCubit-$_instanceId] deleteReview: Chamado em estado inesperado $state. Operação ignorada.');
      emit(ReviewError(message: 'Erro ao excluir avaliação: estado inesperado do sistema.'));
    }
  }

  @override
  Future<void> close() {
    print('[ReviewCubit-$_instanceId] Cubit fechado.');
    comentarioController.dispose();
    return super.close();
  }
}