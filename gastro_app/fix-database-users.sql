-- ============================================================================
-- SCRIPT DE CORREÇÃO: PROBLEMA "ERRO AO OBTER DADOS DO USUÁRIO"
-- ============================================================================

-- Verificar se a tabela usuarios existe
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'usuarios') THEN
        RAISE NOTICE '✅ Tabela usuarios existe';
    ELSE
        RAISE NOTICE '❌ Tabela usuarios NÃO existe';
    END IF;
END $$;

-- Criar tabela usuarios se não existir
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255),
    telefone VARCHAR(20),
    data_nascimento DATE,
    favoritos UUID[] DEFAULT '{}',
    preferencias JSONB DEFAULT '{}',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Verificar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Recriar políticas RLS (DROP e CREATE para garantir)
DROP POLICY IF EXISTS "Usuários podem ver apenas seus próprios dados" ON usuarios;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas seus próprios dados" ON usuarios;
DROP POLICY IF EXISTS "Usuários podem inserir apenas seus próprios dados" ON usuarios;

CREATE POLICY "Usuários podem ver apenas seus próprios dados" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar apenas seus próprios dados" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Usuários podem inserir apenas seus próprios dados" ON usuarios
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Recriar função de trigger
CREATE OR REPLACE FUNCTION criar_usuario_automatico()
RETURNS TRIGGER AS $$
BEGIN
    -- Tentar inserir apenas se não existir
    INSERT INTO usuarios (id, email, nome)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
    )
    ON CONFLICT (id) DO NOTHING; -- Ignorar se já existir
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger
DROP TRIGGER IF EXISTS trigger_criar_usuario ON auth.users;
CREATE TRIGGER trigger_criar_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION criar_usuario_automatico();

-- Sincronizar usuários existentes que podem estar faltando na tabela
INSERT INTO usuarios (id, email, nome)
SELECT 
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data->>'name', u.email)
FROM auth.users u
LEFT JOIN usuarios usr ON u.id = usr.id
WHERE usr.id IS NULL -- Apenas usuários que não existem na tabela usuarios
ON CONFLICT (id) DO NOTHING;

-- Verificar resultado
DO $$
DECLARE
    total_auth_users INTEGER;
    total_usuarios INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_auth_users FROM auth.users;
    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    
    RAISE NOTICE '📊 Total de usuários no auth.users: %', total_auth_users;
    RAISE NOTICE '📊 Total de usuários na tabela usuarios: %', total_usuarios;
    
    IF total_auth_users = total_usuarios THEN
        RAISE NOTICE '✅ Todos os usuários estão sincronizados!';
    ELSE
        RAISE NOTICE '⚠️ Há % usuários não sincronizados', (total_auth_users - total_usuarios);
    END IF;
END $$;

-- Exibir usuários sincronizados recentemente
SELECT 
    'Usuários na tabela usuarios:' as info,
    email,
    nome,
    array_length(favoritos, 1) as total_favoritos,
    created_at
FROM usuarios 
ORDER BY created_at DESC 
LIMIT 10; 