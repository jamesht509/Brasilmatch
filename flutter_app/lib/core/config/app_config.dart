import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração centralizada do app
/// Suporta desenvolvimento (.env) e produção (dart-define)
class AppConfig {
  // Supabase
  static String get supabaseUrl {
    // Tenta pegar de dart-define (produção)
    const dartDefine = String.fromEnvironment('SUPABASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    
    // Senão, pega do .env (desenvolvimento)
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    const dartDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (dartDefine.isNotEmpty) return dartDefine;
    
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
  
  // Agora (Video Call)
  static String get agoraAppId {
    const dartDefine = String.fromEnvironment('AGORA_APP_ID');
    if (dartDefine.isNotEmpty) return dartDefine;
    
    return dotenv.env['AGORA_APP_ID'] ?? '';
  }
  
  // Environment
  static String get environment {
    const dartDefine = String.fromEnvironment('ENV');
    if (dartDefine.isNotEmpty) return dartDefine;
    
    return dotenv.env['ENV'] ?? 'development';
  }
  
  // Helpers
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  
  // Validação
  static bool validate() {
    if (supabaseUrl.isEmpty) {
      print('❌ SUPABASE_URL não configurado!');
      return false;
    }
    if (supabaseAnonKey.isEmpty) {
      print('❌ SUPABASE_ANON_KEY não configurado!');
      return false;
    }
    return true;
  }
  
  // Debug info
  static void printConfig() {
    if (isDevelopment) {
      print('📱 BrasilMatch Config:');
      print('   Environment: $environment');
      print('   Supabase URL: ${supabaseUrl.substring(0, 30)}...');
      print('   Has Anon Key: ${supabaseAnonKey.isNotEmpty}');
      print('   Has Agora ID: ${agoraAppId.isNotEmpty}');
    }
  }
}
