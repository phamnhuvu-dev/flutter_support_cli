import 'package:meta/meta.dart';

String getClass({
  bool isAbstract = false,
  String import = "",
  @required String name,
  String extend = "",
  String implement = "",
  String body = "",
}) {
  String abstract = "";
  import = import.isNotEmpty ?  "import '$import';\n\n" : "";
  extend = extend.isNotEmpty ? " extends $extend": "";
  implement = implement.isNotEmpty ? " implements $extend": "";

  return """
$import${abstract}class $name$extend$implement {

$body
}
""";
}