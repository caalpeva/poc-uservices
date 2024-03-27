START TRANSACTION;

DROP DATABASE IF EXISTS TENNIS;
CREATE DATABASE TENNIS CHARSET utf8mb4;
USE TENNIS;

CREATE TABLE COUNTRIES (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL
);

CREATE TABLE PLAYERS (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  SURNAME VARCHAR (100) NOT NULL,
  COUNTRY_ID INT UNSIGNED NOT NULL,
  FOREIGN KEY(COUNTRY_ID) REFERENCES COUNTRIES(ID)
);

INSERT INTO COUNTRIES(ID, NAME) VALUES(1, "Spain");
INSERT INTO COUNTRIES(ID, NAME) VALUES(2, "Switzerland");
INSERT INTO COUNTRIES(ID, NAME) VALUES(3, "Serbian");
INSERT INTO COUNTRIES(ID, NAME) VALUES(4, "Russia");

INSERT INTO PLAYERS(ID, NAME, SURNAME, COUNTRY_ID) VALUES(1, "Rafael", "Nadal", 1);
INSERT INTO PLAYERS(ID, NAME, SURNAME, COUNTRY_ID) VALUES(2, "Roger", "Federer", 2);
INSERT INTO PLAYERS(ID, NAME, SURNAME, COUNTRY_ID) VALUES(3, "Novak", "Djokovic", 3);
INSERT INTO PLAYERS(ID, NAME, SURNAME, COUNTRY_ID) VALUES(4, "Daniil", "Medvedev", 4);

COMMIT;