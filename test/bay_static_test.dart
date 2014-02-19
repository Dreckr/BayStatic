library bay.test;

import 'dart:async';
import 'package:bay/bay.dart';
import 'package:bay_static/bay_static.dart';
import 'package:logging/logging.dart';

void main () {
  Bay.init([new BayStaticModule(rootDirectory: "static")], port: 8080);
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}.'
          '${rec.error != null ? '${rec.error}\n${rec.stackTrace}' : ''}');
  });
  
}
