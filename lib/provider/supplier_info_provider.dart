import 'package:flutter/material.dart';
import 'package:flutter_pdf/pdf_invoice.dart';
import 'package:flutter_pdf/supplier_info.dart';

class SupplierInfoProvider with ChangeNotifier {
  Supplier supplierInfo = Supplier();
  final SharedPrefsApi _sharedPrefsApi = SharedPrefsApi();
  Future<void> getSupplierInfo() async {
    if (await _sharedPrefsApi.getBoolValue(
            key: SupplierKeys.supplierDataAdded()) ??
        false) {
      supplierInfo.address = await _sharedPrefsApi.getStringValue(
        key: SupplierKeys.supplierAddress(),
      );
      supplierInfo.gstNumber = await _sharedPrefsApi.getStringValue(
        key: SupplierKeys.supplierGSTNumber(),
      );
      supplierInfo.paymentInfo = await _sharedPrefsApi.getStringValue(
        key: SupplierKeys.supplierPaymentInfo(),
      );
      supplierInfo.name = await _sharedPrefsApi.getStringValue(
        key: SupplierKeys.supplierName(),
      );
    }
  }
}
