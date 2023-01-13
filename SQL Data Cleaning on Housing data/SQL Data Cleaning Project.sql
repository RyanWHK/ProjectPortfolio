-- Cleaning Data in SQL Queries

SELECT *
FROM "Nashville Housing"

-- Standardize SaleData Format 

SELECT CAST("SaleDate" AS Date) -- OR "SaleDate"::Date 
FROM "Nashville Housing"

UPDATE "Nashville Housing"
SET "SaleDate" = CAST("SaleDate" AS Date)

-- If not working we can use ALTER TABLE 
-- ALTER Table "Nashville Housing"
-- add SaleDateConverted
-- 
-- Update "Nashville Housing"
-- Set "SaleDateConverted" = cast("SaleDate" as Date)


--Populate Property Address date

SELECT "a"."ParcelID", "a"."PropertyAddress", "b"."ParcelID", "b"."PropertyAddress"
, COALESCE("a"."PropertyAddress", "b"."PropertyAddress") --ISNULL() for MS SQL
FROM "Nashville Housing" AS a
JOIN "Nashville Housing" AS b
    ON "a"."ParcelID" = "b"."ParcelID" 
    AND "a"."UniqueID" <> "b"."UniqueID" -- <> = IS NOT EQUAL
WHERE "a"."PropertyAddress" IS NULL

-- For Postgre
UPDATE "Nashville Housing"  a
SET "PropertyAddress" = COALESCE("a"."PropertyAddress", "b"."PropertyAddress")
FROM "Nashville Housing" AS b
WHERE a."PropertyAddress" IS NULL 
AND a."ParcelID" = "b"."ParcelID"  
AND "a"."UniqueID" <> "b"."UniqueID"

-- For MS SQL
-- Update a
-- set "PropertyAddress" = isnull("a"."PropertyAddress", "b"."PropertyAddress")
-- from "Nashville Housing" as a
-- join "Nashville Housing" as b
--     on "a"."ParcelID" = "b"."ParcelID"  
--     and "a"."UniqueID" <> "b"."UniqueID" -- <> = IS NOT EQUAL
-- where "a"."PropertyAddress" is NULL

-- Breaking out Address into Individual Columns (Address, City, State) 
SELECT "PropertyAddress"
FROM "Nashville Housing"

-- Select 
-- SUBSTRINg("PropertyAddress", 1, strpos("PropertyAddress",',') -1) as Address -- -1 for comma
-- , SUBSTRINg("PropertyAddress", strpos("PropertyAddress",',') +1, length("PropertyAddress")) as City
-- from "Nashville Housing"

SELECT split_part("PropertyAddress",',',1) AS Address
, split_part("PropertyAddress",',',2) AS City
FROM "Nashville Housing"

ALTER TABLE "Nashville Housing"
ADD PropertySplitAddress VARCHAR(255); 

UPDATE "Nashville Housing"
SET PropertySplitAddress = split_part("PropertyAddress",',',1)

ALTER TABLE "Nashville Housing"
ADD PropertySplitCity VARCHAR(255);

UPDATE "Nashville Housing"
SET PropertySplitCity = split_part("PropertyAddress",',',2)

SELECT * 
FROM "Nashville Housing"

-- Change Owner address to address, city, state

SELECT "OwnerAddress"
FROM "Nashville Housing"

SELECT split_part("OwnerAddress",',',1) AS Address
, split_part("OwnerAddress",',',2) AS City
,split_part("OwnerAddress",',',3) AS State
FROM "Nashville Housing"


ALTER TABLE "Nashville Housing"
ADD OwnerSplitAddress VARCHAR(255); 

ALTER TABLE "Nashville Housing"
ADD OwnerSplitCity VARCHAR(255); 

SELECT * FROM "Nashville Housing"

ALTER TABLE "Nashville Housing"
ADD OwnerSplitState VARCHAR(255); 

UPDATE "Nashville Housing"
SET OwnerSplitAddress = split_part("OwnerAddress",',',1)

UPDATE "Nashville Housing" 
SET OwnerSplitCity = split_part("OwnerAddress",',',2)

UPDATE "Nashville Housing"
SET OwnerSplitState = split_part("OwnerAddress",',',3)


-- change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT("SoldAsVacant"), count("SoldAsVacant")
FROM "Nashville Housing"
GROUP BY "SoldAsVacant"
ORDER BY 2

SELECT "SoldAsVacant"
,   CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
         WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END 
FROM "Nashville Housing"

UPDATE "Nashville Housing"
SET "SoldAsVacant" = CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
         WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END 
    
    
-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
    row_number() OVER (
    PARTITION BY "ParcelID", 
                 "PropertyAddress", 
                 "SalePrice", 
                 "SaleDate", 
                 "LegalReference"
                 ORDER BY "UniqueID"
                ) row_num
FROM "Nashville Housing"
ORDER BY "ParcelID"
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY "PropertyAddress"
-- Delete from RowNumCTE where row_num >1   DID NOT WORK with postgre


-- Delete Unused Columns

SELECT *
FROM "Nashville Housing"

ALTER TABLE "Nashville Housing"
DROP COLUMN "PropertyAddress",
DROP COLUMN "TaxDistrict",
DROP COLUMN "OwnerAddress"

