-- Verificar dados nas tabelas principais
SELECT 'categories' as table_name, COUNT(*) as count FROM categories
UNION ALL
SELECT 'restaurants' as table_name, COUNT(*) as count FROM restaurants
UNION ALL
SELECT 'featured_restaurants' as table_name, COUNT(*) as count FROM restaurants WHERE is_featured = true;

-- Verificar algumas categorias
SELECT id, name, icon, is_active FROM categories LIMIT 5;

-- Verificar alguns restaurantes
SELECT id, name, category_id, is_open, is_featured, rating FROM restaurants LIMIT 5;