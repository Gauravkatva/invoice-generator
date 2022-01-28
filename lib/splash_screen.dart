import 'package:flutter/material.dart';
import 'package:flutter_pdf/home_page.dart';
import 'package:flutter_pdf/provider/supplier_info_provider.dart';
import 'package:flutter_pdf/supplier_info.dart';
import 'package:provider/provider.dart';

enum AppState { splash, supplierInfo, home }

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPrefsApi sharedPrefsApi = SharedPrefsApi();
  AppState _state = AppState.splash;
  @override
  void initState() {
    init();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await Provider.of<SupplierInfoProvider>(context, listen: false)
          .getSupplierInfo();
    });
    super.initState();
  }

  void init() async {
    // await Future.delayed(const Duration(seconds: 2));
    bool? supplierDataAdded = await sharedPrefsApi.getBoolValue(
        key: SupplierKeys.supplierDataAdded());
    supplierDataAdded = supplierDataAdded ?? false;
    if (supplierDataAdded) {
      setState(() {
        _state = AppState.home;
      });
    } else {
      setState(() {
        _state = AppState.supplierInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildForState(_state);
  }

  Widget buildForState(AppState state) {
    switch (state) {
      case AppState.home:
        return const MyHomePage(title: 'Invoice Generator');
      case AppState.supplierInfo:
        return const SupplierInfo();
      default:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'GENERATOR',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        );
    }
  }
}
