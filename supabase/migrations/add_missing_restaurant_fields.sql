-- Adicionar campos ausentes na tabela restaurants para compatibilidade com RestaurantModel

-- Adicionar review_count
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;

-- Adicionar min_order_value
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS min_order_value NUMERIC(10,2) DEFAULT 0.00;

-- Adicionar has_promotion
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS has_promotion BOOLEAN DEFAULT false;

-- Adicionar price_range
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS price_range VARCHAR(10) DEFAULT '$';

-- Adicionar distance (campo calculado, pode ser NULL)
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS distance NUMERIC(10,2);

-- Comentários para documentação
COMMENT ON COLUMN restaurants.review_count IS 'Número total de avaliações do restaurante';
COMMENT ON COLUMN restaurants.min_order_value IS 'Valor mínimo do pedido em reais';
COMMENT ON COLUMN restaurants.has_promotion IS 'Indica se o restaurante tem promoções ativas';
COMMENT ON COLUMN restaurants.price_range IS 'Faixa de preço: $ (barato), $$ (médio), $$$ (caro)';
COMMENT ON COLUMN restaurants.distance IS 'Distância calculada do usuário (em km)';

-- Atualizar alguns registros existentes com dados de exemplo
UPDATE restaurants 
SET 
  review_count = FLOOR(RANDOM() * 500 + 10),
  min_order_value = CASE 
    WHEN RANDOM() < 0.3 THEN 15.00
    WHEN RANDOM() < 0.6 THEN 25.00
    ELSE 35.00
  END,
  has_promotion = RANDOM() < 0.3,
  price_range = CASE 
    WHEN RANDOM() < 0.4 THEN '$'
    WHEN RANDOM() < 0.8 THEN '$$'
    ELSE '$$$'
  END
WHERE review_count = 0;