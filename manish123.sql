--Importing banks_sec_2002.csv--
DROP TABLE IF EXISTS Bank_new
CREATE TABLE Bank_new(id int NOT NULL,given_date DATE,security int)

COPY Bank_new FROM 'C:\Users\91901\Downloads\banks_sec_2002.csv' DELIMITER ',' CSV HEADER
SELECT * FROM Bank_new

--Importing banks_al_2002.csv--
DROP TABLE IF EXISTS Bank_new_1
CREATE TABLE Bank_new_1(id int NOT NULL,given_date DATE,asset int,liability int)

COPY Bank_new_1 FROM 'C:\Users\91901\Downloads\banks_al_2002.csv'DELIMITER ',' CSV HEADER
SELECT * FROM Bank_new_1;

--Importing banks_al_2001.csv--
DROP TABLE IF EXISTS Bank_new_2
CREATE TABLE Bank_new_2(id int NOT NULL,given_date DATE,asset int,liability int)

COPY Bank_new_2 FROM 'C:\Users\91901\Downloads\banks_al_2001-1 (1).csv'DELIMITER ',' CSV HEADER
SELECT * FROM Bank_new_2;

--Creating a new table to store cleaned table (deleted duplicate rows)
DROP TABLE IF EXISTS banks_sec
CREATE TABLE banks_sec(id int NOT NULL,given_date DATE,security int)


--Deleting duplicate rows from banks sec 2002.csv--
INSERT INTO banks_sec
SELECT DISTINCT id, given_date, security FROM Bank_new


--Creating a table banks_total to save results of the join--
DROP TABLE IF EXISTS banks_total
CREATE TABLE banks_total(id int NOT NULL,given_date DATE,security int, asset int,liability int)


--Performing an inner join--
INSERT INTO banks_total
SELECT B.id, B.given_date, B.security, C.asset, C.liability
FROM banks_sec AS B
LEFT JOIN Bank_new_1 AS C
ON B.id= C.id
AND B.given_date = C.given_date;

--First 10 records from the combined datasets--
SELECT * FROM banks_total
LIMIT 10

--Setting PRIMARY KEY for banks_total table--
ALTER TABLE banks_total ADD PRIMARY KEY(id, given_date)

--How many banks have security over 20% of its’ asset for each quarter of 2002--
SELECT extract(quarter from given_date) as quarter,COUNT(*) FROM banks_total
WHERE banks_total.security > 0.20 * banks_total.asset
GROUP BY extract(quarter from given_date)
ORDER BY extract(quarter from given_date) ASC

--How many banks have liability over 90% of assets in last quarter of 2001
--but goes below 90% in first quarter of 2002--
SELECT COUNT(*) FROM
(
SELECT id FROM Bank_new_2
WHERE (liability > 0.90* asset AND given_date BETWEEN '2001-10-01' AND '2001-12-31')
INTERSECT 
SELECT id FROM banks_total WHERE (liability < 0.90*asset AND given_date BETWEEN '2002-01-01' AND '2002-03-31')
) I

--Write a function that can take the results(4 numbers) from Q4. And 
--return the mean, maximum, and minimum--
DROP FUNCTION IF EXISTS results
CREATE FUNCTION results ( a NUMERIC, 
						 b NUMERIC, 
						 c NUMERIC,
						 d NUMERIC,OUT mean int,OUT maximum NUMERIC,OUT minimum NUMERIC) AS $$
	
	BEGIN
	     mean := (a+b+c+d)/4;
		 maximum := GREATEST(a,b,c,d);
		 minimum := LEAST(a,b,c,d);
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM results(984,1023,1033,1048);


--Creating a new table to store growth rate of each bank each quarter--
DROP TABLE IF EXISTS growth_table
CREATE TABLE growth_table(id int NOT NULL,given_date DATE,asset int, quarter varchar, previous_asset float, growth_rate float)


--Calculate asset growth rate for each quarter each bank.
--This can be done in either R or SQL. The result should start from
--second quarter, since we don’t have all necessary data for first quarter calculation --

INSERT INTO growth_table
SELECT id, 
given_date,
asset as current_asset, 
extract(quarter from given_date) as quarter,
LAG(asset) OVER (PARTITION BY id) AS previous_asset
FROM banks_total

INSERT INTO growth_table
SELECT id,
given_date,
asset,
quarter,
previous_asset,
((asset-previous_asset)/previous_asset)*100 AS growth_rate
FROM growth_table


SELECT * FROM growth_table

--Report the average asset growth rate for each quarter. --
SELECT quarter, AVG(growth_rate) AS average_quarterly_growth_rate
FROM growth_table
GROUP BY quarter
ORDER BY quarter


--Creating a database--
CREATE DATABASE banking1

--Checking roles and their privileges--
SELECT * FROM pg_roles;


--Creating a table in the database for importing the joint CSV from Question1--
DROP TABLE IF EXISTS final_data
CREATE TABLE final_data (id int, given_date DATE, security numeric, asset numeric, liability numeric)

--Import CSV file into the table created--
COPY final_data FROM 'C:\Users\91901\Downloads\banks_total.csv' DELIMITER ',' CSV HEADER
SELECT * FROM final_data




