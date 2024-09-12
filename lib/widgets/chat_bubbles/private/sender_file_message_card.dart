import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp_clone/colors.dart';

import '../../../features/file_message/cubit/file_message_cubit.dart';

class SenderFileMessageCard extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final String time;

  const SenderFileMessageCard({
    super.key,
    required this.fileUrl,
    required this.time,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 30, top: 5, bottom: 20),
                child: BlocBuilder<FileMessageCubit, double>(
                  builder: (context, state) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          fit: FlexFit.loose,
                          child: Icon(
                            Icons.insert_drive_file,
                            size: 30,
                          ),
                        ),
                        const Gap(10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const Gap(10),
                        if (state == 0)
                          Flexible(
                            fit: FlexFit.loose,
                            child: IconButton(
                              onPressed: () {
                                context.read<FileMessageCubit>().downloadFile(
                                      fileUrl: fileUrl,
                                      fileName: fileName,
                                    );
                              },
                              icon: const Icon(
                                  Icons.download_for_offline_outlined),
                            ),
                          )
                        else if (state == 1)
                          Flexible(
                            fit: FlexFit.loose,
                            child: IconButton(
                              onPressed: () {
                                context.read<FileMessageCubit>().openFile(
                                      fileUrl: fileUrl,
                                    );
                              },
                              icon: const Icon(Icons.done),
                            ),
                          )
                        else
                          Flexible(
                            fit: FlexFit.loose,
                            child: IconButton(
                              onPressed: null,
                              icon: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: state,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 2,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      time.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
