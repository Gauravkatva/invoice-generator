import 'package:flutter/cupertino.dart';
import 'package:flutter_pdf/models/invoice_item.dart';

class BillItemsProvider with ChangeNotifier {
  List<InvoiceItem> items = [];
  void addItem(InvoiceItem item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void clearItems() {
    items.clear();
    notifyListeners();
  }
}
