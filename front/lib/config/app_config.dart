import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  String? baseUrl;

  Future<void> init() async {
    baseUrl = dotenv.env['BASE_URL'];
  }
}
