-- Adicionar coluna sort_order à tabela categories

ALTER TABLE categories ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Atualizar valores existentes com sort_order baseado no nome
UPDATE categories SET sort_order = 
  CASE 
    WHEN name = 'Pizza' THEN 1
    WHEN name = 'Hambúrguer' THEN 2
    WHEN name = 'Japonesa' THEN 3
    WHEN name = 'Italiana' THEN 4
    WHEN name = 'Brasileira' THEN 5
    WHEN name = 'Mexicana' THEN 6
    WHEN name = 'Chinesa' THEN 7
    WHEN name = 'Árabe' THEN 8
    WHEN name = 'Vegetariana' THEN 9
    WHEN name = 'Sobremesas' THEN 10
    ELSE 99
  END
WHERE sort_order = 0;

-- Criar índice para melhor performance na ordenação
CREATE INDEX IF NOT EXISTS idx_categories_sort_order ON categories(sort_order);