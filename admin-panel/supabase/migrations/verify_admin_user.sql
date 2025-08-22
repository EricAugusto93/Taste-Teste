-- Verificar se o usuário administrador foi criado corretamente

-- Verificar na tabela auth.users
SELECT 
  'auth.users' as tabela,
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'admin@gastroapp.com';

-- Verificar na tabela public.admins
SELECT 
  'public.admins' as tabela,
  id,
  email,
  full_name,
  role,
  is_active,
  created_at
FROM public.admins 
WHERE email = 'admin@gastroapp.com';