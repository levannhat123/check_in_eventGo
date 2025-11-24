import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format tiền tệ

class OrderHistoryCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final String orderCode;
  final DateTime orderDate;
  final double amount;
  final VoidCallback? onTap;

  const OrderHistoryCard({
    super.key,
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.orderCode,
    required this.orderDate,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy - HH:mm');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusTag(statusText, statusColor),
            const SizedBox(height: 12),
            _buildDetailRow('Mã đơn hàng', orderCode),
            _buildDetailRow('Đặt hàng', dateFormatter.format(orderDate)),
            _buildDetailRow('Thành tiền', currencyFormatter.format(amount)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontFamily: 'Roboto', // Đảm bảo font chữ đồng nhất
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w500, // In đậm giá trị
              ),
            ),
          ],
        ),
      ),
    );
  }
}
