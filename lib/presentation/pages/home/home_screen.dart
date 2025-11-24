import 'package:check_in_qr/presentation/pages/home/widget/event_card.dart';
import 'package:check_in_qr/presentation/pages/home/widget/summary_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Phần thẻ thống kê trên cùng - Đã cập nhật truyền tham số
            const SummaryCard(
              soldTickets: 1,
              totalTickets: 2000,
            ),
            const SizedBox(height: 24),

            // Danh sách các sự kiện
            EventCard(
              imageUrl: 'https://picsum.photos/200/300?random=1', // Placeholder ảnh
              title: '[TP.HCM] Những Thành Phố Mơ Màng Year End 2024',
              date: '31.12.2024',
              rating: '8/10',
              isHightlight: true, // Ví dụ để đổi màu viền ảnh nếu cần
            ),
            const SizedBox(height: 16),
            EventCard(
              imageUrl: 'https://picsum.photos/200/300?random=2',
              title: '[Nhà Hát THANH NIÊN] Hài kịch: Lạc lối ở BangKok',
              date: '25.12.2024',
              rating: '8/10',
            ),
            const SizedBox(height: 16),
            EventCard(
              imageUrl: 'https://picsum.photos/200/300?random=3',
              title: '1900 Future Hits #61: Quang Hùng MasterD',
              date: '21.11.2024',
              rating: '8/10',
            ),
            // Thêm khoảng trống dưới cùng để không bị che bởi các nút điều hướng nếu có
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}