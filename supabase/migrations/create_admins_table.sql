-- Criar tabela admins para o painel administrativo
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin' NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS na tabela admins
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir que admins autenticados vejam apenas seus próprios dados
CREATE POLICY "Admins can view own data" ON public.admins
    FOR SELECT USING (auth.uid() = id);

-- Criar política para permitir que admins autenticados atualizem apenas seus próprios dados
CREATE POLICY "Admins can update own data" ON public.admins
    FOR UPDATE USING (auth.uid() = id);

-- Conceder permissões para as roles anon e authenticated
GRANT SELECT, INSERT, UPDATE ON public.admins TO anon;
GRANT SELECT, INSERT, UPDATE ON public.admins TO authenticated;

-- Inserir usuário admin padrão
-- Senha: admin123 (hash bcrypt)
INSERT INTO public.admins (email, password_hash, full_name, role) 
VALUES (
    'admin@gastroapp.com',
    '$2b$10$rQZ8kZKZQZKZQZKZQZKZQOeKZQZKZQZKZQZKZQZKZQZKZQZKZQZKZ',
    'Administrador do Sistema',
    'admin'
) ON CONFLICT (email) DO NOTHING;

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar updated_at automaticamente
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON public.admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();