import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/helper/open_file.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'camera_page.dart';

class FileField extends StatelessWidget {
  final PlatformFile? platformFile;
  final Function(PlatformFile) pickFile;
  final VoidCallback removeFile;
  final bool canTakePhoto;
  final String label;
  final bool required;
  final bool canBePdf;

  const FileField({
    super.key,
    required this.pickFile,
    required this.canTakePhoto,
    required this.removeFile,
    required this.platformFile,
    required this.label,
    this.required = true,
    this.canBePdf = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                textAlign: TextAlign.left,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (required)
                Text(
                  "*",
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(4),
          DottedBorder(
            color: const Color(0xFFCACACA),
            strokeWidth: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: platformFile != null
                  ? FilePickedCard(
                      file: platformFile!,
                      removeFile: removeFile,
                    )
                  : PickFileCard(
                      canTakePhoto: canTakePhoto,
                      pickFile: pickFile,
                      canBePdf: canBePdf,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> pickFileWithPermission(Function(PlatformFile) pickFile) async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null) {
        pickFile(result.files.first);
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection du fichier : $e");
      throw Exception("Erreur lors de la sélection du fichier : $e");
    }
  } else if (status.isDenied) {
    throw Exception("Permission refusée par l'utilisateur.");
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
    throw Exception(
        "Permission définitivement refusée, active-la dans les paramètres.");
  }
}

class PickFileCard extends StatelessWidget {
  final Function(PlatformFile) pickFile;
  final bool canBePdf;
  final bool canTakePhoto;
  const PickFileCard({
    super.key,
    required this.pickFile,
    required this.canBePdf,
    required this.canTakePhoto,
  });

  Future<void> _pickFromGallery(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          canBePdf ? ['jpg', 'jpeg', 'png', 'pdf'] : ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null) {
      pickFile(result.files.first);
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint("Permission caméra refusée");
      return;
    }
    await Permission.audio.request();
    // if (!audio.isGranted) {
    //   debugPrint("Permission audio refusée");
    //   return;
    // }
    final picture =
        await MutationRequestContextualBehavior.openPage(CameraCapturePage());

    if (picture != null) {
      final bytes = await File(picture.path).readAsBytes();
      final fileName = path.basename(picture.path);

      final platformFile = PlatformFile(
        name: fileName,
        path: picture.path,
        size: bytes.length,
        bytes: bytes,
      );

      pickFile(platformFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    var allowedExtensions = [
      'jpg',
      'jpeg',
      'png',
    ];
    if (canBePdf) {
      allowedExtensions.add('pdf');
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _optionButton(
                context, Icons.folder, "Choisir un fichier", _pickFromGallery),
            if (isMobileDevice() && canTakePhoto) ...[
              const Gap(16),
              _optionButton(
                context,
                Icons.camera_alt,
                "Prendre une photo",
                _takePhoto,
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _optionButton(BuildContext context, IconData icon, String label,
      Function(BuildContext) onTap) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF5F5F5),
            radius: 20,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class FilePickedCard extends StatelessWidget {
  final VoidCallback removeFile;
  final PlatformFile file;

  const FilePickedCard({
    super.key,
    required this.file,
    required this.removeFile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_copy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.name.split("/").last.split("_").last,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(4),
              GestureDetector(
                onTap: removeFile,
                child: const Icon(
                  Icons.delete,
                  color: AppColor.redColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async => await openFile(
              name: file.path!,
            ),
            child: Text(
              "Afficher",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColor.adaptiveGreenSecondary500(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
