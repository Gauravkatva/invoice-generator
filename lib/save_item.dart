import 'package:flutter/material.dart';
import 'package:flutter_pdf/add_item.dart';
import 'package:flutter_pdf/home_page.dart';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:flutter_pdf/provider/database_provider.dart';
import 'package:provider/provider.dart';

class SaveItem extends StatefulWidget {
  const SaveItem({Key? key}) : super(key: key);

  @override
  _SaveItemState createState() => _SaveItemState();
}

class _SaveItemState extends State<SaveItem> {
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Products'),
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
                  onRemove: () {
                    databaseProvider.removeItem(key: key);
                  },
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AddItem(
                            invoiceItem: item,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text('No Items Saved'),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddItem(),
            ),
          );
        },
        tooltip: 'Save new product',
      ),
    );
  }
}
