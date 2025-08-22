-- Limpar todos os dados existentes da tabela restaurants
DELETE FROM restaurants;

-- Inserir os 16 novos restaurantes com coordenadas de Porto Alegre
INSERT INTO restaurants (
  name, 
  description, 
  address, 
  latitude, 
  longitude, 
  rating, 
  delivery_time, 
  delivery_fee, 
  is_open, 
  is_featured, 
  price_range,
  min_order_value
) VALUES 
-- 1) Maki - Japonesa
('Maki', 
 'Sushis fresquinhos, toque contemporâneo e a vibe perfeita para um jantar! O Maki entrega sabor e frescor em cada peça. Combinamos para você ou para dividir!', 
 'Rua Cabral, 285, Bairro Rio Branco, Porto Alegre', 
 -30.0346, -51.2177, 
 4.5, '25-35 min', 8.50, true, true, '$$', 25.00),

-- 2) Tangamandápio - Mexicano
('Tangamandápio', 
 'Tacos autorais, drinks vibrantes e uma alma latina que não se esconde. A taqueria que começou no delivery hoje tem garagem aberta para quem busca sabor, criatividade e boas histórias.', 
 'Av. Plínio Brasil Milano, 20, Bairro Auxiliadora, Porto Alegre', 
 -30.0277, -51.1946, 
 4.3, '30-40 min', 7.00, true, false, '$$', 20.00),

-- 3) A Cantina do Press - Italiano
('A Cantina do Press', 
 'Clássicos italianos com pegada moderna, drinks incríveis e uma energia que faz querer voltar. A Cantina do Press é onde a lasanha é premiada — e o clima, intimista e alto astral.', 
 'Av. João Wallig, 1600 - loja 2264, Bairro Passo D''areia, Porto Alegre, Dentro do shopping Iguatemi', 
 -30.0346, -51.2177, 
 4.7, '35-45 min', 12.00, true, true, '$$$', 35.00),

-- 4) You Yi - Chinesa
('You Yi', 
 'Receitas típicas, sabores intensos e uma história que atravessa gerações. No You Yi, a gastronomia chinesa ganha vida com afeto, tradição e muito sabor.', 
 'Rua Cândido Silveira, 242, Bairro Auxiliadora - Porto Alegre', 
 -30.0277, -51.1946, 
 4.4, '25-35 min', 6.50, true, false, '$$', 22.00),

-- 5) Green station - Saudável
('Green Station', 
 'Saladas feitas na hora, wraps fresquinhos e praticidade sem abrir mão do sabor. O Green Station chegou pra quem ama comer bem, rápido e do seu jeito.', 
 'Rua Comendador Caminha, 358, Bairro Moinhos de Vento, Porto Alegre', 
 -30.0118, -51.1882, 
 4.2, '15-25 min', 5.00, true, false, '$', 15.00),

-- 6) Horneria - Cafeteria
('Horneria', 
 'Pães artesanais saindo do forno, brunch o dia todo e aquele clima que só lugar feito com carinho tem. Na Horneria, tudo é feito na hora — e do seu jeito.', 
 'Av. Nova York, 231, Bairro Auxiliadora, Porto Alegre', 
 -30.0277, -51.1946, 
 4.6, '20-30 min', 4.50, true, false, '$', 12.00),

-- 7) The Coffee - Cafeteria
('The Coffee', 
 'Cafés especiais, design minimalista e uma experiência que vai além do copo. Na The Coffee, cada detalhe importa — do grão à sua casa.', 
 'Rua 24 de Outubro, 636, Bairro Moinhos de Vento, Porto Alegre', 
 -30.0118, -51.1882, 
 4.5, '15-25 min', 3.50, true, false, '$', 10.00),

-- 8) O Galo Cinza - Restaurante buffet
('O Galo Cinza', 
 'Comida com sabor de aconchego, feita com carinho e servida sem pressa. O Galo Cinza é aquele buffet livre que abraça no prato.', 
 'Rua Eudoro Berlink, 855, Bairro Auxiliadora, Porto Alegre', 
 -30.0277, -51.1946, 
 4.1, '20-30 min', 9.00, true, false, '$', 18.00),

-- 9) Princesa Isabel - Churrascaria
('Princesa Isabel', 
 'Churrasco raiz, espeto corrido e aquele banquete de acompanhamentos que não pode faltar. A Princesa Isabel é tradição gaúcha servida com orgulho.', 
 'Rua São Luís, 410, Bairro Santana, Porto Alegre', 
 -30.0346, -51.2177, 
 4.3, '40-50 min', 15.00, true, false, '$$$', 45.00),

-- 10) Sabor de Luna - padaria uruguaya
('Sabor de Luna', 
 'Sabores típicos do Uruguai, feitos de forma artesanal e cheios de memória. No Sabor de Luna, cada receita rio-platense é um convite pra sentir-se em casa — ou em Montevidéu.', 
 'Rua Doutor Freire Alemão, 310, Bairro Mon''t Serrat, Porto Alegre', 
 -30.0118, -51.1882, 
 4.0, '25-35 min', 6.00, true, false, '$', 16.00),

-- 11) Peppo Cucina - Italiano
('Peppo Cucina', 
 'Receitas italianas com alma caseira, toques modernos e uma taça sempre bem servida. No Peppo, cada detalhe celebra o prazer de receber — com sabor e afeto.', 
 'Rua Dona Laura, 161, Bairro Rio Branco, Porto Alegre', 
 -30.0346, -51.2177, 
 4.4, '30-40 min', 10.00, true, false, '$$', 28.00),

-- 12) Al Nur - Árabe
('Al Nur', 
 'Mais de três décadas de tradição, especiarias na medida e aquele sabor que aquece. O Al Nur é referência em cozinha árabe — pra levar ou saborear onde quiser.', 
 'Av. Protásio Alves, 616, Bairro Santa Cecília, Porto Alegre', 
 -30.0277, -51.1946, 
 4.6, '25-35 min', 7.50, true, true, '$$', 24.00),

-- 13) Sharin - Indiano
('Sharin', 
 'Sabores intensos, aromas marcantes e uma cozinha que mistura tradição indiana com toques contemporâneos. No Sharin, cada prato é uma viagem — e seu evento, uma experiência memorável.', 
 'Rua Felipe Neri, 332, Bairro Auxiliadora, Porto Alegre', 
 -30.0277, -51.1946, 
 4.5, '30-40 min', 8.00, true, false, '$$', 26.00),

-- 14) CauCakes - Doceria
('CauCakes', 
 'Doces autorais, vibes cor de rosa e um cantinho cheio de charme para curtir sem pressa. A CauCakes é sabor, afeto e uma experiência pra lembrar (e postar!).', 
 'Rua Dinarte Ribeiro, 95, Bairro Moinhos de Vento, Porto Alegre', 
 -30.0118, -51.1882, 
 4.7, '20-30 min', 5.50, true, false, '$', 14.00),

-- 15) Five Points - Hamburgueria
('Five Points', 
 'Grelha no comando, bacon artesanal e sabor em cada detalhe. No Five Points, tudo é feito com ingredientes próprios — e no ponto certo.', 
 'Av. Dr. Nilo Peçanha, 3228 - loja 3, Bairro Chácara das Pedras, Porto Alegre', 
 -30.1118, -51.1882, 
 4.4, '25-35 min', 9.50, true, false, '$$', 22.00),

-- 16) 14bis - Lancheria
('14bis', 
 'Xis clássico com sabor de verdade, maionese leve e aquele acebolado que vale a pena sair da rota. No 14 Bis, é tudo do jeitinho que a gente gosta — sem erro.', 
 'Av. Plínio Brasil Milano, 1053, Bairro Higienópolis, Porto Alegre', 
 -30.0277, -51.1946, 
 4.2, '20-30 min', 6.50, true, false, '$', 18.00);

-- Atualizar contadores de avaliações para dar mais realismo
UPDATE restaurants SET review_count = FLOOR(RANDOM() * 100) + 10 WHERE name IN (
  'Maki', 'Tangamandápio', 'A Cantina do Press', 'You Yi', 'Green Station', 
  'Horneria', 'The Coffee', 'O Galo Cinza', 'Princesa Isabel', 'Sabor de Luna',
  'Peppo Cucina', 'Al Nur', 'Sharin', 'CauCakes', 'Five Points', '14bis'
);