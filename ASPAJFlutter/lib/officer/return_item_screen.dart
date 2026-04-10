import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/borrowing_item.dart';
import '../providers/borrowing_provider.dart';

class ReturnItemScreen extends StatefulWidget {
  final BorrowingItem item;

  const ReturnItemScreen({super.key, required this.item});

  @override
  State<ReturnItemScreen> createState() => _ReturnItemScreenState();
}

class _ReturnItemScreenState extends State<ReturnItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conditionController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAndCropImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Compress image to 50% quality to reduce file size
      );
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 300,
              height: 300,
            ),
          ),
        ],
      );

      if (!mounted) return;

      if (croppedFile != null) {
        setState(() {
          _image = XFile(croppedFile.path, name: pickedFile.name);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick or crop image: $e')),
        );
      }
    }
  }

  Future<void> _submitReturn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a return proof photo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // The map now contains the XFile object for the image, not the bytes.
    // The key 'return_photo' must match what the backend API expects for the file upload.
    // The key 'condition' must match the backend validation.
    final returnData = {
      'condition': _conditionController.text,
      'return_photo': _image, // Pass the XFile object
    };

    try {
      // Ensure borrowingId and itemId are available
      if (widget.item.borrowingId == null) {
        throw Exception('Borrowing ID is missing for this item.');
      }
      if (widget.item.id == null) {
        throw Exception('Item ID is missing for this item.');
      }

      // Call the correct provider method for returning a single item
      await context.read<BorrowingProvider>().returnBorrowingItem(
            widget.item.borrowingId!,
            widget.item.id!,
            returnData,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item returned successfully!'),
              backgroundColor: Colors.green),
        );
        // Pop back to the borrowing status screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to return item: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commodity = widget.item.commodity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Item'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          image: commodity?.fixedPhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(commodity!.fixedPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: commodity?.fixedPhotoUrl == null
                            ? const Icon(Icons.image_not_supported, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commodity?.name ?? 'Unknown Item',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text('Code: ${commodity?.code ?? '-'}'),
                            Text('Quantity to return: ${widget.item.quantity}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Return Form
              const Text('Return Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Condition
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Item Condition',
                  hintText: 'Describe the condition of the item upon return...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the item condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Photo
              const Text('Proof of Return', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? (kIsWeb
                        ? Image.network(_image!.path, fit: BoxFit.cover)
                        : Image.file(File(_image!.path), fit: BoxFit.cover))
                    : const Center(child: Text('No image selected')),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickAndCropImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Select Image'),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReturn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                      : const Text('Submit Return', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
