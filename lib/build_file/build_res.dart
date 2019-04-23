import 'dart:convert';
import 'dart:io';

import 'package:flutter_support_cli/template/class.dart';

RegExp regExpFileWithType = RegExp(r"[^\/]+$");
RegExp regExpFileWithoutType = RegExp(r"^([^.]+)");

void main() {
  buildImages(Directory.current.path);
  buildColors(Directory.current.path);
  buildFonts(Directory.current.path);
}

void buildSyncResource(String rootPath) {
  Directory.current = rootPath;
  buildImages(rootPath);
  buildColors(rootPath);
  buildFonts(rootPath);
}

void buildImages(String rootPath) {
  Directory dir = Directory("$rootPath/res/images");

  List<FileSystemEntity> files = dir.listSync();

  String bodyFile = "";
  String images = "  assets:";
  files.sort((a, b) => a.path.compareTo(b.path));
  bodyFile += "  static const String _path = \"res/images/\";\n";
  files.forEach((file) {
    final fileName = regExpFileWithType.stringMatch(file.path);
    bodyFile +=
        "  static const String ${regExpFileWithoutType.stringMatch(fileName)} = \"\${_path}$fileName\";\n";
    images += "\n    - res/images/$fileName";
  });
  File file = File("$rootPath/lib/statics/app_images.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(getClass(name: "AppImages", body: bodyFile));

  File filePub = File("pubspec.yaml");
  String strFilePub = filePub.readAsStringSync();

  RegExp regExpAssets = RegExp(r"^(  assets:\n?)(    - [^\s]+\n?)*", multiLine: true);
  if (regExpAssets.hasMatch(strFilePub)) {
    String strReplace = regExpAssets.stringMatch(strFilePub);
    images += "\n";
    strFilePub = strFilePub.replaceAll(strReplace, images);
  } else {
    strFilePub += "\n\n$images";
  }
  filePub.writeAsStringSync(strFilePub);
}

void buildColors(String rootPath) {
  File fileJson = File("$rootPath/res/colors.json");
  Map map = jsonDecode(fileJson.readAsStringSync());
  String bodyFile = "";
  map.forEach((key, hex) {
    String value;
    if (hex.length > 7) {
      value = (int.parse(hex.substring(1), radix: 16) + 0x00000000)
          .toRadixString(16)
          .toUpperCase();
    } else {
      value = (int.parse(hex.substring(1), radix: 16) + 0xFF000000)
          .toRadixString(16)
          .toUpperCase();
    }
    bodyFile += "  static const Color $key = Color(0x$value);\n";
  });

  File file = File("$rootPath/lib/statics/app_colors.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(getClass(import: "import 'package:flutter/material.dart' show Color;", name: "AppColors", body: bodyFile));
}

void buildFonts(String rootPath) {
  //  Init Current font family
  String currentFontFamily = "####";

  //  Get font family name
  RegExp regExpFontFamily = RegExp(r"^\w+");

  // Get whole fonts string in pubspec.yaml file
  RegExp regExpAssets = RegExp(r"^(  fonts:\n?)((    - family: \w+\n?)*(      fonts:\n?)*(        - asset: .+\n?)*((          style: |          weight: ).+\n?)*)*", multiLine: true);

  //Read pubspec.yaml file
  File filePub = File("pubspec.yaml");
  String strFilePub = filePub.readAsStringSync();

  Directory dir = Directory("$rootPath/res/fonts");
  List<FileSystemEntity> files = dir.listSync();

  String bodyFile = "";
  String fonts = "  fonts:";

  files.sort((a, b) => a.path.compareTo(b.path));
  files.forEach((file) {
    final fileName = regExpFileWithType.stringMatch(file.path);
    if (!fileName.contains(currentFontFamily)) {
      currentFontFamily = regExpFontFamily.stringMatch(fileName);
      fonts += """\n    - family: $currentFontFamily
      fonts:""";
      bodyFile += "  static const String $currentFontFamily = \"$currentFontFamily\";\n";
    }

    fonts += "\n        - asset: res/fonts/$fileName";
  });

  File file = File("$rootPath/lib/statics/app_fonts.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(getClass(name: "AppFonts", body: bodyFile));

  if (regExpAssets.hasMatch(strFilePub)) {
    String strReplace = regExpAssets.stringMatch(strFilePub);
    fonts += "\n";
    strFilePub = strFilePub.replaceAll(strReplace, fonts);
  } else {
    strFilePub += "\n\n$fonts";
  }
  filePub.writeAsStringSync(strFilePub);
}
