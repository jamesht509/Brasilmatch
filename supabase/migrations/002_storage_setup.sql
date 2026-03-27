-- ============================================
-- MIGRATION: Setup Storage Bucket
-- ============================================
-- 
-- Este arquivo configura o bucket de fotos de perfil
-- no Supabase Storage com as políticas corretas
--

-- 1. Criar bucket 'profile-photos' se não existir
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Política: Qualquer usuário autenticado pode UPLOAD
-- ============================================
CREATE POLICY "Usuarios podem fazer upload de fotos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 3. Política: Qualquer um pode VER fotos (bucket é público)
-- ============================================
CREATE POLICY "Fotos de perfil são públicas"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profile-photos');

-- 4. Política: Usuários podem DELETAR apenas suas próprias fotos
-- ============================================
CREATE POLICY "Usuarios podem deletar suas próprias fotos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-photos'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 5. Política: Usuários podem ATUALIZAR apenas suas próprias fotos
-- ============================================
CREATE POLICY "Usuarios podem atualizar suas próprias fotos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-photos'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ============================================
-- EXPLICAÇÃO DAS POLÍTICAS:
-- ============================================
--
-- A função storage.foldername(name) retorna array com segmentos do path
-- Exemplo: Para 'userId/photo.jpg', retorna ['userId', 'photo.jpg']
-- 
-- (storage.foldername(name))[1] pega o primeiro segmento = userId
-- 
-- Comparamos com auth.uid() para garantir que o usuário só
-- mexe nas suas próprias fotos
--
-- O bucket é público (public: true) então as URLs das fotos
-- funcionam sem autenticação
-- ============================================

-- COMO EXECUTAR:
-- 1. Acesse Supabase Dashboard
-- 2. Vá em SQL Editor
-- 3. Cole este arquivo completo
-- 4. Clique em RUN
-- 5. Deve aparecer "Success"
