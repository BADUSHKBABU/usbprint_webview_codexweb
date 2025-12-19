// import 'dart:typed_data';
// import 'dart:developer';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf_render/pdf_render.dart';
// // import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' hide Text;
// // import 'package:pdf_render/pdf_render.dart';
// import 'package:untitled/printservice.dart';
// // import 'printer_service.dart'; // import your existing PrinterService
//
// /// Handles picking and printing a PDF file to a connected printer
// class PDFPrinterService {
//   /// Pick a PDF file using FilePicker and print it
//   static Future<void> pickAndPrintPDF(BuildContext context) async {
//     try {
//       // Step 1: Pick PDF file
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//       );
//
//       if (result == null || result.files.isEmpty) {
//         log('[PDFPrinterService] No file selected');
//         return;
//       }
//
//       final filePath = result.files.single.path!;
//       log('[PDFPrinterService] Picked file: $filePath');
//
//       // Step 2: Print the PDF
//       await printPDF(filePath);
//     } catch (e, st) {
//       log('[PDFPrinterService] Error picking/printing PDF: $e');
//       log(st.toString());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error printing PDF: $e')),
//       );
//     }
//   }
//
//   /// Print a given PDF file (page by page)
//   static Future<void> printPDF(String filePath) async {
//     if (!PrinterService.isPrinterConnected) {
//       log('[PDFPrinterService] Printer not connected');
//       return;
//     }
//
//     try {
//       // Load PDF document
//       final doc = await PdfDocument.openFile(filePath);
//       log('[PDFPrinterService] Loaded PDF with ${doc.pageCount} pages');
//
//       for (int i = 1; i <= doc.pageCount; i++) {
//         log('[PDFPrinterService] Rendering page $i / ${doc.pageCount}');
//         final page = await doc.getPage(i);
//         final pageImage = await page.render(
//           // width: page.width,
//           // height: page.height,
//           backgroundFill: true,
//         );
//
//         // Convert to Uint8List
//         final Uint8List imageBytes = pageImage!.bytes;
//         await page.close();
//
//         // Print page as image
//         await PrinterService.printImage(imageBytes);
//
//         // Optional: Small delay between pages
//         await Future.delayed(const Duration(seconds: 1));
//       }
//
//       await doc.close();
//       log('[PDFPrinterService] PDF printing completed.');
//     } catch (e, st) {
//       log('[PDFPrinterService] Error printing PDF: $e');
//       log(st.toString());
//     }
//   }
// }
