import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nood_food/model/food.dart';

import 'open_food_facts.dart';

Future<Food?> scanBarcode() async {
  String barcodeScanRes;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
  } on PlatformException {
    print('Failed to get platform version.');
    return null;
  }

  try {
    return await getFood(barcodeScanRes);
  } on Exception {
    print(' Unable to get the food with barcode $barcodeScanRes');
  }
  return null;
}
