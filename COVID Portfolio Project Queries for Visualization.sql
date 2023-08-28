--QUERIES FOR VISUALIZATION

--#1. Global Totals

Select SUM(New_Cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
Order by 1, 2


--#2. Death Count by Continent
	-- World, EU, and International are taken out beacuse these numbers are not included in the above query
	-- EU is part of Europe, it doesn't get its own category

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is null
	AND location NOT IN ('World', 'European Union', 'International')
Group by Location
Order by TotalDeathCount desc


--#3. Countries with Highest Infection Rate Compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc


--#4. Shows rolling Percent Population Infected

Select Location, Population, Date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population, Date
Order by PercentPopulationInfected desc

Select Location, Population, Date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
WHERE total_cases is null
Group by Location, Population, Date
Order by PercentPopulationInfected desc
