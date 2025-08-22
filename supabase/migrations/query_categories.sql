-- Query para consultar todas as categorias existentes
SELECT 
    id,
    name,
    icon,
    color,
    is_active,
    sort_order,
    created_at
FROM categories 
WHERE is_active = true
ORDER BY sort_order ASC, name ASC;