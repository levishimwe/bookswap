import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';

/// PDF Viewer screen for displaying book PDFs
class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String? pdfUrl;
  final String? pdfBase64;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.pdfUrl,
    this.pdfBase64,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String? path;

      // If base64 encoded, decode and save to temp file
      if (widget.pdfBase64 != null && widget.pdfBase64!.isNotEmpty) {
        final bytes = base64Decode(widget.pdfBase64!);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(bytes);
        path = file.path;
      } else if (widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty) {
        // If URL, download and save
        // For now, just use URL directly (PDFView can handle URLs)
        path = widget.pdfUrl;
      }

      if (path == null || path.isEmpty) {
        setState(() {
          _errorMessage = 'No PDF available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _localPath = path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_localPath == null) {
      return const Center(
        child: Text('No PDF to display'),
      );
    }

    return PDFView(
      filePath: _localPath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
      onPageError: (page, error) {
        setState(() {
          _errorMessage = 'Error on page $page: $error';
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // Can store controller if needed
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
    );
  }
}
