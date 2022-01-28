import 'package:hive/hive.dart';
part 'invoice_item.g.dart';

@HiveType(typeId: 0)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  final String? title;
  @HiveField(1)
  final double? gst;
  @HiveField(2)
  final double? unitPrice;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final int? quantity;

  InvoiceItem(
      {this.title,
      this.description,
      this.quantity,
      this.unitPrice,
      this.gst = 0.18});
}
