import 'package:flutter_template_cli/template/widget.dart';
import 'package:recase/recase.dart';

String getItemWidget(String name) {
  return getStatelessWidget("Item${name}Widget", body: getItemBody(name));
}

String getItemBody(String nameModel) {
  ReCase reCase = ReCase(nameModel);
  String pascal = reCase.pascalCase;
  String camel = reCase.camelCase;
  return """
  final $pascal $camel;
  
  const ItemCardWidget({
    Key key,
    this.$camel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
""";
}

String getListWidget(String name) {
  return getStatelessWidget("List${name}Widget", body: getListBody(name));
}

String getListBody(String nameModel) {
  ReCase reCase = ReCase(nameModel);
  String pascal = reCase.pascalCase;
  String camel = reCase.camelCase;
  return """
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<${pascal}>>(
      stream: ${camel}Bloc.${camel}sStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<${pascal}>> asyncSnapshot,
      ) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
          case ConnectionState.none:
            break;
  
          case ConnectionState.waiting:
            return waiting();
  
          case ConnectionState.active:
            final ${camel}s = asyncSnapshot.data;
  
            if (asyncSnapshot.hasError) {
              return error(asyncSnapshot.error);
  
            } else if (!asyncSnapshot.hasData) {
              return waiting();
  
            } else {
              return ListView.separated(
                cacheExtent: 4.0,
                itemCount: ${camel}s.length,
  
                //// ITEM
                itemBuilder: (BuildContext context, int index) {
                  return item(${camel}s[index]);
                },
  
                //// SEPARATOR
                separatorBuilder: (BuildContext context, int index) {
                  return separator();
                  },
                );
              }
          }
        }
    );
  }
  
  Widget waiting() {
    //TODO: implement waiting widget
  }
  
  Widget item($pascal $camel) {
    //TODO: implement item widget
  }
  
  Widget error(Object error) {
    //TODO: implement error widget
  }
  
  Widget separator() {
    //TODO: implement separator widget
  }
""";
}
