/*

Cleaning Data in SQL Queries

*/
SET SQL_SAFE_UPDATES = 0;
Use housing;

Select *
From housingdata;



-- Standardize Date Format

SELECT Saledate, STR_TO_DATE(Saledate, '%M %e, %Y')
FROM housingdata;

Update housingdata
Set Saledate = STR_TO_DATE(Saledate, '%M %e, %Y');



-- Populate Property Address data

update housingdata
SET PropertyAddress = null
WHERE PropertyAddress = '' ;

Select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID
From housingdata as a
Join housingdata as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null;

UPDATE housingdata a
JOIN housingdata b
ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;




-- Breaking out PropertyAddress into Individual Columns (Address, City)

Select PropertyAddress, substring(Propertyaddress, 1, locate(',', Propertyaddress) - 1) AS PropertyAddtressAltered,
substring(Propertyaddress, locate(',', Propertyaddress) + 1) AS PropertyCityAltered
From housingdata;

Alter table housingdata
ADD PropertyAddtressAltered varchar(255),
ADD PropertyCityAltered VARCHAR(255)
;

UPDATE housingdata
SET PropertyAddtressAltered = substring(Propertyaddress, 1, locate(',', Propertyaddress) - 1),
    PropertyCityAltered = substring(Propertyaddress, locate(',', Propertyaddress) + 1);

-- Breaking out OwnerAddress into Individual Columns (Address, City, State)

SELECT
  SUBSTRING_INDEX(Owneraddress, ',', 1) AS address,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 2), ',', -1) AS city,
  SUBSTRING_INDEX(Owneraddress, ',', -1) AS state
FROM 
  housingdata;

Alter table housingdata
add owneraddressaltered varchar(255),
add ownercity varchar(255),
add ownerstate varchar(255);

update housingdata
set owneraddressaltered = SUBSTRING_INDEX(Owneraddress, ',', 1),
    ownercity = SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 2), ',', -1) ,
    ownerstate = SUBSTRING_INDEX(Owneraddress, ',', -1) 
;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct soldasvacant, count(SoldAsVacant)
from housingdata
group by SoldAsVacant;

UPDATE housingdata
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;


-- Remove Duplicates


with cte1 as(
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY parcelid,
                                  SaleDate,
                                  Saleprice,
                                  Legalreference,
                                  Ownername
                     ORDER BY ParcelID) AS row_num
FROM housingdata)
select *
from cte1
where row_num >= 2;


DELETE housingdata
FROM housingdata
JOIN (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, SaleDate, Saleprice, Legalreference, Ownername ORDER BY ParcelID) AS row_num
  FROM housingdata
) cte1 ON housingdata.UniqueID = cte1.uniqueid
WHERE cte1.row_num >= 2;



Select * From housingdata;
-- Delete Unused Columns

Alter table housingdata
drop column OwnerAddress,
drop column PropertyAddress;


