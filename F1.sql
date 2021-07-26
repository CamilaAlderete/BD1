-- @C:\SQL\F1.sql;

--CREAR USUARIO
connect system/admin;

--SI EXISTE USUARIO, ELIMINARLO
DROP USER camila CASCADE;

--CREAR USUARIO
CREATE USER camila IDENTIFIED BY admin DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users;

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
GRANT DESARROLLO TO camila;

disc system;

--------------------------------------------------

--CONECTAR USUARIO

CONN camila/admin;

CREATE TABLE DEPOSITO(
	ID_DEPOSITO NUMBER(6) NOT NULL,
	CONSTRAINT ID_DEPOSITO_PK PRIMARY KEY(ID_DEPOSITO)
);

CREATE TABLE UNIDAD_MEDIDA(
	ID_UNIDAD NUMBER(6) NOT NULL,
	DESCRIPCION_UNID VARCHAR2(60) NOT NULL,
	CONSTRAINT ID_UNIDAD_PK PRIMARY KEY(ID_UNIDAD)
);

CREATE TABLE MARCA(
	ID_MARCA NUMBER(6) NOT NULL,
	DESCRIPCION_MARCA VARCHAR2(60) NOT NULL,
	CONSTRAINT ID_MARCA_PK PRIMARY KEY(ID_MARCA)
);

CREATE TABLE LINEA(
	ID_LINEA NUMBER(6) NOT NULL,
	DESCRIPCION_LINEA VARCHAR2(60) NOT NULL,
	CONSTRAINT ID_LINEA_PK PRIMARY KEY(ID_LINEA)
);

CREATE TABLE PROVEEDOR(
	ID_PROVEEDOR NUMBER(6) NOT NULL,
	NOMBRE_PROVEEDOR VARCHAR2(60) NOT NULL,
	DIRECCION_PROVEEDOR VARCHAR2(60) NOT NULL,
	CONSTRAINT ID_PROVEEDOR_PK PRIMARY KEY(ID_PROVEEDOR)
);

CREATE TABLE REPUESTO(
	ID_REPUESTO VARCHAR2(60) NOT NULL,
	ID_UNIDAD NUMBER(6) NOT NULL,
	DESCIPCION_REPUESTO VARCHAR2(60) NOT NULL,
	EXENTA VARCHAR2(1),
	ID_MARCA NUMBER(6) NOT NULL,
	ID_LINEA NUMBER(6) NOT NULL,
	CONSTRAINT ID_REPUESTO_PK PRIMARY KEY(ID_REPUESTO),
	CONSTRAINT ID_UNIDAD_FK FOREIGN KEY(ID_UNIDAD) REFERENCES UNIDAD_MEDIDA(ID_UNIDAD),
	CONSTRAINT ID_MARCA_FK FOREIGN KEY(ID_MARCA) REFERENCES MARCA(ID_MARCA),
	CONSTRAINT ID_LINEA_FK FOREIGN KEY(ID_LINEA) REFERENCES LINEA(ID_LINEA)
);


CREATE TABLE REPUESTO_DEPOSITO(
	ID_DEPOSITO NUMBER(6) NOT NULL,
	ID_REPUESTO VARCHAR2(60) NOT NULL,
	UBICACION VARCHAR2(5),
	EXISTENCIA NUMBER(6),
	CONSTRAINT REPUESTO_DEPOSITO_PK PRIMARY KEY(ID_DEPOSITO,ID_REPUESTO),
	CONSTRAINT DEP_FK FOREIGN KEY(ID_DEPOSITO) REFERENCES DEPOSITO(ID_DEPOSITO),
	CONSTRAINT REP_FK FOREIGN KEY(ID_REPUESTO) REFERENCES REPUESTO(ID_REPUESTO)	
);

CREATE TABLE REPUESTO_PROVEEDOR(
	ID_PROVEEDOR NUMBER(6) NOT NULL,
	ID_REPUESTO VARCHAR2(60) NOT NULL,
	ULTIMO_PRECIO NUMBER(6),
	CONSTRAINT REPUESTO_PROVEEDOR_PK PRIMARY KEY(ID_PROVEEDOR,ID_REPUESTO),
	CONSTRAINT REPU_FK FOREIGN KEY(ID_REPUESTO) REFERENCES REPUESTO(ID_REPUESTO),
	CONSTRAINT PROV_FK FOREIGN KEY(ID_PROVEEDOR) REFERENCES PROVEEDOR(ID_PROVEEDOR)
);



--6
ALTER TABLE REPUESTO ADD PRECIO NUMBER(7);
ALTER TABLE REPUESTO MODIFY PRECIO DEFAULT 0;
ALTER TABLE REPUESTO ADD CONSTRAINT CHEK_PRECIO CHECK(PRECIO>=0) ;


--7
ALTER TABLE REPUESTO DROP CONSTRAINT ID_LINEA_FK;
ALTER TABLE REPUESTO DROP CONSTRAINT ID_MARCA_FK;

ALTER TABLE LINEA ADD ID_MARCA NUMBER(6);
ALTER TABLE LINEA DROP CONSTRAINT ID_LINEA_PK;
ALTER TABLE LINEA ADD PRIMARY KEY (ID_MARCA,ID_LINEA);

--8
ALTER TABLE REPUESTO_PROVEEDOR ADD FECHA DATE;
ALTER TABLE REPUESTO_PROVEEDOR ADD USUARIO VARCHAR2(100);
ALTER TABLE REPUESTO_PROVEEDOR MODIFY USUARIO DEFAULT USER;


--9
SELECT 
	repuesto_.ID_REPUESTO,
	repuesto_.DESCIPCION_REPUESTO,
	marca_.DESCRIPCION_MARCA,
	linea_.DESCRIPCION_LINEA,
	unidad_medida_.DESCRIPCION_UNID
FROM 
	REPUESTO repuesto_ JOIN MARCA marca_ ON 
	repuesto_.ID_MARCA = marca_.ID_MARCA
	JOIN LINEA linea_ ON repuesto_.ID_LINEA = linea_.ID_LINEA
	JOIN UNIDAD_MEDIDA unidad_medida_ ON repuesto_.ID_UNIDAD = unidad_medida_.ID_UNIDAD
WHERE (unidad_medida_.DESCRIPCION_UNID='centimetros') OR (unidad_medida_.DESCRIPCION_UNID='metros cuadrados'); 


--10
CREATE TABLE AUDITAREPUESTO(
	datos VARCHAR2(100)
);

create or replace trigger audita_repuesto_insercion
	after insert on REPUESTO
	for each row
	declare 
		cadena VARCHAR2(100);
	begin
		cadena:= TO_CHAR(sysdate)||', ' ||TO_CHAR(USER)||', '||'INSERCION';
		INSERT INTO AUDITAREPUESTO VALUES(cadena);	
	end audita_repuesto_insercion;
/	


create or replace trigger audita_repuesto_delete
	before delete on REPUESTO
	for each row
	declare 
		cadena VARCHAR2(100);
	begin
		cadena:= TO_CHAR(sysdate)||', ' ||TO_CHAR(USER)||', '||'BORRADO';
		INSERT INTO AUDITAREPUESTO VALUES(cadena);
	end audita_repuesto_delete;
/	

ALTER SESSION SET NLS_DATE_FORMAT= 'DD/MM/YYYY HH24:MI:SS';

COMMIT;