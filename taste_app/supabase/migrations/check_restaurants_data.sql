-- Verificar se existem restaurantes na tabela
SELECT COUNT(*) as total_restaurants FROM restaurants;

-- Mostrar alguns restaurantes de exemplo
SELECT id, name, category_id, latitude, longitude, is_open 
FROM restaurants 
LIMIT 5;