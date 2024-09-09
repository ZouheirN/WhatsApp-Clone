import 'package:hive_flutter/hive_flutter.dart';

class DownloadedFilesBox {
  static final _downloadedFilesBox = Hive.box('downloadedFiles');

  static addFile({
    required String fileUrl,
    required String path,
  }) {
    _downloadedFilesBox.put(fileUrl, {
      'path': path,
    });
  }

  static removeFile(String fileUrl) {
    _downloadedFilesBox.delete(fileUrl);
  }

  static bool isFileDownloaded(String fileUrl) {
    return _downloadedFilesBox.containsKey(fileUrl);
  }

  static String getFilePath(String fileUrl) {
    return _downloadedFilesBox.get(fileUrl)['path'];
  }
}
