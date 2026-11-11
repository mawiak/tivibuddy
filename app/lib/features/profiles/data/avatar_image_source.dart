import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';

/// Lets the user pick an image and turns it into a small square PNG suitable
/// for storing in the database (PROF-3).
class AvatarImageSource {
  static const size = 256;

  static const _imageTypes = XTypeGroup(
    label: 'images',
    extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'],
    mimeTypes: ['image/*'],
    uniformTypeIdentifiers: ['public.image'],
  );

  /// Returns null when the user cancels.
  Future<Uint8List?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_imageTypes]);
    if (file == null) return null;
    return toAvatarPng(await file.readAsBytes());
  }

  /// Decodes [encoded] directly at the target resolution (to avoid holding a
  /// full-size bitmap in memory), crops the centre square and encodes PNG.
  static Future<Uint8List> toAvatarPng(Uint8List encoded) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(encoded);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final scale =
        size /
        (descriptor.width < descriptor.height
            ? descriptor.width
            : descriptor.height);
    final codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * scale).ceil(),
      targetHeight: (descriptor.height * scale).ceil(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final left = (image.width - size) / 2;
    final top = (image.height - size) / 2;
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(left, top, size.toDouble(), size.toDouble()),
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final cropped = await recorder.endRecording().toImage(size, size);
    final png = await cropped.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();
    cropped.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    return png!.buffer.asUint8List();
  }
}
