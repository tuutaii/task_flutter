import 'package:basesource/app/modules/input_formatter/widgets/upcase_widget.dart';
import 'package:flutter/material.dart';
import '../../../widgets/common/text_input_formatter.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    Key? key,
    required this.textEditingController,
    required this.textInputFormatter,
    required this.validator,
    required this.hint,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final MaskTextInputFormatter textInputFormatter;
  final FormFieldValidator<String> validator;
  final String hint;

  @override
  Widget build(BuildContext context) {
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
