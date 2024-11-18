---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA VENTA-----
-------------------------

-----Consulta de facturas con sus detalles

CREATE OR REPLACE FUNCTION public.generar_reporte_facturas(fecha_inicio DATE, fecha_fin DATE)
RETURNS TABLE(
    id BIGINT,
    fecha DATE,
    producto VARCHAR(100),
    cliente INT,
    empleado INT,
    promocion VARCHAR(100),
    forma_pago VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id AS id,
        f.fecha AS fecha,
        p.descripcion AS producto, 
        c.codigo AS id_cliente, 
        e.codigo AS id_empleado,
        pr.descripcion AS promocion,
        fp.descripcion AS forma_pago
    FROM venta.factura f
    JOIN venta.factura_detalle df ON f.id = df.id_factura -- Unión entre factura y detalle_factura
    JOIN producto.producto p ON p.id = df.id_producto -- Unión entre detalle_factura y producto
    JOIN persona.cliente c ON c.id = f.id_cliente -- Unión entre factura y cliente
    JOIN persona.empleado e ON e.id = f.id_empleado -- Unión entre factura y empleado
    LEFT OUTER JOIN venta.promocion pr ON pr.id = f.id_promocion -- Unión entre factura y promoción
    LEFT OUTER JOIN venta.forma_pago fp ON fp.id = f.id_forma_pago -- Unión entre factura y forma_pago
    WHERE f.fecha BETWEEN fecha_inicio AND fecha_fin
    ORDER BY f.fecha;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM public.generar_reporte_facturas('2021-01-01', '2021-12-31');

-----Volumen de ventas por año-mes

CREATE OR REPLACE FUNCTION public.total_ventas_anio_mes(anio_mes_inicio DATE, anio_mes_fin DATE)
RETURNS TABLE(
    anio INTEGER,
    mes INTEGER,
    total_venta NUMERIC(38,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXTRACT(YEAR FROM f.fecha)::INTEGER AS anio, 
        EXTRACT(MONTH FROM f.fecha)::INTEGER AS mes,
        SUM(f.total)::NUMERIC(38,2) AS total_venta 
    FROM venta.factura f
    WHERE f.fecha BETWEEN anio_mes_inicio AND anio_mes_fin
    GROUP BY anio, mes
    ORDER BY anio, mes;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM total_ventas_anio_mes('2021-01-01', '2021-12-31');


-----Ranking de productos más vendidos por año

CREATE OR REPLACE FUNCTION public.productos_mas_vendidos(anio INTEGER)
RETURNS TABLE(
    id_p BIGINT,
    producto VARCHAR(100),
    cantidad INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id AS id_p,
        p.descripcion AS producto,
        SUM(fd.cantidad)::INTEGER AS cantidad
    FROM venta.factura f 
    JOIN venta.factura_detalle fd ON f.id = fd.id_factura -- Unión entre factura y factura_detalle
    JOIN producto.producto p ON p.id = fd.id_producto -- Unión entre factura_detalle y producto
    WHERE EXTRACT(YEAR FROM f.fecha) = anio
    GROUP BY id_p, producto
    ORDER BY cantidad DESC;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM productos_mas_vendidos(2022);


-----Ranking de clientes con más volúmen comprado por año

CREATE OR REPLACE FUNCTION public.clientes_mas_volumen_comprado(anio INTEGER)
RETURNS TABLE(
    id_c BIGINT,
    total_facturado NUMERIC(38,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS id_c,
        SUM(f.total) AS total_facturado
    FROM venta.factura f
    JOIN persona.cliente c ON c.id = f.id_cliente -- Unión entre factura y cliente
    JOIN persona.persona p ON c.id_persona = p.id -- Unión entre cliente y persona
    WHERE EXTRACT(YEAR FROM f.fecha) = anio
    GROUP BY id_c
    ORDER BY total_facturado DESC;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM clientes_mas_volumen_comprado(2022);


-----Distribución de ventas por geografía 

SELECT 
    pr.descripcion AS provincia,
    l.descripcion AS localidad,
    COUNT(f.id) AS cantidad_ventas
FROM venta.factura f 
JOIN persona.cliente c ON f.id_cliente = c.id -- Unión entre factura y cliente
JOIN persona.persona p ON c.id_persona = p.id -- Unión entre cliente y persona
JOIN persona.localidad l ON p.id_localidad = l.id -- Unión entre persona y localidad
JOIN persona.provincia pr ON l.id_provincia = pr.id -- Unión entre localidad y provincia
GROUP BY provincia, localidad
ORDER BY provincia, localidad, cantidad_ventas;

