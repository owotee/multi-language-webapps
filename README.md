# Multi-language-webapps
Five web applications built with different programming languages deployed on AWS EC2 using SQLite

Multi-Language Web Applications with EC2 and SQLite
**Overview**

This project demonstrates the deployment of five simple web applications using different programming languages, all hosted on a single AWS EC2 instance. Each application includes a backend database using SQLite to store and display user input data.

The purpose of this project is to show how different backend technologies can be used to build similar web applications while sharing the same cloud infrastructure.

All applications follow the same pattern:

Homepage

Form to collect user input

Data stored in a database

Page displaying submitted data

**Architecture**

Cloud Platform: AWS EC2
Instance Type: t3.micro
Database: SQLite
Server OS: Amazon Linux

All applications run on the same EC2 instance but use different ports.

EC2 Instance
│
├── Python Flask App (Port 5001)
├── Node.js Express App (Port 5002)
├── PHP App (Port 5003)
├── Ruby Sinatra App (Port 5004)
└── Java Spark App (Port 5005)

**Application List**
App	Language	Port	Purpose
App 1	Python (Flask)	5001	Contact Form
App 2	Node.js (Express)	5002	Feedback Form
App 3	PHP	5003	Newsletter Signup
App 4	Ruby (Sinatra)	5004	Event Registration
App 5	Java (Spark)	5005	Job Inquiry Form
Public Application URLs
Python Contact Form
http://52.73.214.214:5001

Node Feedback Form
http://52.73.214.214:5002

PHP Newsletter Signup
http://52.73.214.214:5003

Ruby Event Registration
http://52.73.214.214:5004

Java Job Inquiry
http://52.73.214.214:5005

**Application Descriptions**

**App 1 — Python Contact Form**

Language: Python (Flask)

Fields collected:

Name

Email

Message

Users can submit a contact message which is stored in the SQLite database and displayed on the admin page.

Database table:

entries
id
name
email
message

Admin dashboard:

/entries

**App 2 — Node.js Feedback Form**

Language: Node.js (Express)

Fields collected:

Name

Rating

Comment

Users can submit feedback about the website.

Database table:

feedback
id
name
rating
comment

Admin dashboard:

/feedback

**App 3 — PHP Newsletter Signup**

Language: PHP

Fields collected:

Name

Email

Interest

Users can subscribe to a newsletter.

Database table:

signups
id
name
email
interest

Admin dashboard:

?page=list

**App 4 — Ruby Event Registration**

Language: Ruby (Sinatra)

Fields collected:

Name

Email

Event Name

Users can register for an event.

Database table:

registrations
id
name
email
event_name

Admin dashboard:

/registrations

**App 5 — Java Job Inquiry Form**

Language: Java (Spark Framework)

Fields collected:

Name

Email

Role

Users can submit job inquiries.

Database table:

inquiries
id
name
email
role

Admin dashboard:

/inquiries
Project Folder Structure
multi-apps
│
├── python-app
│   └── app.py
│
├── node-app
│   └── app.js
│
├── php-app
│   └── index.php
│
├── ruby-app
│   └── app.rb
│
└── java-app
    ├── pom.xml
    └── src/main/java/App.java
Database Access (Terminal)

Each application uses its own SQLite database file.

Python
cd ~/multi-apps/python-app
sqlite3 python_app.db
SELECT * FROM entries;
Node
cd ~/multi-apps/node-app
sqlite3 node_app.db
SELECT * FROM feedback;
PHP
cd ~/multi-apps/php-app
sqlite3 php_app.db
SELECT * FROM signups;
Ruby
cd ~/multi-apps/ruby-app
sqlite3 ruby_app.db
SELECT * FROM registrations;
Java
cd ~/multi-apps/java-app
sqlite3 java_app.db
SELECT * FROM inquiries;

Exit SQLite with:

.exit
Running the Applications

All applications are started from the EC2 server.

Example commands:

Python
python3 app.py
Node
node app.js
PHP
php -S 0.0.0.0:5003
Ruby
ruby app.rb
Java
mvn compile exec:java
Running Applications in Background

To keep applications running after the terminal closes:

nohup python3 app.py &
nohup node app.js &
nohup php -S 0.0.0.0:5003 &
nohup ruby app.rb &
nohup mvn exec:java &

Check active ports:

ss -tulpn

Expected ports:

5001
5002
5003
5004
5005
Technologies Used

AWS EC2

Python Flask

Node.js Express

PHP

Ruby Sinatra

Java Spark Framework

SQLite

HTML Forms

Key Features

Five different backend languages

Cloud deployment on AWS

Simple database integration

User input stored and retrieved

Multiple web applications running on one server

Future Improvements

Possible improvements for this project include:

Adding authentication for admin dashboards

Using a managed cloud database such as AWS RDS

Adding frontend styling with CSS frameworks

Deploying applications behind Nginx

Using Docker containers for each service
