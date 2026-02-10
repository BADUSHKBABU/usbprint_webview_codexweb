// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:untitled/printservice.dart';
// import 'package:webcontent_converter/webcontent_converter.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:image/image.dart' as img;
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
//   // Track which HTML is currently displayed
//   bool showingHtmlContent1 = true;
//
//   // HTML Content 1 - Click-based dropdown
//   final String htmlContent = '''
//
// <!DOCTYPE html>
// <html>
// <head>
// <meta name="viewport" content="width=device-width, initial-scale=1">
// <style>
// body {
//   font-family: Arial, sans-serif;
//   padding: 20px;
//   margin: 0;
// }
//
// /* Button */
// .dropdown-btn {
//   background-color: #007bff;
//   color: white;
//   padding: 10px 16px;
//   border: none;
//   cursor: pointer;
//   border-radius: 4px;
//   font-size: 14px;
//   font-weight: 500;
// }
//
// .dropdown-btn:hover {
//   background-color: #0056b3;
// }
//
// /* Dropdown container */
// .dropdown {
//   position: relative;
//   display: inline-block;
// }
//
// /* Dropdown content */
// .dropdown-menu {
//   display: none;
//   position: absolute;
//   background-color: white;
//   min-width: 160px;
//   box-shadow: 0 6px 12px rgba(0,0,0,0.15);
//   border-radius: 4px;
//   z-index: 1000;
//   margin-top: 5px;
//   border: 1px solid #ddd;
// }
//
// /* Dropdown items */
// .dropdown-menu a {
//   color: #333;
//   padding: 10px 16px;
//   text-decoration: none;
//   display: block;
//   font-size: 14px;
// }
//
// .dropdown-menu a:first-child {
//   border-radius: 4px 4px 0 0;
// }
//
// .dropdown-menu a:last-child {
//   border-radius: 0 0 4px 4px;
// }
//
// .dropdown-menu a:hover {
//   background-color: #f1f1f1;
// }
//
// .label {
//   margin-top: 20px;
//   font-size: 12px;
//   color: #666;
// }
// </style>
// </head>
//
// <body>
//
// <h3>Click-based Dropdown</h3>
//
// <div class="dropdown">
//   <button class="dropdown-btn" id="menuBtn">
//     Menu ▼
//   </button>
//
//   <div class="dropdown-menu" id="dropdownMenu">
//     <a href="#" onclick="alert('Item 1 clicked'); return false;">Item 1</a>
//     <a href="#" onclick="alert('Item 2 clicked'); return false;">Item 2</a>
//     <a href="#" onclick="alert('Item 3 clicked'); return false;">Item 3</a>
//   </div>
// </div>
//
// <p class="label">Click the button to toggle dropdown</p>
//
// <script>
// document.addEventListener('DOMContentLoaded', function() {
//   const btn = document.getElementById('menuBtn');
//   const menu = document.getElementById('dropdownMenu');
//
//   if (btn && menu) {
//     btn.addEventListener('click', function(e) {
//       e.stopPropagation();
//       menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
//     });
//
//     // Close dropdown when clicking outside
//     document.addEventListener('click', function(event) {
//       if (!event.target.matches('.dropdown-btn')) {
//         if (menu.style.display === 'block') {
//           menu.style.display = 'none';
//         }
//       }
//     });
//   }
// });
// </script>
//
// </body>
// </html>
//   ''';
//
//   // HTML Content 2 - Hover-based dropdown (no JavaScript)
//   final String htmlContent2 = '''
// <!DOCTYPE html>
// <html>
// <head>
// <meta name="viewport" content="width=device-width, initial-scale=1">
// <style>
// body {
//   font-family: Arial, sans-serif;
//   padding: 20px;
//   margin: 0;
// }
//
// /* Navigation bar */
// .nav {
//   list-style-type: none;
//   margin: 0;
//   padding: 0;
//   background-color: #333;
//   border-radius: 4px;
//   overflow: hidden;
// }
//
// .nav-item {
//   float: left;
//   position: relative;
// }
//
// .nav-link {
//   display: block;
//   color: white;
//   text-align: center;
//   padding: 14px 20px;
//   text-decoration: none;
//   font-size: 14px;
//   cursor: pointer;
// }
//
// .nav-link:hover {
//   background-color: #555;
// }
//
// /* Dropdown container */
// .dropdown-menu {
//   display: none;
//   position: absolute;
//   background-color: white;
//   min-width: 200px;
//   box-shadow: 0 8px 16px rgba(0,0,0,0.2);
//   z-index: 1000;
//   border-radius: 0 0 4px 4px;
//   border: 1px solid #ddd;
//   border-top: none;
// }
//
// /* Show dropdown on hover */
// .nav-item:hover .dropdown-menu {
//   display: block;
// }
//
// /* Dropdown links */
// .dropdown-item {
//   color: #333;
//   padding: 12px 16px;
//   text-decoration: none;
//   display: block;
//   font-size: 14px;
// }
//
// .dropdown-item:hover {
//   background-color: #f1f1f1;
// }
//
// .label {
//   margin-top: 20px;
//   font-size: 12px;
//   color: #666;
// }
// </style>
// </head>
//
// <body>
//
// <h3>Hover-based Dropdown</h3>
//
// <ul class="nav">
//   <li class="nav-item">
//     <a class="nav-link">Menu ▼</a>
//     <div class="dropdown-menu">
//       <a class="dropdown-item" href="#" onclick="alert('Action clicked'); return false;">Action</a>
//       <a class="dropdown-item" href="#" onclick="alert('Another action clicked'); return false;">Another action</a>
//       <a class="dropdown-item" href="#" onclick="alert('Something else clicked'); return false;">Something else</a>
//     </div>
//   </li>
//
//   <li class="nav-item">
//     <a class="nav-link">Options ▼</a>
//     <div class="dropdown-menu">
//       <a class="dropdown-item" href="#" onclick="alert('Option 1 clicked'); return false;">Option 1</a>
//       <a class="dropdown-item" href="#" onclick="alert('Option 2 clicked'); return false;">Option 2</a>
//     </div>
//   </li>
// </ul>
//
// <p class="label">Hover over menu items to see dropdowns</p>
//
// </body>
// </html>
//   ''';
//
//   // Get current HTML based on selection
//   String get currentHtmlContent => showingHtmlContent1 ? htmlContent : htmlContent2;
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
//       ..loadHtmlString(currentHtmlContent);
//
//     // Reload after delay to ensure scripts execute properly on Android 7
//     Future.delayed(const Duration(milliseconds: 1000), () {
//       if (mounted) {
//         webViewController.reload();
//       }
//     });
//   }
//
//   // Switch to HTML Content 1
//   void _loadHtmlContent1() {
//     setState(() {
//       showingHtmlContent1 = true;
//     });
//     webViewController.loadHtmlString(htmlContent);
//
//     // Reload to ensure JavaScript executes
//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (mounted) {
//         webViewController.reload();
//       }
//     });
//
//     _showSnackBar('Loaded Click-based Dropdown');
//   }
//
//   // Switch to HTML Content 2
//   void _loadHtmlContent2() {
//     setState(() {
//       showingHtmlContent1 = false;
//     });
//     webViewController.loadHtmlString(htmlContent2);
//
//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (mounted) {
//         webViewController.reload();
//       }
//     });
//
//     _showSnackBar('Loaded Hover-based Dropdown');
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
//         htmlContent: currentHtmlContent);
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
//         htmlContent: currentHtmlContent);
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
//   Future<Uint8List> _generatePdfFromHtml() async {
//     try {
//       final pdfBytes = await Printing.convertHtml(
//         format: PdfPageFormat.a4,
//         html: currentHtmlContent,
//       );
//       return pdfBytes;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> _viewAsPdf() async {
//     setState(() => isConvertingPdf = true);
//     try {
//       final pdfBytes = await _generatePdfFromHtml();
//       setState(() => isConvertingPdf = false);
//
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Scaffold(
//             appBar: AppBar(title: const Text('PDF Preview')),
//             body: PdfPreview(
//               build: (format) => pdfBytes,
//               allowSharing: true,
//               allowPrinting: true,
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       setState(() => isConvertingPdf = false);
//       _showSnackBar('Error generating PDF: $e', isError: true);
//     }
//   }
//
//   Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
//     try {
//       final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
//         content: htmlContent,
//         duration: 1000,
//         scale: 2,
//       );
//       return imageBytes;
//     } catch (e) {
//       print('Error converting HTML to Uint8List: $e');
//       return null;
//     }
//   }
//
//   Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
//     final image = img.decodeImage(htmlBytes);
//     if (image == null) {
//       throw Exception("Failed to decode HTML image");
//     }
//
//     const int targetWidth = 576;
//
//     if (image.width != targetWidth) {
//       final resized = img.copyResize(
//         image,
//         width: targetWidth,
//         interpolation: img.Interpolation.cubic,
//       );
//       return Uint8List.fromList(img.encodePng(resized));
//     }
//
//     return Uint8List.fromList(img.encodePng(image));
//   }
//
//   Future<void> _printAsPdf() async {
//     if (!PrinterService.isPrinterConnected) {
//       _showSnackBar('Please connect to a printer first', isError: true);
//       return;
//     }
//
//     setState(() {
//       isPrinting = true;
//       isConvertingPdf = true;
//     });
//
//     try {
//       _showSnackBar('Converting HTML to image...');
//
//       final Uint8List? bytes = await convertHtmlToUint8List(currentHtmlContent);
//
//       if (bytes == null) {
//         throw Exception('Failed to convert HTML to image');
//       }
//
//       _showSnackBar('Resizing for thermal printer...');
//
//       final resizedBytes = await resizeForThermal(bytes);
//
//       setState(() => isConvertingPdf = false);
//
//       _showSnackBar('Sending to printer...');
//
//       await PrinterService.printImage(resizedBytes);
//
//       setState(() => isPrinting = false);
//       _showSnackBar('Print completed successfully');
//     } catch (e) {
//       setState(() {
//         isPrinting = false;
//         isConvertingPdf = false;
//       });
//       _showSnackBar('Error: $e', isError: true);
//       print('Print error: $e');
//     }
//   }
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
//           // HTML Switcher Buttons
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: showingHtmlContent1 ? null : _loadHtmlContent1,
//                     icon: const Icon(Icons.touch_app, size: 18),
//                     label: const Text('Click Dropdown'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: showingHtmlContent1
//                           ? Colors.blue.shade700
//                           : Colors.blue,
//                       foregroundColor: Colors.white,
//                       elevation: showingHtmlContent1 ? 8 : 2,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: showingHtmlContent1 ? _loadHtmlContent2 : null,
//                     icon: const Icon(Icons.mouse, size: 18),
//                     label: const Text('Hover Dropdown'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: !showingHtmlContent1
//                           ? Colors.blue.shade700
//                           : Colors.blue,
//                       foregroundColor: Colors.white,
//                       elevation: !showingHtmlContent1 ? 8 : 2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
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
//                         Text(
//                           'Preview: ${showingHtmlContent1 ? "Click" : "Hover"} Dropdown',
//                           style: const TextStyle(
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
//                           label: Text(
//                               isConvertingPdf ? 'Converting...' : 'View as PDF'),
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
//                       child: Screenshot(
//                         controller: screenshotController,
//                         child: WebViewWidget(controller: webViewController),
//                       ),
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
//                         onPressed:
//                         PrinterService.isPrinterConnected && !isPrinting
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
//                         onPressed:
//                         PrinterService.isPrinterConnected && !isPrinting
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
//                     onPressed: PrinterService.isPrinterConnected &&
//                         !isPrinting &&
//                         !isConvertingPdf
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
//                         : const Icon(Icons.image),
//                     label: Text(
//                       isConvertingPdf
//                           ? 'Converting...'
//                           : isPrinting
//                           ? 'Printing...'
//                           : 'Print as Image',
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
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

  // Track which HTML is currently displayed
  bool showingHtmlContent1 = true;

  // HTML Content 1 - Click-based dropdown
  final String htmlContent = '''
  

<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {
  font-family: Arial, sans-serif;
  padding: 20px;
  margin: 0;
}

/* Button */
.dropdown-btn {
  background-color: #007bff;
  color: white;
  padding: 10px 16px;
  border: none;
  cursor: pointer;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 500;
}

.dropdown-btn:hover {
  background-color: #0056b3;
}

/* Dropdown container */
.dropdown {
  position: relative;
  display: inline-block;
}

/* Dropdown content */
.dropdown-menu {
  display: none;
  position: absolute;
  background-color: white;
  min-width: 160px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.15);
  border-radius: 4px;
  z-index: 1000;
  margin-top: 5px;
  border: 1px solid #ddd;
}

/* Dropdown items */
.dropdown-menu a {
  color: #333;
  padding: 10px 16px;
  text-decoration: none;
  display: block;
  font-size: 14px;
}

.dropdown-menu a:first-child {
  border-radius: 4px 4px 0 0;
}

.dropdown-menu a:last-child {
  border-radius: 0 0 4px 4px;
}

.dropdown-menu a:hover {
  background-color: #f1f1f1;
}

.label {
  margin-top: 20px;
  font-size: 12px;
  color: #666;
}
</style>
</head>

<body>

<h3>Click-based Dropdown</h3>

<div class="dropdown">
  <button class="dropdown-btn" id="menuBtn">
    Menu ▼
  </button>

  <div class="dropdown-menu" id="dropdownMenu">
    <a href="#" onclick="alert('Item 1 clicked'); return false;">Item 1</a>
    <a href="#" onclick="alert('Item 2 clicked'); return false;">Item 2</a>
    <a href="#" onclick="alert('Item 3 clicked'); return false;">Item 3</a>
  </div>
</div>

<p class="label">Click the button to toggle dropdown</p>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const btn = document.getElementById('menuBtn');
  const menu = document.getElementById('dropdownMenu');
  
  if (btn && menu) {
    btn.addEventListener('click', function(e) {
      e.stopPropagation();
      menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
      if (!event.target.matches('.dropdown-btn')) {
        if (menu.style.display === 'block') {
          menu.style.display = 'none';
        }
      }
    });
  }
});
</script>

</body>
</html>
  ''';

  // HTML Content 2 - Hover-based dropdown (no JavaScript)
  final String htmlContent2 = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {
  font-family: Arial, sans-serif;
  padding: 20px;
  margin: 0;
}

/* Navigation bar */
.nav {
  list-style-type: none;
  margin: 0;
  padding: 0;
  background-color: #333;
  border-radius: 4px;
  overflow: hidden;
}

.nav-item {
  float: left;
  position: relative;
}

.nav-link {
  display: block;
  color: white;
  text-align: center;
  padding: 14px 20px;
  text-decoration: none;
  font-size: 14px;
  cursor: pointer;
}

.nav-link:hover {
  background-color: #555;
}

/* Dropdown container */
.dropdown-menu {
  display: none;
  position: absolute;
  background-color: white;
  min-width: 200px;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
  z-index: 1000;
  border-radius: 0 0 4px 4px;
  border: 1px solid #ddd;
  border-top: none;
}

/* Show dropdown on hover */
.nav-item:hover .dropdown-menu {
  display: block;
}

/* Dropdown links */
.dropdown-item {
  color: #333;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
  font-size: 14px;
}

.dropdown-item:hover {
  background-color: #f1f1f1;
}

.label {
  margin-top: 20px;
  font-size: 12px;
  color: #666;
}
</style>
</head>

<body>

<h3>Hover-based Dropdown</h3>

<ul class="nav">
  <li class="nav-item">
    <a class="nav-link">Menu ▼</a>
    <div class="dropdown-menu">
      <a class="dropdown-item" href="#" onclick="alert('Action clicked'); return false;">Action</a>
      <a class="dropdown-item" href="#" onclick="alert('Another action clicked'); return false;">Another action</a>
      <a class="dropdown-item" href="#" onclick="alert('Something else clicked'); return false;">Something else</a>
    </div>
  </li>
  
  <li class="nav-item">
    <a class="nav-link">Options ▼</a>
    <div class="dropdown-menu">
      <a class="dropdown-item" href="#" onclick="alert('Option 1 clicked'); return false;">Option 1</a>
      <a class="dropdown-item" href="#" onclick="alert('Option 2 clicked'); return false;">Option 2</a>
    </div>
  </li>
</ul>

<p class="label">Hover over menu items to see dropdowns</p>

</body>
</html>
  ''';

  // Get current HTML based on selection
  String get currentHtmlContent => showingHtmlContent1 ? htmlContent : htmlContent2;

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
      ..loadHtmlString(currentHtmlContent);

    // Reload after delay to ensure scripts execute properly on Android 7
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        webViewController.reload();
      }
    });
  }

  // Switch to HTML Content 1
  void _loadHtmlContent1() {
    setState(() {
      showingHtmlContent1 = true;
    });
    webViewController.loadHtmlString(htmlContent);

    // Reload to ensure JavaScript executes
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        webViewController.reload();
      }
    });

    _showSnackBar('Loaded Click-based Dropdown');
  }

  // Switch to HTML Content 2
  void _loadHtmlContent2() {
    setState(() {
      showingHtmlContent1 = false;
    });
    webViewController.loadHtmlString(htmlContent2);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        webViewController.reload();
      }
    });

    _showSnackBar('Loaded Hover-based Dropdown');
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
        htmlContent: currentHtmlContent);

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
        htmlContent: currentHtmlContent);

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

  Future<Uint8List> _generatePdfFromHtml() async {
    try {
      final pdfBytes = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: currentHtmlContent,
      );
      return pdfBytes;
    } catch (e) {
      rethrow;
    }
  }

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

  Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
    try {
      final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
        content: htmlContent,
        duration: 1000,
        scale: 2,
      );
      return imageBytes;
    } catch (e) {
      print('Error converting HTML to Uint8List: $e');
      return null;
    }
  }

  Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
    final image = img.decodeImage(htmlBytes);
    if (image == null) {
      throw Exception("Failed to decode HTML image");
    }

    const int targetWidth = 576;

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

      final Uint8List? bytes = await convertHtmlToUint8List(currentHtmlContent);

      if (bytes == null) {
        throw Exception('Failed to convert HTML to image');
      }

      _showSnackBar('Resizing for thermal printer...');

      final resizedBytes = await resizeForThermal(bytes);

      setState(() => isConvertingPdf = false);

      _showSnackBar('Sending to printer...');

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

          // HTML Switcher Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showingHtmlContent1 ? null : _loadHtmlContent1,
                    icon: const Icon(Icons.touch_app, size: 18),
                    label: const Text('Click Dropdown'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showingHtmlContent1
                          ? Colors.blue.shade700
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: showingHtmlContent1 ? 8 : 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showingHtmlContent1 ? _loadHtmlContent2 : null,
                    icon: const Icon(Icons.mouse, size: 18),
                    label: const Text('Hover Dropdown'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !showingHtmlContent1
                          ? Colors.blue.shade700
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: !showingHtmlContent1 ? 8 : 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                        Text(
                          'Preview: ${showingHtmlContent1 ? "Click" : "Hover"} Dropdown',
                          style: const TextStyle(
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