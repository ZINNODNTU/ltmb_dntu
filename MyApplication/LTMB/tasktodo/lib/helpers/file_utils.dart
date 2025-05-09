import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentHandler {
  final BuildContext context;
  final String taskTitle;

  AttachmentHandler(this.context, this.taskTitle);

  Future<bool> _requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final statuses = await Future.wait([
        Permission.photos.request(),
        Permission.videos.request(),
        Permission.audio.request(),
      ]);
      return statuses.every((status) => status.isGranted);
    } else if (sdkInt >= 30) {
      return (await Permission.manageExternalStorage.request()).isGranted;
    } else {
      return (await Permission.storage.request()).isGranted;
    }
  }

  Future<void> downloadFile(String base64String, String suggestedFileName) async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _showMessage('Bạn cần cấp quyền lưu trữ để tải tệp.');
        return;
      }

      Directory? downloadDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      Uint8List bytes = base64Decode(base64String);
      String filePath = '${downloadDir.path}/$suggestedFileName';

      await File(filePath).writeAsBytes(bytes);

      _showMessage('Đã lưu tệp tại: $filePath');
    } catch (e) {
      debugPrint('Lỗi khi lưu tệp: $e');
      _showMessage('Không thể tải tệp.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String detectFileExtension(Uint8List bytes) {
    if (bytes.length > 4) {
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
        return '.png'; // PNG
      }
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return '.jpg'; // JPEG
      }
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
        return '.gif'; // GIF
      }
      if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
        return '.pdf'; // PDF
      }
      if (bytes.length > 5 &&
          bytes[0] == 0xD0 && bytes[1] == 0xCF && bytes[2] == 0x11 &&
          bytes[3] == 0xE0 && bytes[4] == 0xA1 && bytes[5] == 0xB1) {
        return '.doc'; // Word cũ
      }
      if (bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04) {
        return '.docx'; // Word mới (ZIP container)
      }
    }
    return '.bin'; // Mặc định
  }

  Widget buildAttachmentsSection(List<String> attachments) {
    if (attachments.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tệp Đính Kèm',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: attachments.length,
          itemBuilder: (context, index) => buildAttachmentItem(attachments[index], index),
        ),
      ],
    );
  }

  Widget buildAttachmentItem(String base64String, int index) {
    Uint8List? bytes;
    String fileExtension = '.bin';
    String fileTypeDescription = 'Không xác định';
    Icon icon = Icon(Icons.attach_file, size: 30, color: Colors.teal);
    Widget? preview;
    bool isDownloadable = false;

    try {
      bytes = base64Decode(base64String);
      isDownloadable = true;
      fileExtension = detectFileExtension(bytes);

      switch (fileExtension) {
        case '.png':
        case '.jpg':
        case '.jpeg':
        case '.gif':
          fileTypeDescription = 'Hình ảnh';
          icon = Icon(Icons.image_outlined, size: 30, color: Colors.teal);
          preview = Image.memory(
            bytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => icon,
          );
          break;
        case '.pdf':
          fileTypeDescription = 'Tài liệu PDF';
          icon = Icon(Icons.picture_as_pdf_outlined, size: 30, color: Colors.redAccent);
          break;
        case '.docx':
        case '.doc':
          fileTypeDescription = 'Tài liệu Word';
          icon = Icon(Icons.description_outlined, size: 30, color: Colors.blueAccent);
          break;
        default:
          fileTypeDescription = 'Tệp dữ liệu';
          icon = Icon(Icons.insert_drive_file_outlined, size: 30, color: Colors.teal);
      }
    } catch (_) {
      isDownloadable = false;
      fileTypeDescription = 'Lỗi tệp';
      icon = Icon(Icons.warning_amber_outlined, size: 30, color: Colors.redAccent);
      fileExtension = '.error';
    }

    String displayName = '${taskTitle}_Tệp_${index + 1}$fileExtension';
    String downloadFileName = '${taskTitle}_Tai_lieu_${index + 1}${fileExtension.replaceAll('.', '_')}';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            (preview != null)
                ? ClipRRect(borderRadius: BorderRadius.circular(4), child: preview)
                : Container(width: 60, height: 60, alignment: Alignment.center, child: icon),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(fileTypeDescription,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.download, color: isDownloadable ? Colors.teal : Colors.grey),
              tooltip: isDownloadable ? 'Tải xuống' : 'Không thể tải',
              onPressed: isDownloadable ? () => downloadFile(base64String, downloadFileName) : null,
            ),
          ],
        ),
      ),
    );
  }
}
