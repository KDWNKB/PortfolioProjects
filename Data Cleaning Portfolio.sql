use [Portfolio Project ]
/*

Cleaining Data in SQL Queries

*/

Select* 
FROM [Portfolio Project ]..NashvilleHousing

-----------------------------------------------------------------------------------

--Standardized Date Format 

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project ]..NashvilleHousing 

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------------------------------

--Populated Property Address Data 

Select *
From [Portfolio Project ]..NashvilleHousing 
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ]..NashvilleHousing a
Join [Portfolio Project ]..NashvilleHousing b 
	on a. ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ]..NashvilleHousing a
Join [Portfolio Project ]..NashvilleHousing b 
	on a. ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]



------------------------------------------------------------------------------------------------

--Separating "Breaking Out"  Address into Individual Columns ( Address, City, State)



Select PropertyAddress
From [Portfolio Project ]..NashvilleHousing 
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address 

From [Portfolio Project ]..NashvilleHousing 

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select*
From [Portfolio Project ]..NashvilleHousing 



Select OwnerAddress
From [Portfolio Project ]..NashvilleHousing 


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project ]..NashvilleHousing 


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



---------------------------------------------------------------------------------------------------------


--Changing Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project ]..NashvilleHousing
Group by SoldAsVacant
order by 2 


Select (SoldAsVacant)
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project ]..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




------------------------------------------------------------------------------------------------------------

--Removing Duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From [Portfolio Project ]..NashvilleHousing 
--Order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------

--Deleting Unused Columns 



Select * 
From [Portfolio Project ]..NashvilleHousing


ALTER TABLE [Portfolio Project ]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project ]..NashvilleHousing
DROP COLUMN SaleDate 
