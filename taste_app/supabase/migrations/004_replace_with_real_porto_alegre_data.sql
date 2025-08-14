-- Migração para substituir dados mocados por restaurantes reais de Porto Alegre
-- Data: $(date)

-- Primeiro, limpar dados existentes
DELETE FROM reviews;
DELETE FROM restaurants;
DELETE FROM categories;

-- Inserir categorias atualizadas
INSERT INTO categories (name, icon, color) VALUES
('Japonesa', '🍣', '#FF6B47'),
('Mexicana', '🌮', '#FF8C42'),
('Italiana', '🍝', '#FF6B47'),
('Chinesa', '🥡', '#FF8C42'),
('Saudável', '🥗', '#4CAF50'),
('Cafeteria', '☕', '#8D6E63'),
('Buffet', '🍽️', '#FF9800'),
('Churrascaria', '🥩', '#D32F2F'),
('Padaria', '🥖', '#FFC107'),
('Árabe', '🧆', '#9C27B0'),
('Indiana', '🍛', '#E91E63'),
('Doceria', '🍰', '#FF8C42'),
('Hamburgueria', '🍔', '#FF5722'),
('Lancheria', '🥪', '#607D8B')
ON CONFLICT DO NOTHING;

-- Inserir restaurantes reais de Porto Alegre
INSERT INTO restaurants (name, description, category_id, image_url, rating, delivery_time, delivery_fee, latitude, longitude, address, phone, is_featured) VALUES
(
    'Maki',
    'Sushis fresquinhos, toque contemporâneo e a vibe perfeita para um jantar! O Maki entrega sabor e frescor em cada peça. Combinamos para você ou para dividir!',
    (SELECT id FROM categories WHERE name = 'Japonesa' LIMIT 1),
    'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
    4.7,
    '25-35 min',
    6.99,
    -30.0346,
    -51.2177,
    'Rua Cabral, 285 - Rio Branco, Porto Alegre - RS',
    '(51) 3333-0001',
    true
),
(
    'Tangamandápio',
    'Tacos autorais, drinks vibrantes e uma alma latina que não se esconde. A taqueria que começou no delivery hoje tem garagem aberta para quem busca sabor, criatividade e boas histórias.',
    (SELECT id FROM categories WHERE name = 'Mexicana' LIMIT 1),
    'https://images.unsplash.com/photo-1565299585323-38174c4a6c18?w=400',
    4.6,
    '30-40 min',
    7.50,
    -30.0194,
    -51.1982,
    'Av. Plínio Brasil Milano, 20 - Auxiliadora, Porto Alegre - RS',
    '(51) 3333-0002',
    true
),
(
    'A Cantina do Press',
    'Clássicos italianos com pegada moderna, drinks incríveis e uma energia que faz querer voltar. A Cantina do Press é onde a lasanha é premiada — e o clima, intimista e alto astral.',
    (SELECT id FROM categories WHERE name = 'Italiana' LIMIT 1),
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400',
    4.8,
    '35-45 min',
    8.00,
    -30.0277,
    -51.1946,
    'Av. João Wallig, 1600 - loja 2264 - Passo D''areia, Porto Alegre - RS',
    '(51) 3333-0003',
    true
),
(
    'You Yi',
    'Receitas típicas, sabores intensos e uma história que atravessa gerações. No You Yi, a gastronomia chinesa ganha vida com afeto, tradição e muito sabor.',
    (SELECT id FROM categories WHERE name = 'Chinesa' LIMIT 1),
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
    4.5,
    '25-35 min',
    6.50,
    -30.0194,
    -51.1982,
    'Rua Cândido Silveira, 242 - Auxiliadora, Porto Alegre - RS',
    '(51) 3333-0004',
    false
),
(
    'Green Station',
    'Saladas feitas na hora, wraps fresquinhos e praticidade sem abrir mão do sabor. O Green Station chegou pra quem ama comer bem, rápido e do seu jeito.',
    (SELECT id FROM categories WHERE name = 'Saudável' LIMIT 1),
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    4.4,
    '20-30 min',
    5.99,
    -30.0118,
    -51.1982,
    'Rua Comendador Caminha, 358 - Moinhos de Vento, Porto Alegre - RS',
    '(51) 3333-0005',
    false
),
(
    'Horneria',
    'Pães artesanais saindo do forno, brunch o dia todo e aquele clima que só lugar feito com carinho tem. Na Horneria, tudo é feito na hora — e do seu jeito.',
    (SELECT id FROM categories WHERE name = 'Cafeteria' LIMIT 1),
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400',
    4.6,
    '15-25 min',
    4.50,
    -30.0194,
    -51.1982,
    'Av. Nova York, 231 - Auxiliadora, Porto Alegre - RS',
    '(51) 3333-0006',
    true
),
(
    'The Coffee',
    'Cafés especiais, design minimalista e uma experiência que vai além do copo. Na The Coffee, cada detalhe importa — do grão à sua casa.',
    (SELECT id FROM categories WHERE name = 'Cafeteria' LIMIT 1),
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
    4.7,
    '10-20 min',
    3.99,
    -30.0118,
    -51.1982,
    'Rua 24 de Outubro, 636 - Moinhos de Vento, Porto Alegre - RS',
    '(51) 3333-0007',
    false
),
(
    'O Galo Cinza',
    'Comida com sabor de aconchego, feita com carinho e servida sem pressa. O Galo Cinza é aquele buffet livre que abraça no prato.',
    (SELECT id FROM categories WHERE name = 'Buffet' LIMIT 1),
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
    4.3,
    '30-40 min',
    9.50,
    -30.0194,
    -51.1982,
    'Rua Eudoro Berlink, 855 - Auxiliadora, Porto Alegre - RS',
    '(51) 3333-0008',
    false
),
(
    'Princesa Isabel',
    'Churrasco raiz, espeto corrido e aquele banquete de acompanhamentos que não pode faltar. A Princesa Isabel é tradição gaúcha servida com orgulho.',
    (SELECT id FROM categories WHERE name = 'Churrascaria' LIMIT 1),
    'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
    4.5,
    '40-50 min',
    12.00,
    -30.0346,
    -51.2177,
    'Rua São Luís, 410 - Santana, Porto Alegre - RS',
    '(51) 3333-0009',
    false
),
(
    'Sabor de Luna',
    'Sabores típicos do Uruguai, feitos de forma artesanal e cheios de memória. No Sabor de Luna, cada receita rio-platense é um convite pra sentir-se em casa — ou em Montevideo.',
    (SELECT id FROM categories WHERE name = 'Padaria' LIMIT 1),
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
    4.4,
    '25-35 min',
    7.99,
    -30.0346,
    -51.2177,
    'Rua Doutor Freire Alemão, 310 - Mont''Serrat, Porto Alegre - RS',
    '(51) 3333-0010',
    false
),
(
    'Peppo Cucina',
    'Receitas italianas com alma caseira, toques modernos e uma taça sempre bem servida. No Peppo, cada detalhe celebra o prazer de receber — com sabor e afeto.',
    (SELECT id FROM categories WHERE name = 'Italiana' LIMIT 1),
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400',
    4.6,
    '30-40 min',
    8.50,
    -30.0346,
    -51.2177,
    'Rua Dona Laura, 161 - Rio Branco, Porto Alegre - RS',
    '(51) 3333-0011',
    true
),
(
    'Al Nur',
    'Mais de três décadas de tradição, especiarias na medida e aquele sabor que aquece. O Al Nur é referência em cozinha árabe — pra levar ou saborear onde quiser.',
    (SELECT id FROM categories WHERE name = 'Árabe' LIMIT 1),
    'https://images.unsplash.com/photo-1544510808-5e41d7d2c8b6?w=400',
    4.7,
    '25-35 min',
    6.99,
    -30.0346,
    -51.2177,
    'Av. Protásio Alves, 616 - Santa Cecília, Porto Alegre - RS',
    '(51) 3333-0012',
    false
),
(
    'Sharin',
    'Sabores intensos, aromas marcantes e uma cozinha que mistura tradição indiana com toques contemporâneos. No Sharin, cada prato é uma viagem — e seu evento, uma experiência memorável.',
    (SELECT id FROM categories WHERE name = 'Indiana' LIMIT 1),
    'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
    4.5,
    '30-40 min',
    7.50,
    -30.0194,
    -51.1982,
    'Rua Felipe Neri, 332 - Auxiliadora, Porto Alegre - RS',
    '(51) 3333-0013',
    false
),
(
    'CauCakes',
    'Doces autorais, vibes cor de rosa e um cantinho cheio de charme para curtir sem pressa. A CauCakes é sabor, afeto e uma experiência pra lembrar (e postar!).',
    (SELECT id FROM categories WHERE name = 'Doceria' LIMIT 1),
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    4.8,
    '15-25 min',
    4.99,
    -30.0118,
    -51.1982,
    'Rua Dinarte Ribeiro, 95 - Moinhos de Vento, Porto Alegre - RS',
    '(51) 3333-0014',
    true
),
(
    'Five Points',
    'Grelha no comando, bacon artesanal e sabor em cada detalhe. No Five Points, tudo é feito com ingredientes próprios — e no ponto certo.',
    (SELECT id FROM categories WHERE name = 'Hamburgueria' LIMIT 1),
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    4.6,
    '25-35 min',
    8.99,
    -30.0346,
    -51.2177,
    'Av. Dr. Nilo Peçanha, 3228 - loja 3 - Chácara das Pedras, Porto Alegre - RS',
    '(51) 3333-0015',
    false
),
(
    '14bis',
    'Xis clássico com sabor de verdade, maionese leve e aquele acebolado que vale a pena sair da rota. No 14 Bis, é tudo do jeitinho que a gente gosta — sem erro.',
    (SELECT id FROM categories WHERE name = 'Lancheria' LIMIT 1),
    'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400',
    4.4,
    '20-30 min',
    5.50,
    -30.0346,
    -51.2177,
    'Av. Plínio Brasil Milano, 1053 - Higienópolis, Porto Alegre - RS',
    '(51) 3333-0016',
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