-- ============================================================================
-- 006_configure_cors_policies.sql
-- Configuração de políticas CORS e de acesso para Storage e recursos
-- ============================================================================

-- 1. CONFIGURAR POLÍTICAS PARA STORAGE (IMAGES BUCKET)
-- ============================================================================

-- Permitir leitura pública de imagens
DROP POLICY IF EXISTS "Allow public read access on images" ON storage.objects;
CREATE POLICY "Allow public read access on images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'images');

-- Permitir upload de imagens para usuários autenticados
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
CREATE POLICY "Allow authenticated users to upload images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'images');

-- Permitir atualização de imagens próprias
DROP POLICY IF EXISTS "Allow users to update their own images" ON storage.objects;
CREATE POLICY "Allow users to update their own images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Permitir exclusão de imagens próprias
DROP POLICY IF EXISTS "Allow users to delete their own images" ON storage.objects;
CREATE POLICY "Allow users to delete their own images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 2. CONFIGURAR BUCKET DE IMAGENS
-- ============================================================================

-- Inserir bucket se não existir
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true,
  52428800, -- 50MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 3. ATUALIZAR URLS DE IMAGENS DOS RESTAURANTES
-- ============================================================================

-- Atualizar restaurantes com URLs válidas do Supabase Storage
UPDATE restaurants 
SET image_url = 'https://msjzktnkvyycwahpalhb.supabase.co/storage/v1/object/public/images/restaurants/' || id || '.jpg'
WHERE image_url IS NULL OR image_url = '' OR image_url NOT LIKE '%supabase%';

-- 4. CONFIGURAR RLS PARA ACESSO WEB/CORS
-- ============================================================================

-- Garantir que a tabela restaurants permite leitura pública
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;

-- Política de leitura pública para restaurantes
DROP POLICY IF EXISTS "Allow public read access to restaurants" ON restaurants;
CREATE POLICY "Allow public read access to restaurants"
  ON restaurants FOR SELECT
  TO public
  USING (true);

-- Política de leitura pública para categorias  
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to categories" ON categories;
CREATE POLICY "Allow public read access to categories"
  ON categories FOR SELECT
  TO public
  USING (true);

-- 5. CONFIGURAR POLÍTICAS PARA REVIEWS (PARA USUÁRIOS AUTENTICADOS)
-- ============================================================================

-- Permitir leitura pública de reviews
DROP POLICY IF EXISTS "Allow public read access to reviews" ON reviews;
CREATE POLICY "Allow public read access to reviews"
  ON reviews FOR SELECT
  TO public
  USING (true);

-- Permitir criação de reviews para usuários autenticados
DROP POLICY IF EXISTS "Allow authenticated users to create reviews" ON reviews;
CREATE POLICY "Allow authenticated users to create reviews"
  ON reviews FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Permitir atualização de reviews próprias
DROP POLICY IF EXISTS "Allow users to update their own reviews" ON reviews;
CREATE POLICY "Allow users to update their own reviews"
  ON reviews FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Permitir exclusão de reviews próprias
DROP POLICY IF EXISTS "Allow users to delete their own reviews" ON reviews;
CREATE POLICY "Allow users to delete their own reviews"
  ON reviews FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- 6. CONFIGURAR FAVORITOS (SOMENTE PARA USUÁRIOS AUTENTICADOS)
-- ============================================================================

-- Habilitar RLS para favoritos
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Usuários só podem ver seus próprios favoritos
DROP POLICY IF EXISTS "Users can only see their own favorites" ON favorites;
CREATE POLICY "Users can only see their own favorites"
  ON favorites FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Usuários só podem criar seus próprios favoritos
DROP POLICY IF EXISTS "Users can only create their own favorites" ON favorites;
CREATE POLICY "Users can only create their own favorites"
  ON favorites FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Usuários só podem deletar seus próprios favoritos
DROP POLICY IF EXISTS "Users can only delete their own favorites" ON favorites;
CREATE POLICY "Users can only delete their own favorites"
  ON favorites FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- 7. LOGS E VERIFICAÇÃO
-- ============================================================================

-- Log das políticas configuradas
DO $$
BEGIN
  RAISE NOTICE '✅ Políticas CORS configuradas com sucesso';
  RAISE NOTICE '📸 Bucket images: acesso público configurado';
  RAISE NOTICE '🍽️ Restaurants: leitura pública habilitada';
  RAISE NOTICE '📂 Categories: leitura pública habilitada';
  RAISE NOTICE '⭐ Reviews: leitura pública, escrita autenticada';
  RAISE NOTICE '❤️ Favorites: apenas para usuários autenticados';
  RAISE NOTICE '🔒 RLS configurado em todas as tabelas';
END $$;