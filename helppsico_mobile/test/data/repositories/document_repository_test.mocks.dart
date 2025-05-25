
import 'dart:async' as _i5;

import 'package:helppsico_mobile/core/services/http/generic_http_service.dart'
    as _i2;
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart'
    as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;


class _FakeHttpResponse_0 extends _i1.SmartFake implements _i2.HttpResponse {
  _FakeHttpResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class MockDocumentsDataSource extends _i1.Mock
    implements _i3.DocumentsDataSource {
  MockDocumentsDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get baseUrl =>
      (super.noSuchMethod(
            Invocation.getter(#baseUrl),
            returnValue: _i4.dummyValue<String>(
              this,
              Invocation.getter(#baseUrl),
            ),
          )
          as String);

  @override
  _i5.Future<_i2.HttpResponse> getDocuments() =>
      (super.noSuchMethod(
            Invocation.method(#getDocuments, []),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(this, Invocation.method(#getDocuments, [])),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);

  @override
  _i5.Future<_i2.HttpResponse> uploadDocument(
    String? filePath,
    Map<String, dynamic>? metadata,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#uploadDocument, [filePath, metadata]),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#uploadDocument, [filePath, metadata]),
              ),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);

  @override
  _i5.Future<_i2.HttpResponse> updateDocument(
    String? documentId,
    Map<String, dynamic>? data,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateDocument, [documentId, data]),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#updateDocument, [documentId, data]),
              ),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);

  @override
  _i5.Future<_i2.HttpResponse> deleteDocument(String? documentId) =>
      (super.noSuchMethod(
            Invocation.method(#deleteDocument, [documentId]),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#deleteDocument, [documentId]),
              ),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);

  @override
  _i5.Future<_i2.HttpResponse> toggleFavorite(String? documentId) =>
      (super.noSuchMethod(
            Invocation.method(#toggleFavorite, [documentId]),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#toggleFavorite, [documentId]),
              ),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);
}
