import 'dart:io';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class Invoice {
  final Supplier? supplier;
  final Customer? customer;
  final InvoiceInfo? info;
  final List<InvoiceItem>? items;

  Invoice({this.customer, this.info, this.items, this.supplier});
}

class Supplier {
  String? name;
  String? address;
  String? gstNumber;
  String? paymentInfo;
  double? gstValue;
  Supplier({
    this.address,
    this.name,
    this.paymentInfo,
    this.gstNumber,
    this.gstValue,
  });
}

class Customer {
  final String? name;
  final String? address;

  Customer({this.name, this.address});
}

class InvoiceInfo {
  final DateTime? billDate;
  final DateTime? dueDate;
  final String? description;

  InvoiceInfo({this.billDate, this.description, this.dueDate});
}

class PdfApi {
  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    await OpenFile.open(file.path);
  }
}

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();
    pdf.addPage(MultiPage(
      build: (context) => [
        buildSupplierHeader(invoice),
        Container(height: PdfPageFormat.cm * 1.5),
        buildCustomer(invoice),
        Container(height: PdfPageFormat.cm * 1.5),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
    ));
    int max = 1000000000;
    return PdfApi.saveDocument(
        name: 'invoice_${Random().nextInt(max)}.pdf', pdf: pdf);
  }

  static Widget buildTitle(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INVOICE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 0.8 * PdfPageFormat.cm,
        ),
        Text(invoice.info!.description!),
        SizedBox(
          height: 0.8 * PdfPageFormat.cm,
        ),
      ],
    );
  }

  static Widget buildTotal(Invoice invoice) {
    double netTotal = 0;
    double gst = invoice.items!.first.gst!;
    for (var item in invoice.items!) {
      netTotal += (item.quantity! * item.unitPrice!);
    }
    final gstAmount = netTotal * gst;
    final total = gstAmount + netTotal;
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(
            flex: 6,
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: netTotal.toStringAsFixed(2),
                  unite: true,
                ),
                buildText(
                  title: 'GST ${gst * 100} %',
                  value: gstAmount.toStringAsFixed(2),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Total Amount Due',
                  value: '$total',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unite: true,
                ),
                SizedBox(
                  height: 2 * PdfPageFormat.mm,
                ),
                Divider(
                  height: 1,
                ),
                SizedBox(
                  height: 0.5 * PdfPageFormat.mm,
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildText({
    required String? title,
    required String? value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ??
        TextStyle(
          fontWeight: FontWeight.bold,
        );
    return Container(
      child: Row(children: [
        Expanded(
          child: Text(
            title!,
            style: style,
          ),
        ),
        Text(
          value!,
          style: unite ? style : null,
        ),
      ]),
    );
  }

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      'Item Description',
      'Qty',
      'Rate',
      'GST',
      'Amount',
    ];
    final data = invoice.items?.map((item) {
      final total = item.unitPrice! * item.quantity! * (1 + item.gst!);
      return [
        item.description,
        item.quantity,
        '\$ ${item.unitPrice?.toStringAsFixed(2)}',
        '${item.gst! * 100} %',
        total.toStringAsFixed(2),
      ];
    }).toList();
    return Table.fromTextArray(
      headers: headers,
      data: data!,
      border: null,
      headerStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }

  static Widget buildSupplierHeader(Invoice invoice) {
    // final image = MemoryImage(
    //   File('assets/images/logo.png').readAsBytesSync(),
    // );
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.supplier!.name!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                invoice.supplier!.address!.replaceAll(', ', '\n'),
              ),
              Text(
                'GSTIN: ${invoice.supplier!.gstNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              Text(
                '${invoice.supplier!.paymentInfo}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ],
          ),
          Text(
            "INVOICE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 44,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCustomer(Invoice invoice) {
    int max = 1000000000;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.customer!.name!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              invoice.customer!.address!.replaceAll(', ', '\n'),
            ),
          ],
        ), // Customer Info
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Invoice Number: ${Random().nextInt(max)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            Text(
              'Issue Date: ${invoice.info!.billDate.toString().substring(0, 10)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            Text(
              'Due Date: ${invoice.info!.dueDate.toString().substring(0, 10)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ],
        ), // Date
      ],
    );
  }
}
