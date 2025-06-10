-- ✅ 1. Create Database and Use It
CREATE DATABASE IF NOT EXISTS cinema;
USE cinema;

-- ✅ 2. Disable foreign key checks to drop tables safely
SET FOREIGN_KEY_CHECKS = 0;

-- ✅ 3. Drop all tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS seatinline;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS shows;
DROP TABLE IF EXISTS hall;
DROP TABLE IF EXISTS theatre;
DROP TABLE IF EXISTS movie;
DROP TABLE IF EXISTS customer;

-- ✅ 4. Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ✅ 5. Create Customer Table
CREATE TABLE IF NOT EXISTS customer (
    ID INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    PRIMARY KEY(ID)
);

-- ✅ 6. Create Movie Table
CREATE TABLE IF NOT EXISTS movie (
    ID INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    length TIME NOT NULL,
    genre VARCHAR(50),
    language VARCHAR(50),
    PRIMARY KEY(ID)
);

-- ✅ 7. Create Theatre Table
CREATE TABLE IF NOT EXISTS theatre (
    ID INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    road VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    pincode INT NOT NULL,
    PRIMARY KEY(ID)
);

-- ✅ 8. Create Hall Table
CREATE TABLE IF NOT EXISTS hall (
    ID INT NOT NULL AUTO_INCREMENT,
    theatre_ID INT NOT NULL,
    capacity INT NOT NULL,
    PRIMARY KEY(ID, theatre_ID),
    CONSTRAINT fk_hall FOREIGN KEY (theatre_ID)
        REFERENCES theatre(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ✅ 9. Create Shows Table
CREATE TABLE IF NOT EXISTS shows (
    ID INT NOT NULL AUTO_INCREMENT,
    movie_ID INT NOT NULL,
    hall_ID INT NOT NULL,
    theatre_ID INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    show_date DATE NOT NULL,
    price FLOAT NOT NULL,
    PRIMARY KEY(ID),
    CONSTRAINT fk_movie FOREIGN KEY(movie_ID) REFERENCES movie(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_halltheatre FOREIGN KEY(hall_ID, theatre_ID) REFERENCES hall(ID, theatre_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ✅ 10. Create Payment Table
CREATE TABLE IF NOT EXISTS payment (
    ID INT NOT NULL AUTO_INCREMENT,
    amt FLOAT NOT NULL,
    pay_time TIME NOT NULL,
    pay_date DATE NOT NULL,
    PRIMARY KEY(ID)
);

-- ✅ 11. Create Books Table
CREATE TABLE IF NOT EXISTS books (
    customer_ID INT NOT NULL,
    seat_ID INT NOT NULL,
    show_ID INT NOT NULL,
    payment_ID INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY(customer_ID) REFERENCES customer(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_show FOREIGN KEY(show_ID) REFERENCES shows(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_payment FOREIGN KEY(payment_ID) REFERENCES payment(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ✅ 12. Create SeatInline Table
CREATE TABLE IF NOT EXISTS seatinline (
    ID INT NOT NULL AUTO_INCREMENT,
    seat_ID INT NOT NULL,
    show_ID INT NOT NULL,
    book_time TIME NOT NULL,
    book_date DATE NOT NULL,
    PRIMARY KEY(ID),
    CONSTRAINT fk_seatShow FOREIGN KEY(show_ID) REFERENCES shows(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ✅ 13. Sample Data Inserts
INSERT INTO customer(name, email, password)
VALUES ('Omkar Dhage', 'omkar@example.com', 'omkar8180');

INSERT INTO movie(name, length, genre, language)
VALUES ('Inception', '02:28:00', 'Sci-Fi', 'English');

INSERT INTO theatre(name, road, city, pincode)
VALUES ('PVR Cinemas', 'Link Road', 'Mumbai', 400104);

INSERT INTO hall(theatre_ID, capacity)
VALUES (1, 150);

INSERT INTO shows(movie_ID, hall_ID, theatre_ID, start_time, end_time, show_date, price)
VALUES (1, 1, 1, '15:00:00', '17:30:00', CURDATE(), 350);

INSERT INTO seatinline(seat_ID, show_ID, book_time, book_date)
VALUES (5, 1, CURTIME(), CURDATE());

INSERT INTO payment(amt, pay_time, pay_date)
VALUES (350, CURTIME(), CURDATE());

INSERT INTO books(customer_ID, seat_ID, show_ID, payment_ID)
VALUES (1, 5, 1, 1);

-- ✅ 14. Useful Queries

-- Check if email exists
SELECT CASE 
    WHEN EXISTS(SELECT email FROM customer WHERE email = 'omkar@example.com') 
    THEN 0 ELSE 1 
END AS val;

-- Get show info for a movie
SELECT s.ID, t.name, start_time, show_date, hall_ID
FROM shows s
JOIN theatre t ON s.theatre_ID = t.ID
WHERE s.movie_ID = 1
ORDER BY show_date, start_time;

-- Get booked seat IDs
SELECT seat_ID FROM books WHERE show_ID = 1;

-- Get seat holds (inline) not older than ~10 minutes
SELECT seat_ID 
FROM seatinline 
WHERE show_ID = 1 AND book_date = CURDATE()
AND (CAST(CURTIME() AS TIME) - CAST(book_time AS TIME)) <= 1000;

-- Delete expired seat hold
DELETE FROM seatinline WHERE seat_ID = 5 AND show_ID = 1;
