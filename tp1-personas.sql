---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA PERSONA-----
-------------------------

----- Sucursales con información de empleados

SELECT
    s.descripcion AS nombre_sucursal,
    l.descripcion AS nombre_localidad,
    p.descripcion AS nombre_provincia,
    pf.apellido AS apellido_empleado,
    pf.nombre AS nombre_empleado
FROM sucursal s
JOIN localidad l ON l.id = s.id_localidad -- Unión entre sucursal y localidad
JOIN provincia p ON p.id = l.id_provincia -- Unión entre localidad y provincia
JOIN empleado e ON s.id = e.id_sucursal -- Unión entre empleado y sucursal
JOIN persona_fisica pf ON pf.id = e.id_persona_fisica -- Unión entre empleado y persona física
ORDER BY 
    nombre_provincia, 
    nombre_localidad, 
    nombre_sucursal, 
    apellido_empleado, 
    nombre_empleado;


----- Clientes con información de datos personales

SELECT 
    p.tipo,
    CASE
        WHEN p.tipo = 'FISICA' THEN pf.apellido || ' ' || pf.nombre
        WHEN p.tipo = 'JURIDICA' THEN pj.denominacion
    END AS denominacion,
    CASE
        WHEN p.tipo = 'FISICA' THEN pf.cuil
        WHEN p.tipo = 'JURIDICA' THEN pj.cuit
    END AS identificacion,
    l.descripcion AS nombre_localidad,
    p2.descripcion AS nombre_provincia
FROM persona.cliente c
JOIN persona.persona p ON p.id = c.id_persona -- Unión entre cliente y persona
LEFT JOIN persona.persona_fisica pf ON p.id = pf.id_persona AND p.tipo = 'FISICA' -- Unión entre persona y persona física (si existe)
LEFT JOIN persona.persona_juridica pj ON p.id = pj.id_persona AND p.tipo = 'JURIDICA' -- Unión entre persona y persona jurídica (si existe)
LEFT JOIN persona.localidad l ON l.id = p.id_localidad -- Unión entre persona y localidad
LEFT JOIN persona.provincia p2 ON p2.id = l.id_provincia -- Unión entre localidad y provincia
ORDER BY denominacion;


----- Personas con múltiples roles
SELECT 
    CASE
        WHEN p.tipo = 'FISICA' THEN pf.apellido || ' ' || pf.nombre
        WHEN p.tipo = 'JURIDICA' THEN pj.denominacion
    END AS denominacion,
    CASE
        WHEN e.id_persona_fisica IS NOT NULL THEN 'EMPLEADO'
        WHEN pr.id_persona_juridica IS NOT NULL THEN 'PROVEEDOR'
        WHEN c.id_persona IS NOT NULL THEN 'CLIENTE'
    END AS rol_persona
FROM persona p
LEFT JOIN persona_fisica pf ON p.id = pf.id_persona AND p.tipo = 'FISICA' -- Unión entre persona y persona física
LEFT JOIN empleado e ON pf.id = e.id_persona_fisica -- Unión entre persona física y empleado
LEFT JOIN persona_juridica pj ON p.id = pj.id_persona AND p.tipo = 'JURIDICA' -- Unión entre persona y persona jurídica
LEFT JOIN proveedor pr ON pj.id_persona = pr.id_persona_juridica -- Unión entre persona jurídica y proveedor
LEFT JOIN cliente c ON p.id = c.id_persona -- Unión entre persona y cliente
WHERE 
    ((e.id_persona_fisica IS NOT NULL)::INT + 
     (pr.id_persona_juridica IS NOT NULL)::INT + 
     (c.id_persona IS NOT NULL)::INT) > 1 -- Al menos dos roles
ORDER BY denominacion;





