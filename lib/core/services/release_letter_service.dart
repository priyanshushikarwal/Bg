import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/bg_model.dart';
import 'file_save_helper.dart';

class ReleaseLetterService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static Future<String> generateReleaseLetter(BgModel bg) async {
    final pdf = pw.Document();

    const pageMargin = pw.EdgeInsets.all(40);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pageMargin,
        build: (pw.Context context) {
          final textStyle = pw.TextStyle(
            fontSize: 10.5,
            font: pw.Font.times(),
            lineSpacing: 1.5,
          );
          final boldStyle = pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            font: pw.Font.timesBold(),
          );
          final titleStyle = pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            font: pw.Font.timesBold(),
          );
          final subHeaderStyle = pw.TextStyle(
            fontSize: 11,
            font: pw.Font.times(),
          );

          final firmInitials = bg.firmName
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .join('')
              .toUpperCase();
          final currentYear = DateTime.now().year;
          final fiscalYear = '${currentYear % 100}-${(currentYear + 1) % 100}';
          final refNo = 'Ref $firmInitials/$fiscalYear/';

          return pw.Stack(
            children: [
              pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.5,
                  child: pw.Text(
                    bg.firmName.split(' ').take(3).join(' ').toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 80,
                      color: PdfColors.grey200,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'M/s ${bg.firmName.toUpperCase()}',
                          style: titleStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '16A, JAMANA COLONY, VIDHYADHAR NAGAR, JAIPUR 302039',
                          style: subHeaderStyle,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text('EMAIL ID : ', style: subHeaderStyle),
                            pw.Text(
                              'bhitech2021@gmail.com',
                              style: subHeaderStyle.copyWith(
                                color: PdfColors.blue,
                                decoration: pw.TextDecoration.underline,
                              ),
                            ),
                            pw.Text(
                              ' Mob No. 6376270060',
                              style: subHeaderStyle,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          height: 1.5,
                          color: PdfColor.fromHex(
                            '#800000',
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(refNo, style: boldStyle),
                      pw.Text(
                        'Date ${_dateFormat.format(DateTime.now())}',
                        style: boldStyle,
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  pw.Text('To,', style: boldStyle),
                  pw.Text('The Branch Manager', style: boldStyle),
                  pw.Text(bg.bankName, style: boldStyle),
                  pw.Text('Branch', style: boldStyle),

                  pw.SizedBox(height: 20),

                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text:
                              'Subject: Submission of Original Bank Guarantee for Cancellation against TN -',
                          style: boldStyle,
                        ),
                        pw.TextSpan(text: bg.tenderNumber, style: boldStyle),
                        pw.TextSpan(
                          text:
                              '\nRef - ${bg.discom} Release Letter No. 16091 Dated ${_dateFormat.format(DateTime.now().subtract(const Duration(days: 30)))}.',
                          style: boldStyle,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  pw.Text('Respected Sir/Madam,', style: textStyle),
                  pw.SizedBox(height: 10),

                  pw.RichText(
                    textAlign: pw.TextAlign.justify,
                    text: pw.TextSpan(
                      style: textStyle,
                      children: [
                        pw.TextSpan(text: 'We hereby submit the '),
                        pw.TextSpan(
                          text: 'original Bank Guarantee',
                          style: boldStyle,
                        ),
                        pw.TextSpan(
                          text:
                              ', as detailed below, for cancellation at your end.',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  pw.RichText(
                    textAlign: pw.TextAlign.justify,
                    text: pw.TextSpan(
                      style: textStyle,
                      children: [
                        pw.TextSpan(
                          text:
                              'The said Bank Guarantee was issued by your bank in favor of ',
                        ),
                        pw.TextSpan(text: bg.discom, style: boldStyle),
                        pw.TextSpan(text: ' against a tender '),
                        pw.TextSpan(
                          text: 'TN-${bg.tenderNumber}',
                          style: boldStyle,
                        ),
                        pw.TextSpan(text: '. We have now received the '),
                        pw.TextSpan(
                          text:
                              'original Bank Guarantee along with the official BG Cancellation / Discharge Letter',
                          style: boldStyle,
                        ),
                        pw.TextSpan(text: ' from the concerned DISCOM.'),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  pw.RichText(
                    textAlign: pw.TextAlign.justify,
                    text: pw.TextSpan(
                      style: textStyle,
                      children: [
                        pw.TextSpan(
                          text:
                              'As the purpose of the Bank Guarantee has been duly completed and no further claim remains, we kindly request you to ',
                        ),
                        pw.TextSpan(
                          text:
                              'cancel the above-mentioned Bank Guarantee and release the related margin / FD / lien amount',
                          style: boldStyle,
                        ),
                        pw.TextSpan(text: ', as applicable, at the earliest.'),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  pw.Text('Bank Guarantee Details:', style: boldStyle),
                  pw.SizedBox(height: 8),
                  _buildBulletPoint(
                    'BG Number: ',
                    bg.bgNumber,
                    boldStyle,
                    textStyle,
                  ),
                  _buildBulletPoint(
                    'BG Amount: ',
                    '${_currencyFormat.format(bg.amount)}/-',
                    boldStyle,
                    textStyle,
                  ),
                  _buildBulletPoint(
                    'Date of Issue: ',
                    _dateFormat.format(bg.issueDate),
                    boldStyle,
                    textStyle,
                  ),
                  _buildBulletPoint(
                    'Issued in favor of: ',
                    bg.discom,
                    boldStyle,
                    textStyle,
                  ),

                  pw.SizedBox(height: 20),

                  pw.Text('Enclosures:', style: boldStyle),
                  pw.SizedBox(height: 8),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('1. Original Bank Guarantee', style: textStyle),
                        pw.Text(
                          '2. BG Cancellation / Discharge Letter issued by ${bg.discom}',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  pw.Text(
                    'We request you to kindly process the cancellation and confirm the same to us.',
                    style: textStyle,
                  ),
                  pw.SizedBox(height: 15),
                  pw.Text('Thanking you.', style: textStyle),
                  pw.SizedBox(height: 10),
                  pw.Text('Yours faithfully,', style: textStyle),
                  pw.SizedBox(height: 15),
                  pw.Text('For ${bg.firmName}', style: boldStyle),

                  pw.Spacer(),

                  pw.Text('Authorized Signatory', style: textStyle),
                ],
              ),
            ],
          );
        },
      ),
    );

    final fileName = 'Release_Letter_${bg.bgNumber.replaceAll('/', '_')}.pdf';
    final bytes = await pdf.save();

    return await saveAndOpenFile(fileName, bytes);
  }

  static pw.Widget _buildBulletPoint(
    String label,
    String value,
    pw.TextStyle boldStyle,
    pw.TextStyle regularStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4, right: 8),
            child: pw.Container(
              width: 3.5,
              height: 3.5,
              decoration: const pw.BoxDecoration(
                color: PdfColors.black,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.Text(label, style: regularStyle),
          pw.Expanded(child: pw.Text(value, style: boldStyle)),
        ],
      ),
    );
  }
}
