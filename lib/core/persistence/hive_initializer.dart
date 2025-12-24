import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

Future<void> initHiveForApp() async {
  await Hive.initFlutter();
}

Future<void> openAppBoxes() async {
  await Hive.openBox(HiveBoxes.projects);
  await Hive.openBox(HiveBoxes.settings);
}
