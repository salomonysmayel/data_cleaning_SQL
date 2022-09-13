/* For some sales, the "PropertyAddress" is empty, to work with that column is better to change it to null*/

UPDATE nashville_housing3
SET PropertyAddress = NULLIF(PropertyAddress, '')

/* Joining the table to itself on ParcelID, this give us the address that should go on the null cell. This may have happened because
 * once a property has an address, for the next entry of that same property they skipped adding again the address.
 */

Select a.UniqueID ,a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_housing3 AS a
JOIN nashville_housing3 AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_housing3 AS a
JOIN nashville_housing3 AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID

/*To fill PropertyAddress null entries */

UPDATE nashville_housing3 
SET PropertyAddress = "109  CEDAR PLACE BND, NASHVILLE"
WHERE UniqueID =51703

/* To select everything before the comma in the string PropertyAddress, after the comma we have the city for all entries, we use the -1 to not include the comma in the output */

SELECT 
SUBSTRING(PropertyAddress,1,POSITION("," IN PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress,POSITION("," IN PropertyAddress)+1,LENGTH(PropertyAddress)) AS CITY
FROM nashville_housing3


/*SELECT LENGTH(PropertyAddress)
FROM nashville_housing3*/

/*Create new column for split address*/

ALTER TABLE nashville_housing3
Add PropertySplitAddress Nvarchar(255);

/*Filling PropertySplitAddress column */

UPDATE nashville_housing3
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,POSITION("," IN PropertyAddress)-1)

SELECT * FROM nashville_housing3 

/*Create new column for split city*/

ALTER TABLE nashville_housing3
Add PropertySplitCity Nvarchar(255);

/*Filling PropertySplitAddress column */

UPDATE nashville_housing3
SET PropertySplitCity = SUBSTRING(PropertyAddress,POSITION("," IN PropertyAddress)+1,LENGTH(PropertyAddress))	

/* To split the owner's address*/

Select
SUBSTRING_INDEX(OwnerAddress,',',1) AS part1,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) AS part2,
SUBSTRING_INDEX(OwnerAddress,',',-1) AS part3
From nashville_housing3

/*Creating and filling new columns for owner address*/

ALTER TABLE nashville_housing3
Add OwnerSplitAddress Nvarchar(255)

UPDATE nashville_housing3
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1) 

/*Creating and filling new columns for owner city*/

ALTER TABLE nashville_housing3
Add OwnerSplitCity Nvarchar(255)

UPDATE nashville_housing3
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1)

/*Creating and filling new columns for owner state*/

ALTER TABLE nashville_housing3
Add OwnerSplitState Nvarchar(255)

UPDATE nashville_housing3
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1)


/*Changing SoldAsVacant to YES and NO, because there are some entries with Y and Ns
 * First we viz and count all distinct values*/

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville_housing3 nh 
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing3

-- Creating a CTE to shoe the row number over a partition of a selection of columns, if row number > 1 then the row is repeated 

WITH row_num_cte AS(
SELECT *, ROW_NUMBER()  OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) num_rows
FROM nashville_housing3)

Select *
From row_num_cte
Where num_rows > 1
Order by PropertyAddress


Update nashville_housing3 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No
	   ELSE SoldAsVacant
	   END





