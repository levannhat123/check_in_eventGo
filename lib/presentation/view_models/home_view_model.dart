import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/base/base_view_model.dart';
import '../../core/constants/app_storage_key.dart';
import '../../core/constants/app_strings.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<String> processCheckIn(String orderId, String currentEventId) async {
    final ticketRef = _db
        .collection(AppStorageKey.ticketsCollection)
        .doc(orderId);
    try {
      return await _db.runTransaction((transaction) async {
        final ticketDoc = await transaction.get(ticketRef);

        if (!ticketDoc.exists) {
          return AppStrings.invalidOrMissingTicketError;
        }

        final data = ticketDoc.data();
        if (data == null) {
          return AppStrings.ticketReadError;
        }
        if (data[AppStorageKey.eventId] != currentEventId) {
          return AppStrings.wrongEventTicketError;
        }
        if (data[AppStorageKey.paymentStatus] !=
            AppStorageKey.statusCompleted) {
          return AppStrings.unpaidTicketError;
        }
        final Timestamp? startTs = data[AppStorageKey.startTime];
        final Timestamp? endTs = data[AppStorageKey.endTime];

        if (startTs != null && endTs != null) {
          final now = DateTime.now();

          if (now.isBefore(startTs.toDate())) {
            return AppStrings.eventNotStartedError;
          }

          if (now.isAfter(endTs.toDate())) {
            return AppStrings.eventEndedError;
          }
        }

        final checkinStatus = data[AppStorageKey.checkInStatus];
        if (checkinStatus == AppStorageKey.statusCompleted) {
          final timestamp = data[AppStorageKey.checkInTimestamp] as Timestamp?;
          final timeStr = timestamp != null
              ? DateFormat('HH:mm dd/MM/yyyy').format(timestamp.toDate())
              : AppStrings.unknownTime;
          return AppStrings.alreadyCheckedInAt.replaceFirst('{time}', timeStr);
        }
        transaction.update(ticketRef, {
          AppStorageKey.checkInStatus: AppStorageKey.statusCompleted,
          AppStorageKey.checkInTimestamp: FieldValue.serverTimestamp(),
        });

        final email = data[AppStorageKey.userEmail] ?? AppStrings.guestLabel;
        return AppStrings.checkInSuccessWithEmail.replaceFirst(
          '{email}',
          '$email',
        );
      });
    } catch (e) {
      return AppStrings.checkInSystemError;
    }
  }

  Future<Map<String, dynamic>?> getTicket(String orderId) async {
    final snap = await _db
        .collection(AppStorageKey.ticketsCollection)
        .doc(orderId)
        .get();
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
    final ref = _db.collection(AppStorageKey.ticketsCollection).doc(orderId);

    try {
      return await _db.runTransaction((transaction) async {
        final snap = await transaction.get(ref);

        if (!snap.exists) return AppStrings.ticketNotFoundError;

        final data = snap.data()!;
        final List items = data[AppStorageKey.tickets] ?? [];
        int totalQuantity = 0;
        for (var t in items) {
          totalQuantity += parseQuantity(t[AppStorageKey.quantity] ?? 1);
        }

        final int checkedIn = data[AppStorageKey.checkedIn] ?? 0;
        final int remaining = totalQuantity - checkedIn;

        if (remaining <= 0) {
          return AppStrings.ticketExhaustedError;
        }

        if (count > remaining) {
          return AppStrings.checkInExceedRemainingError;
        }

        final newCheckedIn = checkedIn + count;

        transaction.update(ref, {
          AppStorageKey.checkedIn: newCheckedIn,
          AppStorageKey.checkInTimestamp: FieldValue.serverTimestamp(),
          AppStorageKey.checkInStatus: newCheckedIn == totalQuantity
              ? AppStorageKey.statusCompleted
              : AppStorageKey.statusPartial,
        });

        return AppStrings.checkInCountSuccess.replaceFirst('{count}', '$count');
      });
    } catch (e) {
      return AppStrings.checkInErrorWithDetails.replaceFirst('{error}', '$e');
    }
  }
}
