
import 'dart:async' as _i4;

import 'package:helppsico_mobile/data/datasource/review_datasource.dart' as _i2;
import 'package:helppsico_mobile/domain/entities/review_entity.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i3;


class MockReviewDataSource extends _i1.Mock implements _i2.ReviewDataSource {
  MockReviewDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get baseUrl =>
      (super.noSuchMethod(
            Invocation.getter(#baseUrl),
            returnValue: _i3.dummyValue<String>(
              this,
              Invocation.getter(#baseUrl),
            ),
          )
          as String);

  @override
  _i4.Future<List<_i5.ReviewEntity>> getReviewsByPsicologoId(
    String? psicologoId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getReviewsByPsicologoId, [psicologoId]),
            returnValue: _i4.Future<List<_i5.ReviewEntity>>.value(
              <_i5.ReviewEntity>[],
            ),
          )
          as _i4.Future<List<_i5.ReviewEntity>>);

  @override
  _i4.Future<void> addReview(_i5.ReviewEntity? review) =>
      (super.noSuchMethod(
            Invocation.method(#addReview, [review]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deleteReview(String? reviewId) =>
      (super.noSuchMethod(
            Invocation.method(#deleteReview, [reviewId]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
