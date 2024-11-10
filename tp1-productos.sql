---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA PRODUCTO-----
-------------------------

----- Productos con información de marca, categoría y proveedor

select 
	p.descripcion as nombre_producto,
	m.descripcion as nombre_marca,
	c.descripcion as categoria
from producto p 
join marca m on m.id = p.id_marca --unión entre producto y marca
join subcategoria s on s.id = p.id_subcategoria --unión entre producto y subcategoria 
join categoria c on c.id = s.id_categoria --unión entre subcategoria y categoria
order by nombre_marca, nombre_producto, categoria;


