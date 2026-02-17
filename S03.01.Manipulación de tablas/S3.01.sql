-- Nivel 1
-- Ejercicio 1
  -- Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar de 
  -- forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la 
  -- información del documento denominado "datos_introducir_credit". Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

USE transactions;

DROP TABLE IF EXISTS credit_card ;

CREATE TABLE credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(40),
    pan VARCHAR(20),
    pin CHAR(4),
    cvv CHAR(3),
    expiring_date VARCHAR(10)
);

-- seleccionamos la informacion de la base de datos "datos_introducir_credit" y lo corremos. 

SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE transaction
ADD CONSTRAINT cc_transaction
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- Ejercicio 2
  -- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. La información que debe 
  -- mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
  
UPDATE credit_card 
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT iban
FROM credit_card
WHERE id = 'CcU-2938';

-- Ejercicio 3
  -- En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
  -- Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
  -- credit_card_id	CcU-9999
  -- company_id	b-9999
  -- user_id	9999
  -- lat	829.999
  -- longitude	-117.999
  -- amount	111.11
  -- declined	0
  
INSERT INTO credit_card (id)   
VALUES ('CcU-9999');

INSERT INTO company (id)   
VALUES ('b-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Ejercicio 4
-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

ALTER TABLE credit_card
DROP COLUMN pan; 

SELECT *
FROM credit_card;

-- Nivel 2
-- Ejercicio 1
-- Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE FROM transaction 
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Ejercicio 2
-- La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
-- Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
-- Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía. 
-- Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
-- Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name AS nombre_compania, 
       c.phone AS telefono_contacto, 
       c.country AS pais_residencia, 
       AVG(t.amount) AS media_compra
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY c.id, c.company_name
ORDER BY media_compra DESC;

SELECT * 
FROM VistaMarketing;

-- Ejercicio 3
-- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT *
FROM VistaMarketing
WHERE pais_residencia = 'Germany';

-- Nivel 3
-- Ejercicio 1
-- La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones en la base de datos, 
-- pero no recuerda cómo las realizó. Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:

-- 1) creamos tabla user y cargamos base de datos a user.

DROP TABLE IF EXISTS user;
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
); 

-- 2) corregimos datos distintos en este caso user.id CHAR lo cambiamos a INT como figura en la imagen asi queda igual a la tabla transaction.
ALTER TABLE user
MODIFY COLUMN id INT;

-- 3) renombramos la columna email por personal_email
ALTER TABLE user
RENAME COLUMN email TO personal_email; 

-- 4) cambiamos el nombre de la tabla a data_user
RENAME TABLE user TO data_user;

-- 5) eliminamos la columna website
ALTER TABLE company
DROP COLUMN website; 

-- 6) en transaction cambiamos la longitud de los datos credit_card_id de 15 a 20.
ALTER TABLE transaction
MODIFY COLUMN credit_card_id VARCHAR(20);

-- 7) en credit_card cambiamos la longitud de los datos id a VARCHAR(20), iban a VARCHAR(50), 
-- cambiamos el cvv a INT y por ultimo expiring_date VARCHAR(20).  
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20),
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN cvv INT,
MODIFY COLUMN expiring_date VARCHAR(20);

-- 8) añadimos columna fecha_actual DATE
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- 9) agregamos dato huerfano en tabla data_user

INSERT INTO data_user (id)
VALUES (9999);

-- 10) relacionamos tablas data_user y transaction
ALTER TABLE transaction
ADD CONSTRAINT user_transaction
FOREIGN KEY (user_id)
REFERENCES data_user(id);

-- Ejercicio 2
-- La empresa también le pide crear una vista llamada "InformeTecnico" que contenga la siguiente información:

-- ID de la transacción
-- Nombre del usuario/a
-- Apellido del usuario/a
-- IBAN de la tarjeta de crédito usada.
-- Nombre de la compañía de la transacción realizada.
-- Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.

-- Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.
DROP VIEW IF EXISTS InformeTecnico;
CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaccion, 
       u.name AS nombre_usuario, 
       u.surname AS apellido_usuario, 
       c.company_name AS nombre_compania, 
       cc.iban AS iban
FROM company c 
JOIN transaction t ON c.id = t.company_id
JOIN data_user u ON t.user_id = u.id
JOIN credit_card cc ON cc.id = t.credit_card_id
ORDER BY t.id DESC;

SELECT *
FROM InformeTecnico;




