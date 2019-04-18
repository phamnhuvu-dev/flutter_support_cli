import 'package:flutter_template_cli/template/widget.dart';
import 'package:recase/recase.dart';

import 'dart:io';

void buildWidget({String name, bool isStateful = false}) {
  final reCase = ReCase(name);
  final file = File("${reCase.snakeCase}.dart");
  if (!file.existsSync()) {
    String content = isStateful
        ? getStatefulWidget(reCase.pascalCase)
        : getStatelessWidget(reCase.pascalCase);
    file.writeAsStringSync(content);
  }
}
