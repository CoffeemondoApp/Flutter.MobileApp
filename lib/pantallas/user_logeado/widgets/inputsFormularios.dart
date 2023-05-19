import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../colores/colores.dart';

Widget textFieldInputCustom(String texto, TextEditingController controller,
    TextInputType keyboardType, List<TextInputFormatter>? inputFormatters) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      style: TextStyle(
          color: colorNaranja,
          letterSpacing: 2,
          fontSize: 14,
          fontWeight: FontWeight.bold),
      controller: controller,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: colorNaranja),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorNaranja),
        ),
        hintText: texto,
        hintStyle: TextStyle(
            color: colorNaranja, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    ),
  );
}

Widget nameInputCustom(String texto, TextEditingController controller) {
  return textFieldInputCustom(
    texto,
    controller,
    TextInputType.name,
    [
      FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
    ],
  );
}

Widget rutInputCustom(String texto, TextEditingController controller) {
  var rutFormatter = MaskTextInputFormatter(
      mask: '##.###.###-#',

      //permitir letra K en el ultimo digito
      filter: {"#": RegExp(r'[0-9kK]')},
      type: MaskAutoCompletionType.lazy);
  return textFieldInputCustom(
    texto,
    controller,
    TextInputType.phone,
    [rutFormatter],
  );
}

Widget phoneNumberInputCustom(String texto, TextEditingController controller) {
  var maskFormatter = MaskTextInputFormatter(
      mask: '+(##) # ### ### ##)',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  return textFieldInputCustom(
    texto,
    controller,
    TextInputType.phone,
    [
      maskFormatter,
    ],
  );
}

Widget emailInputCustom(String texto, TextEditingController controller) {
  return textFieldInputCustom(
    texto,
    controller,
    TextInputType.emailAddress,
    [
      FilteringTextInputFormatter.deny(RegExp(r'\s')),
      EmailInputFormatter(),
    ],
  );
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains(RegExp(r'\s'))) {
      return oldValue;
    }
    return newValue;
  }
}
