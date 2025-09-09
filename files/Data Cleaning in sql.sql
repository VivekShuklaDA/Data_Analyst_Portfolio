-- Create empty cleaned table with same structure
SELECT * 
INTO NashvilleHousingCleaned 
FROM Project..NashvilleHousing 
WHERE 1 = 0;

-- Data exploration
SELECT * FROM Project..NashvilleHousing;
SELECT * FROM NashvilleHousingCleaned;


 -- STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(DATE, SaleDate) AS SALE_DATE 
FROM Project..NashvilleHousing;

ALTER TABLE Project..NashvilleHousing
ADD SalesDate DATE;

UPDATE Project..NashvilleHousing
SET SalesDate = CONVERT(DATE, SaleDate);

 -- POPULATE MISSING PROPERTY ADDRESSES

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS SuggestedAddress
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Update missing addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Project..NashvilleHousing;

ALTER TABLE Project..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Project..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Owner Address splitting

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Project..NashvilleHousing;

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Project..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- STANDARDIZE "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Standardize Y/N to Yes/No

--UPDATE Project..NashvilleHousing
--SET SoldAsVacant = CASE 
--    WHEN SoldAsVacant = 'Y' THEN 'Yes'
--    WHEN SoldAsVacant = 'N' THEN 'No'
--    ELSE SoldAsVacant
--END;   

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project..NashvilleHousingCleaned
GROUP BY SoldAsVacant
ORDER BY 2;

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Project..NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

-- Delete Unused Columns

ALTER TABLE Project..NashvilleHousing
DROP COLUMN PropertySplitAddress,
			PropertySplitCity,
			OwnerSplitAddress,
			OwnerSplitCity,
			OwnerSplitState,
			SalesDate;

----------------------------------------------------------------------------------------------------------------------------------------------
  
  --COPY DATA TO CLEANED TABLE

ALTER TABLE NashvilleHousingCleaned 
ADD (
    PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255),
    OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255),
    SalesDate DATE);

     
 INSERT INTO NashvilleHousingCleaned (
    UniqueID,
    ParcelID,
    LandUse,
	PropertyAddress,
	SaleDate,
    SalePrice,
    LegalReference,
    SoldAsVacant,
	OwnerName,
	OwnerAddress,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath,
	PropertySplitAddress,
    PropertySplitCity,
    OwnerSplitAddress,
    OwnerSplitCity,
    OwnerSplitState,
	SalesDate
	)
SELECT
    UniqueID,
    ParcelID,
    LandUse,
	PropertyAddress,
	SaleDate,
    SalePrice,
    LegalReference,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant,
    OwnerName,
	OwnerAddress,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath,
	PropertySplitAddress,
	PropertySplitCity,
	OwnerSplitAddress,
    OwnerSplitCity,
    OwnerSplitState,
	SalesDate
FROM Project..NashvilleHousing;

