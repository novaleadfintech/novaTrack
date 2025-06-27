import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/widget/drop_down_text_field.dart';
import 'package:gap/gap.dart';

import '../../../helper/date_helper.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/validate_button.dart';

class BilanChangeDuring extends StatefulWidget {
  final TextEditingController debutController;
  final TextEditingController finController;
  final Function(String?) onselectedType;
  final Function(DateTime?, DateTime?) onDatesSelected;

  const BilanChangeDuring({
    super.key,
    required this.debutController,
    required this.finController,
    required this.onDatesSelected,
    required this.onselectedType,
  });

  @override
  State<BilanChangeDuring> createState() => _BilanChangeDuringState();
}

class _BilanChangeDuringState extends State<BilanChangeDuring> {
  DateTime? debut;
  DateTime? fin;
  @override
  void dispose() {
    widget.debutController.clear();
    widget.finController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropDownField(
          items: ["Tous", "Entrée", "Sortie"],
          onChanged: widget.onselectedType,
          selectedItem: "Tous",
          label: "Type",
        ),
        DateField(
          onCompleteDate: (value) {
            DateTime val;
            val = value ?? DateTime.now();
            widget.debutController.text = getStringDate(time: val);
            setState(() {
              debut = val;
            });
          },
          lastDate: fin,
          label: "Debut",
          dateController: widget.debutController,
        ),
        const Gap(4),
        DateField(
          onCompleteDate: (value) {
            DateTime val;
            val = value ?? DateTime.now();
            widget.finController.text = getStringDate(time: val);
            setState(() {
              fin = val;
            });
          },
          firstDate: debut,
          label: "Fin",
          dateController: widget.finController,
        ),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () {
                widget.onDatesSelected(debut, fin);
                MutationRequestContextualBehavior.closePopup();
              },
            ),
          ),
        ),
      ],
    );
  }
}
