import 'dart:io';

import 'package:flutter/cupertino.dart';

class KycFormModel {
  String? name;
  String? label;
  String? isRequired;
  String? instruction;
  String? extensions;
  List<String>? options;
  String? type;
  dynamic selectedValue;
  TextEditingController? textEditingController;
  File? imageFile;
  List<String>? cbSelected;
  // Added an optional parameter to initialize the textEditingController
  KycFormModel(this.name, this.label, this.isRequired, this.instruction, this.extensions, this.options, this.type, this.selectedValue, {this.cbSelected, this.imageFile, this.textEditingController}) {
    // Initialize textEditingController if not provided
    textEditingController ??= TextEditingController();
  }
}
