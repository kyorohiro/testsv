import 'dart:async';
import 'dart:convert' as conv;
abstract class HttpServerManager {
  Future<HttpServer> bind(String address, int port, {SecurityContext c});
}

abstract class HttpServer {
  Stream<HttpHandle> requests;
  Future<HttpServer> close();
}

abstract class SecurityContext{
  void useCertificateChain(String file, String passwd);
  void usePrivateKey(String key, String password);
}

class HttpHandle {
  HttpRequest request;
  HttpResponse response;
  HttpHandle(this.request, this.response);
}

abstract class HttpRequest {
  String get method;
  Uri get uri;
  Map<String, List<String>> get header;
  Stream<List<int>> get data;
}

abstract class HttpResponse {
  int statusCode;
  void add(List<int> data);
  void addString(String data, {conv.Encoding codec=conv.UTF8}) {
    add(codec.encode(data));
  }
  void addHeader(String name, String value);
  Future<HttpResponse> close();
}
