-- @C:\SQL\almacen.sql;

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


create table cliente(
	id_cliente int not null,
	ruc varchar2(40) not null,
	nombre varchar2(40) not null,
	direccion varchar2(40) not null,
	telefono varchar2(40) not null,
	constraint id_cliente_pk primary key(id_cliente)
);

create sequence seq_cliente start with 1 increment by 1;
insert into cliente values(seq_cliente.nextval, '12343421/8','Fulgencio Mbaraka','Los Alpes 321','0981 987 332');

create table almacen(
	id_producto int not null,
	descripcion varchar2(40) not null,
	precio int not null,
	stock int not null,
	stockmin int not null,
	stockmax int not null,
	constraint id_producto_pk primary key(id_producto)
);


create table venta(
	id_venta int not null,
	cod_prod int not null,
	unid_vendida int not null,
	precio_venta int not null,
	fecha date not null,
	cliente int not null,
	constraint id_venta_pk primary key(id_venta),
	constraint cliente_fk foreign key(cliente) references cliente(id_cliente),
	constraint cod_prod_fk foreign key(cod_prod) references almacen(id_producto)
);



/**********************************************************/
-- activar impresion de mensajes por consolaaaa
SET SERVEROUTPUT ON;
/*********************************************************/

/*
a) Se desea mantener actualizado el stock del ALMACEN cada vez que se vendan unidades de un determinado
producto.
*/

/*c) Si el stock es menor que la cantidad solicitada, se debe impedir la venta y emitir un mensaje.*/
create or replace trigger verificar_stock
	before insert on venta
	for each row
	declare
		var_stock integer;
	begin
		select stock into var_stock from almacen where id_producto = :new.cod_prod; 
		if( var_stock < :new.unid_vendida) then
			raise_application_error(-20001,'No hay producto, no se puede realizar venta');
		else
			update almacen set stock = stock - :new.unid_vendida
			where id_producto = :new.cod_prod;
		end if;
	end verificar_stock;
/ 



/*
b) Cuando el stock de un producto esté igual o por debajo del stock mínimo, lanzar un mensaje de petición de
compra. Se indicará el número de unidades a comprar, según el stock actual y el stock máximo.
*/

create or replace trigger verificar_stock_minimo
	after insert on venta
	for each row
	declare 
		var_stock_minimo integer;
		var_stock integer;
	begin

		select stockmin into var_stock_minimo from almacen where id_producto=:new.cod_prod;
		select stock into var_stock from almacen where id_producto=:new.cod_prod;
		
		if(var_stock <= var_stock_minimo) then
			--raise_application_error(-20002,'El stock del producto esta a minimo: '||TO_CHAR(var_stock)||', reponer mercaderias');
			--dbms_output.enable;
			DBMS_OUTPUT.put_line('El stock del producto esta a minimo: '||TO_CHAR(var_stock)||', reponer mercaderias');
		end if;

	end verificar_stock_minimo;
/




/*
Trigger para verificar que al insertar producto al almacen, que evite que se ingrese un nro de 
productos menor al stock minimo 
*/

create or replace trigger verificacion_inicial_del_stock
	before insert on almacen
	for each row
	begin
		if( :new.stock < :new.stockmin) then
			raise_application_error(-20003,'El stock es menor:'||TO_CHAR(:new.stock)||' al stock minimo del producto:'||TO_CHAR(:new.stockmin)||'.');
		-- else if (:new.stock > :new.stockmax) then
		-- 	raise_application_error(-20004,'El stock es mayor:'||TO_CHAR(:new.stock)||' al stock max del producto:'||TO_CHAR(:new.stockmax)||'.');
		end if;
	end verificacion_inicial_del_stock;
/		



create sequence seq_almacen start with 1 increment by 1;
insert into almacen values(seq_almacen.nextval,'Yogurt','2000','10','5','11');
insert into almacen values(seq_almacen.nextval,'Detergente','5000','7','5','11');
insert into almacen values(seq_almacen.nextval,'Talco','10000','6','5','13');

--insercion para probar trigger verificacion_inicial_del_stock, el cual
--verifica que al insertar en almacen, el stock sea mayor al minimo requerido
-- 4 < 5
insert into almacen values(seq_almacen.nextval,'Coca','10000','4','5','13');




create sequence seq_venta start with 1 increment by 1;
--Yogurt en stock, debe actualizar stock luego de venta
insert into venta values(seq_venta.nextval, 1,2,4000,sysdate,1);

--venta de detergente, solo hay 1 en stock, y el cliente pide 2... debe salir error
insert into venta values(seq_venta.nextval, 2,2,6000,sysdate,1);

--venta para probar trigger de stock minimo...... se compra producto hasta acabar stock
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);
insert into venta values(seq_venta.nextval, 3,1,6000,sysdate,1);



/*
3.2) Crear una vista que permita mostrarnos por cada Venta realizada los siguientes datos:
nro de venta, fecha, nombre cliente, nombre producto, cantidad, precio de venta, importe
*/

create view vista
	(nro_venta, fecha, nombre_cliente, producto, cantidad, precio_venta, importe)
as 
	select
		venta_.id_venta,
		venta_.fecha,
		cliente_.nombre,
		almacen_.descripcion,
		venta_.unid_vendida,
		venta_.precio_venta,
		(venta_.unid_vendida*venta_.precio_venta)
	from
		venta venta_ join cliente cliente_ on venta_.cliente = cliente_.id_cliente
		join almacen almacen_ on venta_.cod_prod = almacen_.id_producto;	

commit;

