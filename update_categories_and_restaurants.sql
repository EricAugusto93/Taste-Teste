-- Reorganizar restaurantes com novas categorias personalizadas
-- Estratégia: atualizar categorias existentes com novos nomes e reorganizar restaurantes

BEGIN;

-- 1. Atualizar as categorias existentes com as novas categorias personalizadas
-- Mapeamento inteligente baseado no tipo de restaurante atual

-- Date night (românticos, sofisticados)
UPDATE categories SET 
  name = 'Date night', 
  icon = '💕',
  updated_at = NOW()
WHERE name = 'Italiana'; -- Restaurantes italianos são ótimos para date night

-- Para curar ressaca (comida caseira, brunches)
UPDATE categories SET 
  name = 'Para curar ressaca', 
  icon = '🍳',
  updated_at = NOW()
WHERE name = 'Café'; -- Cafés são perfeitos para curar ressaca

-- Com vibe leve (casuais, descontraídos)  
UPDATE categories SET 
  name = 'Com vibe leve', 
  icon = '🌿',
  updated_at = NOW()
WHERE name = 'Saudável'; -- Lugares saudáveis têm vibe leve

-- Clássicos POA (tradicionais de Porto Alegre)
UPDATE categories SET 
  name = 'Classicos POA', 
  icon = '🏛️',
  updated_at = NOW()
WHERE name = 'Churrascaria'; -- Churrascarias são clássicos do RS

-- Vontade de Doce (docerias, sobremesas)
UPDATE categories SET 
  name = 'Vontade de Doce', 
  icon = '🍰',
  updated_at = NOW()
WHERE name = 'Doceria'; -- Já eram docerias

-- Almoço de Domingo (buffets, comida de família)
UPDATE categories SET 
  name = 'Almoço de Domingo', 
  icon = '🍽️',
  updated_at = NOW()
WHERE name = 'Buffet'; -- Buffets são perfeitos para almoço em família

-- Happy Hour de Firma (bares, petiscos)
UPDATE categories SET 
  name = 'Happy Hour de Firma', 
  icon = '🍻',
  updated_at = NOW()
WHERE name = 'Hamburgueria'; -- Hamburguerias são boas para happy hour

-- Sushi Freh (comida japonesa)
UPDATE categories SET 
  name = 'Sushi Freh', 
  icon = '🍣',
  updated_at = NOW()
WHERE name = 'Japonesa'; -- Já era japonesa

-- 2. Reorganizar os outros restaurantes nas categorias que fazem mais sentido

-- Pizzaria -> Happy Hour de Firma (pizza + cerveja = happy hour)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Happy Hour de Firma'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Pizzaria');

-- Fast Food -> Com vibe leve (casual)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Com vibe leve'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Fast Food');

-- Árabe -> Date night (culinária exótica é boa para encontros)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Date night'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Árabe');

-- Chinesa -> Sushi Freh (asiática em geral)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Sushi Freh'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Chinesa');

-- Indiana -> Date night (culinária especial)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Date night'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Indiana');

-- Mexicana -> Happy Hour de Firma (comida mexicana + drinks)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Happy Hour de Firma'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Mexicana');

-- Uruguaia -> Classicos POA (cultura sulista similar)
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Classicos POA'
) WHERE category_id = (SELECT id FROM categories WHERE name = 'Uruguaia');

-- 3. Remover categorias que não são mais usadas
DELETE FROM categories WHERE name NOT IN (
  'Date night', 'Para curar ressaca', 'Com vibe leve', 'Classicos POA', 
  'Vontade de Doce', 'Almoço de Domingo', 'Happy Hour de Firma', 'Sushi Freh'
);

-- 4. Atualizar sort_order das categorias
UPDATE categories SET sort_order = 1 WHERE name = 'Date night';
UPDATE categories SET sort_order = 2 WHERE name = 'Para curar ressaca';
UPDATE categories SET sort_order = 3 WHERE name = 'Com vibe leve';
UPDATE categories SET sort_order = 4 WHERE name = 'Classicos POA';
UPDATE categories SET sort_order = 5 WHERE name = 'Vontade de Doce';
UPDATE categories SET sort_order = 6 WHERE name = 'Almoço de Domingo';
UPDATE categories SET sort_order = 7 WHERE name = 'Happy Hour de Firma';
UPDATE categories SET sort_order = 8 WHERE name = 'Sushi Freh';

COMMIT;

-- Verificar o resultado
SELECT 
  c.name as categoria,
  c.icon,
  c.sort_order,
  COUNT(r.id) as total_restaurantes,
  STRING_AGG(r.name, ', ') as restaurantes
FROM categories c
LEFT JOIN restaurants r ON c.id = r.category_id
GROUP BY c.id, c.name, c.icon, c.sort_order
ORDER BY c.sort_order;