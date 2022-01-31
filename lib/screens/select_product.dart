import 'package:flutter/material.dart';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:flutter_pdf/provider/database_provider.dart';
import 'package:flutter_pdf/screens/add_item_to_bill.dart';
import 'package:flutter_pdf/screens/home_page.dart';
import 'package:provider/provider.dart';

class SelectProduct extends StatefulWidget {
  const SelectProduct({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SelectProduct();
}

class _SelectProduct extends State<SelectProduct> {
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product from Saved Template'),
      ),
      body: databaseProvider.invoiceItemBox.length > 0
          ? ListView.builder(
              itemCount: databaseProvider.invoiceItemBox.length,
              itemBuilder: (context, index) {
                final key =
                    databaseProvider.invoiceItemBox.keys.toList()[index];
                InvoiceItem? item = databaseProvider.invoiceItemBox.get(key);
                return ItemCard(
                  invoiceItem: item!,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddItemToBill(
                          invoiceItem: item,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text('No Items Saved'),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddItemToBill(),
            ),
          );
        },
        label: const Text('Enter Manual'),
      ),
    );
  }
}
