import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nood_food/services/open_food_facts_service.dart';

Future<Map<String, String>?> scanBarcode() async {
  String barcodeScanRes;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
  } on PlatformException {
    return null;
  }

  try {
    return await lookupBarcodeInOpenFoodFacts(barcodeScanRes);
  } on Exception {
    print(' Unable to get the food with barcode $barcodeScanRes');
  }
  return null;
}
