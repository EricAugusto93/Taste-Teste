-- Migração para otimizar políticas RLS
-- Remove políticas duplicadas e otimiza performance

-- 1. Remover políticas duplicadas da tabela admins
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.admins;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.admins;

-- 2. Otimizar políticas existentes substituindo auth.uid() por (SELECT auth.uid())

-- Reviews - Otimizar políticas
DROP POLICY IF EXISTS "Users can insert their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can update their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can delete their own reviews" ON public.reviews;

CREATE POLICY "Users can insert their own reviews" ON public.reviews
  FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update their own reviews" ON public.reviews
  FOR UPDATE USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete their own reviews" ON public.reviews
  FOR DELETE USING (user_id = (SELECT auth.uid()));

-- Favorites - Otimizar políticas
DROP POLICY IF EXISTS "Users can view their own favorites" ON public.favorites;
DROP POLICY IF EXISTS "Users can insert their own favorites" ON public.favorites;
DROP POLICY IF EXISTS "Users can delete their own favorites" ON public.favorites;

CREATE POLICY "Users can view their own favorites" ON public.favorites
  FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert their own favorites" ON public.favorites
  FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete their own favorites" ON public.favorites
  FOR DELETE USING (user_id = (SELECT auth.uid()));

-- Search History - Otimizar políticas
DROP POLICY IF EXISTS "Users can view their own search history" ON public.search_history;
DROP POLICY IF EXISTS "Users can insert their own search history" ON public.search_history;
DROP POLICY IF EXISTS "Users can delete their own search history" ON public.search_history;

CREATE POLICY "Users can view their own search history" ON public.search_history
  FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert their own search history" ON public.search_history
  FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete their own search history" ON public.search_history
  FOR DELETE USING (user_id = (SELECT auth.uid()));

-- User Settings - Otimizar políticas
DROP POLICY IF EXISTS "Users can view own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can insert own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can update own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can delete own settings" ON public.user_settings;

CREATE POLICY "Users can view own settings" ON public.user_settings
  FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own settings" ON public.user_settings
  FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can update own settings" ON public.user_settings
  FOR UPDATE USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own settings" ON public.user_settings
  FOR DELETE USING (user_id = (SELECT auth.uid()));

-- User Profiles - Otimizar políticas
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.user_profiles;

CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (id = (SELECT auth.uid()));

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (id = (SELECT auth.uid()));

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (id = (SELECT auth.uid()));

CREATE POLICY "Users can delete own profile" ON public.user_profiles
  FOR DELETE USING (id = (SELECT auth.uid()));

-- Admins - Otimizar políticas
DROP POLICY IF EXISTS "Admins can view own data" ON public.admins;
DROP POLICY IF EXISTS "Admins can update own data" ON public.admins;

CREATE POLICY "Admins can view own data" ON public.admins
  FOR SELECT USING (
    email IN (
      SELECT raw_user_meta_data->>'email' 
      FROM auth.users 
      WHERE id = (SELECT auth.uid())
    )
  );

CREATE POLICY "Admins can update own data" ON public.admins
  FOR UPDATE USING (
    email IN (
      SELECT raw_user_meta_data->>'email' 
      FROM auth.users 
      WHERE id = (SELECT auth.uid())
    )
  );

-- Restaurants - Otimizar políticas de admin
DROP POLICY IF EXISTS "Admins can insert restaurants" ON public.restaurants;
DROP POLICY IF EXISTS "Admins can update restaurants" ON public.restaurants;
DROP POLICY IF EXISTS "Admins can delete restaurants" ON public.restaurants;

CREATE POLICY "Admins can insert restaurants" ON public.restaurants
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );

CREATE POLICY "Admins can update restaurants" ON public.restaurants
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );

CREATE POLICY "Admins can delete restaurants" ON public.restaurants
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );

-- Categories - Otimizar políticas de admin
DROP POLICY IF EXISTS "Admins can insert categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can update categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can delete categories" ON public.categories;

CREATE POLICY "Admins can insert categories" ON public.categories
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );

CREATE POLICY "Admins can update categories" ON public.categories
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );

CREATE POLICY "Admins can delete categories" ON public.categories
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.admins 
      WHERE email IN (
        SELECT raw_user_meta_data->>'email' 
        FROM auth.users 
        WHERE id = (SELECT auth.uid())
      ) AND is_active = true
    )
  );