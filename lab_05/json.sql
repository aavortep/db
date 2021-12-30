-- 1) Выгрузка таблицы Designers в json

copy (select to_json(Designers.*) from sch.Designers)
to 'C:\Anya\Prog\DB\lab_05\designers.json';

copy(select array_to_json(array_agg(row_to_json(t))) as "Designers"
     from sch.Designers as t)
to 'C:\Anya\Prog\DB\lab_05\designers.json';

-- 2) Загрузка JSON файла в таблицу

create temporary table json_import (values text);
copy json_import from 'C:\Anya\Prog\DB\lab_05\designers.json';

create table sch.des_json(
    DesignerID serial NOT NULL PRIMARY KEY,
  	DesignerName text NOT NULL,
  	DesignerMail text,
  	DesignerPhone varchar(16),
  	DOB varchar(10),
  	DesignerPos varchar(12) NOT NULL,
  	Specialization varchar(11) NOT NULL,
  	BossID int
);

insert into sch.des_json(designerid, designername, designermail, designerphone, dob, designerpos,
					 	 specialization, bossid)
SELECT (j->>'designerid')::INTEGER, (j->>'designername'), (j->>'designermail'), (j->>'designerphone'),
	   (j->>'dob'), (j->>'designerpos'), (j->>'specialization'), (j->>'bossid')::INTEGER
from (select json_array_elements(replace(values,'\','\\')::json) as j 
      from json_import
     ) a where j->'designerid' is not null;
select * from sch.des_json;

DROP TABLE json_import, sch.des_json

-- 3) Создание таблицы, в которой есть атрибут с типом JSON

drop table context;
CREATE TABLE context (
    data jsonb
);
INSERT INTO context (data) VALUES 
('{"name": "Anna", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2023}}'), 
('{"name": "Alex", "age": 20, "education": {"university": "MIET", "graduation_year": 2023}}');

-- 4) Выполнить следующие действия:
-- 1. Извлечь JSON фрагмент из JSON документа
-- 2. Извлечь значения конкретных узлов или атрибутов JSON документа
-- 3. Выполнить проверку существования узла или атрибута
-- 4. Изменить JSON документ
-- 5. Разделить JSON документ на несколько строк по узлам

-- Извлечь JSON фрагмент из JSON документа.
SELECT data->'education' education FROM context;

-- Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT data->'education'->'university' university FROM context;

-- Выполнить проверку существования узла или атрибута.
CREATE FUNCTION if_key_exists(json_to_check jsonb, key text)
RETURNS BOOLEAN 
AS $$
BEGIN
    RETURN (json_to_check->key) IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
SELECT if_key_exists('{"name": "Anna", "age": 20}', 'education');
SELECT if_key_exists('{"name": "Alex", "age": 20}', 'name');

-- Изменить JSON документ.
UPDATE context SET data = data || '{"age": 21}'::jsonb WHERE (data->'age')::INT = 20;
select * from context;
  
-- 5. Разделить JSON документ на несколько строк по узлам

SELECT * FROM jsonb_array_elements('[
    {"name": "Anna", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2023}},
    {"name": "Alex", "age": 20, "education": {"university": "MIET", "graduation_year": 2023}}
]');