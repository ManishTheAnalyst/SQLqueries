--1.1 CREATING A TABLE AND IMPORTING GIVEN BANK DATA INTO DATABASE--

DROP TABLE IF EXISTS Bank_data
CREATE TABLE Bank_data(id int NOT NULL, given_date DATE, asset int, liability int, idx int)

COPY Bank_data FROM 'C:\Users\91901\Downloads\bank_data.csv' DELIMITER ',' CSV HEADER

SELECT * FROM Bank_data

--1.2 Create a index for the import table--
CREATE INDEX idx_bank
ON Bank_data(idx)

--Creating a table to store highest asset observation for each bank--
DROP TABLE IF EXISTS Bank_asset
CREATE TABLE Bank_asset(id int NOT NULL, given_date DATE, asset int, liability int, idx int)


--1.3 Find the highest asset observation for each bank--
INSERT INTO Bank_asset
SELECT sd.id,sd.given_date,sd.asset,sd.liability,sd.idx
FROM(SELECT id,given_date,asset,liability,idx, ROW_NUMBER() OVER(PARTITION BY id ORDER BY asset DESC) b_asset
FROM Bank_data) sd 
WHERE sd.b_asset =1
ORDER BY sd.asset DESC;

SELECT * FROM Bank_asset
LIMIT 10

--1.4 Show the query plan for question 1.3--
EXPLAIN SELECT sd.id,sd.given_date,sd.asset,sd.liability,sd.idx
FROM(SELECT id,given_date,asset,liability,idx, ROW_NUMBER() OVER(PARTITION BY id ORDER BY asset DESC) b_asset
FROM Bank_data) sd 
WHERE sd.b_asset =1
ORDER BY sd.asset DESC


--1.5 Given above highest asset table, count how many observations are there for each quarter--
SELECT extract(quarter FROM given_date) as quarter, COUNT (*)
FROM Bank_asset
GROUP BY extract(quarter FROM given_date)
ORDER BY extract(quarter FROM given_date) ASC

-- 1.6 For the whole sample data, how many observations have asset value higher than 100,000 and liability value smaller than 100,000--
SELECT COUNT(id)
FROM Bank_data
WHERE(Bank_data.asset > 100000 AND Bank_data.liability < 100000)

-- 1.7 Find the average liability of observation with odd ’idx’ number--
DROP TABLE IF EXISTS Liability_operations_ODD
CREATE TABLE Liability_operations_ODD(AVG_liability_ODD FLOAT)
INSERT INTO Liability_operations_ODD
SELECT ROUND(AVG(liability),4) AS AVG_liability_ODD 
FROM Bank_data
WHERE ( idx % 2 ) = 1

SELECT * FROM Liability_operations_ODD

-- 1.8 Find the average liability of observation with even ’idx’ number. --
DROP TABLE IF EXISTS Liability_operations_EVEN
CREATE TABLE Liability_operations_EVEN(AVG_liability_EVEN FLOAT)
INSERT INTO Liability_operations_EVEN
SELECT ROUND(AVG(liability),4) AS AVG_liability_EVEN
FROM Bank_data 
WHERE ( idx % 2 ) = 0

SELECT * FROM Liability_operations_EVEN



--1.8 What’s the difference between these two average number.--
SELECT(SELECT * FROM Liability_operations_EVEN) - (SELECT * FROM Liability_operations_ODD) AS The_Difference


--1.9 For each bank find all dates with higher asset compared to its previous dates.--
SELECT *
FROM (SELECT id,given_date,asset,
	  LAG(asset) OVER(PARTITION By id ORDER BY given_date) AS previous_asset FROM Bank_data) AS Last_data
WHERE asset > previous_asset 
LIMIT 10




