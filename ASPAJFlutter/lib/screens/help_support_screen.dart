import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/bug_report_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDeviceType;
  String? _selectedBugType;
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;
  String? _successMessage;
  String? _errorMessage;

  final List<String> _deviceTypes = ['mobile', 'desktop'];
  final List<String> _bugTypes = ['tampilan', 'sistem'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitBugReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final bugReportService = BugReportService();

      // Prepare data
      final Map<String, dynamic> bugData = {
        'device_type': _selectedDeviceType,
        'bug_type': _selectedBugType,
        'bug_description': _descriptionController.text,
      };

      // Handle image upload if selected
      if (_selectedImage != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final Uint8List bytes = await _selectedImage!.readAsBytes();
          bugData['bug_image_path'] = bytes;
          bugData['image_filename'] = _selectedImage!.name;
        } else {
          // For mobile, use file path
          bugData['bug_image_path'] = _selectedImage!.path;
        }
      }

      // Submit bug report
      await bugReportService.submitBugReport(bugData);

      setState(() {
        _successMessage = 'Laporan bug berhasil dikirim.';
        _selectedDeviceType = null;
        _selectedBugType = null;
        _descriptionController.clear();
        _selectedImage = null;
      });

      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengirim laporan bug: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Device Type Dropdown
              const Text(
                'Device',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDeviceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                hint: const Text('Pilih Device'),
                items: _deviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == 'mobile' ? 'Mobile' : 'Desktop'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipe perangkat wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bug Type Dropdown
              const Text(
                'Jenis Bug',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBugType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                hint: const Text('Pilih Jenis Bug'),
                items: _bugTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == 'tampilan' ? 'Tampilan' : 'Sistem'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBugType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis bug wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bug Image Picker
              const Text(
                'Gambar Bug (Opsional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: _selectedImage != null
                      ? kIsWeb
                          ? FutureBuilder<Uint8List>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            )
                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Ketuk untuk memilih gambar', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Bug Description
              const Text(
                'Deskripsi Bug',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Jelaskan bug yang Anda temukan...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi bug wajib diisi';
                  }
                  if (value.length > 2000) {
                    return 'Description must be less than 2000 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBugReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Kirim Laporan Bug'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
