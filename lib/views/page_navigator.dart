import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/views/pages/account/account.dart';
import 'package:nood_food/views/pages/chart/chart.dart';
import 'package:nood_food/views/pages/home.dart';
import 'package:nood_food/views/pages/meals/meals.dart';
import 'package:provider/provider.dart';

class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  late final AuthService _authService;
  late final DBService _dbService;
  double dailyCaloriesAllowed = 3200.0;
  DateTime _selectedDay = DateTime.now();
  late String? accIconUrl;

  int _selectedPageIndex = 0;
  final List<String> _pageTitles = ['Nood Food', 'Meals', 'Chart', 'Account'];

  // Will allow the home to control the date, which can get shared with others.
  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDay = newDate;
    });
  }

  DateTime _getSelectedDate() {
    return _selectedDay;
  }

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _dbService = DBService(uid: _authService.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Food>>.value(
      value: _dbService.getFoodsFromDate(_selectedDay),
      initialData: const [],
      child: StreamBuilder(
          stream: _dbService.userAccountInfo,
          builder: (context, AsyncSnapshot<NFUser?> snapshot) {
            if (!snapshot.hasData) {
              return const Loader();
            }
            Widget profilePic = CachedNetworkImage(
              imageUrl: snapshot.data!.photoURL!,
              placeholder: (context, val) => const Loader(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person_outlined),
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  radius: 18,
                  backgroundImage: imageProvider,
                );
              },
            );
            return Scaffold(
                appBar: AppBar(title: Text(_pageTitles[_selectedPageIndex])),
                bottomNavigationBar: BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  iconSize: 25,
                  items: <BottomNavigationBarItem>[
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.fastfood_outlined),
                      activeIcon: Icon(Icons.fastfood),
                      label: 'Meals',
                    ),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.show_chart),
                        activeIcon: Icon(Icons.show_chart_outlined),
                        label: 'Chart'),
                    BottomNavigationBarItem(
                      icon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        child: profilePic,
                      ),
                      activeIcon: CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        radius: 20,
                        child: profilePic,
                      ),
                      label: 'Account',
                    ),
                  ],
                  backgroundColor: Colors.black54,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  currentIndex: _selectedPageIndex,
                  selectedItemColor: const Color.fromARGB(255, 170, 231, 220),
                  onTap: (index) => setState(() => _selectedPageIndex = index),
                ),
                body: [
                  Home(
                    user: snapshot.data!,
                    updateDate: _updateSelectedDate,
                    getSelectedDate: _getSelectedDate,
                  ),
                  Meals(day: _selectedDay),
                  const Chart(),
                  Account(user: snapshot.data!),
                ][_selectedPageIndex]);
          }),
    );
  }
}
