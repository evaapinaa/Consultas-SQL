/*10. [F] Instalaciones en las que se ubican actividades de nivel 
de intensidad muy bajo y bajo, es decir de nivel 1 y 2. 
Sin duplicados. Ordenado ascendentemente (instalacion_id).*/

SELECT DISTINCT instalacion_id 
FROM actividad
WHERE nivel BETWEEN 1 AND 2
ORDER BY instalacion_id ASC;

/*11. [F] Metros cuadrados de las instalaciones dedicadas a las actividades 
‘Pilates’ y/o a ‘Balonmano’, indicando el nombre de la instalación y 
el de la actividad (nombre_actividad,
nombre_instalacion, m2).*/

SELECT a.nombre , i.nombre , m2
FROM actividad a JOIN instalacion i
            ON a.instalacion_id = i.instalacion_id
WHERE a.nombre IN ('Pilates' , 'Balonmano');

/*12. [F] Nombres de los monitores que los viernes por la tarde
(después de las 15h) imparten sesiones de las actividades cuyos
identificadores son ‘A02’, ‘A05’, ‘A09’ y ‘A19’
(actividad_id, hora, nombre_monitor). Ordenado por hora de inicio.*/

SELECT s.actividad_id, s.hora, m.nombre
FROM sesion s JOIN monitor m
    ON s.monitor_id = m.dni
WHERE (diasemana = 'V' AND hora >= 15.00) 
AND actividad_id IN ('A02', 'A05', 'A09', 'A19')
ORDER BY hora; 

/*13. [F] Actividades que se desarrollan al aire libre. 
(nombre_actividad, precio, nivel,
nombre_instalacion). Ordenado por nombre de actividad.*/
SELECT a.nombre, precio, nivel, i.nombre
FROM actividad a JOIN instalacion i
                ON a.instalacion_id = i.instalacion_id
WHERE i.tipo = 'Exterior'
ORDER BY a.nombre;


/*14. [F] Monitores que imparten sesiones a las 19h o 
más tarde de alguna actividad de nivel alto o
muy alto. Sin repeticiones. (nombre_monitor, nombre_actividad).*/

SELECT DISTINCT m.nombre, a.nombre
FROM monitor m JOIN sesion s
            ON m.dni = s.monitor_id
            JOIN actividad a
            ON s.actividad_id = a.actividad_id
WHERE (s.hora >= 19.00 AND a.nivel >= 4);

/*15. [F/M] Para las sesiones programadas para viernes y sábados,
mostrar el tipo de instalación
donde tienen lugar (exterior o interior), el nombre de la actividad,
su nivel y el día de la
semana en el que se desarrollan. Mostrar los datos ordenados 
por día de la semana y de mayor
a menor intensidad. (tipo, nombre_actividad, nivel, diasemana).*/

SELECT tipo, a.nombre, nivel, diasemana
FROM instalacion i JOIN actividad a
                ON i.instalacion_id = a.instalacion_id
                JOIN sesion s
                ON s.actividad_id = a.actividad_id
WHERE diasemana IN ('V', 'S')
ORDER BY diasemana, nivel DESC;

/*16. [F/M] Mostrar el nombre de cada monitor junto con el nombre de 
cada actividad en la que es
especialista. (nombre_monitor, nombre_actividad). 
Ordenado por nombre de monitor.*/

SELECT m.nombre, a.nombre
FROM especialista e JOIN monitor m
                ON e.monitor_id = m.dni
                JOIN actividad a
                ON e.actividad_id = a.actividad_id
ORDER BY m.nombre;


/*17. [M] Tipo de las instalaciones dedicadas 
a las actividades ‘Yoga’, ‘Body combat‘ y ‘Hapkido‘,
indicando el nombre de la instalación y el del responsable de la actividad
(nombre_instalacion, tipo, nombre_monitor). 
Ordenado por nombre de instalación.*/

SELECT i.nombre, i.tipo, m.nombre
FROM actividad a JOIN instalacion i
                ON a.instalacion_id = i.instalacion_id
                JOIN monitor m
                ON a.responsable = m.dni
WHERE a.nombre IN ('Yoga', 'Body combat' ,'Hapkido')
ORDER BY i.nombre;


/*18. [M] Listar las sesiones que tienen lugar los lunes y miércoles, 
junto con el nombre de la
actividad y el de su monitor. 
(diasemana, hora, nombre_actividad, nombre_monitor),
ordenado por día, hora y actividad.*/

SELECT diasemana, hora, a.nombre, m.nombre
FROM actividad a JOIN monitor m 
                ON  a.responsable = m.dni
                JOIN sesion s
                ON a.actividad_id = s.actividad_id
WHERE diasemana IN ('L', 'X')
ORDER BY diasemana, hora, a.nombre;


/*19. [M] Sesiones programadas para la monitora llamada ‘Belinda’, 
indicando también el nombre
de la actividad y el nombre del responsable de la actividad (diasemana, hora,
nombre_actividad, nombre_responsable).*/

SELECT s.diasemana, s.hora, a.nombre, m.nombre
FROM sesion s JOIN actividad a 
            ON s.actividad_id = a.actividad_id
            JOIN monitor m 
            ON a.responsable = m.dni
WHERE s.monitor_id = '66666666F';

/*20. [M] Listado de actividades y sus monitores responsables. 
Se debe mostrar todos los monitores
existentes en la base de datos. 
Para cada monitor que no sea responsable de ninguna actividad,
se debe mostrar 3 guiones en la columna correspondiente a la actividad. 
(nombre_actividad,
nombre_responsable). Ordenado por nombre de monitor.*/

SELECT m.nombre, COALESCE(a.nombre, '---') AS nombre_actividad
FROM monitor m
LEFT JOIN actividad a ON m.dni = a.responsable
ORDER BY m.nombre;

/*21. [M] Instalaciones y actividades, 
mostrando todas las instalaciones existentes. Para cada
instalación que no se use para ninguna actividad, 
se debe mostrar 4 guiones en la columna
correspondiente a la actividad (nombre_instalacion, nombre_actividad). 
Ordenado por
nombre de instalación.*/

SELECT i.nombre, COALESCE(a.nombre, '---') AS nombre_actividad
FROM instalacion i
LEFT JOIN actividad a ON i.instalacion_id = a.instalacion_id
ORDER BY i.nombre;