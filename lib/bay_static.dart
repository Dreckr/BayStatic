library bay.static;

import 'dart:async';
import 'dart:io';
import 'package:bay/bay.dart';
import 'package:http_server/http_server.dart' show VirtualDirectory;

class BayStaticModule extends DeclarativeModule {
  
  BayStaticRequestHandler requestHandler;
  
  @BayStaticRoot 
  String root;
  
  BayStaticModule([this.root = "."]);
}

class BayStaticRequestHandler extends RequestHandler {
  final VirtualDirectory _virtualDirectory;
  
  BayStaticRequestHandler(@BayStaticRoot String root) : 
    _virtualDirectory = new VirtualDirectory(root);
  
  bool accepts(HttpRequest request) => true;
  
  Future<HttpRequest> handle(HttpRequest request) {
    var completer = new Completer<HttpRequest>();
    
    _virtualDirectory.serveRequest(request);
    request.response.done.then(
        (_) => completer.complete(request),
        onError: (error, stackTrace) => 
            completer.completeError(error));
    
    return completer.future;
  }
}

const BayStaticRoot = const BayStaticRootAnnotation._();
class BayStaticRootAnnotation implements BindingAnnotation {
  
  const BayStaticRootAnnotation._();
}