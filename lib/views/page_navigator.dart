import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/loader.dart';
import 'package:nood_food/models/food.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/auth_service.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:nood_food/views/pages/account/account.dart';
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
  Widget _accountIcon = const Icon(Icons.person_outlined);
  Widget _accountIconActive = const Icon(Icons.person);

  int _selectedPageIndex = 0;
  final List<String> _pageTitles = ['Nood Food', 'Meals', 'Account'];

  // Will allow the home to control the date, which can get shared with others.
  void _updateSelectedDate(DateTime newDate) {
    setState(() => _selectedDay = newDate);
  }

  DateTime _getSelectedDate() {
    return _selectedDay;
  }

  void _setAccountIcon(String? photoURL) {
    if (photoURL == null) return;
    // Will be triggered after build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          Widget profilePic = CachedNetworkImage(
            imageUrl: photoURL,
            placeholder: (context, val) => const Loader(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                radius: 18,
                backgroundImage: imageProvider,
              );
            },
          );
          _accountIcon = CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: profilePic,
          );
          _accountIconActive = CircleAvatar(
            backgroundColor: Colors.greenAccent,
            radius: 20,
            child: profilePic,
          );
        }));
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
      child: Scaffold(
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
            BottomNavigationBarItem(
              icon: _accountIcon,
              activeIcon: _accountIconActive,
              label: 'Account',
            ),
          ],
          backgroundColor: Colors.black54,
          elevation: 0,
          currentIndex: _selectedPageIndex,
          selectedItemColor: const Color.fromARGB(255, 170, 231, 220),
          onTap: (index) => setState(() => _selectedPageIndex = index),
        ),
        body: StreamBuilder(
          stream: _dbService.userAccountInfo,
          builder: (context, AsyncSnapshot<NFUser?> snapshot) {
            if (!snapshot.hasData) {
              return const Loader();
            }
            _setAccountIcon(snapshot.data!.photoURL);
            return [
              Home(
                user: snapshot.data!,
                updateDate: _updateSelectedDate,
                getSelectedDate: _getSelectedDate,
              ),
              Meals(day: _selectedDay),
              Account(user: snapshot.data!),
            ][_selectedPageIndex];
          },
        ),
      ),
    );
  }
}
