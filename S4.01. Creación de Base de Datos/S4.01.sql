-- Nivel 1

-- Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
-- al menos 4 tablas de las que puedas realizar las siguientes consultas:

-- 1) creamos la BBDD sprint4
CREATE DATABASE sprint4;

-- 2) creamos las tablas a usar 

DROP TABLE IF EXISTS american_users;
CREATE TABLE IF NOT EXISTS american_users (
	id INT PRIMARY KEY,
    name VARCHAR(30),
    surname VARCHAR(30),
    phone VARCHAR(30),
    email VARCHAR(50),
    birth_date VARCHAR(20),
    country VARCHAR(30),
    city VARCHAR(30),
    postal_code VARCHAR(20),
    address VARCHAR(50)
);

DROP TABLE IF EXISTS european_users;
CREATE TABLE IF NOT EXISTS european_users (
	id INT PRIMARY KEY,
    name VARCHAR(30),
    surname VARCHAR(30),
    phone VARCHAR(30),
    email VARCHAR(50),
    birth_date VARCHAR(20),
    country VARCHAR(30),
    city VARCHAR(30),
    postal_code VARCHAR(20),
    address VARCHAR(50)
);

DROP TABLE IF EXISTS companies;
CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(50) PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(50),
    country VARCHAR(30),
    website VARCHAR(50)
);			

DROP TABLE IF EXISTS credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin CHAR(4),
    cvv CHAR(3),
    track1 VARCHAR(60),
    track2 VARCHAR(60),
    expiring_date VARCHAR(10)
);

DROP TABLE IF EXISTS transactions;
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(20), 
    business_id VARCHAR(50),
	timestamp TIMESTAMP,
	amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_ids VARCHAR(20),
    user_id INT,
    lat VARCHAR(50),
    longitude VARCHAR(50),
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id)
); 

-- 3) cargamos las tablas con los archivos csv

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE american_users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv'
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
IGNORE 1 ROWS;

-- 4) verificamos si hay ids duplicados en las tablas american_users y european_users para unirlas

SELECT COUNT(*) AS total_repetidos
FROM american_users a
JOIN european_users e ON a.id = e.id;

-- 5) agregamos una columna en american_users y en european_users llamada 'region'

ALTER TABLE american_users
ADD region VARCHAR(20);

UPDATE american_users
SET region = 'America'
WHERE id > 0;

ALTER TABLE european_users
ADD region VARCHAR(20);

UPDATE european_users
SET region = 'Europa'
WHERE id != '';

-- 6) unimos tablas american.users y european_users

DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users AS
SELECT * FROM american_users
UNION ALL
SELECT * FROM european_users;

-- 7) agregamos primary key a users

ALTER TABLE users
ADD PRIMARY KEY (id);

-- 8) relacionamos tabla users con transactions 

ALTER TABLE transactions
ADD CONSTRAINT users_transaction
FOREIGN KEY (user_id)
REFERENCES users(id);

-- 9) cambiamos users.birth_date a DATE

UPDATE users
SET birth_date = STR_TO_DATE(birth_date,'%b %d, %Y') 
WHERE id > 0;

-- 10) cambiamos credit_card.expiring_date a DATE

UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y')
WHERE id != '';

-- 11) eliminamos american_users y european_users 

DROP TABLE IF EXISTS american_users, european_users;

-- Ejercicio 1
-- Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

SELECT u.name, u.surname, COUNT(t.id) AS cantidad_transacciones
FROM transactions t
JOIN users u ON t.user_id = u.id
WHERE t.declined = 0 AND EXISTS (SELECT 1
							   FROM transactions t
                               WHERE t.user_id = u.id 
                               AND t.declined = 0
							   GROUP BY t.user_id
                               HAVING COUNT(t.id) > 80)
GROUP BY u.id,u.name, u.surname;
                        
-- Ejercicio 2
-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

SELECT cc.iban, ROUND(AVG(t.amount),2) AS media
FROM transactions t
JOIN credit_card cc ON t.card_id = cc.id
JOIN companies c ON c.company_id = t.business_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- Nivel 2
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones han sido declinadas 
-- entonces es inactivo, si al menos una no es rechazada entonces es activo . Partiendo de esta tabla responde:

-- 1) creamos la tabla estado_tarjetas para que refleje el estado de las tarjetas

DROP TABLE IF EXISTS estado_tarjetas;
CREATE TABLE IF NOT EXISTS estado_tarjetas (
	card_id VARCHAR(20) PRIMARY KEY,
    estado VARCHAR(20)
);

-- 2) cargamos la columna card_id de la tabla estado_tarjetas con todos los registros de la columna id de credit_card

INSERT INTO estado_tarjetas (card_id)
SELECT id FROM credit_card;

-- 3) creamos una columna temporal estado a partir de algunos calculos 

UPDATE estado_tarjetas et
JOIN (
    SELECT t1.card_id,
           CASE 
               WHEN SUM(t1.declined) = 3 THEN 'Inactiva'
               ELSE 'Activa'
           END AS nuevo_estado
    FROM transactions t1
    WHERE (
        SELECT COUNT(*) 
        FROM transactions t2
        WHERE t2.card_id = t1.card_id
          AND t2.timestamp > t1.timestamp
    ) < 3  
    GROUP BY t1.card_id
    ) AS ultimos3 
ON et.card_id = ultimos3.card_id
SET et.estado = ultimos3.nuevo_estado
WHERE et.card_id != '';

-- 4) relacionamos estado_tarjetas con transactions

ALTER TABLE transactions 
ADD CONSTRAINT et_transactions
FOREIGN KEY (card_id)
REFERENCES estado_tarjetas(card_id);


-- Ejercicio 1
-- ¿Cuántas tarjetas están activas?

SELECT COUNT(*)
FROM estado_tarjetas
WHERE estado = 'Activa';

-- Nivel 3
-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
-- teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:

-- 1) creamos la tabla products

DROP TABLE IF EXISTS products;
CREATE TABLE IF NOT EXISTS products (
	id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(30),
    price VARCHAR(10),
    colour VARCHAR(30),
    weight VARCHAR(10),
    warehouse_id VARCHAR(10)
);

-- 2) cargamos tabla products con el archivo csv proporcionado

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- 3) renombramos la tabla transactions para en un futuro borrar la original  que esta sin modificar

RENAME TABLE transactions TO transactions_backup;

-- 4) creamos una nueva tabla transactions para en un futuro sea la definitiva

DROP TABLE IF EXISTS transactions;
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(50),
    card_id VARCHAR(20), 
    business_id VARCHAR(50),
	timestamp TIMESTAMP,
	amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_id VARCHAR(20),
    user_id INT,
    lat VARCHAR(50),
    longitude VARCHAR(50),
	PRIMARY KEY (id, product_id), -- para solucionar el erro duplicate entry hacemos clave primaria compuesta (id, product_id)
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (product_id) REFERENCES products(id) -- aqui se relaciona products con transactions
); 

-- 5) cargamos la tabla con datos con casi todos los registros de transactions_backup, menos product_id, que la 
-- obtendremos con JSON

INSERT INTO transactions (
    id, card_id, business_id, timestamp, amount, declined, product_id, user_id, lat, longitude
)
SELECT 
    t.id,
    t.card_id,
    t.business_id,
    t.timestamp,
    t.amount,
    t.declined,
    CAST(j.value AS UNSIGNED) AS product_id,
    t.user_id,
    t.lat,
    t.longitude
FROM transactions_backup t
JOIN JSON_TABLE(
    CONCAT(
        '["', 
        REPLACE(t.product_ids, ',', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (value VARCHAR(50) PATH '$')
) AS j;


-- 6) eliminamos la tabla transactions_backup

DROP TABLE IF EXISTS transactions_backup;

-- Ejercicio 1
-- Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT product_id, COUNT(*) AS veces_vendidos
FROM transactions t
GROUP BY product_id;



