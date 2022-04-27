import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class ViewFilePage extends StatefulWidget {
  final PDFDocument document;
  const ViewFilePage(this.document, {Key key}) : super(key: key);

  @override
  _ViewFilePageState createState() => _ViewFilePageState();
}

class _ViewFilePageState extends State<ViewFilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: PDFViewer(document: widget.document));
  }
}
