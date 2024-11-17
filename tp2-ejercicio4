---------- TP2 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA VENTA-----
-------------------------

CREATE OR REPLACE FUNCTION venta.actualizar_total_factura()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE venta.factura --actualizo venta 
    SET total = (
        SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
        FROM venta.factura_detalle --en relacion al detalle 
        WHERE id_factura = COALESCE(NEW.id_factura, OLD.id_factura)
    )
    WHERE id = COALESCE(NEW.id_factura, OLD.id_factura); --solo modifico la factura afectada 
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_total_factura
AFTER INSERT OR UPDATE OR DELETE 
ON venta.factura_detalle 
FOR EACH ROW 
EXECUTE FUNCTION venta.actualizar_total_factura();

--Insertar detalle
INSERT INTO venta.factura_detalle (id, version, id_factura, item, cantidad, precio_unitario, id_producto)
VALUES (49, 0, 27, 2, 10, 150, 100);

--Actualizar detalle
UPDATE venta.factura_detalle 
SET cantidad = 5
WHERE id = 49;

--Eliminar detalle
DELETE FROM venta.factura_detalle 
WHERE id = 49;
