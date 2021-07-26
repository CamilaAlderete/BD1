-- @C:\SQL\2P.sql;

--1 Coneccion
CONN system/admin;

--2 Creacion de usuario
DROP USER edgar CASCADE;
CREATE USER edgar IDENTIFIED BY admin DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users;

--3 Asignar permisos al usuario
GRANT CREATE ANY INDEX, CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE VIEW TO edgar;

--4 Coneccion del usuario
CONN edgar/admin;

--5 Estructura y Restricciones para tabla Persona:
CREATE TABLE persona(
	nropersona integer NOT NULL,
	ci integer NOT NULL,
	nombres varchar2(30) NOT NULL,
	apellidos varchar2(30) NOT NULL,
	edad integer NOT NULL,
	sexo char(1) NOT NULL,
	direccion varchar2(30) NOT NULL,
	telefono varchar2(20) NOT NULL,
	CONSTRAINT pkp PRIMARY KEY(nropersona),
	CONSTRAINT unico_ci UNIQUE (ci),
	CONSTRAINT chk_mayor_edad CHECK(edad >= 18), 
	CONSTRAINT chk_sexo CHECK(sexo in('M','F'))
);

-- Secuencia autonumerica para la tabla Persona:
CREATE SEQUENCE seq_persona
	START WITH 1
	INCREMENT BY 1;

-- Estructura y Restricciones para tabla Cliente:
CREATE TABLE cliente(
	nrocliente integer NOT NULL,
	nropersona integer NOT NULL UNIQUE,
	fechaingreso date NOT NULL,
	deudatotal integer DEFAULT 0 NOT NULL ,
	CONSTRAINT pkc PRIMARY KEY(nrocliente),
	CONSTRAINT FKP FOREIGN KEY(nropersona) REFERENCES persona(nropersona)
);

-- Secuencia autonumerica para la tabla cliente:
CREATE SEQUENCE seq_cliente
	START WITH 1
	INCREMENT BY 1;

-- Estructura y Restricciones para Tabla Prestamo:
CREATE TABLE prestamo(
	nroprestamo integer NOT NULL,
	nrocliente integer NOT NULL,
	fecha date NOT NULL,
	tasa number(2,1) NOT NULL,
	garante1 integer NULL,
	garante2 integer NULL,
	monto integer NOT NULL,
	saldo integer NOT NULL,
	CONSTRAINT pkpr PRIMARY KEY(nroprestamo),
	CONSTRAINT fkpc FOREIGN KEY(nrocliente) REFERENCES cliente(nrocliente),
	CONSTRAINT fkpg1 FOREIGN KEY(garante1) REFERENCES persona(nropersona),
	CONSTRAINT fkpg2 FOREIGN KEY(garante2) REFERENCES persona(nropersona),
	CONSTRAINT chk_monto CHECK(monto > 0),
	CONSTRAINT chk_saldo CHECK(monto >= 0), 
	CONSTRAINT chk_g1g2 CHECK(garante1 < > garante2)
);

-- Secuencia autonumerica para la tabla Prestamo:
CREATE SEQUENCE seq_prestamo
	START WITH 1
	INCREMENT BY 1;

--6 Trigger para acutalizar deuda del cliente
CREATE OR REPLACE TRIGGER actualizar_deuda_cliente
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
  UPDATE cliente SET deudatotal = deudatotal + :new.monto WHERE nrocliente = :new.nrocliente;
END actualizar_deuda_cliente;
/


--7 Insercion de Datos en las tablas:
-- Cambiamos formato de fecha:
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy';

set lines 400

-- Insercion en tabla Personas
INSERT INTO persona VALUES(seq_persona.NEXTVAL,1111,'Luis','Acosta Fretes',55, 'M', 'Mcal Lopez 370', '021223456');
INSERT INTO persona VALUES(seq_persona.NEXTVAL,2222,'Pedro','Rivaldi',59,'M', 'Paraiso 899', '0982234443' );
INSERT INTO persona VALUES(seq_persona.NEXTVAL,3333,'Laura','Diaz de Vivar',60, 'F', 'Eusebio Ayala 345', '097233444');
INSERT INTO persona VALUES(seq_persona.NEXTVAL,4444,'Leticia','Perez Escobar',53, 'F', 'Carapegua', '0985467899');
INSERT INTO persona VALUES(seq_persona.NEXTVAL,5555,'Lucia','Perez Oviedo',29, 'F', 'Carapegua', '0985467888');
INSERT INTO persona VALUES(seq_persona.NEXTVAL,6666,'Ruben','Romero Roa',22, 'F', 'San Lorenzo', '0971225668');

-- Insercion en tabla cliente
INSERT INTO cliente(nrocliente, nropersona, fechaingreso) VALUES(seq_cliente.NEXTVAL, 1, '01/02/2020');
INSERT INTO cliente(nrocliente, nropersona, fechaingreso) VALUES(seq_cliente.NEXTVAL, 2, '05/02/2020');
INSERT INTO cliente(nrocliente, nropersona, fechaingreso) VALUES(seq_cliente.NEXTVAL, 3, '10/02/2020');
INSERT INTO cliente(nrocliente, nropersona, fechaingreso) VALUES(seq_cliente.NEXTVAL, 4, '12/02/2020');
INSERT INTO cliente(nrocliente, nropersona, fechaingreso) VALUES(seq_cliente.NEXTVAL, 5, '15/02/2020');

-- Insercion en tabla Prestamo
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 5, '01/03/2020', 1.2, 3, 4, 1000000, 1000000);
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 3, '01/04/2020', 1.2, 1, 5, 500, 500);
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 3, '05/04/2020', 1.2, 5, 4, 100000, 100000);
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 1, '05/04/2020', 1.2, NULL, NULL, 300000,300000);
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 4, '10/05/2020', 1.2, 3, NULL, 100000, 100000);
INSERT INTO prestamo VALUES (seq_prestamo.NEXTVAL, 2, '12/05/2020', 1.2, 4, 5, 1000000, 1000000);

COMMIT;

--8 Creacion de Vista:
CREATE OR REPLACE VIEW vista_edgar 
(Nro_Prestamo, Fecha_Prestamo, Nro_Cliente, Cliente, CI, Monto_Prestamo, Saldo_Prestamo, Garante1, Garante2) as 
SELECT
pr.nroprestamo,
pr.fecha,
pr.nrocliente,
pc.nombres || ' ' || pc.apellidos,
pc.ci, 
pr.monto, 
pr.saldo,
pg1.nombres || ' ' || pg1.apellidos,
pg2.nombres || ' ' || pg2.apellidos
FROM prestamo pr 
JOIN cliente cl ON pr.nrocliente = cl.nrocliente
JOIN persona pc ON pc.nropersona = cl.nropersona
LEFT JOIN persona pg1 ON pg1.nropersona = pr.garante1
LEFT JOIN persona pg2 ON pg2.nropersona = pr.garante2
ORDER BY pr.nrocliente desc, pr.fecha desc;

SELECT * FROM vista_edgar;

--9 Listar clientes:
SELECT c.nrocliente, c.nropersona, p.ci, p.nombres, p.apellidos, p.edad, c.deudatotal
FROM cliente c
JOIN persona p ON c.nropersona = p.nropersona
WHERE c.deudatotal >= 10000 AND (p.edad BETWEEN 50 AND 60);


--10  Monto mayor de Prestamo y a que cliente corresponde:
SELECT pr.nroprestamo, pr.nrocliente, per.nombres, per.apellidos, pr.monto
FROM prestamo pr
JOIN cliente cl ON pr.nrocliente = cl.nrocliente
JOIN persona per ON cl.nrocliente = per.nropersona
WHERE pr.monto = (SELECT MAX(monto) FROM prestamo); 

DISC;