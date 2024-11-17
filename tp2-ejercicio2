
---------- TP2 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA COMPRA-----
-------------------------

CREATE SCHEMA compra;

CREATE TABLE compra.factura_compra (
    id BIGINT NOT NULL,
    version INTEGER NOT NULL,
    id_proveedor BIGINT NOT NULL,
    numero INTEGER NOT NULL,
    fecha DATE NOT NULL,
    descuento NUMERIC(38,2),
    total NUMERIC(38,2),

    CONSTRAINT pk_factura_compra PRIMARY KEY (id),
    CONSTRAINT fk_factura_compra_proveedor FOREIGN KEY (id_proveedor) REFERENCES persona.proveedor(id),
    CONSTRAINT uk_factura_compra UNIQUE (id_proveedor, numero)
);

CREATE TABLE compra.factura_compra_detalle (
    id BIGINT NOT NULL,
    version INTEGER NOT NULL,
    id_factura BIGINT NOT NULL,
    item_fact_compra INTEGER NOT NULL,
    cantidad_compra NUMERIC(38,2),
    precio_compra NUMERIC(38,2),
    id_producto BIGINT NOT NULL,

    CONSTRAINT pk_factura_compra_detalle PRIMARY KEY (id),
    CONSTRAINT fk_factura_compra_detalle_factura FOREIGN KEY (id_factura) REFERENCES compra.factura_compra(id),
    CONSTRAINT fk_factura_compra_detalle_producto FOREIGN KEY (id_producto) REFERENCES producto.producto(id),
    CONSTRAINT uk_factura_compra_detalle UNIQUE (id_factura, item_fact_compra)
);


