/*
Cleaning Data in SQL Queries

Skills Used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
USE Portfolio_Projects

SELECT *
FROM Housing_Data
ORDER BY UniqueID

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

UPDATE Housing_Data
SET SaleDate = CONVERT(DATE, SaleDate) --Convert is same as CAST(SaleDate AS DATE)


-- Used ALTER TABLE cause Update doesn't work

ALTER TABLE Housing_Data
ADD Sale_Date DATE

UPDATE Housing_Data
SET Sale_Date = Convert(Date, SaleDate)


-- For Droping the SaleData Column

ALTER TABLE Housing_Data
DROP COLUMN SaleDate



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- We figure out there is connection between ParcelID and PropertyAddress
-- ParcelID is not null but Property Address is Null

SELECT PropertyAddress, ParcelID
FROM Housing_Data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID -- We can see above or below of NULL value there are matching value in ParcelID Column


--We use Join fix null with the help of matching ParcelID, and different UniqueID, and we use ISNULL to deal with null value

SELECT Prop1.ParcelID, Prop1.PropertyAddress, Prop2.ParcelID, Prop2.PropertyAddress,
ISNULL(Prop1.PropertyAddress, Prop2.PropertyAddress) AS Fixed_Null
FROM Housing_Data AS Prop1
JOIN Housing_Data AS Prop2
  ON Prop1.ParcelID = Prop2.ParcelID AND Prop1.UniqueID != Prop2.UniqueID -------------- Here we get matching rows by ParcelID, and not included single row match
-- WHERE Prop1.PropertyAddress IS NULL
--ORDER BY Prop1.ParcelID


UPDATE Prop1
SET PropertyAddress = ISNULL(Prop1.PropertyAddress, Prop2.PropertyAddress)
FROM Housing_Data AS Prop1
JOIN Housing_Data AS Prop2
  ON Prop1.ParcelID = Prop2.ParcelID AND Prop1.UniqueID != Prop2.UniqueID



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PropertyAddress

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Property_street_Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) AS Property_City_Address
FROM Housing_Data

ALTER TABLE Housing_Data
ADD Prop_Street_Add NVARCHAR(255), Prop_City_Add NVARCHAR(255)

UPDATE Housing_Data
SET Prop_Street_Add = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
Prop_City_Add = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- OwnerAddress

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Ow_Street_Add,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Ow_City_Add,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Ow_Sate_Add
FROM Housing_Data

ALTER TABLE Housing_Data
ADD Ow_Street_Add NVARCHAR(255), Ow_City_Add NVARCHAR(255), Ow_State_Add NVARCHAR(255)

UPDATE Housing_Data
SET Ow_Street_Add = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
Ow_City_Add = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
Ow_State_Add = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing_Data
GROUP BY SoldAsVacant

SELECT DISTINCT(SoldAsVacant), CASE WHEN SoldAsVacant = 'N' THEN 'No'
									WHEN SoldAsVacant = 'Y' THEN 'Yes'
									ELSE SoldAsVacant
									END AS Fixed
FROM Housing_Data

UPDATE Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
									WHEN SoldAsVacant = 'Y' THEN 'Yes'
									ELSE SoldAsVacant
									END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, SalePrice, LegalReference, Sale_Date ORDER BY ParcelID) AS Count_of_Dub
FROM Housing_Data

WITH Using_Where_and_Delete AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, SalePrice, LegalReference, Sale_Date ORDER BY ParcelID) AS Count_of_Dub
FROM Housing_Data
)
DELETE --SELECT * to see Dub
FROM Using_Where_and_Delete
WHERE Count_of_Dub > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE Housing_Data
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict