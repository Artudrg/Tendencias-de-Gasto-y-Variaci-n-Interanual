;WITH datos_limpios AS (
    SELECT
        category AS categoria,
        YEAR(CAST(transaction_date AS DATE)) AS anio,
        TRY_CAST(
            REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)
        ) AS monto
    FROM transactions..transactions
),
gasto_anual AS (
    SELECT
        categoria,
        anio,
        SUM(monto) AS gasto_total
    FROM datos_limpios
    GROUP BY categoria, anio
),
variacion_anual AS (
    SELECT
        categoria,
        anio,
        gasto_total,
        LAG(gasto_total) OVER (PARTITION BY categoria ORDER BY anio) AS gasto_anio_anterior,
        ((gasto_total - LAG(gasto_total) OVER (PARTITION BY categoria ORDER BY anio))
        / NULLIF(LAG(gasto_total) OVER (PARTITION BY categoria ORDER BY anio), 0)) * 100 AS porcentaje_cambio_yoy
    FROM gasto_anual
)
SELECT
    categoria,
    anio,
    gasto_total,
    gasto_anio_anterior,
    porcentaje_cambio_yoy
FROM variacion_anual
ORDER BY categoria, anio;