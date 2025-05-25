

import 'dart:async' as _i3;

import 'package:helppsico_mobile/core/services/http/generic_http_service.dart'
    as _i2;
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart'
    as _i4;
import 'package:mockito/mockito.dart' as _i1;


class _FakeHttpResponse_0 extends _i1.SmartFake implements _i2.HttpResponse {
  _FakeHttpResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}


class MockIGenericHttp extends _i1.Mock implements _i2.IGenericHttp {
  MockIGenericHttp() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i2.HttpResponse> get(
    String? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url], {#headers: headers}),
            returnValue: _i3.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#get, [url], {#headers: headers}),
              ),
            ),
          )
          as _i3.Future<_i2.HttpResponse>);

  @override
  _i3.Future<_i2.HttpResponse> post(
    String? url,
    dynamic body, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#post, [url, body], {#headers: headers}),
            returnValue: _i3.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#post, [url, body], {#headers: headers}),
              ),
            ),
          )
          as _i3.Future<_i2.HttpResponse>);

  @override
  _i3.Future<_i2.HttpResponse> put(
    String? url,
    dynamic body, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#put, [url, body], {#headers: headers}),
            returnValue: _i3.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#put, [url, body], {#headers: headers}),
              ),
            ),
          )
          as _i3.Future<_i2.HttpResponse>);

  @override
  _i3.Future<_i2.HttpResponse> delete(
    String? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#delete, [url], {#headers: headers}),
            returnValue: _i3.Future<_i2.HttpResponse>.value(
              _FakeHttpResponse_0(
                this,
                Invocation.method(#delete, [url], {#headers: headers}),
              ),
            ),
          )
          as _i3.Future<_i2.HttpResponse>);
}


class MockSecureStorageService extends _i1.Mock
    implements _i4.SecureStorageService {
  MockSecureStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveToken(String? token) =>
      (super.noSuchMethod(
            Invocation.method(#saveToken, [token]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<String?> getToken() =>
      (super.noSuchMethod(
            Invocation.method(#getToken, []),
            returnValue: _i3.Future<String?>.value(),
          )
          as _i3.Future<String?>);

  @override
  _i3.Future<bool> hasToken() =>
      (super.noSuchMethod(
            Invocation.method(#hasToken, []),
            returnValue: _i3.Future<bool>.value(false),
          )
          as _i3.Future<bool>);

  @override
  _i3.Future<void> deleteToken() =>
      (super.noSuchMethod(
            Invocation.method(#deleteToken, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> saveUserData(String? userData) =>
      (super.noSuchMethod(
            Invocation.method(#saveUserData, [userData]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<String?> getUserData() =>
      (super.noSuchMethod(
            Invocation.method(#getUserData, []),
            returnValue: _i3.Future<String?>.value(),
          )
          as _i3.Future<String?>);

  @override
  _i3.Future<void> deleteUserData() =>
      (super.noSuchMethod(
            Invocation.method(#deleteUserData, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(
            Invocation.method(#clearAll, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}
