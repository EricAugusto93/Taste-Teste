-- Atualizar categorias existentes para sincronizar com o painel administrativo
-- Esta migração atualiza as categorias existentes ao invés de deletá-las

-- Primeiro, vamos ver quais categorias já existem
SELECT id, name, icon, color FROM categories ORDER BY sort_order;

-- Atualizar categorias existentes com nomes e ícones apropriados
-- Vamos mapear as categorias existentes para os tipos do painel administrativo

-- Se existirem categorias, vamos atualizá-las
UPDATE categories SET 
    name = 'Brasileira',
    icon = 'restaurant',
    color = '#FF6B47',
    sort_order = 1
WHERE name ILIKE '%brasil%' OR name ILIKE '%tradicional%';

UPDATE categories SET 
    name = 'Italiana',
    icon = 'local_pizza',
    color = '#4CAF50',
    sort_order = 2
WHERE name ILIKE '%ital%' OR name ILIKE '%pizza%';

UPDATE categories SET 
    name = 'Japonesa',
    icon = 'ramen_dining',
    color = '#FF9800',
    sort_order = 3
WHERE name ILIKE '%japon%' OR name ILIKE '%sushi%';

UPDATE categories SET 
    name = 'Fast Food',
    icon = 'fastfood',
    color = '#FFC107',
    sort_order = 7
WHERE name ILIKE '%fast%' OR name ILIKE '%lanche%';

UPDATE categories SET 
    name = 'Café',
    icon = 'local_cafe',
    color = '#6D4C41',
    sort_order = 14
WHERE name ILIKE '%caf%' OR name ILIKE '%coffee%';

-- Inserir categorias que não existem ainda
INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Chinesa', 'rice_bowl', '#F44336', true, 4
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Chinesa');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Mexicana', 'local_dining', '#9C27B0', true, 5
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Mexicana');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Indiana', 'curry', '#FF5722', true, 6
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Indiana');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Pizzaria', 'local_pizza', '#E91E63', true, 8
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Pizzaria');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Churrascaria', 'outdoor_grill', '#795548', true, 9
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Churrascaria');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Vegetariana', 'eco', '#4CAF50', true, 10
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Vegetariana');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Vegana', 'nature', '#8BC34A', true, 11
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Vegana');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Frutos do Mar', 'set_meal', '#00BCD4', true, 12
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Frutos do Mar');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Hambúrguer', 'lunch_dining', '#FF5722', true, 13
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Hambúrguer');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Padaria', 'bakery_dining', '#FF9800', true, 15
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Padaria');

INSERT INTO categories (id, name, icon, color, is_active, sort_order)
SELECT gen_random_uuid(), 'Sorveteria', 'icecream', '#E1BEE7', true, 16
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Sorveteria');

-- Verificar o resultado final
SELECT 
    id,
    name,
    icon,
    color,
    is_active,
    sort_order
FROM categories 
WHERE is_active = true
ORDER BY sort_order ASC;