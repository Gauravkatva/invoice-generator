import 'package:flutter/material.dart';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:flutter_pdf/utils/pdf_invoice.dart';
import 'package:flutter_pdf/provider/bill_items_provider.dart';
import 'package:flutter_pdf/provider/supplier_info_provider.dart';
import 'package:flutter_pdf/screens/save_item.dart';
import 'package:flutter_pdf/screens/supplier_settings.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget textField({
    required TextEditingController? controller,
    required String? labelText,
    int? maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        maxLength: maxLength,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  TextEditingController customerNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final listViewController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final supplierInfoProvider = Provider.of<SupplierInfoProvider>(context);
    final billItemsProvider = Provider.of<BillItemsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_sharp),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SaveItem(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SupplierSettings(
                      initialSupplierInfo: supplierInfoProvider.supplierInfo,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Customer Info',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const Divider(
              color: Colors.white,
            ),
            textField(
              controller: customerNameController,
              labelText: 'Customer Name',
            ),
            textField(
              controller: addressController,
              labelText: 'Customer Address',
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Billing Info',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Add Item',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        billItemsProvider.clearItems();
                      },
                      child: const Text(
                        'Clear List',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: billItemsProvider.items.isNotEmpty
                  ? ListView.builder(
                      controller: listViewController,
                      itemCount: billItemsProvider.items.length,
                      itemBuilder: (context, index) {
                        InvoiceItem invoiceItem =
                            billItemsProvider.items[index];
                        return ItemCard(
                          invoiceItem: invoiceItem,
                          onRemove: () {
                            billItemsProvider.removeItem(index);
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No items added',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: billItemsProvider.items.isNotEmpty
            ? () async {
                final Invoice invoice = Invoice(
                  supplier: supplierInfoProvider.supplierInfo,
                  customer: Customer(
                    name: customerNameController.text.isEmpty
                        ? 'No Customer Name'
                        : customerNameController.text,
                    address: addressController.text.isEmpty
                        ? 'No Customer Address'
                        : addressController.text,
                  ),
                  info: InvoiceInfo(
                    billDate: DateTime.now(),
                    dueDate: DateTime.now(),
                    description:
                        'Bill is generated today and valid to pay for today only.',
                  ),
                  items: billItemsProvider.items,
                );
                final file = await PdfInvoiceApi.generate(invoice);
                await PdfApi.openFile(file);
              }
            : null,
        tooltip: 'Generate Invoice',
        label: const Text('Generate'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final InvoiceItem invoiceItem;
  final void Function()? onRemove;
  final void Function()? onEdit;
  const ItemCard(
      {Key? key, required this.invoiceItem, this.onRemove, this.onEdit})
      : super(key: key);

  @override
  Widget build(context) {
    final style = Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      child: Card(
        child: Container(
          margin: const EdgeInsets.only(
            left: 10,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${invoiceItem.title}',
                    style: style,
                  ),
                  Text(
                    'Price: ${invoiceItem.unitPrice}',
                    style: style,
                  ),
                  Text(
                    'GST: ${invoiceItem.gst! * 100} %',
                    style: style,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
