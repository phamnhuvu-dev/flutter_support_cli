import 'dart:io';

import 'package:flutter_support_cli/template/list.dart';
import 'package:recase/recase.dart';

void buildListWidget(String name) {
  ReCase reCase = ReCase(name);
  final dir = Directory(reCase.snakeCase);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    Directory.current = dir.path;

    final listFile = File("list_${name.toLowerCase()}_widget.dart");
    final itemFile = File("item_${name.toLowerCase()}_widget.dart");

    listFile.writeAsStringSync(getListWidget(name));
    itemFile.writeAsStringSync(getItemWidget(name));
  }
}