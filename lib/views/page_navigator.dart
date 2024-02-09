import 'package:flutter/material.dart';
import 'package:nood_food/util/macronutrient.dart';
import 'package:nood_food/views/pages/account.dart';
import 'package:nood_food/views/pages/home.dart';
import 'package:nood_food/views/pages/meals/meals.dart';

class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  double dailyCaloriesAllowed = 3200.0;
  Map<String, double> totalConsumedSample = {
    'protein': 120,
    'carbs': 300,
    'fat': 150,
    'calories': computeTotalCalories(120, 300, 150),
  };

  int _selectedPageIndex = 0;
  final List<String> _pageTitles = ['Nood Food', 'Meals', 'Account'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: [const Home(), const Meals(), const Account()][_selectedPageIndex],
    );
  }
}
