import '../color.dart';
import '../../../helper/date_helper.dart';
import '../../../model/entreprise/entreprise.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../helper/amout_formatter.dart';
import '../../../helper/nomber_converter.dart';
import '../../../model/request_response.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import '../load_file.dart';
import '../utils/brouillard.dart';
import '../utils/download_helper.dart';

class FluxPdfGenerator {
  static Future<RequestResponse> generateAndDownloadPdf({
    required List<FluxFinancierModel> fluxFinanciers,
    required DateTime? dateDebut,
    required DateTime? dateFin,
      required FluxFinancierType? type
  }) async {
    try {
      StrictEntreprise? entreprise =
          await EntrepriseService.getEntrepriseInformation();
      final logoImage = await loadNetworkImage(
        url: entreprise.logo,
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
                type: type,
                fluxFinanciers: fluxFinanciers,
                logoImage: logoImage,
                dateDebut: dateDebut,
                dateFin: dateFin,
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
      final bytes = await pdf.save();
      final fileName = (dateDebut != null && dateFin != null)
          ? 'transaction_du_${getShortStringDate(time: dateDebut)}_${getShortStringDate(time: dateFin)}.pdf'
          : "transaction.pdf";
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
    required DateTime? dateDebut,
    required DateTime? dateFin,
    required StrictEntreprise entreprise, 
    required FluxFinancierType? type,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(
          type: type,
          logoImage,
          dateFin,
          dateDebut,
        ),
        pw.SizedBox(
          height: 16,
        ),
        _buildCustomTable(fluxFinanciers: fluxFinanciers, type: type),
        pw.SizedBox(
          height: 16,
        ),
        _buildTotalLetterAmount(fluxFinanciers: fluxFinanciers, type: type),
        pw.SizedBox(height: 16),
       
      ],
    );
  }

static pw.Widget _buildTotalLetterAmount({
    required List<FluxFinancierModel> fluxFinanciers,
    required FluxFinancierType? type,
  }) {
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
          if (type != FluxFinancierType.output)
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
          if (type != FluxFinancierType.input)
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
  static pw.Widget _buildCustomTable({
    required List<FluxFinancierModel> fluxFinanciers,
    required FluxFinancierType? type,
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
          children: brouillardTableTitle
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
                  flux.bank!.name,
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
        _buildAmountTable(fluxFinanciers: fluxFinanciers, type: type),
      ],
    );
  }

  static pw.TableRow _buildAmountTable({
    required List<FluxFinancierModel> fluxFinanciers,
    required FluxFinancierType? type,
  }) {
    double totalEntrees = 0.0;
    double totalSorties = 0.0;

    for (var flux in fluxFinanciers) {
      if (flux.type == FluxFinancierType.input) {
        totalEntrees += flux.montant;
      } else if (flux.type == FluxFinancierType.output) {
        totalSorties += flux.montant;
      }
    }
    return pw.TableRow(
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
        pw.Text("-", style: pw.TextStyle(color: pdfcouleur)),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(),
          child: pw.Text(
            type != FluxFinancierType.output
                ? Formatter.formatAmount(totalEntrees)
                : "",
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
            type != FluxFinancierType.input
                ? Formatter.formatAmount(totalSorties)
                : "",
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  static pw.Widget _buildHeader(
    pw.ImageProvider logoImage,
    DateTime? dateDebut,
    DateTime? dateFin,
    {
    required FluxFinancierType? type,
  }
  ) {
    return pw.SizedBox(
        child: pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            width: 150,
            height: 50,
            child: pw.Image(logoImage),
          ),
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "LISTE DES DIFFERENTES TRANSACTIONS ${type == FluxFinancierType.output ? "DE SORTIES" : type == FluxFinancierType.input ? "D'ENTRÉES" : ""}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (dateDebut != null && dateFin != null)
                  pw.Text(
                    "(Du ${getStringDate(time: dateDebut)} au ${getStringDate(time: dateFin)})",
                  ),
              ]),
        ],
      ),
    ]));
  }
}
