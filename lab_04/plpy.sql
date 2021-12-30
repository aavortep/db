CREATE EXTENSION PLPYTHON3U;
-- 1) Скалярная функция PL/Python.
-- Увеличить на 1 все ID дизайнеров в проектах
drop function inc_id_py(integer);
CREATE FUNCTION inc_id_py (id integer)
  RETURNS integer
AS $$
	DesignerID = id + 1
	return DesignerID
$$ LANGUAGE plpython3u;

SELECT inc_id_py(548);

-- 2) Пользовательскую агрегатную функцию CLR
-- Функция умножения всех чисел в столбце
create or replace function mul(state int, arg int)
returns int
as $$
    return state * arg
$$ language plpython3u;

CREATE AGGREGATE my_agr(int)
(
    sfunc = mul,
    stype = int,
    initcond = 1
);

select my_agr(gen.x) from generate_series(1, 5) as gen(x);

-- 3) Определяемая пользователем табличная функция PL/Python.
-- Вывести всех дизайнеров, родившихся после 2000 года
CREATE OR REPLACE FUNCTION get_des_py(min_dob varchar)
RETURNS TABLE (
    DesignerID int,
  	DesignerName text,
  	DOB varchar
) AS $$
    query = f"SELECT d.DesignerID did, d.DesignerName dname, d.DOB ddob FROM sch.Designers d WHERE d.DOB > '{min_dob}';"
    result = plpy.execute(query)
    for x in result:
        yield(x["did"], x["dname"], x["ddob"])
$$ LANGUAGE PLPYTHON3U;
SELECT * from get_des_py('2000.01.01');

-- 4) Хранимая процедура PL/Python.
create or replace procedure update_var_p (t_name text, p_var char, p_new_var char)
as $$
    plpy.execute("update " + t_name + " set name = \'" + str(p_new_var) + "\' where name = \'" +  str(p_var) + "\'")
$$ language plpython3u;

call update_var_p('sch.test_for_rec', 'B', 'A');
select * from sch.test_for_rec;

--5) Триггер CLR
drop trigger trig on sch.test_for_rec;
drop table act_tab;

create table act_tab(
    id int,
    act text
);

create or replace function tr_before() returns trigger
as $$
    if TD["event"] == "DELETE":
        old_id = str(TD["old"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + old_id + ", \'delete\')")
        return "OK"
        
    elif TD["event"] == "INSERT":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'insert\')")
        return "OK"
        
    elif TD["event"] == "update":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'update\')")
        return "OK"
$$ language plpython3u;

CREATE TRIGGER trig BEFORE INSERT ON sch.test_for_rec
FOR ROW EXECUTE PROCEDURE tr_before();

insert into sch.test_for_rec(id, name) values (6, 'D');

select * from act_tab

-- 6)Определяемый пользователем тип данных 
CREATE TYPE complex_new AS (
    r       double precision,
    i       double precision
);

create or replace function set_complex_new(r double precision , i double precision )
returns setof complex_new
as $$
    return ([r, i],)
$$ language plpython3u;

select * from set_complex_new(3, 5);

-- защита
create table sch.with_complex
(
	id int,
	num complex_new
);

insert into sch.with_complex values (1, (1, 2));
insert into sch.with_complex values (2, (3, 4));
insert into sch.with_complex values (3, (1, -5));
insert into sch.with_complex values (4, (-2, 6));
insert into sch.with_complex values (5, (7, 0));

select * from sch.with_complex;
select id, (num).i from sch.with_complex;

-- Вспомогательная таблица
drop table sch.test_for_rec;
create table sch.test_for_rec 
(
    id int,
    name text
);

insert into sch.test_for_rec  (id, name) values (1, 'A');
insert into sch.test_for_rec  (id, name) values (2, 'B');
insert into sch.test_for_rec  (id, name) values (3, 'c');
insert into sch.test_for_rec  (id, name) values (4, 'D');
insert into sch.test_for_rec  (id, name) values (5, 'A');
insert into sch.test_for_rec  (id, name) values (6, 'B');
insert into sch.test_for_rec  (id, name) values (7, 'c');
insert into sch.test_for_rec  (id, name) values (8, 'D');