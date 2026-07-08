import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

Future<String?> saveExportFile({
  required String url,
  required String fileName,
}) async {
  final selectedPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Simpan Laporan Pembayaran',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
  );

  if (selectedPath == null || selectedPath.trim().isEmpty) {
    return null;
  }

  await Dio().download(
    Uri.encodeFull(url.trim()),
    selectedPath,
    options: Options(responseType: ResponseType.bytes),
  );

  return selectedPath;
}
