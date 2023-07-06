select * 
from portfolio_1..nashville_housing
order by 1

--format the date(SaleDate)

alter table portfolio_1..nashville_housing
alter column SaleDate date

--populate  PropertyAddress data

--where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_1..nashville_housing a
join portfolio_1..nashville_housing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_1..nashville_housing a
join portfolio_1..nashville_housing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

 --Breaking out Address into individual columns (Address,City,State)\

 select PropertyAddress
from portfolio_1..nashville_housing



alter table portfolio_1..nashville_housing
add address_  Nvarchar(255);
update portfolio_1..nashville_housing
set address_=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table portfolio_1..nashville_housing
add City  Nvarchar(255);
update portfolio_1..nashville_housing
set City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

--looking at OwnerAddress
select * 
from portfolio_1.dbo.nashville_housing

---------------
select distinct
PARSENAME(replace(OwnerAddress,',','.'),1)
from portfolio_1.dbo.nashville_housing
-------------- there is no states known except 'TN'

-- change Y & N to yes & no in SoldAsVacant

select distinct SoldAsVacant
from portfolio_1.dbo.nashville_housing


select SoldAsVacant,
case
when  SoldAsVacant ='N' then 'No'
when SoldAsVacant ='Y' then 'Yes'
else SoldAsVacant
end
from portfolio_1.dbo.nashville_housing

update portfolio_1.dbo.nashville_housing
set SoldAsVacant=case
when  SoldAsVacant ='N' then 'No'
when SoldAsVacant ='Y' then 'Yes'
else SoldAsVacant
end

--------------------------------
--Removing Duplicates

--first take alook at the duplicated rows
with my_temp as (
select *,
ROW_NUMBER()over(partition by ParcelID,LandUse,PropertyAddress ,LegalReference
order by (UniqueID))as row_number

from portfolio_1.dbo.nashville_housing)
select* 
from my_temp
where row_number>1

--to deleat duplicates
with my_temp as (
select *,
ROW_NUMBER()over(partition by ParcelID,LandUse,PropertyAddress ,LegalReference
order by (UniqueID))as row_number

from portfolio_1.dbo.nashville_housing)
delete
from my_temp
where row_number>1

--Delete Unused Columns]
select*
from portfolio_1.dbo.nashville_housing

alter table Portfolio_1..nashville_housing
drop column TaxDistrict,OwnerAddress,PropertyAddress