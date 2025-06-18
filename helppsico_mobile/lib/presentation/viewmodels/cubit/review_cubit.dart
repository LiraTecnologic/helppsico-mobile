import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

import '../../../data/repositories/review_repository.dart';
import '../../../domain/entities/review_entity.dart';

import '../state/review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  static ReviewCubit? _instance;

  final ReviewRepository _repository;
  final SecureStorageService _secureStorageService;
  final TextEditingController comentarioController = TextEditingController();

  int _rating = 0;
  String? _currentPsicologoId;
  String? _currentPsicologoNome;
  String? _currentPsicologoCrp;
  String? _currentPacienteId;
  String? _currentPacienteNome;
  String? get currentPacienteId => _currentPacienteId;

  ReviewCubit._internal(
    this._repository,
    this._secureStorageService,
  ) : super(const ReviewLoading());

  factory ReviewCubit.instance({
    ReviewRepository? repository,
    SecureStorageService? secureStorageService,
  }) {
    _instance ??= ReviewCubit._internal(
        repository ?? ReviewRepository(),
        secureStorageService ?? GetIt.instance<SecureStorageService>(),
      );
    return _instance!;
  }

  static void disposeInstance() {
    _instance?.close();
    _instance = null;
  }

  Future<void> initialize() async {
    emit(const ReviewLoading());
    try {
      final psicologoJson = await _secureStorageService.getPsicologoData();
      if (psicologoJson == null) {
        emit(const ReviewError(message: 'Faça login novamente.'));
        return;
      }
      final psicologoMap = json.decode(psicologoJson) as Map<String, dynamic>;
      _currentPsicologoId = psicologoMap['id'] as String?;
      _currentPsicologoNome = psicologoMap['nome'] as String?;
      _currentPsicologoCrp = psicologoMap['crp'] as String?;
      if (_currentPsicologoId == null || _currentPsicologoNome == null) {
        emit(const ReviewError(message: 'Dados do psicólogo incompletos.'));
        return;
      }
      _currentPacienteId = await _secureStorageService.getUserId();
      final userJson = await _secureStorageService.getUserData();
      if (_currentPacienteId == null || userJson == null) {
        emit(const ReviewError(message: 'Usuário não autenticado.'));
        return;
      }
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      _currentPacienteNome = userMap['nome'] as String? ?? 'Usuário';
      final reviews = await _repository.getReviewsByPsicologoId(_currentPsicologoId!);
      emit(ReviewInitial(
        psicologoId: _currentPsicologoId!,
        psicologoNome: _currentPsicologoNome!,
        psicologoCrp: _currentPsicologoCrp!,
        reviews: reviews,
      ));
    } catch (e) {
      emit(ReviewError(message: 'Erro ao carregar avaliações: $e'));
    }
  }

  void setRating(int rating) {
    _rating = rating;
    if (state is ReviewRated || state is ReviewInitial || state is ReviewDeleted) {
      final baseState = state;
      emit(ReviewRated(
        psicologoId: baseState.psicologoId!,
        psicologoNome: baseState.psicologoNome!,
        psicologoCrp: baseState.psicologoCrp!,
        reviews: baseState.reviews,
        rating: rating,
        comentarioController: comentarioController,
      ));
    }
  }

  Future<void> enviarAvaliacao() async {
    if (_rating == 0) return;
    final comment = comentarioController.text.trim().isEmpty
        ? 'Sem comentário'
        : comentarioController.text.trim();
    final newReview = ReviewEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      psicologoId: _currentPsicologoId!,
      pacienteId: _currentPacienteId!,
      userName: _currentPacienteNome!,
      rating: _rating,
      comment: comment,
      date: DateTime.now(),
    );
    try {
      await _repository.addReview(newReview);
      final updated = await _repository.getReviewsByPsicologoId(_currentPsicologoId!);
      comentarioController.clear();
      emit(ReviewSuccess(
        message: 'Avaliação enviada com sucesso!',
        psicologoId: _currentPsicologoId!,
        psicologoNome: _currentPsicologoNome!,
        psicologoCrp: _currentPsicologoCrp!,
        reviews: updated,
        rating: _rating,
      ));
    } catch (e) {
      emit(ReviewError(message: 'Erro ao enviar avaliação: $e'));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    if (state is ReviewInitial ||
        state is ReviewRated ||
        state is ReviewSuccess ||
        state is ReviewDeleted) {
      try {
        final psicologoId = state.psicologoId!;
        await _repository.deleteReview(reviewId);
        final updated = await _repository.getReviewsByPsicologoId(psicologoId);
        emit(ReviewDeleted(
          psicologoId: psicologoId,
          psicologoNome: state.psicologoNome!,
          psicologoCrp: state.psicologoCrp!,
          reviews: updated,
          message: 'Comentário excluído com sucesso!',
          rating: _rating,
        ));
      } catch (e) {
        emit(ReviewError(message: 'Erro ao excluir avaliação: $e'));
      }
    } else {
      emit(const ReviewError(
          message:
              'Operação não permitida no estado atual. Tente novamente.'));
    }
  }

  @override
  Future<void> close() {
    comentarioController.dispose();
    return super.close();
  }
}
