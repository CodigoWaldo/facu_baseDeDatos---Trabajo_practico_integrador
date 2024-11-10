---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA VENTA-----
-------------------------

create or replace view venta.productos_vendidos_anio_mes as
select 
	p.descripcion as producto,
	sum(fd.cantidad) as cantidad,
	extract(year from f.fecha) as anio,
	extract(month from f.fecha) as mes
	
	
from venta.factura f
join venta.factura_detalle fd on f.id = fd.id_factura --unión entre factura y factura_detalle
join producto.producto p on p.id = fd.id_producto --unión entre factura_detalle y producto

group by producto, anio, mes
order by anio, mes, cantidad desc;

select *
from venta.productos_vendidos_anio_mes;
