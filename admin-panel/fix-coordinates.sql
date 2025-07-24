-- Script para corrigir a precisão dos campos latitude e longitude
-- Problema: NUMERIC(9,6) é muito restritivo para coordenadas geográficas
-- Solução: Mudar para FLOAT8 (double precision) que é ideal para coordenadas

-- Backup dos dados atuais (caso necessário)
-- SELECT id, latitude, longitude FROM restaurantes;

-- Alterar tipo para FLOAT8 (double precision)
ALTER TABLE restaurantes 
ALTER COLUMN latitude TYPE FLOAT8 USING latitude::FLOAT8;

ALTER TABLE restaurantes 
ALTER COLUMN longitude TYPE FLOAT8 USING longitude::FLOAT8;

-- Verificar a alteração
SELECT column_name, data_type, numeric_precision, numeric_scale 
FROM information_schema.columns 
WHERE table_name = 'restaurantes' 
AND column_name IN ('latitude', 'longitude'); 