grant all privileges on sch.Customers, sch.Designers, sch.Distribution,
sch.Projects, sch.Techtasks to avortep;

COPY sch.Customers FROM 'home/Prog/db/lab_01/customers.txt' WITH (DELIMITER '|');
COPY sch.Designers FROM 'home/Prog/db/lab_01/designers.txt' WITH (DELIMITER '|');
COPY sch.TechTasks FROM 'home/Prog/db/lab_01/tasks.txt' WITH (DELIMITER '|');
COPY sch.Projects FROM 'home/Prog/db/lab_01/projects.txt' WITH (DELIMITER '|');
COPY sch.Distribution FROM 'home/Prog/db/lab_01/distrib.txt' WITH (DELIMITER '|');