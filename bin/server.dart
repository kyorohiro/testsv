import 'dart:io' as io;

import 'package:args/args.dart';
import 'dart:async';
import 'dart:convert' as conv;
import 'package:testsv/httpserver_io.dart' as uni;
import 'package:testsv/httpserver.dart' as umi;

typedef Future<Route<X>> OnHandle<X>(X v);
class Route<X> {
  Map<Pattern, OnHandle<X>> _m = {};
  Route<X> addHandler(Pattern p, OnHandle<X> v) {
    _m[p] = v;
    return this;
  }

  Future<Route<X>> execute(String key, X x) async {
    print("## ${_m.length}");
    for(Pattern p in _m.keys) {
      print("${p.toString()}");
      if(key.contains(p)) {
        _m[p](x);
        return this;
      }
    }
    return this;
  }
}

Route<uni.HttpHandle> route = new Route();

Future<Route<uni.HttpHandle>> handleHome(uni.HttpHandle v) {
  print(">>>S3");
  v.response.statusCode = 200;
  v.response.addHeader("Content-Type", "text/html; charset=utf-8");
  v.response.addString("<html>");
  v.response.addString(" <head><title>Home Page</title></head>");
  v.response.addString(" <body>");
  v.response.addString("  <div>");
  v.response.addString("  Hello, World!!");
  v.response.addString("  </div>");
  v.response.addString(" </body>");
  v.response.addString("</html>");
  v.response.close();
}

class TinyServerBuilder {
  String address = "0.0.0.0";
  int port = 80;
  bool useSSL = false;
  umi.SecurityContext context = null;
  Route route = new Route();
  TinyServerBuilder();
  TinyServer build() {
    return new TinyServer.fromBuilder(this);
  }
}

class TinyServer {
  String _address;
  bool _useSSL;
  umi.SecurityContext _context;
  Route _route;
  int _port;

  TinyServer.fromBuilder(TinyServerBuilder builder) {
    this._address = builder.address;
    this._useSSL = builder.useSSL;
    this._context = builder.context;
    this._route = builder.route;
    this._port = builder.port;
  }

  Future<TinyServer> start() async {
    uni.HttpServerManager manager = new uni.HttpServerManager();
    uni.HttpServer server = await manager.bind(this._address, this._port, c:this._context);
    await for(uni.HttpHandle handle in server.requests) {
      print(">>>S1");
      uni.HttpRequest req = handle.request;
      uni.HttpResponse response = handle.response;
      print("${req.method} ${req.uri}");
      this._route.execute(req.uri.path, handle);
      print(">>>S2");
    }
    return this;
  }
}

main(List<String> args) async {
  print("main");
  ArgParser parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('bindAddress', abbr: 'b', defaultsTo: '0.0.0.0');
  ArgResults result = parser.parse(args);

  TinyServerBuilder builder = new TinyServerBuilder();
  builder.port = int.parse(result['port']);
  builder.address = result['bindAddress'];
  builder.route.addHandler(new RegExp(r"^/$"), handleHome);
  TinyServer server = builder.build();
  server.start();
}



