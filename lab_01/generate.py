import random
import string

def gen_str(length):
    let = string.ascii_lowercase
    s = ''.join(random.choice(let) for i in range(length))
    return s

def gen_mail(mails):
    mail = gen_str(random.randint(5, 10)) + '@' + mails[random.randint(0, 2)]
    return mail

def gen_phone():
    phone = '+7-9'
    phone += str(random.randint(0, 9))
    phone += str(random.randint(0, 9))
    phone += '-'
    phone += str(random.randint(0, 9))
    phone += str(random.randint(0, 9))
    phone += str(random.randint(0, 9))
    phone += '-'
    phone += str(random.randint(0, 9))
    phone += str(random.randint(0, 9))
    phone += '-'
    phone += str(random.randint(0, 9))
    phone += str(random.randint(0, 9))
    return phone

def gen_date(year_lim1, year_lim2):
    date = str(random.randint(year_lim1, year_lim2)) + '.'

    first = random.randint(0, 1)
    if first == 0:
        sec = random.randint(1, 9)
    else:
        sec = random.randint(0, 2)
    date += str(first) + str(sec) + '.'
    
    first = random.randint(0, 2)
    if first != 0:
        sec = random.randint(0, 9)
    else:
        sec = random.randint(1, 9)
    date += str(first) + str(sec)

    return date

names = ['Aaliyah', 'Abigail', 'Ada', 'Adelina', 'Agatha', 'Alexa', 'Alexandra', 'Alexis', 'Alise', 'Bailey', 'Barbara', 'Beatrice', \
         'Belinda', 'Brianna', 'Bridjet', 'Brooke', 'Caroline', 'Catherine', 'Cecilia', 'Celia', 'Chloe', 'Christine', 'Claire', 'Daisy',\
         'Danielle', 'Deborah', 'Delia', 'Destiny', 'Diana', 'Dorothy', 'Eleanor', 'Elizabeth', 'Ella', 'Emily', 'Emma', 'Erin',\
         'Aaron', 'Abraham', 'Adam', 'Adrian', 'Aidan', 'Alan', 'Albert', 'Alejandro', 'Alex', 'Alexander', 'Alfred', 'Andrew',\
         'Benjamin', 'Bernard', 'Blake', 'Brandon', 'Brian', 'Bruce', 'Bryan', 'Cameron', 'Carl', 'Carlos', 'Charles', 'Christopher',\
         'Daniel', 'David', 'Dennis', 'Devin', 'Diego', 'Dominic', 'Donald', 'Douglas', 'Dylan', 'Edward', 'Elijah', 'Eric']
mails = ['yandex.ru', 'mail.ru', 'gmail.com']

cust = open('customers.txt', 'w')
cust_type = ['entity', 'individual']
for i in range(1, 1051):
    cust.write(str(i) + '|')  # CustomerID
    cust.write(names[random.randint(0, 71)] + '|')  # CustomerName
    cust.write(gen_mail(mails) + '|')  # CustomerMail
    cust.write(gen_phone() + '|')  # CustomerPhone
    cust.write(cust_type[random.randint(0, 1)] + '\n')  # CustomerType
cust.close()

designers = open('designers.txt', 'w')
des_pos = ['junior', 'middle', 'senior', 'art director']
des_spec = ['web', 'graphic', 'ux/ui', 'illustrator', 'fullstack']
for i in range(1, 1051):
    designers.write(str(i) + '|')  # DesignerID
    designers.write(names[random.randint(0, 71)] + '|')  # DesignerName
    designers.write(gen_mail(mails) + '|')  # DesignerMail
    designers.write(gen_phone() + '|')  # DesignerPhone
    designers.write(gen_date(1955, 2002) + '|')  # DOB
    designers.write(des_pos[random.randint(0, 3)] + '|')  # DesignerPos
    designers.write(des_spec[random.randint(0, 4)] + '\n')  # specialization
designers.close()

tasks = open('tasks.txt', 'w')
soft = ['Illustrator', 'Photoshop', 'InDesign', 'Lightroom', 'Figma', 'Tilda']
choice = ['y', 'n']
for i in range(1, 1051):
    tasks.write(str(i) + '|')  # TaskID
    tasks.write(gen_str(random.randint(5, 10)) + '|')  # theme
    tasks.write(soft[random.randint(0, 5)] + '|')  # software
    tasks.write(choice[random.randint(0, 1)] + '|')  # print
    tasks.write(choice[random.randint(0, 1)] + '|')  # refs
    tasks.write(gen_date(2020, 2023) + '\n')  # Deadline
tasks.close()

proj = open('projects.txt', 'w')
used = []
projType = ['interface', 'web-site', 'illustration', 'polygraphy', 'advertising', 'branding']
stat = ['wip', 'done']
for i in range(1, 1051):
    proj.write(str(i) + '|')  # ProjectID
    proj.write(str(random.randint(1, 1050)) + '|')  # CustomerID
    proj.write(str(random.randint(1, 1050)) + '|')  # DesignerID
    t = random.randint(1, 1050)
    while t in used:
        t = random.randint(1, 1050)
    proj.write(str(t) + '|')  # TaskID
    used.append(t)
    proj.write(gen_str(random.randint(5, 10)) + '|')  # ProjectName
    proj.write(projType[random.randint(0, 5)] + '|')  # ProjectType
    proj.write(stat[random.randint(0, 1)] + '\n')  # status
proj.close()

distr = open('distrib.txt', 'w')
used_pairs = []
for i in range(1, 1201):
    proj = random.randint(1, 1050)
    str_proj = str(proj)
    des = random.randint(1, 1050)
    str_des = str(des)
    pair = str_proj + str_des
    while pair in used_pairs:
        proj = random.randint(1, 1050)
        str_proj = str(proj)
        des = random.randint(1, 1050)
        str_des = str(des)
        pair = str_proj + str_des
    used_pairs.append(pair)
    distr.write(str_proj + '|' + str_des + '\n')
distr.close()
