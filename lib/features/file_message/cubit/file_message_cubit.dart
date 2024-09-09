import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web/web.dart';

class FileMessageCubit extends Cubit<double> {
  FileMessageCubit(super.initialState);

  Future<void> downloadFile(
      {required String fileUrl, required String fileName}) async {
    final dio = Dio();

    if (kIsWeb) {
      if (kReleaseMode) {
        fileUrl = "assets/$fileUrl";
      }

      final anchor = HTMLAnchorElement();
      anchor.href = fileUrl;
      anchor.download = fileUrl;
      anchor.click();
    } else {
      final dataDir = await getApplicationDocumentsDirectory();
      final path = '${dataDir.path}/$fileName';

      dio.download(
        fileUrl,
        path,
        onReceiveProgress: (received, total) {
          emit(received / total);
        },
      );
    }
  }
}
