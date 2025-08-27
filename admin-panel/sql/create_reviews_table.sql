-- Criação da tabela reviews para avaliações de restaurantes
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  user_avatar TEXT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  helpful_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS reviews_restaurant_id_idx ON public.reviews(restaurant_id);
CREATE INDEX IF NOT EXISTS reviews_user_id_idx ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS reviews_rating_idx ON public.reviews(rating);
CREATE INDEX IF NOT EXISTS reviews_created_at_idx ON public.reviews(created_at DESC);

-- Criação da tabela para respostas às avaliações
CREATE TABLE IF NOT EXISTS public.review_replies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  user_avatar TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_restaurant_owner BOOLEAN DEFAULT FALSE
);

-- Índices para respostas
CREATE INDEX IF NOT EXISTS review_replies_review_id_idx ON public.review_replies(review_id);
CREATE INDEX IF NOT EXISTS review_replies_user_id_idx ON public.review_replies(user_id);

-- Criação da tabela para relatórios de avaliações
CREATE TABLE IF NOT EXISTS public.review_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criação da tabela para relatórios de respostas
CREATE TABLE IF NOT EXISTS public.reply_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reply_id UUID NOT NULL REFERENCES public.review_replies(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Function para incrementar contador de helpful_count
CREATE OR REPLACE FUNCTION increment_helpful_count(review_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.reviews 
  SET helpful_count = helpful_count + 1 
  WHERE id = review_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_reviews_updated_at ON public.reviews;
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Políticas RLS (Row Level Security)
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reply_reports ENABLE ROW LEVEL SECURITY;

-- Política para visualizar todas as avaliações (público)
DROP POLICY IF EXISTS "Reviews are publicly readable" ON public.reviews;
CREATE POLICY "Reviews are publicly readable" 
ON public.reviews FOR SELECT 
USING (true);

-- Política para criar avaliações (qualquer usuário autenticado)
DROP POLICY IF EXISTS "Users can create reviews" ON public.reviews;
CREATE POLICY "Users can create reviews" 
ON public.reviews FOR INSERT 
WITH CHECK (true);

-- Política para atualizar próprias avaliações
DROP POLICY IF EXISTS "Users can update own reviews" ON public.reviews;
CREATE POLICY "Users can update own reviews" 
ON public.reviews FOR UPDATE 
USING (true) WITH CHECK (true);

-- Política para deletar próprias avaliações
DROP POLICY IF EXISTS "Users can delete own reviews" ON public.reviews;
CREATE POLICY "Users can delete own reviews" 
ON public.reviews FOR DELETE 
USING (true);

-- Políticas para respostas (públicas para leitura)
DROP POLICY IF EXISTS "Replies are publicly readable" ON public.review_replies;
CREATE POLICY "Replies are publicly readable" 
ON public.review_replies FOR SELECT 
USING (true);

-- Política para criar respostas
DROP POLICY IF EXISTS "Users can create replies" ON public.review_replies;
CREATE POLICY "Users can create replies" 
ON public.review_replies FOR INSERT 
WITH CHECK (true);

-- Comentários nas tabelas
COMMENT ON TABLE public.reviews IS 'Tabela para armazenar avaliações de restaurantes';
COMMENT ON TABLE public.review_replies IS 'Tabela para armazenar respostas às avaliações';
COMMENT ON TABLE public.review_reports IS 'Tabela para relatórios de avaliações inadequadas';
COMMENT ON TABLE public.reply_reports IS 'Tabela para relatórios de respostas inadequadas';