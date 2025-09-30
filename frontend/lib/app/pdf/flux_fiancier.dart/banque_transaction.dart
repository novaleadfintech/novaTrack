import 'package:frontend/app/pdf/color.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/model/flux_financier/flux_financier_model.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../helper/amout_formatter.dart';
import '../../../helper/nomber_converter.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/request_response.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import '../load_file.dart';
import '../utils/brouillard.dart';
import '../utils/download_helper.dart';

class TransactionPdfGenerator {
  static Future<RequestResponse> generateAndDownloadPdf({
    required List<FluxFinancierModel> fluxFinanciers,
    required BanqueModel banque,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    try {
      StrictEntreprise? entreprise =
          await EntrepriseService.getEntrepriseInformation();
      final logoImage = await loadNetworkImage(
        url: entreprise.logo,
      );
      final banquelogoImage = banque.logo == null
          ? null
          : await loadNetworkImage(
              url: banque.logo!,
            );

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
                fluxFinanciers: fluxFinanciers,
                entreprise: entreprise,
                logoImage: logoImage,
                banqueLogoImage: banquelogoImage,
                banque: banque,
                dateDebut: dateDebut,
                dateFin: dateFin,
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
      final bytes = await pdf.save();
      final fileName =
          'transaction_${banque.name.replaceAll("/", "_")}_${banque.country!.name.replaceAll("/", "_")}.pdf';
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
    required List<FluxFinancierModel> fluxFinanciers,
    required pw.ImageProvider logoImage,
    required pw.ImageProvider? banqueLogoImage,
    required BanqueModel banque,
    required DateTime dateDebut,
    required DateTime dateFin,
    required StrictEntreprise entreprise,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(
          banque: banque,
          logoImage: logoImage,
          banquelogoImage: banqueLogoImage,
          dateDebut: dateDebut,
          dateFin: dateFin,
        ),
        pw.SizedBox(
          height: 16,
        ),
        _buildCustomTable(fluxFinanciers: fluxFinanciers),
        pw.SizedBox(
          height: 16,
        ),
        _buildTotalLetterAmount(fluxFinanciers: fluxFinanciers),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildCustomTable({
    required List<FluxFinancierModel> fluxFinanciers,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.IntrinsicColumnWidth(),
        1: const pw.FlexColumnWidth(),
        2: const pw.IntrinsicColumnWidth(),
        3: const pw.IntrinsicColumnWidth(),
        4: const pw.IntrinsicColumnWidth(),
      },
      border: pw.TableBorder.all(
        color: pdfcouleur,
        width: 1,
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pdfcouleur),
          children: banqueTransactionTitle
              .map(
                (title) => pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(),
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(),
              child: pw.Text(
                "",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(),
              child: pw.Text(
                "-",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(),
              child: pw.Text(
                "Solde initial",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(),
              child: pw.Text(
                Formatter.formatAmount(
                  fluxFinanciers.first.bank!.soldeReel,
                ),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(),
              child: pw.Text(
                "",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        ...fluxFinanciers.map(
          (flux) => pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(),
                child: pw.Text(
                  getShortStringDate(time: flux.dateOperation!),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(),
                child: pw.Text(
                  flux.libelle!,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(),
                child: pw.Text(
                  flux.status!.label,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(),
                child: pw.Text(
                  flux.type == FluxFinancierType.input
                      ? Formatter.formatAmount(flux.montant)
                      : "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(),
                child: pw.Text(
                  flux.type == FluxFinancierType.input
                      ? ""
                      : Formatter.formatAmount(flux.montant),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._buildAmountTable(fluxFinanciers: fluxFinanciers)
      ],
    );
  }

  

  static List<pw.TableRow> _buildAmountTable({
    required List<FluxFinancierModel> fluxFinanciers,
  }) {
    double totalEntrees = 0.0;
    double totalSorties = 0.0;
    double resultat = fluxFinanciers.first.bank!.soldeReel;

    for (var flux in fluxFinanciers) {
      if (flux.type == FluxFinancierType.input) {
        totalEntrees += flux.montant;
        resultat += flux.montant;
      } else if (flux.type == FluxFinancierType.output) {
        totalSorties += flux.montant;
        resultat -= flux.montant;
      }
    }
    return [
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: pdfcouleur,
          border: pw.TableBorder(
            top: pw.BorderSide(color: PdfColors.white, width: 2),
          ),
        ),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              "TOTAL",
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text("-", style: pw.TextStyle(color: pdfcouleur)),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              Formatter.formatAmount(totalEntrees),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              Formatter.formatAmount(totalSorties),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: resultat < 0
              ? PdfColors.red100
              : resultat > 0
                  ? PdfColors.green100
                  : PdfColors.grey100,
          border: pw.TableBorder(
            top: pw.BorderSide(color: PdfColors.white, width: 2),
          ),
        ),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              "SOLDE",
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text("-",
              style: pw.TextStyle(
                color: PdfColors.grey100,
              )),
          pw.Text("-",
              style: pw.TextStyle(
                color: PdfColors.grey100,
              )),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(),
            child: pw.Text(
              Formatter.formatAmount(resultat),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  static pw.Widget _buildTotalLetterAmount(
      {required List<FluxFinancierModel> fluxFinanciers}) {
    double totalEntrees = 0.0;
    double totalSorties = 0.0;

    for (var flux in fluxFinanciers) {
      if (flux.type == FluxFinancierType.input) {
        totalEntrees += flux.montant;
      } else if (flux.type == FluxFinancierType.output) {
        totalSorties += flux.montant;
      }
    }
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              text: "Total des entrées en lettre : ",
              style: const pw.TextStyle(fontSize: 10),
              children: [
                pw.TextSpan(
                  text: " ${convertNumberToWords(
                    totalEntrees,
                  )} FCFA",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.RichText(
            text: pw.TextSpan(
              text: "Total des sorties en lettre : ",
              style: const pw.TextStyle(fontSize: 10),
              children: [
                pw.TextSpan(
                  text: " ${convertNumberToWords(
                    totalSorties,
                  )} FCFA",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ]);
  }

  static pw.Widget _buildHeader({
    required BanqueModel banque,
    required pw.ImageProvider logoImage,
    required pw.ImageProvider? banquelogoImage,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) {
    return pw.SizedBox(
        child: pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                width: 150,
                height: 50,
                child: pw.Image(logoImage),
              ),
            ],
          ),
          pw.SizedBox(
            width: 100,
          ),
          if (banquelogoImage != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  width: 150,
                  height: 50,
                  child: pw.Image(banquelogoImage),
                ),
              ],
            )
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        "LISTE DES DIFFERENTES TRANSACTIONS DE ${banque.name.toUpperCase()} ${banque.country!.name.toUpperCase()}",
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Text(
        "(Du ${getStringDate(time: dateDebut)} au ${getStringDate(time: dateFin)})",
      ),
    ]));
  }
}
