ALTER TABLE sch.Customers ADD CHECK(sch.Customers.CustomerType IN('individual', 'entity'));
ALTER TABLE sch.Designers ADD CHECK(sch.Designers.DesignerPos IN('junior', 'middle', 'senior',
															 'art director'));
ALTER TABLE sch.Designers ADD CHECK(sch.Designers.Specialization IN('web', 'graphic',
														'ux/ui', 'illustrator', 'fullstack'));
ALTER TABLE sch.TechTasks ADD CHECK(sch.TechTasks.Print IN('y', 'n'));
ALTER TABLE sch.TechTasks ADD CHECK(sch.TechTasks.Refs IN('y', 'n'));
ALTER TABLE sch.Projects ADD CHECK(sch.Projects.ProjectType IN('interface', 'web-site', 'illustration',
					    							'polygraphy', 'advertising', 'branding'));