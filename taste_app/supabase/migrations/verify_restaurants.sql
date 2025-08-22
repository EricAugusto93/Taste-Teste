-- Verificar quantos restaurantes existem agora
SELECT COUNT(*) as total_restaurants FROM restaurants;

-- Mostrar os restaurantes inseridos
SELECT id, name, category_id, latitude, longitude, is_open, rating 
FROM restaurants 
ORDER BY created_at DESC;