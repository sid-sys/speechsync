import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class ExportService {
  static Future<void> exportToPdf(String text) async {
    if (kIsWeb) return; // Simple web check
    
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 16)),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/SpeechSync_Export.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static Future<void> exportToMarkdown(String text) async {
    if (kIsWeb) return;
    
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/SpeechSync_Export.md");
    await file.writeAsString("# SpeechSync Transcription\n\n$text");
    await OpenFilex.open(file.path);
  }
}
