-- Creating a Table to import CSV --
CREATE TABLE My_Bank_2001(id varchar, Date date, asset numeric, liablity numeric )

--Importing CSV --
COPY My_Bank_2001 FROM 'C:\Users\91901\Downloads\banks_al_2001.csv' DELIMITER ',' CSV HEADER
--Display the CSV --
select * from My_Bank_2001

--Renaming ID Column to avoid confusion--
ALTER TABLE My_Bank_2001
RENAME COLUMN id TO given_id;

--Renaming date Column to avoid confusion--
ALTER TABLE My_Bank_2001
RENAME COLUMN date TO given_date;

-- Display ID for banks with second largest asset for second quarter--
SELECT given_id
FROM My_Bank_2001
WHERE My_Bank_2001.given_date BETWEEN '2001-04-01' AND '2001-06-30'
AND My_Bank_2001.asset NOT IN(SELECT MAX(asset) FROM My_Bank_2001)
ORDER BY My_Bank_2001.asset DESC
LIMIT 1 OFFSET 1


--Count number of banks for each quarter with one query-
SELECT extract(quarter from given_date) as quarter, count(given_id)
FROM My_Bank_2001
GROUP BY quarter
ORDER BY quarter ASC

--Count the number of banks whose equity is over 10% of its asset in the first quarter(hint: equity = asset-liability)--
SELECT COUNT(given_id)
FROM My_Bank_2001
WHERE ((My_Bank_2001.asset-My_Bank_2001.liablity)/My_Bank_2001.asset)>0.1 AND My_Bank_2001.given_date <= '2001-03-31';




--What is the average liability value for banks whose asset is higher than average asset value in first quarter. Complete this task in one query.(subquery)--
SELECT AVG(liablity)
FROM My_Bank_2001
WHERE My_Bank_2001.asset > (SELECT AVG(asset) FROM My_Bank_2001) AND My_Bank_2001.given_date <= '2001-03-31';


