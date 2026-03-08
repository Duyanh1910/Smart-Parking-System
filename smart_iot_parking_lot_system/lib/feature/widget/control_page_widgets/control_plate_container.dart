import 'package:flutter/material.dart';

class LicensePlateWidget extends StatelessWidget {
  final String plateNumber;

  const LicensePlateWidget({super.key, required this.plateNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // tăng padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3), // border dày hơn
        borderRadius: BorderRadius.circular(12), // bo góc lớn hơn
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, // tăng chiều rộng
            height: 32, // tăng chiều cao
            color: Colors.red,
            child: Center(
              child: Icon(Icons.star, color: Colors.yellow, size: 24), // icon to hơn
            ),
          ),
          SizedBox(width: 8), // tăng khoảng cách
          // Số biển
          Text(
            plateNumber,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 32, // chữ lớn hơn
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
