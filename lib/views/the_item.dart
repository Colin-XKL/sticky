import "package:flutter/material.dart";
import 'package:stickys/views/whiteboard.dart';
enum ITEM_TYPE { TEXT, IMAGE, LINK, TODO, WIDGET }


abstract class TheItemBlock extends StatelessWidget {
  final Key key = UniqueKey();
  final ITEM_TYPE type;

  TheItemBlock(this.type);
}

class TextBlock extends TheItemBlock {
  final TextCardContent data;

  TextBlock(String? str)
      : data = new TextCardContent(str ?? ""),
        super(ITEM_TYPE.TEXT);

  String? get text => this.data.text;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        isAlwaysShown: false,
        child: SingleChildScrollView(
          child: SelectableText(this.text!),
        ));
  }
}

