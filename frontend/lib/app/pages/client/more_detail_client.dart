import 'package:flutter/material.dart';
import '../../../helper/string_helper.dart';
import '../../../model/client/client_moral_model.dart';
import '../../../model/client/client_model.dart';
import '../../../widget/detail_client.dart';
import 'package:gap/gap.dart';
import '../../../widget/detail_table_row.dart';
import '../../responsitvity/responsivity.dart';

class MoreDatailClientPage extends StatefulWidget {
  final ClientModel client;
  final Future<void> Function() refresh;
  const MoreDatailClientPage({
    super.key,
    required this.client,
    required this.refresh,
  });

  @override
  State<MoreDatailClientPage> createState() => _MoreDatailClientPageState();
}

class _MoreDatailClientPageState extends State<MoreDatailClientPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DetailClient(
              client: widget.client,
            ),
            Gap(8),
            if (widget.client is ClientMoralModel &&
                (widget.client as ClientMoralModel).responsable != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDADCE0),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations de la personne contact",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Table(
                                columnWidths: {
                                  0: Responsive.isMobile(context)
                                      ? const IntrinsicColumnWidth()
                                      : const FlexColumnWidth()
                                },
                                children: [
                                  buildTableRow(
                                    "Nom",
                                    (widget.client as ClientMoralModel)
                                        .responsable!
                                        .nom
                                        .toUpperCase(),
                                  ),
                                  buildTableRow(
                                    "Prénoms",
                                    capitalizeFirstLetter(
                                      word: (widget.client as ClientMoralModel)
                                          .responsable!
                                          .prenom,
                                    ),
                                  ),
                                  buildTableRow(
                                    "Sexe",
                                    (widget.client as ClientMoralModel)
                                        .responsable!
                                        .sexe
                                        .label,
                                  ),
                                  buildTableRow(
                                    "Civilité",
                                    (widget.client as ClientMoralModel)
                                        .responsable!
                                        .civilite
                                        .label,
                                  ),
                                  buildTableRow(
                                    "Email",
                                    (widget.client as ClientMoralModel)
                                        .responsable!
                                        .email,
                                  ),

                                  /* buildTableRow(
                                    "Pays",
                                    widget.client.pays!.name,
                                  ), */
                                  buildTableRow(
                                    "Téléphone",
                                    "+${(widget.client as ClientMoralModel).pays!.code} ${(widget.client as ClientMoralModel).responsable!.telephone}",
                                  ),
                                  buildTableRow(
                                      "Adresse",
                                      capitalizeFirstLetter(
                                        word: widget.client.adresse,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
          ],
        ),
      ),
    );
  }
}
