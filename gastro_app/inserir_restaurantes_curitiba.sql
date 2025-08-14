-- Script para inserir restaurantes de teste em Curitiba
-- Execute este script diretamente no Supabase SQL Editor

-- Inserir restaurantes próximos a Curitiba
INSERT INTO restaurantes (
  nome, tipo, descricao, endereco, latitude, longitude, 
  telefone, preco_medio, imagem_url, tags, ativo
) VALUES 
(
  'Churrascaria Gaúcha',
  'churrascaria',
  'Tradicional churrascaria com carnes nobres e buffet completo.',
  'Rua XV de Novembro, 100 - Centro, Curitiba',
  -25.4284,
  -49.2733,
  '(41) 99999-1111',
  65.00,
  'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
  ARRAY['churrasco', 'carne', 'buffet', 'tradicional'],
  true
),
(
  'Bistrô do Batel',
  'contemporâneo',
  'Culinária contemporânea em ambiente sofisticado no coração do Batel.',
  'Av. Batel, 200 - Batel, Curitiba',
  -25.4372,
  -49.2844,
  '(41) 99999-2222',
  85.00,
  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
  ARRAY['contemporâneo', 'sofisticado', 'batel', 'jantar'],
  true
),
(
  'Pizzaria Curitibana',
  'italiano',
  'Pizza artesanal com ingredientes locais e massa fermentada naturalmente.',
  'Rua Comendador Araújo, 300 - Centro, Curitiba',
  -25.4195,
  -49.2646,
  '(41) 99999-3333',
  40.00,
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
  ARRAY['pizza', 'artesanal', 'massa natural', 'local'],
  true
),
(
  'Café Central',
  'café',
  'Café especial com torrefação própria no centro histórico de Curitiba.',
  'Largo da Ordem, 50 - Centro Histórico, Curitiba',
  -25.4284,
  -49.2733,
  '(41) 99999-4444',
  20.00,
  'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
  ARRAY['café especial', 'torrefação', 'centro histórico', 'wifi'],
  true
),
(
  'Sushi Curitiba',
  'japonês',
  'Sushi bar moderno com peixes frescos e ambiente descontraído.',
  'Rua Marechal Deodoro, 400 - Centro, Curitiba',
  -25.4284,
  -49.2733,
  '(41) 99999-5555',
  70.00,
  'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
  ARRAY['sushi', 'peixe fresco', 'moderno', 'descontraído'],
  true
)
ON CONFLICT (nome) DO NOTHING;

-- Verificar se os restaurantes foram inseridos
SELECT nome, tipo, latitude, longitude FROM restaurantes 
WHERE nome IN (
  'Churrascaria Gaúcha', 
  'Bistrô do Batel', 
  'Pizzaria Curitibana', 
  'Café Central', 
  'Sushi Curitiba'
)
ORDER BY nome;