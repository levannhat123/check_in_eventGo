import 'package:check_in_qr/presentation/pages/home/widget/event_card.dart';
import 'package:check_in_qr/presentation/pages/home/widget/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              int globalSold = 0;
              for (var doc in orderDocs) {
                final data = doc.data() as Map<String, dynamic>;
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

                eventListDisplay.add({
                  'event': event,
                  'sold': eventSold,
                  'total': eventTotal,
                });
              }

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
                      final sold = item['sold'] as int;
                      final total = item['total'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EventCard(
                          imageUrl: event.bannerURL ?? "",
                          title: event.title,
                          date: event.startTime != null
                              ? "${event.startTime!.day}.${event.startTime!.month}.${event.startTime!.year}"
                              : "Chưa có ngày",
                          rating: "$sold/$total",
                          onTap: () {
                            context.push(RouterPath.check_in, extra: event.id);
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
      ),
    );
  }
}
