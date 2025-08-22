-- Corrigir a tabela admins - inserir o usuário administrador
-- O usuário já existe no auth.users, agora precisa existir na tabela admins

-- Verificar se o usuário existe na tabela admins
SELECT 'Verificando usuário na tabela admins:' as status;
SELECT * FROM public.admins WHERE email = 'admin@gastroapp.com';

-- Inserir o usuário na tabela admins se não existir
INSERT INTO public.admins (
  email,
  password_hash,
  full_name,
  role,
  is_active,
  created_at,
  updated_at
) VALUES (
  'admin@gastroapp.com',
  crypt('admin123', gen_salt('bf')),
  'Administrador do Sistema',
  'admin',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) 
DO UPDATE SET
  password_hash = EXCLUDED.password_hash,
  full_name = EXCLUDED.full_name,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verificar se foi inserido corretamente
SELECT 'Usuário após inserção:' as status;
SELECT * FROM public.admins WHERE email = 'admin@gastroapp.com';