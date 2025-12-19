//
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:untitled/popupmessage.dart';
// import 'package:untitled/printservice.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image/image.dart' as img;
// import 'package:webcontent_converter/webcontent_converter.dart';
// // import 'package:blue_thermal_printer/blue_thermal_printer.dart';
//
// /// Configuration for WebView Print functionality
// class WebViewPrintConfig {
//   final String initialUrl;
//   final String channelName;
//   final String printButtonId;
//   final List<String> interceptUrls;
//   final int printImageWidth;
//   final bool enableDebugLog;
//
//   const WebViewPrintConfig({
//     this.initialUrl = "https://prerelease.codexerp.com",
//     // this.channelName = "FlutterChannel",
//     this.channelName = "printResponseHandler",
//
//     this.printButtonId = "print",
//     this.interceptUrls = const ["print.php"],
//     this.printImageWidth = 576,
//     this.enableDebugLog = true,
//   });
// }
//
// class WebViewPrintPage extends StatefulWidget {
//
//   final WebViewPrintConfig? config;
//
//    WebViewPrintPage({
//     Key? key,
//     this.config,
//   }) : super(key: key);
//
//   @override
//   State<WebViewPrintPage> createState() => _WebViewPrintPageState();
// }
//
// class _WebViewPrintPageState extends State<WebViewPrintPage> {
//   //for bt dev{
//   // bool _connected = false;
//   // BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//   // List<BluetoothDevice> _devices = [];
//   // BluetoothDevice? _selectedDevice;
//   //}
//
//
//   InAppWebViewController? _controller;
//   late WebViewPrintConfig _config;
//   final ScreenshotController _screenshotController = ScreenshotController();
//
//   // State variables
//   String _serverResponse = "";
//   String _receivedHtml = "";
//   Uint8List? _screenshotBytes;
//   bool _isCapturing = false;
//   bool _showPreview = false;
//   bool _isConvertingPdf = false;
//   double _progress = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _config = widget.config ?? const WebViewPrintConfig();
//     _initializePrinter();
//     // _initializeBluetooth();
//   }
//
//
//   /// Initialize printer service
//   Future<void> _initializePrinter() async {
//     PrinterService.init();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await PrinterService.scan();
//     });
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
//     // Update response box with message
//     setState(() {
//       _serverResponse = message;
//     });
//
//     // Check if it's HTML content - if yes, print silently
//     if (message.contains("<html") ||
//         message.contains("<!DOCTYPE") ||
//         message.contains("<body")||
//         message.contains("</html>")) {
//       if (_config.enableDebugLog) {
//         print("✅ HTML content detected - Starting print...$message");
//       }
//       _receivedHtml = message;
//       print("received message is $_receivedHtml");
//       // Update status in response box
//       setState(() {
//         _serverResponse = "HTML received (${message.length} chars) - Printing...";
//       });
//       _printHtmlAsImage();
//     }
//     // For non-HTML messages, just show in response box
//     else {
//       if (_config.enableDebugLog) {
//         print("📝 Message: $message");
//       }
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
//     console.log('Print button found:', printButton);
//
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
//
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
//               } else {
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
//       // Retry after delay
//       Future.delayed(const Duration(milliseconds: 1000), () {
//         if (mounted && _controller != null) {
//           print("🔄 Retrying JavaScript injection...");
//           _controller?.evaluateJavascript(source: jsCode);
//         }
//       });
//     }
//   }
//
//
//   /// Convert HTML to Uint8List image
//   Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
//     print("html to be printed $htmlContent");
//     // String hht="";
//     final String htmlContentss = '''
//
// <!DOCTYPE html>
// <html lang="en">
// <head>
//     <meta charset="UTF-8" />
//     <meta name="viewport" content="width=576, initial-scale=1.0" />
//     <title>Sample HTML Page</title>
//     <style>
//         body {
//           font-family: Arial, sans-serif;
//           margin: 20px;
//           padding: 0;
//           background-color: #ffffff;
//           color: #000000;
//           width: 536px;
//           font-size: 18px;
//         }
//         header {
//           background-color: #007bff;
//           color: white;
//           padding: 15px;
//           border-radius: 8px;
//           text-align: center;
//           margin-bottom: 15px;
//         }
//         h1 {
//           font-size: 28px;
//           margin: 10px 0;
//         }
//         h2 {
//           font-size: 24px;
//           margin: 10px 0;
//         }
//         section {
//           margin-top: 15px;
//           margin-bottom: 15px;
//         }
//         p {
//           font-size: 18px;
//           line-height: 1.5;
//           margin: 8px 0;
//         }
//         label {
//           font-size: 18px;
//           font-weight: bold;
//         }
//         input {
//           font-size: 16px;
//           padding: 8px;
//           width: 100%;
//           margin: 5px 0;
//           box-sizing: border-box;
//         }
//         button {
//           background-color: #007bff;
//           color: white;
//           border: none;
//           padding: 12px 20px;
//           border-radius: 5px;
//           cursor: pointer;
//           font-size: 18px;
//           margin-top: 10px;
//         }
//         footer {
//           margin-top: 20px;
//           text-align: center;
//           font-size: 16px;
//         }
//     </style>
// </head>
// <body>
// <header>
//     <h1>Welcome to My Sample Page</h1>
// </header>
//
// <section>
//     <h2>About</h2>
//     <p>This is a simple HTML example with basic styling and structure optimized for thermal printing.</p>
// </section>
//
// <section>
//     <h2>Contact</h2>
//     <form>
//         <label for="name">Name:</label><br />
//         <input type="text" id="name" name="name" value="John Doe" /><br />
//
//         <label for="email">Email:</label><br />
//         <input type="email" id="email" name="email" value="john@example.com" /><br />
//
//         <button type="button">Submit</button>
//     </form>
// </section>
//
// <footer>
//     <p>&copy; 2025 My Website</p>
// </footer>
// </body>
// </html>
//
//   ''';
//
//
//
//
//     try {
//
//       // Wrap HTML with print-friendly styling
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
//
// </body>
// </html>
// """;
//
//       final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
//         content: styledHtml,
//         // content: htmlContentss,
//         duration: 2000,
//         scale: 2,
//       );
//
//       return imageBytes;
//     } catch (e) {
//       print('❌ Error converting HTML to Uint8List: $e');
//       return null;
//     }
//   }
//   Future<Uint8List> resizeForThermal(Uint8List htmlBytes) async {
//     final image = img.decodeImage(htmlBytes);
//     if (image == null) {
//       throw Exception("Failed to decode HTML image");
//     }
//
//     // Target width for 80mm thermal printer (203 DPI)
//     const int targetWidth = 576;
//
//     // Only resize if image is not already at target width
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
//   /// Resize image for thermal printer
//   Future<Uint8List> resizeForThermalold(Uint8List imageBytes) async {
//     try {
//       img.Image? original = img.decodeImage(imageBytes);
//       if (original == null) {
//         throw Exception('Failed to decode image');
//       }
//
//       // Convert to grayscale
//       img.Image grayscale = img.grayscale(original);
//
//       // Resize to thermal printer width
//       img.Image resized = img.copyResize(
//         grayscale,
//         width: _config.printImageWidth,
//       );
//
//       // Enhanced contrast and brightness
//       img.Image contrasted = img.adjustColor(
//         resized,
//         contrast: 1.8,
//         brightness: 1.15,
//       );
//
//       // Apply threshold for clear black/white distinction
//       for (int y = 0; y < contrasted.height; y++) {
//         for (int x = 0; x < contrasted.width; x++) {
//           final pixel = contrasted.getPixel(x, y);
//           final luminance = img.getLuminanceRgb(
//             pixel.r.toInt(),
//             pixel.g.toInt(),
//             pixel.b.toInt(),
//           );
//           final newColor = luminance > 128 ? 255 : 0;
//           contrasted.setPixelRgb(x, y, newColor, newColor, newColor);
//         }
//       }
//
//       return Uint8List.fromList(img.encodePng(contrasted));
//     } catch (e) {
//       print('❌ Error resizing image: $e');
//       rethrow;
//     }
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
//     if (!PrinterService.isPrinterConnected) {
//       setState(() {
//         _serverResponse = "Error: Printer not connected";
//       });
//       return;
//     }
//
//     setState(() {
//       _isCapturing = true;
//       _isConvertingPdf = true;
//       _serverResponse = "Converting HTML to image...";
//     });
//
//     try {
//       final Uint8List? bytes = await convertHtmlToUint8List(_receivedHtml);
//
//       if (bytes == null) {
//         throw Exception('Failed to convert HTML to image');
//       }
//
//       if (_config.enableDebugLog) {
//         print("✅ HTML converted to image (${bytes.length} bytes)");
//       }
//
//       setState(() {
//         _isConvertingPdf = false;
//         _serverResponse = "Optimizing for thermal printer...";
//       });
//
//       final resizedBytes = await resizeForThermal(bytes);
//
//       if (_config.enableDebugLog) {
//         print("✅ Image optimized (${resizedBytes.length} bytes)");
//       }
//
//       setState(() {
//         _screenshotBytes = resizedBytes;
//         _showPreview = true;
//         _serverResponse = "Sending to printer...";
//       });
//
//       // await PrinterService.printImage(resizedBytes);
//       await PrinterService.printImage(resizedBytes);
//       setState(() {
//         _serverResponse = "✅ Print completed successfully";
//       });
//
//       if (_config.enableDebugLog) {
//         print("✅ Print job completed successfully");
//       }
//     } catch (e) {
//       setState(() {
//         _serverResponse = "❌ Print failed: $e";
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
//
//   /// Capture screenshot and print
//   Future<void> _captureAndPrint() async {
//     if (_config.enableDebugLog) {
//       print("📸 Starting screenshot capture...");
//     }
//
//     if (!mounted) return;
//
//     if (!PrinterService.isPrinterConnected) {
//       _showError("Please connect your USB printer first");
//       return;
//     }
//
//     setState(() => _isCapturing = true);
//
//     try {
//       final Uint8List? captured = await _screenshotController.capture();
//
//       if (captured == null) {
//         _showError("Failed to capture screenshot");
//         return;
//       }
//
//       final printable = await resizeForThermal(captured);
//
//       setState(() {
//         _screenshotBytes = printable;
//         _showPreview = true;
//       });
//
//       await PrinterService.
//       printImage(printable);
//       _showSuccess("✅ Screenshot printed successfully");
//
//     } catch (e) {
//       _showError("Error: ${e.toString()}");
//       print("❌ Screenshot error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isCapturing = false);
//       }
//     }
//   }
//
//   void _showError(String message) {
//     if (mounted) {
//       PopUpMessage.showPopup(
//         context: context,
//         title: "Error",
//         content: message,
//       );
//     }
//   }
//
//   void _showSuccess(String message) {
//     if (mounted) {
//       PopUpMessage.showPopup(
//         context: context,
//         title: "Info",
//         content: message,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('IQUAD INNOVATIONS'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _controller?.reload(),
//             tooltip: 'Refresh',
//           ),
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: _captureAndPrint,
//             tooltip: 'Screenshot & Print',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildPrinterStatusSection(),
//           if (_serverResponse.isNotEmpty && _serverResponse.length < 500)
//             _buildServerResponseSection(),
//           if (_receivedHtml.isNotEmpty) _buildHtmlReceivedIndicator(),
//
//           // Progress indicator
//           if (_progress > 0 && _progress < 1)
//             LinearProgressIndicator(
//               value: _progress,
//               backgroundColor: Colors.grey[200],
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//             ),
//
//           Expanded(child: _buildWebViewSection()),
//           _buildPreviewSection(),
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
//               "Printer: ${PrinterService.printerName.isNotEmpty ? PrinterService.printerName : 'None'}",
//             ),
//             subtitle: Text("Status: ${PrinterService.printerStatus}"),
//             trailing: Switch(
//               value: PrinterService.isPrinterConnected,
//               onChanged: (val) async {
//                 if (val) {
//                   await PrinterService.connect();
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
//   Widget _buildServerResponseSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, color: Colors.blue),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "Response: ${_serverResponse.length > 100 ? '${_serverResponse.substring(0, 100)}...' : _serverResponse}",
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 18),
//             onPressed: () => setState(() => _serverResponse = ""),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHtmlReceivedIndicator() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.code, color: Colors.green),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "HTML Ready (${_receivedHtml.length} chars) - ${_isConvertingPdf ? 'Converting...' : 'Tap to reprint'}",
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.print, color: Colors.green),
//             onPressed: _isCapturing ? null : _printHtmlAsImage,
//             tooltip: "Reprint",
//           ),
//         ],
//       ),
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
//               // Better compatibility for older Android
//               cacheEnabled: true,
//               clearCache: false,
//               thirdPartyCookiesEnabled: true,
//               supportZoom: false,
//               builtInZoomControls: false,
//               displayZoomControls: false,
//               // Force modern rendering
//               useWideViewPort: true,
//               loadWithOverviewMode: true,
//               // Enable debugging
//               isInspectable: _config.enableDebugLog,
//             ),
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // Add JavaScript handler for communication
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
//               // Inject listener with delay for page to fully render
//               await Future.delayed(const Duration(milliseconds: 500));
//               _injectJavaScriptListener();
//             },
//             onProgressChanged: (controller, progress) {
//               setState(() {
//                 _progress = progress / 100;
//               });
//             },
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final url = navigationAction.request.url.toString();
//
//               if (_config.enableDebugLog) {
//                 print("🔗 Navigation request: $url");
//               }
//
//               // Check if URL should be intercepted
//               for (String interceptUrl in _config.interceptUrls) {
//                 if (url.contains(interceptUrl)) {
//                   if (_config.enableDebugLog) {
//                     print("✅ Intercepted: $interceptUrl");
//                   }
//
//                   // Inject JS after a delay
//                   Future.delayed(const Duration(milliseconds: 500), () {
//                      _injectJavaScriptListener();
//                   });
//
//                   return NavigationActionPolicy.CANCEL;
//                 }
//               }
//
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
//   Widget _buildPreviewSection() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           if (_isCapturing)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(width: 16),
//                   Text(_isConvertingPdf ? "Converting HTML..." : "Processing..."),
//                 ],
//               ),
//             ),
//           if (_showPreview && _screenshotBytes != null)
//             Card(
//               child: Column(
//                 children: [
//                   ListTile(
//                     title: const Text("Print Preview"),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => setState(() => _showPreview = false),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 200,
//                     child: Image.memory(_screenshotBytes!),
//                   ),
//                 ],
//               ),
//             ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: _isCapturing ? null : _captureAndPrint,
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text('Screenshot & Print'),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton.icon(
//                 onPressed: () => _controller?.reload(),
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Reload'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     PrinterService.dispose();
//     super.dispose();
//   }
// }


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

  WebViewPrintPage({
    Key? key,
    this.config,
  }) : super(key: key);

  @override
  State<WebViewPrintPage> createState() => _WebViewPrintPageState();
}

class _WebViewPrintPageState extends State<WebViewPrintPage> {
  InAppWebViewController? _controller;
  late WebViewPrintConfig _config;
  final ScreenshotController _screenshotController = ScreenshotController();

  // State variables
  List<String> _jsMessages = []; // ✅ Changed to List to store multiple messages
  String _receivedHtml = "";
  Uint8List? _screenshotBytes;
  bool _isCapturing = false;
  bool _showPreview = false;
  bool _isConvertingPdf = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? const WebViewPrintConfig();
    _initializePrinter();
  }

  /// Initialize printer service
  Future<void> _initializePrinter() async {
    PrinterService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PrinterService.scan();
    });
  }

  // / Handle messages from JavaScript
  void _handleJavaScriptMessage(String message) {
    if (_config.enableDebugLog) {
      print("=======message length ${message.length}");
      print("📩 Message from JS: "
          "${message.substring(0, message.length > 200 ? 200 : message.length)}...");
    }

    // ✅ Add message to list
    setState(() {
      _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - $message");
      // Keep only last 50 messages to prevent memory issues
      if (_jsMessages.length > 50) {
        _jsMessages.removeAt(0);
      }
    });

    // Check if it's HTML content - if yes, print silently
    if (message.contains("<html") ||
        message.contains("<!DOCTYPE") ||
        message.contains("<body") ||
        message.contains("</html>")) {
      if (_config.enableDebugLog) {
        print("✅ HTML content detected - Starting print...$message");
      }
      _receivedHtml = message;
      print("received message is $_receivedHtml");

      setState(() {
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - HTML received (${message.length} chars) - Printing...");
      });
      _printHtmlAsImage();
    }
  }

  /// Inject JavaScript to listen for print button clicks
  Future<void> _injectJavaScriptListener() async {

    if (_controller == null) return;

    final jsCode = """
      (function() {
        console.log('🔧 Injecting print listener for InAppWebView...');
        var printButton = document.getElementById('${_config.printButtonId}') 
                      || document.querySelector('input[name="print"]')
                      || document.querySelector('button[name="print"]');
    
        console.log('Print button found:', printButton);

        // Polyfill for older browsers
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
          // Remove existing listeners by cloning
          var newButton = printButton.cloneNode(true);
          printButton.parentNode.replaceChild(newButton, printButton);

          newButton.addEventListener('click', function(e) {
            e.preventDefault();
            console.log('🖨️ Print button clicked!');

            try {
              // Get the HTML content to print
              var htmlContent = document.documentElement.outerHTML;
              console.log('HTML length:', htmlContent.length);

              // Send HTML content to Flutter
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('${_config.channelName}', htmlContent);
                console.log('✅ HTML sent to Flutter via handler');
              }else {
                console.error('❌ flutter_inappwebview.callHandler not available!');
              }
            } catch (error) {
              console.error('❌ Error sending HTML:', error);
            }
          });

          console.log('✅ Print listener attached successfully');

          // Confirm listener attachment
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
        print("✅ JavaScript listener injected");
      }
    } catch (e) {
      print("❌ Error injecting JavaScript: $e");
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _controller != null) {
          print("🔄 Retrying JavaScript injection...");
          _controller?.evaluateJavascript(source: jsCode);
        }
      });
    }
  }

  /// Convert HTML to Uint8List image
  Future<Uint8List?> convertHtmlToUint8List(String htmlContent) async {
    print("html to be printed $htmlContent");

    try {
      final styledHtml = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body {
      margin: 0;
      padding: 10px;
      font-family: Arial, sans-serif;
      font-size: 12px;
      background: white;
      color: black;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 0;
      padding: 0;
    }
    td {
      padding: 2px 4px;
      vertical-align: top;
    }
    b {
      font-weight: bold;
    }
    @media print {
      body { margin: 0; padding: 5px; }
    }
  </style>
</head>
<body>
$htmlContent
</body>
</html>
""";

      final Uint8List? imageBytes = await WebcontentConverter.contentToImage(
        content: htmlContent,
        duration: 2000,
        scale: 2,
      );

      return imageBytes;
    } catch (e) {
      print('❌ Error converting HTML to Uint8List: $e');
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

  /// Print HTML as image to thermal printer
  Future<void> _printHtmlAsImage() async {
    if (_config.enableDebugLog) {
      print("🖨️ Starting HTML to image print...");
    }

    if (!mounted) return;

    if (!PrinterService.isPrinterConnected) {
      setState(() {
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Error: Printer not connected");
      });
      return;
    }

    setState(() {
      _isCapturing = true;
      _isConvertingPdf = true;
      _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Converting HTML to image...");
    });

    try {
      final Uint8List? bytes = await convertHtmlToUint8List(_receivedHtml);

      if (bytes == null) {
        throw Exception('Failed to convert HTML to image');
      }

      if (_config.enableDebugLog) {
        print("✅ HTML converted to image (${bytes.length} bytes)");
      }

      setState(() {
        _isConvertingPdf = false;
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Optimizing for thermal printer...");
      });

      final resizedBytes = await resizeForThermal(bytes);

      if (_config.enableDebugLog) {
        print("✅ Image optimized (${resizedBytes.length} bytes)");
      }

      setState(() {
        _screenshotBytes = resizedBytes;
        _showPreview = true;
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - Sending to printer...");
      });

      await PrinterService.printImage(resizedBytes);

      setState(() {
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ✅ Print completed successfully");
      });

      if (_config.enableDebugLog) {
        print("✅ Print job completed successfully");
      }
    } catch (e) {
      setState(() {
        _jsMessages.add("${DateTime.now().toString().substring(11, 19)} - ❌ Print failed: $e");
      });
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

  /// Capture screenshot and print
  Future<void> _captureAndPrint() async {
    if (_config.enableDebugLog) {
      print("📸 Starting screenshot capture...");
    }

    if (!mounted) return;

    if (!PrinterService.isPrinterConnected) {
      _showError("Please connect your USB printer first");
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final Uint8List? captured = await _screenshotController.capture();

      if (captured == null) {
        _showError("Failed to capture screenshot");
        return;
      }

      final printable = await resizeForThermal(captured);

      setState(() {
        _screenshotBytes = printable;
        _showPreview = true;
      });

      await PrinterService.printImage(printable);
      _showSuccess("✅ Screenshot printed successfully");
    } catch (e) {
      _showError("Error: ${e.toString()}");
      print("❌ Screenshot error: $e");
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureAndPrint,
            tooltip: 'Screenshot & Print',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPrinterStatusSection(),

          // ✅ New scrollable messages section
          if (_jsMessages.isNotEmpty) _buildMessagesSection(),

          if (_receivedHtml.isNotEmpty) _buildHtmlReceivedIndicator(),

          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          Expanded(child: _buildWebViewSection()),
          _buildPreviewSection(),
        ],
      ),
    );
  }

  // ✅ New widget to display messages in scrollable column
  Widget _buildMessagesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 150, // Fixed height for the message container
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.message, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "JavaScript Messages",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 20),
                  onPressed: () => setState(() => _jsMessages.clear()),
                  tooltip: "Clear messages",
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _jsMessages.clear()),
                  tooltip: "Close",
                ),
              ],
            ),
          ),
          // Scrollable messages
          Expanded(
            child: SingleChildScrollView(
              reverse: true, // Auto-scroll to bottom (newest messages)
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _jsMessages.map((message) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
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
              "Printer: ${PrinterService.printerName.isNotEmpty ? PrinterService.printerName : 'None'}",
            ),
            subtitle: Text("Status: ${PrinterService.printerStatus}"),
            trailing: Switch(
              value: PrinterService.isPrinterConnected,
              onChanged: (val) async {
                if (val) {
                  await PrinterService.connect();
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

  Widget _buildHtmlReceivedIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.code, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "HTML Ready (${_receivedHtml.length} chars) - ${_isConvertingPdf ? 'Converting...' : 'Tap to reprint'}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Colors.green),
            onPressed: _isCapturing ? null : _printHtmlAsImage,
            tooltip: "Reprint",
          ),
        ],
      ),
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
                print("🔗 Loading started: $url");
              }
              setState(() {
                _progress = 0;
              });
            },
            onLoadStop: (controller, url) async {
              if (_config.enableDebugLog) {
                print("✅ Page loaded: $url");
              }
              setState(() {
                _progress = 1;
              });

              await Future.delayed(const Duration(milliseconds: 500));
              // _injectJavaScriptListener();
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
                    print("✅ Intercepted: $interceptUrl");
                  }

                  Future.delayed(const Duration(milliseconds: 500), () {
                    _injectJavaScriptListener();
                  });

                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (_config.enableDebugLog) {
                print("🖥️ Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
              }
            },
            onReceivedError: (controller, request, error) {
              if (_config.enableDebugLog) {
                print("❌ WebView Error:");
                print("   Type: ${error.type}");
                print("   Description: ${error.description}");
                print("   URL: ${request.url}");
              }

              if (mounted) {
                _showError("Network Error: ${error.description}");
              }
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              if (_config.enableDebugLog) {
                print("❌ HTTP Error:");
                print("   Status Code: ${errorResponse.statusCode}");
                print("   URL: ${request.url}");
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (_isCapturing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(_isConvertingPdf ? "Converting HTML..." : "Processing..."),
                ],
              ),
            ),
          if (_showPreview && _screenshotBytes != null)
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Print Preview"),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _showPreview = false),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Image.memory(_screenshotBytes!),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isCapturing ? null : _captureAndPrint,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Screenshot & Print'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _controller?.reload(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    PrinterService.dispose();
    super.dispose();
  }
}