-- Script para inserir restaurantes "14bis" e "Five Points" na categoria "Para Beber"
-- Execute no Supabase SQL Editor

-- Inserir 14bis como BAR
INSERT INTO restaurantes (
  nome, tipo, descricao, endereco, latitude, longitude, 
  telefone, preco_medio, imagem_url, tags, ativo
) VALUES (
  '14bis',
  'bar',
  'Bar brasileiro com ambiente descontraído, perfeito para drinks e happy hour com amigos. Ambiente acolhedor com música ao vivo e petiscos tradicionais.',
  'Rua Padre Chagas, 300 - Moinhos de Vento, Porto Alegre',
  -30.0277,
  -51.2287,
  '(51) 99999-1414',
  45.00,
  'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500',
  ARRAY['bar', 'drinks', 'happy hour', 'música ao vivo', 'petiscos', 'brasileira', 'descontraído'],
  true
)
ON CONFLICT (nome) DO UPDATE SET
  tipo = EXCLUDED.tipo,
  descricao = EXCLUDED.descricao,
  tags = EXCLUDED.tags;

-- Inserir Five Points como CERVEJARIA
INSERT INTO restaurantes (
  nome, tipo, descricao, endereco, latitude, longitude, 
  telefone, preco_medio, imagem_url, tags, ativo
) VALUES (
  'Five Points',
  'cervejaria',
  'Cervejaria americana com grande variedade de cervejas artesanais e chopp gelado. Ambiente casual com decoração industrial e cardápio de pub food.',
  'Rua José Bonifácio, 500 - Cidade Baixa, Porto Alegre',
  -30.0346,
  -51.2177,
  '(51) 99999-5555',
  55.00,
  'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=500',
  ARRAY['cervejaria', 'beer', 'cerveja artesanal', 'chopp', 'pub food', 'americana', 'casual', 'industrial'],
  true
)
ON CONFLICT (nome) DO UPDATE SET
  tipo = EXCLUDED.tipo,
  descricao = EXCLUDED.descricao,
  tags = EXCLUDED.tags;

-- Verificar se os restaurantes foram inseridos corretamente
SELECT 
  nome, 
  tipo, 
  tags,
  CASE 
    WHEN tipo ILIKE ANY(ARRAY['%bar%', '%pub%', '%cervejaria%', '%choperia%', '%lounge%']) THEN '✅ Tipo OK'
    ELSE '❌ Tipo não reconhecido'
  END as status_tipo,
  CASE 
    WHEN tags && ARRAY['bar', 'cerveja', 'beer', 'drinks', 'happy hour', 'chopp'] THEN '✅ Tags OK'
    ELSE '❌ Tags não reconhecidas'
  END as status_tags
FROM restaurantes 
WHERE nome IN ('14bis', 'Five Points')
ORDER BY nome;

-- Testar filtro da categoria "Para Beber"
SELECT 
  nome, 
  tipo, 
  tags,
  'Aparecerá em Para Beber' as categoria
FROM restaurantes 
WHERE 
  (
    tipo ILIKE ANY(ARRAY['%bar%', '%pub%', '%cervejaria%', '%choperia%', '%lounge%'])
    OR tags && ARRAY['bar', 'cerveja', 'beer', 'drinks', 'happy hour', 'chopp']
    OR nome ILIKE ANY(ARRAY['%bar%', '%beer%', '%pub%', '%cervejaria%'])
  )
  AND ativo = true
ORDER BY nome;