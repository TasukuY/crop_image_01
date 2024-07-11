import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;

class CropImage extends StatefulWidget {
  final Uint8List image;
  final Function(Uint8List) onCropped;

  const CropImage({
    super.key,
    required this.image,
    required this.onCropped,
  });

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final _controller = CropController();
  int _quarterTurns = 0;
  bool _loading = false;
  bool _isPreviewing = false;
  bool _doneCropping = false;
  late Uint8List _image;
  late Uint8List _originalImage;

  set isPreviewing(bool value) {
    setState(() {
      _isPreviewing = value;
    });
  }

  Future<Uint8List> rotateImage90Degrees(
      Uint8List input, int quarterTurns) async {
    img.Image image = img.decodeImage(input)!;
    img.Image rotated = img.copyRotate(image, angle: (90 * quarterTurns));
    Uint8List output = Uint8List.fromList(img.encodePng(rotated));
    return output;
  }

  void _rotate(bool clockwise) {
    if (_quarterTurns == 3 && clockwise) {
      _quarterTurns = 0;
    } else if (_quarterTurns == 0 && !clockwise) {
      _quarterTurns = 3;
    } else {
      clockwise ? _quarterTurns++ : _quarterTurns--;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _originalImage = widget.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image Picker & Image Cropper'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isPreviewing
                      ? Container(
                          width: MediaQuery.of(context).size.width - 24,
                          height: MediaQuery.of(context).size.width - 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width - 24),
                            child: Image.memory(
                              _image,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.width - 24,
                          width: MediaQuery.of(context).size.width - 24,
                          color: Colors.lightGreen,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: RotatedBox(
                              quarterTurns: _quarterTurns,
                              child: Crop(
                                image: _image,
                                controller: _controller,
                                onCropped: (image) async {
                                  _image = await rotateImage90Degrees(
                                      image, _quarterTurns);
                                  _loading = false;
                                  setState(() {});
                                  if (_doneCropping) {
                                    widget.onCropped(_image).call();
                                  }
                                },
                                initialSize: 0.8,
                                withCircleUi: true,
                                baseColor: Colors.black,
                                maskColor: _isPreviewing ? Colors.white : null,
                                progressIndicator:
                                    const CircularProgressIndicator(),
                                cornerDotBuilder: (size, edgeAlignment) {
                                  return _isPreviewing
                                      ? const SizedBox.shrink()
                                      : const DotControl();
                                },
                                clipBehavior: Clip.none,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Tooltip(
                          message: 'Rotate image to left',
                          child: IconButton(
                            onPressed: () {
                              if (_isPreviewing) return;
                              _rotate(false);
                            },
                            icon: const Icon(
                                Icons.rotate_90_degrees_ccw_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Rotate'),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Tooltip(
                          message: 'Rotate image to right',
                          child: IconButton(
                            onPressed: () {
                              if (_isPreviewing) return;
                              _rotate(true);
                            },
                            icon:
                                const Icon(Icons.rotate_90_degrees_cw_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      TextButton(
                        onPressed: () {
                          isPreviewing = !_isPreviewing;
                          if (_isPreviewing) {
                            _controller.cropCircle();
                            _loading = true;
                          } else {
                            setState(() {
                              _image = _originalImage;
                              _quarterTurns = 0;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            _isPreviewing ? 'Revert' : 'PREVIEW',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.cropCircle();
                        _doneCropping = true;
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
