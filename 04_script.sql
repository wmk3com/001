# ¿Cuál es el total de ventas de la empresa ?

SELECT 
	SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos;

# ¿Cuál es el total de las ventas por año?

SELECT 
	YEAR(fecha_pedido) AS anio, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos
GROUP BY anio;

# ¿Cuál es el total de las ventas por producto?

SELECT 
	f.SKU_producto, 
    p.nombre_producto AS producto, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
GROUP BY producto
ORDER BY ventas_totales DESC;

# ¿Cuál es el total de ventas por producto pero por cantidad?

SELECT 
	p.nombre_producto AS producto, 
    COUNT(p.SKU_producto) AS cantidad, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
GROUP BY producto
ORDER BY ventas_totales DESC;

# ¿A qué precio se ha vendido cada producto? 
# ¿Se podría sacar el valor único?

SELECT 
	DISTINCT pr.nombre_producto AS producto, 
    costo_pedido AS costo
FROM proyecto_001.fac_pedidos AS pe
LEFT JOIN proyecto_001.dim_productos pr ON pr.SKU_producto = pe.SKU_producto
ORDER BY producto ASC;

# ¿A qué podríamos atribuir ese crecimiento de ventas? 
# ¿Podriamos ver las ventas por producto y por año?

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

# ¿Cuáles son las ventas por meses del año 2021?

SELECT 
	MONTH(fecha_pedido) AS mes, 
	COUNT(p.SKU_producto) AS cantidad, 
	SUM(importe_total_pedido*cantidad_pedido) AS ventas
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_productos p ON p.SKU_producto = f.SKU_producto
WHERE YEAR(fecha_pedido) = 2021
GROUP BY mes
ORDER BY ventas DESC;

# ¿Cuáles son los top 3 clientes que compran en términos monetarios?
SELECT 
	CONCAT(c.nombre_cliente,' ',c.apellido_cliente) AS cliente, 
	SUM(importe_total_pedido) AS ventas
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = f.id_cliente
GROUP BY cliente
ORDER BY ventas DESC
LIMIT 3;

# ¿Cúales son los top 3 clientes que compran por cantidad?

SELECT 
	CONCAT(c.nombre_cliente,' ',c.apellido_cliente) AS cliente, 
    SUM(cantidad_pedido) AS cantidad
FROM proyecto_001.fac_pedidos f
LEFT JOIN proyecto_001.dim_clientes c ON c.id_cliente = f.id_cliente
GROUP BY cliente
ORDER BY cantidad DESC
LIMIT 3;

# ¿Cúal es el método de pago con el cual más pagan los clientes?

SELECT 
	tipo_pago_pedido, 
	COUNT(tipo_pago_pedido) AS tipo_pago
FROM proyecto_001.fac_pedidos
GROUP BY tipo_pago_pedido
ORDER BY tipo_pago DESC;

# ¿Cuanto es el importe total en términos monetarios utilizado en cupones?

SELECT 
	SUM(importe_de_descuento_pedido) AS total_x_cupones, 
    SUM(importe_total_pedido) AS ventas_netas
FROM proyecto_001.fac_pedidos;

# ¿Cúal es el total de cupones utilizados en las ventas en terminos cuantitativos?

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

# ¿Cúal es el total de cupones utilizados en las ventas en terminos cuantitativos? (desglosado por año)

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

# ¿Cúal es el total de comisiones pagadas a Stripe?

SELECT 
	ABS(SUM(comision_pago)) AS comision  
FROM proyecto_001.fac_pagos_stripe;

# ¿Cúal es el porcentaje de comisión de cada pedido realizado por Stripe?

SELECT 
	DISTINCT comision_pago AS comision, 
    importe_pago AS total, 
    FORMAT((comision_pago*100/importe_pago),2) AS porcentaje  
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
WHERE p.tipo_pago_pedido = 'Stripe';

# ¿Cúal es la media de porcentaje total?

SELECT 
	FORMAT(AVG(comision_pago*100/importe_pago),1) AS porcentaje  
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
WHERE p.tipo_pago_pedido = 'Stripe';

# Calcula el total de ventas, las ventas sin comisión de Stripe y las comisiones de Stripe por año.

SELECT 
	YEAR(fecha_pedido) AS anio, 
    SUM(importe_total_pedido*cantidad_pedido) AS ventas_totales, 
    (SUM(importe_total_pedido*cantidad_pedido)-SUM(s.comision_pago)) AS ventas_sin_comisiones, 
    ABS(SUM(s.comision_pago)) AS total_comisiones
FROM proyecto_001.fac_pedidos p
LEFT JOIN proyecto_001.fac_pagos_stripe s ON s.id_pedido = p.id_pedido
GROUP BY anio;

# ¿Como podríamos saber el porcentaje de ventas sobre el total de cada curso para ver si se cumple la ley de pareto?
# ¿Qué cursos habría que continuar promocionando y cuales dejar de hacerlo?

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