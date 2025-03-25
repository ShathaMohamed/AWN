/* Database creation: */
CREATE DATABASE IF NOT EXISTS AwnVolunteerDB;
USE 'awn-database';

-- 1
/* Organization Table:
Stores information about organizations managing volunteer programs. */
CREATE TABLE Organization (
    organization_id INT PRIMARY KEY AUTO_INCREMENT,
    O_name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    website VARCHAR(2083), -- 2083 is the maximum length of a URL in many web browser
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL  -- Passwords should be securely hashed
);

-- 2
/* Program Table
Represents volunteer programs managed by organizations. */
CREATE TABLE Program (
    program_id INT PRIMARY KEY AUTO_INCREMENT,
    organization_id INT NOT NULL,
    P_name VARCHAR(255) NOT NULL,
    program_goal TEXT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id) ON DELETE CASCADE
);

-- 3
/* Employee Table
Stores employees managing volunteers in an organization. */
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    organization_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    -- role ENUM('Admin', 'Supervisor', 'Staff') NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id) ON DELETE CASCADE
);

-- 4
/* Volunteer Table
Stores volunteer information. */
CREATE TABLE Volunteer (
    volunteer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('Male','Female'),
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    skills ENUM('التواصل والاستماع', 'العمل الجماعي',
    'حل المشكلات', 'حل النزاعات', 'القيادة والإدارة', 'التعاطف والرحمة',
    'الصبر والتفهم', 'القدرة على التكيف والمرونة', 'الوعي الثقافي',
    'التواصل وبناء العلاقات المجتمعية'),  -- List of skills
    experience TEXT, -- Previous experience
    availability boolean,  -- If available or not
    special_requirments TEXT,
    organization_id INT,
    program_id INT,
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id) ON DELETE SET NULL,
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE SET NULL
);

-- 5
/* Event Table
Stores volunteer events related to programs. */
CREATE TABLE Event (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    program_id INT NOT NULL,
    E_name VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    location VARCHAR(255),
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE
);

-- 6
/* Task Table
Tracks assigned tasks for volunteers. */
CREATE TABLE Task (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    program_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    T_name VARCHAR(255) NOT NULL,
    due_date DATE NOT NULL,
    task_completion_status ENUM('قيد الانتظار', 'مكتملة', 'متأخرة') DEFAULT 'قيد الانتظار',    -- Status of tasks assigned to the team (only these three values allowed)
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);

-- 7
-- Task Assignment table
/*
cREATE TABLE Task_Assignment (
    Assignment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Task_ID INT,
    Assigned_To_Type ENUM('Volunteer', 'Team'),
    Assigned_To_ID INT,  -- Stores either Volunteer_ID or Team_ID
    Assigned_By INT,  -- Employee who assigned the task
    Assigned_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Task_ID) REFERENCES Task(Task_ID),   
    FOREIGN KEY (Assigned_By) REFERENCES Employee(Employee_ID)
);
*/

-- 8
-- location table
CREATE TABLE Location (
    Location_ID INT PRIMARY KEY AUTO_INCREMENT,
    Location_Name VARCHAR(255),
    Latitude DECIMAL(9,6),   -- Example: 25.276987
    Longitude DECIMAL(9,6),  -- Example: 55.296249
    Radius_Meters INT        -- Allowed radius in meters for attendance
);

-- 9
/* Attendance Table
Records volunteer attendance via GPS/QR code. */
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT NOT NULL,
    event_id INT NOT NULL,
    CheckIn_Time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CheckOut_time DATETIME NULL,
    Location_ID INT,  
    Latitude DECIMAL(9,6),   -- Actual latitude where QR was scanned
    Longitude DECIMAL(9,6),  -- Actual longitude where QR was scanned    
    qr_code VARCHAR(255),  -- Unique QR code for verification
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID)
);

-- 10
/* Certification Table
Stores certificates issued to volunteers. */
CREATE TABLE Certification (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT NOT NULL,
    volunteer_first_name VARCHAR(100) NOT NULL, -- Snapshot of the volunteer's first name
    volunteer_last_name VARCHAR(100) NOT NULL,  -- Snapshot of the volunteer's last name   
    volunteer_hours INT NOT NULL,
    program_id INT NOT NULL,
    program_name  VARCHAR(255),
    organization_id INT NOT NULL,
    organization_name  VARCHAR(255),
    issue_date DATE NOT NULL, 
    supervisor_signature VARCHAR(255),
    certificate_pdf VARCHAR(255),  -- Link to PDF
    security_QR_Code VARCHAR(255),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES Program(program_id),
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id)
);  
    

-- 11

CREATE TABLE Files(
    file_id INT AUTO_INCREMENT PRIMARY KEY,
    uploader INT,  -- To link to the user (if applicable)
    f_name VARCHAR(255),
    file_type VARCHAR(50),
    file_size INT,
    file_path VARCHAR(255)  -- Path to where the file is saved
);

-- 12
/* Report Table
Stores progress reports submitted by volunteers or supervisors. */
CREATE TABLE Report (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    program_id INT NOT NULL,
    -- submitted_by ENUM('Volunteer', 'Employee') NOT NULL,
    sender_id INT NOT NULL,
    send_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    file_id int,
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES Files(file_id) 
);

-- 13
/* Team Table
The Team table organizes volunteers and employees into groups for better task distribution. */
CREATE TABLE Team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    employee_id INT NOT NULL,  -- Employee who manages the team
    t_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) 
);


-- 14
/* Message Table
The Message table stores communication between volunteers and employees. */
CREATE TABLE Message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each message (auto-increments)
    program_id INT NOT NULL,  -- The program related to this message
    sender_id INT NOT NULL,  -- The ID of the person who sent the message
    message_text TEXT NOT NULL,  -- The actual content of the message
    send_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    -- Automatically records the date and time the message was sent
    -- Foreign key linking to Program table (ensures message is related to a valid program)
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE
);


-- *************ALL junction tables**************
-- 15
CREATE TABLE Team_Volunteers (
    team_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    role VARCHAR(100),  -- Optional: Role in the team
    PRIMARY KEY (team_id, volunteer_id),  -- Composite PK ensures uniqueness
    FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);

-- **********************************
-- 16
/*A volunteer can participate in many events.
An event can have many volunteers.*/
/*
CREATE TABLE Event_Volunteers (
    event_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    PRIMARY KEY (event_id, volunteer_id),
    FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);
*/
-- **********************************
-- 17
/*A volunteer can enroll in multiple programs.
A program can have multiple volunteers.*/

CREATE TABLE Program_Volunteers (
    program_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (program_id, volunteer_id),
    FOREIGN KEY (program_id) REFERENCES Program(program_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);

-- **********************************
-- 18
/* A team can be assigned multiple tasks.
A task can be assigned to multiple teams. */

CREATE TABLE Task_Team (
    task_id INT NOT NULL,
    team_id INT NOT NULL,
    PRIMARY KEY (task_id, team_id),
    FOREIGN KEY (task_id) REFERENCES Task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Team(team_id) ON DELETE CASCADE
);

-- 19
CREATE TABLE Task_Volunteer (
    task_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    PRIMARY KEY (task_id, volunteer_id),
    FOREIGN KEY (task_id) REFERENCES Task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);

-- **********************************
-- 20
/* A message can be sent to multiple employees/volunteers.
An employee/volunteer can receive multiple messages. */

CREATE TABLE Message_Recipients (
    message_id INT NOT NULL,
    recipient_id INT NOT NULL,  -- Can be Employee or Volunteer
    recipient_type ENUM('Employee', 'Volunteer'),  -- Distinguishes recipient type
    PRIMARY KEY (message_id, recipient_id, recipient_type),
    FOREIGN KEY (message_id) REFERENCES Message(message_id) ON DELETE CASCADE
);

-- **********************************
-- 21
/* An employee can work for multiple organizations.
An organization can have multiple employees. */

CREATE TABLE Organization_Employees (
    organization_id INT NOT NULL,
    employee_id INT NOT NULL,
    -- role VARCHAR(100),
    PRIMARY KEY (organization_id, employee_id),
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE CASCADE
);


-- **********************************
-- 22
/* A volunteer can be part of multiple organizations.
An organization can have multiple volunteers. */
/*
CREATE TABLE Organization_Volunteers (
    organization_id INT NOT NULL,
    volunteer_id INT NOT NULL,
    PRIMARY KEY (organization_id, volunteer_id),
    FOREIGN KEY (organization_id) REFERENCES Organization(organization_id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);
*/
-- **********************************