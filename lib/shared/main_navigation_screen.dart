import 'package:flutter/material.dart';
import '../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/fal_list/presentation/fal_list_screen.dart';
import '../features/istikhara/presentation/istikhara_screen.dart';
import '../features/learning/presentation/learning_list_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'placeholder_screen.dart';
import '../core/services/browser_back_handler.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}


class _MainNavigationScreenState extends State<MainNavigationScreen> {

  int _currentIndex = 0;


  final List<Widget> _screens = const [

    HomeScreen(),

    FalListScreen(),

    AiAssistantScreen(),



    LearningListScreen(),

    ProfileScreen(),

  ];

  @override
  void initState() {
    super.initState();

    // دکمه/ژست برگشت گوشی: اگه رو تب خانه نیستیم، اول برگرد به
    // تب خانه (رفتار استاندارد اپ‌های نوار پایین‌دار). فقط وقتی
    // از قبل تو تب خانه‌ایم، اجازه می‌دیم از سایت خارج بشه.
    BrowserBackHandler.rootBackInterceptor = () {
      if (_currentIndex != 0) {
        setState(() => _currentIndex = 0);
        return true;
      }
      return false;
    };
  }

  @override
  void dispose() {
    BrowserBackHandler.rootBackInterceptor = null;
    super.dispose();
  }


  void openIstikhara(){

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IstikharaScreen(),
      ),
    );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),



      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _currentIndex,

        onTap: (index){

          setState(() {

            _currentIndex = index;

          });

        },


        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'خانه',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'فال‌ها',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: 'هوش مصنوعی',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'آموزش',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'پروفایل',
          ),

        ],

      ),

    );

  }

}