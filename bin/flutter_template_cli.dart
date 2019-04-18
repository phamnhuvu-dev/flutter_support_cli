import 'package:flutter_template_cli/build_file/build_list.dart';
import 'package:flutter_template_cli/build_file/build_widget.dart';
import 'package:flutter_template_cli/flutter_template_cli.dart'
    as flutter_template_cli;
import 'dart:io';
import 'package:args/args.dart';


const name = "name";
const widget = "widget";
const state = "state";
const list = "list";
ArgResults argResults;

main(List<String> arguments) {
//  print('Hello world: ${flutter_template_cli.calculate()}!');
  String currentPath = Directory.current.path;
  if (currentPath.contains('lib') ||
      Directory("$currentPath/lib").existsSync()) {
    if (currentPath.contains('lib')) {
      RegExp exp = new RegExp(r"(lib)");
      Directory.current =
          currentPath.substring(0, exp.firstMatch(currentPath).end);
    } else {
      Directory.current = "$currentPath/lib";
    }
    print(Directory.current.path);
  } else {
    print("Error: Please use command line in your project");
  }

  final parser = new ArgParser()
    ..addOption(name, defaultsTo: "", abbr: "n")
    ..addFlag(widget, negatable: false, abbr: "w")
    ..addFlag(state, negatable: false, abbr: "s")
    ..addFlag(list, negatable: false, abbr: "l");
  argResults = parser.parse(arguments);

  if (argResults[widget]) {
    assert(argResults[name] != "");
    buildWidget(name: argResults[name], isStateful: argResults[state]);
  } else if (argResults[list]) {
    assert(argResults[name] != "");
    buildListWidget(argResults[name]);
  }
}
