import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Certificate extends StatelessWidget {
  const Certificate({
    required this.username,
    required this.coursename,
  }) : super();

  final String username;
  final String coursename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Certificate"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/image/certificate.png",
              gaplessPlayback: true,
            ),
            Positioned(
              child: Text(
                username,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              top: MediaQuery.of(context).size.width * 0.43,
            ),
            Positioned(
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 200),
                child: Text(
                  "Upon his/her successful completion of the course: $coursename ",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              top: MediaQuery.of(context).size.width * 0.51,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveCertificateToDevice(context);
        },
        child: Icon(Icons.download),
      ),
    );
  }

  Future<void> _saveCertificateToDevice(BuildContext acontext) async {
    final pdf = pw.Document();
    final image =
        pw.MemoryImage(await _loadImage("assets/image/certificate.png"));
    final PdfPageFormat format = PdfPageFormat(612, 430, marginAll: 0);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Stack(
              children: [
                pw.Image(image),
                pw.Positioned(
                    child: pw.Text(
                      username,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    top: MediaQuery.of(acontext).size.width * 0.68,
                    left: null,
                    right: null),
                pw.Positioned(
                    child: pw.ConstrainedBox(
                      constraints: pw.BoxConstraints.tightFor(width: 350),
                      child: pw.Text(
                        "Upon his/her successful completion of the course: $coursename ",
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    top: MediaQuery.of(acontext).size.width * 0.80,
                    left: null,
                    right: null),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/certificate.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file using the platform-specific file opening mechanism
    OpenFile.open(file.path);
  }

  Future<Uint8List> _loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }
}
