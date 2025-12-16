import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomeClassroomScreen extends StatelessWidget {
  const HomeClassroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lớp học của tôi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8),
        children: [
          buildCard(
            title: "XML và ứng dụng - Nhóm 1",
            code: "2025-2026.1.TIN4583.001",
            students: "58 học viên",
          ),
          buildCard(
            title: "Đồ án công nghệ phần mềm - Nhóm 1",
            code: "2025-2026.1.TIN4583.001",
            students: "23 học viên",
          ),
          buildCard(
            title: "Lập trình ứng dụng di động - Nhóm 2",
            code: "2025-2026.1.TIN4583.001",
            students: "68 học viên",
          ),
          buildCard(
            title: "Lập trình hướng đối tượng - Nhóm 2",
            code: "2025-2026.1.TIN4583.001",
            students: "68 học viên",
          ),
          buildCard(
            title: "Lập trình android - Nhóm 2",
            code: "2025-2026.1.TIN4583.001",
            students: "68 học viên",
          ),
        ],
      ),
    );
  }

  Widget buildCard({required String title, required String code, required String students}) {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
        image: DecorationImage(
          image: NetworkImage('https://tse3.mm.bing.net/th/id/OIP.5dJYOihKRkSgH_j7b3LUpQHaEo?pid=Api&P=0&h=220'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Handle image loading error
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.more_horiz_sharp,
                size: 28,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            code,
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
          Text(
            students,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

