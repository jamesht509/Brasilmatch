import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (apenas em desenvolvimento)
  // Em produção, usa dart-define
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env não existe em produção, OK
    print('ℹ️  Rodando sem .env (produção)');
  }
  
  // Valida configuração
  if (!AppConfig.validate()) {
    throw Exception('Configuração inválida! Verifique suas credenciais.');
  }
  
  // Print config (apenas desenvolvimento)
  AppConfig.printConfig();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: BrasilMatchApp(),
    ),
  );
}
