SELECT * 
FROM PortfolioProject.nashvillehousing;

-- Change SaleDate format to MMDDYYYY

SELECT SaleDate
FROM PortfolioProject.nashvillehousing;

SELECT STR_TO_DATE(SaleDate, '%M %d, %Y') AS SaleDateDatetime
FROM PortfolioProject.nashvillehousing;

UPDATE PortfolioProject.nashvillehousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

UPDATE PortfolioProject.nashvillehousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

-- Populate Property Address Data

UPDATE PortfolioProject.nashvillehousing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT *
FROM  PortfolioProject.nashvillehousing
-- WHERE PropertyAddress is null;
order by ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM  PortfolioProject.nashvillehousing a 
JOIN PortfolioProject.nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM  PortfolioProject.nashvillehousing;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) as Address 
FROM  PortfolioProject.nashvillehousing;


ALTER TABLE PortfolioProject.nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

ALTER TABLE PortfolioProject.nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)); 

UPDATE PortfolioProject.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

UPDATE PortfolioProject.nashvillehousing
SET OwnerAddress = NULL
WHERE OwnerAddress = '';

SELECT OwnerAddress
FROM  PortfolioProject.nashvillehousing;

SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS Part3,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Part2,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Part1
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitState VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

-- Change Y and N to Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.nashvillehousing;


UPDATE PortfolioProject.nashvillehousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-- Remove Duplicates

DELETE FROM PortfolioProject.nashvillehousing
WHERE UniqueID IN (
SELECT UniqueID
FROM (
	SELECT 
		UniqueID,
        ROW_NUMBER() OVER (
			PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
			ORDER BY UniqueID
		) AS row_num
	FROM PortfolioProject.nashvillehousing
) AS RowNumCTIE
WHERE row_num > 1
);

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;

