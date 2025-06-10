import 'package:flutter/material.dart';
import '../../../domain/entities/review_entity.dart';

abstract class ReviewState {
  const ReviewState();
  
  String? get psicologoId => null;
  String? get psicologoNome => null;
  String? get psicologoCrp => null;

  int get get_rating => 0;

  List<ReviewEntity> get reviews => const  [];
}

class ReviewInitial extends ReviewState {
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  @override
  final String psicologoCrp;
  final List<ReviewEntity> reviews;
  @override
  int get get_rating => 0;
  
  const ReviewInitial({
    required this.psicologoId,
    required this.psicologoNome,
    required this.psicologoCrp,
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
  @override
  final String psicologoCrp;
  final List<ReviewEntity> reviews;
  final int rating;
  final TextEditingController comentarioController;
  
  const ReviewRated({
    required this.psicologoId,
    required this.psicologoNome,
    required this.psicologoCrp,
    required this.reviews,
    required this.rating,
    required this.comentarioController,
  });

  @override
  int get get_rating => this.rating;
}

class ReviewSuccess extends ReviewState {
  final String message;
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  @override
  final String psicologoCrp;
  final List<ReviewEntity> reviews;
  final int rating;
  
  const ReviewSuccess({
    required this.message,
    required this.psicologoId,
    required this.psicologoNome,
    required this.psicologoCrp,
    required this.reviews,
    required this.rating,
  });

  @override
  int get get_rating => this.rating;
}

class ReviewDeleted extends ReviewState {
  @override
  final String psicologoId;
  @override
  final String psicologoNome;
  @override
  final String psicologoCrp;
  final List<ReviewEntity> reviews;
  final int rating;
  TextEditingController? comentarioController;
  String? message;

  ReviewDeleted({
    required this.psicologoId,
    required this.psicologoNome,
    required this.psicologoCrp,
    required this.reviews,
    required this.rating,
    this.comentarioController,
    this.message,
  });

  @override
  int get get_rating => this.rating;
}

class ReviewError extends ReviewState {
  final String message;
  @override
  final String? psicologoId;
  @override
  final String? psicologoNome;
  @override
  final String? psicologoCrp;
  final List<ReviewEntity> reviews;
  
  const ReviewError({
    required this.message,
    this.psicologoId,
    this.psicologoNome,
    this.psicologoCrp,
    this.reviews = const [],
  });

  @override
  int get get_rating => 0;
}