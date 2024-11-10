---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA VENTA-----
-------------------------

-----Consulta de facturas con sus detalles

create or replace function public.generar_reporte_facturas(fecha_inicio date, fecha_fin date)

returns table(
	id bigint,
	fecha date,
	producto varchar(100),
	cliente varchar(100),
	empleado varchar(100),
	promocion varchar(100),
	forma_pago varchar(100)
) as $$

begin
	return query
	
	select 
		f.id as id,
		f.fecha as fecha,
		p.producto as producto,
		c.cliente as cliente,
		e.empleado as empleado,
		pr.promocion as promocion,
		fp.forma_pago as forma_pago
		
	from venta.factura f
	
	join venta.detalle_factura df on f.id = df.id_factura --unión entre factura y detalle_factura
	join producto.producto p on p.id = df.id_producto --unión entre detalle_factura y producto
	join persona.cliente c on c.id = f.id_cliente --unión entre factura y cliente
	join persona.empleado e on e.id = f.id_empleado --unión entre factura y empleado
	join venta.promocion pr on pr.id = f.id_promocion --unión entre factura y promocion
	join venta.forma_pago fp on fp.id = f.id_forma_pago --unión entre factura y forma_pago
	--hasta acá se unió a factura con todas las tablas del esquema venta
	
	where f.fecha between fecha_inicio and fecha_fin
	order by f.fecha;
end;
$$ language plpgsql;

select *
from public.generar_reporte_Facturas('2021-01-01', '2021-12-31');


-----Volumen de ventas por año-mes

create or replace function total_ventas_anio_mes(anio_mes_inicio date, anio_mes_fin date)

returns table(
	anio integer,
	mes integer,
	total_venta numeric(38,2)
) as $$

begin
	return query
	
	select 
		extract (year from f.fecha) as anio,
		extract (month from f.fecha) as mes,
		sum(f.total) as total_venta
		
	from venta.factura f
	where f.fecha between anio_mes_inicio and anio_mes_fin
	group by 
		extract (year from f.fecha),
		extract (month from f.fecha);
end
$$ language plpgsql;

select *
from total_ventas_anio_mes('2021-01-01', '2021-12-31');


-----Ranking de productos más vendidos por año

create or replace function productos_mas_vendidos(anio integer)
returns table(
	id bigint,
	producto varchar(100),
	cantidad integer
) as $$
begin
	return query
		select
			f.id as id,
			sum(fd.cantidad) as cantidad,
			p.descripcion as producto
		
		from factura f 
		join factura_detalle fd on f.id = fd.id_factura --unión entre factura y factura_detalle
		join producto p on p.id = fd.id_producto --unión entre factura_detalle y producto
		
		where extract(year from f.fecha) = anio
		group by producto
		order by cantidad desc;
end
$$ language plpgsql;

select *
from productos_mas_vendidos(2022);


-----Ranking de clientes con más volúmen comprado por año

create or replace function clientes_mas_volumen_comprado(anio integer)
returns table(
	id bigint,
	total_facturado numeric(38,2)
) as $$
begin
	return query
	select
		f.id as id_factura,
		c.id as id_cliente, --acá habria que modificar para unir con persona y poner nombre_apellido para pf o denominacion para pj
		sum(f.total) as total_facturado
	
	from factura f 
	join cliente c on c.id = f.id_cliente --unión entre factura y cliente
	--faltaria un join entre cliente y persona y según tipo entre persona y pf o pj
	where extract (year from f.fecha) = anio
	order by total_facturado desc;
end
$$ language plpgsql;

select *
from clientes_mas_volumen_comprado(2022);
