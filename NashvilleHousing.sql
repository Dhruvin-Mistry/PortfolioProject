--

Alter Table Nashville
Add SalesDateNew Date ;
Update Nashville
set SalesDateNew = Convert(date,SaleDate);

Select *from Nashville;


-----Populating the PropertyAddress
--We will be populating address based on ParcelID 

select a.ParcelID, a.PropertyAddress, b.ParcelID,  b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------Breaking Address into Two Columns (Address,City, State)

Select PropertyAddress
from Nashville

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1 ) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from Nashville

Alter Table Nashville
Add PropertySplitAddress Nvarchar(255) ;


Update Nashville
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1 );

Alter Table Nashville
Add PropertySplitCity nvarchar(255);

Update Nashville
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

---Same thing for Owner Address

Select OwnerAddress
From Nashville

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from Nashville

Alter Table Nashville
Add OwnerSplitAddress Nvarchar(255) ;

Update Nashville
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);


Alter Table Nashville
Add OwnerSplitCity nvarchar(255);

Update Nashville
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);


Alter Table Nashville
Add OwnerSplitState nvarchar(255);

Update Nashville
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

select * from Nashville


----Changing Y and N to Yes and No in Sold As Vacant

select Distinct(SoldAsVacant)
from Nashville

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
from Nashville

Update Nashville
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END


---Remove Duplicates
 
With row_numCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueId
					) row_num
From Nashville)


Delete  from row_numCTE
where row_num>1

----------Delete Unused columns

Alter table Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table Nashville
drop column SaleDate
