import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/coffee_data.dart';
import '../data/coffee_ai_service.dart';

enum _CoffeeStage {
  intro,
  camera,
  loading,
  aiResult,
  manualResult,
  error,
}

class CoffeeFortuneScreen extends StatefulWidget {
  const CoffeeFortuneScreen({super.key});

  @override
  State<CoffeeFortuneScreen> createState() => _CoffeeFortuneScreenState();
}

class _CoffeeFortuneScreenState extends State<CoffeeFortuneScreen> {
  _CoffeeStage _stage = _CoffeeStage.intro;

  CoffeeSymbol? _manualResult;
  CoffeeAiResult? _aiResult;

  Uint8List? _capturedImageBytes;
  String? _errorMessage;

  final Random _random = Random();
  final ImagePicker _picker = ImagePicker();

  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _takingPicture = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SYMBOL ICON
  // ------------------------------------------------------------

  IconData _iconForSymbolName(String? name) {
    if (name == null) return Icons.auto_awesome;

    final match = coffeeSymbols.where(
      (s) => name.contains(s.name) || s.name.contains(name),
    );

    if (match.isNotEmpty) {
      return match.first.icon;
    }

    return Icons.auto_awesome;
  }

  // ------------------------------------------------------------
  // ASK USER
  // ------------------------------------------------------------

  Future<bool> _askCameraPermission() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'اجازه‌ی دسترسی به دوربین',
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'برای دیدن نقش واقعی فنجانت، باید از داخل فنجان عکس بگیریم. '
          'بعد از تأیید، دوربین دستگاه باز می‌شود.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('نه، فعلاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('اجازه می‌دم'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ------------------------------------------------------------
  // OPEN CAMERA
  // ------------------------------------------------------------

  Future<void> _openCamera() async {
    final allowed = await _askCameraPermission();

    if (!allowed) return;

    try {
      setState(() {
        _stage = _CoffeeStage.camera;
        _cameraInitialized = false;
        _errorMessage = null;
      });

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera found');
      }

      // ----------------------------------------------------------
      // انتخاب دوربین
      //
      // موبایل:
      // اولویت با دوربین پشت
      //
      // لپ‌تاپ:
      // معمولاً تنها Webcam موجود انتخاب می‌شود
      // ----------------------------------------------------------

      CameraDescription selectedCamera;

      final backCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      if (backCameras.isNotEmpty) {
        selectedCamera = backCameras.first;
      } else {
        selectedCamera = cameras.first;
      }

      await _cameraController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController = controller;

      // ----------------------------------------------------------
      // این قسمت در Web باعث درخواست واقعی اجازه دوربین
      // از مرورگر می‌شود.
      // ----------------------------------------------------------

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cameraInitialized = false;
        _errorMessage =
            'دوربین در دسترس نبود. لطفاً اجازه دسترسی به دوربین را در مرورگر فعال کن یا یک عکس از فنجان انتخاب کن.';
        _stage = _CoffeeStage.error;
      });
    }
  }

  // ------------------------------------------------------------
  // TAKE PHOTO
  // ------------------------------------------------------------

  Future<void> _capturePhoto() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _takingPicture) {
      return;
    }

    try {
      setState(() {
        _takingPicture = true;
      });

      final XFile photo = await controller.takePicture();

      final bytes = await photo.readAsBytes();

      await controller.dispose();
      _cameraController = null;

      if (!mounted) return;

      setState(() {
        _capturedImageBytes = bytes;
        _stage = _CoffeeStage.loading;
        _cameraInitialized = false;
        _takingPicture = false;
        _errorMessage = null;
      });

      await _analyzeImage(bytes);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _takingPicture = false;
        _errorMessage =
            'گرفتن عکس انجام نشد. دوباره امتحان کن یا یک عکس از فایل انتخاب کن.';
        _stage = _CoffeeStage.error;
      });
    }
  }

  // ------------------------------------------------------------
  // ANALYZE IMAGE
  // ------------------------------------------------------------

  Future<void> _analyzeImage(Uint8List bytes) async {
    try {
      final base64Image = base64Encode(bytes);

      final result = await CoffeeAiService.analyzeImage(base64Image);

      if (!mounted) return;

      setState(() {
        _aiResult = result;
        _stage = _CoffeeStage.aiResult;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'تحلیل تصویر انجام نشد. لطفاً دوباره امتحان کن.';
        _stage = _CoffeeStage.error;
      });
    }
  }

  // ------------------------------------------------------------
  // PICK IMAGE FROM FILE
  // ------------------------------------------------------------

  Future<void> _pickImageFromFile() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _capturedImageBytes = bytes;
        _stage = _CoffeeStage.loading;
        _errorMessage = null;
      });

      await _analyzeImage(bytes);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'انتخاب یا خواندن تصویر انجام نشد.';
        _stage = _CoffeeStage.error;
      });
    }
  }

  // ------------------------------------------------------------
  // MANUAL FORTUNE
  // ------------------------------------------------------------

  void _getManualFortune() {
    setState(() {
      _manualResult =
          coffeeSymbols[_random.nextInt(coffeeSymbols.length)];

      _stage = _CoffeeStage.manualResult;
    });
  }

  // ------------------------------------------------------------
  // RESET
  // ------------------------------------------------------------

  Future<void> _reset() async {
    await _cameraController?.dispose();
    _cameraController = null;

    if (!mounted) return;

    setState(() {
      _stage = _CoffeeStage.intro;
      _manualResult = null;
      _aiResult = null;
      _capturedImageBytes = null;
      _errorMessage = null;
      _cameraInitialized = false;
      _takingPicture = false;
    });
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فال قهوه'),
      ),
      body: Stack(
        children: [
          const StarFieldBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  switch (_stage) {
                    _CoffeeStage.intro => _buildIntro(),

                    _CoffeeStage.camera => _buildCamera(),

                    _CoffeeStage.loading => _buildLoading(),

                    _CoffeeStage.aiResult =>
                      _buildAiResult(_aiResult!),

                    _CoffeeStage.manualResult =>
                      _buildManualResult(_manualResult!),

                    _CoffeeStage.error => _buildError(),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------

  Widget _buildIntro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        const Icon(
          Icons.coffee_outlined,
          color: AppColors.gold,
          size: 64,
        ),

        const SizedBox(height: 20),

        Text(
          'فنجانت را ته‌نشین کن و برگردانش',
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        Text(
          'یه عکس واضح از داخل فنجانت بگیر تا نقش واقعی تفاله رو بخونیم.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('فنجان را ببینم'),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImageFromFile,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('انتخاب عکس از گالری'),
          ),
        ),

        const SizedBox(height: 14),

        TextButton(
          onPressed: _getManualFortune,
          child: Text(
            'یا فقط شانسی امتحان کن',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CAMERA SCREEN
  // ------------------------------------------------------------

  Widget _buildCamera() {
    if (!_cameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),

          const CircularProgressIndicator(
            color: AppColors.gold,
          ),

          const SizedBox(height: 20),

          Text(
            'در حال باز کردن دوربین...',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          Text(
            'اگر مرورگر اجازه خواست، گزینه Allow / اجازه را انتخاب کن.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          OutlinedButton(
            onPressed: _pickImageFromFile,
            child: const Text('انتخاب عکس از فایل'),
          ),
        ],
      );
    }

    final controller = _cameraController!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),

        Text(
          'دوربین آماده است',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'داخل فنجان را در کادر قرار بده',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _takingPicture ? null : _capturePhoto,
            icon: _takingPicture
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(
              _takingPicture
                  ? 'در حال گرفتن عکس...'
                  : 'گرفتن عکس',
            ),
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _pickImageFromFile,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('انتخاب عکس از فایل'),
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: _reset,
          child: const Text('انصراف'),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),

        if (_capturedImageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              _capturedImageBytes!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 24),

        const CircularProgressIndicator(
          color: AppColors.gold,
        ),

        const SizedBox(height: 16),

        Text(
          'در حال خواندن نقش‌های فنجانت...',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 48,
        ),

        const SizedBox(height: 16),

        Text(
          _errorMessage ?? 'خطایی رخ داد',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('دوباره باز کردن دوربین'),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImageFromFile,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('انتخاب عکس از فایل'),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _getManualFortune,
          child: Text(
            'یا فقط شانسی امتحان کن',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // AI RESULT
  // ------------------------------------------------------------

  Widget _buildAiResult(CoffeeAiResult result) {
    final icon = _iconForSymbolName(result.symbolName);

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_capturedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                _capturedImageBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 16),

          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            result.symbolName != null
                ? 'نقش «${result.symbolName}»'
                : 'تحلیل فنجانت',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorder,
              ),
            ),
            child: Text(
              result.interpretation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.9,
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('فنجان دیگر'),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: _reset,
            child: const Text('بازگشت'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MANUAL RESULT
  // ------------------------------------------------------------

  Widget _buildManualResult(CoffeeSymbol symbol) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold,
              ),
            ),
            child: Icon(
              symbol.icon,
              color: AppColors.gold,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'نقش «${symbol.name}»',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.gold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorder,
              ),
            ),
            child: Text(
              symbol.interpretation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.9,
              ),
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton(
            onPressed: _reset,
            child: const Text('فنجان دیگر'),
          ),
        ],
      ),
    );
  }
}