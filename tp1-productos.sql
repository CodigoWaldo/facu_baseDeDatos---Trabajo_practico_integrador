---------- TP1 ----------
--*--*--*--*--*--*--*--*--

----- ESQUEMA PRODUCTO -----
----------------------------

----- Productos con información de marca, categoría y proveedor
SELECT 
    p.descripcion AS nombre_producto,
    m.descripcion AS nombre_marca,
    c.descripcion AS categoria
FROM producto p
JOIN marca m ON m.id = p.id_marca -- Unión entre producto y marca
JOIN subcategoria s ON s.id = p.id_subcategoria -- Unión entre producto y subcategoría
JOIN categoria c ON c.id = s.id_categoria -- Unión entre subcategoría y categoría
ORDER BY 
    nombre_marca, 
    nombre_producto, 
    categoria;


