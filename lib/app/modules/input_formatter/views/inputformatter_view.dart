import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/common/text_input_formatter.dart';
import '../controllers/inputformatter_controller.dart';

class InputFormatterView extends GetView<InputFormatterController> {
  InputFormatterView({Key? key}) : super(key: key);
  final List<_ExampleMask> examples = [
    _ExampleMask(
        formatter: MaskTextInputFormatter(mask: "+## (###) ###-##-##"),
        hint: "+84 (234) 567-89-01",
        validator: (String? value) {
          return null;
        }),
    _ExampleMask(
        formatter: MaskTextInputFormatter(mask: "###"),
        hint: "CVV/CVC",
        validator: (String? value) {
          return null;
        }),
    _ExampleMask(
        formatter: MaskTextInputFormatter(mask: "##/##/####"),
        hint: "31/12/2020",
        validator: (value) {
          if (value!.isEmpty) {
            return null;
          }
          final components = value.split("/");
          if (components.length == 3) {
            final day = int.tryParse(components[0]);
            final month = int.tryParse(components[1]);
            final year = int.tryParse(components[2]);
            if (day != null && month != null && year != null) {
              final date = DateTime(year, month, day);
              if (date.year == year && date.month == month && date.day == day) {
                return null;
              }
            }
          }
          return "Định dạng ngày không hợp lệ. ";
        }),
    _ExampleMask(
        formatter: MaskTextInputFormatter(mask: "(AA) ####-####"),
        hint: "(AB) 1234-5678",
        validator: (String? value) {
          return null;
        }),
    _ExampleMask(
        formatter: MaskTextInputFormatter(
            mask: "##/##/##", type: MaskAutoCompletionType.eager),
        hint: "12/34/56 (eager type)",
        validator: (String? value) {
          return null;
        }),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            for (final example in examples)
              buildTextField(example.textController, example.formatter,
                  example.validator, example.hint),
          ],
        )));
  }

  Widget buildTextField(
      TextEditingController textEditingController,
      MaskTextInputFormatter textInputFormatter,
      FormFieldValidator<String> validator,
      String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          TextFormField(
            controller: textEditingController,
            inputFormatters: [
              const UpperCaseTextFormatter(),
              textInputFormatter
            ],
            autocorrect: false,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.always,
            validator: validator,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.black,
                    size: 24,
                  ),
                  onPressed: () => textEditingController.clear(),
                ),
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorMaxLines: 1),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter implements TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class SpecialMaskTextInputFormatter extends MaskTextInputFormatter {
  static String maskA = "S.####";
  static String maskB = "S.######";

  SpecialMaskTextInputFormatter({String? initialText})
      : super(
            mask: maskA,
            filter: {"#": RegExp('[0-9]'), "S": RegExp('[AB]')},
            initialText: initialText);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith("A")) {
      if (getMask() != maskA) {
        updateMask(mask: maskA);
      }
    } else {
      if (getMask() != maskB) {
        updateMask(mask: maskB);
      }
    }
    return super.formatEditUpdate(oldValue, newValue);
  }
}

class _ExampleMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String> validator;
  final String hint;
  _ExampleMask(
      {required this.formatter, required this.validator, required this.hint});
}
