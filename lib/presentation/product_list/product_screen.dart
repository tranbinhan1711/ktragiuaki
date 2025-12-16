import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_test/presentation/home_classroom/home_classroom_screen.dart';
import 'package:mobile_test/presentation/welcome_charlie/welcome_charlie_screen.dart';
import 'package:mobile_test/presentation/timer_counter/selection_screen.dart';
import 'package:mobile_test/presentation/login_register/selection_screen.dart';
import 'package:mobile_test/presentation/bmi_feedback/selection_screen.dart';
import 'package:mobile_test/presentation/ecommerce/product_list_screen.dart';
import 'package:mobile_test/presentation/login_profile/login_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Iconsax.menu_board),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Danh sách bài tập',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 80),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 1: Home Classroom'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeClassroomScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 2: Welcome Charlie'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeCharlieScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 3: Bộ đếm thời gian & Đếm số'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 4: Form Login và Register'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginRegisterSelectionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 5: Bài tập BMI & Gửi phản hồi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BMIFeedbackSelectionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 6: Thương mại điện tử - WebAPI'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text(
                'Bài tập 7: Thương mại điện tử & Chi tiết sản phẩm - WebAPI',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.book),
              title: Text('Bài tập 8: Login & Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.withOpacity(0.015),
        child: Center(child: Text('Nội dung chính')),
      ),
    );
  }
}
