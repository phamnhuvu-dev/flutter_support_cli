import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_support_cli/template/class.dart';

RegExp regExpFileWithType = RegExp(r"[^\/]+$");
RegExp regExpFileWithoutType = RegExp(r"^([^.]+)");

void main() {
  String strAssets = buildStrings(Directory.current.path);
  String imgAssets = buildImages(Directory.current.path);
  buildColors(Directory.current.path);
  buildFonts(Directory.current.path);
  buildAssets(strAssets += imgAssets);
}

void buildSyncResource(String rootPath) {
  Directory.current = rootPath;

  String strAssets = buildStrings(rootPath);
  String imgAssets = buildImages(rootPath);
  buildColors(rootPath);
  buildFonts(rootPath);
  buildAssets(strAssets += imgAssets);

  Directory.current = rootPath;
  Process.runSync('flutter', ["--no-color", "packages", "get"]);
}

String buildImages(String rootPath) {
  Directory dir = Directory("$rootPath/res/images");

  List<FileSystemEntity> files = dir.listSync();

  String bodyFile = "";
  String images = "";
  files.sort((a, b) => a.path.compareTo(b.path));
  bodyFile += "  static const String _path = \"res/images/\";\n";
  files.forEach((file) {
    final fileName = regExpFileWithType.stringMatch(file.path);
    images += "\n    - res/images/$fileName";
    bodyFile +=
        "  static const String ${regExpFileWithoutType.stringMatch(fileName)} = \"\${_path}$fileName\";\n";
  });
  File file = File("$rootPath/lib/statics/app_images.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(getClass(name: "AppImages", body: bodyFile.trimRight()));

  return images;
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
  file.writeAsStringSync(getClass(
      import: "import 'package:flutter/material.dart' show Color;",
      name: "AppColors",
      body: bodyFile.trimRight()));
}

void buildFonts(String rootPath) {
  //  Init Current font family
  String currentFontFamily = "####";

  //  Get font family name
  RegExp regExpFontFamily = RegExp(r"^\w+");

  // Get whole fonts string in pubspec.yaml file
  RegExp regExpAssets = RegExp(
      r"^(  fonts:\n?)((    - family: \w+\n?)*(      fonts:\n?)*(        - asset: .+\n?)*((          style: |          weight: ).+\n?)*)*",
      multiLine: true);

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
      bodyFile +=
          "  static const String $currentFontFamily = \"$currentFontFamily\";\n";
    }

    fonts += "\n        - asset: res/fonts/$fileName";
  });

  File file = File("$rootPath/lib/statics/app_fonts.dart");
  file.createSync(recursive: true);
  file.writeAsStringSync(getClass(name: "AppFonts", body: bodyFile.trimRight()));

  if (regExpAssets.hasMatch(strFilePub)) {
    String strReplace = regExpAssets.stringMatch(strFilePub);
    fonts += "\n";
    strFilePub = strFilePub.replaceAll(strReplace, fonts);
  } else {
    strFilePub += "\n\n$fonts";
  }
  filePub.writeAsStringSync(strFilePub);
}

String buildStrings(String rootPath) {
  Directory dir = Directory("$rootPath/res/localizations");
  List<FileSystemEntity> files = dir.listSync();
  files.sort((a, b) => a.path.compareTo(b.path));
  int fileCount = files.length;
  Map<String, List<dynamic>> mapSum = SplayTreeMap();

  String assets = "";

  for (int i = 0; i < fileCount; i++) {
    final fileSE = files[i];
    final fileJSON = File(fileSE.path);
    final fileName = regExpFileWithType.stringMatch(fileSE.path);
    assets += "\n    - res/localizations/$fileName";

    try {
      Map<String, dynamic> map = jsonDecode(fileJSON.readAsStringSync());
      map.forEach((key, value) {
        List<dynamic> strings = mapSum[key] ?? List(fileCount);
        strings[i] = value;
        mapSum[key] = strings;
      });
    } catch (e) {
      print(e);
      continue;
    }
  }
  List<Map<String, String>> maps = List(fileCount);
  for (int i = 0; i < fileCount; i++) {
    maps[i] = Map();
  }

  String functions = "";
  mapSum.forEach((key, value) {
    for (int i = 0; i < fileCount; i++) {
      maps[i][key] = value[i] ?? "";
    }
    functions += "\n\n  String get $key => this._sentences['$key'];";
  });
  for (int i = 0; i < fileCount; i++) {
    final fileSE = files[i];
    final fileJSON = File(fileSE.path);
    fileJSON.writeAsStringSync(json.encode(maps[i]));
  }

  File file = File("$rootPath/lib/statics/app_localizations.dart");
  file.createSync(recursive: true);
  String import = """import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
""";

  String body1 = """  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle.loadString('res/localizations/\${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }$functions""";


  file.writeAsStringSync(getClass(
    import: import,
    name: "AppLocalizations",
    body: body1,
  ));

  String locales = files
      .map((file) =>
          "'${regExpFileWithoutType.stringMatch(regExpFileWithType.stringMatch(file.path))}'")
      .join(", ");
  String body2 = """  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [$locales].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) {
    return this != old;
  }""";

  file.writeAsStringSync(
      "\n\n${getClass(
          name: "AppLocalizationsDelegate",
          extend: "LocalizationsDelegate<AppLocalizations>",
          body: body2)}",
      mode: FileMode.append);

  return assets;
}

void buildAssets(String content) {
  String assets = "  assets:";
  assets += content;
  File filePub = File("pubspec.yaml");
  String strFilePub = filePub.readAsStringSync();

  RegExp regExpAssets =
  RegExp(r"^(  assets:\n?)(    - [^\s]+\n?)*", multiLine: true);
  if (regExpAssets.hasMatch(strFilePub)) {
    String strReplace = regExpAssets.stringMatch(strFilePub);
    assets += "\n";
    strFilePub = strFilePub.replaceAll(strReplace, assets);
  } else {
    strFilePub += "\n\n$assets";
  }
  filePub.writeAsStringSync(strFilePub);
}
