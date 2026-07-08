import 'dart:html' as html;

Future<String?> saveExportFile({
  required String url,
  required String fileName,
}) async {
  final anchor = html.AnchorElement(href: Uri.encodeFull(url.trim()))
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return fileName;
}
