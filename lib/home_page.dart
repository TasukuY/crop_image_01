import 'package:crop_image_01/crop_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;

  Future<void> _pickImage({bool takingImage = false}) async {
    Uint8List? selectedImage;
    if (takingImage) {
      XFile? result = await ImagePicker().pickImage(source: ImageSource.camera);
      if (result == null) return;
      selectedImage = await result.readAsBytes();
    } else if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'svg', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.first.bytes == null) return;
      selectedImage = result.files.first.bytes;
    } else {
      XFile? result =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (result == null) return;
      selectedImage = await result.readAsBytes();
    }
    if (!mounted || selectedImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => CropImage(
              image: selectedImage!,
              onCropped: (image) {
                setState(() {
                  _image = image;
                });
                Navigator.pop(context);
              },
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image Picker & Image Cropper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_image != null) ...[
              Container(
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
                    _image!,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ] else
              const Text('no image selected...'),
            const SizedBox(height: 36),
            ElevatedButton(
              child: const Text('Pick Gallery Images'),
              onPressed: () => _pickImage(),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              child: const Text('Take an Image'),
              onPressed: () => _pickImage(takingImage: true),
            ),
          ],
        ),
      ),
    );
  }
}
