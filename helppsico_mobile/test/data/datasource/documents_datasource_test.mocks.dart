
import 'dart:async' as _i3;

import 'package:helppsico_mobile/core/services/http/generic_http_service.dart'
    as _i2;
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
