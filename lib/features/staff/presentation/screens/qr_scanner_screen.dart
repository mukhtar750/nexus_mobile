import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_provider.dart';
import '../../../profile/presentation/providers/user_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool _isProcessing = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        controller.stop();
        break;
      case AppLifecycleState.resumed:
        controller.start();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });

        // Haptic feedback for user confirmation
        await HapticFeedback.mediumImpact();

        // Verify ticket via backend
        await ref.read(staffProvider.notifier).verifyTicket(barcode.rawValue!);

        // The listener will handle navigation to the result screen
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isStaff = userState.user?.isStaff ?? false;

    if (!isStaff) {
      if (!_redirected) {
        _redirected = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff access only')),
          );
          context.go('/profile');
        });
      }
      return const SizedBox.shrink();
    }

    ref.listen(staffProvider, (previous, next) {
      if (next.error != null) {
        setState(() {
          _isProcessing = false;
        });
        context.push('/staff/scan/result', extra: {
          'success': false,
          'message': next.error!,
        });
        ref.read(staffProvider.notifier).reset();
      } else if (next.successMessage != null) {
        setState(() {
          _isProcessing = false;
        });
        context.push('/staff/scan/result', extra: {
          'success': true,
          'message': next.successMessage!,
          'data': next.verificationResult,
        });
        ref.read(staffProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Ticket', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              final torchIcon = state.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off;
              return IconButton(
                onPressed: () => controller.toggleTorch(),
                icon: Icon(torchIcon, color: Colors.white),
              );
            },
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          _buildOverlay(),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Verifying Ticket...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scanAreaSize = constraints.maxWidth * 0.7;
        return Stack(
          children: [
            // Darkened background
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Viewfinder border
            Center(
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Instructions
            Positioned(
              top: constraints.maxHeight / 2 + scanAreaSize / 2 + 32,
              left: 0,
              right: 0,
              child: const Text(
                'Align QR Code within the frame to scan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}
