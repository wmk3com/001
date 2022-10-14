SELECT * 
FROM raw_001.raw_productos_wocommerce;

INSERT INTO proyecto_001.dim_productos
	SELECT 
		id as id_producto,
		sku as sku_producto,
		nombre as nombre_producto,
		publicado as publicado_producto,
		inventario as inventario_producto,
		precio_normal as precio_normal_producto,
		categorias as categoria_producto
	FROM raw_001.raw_productos_wocommerce;

SELECT
	id as id_cliente,
	DATE(STR_TO_DATE(date_created,"%d/%m/%Y %H:%i:%s")) AS fecha_creacion_cliente,
	billing
FROM raw_001.raw_clientes_wocommerce
ORDER BY DATE(STR_TO_DATE(date_created,"%d/%m/%Y %H:%i:%s")) desc;

SELECT
	id as id_cliente,
	DATE(STR_TO_DATE(date_created,"%d/%m/%Y %H:%i:%s")) AS fecha_creacion_cliente,
	JSON_VALUE(billing,'$[0].first_name') AS nombre_cliente,
	JSON_VALUE(billing,'$[0].last_name') AS apellido_cliente,
	JSON_VALUE(billing,'$[0].email') AS email_cliente,
	JSON_VALUE(billing,'$[0].phone') AS telefono_cliente,
	JSON_VALUE(billing,'$[0].Region') AS region_cliente,
	JSON_VALUE(billing,'$[0].country') AS pais_cliente,
	JSON_VALUE(billing,'$[0].postcode') AS codigo_postal_cliente,
	JSON_VALUE(billing,'$[0].address_1') AS direccion_cliente
FROM raw_001.raw_clientes_wocommerce;

INSERT INTO proyecto_001.dim_clientes
	SELECT
		id AS id_cliente,
		DATE(STR_TO_DATE(date_created,"%d/%m/%Y %H:%i:%s")) AS fecha_creacion_cliente,
		JSON_VALUE(billing,'$[0].first_name') AS nombre_cliente,
		JSON_VALUE(billing,'$[0].last_name') AS apellido_cliente,
		JSON_VALUE(billing,'$[0].email') AS email_cliente,
		JSON_VALUE(billing,'$[0].phone') AS telefono_cliente,
		JSON_VALUE(billing,'$[0].Region') AS region_cliente,
		JSON_VALUE(billing,'$[0].country') AS pais_cliente,
		JSON_VALUE(billing,'$[0].postcode') AS codigo_postal_cliente,
		JSON_VALUE(billing,'$[0].address_1') AS direccion_cliente
	FROM raw_001.raw_clientes_wocommerce;

SELECT * 
FROM raw_001.raw_pedidos_wocommerce;

SELECT *
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;

SELECT *
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo
WHERE nombre_producto IS NULL;

SELECT 
	DISTINCT  titulo_metodo_de_pago
FROM raw_001.raw_pedidos_wocommerce w 
ORDER BY titulo_metodo_de_pago;
 
SELECT 
	numero_de_pedido,count(*)
FROM raw_001.raw_pedidos_wocommerce
GROUP BY numero_de_pedido
HAVING count(*)>1;

SELECT * FROM raw_001.raw_pedidos_wocommerce WHERE numero_de_pedido = 41624;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM raw_001.raw_pedidos_wocommerce WHERE numero_de_pedido = 41624 AND `id cliente` = 1324;
SET SQL_SAFE_UPDATES = 1;

SELECT
	numero_de_pedido,
	estado_de_pedido,
	fecha_de_pedido,
    #p.SKU_producto,
	CASE WHEN p.SKU_producto IS NULL THEN 3 ELSE p.SKU_producto END AS SKU_producto,
	`id cliente` AS id_cliente,
	titulo_metodo_de_pago,
	coste_articulo,
	importe_de_descuento_del_carrito,
	importe_total_pedido,
	cantidad,
	cupon_articulo
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;
    
SELECT
	numero_de_pedido,
	estado_de_pedido,
	fecha_de_pedido,
    CASE WHEN p.SKU_producto IS NULL THEN 3 ELSE p.SKU_producto END AS SKU_producto,
	`id cliente` AS id_cliente,
	CASE WHEN titulo_metodo_de_pago LIKE '%Stripe%' THEN 'Stripe' ELSE 'Tarjeta' END AS metodo_pago_pedido,
	coste_articulo,
	importe_de_descuento_del_carrito,
	importe_total_pedido,
	cantidad,
	cupon_articulo
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;
    
SELECT
	numero_de_pedido,
	estado_de_pedido,
	DATE(fecha_de_pedido) AS fecha_pedido,
    CASE WHEN p.SKU_producto IS NULL THEN 3 ELSE p.SKU_producto END AS SKU_producto,
	`id cliente` AS id_cliente,
	CASE WHEN titulo_metodo_de_pago LIKE '%Stripe%' THEN 'Stripe' ELSE 'Tarjeta' END AS metodo_pago_pedido,
	coste_articulo,
	importe_de_descuento_del_carrito,
	importe_total_pedido,
	cantidad,
	cupon_articulo
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;
    
SELECT
	numero_de_pedido,
	estado_de_pedido,
	DATE(fecha_de_pedido) AS fecha_pedido,
    CASE WHEN p.SKU_producto IS NULL THEN 3 ELSE p.SKU_producto END as SKU_producto,
	`id cliente` AS id_cliente,
	CASE WHEN titulo_metodo_de_pago LIKE '%Stripe%' THEN 'Stripe' ELSE 'Tarjeta' END AS metodo_pago_pedido,
	CEILING(coste_articulo) AS costo_pedido,
	importe_de_descuento_del_carrito,
	importe_total_pedido,
	cantidad,
	cupon_articulo
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;
    
INSERT INTO proyecto_001.fac_pedidos
SELECT
    numero_de_pedido,
    CASE WHEN p.SKU_producto IS NULL THEN 3 ELSE CAST(p.SKU_producto AS UNSIGNED) END AS SKU_producto,
	estado_de_pedido,
	DATE(fecha_de_pedido) AS fecha_pedido,
	w.`id cliente` AS id_cliente,
	CASE WHEN titulo_metodo_de_pago LIKE '%Stripe%' THEN 'Stripe' ELSE 'Tarjeta' END AS tipo_pago_pedido,
	CEILING(coste_articulo) AS costo_pedido,
	importe_de_descuento_del_carrito,
	importe_total_pedido,
	cantidad AS cantidad_pedido,
	cupon_articulo
FROM raw_001.raw_pedidos_wocommerce w
LEFT JOIN proyecto_001.dim_productos p ON p.nombre_producto = w.nombre_del_articulo;

SELECT * FROM raw_001.raw_pagos_stripe;

SELECT DISTINCT `status` FROM raw_001.raw_pagos_stripe;
SELECT DISTINCT `type` FROM raw_001.raw_pagos_stripe;

SELECT 
	created,
	RIGHT(`description`,5) AS id_pedido,
	amount,
	currency,
	fee,
	net,
	`status`,
	`type`
FROM raw_001.raw_pagos_stripe;

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

SELECT 
	TIMESTAMP(created) AS fecha_pago,
    RIGHT(`description`,5) AS id_pedido,
	amount,
	currency,
	fee,
	net,
	`status`,
	`type`
FROM raw_001.raw_pagos_stripe;

SELECT 
	TIMESTAMP(created) AS fecha_pago,
    RIGHT(`description`,5) AS id_pedido,
	amount,
	currency,
	REPLACE(fee,',','.') AS comision_pago,
	REPLACE(net,',','.') AS neto_pago,
	`status`,
	`type`
FROM raw_001.raw_pagos_stripe;

SELECT 
	TIMESTAMP(created) AS fecha_pago,
    RIGHT(`description`,5) AS id_pedido,
	amount,
	currency,
	CAST(REPLACE(fee,',','.') AS DECIMAL(10,2)) AS comision_pago,
	CAST(REPLACE(net,',','.') AS DECIMAL(10,2)) AS neto_pago,
	`status`,
	`type`
FROM raw_001.raw_pagos_stripe;

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
INSERT INTO proyecto_001.fac_pagos_stripe
	SELECT
		TIMESTAMP(created) AS fecha_pago,
		RIGHT(`description`,5) AS id_pedido,
		amount AS importe_pago,
		currency AS moneda_pago,
		CAST(REPLACE(fee,',','.') AS DECIMAL(10,2)) AS comision_pago,
		CAST(REPLACE(net,',','.') AS DECIMAL(10,2)) AS neto_pago,
		`type` AS tipo_pago
	FROM raw_001.raw_pagos_stripe;

SELECT * FROM raw_001.raw_dim_ad_facebook_ads;

INSERT INTO proyecto_001.ad_facebook_ads
	SELECT 
		created_time AS fecha_creacion_ad,
		campaign_id AS id_campaign,
		ad_set_id AS id_ad_set,
		ad_source_id AS id_ad,
		bid_type AS bid_type,
		`status` AS estado_ad,
		`name` AS nombre_ad
	FROM raw_001.raw_dim_ad_facebook_ads;

SELECT * FROM raw_001.raw_dim_campaigns_facebook;

SELECT
id AS id_campaign,
source_campaign_id,
TIMESTAMP(created_time) AS campaign_created,
`status` AS campaign_status,
`name` AS campaign_name,
objective AS campaign_objective,
TIMESTAMP(stop_time) AS campaign_stop_time
FROM raw_001.raw_dim_campaigns_facebook f;

INSERT INTO proyecto_001.campaign_facebook_ads
	SELECT
		id AS id_campaign,
		source_campaign_id,
		TIMESTAMP(created_time) AS campaign_created,
		`status` AS campaign_status,
		`name` AS campaign_name,
		objective AS campaign_objective,
		TIMESTAMP(stop_time) AS campaign_stop_time
	FROM raw_001.raw_dim_campaigns_facebook f;

SELECT * FROM raw_001.raw_dim_campaigns_facebook;

SELECT 
	DATE(DATE) AS fecha_campaign,
	ad_id AS id_ad,
	campaign_id AS id_campaign,
	clicks AS clicks,
	cpc AS cpc,
	impressions AS impresiones,
	spend AS costo,
	reach AS alcance
FROM raw_001.raw_facebook_campaigns;

INSERT INTO proyecto_001.campaign_facebook_ads_detalle
	SELECT 
		DATE(DATE) AS fecha_campaign,
		ad_id AS id_ad,
		campaign_id AS id_campaign,
		clicks AS clicks,
		cpc AS cpc,
		impressions AS impresiones,
		spend AS costo,
		reach AS alcance
	FROM raw_001.raw_facebook_campaigns;

SELECT * FROM raw_001.raw_google_analytics_campaigns;

SELECT 
DATE(DATE) AS fecha_google_analytics,
bounce_rate,
campaign AS id_campaign,
new_users AS nuevos_usuarios,
pageviews_per_session AS vista_paginas_por_sesion,
sessions AS sesiones,
users AS usuarios
FROM raw_001.raw_google_analytics_campaigns;

INSERT INTO proyecto_001.campaign_google_analytics
	SELECT 
        DATE(DATE) AS fecha_google_analytics,
        bounce_rate,
        campaign AS id_campaign,
        new_users AS nuevos_usuarios,
        pageviews_per_session AS vista_paginas_por_sesion,
        sessions AS sesiones,
        users AS usuarios
	FROM raw_001.raw_google_analytics_campaigns;
