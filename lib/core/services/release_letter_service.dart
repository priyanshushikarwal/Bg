import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/bg_model.dart';
import 'file_save_helper.dart';

class ReleaseLetterService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '', // No symbol in the table cell based on image
    decimalDigits: 2,
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _letterDateFormat = DateFormat('dd MMM yyyy');

  /// Generates a PDF release letter matching the AVVNL formal style
  static Future<String> generateReleaseLetter(BgModel bg) async {
    final pdf = pw.Document();

    // Define basic styles
    final textStyle = pw.TextStyle(fontSize: 10, font: pw.Font.times());
    final boldStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: pw.Font.timesBold(),
    );
    final headerStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      font: pw.Font.timesBold(),
    );

    // Fallback if discom is empty
    final orgName = bg.discom.isNotEmpty
        ? bg.discom.toUpperCase()
        : 'AJMER VIDYUT VITRAN NIGAM LIMITED';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo Placeholder
                  pw.Container(
                    width: 50,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 2),
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text("LOGO", style: pw.TextStyle(fontSize: 8)),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  // Center Text
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('ID No.   50,483', style: boldStyle),
                        ),
                        pw.Text(
                          orgName,
                          style: headerStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'OFFICE OF THE ACCOUNTS OFFICER(MM)',
                          style: boldStyle,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Corporate Identification Number (CIN)-U40109RJ2000SGC016482',
                          style: textStyle,
                        ),
                        pw.Text(
                          'Registered Office: Vidyut Bhawan, Makarwali Road, Panchsheel Nagar, Ajmer-305004',
                          style: textStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Phone : +0145-2642530. Fax: +91-0145-2644542; Email:aommavvnl@gmail.com',
                          style: textStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Web site - http://energy.rajasthan.gov.in/avvnl',
                          style: textStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),

              // --- Ref No & Date ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'No. $orgName/ AO(MM)- Sec-IV/XEN( MM-)/ TN-${bg.tenderNumber}/D',
                    style: boldStyle,
                  ),
                  pw.Transform.rotate(
                    angle: -0.1,
                    child: pw.Text(
                      '1609',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: pw.Font.courier(),
                        color: PdfColors.blue,
                      ),
                    ),
                  ), // Simulated stamp/handwritten number
                  pw.Text(
                    'Dt  ${_letterDateFormat.format(DateTime.now()).toUpperCase()}',
                    style: boldStyle,
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

              // --- To Address ---
              pw.Text('The Manager,', style: textStyle),
              pw.Text(bg.bankName, style: textStyle),
              pw.Text(
                '2nd floor , Krishna Towers, Plot No.57, Sardar Patel Marg, C- Scheme, Jaipur',
                style: textStyle,
              ), // Placeholder address as we don't have bank address in model

              pw.SizedBox(height: 15),

              // --- Subject ---
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'Sub: ', style: boldStyle),
                    pw.TextSpan(
                      text:
                          'Release/Cancellation of Bank Guarantee(s) against P.O.No.$orgName/SE(MM)/XENMM-)/${bg.tenderNumber}/P.O.No. furnished on behalf of M/s ',
                      style: textStyle,
                    ),
                    pw.TextSpan(
                      text: bg.firmName.toUpperCase(),
                      style: boldStyle,
                    ),
                    pw.TextSpan(
                      text: ', Contact No. - 9414050061, 8764237761',
                      style: textStyle,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Text('Dear Sir,', style: textStyle),
              pw.Text(
                'With reference to above, it is to intimate you that under mentioned Bank Guarantee furnished by you against subject purchase order has been released/cancelled.',
                style: textStyle,
                textAlign: pw.TextAlign.justify,
              ),

              pw.SizedBox(height: 15),

              // --- Table ---
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40), // Sr No
                  1: const pw.FixedColumnWidth(80), // Kind of BG
                  2: const pw.FlexColumnWidth(2), // BG No & Date
                  3: const pw.FlexColumnWidth(1.5), // Amount
                  4: const pw.FixedColumnWidth(80), // Validity
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    children: [
                      _buildHeaderCell('Sr. No.', boldStyle),
                      _buildHeaderCell('Kind of BG', boldStyle),
                      _buildHeaderCell('BG No. & Date', boldStyle),
                      _buildHeaderCell('Amount in Rs.', boldStyle),
                      _buildHeaderCell('Validity', boldStyle),
                    ],
                  ),
                  // Data Row
                  pw.TableRow(
                    children: [
                      _buildCell('1', textStyle),
                      _buildCell(
                        'BG',
                        boldStyle,
                      ), // Assuming generic BG type for now
                      _buildCell(
                        '${bg.bgNumber}\n\n${_dateFormat.format(bg.issueDate)}',
                        boldStyle,
                      ),
                      _buildCell(_currencyFormat.format(bg.amount), boldStyle),
                      _buildCell(
                        _dateFormat.format(bg.currentExpiryDate),
                        boldStyle,
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              // --- Footer Text ---
              pw.Text(
                'The Release / Cancellation of above BG is without prejudice to the terms and conditions of subject purchase order the original BG duly discharged/cancelled is enclosed , herewith,',
                style: textStyle,
                textAlign: pw.TextAlign.justify,
              ),
              pw.Text('Thanking you', style: textStyle),

              pw.SizedBox(height: 20),

              // --- Signatories ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Yours sincerely', style: textStyle),
                      pw.SizedBox(height: 20),
                      // Mock Signature
                      pw.Container(
                        child: pw.Text(
                          "Sig.",
                          style: pw.TextStyle(
                            font: pw.Font.zapfDingbats(),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      pw.Text('(R.C. Somani)', style: boldStyle),
                      pw.Text(
                        'Asstt. Accounts Officer-I(MM)',
                        style: boldStyle,
                      ),
                      pw.Text('$orgName, Ajmer', style: boldStyle),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // --- Encl & Copy To ---
              pw.Text('Encl: As above', style: textStyle),
              pw.Text('Copy to : -', style: textStyle),
              pw.SizedBox(height: 5),
              pw.Text(
                '1. The Executive Engineer(MM-E 1), $orgName, ajmer.BG(s) has/have been released in in compliance of release order No  14289  Dt.${_dateFormat.format(DateTime.now())} issued by the SE.(MM)$orgName,Ajmer',
                style: textStyle,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '2. M/s. ${bg.firmName}, [Address Placeholder]',
                style: textStyle,
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      child: pw.Text(
                        "Sig.",
                        style: pw.TextStyle(
                          font: pw.Font.zapfDingbats(),
                          fontSize: 20,
                        ),
                      ), // Mock Signature
                    ),
                    pw.Text('Asstt. Accounts Officer-I(MM)', style: boldStyle),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save logic
    final fileName =
        'Release_Letter_${bg.bgNumber.replaceAll('/', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final bytes = await pdf.save();

    // Delegate to helper
    return await saveAndOpenFile(fileName, bytes);
  }

  static pw.Widget _buildHeaderCell(String text, pw.TextStyle style) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
      ),
    );
  }
}
