-- ============================================================================
-- SCHEMA DO GASTRO APP - SUPABASE
-- ============================================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- Para geolocalização

-- ============================================================================
-- TABELA USUARIOS
-- ============================================================================

-- Tabela para dados extras dos usuários (complementa auth.users)
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255),
    telefone VARCHAR(20),
    data_nascimento DATE,
    favoritos UUID[] DEFAULT '{}', -- Array de IDs de restaurantes favoritos
    preferencias JSONB DEFAULT '{}', -- Preferências alimentares, restrições, etc.
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para usuarios
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para usuarios
CREATE POLICY "Usuários podem ver apenas seus próprios dados" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar apenas seus próprios dados" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Usuários podem inserir apenas seus próprios dados" ON usuarios
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Trigger para criar usuário automaticamente após signup
CREATE OR REPLACE FUNCTION criar_usuario_automatico()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO usuarios (id, email, nome)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger se não existir
DROP TRIGGER IF EXISTS trigger_criar_usuario ON auth.users;
CREATE TRIGGER trigger_criar_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION criar_usuario_automatico();

-- ============================================================================
-- TABELA RESTAURANTES (se não existir)
-- ============================================================================

CREATE TABLE IF NOT EXISTS restaurantes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(100) NOT NULL, -- ex: "italiano", "japonês", "pizza"
    descricao TEXT,
    endereco TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    telefone VARCHAR(20),
    site_url TEXT,
    horario_funcionamento JSONB,
    preco_medio DECIMAL(10, 2), -- Preço médio por pessoa
    avaliacao_media DECIMAL(3, 2) DEFAULT 0, -- De 0 a 5
    total_avaliacoes INTEGER DEFAULT 0,
    imagem_url TEXT,
    imagens_extras TEXT[], -- Array de URLs de imagens adicionais
    tags TEXT[] DEFAULT '{}', -- ex: ["vegano", "pet-friendly", "wifi"]
    features JSONB DEFAULT '{}', -- Características extras (estacionamento, etc.)
    ativo BOOLEAN DEFAULT true,
    verificado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para geolocalização
CREATE INDEX IF NOT EXISTS idx_restaurantes_localizacao 
ON restaurantes USING GIST (ST_Point(longitude, latitude));

CREATE INDEX IF NOT EXISTS idx_restaurantes_tipo ON restaurantes(tipo);
CREATE INDEX IF NOT EXISTS idx_restaurantes_tags ON restaurantes USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_restaurantes_ativo ON restaurantes(ativo);

-- ============================================================================
-- TABELA EXPERIENCIAS
-- ============================================================================

CREATE TABLE IF NOT EXISTS experiencias (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
    restaurante_id UUID REFERENCES restaurantes(id) ON DELETE CASCADE NOT NULL,
    emoji VARCHAR(10) NOT NULL, -- Ex: 😋, ❤️, 😐, 🤢
    comentario TEXT,
    nota INTEGER CHECK (nota >= 1 AND nota <= 5), -- Nota de 1 a 5 estrelas
    preco_pago DECIMAL(10, 2), -- Quanto gastou
    acompanhantes INTEGER DEFAULT 1, -- Quantas pessoas
    ocasiao VARCHAR(100), -- Ex: "jantar romântico", "almoço trabalho"
    pratos_consumidos TEXT[], -- Lista de pratos pedidos
    data_visita TIMESTAMP WITH TIME ZONE NOT NULL,
    fotos TEXT[], -- URLs das fotos da experiência
    recomenda BOOLEAN DEFAULT true,
    voltaria BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir que um usuário só pode ter uma experiência por restaurante por dia
    UNIQUE(user_id, restaurante_id, DATE(data_visita))
);

-- RLS para experiencias
ALTER TABLE experiencias ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para experiencias
CREATE POLICY "Usuários podem ver apenas suas próprias experiências" ON experiencias
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir apenas suas próprias experiências" ON experiencias
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar apenas suas próprias experiências" ON experiencias
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias experiências" ON experiencias
    FOR DELETE USING (auth.uid() = user_id);

-- Índices para experiencias
CREATE INDEX IF NOT EXISTS idx_experiencias_user_id ON experiencias(user_id);
CREATE INDEX IF NOT EXISTS idx_experiencias_restaurante_id ON experiencias(restaurante_id);
CREATE INDEX IF NOT EXISTS idx_experiencias_data_visita ON experiencias(data_visita);
CREATE INDEX IF NOT EXISTS idx_experiencias_emoji ON experiencias(emoji);

-- ============================================================================
-- FUNÇÕES ÚTEIS
-- ============================================================================

-- Função para buscar restaurantes próximos
CREATE OR REPLACE FUNCTION buscar_restaurantes_proximos(
    lat DECIMAL,
    lng DECIMAL,
    raio_km DECIMAL DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    tipo VARCHAR,
    descricao TEXT,
    endereco TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    telefone VARCHAR,
    site_url TEXT,
    horario_funcionamento JSONB,
    preco_medio DECIMAL,
    avaliacao_media DECIMAL,
    total_avaliacoes INTEGER,
    imagem_url TEXT,
    imagens_extras TEXT[],
    tags TEXT[],
    features JSONB,
    ativo BOOLEAN,
    verificado BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    distancia_km DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.*,
        ROUND(
            ST_Distance(
                ST_Point(lng, lat)::geography,
                ST_Point(r.longitude, r.latitude)::geography
            ) / 1000, 2
        ) as distancia_km
    FROM restaurantes r
    WHERE 
        r.ativo = true
        AND ST_DWithin(
            ST_Point(lng, lat)::geography,
            ST_Point(r.longitude, r.latitude)::geography,
            raio_km * 1000
        )
    ORDER BY distancia_km;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar a avaliação média dos restaurantes
CREATE OR REPLACE FUNCTION atualizar_avaliacao_restaurante()
RETURNS TRIGGER AS $$
DECLARE
    nova_media DECIMAL;
    total_exp INTEGER;
BEGIN
    -- Calcular nova média baseada nos emojis
    SELECT 
        AVG(
            CASE 
                WHEN emoji = '😋' THEN 5 -- Delicioso
                WHEN emoji = '❤️' THEN 5 -- Amei
                WHEN emoji = '😊' THEN 4 -- Gostei
                WHEN emoji = '😐' THEN 3 -- Ok
                WHEN emoji = '😞' THEN 2 -- Não gostei
                WHEN emoji = '🤢' THEN 1 -- Ruim
                ELSE 3 -- Default
            END
        ),
        COUNT(*)
    INTO nova_media, total_exp
    FROM experiencias 
    WHERE restaurante_id = COALESCE(NEW.restaurante_id, OLD.restaurante_id);
    
    -- Atualizar o restaurante
    UPDATE restaurantes 
    SET 
        avaliacao_media = COALESCE(nova_media, 0),
        total_avaliacoes = total_exp,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.restaurante_id, OLD.restaurante_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar avaliação
DROP TRIGGER IF EXISTS trigger_atualizar_avaliacao_insert ON experiencias;
CREATE TRIGGER trigger_atualizar_avaliacao_insert
    AFTER INSERT ON experiencias
    FOR EACH ROW EXECUTE FUNCTION atualizar_avaliacao_restaurante();

DROP TRIGGER IF EXISTS trigger_atualizar_avaliacao_update ON experiencias;
CREATE TRIGGER trigger_atualizar_avaliacao_update
    AFTER UPDATE ON experiencias
    FOR EACH ROW EXECUTE FUNCTION atualizar_avaliacao_restaurante();

DROP TRIGGER IF EXISTS trigger_atualizar_avaliacao_delete ON experiencias;
CREATE TRIGGER trigger_atualizar_avaliacao_delete
    AFTER DELETE ON experiencias
    FOR EACH ROW EXECUTE FUNCTION atualizar_avaliacao_restaurante();

-- ============================================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- ============================================================================

-- Inserir alguns restaurantes de exemplo (apenas se não existirem)
INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Pizzaria Bella Vista',
    'italiano',
    'Autêntica pizzaria italiana com forno a lenha e vista panorâmica da cidade.',
    'Rua das Flores, 123 - Centro',
    -23.5505,
    -46.6333,
    '(11) 99999-1234',
    45.00,
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
    ARRAY['pizza', 'italiano', 'vista', 'forno a lenha']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Pizzaria Bella Vista');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Sushi Zen',
    'japonês',
    'Sushiria tradicional com ingredientes frescos e ambiente minimalista.',
    'Av. Paulista, 456 - Bela Vista',
    -23.5612,
    -46.6563,
    '(11) 99999-5678',
    80.00,
    'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
    ARRAY['sushi', 'japonês', 'peixe fresco', 'tradicional']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Sushi Zen');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Café da Esquina',
    'café',
    'Cafeteria aconchegante com wi-fi grátis, perfeita para trabalhar.',
    'Rua Augusta, 789 - Vila Madalena',
    -23.5489,
    -46.6866,
    '(11) 99999-9012',
    25.00,
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
    ARRAY['café', 'wifi', 'trabalho', 'aconchegante']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Café da Esquina');

-- Restaurantes próximos a Curitiba para teste
INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Churrascaria Gaúcha',
    'churrascaria',
    'Tradicional churrascaria com carnes nobres e buffet completo.',
    'Rua XV de Novembro, 100 - Centro, Curitiba',
    -25.4284,
    -49.2733,
    '(41) 99999-1111',
    65.00,
    'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
    ARRAY['churrasco', 'carne', 'buffet', 'tradicional']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Churrascaria Gaúcha');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Bistrô do Batel',
    'contemporâneo',
    'Culinária contemporânea em ambiente sofisticado no coração do Batel.',
    'Av. Batel, 200 - Batel, Curitiba',
    -25.4372,
    -49.2844,
    '(41) 99999-2222',
    85.00,
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
    ARRAY['contemporâneo', 'sofisticado', 'batel', 'jantar']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Bistrô do Batel');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Pizzaria Curitibana',
    'italiano',
    'Pizza artesanal com ingredientes locais e massa fermentada naturalmente.',
    'Rua Comendador Araújo, 300 - Centro, Curitiba',
    -25.4195,
    -49.2646,
    '(41) 99999-3333',
    40.00,
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
    ARRAY['pizza', 'artesanal', 'massa natural', 'local']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Pizzaria Curitibana');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Café Central',
    'café',
    'Café especial com torrefação própria no centro histórico de Curitiba.',
    'Largo da Ordem, 50 - Centro Histórico, Curitiba',
    -25.4284,
    -49.2733,
    '(41) 99999-4444',
    20.00,
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
    ARRAY['café especial', 'torrefação', 'centro histórico', 'wifi']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Café Central');

INSERT INTO restaurantes (nome, tipo, descricao, endereco, latitude, longitude, telefone, preco_medio, imagem_url, tags)
SELECT 
    'Sushi Curitiba',
    'japonês',
    'Sushi bar moderno com peixes frescos e ambiente descontraído.',
    'Rua Marechal Deodoro, 400 - Centro, Curitiba',
    -25.4284,
    -49.2733,
    '(41) 99999-5555',
    70.00,
    'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
    ARRAY['sushi', 'peixe fresco', 'moderno', 'descontraído']
WHERE NOT EXISTS (SELECT 1 FROM restaurantes WHERE nome = 'Sushi Curitiba');

-- ============================================================================
-- COMENTÁRIOS FINAIS
-- ============================================================================

-- Este schema fornece:
-- 1. Tabela usuarios com RLS para dados pessoais
-- 2. Tabela experiencias com RLS para avaliações por usuário
-- 3. Triggers automáticos para criação de usuários
-- 4. Triggers para atualização de avaliações
-- 5. Função para busca geográfica de restaurantes
-- 6. Índices otimizados para performance
-- 7. Dados de exemplo para testes

-- Para executar este schema:
-- 1. Acesse o Supabase Dashboard
-- 2. Vá em "SQL Editor"
-- 3. Cole este código e execute
-- 4. Verifique se todas as tabelas foram criadas corretamente