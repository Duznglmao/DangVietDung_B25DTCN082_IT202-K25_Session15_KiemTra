DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

CREATE TABLE students (
    student_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE subjects (
    subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credits INT CHECK(credits > 0)
);

CREATE TABLE grades (
    student_id VARCHAR(5) NOT NULL,
    subject_id VARCHAR(5) NOT NULL,
    score DECIMAL(4, 2) CHECK(score BETWEEN 0 AND 10),
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE grade_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(5) NOT NULL,
    old_score DECIMAL(4, 2),
    new_score DECIMAL(4, 2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (student_id, full_name, total_debt)
VALUES  
    ('SV01', 'Nguyễn Minh Hiển', 2000000), 
    ('SV03', 'Quách Trần Anh', 0), 
    ('SV04', 'Vũ Lê Minh Hiếu', 36000000);
    
INSERT INTO subjects (subject_id, subject_name, credits)
VALUES  
    ('MH001', 'Lập trình C', 4),
    ('MH002', 'Cơ sở dữ liệu', 3),
    ('MH003', 'Lập trình Python', 5);

INSERT INTO grades (student_id, subject_id, score)
VALUES
    ('SV01', 'MH001', 10),
    ('SV03', 'MH003', 8),
    ('SV04', 'MH002', 7);
  
-- A.1
DELIMITER //
CREATE TRIGGER tg_check_score 
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    IF NEW.score < 0 THEN
        SET NEW.score = 0;
    ELSEIF NEW.score > 10 THEN
        SET NEW.score = 10;
    END IF;
END 
// DELIMITER ;

INSERT INTO grades(student_id, subject_id, score)
VALUES ('SV01', 'MH002', -5);

SELECT * 
FROM grades;

-- A.2
START TRANSACTION;
    INSERT INTO students (student_id, full_name, total_debt)
    VALUES ('SV02', 'Ha Bich Ngoc', 5000000);
COMMIT;

SELECT *
FROM students;

-- B.3
DELIMITER //
CREATE TRIGGER tg_log_grade_update  
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.score != NEW.score THEN
        INSERT INTO grade_log (student_id, old_score, new_score, change_date)
        VALUES 
        (OLD.student_id, OLD.score, NEW.score, NOW());
    END IF;
END 
// DELIMITER ;

UPDATE grades
SET score = 9
WHERE student_id = 'SV03'
AND subject_id = 'MH003';

SELECT * 
FROM grade_log;

-- B.4
DELIMITER //
CREATE PROCEDURE sp_pay_tuition ()
BEGIN
    DECLARE v_total_debt DECIMAL(10, 2);
    START TRANSACTION;
    
        UPDATE students
        SET total_debt = total_debt - 2000000
        WHERE student_id = 'SV01';
        
        SELECT total_debt INTO v_total_debt
        FROM students
        WHERE student_id = 'SV01';
        
        IF v_total_debt < 0 THEN
            ROLLBACK;
        ELSE 
            COMMIT;
        END IF;
END 
// DELIMITER ;

CALL sp_pay_tuition();

SELECT *
FROM students;

-- B.5
DELIMITER //
CREATE TRIGGER tg_prevent_pass_update 
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.score >= 4.0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = "Qua môn rồi thì kệ đi bạn tôi ";
    END IF;
END 
// DELIMITER ;

UPDATE grades
SET score = 9
WHERE student_id = 'SV04';