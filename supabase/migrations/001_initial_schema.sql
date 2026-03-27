-- BrasilMatch Database Schema
-- Execute este arquivo no Supabase SQL Editor

-- ============================================================================
-- TABELA: users
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age >= 18),
  bio TEXT,
  photos TEXT[] DEFAULT '{}',
  avatar_url TEXT,
  
  -- Localização atual
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'USA',
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  
  -- Origem brasileira
  brazilian_city TEXT NOT NULL,
  brazilian_state TEXT NOT NULL,
  
  -- Preferências
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  interested_in TEXT NOT NULL CHECK (interested_in IN ('male', 'female', 'both')),
  min_age INTEGER DEFAULT 18 CHECK (min_age >= 18),
  max_age INTEGER DEFAULT 50 CHECK (max_age <= 100),
  max_distance INTEGER DEFAULT 50, -- em km
  
  -- Verificação
  is_verified BOOLEAN DEFAULT FALSE,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  is_document_verified BOOLEAN DEFAULT FALSE,
  
  -- Créditos
  credits INTEGER DEFAULT 0 CHECK (credits >= 0),
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_users_location ON public.users(latitude, longitude);
CREATE INDEX idx_users_gender ON public.users(gender);
CREATE INDEX idx_users_interested_in ON public.users(interested_in);
CREATE INDEX idx_users_last_active ON public.users(last_active DESC);

-- ============================================================================
-- TABELA: swipes
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.swipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  swiper_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  swiped_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  direction TEXT NOT NULL CHECK (direction IN ('like', 'nope', 'super_like')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Evitar swipes duplicados
  UNIQUE(swiper_id, swiped_id)
);

CREATE INDEX idx_swipes_swiper ON public.swipes(swiper_id);
CREATE INDEX idx_swipes_swiped ON public.swipes(swiped_id);
CREATE INDEX idx_swipes_direction ON public.swipes(direction);

-- ============================================================================
-- TABELA: matches
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  matched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'unmatched', 'blocked')),
  last_message_preview TEXT,
  last_message_at TIMESTAMP WITH TIME ZONE,
  unread_count INTEGER DEFAULT 0,
  
  -- Garantir que cada par só tenha 1 match
  UNIQUE(user1_id, user2_id),
  
  -- Garantir que user1_id < user2_id (ordem consistente)
  CHECK (user1_id < user2_id)
);

CREATE INDEX idx_matches_user1 ON public.matches(user1_id);
CREATE INDEX idx_matches_user2 ON public.matches(user2_id);
CREATE INDEX idx_matches_status ON public.matches(status);
CREATE INDEX idx_matches_last_message ON public.matches(last_message_at DESC);

-- ============================================================================
-- TABELA: messages
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'video')),
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_messages_match ON public.messages(match_id, sent_at DESC);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX idx_messages_unread ON public.messages(receiver_id, is_read) WHERE is_read = FALSE;

-- ============================================================================
-- TABELA: credits_transactions
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.credits_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL, -- Positivo = ganhou, Negativo = gastou
  type TEXT NOT NULL CHECK (type IN ('purchase', 'spend', 'bonus', 'refund')),
  description TEXT,
  reference_id TEXT, -- ID da compra IAP ou ação
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_credits_user ON public.credits_transactions(user_id, created_at DESC);

-- ============================================================================
-- TABELA: reports
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reported_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('spam', 'harassment', 'fake', 'inappropriate', 'other')),
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by UUID REFERENCES public.users(id)
);

CREATE INDEX idx_reports_status ON public.reports(status);
CREATE INDEX idx_reports_reported ON public.reports(reported_id);

-- ============================================================================
-- TABELA: blocked_users
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.blocked_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(blocker_id, blocked_id)
);

CREATE INDEX idx_blocked_blocker ON public.blocked_users(blocker_id);
CREATE INDEX idx_blocked_blocked ON public.blocked_users(blocked_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS em todas as tabelas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credits_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocked_users ENABLE ROW LEVEL SECURITY;

-- Policies: users
CREATE POLICY "Users can view other users" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Policies: swipes
CREATE POLICY "Users can view their own swipes" ON public.swipes
  FOR SELECT USING (auth.uid() = swiper_id);

CREATE POLICY "Users can insert their own swipes" ON public.swipes
  FOR INSERT WITH CHECK (auth.uid() = swiper_id);

-- Policies: matches
CREATE POLICY "Users can view their matches" ON public.matches
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "System can create matches" ON public.matches
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their matches" ON public.matches
  FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Policies: messages
CREATE POLICY "Users can view messages in their matches" ON public.messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages" ON public.messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update their received messages" ON public.messages
  FOR UPDATE USING (auth.uid() = receiver_id);

-- Policies: credits_transactions
CREATE POLICY "Users can view their own transactions" ON public.credits_transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can create transactions" ON public.credits_transactions
  FOR INSERT WITH CHECK (true);

-- Policies: reports
CREATE POLICY "Users can create reports" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view their own reports" ON public.reports
  FOR SELECT USING (auth.uid() = reporter_id);

-- Policies: blocked_users
CREATE POLICY "Users can view who they blocked" ON public.blocked_users
  FOR SELECT USING (auth.uid() = blocker_id);

CREATE POLICY "Users can block others" ON public.blocked_users
  FOR INSERT WITH CHECK (auth.uid() = blocker_id);

CREATE POLICY "Users can unblock" ON public.blocked_users
  FOR DELETE USING (auth.uid() = blocker_id);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Função para criar match quando dois usuários dão like um no outro
CREATE OR REPLACE FUNCTION public.check_and_create_match()
RETURNS TRIGGER AS $$
DECLARE
  mutual_like_exists BOOLEAN;
  new_match_id UUID;
BEGIN
  -- Só processa se for 'like' ou 'super_like'
  IF NEW.direction IN ('like', 'super_like') THEN
    -- Verifica se o outro usuário também deu like
    SELECT EXISTS (
      SELECT 1 FROM public.swipes
      WHERE swiper_id = NEW.swiped_id
        AND swiped_id = NEW.swiper_id
        AND direction IN ('like', 'super_like')
    ) INTO mutual_like_exists;
    
    IF mutual_like_exists THEN
      -- Cria o match (garante user1_id < user2_id)
      INSERT INTO public.matches (user1_id, user2_id)
      VALUES (
        LEAST(NEW.swiper_id, NEW.swiped_id),
        GREATEST(NEW.swiper_id, NEW.swiped_id)
      )
      ON CONFLICT (user1_id, user2_id) DO NOTHING
      RETURNING id INTO new_match_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar match automático
CREATE TRIGGER on_swipe_check_match
  AFTER INSERT ON public.swipes
  FOR EACH ROW
  EXECUTE FUNCTION public.check_and_create_match();

-- Função para atualizar last_active
CREATE OR REPLACE FUNCTION public.update_last_active()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.users
  SET last_active = NOW()
  WHERE id = NEW.swiper_id OR id = NEW.sender_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers para atualizar last_active
CREATE TRIGGER on_swipe_update_active
  AFTER INSERT ON public.swipes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_last_active();

CREATE TRIGGER on_message_update_active
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_last_active();

-- ============================================================================
-- STORAGE BUCKETS
-- ============================================================================

-- Bucket para fotos de perfil
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Policy para upload de fotos
CREATE POLICY "Users can upload their own photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy para visualizar fotos (público)
CREATE POLICY "Anyone can view photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-photos');

-- Policy para deletar suas próprias fotos
CREATE POLICY "Users can delete their own photos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
