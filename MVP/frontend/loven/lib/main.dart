import 'package:flutter/material.dart';
import 'package:loven/app/app.dart';
import 'package:loven/app/bootstrap.dart';

Future<void> main() async {
  final bootstrapResult = await bootstrap();
  runApp(LovenApp(appPreferences: bootstrapResult.appPreferences));
}
