-- Sincronização das categorias com os tipos do painel administrativo
-- Este arquivo estabelece a correspondência entre os containers do Taste App e os tipos do admin panel

-- Primeiro, vamos limpar as categorias existentes para evitar duplicatas
DELETE FROM categories WHERE id IN (
  SELECT id FROM categories WHERE name IN (
    'Brasileira', 'Italiana', 'Japonesa', 'Chinesa', 'Mexicana', 'Indiana',
    'Fast Food', 'Pizzaria', 'Churrascaria', 'Vegetariana', 'Vegana',
    'Frutos do Mar', 'Hambúrguer', 'Café', 'Padaria', 'Sorveteria'
  )
);

-- Inserir as categorias sincronizadas com o painel administrativo
INSERT INTO categories (id, name, icon, color, is_active, sort_order) VALUES
-- Categorias principais com cores vibrantes e ícones apropriados
(gen_random_uuid(), 'Brasileira', 'restaurant', '#FF6B47', true, 1),
(gen_random_uuid(), 'Italiana', 'local_pizza', '#4CAF50', true, 2),
(gen_random_uuid(), 'Japonesa', 'ramen_dining', '#FF9800', true, 3),
(gen_random_uuid(), 'Chinesa', 'rice_bowl', '#F44336', true, 4),
(gen_random_uuid(), 'Mexicana', 'local_dining', '#9C27B0', true, 5),
(gen_random_uuid(), 'Indiana', 'curry', '#FF5722', true, 6),

-- Categorias de estilo de serviço
(gen_random_uuid(), 'Fast Food', 'fastfood', '#FFC107', true, 7),
(gen_random_uuid(), 'Pizzaria', 'local_pizza', '#E91E63', true, 8),
(gen_random_uuid(), 'Churrascaria', 'outdoor_grill', '#795548', true, 9),

-- Categorias especiais
(gen_random_uuid(), 'Vegetariana', 'eco', '#4CAF50', true, 10),
(gen_random_uuid(), 'Vegana', 'nature', '#8BC34A', true, 11),
(gen_random_uuid(), 'Frutos do Mar', 'set_meal', '#00BCD4', true, 12),

-- Categorias específicas
(gen_random_uuid(), 'Hambúrguer', 'lunch_dining', '#FF5722', true, 13),
(gen_random_uuid(), 'Café', 'local_cafe', '#6D4C41', true, 14),
(gen_random_uuid(), 'Padaria', 'bakery_dining', '#FF9800', true, 15),
(gen_random_uuid(), 'Sorveteria', 'icecream', '#E1BEE7', true, 16);

-- Verificar as categorias inseridas
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