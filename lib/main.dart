import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_pdf/utils/keys.dart';
import 'package:flutter_pdf/models/invoice_item.dart';
import 'package:flutter_pdf/provider/bill_items_provider.dart';
import 'package:flutter_pdf/provider/database_provider.dart';
import 'package:flutter_pdf/provider/supplier_info_provider.dart';
import 'package:flutter_pdf/screens/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive
    ..init(document.path)
    ..registerAdapter(InvoiceItemAdapter());
  await Hive.openBox<InvoiceItem>(invoiceItemsBoxKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BillItemsProvider>(
          create: (context) {
            return BillItemsProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return SupplierInfoProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return DatabaseProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
