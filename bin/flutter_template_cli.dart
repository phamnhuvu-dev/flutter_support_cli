import 'package:args/args.dart';
import 'package:flutter_template_cli/flutter_template_cli.dart' as flutter_template_cli;
import 'dart:io';

import 'package:flutter_template_cli/widget/widget_template.dart';


const name = "name";
const widget = "widget";
const state = "state";
ArgResults argResults;

main(List<String> arguments) {
  print('Hello world: ${flutter_template_cli.calculate()}!');
  print(Directory.current.path);

  final parser = new ArgParser()
    ..addOption(name, defaultsTo: "", abbr: "n")
    ..addFlag(widget, negatable: false, abbr: "w")
    ..addFlag(state, negatable: false, abbr: "s");
  argResults = parser.parse(arguments);

  if (argResults[widget]) {
    buildWidget(name: argResults[name], isStateful: argResults[state]);
  }
}
