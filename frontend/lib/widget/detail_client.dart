import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import 'package:gap/gap.dart';
import '../app/responsitvity/responsivity.dart';
import '../helper/date_helper.dart';
import '../model/client/client_model.dart';
import '../model/client/client_moral_model.dart';
import '../model/client/client_physique_model.dart';
import 'detail_table_row.dart';

class DetailClient extends StatefulWidget {
  final ClientModel client;

  const DetailClient({
    super.key,
    required this.client,
  });

  @override
  State<DetailClient> createState() => _DetailClientState();
}

class _DetailClientState extends State<DetailClient> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Informations du partenaire",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Gap(18),
          if (Responsive.isMobile(context) &&
              widget.client is ClientMoralModel &&
              (widget.client as ClientMoralModel).logo != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      image: DecorationImage(
                        image: NetworkImage(
                            (widget.client as ClientMoralModel).logo!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.client is ClientMoralModel &&
                  !Responsive.isMobile(context) &&
                  (widget.client as ClientMoralModel).logo != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(1),
                          image: DecorationImage(
                            image: NetworkImage(
                              (widget.client as ClientMoralModel).logo!,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Gap(16),
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
                          widget.client.toStringify(),
                        ),
                        buildTableRow(
                          "Email",
                          widget.client.email ?? "inconnu",
                        ),
                        buildTableRow(
                          "Type",
                          'Personne ${widget.client.typeName!.label}e',
                        ),
                        if (widget.client is ClientMoralModel) ...[
                          buildTableRow(
                              "Catégorie",
                              capitalizeFirstLetter(
                                word: (widget.client as ClientMoralModel)
                                    .categorie!
                                    .libelle,
                              )),
                        ],
                        if (widget.client is ClientPhysiqueModel) ...[
                          buildTableRow(
                            "Sexe",
                            (widget.client as ClientPhysiqueModel).sexe!.label,
                          ),
                        ],
                        buildTableRow(
                          "Pays",
                          widget.client.pays!.name,
                        ),
                        buildTableRow(
                          "Téléphone",
                          "+${widget.client.pays!.code} ${widget.client.telephone ?? "_" * widget.client.pays!.phoneNumber!}",
                        ),
                        buildTableRow(
                          "Adresse",
                          widget.client.adresse == null ||
                                  widget.client.adresse!.isEmpty
                              ? "inconnu"
                              : capitalizeFirstLetter(
                                  word: widget.client.adresse,
                                ),
                        ),
                        buildTableRow(
                          "Crée",
                          getStringDate(
                            time: widget.client.dateEnregistrement!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
