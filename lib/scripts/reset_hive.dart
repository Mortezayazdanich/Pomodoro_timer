import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  final boxNames = ['projectsBox', 'sessionsBox'];
  for (final boxName in boxNames) {
    var box = await Hive.openBox(boxName);
    await box.clear();
    await box.close();
    print('Cleared $boxName');
  }
}