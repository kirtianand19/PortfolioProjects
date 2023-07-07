/*

Cleaning Data in SQL Queries

*/

select*from dbo.NashvilleHousing;

-- Standardize Date Format

select SaleDateConverted, convert(date,saledate) from dbo.NashvilleHousing;

Update NashvilleHousing set SaleDate=CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted= convert(date,saledate)

--Populate Property Address data

select*from dbo.NashvilleHousing --where PropertyAddress is null
order by ParcelID;

Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]!=b.[UniqueID ] 
where a.PropertyAddress is null;


Update a 
set propertyaddress= ISNULL(a.propertyaddress,b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing b 
on a.ParcelID=b.ParcelID and a.[UniqueID ]!=b.[UniqueID ] 
where a.PropertyAddress is null;

--Breaking out address into individual columns (Address, City, State)


select propertyaddress from dbo.NashvilleHousing;

select SUBSTRING(propertyaddress,1, charindex(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as address
from dbo.NashvilleHousing;

--Select propertyaddress, len(propertyaddress) from dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add PropertySplitAddress varchar(255);

Update NashvilleHousing
set PropertySplitAddress= SUBSTRING(propertyaddress,1, charindex(',',propertyaddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity varchar(255);

Update NashvilleHousing
set PropertySplitCity= SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress));

Select*from dbo.NashvilleHousing;



select owneraddress from dbo.NashvilleHousing;

Select
PARSENAME(REPLACE(owneraddress,',','.'),1),
PARSENAME(REPLACE(owneraddress,',','.'),2) ,
PARSENAME(REPLACE(owneraddress,',','.'),3) 
from dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add Owner_Split_Address varchar(255);

Update NashvilleHousing
set Owner_Split_Address= PARSENAME(REPLACE(owneraddress,',','.'),3)

Alter Table NashvilleHousing
Add Owner_Split_City varchar(255);

Update NashvilleHousing
set Owner_Split_City= PARSENAME(REPLACE(owneraddress,',','.'),2);


Alter Table NashvilleHousing
Add Owner_Split_State varchar(255);

Update NashvilleHousing
set Owner_Split_State = PARSENAME(REPLACE(owneraddress,',','.'),1)



--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(soldasVacant), Count(*)
from dbo.NashvilleHousing group by SoldAsVacant order by 2;

select soldasVacant, case when soldasVacant = 'Y' then 'Yes'
when soldasVacant = 'N' then 'No'
Else Soldasvacant
end
from dbo.NashvilleHousing;

Update NashvilleHousing
set SoldAsVacant= case when soldasVacant = 'Y' then 'Yes'
when soldasVacant = 'N' then 'No'
Else Soldasvacant
end
from dbo.NashvilleHousing;

-- Remove Duplicates

With RowNumCTE AS(Select*,ROW_NUMBER() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid) AS row_num
from dbo.NashvilleHousing)
Delete FROM RowNumCTE WHERE row_num >1; --ORDER BY PROPERTYADDRESS;

-- Delete Unused Columns

Select*from dbo.NashvilleHousing;

Alter Table NashvilleHousing
Drop column owneraddress,taxdistrict,propertyaddress

Alter Table NashvilleHousing
Drop column saledate