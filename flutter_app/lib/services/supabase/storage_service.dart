import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service para gerenciar uploads de fotos no Supabase Storage
/// 
/// Responsabilidades:
/// - Comprimir imagens antes do upload (otimização)
/// - Fazer upload para bucket 'profile-photos'
/// - Gerar URLs públicas das fotos
/// - Deletar fotos antigas se necessário
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Nome do bucket no Supabase Storage
  static const String bucketName = 'profile-photos';
  
  /// Tamanho máximo da imagem (largura/altura)
  static const int maxImageSize = 1200;
  
  /// Qualidade da compressão (0-100)
  static const int compressionQuality = 85;
  
  /// Tamanho máximo do arquivo em bytes (500KB)
  static const int maxFileSizeBytes = 500 * 1024;

  /// Upload de uma foto de perfil
  /// 
  /// [filePath] - Path local da imagem escolhida
  /// [userId] - ID do usuário (para organizar no storage)
  /// 
  /// Retorna a URL pública da foto uploadada ou null em caso de erro
  Future<String?> uploadProfilePhoto({
    required String filePath,
    required String userId,
  }) async {
    try {
      print('📸 Iniciando upload de foto...');
      print('   Path original: $filePath');
      
      // PASSO 1: Comprimir a imagem
      final compressedFile = await _compressImage(filePath);
      if (compressedFile == null) {
        print('❌ Falha ao comprimir imagem');
        return null;
      }
      
      print('✅ Imagem comprimida: ${compressedFile.lengthSync()} bytes');
      
      // PASSO 2: Gerar nome único para o arquivo
      // Formato: userId/timestamp_randomId.jpg
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(filePath);
      final fileName = '$userId/${timestamp}_${_generateRandomId()}$extension';
      
      print('📁 Nome do arquivo: $fileName');
      
      // PASSO 3: Upload para Supabase Storage
      final uploadPath = await _supabase.storage
          .from(bucketName)
          .upload(
            fileName,
            compressedFile,
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache de 1 hora
              upsert: false, // Não sobrescrever se já existir
            ),
          );
      
      print('✅ Upload concluído: $uploadPath');
      
      // PASSO 4: Gerar URL pública
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      
      print('🔗 URL pública: $publicUrl');
      
      // PASSO 5: Limpar arquivo temporário comprimido
      await compressedFile.delete();
      
      return publicUrl;
      
    } catch (e) {
      print('❌ Erro no upload: $e');
      return null;
    }
  }
  
  /// Upload de múltiplas fotos (para perfil completo)
  /// 
  /// [filePaths] - Lista de paths das imagens
  /// [userId] - ID do usuário
  /// 
  /// Retorna lista de URLs públicas (pode ter nulls se algum upload falhar)
  Future<List<String>> uploadMultiplePhotos({
    required List<String> filePaths,
    required String userId,
  }) async {
    print('📸 Uploading ${filePaths.length} fotos...');
    
    final urls = <String>[];
    
    for (int i = 0; i < filePaths.length; i++) {
      print('\n🔄 Foto ${i + 1}/${filePaths.length}');
      
      final url = await uploadProfilePhoto(
        filePath: filePaths[i],
        userId: userId,
      );
      
      if (url != null) {
        urls.add(url);
      } else {
        print('⚠️ Falha no upload da foto ${i + 1}');
      }
    }
    
    print('\n✅ Upload completo: ${urls.length}/${filePaths.length} fotos');
    return urls;
  }
  
  /// Deletar uma foto do storage
  /// 
  /// [photoUrl] - URL pública da foto a ser deletada
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      // Extrair o path do arquivo da URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      // O path é: /storage/v1/object/public/profile-photos/userId/filename.jpg
      // Precisamos de: userId/filename.jpg
      final filePath = pathSegments.sublist(pathSegments.indexOf(bucketName) + 1).join('/');
      
      await _supabase.storage
          .from(bucketName)
          .remove([filePath]);
      
      print('🗑️ Foto deletada: $filePath');
      return true;
      
    } catch (e) {
      print('❌ Erro ao deletar foto: $e');
      return false;
    }
  }
  
  /// Comprimir imagem para otimizar upload
  /// 
  /// Reduz tamanho do arquivo mantendo qualidade aceitável
  Future<File?> _compressImage(String filePath) async {
    try {
      // Pegar diretório temporário
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${path.basename(filePath)}',
      );
      
      // Comprimir imagem
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: compressionQuality,
        minWidth: maxImageSize,
        minHeight: maxImageSize,
        format: CompressFormat.jpeg, // Sempre salvar como JPEG
      );
      
      if (compressedFile == null) {
        return null;
      }
      
      // Verificar se o arquivo comprimido está dentro do limite
      final fileSize = await compressedFile.length();
      
      if (fileSize > maxFileSizeBytes) {
        print('⚠️ Arquivo ainda muito grande: $fileSize bytes');
        // Tentar comprimir mais
        final secondPass = await FlutterImageCompress.compressAndGetFile(
          compressedFile.path,
          targetPath.replaceAll('.jpg', '_2.jpg'),
          quality: 70, // Qualidade menor
          minWidth: 800,
          minHeight: 800,
        );
        
        // Deletar primeiro arquivo
        await compressedFile.delete();
        
        return secondPass != null ? File(secondPass.path) : null;
      }
      
      return File(compressedFile.path);
      
    } catch (e) {
      print('❌ Erro ao comprimir imagem: $e');
      return null;
    }
  }
  
  /// Gerar ID aleatório para nome do arquivo
  String _generateRandomId() {
    final random = DateTime.now().microsecondsSinceEpoch;
    return random.toRadixString(36); // Base 36 (0-9, a-z)
  }
}
