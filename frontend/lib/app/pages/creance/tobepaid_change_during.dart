import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../helper/date_helper.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/validate_button.dart';

class CreanceTobePaidChangeDuring extends StatefulWidget {
  final TextEditingController debutController;
  final TextEditingController finController;
  final Function(DateTime?, DateTime?) onDatesSelected;

  const CreanceTobePaidChangeDuring({
    super.key,
    required this.debutController,
    required this.finController,
    required this.onDatesSelected,
  });

  @override
  State<CreanceTobePaidChangeDuring> createState() =>
      _CreanceTobePaidChangeDuringState();
}

class _CreanceTobePaidChangeDuringState
    extends State<CreanceTobePaidChangeDuring> {
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
        DateField(
          onCompleteDate: (value) {
            DateTime val;
            val = value ?? DateTime.now();
            widget.debutController.text = getStringDate(time: val);
            debut = val;
            setState(() {
              debut = val;
            });
          },
          firstDate: DateTime.now(),
          lastDate: fin,
          label: "Début",
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
          label: "Fin",
          firstDate: debut ?? DateTime.now(),
          dateController: widget.finController,
        ),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              libelle: "OK",
              onPressed: () {
                widget.onDatesSelected(debut, fin);
              },
            ),
          ),
        ),
      ],
    );
  }
}
