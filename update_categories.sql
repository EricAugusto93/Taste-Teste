-- Atualizar categorias do Taste App
-- Remove categorias antigas e adiciona as novas categorias personalizadas

BEGIN;

-- 1. Primeiro, vamos remover todas as categorias existentes
DELETE FROM categories;

-- 2. Inserir as novas categorias com ordem específica
INSERT INTO categories (id, name, emoji, sort_order, created_at, updated_at) VALUES
-- Date night - Restaurantes românticos e sofisticados
('date-night-001', 'Date night', '💕', 1, NOW(), NOW()),

-- Para curar ressaca - Comida caseira, cafés, brunches
('curar-ressaca-002', 'Para curar ressaca', '🍳', 2, NOW(), NOW()),

-- Com vibe leve - Lugares casuais, descontraídos
('vibe-leve-003', 'Com vibe leve', '🌿', 3, NOW(), NOW()),

-- Clássicos POA - Tradicionais de Porto Alegre
('classicos-poa-004', 'Classicos POA', '🏛️', 4, NOW(), NOW()),

-- Vontade de Doce - Docerias, cafés, sobremesas
('vontade-doce-005', 'Vontade de Doce', '🍰', 5, NOW(), NOW()),

-- Almoço de Domingo - Comida de família, buffets
('almoco-domingo-006', 'Almoço de Domingo', '🍽️', 6, NOW(), NOW()),

-- Happy Hour de Firma - Bares, petiscos, drinks
('happy-hour-007', 'Happy Hour de Firma', '🍻', 7, NOW(), NOW()),

-- Sushi Fresh - Comida japonesa, sushi
('sushi-fresh-008', 'Sushi Fresh', '🍣', 8, NOW(), NOW());

COMMIT;

-- Verificar se as categorias foram inseridas
SELECT id, name, emoji, sort_order FROM categories ORDER BY sort_order;