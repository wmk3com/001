#1
SELECT 
	SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos;

#2
SELECT 
	YEAR(fecha_pedido) AS anio, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos
GROUP BY anio;

#3
SELECT 
	f.SKU_producto, 
    p.nombre_producto AS producto, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
GROUP BY producto
ORDER BY ventas_totales DESC;

#4
SELECT 
	p.nombre_producto AS producto, 
    COUNT(p.SKU_producto) AS cantidad, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
GROUP BY producto
ORDER BY ventas_totales DESC;

#5
SELECT 
	DISTINCT pr.nombre_producto AS producto, 
    costo_pedido AS costo
FROM proyecto_001.fac_pedidos AS pe
LEFT JOIN proyecto_001.dim_productos pr ON pr.SKU_producto = pe.SKU_producto
ORDER BY producto ASC;

#6  | campañas en google | ver fechas ventas en 2021 | descuentos en 2021 | moda
SELECT 
	YEAR(fecha_pedido) AS anio,
    p.SKU_producto AS codigo, 
    p.nombre_producto AS producto, 
    COUNT(p.SKU_producto) AS cantidad, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos f
INNER JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
GROUP BY anio, codigo
ORDER BY anio ASC;

#7
SELECT 
	MONTH(fecha_pedido) AS mes, 
	COUNT(p.SKU_producto) AS cantidad, 
	SUM(importe_total_pedido*cantidad_pedido) AS ventas
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
WHERE YEAR(fecha_pedido) = 2021
GROUP BY mes
ORDER BY ventas DESC;

#8
SELECT 
	CONCAT(c.nombre_cliente,' ',c.apellido_cliente) AS cliente, 
	SUM(importe_total_pedido) AS ventas
	#FORMAT(SUM(importe_total_pedido),'##,###.00') AS ventas
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = f.id_cliente
GROUP BY cliente
ORDER BY ventas DESC
LIMIT 3;

#9
SELECT 
	CONCAT(c.nombre_cliente,' ',c.apellido_cliente) AS cliente, 
    SUM(cantidad_pedido) AS cantidad
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = f.id_cliente
GROUP BY cliente
ORDER BY cantidad DESC
LIMIT 3;

#10
SELECT 
	tipo_pago_pedido, 
	COUNT(tipo_pago_pedido) AS tipo_pago
FROM proyecto_001.fac_pedidos
GROUP BY tipo_pago_pedido
ORDER BY tipo_pago DESC;

#11
SELECT 
	SUM(importe_de_descuento_pedido) AS total_x_cupones, 
    SUM(importe_total_pedido) AS ventas_netas
FROM proyecto_001.fac_pedidos;

#12 CTE
WITH cupones AS(
	SELECT 
		id_pedido, 
        codigo_cupon_pedido,
	CASE WHEN codigo_cupon_pedido='' THEN 0 ELSE 1 END AS cupones
	FROM proyecto_001.fac_pedidos)

SELECT 
	SUM(cupones) AS total_cupones, 
    COUNT(DISTINCT p.id_pedido) AS pedidos,
	SUM(cupones)/COUNT(DISTINCT p.id_pedido) AS porcentaje
FROM proyecto_001.fac_pedidos p 
LEFT JOIN cupones c ON c.id_pedido = p.id_pedido;

#13
WITH cupones AS(
	SELECT 
		id_pedido, 
        codigo_cupon_pedido,
	CASE WHEN codigo_cupon_pedido='' THEN 0 ELSE 1 END AS cupones
	FROM proyecto_001.fac_pedidos)

SELECT 
	YEAR(fecha_pedido) AS anio, 
    SUM(cupones) AS total_cupones, 
    COUNT(distinct p.id_pedido) AS pedidos,
	SUM(cupones)/COUNT(distinct p.id_pedido) AS porcentaje
FROM proyecto_001.fac_pedidos p 
LEFT JOIN cupones c ON c.id_pedido = p.id_pedido
GROUP BY anio;

#14
SELECT 
	ABS(SUM(comision_pago)) AS comision  
FROM proyecto_001.fac_pagos_stripe;

#15
SELECT 
	DISTINCT comision_pago AS comision, 
    importe_pago AS total, 
    FORMAT((comision_pago*100/importe_pago),2) AS porcentaje  
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
WHERE p.tipo_pago_pedido = 'Stripe';

#16
SELECT 
	FORMAT(AVG(comision_pago*100/importe_pago),1) AS porcentaje  
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
WHERE p.tipo_pago_pedido = 'Stripe';

#17
SELECT 
	YEAR(fecha_pedido) AS anio, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales, 
    (SUM(importe_total_pedido*cantidad_pedido)-SUM(s.comision_pago)) AS ventas_sin_comisiones, 
    ABS(SUM(s.comision_pago)) AS total_comisiones
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
GROUP BY anio;

# ---------------------------------------------------------
SELECT
YEAR(fecha_pedido) AS YEAR,
SUM(importe_total_pedido) AS total_ventas ,
IFNULL(SUM(comision_pago),0) AS comisiones,
SUM(importe_total_pedido) + IFNULL(SUM(comision_pago),0) AS ventas_netas
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido=p.id_pedido
GROUP BY year(fecha_pedido);
# ---------------------------------------------------------

#18
SELECT 
	DISTINCT nombre_producto,
	SUM(importe_total_pedido) OVER (PARTITION BY nombre_producto) AS ventas,
	SUM(importe_total_pedido) OVER (PARTITION BY nombre_producto) / SUM(importe_total_pedido) OVER() * 100 AS ventas_porcentaje
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.dim_productos pr ON pr.SKU_producto = p.SKU_producto

UNION ALL

SELECT 
	'Total',
	SUM(importe_total_pedido) AS ventas,
	100 AS ventas_porcentaje
FROM proyecto_001.fac_pedidos p;