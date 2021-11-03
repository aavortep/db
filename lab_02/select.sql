SELECT designerID, designerName, dob
FROM sch.Designers
WHERE designerPos = 'senior' AND dob > '1990.01.01'
ORDER BY dob;

SELECT sch.Projects.taskID, sch.TechTasks.taskName, sch.TechTasks.deadline
FROM sch.Projects JOIN sch.TechTasks ON sch.Projects.taskID = sch.TechTasks.taskID
WHERE sch.Projects.Status = 'done' AND 
	  sch.TechTasks.Deadline BETWEEN '2020.11.02' AND '2021.11.02'
ORDER BY deadline;

SELECT customerID, customerName, customerMail
FROM sch.Customers
WHERE customerType = 'entity' AND customerMail LIKE '%gmail.com';

/*Получить список проектов от заказчиков, являющихся физ. лицом,
над которыми работают (работали) иллюстраторы*/
SELECT ProjectID, ProjectName
FROM sch.Projects
WHERE DesignerID IN (SELECT sch.Designers.DesignerID
					 FROM sch.Designers
					 WHERE sch.Designers.Specialization = 'illustrator')
	  AND CustomerID IN (SELECT sch.Customers.CustomerID
						 FROM sch.Customers
						 WHERE sch.Customers.CustomerType = 'individual')
ORDER BY ProjectID;

/*Получить список заказчиков, у которых есть проекты по разработке сайта*/
SELECT sch.Customers.CustomerID, sch.Customers.CustomerName
FROM sch.Customers
WHERE EXISTS(SELECT sch.Projects.ProjectID
			 FROM sch.Projects
			 WHERE sch.Projects.CustomerID = sch.Customers.CustomerID
			 	   AND sch.Projects.ProjectType = 'web-site')
ORDER BY sch.Customers.CustomerID;

