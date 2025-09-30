import 'package:frontend/app/pages/utils/bulletin_util.dart';
import 'package:frontend/app/pdf/color.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/helper/get_bulletin_period.dart';
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart';
import 'package:frontend/model/bulletin_paie/section_bulletin.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/service/section_service.dart';
import '../../../helper/amout_formatter.dart';
import '../../../model/bulletin_paie/bulletin_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/bulletin_paie/rubrique.dart';
import '../../../model/bulletin_paie/rubrique_paie.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/request_response.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import '../load_file.dart';
import '../utils/download_helper.dart';

class BulletinPdfGenerator {
  static Future<RequestResponse?> generateAndDownloadPdf({
    required BulletinPaieModel bulletin,
  }) async {
    try {
    StrictEntreprise? entreprise =
        await EntrepriseService.getEntrepriseInformation();
    List<SectionBulletin> sections = await SectionService.getSections();
    final logoImage = await loadNetworkImage(
      url: entreprise.logo,
    );
    final pdf = pw.Document();
    const pageFormat = PdfPageFormat.a4;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        // margin: pw.EdgeInsets.all(24),
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
            fontSize: 10,
            font: pw.Font.courier(),
            fontNormal: pw.Font.courier(),
            fontBold: pw.Font.courierBold(),
            wordSpacing: 1,
            letterSpacing: 0,
            color: PdfColors.black,
          ),
        ),
        build: (context) => [
          pw.Column(children: [
            pw.Container(
              width: pageFormat.availableWidth,
              child: _buildContent(
                bulletin: bulletin,
                logoImage: logoImage,
                entreprise: entreprise,
                sections: sections,
              ),
            ),
            pw.SizedBox(height: 12),
            _buildFooter(bulletin: bulletin)
          ])
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName =
        'bulletin_${bulletin.salarie.personnel.nom}_${bulletin.salarie.personnel.prenom}_du_${getShortStringDate(time: bulletin.debutPeriodePaie)}_au_${getShortStringDate(time: bulletin.finPeriodePaie)}.pdf';
    PdfDownloadHelper.downloadPdf(bytes: bytes, fileName: fileName);
    return RequestResponse(status: PopupStatus.success);
    } catch (err) {
       

      throw err.toString();
    }
  }

  static Future<RequestResponse?> generateAndDownloadMultipleBulletins({
    required List<BulletinPaieModel> bulletins,
  }) async {
    try {
      final pdf = pw.Document();
      const pageFormat = PdfPageFormat.a4;

      // Récupère les infos une seule fois (pas besoin de les recharger à chaque bulletin)
      final StrictEntreprise entreprise =
          await EntrepriseService.getEntrepriseInformation();
      final List<SectionBulletin> sections = await SectionService.getSections();
      final logoImage = await loadNetworkImage(url: entreprise.logo);

      // Ajoute chaque bulletin comme une nouvelle page
      for (final bulletin in bulletins) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: pageFormat,
            theme: pw.ThemeData(
              defaultTextStyle: pw.TextStyle(
                fontSize: 10,
                font: pw.Font.courier(),
                fontNormal: pw.Font.courier(),
                fontBold: pw.Font.courierBold(),
                wordSpacing: 1,
                letterSpacing: 0,
                color: PdfColors.black,
              ),
            ),
            build: (context) => [
              pw.Column(children: [
                pw.Container(
                  width: pageFormat.availableWidth,
                  child: _buildContent(
                    bulletin: bulletin,
                    logoImage: logoImage,
                    entreprise: entreprise,
                    sections: sections,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildFooter(bulletin: bulletin),
              ])
            ],
          ),
        );
      }

      // Génère un nom générique avec date
      final fileName =
          'bulletins_${getShortStringDate(time: DateTime.now())}.pdf';
      final bytes = await pdf.save();

      PdfDownloadHelper.downloadPdf(bytes: bytes, fileName: fileName);
      return RequestResponse(status: PopupStatus.success);
    } catch (err) {
       

      throw err.toString();
    }
  }


  static pw.Widget _buildContent({
    required BulletinPaieModel bulletin,
    required pw.ImageProvider logoImage,
    required StrictEntreprise entreprise,
    required List<SectionBulletin> sections,
  }) {
    final rubriquesSansSection = bulletin.rubriques
        .where(
          (r) =>
              r.rubrique.section == null &&
              r.rubrique.rubriqueRole != RubriqueRole.variable &&
              r.value != null &&
              r.value?.toInt() != 0,
        )
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Colonne Entreprise avec logo
            pw.Container(
              width: 180,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(
                    logoImage,
                    height: 50,
                    fit: pw.BoxFit.contain,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    entreprise.raisonSociale,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    entreprise.adresse,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      // color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),

            pw.Container(
              width: 180,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    bulletin.salarie.personnel.toStringify(),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: PdfColors.blue900,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    "Poste : ${bulletin.salarie.personnel.poste != null ? bulletin.salarie.personnel.poste!.libelle : "Aucun"}",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    "Tel : +${bulletin.salarie.personnel.pays!.code} ${bulletin.salarie.personnel.telephone}",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    "${bulletin.salarie.personnel.adresse}, ${bulletin.salarie.personnel.pays!.name}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'BULLETIN DE SALAIRE',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Période : du ${getStringDate(time: bulletin.debutPeriodePaie)} au ${getStringDate(time: bulletin.finPeriodePaie)}',
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
            pw.Text(
              'Date d\'édition : ${formatDate(dateTime: bulletin.dateEdition)}',
              style: const pw.TextStyle(
                fontSize: 9,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        if (rubriquesSansSection.isNotEmpty) ...[
          pw.Table(
            columnWidths: {
              0: const pw.IntrinsicColumnWidth(),
              1: const pw.FlexColumnWidth(),
              2: const pw.IntrinsicColumnWidth(),
              3: const pw.IntrinsicColumnWidth(),
              4: const pw.IntrinsicColumnWidth(),
            },
            border: pw.TableBorder.all(
              width: 0.5,
            ),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: pdfcouleur),
                children: bulletinPdfTableTitles
                    .map(
                      (title) => pw.Container(
                        padding: const pw.EdgeInsets.all(2),
                        decoration: const pw.BoxDecoration(),
                        child: pw.Text(
                          title.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...rubriquesSansSection.map((rubriqueOnBulletin) {
                return _buildTableRow(
                  rubriqueOnBulletin: rubriqueOnBulletin,
                  rubriques: bulletin.rubriques,
                );
              }),
            ],
          ),
        ],
        ...sections.map(
          (section) {
            final rubriquesDeSection = bulletin.rubriques
                .where((r) =>
                    r.rubrique.section?.id == section.id &&
                    r.value != null &&
                    r.value?.toInt() != 0)
                .toList();

            if (rubriquesDeSection.isEmpty) {
              return pw.SizedBox();
            }

            return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Column(children: [
                  pw.Text(
                    section.section.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.IntrinsicColumnWidth(),
                      1: const pw.FlexColumnWidth(),
                      2: const pw.IntrinsicColumnWidth(),
                      3: const pw.IntrinsicColumnWidth(),
                      4: const pw.IntrinsicColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: pdfcouleur),
                        children: bulletinPdfTableTitles
                            .map(
                              (title) => pw.Container(
                                padding: const pw.EdgeInsets.all(2),
                                decoration: const pw.BoxDecoration(),
                                child: pw.Text(
                                  title.toUpperCase(),
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      ...rubriquesDeSection.map(
                        (rubriqueOnBulletin) => _buildTableRow(
                          rubriqueOnBulletin: rubriqueOnBulletin,
                          rubriques: bulletin.rubriques,
                        ),
                      ),
                    ],
                  ),
                ]));
          },
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: _buildRubriqueVariableRows(bulletin.rubriques),
        ),
      ],
    );
  }

  static List<pw.TableRow> _buildRubriqueVariableRows(
      List<RubriqueOnBulletinModel> rubriques) {
    final variables = rubriques
        .where((r) => r.rubrique.rubriqueRole == RubriqueRole.variable)
        .toList();

    // On regroupe les rubriques 2 par 2
    List<pw.TableRow> rows = [];
    for (int i = 0; i < variables.length; i += 2) {
      final r1 = variables[i];
      final r2 = (i + 1 < variables.length) ? variables[i + 1] : null;

      rows.add(
        pw.TableRow(
          children: [
            _buildRubriqueCell(r1),
            if (r2 != null) _buildRubriqueCell(r2) else pw.Container(),
          ],
        ),
      );
    }

    return rows;
  }

  static pw.Widget _buildRubriqueCell(RubriqueOnBulletinModel r) {
    final isAnciennete =
        r.rubrique.rubriqueIdentity == RubriqueIdentity.anciennete;
    final label = r.rubrique.rubriqueIdentity?.label ?? r.rubrique.rubrique;
    final valueText = isAnciennete
     ? formatAnciennete(r.value)
        : "${r.value ?? 0}";

    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        '$label : $valueText',
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.TableRow _buildTableRow(
      {required RubriqueOnBulletinModel rubriqueOnBulletin,
      required List<RubriqueOnBulletinModel> rubriques}) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            rubriqueOnBulletin.rubrique.code,
            textAlign: pw.TextAlign.end,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            rubriqueOnBulletin.rubrique.rubrique,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            () {
              final nature = rubriqueOnBulletin.rubrique.nature;
              if (nature == NatureRubrique.constant) {
                return Formatter.formatAmount(rubriqueOnBulletin.value ?? 0);
              }
              if (nature == NatureRubrique.taux &&
                  rubriqueOnBulletin.rubrique.taux != null) {
                return "${getFormuleValue(
                  rubrique: rubriqueOnBulletin.rubrique.taux!.base,
                  toutesLesRubriquesSurBulletin: rubriques,
                )}";
              }
              if (nature == NatureRubrique.calcul &&
                  rubriqueOnBulletin.rubrique.calcul != null &&
                  rubriqueOnBulletin.rubrique.calcul!.operateur ==
                      Operateur.multiplication) {
                final element =
                    rubriqueOnBulletin.rubrique.calcul!.elements.first;
                return "${element.type == BaseType.valeur ? element.valeur : getFormuleValue(
                    rubrique: element.rubrique!,
                    toutesLesRubriquesSurBulletin: rubriques,
                  )}";
              }
              if (nature == NatureRubrique.bareme &&
                  rubriqueOnBulletin.rubrique.bareme != null) {
                final bareme = rubriqueOnBulletin.rubrique.bareme!;
                final referenceValue = rubriques
                        .firstWhere(
                          (el) => el.rubrique.code == bareme.reference.code,
                          orElse: () => RubriqueOnBulletinModel(
                            rubrique: RubriqueBulletin(
                              id: "id",
                              rubrique: "rubrique",
                              code: "code",
                              type: TypeRubrique.gain,
                              nature: NatureRubrique.constant,
                              portee: null,
                            ),
                            value: 0,
                          ),
                        )
                        .value ??
                    0;
                final tranche = bareme.tranches.firstWhere(
                  (tr) =>
                      referenceValue >= tr.min &&
                      (tr.max == null || referenceValue <= tr.max!),
                  orElse: () => Tranche(
                    min: 0,
                    max: 0,
                    value: TrancheValue(
                      type: TrancheValueType.valeur,
                      valeur: 0,
                    ),
                  ),
                );
                return tranche.value.type == TrancheValueType.valeur
                    ? Formatter.formatAmount(tranche.value.valeur ?? 0)
                    : tranche.value.type == TrancheValueType.taux
                        ? "${getFormuleValue(rubrique: tranche.value.taux!.base, toutesLesRubriquesSurBulletin: rubriques)}"
                        : "";
              }

              return "";
            }(),
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              () {
                final nature = rubriqueOnBulletin.rubrique.nature;

                if (nature == NatureRubrique.taux &&
                    rubriqueOnBulletin.rubrique.taux != null) {
                  return "${rubriqueOnBulletin.rubrique.taux!.taux}%";
                }

                if (nature == NatureRubrique.calcul &&
                    rubriqueOnBulletin.rubrique.calcul != null &&
                    rubriqueOnBulletin.rubrique.calcul!.operateur ==
                        Operateur.multiplication) {
                  final element =
                      rubriqueOnBulletin.rubrique.calcul!.elements.last;
                  return "${element.type == BaseType.valeur ? element.valeur : getFormuleValue(
                      rubrique: element.rubrique!,
                      toutesLesRubriquesSurBulletin: rubriques,
                    )}";
                }

                if (nature == NatureRubrique.bareme &&
                    rubriqueOnBulletin.rubrique.bareme != null) {
                  final bareme = rubriqueOnBulletin.rubrique.bareme!;
                  final referenceValue = rubriques
                          .firstWhere(
                            (el) => el.rubrique.code == bareme.reference.code,
                            orElse: () => RubriqueOnBulletinModel(
                              rubrique: RubriqueBulletin(
                                id: "id",
                                rubrique: "rubrique",
                                code: "code",
                                type: TypeRubrique.gain,
                                nature: NatureRubrique.constant,
                                portee: null,
                              ),
                              value: 0,
                            ),
                          )
                          .value ??
                      0;

                  final tranche = bareme.tranches.firstWhere(
                    (tr) =>
                        referenceValue >= tr.min &&
                        (tr.max == null || referenceValue <= tr.max!),
                    orElse: () => Tranche(
                      min: 0,
                      max: 0,
                      value: TrancheValue(
                        type: TrancheValueType.valeur,
                        valeur: 0,
                      ),
                    ),
                  );
                  return tranche.value.type == TrancheValueType.taux
                      ? "${tranche.value.taux!.taux}%"
                      : "";
                }

                return "";
              }(),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.normal,
              ),
            )),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            rubriqueOnBulletin.rubrique.type == TypeRubrique.retenue
                ? Formatter.formatAmount(rubriqueOnBulletin.value!)
                : "",
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            rubriqueOnBulletin.rubrique.type == TypeRubrique.gain
                ? Formatter.formatAmount(rubriqueOnBulletin.value!)
                : "",
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter({required BulletinPaieModel bulletin}) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.green200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      "Net à payer",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      "",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      textAlign: pw.TextAlign.center,
                      "${Formatter.formatAmount(bulletin.rubriques.firstWhere(
                            (r) =>
                                r.rubrique.rubriqueIdentity ==
                                RubriqueIdentity.netPayer,
                            orElse: () => RubriqueOnBulletinModel(
                              rubrique: RubriqueBulletin(
                                id: '',
                                rubrique: '',
                                code: '',
                                type: TypeRubrique.gain,
                                nature: NatureRubrique.constant,
                                portee: null,
                              ),
                              value: 0,
                            ),
                          ).value ?? 0)} FCFA",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          "Par ${bulletin.moyenPayement!.libelle}",
                        ),
                        pw.Text(
                          bulletin.banque!.name,
                        ),
                        pw.Text(
                          "${bulletin.referencePaie}",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            height: 75,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Employeur",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ]),
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Employé",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        bulletin.salarie.personnel.toStringify(),
                      ),
                    ]),
              ],
            ),
          )
        ]);
  }
}
