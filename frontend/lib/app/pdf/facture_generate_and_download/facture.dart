import 'package:frontend/app/pdf/color.dart';
import 'package:frontend/app/pdf/utils/download_helper.dart';
import 'package:frontend/model/facturation/ligne_model.dart';
import '../../../helper/facture_helper.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/entreprise/type_canaux_paiement.dart';
import '../../../model/facturation/facture_acompte.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../../../global/constant/constant.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/facture_proforma_helper.dart';
import '../../../helper/nomber_converter.dart';
import '../../../model/client/client_moral_model.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/facturation/facture_model.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/request_response.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_prix_model.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import 'constant.dart';
import '../load_file.dart';

class FacturePdfGenerator {
  static Future<RequestResponse> generateAndDownloadPdf({
    required FactureModel facture,
    required bool withSignature,
  }) async {
    try {
      StrictEntreprise? entreprise =
          await EntrepriseService.getEntrepriseInformation();
      final logoImage = await loadNetworkImage(
        url: entreprise.logo,
      );

      Future<List<pw.ImageProvider?>> loadBanqueImages(
          {required List<BanqueModel> banques}) async {
        List<pw.ImageProvider?> images = [];
        for (var banque in banques) {
          banque.logo != null
              ? images.add(await loadNetworkImage(url: banque.logo!))
              : images.add(null);
        }
        return images;
      }

      final clientLogo = (facture.client is ClientMoralModel &&
              (facture.client as ClientMoralModel).logo!.isNotEmpty)
          ? await loadNetworkImage(
              url: (facture.client as ClientMoralModel).logo!)
          : null;
      final signature = await loadNetworkImage(
        url: entreprise.tamponSignature,
      );
      final banqueImages = await loadBanqueImages(banques: facture.banques!);
      final pdf = pw.Document();
      const pageFormat = PdfPageFormat.a4;
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
                facture: facture,
                logoImage: logoImage,
                clientLogoImage: clientLogo,
                signature: signature,
                withSignature: withSignature,
                entreprise: entreprise,
              ),
            ),
          ],
          footer: (pw.Context context) {
            if (facture.banques != null && facture.banques!.isNotEmpty) {
              return _buildFooter(
                banques: facture.banques!,
                images: banqueImages,
                entreprise: entreprise,
              );
            }
            return pw.Container();
          },
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'facture_${facture.reference.replaceAll("/", "_")}_${facture.client!.toStringify().replaceAll(" ", "_")}.pdf';
      PdfDownloadHelper.downloadPdf(bytes: bytes, fileName: fileName);
      return RequestResponse(status: PopupStatus.success);
    } catch (err) {
      return RequestResponse(
        status: PopupStatus.customError,
        message: err.toString(),
      );
    }
  }

  static pw.Widget _buildContent({
    required FactureModel facture,
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
          facture,
          logoImage,
          clientLogoImage,
          entreprise: entreprise,
        ),
        pw.SizedBox(
          height: 16,
        ),
        _buildFactureTable(
          facture,
        ),
        pw.SizedBox(
          height: 16,
        ),
        _buildTotalAmount(
          facture.montant! +
              (facture.facturesAcompte.fold(
                    0.0,
                    (sum, acompte) =>
                        sum! +
                        (acompte.oldPenalties
                                ?.fold(0.0, (s, p) => s! + p.montant) ??
                            0.0),
                  ) ??
                  0.0),
        ),
        if (facture.facturesAcompte.length > 1) ...[
          pw.SizedBox(
            height: 16,
          ),
          _buildEcheancierTable(
              accomptes: facture.facturesAcompte,
              montantTotalFacture: facture.montant!),
        ],

        //TOGO SIL Y A UN BLELME C4EST MOOI
        if (
            facture.payements!.isNotEmpty) ...[
          pw.SizedBox(
            height: 16,
          ),
          _buildPaymentTable(
            facture.payements!,
          ),
          _buildAmountResetTable(
            facture,
          ),
        ],
        pw.SizedBox(height: 16),
        _buildDirectorSignature(
          facture,
          entreprise: entreprise,
          signature,
          withSignature: withSignature,
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentTable(List<FluxFinancierModel> payements) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            vertical: 8,
          ),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            payements.length == 1 ? "RÈGLEMENT" : "RÈGLEMENTS",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        pw.Table(
          columnWidths: {
            0: const pw.IntrinsicColumnWidth(),
            3: const pw.IntrinsicColumnWidth()
          },
          border: pw.TableBorder.all(
            color: pdfcouleur,
            width: 1,
          ),
          children: [
            _buildTableHeader(
              titles: payementTitle,
            ),
            ...payements.asMap().entries.map(
              (entry) {
                final payment = entry.value;
                return pw.TableRow(
                  children: [
                    _buildBodyTableCell(payment.bank!.name),
                    _buildBodyTableCell(
                      Formatter.formatAmount(payment.montant),
                    ),
                    _buildBodyTableCell(payment.moyenPayement!.libelle),
                    _buildBodyTableCell(
                      getStringDate(
                        time: payment.dateOperation!,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildEcheancierTable(
      {required List<FactureAcompteModel> accomptes,
      required double montantTotalFacture}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            vertical: 8,
          ),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            "MODALITÉS DE PAIEMENT",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(
            color: pdfcouleur,
            width: 1,
          ),
          children: [
            _buildTableHeader(
              titles: echeancierTile,
            ),
            ...accomptes.asMap().entries.map(
              (entry) {
                final accompte = entry.value;
                return pw.TableRow(
                  children: [
                    _buildBodyTableCell(
                        "Paiement N° ${accompte.rang} (${accompte.pourcentage}%)"),
                    _buildBodyTableCell(
                      Formatter.formatAmount(
                          accompte.pourcentage * montantTotalFacture / 100),
                    ),
                    // _buildBodyTableCell(
                    //   Formatter.formatAmount(
                    //     (accompte.oldPenalties != null
                    //         ? accompte.oldPenalties!.fold(
                    //             0.0, (sum, penalty) => sum + penalty.montant)
                    //         : 0.0),
                    //   ),
                    // ),
                    _buildBodyTableCell(
                      getStringDate(time: accompte.dateEnvoieFacture),
                    ),
                    _buildBodyTableCell(
                        accompte.isPaid! ? "Réglé" : "À régler"),
                  ],
                );
              },
            ),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildDirectorSignature(
    FactureModel facture,
    pw.ImageProvider signature, {
    required bool withSignature,
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

  static pw.Widget _buildAmountResetTable(FactureModel facture) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.Table(
      columnWidths: {
        1: const pw.IntrinsicColumnWidth(),
      },
      children: [
        pw.TableRow(
          children: [
            'MONTANT PAYÉ',
            '${Formatter.formatAmount(
              (calculerMontantPaye(payements: facture.payements!)),
            )} FCFA'
          ]
              .map(
                (text) => pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(color: pdfcouleur),
                  child: pw.Text(text, style: style),
                ),
              )
              .toList(),
        ),
        pw.TableRow(
          children: [
            'MONTANT RESTANT',
            '${Formatter.formatAmount(
              (facture.montant! +
                  (facture.facturesAcompte.fold(
                        0.0,
                        (sum, acompte) =>
                            sum! +
                            (acompte.oldPenalties
                                    ?.fold(0.0, (s, p) => s! + p.montant) ??
                                0.0),
                      ) ??
                      0.0) -
                  calculerMontantPaye(
                    payements: facture.payements!,
                  )),
            )} FCFA',
          ]
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
        )
      ],
    );
  }

  static pw.Widget _buildFactureTable(
    FactureModel facture,
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
        if (facture.ligneFactures != null &&
            facture.ligneFactures!.isNotEmpty) ...[
          for (var i = 0; i < facture.ligneFactures!.length && i < 5; i++) ...[
            _buildTableRow(facture.ligneFactures![i]),
            if (facture.ligneFactures![i].fraisDivers != null &&
                facture.ligneFactures![i].fraisDivers!.isNotEmpty) ...[
              ...facture.ligneFactures![i].fraisDivers!
                  .map((frais) => pw.TableRow(
                        children: [
                          frais.libelle,
                          "-",
                          "-",
                          "-",
                          Formatter.formatAmount(
                            calculMontantFraisDivers(
                              frais: frais,
                              tauxTVA: facture.tauxTVA!,
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
        ...facture.facturesAcompte
            .where((factureAcompte) =>
                factureAcompte.oldPenalties != null &&
                factureAcompte.oldPenalties!.isNotEmpty)
            .expand(
                (factureAcompte) => factureAcompte.oldPenalties!.map((penalty) {
                      return pw.TableRow(
                        children: [
                          penalty.libelle,
                          "-",
                          "-",
                          "-",
                          Formatter.formatAmount(penalty.montant),
                        ].map((e) => _buildBodyTableCell(e)).toList(),
                      );
                    })),
        _buildTableFooter(
          libelle: "TOTAL HT",
          montant: Formatter.formatAmount(calculerMontantHT(facture: facture)),
        ),
        if (facture.reduction != null && facture.reduction!.valeur != 0) ...[
          pw.TableRow(
            children: [
              "Réduction ${facture.reduction?.unite != null ? "(%)" : ""}",
              "-",
              "-",
              "-",
              Formatter.formatAmount(calculerReduction(
                  lignes: facture.ligneFactures!,
                  reduction: facture.reduction!)),
            ]
                .map(
                  (e) => _buildBodyTableCell(e),
                )
                .toList(),
          ),
        ],
        pw.TableRow(
          children: [
            "TVA ${facture.tva! ? "(${facture.client!.pays!.tauxTVA}%)" : ""}",
            "-",
            "-",
            "-",
            Formatter.formatAmount(
              calculerTva(
                lignes: facture.ligneFactures!,
                reduction: facture.reduction!,
                tva: facture.tva!,
                tauxTVA: facture.tauxTVA!,
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
          montant: Formatter.formatAmount(facture.montant! +
              (facture.facturesAcompte.fold(
                    0.0,
                    (sum, acompte) =>
                        sum! +
                        (acompte.oldPenalties
                                ?.fold(0.0, (s, p) => s! + p.montant) ??
                            0.0),
                  ) ??
                  0.0)),
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
        ligne.unit == Constant.units[0] ? "-" : (ligne.unit),
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
      child: pw.Text(text,
          style: style,
          textAlign: int.tryParse(Formatter.parseAmount(text)) != null ||
                  double.tryParse(Formatter.parseAmount(text)) != null
              ? pw.TextAlign.right
              : pw.TextAlign.left),
    );
  }

  static pw.TableRow _buildTableHeader({required List<String> titles}) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: pdfcouleur),
      children: titles
          .map(
            (text) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
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
              child: pw.Text(text, style: style),
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _buildTotalAmount(double montant) {
    return pw.RichText(
      text: pw.TextSpan(
        text: "Arrêtée la présente facture à la somme totale ${[
          "a",
          "e",
          "i",
          "o",
          "u",
          "y"
        ].contains(convertNumberToWords(
          montant,
        ).trim().split('').first.toLowerCase()) ? 'd\'' : "de "}",
        style: const pw.TextStyle(fontSize: 10),
        children: [
          pw.TextSpan(
            text: "${convertNumberToWords(
              montant,
            )} FCFA",
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
static pw.Widget _buildFooter({
    required List<BanqueModel> banques,
    required List<pw.ImageProvider?> images,
    required StrictEntreprise entreprise,
  }) {
    return pw.Align(
      alignment: pw.Alignment.bottomLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(height: 1, color: PdfColors.grey),
          pw.SizedBox(height: 8),
          pw.RichText(
            text: pw.TextSpan(
              text: "Payez à l'ordre de ",
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
              ),
              children: [
                pw.TextSpan(
                  text: entreprise.raisonSociale.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 12,
            runSpacing: 8,
            direction: pw.Axis.horizontal,
            children: banques.asMap().entries.map((entry) {
              final banque = entry.value;
              return pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    height: 12,
                    width: 12,
                    decoration: pw.BoxDecoration(
                      color: pdfcouleur,
                      image: banque.logo != null
                          ? pw.DecorationImage(
                              image: images[entry.key]!,
                              fit: pw.BoxFit.fill,
                            )
                          : null,
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    banque.name,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                  pw.Text(
                    banque.type == CanauxPaiement.operateurMobile
                        ? " : ${banque.numCompte}"
                        : " : ${banque.codeBanque}-${banque.codeGuichet}-${banque.codeBIC}-${banque.numCompte}-${banque.cleRIB}",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  
  static pw.Widget _buildHeader(
    FactureModel facture,
    pw.ImageProvider logoImage,
    pw.ImageProvider? clientLogoImage, {
    required StrictEntreprise entreprise,
  }) {
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
                        text: 'FACTURE ',
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(
                      'N° ${facture.reference}',
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
                      "${entreprise.ville}, le ${getStringDate(time: facture.dateEtablissementFacture!)}",
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    if (facture.ligneFactures!.isNotEmpty &&
                        facture.ligneFactures!.first.dureeLivraison != null)
                      pw.Text(
                        "Durée de livraison : ${convertDuration(
                          durationMs:
                              facture.ligneFactures!.first.dureeLivraison!,
                        ).compteur.toString()} ${convertDuration(
                          durationMs:
                              facture.ligneFactures!.first.dureeLivraison!,
                        ).unite}",
                        style: const pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    // if (facture.datePayementEcheante != null)
                    //   pw.Text(
                    //     "À payer avaprnt : ${getStringDate(time: facture.datePayementEcheante!)}",
                    //     style: const pw.TextStyle(
                    //       fontSize: 10,
                    //     ),
                    //   )
                    // else
                    //   pw.Text(
                    //     "À payer avant : ${getStringDate(
                    //       time: facture
                    //           .facturesAcompte!.first.datePayementEcheante,
                    //     )}",
                    //     style: const pw.TextStyle(
                    //       fontSize: 10,
                    //     ),
                    //   ),
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
                        facture.client!.toStringify(),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        "${facture.client!.adresse}, ${facture.client!.pays!.name}",
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
