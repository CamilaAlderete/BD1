-- @C:\SQL\f1_1.sql;

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

ALTER SESSION SET NLS_DATE_FORMAT= 'DD-MM-YYYY';

create table seccion(
	cod_seccion integer not null,
	nombre varchar2(30) not null,
	sueldo_max integer not null,
	constraint pk_seccion primary key(cod_seccion),
	constraint check_sueldo_max check(sueldo_max > 0)
);


create table empleado(
	nro_empleado integer not null,
	ci integer not null,
	nombres varchar2(30) not null,
	apellidos varchar2(30) not null,
	cod_seccion integer not null,
	estado_civil char(1) not null,
	edad integer not null,
	sexo char(1) not null,
	sueldo integer not null,
	constraint pk_empleado primary key(nro_empleado),
	constraint unique_ci unique(ci),
	constraint fk_empleado_seccion foreign key(cod_seccion) references seccion(cod_seccion),
	constraint check_edad check(edad > 18),
	constraint check_estado_civil check( estado_civil in('S','C','D','V') ),
	constraint check_sexo check(sexo in('M','F')),
	constraint check_sueldo check(sueldo > 0)	
);


create table vendedor(
	cod_vendedor integer not null,
	nro_empleado integer not null,
	supervisor integer,
	comision integer default 0 not null,
	constraint pk_vendedor primary key(cod_vendedor),
	constraint fk_nro_empleado foreign key(nro_empleado) references empleado(nro_empleado),
	constraint fk_supervisor foreign key(supervisor) references vendedor(cod_vendedor),
	constraint chk_supervisor_cod_vendedor check(cod_vendedor < > supervisor)
);

---------------------

create table venta(
	nro_venta integer not null,
	cod_vendedor integer not null,
	fecha date not null,
	importe integer not null,
	constraint pk_venta primary key(nro_venta),
	constraint fk_venta foreign key(cod_vendedor) references vendedor(cod_vendedor),
	constraint chk_importe check(importe>0)
);


/* 5 Implememtar triggers las instrucciones insert o update
  en la tabla empleado, de forma tal que, se debe verificar
  que el sueldo del empleado no sea mayor al sueldo maximo establecido
  para la seccion. Si lo es, debe mostrar un mensaje indicando la situacion

  Hay que trabajar sobre empleado y seccion para comparar sueldos
*/

--con insert y update....
create or replace trigger verificar_sueldo
	before insert or update on empleado
	for each row
	declare
		var_sueldo_max integer;
	begin
		select sueldo_max into var_sueldo_max from seccion where cod_seccion = :new.cod_seccion; 
		if( :new.sueldo > var_sueldo_max ) then
			raise_application_error(-20001,'El sueldo '||TO_CHAR(:new.sueldo)||', es mayor al maximo de la seccion ('||TO_CHAR(var_sueldo_max)||')');
			--DBMS_OUTPUT.put_line('____');
		end if;
	end verificar_sueldo;
/ 



-- create or replace trigger verificar_sueldo_insert
-- 	before insert on empleado
-- 	for each row
-- 	declare
-- 		var_sueldo_max integer;
-- 	begin
-- 		select sueldo_max into var_sueldo_max from seccion where cod_seccion = :new.cod_seccion; 
-- 		if( :new.sueldo > var_sueldo_max ) then
-- 			raise_application_error(-20001,'Insert: El sueldo '||TO_CHAR(:new.sueldo)||', es mayor al maximo de la seccion ('||TO_CHAR(var_sueldo_max)||')');
-- 		end if;
-- 	end verificar_sueldo_insert;
-- / 




--solo update
-- create or replace trigger verificar_sueldo_update
-- 	before update of sueldo on empleado
-- 	for each row
-- 	declare
-- 		var_sueldo_max integer;
-- 	begin
-- 		select sueldo_max into var_sueldo_max from seccion where cod_seccion = :old.cod_seccion; 
-- 		if( :new.sueldo > var_sueldo_max ) then
-- 			raise_application_error(-20001,'Update: El sueldo '||TO_CHAR(:new.sueldo)||', es mayor al maximo de la seccion ('||TO_CHAR(var_sueldo_max)||')');
-- 		end if;
-- 	end verificar_sueldo_update;
-- / 


/*
	6. Crear un trigger que permita calcular y actualizar la columna
	comision en la tabla vendedor por cada venta que se inserta en la 
	tabla venta.
*/


/*
	7.Insertar registros en c/ tabla para corroborar las restricciones
*/

/*
	8. Crear vista1  que muestre de cada vendedor su cod_vendedor, ci,
	nombres, apellido, nombre seccion, cod_supervisor, nombres supervisor,
	ci supervisor. Debe estar ordenado ascendentemente por cod_vendedor.
*/

create view vista1
	(cod_vendedor, nombre, ci, seccion, cod_supervisor, nombres, ci_sup)
as 
	select
		vendedor_.cod_vendedor,
		empleado_.nombres ||' '||empleado_.apellidos,
		empleado_.ci,
		seccion_.nombre,
		supervisor_.cod_vendedor,
		empleado_sup_.nombres||' '||empleado_sup_.apellidos,
		empleado_sup_.ci
	from 
		vendedor vendedor_ join empleado empleado_ on vendedor_.nro_empleado = empleado_.nro_empleado
		join seccion seccion_ on empleado_.cod_seccion = seccion_.cod_seccion
		left join vendedor supervisor_ on supervisor_.cod_vendedor = vendedor_.supervisor
		left join empleado empleado_sup_ on empleado_sup_.nro_empleado = supervisor_.nro_empleado
		order by vendedor_.cod_vendedor asc;

--left join del vendedor y su supervisor, ya que puede que un empleado no tenga supervisor (un supervisor)



/*
	9. Crear una vista llamada vista2 que muestre por cada empleado: cod_empleado, ci,
	nombres, apellidos, sueldo, codigo_seccion, nombre seccion, sueldo max de la seccion.
	Debe estar ordenado descendentemente por numero de empleado.

*/

create view vista2
	(nro_empleado, ci,nombres,sueldo,cod_seccion,nombre,sueldo_max)
as
	select
		empleado_.nro_empleado,
		empleado_.ci,
		empleado_.nombres||' '||empleado_.apellidos,
		empleado_.sueldo,
		seccion_.cod_seccion,
		seccion_.nombre,
		seccion_.sueldo_max
	from
		empleado empleado_ join seccion seccion_ on empleado_.cod_seccion = seccion_.cod_seccion
		order by empleado_.nro_empleado desc;


create sequence seq_seccion start with 1 increment by 1;

--insert into seccion values('A','3000000');
insert into seccion values(seq_seccion.nextval,'A','3000000');
insert into seccion values(seq_seccion.nextval,'B','1000000');
insert into seccion values(seq_seccion.nextval,'C','5400000');
insert into seccion values(seq_seccion.nextval,'D','5000000');
insert into seccion values(seq_seccion.nextval,'E','4000000');


create sequence seq_empleado start with 1 increment by 1;
insert into empleado values(seq_empleado.nextval,1234567,'Julia','Torres',1,'C',27,'F',1000000);
insert into empleado values(seq_empleado.nextval,1244567,'Carlos','Aguilera',3,'S',20,'M',3000000);
insert into empleado values(seq_empleado.nextval,1234565,'Jenny','Lichi',1,'D',26,'F',900000);
insert into empleado values(seq_empleado.nextval,1224567,'Ian','Gonzalez',1,'V',23,'M',2000000);
insert into empleado values(seq_empleado.nextval,1234577,'Aymara','Sosa',1,'S',60,'F',3000000);
insert into empleado values(seq_empleado.nextval,1234578,'Johana','Suarez',1,'S',40,'F',3000000);

--situacion: si a Jenny Lichi se le coloca un salario no valido, no se insertan sus datos en la tabla
--y el nro de secuencia (3) se pierde....

create sequence seq_vendedor start with 1 increment by 1;
insert into vendedor values(seq_vendedor.nextval,1,null,80000);
insert into vendedor values(seq_vendedor.nextval,2,null,60000);
insert into vendedor values(seq_vendedor.nextval,3,1,70000);
insert into vendedor values(seq_vendedor.nextval,4,2,10000);
insert into vendedor values(seq_vendedor.nextval,5,2,83000);

create sequence seq_venta start with 1 increment by 1;
insert into venta values(seq_venta.nextval,1,sysdate-2,538000);
insert into venta values(seq_venta.nextval,4,sysdate-2,875000);
insert into venta values(seq_venta.nextval,2,sysdate-1,68000);
insert into venta values(seq_venta.nextval,3,'14-02-2021',54000);
insert into venta values(seq_venta.nextval,3,'12-06-2021',8000);


--prueba del trigger
--mal
insert into empleado values(seq_empleado.nextval,1234321,'Cristina','Amarilla',1,'C',27,'F',8000000);
--bien
insert into empleado values(seq_empleado.nextval,1234321,'Cristina','Amarilla',1,'C',27,'F',3000000);


--el id deberia ser 7, pero se pierde al insertar "mal"

--mal
update empleado set sueldo=7000000 where( nro_empleado = 8);

--bien
update empleado set sueldo=1000000 where( nro_empleado = 8);

commit;
