library bay.static;

import 'dart:async';
import 'dart:io';
import 'package:bay/bay.dart';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:uri/uri.dart';

class BayStaticModule extends DeclarativeModule {
  
  BayStaticRequestHandler requestHandler;
  
  @BayStaticPath('root')
  String rootDirectory;
  
  @BayStaticPath('path')
  String path;
  
  BayStaticModule({this.rootDirectory: ".", this.path:"/"});
}

class BayStaticRequestHandler extends RequestHandler {
  final Uri _rootDirectory;
  final VirtualDirectory _virtualDirectory;
  final UriPattern _pathPattern;
  
  BayStaticRequestHandler(@BayStaticPath('root') String root,
                          @BayStaticPath('path') String path) : 
    _rootDirectory = new Uri.file(root),                     
    _virtualDirectory = new VirtualDirectory(root),
    _pathPattern = new UriParser(new UriTemplate(path)) {
    
    _virtualDirectory..allowDirectoryListing = true
                     ..followLinks = true
                     ..jailRoot = true;
  }
  
  bool accepts(HttpRequest request) => resolveFile(request) != null;
  
  Future<HttpRequest> handle(HttpRequest request) {
    var filePath = resolveFile(request);
    _virtualDirectory.serveFile(new File(filePath), request);
    
    return request.response.done.then((_) => request);
  }
  
  String resolveFile(HttpRequest request) {
    var match = _pathPattern.match(request.uri);
    
    if (match == null) {
      return null;
    }
    
    var fileUri = new Uri.file(_rootDirectory.path + 
                                Platform.pathSeparator + 
                                match.rest.path);
    
    var filePath = fileUri.toFilePath(windows: Platform.isWindows);
    
    if (FileSystemEntity.isFileSync(filePath)) {
      return filePath;
    } else if (FileSystemEntity.isDirectorySync(filePath) &&
                request.uri.path.endsWith("/")) {
      fileUri = fileUri.resolve("index.html");
      filePath = fileUri.toFilePath(windows: Platform.isWindows);
      
      if (FileSystemEntity.isFileSync(filePath)) {
        return filePath;
      }
    }
    
    return null;
  }
}

class BayStaticPath implements BindingAnnotation {
  final String type;
  
  const BayStaticPath(this.type);
}