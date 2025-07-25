-- ============================================================================
-- CORREÇÃO URGENTE: PROBLEMA COM COLUNA 'NOME' NA TABELA USUARIOS
-- ============================================================================
-- 
-- ERRO: PostgrestException(message: Could not find the 'nome' column of 'usuarios' in the schema cache, code: PGRST204)
-- CAUSA: Tabela usuarios pode não ter a coluna 'nome' ou schema desatualizado
-- SOLUÇÃO: Verificar e corrigir estrutura da tabela
--

-- 1. Verificar se a tabela usuarios existe e sua estrutura
DO $$
BEGIN
    -- Verificar se tabela existe
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'usuarios') THEN
        RAISE NOTICE '✅ Tabela usuarios existe';
        
        -- Verificar se coluna nome existe
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'nome') THEN
            RAISE NOTICE '✅ Coluna nome existe';
        ELSE
            RAISE NOTICE '❌ Coluna nome NÃO existe - será criada';
        END IF;
    ELSE
        RAISE NOTICE '❌ Tabela usuarios NÃO existe - será criada';
    END IF;
END $$;

-- 2. Criar tabela usuarios se não existir (com estrutura completa)
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

-- 3. Adicionar coluna nome se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'nome') THEN
        ALTER TABLE usuarios ADD COLUMN nome VARCHAR(255);
        RAISE NOTICE '✅ Coluna nome adicionada com sucesso';
    END IF;
END $$;

-- 4. Verificar e corrigir RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes para evitar conflitos
DROP POLICY IF EXISTS "Usuários podem ver apenas seus próprios dados" ON usuarios;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas seus próprios dados" ON usuarios;
DROP POLICY IF EXISTS "Usuários podem inserir apenas seus próprios dados" ON usuarios;

-- Recriar políticas RLS
CREATE POLICY "Usuários podem ver apenas seus próprios dados" ON usuarios
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar apenas seus próprios dados" ON usuarios
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Usuários podem inserir apenas seus próprios dados" ON usuarios
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 5. Recriar função de trigger para criação automática
CREATE OR REPLACE FUNCTION criar_usuario_automatico()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO usuarios (id, email, nome)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        nome = COALESCE(EXCLUDED.nome, usuarios.nome),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Recriar trigger
DROP TRIGGER IF EXISTS trigger_criar_usuario ON auth.users;
CREATE TRIGGER trigger_criar_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION criar_usuario_automatico();

-- 7. Atualizar usuários existentes que podem não ter nome
UPDATE usuarios 
SET nome = COALESCE(nome, split_part(email, '@', 1))
WHERE nome IS NULL OR nome = '';

-- 8. Sincronizar usuários do auth.users que podem estar faltando
INSERT INTO usuarios (id, email, nome)
SELECT 
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1))
FROM auth.users u
LEFT JOIN usuarios usr ON u.id = usr.id
WHERE usr.id IS NULL
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    nome = COALESCE(EXCLUDED.nome, usuarios.nome),
    updated_at = NOW();

-- 9. Forçar refresh do schema cache (PostgREST)
NOTIFY pgrst, 'reload schema';

-- 10. Verificar resultado final
DO $$
DECLARE
    total_auth_users INTEGER;
    total_usuarios INTEGER;
    usuarios_sem_nome INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_auth_users FROM auth.users;
    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    SELECT COUNT(*) INTO usuarios_sem_nome FROM usuarios WHERE nome IS NULL OR nome = '';
    
    RAISE NOTICE '📊 RESULTADO DA CORREÇÃO:';
    RAISE NOTICE '   • Total usuários auth.users: %', total_auth_users;
    RAISE NOTICE '   • Total usuários tabela usuarios: %', total_usuarios;
    RAISE NOTICE '   • Usuários sem nome: %', usuarios_sem_nome;
    
    IF total_auth_users = total_usuarios AND usuarios_sem_nome = 0 THEN
        RAISE NOTICE '✅ CORREÇÃO APLICADA COM SUCESSO!';
    ELSE
        RAISE NOTICE '⚠️ Pode haver problemas remanescentes';
    END IF;
END $$;

-- 11. Exibir estrutura final da tabela para verificação
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position; 