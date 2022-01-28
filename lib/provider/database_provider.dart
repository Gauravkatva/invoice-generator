import 'package:flutter/cupertino.dart';
import 'package:flutter_pdf/keys.dart';
import 'package:flutter_pdf/models/invoice_item.dart';

import 'package:hive/hive.dart';

class DatabaseProvider with ChangeNotifier {
  Box<InvoiceItem> invoiceItemBox = Hive.box<InvoiceItem>(invoiceItemsBoxKey);

  void addItem({String? title, required InvoiceItem item}) async {
    await invoiceItemBox.put(title, item);
    notifyListeners();
  }

  void removeItem({required String key}) {
    invoiceItemBox.delete(key);
    notifyListeners();
  }
}
