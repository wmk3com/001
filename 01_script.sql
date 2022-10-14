CREATE SCHEMA proyecto_001;
USE proyecto_001;

CREATE TABLE dim_clientes(
	id_cliente INT,
    fecha_creacion_cliente DATE,
    nombre_cliente VARCHAR(100),
    apellido_cliente VARCHAR(100),
    email_cliente VARCHAR(100),
    telefono_cliente VARCHAR(100),
    region_cliente VARCHAR(100),
    pais_cliente VARCHAR(100),
    codigo_postal_cliente VARCHAR(100),
    direccion_cliente VARCHAR(255),
    PRIMARY KEY (id_cliente)
);

CREATE TABLE dim_productos (
  id_producto int  NULL,
  SKU_producto int NOT NULL,
  nombre_producto text,
  publicado_producto int  NULL,
  inventario_producto text,
  precio_normal_producto int NOT NULL,
  categoria_producto text,
  PRIMARY KEY (SKU_producto)
);

CREATE TABLE fac_pedidos (
  id_pedido int NOT NULL,
  SKU_producto int NULL,
  estado_pedido text,
  fecha_pedido date  NULL,
  id_cliente int  NULL,
  tipo_pago_pedido varchar(7) NOT NULL ,
  costo_pedido bigint  NULL,
  importe_de_descuento_pedido decimal(10,0)  NULL,
  importe_total_pedido int  NULL,
  cantidad_pedido int  NULL,
  codigo_cupon_pedido text,
  PRIMARY KEY (id_pedido),
  FOREIGN KEY (id_cliente) REFERENCES dim_clientes (id_cliente),
  FOREIGN KEY (SKU_producto) REFERENCES dim_productos (SKU_producto)
);

CREATE TABLE fac_pagos_stripe (
    fecha_pago DATETIME(6),
    id_pedido INT,
    importe_pago INT,
    moneda_pago TEXT,
    comision_pago DECIMAL(10 , 2 ),
    neto_pago DECIMAL(10 , 2 ),
    tipo_pago TEXT,
    FOREIGN KEY (id_pedido) REFERENCES fac_pedidos (id_pedido)
);

CREATE TABLE campaign_facebook_ads (
  id_campaign bigint NOT NULL,
  source_campaign_id bigint  NULL,
  campaign_created datetime(6)  NULL,
  campaign_status text,
  campaign_name text,
  campaign_objective text,
  campaign_stop_time datetime(6)  NULL,
  PRIMARY KEY (`id_campaign`)
);

CREATE TABLE ad_facebook_ads (
  fecha_creacion_ad date  NULL,
  id_campaign bigint  NULL,
  id_ad_set bigint  NULL,
  id_ad bigint NOT NULL,
  bid_type text,
  estado_ad text,
  nombre_ad text,
  PRIMARY KEY (`id_ad`)
);

CREATE TABLE campaign_facebook_ads_detalle (
  fecha_campaign date  NULL,
  id_ad bigint  NULL,
  id_campaign bigint  NULL,
  clicks int  NULL,
  cpc double  NULL,
  impresiones int  NULL,
  costo double  NULL,
  alcance int  NULL,
  FOREIGN KEY (id_ad) REFERENCES ad_facebook_ads (id_ad),
  FOREIGN KEY (id_campaign) REFERENCES campaign_facebook_ads (id_campaign)
);

CREATE TABLE campaign_google_analytics (
  fecha_google_analytics date,
  bounce_rate double,
  id_campaign bigint,
  nuevos_usuarios int,
  vista_paginas_por_sesion double,
  sesiones int,
  usuarios int,
	FOREIGN KEY (id_campaign) REFERENCES campaign_facebook_ads (id_campaign)
);
