
-- Question 2: SQL and Databases
-- Data Engineer Intern Assignment - Affinity Answers
--
-- Database: Rfam Public Database (MySQL)
-- Reference: https://docs.rfam.org/en/latest/database.html
--
-- Note:
-- I initially used MySQL Workbench to execute these queries.
-- Questions 1 and 2 executed successfully.
--
-- However, the third query repeatedly failed with Error 2013
-- (Lost connection to MySQL server during query).
--
-- I first encountered the error after 30 seconds.
-- Increasing the Workbench read timeout to 120 seconds
-- did not resolve the problem.
--
-- To investigate, I tested the third query with smaller
-- ranges of family accession IDs. These queries worked,
-- which confirmed that the JOIN and aggregation logic was valid.
--
-- I then switched to MySQL CLI to avoid Workbench's
-- configured read timeout.
--
-- The complete query executed successfully through MySQL CLI
-- and returned 15 rows in 7 minutes and 57.40 seconds.


-- =====================================================
-- Question 2.1
-- How many types of Acacia plants are in the taxonomy table?
-- =====================================================

-- Find records where the species name starts with "Acacia ".
-- COUNT(*) returns the total number of matching records.

SELECT COUNT(*) AS acacia_count
FROM taxonomy
WHERE species LIKE 'Acacia %';

-- Result: 326 matching taxonomy records.


-- =====================================================
-- Question 2.2
-- Which type of wheat has the longest DNA sequence?
-- =====================================================

-- The taxonomy table contains species names.
-- The rfamseq table contains sequence information.
--
-- Both tables have the ncbi_id column.
-- We use this column to join them.
--
-- Triticum is the genus that includes wheat.
-- We filter for DNA molecule types and sort by length
-- in descending order.
-- LIMIT 1 returns the longest matching sequence.

SELECT
    t.species,
    r.length,
    r.mol_type
FROM taxonomy t
JOIN rfamseq r
    ON t.ncbi_id = r.ncbi_id
WHERE t.species LIKE 'Triticum %'
    AND r.mol_type LIKE '%DNA%'
ORDER BY r.length DESC
LIMIT 1;

-- Result:
-- Species: Triticum durum (durum wheat)
-- Sequence Length: 836514780
-- Molecule Type: genomic DNA


-- =====================================================
-- Question 2.3
-- Find families and their longest DNA sequence lengths.
--
-- Requirements:
-- 1. Maximum sequence length greater than 1,000,000.
-- 2. Sort by sequence length in descending order.
-- 3. Return family accession, name and maximum length.
-- 4. Return page 9 with 15 records per page.
-- =====================================================

-- Three tables are used:
--
-- family:
-- Contains the family accession and family name.
--
-- full_region:
-- Connects families to their associated sequences.
--
-- rfamseq:
-- Contains sequence lengths and molecule types.
--
-- JOIN connects the tables using their common columns.
--
-- WHERE removes sequences with length <= 1000000
-- and filters for DNA molecule types.
--
-- GROUP BY groups sequences belonging to each family.
--
-- MAX() finds the longest sequence for each family.
--
-- ORDER BY sorts the results from longest to shortest.
-- rfam_acc is used as a second sorting column
-- when multiple families have the same maximum length.
--
-- Pagination:
-- Page number = 9
-- Records per page = 15
-- OFFSET = (9 - 1) * 15 = 120
--
-- LIMIT 15 OFFSET 120 skips the first 120 records
-- and returns the next 15 records.

SELECT
    f.rfam_acc,
    f.rfam_id,
    MAX(r.length) AS max_sequence_length
FROM family f
JOIN full_region fr
    ON f.rfam_acc = fr.rfam_acc
JOIN rfamseq r
    ON fr.rfamseq_acc = r.rfamseq_acc
WHERE r.length > 1000000
    AND r.mol_type LIKE '%DNA%'
GROUP BY f.rfam_acc, f.rfam_id
ORDER BY max_sequence_length DESC, f.rfam_acc ASC
LIMIT 15 OFFSET 120;

-- Result: 15 rows returned successfully.
-- Execution time using MySQL CLI: 7 min 57.40 sec.