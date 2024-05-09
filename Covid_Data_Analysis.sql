

Select * from Portfolio_Project..CovidDeaths
where continent is not null
Order by 3,4 

--Select * from Portfolio_Project..CovidVaccines
--Order by 3,4


Select location,date,total_cases,new_cases,population
from Portfolio_Project..CovidDeaths
where continent is not null
Order by 1,2


--Total Cases VS Total Deaths in India
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%india%'
Order by 1,2

--Total Cases VS Population

Select location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
from Portfolio_Project..CovidDeaths
where location like '%india%'
and continent is not null
Order by 1,2

--Highest Infection Rates Compared to Population
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100  as InfectedPercentage

from Portfolio_Project..CovidDeaths
group by location,population
Order by InfectedPercentage desc

--Countries with Highest Death Count Per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
Order by TotalDeathCount desc

--Looking by Continents
  
  --Continents with Highest Death Count 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
Order by TotalDeathCount desc

--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100  as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
group by date 
order by 1,2

--Total Deaths Percentages

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100  as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
--group by date 
order by 1,2


--Total Population Vs Vaccination

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated,

(RollingPeopleVaccinated/population)*100

From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE of CTE

WITH PopVsVacc AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM
        Portfolio_Project..CovidDeaths dea
    JOIN
        Portfolio_Project..CovidVaccines vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVacc
FROM PopVsVacc



--Temp Table

drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric)


 Insert into #PercentPopulationVaccinated
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM
        Portfolio_Project..CovidDeaths dea
    JOIN
        Portfolio_Project..CovidVaccines vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVacc
FROM #PercentPopulationVaccinated


--Create View For Visualization


create view PercentPopulationVaccinated as
 SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM
        Portfolio_Project..CovidDeaths dea
    JOIN
        Portfolio_Project..CovidVaccines vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
	

	select*from PercentPopulationVaccinated
