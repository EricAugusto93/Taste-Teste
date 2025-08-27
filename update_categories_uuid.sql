-- Atualizar categorias do Taste App com UUIDs válidos
-- Remove categorias antigas e adiciona as novas categorias personalizadas

BEGIN;

-- 1. Primeiro, vamos remover todas as categorias existentes
DELETE FROM categories;

-- 2. Inserir as novas categorias com UUIDs válidos e ordem específica
INSERT INTO categories (id, name, emoji, sort_order, created_at, updated_at) VALUES
-- Date night - Restaurantes românticos e sofisticados
('a1b2c3d4-e5f6-4789-89ab-1234567890ab', 'Date night', '💕', 1, NOW(), NOW()),

-- Para curar ressaca - Comida caseira, cafés, brunches
('b2c3d4e5-f6g7-5890-90bc-2345678901bc', 'Para curar ressaca', '🍳', 2, NOW(), NOW()),

-- Com vibe leve - Lugares casuais, descontraídos
('c3d4e5f6-g7h8-6901-01cd-3456789012cd', 'Com vibe leve', '🌿', 3, NOW(), NOW()),

-- Clássicos POA - Tradicionais de Porto Alegre
('d4e5f6g7-h8i9-7012-12de-4567890123de', 'Classicos POA', '🏛️', 4, NOW(), NOW()),

-- Vontade de Doce - Docerias, cafés, sobremesas
('e5f6g7h8-i9j0-8123-23ef-5678901234ef', 'Vontade de Doce', '🍰', 5, NOW(), NOW()),

-- Almoço de Domingo - Comida de família, buffets
('f6g7h8i9-j0k1-9234-34fg-6789012345fg', 'Almoço de Domingo', '🍽️', 6, NOW(), NOW()),

-- Happy Hour de Firma - Bares, petiscos, drinks
('g7h8i9j0-k1l2-0345-45gh-7890123456gh', 'Happy Hour de Firma', '🍻', 7, NOW(), NOW()),

-- Sushi Fresh - Comida japonesa, sushi
('h8i9j0k1-l2m3-1456-56hi-8901234567hi', 'Sushi Fresh', '🍣', 8, NOW(), NOW());

COMMIT;

-- Verificar se as categorias foram inseridas
SELECT id, name, emoji, sort_order FROM categories ORDER BY sort_order;