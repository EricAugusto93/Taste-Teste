-- Migração para corrigir índices do banco de dados
-- Adiciona índices faltantes e remove índices não utilizados

-- 1. Adicionar índices faltantes para foreign keys
-- Favorites table - restaurant_id
CREATE INDEX IF NOT EXISTS idx_favorites_restaurant_id 
ON public.favorites(restaurant_id);

-- Reviews table - user_id  
CREATE INDEX IF NOT EXISTS idx_reviews_user_id 
ON public.reviews(user_id);

-- 2. Remover índices não utilizados (se existirem)
-- Nota: Só remove se realmente não estão sendo usados
DROP INDEX IF EXISTS idx_categories_sort_order;
DROP INDEX IF EXISTS idx_restaurants_location;
DROP INDEX IF EXISTS user_settings_notifications_idx;
DROP INDEX IF EXISTS user_settings_theme_idx;

-- 3. Criar índices otimizados para queries comuns
-- Índice composto para busca de restaurantes por categoria e status
CREATE INDEX IF NOT EXISTS idx_restaurants_category_status 
ON public.restaurants(category_id, is_open, is_active) 
WHERE is_active = true;

-- Índice para busca de restaurantes por localização (usando GiST para coordenadas)
CREATE INDEX IF NOT EXISTS idx_restaurants_coordinates 
ON public.restaurants USING gist(point(longitude, latitude));

-- Índice para busca de favoritos por usuário (mais utilizado)
CREATE INDEX IF NOT EXISTS idx_favorites_user_restaurant 
ON public.favorites(user_id, restaurant_id);

-- Índice para reviews por restaurante e data
CREATE INDEX IF NOT EXISTS idx_reviews_restaurant_date 
ON public.reviews(restaurant_id, created_at DESC);

-- Índice para categorias ativas ordenadas
CREATE INDEX IF NOT EXISTS idx_categories_active_sorted 
ON public.categories(sort_order) 
WHERE is_active = true;

-- 4. Índices para search_history para performance
CREATE INDEX IF NOT EXISTS idx_search_history_user_date 
ON public.search_history(user_id, created_at DESC);

-- 5. Índice para user_settings por usuário
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id 
ON public.user_settings(user_id);

-- 6. Adicionar índice para admins ativos
CREATE INDEX IF NOT EXISTS idx_admins_active_email 
ON public.admins(email) 
WHERE is_active = true;

-- 7. Índice para busca text search em restaurantes
CREATE INDEX IF NOT EXISTS idx_restaurants_search 
ON public.restaurants USING gin(to_tsvector('portuguese', name || ' ' || coalesce(description, '')));

-- 8. Atualizar estatísticas das tabelas para o otimizador
ANALYZE public.restaurants;
ANALYZE public.categories;
ANALYZE public.favorites;
ANALYZE public.reviews;
ANALYZE public.user_profiles;
ANALYZE public.search_history;
ANALYZE public.user_settings;
ANALYZE public.admins;