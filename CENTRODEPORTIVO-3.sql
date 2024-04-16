/*22. [M] Monitores que imparten sesiones de actividades pero 
no son responsables de ninguna
(monitor_id). Hay que usar operadores de conjuntos.*/

SELECT monitor_id
FROM sesion

MINUS

SELECT responsable
FROM actividad a JOIN monitor m
                 ON a.responsable = m.dni;

/*23. [M] Monitores responsables de actividades con nivel 
de intensidad 5 y que además son
especialistas en actividades de nivel 2 (responsable). 
Hay que usar operadores de conjuntos.*/

SELECT responsable
FROM actividad
WHERE nivel = 5

INTERSECT

SELECT monitor_id
FROM actividad a JOIN especialista e
                 ON a.actividad_id = e.actividad_id
WHERE nivel = 2;

/*24. [M] Actividades que se desarrollan en instalaciones de 
tipo exterior y que tienen programada
alguna sesión los viernes (actividad_id). 
Hay que usar operadores de conjuntos.*/

SELECT a.actividad_id
FROM actividad a JOIN sesion s 
                 ON a.actividad_id = s.actividad_id
WHERE s.diasemana = 'V'

INTERSECT

SELECT a.actividad_id
FROM actividad a 
JOIN instalacion i ON a.instalacion_id = i.instalacion_id
WHERE i.tipo = 'Exterior';


/*25. [M] Monitores contratados hace mas de 12 annos tales 
que imparten al menos una sesión y
todas sus sesiones sean por la tarde a partir de las 16h. (dni). 
Hay que usar operadores de conjuntos.*/

-- NO SALE IGUAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SELECT dni
FROM monitor m JOIN sesion s
               ON m.dni = s.monitor_id
WHERE EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM fcontrato) > 12

INTERSECT

SELECT monitor_id
FROM sesion
WHERE hora >= 16.00;

/*26. [F] Instalaciones no utilizadas para ninguna actividad. 
(instalacion_id, nombre, tipo).*/
SELECT instalacion_id, nombre, tipo
FROM instalacion
WHERE instalacion_id NOT IN (SELECT instalacion_id
                             FROM actividad);

/*27. [F] Monitores no responsables de ninguna actividad, mostrando 
su fecha de contrato con el
mes en letras minúsculas y el año con cuatro dígitos. 
(dni, nombre, fcontrato). Ordenado
por fecha de contrato.*/
SELECT dni, nombre, TO_CHAR(fcontrato, 'dd/month/yyyy')
FROM monitor
WHERE dni NOT IN (SELECT responsable
                  FROM actividad)
ORDER BY fcontrato;

/*28. [F/M] Monitores responsables de alguna actividad de hasta
nivel 3 que se desarrolle en una
instalación de entre 50 y 200m2 (dni, nombre).*/

SELECT dni, nombre
FROM monitor
WHERE dni IN (SELECT responsable
                FROM actividad
                WHERE nivel <= 3 
                AND instalacion_id IN (SELECT instalacion_id
                                        FROM instalacion
                                        WHERE m2 BETWEEN 50 AND 200));
                            
/*29. [F/M] Nombre de los monitores que imparten sesiones 
los martes por la tarde, a partir de las
4pm, de alguna actividad de nivel alto o muy alto. (nombre).*/

SELECT nombre
FROM monitor
WHERE dni IN (SELECT monitor_id
              FROM sesion
              WHERE (diasemana = 'M' AND hora >= 16.00) 
              AND actividad_id IN (SELECT actividad_id
                                 FROM actividad
                                 WHERE nivel >=4));

/*30. [M] Nombre y tipo de las instalaciones en las que sólo 
se desarrollan actividades de nivel de
intensidad muy bajo y bajo, es decir de nivel 1 y 2 (nombre, tipo). 
No deben aparecer las
instalaciones que nunca se usen para ninguna actividad.*/

SELECT nombre, tipo
FROM instalacion
WHERE instalacion_id IN (SELECT instalacion_id
                        FROM actividad
                        WHERE (nivel BETWEEN 1 AND 2) 
                        AND instalacion_id NOT IN (SELECT instalacion_id
                                                   FROM actividad
                                                   WHERE nivel > 2));


/*31. [M] Obtener nombre y fecha de contrato de cada monitor que 
imparte sesiones de actividades
en las que no es especialista. Es una consulta de detección 
de errores en los datos. (nombre,
fcontrato).*/

SELECT nombre, fcontrato
FROM monitor
WHERE dni IN (SELECT responsable
                FROM actividad
                WHERE responsable NOT IN (SELECT monitor_id
                                          FROM especialista));
                                        
/*32. [M] Nombre de cada monitor responsable de alguna actividad 
de la que no imparte ninguna
sesión.*/

-- NO FUNCIONA
SELECT nombre
FROM monitor
WHERE dni IN (SELECT responsable
              FROM actividad)
          AND dni NOT IN (SELECT monitor_id
                      FROM sesion);
                                        
-- OTRA
SELECT nombre
FROM monitor
WHERE dni IN (SELECT responsable
              FROM actividad
              WHERE responsable IN (SELECT monitor_id
                                FROM sesion));
                                
-- TAMPOCO FUNCIONA XD                    
SELECT m.nombre
FROM monitor m
WHERE EXISTS (
    -- Selecciona monitores que son responsables de alguna actividad
    SELECT a.responsable
    FROM actividad a
    WHERE a.responsable = m.dni
) AND NOT EXISTS (
    -- Asegura que el mismo monitor no imparta sesiones
    SELECT s.monitor_id
    FROM sesion s
    WHERE s.monitor_id = m.dni
);
                                                
/*33. [M] Monitores que son responsables de alguna actividad 
organizada en una instalación de más
de 500 m2, indicando el nombre de dicha actividad. 
(nombre_monitor, nombre_actividad).
Ordenado por monitor.*/
--NOOO
SELECT nombre, A.nombre
FROM monitor
WHERE dni IN (SELECT responsable
                FROM actividad
                WHERE instalacion_id IN (SELECT instalacion_id
                                        FROM instalacion
                                        WHERE m2 > 500))
ORDER BY dni;



-- FUNCIONA
SELECT m.nombre AS nombre_monitor, a.nombre AS nombre_actividad
FROM monitor m
JOIN actividad a ON m.dni = a.responsable
JOIN instalacion i ON a.instalacion_id = i.instalacion_id
WHERE i.m2 > 500
ORDER BY m.nombre;


-- NOOOOOOOOOOOO
SELECT m.nombre AS nombre_monitor,
       (
           SELECT a.nombre
           FROM actividad a
           JOIN instalacion i ON a.instalacion_id = i.instalacion_id
           WHERE a.responsable = m.dni AND i.m2 > 500
       ) AS nombre_actividad
FROM monitor m
WHERE EXISTS (
    SELECT instalacion_id
    FROM actividad a
    JOIN instalacion i ON a.instalacion_id = i.instalacion_id
    WHERE a.responsable = m.dni AND i.m2 > 500
)
ORDER BY m.nombre;

/*34. [M/D] Nombre de las instalaciones utilizadas 
para alguna actividad de nivel 3 cuyo
responsable sea un monitor contratado antes de 2018 y 
tenga alguna sesión los sábados.*/

SELECT nombre
FROM instalacion
WHERE instalacion_id IN (
    SELECT instalacion_id
    FROM actividad
    WHERE nivel = 3 
    AND responsable IN (SELECT dni
                        FROM monitor
                        WHERE EXTRACT (YEAR FROM fcontrato) < 2018)
    AND actividad_id IN (SELECT actividad_id
                         FROM sesion
                         WHERE diasemana = 'S'));

/*35. [F] Media del número de sesiones que imparten los monitores 
(numero_medio_sesiones).*/
SELECT AVG(COUNT(*)) AS numero_medio_sesiones
FROM sesion
GROUP BY monitor_id;

/*36. [F] Datos de los monitores que cobran el menor salario 
(nombre, fcontrato, salario).*/
SELECT nombre, fcontrato, salario
FROM monitor
WHERE salario = (SELECT MIN(salario)
                FROM monitor);
                
/*37. [F] Para cada actividad, indicar cuántos monitores son 
especialistas en ella. (actividad_id,
cuantos_monitores). Ordenado por actividad.*/
SELECT actividad_id, COUNT(*) AS cuantos_monitores
FROM especialista
GROUP BY actividad_id
ORDER BY actividad_id;

/*38. [F] Mostrar cuántas sesiones se realizan en cada día de la semana. 
(diasemana,
cuantas_sesiones). Ordenado de más a menos número de sesiones.*/
SELECT diasemana, COUNT(*) AS cuantas_sesiones
FROM sesion
GROUP BY diasemana
ORDER BY cuantas_sesiones DESC;
 
/*39. [F] Cuántas sesiones hay programadas en cada hora 
de inicio por las mañanas hasta las 13:30
(hora, cuantas_sesiones). Ordenado por hora.*/
SELECT hora, COUNT(*) AS cuantas_sesiones
FROM sesion
WHERE hora BETWEEN 00.00 AND 13.30
GROUP BY hora
ORDER BY hora;

/*40. [F] Cuántas sesiones dirige cada monitor en cada
día de la semana (monitor_id, diasemana,
cuantas_sesiones). Ordenado por monitor.*/

SELECT monitor_id, diasemana, COUNT(*) AS cuantas_sesiones
FROM sesion
GROUP BY monitor_id, diasemana
ORDER BY monitor_id;

/*41. [F] Mostrar cuántas actividades se realizan en 
cada instalación (instalación_id,
cuantas_actividades), ordenado por instalación.*/

SELECT instalacion_id, COUNT(*) AS cuantas_actividades
FROM actividad
GROUP BY instalacion_id
ORDER BY instalacion_id;

/*42. [F/M] Para cada monitor cuyo salario esté entre 
950 y 1500€, mostrar cuántas sesiones imparte
a la semana (monitor_id, cuantas_sesiones).*/

SELECT monitor_id, COUNT(*) AS cuantas_sesiones
FROM sesion
WHERE monitor_id IN (SELECT dni
                     FROM monitor
                     WHERE salario BETWEEN 950 AND 1500)
GROUP BY monitor_id;

/*43. [F/M] Dni y nombre de cada monitor y cuántas sesiones imparte. 
Ordenado por nombre (dni,
nombre, cuantas_sesiones).*/
SELECT dni, nombre, (SELECT COUNT(*)
                    FROM sesion s
                    WHERE s.monitor_id = m.dni) AS cuantas_sesiones             
FROM monitor m
ORDER BY nombre;

-- OTRA ALTERNATIVA

SELECT m.dni, m.nombre, COUNT(s.actividad_id) AS cuantas_sesiones
FROM monitor m JOIN sesion s 
                ON m.dni = s.monitor_id
GROUP BY m.dni, m.nombre
ORDER BY m.nombre;

/*44. [F/M] Cuántas sesiones se imparten de cada actividad. 
Ordenado por identificador de
actividad (actividad_id, nombre, cuantas_sesiones).*/

SELECT a.actividad_id, a.nombre, (  SELECT COUNT(*)
                                    FROM sesion s
                                    WHERE s.actividad_id = a.actividad_id
                                ) AS cuantas_sesiones
FROM actividad a
WHERE a.actividad_id IN (SELECT actividad_id
                        FROM sesion)
GROUP BY a.actividad_id, a.nombre
ORDER BY a.actividad_id;

-- OTRA
SELECT a.actividad_id, a.nombre, COUNT(s.actividad_id) AS cuantas_sesiones
FROM actividad a
LEFT JOIN sesion s ON a.actividad_id = s.actividad_id
GROUP BY a.actividad_id, a.nombre
ORDER BY a.actividad_id;

/*45. [F/M] Mostrar las instalaciones que sólo se utilizan 
para una actividad (instalacion_id).*/
SELECT instalacion_id
FROM instalacion
WHERE instalacion_id IN (SELECT instalacion_id
                        FROM actividad
                        GROUP BY instalacion_id
                        HAVING COUNT(*) = 1);

/*46. [M] Actividades cuyo responsable se llama Auspicia y 
tienen más de 2 sesiones semanales,
ordenado alfabéticamente por nombre (nombre, nivel, precio).*/
SELECT *
FROM actividad
WHERE actividad_id IN (SELECT actividad_id
                        FROM sesion
                        GROUP BY actividad_id
                        HAVING COUNT(*) > 2)
AND responsable IN (SELECT dni
                    FROM monitor
                    WHERE nombre = 'Auspicia')
ORDER BY nombre;

/*47. [M] Obtener los monitores que dirijan más de 6 sesiones 
semanales (nombre, fcontrato).*/
SELECT nombre, fcontrato
FROM monitor
WHERE dni IN (SELECT monitor_id
                FROM sesion
                GROUP BY monitor_id
                HAVING COUNT(*) > 6)
ORDER BY nombre;

/*48. [M] Días de la semana en los que se ha programado más de 3 
sesiones al aire libre (diasemana).*/

SELECT diasemana
FROM sesion
WHERE actividad_id IN (SELECT actividad_id
                        FROM actividad
                        WHERE instalacion_id IN (SELECT instalacion_id
                                                FROM instalacion
                                                WHERE tipo = 'Exterior'))
GROUP BY diasemana
HAVING COUNT(*) > 3
ORDER BY diasemana;
                        
/*49. [M] Para cada monitor mostrar cuántas sesiones imparte, 
de forma que aquellos que no
imparten ninguna sesión muestren un 0. 
Ordenado por dni del monitor. (dni, nombre,
cuantas_sesiones).*/

SELECT dni, nombre, COALESCE(COUNT(s.actividad_id), 0) AS cuantas_sesiones
FROM monitor m LEFT JOIN sesion s
                ON m.dni = s.monitor_id
GROUP BY dni, nombre
ORDER BY dni;

/*50. [M] Para cada monitor, indicar en cuántas actividades 
es especialista, mostrando un 0 para
aquellos monitores que no sean especialistas en ninguna actividad. 
Ordenado por la columna
calculada (dni, nombre, cuantas_actividades).*/

SELECT dni, nombre, COALESCE(COUNT(e.actividad_id), 0) AS cuantas_actividades
FROM monitor m LEFT JOIN especialista e
                ON m.dni = e.monitor_id
GROUP BY dni, nombre
ORDER BY cuantas_actividades;

/*51. [M] Mostrar cuántas actividades se realizan en cada instalación.
En el resultado deben aparecer
todas las instalaciones, mostrando un 0 en la columna 
cuantas_actividades para aquellas en
las que no se realice ninguna actividad. 
(instalacion_id, cuantas_actividades), ordenado
por instalación.*/

SELECT i.instalacion_id,
                COALESCE(COUNT(a.actividad_id), 0) AS cuantas_actividades
FROM instalacion i LEFT JOIN actividad a
                ON i.instalacion_id = a.instalacion_id 
GROUP BY i.instalacion_id 
ORDER BY i.instalacion_id;

/*52. [M/D] Cuántas sesiones imparte cada monitor de cada una 
de las actividades de las que es
responsable (responsable, actividad_id, cuantas_sesiones).*/

SELECT a.responsable, a.actividad_id,
                COUNT(s.actividad_id) AS cuantas_actividades
FROM actividad a JOIN sesion s
                ON a.actividad_id = s.actividad_id
WHERE a.responsable = s.monitor_id
GROUP BY a.responsable, a.actividad_id
ORDER BY a.actividad_id;

/*53. [M/D] Para cada actividad realizada en una instalación interior, 
mostrar el nombre de la
actividad, el identificador de su responsable, 
y cuántas sesiones de esa actividad tiene
programadas ese monitor (nombre, responsable, cuantas_sesiones)*/

-- BIEN
SELECT a.nombre, a.responsable,
                COUNT(i.instalacion_id) AS cuantas_actividades
FROM actividad a JOIN instalacion i
                ON a.instalacion_id = i.instalacion_id
                LEFT JOIN sesion s 
                ON a.actividad_id = s.actividad_id
WHERE i.tipo = 'Interior' AND a.responsable = s.monitor_id
GROUP BY a.nombre, a.responsable;


-- OTRA (MAL)
SELECT a.nombre, a.responsable, (SELECT COUNT(*)
                                 FROM sesion s
                                 WHERE s.actividad_id = a.actividad_id 
                                 AND s.monitor_id = a.responsable) 
                                 AS cuantas_sesiones
FROM actividad a JOIN instalacion i 
                 ON a.instalacion_id = i.instalacion_id
WHERE i.tipo = 'Interior';

-- BIEN
SELECT 
    a.nombre, 
    a.responsable,
    COUNT(s.actividad_id) AS cuantas_sesiones
FROM actividad a 
JOIN instalacion i 
ON a.instalacion_id = i.instalacion_id AND i.tipo = 'Interior'
JOIN sesion s 
ON a.actividad_id = s.actividad_id AND a.responsable = s.monitor_id
GROUP BY a.nombre, a.responsable;

