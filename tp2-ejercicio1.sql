---------- TP2 ----------
--*--*--*--*--*--*--*--*--

SET search_path TO "producto";
--

-- La siguiente función importa productos desde un archivo csv.
-- Los archivos csv guardan las filas con sus elementos separados por coma, por lo que cada producto estará en una fila distinta.
-- | Marca | Código de producto | Descripcion | Precio unitario | Costo unitario | 

CREATE OR REPLACE FUNCTION importar_productos_desde_csv(ruta_csv TEXT)
RETURNS TABLE(total_registros_procesados INT, productos_nuevos INT, marcas_nuevas INT) AS $$
DECLARE
    linea TEXT;
    marca_descripcion_importado TEXT;
    codigo_producto_importado INT;
    descripcion_producto_importado TEXT;
    precio_unitario_importado NUMERIC(38, 2);
    costo_unitario_importado NUMERIC(38, 2);
    nueva_marca_id BIGINT;
    producto_id BIGINT;
    productos_insertados INT := 0;
    marcas_insertadas INT := 0;
    registros_totales INT := 0;
BEGIN		
    -- Se crea un bucle para cada fila del archivo csv.
    FOR linea IN
        SELECT UNNEST(STRING_TO_ARRAY(pg_read_file(ruta_csv, 0, 1000000), E'\n')) AS linea
    LOOP
        -- Se separan todos los datos de cada línea por comas
        SELECT SPLIT_PART(linea, ',', 1) INTO marca_descripcion_importado;
        SELECT SPLIT_PART(linea, ',', 2)::INT INTO codigo_producto_importado;
        SELECT SPLIT_PART(linea, ',', 3) INTO descripcion_producto_importado;
        SELECT SPLIT_PART(linea, ',', 4)::NUMERIC INTO precio_unitario_importado;
        SELECT SPLIT_PART(linea, ',', 5)::NUMERIC INTO costo_unitario_importado;

        registros_totales := registros_totales + 1; -- Incrementar el contador de registros procesados.

        -- Se verifica si la marca ya existe
        SELECT id INTO nueva_marca_id FROM producto.marca WHERE descripcion = marca_descripcion_importado;
        IF NOT FOUND THEN -- Si no existe, se inserta la nueva marca y se obtiene su ID.
            INSERT INTO producto.marca(descripcion) VALUES (marca_descripcion_importado) RETURNING id INTO nueva_marca_id;
            marcas_insertadas := marcas_insertadas + 1; -- Aumenta en 1 la cantidad de marcas nuevas.
        END IF;

        -- Se verifica si el producto ya existe
        SELECT id INTO producto_id FROM producto.producto WHERE codigo = codigo_producto_importado;
        IF NOT FOUND THEN  -- Si no existe, se inserta el nuevo producto asociado a la marca. 
            INSERT INTO producto.producto(codigo, descripcion, precio_unitario, costo_unitario, id_marca)
            VALUES (codigo_producto_importado, descripcion_producto_importado, precio_unitario_importado, costo_unitario_importado, nueva_marca_id)
            RETURNING id INTO producto_id;
            productos_insertados := productos_insertados + 1; -- Aumenta en 1 la cantidad productos nuevos.
        END IF;
    END LOOP;
   
    RETURN QUERY SELECT registros_totales, productos_insertados, marcas_insertadas;  -- Se retornan los resultados.
END;
$$ LANGUAGE plpgsql;

-- Comando para ejecutar la función.
SELECT * FROM importar_productos_desde_csv('C:\productos-B.csv'); -- Especificar la ruta del archivo.

-- NOTAS --

-- Se tuvo que modificar el archivo csv debido a que contenia columnas adicionales que no correspondian a la base de datos.
-- (Otra solución era ignorar dichos datos pero era más facil eliminar las columnas.)
-- También contenia valores enteros almacenados entre comillas lo que causaba error de importación.

-- Se tuvo que establecer el id de la tabla marca como autoincremental para satisfacer la integridad de not null.
CREATE SEQUENCE producto.marca_id_seq START 1;
ALTER TABLE producto.marca ALTER COLUMN id SET DEFAULT NEXTVAL('producto.marca_id_seq');
SELECT MAX(id) FROM producto.marca; -- Ver cual era el ultimo id guardado (68).
ALTER SEQUENCE producto.marca_id_seq RESTART WITH 69;

-- Mismo para la tabla producto.
CREATE SEQUENCE producto.producto_id_seq START 1;
ALTER TABLE producto.producto ALTER COLUMN id SET DEFAULT NEXTVAL('producto.producto_id_seq');
SELECT MAX(id) FROM producto.producto; -- Ver cual era el ultimo id guardado (250).
ALTER SEQUENCE producto.marca_id_seq RESTART WITH 251;

-- Se tuvo que eliminar la característica "not null" de diferentes columnas debido a que el csv no contenia dicha información.
-- (Otra opción era establecer un valor por defecto para mantener la integridad pero no se consensuó uno.)
ALTER TABLE producto.marca ALTER COLUMN version DROP NOT NULL;
ALTER TABLE producto.marca ALTER COLUMN codigo DROP NOT NULL;
ALTER TABLE producto.producto ALTER COLUMN version DROP NOT NULL;
