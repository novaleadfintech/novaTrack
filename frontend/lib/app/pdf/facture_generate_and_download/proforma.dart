import 'package:frontend/helper/proforma_helper.dart';
import 'package:frontend/model/facturation/ligne_model.dart';

import '../../../helper/facture_proforma_helper.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import '../color.dart';
import '../utils/download_helper.dart';
import 'constant.dart';
import '../../../global/constant/constant.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/nomber_converter.dart';
import '../../../model/client/client_moral_model.dart';
import '../../../model/request_response.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../../../model/facturation/proforma_model.dart';
import '../load_file.dart';

class ProformaPdfGenerator {
  static Future<RequestResponse> generateAndDownloadPdf({
    required ProformaModel proforma,
    required bool withSignature,
  }) async {
    try {
      StrictEntreprise? entreprise =
          await EntrepriseService.getEntrepriseInformation();
      final logoImage = await loadNetworkImage(
        url: entreprise.logo,
      );
      final clientLogo = proforma.client is ClientMoralModel &&
              (proforma.client as ClientMoralModel).logo!.isNotEmpty
          ? await loadNetworkImage(
              url: (proforma.client as ClientMoralModel).logo!,
            )
          : null;

      final signature = await loadNetworkImage(
        url: entreprise.tamponSignature,
      );

      // Créer le document PDF
      final pdf = pw.Document();
      const pageFormat = PdfPageFormat.a4;
      // Ajout des pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(
              fontSize: 10,
              font: pw.Font.times(),
              fontNormal: pw.Font.times(),
              fontBold: pw.Font.timesBold(),
              color: PdfColors.black,
            ),
          ),
          build: (context) => [
            pw.Container(
              width: pageFormat.availableWidth,
              child: _buildContent(
                proforma: proforma,
                logoImage: logoImage,
                clientLogoImage: clientLogo,
                signature: signature,
                withSignature: withSignature,
                entreprise: entreprise,

              ),
            ),
          ],
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.bottomCenter,
              child: pw.Center(
                child: pw.Text(
                  'Page ${context.pageNumber}/${context.pagesCount}',
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                ),
              ),
            );
          },
        ),
      );

      // Sauvegarde du PDF
      final bytes = await pdf.save();
      final fileName =
          'proforma_${proforma.reference.replaceAll("/", "_")}_${proforma.client!.toStringify().replaceAll(" ", "_")}.pdf';
      PdfDownloadHelper.downloadPdf(bytes: bytes, fileName: fileName);
      return RequestResponse(status: PopupStatus.success);
    } catch (err) {
      return RequestResponse(
        status: PopupStatus.customError,
        message: err.toString(),
      );
    }
  }

  // Sauvegarde du PDF pour le Web
  static pw.Widget _buildContent({
    required ProformaModel proforma,
    required pw.ImageProvider logoImage,
    required pw.ImageProvider? clientLogoImage,
    required pw.ImageProvider signature,
    required bool withSignature,
    required StrictEntreprise entreprise,

  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(
          proforma,
          logoImage,
          clientLogoImage,
          entreprise: entreprise,

        ),
        pw.SizedBox(height: 16),
        _buildProformaTable(proforma),
        pw.SizedBox(height: 16),
        _buildTotalAmount(proforma),
        pw.SizedBox(height: 16),
        _buildDirectorSignature(
          proforma,
          signature,
          withSignature,
          entreprise: entreprise,

        ),
      ],
    );
  }

  static pw.Widget _buildDirectorSignature(
    ProformaModel proforma,
    pw.ImageProvider signature,
    bool withSignature, {
    required StrictEntreprise entreprise,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "Le Directeur Général",
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              withSignature
                  ? pw.Container(
                      alignment: pw.Alignment.center,
                      width: 150,
                      height: 75,

                      child: pw.Image(signature),
                    )
                  : pw.Container(
                      alignment: pw.Alignment.center,
                      width: 150,
                      height: 75,
                    ),
              pw.SizedBox(height: 12),
              pw.Text(
                entreprise.nomDG,
                style: pw.TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProformaTable(
    ProformaModel proforma,
  ) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(),
        1: const pw.IntrinsicColumnWidth(),
        2: const pw.IntrinsicColumnWidth(),
        3: const pw.IntrinsicColumnWidth(),
        4: const pw.IntrinsicColumnWidth(),
      },
      border: pw.TableBorder.all(
        color: pdfcouleur,
        width: 1,
      ),
      children: [
        _buildTableHeader(
          titles: serviceTitle,
        ),
        if (proforma.ligneProformas != null &&
            proforma.ligneProformas!.isNotEmpty) ...[
          for (var i = 0;
              i < proforma.ligneProformas!.length && i < 5;
              i++) ...[
            _buildTableRow(proforma.ligneProformas![i]),
            if (proforma.ligneProformas![i].fraisDivers != null &&
                proforma.ligneProformas![i].fraisDivers!.isNotEmpty) ...[
              ...proforma.ligneProformas![i].fraisDivers!
                  .map((frais) => pw.TableRow(
                        children: [
                          frais.libelle,
                          "-",
                          "-",
                          "-",
                          Formatter.formatAmount(
                            calculMontantFraisDivers(
                              frais: frais,
                              tauxTVA: proforma.tauxTVA!,
                            ),
                          ),
                        ]
                            .map(
                              (e) => _buildBodyTableCell(e),
                            )
                            .toList(),
                      ))
            ]
          ],
        ],
        _buildTableFooter(
          libelle: "TOTAL HT",
          montant:
              Formatter.formatAmount(calculerMontantHT(proforma: proforma)),
        ),
        if (proforma.reduction != null && proforma.reduction!.valeur != 0) ...[
          pw.TableRow(
            children: [
              "Réduction ${proforma.reduction?.unite != null ? "(${proforma.reduction!.valeur}%)" : ""}",
              "-",
              "-",
              "-",
              Formatter.formatAmount(calculerReduction(
                  lignes: proforma.ligneProformas!,
                  reduction: proforma.reduction!)),
            ]
                .map(
                  (e) => _buildBodyTableCell(e),
                )
                .toList(),
          ),
        ],
        pw.TableRow(
          children: [
            "TVA ${proforma.tva! ? "(${proforma.client!.pays!.tauxTVA}%)" : ""}",
            "-",
            "-",
            "-",
            Formatter.formatAmount(
              calculerTva(
                tauxTVA: proforma.tauxTVA!,
                lignes: proforma.ligneProformas!,
                reduction: proforma.reduction!,
                tva: proforma.tva!,
              ),
            ),
          ]
              .map(
                (e) => _buildBodyTableCell(e),
              )
              .toList(),
        ),
        _buildTableFooter(
          libelle: "TOTAL TTC",
          montant: Formatter.formatAmount(proforma.montant!),
        ),
      ],
    );
  }


  static pw.TableRow _buildTableRow(LigneModel ligne) {
    return pw.TableRow(
      children: [
        ligne.designation,
        Formatter.formatAmount((ligne.service!.nature == NatureService.unique
            ? ligne.service!.prix!
            : ligne.service!.tarif.firstWhere(
                (tarif) {
                  if (tarif!.maxQuantity == null) {
                    return ligne.quantite! >= tarif.minQuantity;
                  } else {
                    return ligne.quantite! >= tarif.minQuantity &&
                        ligne.quantite! <= tarif.maxQuantity!;
                  }
                },
                orElse: () => ServiceTarifModel(
                  minQuantity: 1,
                  prix: 0,
                ),
                  )!.prix) +
            ligne.prixSupplementaire!),
        '${ligne.quantite}',
        ligne.unit == Constant.units[0] ? "-" : ligne.unit,
        //(Formatter.formatAmount(ligne.remise!)),
        (Formatter.formatAmount(ligne.montant))
      ].map((text) => _buildBodyTableCell(text!)).toList(),
    );
  }

  static pw.Widget _buildBodyTableCell(
    String text,
  ) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.normal,
    );
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(),
      child: pw.Text(
        text,
        style: style,
          textAlign: int.tryParse(Formatter.parseAmount(text)) != null ||
                  double.tryParse(Formatter.parseAmount(text)) != null
              ? pw.TextAlign.right
              : pw.TextAlign.left
      ),
    );
  }

  static pw.TableRow _buildTableHeader({required List<String> titles}) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.TableRow(
      children: titles
          .map(
            (text) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: pdfcouleur),
              child: pw.Text(
                text,
                style: style,
              ),
            ),
          )
          .toList(),
    );
  }

  static pw.TableRow _buildTableFooter(
      {required String montant, required String libelle}) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.TableRow(
      children: [
        libelle,
        '-',
        '-',
        '-',
        montant,
      ]
          .map(
            (text) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: pdfcouleur),
              child: pw.Text(text,
                  style: style,
                  textAlign: int.tryParse(Formatter.parseAmount(text)) !=
                              null ||
                          double.tryParse(Formatter.parseAmount(text)) != null
                      ? pw.TextAlign.right
                      : pw.TextAlign.left),
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _buildTotalAmount(ProformaModel proforma) {
    return pw.RichText(
      text: pw.TextSpan(
        text: "Arrêtée le présent proforma à la somme totale ${[
          "a",
          "e",
          "i",
          "o",
          "u",
          "y"
        ].contains(convertNumberToWords(
          proforma.montant!,
        ).trim().split('').first.toLowerCase()) ? 'd\'' : "de "}",
        style: const pw.TextStyle(fontSize: 10),
        children: [
          pw.TextSpan(
            text: (() {
              try {
                return "${convertNumberToWords(proforma.montant!)} FCFA";
              } catch (e) {
                return "Montant invalide";
              }
            })(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader(
    ProformaModel proforma,
    pw.ImageProvider logoImage,
    pw.ImageProvider? clientLogoImage,
       {
    required StrictEntreprise entreprise,
  }

  ) {
    return pw.SizedBox(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                width: 150,
                height: 100,
                child: pw.Image(
                  logoImage,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        text: 'PROFORMA ',
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(
                      'N° ${proforma.reference}',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "${entreprise.ville}, le ${getStringDate(time: proforma.dateEtablissementProforma!)}",
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    if (proforma.ligneProformas!.isNotEmpty &&
                        proforma.ligneProformas!.first.dureeLivraison != null)
                      pw.Text(
                        "Durée de livraison : ${convertDuration(
                          durationMs:
                              proforma.ligneProformas!.first.dureeLivraison!,
                        ).compteur.toString()} ${convertDuration(
                          durationMs:
                              proforma.ligneProformas!.first.dureeLivraison!,
                        ).unite}",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    if (proforma.garantyTime != null &&
                        proforma.garantyTime != 0)
                      pw.Text(
                        "Garantie : ${convertDuration(
                          durationMs: proforma.garantyTime!,
                        ).compteur.toString()} ${convertDuration(
                          durationMs: proforma.garantyTime!,
                        ).unite}",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(
            width: 100,
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Container(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        entreprise.adresse,
                        style: const pw.TextStyle(
                          fontSize: 10,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "Tél. (+${entreprise.pays.code}) ${entreprise.telephone}",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        entreprise.email,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(
                  height: 16,
                ),
                pw.Container(
                  child: pw.Column(
                    children: [
                      if (clientLogoImage != null)
                        pw.Container(
                          alignment: pw.Alignment.center,
                          width: 100,
                          height: 75,
                          child: pw.Image(
                            clientLogoImage,
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      pw.Text(
                        proforma.client!.toStringify(),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        "${proforma.client!.adresse}, ${proforma.client!.pays!.name}",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
 
  }
}
