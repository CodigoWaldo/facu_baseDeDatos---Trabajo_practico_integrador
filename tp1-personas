---------- TP1 ----------
--*--*--*--*--*--*--*--*--

-----ESQUEMA PERSONA-----
-------------------------

----- Sucursales con información de empleados

select
	s.descripcion as nombre_sucursal,
	l.descripcion as nombre_localidad,
	p.descripcion as nombre_provincia,
	pf.apellido as apellido_empleado,
	pf.nombre as nombre_empleado
from sucursal s 
join localidad l on l.id = s.id_localidad --unión entre sucursal y localidad
join provincia p on p.id = l.id_provincia --unión entre localidad y provincia
join empleado e on s.id = e.id_sucursal --unión entre empleado y sucursal
join persona_fisica pf on pf.id = e.id_persona_fisica --unión entre empleado y persona física
order by nombre_provincia, nombre_localidad, nombre_sucursal, apellido_empleado, nombre_empleado;


----- Clientes con información de datos personales

select p.tipo,
case
	when p.tipo = 'FISICA' then pf.apellido || ' ' || pf.nombre
	when p.tipo = 'JURIDICA' then pj.denominacion
end as denominacion,
case
	when p.tipo = 'FISICA' then pf.cuil
	when p.tipo = 'JURIDICA' then pj.cuit
end as identificacion,
l.descripcion as nombre_localidad,
p2.descripcion as nombre_provincia
from persona.cliente c 
join 
	persona.persona p on p.id = c.id_persona -- unión entre cliente y persona
left join 
	persona.persona_fisica pf on p.id = pf.id_persona and p.tipo = 'FISICA' -- unión entre persona y persona física (si existe)
left join 
	persona.persona_juridica pj on p.id = pj.id_persona and p.tipo = 'JURIDICA' -- unión entre persona y persona jurídica (si existe)
left join 
	persona.localidad l on l.id = p.id_localidad -- unión entre persona y localidad
left join
	persona.provincia p2 on p2.id = l.id_provincia -- unión entre localidad y provincia 
order by denominacion;


----- Personas con múltiples roles
select 
    case
        when p.tipo = 'FISICA' then pf.apellido || ' ' || pf.nombre
        when p.tipo = 'JURIDICA' then pj.denominacion
    end as denominacion,

    case
        when e.id_persona_fisica is not null then 'EMPLEADO'
        when pr.id_persona_juridica is not null then 'PROVEEDOR'
         when c.id_persona is not null then 'CLIENTE'
    end as rol_persona

from persona p 

left join persona_fisica pf on p.id = pf.id_persona and p.tipo = 'FISICA' -- unión entre persona y persona física
left join empleado e on pf.id = e.id_persona_fisica -- unión entre persona física y empleado

left join persona_juridica pj on p.id = pj.id_persona and p.tipo = 'JURIDICA' -- unión entre persona y persona jurídica
left join proveedor pr on pj.id_persona = pr.id_persona_juridica -- unión entre persona jurídica y proveedor

left join cliente c on p.id = c.id_persona -- unión entre persona y cliente

where 
    ((e.id_persona_fisica is not null)::int + 
     (pr.id_persona_juridica is not null)::int + 
     (c.id_persona is not null)::int) > 1 -- al menos dos roles
order by denominacion;
