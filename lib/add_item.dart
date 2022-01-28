import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:flutter_pdf/provider/database_provider.dart';
import 'package:flutter_pdf/provider/supplier_info_provider.dart';
import 'package:provider/provider.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key, this.invoiceItem}) : super(key: key);
  final InvoiceItem? invoiceItem;
  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  Widget textFormField({
    String? Function(String?)? validator,
    required TextEditingController? controller,
    required String? labelText,
    int? maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool restrictSpecialChar = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        controller: controller,
        maxLines: maxLines,
        inputFormatters: restrictSpecialChar
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.deny(RegExp("[-, , ,]")),
              ]
            : null,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController gstController = TextEditingController();

  bool occurance({
    required String value,
    required String pattern,
    int maxOccurance = 1,
  }) {
    bool result = false;
    int occuranceNumber = 0;

    for (int i = 0; i < value.length; i++) {
      if (pattern == value[i]) {
        occuranceNumber++;
      }
      if (occuranceNumber > maxOccurance) {
        result = true;
        break;
      }
    }
    return result;
  }

  @override
  void initState() {
    if (widget.invoiceItem != null) {
      titleController.text = widget.invoiceItem!.title!;
      gstController.text = widget.invoiceItem!.gst.toString();
      unitPriceController.text = widget.invoiceItem!.unitPrice.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textFormField(
                labelText: 'Title *',
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some product title';
                  }
                  return null;
                },
              ),
              textFormField(
                labelText: 'GST Value (eg. Enter only 5 for 5%)*',
                controller: gstController,
                keyboardType: const TextInputType.numberWithOptions(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'eg. Enter only 5 for 5%';
                  }
                  if (occurance(value: value, pattern: '.', maxOccurance: 1)) {
                    return 'Qauntity can not contain dot (.)';
                  }
                  return null;
                },
                restrictSpecialChar: true,
              ),
              textFormField(
                labelText: 'Price *',
                controller: unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some price';
                  }
                  if (occurance(value: value, pattern: '.', maxOccurance: 1)) {
                    return 'Price can not contain more than 1 dot (.)';
                  }
                  if (value[value.length - 1] == '.') {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                restrictSpecialChar: true,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    InvoiceItem item = InvoiceItem(
                      title: titleController.text,
                      unitPrice: double.parse(unitPriceController.text),
                      gst: double.parse(gstController.text) / 100,
                    );
                    databaseProvider.addItem(item: item, title: item.title);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.invoiceItem == null ? 'Add Item' : "Update Item",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
