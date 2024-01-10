/*
    CLEANING DATA IN SQL queries
*/

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

--Convert Datetime format to Date

SELECT SaleDate, CAST(SaleDate AS DATE)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- Populate Property Address

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY parcelID

SELECT a.parcelID,a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
    ON a.parcelID = b.parcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
    ON a.parcelID = b.parcelID
    AND a.UniqueID <> b.UniqueID

-- Breaking out Propeerty Address Into Individual Columns (Address, City)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY parcelID

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing

-- Breaking out Owner Address Into Individual Columns (Address, City, States)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitSates NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitSates = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)

-- Change Y and N to Yes and No in 'SoldAsVacant' column 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END

-- Removing Duplicates

WITH RowNumCte AS
(
    SELECT*, ROW_NUMBER() OVER
    (
        PARTITION BY ParcelId, 
                    PropertyAddress, 
                    SaleDate,
                    SalePrice,
                    LegalReference
        ORDER BY UniqueId
    ) AS Row_Num
    FROM PortfolioProject.dbo.NashvilleHousing
)

-- SELECT*
-- FROM RowNumCte
-- WHERE Row_Num > 1 

DELETE
FROM RowNumCte
WHERE Row_Num > 1

-- Delete Unused Columns

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, PropertyAddress, TaxDistrict
