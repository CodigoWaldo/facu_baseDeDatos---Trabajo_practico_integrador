CREATE OR REPLACE FUNCTION cargar_facturas_desde_csv(ruta_csv TEXT)  
RETURNS VOID AS $$
DECLARE
    factura_id INTEGER; 
    registro RECORD;   
    producto_id INTEGER; 
    item_numero INTEGER; 
    proveedor_id INTEGER; 
    subtotal NUMERIC(38,2);
BEGIN
    -- crear tabla temporal para mas comodidad
    CREATE TEMP TABLE tmp_factura (
        factura_numero INTEGER,
        etc VARCHAR(10),
        fecha DATE,
        cuit_proveedor VARCHAR(11),
        codigo_producto INTEGER,
        cantidad NUMERIC(38,2),
        precio_unitario NUMERIC(38,2)
    ) ON COMMIT DROP;

    -- cargar datos en tabla temporal
    BEGIN
        EXECUTE FORMAT('COPY tmp_factura FROM %L WITH (FORMAT CSV, DELIMITER '','', HEADER)', ruta_csv);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error al cargar el archivo CSV: %', SQLERRM;
            RETURN;
    END;

    -- trabajar dato por dato de la tabla temporal
    FOR registro IN
        SELECT * FROM tmp_factura
    LOOP
        -- ver si la factura ya existe
        SELECT id INTO factura_id
        FROM venta.factura
        WHERE numero = registro.factura_numero;

        -- si la factura no existe, crearla
        IF factura_id IS NULL THEN
            INSERT INTO venta.factura (numero, fecha , version, descuento, total)
            VALUES (registro.factura_numero, registro.fecha, 1, 1, 0)
            RETURNING id INTO factura_id;
        END IF;

        -- ver si el proveedor existe
        SELECT id INTO proveedor_id
        FROM persona.proveedor
        WHERE id_persona_juridica IN (
            SELECT id FROM persona.persona_juridica WHERE cuit = registro.cuit_proveedor
        );

        -- si el proveedor no existe no hacer nada
        IF proveedor_id IS NULL THEN
            RAISE NOTICE 'Proveedor con CUIT % no encontrado. No se carga la factura.', registro.cuit_proveedor;
            RETURN;
        END IF;

        -- ver si el producto existe
        SELECT id INTO producto_id
        FROM producto.producto
        WHERE codigo = registro.codigo_producto;
        
        -- si el producto no existe no hacer nada
        IF producto_id IS NULL THEN
            RAISE NOTICE 'Producto con código % no encontrado. No se carga la factura.', registro.codigo_producto;
            RETURN;
        ELSE
            -- si el producto ya existe, actualizar el proveedor
            UPDATE producto.producto
            SET id_proveedor = proveedor_id
            WHERE id = producto_id;
        END IF;

        -- siguiente item disponible para esta factura
        SELECT COALESCE(MAX(item), 0) + 1 INTO item_numero
        FROM venta.factura_detalle
        WHERE id_factura = factura_id;


        subtotal := registro.precio_unitario * registro.cantidad;


        INSERT INTO venta.factura_detalle (id, id_factura, id_producto, cantidad, precio_unitario, version, item)
        VALUES (nextval('venta.factura_detalle_id_seq'), factura_id, producto_id, registro.cantidad, registro.precio_unitario, 0, item_numero);

        -- Actualizar el total de la factura sumando el subtotal
        UPDATE venta.factura
        SET total = (SELECT COALESCE(SUM(cantidad * precio_unitario), 0) 
                     FROM venta.factura_detalle 
                     WHERE id_factura = factura_id)
        WHERE id = factura_id;

    END LOOP;

END;
$$ LANGUAGE plpgsql;






SELECT cargar_facturas_desde_csv('C:/Users/Gamemax/Desktop/facturas-A.csv');





/* comandos auxiliares */
--SELECT setval('factura_id_seq', (SELECT MAX(id) FROM venta.factura), false); -- para que la secuencia empiece con el id mas alto
ALTER TABLE venta.factura
ALTER COLUMN id_cliente DROP NOT NULL; /* no indica el cliente */
ALTER TABLE venta.factura
ALTER COLUMN id_empleado DROP NOT NULL;/* no indica el empleado */

SELECT create_sequence('factura','id', 'venta');
SELECT create_sequence('factura_detalle','id', 'venta');




CREATE OR REPLACE FUNCTION create_sequence(
    table_name TEXT, 
    column_name TEXT,
    schema_name TEXT DEFAULT 'public'  -- por defecto 'public'
) RETURNS VOID AS $$
DECLARE
    seq_name TEXT;
    sql_command TEXT;
BEGIN
    -- Generar el nombre de la secuencia con el esquema
    seq_name := schema_name || '.' || table_name || '_' || column_name || '_seq';

    -- Crear la secuencia en el esquema especificado
    EXECUTE 'CREATE SEQUENCE ' || seq_name;

    -- Establecer la secuencia como predeterminada para la columna
    sql_command := 'ALTER TABLE ' || schema_name || '.' || table_name || 
                   ' ALTER COLUMN ' || column_name || 
                   ' SET DEFAULT nextval(''' || seq_name || '''::regclass)';
    EXECUTE sql_command;

    -- Alinear la secuencia con el valor máximo actual de la columna
    sql_command := 'SELECT setval(''' || seq_name || ''', COALESCE((SELECT MAX(' || column_name || ') FROM ' || schema_name || '.' || table_name || '), 0) + 1)';
    EXECUTE sql_command;
END;
$$ LANGUAGE plpgsql;

