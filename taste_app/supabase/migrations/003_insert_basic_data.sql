-- Inserção de dados básicos para o Taste App (sem reviews)

-- Inserir categorias
INSERT INTO categories (name, icon, color) VALUES
('Pizza', '🍕', '#FF6B47'),
('Hambúrguer', '🍔', '#FF8C42'),
('Japonesa', '🍣', '#FF6B47'),
('Italiana', '🍝', '#FF8C42'),
('Brasileira', '🍖', '#FF6B47'),
('Mexicana', '🌮', '#FF8C42'),
('Chinesa', '🥡', '#FF6B47'),
('Sobremesas', '🍰', '#FF8C42'),
('Saudável', '🥗', '#4CAF50'),
('Bebidas', '🥤', '#2196F3')
ON CONFLICT DO NOTHING;

-- Inserir restaurantes de exemplo
INSERT INTO restaurants (name, description, category_id, image_url, rating, delivery_time, delivery_fee, latitude, longitude, address, phone, is_featured) VALUES
(
    'Pizzaria Bella Napoli',
    'Autêntica pizza italiana com ingredientes frescos e massa artesanal',
    (SELECT id FROM categories WHERE name = 'Pizza' LIMIT 1),
    'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
    4.8,
    '25-35 min',
    5.99,
    -23.5505,
    -46.6333,
    'Rua Augusta, 123 - Consolação, São Paulo - SP',
    '(11) 99999-0001',
    true
),
(
    'Burger House',
    'Os melhores hambúrguers artesanais da cidade com batatas especiais',
    (SELECT id FROM categories WHERE name = 'Hambúrguer' LIMIT 1),
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    4.6,
    '20-30 min',
    4.50,
    -23.5489,
    -46.6388,
    'Av. Paulista, 456 - Bela Vista, São Paulo - SP',
    '(11) 99999-0002',
    true
),
(
    'Sushi Zen',
    'Culinária japonesa tradicional com peixes frescos e ambiente aconchegante',
    (SELECT id FROM categories WHERE name = 'Japonesa' LIMIT 1),
    'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
    4.9,
    '30-40 min',
    7.99,
    -23.5558,
    -46.6396,
    'Rua da Consolação, 789 - Consolação, São Paulo - SP',
    '(11) 99999-0003',
    true
),
(
    'Nonna Italiana',
    'Massas caseiras e molhos tradicionais da nonna italiana',
    (SELECT id FROM categories WHERE name = 'Italiana' LIMIT 1),
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400',
    4.7,
    '35-45 min',
    6.50,
    -23.5475,
    -46.6361,
    'Rua Oscar Freire, 321 - Jardins, São Paulo - SP',
    '(11) 99999-0004',
    false
),
(
    'Churrascaria Gaúcha',
    'Carnes nobres e buffet completo no estilo tradicional gaúcho',
    (SELECT id FROM categories WHERE name = 'Brasileira' LIMIT 1),
    'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
    4.5,
    '40-50 min',
    8.99,
    -23.5629,
    -46.6544,
    'Av. Faria Lima, 654 - Itaim Bibi, São Paulo - SP',
    '(11) 99999-0005',
    false
),
(
    'Taco Loco',
    'Sabores autênticos do México com ingredientes frescos e especiarias',
    (SELECT id FROM categories WHERE name = 'Mexicana' LIMIT 1),
    'https://images.unsplash.com/photo-1565299585323-38174c4a6c18?w=400',
    4.4,
    '25-35 min',
    5.50,
    -23.5506,
    -46.6394,
    'Rua Haddock Lobo, 987 - Cerqueira César, São Paulo - SP',
    '(11) 99999-0006',
    false
),
(
    'Dragon Wok',
    'Culinária chinesa tradicional com pratos quentes e saborosos',
    (SELECT id FROM categories WHERE name = 'Chinesa' LIMIT 1),
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
    4.3,
    '30-40 min',
    6.00,
    -23.5577,
    -46.6611,
    'Rua da Liberdade, 147 - Liberdade, São Paulo - SP',
    '(11) 99999-0007',
    false
),
(
    'Sweet Dreams',
    'Doces artesanais, bolos e sobremesas irresistíveis',
    (SELECT id FROM categories WHERE name = 'Sobremesas' LIMIT 1),
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    4.8,
    '15-25 min',
    3.99,
    -23.5482,
    -46.6342,
    'Rua Bela Cintra, 258 - Consolação, São Paulo - SP',
    '(11) 99999-0008',
    true
),
(
    'Green Life',
    'Opções saudáveis, saladas frescas e pratos veganos nutritivos',
    (SELECT id FROM categories WHERE name = 'Saudável' LIMIT 1),
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    4.6,
    '20-30 min',
    4.99,
    -23.5518,
    -46.6777,
    'Av. Rebouças, 369 - Pinheiros, São Paulo - SP',
    '(11) 99999-0009',
    false
),
(
    'Juice Bar',
    'Sucos naturais, vitaminas e bebidas refrescantes',
    (SELECT id FROM categories WHERE name = 'Bebidas' LIMIT 1),
    'https://images.unsplash.com/photo-1546173159-315724a31696?w=400',
    4.2,
    '10-20 min',
    2.99,
    -23.5533,
    -46.6729,
    'Rua Teodoro Sampaio, 741 - Pinheiros, São Paulo - SP',
    '(11) 99999-0010',
    false
)
ON CONFLICT DO NOTHING;

-- Conceder permissões para as roles anon e authenticated
GRANT SELECT ON categories TO anon;
GRANT SELECT ON restaurants TO anon;
GRANT SELECT ON reviews TO anon;

GRANT ALL PRIVILEGES ON categories TO authenticated;
GRANT ALL PRIVILEGES ON restaurants TO authenticated;
GRANT ALL PRIVILEGES ON reviews TO authenticated;
GRANT ALL PRIVILEGES ON favorites TO authenticated;
GRANT ALL PRIVILEGES ON search_history TO authenticated;