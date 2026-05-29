import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';

class PdfService {
  static Future<void> generateAndPrintBill(Bill bill) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Jay Janaki Electronics',
                        style: pw.TextStyle(font: boldFont, fontSize: 24)),
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 24,
                            color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Customer Details:',
                          style: pw.TextStyle(font: boldFont)),
                      pw.Text('Name: ${bill.customerName}'),
                      pw.Text('Phone: ${bill.customerPhone}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          'Date: ${DateFormat('dd-MM-yyyy HH:mm').format(bill.date)}'),
                      pw.Text(
                          'Invoice #: ${bill.id?.substring(0, 8) ?? 'NEW'}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Item',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Price',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child:
                            pw.Text('Qty', style: pw.TextStyle(font: boldFont)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Total',
                            style: pw.TextStyle(font: boldFont)),
                      ),
                    ],
                  ),
                  ...bill.items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.productName),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.price.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              (item.price * item.quantity).toStringAsFixed(2)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Amount: ',
                          style: pw.TextStyle(font: boldFont, fontSize: 18)),
                      pw.Text('Rs. ${bill.totalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 18,
                              color: PdfColors.blue700)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Thank you for your business!',
                    style: pw.TextStyle(
                        font: font, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
