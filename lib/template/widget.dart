import 'package:flutter_template_cli/template/class.dart';

String import = "package:flutter/material.dart";
String build = """
  @override
  Widget build(BuildContext context) {
    return Container();
  }
""";

String getStatelessWidget(String name) {
  return getClass(
    import: import,
    name: name,
    extend: "StatelessWidget",
    body: build,
  );
}

String getStatefulWidget(String name) {
  String stateful = "StatefulWidget";

  String widget = getClass(
    import: import,
    name: name,
    extend: stateful,
    body: """
  @override
  _${name}State createState() => _${name}State();
""",
  );

  String state = getClass(
    name: "_${name}State",
    extend: "State<$name>",
    body: build,
  );
  return "$widget\n$state";
}
