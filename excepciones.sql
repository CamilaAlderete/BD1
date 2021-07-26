-- @C:\SQL\excepciones.sql;

-- la cami

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

/*
Tipos de excepciones:
	- Definidas por el sistema
	- Definidas por el usuario

	
Sintanxis:
	

DECLARE 
	   <declarations section> 
BEGIN 
	   <executable command(s)> 
EXCEPTION 
	   <exception handling goes here > 
	WHEN exception1 THEN  
      exception1-handling-statements  
    WHEN exception2  THEN  
      exception2-handling-statements  
    WHEN exception3 THEN  
      exception3-handling-statements 
   ........ 
    WHEN others THEN 
      exception3-handling-statements 
END;
/


*/

--ALTER SESSION SET NLS_DATE_FORMAT= 'DD-MM-YYYY';

create table persona(
	id_persona integer not null,
	nombre varchar2(30) not null,
	apellido varchar2(30) not null,
	cedula integer not null,
	direccion varchar2(50),
	constraint id_persona_pk primary key(id_persona),
	constraint unique_cedula unique(cedula)
);

SET SERVEROUTPUT ON;

--excepcion definida por el sistema
DECLARE 
	p_id persona.id_persona%type :=8;
	p_nombre persona.nombre%type;
	p_direccion persona.direccion%type;
BEGIN
	select nombre, direccion 
	INTO p_nombre, p_direccion 
	from persona where id_persona=p_id;
	dbms_output.put_line('Nombre: '||  p_nombre); 
    dbms_output.put_line('Direccion: ' || p_direccion);
EXCEPTION 
	when no_data_found then 
		dbms_output.put_line('Persona con '||TO_CHAR(p_id)||' no encontrada.');
	when others then
		dbms_output.put_line('Otro tipo de error');
END;
/


--excepcion definida por el usuario
--se ejecuta 3 veces, porque? no se...
DECLARE 
	p_id persona.id_persona%type :=0;
	p_nombre persona.nombre%type;
	p_direccion persona.direccion%type; 
	ex_invalid_id  EXCEPTION; 
BEGIN 
   IF p_id <= 0 THEN 
      RAISE ex_invalid_id; 
   ELSE 
    select nombre, direccion INTO p_nombre, p_direccion 
	from persona where id_persona=p_id;
	dbms_output.put_line('Nombre: '||  p_nombre); 
    dbms_output.put_line('Direccion: ' || p_direccion);
   END IF; 

EXCEPTION 
   WHEN ex_invalid_id THEN 
      dbms_output.put_line('ID debe ser mayor a cero!'); 
   WHEN no_data_found THEN 
      dbms_output.put_line('No existe persona con ese id!'); 
   WHEN others THEN 
      dbms_output.put_line('Otro Error!');  
END; 
/


/*trigger con excepciones.....*/
/*no permitira que se inserten personas con nombre Michifuz*/
create or replace trigger prueba
	before insert on persona
	for each row
	declare 
		e exception;
		nombre_prohibido persona.nombre%type:='Michifuz';
	begin
		if(:new.nombre = nombre_prohibido) then 
			raise e;
		end if;
	exception
		when e then
			dbms_output.put_line('Michifuz no es nombre de humano!');
			raise_application_error(-20001,'No se inserto en tabla persona');
			--solo con raise_application_error se evita que se inserte el dato
		when others then
			dbms_output.put_line('Otro error!');

	end prueba;
/

insert into persona values(1,'Michifuz','Alderete',4975477,'Los Alpes c/ San Nicolas 666');
insert into persona values(1,'Socorro Maria Del Pilar','Alderete',4975477,'Los Alpes c/ San Nicolas 666');
commit;






