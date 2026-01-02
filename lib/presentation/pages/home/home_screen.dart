import 'package:check_in_qr/presentation/pages/home/widget/event_card.dart';
import 'package:check_in_qr/presentation/pages/home/widget/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/event_detail_model.dart';
import '../../../routers/router_name.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    if (event.startTime == null || event.endTime == null)
      return const SizedBox();

    final now = DateTime.now();
    String text;
    Color color;
    Color bgColor;

    if (now.isBefore(event.startTime!)) {
      text = "Sắp diễn ra";
      color = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
    } else if (now.isAfter(event.endTime!)) {
      text = "Đã kết thúc";
      color = Colors.grey;
      bgColor = Colors.grey.withOpacity(0.1);
    } else {
      text = "Đang diễn ra";
      color = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
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
      backgroundColor: const Color(0xFF0B1221),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1221),
        elevation: 0,
        title: const Text(
          'Check-in Sự Kiện',
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
            return Center(child: Text('Lỗi: ${eventSnapshot.error}'));
          }
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventDocs = eventSnapshot.data?.docs ?? [];
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('orders')
                .where('paymentStatus', isEqualTo: 'completed')
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.hasError) {
                return Center(child: Text('Lỗi Order: ${orderSnapshot.error}'));
              }
              final orderDocs = orderSnapshot.data?.docs ?? [];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .snapshots(),
                builder: (context, ticketSnapshot) {
                  if (ticketSnapshot.hasError) {
                    return Center(
                      child: Text('Lỗi Ticket: ${ticketSnapshot.error}'),
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
                    if (!activeEventIds.contains(data['eventId'])) continue;
                    final List tickets = data['tickets'] ?? [];
                    for (var t in tickets) {
                      globalSold += parseQuantity(t['quantity']);
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
                      return orderData['eventId'] == event.id;
                    });

                    for (var orderDoc in relevantOrders) {
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      final List tickets = orderData['tickets'] ?? [];
                      for (var t in tickets) {
                        eventSold += parseQuantity(t['quantity']);
                      }
                    }

                    int eventCheckedIn = 0;
                    for (var ticketDoc in ticketDocs) {
                      final ticketData =
                          ticketDoc.data() as Map<String, dynamic>;
                      if (ticketData['eventId'] == event.id) {
                        eventCheckedIn += parseQuantity(
                          ticketData['checkedIn'],
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
                      'checkedIn': eventCheckedIn,
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
                          final checkedIn = item['checkedIn'] as int;
                          final realSold = item['realSold'] as int;
                          final bool isTimeValid = canCheckIn(event);
                          final bool isNotFull = realSold > 0 && checkedIn < realSold;
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
                                  : "Chưa có ngày",
                              rating: "$checkedIn/$realSold",

                              onTap: () {
                                if (!canCheckIn(event)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Sự kiện chưa diễn ra",
                                      ),
                                      backgroundColor: Colors.redAccent,
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
                        }).toList(),
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
      textVN = "Đang diễn ra";
      color = const Color(0xFF00E5C0);
      break;

    case 'INACTIVE':
      textVN = "Sắp diễn ra";
      color = const Color(0xFFF59E0B);
      break;

    case 'COMPLETED':
      textVN = "Đã kết thúc";
      color = const Color(0xFFEF4444);
      break;

    case 'CANCELLED':
      textVN = "Đã hủy";
      color = Colors.red;
      break;

    default:
      final now = DateTime.now();
      if (event.startTime != null && now.isBefore(event.startTime!)) {
        textVN = "Sắp diễn ra";
        color = Colors.orange;
      } else if (event.endTime != null && now.isAfter(event.endTime!)) {
        textVN = "Đã kết thúc";
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
