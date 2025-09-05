-- Migração para implementar funcionalidades completas de reviews
-- Execute este script no Supabase SQL Editor

-- 1. Tabela para respostas às avaliações
CREATE TABLE IF NOT EXISTS review_replies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_avatar TEXT,
  content TEXT NOT NULL,
  is_restaurant_owner BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela para reportes de avaliações
CREATE TABLE IF NOT EXISTS review_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  -- Evitar múltiplos reportes do mesmo usuário para a mesma review
  UNIQUE(review_id, user_id)
);

-- 3. Tabela para controlar votos "útil" nas avaliações
CREATE TABLE IF NOT EXISTS review_helpful_votes (
  review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (review_id, user_id)
);

-- 4. Tabela para reportes de respostas
CREATE TABLE IF NOT EXISTS reply_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reply_id UUID REFERENCES review_replies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(reply_id, user_id)
);

-- 5. Função para alternar voto "útil" (toggle)
CREATE OR REPLACE FUNCTION toggle_helpful_vote(p_review_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  -- Verificar se o voto já existe
  SELECT EXISTS(
    SELECT 1 FROM review_helpful_votes 
    WHERE review_id = p_review_id AND user_id = p_user_id
  ) INTO v_exists;
  
  IF v_exists THEN
    -- Remover voto e decrementar contador
    DELETE FROM review_helpful_votes 
    WHERE review_id = p_review_id AND user_id = p_user_id;
    
    UPDATE reviews 
    SET helpful_count = GREATEST(helpful_count - 1, 0)
    WHERE id = p_review_id;
    
    RETURN false; -- Voto removido
  ELSE
    -- Adicionar voto e incrementar contador
    INSERT INTO review_helpful_votes (review_id, user_id) 
    VALUES (p_review_id, p_user_id);
    
    UPDATE reviews 
    SET helpful_count = helpful_count + 1 
    WHERE id = p_review_id;
    
    RETURN true; -- Voto adicionado
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro, não alterar nada
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Função para obter estatísticas detalhadas de reviews
CREATE OR REPLACE FUNCTION get_restaurant_review_stats(p_restaurant_id UUID)
RETURNS JSON AS $$
DECLARE
  v_stats JSON;
  v_total_reviews INTEGER;
  v_average_rating DECIMAL(3,2);
  v_rating_distribution JSON;
BEGIN
  -- Calcular total de reviews
  SELECT COUNT(*) INTO v_total_reviews
  FROM reviews 
  WHERE restaurant_id = p_restaurant_id;
  
  -- Calcular média
  SELECT COALESCE(AVG(rating), 0)::DECIMAL(3,2) INTO v_average_rating
  FROM reviews 
  WHERE restaurant_id = p_restaurant_id;
  
  -- Calcular distribuição por rating
  SELECT json_object_agg(rating_value, rating_count) INTO v_rating_distribution
  FROM (
    SELECT 
      r.rating as rating_value,
      COUNT(*) as rating_count
    FROM reviews r
    WHERE r.restaurant_id = p_restaurant_id
    GROUP BY r.rating
    
    UNION ALL
    
    -- Garantir que todas as estrelas (1-5) estejam representadas
    SELECT 
      generate_series(1,5) as rating_value,
      0 as rating_count
  ) combined
  GROUP BY rating_value
  ORDER BY rating_value;
  
  -- Construir JSON de resposta
  v_stats := json_build_object(
    'total_reviews', v_total_reviews,
    'average_rating', v_average_rating,
    'rating_distribution', v_rating_distribution
  );
  
  RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_review_replies_review_id ON review_replies(review_id);
CREATE INDEX IF NOT EXISTS idx_review_reports_review_id ON review_reports(review_id);
CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_review_id ON review_helpful_votes(review_id);
CREATE INDEX IF NOT EXISTS idx_review_replies_created_at ON review_replies(created_at DESC);

-- 8. Configurar RLS (Row Level Security)
ALTER TABLE review_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reply_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies para review_replies
CREATE POLICY "Qualquer um pode ler respostas" ON review_replies
  FOR SELECT USING (true);

CREATE POLICY "Usuários autenticados podem criar respostas" ON review_replies
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias respostas" ON review_replies
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias respostas" ON review_replies
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies para review_reports
CREATE POLICY "Usuários podem criar reportes" ON review_reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem ver seus próprios reportes" ON review_reports
  FOR SELECT USING (auth.uid() = user_id);

-- RLS Policies para review_helpful_votes
CREATE POLICY "Qualquer um pode ler votos úteis" ON review_helpful_votes
  FOR SELECT USING (true);

CREATE POLICY "Usuários autenticados podem votar" ON review_helpful_votes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem remover seus próprios votos" ON review_helpful_votes
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies para reply_reports
CREATE POLICY "Usuários podem criar reportes de respostas" ON reply_reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem ver seus próprios reportes de respostas" ON reply_reports
  FOR SELECT USING (auth.uid() = user_id);

-- 9. Trigger para atualizar updated_at em review_replies
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_review_replies_updated_at 
  BEFORE UPDATE ON review_replies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE review_replies IS 'Tabela para armazenar respostas às avaliações de restaurantes';
COMMENT ON TABLE review_reports IS 'Tabela para armazenar reportes de avaliações inadequadas';
COMMENT ON TABLE review_helpful_votes IS 'Tabela para controlar votos "útil" nas avaliações';
COMMENT ON TABLE reply_reports IS 'Tabela para reportar respostas inadequadas';