import 'package:flutter/material.dart';
import 'package:nood_food/common/date_picker.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/views/pages/account.dart';
import 'package:nood_food/views/pages/home.dart';
import 'package:nood_food/views/pages/meals/meals.dart';
import 'package:provider/provider.dart';

class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  final DBService _dbService = DBService(uid: AuthService().userUid);
  double dailyCaloriesAllowed = 3200.0;
  DateTime _selectedDay = DateTime.now();

  int _selectedPageIndex = 0;
  final List<String> _pageTitles = ['Nood Food', 'Meals', 'Account'];

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Food>>.value(
      value: _dbService.getFoodsFromDate(_selectedDay),
      initialData: const [],
      child: Scaffold(
        appBar: AppBar(title: Text(_pageTitles[_selectedPageIndex])),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 35,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood_outlined),
              activeIcon: Icon(Icons.fastfood),
              label: 'Meals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          backgroundColor: Colors.black54,
          elevation: 0,
          currentIndex: _selectedPageIndex,
          selectedItemColor: const Color.fromARGB(255, 170, 231, 220),
          onTap: (index) => setState(() => _selectedPageIndex = index),
        ),
        body: [
          Column(
            children: [
              DatePicker(
                selectedDate: _selectedDay,
                changeDay: (day) {
                  setState(() => _selectedDay = day);
                },
              ),
              const Expanded(child: Home()),
            ],
          ),
          Meals(day: _selectedDay),
          const Account(),
        ][_selectedPageIndex],
      ),
    );
  }
}
