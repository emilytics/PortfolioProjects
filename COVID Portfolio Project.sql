Select *
From CovidDeaths$
Where continent is not null
Order by 3,4

--Select *
--From CovidVaccinations$
--Order by 3,4

-- Select Data that we want to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of deaths per total cases by country (ex: United States)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%states%'
	and continent is not null
Order by 1, 2

--Looking at Total Cases vs Population
-- Shows percentage of population that got Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
Order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

--By date
Select date, SUM(New_Cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group By date
Order by 1, 2

--Totals
Select SUM(New_Cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
Order by 1, 2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinated/population)*100
From CovidDeaths$ dea
Inner Join CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2, 3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinated/population)*100
From CovidDeaths$ dea
Inner Join CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Alternatively, TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinated/population)*100
From CovidDeaths$ dea
Inner Join CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinated/population)*100
From CovidDeaths$ dea
Inner Join CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2, 3


Select *
From PercentPopulationVaccinated