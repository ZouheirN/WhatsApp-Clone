import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart';

class FileMessageCubit extends Cubit<double> {
  FileMessageCubit(super.initialState);

  Future<void> downloadFile(
      {required String fileUrl, required String fileName}) async {
    if (kIsWeb) {
      var url = Url.createObjectUrlFromBlob(Blob([fileUrl]));
      AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
    } else {
      final dataDir = await getApplicationDocumentsDirectory();
      final path = '${dataDir.path}/$fileName';

      Dio().download(
        fileUrl,
        path,
        onReceiveProgress: (received, total) {
          emit(received / total);
        },
      );
    }
  }

  Future<void> openFile({required String fileName}) async {
    if (kIsWeb) {
    } else {
      final dataDir = await getApplicationDocumentsDirectory();
      final path = '${dataDir.path}/$fileName';

      OpenFilex.open(path);
    }
  }
}
