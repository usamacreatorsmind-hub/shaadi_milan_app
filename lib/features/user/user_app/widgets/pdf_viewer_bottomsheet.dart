import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerBottomsheet extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerBottomsheet({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  ConsumerState<PdfViewerBottomsheet> createState() =>
      _PdfViewerBottomsheetState();
}

class _PdfViewerBottomsheetState extends ConsumerState<PdfViewerBottomsheet> {
  Uint8List? _pdfBytes;
  double _progress = 0.0;
  String _status = 'Preparing to download...';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(widget.pdfUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength;
        if (totalBytes == -1) {
          // If content length is not available, show indeterminate progress.
          if (mounted) {
            setState(() => _status = 'Downloading...');
          }
          final bytes = await consolidateHttpClientResponseBytes(response);
          if (mounted) {
            setState(() => _pdfBytes = bytes);
          }
          return;
        }

        int receivedBytes = 0;
        final chunks = <List<int>>[];

        response.listen(
          (List<int> chunk) {
            chunks.add(chunk);
            receivedBytes += chunk.length;
            if (mounted) {
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
              setState(() => _pdfBytes = bytes);
            }
          },
          onError: (e) {
            if (mounted) {
              setState(() {
                _error = true;
                _status = 'Download failed. Please try again.';
              });
            }
          },
          cancelOnError: true,
        );
      } else {
        throw HttpException('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _status = 'Failed to load PDF. Please check your connection.';
        });
      }
    } finally {
      client.close();
    }
  }

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
          // 🔹 Header
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

          // 🔹 PDF Viewer
          Expanded(
            child: _pdfBytes != null
                ? SfPdfViewer.memory(
                    _pdfBytes!,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_error)
                          CircularProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                          ),
                        if (_error)
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                        const SizedBox(height: 20),
                        Text(_status),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
