//
//
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:untitled/popupmessage.dart';
// import 'package:untitled/printservice.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image/image.dart' as img;
// import 'package:webcontent_converter/webcontent_converter.dart';
//
// /// Configuration for WebView Print functionality
// class WebViewPrintConfig {
//   final String initialUrl;
//   final String channelName;
//
//   final String printButtonId;
//   final List<String> interceptUrls;
//   final int printImageWidth;
//   final bool enableDebugLog;
//
//   const WebViewPrintConfig({
//     this.initialUrl = "https://prerelease.codexerp.com",
//     this.channelName = "printResponseHandler",
//
//     this.printButtonId = "print",
//     this.interceptUrls = const ["print.php"],
//     this.printImageWidth = 576,
//     this.enableDebugLog = true,
//
//   });
// }
//
// class WebViewPrintPage extends StatefulWidget {
//   final WebViewPrintConfig? config;
//
//
//   WebViewPrintPage({
//     Key? key,
//     this.config,
//   }) : super(key: key);
//
//   @override
//   State<WebViewPrintPage> createState() => _WebViewPrintPageState();
// }
//
// class _WebViewPrintPageState extends State<WebViewPrintPage> with WidgetsBindingObserver {
//   InAppWebViewController? _controller;
//   late WebViewPrintConfig _config;
//   final ScreenshotController _screenshotController = ScreenshotController();
//
//   // State variables
//   List<String> _jsMessages = [];
//   String _receivedHtml = "";
//   Uint8List? _screenshotBytes;
//   bool _isCapturing = false;
//   bool _showPreview = false;
//   bool _isConvertingPdf = false;
//   double _progress = 0;
//
//   // ✅ Timer for periodic printer scanning
//   Timer? _printerScanTimer;
//
//   // ✅ Flag to track if we're currently scanning
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _config = widget.config ?? const WebViewPrintConfig();
//
//     // ✅ Add observer for app lifecycle changes
//     WidgetsBinding.instance.addObserver(this);
//
//     _initializePrinter();
//
//     // ✅ Start periodic printer scanning
//     // _startPeriodicPrinterScan();
//   }
//
//   /// Initialize printer service
//   Future<void> _initializePrinter() async {
//     PrinterService.init();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _scanForPrinters();
//     });
//   }
//
//   // ✅ Start periodic printer scanning
//   void _startPeriodicPrinterScan() {
//     // Scan every 3 seconds for new printers
//     _printerScanTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       if (!_isScanning && mounted) {
//         await _scanForPrinters();
//       }
//     });
//   }
//
//   // ✅ Scan for printers with debouncing
//   Future<void> _scanForPrinters() async {
//     if (_isScanning) return;
//
//     _isScanning = true;
//
//     try {
//       // Only scan if not already connected
//       if (!PrinterService.isPrinterConnected) {
//         if (_config.enableDebugLog) {
//           print("🔍 Scanning for USB printers...");
//         }
//
//         await PrinterService.scan();
//
//         // If printer found and not connected, try to connect
//         if (PrinterService.printerName.isNotEmpty &&
//             !PrinterService.isPrinterConnected) {
//           if (_config.enableDebugLog) {
//             print("🔌 Printer detected: ${PrinterService.printerName}. Attempting to connect...");
//           }
//
//           await PrinterService.connect();
//
//           if (PrinterService.isPrinterConnected) {
//             if (_config.enableDebugLog) {
//               print("✅ Printer connected successfully!");
//             }
//
//             // Show success message
//             if (mounted) {
//               setState(() {
//                 _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ✅ Printer connected: ${PrinterService.printerName}");
//               });
//             }
//           }
//         }
//       } else {
//         // Verify connection is still active
//         if (_config.enableDebugLog) {
//           print("✅ Printer already connected: ${PrinterService.printerName}");
//         }
//       }
//     } catch (e) {
//       if (_config.enableDebugLog) {
//         print("❌ Error scanning for printers: $e");
//       }
//     } finally {
//       _isScanning = false;
//     }
//   }
//
//   // ✅ Override lifecycle methods to handle app state changes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//
//     switch (state) {
//       case AppLifecycleState.resumed:
//       // App came to foreground - scan for printers
//         if (_config.enableDebugLog) {
//           print("📱 App resumed - scanning for printers...");
//         }
//         _scanForPrinters();
//
//         // Restart periodic scanning if it was stopped
//         // if (_printerScanTimer == null || !_printerScanTimer!.isActive) {
//         //   _startPeriodicPrinterScan();
//         // }
//         break;
//
//       case AppLifecycleState.paused:
//       // App went to background - can optionally stop scanning to save resources
//         if (_config.enableDebugLog) {
//           print("📱 App paused");
//         }
//         break;
//
//       default:
//         break;
//     }
//   }
//
//   // / Handle messages from JavaScript
//   void _handleJavaScriptMessage(String message) {
//     if (_config.enableDebugLog) {
//       print("=======message length ${message.length}");
//       print("📩 Message from JS: "
//           "${message.substring(0, message.length > 200 ? 200 : message.length)}...");
//     }
//
//     setState(() {
//       _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - $message");
//       if (_jsMessages.length > 50) {
//         _jsMessages.removeAt(0);
//       }
//     });
//
//     if (message.contains("<html") ||
//         message.contains("<!DOCTYPE") ||
//         message.contains("<body") ||
//         message.contains("</html>")) {
//       if (_config.enableDebugLog) {
//         print("✅ HTML content detected - Starting print...$message");
//       }
//       _receivedHtml = message;
//       print("received message is $_receivedHtml");
//
//       setState(() {
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - HTML received (${message.length} chars) - Printing...");
//       });
//       _printHtmlAsImage();
//     }
//   }
//
//   /// Inject JavaScript to listen for print button clicks
//   Future<void> _injectJavaScriptListener() async {
//     if (_controller == null) return;
//
//     final jsCode = """
//       (function() {
//         console.log('🔧 Injecting print listener for InAppWebView...');
//         var printButton = document.getElementById('${_config.printButtonId}')
//                       || document.querySelector('input[name="print"]')
//                       || document.querySelector('button[name="print"]');
//
//         console.log('Print button found:', printButton);
//
//         // Polyfill for older browsers
//         if (!String.prototype.includes) {
//           String.prototype.includes = function(search, start) {
//             if (typeof start !== 'number') {
//               start = 0;
//             }
//             if (start + search.length > this.length) {
//               return false;
//             } else {
//               return this.indexOf(search, start) !== -1;
//             }
//           };
//         }
//
//         if (printButton) {
//           // Remove existing listeners by cloning
//           var newButton = printButton.cloneNode(true);
//           printButton.parentNode.replaceChild(newButton, printButton);
//
//           newButton.addEventListener('click', function(e) {
//             e.preventDefault();
//             console.log('🖨️ Print button clicked!');
//
//             try {
//               // Get the HTML content to print
//               var htmlContent = document.documentElement.outerHTML;
//               console.log('HTML length:', htmlContent.length);
//
//               // Send HTML content to Flutter
//               if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
//                 window.flutter_inappwebview.callHandler('${_config.channelName}', htmlContent);
//                 console.log('✅ HTML sent to Flutter via handler');
//               }else {
//                 console.error('❌ flutter_inappwebview.callHandler not available!');
//               }
//             } catch (error) {
//               console.error('❌ Error sending HTML:', error);
//             }
//           });
//
//           console.log('✅ Print listener attached successfully');
//
//           // Confirm listener attachment
//           if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
//             window.flutter_inappwebview.callHandler('${_config.channelName}', 'Print listener attached');
//           }
//         } else {
//           console.warn('⚠️ Print button with id "${_config.printButtonId}" not found');
//           if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
//             window.flutter_inappwebview.callHandler('${_config.channelName}', 'Print button not found');
//           }
//         }
//       })();
//     """;
//
//     try {
//       await _controller?.evaluateJavascript(source: jsCode);
//       if (_config.enableDebugLog) {
//         print("✅ JavaScript listener injected");
//       }
//     } catch (e) {
//       print("❌ Error injecting JavaScript: $e");
//       Future.delayed(const Duration(milliseconds: 100), () {
//         if (mounted && _controller != null) {
//           print("🔄 Retrying JavaScript injection...");
//           _controller?.evaluateJavascript(source: jsCode);
//         }
//       });
//     }
//   }
//
//   /// Convert HTML to Uint8List image
//   Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
//     print("html to be printed $htmlContent");
//
//     try {
//       final styledHtml = """
// <!DOCTYPE html>
// <html>
// <head>
//   <meta charset="UTF-8">
//   <style>
//     body {
//       margin: 0;
//       padding: 10px;
//       font-family: Arial, sans-serif;
//       font-size: 12px;
//       background: white;
//       color: black;
//     }
//     table {
//       width: 100%;
//       border-collapse: collapse;
//       margin: 0;
//       padding: 0;
//     }
//     td {
//       padding: 2px 4px;
//       vertical-align: top;
//     }
//     b {
//       font-weight: bold;
//     }
//     @media print {
//       body { margin: 0; padding: 5px; }
//     }
//   </style>
// </head>
// <body>
// $htmlContent
// </body>
// </html>
// """;
//
//       final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
//         content: htmlContent,
//         duration: 500,
//         // 2000,
//         scale:2
//         // 2,
//       );
//
//       return imageBytes;
//     } catch (e) {
//       print('❌ Error converting HTML to Uint8List: $e');
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
//         interpolation: img.Interpolation.linear,
//         // img.Interpolation.cubic,
//       );
//       return Uint8List.fromList(img.encodePng(resized));
//     }
//
//     return Uint8List.fromList(img.encodePng(image));
//   }
//
//   /// Print HTML as image to thermal printer
//   Future<void> _printHtmlAsImage() async {
//     if (_config.enableDebugLog) {
//       print("🖨️ Starting HTML to image print...");
//     }
//
//     if (!mounted) return;
//
//     // ✅ Check printer connection and try to reconnect if needed
//     if (!PrinterService.isPrinterConnected) {
//       setState(() {
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ⚠️ Printer not connected. Attempting to connect...");
//       });
//
//       // Try to scan and connect
//       await _scanForPrinters();
//
//       // Check again after scan attempt
//       if (!PrinterService.isPrinterConnected) {
//         setState(() {
//           _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ❌ Error: Printer not connected");
//         });
//         _showError("Please turn on the printer and wait for it to connect.");
//         return;
//       }
//     }
//
//     setState(() {
//       _isCapturing = true;
//       _isConvertingPdf = true;
//       _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Converting HTML to image...");
//     });
//     try {
//       final Uint8List? bytes = await convertHtmlToUint8List(_receivedHtml);
//       if (bytes == null) {
//         throw Exception('Failed to convert HTML to image');
//       }
//       if (_config.enableDebugLog) {
//         print("aaaaaaaaaaa 1");
//         print("✅ HTML converted to image (${bytes.length} bytes)");
//       }
//       setState(() {
//         _isConvertingPdf = false;
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Optimizing for thermal printer...");
//       });
//       final resizedBytes = await resizeForThermal(bytes);
//       if (_config.enableDebugLog) {
//         print("✅ Image optimized (${resizedBytes.length} bytes)");
//       }
//       setState(() {
//         _screenshotBytes = resizedBytes;
//         _showPreview = true;
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Sending to printer...");
//       });
//       await PrinterService.printImage(resizedBytes);
//       setState(() {
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ✅ Print completed successfully");
//       });
//       if (_config.enableDebugLog)
//       {
//         print("✅ Print job completed successfully ${DateTime.now()}");
//       }
//     } catch (e) {
//       setState(() {
//         _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ❌ Print failed: $e");
//       });
//       print('❌ Print error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isCapturing = false;
//           _isConvertingPdf = false;
//         });
//       }
//     }
//   }
//   /// Capture screenshot and print
//   Future<void> _captureAndPrint() async {
//     if (_config.enableDebugLog) {
//       print("📸 Starting screenshot capture...");
//     }
//     if (!mounted) return;
//     if (!PrinterService.isPrinterConnected) {
//       _showError("Please connect your USB printer first");
//       return;
//     }
//     setState(() => _isCapturing = true);
//     try {
//       final Uint8List? captured = await _screenshotController.capture();
//       if (captured == null) {
//         _showError("Failed to capture screenshot");
//         return;
//       }
//       final printable = await resizeForThermal(captured);
//       setState(() {
//         _screenshotBytes = printable;
//         _showPreview = true;
//       });
//       await PrinterService.printImage(printable);
//       _showSuccess("✅ Screenshot printed successfully");
//     } catch (e) {
//       _showError("Error: ${e.toString()}");
//       print("❌ Screenshot error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isCapturing = false);
//       }
//     }
//   }
//   void _showError(String message) {
//     if (mounted) {
//       PopUpMessage.showPopup(
//         context: context,
//         title: "Error",
//         content: message,
//       );
//     }
//   }
//   void _showSuccess(String message) {
//     if (mounted) {
//       PopUpMessage.showPopup(
//         context: context,
//         title: "Info",
//         content: message,
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('IQUAD INNOVATIONS'),
//         actions: [IconButton(onPressed: (){
//           _scanForPrinters();
//         }, icon: Icon(Icons.print)),
//           // ✅ Manual scan button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () async {
//               await _scanForPrinters();
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Scanning for printers...'),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//               }
//             },
//             tooltip: 'Scan for Printers',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildPrinterStatusSection(),
//
//           if (_progress > 0 && _progress < 1)
//             LinearProgressIndicator(
//               value: _progress,
//               backgroundColor: Colors.grey[200],
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
//             ),
//
//           Expanded(child: _buildWebViewSection()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPrinterStatusSection() {
//     return StreamBuilder(
//       stream: PrinterService.currentUsbStringStatusStream,
//       builder: (context, snapshot) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           child: ListTile(
//             leading: Icon(
//               PrinterService.isPrinterConnected ? Icons.print : Icons.print_disabled,
//               color: PrinterService.isPrinterConnected ? Colors.green : Colors.grey,
//             ),
//             title: Text(
//               "Printer: ${PrinterService.printerName.isNotEmpty ? PrinterService.printerName : 'Searching...'}",
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Status: ${PrinterService.printerStatus}"),
//                 // ✅ Show scanning indicator
//                 if (_isScanning)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 4),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 12,
//                           height: 12,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           "Scanning for devices...",
//                           style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//             trailing: Switch(
//               value: PrinterService.isPrinterConnected,
//               onChanged: (val) async {
//                 if (val) {
//                   await _scanForPrinters();
//                 } else {
//                   await PrinterService.disConnect();
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildWebViewSection() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Screenshot(
//           controller: _screenshotController,
//           child: InAppWebView(
//
//             initialUrlRequest: URLRequest(
//               url: WebUri(_config.initialUrl),
//             ),
//             initialSettings: InAppWebViewSettings(
//               javaScriptEnabled: true,
//               domStorageEnabled: true,
//               databaseEnabled: true,
//               useHybridComposition: true,
//               allowFileAccessFromFileURLs: true,
//               allowUniversalAccessFromFileURLs: true,
//               mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               cacheEnabled: true,
//               clearCache: false,
//               thirdPartyCookiesEnabled: true,
//               supportZoom: false,
//               builtInZoomControls: false,
//               displayZoomControls: false,
//               useWideViewPort: true,
//               loadWithOverviewMode: true,
//               isInspectable: _config.enableDebugLog,
//             ),
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               _controller?.addJavaScriptHandler(
//                 handlerName: _config.channelName,
//                 callback: (args) {
//                   if (args.isNotEmpty) {
//                     _handleJavaScriptMessage(args[0].toString());
//                   }
//                 },
//               );
//
//               if (_config.enableDebugLog) {
//                 print("✅ InAppWebView created and handler registered");
//               }
//             },
//             onLoadStart: (controller, url) {
//               if (_config.enableDebugLog) {
//                 print("🔗 Loading started: $url");
//               }
//               setState(() {
//                 _progress = 0;
//               });
//             },
//             onLoadStop: (controller, url) async {
//               if (_config.enableDebugLog) {
//                 print("✅ Page loaded: $url");
//               }
//               setState(() {
//                 _progress = 1;
//               });
//
//               await Future.delayed(const Duration(milliseconds: 500));
//             },
//             onProgressChanged: (controller, progress) {
//               setState(() {
//                 _progress = progress / 100;
//               });
//             },
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final url = navigationAction.request.url.toString();
//               if (_config.enableDebugLog) {
//                 print("🔗 Navigation request: $url");
//               }
//
//               for (String interceptUrl in _config.interceptUrls) {
//                 if (url.contains(interceptUrl)) {
//                   if (_config.enableDebugLog) {
//                     print("✅ Intercepted: $interceptUrl");
//                   }
//
//                   Future.delayed(const Duration(milliseconds: 500), () {
//                     _injectJavaScriptListener();
//                   });
//
//                   return NavigationActionPolicy.CANCEL;
//                 }
//               }
//               return NavigationActionPolicy.ALLOW;
//             },
//             onConsoleMessage: (controller, consoleMessage) {
//               if (_config.enableDebugLog) {
//                 print("🖥️ Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
//               }
//             },
//             onReceivedError: (controller, request, error) {
//               if (_config.enableDebugLog) {
//                 print("❌ WebView Error:");
//                 print("   Type: ${error.type}");
//                 print("   Description: ${error.description}");
//                 print("   URL: ${request.url}");
//               }
//
//               if (mounted) {
//                 _showError("Network Error: ${error.description}");
//               }
//             },
//             onReceivedHttpError: (controller, request, errorResponse) {
//               if (_config.enableDebugLog) {
//                 print("❌ HTTP Error:");
//                 print("   Status Code: ${errorResponse.statusCode}");
//                 print("   URL: ${request.url}");
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // ✅ Clean up resources
//     _printerScanTimer?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     PrinterService.dispose();
//     super.dispose();
//   }
// }
//
//
//
//
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:untitled/popupmessage.dart';
import 'package:untitled/printservice.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:webcontent_converter/webcontent_converter.dart';

/// Configuration for WebView Print functionality
class WebViewPrintConfig {
  final String initialUrl;
  final String channelName;
  final String printButtonId;
  final List<String> interceptUrls;
  final int printImageWidth;
  final bool enableDebugLog;

  const WebViewPrintConfig({
    this.initialUrl = "https://prerelease.codexerp.com",
    this.channelName = "printResponseHandler",
    this.printButtonId = "print",
    this.interceptUrls = const ["print.php"],
    this.printImageWidth = 576,
    this.enableDebugLog = true,
  });
}

class WebViewPrintPage extends StatefulWidget {
  final WebViewPrintConfig? config;

  const WebViewPrintPage({
    Key? key,
    this.config,
  }) : super(key: key);

  @override
  State<WebViewPrintPage> createState() => _WebViewPrintPageState();
}

class _WebViewPrintPageState extends State<WebViewPrintPage> with WidgetsBindingObserver {
  InAppWebViewController? _controller;
  late WebViewPrintConfig _config;
  final ScreenshotController _screenshotController = ScreenshotController();

  // State variables
  List<String> _jsMessages = [];
  String _receivedHtml = "";
  Uint8List? _screenshotBytes;
  bool _isCapturing = false;
  bool _showPreview = false;
  bool _isConvertingPdf = false;
  double _progress = 0;

  Timer? _printerScanTimer;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? const WebViewPrintConfig();
    WidgetsBinding.instance.addObserver(this);
    _initializePrinter();
  }

  /// Initialize printer service
  Future<void> _initializePrinter() async {
    PrinterService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scanForPrinters();
    });
  }

  /// Scan for printers with debouncing
  Future<void> _scanForPrinters() async {
    if (_isScanning) return;

    _isScanning = true;

    try {
      if (!PrinterService.isPrinterConnected) {
        if (_config.enableDebugLog) {
          print("🔍 Scanning for USB printers...");
        }

        await PrinterService.scan();

        if (PrinterService.printerName.isNotEmpty &&
            !PrinterService.isPrinterConnected) {
          if (_config.enableDebugLog) {
            print("🔌 Printer detected: ${PrinterService.printerName}. Attempting to connect...");
          }

          await PrinterService.connect();

          if (PrinterService.isPrinterConnected) {
            if (_config.enableDebugLog) {
              print("✅ Printer connected successfully!");
            }

            if (mounted) {
              setState(() {
                _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ✅ Printer connected: ${PrinterService.printerName}");
              });
            }
          }
        }
      } else {
        if (_config.enableDebugLog) {
          print("✅ Printer already connected: ${PrinterService.printerName}");
        }
      }
    } catch (e) {
      if (_config.enableDebugLog) {
        print("❌ Error scanning for printers: $e");
      }
    } finally {
      _isScanning = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (_config.enableDebugLog) {
          print("📱 App resumed - scanning for printers...");
        }
        _scanForPrinters();
        break;

      case AppLifecycleState.paused:
        if (_config.enableDebugLog) {
          print("📱 App paused");
        }
        break;

      default:
        break;
    }
  }

  /// Handle messages from JavaScript
  void _handleJavaScriptMessage(String message) {
    if (_config.enableDebugLog) {
      print("=======message length ${message.length}");
      print("📩${DateTime.now()} Message from JS:  "
          "${message.substring(0, message.length > 200 ? 200 : message.length)}...");
    }

    setState(() {
      _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - $message");
      if (_jsMessages.length > 50) {
        _jsMessages.removeAt(0);
      }
    });

    if (message.contains("<html") ||
        message.contains("<!DOCTYPE") ||
        message.contains("<body") ||
        message.contains("</html>")) {
      if (_config.enableDebugLog) {
        // print("✅ HTML content detected - Starting print... @${DateTime.now()}");
      }
      _receivedHtml = message;

      // setState(() {
      //   _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - HTML received (${message.length} chars) - Printing... @${DateTime.now()}");
      // });
      _printHtmlAsImage();
    }
  }

  /// Inject JavaScript to listen for print button clicks
  Future<void> _injectJavaScriptListener() async {
    print("inside javascript injection @${DateTime.now()}");
    if (_controller == null) return;

    final jsCode = """
      (function() {
        console.log('🔧 Injecting print listener for InAppWebView...');
        var printButton = document.getElementById('${_config.printButtonId}') 
                      || document.querySelector('input[name="print"]')
                      || document.querySelector('button[name="print"]');
    
        console.log('Print button found:', printButton);

        if (!String.prototype.includes) {
          String.prototype.includes = function(search, start) {
            if (typeof start !== 'number') {
              start = 0;
            }
            if (start + search.length > this.length) {
              return false;
            } else {
              return this.indexOf(search, start) !== -1;
            }
          };
        }

        if (printButton) {
          var newButton = printButton.cloneNode(true);
          printButton.parentNode.replaceChild(newButton, printButton);

          newButton.addEventListener('click', function(e) {
            e.preventDefault();
            console.log('🖨️ Print button clicked! ${DateTime.now()}');

            try {
              var htmlContent = document.documentElement.outerHTML;
              console.log('HTML length:', htmlContent.length);

              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('${_config.channelName}', htmlContent);
                console.log('✅ HTML sent to Flutter via handler');
              } else {
                console.error('❌ flutter_inappwebview.callHandler not available!');
              }
            } catch (error) {
              console.error('❌ Error sending HTML:', error);
            }
          });

          console.log('✅ Print listener attached successfully');

          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('${_config.channelName}', 'Print listener attached');
          }
        } else {
          console.warn('⚠️ Print button with id "${_config.printButtonId}" not found');
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('${_config.channelName}', 'Print button not found');
          }
        }
      })();
    """;

    try {
      await _controller?.evaluateJavascript(source: jsCode);
      if (_config.enableDebugLog) {
        print("✅@${DateTime.now()} JavaScript listener injected");
      }
    } catch (e) {
      print("❌ Error injecting JavaScript: $e");
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _controller != null) {
          print("🔄 Retrying JavaScript injection...");
          _controller?.evaluateJavascript(source: jsCode);
        }
      });
    }
  }



  /// Convert HTML to Uint8List image - OPTIMIZED
  Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
    print("🔄 Converting HTML to image...start @${DateTime.now()}");
    if (_config.enableDebugLog) {

    }

    try {
      final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
        content: htmlContent,
        duration: 100, // ✅ Optimized from 500ms
        scale: 1,    // ✅ Optimized from 2
      );
      print("🔄 Converting HTML to image...end @${DateTime.now()}");
      return imageBytes;
    } catch (e) {
      print('❌ Error converting HTML to Uint8List: $e');
      return null;
    }
  }

  /// Resize image for thermal printer - OPTIMIZED
  Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
    print("Resizing strat ${DateTime.now()}");
    final image = img.decodeImage(htmlBytes);
    if (image == null) {
      throw Exception("Failed to decode HTML image");
    }

    const int targetWidth = 576;

    // ✅ Skip resizing if already close to target
    if ((image.width - targetWidth).abs() < 50) {
      if (_config.enableDebugLog) {
        print("✅ Image width ${image.width} is close to target, skipping resize");
      }
      return htmlBytes;
    }

    if (image.width != targetWidth) {
      final resized = img.copyResize(
        image,
        width: targetWidth,
        interpolation: img.Interpolation.nearest,
      );
      return Uint8List.fromList(img.encodePng(resized));
    }

    return htmlBytes;

  }

  /// Print HTML as image to thermal printer - OPTIMIZED
  Future<void> _printHtmlAsImage() async {
    print("starts printing .....");
    if (_config.enableDebugLog) {
      print("🖨️ Starting HTML to image print...@${DateTime.now()}");
    }

    if (!mounted) return;

    // Check printer connection
    if (!PrinterService.isPrinterConnected) {
      if (mounted) {
        setState(() {
          _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ⚠️ Printer not connected. Attempting to connect...");
        });
      }

      await _scanForPrinters();

      if (!PrinterService.isPrinterConnected) {
        if (mounted) {
          setState(() {
            _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ❌ Error: Printer not connected");
          });
        }
        _showError("Please turn on the printer and wait for it to connect.");
        return;
      }
    }

    // ✅ Single setState before starting
    if (mounted) {
      setState(() {
        _isCapturing = true;
        _isConvertingPdf = true;
      });
    }

    try {
      final Uint8List? bytes = await convertHtmlToUint8List(_receivedHtml);

      if (bytes == null) {
        throw Exception('Failed to convert HTML to image');
      }

      // if (_config.enableDebugLog) {
      //   print("✅ HTML converted to image (${bytes.length} bytes)   @${DateTime.now()}");
      // }

      // final resizedBytes = await resizeForThermal(bytes);

      // if (_config.enableDebugLog) {
      //   // print("✅ Image optimized (${resizedBytes.length} bytes)");
      // }

      // ✅ Update UI once before printing
      if (mounted) {
        setState(() {
          _screenshotBytes = bytes;
          _showPreview = true;
          _isConvertingPdf = false;
        });
      }

      // Print
      await PrinterService.printImage(bytes);



    } catch (e) {
      if (mounted) {
        setState(() {
          _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ❌ Print failed: $e");
        });
      }
      print('❌ Print error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _isConvertingPdf = false;
        });
      }
    }
  }


  void _showError(String message) {
    if (mounted) {
      PopUpMessage.showPopup(
        context: context,
        title: "Error",
        content: message,
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      PopUpMessage.showPopup(
        context: context,
        title: "Info",
        content: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IQUAD INNOVATIONS'),
        actions: [
          // ✅ SAMPLE PRINT BUTTON
          // IconButton(
          //   onPressed: () {
          //     _printSampleHTML();
          //   },
          //   icon: const Icon(Icons.receipt_long),
          //   tooltip: 'Print Sample Receipt',
          // ),
          IconButton(
            onPressed: () {
              _scanForPrinters();
            },
            icon: const Icon(Icons.print),
            tooltip: 'Scan Printer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _scanForPrinters();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scanning for printers...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Refresh Printers',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPrinterStatusSection(),

          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          Expanded(child: _buildWebViewSection()),
        ],
      ),
    );
  }

  Widget _buildPrinterStatusSection() {
    return StreamBuilder(
      stream: PrinterService.currentUsbStringStatusStream,
      builder: (context, snapshot) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(
              PrinterService.isPrinterConnected ? Icons.print : Icons.print_disabled,
              color: PrinterService.isPrinterConnected ? Colors.green : Colors.grey,
            ),
            title: Text(
              "Printer: ${PrinterService.printerName.isNotEmpty ? PrinterService.printerName : 'Searching...'}",
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${PrinterService.printerStatus}"),
                if (_isScanning)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Scanning for devices...",
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Switch(
              value: PrinterService.isPrinterConnected,
              onChanged: (val) async {
                if (val) {
                  await _scanForPrinters();
                } else {
                  await PrinterService.disConnect();
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Screenshot(
          controller: _screenshotController,
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_config.initialUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              useHybridComposition: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              cacheEnabled: true,
              clearCache: false,
              thirdPartyCookiesEnabled: true,
              supportZoom: false,
              builtInZoomControls: false,
              displayZoomControls: false,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              isInspectable: _config.enableDebugLog,
            ),
            onWebViewCreated: (controller) async {
              _controller = controller;
              _controller?.addJavaScriptHandler(
                handlerName: _config.channelName,
                callback: (args) {
                  if (args.isNotEmpty) {
                    _handleJavaScriptMessage(args[0].toString());
                  }
                },
              );

              if (_config.enableDebugLog) {
                print("✅ InAppWebView created and handler registered");
              }
            },
            onLoadStart: (controller, url) {
              if (_config.enableDebugLog) {
                print("🔗  @${DateTime.now()}Loading started: $url");
              }
              setState(() {
                _progress = 0;
              });
            },
            onLoadStop: (controller, url) async {
              if (_config.enableDebugLog) {

                print("✅@${DateTime.now()} Page loaded: $url");
              }
              setState(() {
                _progress = 1;
              });

              // await Future.delayed(const Duration(milliseconds: 500));
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              if (_config.enableDebugLog) {
                print("🔗 Navigation request: $url");
              }

              for (String interceptUrl in _config.interceptUrls) {
                if (url.contains(interceptUrl)) {
                  if (_config.enableDebugLog) {
                    print("✅@${DateTime.now()} Intercepted: $interceptUrl");
                  }
                  // _injectJavaScriptListener();

                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (_config.enableDebugLog) {

                // print("🖥️ Console @${DateTime.now()}[${consoleMessage.messageLevel}]: ${consoleMessage.message}");
              }
            },
            onReceivedError: (controller, request, error) {
              if (_config.enableDebugLog) {
                // print("❌ WebView Error:");
                // print("   Type: ${error.type}");
                // print("   Description: ${error.description}");
                // print("   URL: ${request.url}");
              }

              if (mounted) {
                _showError("Network Error: ${error.description}");
              }
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              if (_config.enableDebugLog) {
                // print("❌ HTTP Error:");
                // print("   Status Code: ${errorResponse.statusCode}");
                // print("   URL: ${request.url}");
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _printerScanTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    PrinterService.dispose();
    super.dispose();
  }
}