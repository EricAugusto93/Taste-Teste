-- Inserir categorias iniciais
INSERT INTO categories (name, icon, color, is_active) VALUES
('Pizza', '🍕', '#FF6B47', true),
('Hambúrguer', '🍔', '#FFB347', true),
('Sushi', '🍣', '#47B5FF', true),
('Sobremesa', '🧁', '#FF69B4', true),
('Café', '☕', '#8B4513', true),
('Vegetariano', '🥗', '#32CD32', true),
('Churrasco', '🥩', '#DC143C', true),
('Italiana', '🍝', '#228B22', true)
ON CONFLICT (name) DO NOTHING;

-- Verificar se as categorias foram inseridas
SELECT * FROM categories ORDER BY name;