import 'package:check_in_qr/presentation/pages/home/widget/event_card.dart';
import 'package:check_in_qr/presentation/pages/home/widget/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_storage_key.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/event_detail_model.dart';
import '../../../routers/router_name.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int parseQuantity(dynamic q) {
    if (q == null) return 0;
    if (q is int) return q;
    if (q is double) return q.toInt();
    if (q is num) return q.toInt();
    return int.tryParse(q.toString()) ?? 0;
  }

  int _calculateEventTotalTickets(EventDetailModel event) {
    if (event.ticketType == null) return 0;
    int total = 0;
    for (var t in event.ticketType!) {
      total += t.totalQuantity ?? 0;
    }
    return total;
  }

  bool isEventDisplayable(EventDetailModel event) {
    if (event.endTime == null) return false;
    final now = DateTime.now();
    return now.isBefore(event.endTime!);
  }

  bool canCheckIn(EventDetailModel event) {
    if (event.startTime == null || event.endTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(event.startTime!) && now.isBefore(event.endTime!);
  }

  Widget _buildEventStatusTag(EventDetailModel event) {
    if (event.startTime == null || event.endTime == null) {
      return const SizedBox();
    }

    final now = DateTime.now();
    String text;
    Color color;
    Color bgColor;

    if (now.isBefore(event.startTime!)) {
      text = AppStrings.upcomingStatus;
      color = Colors.orange;
      bgColor = Colors.orange.withValues(alpha: 0.1);
    } else if (now.isAfter(event.endTime!)) {
      text = AppStrings.endedStatus;
      color = Colors.grey;
      bgColor = Colors.grey.withValues(alpha: 0.1);
    } else {
      text = AppStrings.happeningStatus;
      color = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground,
        elevation: 0,
        title: const Text(
          AppStrings.checkInScreenTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.hasError) {
            return Center(
              child: Text(
                AppStrings.eventLoadError.replaceFirst(
                  '{error}',
                  '${eventSnapshot.error}',
                ),
              ),
            );
          }
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventDocs = eventSnapshot.data?.docs ?? [];
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup(AppStorageKey.ordersCollection)
                .where(
                  AppStorageKey.paymentStatus,
                  isEqualTo: AppStorageKey.statusCompleted,
                )
                .orderBy(AppStorageKey.createdAt)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.hasError) {
                return Center(
                  child: Text(
                    AppStrings.orderLoadError.replaceFirst(
                      '{error}',
                      '${orderSnapshot.error}',
                    ),
                  ),
                );
              }
              final orderDocs = orderSnapshot.data?.docs ?? [];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppStorageKey.ticketsCollection)
                    .snapshots(),
                builder: (context, ticketSnapshot) {
                  if (ticketSnapshot.hasError) {
                    return Center(
                      child: Text(
                        AppStrings.ticketLoadError.replaceFirst(
                          '{error}',
                          '${ticketSnapshot.error}',
                        ),
                      ),
                    );
                  }

                  final ticketDocs = ticketSnapshot.data?.docs ?? [];
                  final Set<String> activeEventIds = {};

                  for (var doc in eventDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    final event = EventDetailModel.fromJson(data);
                    if (isEventDisplayable(event)) {
                      activeEventIds.add(event.id);
                    }
                  }

                  int globalSold = 0;
                  for (var doc in orderDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (!activeEventIds.contains(data[AppStorageKey.eventId])) {
                      continue;
                    }
                    final List tickets = data[AppStorageKey.tickets] ?? [];
                    for (var t in tickets) {
                      globalSold += parseQuantity(t[AppStorageKey.quantity]);
                    }
                  }

                  int globalTotal = 0;
                  List<Map<String, dynamic>> eventListDisplay = [];

                  for (var doc in eventDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;

                    final event = EventDetailModel.fromJson(data);
                    if (!isEventDisplayable(event)) continue;

                    final eventTotal = _calculateEventTotalTickets(event);
                    globalTotal += eventTotal;

                    int eventSold = 0;
                    final relevantOrders = orderDocs.where((orderDoc) {
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      return orderData[AppStorageKey.eventId] == event.id;
                    });

                    for (var orderDoc in relevantOrders) {
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      final List tickets =
                          orderData[AppStorageKey.tickets] ?? [];
                      for (var t in tickets) {
                        eventSold += parseQuantity(t[AppStorageKey.quantity]);
                      }
                    }

                    int eventCheckedIn = 0;
                    for (var ticketDoc in ticketDocs) {
                      final ticketData =
                          ticketDoc.data() as Map<String, dynamic>;
                      if (ticketData[AppStorageKey.eventId] == event.id) {
                        eventCheckedIn += parseQuantity(
                          ticketData[AppStorageKey.checkedIn],
                        );
                      }
                    }

                    final displaySold = (eventSold - eventCheckedIn).clamp(
                      0,
                      eventSold,
                    );

                    eventListDisplay.add({
                      'event': event,
                      'sold': displaySold,
                      'total': eventTotal,
                      AppStorageKey.checkedIn: eventCheckedIn,
                      'realSold': eventSold,
                    });
                  }

                  eventListDisplay.sort((a, b) {
                    final eventA = a['event'] as EventDetailModel;
                    final eventB = b['event'] as EventDetailModel;

                    final bool isHappeningA = canCheckIn(eventA);
                    final bool isHappeningB = canCheckIn(eventB);
                    if (isHappeningA && !isHappeningB) return -1;
                    if (!isHappeningA && isHappeningB) return 1;
                    if (eventA.startTime != null && eventB.startTime != null) {
                      return eventA.startTime!.compareTo(eventB.startTime!);
                    }
                    return 0;
                  });
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SummaryCard(
                          soldTickets: globalSold,
                          totalTickets: globalTotal,
                        ),

                        const SizedBox(height: 24),

                        ...eventListDisplay.map((item) {
                          final event = item['event'] as EventDetailModel;
                          final checkedIn =
                              item[AppStorageKey.checkedIn] as int;
                          final realSold = item['realSold'] as int;
                          final bool isTimeValid = canCheckIn(event);
                          final bool isNotFull =
                              realSold > 0 && checkedIn < realSold;
                          final bool isEnabled = isTimeValid && isNotFull;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: EventCard(
                              isEnabled: isEnabled,
                              imageUrl: event.bannerURL ?? "",
                              title: event.title,
                              statusTag: _buildEventStatusTag(event),
                              date: event.startTime != null
                                  ? DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(event.startTime!)
                                  : AppStrings.noDate,
                              rating: "$checkedIn/$realSold",

                              onTap: () {
                                if (!canCheckIn(event)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(AppStrings.eventNotStarted),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                context.push(
                                  RouterPath.check_in,
                                  extra: event.id,
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildEventStatusTag(EventDetailModel event) {
  String statusEN = event.status ?? '';
  String textVN = "";
  Color color = Colors.grey;
  switch (statusEN.toUpperCase()) {
    case 'ACTIVE':
      textVN = AppStrings.happeningStatus;
      color = AppColors.checkInGradientStart;
      break;

    case 'INACTIVE':
      textVN = AppStrings.upcomingStatus;
      color = AppColors.warning;
      break;

    case 'COMPLETED':
      textVN = AppStrings.endedStatus;
      color = AppColors.error;
      break;

    case 'CANCELLED':
      textVN = AppStrings.cancelled;
      color = AppColors.error;
      break;

    default:
      final now = DateTime.now();
      if (event.startTime != null && now.isBefore(event.startTime!)) {
        textVN = AppStrings.upcomingStatus;
        color = Colors.orange;
      } else if (event.endTime != null && now.isAfter(event.endTime!)) {
        textVN = AppStrings.endedStatus;
        color = Colors.grey;
      } else {
        textVN = statusEN;
        color = Colors.white;
      }
  }
  return Text(
    textVN.toUpperCase(),
    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
  );
}
