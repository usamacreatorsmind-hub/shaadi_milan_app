import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PdfViewerBottomsheet extends ConsumerStatefulWidget {
//   final String source; // URL or local file path
//   final String title;
//   final bool isLocal;

//   const PdfViewerBottomsheet({
//     super.key,
//     required this.source,
//     required this.title,
//     required this.isLocal,
//   });

//   @override
//   ConsumerState<PdfViewerBottomsheet> createState() =>
//       _PdfViewerBottomsheetState();
// }

// class _PdfViewerBottomsheetState
//     extends ConsumerState<PdfViewerBottomsheet> {
//   Uint8List? _pdfBytes;
//   double _progress = 0.0;
//   String _status = 'Preparing PDF...';
//   bool _error = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.isLocal ? _loadLocalPdf() : _downloadPdf();
//   }

//   // ================= LOCAL PDF =================
//   Future<void> _loadLocalPdf() async {
//     try {
//       final file = File(widget.source);

//       if (!await file.exists()) {
//         throw Exception('File not found');
//       }

//       final bytes = await file.readAsBytes();
//       if (mounted) {
//         setState(() {
//           _pdfBytes = bytes;
//           _status = 'Loaded';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = true;
//           _status = 'Failed to open PDF';
//         });
//       }
//     }
//   }

//   // ================= NETWORK PDF =================
//   Future<void> _downloadPdf() async {
//     final client = HttpClient();

//     try {
//       final request = await client.getUrl(Uri.parse(widget.source));
//       final response = await request.close();

//       if (response.statusCode != 200) {
//         throw HttpException('Failed to load PDF');
//       }

//       final totalBytes = response.contentLength;
//       int receivedBytes = 0;
//       final chunks = <List<int>>[];

//       response.listen(
//         (chunk) {
//           chunks.add(chunk);
//           receivedBytes += chunk.length;

//           if (mounted && totalBytes > 0) {
//             setState(() {
//               _progress = receivedBytes / totalBytes;
//               _status =
//                   'Downloading... ${(_progress * 100).toStringAsFixed(0)}%';
//             });
//           }
//         },
//         onDone: () {
//           final bytes = Uint8List(receivedBytes);
//           int offset = 0;

//           for (final chunk in chunks) {
//             bytes.setRange(offset, offset + chunk.length, chunk);
//             offset += chunk.length;
//           }

//           if (mounted) {
//             setState(() {
//               _pdfBytes = bytes;
//               _status = 'Loaded';
//             });
//           }
//         },
//         onError: (_) {
//           if (mounted) {
//             setState(() {
//               _error = true;
//               _status = 'Download failed';
//             });
//           }
//         },
//         cancelOnError: true,
//       );
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _error = true;
//           _status = 'Failed to load PDF';
//         });
//       }
//     } finally {
//       client.close();
//     }
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         children: [
//           // 🔹 HEADER
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),

//           const Divider(height: 1),

//           // 🔹 BODY
//           Expanded(
//             child: _pdfBytes != null
//                 ? SfPdfViewer.memory(
//                     _pdfBytes!,
//                     canShowScrollHead: true,
//                     canShowScrollStatus: true,
//                   )
//                 : _buildLoadingState(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (!_error)
//             CircularProgressIndicator(
//               value: widget.isLocal ? null : (_progress > 0 ? _progress : null),
//             ),
//           if (_error)
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 48,
//             ),
//           const SizedBox(height: 20),
//           Text(
//             _status,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }
 
class PdfViewerBottomsheet extends ConsumerStatefulWidget {
  final String source; // URL or local file path
  final String title;
  final bool isLocal;

  const PdfViewerBottomsheet({
    super.key,
    required this.source,
    required this.title,
    required this.isLocal,
  });

  @override
  ConsumerState<PdfViewerBottomsheet> createState() =>
      _PdfViewerBottomsheetState();
}

class _PdfViewerBottomsheetState
    extends ConsumerState<PdfViewerBottomsheet> {
  Uint8List? _pdfBytes;
  double _progress = 0.0;
  String _status = 'Preparing PDF...';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    widget.isLocal ? _loadLocalPdf() : _downloadPdf();
  }

  // ================= LOCAL PDF =================
  Future<void> _loadLocalPdf() async {
    try {
      final file = File(widget.source);

      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // No need to read as bytes for SfPdfViewer.file
      if (mounted) {
        setState(() {
          _status = 'Loaded';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _status = 'Failed to open PDF';
        });
      }
    }
  }

  // ... (keep _downloadPdf as is)
  Future<void> _downloadPdf() async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(widget.source));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw const HttpException('Failed to load PDF');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final chunks = <List<int>>[];

      response.listen(
        (chunk) {
          chunks.add(chunk);
          receivedBytes += chunk.length;

          if (mounted && totalBytes > 0) {
            setState(() {
              _progress = receivedBytes / totalBytes;
              _status =
                  'Downloading... ${(_progress * 100).toStringAsFixed(0)}%';
            });
          }
        },
        onDone: () {
          final bytes = Uint8List(receivedBytes);
          int offset = 0;

          for (final chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }

          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _status = 'Loaded';
            });
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _error = true;
              _status = 'Download failed';
            });
          }
        },
        cancelOnError: true,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _status = 'Failed to load PDF';
        });
      }
    } finally {
      client.close();
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 🔹 HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 🔹 BODY
          Expanded(
            child: widget.isLocal
                ? SfPdfViewer.file(
                    File(widget.source),
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                  )
                : (_pdfBytes != null
                    ? SfPdfViewer.memory(
                        _pdfBytes!,
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                      )
                    : _buildLoadingState()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_error)
            CircularProgressIndicator(
              value: widget.isLocal ? null : (_progress > 0 ? _progress : null),
            ),
          if (_error)
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
          const SizedBox(height: 20),
          Text(
            _status,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
