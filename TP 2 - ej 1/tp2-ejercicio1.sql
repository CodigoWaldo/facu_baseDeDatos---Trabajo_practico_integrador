--
SET search_path TO "producto";
--

-- La siguiente función importa productos desde un archivo csv.
-- Los archivos csv guardan las filas con sus elementos separados por coma, por lo que cada producto estará en una fila distinta.
-- | Marca | Código de producto | Descripcion | Precio unitario | Costo unitario | 


create or replace function importar_productos_desde_csv(ruta_csv TEXT)
returns table(total_registros_procesados INT, productos_nuevos INT, marcas_nuevas INT) as $$
declare
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
begin		
    -- Se crea un bucle para cada fila del archivo csv.
    for linea in
        select unnest(string_to_array(pg_read_file(ruta_csv, 0, 1000000), E'\n')) as linea
    loop
        -- Se separan todos los datos de cada línea por comas
        select split_part(linea, ',', 1) into marca_descripcion_importado;
        select split_part(linea, ',', 2)::INT into codigo_producto_importado;
        select split_part(linea, ',', 3) into descripcion_producto_importado;
        select split_part(linea, ',', 4)::NUMERIC into precio_unitario_importado;
        select split_part(linea, ',', 5)::NUMERIC into costo_unitario_importado;

        registros_totales := registros_totales + 1; -- Incrementar el contador de registros procesadoss.

        -- Se verifica si la marca ya existe
        select id into nueva_marca_id from producto.marca where descripcion = marca_descripcion_importado;
        if not found then -- Si no existe, se inserta la nueva marca y se obtiene su ID.
            insert into producto.marca(descripcion) values (marca_descripcion_importado) returning id into nueva_marca_id;
            marcas_insertadas := marcas_insertadas + 1; -- Aumenta en 1 la cantidad de marcas nuevas
        end if;

        -- Se verifica si el producto ya existe
        select id into producto_id from producto.producto where codigo = codigo_producto_importado;
        if not found then  -- Si no existe, se inserta el nuevo producto asociado a la marca. 
            insert into producto.producto(codigo, descripcion, precio_unitario, costo_unitario, id_marca)
            values (codigo_producto_importado, descripcion_producto_importado, precio_unitario_importado, costo_unitario_importado, nueva_marca_id)
            returning id into producto_id;
            productos_insertados := productos_insertados + 1; -- Aumenta en 1 la cantidad productos nuevos.
        end if;
    end loop;
   
   	return QUERY select registros_totales, productos_insertados, marcas_insertadas;  -- Se retornan los resultados.
end;
$$ language plpgsql;

-- Comando para ejecutar la función.
select * from importar_productos_desde_csv('C:\productos-B.csv'); -- Especificar la ruta del archivo.


-- NOTAS --

-- Se tuvo que modificar el archivo csv debido a que contenia columnas adicionales que no correspondian a la base de datos.
-- (Otra solución era ignorar dichos datos pero era más facil eliminar las columnas.)
-- También contenia valores enteros almacenados entre comillas lo que causaba error de importación.

-- Se tuvo que establecer el id de la tabla marca como autoincremental para satisfacer la integridad de not null.
create sequence producto.marca_id_seq start 1;
alter table producto.marca alter column id set default nextval('producto.marca_id_seq');
select MAX(id) from producto.marca; -- ver cual era el ultimo id guardado (68).
alter sequence producto.marca_id_seq restart with 69;

-- Mismo para la tabla procucto.
create sequence producto.producto_id_seq start 1;
alter table producto.producto alter column id set default nextval('producto.producto_id_seq');
select MAX(id) from producto.producto p ; -- ver cual era el ultimo id guardado (250).
alter sequence producto.marca_id_seq restart with 251;

-- Se tuvo que eliminar la característica "not null" de diferentes columnas debido a que el csv no contenia dicha información.
-- (Otra opción era establecer un valor por defecto para mantener la integridad pero no se consensuó uno.)
alter table producto.marca alter column version drop not null;
alter table producto.marca alter column codigo drop not null;
alter table producto.producto alter	column  version drop not null;


