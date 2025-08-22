-- Criar tabela admins se não existir
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

-- Remover RLS temporariamente para permitir login
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;

-- Conceder permissões completas para desenvolvimento
GRANT ALL ON public.admins TO anon;
GRANT ALL ON public.admins TO authenticated;

-- Limpar dados existentes e inserir admin correto
DELETE FROM public.admins WHERE email = 'admin@gastroapp.com';

-- Inserir usuário admin com hash bcrypt correto para 'admin123'
INSERT INTO public.admins (email, password_hash, full_name, role) 
VALUES (
    'admin@gastroapp.com',
    '$2b$10$X.2/fLNqXLZl.RjKCHZmTe3VKYx/fXu8VKx/Km7KtqZjDZmU.XZmS',
    'Administrador do Sistema',
    'admin'
) ON CONFLICT (email) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role;