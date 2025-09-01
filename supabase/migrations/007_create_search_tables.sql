-- Criar tabelas para funcionalidades de busca
-- Executar: 2025-09-01

-- Tabela para armazenar histórico de buscas dos usuários
CREATE TABLE IF NOT EXISTS public.user_search_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para rastrear buscas populares
CREATE TABLE IF NOT EXISTS public.popular_searches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    query TEXT NOT NULL UNIQUE,
    search_count INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_search_history_user_id ON public.user_search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_search_history_created_at ON public.user_search_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_popular_searches_count ON public.popular_searches(search_count DESC);
CREATE INDEX IF NOT EXISTS idx_popular_searches_query ON public.popular_searches(query);

-- RLS (Row Level Security) policies
ALTER TABLE public.user_search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.popular_searches ENABLE ROW LEVEL SECURITY;

-- Política para user_search_history: usuários podem ver apenas suas próprias buscas
CREATE POLICY "Users can view their own search history" ON public.user_search_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own search history" ON public.user_search_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para popular_searches: leitura pública, mas apenas usuários autenticados podem ver
CREATE POLICY "Authenticated users can view popular searches" ON public.popular_searches
    FOR SELECT USING (auth.role() = 'authenticated');

-- Função para atualizar popular_searches automaticamente
CREATE OR REPLACE FUNCTION public.update_popular_searches()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.popular_searches (query, search_count)
    VALUES (NEW.query, 1)
    ON CONFLICT (query) 
    DO UPDATE SET 
        search_count = popular_searches.search_count + 1,
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar popular_searches quando uma nova busca é adicionada
DROP TRIGGER IF EXISTS trigger_update_popular_searches ON public.user_search_history;
CREATE TRIGGER trigger_update_popular_searches
    AFTER INSERT ON public.user_search_history
    FOR EACH ROW
    EXECUTE FUNCTION public.update_popular_searches();

-- Inserir algumas buscas populares de exemplo
INSERT INTO public.popular_searches (query, search_count) VALUES
    ('pizza', 25),
    ('hambúrguer', 20),
    ('sushi', 15),
    ('italiana', 12),
    ('brasileira', 10)
ON CONFLICT (query) DO NOTHING;

-- Comentários para documentação
COMMENT ON TABLE public.user_search_history IS 'Armazena o histórico de buscas de cada usuário';
COMMENT ON TABLE public.popular_searches IS 'Rastreia as buscas mais populares do sistema';
COMMENT ON FUNCTION public.update_popular_searches() IS 'Atualiza automaticamente as buscas populares';