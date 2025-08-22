-- Limpar categorias existentes para evitar duplicatas
DELETE FROM categories;

-- Inserir categorias baseadas nos tipos de culinária dos restaurantes
INSERT INTO categories (name, icon, color) VALUES 
('Japonesa', '🍣', '#FF6B47'),
('Mexicana', '🌮', '#FF8C42'),
('Italiana', '🍝', '#FF6B6B'),
('Chinesa', '🥢', '#FFD93D'),
('Saudável', '🥗', '#6BCF7F'),
('Cafeteria', '☕', '#8B4513'),
('Buffet', '🍽️', '#FF9F43'),
('Churrascaria', '🥩', '#C44569'),
('Uruguaia', '🇺🇾', '#4834D4'),
('Árabe', '🧆', '#F8B500'),
('Indiana', '🍛', '#FF6348'),
('Doceria', '🧁', '#FF69B4'),
('Hamburgueria', '🍔', '#FF4757'),
('Lancheria', '🥪', '#FFA502');

-- Atualizar os restaurantes com suas respectivas categorias
UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Japonesa' LIMIT 1
) WHERE name = 'Maki';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Mexicana' LIMIT 1
) WHERE name = 'Tangamandápio';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Italiana' LIMIT 1
) WHERE name = 'A Cantina do Press';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Chinesa' LIMIT 1
) WHERE name = 'You Yi';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Saudável' LIMIT 1
) WHERE name = 'Green Station';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Cafeteria' LIMIT 1
) WHERE name = 'Horneria';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Cafeteria' LIMIT 1
) WHERE name = 'The Coffee';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Buffet' LIMIT 1
) WHERE name = 'O Galo Cinza';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Churrascaria' LIMIT 1
) WHERE name = 'Princesa Isabel';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Uruguaia' LIMIT 1
) WHERE name = 'Sabor de Luna';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Italiana' LIMIT 1
) WHERE name = 'Peppo Cucina';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Árabe' LIMIT 1
) WHERE name = 'Al Nur';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Indiana' LIMIT 1
) WHERE name = 'Sharin';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Doceria' LIMIT 1
) WHERE name = 'CauCakes';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Hamburgueria' LIMIT 1
) WHERE name = 'Five Points';

UPDATE restaurants SET category_id = (
  SELECT id FROM categories WHERE name = 'Lancheria' LIMIT 1
) WHERE name = '14bis';