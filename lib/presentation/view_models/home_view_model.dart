import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/base/base_view_model.dart';

enum CaptchaResult { success, fail, lockedOut }

class HomeViewModel extends BaseViewModel {
  HomeViewModel() {}

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<String> processCheckIn(String orderId, String currentEventId) async {
    final ticketRef = _db.collection('tickets').doc(orderId);

    try {
      return await _db.runTransaction((transaction) async {
        final ticketDoc = await transaction.get(ticketRef);

        if (!ticketDoc.exists) {
          return "LỖI: Vé không hợp lệ hoặc không tồn tại.";
        }



        final data = ticketDoc.data();
        if (data == null) {
          return "LỖI: Không thể đọc dữ liệu vé.";
        }
        if (data['eventId'] != currentEventId) {
          return "LỖI: Vé này KHÔNG thuộc sự kiện đang check-in!";
        }
        if (data['paymentStatus'] != 'completed') {
          return "LỖI: Vé này chưa hoàn tất thanh toán.";
        }
        // 🔒 CHƯA TỚI GIỜ HOẶC ĐÃ KẾT THÚC
        final Timestamp? startTs = data['startTime'];
        final Timestamp? endTs = data['endTime'];

        if (startTs != null && endTs != null) {
          final now = DateTime.now();

          if (now.isBefore(startTs.toDate())) {
            return "Sự kiện chưa bắt đầu.";
          }

          if (now.isAfter(endTs.toDate())) {
            return "Sự kiện đã kết thúc.";
          }
        }

        final checkinStatus = data['checkinStatus'];
        if (checkinStatus == 'completed') {
          final timestamp = data['checkinTimestamp'] as Timestamp?;
          final timeStr = timestamp != null
              ? DateFormat('HH:mm dd/MM/yyyy').format(timestamp.toDate())
              : 'không rõ';
          return "LỖI: Vé này đã được check-in lúc $timeStr.";
        }
        transaction.update(ticketRef, {
          'checkinStatus': 'completed',
          'checkinTimestamp': FieldValue.serverTimestamp(),
        });

        final email = data['userEmail'] ?? 'Khách';
        return "THÀNH CÔNG: Check-in cho [$email] thành công!";
      });
    } catch (e) {
      return "LỖI HỆ THỐNG: Vui lòng thử lại sau.";
    }
  }

  Future<Map<String, dynamic>?> getTicket(String orderId) async {
    final snap = await _db.collection('tickets').doc(orderId).get();
    return snap.data();
  }

  int parseQuantity(dynamic q) {
    if (q == null) return 0;
    if (q is int) return q;
    if (q is double) return q.toInt();
    if (q is num) return q.toInt();
    return int.tryParse(q.toString()) ?? 0;
  }

  Future<String> checkInQuantity(String orderId, int count) async {
    final ref = _db.collection('tickets').doc(orderId);

    try {
      return await _db.runTransaction((transaction) async {
        final snap = await transaction.get(ref);

        if (!snap.exists) return "Lỗi: Vé không tồn tại.";

        final data = snap.data()!;
        final List items = data['tickets'] ?? [];
        int totalQuantity = 0;
        for (var t in items) {
          totalQuantity += parseQuantity(t['quantity'] ?? 1);
        }

        final int checkedIn = data['checkedIn'] ?? 0;
        final int remaining = totalQuantity - checkedIn;

        if (remaining <= 0) {
          return "Vé đã được sử dụng hết.";
        }

        if (count > remaining) {
          return "Không thể check-in vượt quá số còn lại.";
        }

        final newCheckedIn = checkedIn + count;

        transaction.update(ref, {
          "checkedIn": newCheckedIn,
          "checkinTimestamp": FieldValue.serverTimestamp(),
          "checkinStatus": newCheckedIn == totalQuantity
              ? "completed"
              : "partial",
        });

        return "Check-in thành công $count người!";
      });
    } catch (e) {
      return "Lỗi check-in: $e";
    }
  }
}
