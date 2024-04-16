/*54. [M] Actividad con más especialistas (actividad_id).*/

SELECT actividad_id
FROM actividad
WHERE actividad_id IN (SELECT actividad_id
                        FROM especialista
                        GROUP BY actividad_id
                        HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                            FROM especialista
                                            GROUP BY actividad_id));

/*55. [M] Actividades con más sesiones programadas, indicando cuántas
son (actividad_id,
cuantas_sesiones).*/

SELECT actividad_id, COUNT(*) AS cuantas_sesiones
FROM sesion
GROUP BY actividad_id
HAVING COUNT(*) = (SELECT MAX(cuantas_sesiones)
                   FROM (SELECT COUNT(*) AS cuantas_sesiones
                    FROM sesion
                    GROUP BY actividad_id));

-- Mejor
SELECT actividad_id, COUNT(*) AS cuantas_sesiones
FROM sesion
GROUP BY actividad_id
HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                   FROM sesion
                   GROUP BY actividad_id);
                   
/*56. [M] Monitores que menos sesiones imparten (dni, nombre, salario).*/

SELECT dni, nombre, salario
FROM monitor
WHERE dni IN (SELECT monitor_id
                FROM sesion
                GROUP BY monitor_id
                HAVING COUNT(*) = (SELECT MIN(COUNT(*))
                                        FROM sesion
                                        GROUP BY monitor_id));

/*57. [M] Instalaciones que más se usan para realizar actividades 
(instalacion_id, nombre, m2).*/

SELECT instalacion_id, nombre, m2
FROM instalacion
WHERE instalacion_id IN (SELECT instalacion_id
                         FROM actividad
                         GROUP BY instalacion_id
                         HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                            FROM actividad
                                            GROUP BY instalacion_id))
ORDER BY instalacion_id;

/*58. [M] Nombre y precio de las actividades que menos sesiones 
tienen programadas (nombre,
precio). Ordenado por nombre.*/
SELECT nombre, precio
FROM actividad
WHERE actividad_id IN (SELECT actividad_id
                       FROM sesion
                       GROUP BY actividad_id
                       HAVING COUNT(*) = (SELECT MIN(COUNT(*))
                                          FROM sesion
                                          GROUP BY actividad_id))
ORDER BY nombre;

/*59. [M/D] Actividades cuyo responsable es el monitor con más 
antigüedad en el Centro y con más
de 2 sesiones semanales, en orden alfabético por su nombre 
(nombre, nivel, precio).*/

SELECT nombre, nivel, precio
FROM actividad
WHERE responsable IN (SELECT dni
                      FROM monitor
                      WHERE fcontrato = (SELECT MIN(fcontrato) 
                                         FROM monitor))
                  AND actividad_id IN (SELECT actividad_id
                                       FROM sesion
                                       GROUP BY actividad_id
                                       HAVING COUNT(*) > 2)
ORDER BY nombre;

/*60. [M/D] Monitor tal que el número de sesiones que 
imparte correspondientes a actividades
realizadas al aire libre coincide con la media 
(redondeada a cero decimales) del número de
sesiones que imparten los monitores (monitor_id, sesiones_exteriores).*/

-- MAS COMPLICADO SIN NECESIDAD XD
SELECT monitor_id, COUNT(*) AS sesiones_exteriores
FROM sesion    
WHERE monitor_id IN (SELECT monitor_id
                      FROM sesion
                      GROUP BY monitor_id
                      HAVING COUNT(*) = (SELECT ROUND(AVG(COUNT(*)))
                                          FROM sesion
                                           GROUP BY monitor_id))
GROUP BY monitor_id;
 
-- CORRECTO

SELECT monitor_id, COUNT(*) AS sesiones_exteriores
FROM sesion    
WHERE actividad_id IN (SELECT actividad_id
                       FROM actividad
                       WHERE instalacion_id IN (SELECT instalacion_id
                                                FROM instalacion
                                                WHERE tipo = 'Exterior'))
GROUP BY monitor_id
HAVING COUNT(*) = (SELECT ROUND(AVG(COUNT(*)))
                    FROM sesion
                     GROUP BY monitor_id);

/*61. [M/D] Mostrar las actividades con más monitores especialistas, 
mostrando su identificador, su
nombre, y el nombre de su monitor responsable (actividad_id, nombre_actividad,
nombre_responsable).*/

SELECT a.actividad_id, a.nombre, m.nombre
FROM actividad a JOIN monitor m 
                 ON a.responsable = m.dni
WHERE a.actividad_id IN (SELECT actividad_id
                        FROM especialista
                        GROUP BY actividad_id
                        HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                           FROM especialista
                                           GROUP BY actividad_id));

/*62. [D] Para los monitores con el salario más bajo, obtener el
número de sesiones que imparten en
martes, así como nombre de la actividad (nombre_monitor, nombre_actividad,
sesiones_martes).*/

SELECT nombre_monitor, nombre_actividad, sesiones_martes
FROM sesion s JOIN (SELECT dni, nombre AS nombre_monitor
                      FROM monitor
                      WHERE salario = (SELECT MIN(salario)
                                        FROM monitor)) m
              ON s.monitor_id = m.dni
              JOIN (SELECT actividad_id, nombre AS nombre_actividad, 
                                        COUNT(*) sesiones_martes
              FROM actividad
              GROUP BY actividad_id, nombre) A
              ON s.actividad_id = A.actividad_id
WHERE diasemana = 'M'
GROUP BY nombre_monitor, nombre_actividad, sesiones_martes
ORDER BY nombre_monitor;

/*63. [F/M] Utiliza online views para mejorar la 43: Dni y nombre de 
cada monitor y cuántas sesiones
imparte. Ordenado por nombre (dni, nombre, cuantas_sesiones).*/

SELECT dni, nombre, cuantas_sesiones             
FROM monitor m JOIN (SELECT monitor_id, COUNT(*) AS cuantas_sesiones
                    FROM sesion
                    GROUP BY monitor_id) S
                    ON S.monitor_id = m.dni
ORDER BY nombre;

/*64. [F/M] Utiliza online views para mejorar la 44: 
Cuántas sesiones se imparten de cada actividad.
Ordenado por identificador de actividad 
(actividad_id, nombre, cuantas_sesiones).*/

SELECT a.actividad_id, a.nombre, S.cuantas_sesiones
FROM actividad a JOIN (SELECT actividad_id, COUNT(*) cuantas_sesiones
                       FROM sesion
                       GROUP BY actividad_id) S
                 ON a.actividad_id = S.actividad_id
ORDER BY actividad_id;


/*65. [M] Utiliza online views para ampliar la 29: Nombre de los 
monitores que imparten sesiones los
martes por la tarde, a partir de las 4pm, de alguna actividad de
nivel alto o muy alto, indicando
cuál es dicha actividad. (nombre_monitor, nombre_actividad).*/
                                 
SELECT nombre_monitor, a.nombre
FROM actividad a JOIN (SELECT dni, nombre AS nombre_monitor
                   FROM monitor) M
                 ON M.dni = A.responsable
             JOIN (SELECT actividad_id
                   FROM sesion
                   WHERE (diasemana = 'M' AND hora >= 16.00)) S
             ON a.actividad_id = S.actividad_id
WHERE a.nivel BETWEEN 4 AND 5;


/*66. [M/D] Utiliza online views para ampliar la 53: Para cada 
actividad realizada en una instalación
interior, mostrar el nombre de la actividad, el identificador de 
su responsable, y cuántas
sesiones de esa actividad imparte ese monitor 
(nombre, responsable, cuantas_sesiones).*/

SELECT nombre, responsable, cuantas_sesiones
FROM actividad a JOIN (SELECT instalacion_id
                       FROM instalacion
                       WHERE tipo = 'Interior') I
                 ON a.instalacion_id = I.instalacion_id
                 JOIN (SELECT actividad_id, monitor_id, 
                                         COUNT(*) AS cuantas_sesiones
                       FROM sesion
                       GROUP BY actividad_id,monitor_id) S
                       ON a.actividad_id = S.actividad_id
WHERE a.responsable = S.monitor_id;

/*67. [M/D] Utiliza online views para ampliar la 54: Actividad 
con más monitores especialistas,
indicando el nombre de la actividad y cuántos especialistas 
tiene (actividad_id, nombre,
cuantos_especialistas).*/

SELECT a.actividad_id, a.nombre, E.cuantos_especialistas 
FROM actividad a JOIN (SELECT actividad_id, COUNT(*) cuantos_especialistas 
                        FROM especialista
                        GROUP BY actividad_id
                        HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                            FROM especialista
                                            GROUP BY actividad_id)) E
                ON a.actividad_id = E.actividad_id;
                
/*68. [M/D] Utiliza online views para ampliar la 55: 
Identificador, nombre y nivel de la actividad con
más sesiones semanales programadas, indicando cuántas 
sesiones son (actividad_id,
nombre, cuantas_sesiones).*/

SELECT a.actividad_id, a.nombre, S.cuantas_sesiones
FROM actividad a JOIN (SELECT actividad_id, COUNT(*) cuantas_sesiones
                       FROM sesion
                       GROUP BY actividad_id
                       HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                          FROM sesion
                                          GROUP BY actividad_id)) S
                 ON a.actividad_id = S.actividad_id;

/*69. Mostrar cuantas actividades de nivel 3 y cuantas de nivel 5 
se realizan en cada instalación.
Deben aparecer todas las instalaciones, mostrando un cero para una
instalación no utilizada
para actividades de uno u otro nivel. Mostrar ordenado por 
identificador de instalación
(nombre, activ_3, activ_5).*/

-- EN SOLUCION: SE HA EQUIVOCADO Y EN VEZ DE NIVEL 3, HA PUESTO 2

SELECT i.nombre, COALESCE(activ_2, 0) activ_2, COALESCE(activ_5, 0) activ_5
FROM instalacion i LEFT JOIN (SELECT instalacion_id, COUNT(*) activ_2
                        FROM actividad
                        WHERE nivel = 2
                        GROUP BY instalacion_id) A1
                    ON i.instalacion_id = A1.instalacion_id
                    LEFT JOIN (SELECT instalacion_id, COUNT(*) activ_5
                        FROM actividad
                        WHERE nivel = 5
                        GROUP BY instalacion_id) A2
                    ON i.instalacion_id = A2.instalacion_id
ORDER BY i.instalacion_id;

/*70. Utiliza online views para combinar y ampliar las consultas 49 y 50:
Para cada monitor, indicar de
cuántas actividades es responsable, de cuántas es especialista, y
cuántas sesiones imparte en
total. Deben aparecer todos los monitores, mostrando un cero cuando
un monitor no sea
responsable, o no sea especialista o no imparta ninguna sesión. 
Mostrar ordenado por nombre
(nombre, n_responsable, n_especialista, n_sesiones).*/

SELECT m.nombre, COALESCE(n_responsable, 0) n_responsable,
                 COALESCE(n_especialista, 0) n_especialista,
                 COALESCE(n_sesiones, 0) n_sesiones
FROM monitor m LEFT JOIN (SELECT responsable, COUNT(*) n_responsable
                        FROM actividad
                        GROUP BY responsable) A
                        ON m.dni = A.responsable
             LEFT JOIN (SELECT monitor_id, COUNT(*) n_especialista
                        FROM especialista
                        GROUP BY monitor_id) E
                        ON m.dni = E.monitor_id
             LEFT JOIN (SELECT monitor_id, COUNT(*) n_sesiones
                        FROM sesion
                        GROUP BY monitor_id) S
                        ON m.dni = S.monitor_id
ORDER BY m.nombre;

/*71. [D] Actividades tales que todos los monitores 
son especialistas en ella (nombre, nivel)     
->
Actividades tales que NO EXISTE un monitor que NO sea especialista en ella. */

SELECT a.nombre, a.nivel
FROM actividad a
WHERE NOT EXISTS (SELECT *
                  FROM monitor m
                  WHERE m.dni NOT IN (SELECT e.monitor_id
                                           FROM especialista e
                                           WHERE e.monitor_id = a.responsable))

