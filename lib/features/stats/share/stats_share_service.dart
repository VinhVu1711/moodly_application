import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class StatsShareService {
  /// Combine image vertically
  Future<Uint8List> mergeImages(List<Uint8List> images) async {
    final uiImages = await Future.wait(
      images.map((e) => decodeImageFromList(e)),
    );

    int width = uiImages.map((e) => e.width).reduce((a, b) => a > b ? a : b);
    int height = uiImages.fold(0, (sum, img) => sum + img.height);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    double offsetY = 0;
    for (final img in uiImages) {
      canvas.drawImage(img, Offset(0, offsetY), paint);
      offsetY += img.height;
    }

    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(width, height);
    final byteData = await finalImage.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> shareStats({
    required Uint8List flow,
    required Uint8List bar,
    required Uint8List total,
    required String textSummary,
  }) async {
    final merged = await mergeImages([
      flow,
      bar,
      total,
    ]);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/stats_share.png');
    await file.writeAsBytes(merged);

    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      text: textSummary,
    );
  }
}
