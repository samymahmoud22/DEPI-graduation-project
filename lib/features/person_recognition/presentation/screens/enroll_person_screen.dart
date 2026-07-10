import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../domain/entities/person_entity.dart';

class EnrollPersonScreen extends ConsumerStatefulWidget {
  const EnrollPersonScreen({super.key});

  @override
  ConsumerState<EnrollPersonScreen> createState() => _EnrollPersonScreenState();
}

class _EnrollPersonScreenState extends ConsumerState<EnrollPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final t = ref.read(translationsProvider);
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('pick_image_error', [e.toString()])),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePerson() async {
    final t = ref.read(translationsProvider);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('select_image_first')),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Copy image to permanent documents directory
      final docDir = await getApplicationDocumentsDirectory();
      final id = const Uuid().v4();
      final extension = _selectedImage!.path.split('.').last;
      final permanentPath = '${docDir.path}/face_$id.$extension';
      
      final permanentFile = await _selectedImage!.copy(permanentPath);

      final person = PersonEntity(
        id: id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        jobTitle: _jobController.text.trim(),
        bio: _bioController.text.trim(),
        imagePath: permanentFile.path,
      );

      await ref.read(enrollPersonUseCaseProvider)(person);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('person_saved')),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('save_error', [e.toString()])),
            backgroundColor: AppColors.red,
          ),
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
    final t = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(t.get('enroll_person'), style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image preview & pick buttons
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.bottomNav,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryButton,
                            width: 3,
                          ),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.white70,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryButton,
                          radius: 22,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                            onPressed: () {
                              _showImageSourceActionSheet(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _buildInputDecoration(t.get('full_name'), Icons.badge_outlined),
                  validator: (value) => value == null || value.trim().isEmpty ? t.get('enter_name') : null,
                ),
                const SizedBox(height: 16),

                // Age Input
                TextFormField(
                  controller: _ageController,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(t.get('age'), Icons.cake_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return t.get('enter_age');
                    if (int.tryParse(value) == null) return t.get('valid_number');
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Job Title Input
                TextFormField(
                  controller: _jobController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: _buildInputDecoration(t.get('job_title'), Icons.work_outline),
                  validator: (value) => value == null || value.trim().isEmpty ? t.get('enter_job') : null,
                ),
                const SizedBox(height: 16),

                // Bio/Details Input
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: AppColors.white),
                  maxLines: 3,
                  decoration: _buildInputDecoration(t.get('bio_education'), Icons.description_outlined),
                  validator: (value) => value == null || value.trim().isEmpty ? t.get('enter_bio') : null,
                ),
                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePerson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(t.get('save_details'), style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final t = ref.read(translationsProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bottomNav,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.white),
              title: Text(t.get('take_photo'), style: const TextStyle(color: AppColors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.white),
              title: Text(t.get('choose_gallery'), style: const TextStyle(color: AppColors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.white70),
      prefixIcon: Icon(icon, color: AppColors.primaryButton),
      filled: true,
      fillColor: AppColors.bottomNav,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryButton, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 2),
      ),
    );
  }
}
