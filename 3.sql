--COOPERATIVA

-- @C:\SQL\3.sql;

--CREAR USUARIO
connect system/admin;

--SI EXISTE USUARIO, ELIMINARLO
DROP USER alfa CASCADE;

--CREAR USUARIO
CREATE USER alfa IDENTIFIED BY admin DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users;

--CREAR ROL 
DROP ROLE DESARROLLO;
CREATE ROLE DESARROLLO;

--CONCEDER PERMISOS
GRANT CREATE SESSION,
CREATE TABLE,
CREATE SEQUENCE,
CREATE ANY INDEX,
CREATE VIEW, 
CREATE TRIGGER TO DESARROLLO;

--ASIGNAR PERMISOS A ROL
GRANT DESARROLLO TO alfa;

disc system;

clear screen;
--------------------------------------------------
CONN alfa/admin;

ALTER SESSION SET NLS_DATE_FORMAT= 'DDMM-YYYY';


CREATE TABLE SOCIOS(
	NRO_SOCIO NUMBER(4),
	NOMBRE VARCHAR2(30) NOT NULL,
	APELLIDO VARCHAR2(30) NOT NULL,
	CI NUMBER(7) NOT NULL,
	EDAD NUMBER(2) NOT NULL,
	NRO_SOCIO_PROPONENTE NUMBER(4),
	CONSTRAINT NRO_SOCIO_PK PRIMARY KEY(NRO_SOCIO),
	CONSTRAINT NRO_SOCIO_PROPONENTE_FK FOREIGN KEY(NRO_SOCIO_PROPONENTE) REFERENCES SOCIOS(NRO_SOCIO),
	CONSTRAINT CHECK_EDAD CHECK(EDAD>18),
	CONSTRAINT UNIQUE_CI UNIQUE(CI),
	CONSTRAINT CHECK_SOCIO_PROP CHECK(NRO_SOCIO<>NRO_SOCIO_PROPONENTE)
);

CREATE SEQUENCE SEQ_NRO_SOCIO START WITH 1 INCREMENT BY 1;

-- socio nro 1 dummy para tener un primer proponente 
-- INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
-- VALUES(SEQ_NRO_SOCIO.NEXTVAL,'DUMMY_NAME','DUMMY_LASTNAME',0000000,99,NULL);

INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
VALUES(SEQ_NRO_SOCIO.NEXTVAL,'Lily','Chen',4388521,24,NULL);

INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
VALUES(SEQ_NRO_SOCIO.NEXTVAL,'Marcelo','Capdepont',3098221,40,1);

INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
VALUES(SEQ_NRO_SOCIO.NEXTVAL,'Noelia','Sarubbi',1889723,55,2);

INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
VALUES(SEQ_NRO_SOCIO.NEXTVAL,'Montserrat','Rapennecker',4002341,30,3);

INSERT INTO SOCIOS(NRO_SOCIO,NOMBRE,APELLIDO,CI,EDAD,NRO_SOCIO_PROPONENTE)
VALUES(SEQ_NRO_SOCIO.NEXTVAL,'Ignacio','Gonzalez',4098287,28,4);

COMMIT;


CREATE TABLE PRESTAMOS(
	NRO_PRESTAMO NUMBER(7),
	NRO_SOCIO NUMBER(4),
	FECHA DATE NOT NULL,
	TASA NUMBER(2,1) NOT NULL,
	MONTO NUMBER(9) NOT NULL,
	SALDO NUMBER(9) NOT NULL,
	CONSTRAINT NRO_PRESTAMO_PK PRIMARY KEY(NRO_PRESTAMO),
	CONSTRAINT NRO_SOCIO_FK FOREIGN KEY(NRO_SOCIO) REFERENCES SOCIOS(NRO_SOCIO),
	CONSTRAINT CHECK_MONTO CHECK(MONTO>0)
);

CREATE SEQUENCE SEQ_NRO_PRESTAMO START WITH 1 INCREMENT BY 1;

INSERT INTO PRESTAMOS(NRO_PRESTAMO,NRO_SOCIO,FECHA,TASA,MONTO,SALDO)
VALUES(SEQ_NRO_PRESTAMO.NEXTVAL,2,'2010-2019',3,1000000,1000000);


INSERT INTO PRESTAMOS(NRO_PRESTAMO,NRO_SOCIO,FECHA,TASA,MONTO,SALDO)
VALUES(SEQ_NRO_PRESTAMO.NEXTVAL,2,'1005-2020',2,200000,200000);

INSERT INTO PRESTAMOS(NRO_PRESTAMO,NRO_SOCIO,FECHA,TASA,MONTO,SALDO)
VALUES(SEQ_NRO_PRESTAMO.NEXTVAL,1,'0304-2017',5,10000000,10000000);


INSERT INTO PRESTAMOS(NRO_PRESTAMO,NRO_SOCIO,FECHA,TASA,MONTO,SALDO)
VALUES(SEQ_NRO_PRESTAMO.NEXTVAL,3,'1008-2017',3,1000000,1000000);

INSERT INTO PRESTAMOS(NRO_PRESTAMO,NRO_SOCIO,FECHA,TASA,MONTO,SALDO)
VALUES(SEQ_NRO_PRESTAMO.NEXTVAL,4,'0606-2020',2,10000000,10000000);


COMMIT;


CREATE TABLE CUOTAS(
	NRO_CUOTA NUMBER(10) DEFAULT 1,
	NRO_PRESTAMO NUMBER(7),
	FECHA_VENCIMIENTO DATE NOT NULL,
	FECHA_PAGO DATE,
	IMPORTE NUMBER(9),
	CONSTRAINT NRO_PRESTAMO_FK FOREIGN KEY(NRO_PRESTAMO) REFERENCES PRESTAMOS(NRO_PRESTAMO),
	CONSTRAINT CHECK_IMPORTE CHECK(IMPORTE>0)
);

/*
2. Se tiene como política que toda cuota puede ser pagada hasta el día del vencimiento. 
Para verificar esto, cree un Trigger que debe impedir la actualización de la fecha de 
pago en la tabla Cuota si la fecha de pago es mayor que la fecha de vencimiento de la 
cuota, emitiendo un mensaje de alerta y, si la fecha corresponde actualice el saldo en 
la tabla préstamo
*/

CREATE OR REPLACE TRIGGER PAGO_COUTA
	BEFORE UPDATE OF FECHA_PAGO ON CUOTAS
	FOR EACH ROW
	BEGIN
		IF(:NEW.FECHA_PAGO > :OLD.FECHA_VENCIMIENTO) THEN
			RAISE_APPLICATION_ERROR(-20000,'Cuota vencida, acerquese a su cooperativa');
		ELSE
			UPDATE PRESTAMOS SET SALDO= SALDO- :NEW.IMPORTE
			WHERE NRO_PRESTAMO = :NEW.NRO_PRESTAMO;
		END IF;
END PAGO_COUTA;
/



-- cuotas a pagar... 
-- CUOTAS DEL PRESTAMO 1
INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(1,1,SYSDATE,NULL,50000);

INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(2,1,ADD_MONTHS(SYSDATE,1),NULL,50000);


--CUOTAS DEL PRESTAMO 2
INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(1,2,SYSDATE,NULL,150000);

INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(2,2,ADD_MONTHS(SYSDATE,1),NULL,150000);

--cuotas de prestamo 3
INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(1,3,SYSDATE,NULL,300000);

INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(2,3,ADD_MONTHS(SYSDATE,1),NULL,300000);


--cuotas de prestamo 4
INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(1,4,SYSDATE,NULL,80000);

INSERT INTO CUOTAS(NRO_CUOTA,NRO_PRESTAMO,FECHA_VENCIMIENTO,FECHA_PAGO,IMPORTE)
VALUES(2,4,ADD_MONTHS(SYSDATE,1),NULL,80000);




--PAGANDO CUOTAS
--pagando cuota el dia del vencimiento
UPDATE CUOTAS SET FECHA_PAGO=SYSDATE WHERE NRO_PRESTAMO=1 AND NRO_CUOTA=1; 


--pagando cuota pasado el vencimiento
UPDATE CUOTAS SET FECHA_PAGO=SYSDATE+1 WHERE NRO_PRESTAMO=2 AND NRO_CUOTA=1; 


UPDATE CUOTAS SET FECHA_PAGO=SYSDATE WHERE NRO_PRESTAMO=3 AND NRO_CUOTA=1; 


UPDATE CUOTAS SET FECHA_PAGO=SYSDATE WHERE NRO_PRESTAMO=4 AND NRO_CUOTA=1; 

COMMIT;

--clear screen;

/*
4. Crear una vista llamada “Vista_Socios” en la que se nos muestre los nrosocio, nombres + apellidos,
CI, monto total de préstamos obtenidos (Total_Prestamo_Obtenido), monto total de préstamos
cancelados hasta la fecha (Total_Prestamo_Cancelado) y, los apellidos + nombres del Socio
Proponente. Debe estar ordenado ascendentemente por número de socios
*/

--SIN PROBLEMAS CON EL PRIMER SOCIO CON PROPONENTE NULL
CREATE VIEW VISTA_SOCIO 
	(NRO_SOCIO,NOMBRE,CI,TOTAL_PRESTAMO_OBTENIDO,TOTAL_PRESTAMO_CANCELADO,NOMBRE_PROPONENTE)
AS 
	SELECT 
		socio.NRO_SOCIO, 
		socio.NOMBRE ||' '|| socio.APELLIDO, 
		socio.CI,
		(SELECT SUM( MONTO ) FROM PRESTAMOS WHERE NRO_SOCIO = socio.NRO_SOCIO ),
		(SELECT SUM( MONTO - SALDO ) FROM PRESTAMOS WHERE NRO_SOCIO = socio.NRO_SOCIO),
		proponente.NOMBRE||' '||proponente.APELLIDO
	FROM SOCIOS socio LEFT JOIN SOCIOS proponente
	ON proponente.NRO_SOCIO = socio.NRO_SOCIO_PROPONENTE
	ORDER BY NRO_SOCIO ASC;

SELECT * FROM VISTA_SOCIO;


/* 5. Listar todos los socios entre 25 y 30 años. Muestre ci, nombres, apellidos, edad*/
CREATE VIEW ENTRE_25_30(CI, NOMBRE, APELLIDO, EDAD )
AS
SELECT  CI, NOMBRE, APELLIDO, EDAD 
FROM SOCIOS 
WHERE EDAD BETWEEN 25 AND 30;

SELECT * FROM ENTRE_25_30; 

/* 6. Cuál/es es/son el/los número/s de préstamo/s de mayor monto y, a que socio/s corresponde/n
(Listar norprestamo, nrosocio, ci, nombres, apellidos del socio y apellidos + nombres del Socio
Proponente)
*/
CREATE VIEW MAYORES_PRESTAMOS(NRO_PRESTAMO,MONTO,NRO_SOCIO,CI,NOMBRE, NOMBRE_PROPONENTE)
AS
	SELECT 
		prestamo.NRO_PRESTAMO, 
		prestamo.MONTO, 
		socio.NRO_SOCIO,
		socio.CI,
		socio.NOMBRE||' '||socio.APELLIDO,
		proponente.NOMBRE||' '||proponente.APELLIDO
	FROM PRESTAMOS prestamo, SOCIOS socio LEFT JOIN SOCIOS proponente
	ON proponente.NRO_SOCIO = socio.NRO_SOCIO_PROPONENTE
	WHERE prestamo.MONTO = (SELECT MAX(MONTO) FROM PRESTAMOS) 
	AND prestamo.NRO_SOCIO=socio.NRO_SOCIO;
    
SELECT * FROM MAYORES_PRESTAMOS;

COMMIT;

set serveroutput on format wrapped;
begin
    DBMS_OUTPUT.put_line('PARA LA MAYORIA DE LOS ENUNCIADOS SE CREARON VISTAS, PARA COMPROBAR LOS RESULTADOS CON MAS FACILIDAD ...');
end;
/