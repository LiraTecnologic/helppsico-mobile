import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/review_repository.dart';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import '../../../domain/entities/review_entity.dart';
import '../state/review_state.dart';
import 'dart:math';

class ReviewCubit extends Cubit<ReviewState> {
  static ReviewCubit? _instance;

  final ReviewRepository _repository;
  final SecureStorageService _secureStorageService;
  final TextEditingController comentarioController = TextEditingController();
  int _rating = 0;
  final String _instanceId = Random().nextInt(10000).toString();

  String? _currentPsicologoId;
  String? _currentPsicologoNome;

  ReviewCubit._internal(this._repository, this._secureStorageService)
      : super(const ReviewLoading()) {
    print('[ReviewCubit-$_instanceId] Instância INTERNA criada, estado inicial: $state');
    print('[ReviewCubit] Instance created with initial state: ReviewInitial');
  }

  factory ReviewCubit.instance({
    ReviewRepository? repository,
    SecureStorageService? secureStorageService,
  }) {
    if (_instance == null) {
      print('[ReviewCubitFactory] Criando NOVA instância única');
      _instance = ReviewCubit._internal(
        repository ?? ReviewRepository(),
        secureStorageService ?? GetIt.instance<SecureStorageService>(),
      );
    } else {
      print('[ReviewCubitFactory] Reutilizando instância EXISTENTE única');
    }
    return _instance!;
  }

  // Optional: if you need a way to dispose the singleton, e.g., for tests or app lifecycle events
  static void disposeInstance() {
    if (_instance != null) {
      print('[ReviewCubitFactory] Fechando e removendo instância única');
      _instance!.close();
      _instance = null;
    }
  }

  Future<void> initialize() async {
    print('[ReviewCubit-$_instanceId] initialize chamado, estado atual: $state');
    print('[ReviewCubit] loadReviews called');
    emit(const ReviewLoading());
    print('[ReviewCubit] Emitted ReviewLoading state');
    try {
      final psicologoDataString = await _secureStorageService.getPsicologoData();
      if (psicologoDataString == null) {
        print('[ReviewCubit-$_instanceId] Dados do psicólogo não encontrados no storage.');
        emit(const ReviewError(message: 'Dados do psicólogo não encontrados. Faça login novamente.'));
        return;
      }

      final psicologoData = json.decode(psicologoDataString);
      final psicologoId = psicologoData['id'] as String?;
      final psicologoNome = psicologoData['nome'] as String?;

      if (psicologoId == null || psicologoNome == null) {
        print('[ReviewCubit-$_instanceId] ID ou nome do psicólogo ausentes nos dados do storage.');
        emit(const ReviewError(message: 'Informações do psicólogo incompletas. Faça login novamente.'));
        return;
      }

      _currentPsicologoId = psicologoId;
      _currentPsicologoNome = psicologoNome;
      print('[ReviewCubit-$_instanceId] Psicólogo ID: $psicologoId, Nome: $psicologoNome');

      print('[ReviewCubit] Calling repository.getReviews()');
      final reviews = await _repository.getReviewsByPsicologoId(psicologoId);
      print('[ReviewCubit-$_instanceId] Reviews carregadas: ${reviews.length} avaliações');
      print('[ReviewCubit] Repository returned ${reviews.length} reviews');
      emit(ReviewInitial(
        psicologoId: psicologoId,
        psicologoNome: psicologoNome,
        reviews: reviews,
      ));
      print('[ReviewCubit-$_instanceId] [initialize] Estado atual após inicialização: $state');
      print('[ReviewCubit] Emitted ReviewLoaded state with ${reviews.length} reviews');
    } catch (e) {
      print('[ReviewCubit-$_instanceId] Erro ao inicializar: ${e.toString()}');
      print('[ReviewCubit] Error loading reviews: $e');
      emit(ReviewError(message: 'Erro ao carregar dados para avaliação: ${e.toString()}'));
      print('[ReviewCubit] Emitted ReviewError state: ${e.toString()}');
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
    print('[ReviewCubit] addReview called with review: id=${DateTime.now().millisecondsSinceEpoch.toString()}, rating=$_rating');
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

      if (_currentPsicologoId == null || _currentPsicologoNome == null) {
        emit(const ReviewError(message: 'Informações do psicólogo não disponíveis para enviar avaliação.'));
        return;
      }

      final newReview = ReviewEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        psicologoId: _currentPsicologoId!,
        userName: 'Usuário Atual', // Idealmente, obter o nome do usuário logado
        rating: _rating,
        comment: comment.isEmpty ? "Sem comentário" : comment,
        date: DateTime.now(),
      );

      print('[ReviewCubit] Calling repository.addReview()');
      await _repository.addReview(newReview);
      print('[ReviewCubit] Review added successfully, reloading reviews');
      final updatedReviews = await _repository.getReviewsByPsicologoId(_currentPsicologoId!); // Corrigido para usar _currentPsicologoId

      _rating = 0;
      comentarioController.clear();

      emit(ReviewSuccess(
        message: 'Avaliação enviada com sucesso!',
        psicologoId: _currentPsicologoId!,
        psicologoNome: _currentPsicologoNome!,
        reviews: updatedReviews,
      ));
    } catch (e) {
      print('[ReviewCubit] Error adding review: $e');
      emit(ReviewError(
        message: 'Erro ao enviar avaliação: ${e.toString()}'
      ));
      print('[ReviewCubit] Emitted ReviewError state: ${e.toString()}');
    }
  }


  String _getCurrentPsicologoId() {
    if (_currentPsicologoId == null) throw Exception("PsicologoId não inicializado no ReviewCubit");
    return _currentPsicologoId!;
  }

  String _getCurrentPsicologoNome() {
    if (_currentPsicologoNome == null) throw Exception("PsicologoNome não inicializado no ReviewCubit");
    return _currentPsicologoNome!;
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
    print('[ReviewCubit] deleteReview called with reviewId: $reviewId');

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
        
        print('[ReviewCubit] Calling repository.deleteReview()');
        await _repository.deleteReview(reviewId);
        print('[ReviewCubit] Review deleted successfully, reloading reviews');

         print("[ReviewCubit-$_instanceId] psicologoId: $psicologoId,  psicologoNome: $psicologoNome,  reviewId: $reviewId");
        final updatedReviews = await _repository.getReviewsByPsicologoId(psicologoId);
        
        emit(ReviewDeleted(
          message: 'Comentário excluído com sucesso!',
          psicologoId: psicologoId,
          psicologoNome: psicologoNome,
          reviews: updatedReviews,
        ));
      } catch (e) {
        print('[ReviewCubit] Error deleting review: $e');
        emit(ReviewError(message: 'Erro ao excluir avaliação: ${e.toString()}'));
        print('[ReviewCubit] Emitted ReviewError state: ${e.toString()}');
      }
    } else if (state is ReviewLoading) {
      print('[ReviewCubit-$_instanceId] deleteReview: Tentativa de exclusão durante o estado de carregamento. Operação não permitida.');
      emit(ReviewError(message: 'Operação de exclusão não permitida durante o carregamento. Por favor, tente novamente mais tarde.'));
    } else {
      
      print('[ReviewCubit-$_instanceId] deleteReview: Chamado em estado inesperado $state. Operação ignorada.');
      emit(ReviewError(message: 'Erro ao excluir avaliação: estado inesperado do sistema.'));
    }
  }

  Future<Map<String, String>?> getPsicologoInfo() async {
    print('[ReviewCubit] getPsicologoInfo called');
    try {
      print('[ReviewCubit] Calling repository.getPsicologoInfo()');
      final psicologoInfo = {'id': _currentPsicologoId ?? '', 'nome': _currentPsicologoNome ?? ''};
      print('[ReviewCubit] Retrieved psicologo info: $psicologoInfo');
      return psicologoInfo;
    } catch (e) {
      print('[ReviewCubit] Error getting psicologo info: $e');
      emit(ReviewError(message: e.toString()));
      print('[ReviewCubit] Emitted ReviewError state: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<void> close() {
    print('[ReviewCubit-$_instanceId] Cubit fechado.');
    comentarioController.dispose();
    return super.close();
  }
}