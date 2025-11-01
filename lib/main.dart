import 'dart:io';

import 'package:dico/app.dart';
import 'package:dico/providers/app_provider.dart';
import 'package:dico/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await NotificationService().init();
  runApp(buildAppProviders(DictApp()));
}
