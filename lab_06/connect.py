import psycopg2
from psycopg2 import OperationalError

text = '''
1) Выполнить скалярный запрос
2) Выполнить запрос с несколькими join
3) Выполнить запрос с ОТВ и оконными функциями
4) Выполнить запрос к метаданным
5) Вызвать скалярную функцию (написанную в третьей л.р.)
6) Вызвать многооператорную или табличную функцию (написанную в 3 л.р.)
7) Вызвать хранимую процедуру (написанную в 3 л.р.)
8) Вызвать системную функцию или процедуру
9) Создать таблицу в базе данных, соответствующую теме бд
10) Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
11) Удалить созданную в п. 9 таблицу
0) Выход
'''

# получение дизайнера c id = 980
scalarRequest = '''
select DesignerID, DesignerName from sch.Designers where DesignerID = 980;
'''

# дизайнеры, у которых есть проекты по брендингу
multJoinRequest = '''
SELECT sch.Designers.DesignerID, sch.Designers.DesignerName
FROM sch.Designers JOIN sch.Distribution ON sch.Designers.DesignerID = sch.Distribution.DesignerID
JOIN sch.Projects ON sch.Distribution.ProjectID = sch.Projects.ProjectID
WHERE sch.Projects.ProjectType = 'branding'
'''

# кол-во проектов у каждого дизайнера
OTV = '''
WITH cte(DesignerID, ProjectID) AS (
	SELECT DesignerID, ProjectID
	FROM sch.Distribution
)
SELECT DesignerID, COUNT(ProjectID) OVER (PARTITION BY DesignerID)
FROM cte;
'''

# Получить все данные из public
metadataRequest = '''
select * from pg_tables where schemaname = 'public';
'''

# Увеличить на 1 ID дизайнера
scalarFunc = '''
SELECT inc_id(DesignerID) FROM sch.Projects ORDER BY DesignerID DESC;
'''

# Вывести всех дизайнеров, родившихся после 2000 года
tableFunc = '''
SELECT *
FROM get_designers('2000.01.01')
ORDER BY dob;
'''

# Поменять статус проекта заданного типа
storedProc = '''
CALL change_status('web-site', 'wip', 'done');
SELECT *
FROM sch.Projects WHERE sch.Projects.ProjectType = 'web-site'
'''

# Создать таблицу
tableCreation = '''
create table test_result(
	CustomerID int,
	DesignerID int
);
'''

# Вставить данные в таблицу
tableInsertion = '''
insert into test_result
values (56, 78), (12, 34), (90, 12);
select * from test_result;
'''

# Вызвать системную функцию или процедуру
systemFunc = '''
SELECT * FROM current_database();
'''

delTable = '''
DROP TABLE test_result;
'''

def output(cur, func):
    if func == 1:
        answer = cur.fetchall()
        print("\nВывести дизайнера c id = 980 : \n")
        print("Результат:")
        print("DesignerID", "DesignerName")
        print(answer[0][0], answer[0][1])

    elif func == 2:
        answer = cur.fetchall()

        print("\nДизайнеры, у которых есть проекты по брендингу : \n")
        print("Результат:")
        print("DesignerID", "DesignerName")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 3:
        answer = cur.fetchall()

        print("\nКол-во проектов у каждого дизайнера: \n")
        print("Результат:")
        print("projects count")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 4:
        answer = cur.fetchall()

        print("\nПолучить все данные из public: \n")
        print("Результат:")
        print("shemaname tablename tableowner tablespace hasIndexes hasrules hastriggers")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2],  answer[i][3],  answer[i][4],  answer[i][5], answer[i][6])

    elif func == 5:
        answer = cur.fetchall()

        print("\nУвеличить на 1 ID дизайнера: \n")
        print("Результат:")
        print("ID")
        print(answer[0][0])

    elif func == 6:
        answer = cur.fetchall()

        print("\nВывести всех дизайнеров, родившихся после 2000 года \n")
        print("Результат :")
        for i in range (len(answer)):
            print(answer[i])

    elif func == 7:
        answer = cur.fetchall()

        print("\nПоменять статус проекта заданного типа \n")
        print("Результат :")
        print("ProjectID, CustomerID, DesignerID, TaskID, ProjectName, ProjectType, Status")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3], answer[i][4], answer[i][5], answer[i][6])

    elif func == 8:
        answer = cur.fetchall()

        print("\nВызвать системную функцию или процедуру: \n")
        print("Результат :")
        print("current db")
        print(answer[0][0])

    elif func == 9:
        print("\nСоздать таблицу: \n")
        print("Результат :")
        print("Table created")

    elif func == 10:
        answer = cur.fetchall()

        print("\n Вставить данные в таблицу: \n")
        print("Результат :")
        print("ProjectID, DesignerID")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 11:
        print("Table dropped")
        

def requestPgQuery(connection, query, func):
    cursor = connection.cursor()
    cursor.execute(query)
    # COMMIT фиксирует текущую транзакцию. Все изменения, произведённые транзакцией, становятся видимыми для других и гарантированно сохранятся в случае сбоя.
    connection.commit()
    output(cursor, func)
    cursor.close()



def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            host="localhost",
            database="design",
            user="postgres",
            password="LinkinPark20")


        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection


def menu(connection):
    choice = -1
    while(choice):
        print(text)
        print("Выберите действие:")
        choice = int(input())
        if (choice == 1):
            requestPgQuery(connection, scalarRequest, 1)
        elif choice == 2:
            requestPgQuery(connection, multJoinRequest, 2)
        elif choice == 3:
            requestPgQuery(connection, OTV, 3)
        elif choice == 4:
            requestPgQuery(connection, metadataRequest, 4)
        elif choice == 5:
            requestPgQuery(connection, scalarFunc, 5)
        elif choice == 6:
            requestPgQuery(connection, tableFunc, 6)
        elif choice == 7:
            requestPgQuery(connection, storedProc, 7)
        elif choice == 8:
            requestPgQuery(connection, systemFunc, 8)
        elif choice == 9:
            requestPgQuery(connection, tableCreation, 9)
        elif choice == 10:
            requestPgQuery(connection, tableInsertion, 10)
        elif choice == 11:
            requestPgQuery(connection, delTable, 11)


if __name__ == '__main__':
    connection = connect()
    menu(connection)
    connection.close()
