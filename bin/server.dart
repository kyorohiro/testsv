import 'dart:io' as io;

import 'package:args/args.dart';
import 'dart:async';
import 'dart:convert' as conv;
import 'package:testsv/httpserver_io.dart' as uni;

main(List<String> args) async {
  print("main");
  ArgParser parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('bindAddress', abbr: 'b', defaultsTo: '0.0.0.0');
  ArgResults result = parser.parse(args);

  uni.HttpServerManager manager = new uni.HttpServerManager();
  uni.HttpServer server = await manager.bind(result['bindAddress'], int.parse(result['port']));

  await for(uni.HttpHandle handle in server.requests) {
    uni.HttpRequest req = handle.request;
    uni.HttpResponse response = handle.response;
    print("${req.method} ${req.path}");
    response.statusCode = 200;

    await for(List <int> v in req.data) {
      response.add(v);
    }
    response.add(conv.UTF8.encode("Hello World!!"));
    response.close();
  }
}

