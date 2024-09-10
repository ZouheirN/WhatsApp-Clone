import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/main.dart';
import 'package:whatsapp_clone/screens/camera_image_view.dart';
import 'package:whatsapp_clone/screens/camera_video_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;

  late Future<void> cameraValue;

  ValueNotifier<bool> isRecording = ValueNotifier(false);
  ValueNotifier<bool> isFlashOn = ValueNotifier(false);
  ValueNotifier<bool> isCameraFront = ValueNotifier(false);

  @override
  void initState() {
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraValue = _cameraController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void takePicture(BuildContext context) async {
    final XFile file = await _cameraController.takePicture();

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraImageViewScreen(
          image: file,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: backgroundColor,
        child: Stack(
          children: [
            FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var camera = _cameraController.value;
                  final size = MediaQuery.of(context).size;
                  var scale = size.aspectRatio * camera.aspectRatio;
                  if (scale < 1) scale = 1 / scale;

                  return Transform.scale(
                    scale: scale,
                    child: Center(
                      child: CameraPreview(_cameraController),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                color: backgroundColor,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: isFlashOn,
                          builder: (context, value, child) {
                            return IconButton(
                              onPressed: () {
                                isFlashOn.value = !isFlashOn.value;
                                _cameraController.setFlashMode(
                                  value ? FlashMode.off : FlashMode.torch,
                                );
                              },
                              icon: value
                                  ? const Icon(
                                      Icons.flash_on,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.flash_off,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: isRecording,
                          builder: (context, value, child) {
                            return GestureDetector(
                              onLongPress: () async {
                                await _cameraController.startVideoRecording();
                                isRecording.value = true;
                              },
                              onLongPressUp: () async {
                                final video = await _cameraController
                                    .stopVideoRecording();

                                isRecording.value = false;

                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CameraVideoViewScreen(
                                      video: video,
                                    ),
                                  ),
                                );
                              },
                              onTap: () {
                                if (!value) {
                                  takePicture(context);
                                }
                              },
                              child: value
                                  ? const Icon(
                                      Icons.radio_button_on,
                                      color: Colors.red,
                                      size: 70,
                                    )
                                  : const Icon(
                                      Icons.panorama_fish_eye,
                                      color: Colors.white,
                                      size: 70,
                                    ),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: isCameraFront,
                          builder: (context, value, child) {
                            return IconButton(
                              onPressed: () async {
                                final camera = value ? cameras[0] : cameras[1];
                                isCameraFront.value = !isCameraFront.value;
                                await _cameraController.dispose();
                                _cameraController = CameraController(
                                  camera,
                                  ResolutionPreset.high,
                                );
                                cameraValue = _cameraController.initialize();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Text(
                      'Hold for video, tap for photo',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
