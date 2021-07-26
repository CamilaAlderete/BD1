-- @C:\SQL\4.sql;

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

--CONECTAR USUARIO

CONN alfa/admin;

ALTER SESSION SET NLS_DATE_FORMAT= 'DD/MM/YYYY';

-- El campo CI de la tabla alumno debe ser único, no debe admitir duplicaciones. (0,25p)

CREATE TABLE ALUMNO(
	CODIGO NUMBER(12),
	CI VARCHAR2(20) NOT NULL,
	PRIMER_NOMBRE VARCHAR2(20) NOT NULL,
	SEGUNDO_NOMBRE VARCHAR2(20),
	PRIMER_APELLIDO VARCHAR2(20) NOT NULL,
	SEGUNDO_APELLIDO VARCHAR2(20),
	FECHA_NACIMIENTO DATE NOT NULL,
	TELEFONO VARCHAR2(15) NOT NULL,
	DIRECCION VARCHAR2(150) NOT NULL,
	EMAIL VARCHAR2(50),
	ESTADO CHAR(1) NOT NULL,
	CONSTRAINT CODIGO_ALUMNO_PK PRIMARY KEY(CODIGO),
	CONSTRAINT UNIQUE_CI UNIQUE(CI),
	CONSTRAINT CHECK_ESTADO_ALUMNO CHECK( ESTADO IN('A','I'))
);

-- Ampliar la capacidad del campo dirección de la tabla alumno a 200 caracteres. (0,25p)
ALTER TABLE ALUMNO MODIFY DIRECCION VARCHAR2(200);

CREATE SEQUENCE SEQ_ALUMNO START WITH 1 INCREMENT BY 1;

CREATE TABLE CARRERA(
	CODIGO NUMBER(8),
	NOMBRE VARCHAR2(50) NOT NULL,
	FECHA_CREACION DATE NOT NULL,
	NUM_RESOLUCION VARCHAR2(20) NOT NULL,
	DURACION NUMBER(4) NOT NULL,
	ES_ACREDITADA CHAR(1) NOT NULL,
	ESTADO CHAR(1) NOT NULL,
	CONSTRAINT CODIGO_CARRERA_PK PRIMARY KEY(CODIGO),
	CONSTRAINT CHECK_ACREDITACION CHECK(ES_ACREDITADA IN('S','N')),
	CONSTRAINT CHECK_ESTADO_CARRERA CHECK( ESTADO IN ('A','C')),
	CONSTRAINT UNIQUE_NOMBRE_CARRERA UNIQUE(NOMBRE),
	CONSTRAINT CHECK_DURACION_CARRERA CHECK( DURACION>0) 
);

--- El campo 'Es_acreditada' de la tabla Carrera sólo puede tomar los valores S o N y debe
--asumir por defecto N. (0,25p)
ALTER TABLE CARRERA MODIFY ES_ACREDITADA DEFAULT 'N';

CREATE SEQUENCE SEQ_CARRERA START WITH 1 INCREMENT BY 1;

CREATE TABLE ALUMNO_CARRERA(
	COD_ALUMNO NUMBER(12) NOT NULL,
	COD_CARRERA NUMBER(8),
	FECHA_INGRESO DATE NOT NULL,
	FECHA_EGRESO DATE,
	ESTADO CHAR(1) NOT NULL,
	CONSTRAINT COD_ALUMNO_CARRERA_PK PRIMARY KEY(COD_ALUMNO, COD_CARRERA),
	CONSTRAINT COD_ALUMNO_ALU_CARR_FK FOREIGN KEY(COD_ALUMNO) REFERENCES ALUMNO(CODIGO),
	CONSTRAINT COD_CARRERA_ALU_CARR_FK FOREIGN KEY (COD_CARRERA) REFERENCES CARRERA(CODIGO),
	CONSTRAINT CHECK_ESTADO_ALUMNO_CARRERA CHECK( ESTADO IN ('T','A','X','C'))
);


CREATE TABLE MATERIA(
	CODIGO NUMBER(8) NOT NULL,
	NOMBRE VARCHAR2(50) NOT NULL,
	CONSTRAINT CODIGO_MATERIA_PK PRIMARY KEY(CODIGO),
	CONSTRAINT UNIQUE_NOMBRE_MATERIA UNIQUE(NOMBRE)
);

CREATE SEQUENCE SEQ_MATERIA START WITH 1 INCREMENT BY 1;


-- Tabla Carrera_Materia, la columna costo debe ser mayor a cero.
CREATE TABLE CARRERA_MATERIA(
	COD_MATERIA NUMBER(8) NOT NULL,
	COD_CARRERA NUMBER(8) NOT NULL,
	SEMESTRE NUMBER(2) NOT NULL,
	COSTO NUMBER(10) NOT NULL,
	CONSTRAINT MATERIA_CARRERA_PK PRIMARY KEY(COD_MATERIA,COD_CARRERA),
	CONSTRAINT COD_MATERIA_CARR_MAT_FK FOREIGN KEY(COD_MATERIA) REFERENCES MATERIA(CODIGO),
	CONSTRAINT COD_CARRERA_CARR_MAT_FK FOREIGN KEY(COD_CARRERA) REFERENCES CARRERA(CODIGO),
	CONSTRAINT CHECK_COSTO_CARR_MAT CHECK(COSTO > 0),
	CONSTRAINT CHECK_SEMESTRE_CARR_MAT CHECK(SEMESTRE BETWEEN 1 AND 10)
);




-- El campo calificación de la tabla matriculación sólo puede tomar valores que estén entre
-- 0 y 5. (0,25p)
CREATE TABLE MATRICULACION(
	COD_ALUMNO NUMBER(12) NOT NULL,
	COD_MATERIA NUMBER(8) NOT NULL,
	ANHO NUMBER(4) NOT NULL,
	NUM_SEMESTRE NUMBER(3) NOT NULL,
	FECHA_MATRIC DATE NOT NULL,
	CALIFICACION INTEGER NOT NULL,
	SITUACION CHAR(1) NOT NULL,
	CONSTRAINT COD_MATRICULACION_PK PRIMARY KEY(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE),
	CONSTRAINT CHECK_ANHO CHECK(ANHO>0),
	CONSTRAINT CHECK_NUM_SEMESTRE CHECK(NUM_SEMESTRE IN (1,2)),
	--CONSTRAINT CHECK_CALIFICACION CHECK(CALIFICACION BETWEEN 0 AND 5),
	CONSTRAINT CHECK_CALIFICACION CHECK(CALIFICACION IN (0,1,2,3,4,5)),
	CONSTRAINT CHECK_SITUACION CHECK(SITUACION IN ('C','X','A')),
	CONSTRAINT COD_ALUMNO_MATRIC_FK FOREIGN KEY(COD_ALUMNO) REFERENCES ALUMNO(CODIGO),
	CONSTRAINT COD_MATERIA_MATRIC_FK FOREIGN KEY(COD_MATERIA) REFERENCES MATERIA(CODIGO)
);


--Tabla Matriculación: Agregue el campo calificación cuyo tipo de dato es Int, no debe
--admitir valores nulos y asumir por defecto el valor 0. (0,5p)
ALTER TABLE MATRICULACION MODIFY CALIFICACION DEFAULT 0;
--Al insertar registros en la tabla matriculación, la columna ‘fecha_matric’ debe asumir por
--defecto la fecha del sistema. (0,25p)
ALTER TABLE MATRICULACION MODIFY FECHA_MATRIC DEFAULT SYSDATE;



INSERT INTO CARRERA(CODIGO, NOMBRE,FECHA_CREACION,NUM_RESOLUCION,DURACION,ES_ACREDITADA,ESTADO)
VALUES(SEQ_CARRERA.NEXTVAL, 'TECNICO SUPERIOR EN ELECTRONICA','20/12/2016','001-00-2016',4,'N','A');

INSERT INTO CARRERA(CODIGO,NOMBRE,FECHA_CREACION,NUM_RESOLUCION,DURACION,ES_ACREDITADA,ESTADO)
VALUES(SEQ_CARRERA.NEXTVAL,'PROGRAMACION DE COMPUTADORAS','03/09/2012','033-22-2012',4,'S','A');

INSERT INTO CARRERA(CODIGO,NOMBRE,FECHA_CREACION,NUM_RESOLUCION,DURACION,ES_ACREDITADA,ESTADO)
VALUES(SEQ_CARRERA.NEXTVAL,'TECNICO SUPERIOR EN ELECTRICIDAD','15/12/2017','001-00-2016',4,'N','A');

--INSERT INTO CARRERA(CODIGO,NOMBRE,FECHA_CREACION,NUM_RESOLUCION,DURACION,ES_ACREDITADA,ESTADO)
--VALUES(SEQ_CARRERA.NEXTVAL,'ING. EN INFORMATICA','20/04/2018','011-03-2014',8,'S','A');

---MATERIAS DE LA CARRERA TSE
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'GEOMETRIA ANALITICA Y VECTORES');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGEBRA ');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA MECANICA ');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'DIBUJO I');
--SEMESTRE I TSE
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (1,1,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (2,1,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (3,1,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (4,1,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (5,1,1,20000);

---MATERIAS DE LA CARRERA TSE
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA ELECTRICIDAD');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA ONDAS');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'DIBUJO II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'QUIMICA');

--SEMESTRE II TSE
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (6,1,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (7,1,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (8,1,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (9,1,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (10,1,2,20000);


---MATERIAS DE LA CARRERA TSE
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO III');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTRONICA I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'SISTEMAS DIGITALES');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'MECANICA CLASICA');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'MICROPROCESADOR I');

--SEMESTRE III TSE
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (11,1,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (12,1,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (13,1,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (14,1,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (15,1,3,20000);


---MATERIAS DE LA CARRERA TSE
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTROMAGNETISMO');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTRONICA APLICADA');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'TALLER');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'PROGRAMACION');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'MICROPROCESADOR II');

--SEMESTRE IV TSE
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (16,1,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (17,1,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (18,1,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (19,1,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (20,1,4,20000);

--ALUMNOS DE TSE

INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'4652321','SAMUEL',NULL,'SOSA','PEREIRA','01/05/1995','021523124','AVIADORES Y ESPAÑA',NULL,'A');
INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'3745658','ANA','LAURA','GOMEZ','SOLIS','05/07/1994','0985632142','CHILE Y OLIVA','ANALIA@GMAIL.COM','A');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(1,1,'25/01/2017',NULL,'C');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(2,1,'22/01/2018',NULL,'C');

--MATRICULACION DE LOS ALUMNOS DEL TSE

-- ALUMNO 1 SEMESTRE 1  TSE
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,1,2017,1,'02/02/2017',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,2,2017,1,'02/02/2017',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,3,2017,1,'03/02/2017',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,4,2017,1,'03/02/2017',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,5,2017,1,'04/02/2017',0,'A');

-- ALUMNO 1 SEMESTRE 2  TSE
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,6,2017,2,'02/07/2017',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,7,2017,2,'02/07/2017',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,8,2017,2,'03/07/2017',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,10,2017,2,'03/07/2017',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,5,2017,2,'03/07/2017',3,'C');

-- ALUMNO 1 SEMESTRE 3  TSE
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,9,2018,1,'01/02/2018',1,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,11,2018,1,'02/02/2018',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,12,2018,1,'02/02/2018',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,13,2018,1,'02/02/2018',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,14,2018,1,'05/02/2018',4,'C');

--ALUMNO 1 SEMESTRE 4 TSE

INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,9,2018,2,'01/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,16,2018,2,'02/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,17,2018,2,'02/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,18,2018,2,'02/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,19,2018,2,'05/07/2018',0,'C');


-- ALUMNO 2 SEMESTRE 1  TSE
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,1,2018,1,'02/02/2018',1,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,2,2018,1,'02/02/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,3,2018,1,'03/02/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,4,2018,1,'03/02/2018',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,5,2018,1,'04/02/2018',1,'C');

-- ALUMNO 2 SEMESTRE 2  TSE
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,1,2018,2,'02/07/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,5,2018,2,'02/07/2018',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,8,2018,2,'03/07/2018',0,'X');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(2,10,2018,2,'03/07/2018',0,'X');


-------------------------------------------------------------------------------------------------
---MATERIAS DE LA CARRERA PC
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGORTIMICA I');
--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'GEOMETRIA ANALITICA Y VECTORES');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'LOGICA MATEMATICA');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'INFORMATICA');
--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA ELECTRICIDAD');
--SEMESTRE I PC
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (21,2,1,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (2,2,1,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (22,2,1,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (23,2,1,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (7,2,1,25000);

---MATERIAS DE LA CARRERA PC
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGORIMITCA II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO INTEGRAL');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ESTRUCTURA DE DATOS');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'REDES I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'E-COMMERCE');

--SEMESTRE II  PC
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (24,2,2,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (25,2,2,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (26,2,2,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (27,2,2,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (28,2,2,25000);

---MATERIAS DE LA CARRERA PC
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'BASE DE DATOS I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'REDES II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'COMPILADORES');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'PROGRAMACION WEB I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO VECTORIAL');

--SEMESTRE III PC
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (29,2,3,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (30,2,3,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (31,2,3,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (32,2,3,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (33,2,3,25000);

---MATERIAS DE LA CARRERA PC
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'BASE DE DATOS II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'PROGRAMACION WEB II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'PROGRAMACION MOBILE');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ING. DE SOFTWARE');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'TALLER DE PROGRAMACION');

--SEMESTRE IV PC
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (34,2,4,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (35,2,4,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (36,2,4,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (37,2,4,25000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (38,2,4,25000);

--ALUMNOS DE PC

INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'3582745','INGRID',NULL,'MOLINAS',NULL,'11/05/1993','0971521478','CHILE Y MANDUVIRA',NULL,'I');


INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(3,2,'22/01/2013','26/12/2014','T');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(1,3,'20/01/2018',NULL,'C');

--MATRICULACION DE LOS ALUMNOS DEL PC

-- ALUMNO 3 SEMESTRE 1  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,21,2013,1,'02/02/2013',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,2,2013,1,'02/02/2013',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,22,2013,1,'03/02/2013',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,23,2013,1,'03/02/2013',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,7,2013,1,'04/02/2013',4,'C');

-- ALUMNO 3 SEMESTRE 2  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,24,2013,2,'02/07/2013',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,25,2013,2,'02/07/2013',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,26,2013,2,'03/07/2013',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,27,2013,2,'03/07/2013',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,28,2013,2,'04/07/2013',5,'C');

-- ALUMNO 3 SEMESTRE 3  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,29,2014,1,'02/02/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,30,2014,1,'02/02/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,31,2014,1,'03/02/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,32,2014,1,'03/02/2014',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,33,2014,1,'04/02/2014',4,'C');

--ALUMNO 3 SEMESTRE 4 TSE

INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,34,2014,2,'02/07/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,35,2014,2,'02/07/2014',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,36,2014,2,'03/07/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,37,2014,2,'03/07/2014',5,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(3,38,2014,2,'04/07/2014',3,'C');


-- ALUMNO 1 SEMESTRE 1  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,21,2018,1,'02/02/2018',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,2,2018,1,'02/02/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,22,2018,1,'03/02/2018',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,23,2018,1,'03/02/2018',1,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,7,2018,1,'04/02/2018',4,'C');

-- ALUMNO 1 SEMESTRE 2  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,24,2018,2,'02/07/2018',0,'X');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,25,2018,2,'02/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,28,2018,2,'03/07/2018',0,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(1,23,2018,2,'03/07/2018',0,'C');


--MATERIAS DE LA CARRERA TSEL
--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO I');
--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'GEOMETRIA ANALITICA Y VECTORES');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'EMPRENDEDORISMO');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'DISEÑO ASISTIDO POR COMPUTADORA');
--SEMESTRE I TSEL
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (1,3,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (2,3,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (39,3,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (40,3,1,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (41,3,1,20000);

--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FISICA II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTROTECNIA I');
--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO III');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'TERMODINAMICA');
--SEMESTRE II TSEL
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (6,3,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (42,3,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (43,3,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (11,3,2,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (44,3,2,20000);

INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTROTECNICA II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'INSTALACIONES ELECTRICAS I');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'LABORATORIO DE ELECTROTECNIA');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'PREVENSION Y SEGURIDAD');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'MECANICA DE FLUIDOS');
--SEMESTRE III TSEL
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (45,3,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (46,3,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (47,3,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (48,3,3,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (49,3,3,20000);

INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'INSTALACIONES ELECTRICAS II');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CIRCUITOS ELECTRICOS');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTRONICA BASICA');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTRICIDAD INDUSTRIAL');
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ELECTRICIDAD DE POTENCIA');
--SEMESTRE IV TSEL
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (50,3,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (51,3,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (52,3,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (53,3,4,20000);
INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES (54,3,4,20000);

INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'4215874','JIMENA','JAZMIN','PEREZ','SANDOVAL','11/12/1993','021526321','LAS PERLAS Y SARAVI',NULL,'I');

INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'5369741','CARLOS','ALBERTO','BENITEZ',NULL,'09/09/1995','0985362415','LAS PERLAS Y SARAVI','CARLOSAL@HOTMAIL.COM','A');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(4,3,'25/01/2018',NULL,'A');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(5,3,'25/01/2018',NULL,'C');

--MATRICULACION DE LOS ALUMNOS DEL TSEL

-- ALUMNO 4 SEMESTRE 1  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(4,1,2018,1,'02/02/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(4,2,2018,1,'02/02/2018',1,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(4,39,2018,1,'03/02/2018',1,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(4,40,2018,1,'03/02/2018',0,'A');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(4,41,2018,1,'04/02/2018',0,'A');

-- ALUMNO 5 SEMESTRE 1  PC
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(5,1,2018,1,'02/02/2018',4,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(5,2,2018,1,'03/02/2018',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(5,39,2018,1,'03/02/2018',3,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(5,40,2018,1,'03/02/2018',2,'C');
INSERT INTO MATRICULACION(COD_ALUMNO,COD_MATERIA,ANHO,NUM_SEMESTRE,FECHA_MATRIC,CALIFICACION,SITUACION)
VALUES(5,41,2018,1,'03/02/2018',0,'X');


INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'5532741','JOSE','RAUL','BAEZ','ROA','01/08/1996','0991325741','ESPAÑA Y SACRAMENTO','JOSEBA96@GMAIL.COM','A');

INSERT INTO ALUMNO (CODIGO,CI,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,TELEFONO,DIRECCION,EMAIL,ESTADO)
VALUES(SEQ_ALUMNO.NEXTVAL,'5369781','JOHANA',NULL,'PEREZ','RIVEROS','09/07/1994','0994325641','SAN MARTIN Y ANDRADE','JOHANARIV@HOTMAIL.COM','A');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(6,1,'30/06/2018',NULL,'C');

INSERT INTO ALUMNO_CARRERA(COD_ALUMNO,COD_CARRERA,FECHA_INGRESO,FECHA_EGRESO,ESTADO)
VALUES(7,2,'30/06/2018',NULL,'C');

COMMIT;
--IMPORTANTE COLOCAR COMMIT PARA QUE SE PUEDA VISUALIZAR EN EL NAVEGADOR WEB








/* 2DA PARTE --------------------------------------------------------------------------*/
-- 2.1
-- @C:\SQL\4.sql;
INSERT INTO CARRERA(CODIGO, NOMBRE,FECHA_CREACION,NUM_RESOLUCION,DURACION,ESTADO)
VALUES(SEQ_CARRERA.NEXTVAL, 'ING. EN INFORMATICA','30/09/2018',' 022-003-2018',10,'A');

--PRIMER SEMESTRE
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGORITMOS Y ESTRUCTURA DE DATOS I');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'EXPRESION ORAL Y ESCRITA');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'FUNDAMENTOS DE MATEMATICA');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'MATEMATICA DISCRETA');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ORGANIZACION Y ARQUITECTURA DE COMPUTADORAS I');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'DESARROLLO Y EMPRENDEDORISMO');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,1,25000);

--SEGUNDO SEMESTRE 
INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGEBRA LINEAL');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,2,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ALGORITMOS Y ESTRUCTURA DE DATOS II');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,2,25000);



--INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'CALCULO I');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(1,SEQ_CARRERA.CURRVAL,2,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'INGLES');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,2,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'LENGUAJES DE PROGRAMACION I');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,2,25000);



INSERT INTO MATERIA (CODIGO,NOMBRE) VALUES(SEQ_MATERIA.NEXTVAL,'ORGANIZACION Y ARQUITECTURA DE COMPUTADORAS II');

INSERT INTO CARRERA_MATERIA(COD_MATERIA,COD_CARRERA,SEMESTRE,COSTO) VALUES 
(SEQ_MATERIA.CURRVAL,SEQ_CARRERA.CURRVAL,2,25000);

--CLEAR SCREEN;

/* 2.2 El alumno con código 2 ha decidido desertar el semestre actual (Semestre:2 Año: 2018).
Actualice a 'A' (Abandonada) la situación de las inscripciones a las materias con código 1 y 5 */

UPDATE MATRICULACION SET SITUACION='A' WHERE COD_ALUMNO=2 AND NUM_SEMESTRE=2 AND ANHO=2018 AND (COD_MATERIA=1 OR COD_MATERIA=5);



/*
2.3 Seleccione los datos de todas las carreras activas y que no están acreditadas
*/
SELECT * FROM CARRERA WHERE ESTADO='A' AND ES_ACREDITADA='N';



/*
2.4 Muestre la escala de calificaciones obtenidas en el primer semestre del 2018. Filtre por las
matriculaciones con estado 'C', elimine los datos repetidos y ordene de menor a mayor
*/

SELECT DISTINCT CALIFICACION FROM MATRICULACION WHERE ANHO=2018 AND NUM_SEMESTRE=1 AND SITUACION='C' ORDER BY CALIFICACION ASC;
-- CONFIRMAR...

/*
2.5 Escriba una consulta que recupere los datos de los alumnos que no tienen segundo nombre. 
*/
SELECT * FROM ALUMNO WHERE SEGUNDO_NOMBRE IS NULL;



/*
2.6  ¿Cuánto costará cursar todas las materias del 2° semestre de la carrera 1 – ‘Técnico Superior
en Electrónica’? Escriba una consulta que realice el cálculo
Considere que un semestre académico es igual a 4 meses calendario
*/
--CLEAR SCREEN;
--SELECT * FROM CARRERA_MATERIA WHERE COD_CARRERA=1 AND SEMESTRE=2;


SELECT SUM(COSTO)*4 FROM CARRERA_MATERIA WHERE COD_CARRERA=1 AND SEMESTRE=2;


/*
2.7  Muestre el programa de estudios de la carrera 'Programación de computadoras
*/

--JOIN DE TRES TABLAS... 
CREATE VIEW PROGRAMA_DE_ESTUDIOS
	(CODIGO_CARRERA, NOMBRE_CARRERA, CODIGO_MATERIA, NOMBRE_MATERIA,SEMESTRE)
AS
	SELECT 
		carrera_.CODIGO,
		carrera_.NOMBRE, 
		materia_.CODIGO, 
		materia_.NOMBRE,
		carrera_materia_.SEMESTRE
	FROM
		CARRERA carrera_ JOIN CARRERA_MATERIA carrera_materia_
		ON carrera_.CODIGO = carrera_materia_.COD_CARRERA
		JOIN MATERIA materia_
		ON materia_.CODIGO = carrera_materia_.COD_MATERIA
	WHERE carrera_.CODIGO=2 
	ORDER BY carrera_materia_.SEMESTRE ASC;


SELECT * FROM PROGRAMA_DE_ESTUDIOS;
/* SELECT * FROM CARRERA_MATERIA WHERE COD_CARRERA=2 ORDER BY COD_MATERIA; */


/* 2.8
Prepare el boletín de calificaciones correspondiente al año 2014; para el alumno con código 3.
Debe mostrar sólo las materias cuyas matriculaciones tengan estado 'C'
*/
CREATE VIEW BOLETIN_CALIFICACIONES
	(CODIGO_ALUMNO, CI, NOMBRE_Y_APELLIDO, EDAD, SEMESTRE, ANHO, MATERIA, CALIFICACION)
AS
	SELECT
		alumno_.CODIGO,
		alumno_.CI,
		alumno_.PRIMER_NOMBRE ||' '|| alumno_.SEGUNDO_NOMBRE ||' '|| alumno_.PRIMER_APELLIDO ||' '|| alumno_.SEGUNDO_APELLIDO,
		(TRUNC(MONTHS_BETWEEN(SYSDATE,alumno_.FECHA_NACIMIENTO)/12)),
		matriculacion_.NUM_SEMESTRE,
		matriculacion_.ANHO,
		materia_.NOMBRE,
		matriculacion_.CALIFICACION
	FROM 
		ALUMNO alumno_ JOIN MATRICULACION matriculacion_ 
		ON alumno_.CODIGO = matriculacion_.COD_ALUMNO
		JOIN MATERIA materia_ 
		ON materia_.CODIGO = matriculacion_.COD_MATERIA
	WHERE 
		alumno_.CODIGO=3 AND matriculacion_.ANHO=2014 AND matriculacion_.SITUACION='C'
		ORDER BY matriculacion_.NUM_SEMESTRE ASC;


SELECT * FROM BOLETIN_CALIFICACIONES;
/*
2.9
Haga una consulta que muestre el promedio de calificaciones de las materias cursadas en el año
2014 por el alumno con código 3. Filtre por las matriculaciones con estado 'C'.
*/

--SELECT * FROM MATRICULACION WHERE COD_ALUMNO=3 AND ANHO=2014 AND SITUACION='C';

SELECT SUM(CALIFICACION)/COUNT(CALIFICACION) FROM MATRICULACION 
WHERE COD_ALUMNO=3 AND ANHO=2014 AND SITUACION='C';

SELECT AVG(CALIFICACION) FROM MATRICULACION 
WHERE COD_ALUMNO=3 AND ANHO=2014 AND SITUACION='C';

COMMIT;