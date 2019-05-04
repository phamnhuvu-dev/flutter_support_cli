import 'package:flutter_support_cli/build_file/build_list.dart';
import 'package:flutter_support_cli/build_file/build_res.dart';
import 'package:flutter_support_cli/build_file/build_widget.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';


const name = "name";
const makeWidget = "mkwget";
const stateFull = "statefull";
const makeListWidget = "mklwget";
const syncResource = "sr";
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

  // Sync Resource Parser
  var sr = new ArgParser();

  var mkwget = ArgParser()
    ..addFlag(stateFull, negatable: false, abbr: "f")
    ..addOption(name, defaultsTo: "", abbr: "n");

  var mklwget = ArgParser()
    ..addOption(name, defaultsTo: "", abbr: "n");

  final parser = new ArgParser()
    ..addCommand(syncResource, sr)
    ..addCommand(makeWidget, mkwget)
    ..addCommand(makeListWidget, mklwget);

  argResults = parser.parse(arguments);
  switch (argResults.command.name) {
    case makeWidget:
      final argResultsMakeWidget = mkwget.parse(arguments);
      assert(argResultsMakeWidget[name] != "");
      buildWidget(name: argResultsMakeWidget[name], isStateful: argResultsMakeWidget[stateFull]);
      break;

    case makeListWidget:
      final argResultsMakeListWidget = mklwget.parse(arguments);
      assert(argResultsMakeListWidget[name] != "");
      buildListWidget(argResultsMakeListWidget[name]);
      break;

    case syncResource:
      buildSyncResource(Directory.current.parent.path);
      break;
  }
//    ..addOption(name, defaultsTo: "", abbr: "n")
//    ..addFlag(widget, negatable: false, abbr: "w")
//    ..addFlag(state, negatable: false, abbr: "s")
//    ..addFlag(list, negatable: false, abbr: "l");
//  argResults = parser.parse(arguments);
//
//  if (argResults[widget]) {
//    assert(argResults[name] != "");
//    buildWidget(name: argResults[name], isStateful: argResults[state]);
//  } else if (argResults[list]) {
//    assert(argResults[name] != "");
//    buildListWidget(argResults[name]);
//  }
}
