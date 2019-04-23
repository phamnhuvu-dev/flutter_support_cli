import 'package:flutter_support_cli/template/class.dart';

const String import = "import 'package:flutter/material.dart';";
const String buildBody = """
  @override
  Widget build(BuildContext context) {
    return Container();
  }
""";


String getStatelessWidget(String name, {String body = buildBody}) {
  return getClass(
    import: import,
    name: name,
    extend: "StatelessWidget",
    body: body,
  );
}

String getStatefulWidget(String name, {String buildBody = buildBody}) {
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
    body: buildBody,
  );
  return "$widget\n$state";
}