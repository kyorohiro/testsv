import 'dart:async';
import 'dart:io' as dio;
import 'httpserver.dart' as umi;
class HttpServerManager extends umi.HttpServerManager{
  Future<umi.HttpServer> bind(String address, int port, {umi.SecurityContext c}) async {
    dio.HttpServer rawserver;

    if(c == null) {
     rawserver = await dio.HttpServer.bind(address, port);
    } else {
      rawserver = await dio.HttpServer.bindSecure(address, port, (c as SecurityContext).rawContext);
    }
    HttpServer server = new HttpServer(rawserver);
    return server;
  }
}

class HttpServer extends umi.HttpServer {
  dio.HttpServer _rawserver;
  dio.HttpServer get rawserver => _rawserver;
  StreamController<umi.HttpHandle> _requests;

  HttpServer(this._rawserver) {
    this._requests = new StreamController();
    this._rawserver.listen((dio.HttpRequest req) {
      _requests.add(new HttpHandle(new HttpRequest(req), new HttpResponse(req.response)));
    });
  }

  Stream<umi.HttpHandle> get requests => _requests.stream;

  Future<HttpServer> close() async {
    return this;
  }
}

class SecurityContext extends umi.SecurityContext {
  dio.SecurityContext _rawContext;
  dio.SecurityContext get rawContext => _rawContext;

  SecurityContext(){
    this._rawContext = new dio.SecurityContext();
  }

  void useCertificateChain(String file, String password) {
    this._rawContext.useCertificateChain(file, password: password);
  }

  void usePrivateKey(String key, String password) {
    this._rawContext.usePrivateKey(key, password: password);
  }
}

class HttpHandle extends umi.HttpHandle {
  HttpHandle(HttpRequest request, HttpResponse response) :super(request, response);
}

class HttpRequest extends umi.HttpRequest {
  String get method => _rawrequest.method;
  Uri get uri => _rawrequest.uri;
  Map<String,List<String>> _headers = {};
  Map<String, List<String>> get header => this._headers;
  Stream<List<int>> get data => this._rawrequest;
  dio.HttpRequest _rawrequest;
  HttpRequest(this._rawrequest) {
    this._rawrequest.headers.forEach((String header, List<String> value){
      this._headers[header] = value;
    });
  }
}

class HttpResponse extends umi.HttpResponse {
  int statusCode = 200;
  dio.HttpResponse _rawresponse;
  dio.HttpResponse get rawresponse => _rawresponse;
  HttpResponse(this._rawresponse);

  void add(List<int> data) {
    _rawresponse.add(data);
  }

  Future<HttpResponse> close() async {
    await _rawresponse.close();
    return this;
  }

  void addHeader(String name, String value) {
    _rawresponse.headers.add(name, value);
  }
}
