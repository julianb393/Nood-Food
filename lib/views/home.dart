import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nood_food/services/open_food_facts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

import '../model/food.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _barcode = '';
  Food? _food;
  DateTime _selectedDay = DateTime.now();
  final dataMap = <String, double>{
    "Fat": 1,
    "Sugars": 1,
    "Saturated Fat": 1,
    "Protein": 1,
    "Sodium": 2,
  };
  final colorList = <Color>[
    const Color(0xfffdcb6e),
    const Color(0xff0984e3),
    const Color(0xfffd79a8),
    const Color(0xffe17055),
    const Color(0xff6c5ce7),
  ];

  void _scanBarcode() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() async {
      _barcode = barcodeScanRes;
      _food = await getFood(_barcode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Row(children: [Text('Welcome Julian!')]),
            // const SizedBox(height: 20.0),
            Text(DateFormat.yMMMMd().format(_selectedDay)),
            WeeklyDatePicker(
              selectedDay: _selectedDay,
              changeDay: (value) => setState(() {
                _selectedDay = value;
              }),
              enableWeeknumberText: false,
            ),
            const Text('Calories consumed today:'),
            FAProgressBar(
              currentValue: 1054,
              // size: 25,
              maxValue: 2056,
              changeColorValue: 2000,
              changeProgressColor: Colors.red,
              backgroundColor: Colors.white,
              progressColor: Colors.green,
              animatedDuration: const Duration(milliseconds: 300),
              direction: Axis.horizontal,
              verticalDirection: VerticalDirection.up,
              displayText: 'kcal',
            ),
            SizedBox(height: 10),
            PieChart(
              dataMap: dataMap,
              chartType: ChartType.disc,
              // baseChartColor: Colors.grey[50]!.withOpacity(0.15),
              // colorList: colorList,
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
              centerText: '1054',
              // totalValue: 20,
            ),
            ElevatedButton(onPressed: () {}, child: Text('Edit Meals')),
          ],
        ),
      ),
    );
  }
}
