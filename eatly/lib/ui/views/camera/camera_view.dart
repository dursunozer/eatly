import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stacked/stacked.dart';
import 'camera_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class CameraView extends StackedView<CameraViewModel> {
  const CameraView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CameraViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Fotoğraf Çek',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: viewModel.pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (viewModel.isInitialized && viewModel.controller != null)
            Center(child: CameraPreview(viewModel.controller!))
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.flash_auto,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: viewModel.toggleFlash,
                  ),
                  GestureDetector(
                    onTap: viewModel.isProcessing ? null : viewModel.takePicture,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: viewModel.isProcessing
                            ? Colors.grey
                            : Colors.white.withOpacity(0.3),
                      ),
                      child: viewModel.isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      viewModel.hasMultipleCameras
                          ? Icons.flip_camera_ios
                          : Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: viewModel.hasMultipleCameras
                        ? viewModel.switchCamera
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  CameraViewModel viewModelBuilder(BuildContext context) => CameraViewModel();

  @override
  void onViewModelReady(CameraViewModel viewModel) {
    viewModel.initializeCamera();
  }

  @override
  void onDispose(CameraViewModel viewModel) {
    viewModel.disposeCamera();
    super.onDispose(viewModel);
  }
}
