# 1
SELECT 
	CONCAT(c.nombre_cliente,' ',c.apellido_cliente) AS nombre,
	SUM(importe_total_pedido*cantidad_pedido) AS ventas
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = p.id_cliente
WHERE YEAR(fecha_pedido) = 2021
GROUP BY nombre
ORDER BY ventas DESC 
LIMIT 5;

# 2
SELECT 
	YEAR(fecha_creacion_cliente) AS año,
	COUNT(id_cliente) AS cantidad_clientes 
FROM proyecto_001.dim_clientes
GROUP BY año
ORDER BY año DESC;

# 3
SELECT 
	pais_cliente,
	SUM(cantidad_pedido) AS pedidos
FROM proyecto_001.fac_pedidos ped
LEFT JOIN proyecto_001.dim_clientes clt ON ped.id_cliente = clt.id_cliente
GROUP BY pais_cliente
ORDER BY pedidos DESC
LIMIT 3;

# 4 Existen 116 clientes que tienen 2 pedidos  //  MODA
WITH cantidad_pedidos AS (
	SELECT 
		id_cliente,
		SUM(cantidad_pedido) AS pedidos
	FROM proyecto_001.fac_pedidos ped
	GROUP BY id_cliente
)

SELECT
	pedidos,
    COUNT(pedidos) AS repeticiones
FROM cantidad_pedidos
GROUP BY pedidos
ORDER BY repeticiones DESC
LIMIT 1;

-- Mas legible la CTE y mejor rendimiento

# 5
SELECT 
	costo_pedido,
	SUM(cantidad_pedido) AS pedidos
FROM proyecto_001.fac_pedidos ped
GROUP BY costo_pedido
ORDER BY pedidos DESC;

# 6
WITH cupones AS (
	SELECT 
		id_pedido,
		codigo_cupon_pedido,
	CASE WHEN codigo_cupon_pedido='' THEN 0 ELSE 1 END AS cupones
	FROM proyecto_001.fac_pedidos)

SELECT 
	CONCAT(nombre_cliente," ",apellido_cliente) AS nombre_completo_cliente ,
	SUM(importe_de_descuento_pedido) AS importe,
	SUM(cupones) AS cantidad
FROM cursosdata.fac_pedidos p
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = p.id_cliente
LEFT JOIN cupones cu ON cu.id_pedido = p.id_pedido
GROUP BY nombre_completo_cliente
ORDER BY importe DESC;

# 7 (no era necesario con OVER PARTITION)
SELECT 
	DISTINCT CONCAT(nombre_cliente," ",apellido_cliente) AS nombre_completo_cliente ,
	MIN(fecha_pedido) OVER (PARTITION BY p.id_cliente) AS primer_fecha_compra,
	MAX(fecha_pedido) OVER (PARTITION BY p.id_cliente) AS ultima_fecha_compra,
	DATEDIFF(DATE(NOW()),MAX(fecha_pedido) OVER (PARTITION BY p.id_cliente)) AS dias_desde
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = p.id_cliente
ORDER BY primer_fecha_compra ASC;


# ------------ 1
WITH segmento_clientes_ventas AS(
	SELECT 
		CONCAT(nombre_cliente," ",apellido_cliente) AS nombre_completo,
		CASE WHEN SUM(importe_total_pedido)< 500 THEN '0 A 500'
		WHEN (SUM(importe_total_pedido)> 500 AND SUM(importe_total_pedido)< 1000) THEN '500 A 1000'
		WHEN (SUM(importe_total_pedido)> 1000 AND SUM(importe_total_pedido)< 2000) THEN '1000 A 2000'
		WHEN (SUM(importe_total_pedido)> 2000 AND SUM(importe_total_pedido)< 5000) THEN '2000 A 5000'
		WHEN (SUM(importe_total_pedido)> 5000 AND SUM(importe_total_pedido)< 10000) THEN '5000 A 10000'
		WHEN (SUM(importe_total_pedido)> 10000) THEN '+10000'
		END  AS ventas_acumuladas_cliente
	FROM proyecto_001.fac_pedidos p
	LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = p.id_cliente
	GROUP BY nombre_completo
	ORDER BY ventas_acumuladas_cliente  DESC)

SELECT
	ventas_acumuladas_cliente,
	COUNT(nombre_completo) AS cantidad
FROM segmento_clientes_ventas
GROUP BY ventas_acumuladas_cliente
ORDER BY ventas_acumuladas_cliente;

# ------------ 2
WITH segmento_clientes_ventas AS(
	SELECT 
		CONCAT(nombre_cliente," ",apellido_cliente) AS nombre_completo,
		CASE WHEN COUNT(id_pedido)<= 3 THEN '0 A 3'
		WHEN COUNT(id_pedido)> 3 AND COUNT(id_pedido)<= 6 THEN '4 A 6'
		WHEN ((COUNT(id_pedido))> 6 AND (COUNT(id_pedido))<= 10) THEN '7 A 10'
		WHEN (COUNT(id_pedido))> 10 AND (COUNT(id_pedido))<= 15 THEN '11 A 15'
		WHEN (COUNT(id_pedido))> 15 THEN '+15'
		END  AS cantidad_ventas_acumuladas
	FROM proyecto_001.fac_pedidos p
	LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = p.id_cliente
	GROUP BY nombre_completo
	ORDER BY cantidad_ventas_acumuladas  DESC)

SELECT
	cantidad_ventas_acumuladas,
	COUNT(nombre_completo) AS cantidad
FROM segmento_clientes_ventas
GROUP BY cantidad_ventas_acumuladas
ORDER BY cantidad_ventas_acumuladas;

# -----------------------  ANALISIS DE MARKETING

SELECT 
	id_campaign,
	ROUND(SUM(costo)/SUM(clicks),2) AS cpc
from proyecto_001.campaign_facebook_ads_detalle
GROUP BY id_campaign;

# 2
SELECT 
	id_campaign,
	ROUND(SUM(costo)/SUM(clicks),2) AS cpc
FROM proyecto_001.campaign_facebook_ads_detalle
GROUP BY id_campaign
ORDER BY cpc AS
LIMIT 5;

# 3
SELECT 
	campaign_name,
	MONTH(fecha_google_analytics) AS mes,
	SUM(nuevos_usuarios) AS total_nuevos_usuarios,
	SUM(usuarios) AS total_usuarios
FROM proyecto_001.campaign_google_analytics ga
LEFT JOIN proyecto_001.campaign_facebook_ads fb ON fb.id_campaign = ga.id_campaign
GROUP BY campaign_name,MONTH(fecha_google_analytics)
ORDER BY campaign_name,MONTH(fecha_google_analytics);

# 4
SELECT 
	MONTH(fecha_google_analytics),
	AVG(sesiones)
FROM proyecto_001.campaign_google_analytics
WHERE MONTH(fecha_google_analytics) = 11
GROUP BY MONTH(fecha_google_analytics);

# 5
SELECT 
	id_campaign,
	ROUND(AVG(bounce_rate),2) AS media_bounce_rate
FROM proyecto_001.campaign_google_analytics
GROUP BY id_campaign;