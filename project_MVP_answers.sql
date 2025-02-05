SELECT *
FROM prescriber;

SELECT *
FROM overdose_deaths;

-- WITH drug_info AS 
	




-- 1. 
	--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	    		SELECT
	npi,
	SUM(b.total_claim_count) as t
	
	FROM prescriber AS a


INNER JOIN prescription AS b
USING(npi)
GROUP BY npi
ORDER BY t DESC
LIMIT 1;
	--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

		SELECT
	a.nppes_provider_first_name,
	a.nppes_provider_last_org_name,
	a.nppes_credentials,
	specialty_description,
	npi,
	SUM(b.total_claim_count) as t
	
	FROM prescriber AS a


INNER JOIN prescription AS b
USING(npi)
GROUP BY npi, 	
	a.nppes_provider_first_name,
	a.nppes_provider_last_org_name,
	a.nppes_credentials,
	specialty_description
ORDER BY t DESC
LIMIT 1;

-- 2. 
	--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(total_claim_count) as all_claims
FROM prescription
-- 36220800
	--     b. Which specialty had the most total number of claims for opioids?
WITH drug_list AS (WITH specialty AS (
	
	SELECT DISTINCT
	s.specialty_description,
	s.npi
	FROM prescriber as s
)

SELECT DISTINCT
	npi,
	p.drug_name,
	s.specialty_description
	FROM prescription as p

	LEFT JOIN specialty as s
	USING (npi)
	
)
SELECT DISTINCT d.specialty_description,
COUNT(d.drug_name) as amt_of_claims

FROM drug as b
LEFT JOIN drug_list as d
USING(drug_name)
WHERE b.opioid_drug_flag = 'Y'
GROUP BY d.specialty_description
ORDER BY amt_of_claims DESC


-- Nurse Practitioner - 9551

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

WITH drug_list AS (WITH specialty AS (
	
	SELECT DISTINCT
	s.specialty_description,
	s.npi
	FROM prescriber as s
)

SELECT DISTINCT
	npi,
	p.drug_name,
	s.specialty_description
	FROM prescription as p

	LEFT JOIN specialty as s
	USING (npi)
	
)
SELECT DISTINCT d.specialty_description, d.drug_name
FROM drug as b
LEFT JOIN drug_list as d
USING(drug_name)
WHERE d.drug_name IS NULL

-- 1

	
	--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

WITH total_cost AS (SELECT
	p.drug_name,
	ROUND(p.total_drug_cost, 2) as total_drug
FROM prescription as p)

SELECT
DISTINCT d.generic_name,
t.total_drug
FROM drug as d

LEFT JOIN total_cost as t
ON t.drug_name = d.generic_name
WHERE t.total_drug IS NOT NULL
ORDER BY t.total_drug DESC;
-- "BEXAROTENE" - 2106640.59

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

WITH total_cost AS (SELECT
	p.drug_name,
	ROUND(p.total_drug_cost, 2) as total_drug
FROM prescription as p)

SELECT
DISTINCT ON drug_name,
t.total_drug/30
FROM drug as d

LEFT JOIN total_cost as t
USING(drug_name)
WHERE t.total_drug IS NOT NULL
GROUP BY drug_name, t.total_drug
ORDER BY t.total_drug DESC;

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT drug_name,
       CASE
           WHEN opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
           ELSE 'neither'
       END AS drug_type
FROM drug;


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- 5.
-- a. How many CBSAs are in Tennessee?
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

-- b. Which CBSA has the largest combined population? Which has the smallest?
SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
GROUP BY cbsaname
ORDER BY total_population DESC
LIMIT 1;

SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
GROUP BY cbsaname
ORDER BY total_population ASC
LIMIT 1;

-- c. What is the largest (in terms of population) county which is not included in a CBSA?
SELECT county, SUM(population) AS total_population
FROM fips_codes
WHERE fipscounty NOT IN (SELECT fipscounty FROM cbsa)
GROUP BY county
ORDER BY total_population DESC
LIMIT 1;


-- 6.
-- a. Find all rows in the prescription table where total_claims is at least 3000.
SELECT drug_name, SUM(total_claim_count) as total_claim_count
FROM prescription
GROUP BY drug_name
HAVING SUM(total_claim_count) >= 3000;

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT p.drug_name, SUM(p.total_claim_count) as total_claim_count,
       CASE WHEN d.opioid_drug_flag = 'Y' THEN 'Yes' ELSE 'No' END AS is_opioid
FROM prescription p
JOIN drug d ON p.drug_name = d.drug_name
GROUP BY p.drug_name, d.opioid_drug_flag
HAVING SUM(p.total_claim_count) >= 3000;

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT p.drug_name, SUM(p.total_claim_count) as total_claim_count,
       CASE WHEN d.opioid_drug_flag = 'Y' THEN 'Yes' ELSE 'No' END AS is_opioid,
       pr.nppes_provider_first_name, pr.nppes_provider_last_name
FROM prescription p
JOIN drug d ON p.drug_name = d.drug_name
JOIN prescriber pr ON p.npi = pr.npi
GROUP BY p.drug_name, d.opioid_drug_flag, pr.nppes_provider_first_name, pr.nppes_provider_last_name
HAVING SUM(p.total_claim_count) >= 3000;


-- 7.
-- a. First, create a list of all npi/drug_name combinations for pain management specialists in Nashville, where the drug is an opioid.
SELECT p.npi, d.drug_name
FROM prescriber p
JOIN drug d ON p.npi = d.npi -- Assuming a common column like npi exists in 'drug' table. If the connection is via drug_name, adjust it.
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y';

-- b. Next, report the number of claims per drug per prescriber.
SELECT p.npi, d.drug_name, COUNT(pr.total_claim_count) as total_claim_count
FROM prescriber p
JOIN drug d ON p.npi = d.npi -- Assuming a common column like npi exists in 'drug' table. If the connection is via drug_name, adjust it.
LEFT JOIN prescription pr ON p.npi = pr.npi AND d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y'
GROUP BY p.npi, d.drug_name;

-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
SELECT p.npi, d.drug_name, COALESCE(SUM(pr.total_claim_count), 0) AS total_claim_count
FROM prescriber p
JOIN drug d ON p.npi = d.npi -- Assuming a common column like npi exists in 'drug' table. If the connection is via drug_name, adjust it.
LEFT JOIN prescription pr ON p.npi = pr.npi AND d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management'
  AND p.nppes_provider_city = 'NASHVILLE'
  AND d.opioid_drug_flag = 'Y'
GROUP BY p.npi, d.drug_name;