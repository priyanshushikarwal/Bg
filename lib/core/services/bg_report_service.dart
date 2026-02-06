import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/bg_model.dart';
import 'file_save_helper.dart';

class BgReportService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static Future<String> generateBgListReport(
    List<BgModel> bgs,
    String firmName,
  ) async {
    final pdf = pw.Document();

    // Sort BGs by expiry date (ascending)
    bgs.sort((a, b) => a.currentExpiryDate.compareTo(b.currentExpiryDate));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        firmName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Bank Guarantee Report',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated: ${_dateFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Total BGs: ${bgs.length}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildHeaderCell('Sr'),
                    _buildHeaderCell('BG Number'),
                    _buildHeaderCell('Bank'),
                    _buildHeaderCell('Amount'),
                    _buildHeaderCell('Issue Date'),
                    _buildHeaderCell('Expiry Date'),
                    _buildHeaderCell('Claim Date'),
                    _buildHeaderCell('Status'),
                    _buildHeaderCell('Days Left'),
                  ],
                ),
                // Data Rows
                ...bgs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bg = entry.value;
                  final daysLeft = bg.currentExpiryDate
                      .difference(DateTime.now())
                      .inDays;

                  return pw.TableRow(
                    decoration: index % 2 == 1
                        ? const pw.BoxDecoration(color: PdfColors.grey100)
                        : null,
                    children: [
                      _buildCell((index + 1).toString()),
                      _buildCell(bg.bgNumber),
                      _buildCell(bg.bankName),
                      _buildCell(
                        _currencyFormat.format(bg.amount),
                        alignRight: true,
                      ),
                      _buildCell(_dateFormat.format(bg.issueDate)),
                      _buildCell(_dateFormat.format(bg.currentExpiryDate)),
                      _buildCell(_dateFormat.format(bg.currentClaimExpiryDate)),
                      _buildCell(bg.status.name.toUpperCase()),
                      _buildCell(
                        daysLeft.toString(),
                        color: daysLeft < 0
                            ? PdfColors.red
                            : (daysLeft < 30
                                  ? PdfColors.orange
                                  : PdfColors.black),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Amount: ${_currencyFormat.format(bgs.fold<double>(0, (sum, bg) => sum + bg.amount))}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final fileName =
        'BG_Report_${firmName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final bytes = await pdf.save();

    return await saveAndOpenFile(fileName, bytes);
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildCell(
    String text, {
    bool alignRight = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, color: color),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }
}
