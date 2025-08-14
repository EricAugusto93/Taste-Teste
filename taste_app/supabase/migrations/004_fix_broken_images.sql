-- Verificar e corrigir imagens quebradas no banco de dados

-- Primeiro, vamos verificar se há alguma imagem com o ID problemático
SELECT id, name, image_url 
FROM restaurants 
WHERE image_url LIKE '%photo-1565299624946%';

-- Atualizar qualquer imagem quebrada encontrada
UPDATE restaurants 
SET image_url = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400'
WHERE image_url LIKE '%photo-1565299624946%';

-- Verificar se há outras imagens do Unsplash que podem estar quebradas
SELECT id, name, image_url 
FROM restaurants 
WHERE image_url LIKE '%unsplash.com%' 
AND image_url NOT LIKE '%photo-1574071318508%'
AND image_url NOT LIKE '%photo-1568901346375%'
AND image_url NOT LIKE '%photo-1579584425555%'
AND image_url NOT LIKE '%photo-1551183053-bf91a1d81141%'
AND image_url NOT LIKE '%photo-1544025162-d76694265947%'
AND image_url NOT LIKE '%photo-1565299585323%'
AND image_url NOT LIKE '%photo-1582878826629%'
AND image_url NOT LIKE '%photo-1578985545062%'
AND image_url NOT LIKE '%photo-1512621776951%'
AND image_url NOT LIKE '%photo-1546173159-315724a31696%';

-- Comentário: Esta migração verifica e corrige imagens quebradas
-- A nova imagem é de um restaurante genérico que deve funcionar corretamente