import 'package:flutter/material.dart';
import 'package:flutter_pdf/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SupplierKeys {
  static supplierDataAdded() => 'supplier_data_added';
  static supplierName() => 'supplier_name';
  static supplierAddress() => 'supplier_address';
  static supplierPaymentInfo() => 'supplier_payment_info';
  static supplierGSTNumber() => 'supplier_gst_number';
}

class SharedPrefsApi {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void setBoolValue({required String key, required bool value}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBoolValue({required String? key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key!);
  }

  void setStringValue({required String key, required String value}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String> getStringValue({required String? key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key!)!;
  }

  void setDoubleValue({required String key, required double value}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setDouble(key, value);
  }

  Future<double> getDoubleValue({required String? key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(key!)!;
  }
}

class SupplierInfo extends StatefulWidget {
  const SupplierInfo({Key? key}) : super(key: key);

  @override
  _SupplierInfoState createState() => _SupplierInfoState();
}

class _SupplierInfoState extends State<SupplierInfo> {
  final supplierNameController = TextEditingController();
  final addressController = TextEditingController();
  final paymentInfoController = TextEditingController();
  final gstNumberController = TextEditingController();
  final SharedPrefsApi sharedPrefsApi = SharedPrefsApi();
  final _formKey = GlobalKey<FormState>();

  Widget textFormField({
    required TextEditingController? controller,
    required String? labelText,
    String? Function(String?)? validator,
    int? maxLines = 1,
    int? maxLength,
    bool restrictSpecialChar = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        validator: validator,
        maxLength: maxLength,
        keyboardType: keyboardType,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        inputFormatters: restrictSpecialChar
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.deny(RegExp("[-, , , .]")),
              ]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 18,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                textFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a valid name';
                    }
                  },
                  controller: supplierNameController,
                  labelText: "Supplier Name",
                ),
                textFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a valid address';
                    }
                  },
                  controller: addressController,
                  labelText: "Address",
                  maxLines: 2,
                ),
                textFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a valid payment info (Eg. UPI: 123@example)';
                    }
                  },
                  controller: paymentInfoController,
                  labelText: "Payment Info (UPI)",
                ),
                textFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a valid GST number';
                    }

                    if (value.length < 11) {
                      return 'GST number should be of 11 digits';
                    }
                  },
                  controller: gstNumberController,
                  labelText: "GST Number",
                  maxLength: 11,
                  restrictSpecialChar: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sharedPrefsApi.setStringValue(
                        key: SupplierKeys.supplierName(),
                        value: supplierNameController.text,
                      );
                      sharedPrefsApi.setStringValue(
                        key: SupplierKeys.supplierAddress(),
                        value: addressController.text,
                      );
                      sharedPrefsApi.setStringValue(
                        key: SupplierKeys.supplierPaymentInfo(),
                        value: paymentInfoController.text,
                      );
                      sharedPrefsApi.setStringValue(
                        key: SupplierKeys.supplierGSTNumber(),
                        value: gstNumberController.text,
                      );
                      sharedPrefsApi.setBoolValue(
                          key: SupplierKeys.supplierDataAdded(), value: true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SplashScreen();
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: const Text(
                      'SAVE',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
