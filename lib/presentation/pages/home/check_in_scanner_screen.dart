import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_storage_key.dart';
import '../../../core/base/base_view.dart';
import '../../../core/constants/app_strings.dart';
import '../../../injection/injection.dart';
import '../../view_models/home_view_model.dart';

class CheckInScannerScreen extends StatefulWidget {
  final String eventId;
  const CheckInScannerScreen({super.key, required this.eventId});

  @override
  State<CheckInScannerScreen> createState() => _CheckInScannerScreenState();
}

class _CheckInScannerScreenState extends State<CheckInScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _scanResult;

  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  int parseQuantity(dynamic q) {
    if (q == null) return 0;
    if (q is int) return q;
    if (q is double) return q.toInt();
    if (q is num) return q.toInt();
    return int.tryParse(q.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      autoDispose: false,
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.scanCheckInCode),
            actions: [
              IconButton(
                icon: Icon(
                  _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scannerController.toggleTorch();
                  setState(() => _isTorchOn = !_isTorchOn);
                },
              ),
              IconButton(
                icon: Icon(
                  _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scannerController.switchCamera();
                  setState(() => _isFrontCamera = !_isFrontCamera);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) =>
                    _handleDetection(context, viewModel, capture),
              ),
              if (_scanResult != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _scanResult!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleDetection(
    BuildContext context,
    HomeViewModel viewModel,
    BarcodeCapture capture,
  ) {
    if (_isProcessing) return;

    final String? orderId = capture.barcodes.first.rawValue;

    if (orderId != null && orderId.isNotEmpty) {
      setState(() {
        _isProcessing = true;
        _scanResult = "Đang xử lý mã: $orderId ...";
      });

      _processCheckInQuantity(context, viewModel, orderId);
    }
  }

  Future<void> _processCheckInQuantity(
    BuildContext context,
    HomeViewModel viewModel,
    String orderId,
  ) async {
    final ticket = await viewModel.getTicket(orderId);
    if (!context.mounted) return;

    if (ticket == null) {
      _showSnack(context, "Lỗi: Vé không tồn tại.");
      return _resetScanner();
    }

    if (ticket[AppStorageKey.eventId] != widget.eventId) {
      _showSnack(context, "Vé này KHÔNG thuộc sự kiện đang check-in!");
      return _resetScanner();
    }

    final List items = ticket[AppStorageKey.tickets];
    int totalQuantity = 0;
    for (var t in items) {
      totalQuantity += parseQuantity(t[AppStorageKey.quantity] ?? 1);
    }

    final int checkedIn = ticket[AppStorageKey.checkedIn] ?? 0;
    final int remaining = totalQuantity - checkedIn;

    if (remaining <= 0) {
      _showSnack(context, "Vé này đã sử dụng hết lượt check-in.");
      return _resetScanner();
    }

    if (totalQuantity < 2) {
      final msg = await viewModel.checkInQuantity(orderId, 1);
      if (!context.mounted) return;
      _showSnack(context, msg);
      return _resetScanner();
    }

    int input = 1;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nhập số lượng check-in"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tổng vé: $totalQuantity"),
            Text("Đã check-in: $checkedIn"),
            Text("Còn lại: $remaining"),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Số lượng muốn check-in"),
              onChanged: (v) => input = int.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Xác nhận"),
            onPressed: () async {
              if (input <= 0 || input > remaining) {
                _showSnack(context, "Số lượng không hợp lệ!");
                return;
              }

              Navigator.pop(context);

              final msg = await viewModel.checkInQuantity(orderId, input);
              if (!context.mounted) return;
              _showSnack(context, msg);
              _resetScanner();
            },
          ),
        ],
      ),
    );
  }

  void _resetScanner() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scanResult = null;
      });
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
