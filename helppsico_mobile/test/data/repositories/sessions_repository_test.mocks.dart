
import 'dart:async' as _i5;

import 'package:helppsico_mobile/core/services/http/generic_http_service.dart'
    as _i2;
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart'
    as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;


class _FakeHttpResponse_0 extends _i1.SmartFake implements _i2.HttpResponse {
  _FakeHttpResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class MockSessionsDataSource extends _i1.Mock
    implements _i3.SessionsDataSource {
  MockSessionsDataSource() {
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
  _i5.Future<_i2.HttpResponse> getSessions() =>
      (super.noSuchMethod(
            Invocation.method(#getSessions, []),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(this, Invocation.method(#getSessions, [])),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);

  @override
  _i5.Future<_i2.HttpResponse> getNextSession() =>
      (super.noSuchMethod(
            Invocation.method(#getNextSession, []),
            returnValue: _i5.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(this, Invocation.method(#getNextSession, [])),
            ),
          )
          as _i5.Future<_i2.HttpResponse>);
}
