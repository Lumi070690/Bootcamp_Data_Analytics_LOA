# NIVEL 1

# EJERCICIO 2
# Utilizando JOIN realizarás las siguientes consultas:

# Listado de los países que están generando ventas.

SELECT DISTINCT c.country AS listado_paises
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.amount > 0 AND t.declined = 0;

# Desde cuántos países se generan las ventas.
SELECT COUNT(DISTINCT c.country) AS cantidad_paises_ventas
FROM company as c
INNER JOIN transaction AS t ON c.id = t.company_id
WHERE t.amount > 0 AND t.declined = 0;

#Identifica a la compañía con la mayor media de ventas.
SELECT c.company_name AS compañia_mas_ventas, AVG(t.amount) AS media
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
GROUP BY c.id, c.company_name
ORDER BY media DESC
LIMIT 1;

# EJERCICIO 3
# Utilizando sólo subconsultas (sin utilizar JOIN):

# Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT *
FROM transaction AS t
WHERE t.company_id IN (SELECT c.id
FROM company AS c
WHERE c.country = 'Germany'
);

# Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT c.company_name AS empresas_encima_media
FROM company AS c
WHERE c.id IN (SELECT t.company_id
			   FROM transaction AS t
			   WHERE t.amount > (
			   SELECT AVG(t.amount)
			   FROM transaction AS t)
);

# Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
SELECT c.company_name AS empresas_sin_transacciones
FROM company AS c
WHERE NOT EXISTS (SELECT 1
                  FROM transaction AS t
                  WHERE t.company_id = c.id
);

# NIVEL 2

#EJERCICIO 1

# Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT DATE(t.timestamp) AS fecha, SUM(t.amount) AS total_ventas
FROM transaction AS t
GROUP BY fecha
ORDER BY total_ventas DESC
Limit 5;

# ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country AS pais, AVG(t.amount) AS media_ventas
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
GROUP BY pais
ORDER BY media_ventas DESC;

# EJERCICIO 3
# En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.

# Muestra el listado aplicando JOIN y subconsultas.
SELECT t.*
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE c.country = (SELECT c.country
                  FROM company AS c
                  WHERE c.company_name = 'Non Institute'
);

# Muestra el listado aplicando solo subconsultas.
SELECT t.*
FROM transaction AS t
WHERE t.company_id IN (SELECT c.id
					  FROM company AS c
                      WHERE c.country = (SELECT country
										 FROM company AS c
                                         WHERE c.company_name ='Non Institute')
);

# NIVEL 3

# EJERCICIO 1
# Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros
# y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, DATE(timestamp) AS fecha, t.amount
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE amount BETWEEN 350 AND 400
AND DATE(timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

# Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
# pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.

SELECT c.company_name, c.id, IF (COUNT(t.amount) > 400, 'mas de 400', 'menos de 400') AS conteo_transacciones
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
GROUP BY c.company_name, c.id;


