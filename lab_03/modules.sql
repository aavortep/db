-- 1. Скалярная функция
-- Увеличить на 1 все ID дизайнеров в проектах
CREATE OR REPLACE FUNCTION inc_id(DesignerID int)
RETURNS int
AS $$
	BEGIN
		RETURN DesignerID + 1;
	END
$$ LANGUAGE plpgsql;

SELECT inc_id(DesignerID) FROM sch.Projects ORDER BY DesignerID DESC;

-- 2. Подставляемая табличная функция
-- Вывести всех дизайнеров, родившихся после 2000 года
CREATE OR REPLACE FUNCTION get_designers(min_dob varchar) 
RETURNS SETOF sch.Designers
AS $$
BEGIN
    RETURN 	QUERY (SELECT *
        		   FROM sch.Designers 
        		   WHERE dob > min_dob);
END
$$ LANGUAGE plpgsql;

SELECT *
FROM get_designers('2000.01.01')
ORDER BY dob;

-- 3. Многооператорная табличная функция
-- Вывести все проекты джуниоров
CREATE OR REPLACE FUNCTION find_projects(pos varchar)
RETURNS TABLE (
    ProjID int,
    DesID int,
    ProjName text,
	ProjType varchar,
	Stat varchar
) AS $$
BEGIN
    CREATE TEMP TABLE tbl (
        ProjID int,
    	DesID int,
    	ProjName text,
		ProjType varchar,
		Stat varchar
    );
	
    INSERT INTO tbl (ProjID, DesID, ProjName, ProjType, Stat)
    SELECT ProjectID, sch.Projects.DesignerID, ProjectName, ProjectType, Status
	FROM sch.Projects JOIN sch.Designers ON sch.Projects.DesignerID = sch.Designers.DesignerID
 	WHERE sch.Designers.DesignerPos = pos;
	
    RETURN QUERY
    SELECT * FROM tbl;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM find_projects('junior') ORDER BY DesID;

-- 4. Рекурсивная функция
-- Вывести проекты, у которых TaskID не меньше 1000
CREATE OR REPLACE FUNCTION task_recursive(min_id int)
RETURNS SETOF sch.Projects
AS $$
BEGIN
    RETURN QUERY (SELECT *
    			  FROM sch.Projects
        		  WHERE sch.Projects.TaskID = min_id);
    IF (min_id > 1000) THEN
        RETURN QUERY
        SELECT * FROM task_recursive(min_id - 1);
    END IF;
END
$$ LANGUAGE 'plpgsql';

SELECT * FROM task_recursive(1050);

-- 5. Хранимая процедура с параметрами
-- Поменять статус проекта заданного типа
CREATE OR REPLACE PROCEDURE change_status(proj_type varchar, old_stat varchar, new_stat varchar) 
AS $$
BEGIN
		UPDATE sch.Projects 
		SET Status = new_stat
		WHERE ProjectType = proj_type AND Status = old_stat;
END;
$$ LANGUAGE PLPGSQL;
CALL change_status('web-site', 'wip', 'done');

-- 6. Рекурсивная хранимая процедура.
-- Поменять тип проектов, у которых TaskID не больше 50
CREATE OR REPLACE PROCEDURE change_type(task_id int, max_id int, new_type varchar)
AS $$
BEGIN
	UPDATE sch.Projects
	SET ProjectType = new_type
	WHERE TaskID = task_id;
	IF (task_id < max_id) THEN 
		CALL change_type(task_id + 1, max_id, new_type);
	END IF;
END;
$$ LANGUAGE PLPGSQL;  
CALL change_type(1, 50, 'interface');

-- 7. Хранимая процедура с курсором
-- Поменять заданное ПО у ТЗ на другое
CREATE OR REPLACE PROCEDURE update_soft(old_soft text, new_soft text)
AS $$
    DECLARE
        soft_row record;
        cur CURSOR FOR
        SELECT * FROM sch.TechTasks
        WHERE Software = old_soft;
    BEGIN
        OPEN cur;
        LOOP
            FETCH cur INTO soft_row;
            EXIT WHEN NOT FOUND;
            UPDATE sch.TechTasks 
            SET Software = new_soft
            WHERE sch.TechTasks.TaskID = soft_row.TaskID;
        END LOOP;
        CLOSE cur;
    END;
    $$ LANGUAGE PLPGSQL;
CALL  update_soft('Photoshop','Lightroom');

--8. Хранимая процедура доступа к метаданным
drop table my_tables;
select table_name, count(*) as size
into my_tables
from information_schema.tables
where table_schema = 'sch'
group by table_name;

select * from my_tables;

create or replace procedure table_size()
AS $$
declare
    cur cursor
    for select table_name, size
    from (
        select table_name,
        pg_relation_size(cast(table_name as varchar)) as size
        from information_schema.tables
        where table_schema = 'public'
        order by size desc
    ) AS tmp;
    row record;
begin
    open cur;
    loop
        fetch cur into row;
        exit when not found;
        raise notice '{table : %} {size : %}', row.table_name, row.size;
        update my_tables
        set size = row.size
        where my_tables.table_name = row.table_name;
    end loop;
    close cur;
end
$$ language plpgsql;

call table_size();
select * from my_tables;

-- 9. Триггер AFTER
-- При добавлении дизайнера возникает замечание о высоте его позиции
CREATE OR REPLACE FUNCTION get_designer_rank()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.DesignerPos = 'senior' OR NEW.DesignerPos = 'art director' THEN
        RAISE NOTICE 'Designer % has high position in company', NEW.DesignerID;
    ELSE
        RAISE NOTICE 'Designer % has low position in company', NEW.DesignerID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER pos_suggestion AFTER INSERT ON sch.Designers
FOR ROW EXECUTE PROCEDURE get_designer_rank();

INSERT INTO sch.Designers
VALUES (1051, 'Anna', 'nura.alexevna@yandex.ru', '+7-916-988-53-54', '2001.10.17', 'junior', 'graphic');
DELETE FROM sch.Designers WHERE DesignerID = 1051;

-- 10. Триггер INSTEAD OF
drop view designers;

CREATE VIEW designers AS
SELECT *
FROM sch.Designers;

CREATE OR REPLACE FUNCTION instead_trigger() 
RETURNS TRIGGER 
AS $$
    BEGIN
    INSERT INTO sch.Designers
    VALUES(NEW.DesignerID, NEW.DesignerName, NEW.DesignerMail, NEW.DesignerPhone, NEW.dob,
		   NEW.DesignerPos, NEW.Specialization);
    RAISE NOTICE 'Запись в Designers: id (%), name (%), mail (%), phone (%),
				 dob (%), pos (%), spec (%)', NEW.DesignerID, NEW.DesignerName, NEW.DesignerMail,
				 NEW.DesignerPhone, NEW.dob, NEW.DesignerPos, NEW.Specialization;
    RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER instead_tr
INSTEAD OF INSERT ON designers
FOR EACH ROW
EXECUTE PROCEDURE instead_trigger();

INSERT INTO designers
VALUES (1051, 'Anna', 'nura.alexevna@yandex.ru', '+7-916-988-53-54', '2001.10.17', 'junior', 'graphic');
DELETE FROM sch.Designers WHERE DesignerID = 1051;

-- триггер, который срабатывает, если добавляется проект и в нём нет информации про дизайнера
CREATE VIEW projects AS
SELECT *
FROM sch.Projects;

CREATE OR REPLACE FUNCTION add_proj_trigger()
RETURNS TRIGGER
AS $$
BEGIN
	IF NEW.DesignerID IS NULL THEN
		RAISE NOTICE 'No designer ID, cannot add project';
	ELSE
		INSERT INTO sch.Projects
    	VALUES(NEW.ProjectID, NEW.CustomerID, NEW.DesignerID, NEW.TaskID, NEW.ProjectName,
		   	   NEW.ProjectType, NEW.Status);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER add_tr
INSTEAD OF INSERT ON projects
FOR EACH ROW
EXECUTE PROCEDURE add_proj_trigger();

INSERT INTO projects
VALUES (1051, 1050, NULL, 1050, 'KVN', 'branding', 'wip');

--DELETE FROM sch.Projects WHERE TaskID = 1050;