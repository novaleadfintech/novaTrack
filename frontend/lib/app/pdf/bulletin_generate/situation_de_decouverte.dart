import 'package:frontend/helper/amout_formatter.dart';
import 'package:frontend/helper/date_helper.dart';
import 'package:frontend/model/bulletin_paie/decouverte_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../model/entreprise/entreprise.dart';
import '../../../model/request_response.dart';
import '../../../service/entreprise_service.dart';
import '../../integration/popop_status.dart';
import '../load_file.dart';
import '../utils/download_helper.dart';

class DecouvertePdfGenerator {
  static Future<RequestResponse?> generateAndDownloadPdf({
    required DecouverteModel decouverte,
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
              font: pw.Font.courier(),
              fontNormal: pw.Font.courier(),
              fontBold: pw.Font.courierBold(),
              wordSpacing: 1,
              letterSpacing: 0,
              color: PdfColors.black,
            ),
          ),
          build: (context) => [
            pw.Column(
              children: [
                _buildContent(
                  decouvert: decouverte,
                  logoImage: logoImage,
                  entreprise: entreprise,

                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 16),
                  child: pw.Divider(
                    borderStyle: pw.BorderStyle.dashed,
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                ),
                _buildContent(
                  decouvert: decouverte,
                  logoImage: logoImage,
                  entreprise: entreprise,

                ),
              ],
            )
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'decouverte_${decouverte.salarie.personnel.nom}_${decouverte.salarie.personnel.prenom}.pdf';
      PdfDownloadHelper.downloadPdf(bytes: bytes, fileName: fileName);
      return RequestResponse(status: PopupStatus.success);
    } catch (err) {
       

      return RequestResponse(
        status: PopupStatus.customError,
        message: err.toString(),
      );
    }
  }
}

pw.Widget _buildContent({
  required DecouverteModel decouvert,
  required pw.ImageProvider logoImage,
  required StrictEntreprise entreprise,

}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(
                    logoImage,
                    height: 50,
                  ),
                  pw.Text(
                    textAlign: pw.TextAlign.start,
                    entreprise.adresse,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ]),
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${decouvert.salarie.personnel.nom} ${decouvert.salarie.personnel.prenom}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Tel : +${decouvert.salarie.personnel.pays!.code} ${decouvert.salarie.personnel.telephone}",
                    ),
                    pw.Text(
                      "${decouvert.salarie.personnel.adresse}, ${decouvert.salarie.personnel.pays!.name}",
                    ),
                  ],
                ),
              ),
            ],
          ),
          
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'FICHE D\'AVANCE SUR SALAIRE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Date : ${getStringDate(time: DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Row(children: [
        pw.Text("Motif:",
            style: pw.TextStyle(
              decoration: pw.TextDecoration.underline,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(width: 8),
        pw.Text(
          decouvert.justification,
        ),
      ]),
      pw.SizedBox(height: 16),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1),
          4: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                "Montant sollicité",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                "${Formatter.formatAmount(decouvert.montant)} FCFA",
              ),
            )
          ]),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(
                  "Durée de reversement",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(
                  "${decouvert.dureeReversement} mois",
                ),
              ),
            ],
          ),
          if (decouvert.montantRestant.toInt() != 0)
            pw.TableRow(children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(
                  "Montant restant",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(
                  "${Formatter.formatAmount(decouvert.montantRestant)} FCFA",
                ),
              )
            ]),
        ],
      ),
      pw.SizedBox(height: 16),
      pw.Container(
        height: 100,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
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
                    "${decouvert.salarie.personnel.nom} ${decouvert.salarie.personnel.prenom}",
                  )
                ]),
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
              pw.Text(
                "Employeur",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
                  pw.Text(
                    "Fait, le ${getStringDate(time: decouvert.dateEnregistrement)}",
                  ),
            ]),
          ],
        ),
      )
    ],
  );
}
