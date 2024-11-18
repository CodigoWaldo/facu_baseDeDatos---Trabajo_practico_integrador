---------- TP2 ----------
--*--*--*--*--*--*--*--*--

----- ESQUEMA VENTA/COMPRA -----
--------------------------------

CREATE OR REPLACE FUNCTION public.calcular_stock_disponible(id_p BIGINT, fecha_p DATE)
RETURNS NUMERIC AS $$
DECLARE 
    stock_compras NUMERIC := 0;
    stock_ventas NUMERIC := 0;
BEGIN
    -- Sumar todas las compras
    SELECT COALESCE(SUM(cantidad_compra), 0)
    INTO stock_compras
    FROM compra.factura_compra_detalle fcd
    JOIN compra.factura_compra fc ON fcd.id_factura = fc.id -- Unión entre detalle de compra y factura de compra
    WHERE fcd.id_producto = id_p -- Producto asociado al ID en el detalle de compra
      AND fc.fecha <= fecha_p;
    
    -- Sumar todas las ventas
    SELECT COALESCE(SUM(cantidad), 0)
    INTO stock_ventas
    FROM venta.factura_detalle fd
    JOIN venta.factura f ON fd.id_factura = f.id -- Unión entre detalle de venta y factura de venta
    WHERE fd.id_producto = id_p -- Producto asociado al ID en el detalle de venta
      AND f.fecha <= fecha_p;
    
    -- Calcular stock disponible
    RETURN stock_compras - stock_ventas;
END;
$$ LANGUAGE plpgsql;


SELECT *
FROM public.calcular_stock_disponible(85, '2022-12-31') AS stock;
