//
//
//
// // import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'dart:typed_data';
//
//
// import 'package:flutter/material.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:untitled/printservice.dart';
// import 'package:webcontent_converter/webcontent_converter.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:image/image.dart' as img;
//
//
// class HtmlPrinterPage extends StatefulWidget {
//   const HtmlPrinterPage({Key? key}) : super(key: key);
//
//   @override
//   State<HtmlPrinterPage> createState() => _HtmlPrinterPageState();
// }
//
// class _HtmlPrinterPageState extends State<HtmlPrinterPage> {
//   final ScreenshotController screenshotController = ScreenshotController();
//   String printerStatus = 'Not connected';
//   bool isPrinting = false;
//   bool isConvertingPdf = false;
//   late final WebViewController webViewController;
//
//   // Hardcoded HTML content
//   final String htmlContent = '''
// <!DOCTYPE html>
// <html lang="en">.+
// <head>
//     <meta charset="UTF-8" />
//     <meta name="viewport" content="width=device-width, initial-scale=1.0" />
//     <title>Sample HTML Page</title>
//     <style>
//         body {
//           font-family: Arial, sans-serif;
//           margin: 40px;
//           background-color: #f9f9f9;
//           color: #333;
//         }
//         header {
//           background-color: #007bff;
//           color: white;
//           padding: 15px;
//           border-radius: 8px;
//           text-align: center;
//         }
//         section {
//           margin-top: 20px;
//         }
//         button {
//           background-color: #007bff;
//           color: white;
//           border: none;
//           padding: 10px 15px;
//           border-radius: 5px;
//           cursor: pointer;
//         }
//         button:hover {
//           background-color: #0056b3;
//         }
//         .name{
//             font-size:20px;
//             }
//     </style>
// </head>
// <body>
// <header>
//     <h1>Welcome to My Sample Page</h1>
// </header>
//
// <section>
//     <h1>About</h1>
//     <p>This is a simple HTML example with basic styling and structure.</p>
// </section>
//
// <section>
//     <h2>Contact</h2>
//     <form>
//         <label for="name">Name:</label><br />
//         <input type="text" id="name"  name="name" /><br /><br />
//
//         <label for="email">Email:</label><br />
//         <input type="email" id="email" name="email" /><br /><br />
//
//         <button type="submit">Submit</button>
//     </form>
// </section>
//
// <footer style="margin-top: 30px; text-align:center;">
//     <p>&copy; 2025 My Website</p>
// </footer>
// </body>
// </html>
//   ''';
//
//   @override
//   void initState() {
//     super.initState();
//     _initPrinter();
//     _listenToPrinterStatus();
//     _initWebView();
//   }
//
//   void _initWebView() {
//     webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadHtmlString(htmlContent);
//   }
//
//   void _initPrinter() {
//     PrinterService.init();
//     setState(() {
//       printerStatus = PrinterService.printerStatus;
//     });
//   }
//
//   void _listenToPrinterStatus() {
//     PrinterService.currentUsbStringStatusStream.listen((status) {
//       if (mounted) {
//         setState(() {
//           printerStatus = status;
//         });
//       }
//     });
//   }
//
//   Future<void> _scanForPrinter() async {
//     _showSnackBar('Scanning for printer...');
//     await PrinterService.scan();
//     setState(() {
//       printerStatus = PrinterService.printerStatus;
//     });
//
//     if (PrinterService.printerStatus == PrinterStatus.notConnected) {
//       _showSnackBar('Printer found: ${PrinterService.printerName}');
//     } else if (PrinterService.printerStatus == PrinterStatus.notFound) {
//       _showSnackBar('No printer found', isError: true);
//     }
//   }
//
//   Future<void> _connectPrinter() async {
//     if (PrinterService.printerStatus == PrinterStatus.notConnected) {
//       _showSnackBar('Connecting to printer...');
//       await PrinterService.connect();
//       setState(() {
//         printerStatus = PrinterService.printerStatus;
//       });
//
//       if (PrinterService.isPrinterConnected) {
//         _showSnackBar('Printer connected successfully');
//       } else {
//         _showSnackBar('Failed to connect to printer', isError: true);
//       }
//     }
//   }
//
//   Future<void> _disconnectPrinter() async {
//     if (PrinterService.isPrinterConnected) {
//       await PrinterService.disConnect();
//       setState(() {
//         printerStatus = PrinterService.printerStatus;
//       });
//       _showSnackBar('Printer disconnected');
//     }
//   }
//
//   Future<void> _printHtml() async {
//     if (!PrinterService.isPrinterConnected) {
//       _showSnackBar('Please connect to a printer first', isError: true);
//       return;
//     }
//
//     setState(() {
//       isPrinting = true;
//     });
//
//     _showSnackBar('Printing...');
//
//     bool success = await PrinterService.printHtmlContent(
//         htmlContent: htmlContent);
//
//     setState(() {
//       isPrinting = false;
//     });
//
//     if (success) {
//       _showSnackBar('Print completed successfully');
//     } else {
//       _showSnackBar('Print failed', isError: true);
//     }
//   }
//
//   Future<void> _printAsText() async {
//     if (!PrinterService.isPrinterConnected) {
//       _showSnackBar('Please connect to a printer first', isError: true);
//       return;
//     }
//
//     setState(() {
//       isPrinting = true;
//     });
//
//     _showSnackBar('Printing as text...');
//
//     bool success = await PrinterService.printHtmlAsText(
//         htmlContent: htmlContent);
//
//     setState(() {
//       isPrinting = false;
//     });
//
//     if (success) {
//       _showSnackBar('Print completed successfully');
//     } else {
//       _showSnackBar('Print failed', isError: true);
//     }
//   }
//
//   Future<void> _testPrint() async {
//     if (!PrinterService.isPrinterConnected) {
//       _showSnackBar('Please connect to a printer first', isError: true);
//       return;
//     }
//
//     setState(() {
//       isPrinting = true;
//     });
//
//     await PrinterService.testPrint();
//
//     setState(() {
//       isPrinting = false;
//     });
//   }
//
//   // Convert HTML to PDF
//   Future<Uint8List> _generatePdfFromHtml() async {
//     try {
//       // Convert HTML to PDF bytes (with proper formatting)
//       final pdfBytes = await Printing.convertHtml(
//         format: PdfPageFormat.a4,
//         html: htmlContent,
//       );
//       return pdfBytes;
//     } catch (e) {
//       // log('Error generating formatted PDF: $e');
//       rethrow;
//     }
//   }
//
//   // Future<pw.Document> _generatePdfFromHtml() async {
//   //   final pdf = pw.Document();
//   //
//   //   // Simple text extraction from HTML for PDF
//   //   // Remove HTML tags for basic text content
//   //   String textContent = htmlContent
//   //       .replaceAll(RegExp(r'<[^>]*>'), ' ')
//   //       .replaceAll(RegExp(r'\s+'), ' ')
//   //       .trim();
//   //
//   //   pdf.addPage(
//   //     pw.Page(
//   //       pageFormat: PdfPageFormat.a4,
//   //       build: (context) => pw.Column(
//   //         crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //         children: [
//   //           pw.Header(
//   //             level: 0,
//   //             child: pw.Text(
//   //               'HTML Content',
//   //               style: pw.TextStyle(
//   //                 fontSize: 24,
//   //                 fontWeight: pw.FontWeight.bold,
//   //               ),
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 20),
//   //           pw.Text(
//   //             textContent,
//   //             style: const pw.TextStyle(fontSize: 12),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   //
//   //   return pdf;
//   // }
//   //
//
//
//   // View PDF Preview
//   Future<void> _viewAsPdf() async {
//     setState(() => isConvertingPdf = true);
//     try {
//       final pdfBytes = await _generatePdfFromHtml();
//       setState(() => isConvertingPdf = false);
//
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               Scaffold(
//                 appBar: AppBar(title: const Text('PDF Preview')),
//                 body: PdfPreview(
//                   build: (format) => pdfBytes,
//                   allowSharing: true,
//                   allowPrinting: true,
//                 ),
//               ),
//         ),
//       );
//     } catch (e) {
//       setState(() => isConvertingPdf = false);
//       _showSnackBar('Error generating PDF: $e', isError: true);
//     }
//   }
//
//   // Future<void> _viewAsPdf() async {
//   //   setState(() {
//   //     isConvertingPdf = true;
//   //   });
//   //
//   //   try {
//   //     final pdf = await _generatePdfFromHtml();
//   //
//   //     setState(() {
//   //       isConvertingPdf = false;
//   //     });
//   //
//   //     // Show PDF preview in a new screen
//   //     await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => Scaffold(
//   //           appBar: AppBar(
//   //             title: const Text('PDF Preview'),
//   //             backgroundColor: Colors.blue,
//   //           ),
//   //           body: PdfPreview(
//   //             build: (format) => pdf.save(),
//   //             allowSharing: true,
//   //             allowPrinting: true,
//   //             canChangePageFormat: false,
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     setState(() {
//   //       isConvertingPdf = false;
//   //     });
//   //     _showSnackBar('Error generating PDF: $e', isError: true);
//   //     log('PDF generation error: $e');
//   //   }
//   // }
//   //
//   //
//   // Print as PDF (convert HTML to PDF then print via thermal printer)
//   //
//   // Future<void> _printAsPdf() async {
//   //   if (!PrinterService.isPrinterConnected) {
//   //     _showSnackBar('Please connect to a printer first', isError: true);
//   //     return;
//   //   }
//   //
//   //   setState(() {
//   //     isPrinting = true;
//   //     isConvertingPdf = true;
//   //   });
//   //
//   //   try {
//   //     _showSnackBar('Converting HTML to PDF...');
//   //
//   //     final pdf = await _generatePdfFromHtml();
//   //     final pdfBytes = await pdf.save();
//   //
//   //     setState(() {
//   //       isConvertingPdf = false;
//   //     });
//   //
//   //     _showSnackBar('Printing PDF...');
//   //
//   //     // Here you would need to add a method in PrinterService to handle PDF bytes
//   //     // For now, we'll use the existing HTML print method
//   //     // If your PrinterService has a printPdf method, use:
//   //     // bool success = await PrinterService.printPdf(pdfBytes: pdfBytes);
//   //
//   //     bool success = await PrinterService.printHtmlContent(htmlContent: htmlContent);
//   //
//   //     setState(() {
//   //       isPrinting = false;
//   //     });
//   //
//   //     if (success) {
//   //       _showSnackBar('PDF printed successfully');
//   //     } else {
//   //       _showSnackBar('Print failed', isError: true);
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       isPrinting = false;
//   //       isConvertingPdf = false;
//   //     });
//   //     _showSnackBar('Error: $e', isError: true);
//   //     log('Print as PDF error: $e');
//   //   }
//   // }
//   //
//   //
//
//
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   Color _getStatusColor() {
//     switch (printerStatus) {
//       case PrinterStatus.connected:
//         return Colors.green;
//       case PrinterStatus.connecting:
//       case PrinterStatus.scanning:
//       case PrinterStatus.printing:
//         return Colors.orange;
//       case PrinterStatus.notConnected:
//         return Colors.blue;
//       default:
//         return Colors.red;
//     }
//   }
//
//
//
//   // Future<Uint8List> htmlToPdfBytes(String htmlContent) async {
//   //   final pdf = await Printing.convertHtml(
//   //     format: PdfPageFormat.a4, // or custom page size
//   //     html: htmlContent,
//   //   );
//   //   return pdf;
//   // }
//
//
//
//     Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
//       try {
//         final Uint8List? imageBytes = await WebcontentConverter.
//         contentToImage(
//           content:htmlContent,
//           duration: 500,
//
//           scale: 20,
//         );
//         return imageBytes;
//       } catch (e) {
//         print('Error converting HTML to Uint8List: $e');
//         return null;
//       }
//     }
//
//     Future<void> _printAsPdf() async {
//       try {
//         // Capture the current WebView as image
//         final Uint8List? bytes =await convertHtmlToUint8List(htmlContent);
//         final asd=await resizeForThermal(bytes!);
//         // await screenshotController.capture();
//
//
//         if (asd == null) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text("Failed to capture HTML")));
//           return;
//         }
//
//         // Send captured image to printer
//         await PrinterService.printImage(asd);
//
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Printing started...")));
//       } catch (e) {
//         print("Error printing: $e");
//       }
//
//     // if (!PrinterService.isPrinterConnected) {
//     //   _showSnackBar('Please connect to a printer first', isError: true);
//     //   return;
//     // }
//     //
//     // setState(() {
//     //   isPrinting = true;
//     //   isConvertingPdf = true;
//     // });
//     //
//     // try {
//     //   _showSnackBar('Converting HTML to PDF...');
//     //   final pdfBytes = await _generatePdfFromHtml();
//     //
//     //   setState(() => isConvertingPdf = false);
//     //   _showSnackBar('Printing PDF...');
//     //
//     //   // If your printer supports raw PDF printing:
//     //   // bool success = await PrinterService.printPdf(pdfBytes: pdfBytes);
//     //
//     //   // If not, fallback to image or text printing
//     //   bool success = await PrinterService.printHtmlContent(htmlContent: htmlContent);
//     //
//     //   setState(() => isPrinting = false);
//     //
//     //   if (success) {
//     //     _showSnackBar('PDF printed successfully');
//     //   } else {
//     //     _showSnackBar('Print failed', isError: true);
//     //   }
//     // } catch (e) {
//     //   setState(() {
//     //     isPrinting = false;
//     //     isConvertingPdf = false;
//     //   });
//     //   _showSnackBar('Error: $e', isError: true);
//     // }
//
//
//   }
//
//
//
//   Future<Uint8List> _resizeForPrint(Uint8List originalBytes) async {
//     final decoded = img.decodeImage(originalBytes)!;
//
//     // A4 at 300 DPI ≈ 2480x3508 pixels
//     final resized = img.copyResize(
//       decoded,
//       width: 2480,
//       height: (decoded.height * (2480 / decoded.width)).round(),
//       interpolation: img.Interpolation.cubic,
//     );
//
//     return Uint8List.fromList(img.encodeJpg(resized, quality: 100));
//   }
//   /// Resize HTML image to fit 80mm thermal printer width (576px)
//   Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
//     // Decode image
//     final image = img.decodeImage(htmlBytes);
//     if (image == null) {
//       throw Exception("Failed to decode HTML image");
//     }
//
//     // Resize to 576px width (common for 80mm printers)
//     final resized = img.copyResize(
//       image,
//       width: 576,
//       interpolation: img.Interpolation.cubic,
//     );
//
//     // Encode to PNG or BMP depending on printer support
//     return Uint8List.fromList(img.encodePng(resized));
//   }
//
//
//   @override
//   void dispose() {
//     PrinterService.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('HTML Printer'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           // Printer Status Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: _getStatusColor().withOpacity(0.1),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       PrinterService.isPrinterConnected
//                           ? Icons.print
//                           : Icons.print_disabled,
//                       color: _getStatusColor(),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Printer: $printerStatus',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: _getStatusColor(),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (PrinterService.printerName.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       'Device: ${PrinterService.printerName}',
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           // Control Buttons
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               alignment: WrapAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: printerStatus == PrinterStatus.scanning
//                       ? null
//                       : _scanForPrinter,
//                   icon: const Icon(Icons.search, size: 18),
//                   label: const Text('Scan'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: printerStatus == PrinterStatus.notConnected
//                       ? _connectPrinter
//                       : null,
//                   icon: const Icon(Icons.link, size: 18),
//                   label: const Text('Connect'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: PrinterService.isPrinterConnected
//                       ? _disconnectPrinter
//                       : null,
//                   icon: const Icon(Icons.link_off, size: 18),
//                   label: const Text('Disconnect'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: PrinterService.isPrinterConnected && !isPrinting
//                       ? _testPrint
//                       : null,
//                   icon: const Icon(Icons.receipt, size: 18),
//                   label: const Text('Test'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const Divider(height: 1),
//
//           // HTML Preview with WebView
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'HTML Preview:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: isConvertingPdf ? null : _viewAsPdf,
//                           icon: isConvertingPdf
//                               ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                               : const Icon(Icons.picture_as_pdf, size: 18),
//                           label: Text(isConvertingPdf ? 'Converting...' : 'View as PDF'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Screenshot(controller: screenshotController,
//                       child: WebViewWidget(controller: webViewController)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Print Buttons
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: PrinterService.isPrinterConnected && !isPrinting
//                             ? _printHtml
//                             : null,
//                         icon: isPrinting
//                             ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                             : const Icon(Icons.print),
//                         label: Text(isPrinting ? 'Printing...' : 'Print HTML'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: PrinterService.isPrinterConnected && !isPrinting
//                             ? _printAsText
//                             : null,
//                         icon: const Icon(Icons.text_fields),
//                         label: const Text('Print as Text'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: PrinterService.isPrinterConnected && !isPrinting && !isConvertingPdf
//                         ? _printAsPdf
//                         : null,
//                     icon: (isPrinting || isConvertingPdf)
//                         ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                         : const Icon(Icons.picture_as_pdf),
//                     label: Text(
//                       isConvertingPdf
//                           ? 'Converting to PDF...'
//                           : isPrinting
//                           ? 'Printing PDF...'
//                           : 'Print as PDF',
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:untitled/printservice.dart';
import 'package:webcontent_converter/webcontent_converter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as img;

class HtmlPrinterPage extends StatefulWidget {
  const HtmlPrinterPage({Key? key}) : super(key: key);

  @override
  State<HtmlPrinterPage> createState() => _HtmlPrinterPageState();
}

class _HtmlPrinterPageState extends State<HtmlPrinterPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  String printerStatus = 'Not connected';
  bool isPrinting = false;
  bool isConvertingPdf = false;
  late final WebViewController webViewController;

  // Hardcoded HTML content - optimized for thermal printing
  final String htmlContent = '''
  
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=576, initial-scale=1.0" />
    <title>Sample HTML Page</title>
    <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          padding: 0;
          background-color: #ffffff;
          color: #000000;
          width: 536px;
          font-size: 18px;
        }
        header {
          background-color: #007bff;
          color: white;
          padding: 15px;
          border-radius: 8px;
          text-align: center;
          margin-bottom: 15px;
        }
        h1 {
          font-size: 28px;
          margin: 10px 0;
        }
        h2 {
          font-size: 24px;
          margin: 10px 0;
        }
        section {
          margin-top: 15px;
          margin-bottom: 15px;
        }
        p {
          font-size: 18px;
          line-height: 1.5;
          margin: 8px 0;
        }
        label {
          font-size: 18px;
          font-weight: bold;
        }
        input {
          font-size: 16px;
          padding: 8px;
          width: 100%;
          margin: 5px 0;
          box-sizing: border-box;
        }
        button {
          background-color: #007bff;
          color: white;
          border: none;
          padding: 12px 20px;
          border-radius: 5px;
          cursor: pointer;
          font-size: 18px;
          margin-top: 10px;
        }
        footer {
          margin-top: 20px;
          text-align: center;
          font-size: 16px;
        }
    </style>
</head>
<body>
<header>
    <h1>Welcome to My Sample Page</h1>
</header>

<section>
    <h2>About</h2>
    <p>This is a simple HTML example with basic styling and structure optimized for thermal printing.</p>
</section>

<section>
    <h2>Contact</h2>
    <form>
        <label for="name">Name:</label><br />
        <input type="text" id="name" name="name" value="John Doe" /><br />
        
        <label for="email">Email:</label><br />
        <input type="email" id="email" name="email" value="john@example.com" /><br />
        
        <button type="button">Submit</button>
    </form>
</section>

<footer>
    <p>&copy; 2025 My Website</p>
</footer>
</body>
</html>
  ''';


  @override
  void initState() {
    super.initState();
    _initPrinter();
    _listenToPrinterStatus();
    _initWebView();
  }

  void _initWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
  }

  void _initPrinter() {
    PrinterService.init();
    setState(() {
      printerStatus = PrinterService.printerStatus;
    });
  }

  void _listenToPrinterStatus() {
    PrinterService.currentUsbStringStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          printerStatus = status;
        });
      }
    });
  }

  Future<void> _scanForPrinter() async {
    _showSnackBar('Scanning for printer...');
    await PrinterService.scan();
    setState(() {
      printerStatus = PrinterService.printerStatus;
    });

    if (PrinterService.printerStatus == PrinterStatus.notConnected) {
      _showSnackBar('Printer found: ${PrinterService.printerName}');
    } else if (PrinterService.printerStatus == PrinterStatus.notFound) {
      _showSnackBar('No printer found', isError: true);
    }
  }

  Future<void> _connectPrinter() async {
    if (PrinterService.printerStatus == PrinterStatus.notConnected) {
      _showSnackBar('Connecting to printer...');
      await PrinterService.connect();
      setState(() {
        printerStatus = PrinterService.printerStatus;
      });

      if (PrinterService.isPrinterConnected) {
        _showSnackBar('Printer connected successfully');
      } else {
        _showSnackBar('Failed to connect to printer', isError: true);
      }
    }
  }

  Future<void> _disconnectPrinter() async {
    if (PrinterService.isPrinterConnected) {
      await PrinterService.disConnect();
      setState(() {
        printerStatus = PrinterService.printerStatus;
      });
      _showSnackBar('Printer disconnected');
    }
  }

  Future<void> _printHtml() async {
    if (!PrinterService.isPrinterConnected) {
      _showSnackBar('Please connect to a printer first', isError: true);
      return;
    }

    setState(() {
      isPrinting = true;
    });

    _showSnackBar('Printing...');

    bool success = await PrinterService.printHtmlContent(
        htmlContent: htmlContent);

    setState(() {
      isPrinting = false;
    });

    if (success) {
      _showSnackBar('Print completed successfully');
    } else {
      _showSnackBar('Print failed', isError: true);
    }
  }

  Future<void> _printAsText() async {
    if (!PrinterService.isPrinterConnected) {
      _showSnackBar('Please connect to a printer first', isError: true);
      return;
    }

    setState(() {
      isPrinting = true;
    });

    _showSnackBar('Printing as text...');

    bool success = await PrinterService.printHtmlAsText(
        htmlContent: htmlContent);

    setState(() {
      isPrinting = false;
    });

    if (success) {
      _showSnackBar('Print completed successfully');
    } else {
      _showSnackBar('Print failed', isError: true);
    }
  }

  Future<void> _testPrint() async {
    if (!PrinterService.isPrinterConnected) {
      _showSnackBar('Please connect to a printer first', isError: true);
      return;
    }

    setState(() {
      isPrinting = true;
    });

    await PrinterService.testPrint();

    setState(() {
      isPrinting = false;
    });
  }

  // Convert HTML to PDF
  Future<Uint8List> _generatePdfFromHtml() async {
    try {
      final pdfBytes = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: htmlContent,
      );
      return pdfBytes;
    } catch (e) {
      rethrow;
    }
  }

  // View PDF Preview
  Future<void> _viewAsPdf() async {
    setState(() => isConvertingPdf = true);
    try {
      final pdfBytes = await _generatePdfFromHtml();
      setState(() => isConvertingPdf = false);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('PDF Preview')),
            body: PdfPreview(
              build: (format) => pdfBytes,
              allowSharing: true,
              allowPrinting: true,
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => isConvertingPdf = false);
      _showSnackBar('Error generating PDF: $e', isError: true);
    }
  }

  /// Convert HTML to image with proper sizing for thermal printer
  Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
    try {
      // CRITICAL: Increase scale factor to render larger image
      // Then we'll resize to 576px width
      final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
        content: htmlContent,
        duration: 1000, // Give more time for rendering
        scale: 2, // Increased scale for better quality
      );
      return imageBytes;
    } catch (e) {
      print('Error converting HTML to Uint8List: $e');
      return null;
    }
  }


  /// Resize image to 576px width for 80mm thermal printer
  Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
    final image = img.decodeImage(htmlBytes);
    if (image == null) {
      throw Exception("Failed to decode HTML image");
    }

    // Target width for 80mm thermal printer (203 DPI)
    const int targetWidth = 576;

    // Only resize if image is not already at target width
    if (image.width != targetWidth) {
      final resized = img.copyResize(
        image,
        width: targetWidth,
        interpolation: img.Interpolation.cubic,
      );
      return Uint8List.fromList(img.encodePng(resized));
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// Print HTML as image to thermal printer
  Future<void> _printAsPdf() async {
    if (!PrinterService.isPrinterConnected) {
      _showSnackBar('Please connect to a printer first', isError: true);
      return;
    }

    setState(() {
      isPrinting = true;
      isConvertingPdf = true;
    });

    try {
      _showSnackBar('Converting HTML to image...');

      // Convert HTML to image
      final Uint8List? bytes = await convertHtmlToUint8List(htmlContent);

      if (bytes == null) {
        throw Exception('Failed to convert HTML to image');
      }

      _showSnackBar('Resizing for thermal printer...');

      // Resize for thermal printer
      final resizedBytes = await resizeForThermal(bytes);

      setState(() => isConvertingPdf = false);

      _showSnackBar('Sending to printer...');

      // Print the image
      await PrinterService.printImage(resizedBytes);

      setState(() => isPrinting = false);
      _showSnackBar('Print completed successfully');
    } catch (e) {
      setState(() {
        isPrinting = false;
        isConvertingPdf = false;
      });
      _showSnackBar('Error: $e', isError: true);
      print('Print error: $e');
    }
  }


  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getStatusColor() {
    switch (printerStatus) {
      case PrinterStatus.connected:
        return Colors.green;
      case PrinterStatus.connecting:
      case PrinterStatus.scanning:
      case PrinterStatus.printing:
        return Colors.orange;
      case PrinterStatus.notConnected:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    PrinterService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Printer'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Printer Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getStatusColor().withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PrinterService.isPrinterConnected
                          ? Icons.print
                          : Icons.print_disabled,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Printer: $printerStatus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
                if (PrinterService.printerName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Device: ${PrinterService.printerName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: printerStatus == PrinterStatus.scanning
                      ? null
                      : _scanForPrinter,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: printerStatus == PrinterStatus.notConnected
                      ? _connectPrinter
                      : null,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: PrinterService.isPrinterConnected
                      ? _disconnectPrinter
                      : null,
                  icon: const Icon(Icons.link_off, size: 18),
                  label: const Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: PrinterService.isPrinterConnected && !isPrinting
                      ? _testPrint
                      : null,
                  icon: const Icon(Icons.receipt, size: 18),
                  label: const Text('Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // HTML Preview with WebView
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HTML Preview:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isConvertingPdf ? null : _viewAsPdf,
                          icon: isConvertingPdf
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.picture_as_pdf, size: 18),
                          label: Text(
                              isConvertingPdf ? 'Converting...' : 'View as PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Screenshot(
                        controller: screenshotController,
                        child: WebViewWidget(controller: webViewController),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Print Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                        PrinterService.isPrinterConnected && !isPrinting
                            ? _printHtml
                            : null,
                        icon: isPrinting
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.print),
                        label: Text(isPrinting ? 'Printing...' : 'Print HTML'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                        PrinterService.isPrinterConnected && !isPrinting
                            ? _printAsText
                            : null,
                        icon: const Icon(Icons.text_fields),
                        label: const Text('Print as Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: PrinterService.isPrinterConnected &&
                        !isPrinting &&
                        !isConvertingPdf
                        ? _printAsPdf
                        : null,
                    icon: (isPrinting || isConvertingPdf)
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.image),
                    label: Text(
                      isConvertingPdf
                          ? 'Converting...'
                          : isPrinting
                          ? 'Printing...'
                          : 'Print as Image',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}