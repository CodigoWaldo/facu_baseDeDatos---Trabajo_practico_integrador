
---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA PUBLIC-----
-------------------------

CREATE OR REPLACE VIEW public.productos_vendidos_anio_mes AS
SELECT 
    p.descripcion AS producto,
    SUM(fd.cantidad) AS cantidad,
    EXTRACT(YEAR FROM f.fecha) AS anio,
    EXTRACT(MONTH FROM f.fecha) AS mes
FROM venta.factura f
JOIN venta.factura_detalle fd ON f.id = fd.id_factura -- Unión entre factura y factura_detalle
JOIN producto.producto p ON p.id = fd.id_producto -- Unión entre factura_detalle y producto
GROUP BY producto, anio, mes
ORDER BY anio, mes, cantidad DESC;

SELECT *
FROM public.productos_vendidos_anio_mes;
