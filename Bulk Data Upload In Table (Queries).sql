
-- security permission on to other file upload from computer
SET GLOBAL local_infile = 1;

-- 1. SPEED BADHANE WALI SETTINGS 
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- 2. DATA LOAD KARNE KA COMMAND
LOAD DATA LOCAL INFILE "C:/Users/nehas/Downloads/Grocery Sales Database/sales.csv"  
INTO TABLE sales                             
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;                                   -- (Ye pehli line (headers) ko chhod dega)

-- 3. FINAL SAVE AUR SETTINGS WAPAS ON
COMMIT;
SET unique_checks = 1;
SET foreign_key_checks = 1;
SET autocommit = 1;

--         AFTER
-- COMMIT;
-- SET unique_checks = 0;
-- SET foreign_key_checks = 0;
-- SET autocommit = 0;

