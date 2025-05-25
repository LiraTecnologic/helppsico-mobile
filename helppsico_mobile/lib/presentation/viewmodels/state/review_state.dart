import 'package:flutter/material.dart';
import '../../../domain/entities/review_entity.dart';

abstract class ReviewState {
  const ReviewState();
  
  String? get psicologoId => null;
  String? get psicologoNome => null;
}

class ReviewInitial extends ReviewState {
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  final List<ReviewEntity> reviews;
  
  const ReviewInitial({
    required this.psicologoId,
    required this.psicologoNome,
    required this.reviews,
  });
}

class ReviewLoading extends ReviewState {
  

  const ReviewLoading();
}

class ReviewRated extends ReviewState {
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  final List<ReviewEntity> reviews;
  final int rating;
  final TextEditingController comentarioController;
  
  const ReviewRated({
    required this.psicologoId,
    required this.psicologoNome,
    required this.reviews,
    required this.rating,
    required this.comentarioController,
  });
}

class ReviewSuccess extends ReviewState {
  final String message;
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  final List<ReviewEntity> reviews;
  
  const ReviewSuccess({
    required this.message,
    required this.psicologoId,
    required this.psicologoNome,
    required this.reviews,
  });
}

class ReviewDeleted extends ReviewState {
   @override
  final String psicologoId;
  @override
  final String psicologoNome;
  final List<ReviewEntity> reviews;
  final int rating;
  TextEditingController? comentarioController;
  String? message;

  ReviewDeleted({
    required this.psicologoId,
    required this.psicologoNome,
    required this.reviews,
    this.rating = 0,
    this.comentarioController,
    this.message,
  });
}

class ReviewError extends ReviewState {
  final String message;
  @override
  final String? psicologoId;
  @override
  final String? psicologoNome;
  final List<ReviewEntity> reviews;
  
  const ReviewError({
    required this.message,
    this.psicologoId,
    this.psicologoNome,
    this.reviews = const [], // Default to an empty list if not provided
  });
}