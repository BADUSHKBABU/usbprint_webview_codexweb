//
// //
// // import 'dart:async';
// // import 'dart:developer';
// // import 'dart:typed_data';
// // import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// // import 'package:image/image.dart';
// // import 'package:flutter/services.dart';
// //
// // import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// //
// // class PrinterService {
// //   static late String printerName;
// //   static late Completer<PrinterDevice> _completer;
// //   static late PrinterDevice _printer;
// //   static USBStatus _currentUsbStatus = USBStatus.none;
// //   static StreamSubscription<USBStatus>? _subscriptionUsbStatus;
// //   static final _printerManager = PrinterManager.instance;
// //
// //   static final StreamController<String> _currentUsbStatusStreamController = StreamController();
// //   static Stream<String> currentUsbStringStatusStream = _currentUsbStatusStreamController.stream.asBroadcastStream();
// //   static late StreamSubscription<String> _currentUsbStatusStringSubscription;
// //   static bool _isPrinterAvailable = false;
// //   static bool _isScanning = false;
// //   static bool _isDisconnecting = false;
// //   static bool _isPrinting = false;
// //
// //   static String get printerStatus => _convertUsbStatusToString();
// //   static bool get isPrinterConnected => _currentUsbStatus == USBStatus.connected;
// //
// //   static void init() {
// //     log('[PrinterService] init called');
// //     _currentUsbStatusStringSubscription = currentUsbStringStatusStream.listen((event) { });
// //
// //     _currentUsbStatusStringSubscription.onData((data) {
// //       // log('[printer_service] on data _currentUsbStatusStringSubscription');
// //       // log(data);
// //     });
// //   }
// //
// //   static void dispose() {
// //     _currentUsbStatusStringSubscription.cancel();
// //     _currentUsbStatusStreamController.close();
// //   }
// //
// //   static String _convertUsbStatusToString() {
// //     final usbStatus = _currentUsbStatus == USBStatus.connecting
// //         ? PrinterStatus.connecting
// //         : _currentUsbStatus == USBStatus.connected ? PrinterStatus.connected : PrinterStatus.notConnected;
// //
// //     if (_isScanning) {
// //       return PrinterStatus.scanning;
// //     }
// //     else if (_isPrinting) {
// //       return PrinterStatus.printing;
// //     }
// //     else if (_isDisconnecting) {
// //       return PrinterStatus.disconnecting;
// //     }
// //     else if (usbStatus == PrinterStatus.notConnected) {
// //       return _isPrinterAvailable ? PrinterStatus.notConnected : PrinterStatus.notFound;
// //     }
// //
// //     return usbStatus;
// //   }
// //
// //   static Future<void> scan() async {
// //     if (_isScanning == false) {
// //       _isScanning = true;
// //       _refreshPrinterStatus();
// //
// //       var defaultPrinterType = PrinterType.usb;
// //
// //       _subscriptionUsbStatus = _printerManager.stateUSB.listen((status) {
// //         log('[PrinterService] on listen');
// //       });
// //
// //       _subscriptionUsbStatus?.onData((status) {
// //         log('[PrinterService] on data');
// //         log(' ----------------- status usb $status ------------------ ');
// //         _currentUsbStatus = status;
// //         _refreshPrinterStatus();
// //       });
// //
// //       // _subscriptionUsbStatus?.onDone(() {
// //       //   log('[PrinterService] on done');
// //       //   _currentUsbStatus = USBStatus.none;
// //       // });
// //
// //       /// *********** scan method ************* ///
// //       log('[printer_service] Searching for printers...');
// //       _completer = Completer<PrinterDevice>();
// //
// //       _printerManager.discovery(type: defaultPrinterType).listen((printer) {
// //         log('printer os: ${printer.operatingSystem}');
// //         log('printer name: ${printer.name}');
// //         log('printer address: ${printer.address}');
// //         log('printer vendor id: ${printer.vendorId}');
// //         log('printer product id: ${printer.productId}');
// //         _completer.complete(printer);
// //       });
// //
// //       try {
// //         printerName = '';
// //         _printer = await _completer.future.timeout(const Duration(seconds: 5))
// //             .whenComplete(() {
// //           log('[printer_service] scanning timer done');
// //           _isScanning = false;
// //         });
// //
// //         printerName = _printer.name;
// //         _isPrinterAvailable = printerName.isNotEmpty;
// //
// //         _refreshPrinterStatus();
// //       } on TimeoutException catch (e) {
// //         log('[printer_service@TimeoutException] Scan result: Printer not found\n$e');
// //         _isPrinterAvailable = false;
// //         _refreshPrinterStatus();
// //         return;
// //       }
// //     }
// //   }
// //
// //   static Future<void> connect() async {
// //     if (printerStatus == PrinterStatus.notConnected) {
// //       // log('printer name: ${_printer.name} / current status usb: ${printerManager.currentStatusUSB.name}');
// //
// //       try {
// //         await _printerManager.connect(
// //             type: PrinterType.usb,
// //             model: UsbPrinterInput(
// //                 name: _printer.name,
// //                 productId: _printer.productId,
// //                 vendorId: _printer.vendorId
// //             )
// //         )
// //             .timeout(const Duration(seconds: 5))
// //             .whenComplete(() => log('connecting done'));
// //
// //       } on TimeoutException catch (e) {
// //         log("[printer_service] Failed to connect with printer\n$e");
// //         return;
// //       }
// //     }
// //   }
// //
// //   static Future<void> disConnect() async {
// //
// //     if (printerStatus == PrinterStatus.connected) {
// //       log('Disconnecting printer');
// //       _isDisconnecting = true;
// //       _refreshPrinterStatus();
// //
// //       try {
// //         await _printerManager.disconnect(type: PrinterType.usb,)
// //             .timeout(const Duration(seconds: 5))
// //             .whenComplete(() {
// //           log('[printer_service] disconnect task done');
// //           _currentUsbStatus = USBStatus.none;
// //           _isDisconnecting = false;
// //           _refreshPrinterStatus();
// //         });
// //       } on TimeoutException catch (e) {
// //         log("Failed to disConnect printer\n$e");
// //         return;
// //       }
// //     }
// //   }
// //
// //   static Future<void> testPrint() async {
// //     _isPrinting = true;
// //     _refreshPrinterStatus();
// //
// //     // FIX: Create a growable list using <int>[]
// //     List<int> bytes = <int>[];
// //
// //     final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
// //     bytes.addAll(generator.text('Print test OK'));
// //     bytes.addAll(generator.cut());
// //
// //     await _print(data: bytes);
// //   }
// //
// //   static void _refreshPrinterStatus() {
// //     _currentUsbStatusStreamController.sink.add(_convertUsbStatusToString());
// //   }
// //
// //   static Future<bool> _print({required List<int> data}) async {
// //     bool isPrintOk = true;
// //
// //     try {
// //       isPrintOk = await _printerManager
// //           .send(type: PrinterType.usb, bytes: data)
// //           .timeout(const Duration(seconds: 5))
// //           .whenComplete(() {
// //         _isPrinting = false;
// //         _refreshPrinterStatus();
// //       });
// //       log('[printer_service] Print test OK');
// //     } on TimeoutException catch (e) {
// //       isPrintOk = false;
// //       log('[printer_service] Failed to print data\n$e');
// //     }
// //
// //     return isPrintOk;
// //   }
// //
// //   static Future<void> printInvoiceFromImage({required Uint8List? imageData}) async {
// //     if (imageData == null) return;
// //
// //     _isPrinting = true;
// //     _refreshPrinterStatus();
// //
// //     try {
// //       // FIX: Create a growable list using <int>[]
// //       List<int> bytes = <int>[];
// //
// //       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
// //       final image = decodePng(imageData);
// //
// //       if (image == null) {
// //         log('[printer_service] Failed to decode image');
// //         return;
// //       }
// //
// //       // Use imageRaster for better quality on thermal printers
// //       bytes.addAll(generator.imageRaster(image, align: PosAlign.center));
// //       bytes.addAll(generator.feed(2)); // Add some spacing
// //       bytes.addAll(generator.cut());
// //
// //       await _print(data: bytes);
// //     } catch (e) {
// //       log('[printer_service] Error printing image: $e');
// //     }
// //   }
// //
// //   /// Print HTML content as text (basic formatting)
// //   static Future<void> printHtmlAsText({required String htmlContent}) async {
// //     _isPrinting = true;
// //     _refreshPrinterStatus();
// //
// //     try {
// //       List<int> bytes = <int>[];
// //
// //       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
// //
// //       // Basic HTML to text conversion (you can enhance this)
// //       String plainText = _htmlToPlainText(htmlContent);
// //
// //       bytes.addAll(generator.text(plainText, styles: PosStyles(align: PosAlign.center)));
// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());
// //
// //       await _print(data: bytes);
// //     } catch (e) {
// //       log('[printer_service] Error printing HTML: $e');
// //     }
// //   }
// //
// //   /// Convert basic HTML to plain text (basic implementation)
// //   static String _htmlToPlainText(String html) {
// //     // Remove HTML tags
// //     String text = html.replaceAll(RegExp(r'<[^>]*>'), '');
// //
// //     // Decode HTML entities
// //     text = text
// //         .replaceAll('&nbsp;', ' ')
// //         .replaceAll('&amp;', '&')
// //         .replaceAll('&lt;', '<')
// //         .replaceAll('&gt;', '>')
// //         .replaceAll('&quot;', '"')
// //         .replaceAll('&#39;', "'");
// //
// //     // Remove extra whitespace
// //     text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
// //
// //     return text;
// //   }
// //
// //   /// Print formatted invoice/receipt
// //   static Future<void> printFormattedReceipt({
// //     required String title,
// //     required List<Map<String, String>> items,
// //     String? footer,
// //   }) async {
// //     _isPrinting = true;
// //     _refreshPrinterStatus();
// //
// //     try {
// //       List<int> bytes = <int>[];
// //
// //       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
// //
// //       // Header
// //       bytes.addAll(generator.text(
// //         title,
// //         styles: PosStyles(
// //           align: PosAlign.center,
// //           bold: true,
// //           height: PosTextSize.size2,
// //           width: PosTextSize.size2,
// //         ),
// //       ));
// //       bytes.addAll(generator.feed(1));
// //       bytes.addAll(generator.hr());
// //
// //       // Items
// //       for (var item in items) {
// //         String itemName = item['name'] ?? '';
// //         String itemValue = item['value'] ?? '';
// //
// //         bytes.addAll(generator.row([
// //           PosColumn(text: itemName, width: 6),
// //           PosColumn(text: itemValue, width: 6, styles: PosStyles(align: PosAlign.right)),
// //         ]));
// //       }
// //
// //       bytes.addAll(generator.hr());
// //
// //       // Footer
// //       if (footer != null && footer.isNotEmpty) {
// //         bytes.addAll(generator.text(
// //           footer,
// //           styles: PosStyles(align: PosAlign.center),
// //         ));
// //       }
// //
// //       bytes.addAll(generator.feed(2));
// //       bytes.addAll(generator.cut());
// //
// //       await _print(data: bytes);
// //     } catch (e) {
// //       log('[printer_service] Error printing receipt: $e');
// //     }
// //   }
// // }
// //
// // class PrinterStatus {
// //   static const connecting = 'Connecting';
// //   static const disconnecting = 'Disconnecting';
// //   static const connected = 'Connected';
// //   static const notFound = 'Printer not found';
// //   static const notConnected = 'Not connected';
// //   static const scanning = 'Searching for printer';
// //   static const printing = 'Printing';
// // }
//
//
// import 'dart:async';
// import 'dart:developer';
// import 'dart:typed_data';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/services.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as html_dom;
//
// class PrinterService {
//   static late String printerName;
//   static late Completer<PrinterDevice> _completer;
//   static late PrinterDevice _printer;
//   static USBStatus _currentUsbStatus = USBStatus.none;
//   static StreamSubscription<USBStatus>? _subscriptionUsbStatus;
//   static final _printerManager = PrinterManager.instance;
//
//   static final StreamController<String> _currentUsbStatusStreamController = StreamController();
//   static Stream<String> currentUsbStringStatusStream = _currentUsbStatusStreamController.stream.asBroadcastStream();
//   static late StreamSubscription<String> _currentUsbStatusStringSubscription;
//   static bool _isPrinterAvailable = false;
//   static bool _isScanning = false;
//   static bool _isDisconnecting = false;
//   static bool _isPrinting = false;
//
//   static String get printerStatus => _convertUsbStatusToString();
//   static bool get isPrinterConnected => _currentUsbStatus == USBStatus.connected;
//
//   static void init() {
//     log('[PrinterService] init called');
//     _currentUsbStatusStringSubscription = currentUsbStringStatusStream.listen((event) { });
//
//     _currentUsbStatusStringSubscription.onData((data) {
//       // log('[printer_service] on data _currentUsbStatusStringSubscription');
//       // log(data);
//     });
//   }
//
//   static void dispose() {
//     _currentUsbStatusStringSubscription.cancel();
//     _currentUsbStatusStreamController.close();
//   }
//
//   static String _convertUsbStatusToString() {
//     final usbStatus = _currentUsbStatus == USBStatus.connecting
//         ? PrinterStatus.connecting
//         : _currentUsbStatus == USBStatus.connected ? PrinterStatus.connected : PrinterStatus.notConnected;
//
//     if (_isScanning) {
//       return PrinterStatus.scanning;
//     }
//     else if (_isPrinting) {
//       return PrinterStatus.printing;
//     }
//     else if (_isDisconnecting) {
//       return PrinterStatus.disconnecting;
//     }
//     else if (usbStatus == PrinterStatus.notConnected) {
//       return _isPrinterAvailable ? PrinterStatus.notConnected : PrinterStatus.notFound;
//     }
//
//     return usbStatus;
//   }
//
//   static Future<void> scan() async {
//     if (_isScanning == false) {
//       _isScanning = true;
//       _refreshPrinterStatus();
//
//       var defaultPrinterType = PrinterType.usb;
//
//       _subscriptionUsbStatus = _printerManager.stateUSB.listen((status) {
//         log('[PrinterService] on listen');
//       });
//
//       _subscriptionUsbStatus?.onData((status) {
//         log('[PrinterService] on data');
//         log(' ----------------- status usb $status ------------------ ');
//         _currentUsbStatus = status;
//         _refreshPrinterStatus();
//       });
//
//       log('[printer_service] Searching for printers...');
//       _completer = Completer<PrinterDevice>();
//
//       _printerManager.discovery(type: defaultPrinterType).listen((printer) {
//         log('printer os: ${printer.operatingSystem}');
//         log('printer name: ${printer.name}');
//         log('printer address: ${printer.address}');
//         log('printer vendor id: ${printer.vendorId}');
//         log('printer product id: ${printer.productId}');
//         _completer.complete(printer);
//       });
//
//       try {
//         printerName = '';
//         _printer = await _completer.future.timeout(const Duration(seconds: 5))
//             .whenComplete(() {
//           log('[printer_service] scanning timer done');
//           _isScanning = false;
//         });
//
//         printerName = _printer.name;
//         _isPrinterAvailable = printerName.isNotEmpty;
//
//         _refreshPrinterStatus();
//       } on TimeoutException catch (e) {
//         log('[printer_service@TimeoutException] Scan result: Printer not found\n$e');
//         _isPrinterAvailable = false;
//         _refreshPrinterStatus();
//         return;
//       }
//     }
//   }
//
//   static Future<void> connect() async {
//     if (printerStatus == PrinterStatus.notConnected) {
//       try {
//         await _printerManager.connect(
//             type: PrinterType.usb,
//             model: UsbPrinterInput(
//                 name: _printer.name,
//                 productId: _printer.productId,
//                 vendorId: _printer.vendorId
//             )
//         )
//             .timeout(const Duration(seconds: 5))
//             .whenComplete(() => log('connecting done'));
//
//       } on TimeoutException catch (e) {
//         log("[printer_service] Failed to connect with printer\n$e");
//         return;
//       }
//     }
//   }
//
//   static Future<void> disConnect() async {
//     if (printerStatus == PrinterStatus.connected) {
//       log('Disconnecting printer');
//       _isDisconnecting = true;
//       _refreshPrinterStatus();
//
//       try {
//         await _printerManager.disconnect(type: PrinterType.usb,)
//             .timeout(const Duration(seconds: 5))
//             .whenComplete(() {
//           log('[printer_service] disconnect task done');
//           _currentUsbStatus = USBStatus.none;
//           _isDisconnecting = false;
//           _refreshPrinterStatus();
//         });
//       } on TimeoutException catch (e) {
//         log("Failed to disConnect printer\n$e");
//         return;
//       }
//     }
//   }
//
//   static Future<void> testPrint() async {
//     _isPrinting = true;
//     _refreshPrinterStatus();
//
//     List<int> bytes = <int>[];
//
//     final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
//     bytes.addAll(generator.text('Print test OK'));
//     bytes.addAll(generator.cut());
//
//     await _print(data: bytes);
//   }
//
//   static void _refreshPrinterStatus() {
//     _currentUsbStatusStreamController.sink.add(_convertUsbStatusToString());
//   }
//
//   static Future<bool> _print({required List<int> data}) async {
//     bool isPrintOk = true;
//
//     try {
//       isPrintOk = await _printerManager
//           .send(type: PrinterType.usb, bytes: data)
//           .timeout(const Duration(seconds: 10))
//           .whenComplete(() {
//         _isPrinting = false;
//         _refreshPrinterStatus();
//       });
//       log('[printer_service] Print completed: $isPrintOk');
//     } on TimeoutException catch (e) {
//       isPrintOk = false;
//       log('[printer_service] Failed to print data - Timeout\n$e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//     } catch (e) {
//       isPrintOk = false;
//       log('[printer_service] Failed to print data - Error: $e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//     }
//
//     return isPrintOk;
//   }
//
//   static Future<void> printInvoiceFromImage({required Uint8List? imageData}) async {
//     if (imageData == null) return;
//
//     _isPrinting = true;
//     _refreshPrinterStatus();
//
//     try {
//       List<int> bytes = <int>[];
//
//       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
//       final image = img.decodePng(imageData);
//
//       if (image == null) {
//         log('[printer_service] Failed to decode image');
//         _isPrinting = false;
//         _refreshPrinterStatus();
//         return;
//       }
//
//       // Use imageRaster for better quality on thermal printers
//       bytes.addAll(generator.imageRaster(image, align: PosAlign.center));
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());
//
//       await _print(data: bytes);
//     } catch (e) {
//       log('[printer_service] Error printing image: $e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//     }
//   }
//
//   /// Print HTML content by parsing and formatting
//   static Future<bool> printHtmlContent({required String htmlContent}) async {
//     if (!isPrinterConnected) {
//       log('[printer_service] Printer not connected');
//       return false;
//     }
//
//     log('[printer_service] Starting HTML print...');
//     _isPrinting = true;
//     _refreshPrinterStatus();
//
//     try {
//       List<int> bytes = <int>[];
//       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
//
//       // Parse HTML
//       final document = html_parser.parse(htmlContent);
//
//       log('[printer_service] HTML parsed, processing elements...');
//
//       // Extract and format content
//       await _parseHtmlToBytes(document, generator, bytes);
//
//       // Add cut command
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());
//
//       log('[printer_service] Generated ${bytes.length} bytes, sending to printer...');
//
//       // Print
//       return await _print(data: bytes);
//     } catch (e) {
//       log('[printer_service] Error printing HTML: $e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//       return false;
//     }
//   }
//
//   /// Parse HTML document and convert to ESC/POS bytes
//   static Future<void> _parseHtmlToBytes(
//       html_dom.Document document,
//       Generator generator,
//       List<int> bytes,
//       ) async {
//     // Try to find the main content
//     final body = document.body;
//     if (body == null) {
//       log('[printer_service] No body found in HTML');
//       return;
//     }
//
//     // Process each element
//     _processHtmlElement(body, generator, bytes);
//   }
//
//   /// Process HTML element recursively
//   static void _processHtmlElement(
//       html_dom.Element element,
//       Generator generator,
//       List<int> bytes,
//       {bool isBold = false, bool isCenter = false, int fontSize = 1}
//       ) {
//     for (var node in element.nodes) {
//       if (node is html_dom.Element) {
//         final tagName = node.localName?.toLowerCase() ?? '';
//
//         switch (tagName) {
//           case 'h1':
//           case 'h2':
//           case 'h3':
//             final text = node.text.trim();
//             if (text.isNotEmpty) {
//               bytes.addAll(generator.text(
//                 text,
//                 styles: PosStyles(
//                   align: PosAlign.center,
//                   bold: true,
//                   height: tagName == 'h1' ? PosTextSize.size2 : PosTextSize.size1,
//                   width: tagName == 'h1' ? PosTextSize.size2 : PosTextSize.size1,
//                 ),
//               ));
//               bytes.addAll(generator.feed(1));
//             }
//             break;
//
//           case 'p':
//             final text = node.text.trim();
//             if (text.isNotEmpty) {
//               bytes.addAll(generator.text(
//                 text,
//                 styles: PosStyles(
//                   align: isCenter ? PosAlign.center : PosAlign.left,
//                   bold: isBold,
//                 ),
//               ));
//               bytes.addAll(generator.feed(1));
//             }
//             break;
//
//           case 'strong':
//           case 'b':
//             _processHtmlElement(node, generator, bytes, isBold: true, isCenter: isCenter);
//             break;
//
//           case 'center':
//             _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: true);
//             break;
//
//           case 'table':
//             _processTable(node, generator, bytes);
//             break;
//
//           case 'br':
//             bytes.addAll(generator.feed(1));
//             break;
//
//           case 'hr':
//             bytes.addAll(generator.hr());
//             break;
//
//           case 'ul':
//           case 'ol':
//             _processList(node, generator, bytes, ordered: tagName == 'ol');
//             break;
//
//           case 'div':
//           case 'span':
//           case 'section':
//           case 'article':
//             _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: isCenter);
//             break;
//
//           default:
//           // Process children for unknown tags
//             _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: isCenter);
//         }
//       } else if (node is html_dom.Text) {
//         final text = node.text.trim();
//         if (text.isNotEmpty) {
//           bytes.addAll(generator.text(
//             text,
//             styles: PosStyles(
//               align: isCenter ? PosAlign.center : PosAlign.left,
//               bold: isBold,
//             ),
//           ));
//         }
//       }
//     }
//   }
//
//   /// Process HTML table
//   static void _processTable(
//       html_dom.Element table,
//       Generator generator,
//       List<int> bytes,
//       ) {
//     final rows = table.querySelectorAll('tr');
//
//     for (var row in rows) {
//       final cells = row.querySelectorAll('td, th');
//       final isHeader = row.querySelector('th') != null;
//
//       if (cells.isEmpty) continue;
//
//       if (cells.length == 2) {
//         // Two column layout - perfect for receipts
//         bytes.addAll(generator.row([
//           PosColumn(
//             text: cells[0].text.trim(),
//             width: 6,
//             styles: PosStyles(bold: isHeader),
//           ),
//           PosColumn(
//             text: cells[1].text.trim(),
//             width: 6,
//             styles: PosStyles(align: PosAlign.right, bold: isHeader),
//           ),
//         ]));
//       } else if (cells.length == 3) {
//         // Three column layout
//         bytes.addAll(generator.row([
//           PosColumn(
//             text: cells[0].text.trim(),
//             width: 4,
//             styles: PosStyles(bold: isHeader),
//           ),
//           PosColumn(
//             text: cells[1].text.trim(),
//             width: 4,
//             styles: PosStyles(align: PosAlign.center, bold: isHeader),
//           ),
//           PosColumn(
//             text: cells[2].text.trim(),
//             width: 4,
//             styles: PosStyles(align: PosAlign.right, bold: isHeader),
//           ),
//         ]));
//       } else {
//         // Single column or multiple columns - print each cell on new line
//         for (var cell in cells) {
//           final cellText = cell.text.trim();
//           if (cellText.isNotEmpty) {
//             bytes.addAll(generator.text(
//               cellText,
//               styles: PosStyles(bold: isHeader),
//             ));
//           }
//         }
//       }
//     }
//
//     bytes.addAll(generator.feed(1));
//   }
//
//   /// Process HTML list (ul/ol)
//   static void _processList(
//       html_dom.Element list,
//       Generator generator,
//       List<int> bytes,
//       {bool ordered = false}
//       ) {
//     final items = list.querySelectorAll('li');
//
//     for (int i = 0; i < items.length; i++) {
//       final item = items[i];
//       final text = item.text.trim();
//       if (text.isNotEmpty) {
//         final prefix = ordered ? '${i + 1}. ' : '• ';
//         bytes.addAll(generator.text(
//           '$prefix$text',
//           styles: PosStyles(align: PosAlign.left),
//         ));
//       }
//     }
//
//     bytes.addAll(generator.feed(1));
//   }
//
//   /// Convert HTML to plain text (fallback method)
//   static String _htmlToPlainText(String html) {
//     // Remove script and style tags completely
//     html = html.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
//     html = html.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
//
//     // Add line breaks for block elements
//     html = html.replaceAll(RegExp(r'<br[^>]*>'), '\n');
//     html = html.replaceAll(RegExp(r'</p>'), '\n');
//     html = html.replaceAll(RegExp(r'</div>'), '\n');
//     html = html.replaceAll(RegExp(r'</h[1-6]>'), '\n');
//     html = html.replaceAll(RegExp(r'</tr>'), '\n');
//
//     // Remove all HTML tags
//     String text = html.replaceAll(RegExp(r'<[^>]*>'), '');
//
//     // Decode HTML entities
//     text = text
//         .replaceAll('&nbsp;', ' ')
//         .replaceAll('&amp;', '&')
//         .replaceAll('&lt;', '<')
//         .replaceAll('&gt;', '>')
//         .replaceAll('&quot;', '"')
//         .replaceAll('&#39;', "'")
//         .replaceAll('&copy;', '©')
//         .replaceAll('&reg;', '®');
//
//     // Remove extra whitespace
//     text = text.replaceAll(RegExp(r'\n\s*\n'), '\n');
//     text = text.replaceAll(RegExp(r' +'), ' ').trim();
//
//     return text;
//   }
//
//   /// Print HTML as plain text (simple fallback)
//   static Future<bool> printHtmlAsText({required String htmlContent}) async {
//     if (!isPrinterConnected) {
//       log('[printer_service] Printer not connected');
//       return false;
//     }
//
//     log('[printer_service] Printing HTML as plain text...');
//     _isPrinting = true;
//     _refreshPrinterStatus();
//
//     try {
//       List<int> bytes = <int>[];
//
//       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
//
//       // Basic HTML to text conversion
//       String plainText = _htmlToPlainText(htmlContent);
//
//       log('[printer_service] Converted to text: ${plainText.length} characters');
//
//       // Split long text into lines
//       final lines = plainText.split('\n');
//       for (var line in lines) {
//         if (line.trim().isNotEmpty) {
//           bytes.addAll(generator.text(line.trim(), styles: PosStyles(align: PosAlign.left)));
//         }
//       }
//
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());
//
//       return await _print(data: bytes);
//     } catch (e) {
//       log('[printer_service] Error printing HTML as text: $e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//       return false;
//     }
//   }
//
//   /// Print formatted receipt
//   static Future<void> printFormattedReceipt({
//     required String title,
//     required List<Map<String, String>> items,
//     String? footer,
//   }) async {
//     _isPrinting = true;
//     _refreshPrinterStatus();
//
//     try {
//       List<int> bytes = <int>[];
//
//       final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
//
//       // Header
//       bytes.addAll(generator.text(
//         title,
//         styles: PosStyles(
//           align: PosAlign.center,
//           bold: true,
//           height: PosTextSize.size2,
//           width: PosTextSize.size2,
//         ),
//       ));
//       bytes.addAll(generator.feed(1));
//       bytes.addAll(generator.hr());
//
//       // Items
//       for (var item in items) {
//         String itemName = item['name'] ?? '';
//         String itemValue = item['value'] ?? '';
//
//         bytes.addAll(generator.row([
//           PosColumn(text: itemName, width: 6),
//           PosColumn(text: itemValue, width: 6, styles: PosStyles(align: PosAlign.right)),
//         ]));
//       }
//
//       bytes.addAll(generator.hr());
//
//       // Footer
//       if (footer != null && footer.isNotEmpty) {
//         bytes.addAll(generator.text(
//           footer,
//           styles: PosStyles(align: PosAlign.center),
//         ));
//       }
//
//       bytes.addAll(generator.feed(2));
//       bytes.addAll(generator.cut());
//
//       await _print(data: bytes);
//     } catch (e) {
//       log('[printer_service] Error printing receipt: $e');
//       _isPrinting = false;
//       _refreshPrinterStatus();
//     }
//   }
// }
//
// class PrinterStatus {
//   static const connecting = 'Connecting';
//   static const disconnecting = 'Disconnecting';
//   static const connected = 'Connected';
//   static const notFound = 'Printer not found';
//   static const notConnected = 'Not connected';
//   static const scanning = 'Searching for printer';
//   static const printing = 'Printing';
// }



import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class PrinterService {
  // Changed from 'late' to nullable with default empty string
  static String printerName = '';
  static Completer<PrinterDevice>? _completer;
  static PrinterDevice? _printer;
  static USBStatus _currentUsbStatus = USBStatus.none;
  static StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  static final _printerManager = PrinterManager.instance;

  static final StreamController<String> _currentUsbStatusStreamController = StreamController();
  static Stream<String> currentUsbStringStatusStream = _currentUsbStatusStreamController.stream.asBroadcastStream();
  static late StreamSubscription<String> _currentUsbStatusStringSubscription;
  static bool _isPrinterAvailable = false;
  static bool _isScanning = false;
  static bool _isDisconnecting = false;
  static bool _isPrinting = false;

  static String get printerStatus => _convertUsbStatusToString();
  static bool get isPrinterConnected => _currentUsbStatus == USBStatus.connected;

  static void init() {
    log('[PrinterService] init called');
    _currentUsbStatusStringSubscription = currentUsbStringStatusStream.listen((event) { });

    _currentUsbStatusStringSubscription.onData((data) {
      // log('[printer_service] on data _currentUsbStatusStringSubscription');
      // log(data);
    });
  }

  static void dispose() {
    _currentUsbStatusStringSubscription.cancel();
    _currentUsbStatusStreamController.close();
  }

  static String _convertUsbStatusToString() {
    final usbStatus = _currentUsbStatus == USBStatus.connecting
        ? PrinterStatus.connecting
        : _currentUsbStatus == USBStatus.connected ? PrinterStatus.connected : PrinterStatus.notConnected;

    if (_isScanning) {
      return PrinterStatus.scanning;
    }
    else if (_isPrinting) {
      return PrinterStatus.printing;
    }
    else if (_isDisconnecting) {
      return PrinterStatus.disconnecting;
    }
    else if (usbStatus == PrinterStatus.notConnected) {
      return _isPrinterAvailable ? PrinterStatus.notConnected : PrinterStatus.notFound;
    }

    return usbStatus;
  }

  static Future<void> scan() async {
    if (_isScanning == false) {
      _isScanning = true;
      _refreshPrinterStatus();

      var defaultPrinterType = PrinterType.usb;

      _subscriptionUsbStatus = _printerManager.stateUSB.listen((status) {
        log('[PrinterService] on listen');
      });

      _subscriptionUsbStatus?.onData((status) {
        log('[PrinterService] on data');
        log(' ----------------- status usb $status ------------------ ');
        _currentUsbStatus = status;
        _refreshPrinterStatus();
      });

      log('[printer_service] Searching for printers...');
      _completer = Completer<PrinterDevice>();

      _printerManager.discovery(type: defaultPrinterType).listen((printer) {
        log('printer os: ${printer.operatingSystem}');
        log('printer name: ${printer.name}');
        log('printer address: ${printer.address}');
        log('printer vendor id: ${printer.vendorId}');
        log('printer product id: ${printer.productId}');
        if (!_completer!.isCompleted) {
          _completer!.complete(printer);
        }
      });

      try {
        printerName = '';
        _printer = await _completer!.future.timeout(const Duration(seconds: 1))
            .whenComplete(() {
          log('[printer_service] scanning timer done');
          _isScanning = false;
        });

        printerName = _printer?.name ?? '';
        _isPrinterAvailable = printerName.isNotEmpty;

        _refreshPrinterStatus();
      } on TimeoutException catch (e) {
        log('[printer_service@TimeoutException] Scan result: Printer not found\n$e');
        _isPrinterAvailable = false;
        printerName = '';
        _refreshPrinterStatus();
        return;
      }
    }
  }

  static Future<void> connect() async {
    if (printerStatus == PrinterStatus.notConnected && _printer != null) {
      try {
        await _printerManager.connect(
            type: PrinterType.usb,
            model: UsbPrinterInput(
                name: _printer!.name,
                productId: _printer!.productId,
                vendorId: _printer!.vendorId
            )
        )
            .timeout(const Duration(seconds: 1))
            .whenComplete(() => log('connecting done'));

      } on TimeoutException catch (e) {
        log("[printer_service] Failed to connect with printer\n$e");
        return;
      }
    }
  }

  static Future<void> disConnect() async {
    if (printerStatus == PrinterStatus.connected) {
      log('Disconnecting printer');
      _isDisconnecting = true;
      _refreshPrinterStatus();

      try {
        await _printerManager.disconnect(type: PrinterType.usb,)
            .timeout(const Duration(seconds: 1))
            .whenComplete(() {
          log('[printer_service] disconnect task done');
          _currentUsbStatus = USBStatus.none;
          _isDisconnecting = false;
          _refreshPrinterStatus();
        });
      } on TimeoutException catch (e) {
        log("Failed to disConnect printer\n$e");
        return;
      }
    }
  }

  static Future<void> testPrint() async {
    _isPrinting = true;
    _refreshPrinterStatus();

    List<int> bytes = <int>[];

    final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
    bytes.addAll(generator.text('Print test OK'));
    bytes.addAll(generator.cut());

    await _print(data: bytes);
  }

  static void _refreshPrinterStatus() {
    _currentUsbStatusStreamController.sink.add(_convertUsbStatusToString());
  }

  static Future<bool> _print({required List<int> data}) async {
    bool isPrintOk = true;

    try {
      isPrintOk = await _printerManager
          .send(type: PrinterType.usb, bytes: data)
          // .timeout(const Duration(milliseconds: 200))
          .whenComplete(() {
        _isPrinting = false;
        _refreshPrinterStatus();
      });
      log('[printer_service] Print completed: $isPrintOk');
    } on TimeoutException catch (e) {
      isPrintOk = false;
      log('[printer_service] Failed to print data - Timeout\n$e');
      _isPrinting = false;
      _refreshPrinterStatus();
    } catch (e) {
      isPrintOk = false;
      log('[printer_service] Failed to print data - Error: $e');
      _isPrinting = false;
      _refreshPrinterStatus();
    }

    return isPrintOk;
  }

  static Future<void> printInvoiceFromImage({required Uint8List? imageData}) async {
    if (imageData == null) return;

    _isPrinting = true;
    _refreshPrinterStatus();

    try {
      List<int> bytes = <int>[];

      final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
      final image = img.decodePng(imageData);

      if (image == null) {
        log('[printer_service] Failed to decode image');
        _isPrinting = false;
        _refreshPrinterStatus();
        return;
      }

      // Use imageRaster for better quality on thermal printers
      bytes.addAll(generator.imageRaster(image, align: PosAlign.center));
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      await _print(data: bytes);
    } catch (e) {
      log('[printer_service] Error printing image: $e');
      _isPrinting = false;
      _refreshPrinterStatus();
    }
  }

  /// Print HTML content by parsing and formatting
  static Future<bool> printHtmlContent({required String htmlContent}) async {
    if (!isPrinterConnected) {
      log('[printer_service] Printer not connected');
      return false;
    }

    log('[printer_service] Starting HTML print...');
    _isPrinting = true;
    _refreshPrinterStatus();

    try {
      List<int> bytes = <int>[];
      final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());

      // Parse HTML
      final document = html_parser.parse(htmlContent);

      log('[printer_service] HTML parsed, processing elements...');

      // Extract and format content
      await _parseHtmlToBytes(document, generator, bytes);

      // Add cut command
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      log('[printer_service] Generated ${bytes.length} bytes, sending to printer...');

      // Print
      return await _print(data: bytes);
    } catch (e) {
      log('[printer_service] Error printing HTML: $e');
      _isPrinting = false;
      _refreshPrinterStatus();
      return false;
    }
  }

  /// Parse HTML document and convert to ESC/POS bytes
  static Future<void> _parseHtmlToBytes(
      html_dom.Document document,
      Generator generator,
      List<int> bytes,
      ) async {
    // Try to find the main content
    final body = document.body;
    if (body == null) {
      log('[printer_service] No body found in HTML');
      return;
    }

    // Process each element
    _processHtmlElement(body, generator, bytes);
  }

  /// Process HTML element recursively
  static void _processHtmlElement(
      html_dom.Element element,
      Generator generator,
      List<int> bytes,
      {bool isBold = false, bool isCenter = false, int fontSize = 1}
      ) {
    for (var node in element.nodes) {
      if (node is html_dom.Element) {
        final tagName = node.localName?.toLowerCase() ?? '';

        switch (tagName) {
          case 'h1':
          case 'h2':
          case 'h3':
            final text = node.text.trim();
            if (text.isNotEmpty) {
              bytes.addAll(generator.text(
                text,
                styles: PosStyles(
                  align: PosAlign.center,
                  bold: true,
                  height: tagName == 'h1' ? PosTextSize.size2 : PosTextSize.size1,
                  width: tagName == 'h1' ? PosTextSize.size2 : PosTextSize.size1,
                ),
              ));
              bytes.addAll(generator.feed(1));
            }
            break;

          case 'p':
            final text = node.text.trim();
            if (text.isNotEmpty) {
              bytes.addAll(generator.text(
                text,
                styles: PosStyles(
                  align: isCenter ? PosAlign.center : PosAlign.left,
                  bold: isBold,
                ),
              ));
              bytes.addAll(generator.feed(1));
            }
            break;

          case 'strong':
          case 'b':
            _processHtmlElement(node, generator, bytes, isBold: true, isCenter: isCenter);
            break;

          case 'center':
            _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: true);
            break;

          case 'table':
            _processTable(node, generator, bytes);
            break;

          case 'br':
            bytes.addAll(generator.feed(1));
            break;

          case 'hr':
            bytes.addAll(generator.hr());
            break;

          case 'ul':
          case 'ol':
            _processList(node, generator, bytes, ordered: tagName == 'ol');
            break;

          case 'div':
          case 'span':
          case 'section':
          case 'article':
            _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: isCenter);
            break;

          default:
          // Process children for unknown tags
            _processHtmlElement(node, generator, bytes, isBold: isBold, isCenter: isCenter);
        }
      } else if (node is html_dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          bytes.addAll(generator.text(
            text,
            styles: PosStyles(
              align: isCenter ? PosAlign.center : PosAlign.left,
              bold: isBold,
            ),
          ));
        }
      }
    }
  }

  /// Process HTML table
  static void _processTable(
      html_dom.Element table,
      Generator generator,
      List<int> bytes,
      ) {
    final rows = table.querySelectorAll('tr');

    for (var row in rows) {
      final cells = row.querySelectorAll('td, th');
      final isHeader = row.querySelector('th') != null;

      if (cells.isEmpty) continue;

      if (cells.length == 2) {
        // Two column layout - perfect for receipts
        bytes.addAll(generator.row([
          PosColumn(
            text: cells[0].text.trim(),
            width: 6,
            styles: PosStyles(bold: isHeader),
          ),
          PosColumn(
            text: cells[1].text.trim(),
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: isHeader),
          ),
        ]));
      } else if (cells.length == 3) {
        // Three column layout
        bytes.addAll(generator.row([
          PosColumn(
            text: cells[0].text.trim(),
            width: 4,
            styles: PosStyles(bold: isHeader),
          ),
          PosColumn(
            text: cells[1].text.trim(),
            width: 4,
            styles: PosStyles(align: PosAlign.center, bold: isHeader),
          ),
          PosColumn(
            text: cells[2].text.trim(),
            width: 4,
            styles: PosStyles(align: PosAlign.right, bold: isHeader),
          ),
        ]));
      } else {
        // Single column or multiple columns - print each cell on new line
        for (var cell in cells) {
          final cellText = cell.text.trim();
          if (cellText.isNotEmpty) {
            bytes.addAll(generator.text(
              cellText,
              styles: PosStyles(bold: isHeader),
            ));
          }
        }
      }
    }

    bytes.addAll(generator.feed(1));
  }

  /// Process HTML list (ul/ol)
  static void _processList(
      html_dom.Element list,
      Generator generator,
      List<int> bytes,
      {bool ordered = false}
      ) {
    final items = list.querySelectorAll('li');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final text = item.text.trim();
      if (text.isNotEmpty) {
        final prefix = ordered ? '${i + 1}. ' : '• ';
        bytes.addAll(generator.text(
          '$prefix$text',
          styles: PosStyles(align: PosAlign.left),
        ));
      }
    }

    bytes.addAll(generator.feed(1));
  }

  /// Convert HTML to plain text (fallback method)
  static String _htmlToPlainText(String html) {
    // Remove script and style tags completely
    html = html.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    html = html.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');

    // Add line breaks for block elements
    html = html.replaceAll(RegExp(r'<br[^>]*>'), '\n');
    html = html.replaceAll(RegExp(r'</p>'), '\n');
    html = html.replaceAll(RegExp(r'</div>'), '\n');
    html = html.replaceAll(RegExp(r'</h[1-6]>'), '\n');
    html = html.replaceAll(RegExp(r'</tr>'), '\n');

    // Remove all HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®');

    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n');
    text = text.replaceAll(RegExp(r' +'), ' ').trim();

    return text;
  }

  /// Print HTML as plain text (simple fallback)
  static Future<bool> printHtmlAsText({required String htmlContent}) async {
    if (!isPrinterConnected) {
      log('[printer_service] Printer not connected');
      return false;
    }

    log('[printer_service] Printing HTML as plain text...');
    _isPrinting = true;
    _refreshPrinterStatus();

    try {
      List<int> bytes = <int>[];

      final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());

      // Basic HTML to text conversion
      String plainText = _htmlToPlainText(htmlContent);

      log('[printer_service] Converted to text: ${plainText.length} characters');

      // Split long text into lines
      final lines = plainText.split('\n');
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          bytes.addAll(generator.text(line.trim(), styles: PosStyles(align: PosAlign.left)));
        }
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return await _print(data: bytes);
    } catch (e) {
      log('[printer_service] Error printing HTML as text: $e');
      _isPrinting = false;
      _refreshPrinterStatus();
      return false;
    }
  }

  /// Print formatted receipt
  static Future<void> printFormattedReceipt({
    required String title,
    required List<Map<String, String>> items,
    String? footer,
  }) async {
    _isPrinting = true;
    _refreshPrinterStatus();

    try {
      List<int> bytes = <int>[];

      final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());

      // Header
      bytes.addAll(generator.text(
        title,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ));
      bytes.addAll(generator.feed(1));
      bytes.addAll(generator.hr());

      // Items
      for (var item in items) {
        String itemName = item['name'] ?? '';
        String itemValue = item['value'] ?? '';

        bytes.addAll(generator.row([
          PosColumn(text: itemName, width: 6),
          PosColumn(text: itemValue, width: 6, styles: PosStyles(align: PosAlign.right)),
        ]));
      }

      bytes.addAll(generator.hr());

      // Footer
      if (footer != null && footer.isNotEmpty) {
        bytes.addAll(generator.text(
          footer,
          styles: PosStyles(align: PosAlign.center),
        ));
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      await _print(data: bytes);
    } catch (e) {
      log('[printer_service] Error printing receipt: $e');
      _isPrinting = false;
      _refreshPrinterStatus();
    }
  }
  static Future<void> printImage(Uint8List imageData) async {
    // if (!isPrinterConnected) {
    //   log('[printer_service] Printer not connected');
    //   return;
    // }

    _isPrinting = true;
    _refreshPrinterStatus();

    try {
      final List<int> bytes = List<int>.empty(growable: true);
      final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());

      final decodedImage = img.decodeImage(imageData);
      if (decodedImage == null) {
        log('[printer_service] Failed to decode image');
        _isPrinting = false;
        _refreshPrinterStatus();
        return;
      }

      // ✅ Skip resizing if already correct width
      final int targetWidth = 576;
      final finalImage = (decodedImage.width == targetWidth)
          ? decodedImage
          : img.copyResize(decodedImage, width: targetWidth, interpolation: img.Interpolation.linear);

      bytes.addAll(generator.imageRaster(finalImage, align: PosAlign.center));
      bytes.addAll(generator.feed(1));  // ✅ Reduce feed from 2 to 1
      bytes.addAll(generator.cut());

      // ✅ Reduce timeout if your printer responds faster
      await _printerManager
          .send(type: PrinterType.usb, bytes: bytes);
          // .timeout(const Duration(seconds: 5));  // Reduced from 10 to 5

      log('[printer_service] Print completed successfully');
    } catch (e) {
      log('[printer_service] Print error: $e');
    } finally {
      _isPrinting = false;
      _refreshPrinterStatus();
    }
  }
  // static Future<void> printImage(Uint8List imageData) async {
  //   print("inside image print 1");
  //   if (!isPrinterConnected) {
  //     log('[printer_service] Printer not connected');
  //     return;
  //   }
  //
  //   _isPrinting = true;
  //   _refreshPrinterStatus();
  //
  //   try {
  //     print("inside image print 2");
  //
  //     final List<int> bytes = List<int>.empty(growable: true);
  //
  //     final generator = Generator(PaperSize.mm58, await CapabilityProfile.load());
  //
  //     final decodedImage = img.decodeImage(imageData);
  //     if (decodedImage == null) {
  //       log('[printer_service] Failed to decode image');
  //       print("inside image print failed to load");
  //       _isPrinting = false;
  //       _refreshPrinterStatus();
  //       return;
  //     }
  //
  //     // Optional scaling for proper width on POS80
  //     final resized = img.copyResize(decodedImage, width: 576);
  //
  //     // ✅ Ensure we use `List<int>.from` to make it growable
  //     bytes.addAll(List<int>.from(generator.imageRaster(resized, align: PosAlign.center)));
  //     bytes.addAll(List<int>.from(generator.feed(2)));
  //     bytes.addAll(List<int>.from(generator.cut()));
  //
  //     await _print(data: bytes);
  //   } catch (e, st) {
  //     log('[printer_service] Error printing image: $e');
  //     print("inside image print error");
  //     log('[printer_service] Stack: $st');
  //   } finally {
  //     _isPrinting = false;
  //     _refreshPrinterStatus();
  //   }
  // }
  //





}

class PrinterStatus {
  static const connecting = 'Connecting';
  static const disconnecting = 'Disconnecting';
  static const connected = 'Connected';
  static const notFound = 'Printer not found';
  static const notConnected = 'Not connected';
  static const scanning = 'Searching for printer';
  static const printing = 'Printing';
}