-- Criar usuário administrador no sistema de autenticação do Supabase
-- Este script cria o usuário tanto no auth.users quanto na tabela admins

-- Primeiro, verificar se o usuário já existe no auth.users
DO $$
BEGIN
  -- Inserir usuário no sistema de autenticação se não existir
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@gastroapp.com') THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      recovery_sent_at,
      last_sign_in_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'admin@gastroapp.com',
      crypt('admin123', gen_salt('bf')),
      NOW(),
      NOW(),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    );
  END IF;
END $$;

-- Inserir ou atualizar na tabela admins
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

-- Verificar se o usuário foi criado com sucesso
SELECT 
  'Usuário criado no auth.users:' as status,
  email,
  email_confirmed_at
FROM auth.users 
WHERE email = 'admin@gastroapp.com';

SELECT 
  'Usuário criado na tabela admins:' as status,
  email,
  full_name,
  role,
  is_active,
  created_at
FROM public.admins 
WHERE email = 'admin@gastroapp.com';