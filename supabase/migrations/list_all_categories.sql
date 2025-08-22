-- Consultar todas as categorias existentes no banco de dados
-- com seus nomes, ícones, cores e status

SELECT 
    id,
    name,
    icon,
    color,
    is_active,
    sort_order,
    created_at,
    updated_at
FROM categories
ORDER BY sort_order ASC, name ASC;

-- Verificar quantas categorias ativas existem
SELECT 
    COUNT(*) as total_categories,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_categories,
    COUNT(CASE WHEN is_active = false THEN 1 END) as inactive_categories
FROM categories;

-- Listar apenas categorias ativas ordenadas por sort_order
SELECT 
    id,
    name,
    icon,
    color,
    sort_order
FROM categories
WHERE is_active = true
ORDER BY sort_order ASC, name ASC;