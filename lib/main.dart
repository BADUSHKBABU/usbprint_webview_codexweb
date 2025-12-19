import 'package:flutter/material.dart';
import 'package:untitled/html_to_pdf_converter.dart';
import 'package:untitled/printservice.dart';
import 'package:untitled/sampleprintOnhtml.dart';
import 'package:untitled/webviewpage.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PrinterService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewPrintPage(),
      // home: HtmlPrinterPage(),
      // home: html_to_pdf(),
    );
  }
}
